#############################################################
## Remove numeric_value from sign_interpretation_attribute ##
#############################################################

ALTER TABLE sign_interpretation_attribute
DROP INDEX unique_sign_interpretation_attribute_sequence_numeric_value;

CREATE UNIQUE INDEX unique_sign_interpretation_attribute_sequence
ON sign_interpretation_attribute(sign_interpretation_id, attribute_value_id, sequence);

ALTER TABLE `sign_interpretation_attribute` DROP COLUMN `numeric_value`;

##########################################
## Add usage columns to attribute table ##
##########################################

ALTER TABLE `attribute` ADD COLUMN `editable` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'This flag functions as a boolean (0: false, 1: true) determining whether a sign interpretation with an attribute_value of this attribute type can be changed from its current attribute_value to a different attribute_value of this attribute type.  This generally applies to control attributes like LINE_START, TEXT_FRAGMENT_END, etc., where one must perform a larger series of edits in the database to achieve the desired result of, e.g., deleting a line of text, or changing the start of a text fragment.' AFTER `creator_id`;

ALTER TABLE `attribute` ADD COLUMN `removable` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'This flag functions as a boolean (0: false, 1: true) determining whether a this type of attribute can be removed from a sign interpretation.  A sign interpretation that has a character value (not NULL) must have the LETTER attribute_value (which is a SIGN_TYPE attribute), such an attribute cannot be removed from the sign interpretation, it can only be edited.' AFTER `editable`;

ALTER TABLE `attribute` ADD COLUMN `repeatable` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'This flag functions as a boolean (0: false, 1: true) determining whether an attribute_value of this attribute type may be added more than once to the same sign interpretation.' AFTER `removable`;

ALTER TABLE `attribute` ADD COLUMN `batch_editable` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'This flag functions as a boolean (0: false, 1: true) to determine whether this attribute is intended to be set for multiple entities at the same time.' AFTER `repeatable`;

######################################################
## Set the correct values for the new usage columns ##
######################################################

UPDATE attribute
SET removable = 0, repeatable = 0
WHERE attribute_id = 1;

UPDATE attribute
SET editable = 0, batch_editable = 0
WHERE attribute_id = 2;