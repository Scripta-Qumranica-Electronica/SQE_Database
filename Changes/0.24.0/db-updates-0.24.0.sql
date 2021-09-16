
-- Add positioning columns to the image to image map table
ALTER TABLE `image_to_image_map` ADD COLUMN IF NOT EXISTS `scale` DECIMAL(6, 4) NOT NULL DEFAULT 1.0 AFTER `transform_matrix`;

ALTER TABLE `image_to_image_map` ADD COLUMN IF NOT EXISTS `rotate` DECIMAL(6, 2) NOT NULL DEFAULT 0 AFTER `scale`;

ALTER TABLE `image_to_image_map` ADD COLUMN IF NOT EXISTS `translate_x` INT(10) NOT NULL DEFAULT 0 AFTER `rotate`;

ALTER TABLE `image_to_image_map` ADD COLUMN IF NOT EXISTS `translate_y` INT(10) NOT NULL DEFAULT 0 AFTER `translate_x`;

ALTER TABLE `image_to_image_map` DROP INDEX IF EXISTS `unique_image_to_image_map`;

ALTER TABLE `image_to_image_map` ADD CONSTRAINT `unique_image_to_image_map` UNIQUE KEY (`image1_id`,`image2_id`,`region1_hash`,`region2_hash`,`scale`,`rotate`,`translate_x`,`translate_y`) USING BTREE;

ALTER TABLE `image_to_image_map` DROP COLUMN IF EXISTS `transform_matrix` ;
