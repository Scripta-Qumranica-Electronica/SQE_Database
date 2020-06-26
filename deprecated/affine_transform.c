#ifdef STANDARD
/* STANDARD is defined. Don't use any MySQL functions */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
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

#define DIGITORMINUS(poly) (isdigit(poly) || poly == '-')
#define MARIADB_ST_LEAD 4
#define SRID_BYTE_SIZE 4
#define ENDIAN_BYTE_SIZE 1
#define GEOMTYPE_BYTE_SIZE 4
#define RING_NUMS_BYTE_SIZE 4
#define POLY_NUMS_BYTE_SIZE 4
#define POINT_NUMS_BYTE_SIZE 4
#define POINT_BYTE_SIZE 8

static pthread_mutex_t LOCK_hostname;

/*
 * This is a UDF for Mysql/MariaDB.  It receives a string with a transform matrix
 * and a string with a WKB Polygon, Point, or Multipoint, then applies the transform matrix to the geometry.
 * It is built purely for speed, and does very little validation. For the internal layout of WKB
 * see: http://help.arcgis.com/en/geodatabase/10.0/sdk/arcsde/concepts/geometry/representations/binary.htm#WKB
 */

my_bool affine_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message );
char * affine_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error);
void affine_transform_deinit( UDF_INIT *initid );

my_bool affine_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message ) {
    // Initial check for proper arguments
    if (args->arg_count != 2) 
    {
        strcpy(message, "Use two inputs: a POLYGON, POINT, or MULTIPOINT GEOM and a transform matrix.");
        return 1;
    }

    if (!args->args[1] && args->arg_type[1] != STRING_RESULT) 
    {
        strcpy(message, "The transform matrix must be a string.");
        return 1;
    }

    if (args->arg_type[0] != STRING_RESULT)
    {
        strcpy(message, "A Geometry input is required.");
        return 1;
    }

    if (args->lengths[0] < 21) // The smallest GEOM is 21 bytes
    {
        strcpy(message, "The input geometry is invalid.");
        return 1;
    }

    initid->maybe_null = 0;
    initid->const_item = 1;
    initid->ptr = malloc(sizeof(char) * args->lengths[0]);

    return 0;
}

void affine_transform_deinit( UDF_INIT *initid ){
    free(initid->ptr);
    return;
}

char *affine_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error) {
    // Init
    *length = args->lengths[0];
    char* transform = args->args[0];
    char* writePtr = initid->ptr;
    float matrix[6];
    char *matrixString = args->args[1];
    unsigned long matrStringCount = 0;
    unsigned int matrCount = 0;

    // Get the transform matrix
    while(matrCount != 6 && matrStringCount < args->lengths[1]) {

        if(DIGITORMINUS(*matrixString)) {

            char matr[323] = ""; // I guess this is the maximum length of a double in characters.
            unsigned int idx = 0;
            matr[idx++] = *matrixString++;
            matrStringCount++;
            while(isdigit(*matrixString) || *matrixString == '.') {
                matr[idx++] = *matrixString++;
                matrStringCount++;
            }
            matrix[matrCount++] = atof(matr);

        } else {
            ++matrixString;
            ++matrStringCount;
        }
    }

    if (matrCount < 6){
        memcpy(error, "This function requires a valid transform matrix.", 48);
        *length = 54;
        return error;
    }

    // Copy the MariaDB Leader, srid, and endian byte
    int initial_offset = SRID_BYTE_SIZE + ENDIAN_BYTE_SIZE;
    memcpy(writePtr, transform, initial_offset);
    transform += initial_offset;
    writePtr += initial_offset;

    // Get the geometry type
    int geom_type = (*((int*)transform));
    memcpy(writePtr, transform, GEOMTYPE_BYTE_SIZE);
    transform += GEOMTYPE_BYTE_SIZE;
    writePtr += GEOMTYPE_BYTE_SIZE;

    if (geom_type == 3){ // This is a WKB POLYGON
        // Get the number of rings 
        int num_of_rings = (*((int*)transform));
        memcpy(writePtr, transform, RING_NUMS_BYTE_SIZE);
        transform += RING_NUMS_BYTE_SIZE;
        writePtr += RING_NUMS_BYTE_SIZE;

        for (int ring = 0; ring < num_of_rings; ++ring)
        {
            // Get the number of points in this rings
            int num_of_points = (*((int*)transform));
            memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
            transform += POINT_NUMS_BYTE_SIZE;
            writePtr += POINT_NUMS_BYTE_SIZE;

            for (int point = 0; point < num_of_points; ++point)
            {
                // Get the values of each coordinate
                char* points = transform;
                double x = (*((double*)points));
                points += POINT_BYTE_SIZE;
                double y = (*((double*)points));

                // Modify and write point1
                double num1  = (double)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
                uint8_t *array1 = (uint8_t*)(&num1);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *writePtr = array1[i];
                    transform += 1;
                    writePtr += 1;
                }

                // Modify and write point2
                double num2 = (double)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
                uint8_t *array2 = (uint8_t*)(&num2);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *writePtr = array2[i];
                    transform += 1;
                    writePtr += 1;
                }
            }
        }
    } else if (geom_type == 6){ // This is a WKB POLYGON
        int num_polys = (*((int*)transform));
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
            int num_of_rings = (*((int*)transform));
            memcpy(writePtr, transform, RING_NUMS_BYTE_SIZE);
            transform += RING_NUMS_BYTE_SIZE;
            writePtr += RING_NUMS_BYTE_SIZE;

            for (int ring = 0; ring < num_of_rings; ++ring)
            {
                // Get the number of points in this rings
                int num_of_points = (*((int*)transform));
                memcpy(writePtr, transform, POINT_NUMS_BYTE_SIZE);
                transform += POINT_NUMS_BYTE_SIZE;
                writePtr += POINT_NUMS_BYTE_SIZE;

                for (int point = 0; point < num_of_points; ++point)
                {
                    // Get the values of each coordinate
                    char* points = transform;
                    double x = (*((double*)points));
                    points += POINT_BYTE_SIZE;
                    double y = (*((double*)points));

                    // Modify and write point1
                    double num1  = (double)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
                    uint8_t *array1 = (uint8_t*)(&num1);

                    for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                        *writePtr = array1[i];
                        transform += 1;
                        writePtr += 1;
                    }

                    // Modify and write point2
                    double num2 = (double)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
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
        char* points = transform;
        double x = (*((double*)points));
        points += POINT_BYTE_SIZE;
        double y = (*((double*)points));

        // Modify and write x
        double num1  = (double)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
        uint8_t *array1 = (uint8_t*)(&num1);

        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
            *writePtr = array1[i];
            transform += 1;
            writePtr += 1;
        }

        // Modify and write y
        double num2 = (double)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
        uint8_t *array2 = (uint8_t*)(&num2);

        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
            *writePtr = array2[i];
            transform += 1;
            writePtr += 1;
        }
    } else if (geom_type == 4){ // This is a WKB MULTIPOINT
        // Get the number of points in this rings
        int num_of_points = (*((int*)transform));
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
            char* points = transform;
            double x = (*((double*)points));
            points += POINT_BYTE_SIZE;
            double y = (*((double*)points));

            // Modify and write point1
            double num1  = (double)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
            uint8_t *array1 = (uint8_t*)(&num1);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *writePtr = array1[i];
                transform += 1;
                writePtr += 1;
            }

            // Modify and write point2
            double num2 = (double)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
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