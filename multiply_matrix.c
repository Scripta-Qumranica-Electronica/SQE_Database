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
#define DIGITORPERIOD(poly) (isdigit(poly) || poly == '.')

static pthread_mutex_t LOCK_hostname;

/*
 * This is a UDF for Mysql/MariaDB.  It receives a string with a transform matrix
 * and a string with a WKT Polygon, then applies the transform matrix to the polygon.
 * It is built purely for speed, and assumes that the WKT Polygon is valid
 * and that the transform matrix has six numbers (int or float).  It does
 * no validation whatsoever.
 */

my_bool multiply_matrix_init( UDF_INIT *initid, UDF_ARGS* args, char* message );
char * multiply_matrix(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error);
void multiply_matrix_deinit( UDF_INIT *initid );

my_bool multiply_matrix_init( UDF_INIT *initid, UDF_ARGS* args, char* message ) {
    if (args->arg_count == 2 && args->arg_type[0] == STRING_RESULT && args->arg_type[1] == STRING_RESULT) {
        initid->maybe_null = 0;
        initid->const_item = 1;
        return 0;
    } else {
        strcpy(message, "matrix_multiply(): Incorrect usage. Use two and only two strings.");
        return 1;
    }
}

void multiply_matrix_deinit( UDF_INIT *initid ){
    return;
}

char *multiply_matrix(UDF_INIT *initid, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error) {

    // Parse the first matrix
    double matrix1[6];
    char *matrixString1 = args->args[0];
    unsigned int matrCount = 0;

    while(matrCount != 6) {

        if(DIGITORMINUS(*matrixString1)) {

            char matr[323] = ""; // I guess this is the maximum length of a double in characters.
            unsigned int idx = 0;
            matr[idx++] = *matrixString1++;
            while(DIGITORPERIOD(*matrixString1)) {
                matr[idx++] = *matrixString1++;
            }
            matrix1[matrCount++] = atof(matr);

        } else {
            ++matrixString1;
        }
    }

    // Parse the second matrix
    double matrix2[6];
    char *matrixString2 = args->args[1];
    matrCount = 0;

    while(matrCount != 6) {

        if(DIGITORMINUS(*matrixString2)) {

            char matr[323] = ""; // I guess this is the maximum length of a double in characters.
            unsigned int idx = 0;
            matr[idx++] = *matrixString2++;
            while(DIGITORPERIOD(*matrixString2)) {
                matr[idx++] = *matrixString2++;
            }
            matrix2[matrCount++] = atof(matr);

        } else {
            ++matrixString2;
        }
    }

    // Prepare the string with the multiplied matrices
    sprintf(result, "{\"matrix\":[[%.15g,%.15g,%d],[%.15g,%.15g,%d]]}", 
      (matrix1[0] * matrix2[0]) + (matrix1[1] * matrix2[3]) + (matrix1[2] * 0), 
      (matrix1[0] * matrix2[1]) + (matrix1[1] * matrix2[4]) + (matrix1[2] * 0),
      (int)((matrix1[0] * matrix2[2]) + (matrix1[1] * matrix2[5]) + (matrix1[2] * 1)),
      (matrix1[3] * matrix2[0]) + (matrix1[4] * matrix2[3]) + (matrix1[5] * 0), 
      (matrix1[3] * matrix2[1]) + (matrix1[4] * matrix2[4]) + (matrix1[5] * 0),
      (int)((matrix1[3] * matrix2[2]) + (matrix1[4] * matrix2[5]) + (matrix1[5] * 1)));

    //Grab the result and return it
    *length = strlen(result);
    return result;
}