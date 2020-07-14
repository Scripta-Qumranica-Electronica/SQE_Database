##########################
## Fix attribute issues ##
##########################

UPDATE attribute
SET description='Defines a metasign marking a disruption in the text, probably do to physical manuscript damage'
WHERE attribute_id = 2;

UPDATE attribute_value
SET string_value = 'TEXT_FRAGMENT_START'
WHERE attribute_value_id = 12;

UPDATE attribute_value
SET string_value = 'TEXT_FRAGMENT_END'
WHERE attribute_value_id = 13;

UPDATE attribute_value
SET string_value = 'MANUSCRIPT_START'
WHERE attribute_value_id = 14;

UPDATE attribute_value
SET string_value = 'MANUSCRIPT_END'
WHERE attribute_value_id = 15;