#ifdef STANDARD
/* STANDARD is defined. Don't use any MySQL functions */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#ifdef __WIN__
typedef unsigned __int64 ulonglong;     /* Microsoft's 64 bit types */
typedef __int64 longlong;
#else
typedef unsigned long long ulonglong;
typedef long long longlong;
#endif /*__WIN__*/
#else
#include <my_global.h>
#include <my_sys.h>
#endif
#include <mysql.h>
#include <ctype.h>
#include <stdint.h>

#define MARIADB_ST_LEAD 4
#define SRID_BYTE_SIZE 4
#define ENDIAN_BYTE_SIZE 1
#define GEOMTYPE_BYTE_SIZE 4
#define RING_NUMS_BYTE_SIZE 4
#define POLY_NUMS_BYTE_SIZE 4
#define POINT_NUMS_BYTE_SIZE 4
#define POINT_BYTE_SIZE 8
#define PI 3.14159265358979323846

#define U32BIT_LE_DATA(ptr) (*(ptr)<<0) | (*(ptr + 1)<<8) | (*(ptr + 2)<<16) | (*(ptr + 3)<<24)
#define U32BIT_BE_DATA(ptr) (*(ptr + 3)<<0) | (*(ptr + 2)<<8) | (*(ptr + 1)<<16) | (*(ptr)<<24)
#define DOUBLE_FROM_PTR(ptr, var) memcpy(&var, ptr, sizeof(double)) // Unlike the above functions, this is not endian agnostic
// We could always use a loop to go over the doubles (either forward or reverse depending on the binary's endianness), 
// but I think we would need to know the endianness of the machine running this function. See https://stackoverflow.com/questions/62577683/reading-double-in-c-from-binary-unsigned-char-with-specified-endianness.
// uint8_t data[sizeof(double)];
// for(i=0; i<8; i++)
// {
//     data[sizeof(double)-i-1] = *(cc + i);
// }
// double var;
// memcpy(&var, ptr, sizeof(double));

#define CALC_X(x, y, scale, sine, cosine, origin_x, origin_y, translate_x) (((x - origin_x) * scale * cosine) + ((y - origin_y) * scale * sine * -1)) + origin_x + translate_x 
#define CALC_Y(x, y, scale, sine, cosine, origin_x, origin_y, translate_y) (((y - origin_y) * scale * cosine) + ((x - origin_x) * scale * sine)) + origin_y + translate_y 

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

my_bool geom_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message );
char * geom_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error);
void geom_transform_deinit( UDF_INIT *initid );

my_bool geom_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message ) {
    // Initial check for proper arguments
    if (args->arg_count != 5 && args->arg_count != 7) 
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

    if (args->arg_count == 7)
    {
        if (args->arg_type[5] != REAL_RESULT) 
        {
            strcpy(message, "The origin_x value must be a double floating point.");
            return 1;
        }

        if (args->arg_type[6] != REAL_RESULT) 
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

void geom_transform_deinit( UDF_INIT *initid ){
    free(initid->ptr);
    return;
}

char *geom_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error) {
    // Init
    *length = args->lengths[0];
    unsigned char* transform = (unsigned char*)args->args[0];
    unsigned char* writePtr = initid->ptr;

    // Calculate the transform matrix
    double origin_x = args->arg_count == 7 ? *((double*) args->args[5]) : 0.0;
    double origin_y = args->arg_count == 7 ? *((double*) args->args[6]) : 0.0;
    longlong translate_x = *((longlong*) args->args[3]);
    longlong translate_y = *((longlong*) args->args[4]);
    double scale = *((double*) args->args[1]);
    double theta = *((double*) args->args[2]) * (PI / 180);
    double cosine = cos(theta);
    double sine = sin(theta);

    // Check the endianness
    char binaryEndian = (*((char*) transform)); // binaryEndian == 0 for big endian, binaryEndian == 1 for little endian

    // Copy the MariaDB Leader, srid, and endian byte
    int initial_offset = SRID_BYTE_SIZE + ENDIAN_BYTE_SIZE;
    memcpy(writePtr, transform, initial_offset);
    transform += initial_offset;
    writePtr += initial_offset;

    // Get the geometry type
    uint32_t geom_type = U32BIT_LE_DATA(transform);
    memcpy(writePtr, transform, GEOMTYPE_BYTE_SIZE);
    transform += GEOMTYPE_BYTE_SIZE;
    writePtr += GEOMTYPE_BYTE_SIZE;

    if (geom_type == 3){ // This is a WKB POLYGON
        // Get the number of rings 
        uint32_t num_of_rings = U32BIT_LE_DATA(transform);
        memcpy(writePtr, transform, RING_NUMS_BYTE_SIZE);
        transform += RING_NUMS_BYTE_SIZE;
        writePtr += RING_NUMS_BYTE_SIZE;

        for (int ring = 0; ring < num_of_rings; ++ring)
        {
            // Get the number of points in this rings
            uint32_t num_of_points = U32BIT_LE_DATA(transform);
            memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
            transform += POINT_NUMS_BYTE_SIZE;
            writePtr += POINT_NUMS_BYTE_SIZE;

            for (int point = 0; point < num_of_points; ++point)
            {
                // Get the values of each coordinate
                unsigned char* points = transform;
                double x = (*((double*)points));
                points += POINT_BYTE_SIZE;
                double y = (*((double*)points));

                // Modify and write point1
                double num1  = CALC_X(x, y, scale, sine, cosine, origin_x, origin_y, translate_x);  //(double)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
                uint8_t *array1 = (uint8_t*)(&num1);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *writePtr = array1[i];
                    transform += 1;
                    writePtr += 1;
                }

                // Modify and write point2
                double num2 = CALC_Y(x, y, scale, sine, cosine, origin_x, origin_y, translate_y); //(double)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
                uint8_t *array2 = (uint8_t*)(&num2);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *writePtr = array2[i];
                    transform += 1;
                    writePtr += 1;
                }
            }
        }
    } else if (geom_type == 6){ // This is a WKB MULTIPOLYGON
        uint32_t num_polys = U32BIT_LE_DATA(transform);
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
            uint32_t num_of_rings = U32BIT_LE_DATA(transform);
            memcpy(writePtr, transform, RING_NUMS_BYTE_SIZE);
            transform += RING_NUMS_BYTE_SIZE;
            writePtr += RING_NUMS_BYTE_SIZE;

            for (int ring = 0; ring < num_of_rings; ++ring)
            {
                // Get the number of points in this rings
                uint32_t num_of_points = U32BIT_LE_DATA(transform);
                memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
                transform += POINT_NUMS_BYTE_SIZE;
                writePtr += POINT_NUMS_BYTE_SIZE;

                for (int point = 0; point < num_of_points; ++point)
                {
                    // Get the values of each coordinate
                    unsigned char* points = transform;
                    double x = (*((double*)points));
                    points += POINT_BYTE_SIZE;
                    double y = (*((double*)points));

                    // Modify and write point1
                    double num1  = CALC_X(x, y, scale, sine, cosine, origin_x, origin_y, translate_x); //(double)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
                    uint8_t *array1 = (uint8_t*)(&num1);

                    for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                        *writePtr = array1[i];
                        transform += 1;
                        writePtr += 1;
                    }

                    // Modify and write point2
                    double num2 = CALC_Y(x, y, scale, sine, cosine, origin_x, origin_y, translate_y); //(double)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
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
        double x = (*((double*)points));
        points += POINT_BYTE_SIZE;
        double y = (*((double*)points));

        // Modify and write x
        double num1  = CALC_X(x, y, scale, sine, cosine, origin_x, origin_y, translate_x); //(double)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
        uint8_t *array1 = (uint8_t*)(&num1);

        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
            *writePtr = array1[i];
            transform += 1;
            writePtr += 1;
        }

        // Modify and write y
        double num2 = CALC_Y(x, y, scale, sine, cosine, origin_x, origin_y, translate_y); //(double)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
        uint8_t *array2 = (uint8_t*)(&num2);

        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
            *writePtr = array2[i];
            transform += 1;
            writePtr += 1;
        }
    } else if (geom_type == 4){ // This is a WKB MULTIPOINT
        // Get the number of points in this rings
        uint32_t num_of_points = U32BIT_LE_DATA(transform);
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
            double x = (*((double*)points));
            points += POINT_BYTE_SIZE;
            double y = (*((double*)points));

            // Modify and write point1
            double num1  = CALC_X(x, y, scale, sine, cosine, origin_x, origin_y, translate_x); //(double)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
            uint8_t *array1 = (uint8_t*)(&num1);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *writePtr = array1[i];
                transform += 1;
                writePtr += 1;
            }

            // Modify and write point2
            double num2 = CALC_Y(x, y, scale, sine, cosine, origin_x, origin_y, translate_y); //(double)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
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

    return initid->ptr;
}
