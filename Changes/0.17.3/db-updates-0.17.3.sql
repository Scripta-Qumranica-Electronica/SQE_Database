#####################################################################
## Delete the artefact/roi in manuscript and roi in artefact views ##
#####################################################################

DROP VIEW IF EXISTS `artefact_in_manuscript`;
DROP VIEW IF EXISTS `roi_in_manuscript`;
DROP VIEW IF EXISTS `roi_in_artefact`;

#####################################
## Delete the old are_group tables ##
#####################################

DROP TABLE IF EXISTS `area_group`;
DROP TABLE IF EXISTS `area_group_owner`;
DROP TABLE IF EXISTS `area_group_member`;

######################################
## Create new artefact_group system ##
######################################

DROP TABLE IF EXISTS `artefact_group_member_owner`;
DROP TABLE IF EXISTS `artefact_group_member`;
DROP TABLE IF EXISTS `artefact_group_data_owner`;
DROP TABLE IF EXISTS `artefact_group_data`;
DROP TABLE IF EXISTS `artefact_group`;

CREATE TABLE `artefact_group` (
  `artefact_group_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`artefact_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='This table holds the abstract IDs for the artefact group.  An artefact group consists of a name (see artefact_group_name) and a list of members (see artefact_group_member).  It is up to the user to determine what an artefact group is meant to do functionally.  Typically we assume that when one member of a group is transformed, all members of the group will also be transformed accordingly.  The responsibility for such operations, however, lies downstream from the database (i.e., there are no database triggers involved with artefact groups).';

CREATE TABLE `artefact_group_member` (
  `artefact_group_member_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_group_id` int(11) unsigned NOT NULL COMMENT 'The id of the artefact group to which the artefact belongs.',
  `artefact_id` int(11) unsigned NOT NULL COMMENT 'The id of the artefact to add to the artefact group.',
  PRIMARY KEY (`artefact_group_member_id`),
  KEY `artefact_group_member_to_artefact` (`artefact_id`),
  CONSTRAINT `artefact_group_member_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `artefact_group_member_to_artefact_group` FOREIGN KEY (`artefact_group_id`) REFERENCES `artefact_group` (`artefact_group_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='This table is used to aggregate artefacts into groups.  An artefact group consists of a name (see artefact_group_name) and a list of members (see artefact_group_member).  It is up to the user to determine what an artefact group is meant to do functionally.  Typically we assume that when one member of a group is transformed, all members of the group will also be transformed accordingly.  The responsibility for such operations, however, lies downstream from the database (i.e., there are no database triggers involved with artefact groups).';

CREATE TABLE `artefact_group_member_owner` (
  `artefact_group_member_id` int(11) unsigned NOT NULL,
  `edition_id` int(11) unsigned NOT NULL,
  `edition_editor_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`artefact_group_member_id`,`edition_id`),
  KEY `artefact_group_member_owner_to_edition` (`edition_id`),
  KEY `artefact_group_member_owner_to_edition_editor` (`edition_editor_id`),
  CONSTRAINT `artefact_group_member_owner_to_artefact_group_member` FOREIGN KEY (`artefact_group_member_id`) REFERENCES `artefact_group_member` (`artefact_group_member_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `artefact_group_member_owner_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `artefact_group_member_owner_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE `artefact_group_data` (
  `artefact_group_data_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_group_id` int(11) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`artefact_group_data_id`),
  KEY `artefact_group_data_to_artefact_group` (`artefact_group_id`),
  CONSTRAINT `artefact_group_data_to_artefact_group` FOREIGN KEY (`artefact_group_id`) REFERENCES `artefact_group` (`artefact_group_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This table stores data pertaining to an artefact group, specifically its name.';

CREATE TABLE `artefact_group_data_owner` (
  `artefact_group_data_id` int(11) unsigned NOT NULL,
  `edition_id` int(11) unsigned NOT NULL,
  `edition_editor_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`artefact_group_data_id`,`edition_id`),
  KEY `artefact_group_data_owner_to_edition` (`edition_id`),
  KEY `artefact_group_data_owner_to_edition_editor` (`edition_editor_id`),
  CONSTRAINT `artefact_group_data_owner_to_artefact_group_data` FOREIGN KEY (`artefact_group_data_id`) REFERENCES `artefact_group_data` (`artefact_group_data_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `artefact_group_data_owner_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `artefact_group_data_owner_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

######################################
## Create manuscript metrics tables ##
## Populate the tables              ##
######################################

DROP TABLE IF EXISTS `manuscript_metrics_owner`;
DROP TABLE IF EXISTS `manuscript_metrics`;

CREATE TABLE `manuscript_metrics` (
  `manuscript_metrics_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `manuscript_id` int(11) unsigned NOT NULL,
  `x_origin` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'This is the x value of the starting point of the manuscript.  The coordinate system begins top left, positive values increase while moving downward on the y-axis and while moving rightward on the x-axis.',
  `y_origin` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'This is the y value of the starting point of the manuscript.  The coordinate system begins top left, positive values increase while moving downward on the y-axis and while moving rightward on the x-axis.',
  `width` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'This is the width of the manucsript in millimeters.',
  `height` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'This is the height of the manucsript in millimeters.',
  `pixels_per_inch` int(11) unsigned NOT NULL DEFAULT 1215 COMMENT 'This is the pixels per inch for the manuscript.  At the outset we have decided to set all manuscripts at 1215 PPI, which is the resolution of most images being used.  All images should be scaled to this resolution before creating artefacts and ROIs that are placed upon the virtual manuscript.  We have no plans to use varying PPI settings for different manuscripts, which would slightly complicate GIS calcularions across multiple manuscripts.',
  PRIMARY KEY (`manuscript_metrics_id`),
  KEY `manuscript_metrics_to_manuscript` (`manuscript_id`),
  CONSTRAINT `manuscript_metrics_to_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscript` (`manuscript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This table stores basic information about the gross metrics of a manuscript.  The user is able to specify an  x/y-origin point for the start of the manuscript along with its proposed height and width in millimeters.  The coordinate system begins top left, positive values increase while moving downward on the y-axis and while moving rightward on the x-axis.  The PPI is currently fixed ad 1215 PPI to facilitate comparison of GIS data between manuscripts.  All images should be scaled to this resolution before creating artefacts and ROIs that are placed upon the virtual manuscript.';

CREATE TABLE `manuscript_metrics_owner` (
  `manuscript_metrics_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(11) unsigned NOT NULL,
  `edition_editor_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`manuscript_metrics_id`,`edition_id`),
  KEY `manuscript_metrics_owner_to_edition_id` (`edition_id`),
  KEY `manuscript_metrics_owner_to_edition_editor` (`edition_editor_id`),
  CONSTRAINT `manuscript_metrics_owner_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `manuscript_metrics_owner_to_edition_id` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `manuscript_metrics_owner_to_manuscript_metrics` FOREIGN KEY (`manuscript_metrics_id`) REFERENCES `manuscript_metrics` (`manuscript_metrics_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

BEGIN;

INSERT IGNORE INTO manuscript_metrics (manuscript_id)
SELECT manuscript_id
FROM manuscript_data_owner
JOIN manuscript_data USING(manuscript_data_id);

INSERT IGNORE INTO manuscript_metrics_owner (manuscript_metrics_id, edition_id, edition_editor_id)
SELECT manuscript_metrics_id, edition_id, edition_editor_id
FROM manuscript_data_owner
JOIN manuscript_data USING(manuscript_data_id)
JOIN manuscript_metrics USING(manuscript_id);

COMMIT;