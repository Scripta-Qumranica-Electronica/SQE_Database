##########################################
## Change numeric_value to decimal type ##
##########################################

ALTER TABLE `sign_interpretation_attribute` CHANGE COLUMN `numeric_value` `numeric_value` DECIMAL(8, 2) NULL DEFAULT NULL  COMMENT 'Contains the width of a character (normally 1), space (dto.), or vacat (normally > 1) or the level of probability.' AFTER `sequence`;

####################################################
## Include numeric_value in uniqueness constraint ##
####################################################

ALTER TABLE sign_interpretation_attribute 
DROP INDEX unique_sign_interpretation_id_attribute_value_id_sequence, 
ADD UNIQUE KEY `unique_sign_interpretation_attribute_sequence_numeric_value` (`attribute_value_id`,`sequence`,`sign_interpretation_id`,`numeric_value`) USING BTREE;