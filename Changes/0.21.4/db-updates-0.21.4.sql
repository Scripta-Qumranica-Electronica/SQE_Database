/*
 * Create the table to hold
 * the materialized sign streams. 
 */
CREATE TABLE `materialized_sign_stream` (
  `materlialized_sign_stream_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `initial_sign_interpretation_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The id of the first sign interpretation in DAG of sign interpretations.',
  `materialized_text` mediumtext DEFAULT NULL COMMENT 'A concatenated string of the character values in the DAG beginning with the initial_sign_interpretation_id.  These values can be related to their sign_interpretation_id by finding the index of a given character within the string and looking up that index value in the table materialized_sign_stream_indices.',
  PRIMARY KEY (`materlialized_sign_stream_id`),
  KEY `materialized_sign_stream_to_initial_sign_interpretation_id` (`initial_sign_interpretation_id`),
  CONSTRAINT `materialized_sign_stream_to_initial_sign_interpretation_id` FOREIGN KEY (`initial_sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This table is used to store every variant sequence for each possible sign stream DAG.  The sign interpretation id can be found by searching the materialized_sign_stream_indices table for the index of a charachter with the materialized_text string.';

/*
 * Create the table to lookup sign interpretation IDs
 * according to their index in a materialized_sign_stream
 * string. 
 */
CREATE TABLE `materialized_sign_stream_indices` (
  `materialized_sign_stream_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The ID of the materialized sign stream.',
  `index` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The index of a character within a materialized sign stream.',
  `sign_interpretation_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The sign interpretation id of the character at the location in the index column within the materialized sign stream string.',
  PRIMARY KEY (`materialized_sign_stream_id`,`index`),
  KEY `materialized_sign_stream_index_to_sign_interpretation_id` (`sign_interpretation_id`),
  CONSTRAINT `materialized_sign_stream_index_to_materialized_sign_stream_id` FOREIGN KEY (`materialized_sign_stream_id`) REFERENCES `materialized_sign_stream` (`materlialized_sign_stream_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `materialized_sign_stream_index_to_sign_interpretation_id` FOREIGN KEY (`sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This table is used to find specific sign interpretation IDs based on the index of a character within a string stored in the materialized_sign_stream table.';

/*
 * Create the materialization schedule table to store sign
 * interpretation ids that begin sign streams that need to
 * be materialized.
 */
CREATE TABLE `materialized_sign_stream_schedule` (
  `initial_sign_interpretation_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The initial sign interpretation id for the stream that needs to be materialized.',
  `time_initiated` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'The date that a materialization was requested.',
  PRIMARY KEY (`initial_sign_interpretation_id`),
  CONSTRAINT `materialized_sign_stream_schedule_to_sign_interpretation_id` FOREIGN KEY (`initial_sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table is used for a scheduler to determine which sign streams will need to be materialized into the materialized_sign_stream and materialized_sign_stream_index tables.  It is meant to be read by a scheduler that will create the materialized sign stream for all entries in this table (the entries should be deleted once the materialization is complete).';

/*
 * Create a table to keep track of the database versioning 
 */
CREATE TABLE `db_version` (
  `version` varchar(255) NOT NULL DEFAULT '' COMMENT 'The version designation of the database update.',
  `started` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'The date at which the database update was started.',
  `completed` datetime DEFAULT NULL COMMENT 'The time at which the version update was completed.',
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This table stores information about the development version history of the database.  It indicates when each version update was carried out.';

/*
 * Set the version of this update 
 */
INSERT INTO `db_version` (version)
VALUES ("0.21.4");

UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = "0.21.4";

/*
 * Create a convenience function to get the current database version.
 * The create function must be run with sufficient database privileges. 
 */
CREATE DEFINER=`root`@`%` FUNCTION `current_db_version`() RETURNS varchar(255) CHARSET latin1
    READS SQL DATA
    DETERMINISTIC
    SQL SECURITY INVOKER
    COMMENT 'Returns the latest fully loaded version identifier for development updates to the database schema.'
RETURN (SELECT version FROM db_version WHERE completed IS NOT NULL ORDER BY completed DESC LIMIT 1);