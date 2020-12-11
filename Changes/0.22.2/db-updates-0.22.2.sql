-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.22.2";

INSERT INTO `db_version` (version)
VALUES (@VER);

-- Fix foreign keys
ALTER TABLE sign_interpretation_attribute_owner 
DROP FOREIGN KEY IF EXISTS `fk_sign_interpretation_attr_owner_to_sca`;

ALTER TABLE sign_interpretation_character_owner
DROP FOREIGN KEY IF EXISTS `fk_sichar_owner_to_edition_editor`;

ALTER TABLE sign_interpretation_character_owner
ADD CONSTRAINT `fk_sichar_owner_to_edition_editor`
FOREIGN KEY (edition_editor_id) REFERENCES edition_editor(edition_editor_id); 

-- Add switch for mirroring of artefacts
ALTER TABLE `artefact_position` 
ADD COLUMN IF NOT EXISTS `mirrored` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'A boolean flag.  A value of 1 means that the artefact should appear mirrored.' AFTER `translate_y_non_null`;

CREATE OR REPLACE UNIQUE INDEX `fk_unique_artefact_position` 
ON artefact_position(`artefact_id`,`rotate`,`scale`,`translate_x_non_null`,`translate_y_non_null`,`z_index`, `mirrored`) 
USING BTREE;

-- Add scribal font glyphs
ALTER TABLE scribal_font_glyph_metrics
ADD COLUMN IF NOT EXISTS `shape` MULTIPOLYGON NOT NULL DEFAULT GEOMFROMTEXT('MULTIPOLYGON(((0 0,200 0,200 100,0 100,0 0)))') COMMENT 'The vector glyph shape of the character' AFTER `y_offset`;

ALTER TABLE `scribal_font_glyph_metrics` DROP COLUMN IF EXISTS `width`;
ALTER TABLE `scribal_font_glyph_metrics` ADD COLUMN  `width` DOUBLE AS (ST_X(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(shape)), 2)) - ST_X(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(shape)), 0))) VIRTUAL COMMENT 'Width of glyph' AFTER `unicode_char`, ALTER COLUMN `width` DROP DEFAULT;

ALTER TABLE `scribal_font_glyph_metrics` DROP COLUMN IF EXISTS `height`;
ALTER TABLE `scribal_font_glyph_metrics` ADD COLUMN  `height` DOUBLE AS (ST_Y(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(shape)), 2)) - ST_Y(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(shape)), 0))) VIRTUAL COMMENT 'Height of glyph' AFTER `width`, ALTER COLUMN `height` DROP DEFAULT;

ALTER TABLE `scribal_font_glyph_metrics` CHANGE COLUMN `unicode_char` `unicode_char` CHAR(1) NOT NULL  COMMENT 'Char of font' AFTER `scribal_font_id`, ALTER COLUMN `unicode_char` DROP DEFAULT;

ALTER TABLE scribal_font_glyph_metrics
DROP INDEX IF EXISTS `char_idx`;

ALTER TABLE `scribal_font_kerning` CHANGE COLUMN `first_unicode_char` `first_unicode_char` CHAR(1) NOT NULL  COMMENT 'Charcode of the first glyph' AFTER `scribal_font_id`, ALTER COLUMN `first_unicode_char` DROP DEFAULT;

ALTER TABLE `scribal_font_kerning` CHANGE COLUMN `second_unicode_char` `second_unicode_char` CHAR(1) NOT NULL  COMMENT 'Charcode of the second glyph' AFTER `first_unicode_char`, ALTER COLUMN `second_unicode_char` DROP DEFAULT;

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;