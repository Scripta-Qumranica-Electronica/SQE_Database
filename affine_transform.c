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

// A growth factor of 1.5 seems to strike a good balance between avoiding extra reallocations, while not wasting too much memory.
#define GROWTHFACTOR 1.5

static pthread_mutex_t LOCK_hostname;

static const unsigned int powTable[10] = {1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000};

/*
 * This is a UDF for Mysql/MariaDB.  It receives a string with a transform matrix
 * and a string with a WKT Polygon, then applies the transform matrix to the polygon.
 * It is built purely for speed, and assumes that the WKT Polygon is valid
 * and that the transform matrix has six numbers (int or float).  It does
 * no validation whatsoever.
 */

my_bool affine_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message );
char * affine_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error);
void affine_transform_deinit( UDF_INIT *initid );

my_bool affine_transform_init( UDF_INIT *initid, UDF_ARGS* args, char* message ) {
    if (args->arg_count == 2 && args->arg_type[0] == STRING_RESULT && args->arg_type[1] == STRING_RESULT) {
        initid->maybe_null = 0;
        initid->const_item = 1;
        unsigned int alength = args->lengths[1] * GROWTHFACTOR;
        initid->ptr = (char*) malloc(alength * sizeof(char));
        return 0;
    } else {
        strcpy(message, "affine_transform(): Incorrect usage. Use two and only two strings.");
        return 1;
    }
}

void affine_transform_deinit( UDF_INIT *initid ){
    free(initid->ptr);
    return;
}

char *affine_transform(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error) {

    float matrix[6];
    char *matrixString = args->args[0];
    unsigned int matrCount = 0;

    while(matrCount != 6) {

        if(DIGITORMINUS(*matrixString)) {

            char matr[323] = ""; // I guess this is the maximum length of a double in characters.
            unsigned int idx = 0;
            matr[idx++] = *matrixString++;
            while(isdigit(*matrixString) || *matrixString == '.') {
                matr[idx++] = *matrixString++;
            }
            matrix[matrCount++] = atof(matr);

        } else {
            ++matrixString;
        }
    }

    char *polygon = args->args[1];
    unsigned int polyCount = 0;
    unsigned int alength = args->lengths[1] * GROWTHFACTOR;
    *length = 0;
    char *transformPolygon = initid->ptr;

    while(polyCount < args->lengths[1]) {
        if (*length + 25 > alength) { //Grow the string if we near the end. I guess 11 chars for the maximum int length (x2) + 1 char for the space between them + 2 more chars for ")(" or "))".
            alength *= GROWTHFACTOR; 
            initid->ptr = (char*) realloc(initid->ptr, alength * sizeof(char));
            transformPolygon = initid->ptr + *length;
        }
        if(DIGITORMINUS(*polygon)) {
            unsigned char int1[10]; // We are storing single digit integers, char is the smallest integer data type in C.
            int idx = 0;
            int sign = 1;
            if (*polygon == '-'){
                sign = -1;
                ++*polygon;
                ++polyCount;
            }
            int1[idx] = *polygon++ - 48;
            ++polyCount;
            while(isdigit(*polygon)) {
                int1[++idx] = *polygon++ - 48;
                ++polyCount;
            }
            int adj1 = 0;
            for(unsigned int i = 0;idx > -1; --idx){
              adj1 += int1[idx] * powTable[i];
              ++i;
            }
            adj1 *= sign;

            memset(int1, 0, sizeof(int1));
            idx = 0;
            ++polygon; //Skip the whitespace.
            ++polyCount;
            sign = *polygon == '-' ? -1 : 1;
            if (sign == -1){
                *polygon++;
                ++polyCount;
            }
            int1[idx] = *polygon++ - 48;
            ++polyCount;
            while(isdigit(*polygon)) {
                int1[++idx] = *polygon++ - 48;
                ++polyCount;
            }
            int adj2 = 0;
            for(unsigned int i = 0;idx > -1; --idx){
              adj2 += int1[idx] * powTable[i];
              ++i;
            }
            adj2 *= sign;

            int new1 = (int)(adj1 * matrix[0] + adj2 * matrix[1] + matrix[2]);
            int new2 = (int)(adj1 * matrix[3] + adj2 * matrix[4] + matrix[5]);
            char *newLoc = (char*) malloc(23 * sizeof(char));
            sprintf(newLoc, "%d %d", new1, new2);
            for (int i = 0; newLoc[i] != 0; ++i){
                *transformPolygon++ = newLoc[i];
                ++*length;
            }
            free(newLoc);
        } else {
            *transformPolygon++ = *polygon++;
            ++polyCount;
            ++*length;
        }
    }
    //*transformPolygon = '\0';
    return initid->ptr;
}