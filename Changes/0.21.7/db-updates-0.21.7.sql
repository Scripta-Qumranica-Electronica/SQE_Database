/*
 * Set the version of this update 
 */
INSERT INTO `db_version` (version)
VALUES ("0.21.7");

ALTER TABLE `position_in_stream` CHANGE COLUMN `next_sign_interpretation_id` `next_sign_interpretation_id` INT(11) UNSIGNED NOT NULL DEFAULT 0  COMMENT '' AFTER `sign_interpretation_id`;

DROP TABLE IF EXISTS sign_stream;

CREATE TABLE sign_stream (
  latch VARCHAR(32) NULL,
  origid BIGINT UNSIGNED NULL,
  destid BIGINT UNSIGNED NULL,
  weight DOUBLE NULL,
  seq BIGINT UNSIGNED NULL,
  linkid BIGINT UNSIGNED NULL,
  KEY (latch, origid, destid) USING HASH,
  KEY (latch, destid, origid) USING HASH
) 
ENGINE=OQGRAPH 
data_table='position_in_stream' origid='sign_interpretation_id' destid='next_sign_interpretation_id';

DROP TABLE IF EXISTS sign_stream_reverse;

CREATE TABLE sign_stream_reverse (
  latch VARCHAR(32) NULL,
  origid BIGINT UNSIGNED NULL,
  destid BIGINT UNSIGNED NULL,
  weight DOUBLE NULL,
  seq BIGINT UNSIGNED NULL,
  linkid BIGINT UNSIGNED NULL,
  KEY (latch, origid, destid) USING HASH,
  KEY (latch, destid, origid) USING HASH
) 
ENGINE=OQGRAPH 
data_table='position_in_stream' origid='next_sign_interpretation_id' destid='sign_interpretation_id';

/*
 * Record the completion of the update 
 */
 UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = "0.21.7";