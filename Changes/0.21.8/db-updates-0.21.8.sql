/*
 * Set the version of this update 
 */
INSERT INTO `db_version` (version)
VALUES ("0.21.8");

/*
 * Setup the proper uniqueness constraint on the iaa_edition_catalog
 */
UPDATE iaa_edition_catalog
SET comment = ""
WHERE comment IS NULL;

ALTER TABLE `iaa_edition_catalog` CHANGE COLUMN `comment` `comment` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT ''  COMMENT 'Extra comments.' AFTER `manuscript_id`;
ALTER TABLE `iaa_edition_catalog` DROP COLUMN IF EXISTS `comment_hash`;
ALTER TABLE `iaa_edition_catalog` ADD COLUMN `comment_hash` CHAR(56) AS (sha2(comment, 224)) VIRTUAL;
ALTER TABLE `iaa_edition_catalog` CHANGE COLUMN `manuscript` `manuscript` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NULL'  COMMENT 'Standard designation of the manuscript.' AFTER `iaa_edition_catalog_id`;
ALTER TABLE `iaa_edition_catalog` CHANGE COLUMN `edition_name` `edition_name` VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NULL'  COMMENT 'Name of the publication in which the editio princeps appears.' AFTER `manuscript`;
ALTER TABLE `iaa_edition_catalog` DROP INDEX `unique_edition_entry`, ADD UNIQUE INDEX `unique_edition_entry` USING BTREE  (`edition_location_1`, `edition_location_2`, `edition_name`, `edition_side`, `edition_volume`, `manuscript`, `comment_hash`);

/*
 * Fix the unique key in the materialized sign stream
 */
ALTER TABLE `materialized_sign_stream` DROP FOREIGN KEY IF EXISTS `fk_materialized_sign_stream_to_edition_id`;
ALTER TABLE `materialized_sign_stream` DROP FOREIGN KEY IF EXISTS `materialized_sign_stream_to_initial_sign_interpretation_id`;
ALTER TABLE `materialized_sign_stream` DROP INDEX IF EXISTS `unique_edition_sign_interpretation`;

ALTER TABLE `materialized_sign_stream` ADD CONSTRAINT `fk_materialized_sign_stream_to_edition_id` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `materialized_sign_stream` ADD CONSTRAINT `fk_materialized_sign_stream_to_sign_interpretation_id` FOREIGN KEY (`initial_sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`) ON DELETE CASCADE ON UPDATE CASCADE;

/*
 * Record the completion of the update 
 */
 UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = "0.21.8";