DROP FUNCTION IF EXISTS affine_transform;
CREATE FUNCTION affine_transform RETURNS STRING SONAME 'affine_transform.so';