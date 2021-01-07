-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "CURRENT_DATABASE_VERSION";

INSERT INTO `db_version` (version)
VALUES (@VER);

DROP TABLE IF EXISTS `scribal_font_glyph_metrics_owner`;
DROP TABLE IF EXISTS `scribal_font_glyph_metrics`;

CREATE TABLE `scribal_font_glyph_metrics` (
  `scribal_font_glyph_metrics_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier',
  `scribal_font_id` int(10) unsigned NOT NULL COMMENT 'Reference to scribal font',
  `unicode_char` char(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Char of font',
  `width` double GENERATED ALWAYS AS (st_x(st_pointn(st_exteriorring(st_envelope(`shape`)),2)) - st_x(st_pointn(st_exteriorring(st_envelope(`shape`)),0))) VIRTUAL COMMENT 'Width of glyph',
  `height` double GENERATED ALWAYS AS (st_y(st_pointn(st_exteriorring(st_envelope(`shape`)),2)) - st_y(st_pointn(st_exteriorring(st_envelope(`shape`)),0))) VIRTUAL COMMENT 'Height of glyph',
  `y_offset` smallint(6) NOT NULL DEFAULT -200 COMMENT 'Vertical offset glyph (thought to stand on line)',
  `shape` geometry NOT NULL DEFAULT st_geometryfromtext('MULTIPOLYGON(((0 0,200 0,200 100,0 100,0 0)))') COMMENT 'The vector glyph shape of the character',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`scribal_font_glyph_metrics_id`),
  KEY `fk_sfg_to_scribal_font` (`scribal_font_id`),
  KEY `fk_scribal_font_glyph_metrics_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_scribal_font_glyph_metrics_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sfg_to_scribal_font` FOREIGN KEY (`scribal_font_id`) REFERENCES `scribal_font` (`scribal_font_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Contains the bounding box and position metrics of a scribal font. Only used to calculate ROIs not yet set by the user.';

CREATE TABLE `scribal_font_glyph_metrics_owner` (
  `scribal_font_glyph_metrics_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`scribal_font_glyph_metrics_id`,`edition_id`),
  KEY `fk_sfgm_to_edition` (`edition_id`),
  KEY `fk_sfgm_to_edition_editor` (`edition_editor_id`),
  CONSTRAINT `fk_sfgm_owner_to_sfgm` FOREIGN KEY (`scribal_font_glyph_metrics_id`) REFERENCES `scribal_font_glyph_metrics` (`scribal_font_glyph_metrics_id`),
  CONSTRAINT `fk_sfgm_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_sfgm_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE `scribal_font_kerning_owner`;
DROP TABLE `scribal_font_kerning`;

CREATE TABLE `scribal_font_kerning` (
  `scribal_font_kerning_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier',
  `scribal_font_id` int(10) unsigned NOT NULL COMMENT 'Reference to scribal font',
  `first_unicode_char` char(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Charcode of the first glyph',
  `second_unicode_char` char(1) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Charcode of the second glyph',
  `kerning_x` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Horizontal kerning',
  `kerning_y` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Vertical kerning',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`scribal_font_kerning_id`),
  UNIQUE KEY `char_idx` (`scribal_font_id`,`first_unicode_char`,`second_unicode_char`),
  KEY `fk_scribal_font_kerning_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_scribal_font_kerning_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sfk_to_scribal_font` FOREIGN KEY (`scribal_font_id`) REFERENCES `scribal_font` (`scribal_font_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Contains kerning of glyph of a scribal font. Only used to calculated the position of signs not yet positioned by the user';

CREATE TABLE `scribal_font_kerning_owner` (
  `scribal_font_kerning_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`scribal_font_kerning_id`,`edition_id`),
  KEY `fk_sfk_to_edition` (`edition_id`),
  KEY `fk_sfk_to_edition_editor` (`edition_editor_id`),
  CONSTRAINT `fk_sfk_owner_to_sfk` FOREIGN KEY (`scribal_font_kerning_id`) REFERENCES `scribal_font_kerning` (`scribal_font_kerning_id`),
  CONSTRAINT `fk_sfk_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_sfk_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;