DROP FUNCTION IF EXISTS multiply_matrix;
CREATE FUNCTION multiply_matrix RETURNS STRING SONAME 'multiply_matrix.so';