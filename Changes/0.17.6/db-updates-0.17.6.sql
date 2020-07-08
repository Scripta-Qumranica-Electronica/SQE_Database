###########################
## Documentation Updates ##
###########################

ALTER TABLE `artefact_data` CHANGE COLUMN `name` `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL  COMMENT 'This is a human readable designation for the artefact. Multiple artefacts are allowed to share the same name, even in a single manuscript, though this is not advised.  The artefact as a distinct entity is made unique by its artefact_id.' AFTER `artefact_id`;

ALTER TABLE `artefact_group_data` CHANGE COLUMN `name` `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL  COMMENT 'This is a human readable designation for the artefact group. Multiple artefact groups are allowed to share the same name, even in a single manuscript, though this is not advised.  The artefact group as a distinct entity is made unique by its artefact_group_id.' AFTER `artefact_group_id`, ALTER COLUMN `name` DROP DEFAULT;

ALTER TABLE `artefact_position` CHANGE COLUMN `artefact_id` `artefact_id` INT(10) UNSIGNED NOT NULL  COMMENT 'The id of the artefact to be positioned on the virtual manuscript.' AFTER `artefact_position_id`, ALTER COLUMN `artefact_id` DROP DEFAULT;

ALTER TABLE `artefact_shape` CHANGE COLUMN `artefact_id` `artefact_id` INT(11) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'The id of the artefact to which this shape belongs.' AFTER `artefact_shape_id`;

ALTER TABLE `artefact_shape` CHANGE COLUMN `region_in_sqe_image` `region_in_sqe_image` GEOMETRY NOT NULL  COMMENT 'This is the exact polygon of the artefact’s location within the master image’s coordinate system, but alwaya at a resolution of 1215 PPI. If the master image is not 1215 PPI it should be scaled to that resolution before the srtefact is drawn upon it.' AFTER `sqe_image_id`, ALTER COLUMN `region_in_sqe_image` DROP DEFAULT;

## The following may take to long to execute, do it separately if it fails with a lost connection
ALTER TABLE `artefact_shape` CHANGE COLUMN `region_in_sqe_image_hash` `region_in_sqe_image_hash` BINARY(128) GENERATED ALWAYS AS (sha2(`region_in_sqe_image`,512)) STORED COMMENT 'This is a quick hash of the region_in_sqe_image polygon for the purpose of uniqueness constraints.' AFTER `region_in_sqe_image`;

ALTER TABLE `artefact_stack` CHANGE COLUMN `artefact_A_id` `artefact_A_id` INT(10) UNSIGNED NOT NULL  COMMENT 'The first artefact in the stack.' AFTER `artefact_stack_id`, ALTER COLUMN `artefact_A_id` DROP DEFAULT;

ALTER TABLE `artefact_stack` CHANGE COLUMN `artefact_B_id` `artefact_B_id` INT(10) UNSIGNED NOT NULL  COMMENT 'The second artefact in the stack.' AFTER `artefact_A_id`, ALTER COLUMN `artefact_B_id` DROP DEFAULT;

ALTER TABLE `artefact_stack` CHANGE COLUMN `artefact_B_offset` `artefact_B_offset` GEOMETRY NOT NULL DEFAULT ST_GEOMFROMTEXT('POINT(0 0)')  COMMENT 'Gives the offset by which the artefact B must be moved to match the artefact A.  The offset is a POINT geometry.' AFTER `artefact_B_id`;

ALTER TABLE `artefact_stack` CHANGE COLUMN `layer_A` `layer_A` TINYINT(3) UNSIGNED NOT NULL DEFAULT 1  COMMENT 'Gives the number of the layer in the stack to which artefact A belongs. In the case of a recto/verso match, this would be 0. In the case of a wad, a higher number should indicate a layer that is closer to the outside of the scroll, or the front of the codex.' AFTER `artefact_B_offset`;

ALTER TABLE `artefact_stack` CHANGE COLUMN `layer_B` `layer_B` TINYINT(3) UNSIGNED NOT NULL DEFAULT 1  COMMENT 'Gives the number of the layer in the stack to which artefact B belongs. In the case of a recto/verso match, this would be 0. In the case of a wad, a higher number should indicate a layer that is closer to the outside of the scroll, or the front of the codex.' AFTER `layer_A`;

ALTER TABLE `artefact_stack` CHANGE COLUMN `A_is_verso` `A_is_verso` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Boolean whether srtefact A is recto=0 or verso=1.' AFTER `layer_B`;

ALTER TABLE `artefact_stack` CHANGE COLUMN `B_is_verso` `B_is_verso` TINYINT(3) UNSIGNED NOT NULL DEFAULT 1  COMMENT 'Boolean whether srtefact B is recto=0 or verso=1.' AFTER `A_is_verso`;

ALTER TABLE `attribute` CHANGE COLUMN `name` `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL  COMMENT 'Designation of the attribute.' AFTER `attribute_id`;

ALTER TABLE `attribute` CHANGE COLUMN `type` `type` ENUM('BOOLEAN','NUMBER','STRING') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL  COMMENT 'Attributes my be either a boolean, and number, or a string.' AFTER `name`;

ALTER TABLE `attribute` CHANGE COLUMN `description` `description` VARCHAR(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL  COMMENT 'A concise description of the nature of the attribute.' AFTER `type`;

ALTER TABLE `attribute_value` CHANGE COLUMN `attribute_id` `attribute_id` INT(10) UNSIGNED NOT NULL  COMMENT 'The id of the attribute to which a string value is to be assigned.' AFTER `attribute_value_id`, ALTER COLUMN `attribute_id` DROP DEFAULT;

ALTER TABLE `attribute_value` CHANGE COLUMN `string_value` `string_value` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL  COMMENT 'A unique string value that can be applied as an attribute to a sign interpretation.' AFTER `attribute_id`;

ALTER TABLE `attribute_value` CHANGE COLUMN `description` `description` VARCHAR(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL  COMMENT 'A concise description of the attribute value.' AFTER `string_value`;

ALTER TABLE `attribute_value_css` CHANGE COLUMN `attribute_value_id` `attribute_value_id` INT(10) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'The attribute value to be formatted with this CSS code.' AFTER `attribute_value_css_id`;

ALTER TABLE `attribute_value_css` CHANGE COLUMN `css` `css` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL  COMMENT 'The CSS descriptor(s) to apply to sign interpretations with the linked attribute value.' AFTER `attribute_value_id`;

ALTER TABLE `edition` CHANGE COLUMN `edition_id` `edition_id` INT(10) UNSIGNED NOT NULL auto_increment COMMENT 'Unique id of the edition.' FIRST, ALTER COLUMN `edition_id` DROP DEFAULT;

ALTER TABLE `edition` CHANGE COLUMN `manuscript_id` `manuscript_id` INT(10) UNSIGNED NOT NULL  COMMENT 'Id of the manuscript treated in this edition.' AFTER `edition_id`, ALTER COLUMN `manuscript_id` DROP DEFAULT;

ALTER TABLE `edition` CHANGE COLUMN `locked` `locked` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'A boolean wheather this edition is locked. If an edition is locked, the SQE_API will not allow any changes to be made to it.' AFTER `manuscript_id`;

ALTER TABLE `edition` CHANGE COLUMN `public` `public` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'A boolean signalling whether this edition has been made publicly viewable or not. Public relates only to viewing rights, not to write or admin. As the system is currently constructed all public editions should also be locked.' AFTER `collaborators`;

ALTER TABLE `edition_editor` CHANGE COLUMN `edition_editor_id` `edition_editor_id` INT(10) UNSIGNED NOT NULL auto_increment COMMENT 'Id of the editor, who is working on a particular edition.' FIRST, ALTER COLUMN `edition_editor_id` DROP DEFAULT;

ALTER TABLE `edition_editor` CHANGE COLUMN `user_id` `user_id` INT(11) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Link to the editor’s user account.' AFTER `edition_editor_id`;

ALTER TABLE `edition_editor` CHANGE COLUMN `edition_id` `edition_id` INT(10) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'This is the id of the edition on which this editor is working.' AFTER `user_id`;

ALTER TABLE `edition_editor` CHANGE COLUMN `may_write` `may_write` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Boolean whether this editor has permission to write to the edition. An editor must have read permissions to have write permissions.' AFTER `edition_id`;

ALTER TABLE `edition_editor` CHANGE COLUMN `may_lock` `may_lock` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Boolean whether the editor is allowed to lock the edition.' AFTER `may_write`;

ALTER TABLE `edition_editor` CHANGE COLUMN `may_read` `may_read` TINYINT(3) UNSIGNED NOT NULL DEFAULT 1  COMMENT 'Boolean whether the editor is allowed to read the edition. No editors may ever be deleted from an edition, but revoking read access to an editor is the SQE equivalent to fully removing the editor from work on an edition.' AFTER `may_lock`;

ALTER TABLE `edition_editor` CHANGE COLUMN `is_admin` `is_admin` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Boolean whether an editor is an admin. An admin must have read permission. Only an admin may change the permissions of other editors, including revoking admin status (including for herself). Each edition must have at least one admin. Only an admin may publish or delete an edition.' AFTER `may_read`;

ALTER TABLE `edition_editor_request` CHANGE COLUMN `edition_id` `edition_id` INT(12) UNSIGNED NOT NULL  COMMENT 'The id of the edition to be shared.' AFTER `editor_user_id`, ALTER COLUMN `edition_id` DROP DEFAULT;

ALTER TABLE `edition_editor_request` CHANGE COLUMN `is_admin` `is_admin` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Offering admin rights.' AFTER `edition_id`;

ALTER TABLE `edition_editor_request` CHANGE COLUMN `may_lock` `may_lock` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Offering locking rights.' AFTER `is_admin`;

ALTER TABLE `edition_editor_request` CHANGE COLUMN `may_write` `may_write` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Offering write rights.' AFTER `may_lock`;

ALTER TABLE `edition_editor_request` CHANGE COLUMN `date` `date` DATETIME NOT NULL DEFAULT current_timestamp()  COMMENT 'Date the editor request was sent.' AFTER `may_write`;

ALTER TABLE `iaa_edition_catalog` CHANGE COLUMN `manuscript_id` `manuscript_id` INT(11) UNSIGNED NULL DEFAULT NULL  COMMENT 'Id of the manuscript within the SQE database.' AFTER `edition_side`;

ALTER TABLE `iaa_edition_catalog` CHANGE COLUMN `comment` `comment` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL  COMMENT 'Extra comments.' AFTER `manuscript_id`;

ALTER TABLE `image_catalog` CHANGE COLUMN `institution` `institution` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NULL'  COMMENT 'Name of the institution providing the image.' AFTER `image_catalog_id`;

ALTER TABLE `image_catalog` CHANGE COLUMN `catalog_number_1` `catalog_number_1` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NULL'  COMMENT 'First tier object identifier (perhaps a plate or accession number).' AFTER `institution`;

ALTER TABLE `image_catalog` CHANGE COLUMN `catalog_number_2` `catalog_number_2` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NULL'  COMMENT 'Second tier object identifier (if available). Perhaps a fragment number on a plate, or some subdesignation of an accession number.' AFTER `catalog_number_1`;

ALTER TABLE `image_catalog` CHANGE COLUMN `catalog_side` `catalog_side` TINYINT(1) UNSIGNED NULL DEFAULT 0  COMMENT 'Side reference designation, recto = 0, verso = 1.' AFTER `catalog_number_2`;

ALTER TABLE `image_catalog` CHANGE COLUMN `object_id` `object_id` VARCHAR(255) GENERATED ALWAYS AS (CONCAT(`institution`,'-',`catalog_number_1`,'-',`catalog_number_2`)) STORED COMMENT 'An autogenerated human readable object identifier based on the institution and catalogue numbers.' AFTER `catalog_side`;

ALTER TABLE `image_to_image_map` CHANGE COLUMN `image1_id` `image1_id` INT(10) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Id of the first SQE_image to be mapped.' AFTER `image_to_image_map_id`;

ALTER TABLE `image_to_image_map` CHANGE COLUMN `image2_id` `image2_id` INT(10) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Id of the second SQE_image to be mapped.' AFTER `image1_id`;

ALTER TABLE `image_to_image_map` CHANGE COLUMN `transform_matrix` `transform_matrix` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '{"matrix":[[1,0,0],[0,1,0]]}'  COMMENT 'Linear affine transform to apply to image 2 in order to align it with image 1.  The format is: “{“matrix”: [[sx cosθ, -sy sinθ, tx],[sx sinθ, sy cosθ, ty]]}”.' AFTER `region_on_image2`;

ALTER TABLE `image_to_image_map` CHANGE COLUMN `region1_hash` `region1_hash` BINARY(128) GENERATED ALWAYS AS (sha2(`region_on_image1`,512)) STORED COMMENT 'θ' AFTER `transform_matrix`;

ALTER TABLE `image_to_image_map` CHANGE COLUMN `region2_hash` `region2_hash` BINARY(128) GENERATED ALWAYS AS (sha2(`region_on_image2`,512)) STORED COMMENT 'Polygon hash for uniqueness constraints.' AFTER `region1_hash`;

ALTER TABLE `main_action` CHANGE COLUMN `time` `time` DATETIME(6) NULL DEFAULT current_timestamp(6)  COMMENT 'The time that the database action was performed.' AFTER `main_action_id`;

ALTER TABLE `main_action` CHANGE COLUMN `edition_editor_id` `edition_editor_id` INT(10) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Id of the editor who performed the action.' AFTER `rewinded`;

ALTER TABLE `main_action` CHANGE COLUMN `edition_id` `edition_id` INT(10) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Id of the edition in which the action was performed.' AFTER `edition_editor_id`;

ALTER TABLE `manuscript_data` CHANGE COLUMN `name` `name` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NULL'  COMMENT 'Name designation of the manuscript.' AFTER `manuscript_id`;

ALTER TABLE `manuscript_metrics` CHANGE COLUMN `pixels_per_inch` `pixels_per_inch` INT(11) UNSIGNED NOT NULL DEFAULT 1215  COMMENT 'This is the pixels per inch for the manuscript.  At the outset we have decided to set all manuscripts at 1215 PPI, which is the resolution of most images being used.  All images should be scaled to this resolution before creating artefacts and ROIs that are placed upon the virtual manuscript.  We have no plans to use varying PPI settings for different manuscripts, which would slightly complicate GIS calculations across multiple manuscripts.' AFTER `height`;

ALTER TABLE `roi_position` CHANGE COLUMN `artefact_id` `artefact_id` INT(11) UNSIGNED NOT NULL  COMMENT 'ROI’s are linked to artefacts.  Those artefacts may be real (i.e., linked to an image) or virtual (i.e., not linked to an image). A virtual manuscript is the sum total of all the artefacts positioned in it.' AFTER `roi_position_id`, ALTER COLUMN `artefact_id` DROP DEFAULT;

ALTER TABLE `roi_position` CHANGE COLUMN `translate_x` `translate_x` INT(11) NOT NULL DEFAULT 0  COMMENT 'The translation on the X axis necessary to position the a ROI shape in the artefact\'s coordinate system. The artefact coordinate system is the same as the “master imafe” to which it is linked, but always scaled to a resolution of 1215 PPI.' AFTER `artefact_id`;

ALTER TABLE `roi_position` CHANGE COLUMN `translate_y` `translate_y` INT(11) NOT NULL DEFAULT 0  COMMENT 'The translation on the Y axis necessary to position the a ROI shape in the artefact\'s coordinate system. The artefact coordinate system is the same as the “master imafe” to which it is linked, but always scaled to a resolution of 1215 PPI.' AFTER `translate_x`;

ALTER TABLE `roi_position` CHANGE COLUMN `stance_rotation` `stance_rotation` SMALLINT(5) UNSIGNED NULL DEFAULT NULL  COMMENT 'Any rotation that would be necessary for the sign to have the correct stance on a horizontal plane. This is to be applied whent creating fonts and analyzing the expected script orientation in relation to its actual orientation on an artefact.' AFTER `translate_y`;

ALTER TABLE `roi_shape` CHANGE COLUMN `path` `path` GEOMETRY NULL DEFAULT NULL  COMMENT 'This is a POLYGON geometry describing the shape of the ROI. It is its own 0,0 coordinate system and is correlated with a location in an artefact via a translation (without scale or rotation) in the roi_position table. Its resolution is the same as the artefact, 1215 PPI.' AFTER `roi_shape_id`;

ALTER TABLE `sign_interpretation` CHANGE COLUMN `sign_id` `sign_id` INT(10) UNSIGNED NOT NULL  COMMENT 'Id of the sign being described.' AFTER `sign_interpretation_id`, ALTER COLUMN `sign_id` DROP DEFAULT;

ALTER TABLE `sign_interpretation` CHANGE COLUMN `character` `character` CHAR(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL  COMMENT 'This may be left null for signs that are not interpreted as characters (e.g., control signs like line start/line end or material features of any sort), otherwise it is a single letter.' AFTER `is_variant`;

ALTER TABLE `sign_interpretation_attribute` CHANGE COLUMN `sign_interpretation_id` `sign_interpretation_id` INT(10) UNSIGNED NOT NULL  COMMENT 'Id of the sign interpretation being descibed.' AFTER `sign_interpretation_attribute_id`, ALTER COLUMN `sign_interpretation_id` DROP DEFAULT;

ALTER TABLE `sign_interpretation_attribute` CHANGE COLUMN `attribute_value_id` `attribute_value_id` INT(10) UNSIGNED NOT NULL  COMMENT 'Id of the attribute to apply to this sign interpretation.' AFTER `sign_interpretation_id`, ALTER COLUMN `attribute_value_id` DROP DEFAULT;

ALTER TABLE `sign_interpretation_commentary` CHANGE COLUMN `sign_interpretation_id` `sign_interpretation_id` INT(10) UNSIGNED NOT NULL  COMMENT 'Id of the sign interpretation being commented on.' AFTER `sign_interpretation_commentary_id`, ALTER COLUMN `sign_interpretation_id` DROP DEFAULT;

ALTER TABLE `sign_interpretation_commentary` CHANGE COLUMN `attribute_id` `attribute_id` INT(10) UNSIGNED NULL DEFAULT NULL  COMMENT 'Id of the attrivute describing the aspect of this sign interpretation being commented on.' AFTER `sign_interpretation_id`;

ALTER TABLE `sign_interpretation_commentary` CHANGE COLUMN `commentary` `commentary` LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL  COMMENT 'Editorial comments.' AFTER `attribute_id`;

ALTER TABLE `sign_interpretation_roi` CHANGE COLUMN `sign_interpretation_id` `sign_interpretation_id` INT(10) UNSIGNED NULL DEFAULT NULL  COMMENT 'Id of the sign interpretation being marked in an artefact.' AFTER `sign_interpretation_roi_id`;

ALTER TABLE `sign_interpretation_roi` CHANGE COLUMN `roi_shape_id` `roi_shape_id` INT(10) UNSIGNED NOT NULL  COMMENT 'Id of the shape for this ROI.' AFTER `sign_interpretation_id`, ALTER COLUMN `roi_shape_id` DROP DEFAULT;

ALTER TABLE `sign_interpretation_roi` CHANGE COLUMN `roi_position_id` `roi_position_id` INT(10) UNSIGNED NOT NULL  COMMENT 'Id for the position of this ROI in its artefact.' AFTER `roi_shape_id`, ALTER COLUMN `roi_position_id` DROP DEFAULT;

ALTER TABLE `sign_interpretation_roi` CHANGE COLUMN `exceptional` `exceptional` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Boolean whether this ROI is exceptional (and thus should be excluded from some statistical analyses).' AFTER `values_set`;

ALTER TABLE `single_action` CHANGE COLUMN `main_action_id` `main_action_id` INT(10) UNSIGNED NOT NULL  COMMENT 'Id of the main action that this single action belongs to.' AFTER `single_action_id`, ALTER COLUMN `main_action_id` DROP DEFAULT;

ALTER TABLE `single_action` CHANGE COLUMN `id_in_table` `id_in_table` INT(10) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Id of the record that was added to or deleted from the edition (of the linked main_action) in the “table”_owner table.' AFTER `table`;

ALTER TABLE `SQE_image` CHANGE COLUMN `filename` `filename` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NULL'  COMMENT 'Actual filename of the image as specified on the iiif server.  This may often look more like a URI, or a partial URI.' AFTER `image_urls_id`;

ALTER TABLE `SQE_image` CHANGE COLUMN `dpi` `dpi` INT(10) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'The DPI of the full size image (used to calculate relative scaling of images). This should be calculated as optimally as possible and should not rely on EXIF data.' AFTER `native_height`;

ALTER TABLE `SQE_image` CHANGE COLUMN `type` `type` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Four values:
Color = 0
Grayscale = 1
Raking light right = 2
Raking light left = 4
Perhaps remove in favor of “wavelength_start" and “wavelength_end”.' AFTER `dpi`;

ALTER TABLE `SQE_image` CHANGE COLUMN `image_catalog_id` `image_catalog_id` INT(11) UNSIGNED NULL DEFAULT 0  COMMENT 'Id of the image in the image catalogue.' AFTER `is_master`;

ALTER TABLE `SQE_image` CHANGE COLUMN `is_recto` `is_recto` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1  COMMENT 'Notes wether the original image is thought to show rect0 (1) or verso (0) of the fragment. This can be taken as default value for recto/verso-relation in artefact_stack' AFTER `image_catalog_id`;

ALTER TABLE `SQE_image` CHANGE COLUMN `filename` `filename` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'NULL'  COMMENT 'Actual filename of the image as specified on the iiif server.  This may often look more like a URI, or a partial URI.' AFTER `image_urls_id`;

ALTER TABLE `SQE_image` CHANGE COLUMN `dpi` `dpi` INT(10) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'The DPI of the full size image (used to calculate relative scaling of images). This should be calculated as optimally as possible and should not rely on EXIF data.' AFTER `native_height`;

ALTER TABLE `SQE_image` CHANGE COLUMN `type` `type` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Four values:
Color = 0
Grayscale = 1
Raking light right = 2
Raking light left = 4
Perhaps remove in favor of “wavelength_start" and “wavelength_end”.' AFTER `dpi`;

ALTER TABLE `SQE_image` CHANGE COLUMN `image_catalog_id` `image_catalog_id` INT(11) UNSIGNED NULL DEFAULT 0  COMMENT 'Id of the image in the image catalogue.' AFTER `is_master`;

ALTER TABLE `SQE_image` CHANGE COLUMN `is_recto` `is_recto` TINYINT(1) UNSIGNED NOT NULL DEFAULT 1  COMMENT 'Notes wether the original image is thought to show rect0 (1) or verso (0) of the fragment. This can be taken as default value for recto/verso-relation in artefact_stack' AFTER `image_catalog_id`;

ALTER TABLE `work_status` CHANGE COLUMN `work_status_message` `work_status_message` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT ''  COMMENT 'A status message on the ccurrent state of work.' AFTER `work_status_id`;

ALTER TABLE `artefact` COMMENT = 'Every virtual manuscript is made up from artefacts.  The artefact is a polygon region of an image which the editor deems to constitute a coherent piece of material (different editors may come to different conclusions on what makes up an artefact).  This may correspond to what the editors of an editio princeps have designated a “fragment”, but often may not, since the columns and fragments in those publications are often made up of joins of various types.  Joined fragments should not, as a rule, be defined as a single artefact within the SQE system.  Rather, each component of a join should be a separate artefact, and those artefacts can then be positioned properly with each other via the artefact_position table.';

ALTER TABLE `artefact_position` COMMENT = 'This table defines the location, rotation, and size of an artefact within the virtual manuscript.';

ALTER TABLE `artefact_shape` COMMENT = 'This table holds the polygon describing the region of the artefact in the coordinate system of its image. The image must first be scaled to the PPI defined in manuscript_metrics (1215 PPI by default).';

ALTER TABLE `artefact_stack` COMMENT = 'This table stores the relationship between artefacts which make up a stack, meaning that they represent parallel layers in a stack. This could be:\na) Artefact A is and B represent recto/verso of one layer (artefact), then the layer_A and layer_B must be the same\nb) A and B represent parts of different layers of a already decomposed stack (reason= ‚found in a stack‘) or as part of wad (reason = ‚part of a wad‘) or as thought by the scholar to belong in the same perimeter of the manuscript (reason=‚reconstructed‘).\n\nThe tables allow the creation of a sequence of artefacts: A = recto of layer 1 -> B = verso of layer 1 -> C = recto of recto of layer  2 -> D = verso of layer 2 … (where -> represents a record with the left as artefact_A and the right term as artefact_B)\n\nA special case is marked by shared. We could, e.g., have A as verso and B as recto and additionally a subregion of B as shared to A.';

ALTER TABLE `artefact_status` COMMENT = 'The artefact status is a user definable placeholder to store information about how state of work on defining the artefact.';

ALTER TABLE `attribute` COMMENT = 'This table stores attributes that can be used to describe a sign_interpretation.  They are used in conjunction with a string value in the attribute_value, and any related numeric value can be added in the numeric_value column of the sign_interpretation_attribute table.';

ALTER TABLE `edition_editor_request` COMMENT = 'This table stores the data for a request for a user to become an editor of an edition. It contains details about the permissions associated with the request.';

ALTER TABLE `iaa_edition_catalog_to_text_fragment` COMMENT = 'This is a temporary table to curate matches between the image catalog system and the SQE text fragments in a manuscript.  It should eventually be deprecated in favor of matches inferred by spatial overlap on the virtual scroll of a the placement of a ROI linked to text transcription and an artefact linked to an image.';

ALTER TABLE `image_to_image_map` COMMENT = 'This table contains the mapping information to correlate images of the same object via linear affine transformations. The mapping may only invlove a portion of either image as defined in the region_on_imageX columns.';

ALTER TABLE `line` COMMENT = 'The line is an abstract placeholder which can receive definition via the line_data table.  It must be nested in a text fragment (text_fragment_to_line) and will contain signs (line_to_sign)';

ALTER TABLE `main_action` COMMENT = 'Table recording mutation actions (it can be used for infinite undo).  This table stores the state of the action (rewound or not), the date of the change, and the edition that the action is associated with.  The table single_action links to the entries here and describes the table in which the action occurred, the id of the entry in that table that was involved, and the nature of the action (creating a connection between that entry and the edition of the main_action, or deleting the connection between that entry and the edition of the main_action).';

ALTER TABLE `manuscript` COMMENT = 'The manuscript is an abstract placeholder that is given metadata via the manuscript_data table. This allows multiple editions of the same manuscript to be created, regardless of the naming scheme used. A manuscript will contain one or more text fragments (manuscript_to_text_fragment)';

ALTER TABLE `roi_position` COMMENT = 'ROI’s are linked to artefacts.  To get the location of the ROI in the coordinate system of the “virtual manuscript, one must first apply the roi_position and then the position of the linked artefact. This can by done via the UDF nested_geom_transform.';

ALTER TABLE `sign` COMMENT = 'This is an abstract placeholder allowing a multiplicity of interpretations to be related to each other by linking to the same sign_id.';

ALTER TABLE `sign_interpretation_commentary` COMMENT = 'This table allows editors to attach commentary to a specific attribute of a sign interpretation.';

ALTER TABLE `text_fragment` COMMENT = 'The text_fragment is an abstract placeholder that can be named via text_fragment_data, subsumed in a manuscript (manuscript_to_text_fragment), and joined with the lines that contitute it (text_fragment_to_line).';

ALTER TABLE `artefact_position` COMMENT = '';

############################
## Remove unneeded tables ##
############################

DROP TABLE IF EXISTS invitation_blacklist;