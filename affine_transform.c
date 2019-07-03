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
#define SRID_BYTE_SIZE 4
#define ENDIAN_BYTE_SIZE 1
#define GEOMTYPE_BYTE_SIZE 4
#define RING_NUMS_BYTE_SIZE 4
#define POINT_NUMS_BYTE_SIZE 4
#define POINT_BYTE_SIZE 8

static pthread_mutex_t LOCK_hostname;

/*
 * This is a UDF for Mysql/MariaDB.  It receives a string with a transform matrix
 * and a string with a WKB Polygon, Point, or Multipoint, then applies the transform matrix to the geometry.
 * It is built purely for speed, and does very little validation.
 */

my_bool affine_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message );
char * affine_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error);
void affine_transform_deinit( UDF_INIT *initid );

my_bool affine_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message ) {
    if ( args->arg_count == 2 
        && args->arg_type[0] == STRING_RESULT 
        && args->arg_type[1] == STRING_RESULT
        //&& args->lengths[0] >= 9
        //&& args->lengths[1] >= 17
        ) {
        initid->maybe_null = 0;
        initid->const_item = 1;
        return 0;
    } else {
        strcpy(message, "affine_transform(): Incorrect usage. Use two and only two inputs.");
        return 1;
    }
}

void affine_transform_deinit( UDF_INIT *initid ){
    return;
}

char *affine_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error) {
    // Init
    *length = args->lengths[0];
    char* transform = args->args[0];
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
        memcpy(result, "This function requires a valid transform matrix.", 48);
        *length = 54;
        *error = 1;
        return result;
    }

    // Move past srid and endian byte
    int initial_offset = SRID_BYTE_SIZE + ENDIAN_BYTE_SIZE;
    transform += initial_offset;

    // Get the geometry type
    int geom_type = (*((int*)transform));
    transform += GEOMTYPE_BYTE_SIZE;

    if (geom_type == 1) { // this is a WKB POINT
        // Get the values of each coordinate
        char* points = transform;
        double x = (*((double*)points));
        points += POINT_BYTE_SIZE;
        double y = (*((double*)points));

        // Modify and write x
        double num1  = (double)(int)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
        uint8_t *array1 = (uint8_t*)(&num1);

        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
            *transform = array1[i];
            transform += 1;
        }

        // Modify and write y
        double num2 = (double)(int)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
        uint8_t *array2 = (uint8_t*)(&num2);

        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
            *transform = array2[i];
            transform += 1;
        }
    } else if (geom_type == 4){ // This is a WKB MULTIPOINT
        // Get the number of points in this rings
        int num_of_points = (*((int*)transform));
        transform += POINT_NUMS_BYTE_SIZE;

        for (int point = 0; point < num_of_points; ++point)
        {
            // Skip the redundant type signature, we know this is a POINT and we know the endianness
            transform += ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE;

            // Get the values of each coordinate
            char* points = transform;
            double x = (*((double*)points));
            points += POINT_BYTE_SIZE;
            double y = (*((double*)points));

            // Modify and write point1
            double num1  = (double)(int)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
            uint8_t *array1 = (uint8_t*)(&num1);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *transform = array1[i];
                transform += 1;
            }

            // Modify and write point2
            double num2 = (double)(int)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
            uint8_t *array2 = (uint8_t*)(&num2);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *transform = array2[i];
                transform += 1;
            }
        }
    } else if (geom_type == 3){ // This is a WKB MULTIPOLYGON
        // Get the number of rings 
        int num_of_rings = (*((int*)transform));
        transform += RING_NUMS_BYTE_SIZE;

        for (int ring = 0; ring < num_of_rings; ++ring)
        {
            // Get the number of points in this rings
            int num_of_points = (*((int*)transform));
            transform += POINT_NUMS_BYTE_SIZE;
            for (int point = 0; point < num_of_points; ++point)
            {
                // Get the values of each coordinate
                char* points = transform;
                double x = (*((double*)points));
                points += POINT_BYTE_SIZE;
                double y = (*((double*)points));

                // Modify and write point1
                double num1  = (double)(int)((x * matrix[0]) + (y * matrix[1]) + matrix[2]);
                uint8_t *array1 = (uint8_t*)(&num1);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *transform = array1[i];
                    transform += 1;
                }

                // Modify and write point2
                double num2 = (double)(int)((x * matrix[3]) + (y * matrix[4]) + matrix[5]);
                uint8_t *array2 = (uint8_t*)(&num2);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *transform = array2[i];
                    transform += 1;
                }
            }
        }
    } else {
        memcpy(result, "This function requires POLYGON, POINT, or MULTIPOINT geometry type.", 67);
        *length = 54;
        *error = 1;
        return result;
    }

    return args->args[0];
}