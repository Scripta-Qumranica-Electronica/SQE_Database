#ifdef STANDARD
/* STANDARD is defined. Don't use any MySQL functions */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
// #ifdef __WIN__
// typedef unsigned __int64 ulonglong;     /* Microsoft's 64 bit types */
// typedef __int64 longlong;
// #else
typedef unsigned long long ulonglong;
typedef long long longlong;
// #endif /*__WIN__*/
#else
#include <my_global.h>
#include <my_sys.h>
#endif
#include <mysql.h>
#include <ctype.h>
#include <stdint.h>

// endian.h is not portable. I preferred this here to undefined behavior.
// If a more portable solution is needed, see e.g.: https://gist.github.com/panzi/6856583
#include <endian.h>

#define MARIADB_ST_LEAD 4
#define SRID_BYTE_SIZE 4
#define ENDIAN_BYTE_SIZE 1
#define GEOMTYPE_BYTE_SIZE 4
#define RING_NUMS_BYTE_SIZE 4
#define POLY_NUMS_BYTE_SIZE 4
#define POINT_NUMS_BYTE_SIZE 4
#define POINT_BYTE_SIZE 8
#define PI 3.14159265358979323846

#define CALC_X(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_x) (((x - origin_x) * scaledCosine) + ((y - origin_y) * scaledSine * -1)) + translate_x 
#define CALC_Y(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_y) (((y - origin_y) * scaledCosine) + ((x - origin_x) * scaledSine)) + translate_y 

static pthread_mutex_t LOCK_hostname;

/*
 * This is a UDF for Mysql/MariaDB.  It receives the internal representation of a MariaDB geometry with 
 * a rotation in degrees, a scale, a translate_x, a translate_y, and optionally the x and y values around
 * which to perform the transform (ef those are not supplied then the transform is performed around 0,0).
 * It is built mainly for speed, and does very little validation. For the internal layout of WKB
 * see: http://help.arcgis.com/en/geodatabase/10.0/sdk/arcsde/concepts/geometry/representations/binary.htm#WKB.
 * The internal representation of Geometries in MariaDB is the same as that of WKB except that the binary stream
 * begins with a 1 Byte SRID.
 */

my_bool nested_geom_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message );
char * nested_geom_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error);
void nested_geom_transform_deinit( UDF_INIT *initid );

my_bool nested_geom_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message ) {
    // Initial check for proper arguments
    if (args->arg_count != 7 && args->arg_count != 9) 
    {
        sprintf(message, "Received %d arguments, requires (Geom, scale, rotate, translate_x, translate_y, [origin_x, origin_y]).", args->arg_count);
        //strcpy(message, "Invalid params: (Geom, scale, rotate, translate_x, translate_y, [origin_x, origin_y]).");
        return 1;
    }

    if (args->arg_type[1] != DECIMAL_RESULT && args->arg_type[1] !=  REAL_RESULT) 
    {
        strcpy(message, "The scale value must be a decimal or double floating point.");
        return 1;
    }

    if (args->arg_type[2] != DECIMAL_RESULT && args->arg_type[2] !=  REAL_RESULT) 
    {
        strcpy(message, "The rotate value must be a decimal or double floating point.");
        return 1;
    }

    if (args->arg_type[3] != INT_RESULT) 
    {
        strcpy(message, "The translate_x value must be an int.");
        return 1;
    }

    if (args->arg_type[4] != INT_RESULT) 
    {
        strcpy(message, "The translate_y value must be an int.");
        return 1;
    }

    if (args->arg_count == 9)
    {
        if (args->arg_type[7] != REAL_RESULT) 
        {
            strcpy(message, "The origin_x value must be a double floating point.");
            return 1;
        }

        if (args->arg_type[8] != REAL_RESULT) 
        {
            strcpy(message, "The origin_y value must be a double floating point.");
            return 1;
        }
    }

    if (args->arg_type[0] != STRING_RESULT)
    {
        strcpy(message, "A Geometry input is required as the first parameter.");
        return 1;
    }

    if (args->lengths[0] < 21) // The smallest GEOM is 21 bytes
    {
        strcpy(message, "The input geometry is invalid.");
        return 1;
    }

    args->arg_type[1] = REAL_RESULT;
    args->arg_type[2] = REAL_RESULT;
    initid->maybe_null = 0;
    initid->const_item = 1;
    initid->ptr = malloc(sizeof(char) * args->lengths[0]);

    return 0;
}

void nested_geom_transform_deinit( UDF_INIT *initid ){
    free(initid->ptr);
    return;
}

char *nested_geom_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error) {
    // Init
    *length = args->lengths[0];
    unsigned char* transform = (unsigned char*)args->args[0];
    unsigned char* writePtr = initid->ptr;

    // Calculate the transform matrix
    double origin_x = args->arg_count == 9 ? *((double*) args->args[7]) : 0.0;
    double origin_y = args->arg_count == 9 ? *((double*) args->args[8]) : 0.0;
    longlong translate_x = *((longlong*) args->args[3]) + origin_x;
    longlong translate_y = *((longlong*) args->args[4]) + origin_y;
    longlong first_translate_x = *((longlong*) args->args[5]);
    longlong first_translate_y = *((longlong*) args->args[6]);
    double scale = *((double*) args->args[1]);
    double theta = *((double*) args->args[2]) * (PI / 180);
    double scaledCosine = cos(theta) * scale;
    double scaledSine = sin(theta) * scale;

    // Check the endianness
    char binaryEndian = (*((char*) transform)); // binaryEndian == 1 for big endian, binaryEndian == 0 for little endian

    // Copy the MariaDB Leader, srid, and endian byte
    int initial_offset = SRID_BYTE_SIZE + ENDIAN_BYTE_SIZE;
    memcpy(writePtr, transform, initial_offset);
    transform += initial_offset;
    writePtr += initial_offset;

    if (binaryEndian == 1)
    {
        // Get the geometry type
        uint32_t geom_type = be32toh(*((uint32_t*) transform));
        memcpy(writePtr, transform, GEOMTYPE_BYTE_SIZE);
        transform += GEOMTYPE_BYTE_SIZE;
        writePtr += GEOMTYPE_BYTE_SIZE;

        if (geom_type == 3){ // This is a WKB POLYGON
            // Get the number of rings 
            uint32_t num_of_rings = be32toh(*((uint32_t*) transform));
            memcpy(writePtr, transform, RING_NUMS_BYTE_SIZE);
            transform += RING_NUMS_BYTE_SIZE;
            writePtr += RING_NUMS_BYTE_SIZE;

            for (int ring = 0; ring < num_of_rings; ++ring)
            {
                // Get the number of points in this rings
                uint32_t num_of_points = be32toh(*((uint32_t*) transform));
                memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
                transform += POINT_NUMS_BYTE_SIZE;
                writePtr += POINT_NUMS_BYTE_SIZE;

                for (int point = 0; point < num_of_points; ++point)
                {
                    // Get the values of each coordinate
                    unsigned char* points = transform;
                    ulonglong intX = be64toh(*((ulonglong*) points));
                    double x = *((double*) &intX ) + first_translate_x;
                    points += POINT_BYTE_SIZE;
                    ulonglong intY = be64toh(*((ulonglong*) points));
                    double y = *((double*) &intY ) + first_translate_y;

                    // Modify and write point1
                    double num1  = CALC_X(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_x);
                    uint8_t *array1 = (uint8_t*)(&num1);

                    for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                        *writePtr = array1[i];
                        transform += 1;
                        writePtr += 1;
                    }

                    // Modify and write point2
                    double num2 = CALC_Y(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_y);
                    uint8_t *array2 = (uint8_t*)(&num2);

                    for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                        *writePtr = array2[i];
                        transform += 1;
                        writePtr += 1;
                    }
                }
            }
        } else if (geom_type == 6){ // This is a WKB MULTIPOLYGON
            uint32_t num_polys = be32toh(*((uint32_t*) transform));
            memcpy(writePtr, transform, POLY_NUMS_BYTE_SIZE);
            transform += POLY_NUMS_BYTE_SIZE;
            writePtr += POLY_NUMS_BYTE_SIZE;

            for (int poly = 0; poly < num_polys; ++poly)
            {
                // Copy the redundant type signature, we know this is a Polygon and we know the endianness
                memcpy(writePtr, transform, ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE);
                transform += ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE;
                writePtr += ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE;

                // Get the number of rings 
                uint32_t num_of_rings = be32toh(*((uint32_t*) transform));
                memcpy(writePtr, transform, RING_NUMS_BYTE_SIZE);
                transform += RING_NUMS_BYTE_SIZE;
                writePtr += RING_NUMS_BYTE_SIZE;

                for (int ring = 0; ring < num_of_rings; ++ring)
                {
                    // Get the number of points in this rings
                    uint32_t num_of_points = be32toh(*((uint32_t*) transform));
                    memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
                    transform += POINT_NUMS_BYTE_SIZE;
                    writePtr += POINT_NUMS_BYTE_SIZE;

                    for (int point = 0; point < num_of_points; ++point)
                    {
                        // Get the values of each coordinate
                        unsigned char* points = transform;
                        ulonglong intX = be64toh(*((ulonglong*) points));
                        double x = *((double*) &intX ) + first_translate_x;
                        points += POINT_BYTE_SIZE;
                        ulonglong intY = be64toh(*((ulonglong*) points));
                        double y = *((double*) &intY ) + first_translate_y;

                        // Modify and write point1
                        double num1  = CALC_X(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_x);
                        uint8_t *array1 = (uint8_t*)(&num1);

                        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                            *writePtr = array1[i];
                            transform += 1;
                            writePtr += 1;
                        }

                        // Modify and write point2
                        double num2 = CALC_Y(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_y);
                        uint8_t *array2 = (uint8_t*)(&num2);

                        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                            *writePtr = array2[i];
                            transform += 1;
                            writePtr += 1;
                        }
                    }
                }
            }
        } else if (geom_type == 1) { // this is a WKB POINT
            // Get the values of each coordinate
            unsigned char* points = transform;
            ulonglong intX = be64toh(*((ulonglong*) points));
            double x = *((double*) &intX ) + first_translate_x;
            points += POINT_BYTE_SIZE;
            ulonglong intY = be64toh(*((ulonglong*) points));
            double y = *((double*) &intY ) + first_translate_y;

            // Modify and write x
            double num1  = CALC_X(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_x);
            uint8_t *array1 = (uint8_t*)(&num1);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *writePtr = array1[i];
                transform += 1;
                writePtr += 1;
            }

            // Modify and write y
            double num2 = CALC_Y(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_y);
            uint8_t *array2 = (uint8_t*)(&num2);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *writePtr = array2[i];
                transform += 1;
                writePtr += 1;
            }
        } else if (geom_type == 4){ // This is a WKB MULTIPOINT
            // Get the number of points in this rings
            uint32_t num_of_points = be32toh(*((uint32_t*) transform));
            memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
            transform += POINT_NUMS_BYTE_SIZE;
            writePtr += POINT_NUMS_BYTE_SIZE;

            for (int point = 0; point < num_of_points; ++point)
            {
                // Copy the redundant type signature, we know this is a POINT and we know the endianness
                memcpy(writePtr, transform, ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE);
                transform += ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE;
                writePtr += ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE;

                // Get the values of each coordinate
                unsigned char* points = transform;
                ulonglong intX = be64toh(*((ulonglong*) points));
                double x = *((double*) &intX ) + first_translate_x;
                points += POINT_BYTE_SIZE;
                ulonglong intY = be64toh(*((ulonglong*) points));
                double y = *((double*) &intY ) + first_translate_y;

                // Modify and write point1
                double num1  = CALC_X(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_x);
                uint8_t *array1 = (uint8_t*)(&num1);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *writePtr = array1[i];
                    transform += 1;
                    writePtr += 1;
                }

                // Modify and write point2
                double num2 = CALC_Y(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_y);
                uint8_t *array2 = (uint8_t*)(&num2);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *writePtr = array2[i];
                    transform += 1;
                    writePtr += 1;
                }
            }
        } else {
            memcpy(error, "This function requires POLYGON, POINT, or MULTIPOINT geometry type.", 67);
            *length = 54;
            return error;
        }
    }
    else
    {
        // Get the geometry type
        uint32_t geom_type = le32toh(*((uint32_t*) transform));
        memcpy(writePtr, transform, GEOMTYPE_BYTE_SIZE);
        transform += GEOMTYPE_BYTE_SIZE;
        writePtr += GEOMTYPE_BYTE_SIZE;

        if (geom_type == 3){ // This is a WKB POLYGON
            // Get the number of rings 
            uint32_t num_of_rings = le32toh(*((uint32_t*) transform));
            memcpy(writePtr, transform, RING_NUMS_BYTE_SIZE);
            transform += RING_NUMS_BYTE_SIZE;
            writePtr += RING_NUMS_BYTE_SIZE;

            for (int ring = 0; ring < num_of_rings; ++ring)
            {
                // Get the number of points in this rings
                uint32_t num_of_points = le32toh(*((uint32_t*) transform));
                memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
                transform += POINT_NUMS_BYTE_SIZE;
                writePtr += POINT_NUMS_BYTE_SIZE;

                for (int point = 0; point < num_of_points; ++point)
                {
                    // Get the values of each coordinate
                    unsigned char* points = transform;
                    ulonglong intX = le64toh(*((ulonglong*) points));
                    double x = *((double*) &intX ) + first_translate_x;
                    points += POINT_BYTE_SIZE;
                    ulonglong intY = le64toh(*((ulonglong*) points));
                    double y = *((double*) &intY ) + first_translate_y;

                    // Modify and write point1
                    double num1  = CALC_X(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_x);
                    uint8_t *array1 = (uint8_t*)(&num1);

                    for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                        *writePtr = array1[i];
                        transform += 1;
                        writePtr += 1;
                    }

                    // Modify and write point2
                    double num2 = CALC_Y(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_y);
                    uint8_t *array2 = (uint8_t*)(&num2);

                    for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                        *writePtr = array2[i];
                        transform += 1;
                        writePtr += 1;
                    }
                }
            }
        } else if (geom_type == 6){ // This is a WKB MULTIPOLYGON
            uint32_t num_polys = le32toh(*((uint32_t*) transform));
            memcpy(writePtr, transform, POLY_NUMS_BYTE_SIZE);
            transform += POLY_NUMS_BYTE_SIZE;
            writePtr += POLY_NUMS_BYTE_SIZE;

            for (int poly = 0; poly < num_polys; ++poly)
            {
                // Copy the redundant type signature, we know this is a Polygon and we know the endianness
                memcpy(writePtr, transform, ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE);
                transform += ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE;
                writePtr += ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE;

                // Get the number of rings 
                uint32_t num_of_rings = le32toh(*((uint32_t*) transform));
                memcpy(writePtr, transform, RING_NUMS_BYTE_SIZE);
                transform += RING_NUMS_BYTE_SIZE;
                writePtr += RING_NUMS_BYTE_SIZE;

                for (int ring = 0; ring < num_of_rings; ++ring)
                {
                    // Get the number of points in this rings
                    uint32_t num_of_points = le32toh(*((uint32_t*) transform));
                    memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
                    transform += POINT_NUMS_BYTE_SIZE;
                    writePtr += POINT_NUMS_BYTE_SIZE;

                    for (int point = 0; point < num_of_points; ++point)
                    {
                        // Get the values of each coordinate
                        unsigned char* points = transform;
                        ulonglong intX = le64toh(*((ulonglong*) points));
                        double x = *((double*) &intX ) + first_translate_x;
                        points += POINT_BYTE_SIZE;
                        ulonglong intY = le64toh(*((ulonglong*) points));
                        double y = *((double*) &intY ) + first_translate_y;

                        // Modify and write point1
                        double num1  = CALC_X(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_x);
                        uint8_t *array1 = (uint8_t*)(&num1);

                        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                            *writePtr = array1[i];
                            transform += 1;
                            writePtr += 1;
                        }

                        // Modify and write point2
                        double num2 = CALC_Y(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_y);
                        uint8_t *array2 = (uint8_t*)(&num2);

                        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                            *writePtr = array2[i];
                            transform += 1;
                            writePtr += 1;
                        }
                    }
                }
            }
        } else if (geom_type == 1) { // this is a WKB POINT
            // Get the values of each coordinate
            unsigned char* points = transform;
            ulonglong intX = le64toh(*((ulonglong*) points));
            double x = *((double*) &intX ) + first_translate_x;
            points += POINT_BYTE_SIZE;
            ulonglong intY = le64toh(*((ulonglong*) points));
            double y = *((double*) &intY ) + first_translate_y;

            // Modify and write x
            double num1  = CALC_X(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_x);
            uint8_t *array1 = (uint8_t*)(&num1);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *writePtr = array1[i];
                transform += 1;
                writePtr += 1;
            }

            // Modify and write y
            double num2 = CALC_Y(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_y);
            uint8_t *array2 = (uint8_t*)(&num2);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *writePtr = array2[i];
                transform += 1;
                writePtr += 1;
            }
        } else if (geom_type == 4){ // This is a WKB MULTIPOINT
            // Get the number of points in this rings
            uint32_t num_of_points = le32toh(*((uint32_t*) transform));
            memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
            transform += POINT_NUMS_BYTE_SIZE;
            writePtr += POINT_NUMS_BYTE_SIZE;

            for (int point = 0; point < num_of_points; ++point)
            {
                // Copy the redundant type signature, we know this is a POINT and we know the endianness
                memcpy(writePtr, transform, ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE);
                transform += ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE;
                writePtr += ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE;

                // Get the values of each coordinate
                unsigned char* points = transform;
                ulonglong intX = le64toh(*((ulonglong*) points));
                double x = *((double*) &intX ) + first_translate_x;
                points += POINT_BYTE_SIZE;
                ulonglong intY = le64toh(*((ulonglong*) points));
                double y = *((double*) &intY ) + first_translate_y;

                // Modify and write point1
                double num1  = CALC_X(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_x);
                uint8_t *array1 = (uint8_t*)(&num1);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *writePtr = array1[i];
                    transform += 1;
                    writePtr += 1;
                }

                // Modify and write point2
                double num2 = CALC_Y(x, y, scaledSine, scaledCosine, origin_x, origin_y, translate_y);
                uint8_t *array2 = (uint8_t*)(&num2);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *writePtr = array2[i];
                    transform += 1;
                    writePtr += 1;
                }
            }
        } else {
            memcpy(error, "This function requires POLYGON, POINT, or MULTIPOINT geometry type.", 67);
            *length = 54;
            return error;
        }
    }
    return initid->ptr;
}
