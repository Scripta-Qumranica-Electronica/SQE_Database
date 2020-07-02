###################################
## Use signed ints for positions ##
###################################

ALTER TABLE `artefact_position` CHANGE COLUMN `translate_x` `translate_x` INT(11) NULL DEFAULT NULL  COMMENT 'Translation of the artefact on the horizontal axis.' AFTER `rotate`;

ALTER TABLE `artefact_position` CHANGE COLUMN `translate_y` `translate_y` INT(11) NULL DEFAULT NULL  COMMENT 'Translation of the artefact on the vertical axis.' AFTER `translate_x`;

ALTER TABLE `artefact_position` CHANGE COLUMN `translate_x_non_null` `translate_x_non_null` INT(11) GENERATED ALWAYS AS (coalesce(`translate_x`,4294967295)) VIRTUAL COMMENT 'This is a generated column for the sake of uniqueness constraints.  It reads the highest possible value of an int instead of NULL, since that value is basically never going to be used (no scroll or manuscript has pages of such a length).' AFTER `translate_y`;

ALTER TABLE `artefact_position` CHANGE COLUMN `translate_y_non_null` `translate_y_non_null` INT(11) GENERATED ALWAYS AS (coalesce(`translate_y`,4294967295)) VIRTUAL COMMENT 'This is a generated column for the sake of uniqueness constraints.  I reads the highest possible value of an int instead of NULL, since that value is basically never going to be used (no scroll or manuscript has pages of such a length).' AFTER `translate_x_non_null`;

ALTER TABLE `roi_position` CHANGE COLUMN `translate_x` `translate_x` INT(11) NOT NULL DEFAULT 0  COMMENT 'The translation on the X axis necessary to position the a ROI shape in the artefact\'s coordinate system' AFTER `artefact_id`;

ALTER TABLE `roi_position` CHANGE COLUMN `translate_y` `translate_y` INT(11) NOT NULL DEFAULT 0  COMMENT 'The translation on the Y axis necessary to position the a ROI shape in the artefact\'s coordinate system' AFTER `translate_x`;

ALTER TABLE `manuscript_metrics` CHANGE COLUMN `x_origin` `x_origin` INT(11) NOT NULL DEFAULT 0  COMMENT 'This is the x value of the starting point of the manuscript.  The coordinate system begins top left, positive values increase while moving downward on the y-axis and while moving rightward on the x-axis.' AFTER `manuscript_id`;

ALTER TABLE `manuscript_metrics` CHANGE COLUMN `y_origin` `y_origin` INT(11) NOT NULL DEFAULT 0  COMMENT 'This is the y value of the starting point of the manuscript.  The coordinate system begins top left, positive values increase while moving downward on the y-axis and while moving rightward on the x-axis.' AFTER `x_origin`;

