######################################
## Assign base data to sqe_api user ##
######################################

UPDATE iaa_edition_catalog_to_text_fragment_confirmation
SET user_id = 1
WHERE user_id IS NULL;

#####################################
## Alter table nullable properties ##
#####################################

ALTER TABLE `iaa_edition_catalog_to_text_fragment_confirmation` CHANGE COLUMN `confirmed` `confirmed` TINYINT(1) UNSIGNED NULL DEFAULT 0  COMMENT 'Boolean for whether the match has been confirmed (1) or rejected (0).  If this is set to 0 and the user_id is NULL, then the match has neither been confirmed nor rejected (thus it should be queued for review).' AFTER `iaa_edition_catalog_to_text_fragment_id`;

ALTER TABLE `iaa_edition_catalog_to_text_fragment_confirmation` CHANGE COLUMN `user_id` `user_id` INT(11) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'user_id of the person who has confirmed or rejected the match.  If NULL, the match has neither been confirmed nor rejected.' AFTER `confirmed`;

UPDATE iaa_edition_catalog_to_text_fragment_confirmation
SET confirmed = NULL
WHERE user_id = 1;