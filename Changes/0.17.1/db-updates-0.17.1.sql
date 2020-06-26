###################################
## Add new geom transform C UDFs ##
###################################

DROP FUNCTION IF EXISTS geom_transform;
CREATE FUNCTION geom_transform RETURNS STRING SONAME 'geom_transform.so';

DROP FUNCTION IF EXISTS nested_geom_transform;
CREATE FUNCTION nested_geom_transform RETURNS STRING SONAME 'nested_geom_transform.so';

##########################################
## Add view for artefacts in manuscript ##
##########################################

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `artefact_in_manuscript` AS select `artefact_shape`.`artefact_id` AS `artefact_id`,`artefact_shape_owner`.`edition_id` AS `edition_id`,st_astext(geom_transform(`artefact_shape`.`region_in_sqe_image` AS `region_in_sqe_image`,`artefact_position`.`scale` AS `scale`,`artefact_position`.`rotate` AS `rotate`,`artefact_position`.`translate_x` AS `translate_x`,`artefact_position`.`translate_y` AS `translate_y`,st_x(st_centroid(st_envelope(`artefact_shape`.`region_in_sqe_image`))) AS `center_x`,st_y(st_centroid(st_envelope(`artefact_shape`.`region_in_sqe_image`))) AS `center_y`)) AS `shape` from (((`artefact_shape` join `artefact_shape_owner` on(`artefact_shape`.`artefact_shape_id` = `artefact_shape_owner`.`artefact_shape_id`)) join `artefact_position` on(`artefact_shape`.`artefact_id` = `artefact_position`.`artefact_id`)) join `artefact_position_owner` on(`artefact_position_owner`.`artefact_position_id` = `artefact_position`.`artefact_position_id` and `artefact_position_owner`.`edition_id` = `artefact_shape_owner`.`edition_id`));

#####################################
## Add view for ROIs in manuscript ##
#####################################

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `roi_in_manuscript` AS select `sign_interpretation_roi`.`sign_interpretation_id` AS `sign_interpretation_id`,`roi_position`.`artefact_id` AS `artefact_id`,`sign_interpretation_roi_owner`.`edition_id` AS `edition_id`,nested_geom_transform(`roi_shape`.`path` AS `path`,`artefact_position`.`scale` AS `scale`,`artefact_position`.`rotate` AS `rotate`,`artefact_position`.`translate_x` AS `translate_x`,`artefact_position`.`translate_y` AS `translate_y`,`roi_position`.`translate_x` AS `translate_x`,`roi_position`.`translate_y` AS `translate_y`,st_x(st_centroid(st_envelope(`artefact_shape`.`region_in_sqe_image`))) AS `center_x`,st_y(st_centroid(st_envelope(`artefact_shape`.`region_in_sqe_image`))) AS `center_y`) AS `shape` from (((((((`sign_interpretation_roi_owner` join `sign_interpretation_roi` on(`sign_interpretation_roi_owner`.`sign_interpretation_roi_id` = `sign_interpretation_roi`.`sign_interpretation_roi_id`)) join `roi_shape` on(`sign_interpretation_roi`.`roi_shape_id` = `roi_shape`.`roi_shape_id`)) join `roi_position` on(`sign_interpretation_roi`.`roi_position_id` = `roi_position`.`roi_position_id`)) join `artefact_position` on(`roi_position`.`artefact_id` = `artefact_position`.`artefact_id`)) join `artefact_position_owner` on(`artefact_position_owner`.`edition_id` = `sign_interpretation_roi_owner`.`edition_id` and `artefact_position_owner`.`artefact_position_id` = `artefact_position`.`artefact_position_id`)) join `artefact_shape` on(`roi_position`.`artefact_id` = `artefact_shape`.`artefact_id`)) join `artefact_shape_owner` on(`artefact_shape_owner`.`edition_id` = `sign_interpretation_roi_owner`.`edition_id` and `artefact_shape_owner`.`artefact_shape_id` = `artefact_shape`.`artefact_shape_id`));