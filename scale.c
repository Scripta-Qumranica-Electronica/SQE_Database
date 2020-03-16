//
// Created by Bronson Brown on 20.12.19.
//

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
 * This is a UDF for Mysql/MariaDB.  It receives two translate coordinates
 * and a string with a WKB Polygon, Point, or Multipoint, then applies the transform matrix to the geometry.
 * It is built purely for speed, and does very little validation.
 */

my_bool scale_init( UDF_INIT *initid, UDF_ARGS* args, char* message );
char * scale(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error);
void scale_deinit( UDF_INIT *initid );

my_bool scale_init( UDF_INIT *initid, UDF_ARGS* args, char* message ) {
    // Initial check for proper arguments
    if ( args->arg_count > 1 && args->arg_count < 4
         && args->arg_type[0] == STRING_RESULT
         && args->arg_type[1] == INT_RESULT
         && args->lengths[0] >= 9
            ) {
        initid->maybe_null = 0;
        initid->const_item = 1;
    } else {
        strcpy(message, "Use three inputs: a POLYGON, POINT, or MULTIPOINT GEOM and two ints.");
        return 1;
    }

    return 0;
}

void scale_deinit( UDF_INIT *initid ){
    if (initid->ptr) {
        free(initid->ptr);
    }

    return;
}

char *scale(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error) {
    // Init
    size_t sizeLeader = sizeof(unsigned long); // Store the size of the *length variable, which is place at the beginning of initit->ptr
    *length = args->lengths[0]; // Set the length of the response
    char* polygon = args->args[0]; // Copy the pointer to our polygon data (we will walk through the bytearray with this).

    char* response; // instantiate the response variable
    // If initid->ptr exists, check that it is big enough to hold our data
    if (initid->ptr) {
        // If the current initid->ptr is too small for this WKB data, then resize it
        size_t lastLength = (*((unsigned long*)initid->ptr));
        if (lastLength < *length){
            initid->ptr = realloc(initid->ptr, sizeLeader + (*length * sizeof(char)));
        }
    }
        // If initid->ptr has not yet been initialized, initialize it now
    else {
        initid->ptr = (char*)malloc(sizeLeader + (*length * sizeof(char)));
    }
    response = initid->ptr;
    *response = *length; // Store the size of the current polygon (we check it in later row to see if a resize is needed)
    response += sizeLeader; // Jump over the size leader in the bytearray

    int x_scale = *args->args[1];
    int y_scale = args->arg_count == 3 ? *args->args[2] : x_scale;

    // Copy srid and endian byte
    int initial_offset = SRID_BYTE_SIZE + ENDIAN_BYTE_SIZE;
    for (int i = 0; i < initial_offset; ++i) {
        *response = (*((char*)polygon));
        response += 1;
        polygon += 1;
    }

    // Copy the geometry type
    int geom_type = (*((int*)polygon));
    for (int i = 0; i < GEOMTYPE_BYTE_SIZE; ++i) {
        *response = (*((char*)polygon));
        response += 1;
        polygon += 1;
    }

    if (geom_type == 1) { // this is a WKB POINT
        // Get the values of each coordinate
        char* points = polygon;
        double x = (*((double*)points));
        points += POINT_BYTE_SIZE;
        double y = (*((double*)points));

        // Modify and write x
        double num1  = (double)(x * x_scale);
        uint8_t *array1 = (uint8_t*)(&num1);

        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
            *response = array1[i];
            response += 1;
            polygon += 1;
        }

        // Modify and write y
        double num2 = (double)(y * y_scale);
        uint8_t *array2 = (uint8_t*)(&num2);

        for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
            *response = array2[i];
            response += 1;
            polygon += 1;
        }
    } else if (geom_type == 4){ // This is a WKB MULTIPOINT
        // Get the number of points in this rings
        int num_of_points = (*((int*)polygon));
        for (int i = 0; i < POINT_NUMS_BYTE_SIZE; ++i){
            *response = (*((char*)polygon));
            response += 1;
            polygon += 1;
        }

        for (int point = 0; point < num_of_points; ++point)
        {
            // Skip the redundant type signature, we know this is a POINT and we know the endianness
            for (int i = 0; i <  ENDIAN_BYTE_SIZE + GEOMTYPE_BYTE_SIZE; ++i){
                *response = (*((char*)polygon));
                response += 1;
                polygon += 1;
            }

            // Get the values of each coordinate
            char* points = polygon;
            double x = (*((double*)points));
            points += POINT_BYTE_SIZE;
            double y = (*((double*)points));

            // Modify and write point1
            double num1  = (double)(x * x_scale);
            uint8_t *array1 = (uint8_t*)(&num1);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *response = array1[i];
                response += 1;
                polygon += 1;
            }

            // Modify and write point2
            double num2 = (double)(y * y_scale);
            uint8_t *array2 = (uint8_t*)(&num2);

            for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                *response = array2[i];
                response += 1;
                polygon += 1;
            }
        }
    } else if (geom_type == 3){ // This is a WKB POLYGON
        // Get the number of rings
        int num_of_rings = (*((int*)polygon));
        for (int i = 0; i < RING_NUMS_BYTE_SIZE; ++i){
            *response = (*((char*)polygon));
            response += 1;
            polygon += 1;
        }

        for (int ring = 0; ring < num_of_rings; ++ring)
        {
            // Get the number of points in this rings
            int num_of_points = (*((int*)polygon));
            for (int i = 0; i < POINT_NUMS_BYTE_SIZE; ++i){
                *response = (*((char*)polygon));
                response += 1;
                polygon += 1;
            }

            for (int point = 0; point < num_of_points; ++point)
            {
                // Get the values of each coordinate
                char* points = polygon;
                double x = (*((double*)points));
                points += POINT_BYTE_SIZE;
                double y = (*((double*)points));

                // Modify and write point1
                double num1  = (double)(x * x_scale);
                uint8_t *array1 = (uint8_t*)(&num1);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *response = array1[i];
                    response += 1;
                    polygon += 1;
                }

                // Modify and write point2
                double num2 = (double)(y * y_scale);
                uint8_t *array2 = (uint8_t*)(&num2);

                for (int i = 0; i < POINT_BYTE_SIZE; ++i) {
                    *response = array2[i];
                    response += 1;
                    polygon += 1;
                }
            }
        }
    } else {
        memcpy(result, "This function requires POLYGON, POINT, or MULTIPOINT geometry type.", 67);
        *length = 54;
        *error = 1;
        return result;
    }


    response = initid->ptr; // reset response pointer to the beginning of the stored bytearray
    response += sizeLeader; // Jump over the size leader in the bytearray

    return response;
}