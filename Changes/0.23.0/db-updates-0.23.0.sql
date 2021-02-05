START TRANSACTION;

-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.23.0";

INSERT INTO `db_version` (version)
VALUES (@VER);

-- Add creator_id to the image_catalog table

ALTER TABLE `image_catalog` ADD COLUMN `creator_id` INT(11) UNSIGNED NOT NULL DEFAULT 1 AFTER `object_id`;

ALTER TABLE `image_catalog`
ADD CONSTRAINT `fk_image_catalog_to_creator_id` 
FOREIGN KEY (`creator_id`) 
REFERENCES `user` (`user_id`) 
ON DELETE NO ACTION 
ON UPDATE NO ACTION;

-- Add table for storing image settings

CREATE TABLE `SQE_image_settings` (
  `SQE_image_settings_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `SQE_image_id` int(11) unsigned NOT NULL,
  `settings` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `creator_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`SQE_image_settings_id`),
  UNIQUE KEY `unique_sqe_image_settings` (`SQE_image_id`,`settings`) USING BTREE,
  KEY `fk_sqe_image_Settings_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_sqe_image_Settings_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sqe_image_settings_to_sqe_image` FOREIGN KEY (`SQE_image_id`) REFERENCES `SQE_image` (`sqe_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `SQE_image_settings_valid_json` CHECK (json_valid(`settings`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `SQE_image_settings_owner` (
  `SQE_image_settings_id` int(11) unsigned NOT NULL,
  `edition_id` int(11) unsigned NOT NULL,
  `edition_editor_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`SQE_image_settings_id`,`edition_id`),
  KEY `fk_SQE_image_settings_owner_to_edition_id` (`edition_id`),
  KEY `fk_SQE_image_settings_owner_to_edition_editor_id` (`edition_editor_id`),
  CONSTRAINT `fk_SQE_image_settings_owner_to_SQE_image_settings` FOREIGN KEY (`SQE_image_settings_id`) REFERENCES `SQE_image_settings` (`SQE_image_settings_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_SQE_image_settings_owner_to_edition_editor_id` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_SQE_image_settings_owner_to_edition_id` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Add table for desired image in artefact

CREATE TABLE `artefact_image` (
  `artefact_image_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_id` int(11) unsigned NOT NULL,
  `SQE_image_id` int(11) unsigned NOT NULL,
  `creator_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`artefact_image_id`),
  KEY `fk_artefact_image_to_artefact_id` (`artefact_id`),
  KEY `fk_artefact_image_to_sqe_image_id` (`SQE_image_id`),
  KEY `fk_artefact_image_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_artefact_image_to_artefact_id` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_image_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_image_to_sqe_image_id` FOREIGN KEY (`SQE_image_id`) REFERENCES `SQE_image` (`sqe_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `artefact_image_owner` (
  `artefact_image_id` int(11) unsigned NOT NULL,
  `edition_id` int(11) unsigned NOT NULL,
  `edition_editor_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`artefact_image_id`,`edition_id`),
  KEY `artefact_image_owner_to_edition` (`edition_id`),
  KEY `artefact_image_owner_to_edition_editor` (`edition_editor_id`),
  CONSTRAINT `artefact_image_owner_to_artefact_image` FOREIGN KEY (`artefact_image_id`) REFERENCES `artefact_image` (`artefact_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `artefact_image_owner_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `artefact_image_owner_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Update artefact view

DROP VIEW `artefact_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY INVOKER VIEW `artefact_view` AS select `SQE`.`artefact_data_owner`.`edition_id` AS `edition_id`,`SQE`.`artefact`.`artefact_id` AS `artefact_id`,`SQE`.`artefact_data`.`name` AS `name`,`SQE`.`artefact_data`.`creator_id` AS `data_creator_id`,`SQE`.`artefact_data_owner`.`edition_editor_id` AS `data_editor_id`,`as`.`region_in_sqe_image` AS `region_in_sqe_image`,`as`.`sqe_image_id` AS `sqe_image_id`,concat_ws('',`as`.`proxy`,`as`.`url`,`as`.`filename`) AS `full_url`,`as`.`url` AS `url`,`as`.`suffix` AS `suffix`,`as`.`proxy` AS `proxy`,`as`.`filename` AS `filename`,`as`.`creator_id` AS `shape_creator_id`,`as`.`edition_editor_id` AS `shape_editor_id`,`ap`.`z_index` AS `z_index`,`ap`.`scale` AS `scale`,`ap`.`rotate` AS `rotate`,`ap`.`translate_x` AS `translate_x`,`ap`.`translate_y` AS `translate_y`,`ap`.`creator_id` AS `position_creator_id`,`ap`.`edition_editor_id` AS `position_editor_id`,`astat`.`work_status_message` AS `work_status_message`,`astat`.`creator_id` AS `status_creator_id`,`astat`.`edition_editor_id` AS `status_editor_id`,`aimage`.`SQE_image_id` AS `selected_sqe_image_id`,`aimage`.`creator_id` AS `selected_sqe_image_creator_id`,`aimage`.`edition_editor_id` AS `selected_sqe_image_editor_id` from ((((((`SQE`.`artefact` join `SQE`.`artefact_data` on(`SQE`.`artefact`.`artefact_id` = `SQE`.`artefact_data`.`artefact_id`)) join `SQE`.`artefact_data_owner` on(`SQE`.`artefact_data`.`artefact_data_id` = `SQE`.`artefact_data_owner`.`artefact_data_id`)) left join (select `SQE`.`artefact_shape`.`artefact_id` AS `artefact_id`,`SQE`.`artefact_shape`.`region_in_sqe_image` AS `region_in_sqe_image`,`SQE`.`artefact_shape`.`sqe_image_id` AS `sqe_image_id`,`SQE`.`artefact_shape`.`creator_id` AS `creator_id`,`SQE`.`SQE_image`.`filename` AS `filename`,`SQE`.`image_urls`.`url` AS `url`,`SQE`.`image_urls`.`suffix` AS `suffix`,`SQE`.`image_urls`.`proxy` AS `proxy`,`SQE`.`artefact_shape_owner`.`edition_id` AS `edition_id`,`SQE`.`artefact_shape_owner`.`edition_editor_id` AS `edition_editor_id` from (((`SQE`.`artefact_shape` join `SQE`.`artefact_shape_owner` on(`SQE`.`artefact_shape`.`artefact_shape_id` = `SQE`.`artefact_shape_owner`.`artefact_shape_id`)) left join `SQE`.`SQE_image` on(`SQE`.`artefact_shape`.`sqe_image_id` = `SQE`.`SQE_image`.`sqe_image_id`)) left join `SQE`.`image_urls` on(`SQE`.`SQE_image`.`image_urls_id` = `SQE`.`image_urls`.`image_urls_id`))) `as` on(`as`.`artefact_id` = `SQE`.`artefact`.`artefact_id` and `as`.`edition_id` = `SQE`.`artefact_data_owner`.`edition_id`)) left join (select `SQE`.`artefact_position`.`artefact_id` AS `artefact_id`,`SQE`.`artefact_position`.`z_index` AS `z_index`,`SQE`.`artefact_position`.`scale` AS `scale`,`SQE`.`artefact_position`.`rotate` AS `rotate`,`SQE`.`artefact_position`.`translate_x` AS `translate_x`,`SQE`.`artefact_position`.`translate_y` AS `translate_y`,`SQE`.`artefact_position`.`creator_id` AS `creator_id`,`SQE`.`artefact_position_owner`.`edition_id` AS `edition_id`,`SQE`.`artefact_position_owner`.`edition_editor_id` AS `edition_editor_id` from (`SQE`.`artefact_position` join `SQE`.`artefact_position_owner` on(`SQE`.`artefact_position`.`artefact_position_id` = `SQE`.`artefact_position_owner`.`artefact_position_id`))) `ap` on(`ap`.`artefact_id` = `SQE`.`artefact`.`artefact_id` and `ap`.`edition_id` = `SQE`.`artefact_data_owner`.`edition_id`)) left join (select `SQE`.`artefact_status`.`artefact_id` AS `artefact_id`,`SQE`.`work_status`.`work_status_message` AS `work_status_message`,`SQE`.`artefact_status`.`creator_id` AS `creator_id`,`SQE`.`artefact_status_owner`.`edition_id` AS `edition_id`,`SQE`.`artefact_status_owner`.`edition_editor_id` AS `edition_editor_id` from ((`SQE`.`artefact_status` join `SQE`.`artefact_status_owner` on(`SQE`.`artefact_status`.`artefact_status_id` = `SQE`.`artefact_status_owner`.`artefact_status_id`)) join `SQE`.`work_status` on(`SQE`.`artefact_status`.`work_status_id` = `SQE`.`work_status`.`work_status_id`))) `astat` on(`astat`.`artefact_id` = `SQE`.`artefact`.`artefact_id` and `astat`.`edition_id` = `SQE`.`artefact_data_owner`.`edition_id`)) left join (select `SQE`.`artefact_image`.`SQE_image_id` AS `SQE_image_id`,`SQE`.`artefact_image`.`artefact_id` AS `artefact_id`,`SQE`.`artefact_image`.`creator_id` AS `creator_id`,`SQE`.`artefact_image_owner`.`edition_id` AS `edition_id`,`SQE`.`artefact_image_owner`.`edition_editor_id` AS `edition_editor_id` from (`SQE`.`artefact_image` join `SQE`.`artefact_image_owner` on(`SQE`.`artefact_image`.`artefact_image_id` = `SQE`.`artefact_image_owner`.`artefact_image_id`))) `aimage` on(`aimage`.`artefact_id` = `SQE`.`artefact`.`artefact_id` and `aimage`.`edition_id` = `SQE`.`artefact_data_owner`.`edition_id`));

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;