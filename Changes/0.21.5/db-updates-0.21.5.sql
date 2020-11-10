/*
 * Set the version of this update 
 */
INSERT INTO `db_version` (version)
VALUES ("0.21.5");

DROP TABLE IF EXISTS materialized_sign_stream_schedule;
DROP TABLE IF EXISTS materialized_sign_stream_indices;
DROP TABLE IF EXISTS materialized_sign_stream;

CREATE TABLE `materialized_sign_stream` (
  `materlialized_sign_stream_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `edition_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'Edition of the sign stream materialization.',
  `initial_sign_interpretation_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The id of the first sign interpretation in DAG of sign interpretations.',
  `materialized_text` mediumtext DEFAULT NULL COMMENT 'A concatenated string of the character values in the DAG beginning with the initial_sign_interpretation_id.  These values can be related to their sign_interpretation_id by finding the index of a given character within the string and looking up that index value in the table materialized_sign_stream_indices.',
  PRIMARY KEY (`materlialized_sign_stream_id`),
  UNIQUE KEY `unique_edition_sign_interpretation` (`edition_id`,`initial_sign_interpretation_id`) USING BTREE,
  KEY `materialized_sign_stream_to_initial_sign_interpretation_id` (`initial_sign_interpretation_id`),
  CONSTRAINT `fk_materialized_sign_stream_to_edition_id` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `materialized_sign_stream_to_initial_sign_interpretation_id` FOREIGN KEY (`initial_sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This table is used to store every variant sequence for each possible sign stream DAG.  The sign interpretation id can be found by searching the materialized_sign_stream_indices table for the index of a character with the materialized_text string.';

CREATE TABLE `materialized_sign_stream_indices` (
  `materialized_sign_stream_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The ID of the materialized sign stream.',
  `index` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The index of a character within a materialized sign stream.',
  `sign_interpretation_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The sign interpretation id of the character at the location in the index column within the materialized sign stream string.',
  PRIMARY KEY (`materialized_sign_stream_id`,`index`),
  KEY `materialized_sign_stream_index_to_sign_interpretation_id` (`sign_interpretation_id`),
  CONSTRAINT `materialized_sign_stream_index_to_materialized_sign_stream_id` FOREIGN KEY (`materialized_sign_stream_id`) REFERENCES `materialized_sign_stream` (`materlialized_sign_stream_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `materialized_sign_stream_index_to_sign_interpretation_id` FOREIGN KEY (`sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This table is used to find specific sign interpretation IDs based on the index of a character within a string stored in the materialized_sign_stream table.';

CREATE TABLE `materialized_sign_stream_schedule` (
  `edition_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'Edition for the materialized sign stream.',
  `initial_sign_interpretation_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The initial sign interpretation id for the stream that needs to be materialized.',
  `time_initiated` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'The date that a materialization was requested.',
  PRIMARY KEY (`initial_sign_interpretation_id`,`edition_id`),
  KEY `fk_materialized_sign_stream_schedule_to_edition_id` (`edition_id`),
  CONSTRAINT `fk_materialized_sign_stream_schedule_to_edition_id` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `materialized_sign_stream_schedule_to_sign_interpretation_id` FOREIGN KEY (`initial_sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table is used for a scheduler to determine which sign streams will need to be materialized into the materialized_sign_stream and materialized_sign_stream_index tables.  It is meant to be read by a scheduler that will create the materialized sign stream for all entries in this table (the entries should be deleted once the materialization is complete).';

/*
 * Record the completion of the update 
 */
 UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = "0.21.5";