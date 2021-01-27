-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.22.8";

INSERT INTO `db_version` (version)
VALUES (@VER);

ALTER TABLE `scribal_font_kerning` CHANGE COLUMN `first_unicode_char` `first_unicode_char` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL  COMMENT 'Charcode of the first glyph' AFTER `scribal_font_id`, ALTER COLUMN `first_unicode_char` DROP DEFAULT;

ALTER TABLE `scribal_font_kerning` CHANGE COLUMN `second_unicode_char` `second_unicode_char` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL  COMMENT 'Charcode of the second glyph' AFTER `first_unicode_char`, ALTER COLUMN `second_unicode_char` DROP DEFAULT;

ALTER TABLE `scribal_font_glyph_metrics` CHANGE COLUMN `unicode_char` `unicode_char` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL  COMMENT 'Char of font' AFTER `scribal_font_id`, ALTER COLUMN `unicode_char` DROP DEFAULT;

ALTER TABLE `scribal_font_kerning` ADD CONSTRAINT `unique_scribal_font_kerning` UNIQUE (`scribal_font_id`,`first_unicode_char`,`second_unicode_char`,`kerning_x`,`kerning_y`) USING BTREE;

ALTER TABLE `scribal_font_kerning` DROP INDEX `char_idx`;

ALTER TABLE `scribal_font_glyph_metrics` CHANGE COLUMN `width` `width` DOUBLE GENERATED ALWAYS AS (st_x(st_pointn(st_exteriorring(st_envelope(`shape`)),3)) - st_x(st_pointn(st_exteriorring(st_envelope(`shape`)),1))) VIRTUAL COMMENT 'Width of glyph' AFTER `unicode_char`;

ALTER TABLE `scribal_font_glyph_metrics` CHANGE COLUMN `height` `height` DOUBLE GENERATED ALWAYS AS (st_y(st_pointn(st_exteriorring(st_envelope(`shape`)),4)) - st_y(st_pointn(st_exteriorring(st_envelope(`shape`)),2))) VIRTUAL COMMENT 'Height of glyph' AFTER `width`;

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;