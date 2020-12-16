-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.22.4";

INSERT INTO `db_version` (version)
VALUES (@VER);

-- Create font metrics table
CREATE TABLE `scribal_font_metrics` (
  `scribal_font_metrics_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `scribal_font_id` int(11) unsigned NOT NULL,
  `default_word_space` smallint(5) unsigned NOT NULL DEFAULT 85 COMMENT 'The default space in pixel to be set between two words',
  `default_interlinear_space` smallint(5) unsigned NOT NULL DEFAULT 280 COMMENT 'The default space between two lines in pixel',
  `creator_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`scribal_font_metrics_id`),
  KEY `fk_scribal_font_metrics_to_scribal_font` (`scribal_font_id`),
  KEY `fk_scribal_font_metrics_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_scribal_font_metrics_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_scribal_font_metrics_to_scribal_font` FOREIGN KEY (`scribal_font_id`) REFERENCES `scribal_font` (`scribal_font_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='This table stores information about the default spacing for a scribal font.';

CREATE TABLE `scribal_font_metrics_owner` (
  `scribal_font_metrics_id` int(11) unsigned NOT NULL,
  `edition_id` int(11) unsigned NOT NULL,
  `edition_editor_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`scribal_font_metrics_id`,`edition_id`),
  KEY `fk_scribal_font_metrics_owner_to_edition_id` (`edition_id`),
  KEY `fk_scribal_font_metrics_owner_to_edition_editor_id` (`edition_editor_id`),
  CONSTRAINT `fk_scribal_font_metrics_owner_to_edition_editor_id` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_scribal_font_metrics_owner_to_edition_id` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_scribal_font_metrics_owner_to_scribal_font_metrics` FOREIGN KEY (`scribal_font_metrics_id`) REFERENCES `scribal_font_metrics` (`scribal_font_metrics_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Make scribal Font and abstract key 

ALTER TABLE `scribal_font` DROP FOREIGN KEY IF EXISTS `fk_scribal_font_to_creator_id` ;

ALTER TABLE `scribal_font` DROP INDEX IF EXISTS `fk_scribal_font_to_creator_id` ;

ALTER TABLE `scribal_font` DROP COLUMN IF EXISTS `font_file_id` ;

ALTER TABLE `scribal_font` DROP COLUMN IF EXISTS `default_word_space` ;

ALTER TABLE `scribal_font` DROP COLUMN IF EXISTS `default_interlinear_space` ;

ALTER TABLE `scribal_font` DROP COLUMN IF EXISTS `creator_id` ;

-- Update scribal font file to reference scribal font
ALTER TABLE `font_file` ADD COLUMN `scribal_font_id` INT(11) UNSIGNED NOT NULL AFTER `font_file_id`;

ALTER TABLE font_file
ADD CONSTRAINT `fk_font_file_to_scribal_font` FOREIGN KEY IF NOT EXISTS (`scribal_font_id`) REFERENCES `scribal_font` (`scribal_font_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;