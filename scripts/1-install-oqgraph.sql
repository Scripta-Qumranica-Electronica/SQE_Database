##############################
## Load the OQ Graph engine ##
##############################

INSTALL SONAME 'ha_oqgraph';

CREATE TABLE sign_stream
ENGINE=OQGRAPH 
data_table='position_in_stream' origid='origid' destid='destid';