######################################
## Load the geom_transform function ##
######################################

DROP FUNCTION IF EXISTS geom_transform;
CREATE FUNCTION geom_transform RETURNS STRING SONAME 'geom_transform.so';


#############################################
## Load the nested_geom_transform function ##
#############################################

DROP FUNCTION IF EXISTS nested_geom_transform;
CREATE FUNCTION nested_geom_transform RETURNS STRING SONAME 'nested_geom_transform.so';