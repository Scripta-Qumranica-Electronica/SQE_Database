-- MySQL dump 10.17  Distrib 10.3.23-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: SQE
-- ------------------------------------------------------
-- Server version	10.3.23-MariaDB-1:10.3.23+maria~bionic

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `SQE_image`
--

DROP TABLE IF EXISTS `SQE_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SQE_image` (
  `sqe_image_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `image_urls_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Link to image_urls table which contains the url of the iiif server that provides this image and the default suffix used to get images from that server.',
  `filename` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Actual filename of the image as specified on the iiif server.  This may often look more like a URI, or a partial URI.',
  `native_width` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'We store internally the pixel width of the full size image.',
  `native_height` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'We store internally the pixel height of the full size image.',
  `dpi` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'The DPI of the full size image (used to calculate relative scaling of images). This should be calculated as optimally as possible and should not rely on EXIF data.',
  `type` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Four values:\nColor = 0\nGrayscale = 1\nRaking light right = 2\nRaking light left = 4\nPerhaps remove in favor of “wavelength_start" and “wavelength_end”.',
  `wavelength_start` smallint(5) unsigned NOT NULL DEFAULT 445 COMMENT 'Starting wavelength of image in nanometers.',
  `wavelength_end` smallint(5) unsigned NOT NULL DEFAULT 704 COMMENT 'Ending wavelength of image in nanometers.',
  `is_master` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Boolean determining if the image is a “master image”.  Since we have multiple images of each fragment, one image is designated as the master (generally the full color image), all others are non master images and will have a corresponding entry in “image_to_image_map” which provides and transforms (translate, scale, rotate) necessary to line the two images up with each other.',
  `image_catalog_id` int(11) unsigned DEFAULT 0 COMMENT 'Id of the image in the image catalogue.',
  `is_recto` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT 'Notes wether the original image is thought to show rect0 (1) or verso (0) of the fragment. This can be taken as default value for recto/verso-relation in artefact_stack',
  PRIMARY KEY (`sqe_image_id`),
  UNIQUE KEY `url_UNIQUE` (`image_urls_id`,`filename`) USING BTREE,
  KEY `fk_image_to_catalog` (`image_catalog_id`),
  CONSTRAINT `fk_image_to_catalog` FOREIGN KEY (`image_catalog_id`) REFERENCES `image_catalog` (`image_catalog_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_image_to_url` FOREIGN KEY (`image_urls_id`) REFERENCES `image_urls` (`image_urls_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=127476 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table defines an image.  It contains referencing data to access the image via iiif servers, it also stores metadata relating to the image itself, such as sizing, resolution, image color range, etc.  It also maintains a link to the institutional referencing system, and the referencing of the editio princeps (as provided by the imaging institution).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SQE_image_author`
--

DROP TABLE IF EXISTS `SQE_image_author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SQE_image_author` (
  `sqe_image_id` int(11) unsigned NOT NULL DEFAULT 0,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`sqe_image_id`),
  KEY `SQE_image_owner_to_scroll_version_id` (`user_id`),
  CONSTRAINT `fk_SQE_image_author_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_SQE_image_owner_to_sqe_image_id` FOREIGN KEY (`sqe_image_id`) REFERENCES `SQE_image` (`sqe_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact`
--

DROP TABLE IF EXISTS `artefact`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact` (
  `artefact_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`artefact_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26821 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Every virtual manuscript is made up from artefacts.  The artefact is a polygon region of an image which the editor deems to constitute a coherent piece of material (different editors may come to different conclusions on what makes up an artefact).  This may correspond to what the editors of an editio princeps have designated a “fragment”, but often may not, since the columns and fragments in those publications are often made up of joins of various types.  Joined fragments should not, as a rule, be defined as a single artefact within the SQE system.  Rather, each component of a join should be a separate artefact, and those artefacts can then be positioned properly with each other via the artefact_position table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_data`
--

DROP TABLE IF EXISTS `artefact_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_data` (
  `artefact_data_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_id` int(10) unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'This is a human readable designation for the artefact. Multiple artefacts are allowed to share the same name, even in a single manuscript, though this is not advised.  The artefact as a distinct entity is made unique by its artefact_id.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`artefact_data_id`),
  UNIQUE KEY `unique_artefact_id_artefact_data_name` (`artefact_id`,`name`) USING BTREE,
  KEY `fk_artefact_data_to_artefact` (`artefact_id`),
  KEY `fk_artefact_data_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_artefact_data_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_data_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=26821 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This stores metadata about the artefact.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_data_owner`
--

DROP TABLE IF EXISTS `artefact_data_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_data_owner` (
  `artefact_data_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`artefact_data_id`,`edition_id`),
  KEY `fk_artefact_data_owner_to_scroll_version_id` (`edition_editor_id`),
  KEY `fk_artefact_data_to_edition` (`edition_id`),
  CONSTRAINT `fk_artefact_data_owner_to_artefact_data_id` FOREIGN KEY (`artefact_data_id`) REFERENCES `artefact_data` (`artefact_data_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_data_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_artefact_data_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_group`
--

DROP TABLE IF EXISTS `artefact_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_group` (
  `artefact_group_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`artefact_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='This table holds the abstract IDs for the artefact group.  An artefact group consists of a name (see artefact_group_name) and a list of members (see artefact_group_member).  It is up to the user to determine what an artefact group is meant to do functionally.  Typically we assume that when one member of a group is transformed, all members of the group will also be transformed accordingly.  The responsibility for such operations, however, lies downstream from the database (i.e., there are no database triggers involved with artefact groups).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_group_data`
--

DROP TABLE IF EXISTS `artefact_group_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_group_data` (
  `artefact_group_data_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_group_id` int(11) unsigned NOT NULL,
  `name` varchar(255) NOT NULL COMMENT 'This is a human readable designation for the artefact group. Multiple artefact groups are allowed to share the same name, even in a single manuscript, though this is not advised.  The artefact group as a distinct entity is made unique by its artefact_group_id.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`artefact_group_data_id`),
  KEY `artefact_group_data_to_artefact_group` (`artefact_group_id`),
  KEY `fk_artefact_group_data_to_creator_id` (`creator_id`),
  CONSTRAINT `artefact_group_data_to_artefact_group` FOREIGN KEY (`artefact_group_id`) REFERENCES `artefact_group` (`artefact_group_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_group_data_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This table stores data pertaining to an artefact group, specifically its name.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_group_data_owner`
--

DROP TABLE IF EXISTS `artefact_group_data_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_group_member`
--

DROP TABLE IF EXISTS `artefact_group_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_group_member` (
  `artefact_group_member_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_group_id` int(11) unsigned NOT NULL COMMENT 'The id of the artefact group to which the artefact belongs.',
  `artefact_id` int(11) unsigned NOT NULL COMMENT 'The id of the artefact to add to the artefact group.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`artefact_group_member_id`),
  KEY `artefact_group_member_to_artefact` (`artefact_id`),
  KEY `artefact_group_member_to_artefact_group` (`artefact_group_id`),
  KEY `fk_artefact_group_member_to_creator_id` (`creator_id`),
  CONSTRAINT `artefact_group_member_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `artefact_group_member_to_artefact_group` FOREIGN KEY (`artefact_group_id`) REFERENCES `artefact_group` (`artefact_group_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_group_member_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='This table is used to aggregate artefacts into groups.  An artefact group consists of a name (see artefact_group_name) and a list of members (see artefact_group_member).  It is up to the user to determine what an artefact group is meant to do functionally.  Typically we assume that when one member of a group is transformed, all members of the group will also be transformed accordingly.  The responsibility for such operations, however, lies downstream from the database (i.e., there are no database triggers involved with artefact groups).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_group_member_owner`
--

DROP TABLE IF EXISTS `artefact_group_member_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_position`
--

DROP TABLE IF EXISTS `artefact_position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_position` (
  `artefact_position_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_id` int(10) unsigned NOT NULL COMMENT 'The id of the artefact to be positioned on the virtual manuscript.',
  `z_index` int(11) NOT NULL DEFAULT 0 COMMENT 'This value can move artefacts up or down in relation to other artefacts in the scroll.  That is, it sends an artefact further into the foreground or background.',
  `scale` decimal(6,4) unsigned NOT NULL DEFAULT 1.0000 COMMENT 'Resizing to be applied to the artefact.',
  `rotate` decimal(6,2) unsigned NOT NULL DEFAULT 0.00 COMMENT 'Rotation to be applied to the artefact.',
  `translate_x` int(11) DEFAULT NULL COMMENT 'Translation of the artefact on the horizontal axis.',
  `translate_y` int(11) DEFAULT NULL COMMENT 'Translation of the artefact on the vertical axis.',
  `translate_x_non_null` int(11) GENERATED ALWAYS AS (coalesce(`translate_x`,-2147483648)) VIRTUAL COMMENT 'This is a generated column for the sake of uniqueness constraints.  It reads the lowest possible value of an int instead of NULL, since that value is basically never going to be used (no scroll or manuscript has pages of such a length).',
  `translate_y_non_null` int(11) GENERATED ALWAYS AS (coalesce(`translate_y`,-2147483648)) VIRTUAL COMMENT 'This is a generated column for the sake of uniqueness constraints.  It reads the lowest possible value of an int instead of NULL, since that value is basically never going to be used (no scroll or manuscript has pages of such a length).',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`artefact_position_id`),
  UNIQUE KEY `fk_unique_artefact_position` (`artefact_id`,`rotate`,`scale`,`translate_x_non_null`,`translate_y_non_null`,`z_index`) USING BTREE,
  KEY `fk_artefact_position_to_artefact` (`artefact_id`),
  KEY `fk_artefact_position_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_artefact_position_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_position_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_position_owner`
--

DROP TABLE IF EXISTS `artefact_position_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_position_owner` (
  `artefact_position_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`artefact_position_id`,`edition_id`),
  KEY `fk_artefact_position_owner_to_scroll_version` (`edition_editor_id`),
  KEY `fk_artefact_position_to_edition` (`edition_id`),
  CONSTRAINT `fk_artefact_position_owner_to_artefact` FOREIGN KEY (`artefact_position_id`) REFERENCES `artefact_position` (`artefact_position_id`),
  CONSTRAINT `fk_artefact_position_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_artefact_position_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_shape`
--

DROP TABLE IF EXISTS `artefact_shape`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_shape` (
  `artefact_shape_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'The id of the artefact to which this shape belongs.',
  `sqe_image_id` int(10) unsigned DEFAULT NULL COMMENT 'This points to the master image (see SQE_image table) in which this artefact is found.',
  `region_in_sqe_image` geometry NOT NULL COMMENT 'This is the exact polygon of the artefact’s location within the master image’s coordinate system, but alwaya at a resolution of 1215 PPI. If the master image is not 1215 PPI it should be scaled to that resolution before the srtefact is drawn upon it.',
  `region_in_sqe_image_hash` binary(128) GENERATED ALWAYS AS (sha2(`region_in_sqe_image`,512)) STORED COMMENT 'This is a quick hash of the region_in_sqe_image polygon for the purpose of uniqueness constraints.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`artefact_shape_id`) USING BTREE,
  UNIQUE KEY `unique_artefact_shape` (`artefact_id`,`sqe_image_id`,`region_in_sqe_image_hash`) USING BTREE,
  KEY `fk_artefact_shape_to_sqe_image_idx` (`sqe_image_id`) USING BTREE,
  KEY `fk_artefact_shape_to_artefact` (`artefact_id`) USING BTREE,
  KEY `fk_artefact_shape_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_artefact_shape_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_shape_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_shape_to_sqe_image` FOREIGN KEY (`sqe_image_id`) REFERENCES `SQE_image` (`sqe_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=36482 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table holds the polygon describing the region of the artefact in the coordinate system of its image. The image must first be scaled to the PPI defined in manuscript_metrics (1215 PPI by default).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_shape_owner`
--

DROP TABLE IF EXISTS `artefact_shape_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_shape_owner` (
  `artefact_shape_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`artefact_shape_id`,`edition_id`),
  KEY `fk_artefact_shape_owner_to_scroll_version` (`edition_editor_id`),
  KEY `fk_artefact_shape_to_edition` (`edition_id`),
  CONSTRAINT `fk_artefact_shape_owner_to_artefact_shape` FOREIGN KEY (`artefact_shape_id`) REFERENCES `artefact_shape` (`artefact_shape_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_shape_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_artefact_shape_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_stack`
--

DROP TABLE IF EXISTS `artefact_stack`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_stack` (
  `artefact_stack_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_A_id` int(10) unsigned NOT NULL COMMENT 'The first artefact in the stack.',
  `artefact_B_id` int(10) unsigned NOT NULL COMMENT 'The second artefact in the stack.',
  `artefact_B_offset` geometry NOT NULL DEFAULT st_geometryfromtext('POINT(0 0)') COMMENT 'Gives the offset by which the artefact B must be moved to match the artefact A.  The offset is a POINT geometry.',
  `layer_A` tinyint(3) unsigned NOT NULL DEFAULT 1 COMMENT 'Gives the number of the layer in the stack to which artefact A belongs. In the case of a recto/verso match, this would be 0. In the case of a wad, a higher number should indicate a layer that is closer to the outside of the scroll, or the front of the codex.',
  `layer_B` tinyint(3) unsigned NOT NULL DEFAULT 1 COMMENT 'Gives the number of the layer in the stack to which artefact B belongs. In the case of a recto/verso match, this would be 0. In the case of a wad, a higher number should indicate a layer that is closer to the outside of the scroll, or the front of the codex.',
  `A_is_verso` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean whether srtefact A is recto=0 or verso=1.',
  `B_is_verso` tinyint(3) unsigned NOT NULL DEFAULT 1 COMMENT 'Boolean whether srtefact B is recto=0 or verso=1.',
  `reason` enum('RECTO_VERSO','FOUND_IN_A_STACK','PART_OF_A_WAD','RECONSTRUCTED_STACK') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'RECTO_VERSO',
  `shared` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'True if the given region of artefact_B represents a region which appears on the surface of artefact_A (bleeding through, ink glued to the next layer).',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`artefact_stack_id`),
  UNIQUE KEY `unique_artefact_stack` (`A_is_verso`,`artefact_A_id`,`artefact_B_id`,`artefact_B_offset`(25),`B_is_verso`,`layer_A`,`layer_B`,`reason`,`shared`) USING BTREE,
  KEY `fk_af_stack_A_to_artefact_idx` (`artefact_A_id`),
  KEY `fk_af_stack_B_to_artefact_idx` (`artefact_B_id`),
  KEY `fk_artefact_stack_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_af_stack_A_to_artefact` FOREIGN KEY (`artefact_A_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_af_stack_B_to_artefact` FOREIGN KEY (`artefact_B_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_stack_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=27724 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores the relationship between artefacts which make up a stack, meaning that they represent parallel layers in a stack. This could be:\na) Artefact A is and B represent recto/verso of one layer (artefact), then the layer_A and layer_B must be the same\nb) A and B represent parts of different layers of a already decomposed stack (reason= ‚found in a stack‘) or as part of wad (reason = ‚part of a wad‘) or as thought by the scholar to belong in the same perimeter of the manuscript (reason=‚reconstructed‘).\n\nThe tables allow the creation of a sequence of artefacts: A = recto of layer 1 -> B = verso of layer 1 -> C = recto of recto of layer  2 -> D = verso of layer 2 … (where -> represents a record with the left as artefact_A and the right term as artefact_B)\n\nA special case is marked by shared. We could, e.g., have A as verso and B as recto and additionally a subregion of B as shared to A.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_stack_owner`
--

DROP TABLE IF EXISTS `artefact_stack_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_stack_owner` (
  `artefact_stack_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`artefact_stack_id`,`edition_id`),
  KEY `fk_artefact_data_owner_to_scroll_version_id` (`edition_editor_id`),
  KEY `fk_artefact_stack_owner_to_artefact_stack_idx` (`artefact_stack_id`),
  KEY `fk_artefact_stack_to_edition` (`edition_id`),
  CONSTRAINT `fk_artefact_stack_owner_to_artefact_stack` FOREIGN KEY (`artefact_stack_id`) REFERENCES `artefact_stack` (`artefact_stack_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_stack_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_artefact_stack_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_status`
--

DROP TABLE IF EXISTS `artefact_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_status` (
  `artefact_status_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `work_status_id` int(11) unsigned NOT NULL DEFAULT 1,
  `artefact_id` int(11) unsigned NOT NULL,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`artefact_status_id`),
  UNIQUE KEY `unique_artefact_status` (`artefact_id`,`work_status_id`) USING BTREE,
  KEY `fk_artefact_status_to_work_status_id` (`work_status_id`),
  KEY `fk_artefact_status_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_artefact_status_to_artefact_id` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_status_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_status_to_work_status_id` FOREIGN KEY (`work_status_id`) REFERENCES `work_status` (`work_status_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='The artefact status is a user definable placeholder to store information about how state of work on defining the artefact.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_status_owner`
--

DROP TABLE IF EXISTS `artefact_status_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_status_owner` (
  `artefact_status_id` int(11) unsigned NOT NULL,
  `edition_id` int(11) unsigned NOT NULL,
  `edition_editor_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`artefact_status_id`,`edition_id`),
  KEY `fk_artefact_status_owner_to_edition_id` (`edition_id`),
  KEY `fk_artefact_status_owner_to_edition_editor_id` (`edition_editor_id`),
  CONSTRAINT `fk_artefact_status_owner_to_artefact_status_id` FOREIGN KEY (`artefact_status_id`) REFERENCES `artefact_status` (`artefact_status_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_status_owner_to_edition_editor_id` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_status_owner_to_edition_id` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute`
--

DROP TABLE IF EXISTS `attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute` (
  `attribute_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Designation of the attribute.',
  `description` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'A concise description of the nature of the attribute.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`attribute_id`),
  UNIQUE KEY `attribute_name_index` (`name`),
  KEY `fk_attribute_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_attribute_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores attributes that can be used to describe a sign_interpretation.  They are used in conjunction with a string value in the attribute_value, and any related numeric value can be added in the numeric_value column of the sign_interpretation_attribute table.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute_owner`
--

DROP TABLE IF EXISTS `attribute_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute_owner` (
  `attribute_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`attribute_id`,`edition_id`),
  KEY `fk_attribute_to_scroll_version` (`edition_editor_id`),
  KEY `fk_attribute_to_edition` (`edition_id`),
  CONSTRAINT `fk_attribute_owner_to_attribute` FOREIGN KEY (`attribute_id`) REFERENCES `attribute` (`attribute_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_attribute_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_attribute_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute_value`
--

DROP TABLE IF EXISTS `attribute_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute_value` (
  `attribute_value_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `attribute_id` int(10) unsigned NOT NULL COMMENT 'The id of the attribute to which a string value is to be assigned.',
  `string_value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'A unique string value that can be applied as an attribute to a sign interpretation.',
  `description` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'A concise description of the attribute value.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`attribute_value_id`),
  UNIQUE KEY `unique_attribute_and_value` (`attribute_id`,`string_value`) USING BTREE,
  KEY `fk_att_val_to_att_idx` (`attribute_id`),
  KEY `fk_attribute_value_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_att_val_to_att` FOREIGN KEY (`attribute_id`) REFERENCES `attribute` (`attribute_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_attribute_value_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='The specific string value associated with an attribute to describe some aspect of a sign_interpretation.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute_value_css`
--

DROP TABLE IF EXISTS `attribute_value_css`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute_value_css` (
  `attribute_value_css_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `attribute_value_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'The attribute value to be formatted with this CSS code.',
  `css` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The CSS descriptor(s) to apply to sign interpretations with the linked attribute value.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`attribute_value_css_id`),
  UNIQUE KEY `unique_attribute_value_css` (`attribute_value_id`,`css`) USING BTREE,
  KEY `fk_attribute_value_css_to_attribute_value` (`attribute_value_id`),
  KEY `fk_attribute_value_css_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_attribute_value_css_to_attribute_value` FOREIGN KEY (`attribute_value_id`) REFERENCES `attribute_value` (`attribute_value_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_attribute_value_css_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Custom CSS to be applied to and attribute when it is visualized in an HTML context.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute_value_css_owner`
--

DROP TABLE IF EXISTS `attribute_value_css_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute_value_css_owner` (
  `attribute_value_css_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`attribute_value_css_id`,`edition_id`),
  KEY `fk_attribute_value_css_owner_to_scroll_version` (`edition_editor_id`),
  KEY `fk_attribute_value_css_to_edition` (`edition_id`),
  CONSTRAINT `fk_attribute_value_css_owner_to_attribute_value_css` FOREIGN KEY (`attribute_value_css_id`) REFERENCES `attribute_value_css` (`attribute_value_css_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_attribute_value_css_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_attribute_value_css_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute_value_owner`
--

DROP TABLE IF EXISTS `attribute_value_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute_value_owner` (
  `attribute_value_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`attribute_value_id`,`edition_id`),
  KEY `fk_attribute_value_to_scroll_version` (`edition_editor_id`),
  KEY `fk_attribute_value_to_edition` (`edition_id`),
  CONSTRAINT `fk_attribute_value_owner_to_attribute_value` FOREIGN KEY (`attribute_value_id`) REFERENCES `attribute_value` (`attribute_value_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_attribute_value_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_attribute_value_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `edition`
--

DROP TABLE IF EXISTS `edition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `edition` (
  `edition_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique id of the edition.',
  `manuscript_id` int(10) unsigned NOT NULL COMMENT 'Id of the manuscript treated in this edition.',
  `locked` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'A boolean wheather this edition is locked. If an edition is locked, the SQE_API will not allow any changes to be made to it.',
  `copyright_holder` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'This is the person or institution who holds copyright for the edition.',
  `collaborators` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Each edition may have a set list of collaborators.  If NULL, then the API will automatically construct a list of collaborators based on the edition_editors.',
  `public` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'A boolean signalling whether this edition has been made publicly viewable or not. Public relates only to viewing rights, not to write or admin. As the system is currently constructed all public editions should also be locked.',
  PRIMARY KEY (`edition_id`),
  KEY `fk_edition_to_manuscript` (`manuscript_id`) USING BTREE,
  CONSTRAINT `fk_edition_to_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscript` (`manuscript_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1646 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table provides the anchor for a complete scholarly edition of a manuscript.  It also maintains the locked and public status of the edition.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `edition_editor`
--

DROP TABLE IF EXISTS `edition_editor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `edition_editor` (
  `edition_editor_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id of the editor, who is working on a particular edition.',
  `user_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'Link to the editor’s user account.',
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'This is the id of the edition on which this editor is working.',
  `may_write` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean whether this editor has permission to write to the edition. An editor must have read permissions to have write permissions.',
  `may_lock` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean whether the editor is allowed to lock the edition.',
  `may_read` tinyint(3) unsigned NOT NULL DEFAULT 1 COMMENT 'Boolean whether the editor is allowed to read the edition. No editors may ever be deleted from an edition, but revoking read access to an editor is the SQE equivalent to fully removing the editor from work on an edition.',
  `is_admin` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean whether an editor is an admin. An admin must have read permission. Only an admin may change the permissions of other editors, including revoking admin status (including for herself). Each edition must have at least one admin. Only an admin may publish or delete an edition.',
  PRIMARY KEY (`edition_editor_id`),
  UNIQUE KEY `edition_user_idx` (`edition_id`,`user_id`),
  KEY `fk_edition_editor_to_user` (`user_id`),
  CONSTRAINT `fk_edition_editor_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_edition_editor_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1646 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Each edition has one or more edition editors, which are the individual users working on that edition.  Each edition editor has individual access rights that are specified here.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `edition_editor_request`
--

DROP TABLE IF EXISTS `edition_editor_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `edition_editor_request` (
  `token` char(36) CHARACTER SET utf8mb4 NOT NULL COMMENT 'Unique token the user will provide to verify the requested action.',
  `admin_user_id` int(12) unsigned NOT NULL COMMENT 'User id of the admin who requested the editor.',
  `editor_user_id` int(12) unsigned NOT NULL COMMENT 'User id of the editor who was invited to join the edition.',
  `edition_id` int(12) unsigned NOT NULL COMMENT 'The id of the edition to be shared.',
  `is_admin` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Offering admin rights.',
  `may_lock` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Offering locking rights.',
  `may_write` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Offering write rights.',
  `date` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Date the editor request was sent.',
  PRIMARY KEY (`editor_user_id`,`edition_id`),
  KEY `edition_editor_request_to_admin_user_id` (`admin_user_id`),
  KEY `edition_editor_request_to_edition_id` (`edition_id`),
  KEY `edition_editor_request_to_token` (`token`),
  CONSTRAINT `edition_editor_request_to_admin_user_id` FOREIGN KEY (`admin_user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `edition_editor_request_to_edition_id` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `edition_editor_request_to_editor_user_id` FOREIGN KEY (`editor_user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `edition_editor_request_to_token` FOREIGN KEY (`token`) REFERENCES `user_email_token` (`token`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores the data for a request for a user to become an editor of an edition. It contains details about the permissions associated with the request.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `font_file`
--

DROP TABLE IF EXISTS `font_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `font_file` (
  `font_file_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `font_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'A human readable name',
  `is_public` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Flag to mark whether the file may be used also by others',
  `font_binary_data` longblob DEFAULT NULL COMMENT 'The font data to be sent as file to the front end',
  `font_format` enum('woff','woff2','ttf','otf','svg') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'woff' COMMENT 'The font-format of the font_binary_data',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`font_file_id`),
  UNIQUE KEY `font_name_idx` (`font_name`),
  KEY `fk_font_file_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_font_file_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Contains a font file to be used for reconstructed text or overlays';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `font_file_owner`
--

DROP TABLE IF EXISTS `font_file_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `font_file_owner` (
  `font_file_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`font_file_id`,`edition_id`),
  KEY `fk_font_file_to_edition` (`edition_id`),
  KEY `fk_ont_file_to_scroll_version` (`edition_editor_id`),
  CONSTRAINT `fk_font_file_owner_to_font_file` FOREIGN KEY (`font_file_id`) REFERENCES `font_file` (`font_file_id`),
  CONSTRAINT `fk_font_file_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_font_file_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iaa_edition_catalog`
--

DROP TABLE IF EXISTS `iaa_edition_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iaa_edition_catalog` (
  `iaa_edition_catalog_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `manuscript` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Standard designation of the manuscript.',
  `edition_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name of the publication in which the editio princeps appears.',
  `edition_volume` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Volume of the publication in which the editio princeps appears.',
  `edition_location_1` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'First tier identifier (usually a page number).',
  `edition_location_2` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Second tier identifier (usually a fragment/column designation).',
  `edition_side` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Side designation in editio princeps.',
  `manuscript_id` int(11) unsigned DEFAULT NULL COMMENT 'Id of the manuscript within the SQE database.',
  `comment` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Extra comments.',
  PRIMARY KEY (`iaa_edition_catalog_id`),
  UNIQUE KEY `unique_edition_entry` (`edition_location_1`,`edition_location_2`,`edition_name`,`edition_side`,`edition_volume`,`manuscript`) USING BTREE,
  KEY `fk_edition_catalog_to_manuscript_id` (`manuscript_id`) USING BTREE,
  CONSTRAINT `fk_edition_catalog_to_manuscript_id` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscript` (`manuscript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=40041 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table contains the IAA data for the editio princeps reference for all of their images.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iaa_edition_catalog_author`
--

DROP TABLE IF EXISTS `iaa_edition_catalog_author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iaa_edition_catalog_author` (
  `iaa_edition_catalog_id` int(11) unsigned NOT NULL DEFAULT 0,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`iaa_edition_catalog_id`),
  KEY `fk_edition_catalog_owner_to_scroll_version_id` (`user_id`),
  CONSTRAINT `fk_edition_catalog_owner_to_edition_catalog_id` FOREIGN KEY (`iaa_edition_catalog_id`) REFERENCES `iaa_edition_catalog` (`iaa_edition_catalog_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_iaa_edition_catalog_author_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iaa_edition_catalog_to_text_fragment`
--

DROP TABLE IF EXISTS `iaa_edition_catalog_to_text_fragment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iaa_edition_catalog_to_text_fragment` (
  `iaa_edition_catalog_to_text_fragment_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `iaa_edition_catalog_id` int(11) unsigned NOT NULL,
  `text_fragment_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`iaa_edition_catalog_to_text_fragment_id`),
  UNIQUE KEY `unique_edition_catalog_id_text_fragment_id` (`text_fragment_id`,`iaa_edition_catalog_id`) USING BTREE,
  KEY `fk_edition_catalog_to_text_fragment_to_edition_catalog_id` (`iaa_edition_catalog_id`) USING BTREE,
  CONSTRAINT `fk_edition_catalog_to_text_fragment_to_edition_catalog_id` FOREIGN KEY (`iaa_edition_catalog_id`) REFERENCES `iaa_edition_catalog` (`iaa_edition_catalog_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_edition_catalog_to_text_fragment_to_text_fragment_id` FOREIGN KEY (`text_fragment_id`) REFERENCES `text_fragment` (`text_fragment_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=15543 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This is a temporary table to curate matches between the image catalog system and the SQE text fragments in a manuscript.  It should eventually be deprecated in favor of matches inferred by spatial overlap on the virtual scroll of a the placement of a ROI linked to text transcription and an artefact linked to an image.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iaa_edition_catalog_to_text_fragment_confirmation`
--

DROP TABLE IF EXISTS `iaa_edition_catalog_to_text_fragment_confirmation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iaa_edition_catalog_to_text_fragment_confirmation` (
  `iaa_edition_catalog_to_text_fragment_id` int(11) unsigned NOT NULL DEFAULT 0,
  `confirmed` tinyint(1) unsigned DEFAULT 0 COMMENT 'Boolean for whether the match has been confirmed (1) or rejected (0).  If this is set to 0 and the user_id is NULL, then the match has neither been confirmed nor rejected (thus it should be queued for review).',
  `user_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'user_id of the person who has confirmed or rejected the match.  If NULL, the match has neither been confirmed nor rejected.',
  `time` datetime NOT NULL DEFAULT current_timestamp(),
  UNIQUE KEY `unique_edition_catalog_to_text_fragment_confirmation` (`iaa_edition_catalog_to_text_fragment_id`,`confirmed`,`user_id`,`time`) USING BTREE,
  KEY `fk_iaa_edition_catalog_to_text_fragment_confirmation_to_user` (`user_id`) USING BTREE,
  CONSTRAINT `fk_aecttfc_to_iaa_edition_catalog_to_text_fragment` FOREIGN KEY (`iaa_edition_catalog_to_text_fragment_id`) REFERENCES `iaa_edition_catalog_to_text_fragment` (`iaa_edition_catalog_to_text_fragment_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_iaa_edition_catalog_to_text_fragment_confirmation_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table is part of the temporary and preliminary catalog info matching system.  There are three possibilities here: 1. confirmed = 0 and user_id IS NULL (the match has neither been confirmed nor rejected); 2. confirmed = 0 and user_id IS NOT NULL (the user with user_id has rejected the match); 3. confirmed = 1 and user_id IS NOT NULL (the user with user_id has confirmed the match as valid).  The pairing confirmed = 1 and user_id IS NOT NULL is an invalid combination.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `prevent_impossible_insert_to_edition_catalog_to_col_confirmation` BEFORE INSERT ON `iaa_edition_catalog_to_text_fragment_confirmation` FOR EACH ROW BEGIN

IF new.confirmed = 1
    AND new.user_id IS NULL
THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = "A NULL user_id may not set confirmed to 1.";
END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `prevent_impossible_update_to_edition_catalog_to_col_confirmation` BEFORE UPDATE ON `iaa_edition_catalog_to_text_fragment_confirmation` FOR EACH ROW BEGIN

IF new.confirmed = 1
    AND new.user_id IS NULL
THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = "A NULL user_id may not set confirmed to 1.";
END IF;

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `image_catalog`
--

DROP TABLE IF EXISTS `image_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_catalog` (
  `image_catalog_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `institution` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name of the institution providing the image.',
  `catalog_number_1` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'First tier object identifier (perhaps a plate or accession number).',
  `catalog_number_2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Second tier object identifier (if available). Perhaps a fragment number on a plate, or some subdesignation of an accession number.',
  `catalog_side` tinyint(1) unsigned DEFAULT 0 COMMENT 'Side reference designation, recto = 0, verso = 1.',
  `object_id` varchar(255) GENERATED ALWAYS AS (concat(`institution`,'-',`catalog_number_1`,'-',`catalog_number_2`)) STORED COMMENT 'An autogenerated human readable object identifier based on the institution and catalogue numbers.',
  PRIMARY KEY (`image_catalog_id`),
  UNIQUE KEY `unique_catalog_entry` (`catalog_number_1`,`catalog_number_2`,`catalog_side`,`institution`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=43481 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='The referencing system of the institution providing the images.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image_catalog_author`
--

DROP TABLE IF EXISTS `image_catalog_author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_catalog_author` (
  `image_catalog_id` int(11) unsigned NOT NULL DEFAULT 0,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`image_catalog_id`),
  KEY `fk_image_catalog_owner_to_scroll_version_id` (`user_id`),
  CONSTRAINT `fk_image_catalog_author_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_image_catalog_owner_to_image_catalog_id` FOREIGN KEY (`image_catalog_id`) REFERENCES `image_catalog` (`image_catalog_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `image_text_fragment_match_catalogue`
--

DROP TABLE IF EXISTS `image_text_fragment_match_catalogue`;
/*!50001 DROP VIEW IF EXISTS `image_text_fragment_match_catalogue`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `image_text_fragment_match_catalogue` (
  `image_catalog_id` tinyint NOT NULL,
  `institution` tinyint NOT NULL,
  `catalog_number_1` tinyint NOT NULL,
  `catalog_number_2` tinyint NOT NULL,
  `catalog_side` tinyint NOT NULL,
  `object_id` tinyint NOT NULL,
  `image_urls_id` tinyint NOT NULL,
  `url` tinyint NOT NULL,
  `proxy` tinyint NOT NULL,
  `suffix` tinyint NOT NULL,
  `license` tinyint NOT NULL,
  `filename` tinyint NOT NULL,
  `iaa_edition_catalog_id` tinyint NOT NULL,
  `manuscript_id` tinyint NOT NULL,
  `edition_name` tinyint NOT NULL,
  `edition_volume` tinyint NOT NULL,
  `edition_location_1` tinyint NOT NULL,
  `edition_location_2` tinyint NOT NULL,
  `edition_side` tinyint NOT NULL,
  `comment` tinyint NOT NULL,
  `iaa_edition_catalog_to_text_fragment_id` tinyint NOT NULL,
  `text_fragment_id` tinyint NOT NULL,
  `name` tinyint NOT NULL,
  `manuscript_name` tinyint NOT NULL,
  `edition_id` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `image_to_iaa_edition_catalog`
--

DROP TABLE IF EXISTS `image_to_iaa_edition_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_to_iaa_edition_catalog` (
  `iaa_edition_catalog_id` int(11) unsigned NOT NULL DEFAULT 0,
  `image_catalog_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`iaa_edition_catalog_id`,`image_catalog_id`),
  KEY `fk_to_catalog_id` (`image_catalog_id`),
  CONSTRAINT `fk_to_catalog_id` FOREIGN KEY (`image_catalog_id`) REFERENCES `image_catalog` (`image_catalog_id`),
  CONSTRAINT `fk_to_edition_id` FOREIGN KEY (`iaa_edition_catalog_id`) REFERENCES `iaa_edition_catalog` (`iaa_edition_catalog_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Temporary table to link image catalog info with edition info until the SQE_image table is fully populated.  Once that table is populated this one will become redundant.  This was autogenerated from IAA data.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image_to_image_map`
--

DROP TABLE IF EXISTS `image_to_image_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_to_image_map` (
  `image_to_image_map_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `image1_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Id of the first SQE_image to be mapped.',
  `image2_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Id of the second SQE_image to be mapped.',
  `region_on_image1` polygon NOT NULL COMMENT 'Region on image 1 that can be found in image 2.',
  `region_on_image2` polygon NOT NULL COMMENT 'Region in image 2 that can be found in image 1.',
  `transform_matrix` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '{"matrix":[[1,0,0],[0,1,0]]}' COMMENT 'Linear affine transform to apply to image 2 in order to align it with image 1.  The format is: “{“matrix”: [[sx cosθ, -sy sinθ, tx],[sx sinθ, sy cosθ, ty]]}”.',
  `region1_hash` binary(128) GENERATED ALWAYS AS (sha2(`region_on_image1`,512)) STORED COMMENT 'θ',
  `region2_hash` binary(128) GENERATED ALWAYS AS (sha2(`region_on_image2`,512)) STORED COMMENT 'Polygon hash for uniqueness constraints.',
  PRIMARY KEY (`image_to_image_map_id`),
  UNIQUE KEY `unique_image_to_image_map` (`image1_id`,`image2_id`,`region1_hash`,`region2_hash`,`transform_matrix`) USING BTREE,
  KEY `fk_image1_to_image_id` (`image1_id`),
  KEY `fk_image2_to_image_id` (`image2_id`),
  CONSTRAINT `fk_image1_to_image_id` FOREIGN KEY (`image1_id`) REFERENCES `SQE_image` (`sqe_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_image2_to_image_id` FOREIGN KEY (`image2_id`) REFERENCES `SQE_image` (`sqe_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=71728 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table contains the mapping information to correlate images of the same object via linear affine transformations. The mapping may only invlove a portion of either image as defined in the region_on_imageX columns.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image_to_image_map_author`
--

DROP TABLE IF EXISTS `image_to_image_map_author`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_to_image_map_author` (
  `image_to_image_map_id` int(11) unsigned NOT NULL DEFAULT 0,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`image_to_image_map_id`,`user_id`),
  KEY `fk_image_to_image_map_author_to_image_to_user` (`user_id`),
  CONSTRAINT `fk_image_to_image_map_author_to_image_to_image_map` FOREIGN KEY (`image_to_image_map_id`) REFERENCES `image_to_image_map` (`image_to_image_map_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_image_to_image_map_author_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image_urls`
--

DROP TABLE IF EXISTS `image_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_urls` (
  `image_urls_id` int(11) unsigned NOT NULL DEFAULT 0,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'URL prefix of the iiif server.',
  `suffix` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Special suffux for file name (if applicable).  Usually default.jpg.',
  `proxy` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Specify a proxy address if it is necessary to use a proxy for CORS compliance.',
  `license` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'License for this iiif servers resources.',
  PRIMARY KEY (`image_urls_id`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='URL’s for the iiif image servers providing our images.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `line`
--

DROP TABLE IF EXISTS `line`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `line` (
  `line_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`line_id`)
) ENGINE=InnoDB AUTO_INCREMENT=54448 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='The line is an abstract placeholder which can receive definition via the line_data table.  It must be nested in a text fragment (text_fragment_to_line) and will contain signs (line_to_sign)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `line_data`
--

DROP TABLE IF EXISTS `line_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `line_data` (
  `line_data_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `line_id` int(10) unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name designation for this line.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`line_data_id`),
  UNIQUE KEY `unique_line_id_name` (`line_id`,`name`) USING BTREE,
  KEY `fk_line_data_to_line_idx` (`line_id`),
  KEY `fk_line_data_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_line_data_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_line_data_to_line` FOREIGN KEY (`line_id`) REFERENCES `line` (`line_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=54448 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Metadata pertaining to the description of a line of transcribed text.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `line_data_owner`
--

DROP TABLE IF EXISTS `line_data_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `line_data_owner` (
  `line_data_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`line_data_id`,`edition_id`),
  KEY `fk_line_data_owner_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_line_data_to_edition` (`edition_id`),
  CONSTRAINT `fk_line_data_owner_to_line_data` FOREIGN KEY (`line_data_id`) REFERENCES `line_data` (`line_data_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_line_data_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_line_data_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `line_to_sign`
--

DROP TABLE IF EXISTS `line_to_sign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `line_to_sign` (
  `line_to_sign_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sign_id` int(10) unsigned NOT NULL,
  `line_id` int(10) unsigned NOT NULL,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`line_to_sign_id`),
  UNIQUE KEY `line_sign_idx` (`sign_id`,`line_id`) USING BTREE,
  KEY `fk_line_to_sign_to_line_idx` (`line_id`),
  KEY `fk_line_to_sign_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_line_to_sign_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_line_to_sign_to_line` FOREIGN KEY (`line_id`) REFERENCES `line` (`line_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_line_to_sign_to_sign` FOREIGN KEY (`sign_id`) REFERENCES `sign` (`sign_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1733925 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Linking of abstract signs to a line.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `line_to_sign_owner`
--

DROP TABLE IF EXISTS `line_to_sign_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `line_to_sign_owner` (
  `line_to_sign_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`line_to_sign_id`,`edition_id`),
  KEY `fl_to_sign_owner_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_line_to_sign_to_edition` (`edition_id`),
  CONSTRAINT `fk_line_to_sign_owner_to_line_to_sign` FOREIGN KEY (`line_to_sign_id`) REFERENCES `line_to_sign` (`line_to_sign_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_line_to_sign_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_line_to_sign_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `main_action`
--

DROP TABLE IF EXISTS `main_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `main_action` (
  `main_action_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `time` datetime(6) DEFAULT current_timestamp(6) COMMENT 'The time that the database action was performed.',
  `rewinded` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean relaying whether the particular action has been rewound or not.',
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Id of the editor who performed the action.',
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Id of the edition in which the action was performed.',
  PRIMARY KEY (`main_action_id`),
  UNIQUE KEY `all_idx` (`main_action_id`,`edition_id`,`edition_editor_id`),
  KEY `main_action_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_main_action_to_edition` (`edition_id`),
  CONSTRAINT `fk_main_action_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_main_action_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table recording mutation actions (it can be used for infinite undo).  This table stores the state of the action (rewound or not), the date of the change, and the edition that the action is associated with.  The table single_action links to the entries here and describes the table in which the action occurred, the id of the entry in that table that was involved, and the nature of the action (creating a connection between that entry and the edition of the main_action, or deleting the connection between that entry and the edition of the main_action).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manuscript`
--

DROP TABLE IF EXISTS `manuscript`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manuscript` (
  `manuscript_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`manuscript_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1694 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='The manuscript is an abstract placeholder that is given metadata via the manuscript_data table. This allows multiple editions of the same manuscript to be created, regardless of the naming scheme used. A manuscript will contain one or more text fragments (manuscript_to_text_fragment)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manuscript_data`
--

DROP TABLE IF EXISTS `manuscript_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manuscript_data` (
  `manuscript_data_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `manuscript_id` int(10) unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name designation of the manuscript.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`manuscript_data_id`),
  UNIQUE KEY `unique_manuscript_id_name` (`manuscript_id`,`name`) USING BTREE,
  KEY `fk_manuscript_to_master_manuscript_idx` (`manuscript_id`) USING BTREE,
  KEY `fk_manuscript_data_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_manuscript_data_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_manuscript_to_master_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscript` (`manuscript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1372 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Description of a reconstructed manuscript or combination.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manuscript_data_owner`
--

DROP TABLE IF EXISTS `manuscript_data_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manuscript_data_owner` (
  `manuscript_data_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`manuscript_data_id`,`edition_id`),
  KEY `fk_manuscript_data_to_edition` (`edition_id`) USING BTREE,
  KEY `fk_manuscript_owner_scroll_version_idx` (`edition_editor_id`) USING BTREE,
  CONSTRAINT `fk_manuscript_data_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_manuscript_data_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`),
  CONSTRAINT `fk_manuscript_owner_to_scroll_data` FOREIGN KEY (`manuscript_data_id`) REFERENCES `manuscript_data` (`manuscript_data_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manuscript_metrics`
--

DROP TABLE IF EXISTS `manuscript_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manuscript_metrics` (
  `manuscript_metrics_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `manuscript_id` int(11) unsigned NOT NULL,
  `x_origin` int(11) NOT NULL DEFAULT 0 COMMENT 'This is the x value of the starting point of the manuscript.  The coordinate system begins top left, positive values increase while moving downward on the y-axis and while moving rightward on the x-axis.',
  `y_origin` int(11) NOT NULL DEFAULT 0 COMMENT 'This is the y value of the starting point of the manuscript.  The coordinate system begins top left, positive values increase while moving downward on the y-axis and while moving rightward on the x-axis.',
  `width` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'This is the width of the manucsript in millimeters.',
  `height` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'This is the height of the manucsript in millimeters.',
  `pixels_per_inch` int(11) unsigned NOT NULL DEFAULT 1215 COMMENT 'This is the pixels per inch for the manuscript.  At the outset we have decided to set all manuscripts at 1215 PPI, which is the resolution of most images being used.  All images should be scaled to this resolution before creating artefacts and ROIs that are placed upon the virtual manuscript.  We have no plans to use varying PPI settings for different manuscripts, which would slightly complicate GIS calculations across multiple manuscripts.',
  `scribal_font_id` int(10) unsigned DEFAULT NULL,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`manuscript_metrics_id`),
  UNIQUE KEY `unique_manuscript_metrics` (`manuscript_id`,`height`,`pixels_per_inch`,`width`,`x_origin`,`y_origin`) USING BTREE,
  KEY `manuscript_metrics_to_manuscript` (`manuscript_id`),
  KEY `manuscript_metrics_to_scribal_font_fk` (`scribal_font_id`),
  KEY `fk_manuscript_metrics_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_manuscript_metrics_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `manuscript_metrics_to_manuscript` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscript` (`manuscript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `manuscript_metrics_to_scribal_font_fk` FOREIGN KEY (`scribal_font_id`) REFERENCES `scribal_font` (`scribal_font_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1372 DEFAULT CHARSET=utf8mb4 COMMENT='This table stores basic information about the gross metrics of a manuscript.  The user is able to specify an  x/y-origin point for the start of the manuscript along with its proposed height and width in millimeters.  The coordinate system begins top left, positive values increase while moving downward on the y-axis and while moving rightward on the x-axis.  The PPI is currently fixed ad 1215 PPI to facilitate comparison of GIS data between manuscripts.  All images should be scaled to this resolution before creating artefacts and ROIs that are placed upon the virtual manuscript.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manuscript_metrics_owner`
--

DROP TABLE IF EXISTS `manuscript_metrics_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manuscript_to_text_fragment`
--

DROP TABLE IF EXISTS `manuscript_to_text_fragment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manuscript_to_text_fragment` (
  `manuscript_to_text_fragment_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `manuscript_id` int(10) unsigned NOT NULL,
  `text_fragment_id` int(10) unsigned NOT NULL,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`manuscript_to_text_fragment_id`),
  UNIQUE KEY `manuscript_text_fragment_idx` (`manuscript_id`,`text_fragment_id`) USING BTREE,
  KEY `fk_manuscript_to_text_fragment_to_text_fragment_idx` (`text_fragment_id`) USING BTREE,
  KEY `fk_manuscript_to_text_fragment_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_manuscript_to_text_fragment_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_manuscript_to_text_fragment_to_scroll` FOREIGN KEY (`manuscript_id`) REFERENCES `manuscript` (`manuscript_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_manuscript_to_text_fragment_to_text_fragment` FOREIGN KEY (`text_fragment_id`) REFERENCES `text_fragment` (`text_fragment_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Links an entry in the text_fragment table to a reconstructed manuscript.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `manuscript_to_text_fragment_owner`
--

DROP TABLE IF EXISTS `manuscript_to_text_fragment_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manuscript_to_text_fragment_owner` (
  `manuscript_to_text_fragment_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`manuscript_to_text_fragment_id`,`edition_id`),
  KEY `fk_manuscript_to_text_fragment_owner_to_edition_editor_idx` (`edition_editor_id`) USING BTREE,
  KEY `fk_manuscript_to_text_fragment_to_edition` (`edition_id`) USING BTREE,
  CONSTRAINT `fk_manuscript_to_text_fragment_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_manuscript_to_text_fragment_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`),
  CONSTRAINT `fk_mttfo_to_manuscript_to_text_fragment` FOREIGN KEY (`manuscript_to_text_fragment_id`) REFERENCES `manuscript_to_text_fragment` (`manuscript_to_text_fragment_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parallel_group`
--

DROP TABLE IF EXISTS `parallel_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parallel_group` (
  `parallel_group_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`parallel_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parallel_word`
--

DROP TABLE IF EXISTS `parallel_word`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parallel_word` (
  `parallel_word_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `word_id` int(10) unsigned NOT NULL,
  `parallel_group_id` int(10) unsigned NOT NULL,
  `sub_group` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`parallel_word_id`),
  UNIQUE KEY `unique_word_id_parallel_group_id_sup_group` (`parallel_group_id`,`sub_group`,`word_id`) USING BTREE,
  KEY `fk_par_word_to_group_idx` (`parallel_group_id`),
  KEY `fk_par_owrd_to_word_idx` (`word_id`),
  KEY `fk_parallel_word_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_par_owrd_to_word` FOREIGN KEY (`word_id`) REFERENCES `sign_stream_section` (`sign_stream_section_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_par_word_to_group` FOREIGN KEY (`parallel_group_id`) REFERENCES `parallel_group` (`parallel_group_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_parallel_word_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table enables a connection to be made between parallel words in two different manuscripts.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parallel_word_owner`
--

DROP TABLE IF EXISTS `parallel_word_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parallel_word_owner` (
  `parallel_word_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`parallel_word_id`,`edition_id`),
  KEY `fk_par_word_owner_to_sc_idx` (`edition_editor_id`),
  KEY `fk_parallel_word_to_edition` (`edition_id`),
  CONSTRAINT `fk_par_word_owner_to_par_word` FOREIGN KEY (`parallel_word_id`) REFERENCES `parallel_word` (`parallel_word_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_parallel_word_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_parallel_word_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `point_to_point_map`
--

DROP TABLE IF EXISTS `point_to_point_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `point_to_point_map` (
  `point_to_point_map_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `image_to_image_map_id` int(10) unsigned NOT NULL,
  `point_on_image1` multipoint NOT NULL COMMENT 'This is the list of corresponding points for image 1.',
  `point_on_image2` multipoint NOT NULL COMMENT 'This is the list of corresponding points for image 2.',
  PRIMARY KEY (`point_to_point_map_id`),
  KEY `fK_p_to_p_toIm_to_im_idx` (`image_to_image_map_id`),
  CONSTRAINT `fK_p_to_p_toIm_to_im` FOREIGN KEY (`image_to_image_map_id`) REFERENCES `image_to_image_map` (`image_to_image_map_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table holds data pertaining to nonlinear transforms between a set of two images. It stores a list of points in one image and the corresponding points in another image.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `position_in_stream`
--

DROP TABLE IF EXISTS `position_in_stream`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `position_in_stream` (
  `position_in_stream_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sign_interpretation_id` int(11) unsigned NOT NULL,
  `next_sign_interpretation_id` int(11) unsigned DEFAULT NULL,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`position_in_stream_id`),
  KEY `fk_position_in_stream_to_sign_interpretation` (`sign_interpretation_id`),
  KEY `fk_position_in_stream_to_next_sign_interpretation` (`next_sign_interpretation_id`),
  KEY `fk_position_in_stream_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_position_in_stream_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_position_in_stream_to_next_sign_interpretation` FOREIGN KEY (`next_sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`),
  CONSTRAINT `fk_position_in_stream_to_sign_interpretation` FOREIGN KEY (`sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1722967 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table provides ordering data for the transcriptions.  It provides a DAG linking sign_interpretations to each other.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `position_in_stream_owner`
--

DROP TABLE IF EXISTS `position_in_stream_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `position_in_stream_owner` (
  `position_in_stream_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(11) unsigned NOT NULL,
  `edition_editor_id` int(11) unsigned NOT NULL,
  `is_main` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'If true, the next item will be\nfirst in the list of next items. There should \nonly one next item marked this way\nfor each item of this owner.',
  PRIMARY KEY (`position_in_stream_id`,`edition_id`),
  KEY `fk_position_in_stream_owner_to_edition_id` (`edition_id`),
  KEY `fk_position_in_stream_owner_to_edition_editor_id` (`edition_editor_id`),
  CONSTRAINT `fk_position_in_stream_owner_to_edition_editor_id` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_position_in_stream_owner_to_edition_id` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_position_in_stream_owner_to_position_in_stream` FOREIGN KEY (`position_in_stream_id`) REFERENCES `position_in_stream` (`position_in_stream_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `position_in_stream_to_section_rel`
--

DROP TABLE IF EXISTS `position_in_stream_to_section_rel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `position_in_stream_to_section_rel` (
  `position_in_stream_id` int(11) unsigned NOT NULL,
  `sign_stream_section_id` int(10) unsigned NOT NULL COMMENT 'Reference to sign_stream_section',
  PRIMARY KEY (`position_in_stream_id`,`sign_stream_section_id`),
  KEY `fk_position_in_stream_to_section_rel_to_word_id` (`sign_stream_section_id`),
  CONSTRAINT `fk_position_in_stream_to_section_rel_to_position_in_stream` FOREIGN KEY (`position_in_stream_id`) REFERENCES `position_in_stream` (`position_in_stream_id`),
  CONSTRAINT `fk_position_in_stream_to_section_rel_to_word_id` FOREIGN KEY (`sign_stream_section_id`) REFERENCES `sign_stream_section` (`sign_stream_section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table links sign_interpretations to the words they are part of.  This creates a bridge from the SQE data to the words stored in the QWB database.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `position_in_text_fragment_stream`
--

DROP TABLE IF EXISTS `position_in_text_fragment_stream`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `position_in_text_fragment_stream` (
  `position_in_text_fragment_stream_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `text_fragment_id` int(10) unsigned NOT NULL,
  `next_text_fragment_id` int(10) unsigned DEFAULT NULL,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`position_in_text_fragment_stream_id`),
  KEY `fk_pitfs_next_to_text_fragment` (`next_text_fragment_id`),
  KEY `fk_pitfs_to_text_fragment` (`text_fragment_id`),
  KEY `fk_position_in_text_fragment_stream_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_pitfs_next_to_text_fragment` FOREIGN KEY (`next_text_fragment_id`) REFERENCES `text_fragment` (`text_fragment_id`),
  CONSTRAINT `fk_pitfs_to_text_fragment` FOREIGN KEY (`text_fragment_id`) REFERENCES `text_fragment` (`text_fragment_id`),
  CONSTRAINT `fk_position_in_text_fragment_stream_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=16715 DEFAULT CHARSET=latin1 COMMENT='Gives a stream of fragments in a scroll in the right order';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `position_in_text_fragment_stream_owner`
--

DROP TABLE IF EXISTS `position_in_text_fragment_stream_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `position_in_text_fragment_stream_owner` (
  `position_in_text_fragment_stream_id` int(10) unsigned NOT NULL,
  `edition_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL,
  `is_main` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'If true, the next item will be\nfirst in the list of next items. There should\nonly one next item marked this way\nfor each item of this owner.',
  PRIMARY KEY (`position_in_text_fragment_stream_id`,`edition_id`),
  KEY `fk_pitfs_owner_to_edition` (`edition_id`),
  KEY `fk_pitfs_owner_to_editor` (`edition_editor_id`),
  CONSTRAINT `fk_pitfs_owner_pitfs` FOREIGN KEY (`position_in_text_fragment_stream_id`) REFERENCES `position_in_text_fragment_stream` (`position_in_text_fragment_stream_id`),
  CONSTRAINT `fk_pitfs_owner_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_pitfs_owner_to_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qwb_biblio`
--

DROP TABLE IF EXISTS `qwb_biblio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qwb_biblio` (
  `qwb_biblio_id` int(10) unsigned NOT NULL,
  `biblio_short` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `biblio_long` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`qwb_biblio_id`),
  UNIQUE KEY `qwb_biblio_id_UNIQUE` (`qwb_biblio_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qwb_ref`
--

DROP TABLE IF EXISTS `qwb_ref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qwb_ref` (
  `qwb_ref_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `line_id` int(10) unsigned DEFAULT NULL COMMENT 'The SQE line id related to this QWB reference',
  `qwb_scroll_name` varchar(16) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'The precise name of the scroll in the QWB database',
  `qwb_fragment_name` varchar(40) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'The precise name of the fragment or column in the QWB database',
  `qwb_line_name` varchar(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL COMMENT 'The precise line designation in the QWB database',
  `text` varchar(255) GENERATED ALWAYS AS (concat(`qwb_scroll_name`,'%',if(locate('frg',`qwb_fragment_name`) > 0,`qwb_fragment_name`,concat('col. ',`qwb_fragment_name`)),'%',`qwb_line_name`)) STORED,
  PRIMARY KEY (`qwb_ref_id`),
  KEY `qwb_ref_text_index` (`text`)
) ENGINE=InnoDB AUTO_INCREMENT=65536 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table creates a connection between the references in the QWB database and the textual references within the SQE text system.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qwb_variant`
--

DROP TABLE IF EXISTS `qwb_variant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qwb_variant` (
  `qwb_variant_id` int(10) unsigned NOT NULL,
  `qwb_word_id` int(10) unsigned NOT NULL,
  `text` varchar(83) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lemma` varchar(35) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grammar` varchar(33) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meaning` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('variant','missing','addition') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commentary` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qwb_biblio_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`qwb_variant_id`),
  KEY `fk_qwb_var_to_qwb_data_idx` (`qwb_word_id`),
  KEY `fk_qwb_var_to_qwb_biblio_idx` (`qwb_biblio_id`),
  CONSTRAINT `fk_qwb_var_to_qwb` FOREIGN KEY (`qwb_word_id`) REFERENCES `qwb_word` (`qwb_word_id`),
  CONSTRAINT `fk_qwb_var_to_qwb_biblio` FOREIGN KEY (`qwb_biblio_id`) REFERENCES `qwb_biblio` (`qwb_biblio_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qwb_word`
--

DROP TABLE IF EXISTS `qwb_word`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qwb_word` (
  `qwb_word_id` int(10) unsigned NOT NULL,
  `qwb_last_change` datetime NOT NULL DEFAULT '1000-01-01 00:00:00',
  `processing` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`qwb_word_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `recent_edition_catalog_to_col_confirmation`
--

DROP TABLE IF EXISTS `recent_edition_catalog_to_col_confirmation`;
/*!50001 DROP VIEW IF EXISTS `recent_edition_catalog_to_col_confirmation`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `recent_edition_catalog_to_col_confirmation` (
  `iaa_edition_catalog_to_text_fragment_id` tinyint NOT NULL,
  `confirmed` tinyint NOT NULL,
  `user_id` tinyint NOT NULL,
  `MAX(``time``)` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `roi_position`
--

DROP TABLE IF EXISTS `roi_position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roi_position` (
  `roi_position_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_id` int(11) unsigned NOT NULL COMMENT 'ROI’s are linked to artefacts.  Those artefacts may be real (i.e., linked to an image) or virtual (i.e., not linked to an image). A virtual manuscript is the sum total of all the artefacts positioned in it.',
  `translate_x` int(11) NOT NULL DEFAULT 0 COMMENT 'The translation on the X axis necessary to position the a ROI shape in the artefact''s coordinate system. The artefact coordinate system is the same as the “master imafe” to which it is linked, but always scaled to a resolution of 1215 PPI.',
  `translate_y` int(11) NOT NULL DEFAULT 0 COMMENT 'The translation on the Y axis necessary to position the a ROI shape in the artefact''s coordinate system. The artefact coordinate system is the same as the “master imafe” to which it is linked, but always scaled to a resolution of 1215 PPI.',
  `stance_rotation` smallint(5) unsigned DEFAULT NULL COMMENT 'Any rotation that would be necessary for the sign to have the correct stance on a horizontal plane. This is to be applied whent creating fonts and analyzing the expected script orientation in relation to its actual orientation on an artefact.',
  PRIMARY KEY (`roi_position_id`),
  KEY `fk_roi_position_to_artefact` (`artefact_id`),
  CONSTRAINT `fk_roi_position_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ROI’s are linked to artefacts.  To get the location of the ROI in the coordinate system of the “virtual manuscript, one must first apply the roi_position and then the position of the linked artefact. This can by done via the UDF nested_geom_transform.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roi_shape`
--

DROP TABLE IF EXISTS `roi_shape`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roi_shape` (
  `roi_shape_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `path` geometry DEFAULT NULL COMMENT 'This is a POLYGON geometry describing the shape of the ROI. It is its own 0,0 coordinate system and is correlated with a location in an artefact via a translation (without scale or rotation) in the roi_position table. Its resolution is the same as the artefact, 1215 PPI.',
  PRIMARY KEY (`roi_shape_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table holds the polygon describing the ROI in its own coordinate system. The roi_position table situates the polygon in the coordinate system of the artefact.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribal_font`
--

DROP TABLE IF EXISTS `scribal_font`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scribal_font` (
  `scribal_font_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier',
  `font_file_id` int(10) unsigned NOT NULL COMMENT 'Reference to the font file.',
  `default_word_space` smallint(5) unsigned DEFAULT 85 COMMENT 'The default space in pixel to be set between two words',
  `default_interlinear_space` smallint(5) unsigned DEFAULT 280 COMMENT 'The default space between two lines in pixel',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`scribal_font_id`),
  KEY `fk_scribal_font_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_scribal_font_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Defines a font found in the scrolls. It connects to a font file and is referred by glyph info';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribal_font_glyph_metrics`
--

DROP TABLE IF EXISTS `scribal_font_glyph_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scribal_font_glyph_metrics` (
  `scribal_font_glyph_metrics_id` int(10) unsigned NOT NULL COMMENT 'Unique identifier',
  `scribal_font_id` int(10) unsigned NOT NULL COMMENT 'Reference to scribal font',
  `unicode_char` varbinary(4) NOT NULL COMMENT 'Char of font',
  `width` smallint(6) unsigned NOT NULL DEFAULT 100 COMMENT 'Width of glyph',
  `height` smallint(5) unsigned NOT NULL DEFAULT 200 COMMENT 'Height of glyph',
  `y_offset` smallint(6) NOT NULL DEFAULT -200 COMMENT 'Vertical offset glyph (thought to stand on line)',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`scribal_font_glyph_metrics_id`),
  UNIQUE KEY `char_idx` (`unicode_char`),
  KEY `fk_sfg_to_scribal_font` (`scribal_font_id`),
  KEY `fk_scribal_font_glyph_metrics_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_scribal_font_glyph_metrics_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sfg_to_scribal_font` FOREIGN KEY (`scribal_font_id`) REFERENCES `scribal_font` (`scribal_font_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Contains the bounding box and position metrics of a scribal font. Only used to calculate ROIs not yet set by the user.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribal_font_glyph_metrics_owner`
--

DROP TABLE IF EXISTS `scribal_font_glyph_metrics_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribal_font_kerning`
--

DROP TABLE IF EXISTS `scribal_font_kerning`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scribal_font_kerning` (
  `scribal_font_kerning_id` int(10) unsigned NOT NULL COMMENT 'Unique identifier',
  `scribal_font_id` int(10) unsigned NOT NULL COMMENT 'Reference to scribal font',
  `first_unicode_char` varbinary(4) NOT NULL COMMENT 'Charcode of the first glyph',
  `second_unicode_char` varbinary(4) NOT NULL COMMENT 'Charcode of the second glyph',
  `kerning_x` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Horizontal kerning',
  `kerning_y` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Vertical kerning',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`scribal_font_kerning_id`),
  UNIQUE KEY `char_idx` (`scribal_font_id`,`first_unicode_char`,`second_unicode_char`),
  KEY `fk_scribal_font_kerning_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_scribal_font_kerning_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sfk_to_scribal_font` FOREIGN KEY (`scribal_font_id`) REFERENCES `scribal_font` (`scribal_font_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Contains kerning of glyph of a scribal font. Only used to calculated the position of signs not yet positioned by the user';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribal_font_kerning_owner`
--

DROP TABLE IF EXISTS `scribal_font_kerning_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribal_font_owner`
--

DROP TABLE IF EXISTS `scribal_font_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scribal_font_owner` (
  `scribal_font_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`scribal_font_id`,`edition_id`),
  KEY `fk_scribal_font_type_to_edition` (`edition_id`),
  KEY `fk_scribal_font_owner_scroll_version_idx` (`edition_editor_id`),
  CONSTRAINT `fk_scribal_font_owner_to_font` FOREIGN KEY (`scribal_font_id`) REFERENCES `scribal_font` (`scribal_font_id`),
  CONSTRAINT `fk_scribal_font_type_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_scribal_font_type_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribe`
--

DROP TABLE IF EXISTS `scribe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scribe` (
  `scribe_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commetary` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`scribe_id`),
  KEY `fk_scribe_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_scribe_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribe_owner`
--

DROP TABLE IF EXISTS `scribe_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scribe_owner` (
  `scribe_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`scribe_id`,`edition_id`),
  KEY `fk_scribe_owner_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_scribe_to_edition` (`edition_id`),
  CONSTRAINT `fk_scribe_owner_to_scribe` FOREIGN KEY (`scribe_id`) REFERENCES `scribe` (`scribe_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_scribe_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_scribe_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign`
--

DROP TABLE IF EXISTS `sign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign` (
  `sign_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`sign_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1733943 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This is an abstract placeholder allowing a multiplicity of interpretations to be related to each other by linking to the same sign_id.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_interpretation`
--

DROP TABLE IF EXISTS `sign_interpretation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_interpretation` (
  `sign_interpretation_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sign_id` int(10) unsigned NOT NULL COMMENT 'Id of the sign being described.',
  `is_variant` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean set to true when current entry is a variant interpretation of a sign.',
  `character` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'This may be left null for signs that are not interpreted as characters (e.g., control signs like line start/line end or material features of any sort), otherwise it is a single letter.',
  PRIMARY KEY (`sign_interpretation_id`),
  UNIQUE KEY `unique_sign_id_is_variant_sign` (`is_variant`,`character`,`sign_id`) USING BTREE,
  KEY `fk_sign_interpretation_to_sign_idx` (`sign_id`) USING BTREE,
  CONSTRAINT `fk_sign_interpretation_to_sign` FOREIGN KEY (`sign_id`) REFERENCES `sign` (`sign_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1733925 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table describes the interpretation of signs in an edition.  Currently this includes both characters, spaces, and formatting marks, it could perhaps also include other elements that one might want to define as a sign.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_interpretation_attribute`
--

DROP TABLE IF EXISTS `sign_interpretation_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_interpretation_attribute` (
  `sign_interpretation_attribute_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sign_interpretation_id` int(10) unsigned NOT NULL COMMENT 'Id of the sign interpretation being descibed.',
  `attribute_value_id` int(10) unsigned NOT NULL COMMENT 'Id of the attribute to apply to this sign interpretation.',
  `sequence` tinyint(4) DEFAULT NULL COMMENT 'Absolute ordering of this record.  This is used to define the order of all records for the same sign_char_id.',
  `numeric_value` float DEFAULT NULL COMMENT 'Contains the width of a character (normally 1), space (dto.), or vacat (normally > 1) or the level of probability.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`sign_interpretation_attribute_id`),
  UNIQUE KEY `unique_sign_interpretation_id_attribute_value_id_sequence` (`attribute_value_id`,`sequence`,`sign_interpretation_id`) USING BTREE,
  KEY `fk_sign_interpretation_attr_to_attr_value_idx` (`attribute_value_id`) USING BTREE,
  KEY `fk_sign_interpretation_attr_to_sign_interpretation_idx` (`sign_interpretation_id`) USING BTREE,
  KEY `fk_sign_interpretation_attribute_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_sign_interpretation_attr_to_attr_value` FOREIGN KEY (`attribute_value_id`) REFERENCES `attribute_value` (`attribute_value_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_interpretation_attr_to_sign_interpretation` FOREIGN KEY (`sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_interpretation_attribute_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4970052 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table links sign_interpretations to the attributes that further describe the sign’s interpretation.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_interpretation_attribute_owner`
--

DROP TABLE IF EXISTS `sign_interpretation_attribute_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_interpretation_attribute_owner` (
  `sign_interpretation_attribute_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`sign_interpretation_attribute_id`,`edition_id`),
  KEY `fk_sign_attr_owner_to_edition_editor_idx` (`edition_editor_id`) USING BTREE,
  KEY `fk_sign_interpretation_attribute_to_edition` (`edition_id`) USING BTREE,
  CONSTRAINT `fk_sign_interpretation_attr_owner_to_sca` FOREIGN KEY (`sign_interpretation_attribute_id`) REFERENCES `sign_interpretation_attribute` (`sign_interpretation_attribute_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_interpretation_attribute_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_sign_interpretation_attribute_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`),
  CONSTRAINT `fk_sign_interpretation_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_interpretation_commentary`
--

DROP TABLE IF EXISTS `sign_interpretation_commentary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_interpretation_commentary` (
  `sign_interpretation_commentary_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sign_interpretation_id` int(10) unsigned NOT NULL COMMENT 'Id of the sign interpretation being commented on.',
  `attribute_id` int(10) unsigned DEFAULT NULL COMMENT 'Id of the attrivute describing the aspect of this sign interpretation being commented on.',
  `commentary` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Editorial comments.',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`sign_interpretation_commentary_id`),
  KEY `fk_sic_to_attribute_idx` (`attribute_id`) USING BTREE,
  KEY `sign_interpretation_id` (`sign_interpretation_id`) USING BTREE,
  KEY `fk_sign_interpretation_commentary_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_sign_interpretation_commentary_to_attribute` FOREIGN KEY (`attribute_id`) REFERENCES `attribute` (`attribute_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_interpretation_commentary_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_interpretation_commentary_to_sign_char` FOREIGN KEY (`sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table allows editors to attach commentary to a specific attribute of a sign interpretation.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_interpretation_commentary_owner`
--

DROP TABLE IF EXISTS `sign_interpretation_commentary_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_interpretation_commentary_owner` (
  `sign_interpretation_commentary_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`sign_interpretation_commentary_id`,`edition_id`),
  KEY `fk_sic_owner_to_scrollversion_idx` (`edition_editor_id`) USING BTREE,
  KEY `fk_sign_interpretation_commentary_to_edition` (`edition_id`) USING BTREE,
  CONSTRAINT `fk_sign_interpretation_commentary_onwer_to_scc` FOREIGN KEY (`sign_interpretation_commentary_id`) REFERENCES `sign_interpretation_commentary` (`sign_interpretation_commentary_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_interpretation_commentary_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_sign_interpretation_commentary_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_interpretation_roi`
--

DROP TABLE IF EXISTS `sign_interpretation_roi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_interpretation_roi` (
  `sign_interpretation_roi_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sign_interpretation_id` int(10) unsigned DEFAULT NULL COMMENT 'Id of the sign interpretation being marked in an artefact.',
  `roi_shape_id` int(10) unsigned NOT NULL COMMENT 'Id of the shape for this ROI.',
  `roi_position_id` int(10) unsigned NOT NULL COMMENT 'Id for the position of this ROI in its artefact.',
  `values_set` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `exceptional` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean whether this ROI is exceptional (and thus should be excluded from some statistical analyses).',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`sign_interpretation_roi_id`),
  UNIQUE KEY `unique_sign_interpretation_shape_position` (`sign_interpretation_id`,`roi_shape_id`,`roi_position_id`) USING BTREE,
  KEY `fk_sign_area_to_area_idx` (`roi_shape_id`),
  KEY `fk_sign_area_to_area_position_idx` (`roi_position_id`),
  KEY `fk_sign_area_to_sign_interpretation_idx` (`sign_interpretation_id`) USING BTREE,
  KEY `fk_sign_interpretation_roi_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_sign_area_to_roi_position` FOREIGN KEY (`roi_position_id`) REFERENCES `roi_position` (`roi_position_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_area_to_roi_shape` FOREIGN KEY (`roi_shape_id`) REFERENCES `roi_shape` (`roi_shape_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_interpretation_roi_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_sign_roi_to_sign_interpretation` FOREIGN KEY (`sign_interpretation_id`) REFERENCES `sign_interpretation` (`sign_interpretation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table links a sign_interpretation to the ROI or ROIs it describes.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_interpretation_roi_owner`
--

DROP TABLE IF EXISTS `sign_interpretation_roi_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_interpretation_roi_owner` (
  `sign_interpretation_roi_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`sign_interpretation_roi_id`,`edition_id`),
  KEY `fk_sign_area_owner_to_sv_idx` (`edition_editor_id`),
  KEY `fk_sign_interpretation_roi_to_edition` (`edition_id`) USING BTREE,
  CONSTRAINT `fk_sign_area_owner_to_sign_area` FOREIGN KEY (`sign_interpretation_roi_id`) REFERENCES `sign_interpretation_roi` (`sign_interpretation_roi_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_interpretation_roi_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_sign_interpretation_roi_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_stream_section`
--

DROP TABLE IF EXISTS `sign_stream_section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_stream_section` (
  `sign_stream_section_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier',
  `commentary` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`sign_stream_section_id`),
  KEY `fk_sign_stream_section_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_sign_stream_section_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=380474 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='A collection of coherent signs from a stream.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_stream_section_owner`
--

DROP TABLE IF EXISTS `sign_stream_section_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_stream_section_owner` (
  `sign_stream_section_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`sign_stream_section_id`,`edition_id`),
  KEY `fk_sss_owner_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_sss_owner_to_edition` (`edition_id`),
  CONSTRAINT `fk_sss_owner_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_sss_owner_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`),
  CONSTRAINT `fk_sss_owner_to_sss` FOREIGN KEY (`sign_stream_section_id`) REFERENCES `sign_stream_section` (`sign_stream_section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_stream_section_to_qwb_word`
--

DROP TABLE IF EXISTS `sign_stream_section_to_qwb_word`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_stream_section_to_qwb_word` (
  `sign_stream_section_id` int(10) unsigned NOT NULL COMMENT 'Refers to sign_stream_section',
  `qwb_word_id` int(10) unsigned NOT NULL COMMENT 'Refers to qwb_word',
  UNIQUE KEY `sign_stream_section_to_qwb_word_pk` (`sign_stream_section_id`,`qwb_word_id`),
  KEY `sss_to_qwb_word_fk` (`qwb_word_id`),
  CONSTRAINT `sss_to_qwb_word_fk` FOREIGN KEY (`qwb_word_id`) REFERENCES `qwb_word` (`qwb_word_id`),
  CONSTRAINT `sss_to_qwb_word_to_sss_fk` FOREIGN KEY (`sign_stream_section_id`) REFERENCES `sign_stream_section` (`sign_stream_section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Provides n:m connection between qwb words and sections of the sign stream.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `single_action`
--

DROP TABLE IF EXISTS `single_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `single_action` (
  `single_action_id` bigint(19) unsigned NOT NULL AUTO_INCREMENT,
  `main_action_id` int(10) unsigned NOT NULL COMMENT 'Id of the main action that this single action belongs to.',
  `action` enum('add','delete') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The nature of the action applied.  A link to an edition was either added or deleted.',
  `table` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Table containing the entry that was either added to or deleted from the edition.',
  `id_in_table` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Id of the record that was added to or deleted from the edition (of the linked main_action) in the “table”_owner table.',
  PRIMARY KEY (`single_action_id`),
  KEY `fk_single_action_to_main_idx` (`main_action_id`),
  CONSTRAINT `fk_single_action_to_main` FOREIGN KEY (`main_action_id`) REFERENCES `main_action` (`main_action_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table joins with the main_action table to record all mutation actions taken regarding each edition.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_roles`
--

DROP TABLE IF EXISTS `system_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_roles` (
  `system_roles_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `role_title` varchar(128) NOT NULL DEFAULT '' COMMENT 'A short title for the role.',
  `role_description` text NOT NULL COMMENT 'A description of what an API that manages the database should consider as permissable for this role to do within the database.',
  PRIMARY KEY (`system_roles_id`),
  UNIQUE KEY `role_title` (`role_title`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `text_fragment`
--

DROP TABLE IF EXISTS `text_fragment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `text_fragment` (
  `text_fragment_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`text_fragment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='The text_fragment is an abstract placeholder that can be named via text_fragment_data, subsumed in a manuscript (manuscript_to_text_fragment), and joined with the lines that contitute it (text_fragment_to_line).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `text_fragment_data`
--

DROP TABLE IF EXISTS `text_fragment_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `text_fragment_data` (
  `text_fragment_data_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `text_fragment_id` int(10) unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name designation for this fragment of text (usually col. x or frg. x).',
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`text_fragment_data_id`),
  UNIQUE KEY `unique_text_fragment_id_text_fragment_name` (`text_fragment_id`,`name`) USING BTREE,
  KEY `fk_text_fragment_data_to_text_fragment_idx` (`text_fragment_id`) USING BTREE,
  KEY `fk_text_fragment_data_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_text_fragment_data_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_text_fragment_data_to_text_fragment` FOREIGN KEY (`text_fragment_id`) REFERENCES `text_fragment` (`text_fragment_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table defines the properties of a unified grouping of text containing one or more lines.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `text_fragment_data_owner`
--

DROP TABLE IF EXISTS `text_fragment_data_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `text_fragment_data_owner` (
  `text_fragment_data_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`text_fragment_data_id`,`edition_id`),
  KEY `fk_text_fragment_data_owner_to_scroll_version_idx` (`edition_editor_id`) USING BTREE,
  KEY `fk_text_fragment_data_to_edition` (`edition_id`) USING BTREE,
  CONSTRAINT `fk_text_fragment_data_owner_to_text_fragment_data` FOREIGN KEY (`text_fragment_data_id`) REFERENCES `text_fragment_data` (`text_fragment_data_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_text_fragment_data_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_text_fragment_data_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `text_fragment_to_line`
--

DROP TABLE IF EXISTS `text_fragment_to_line`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `text_fragment_to_line` (
  `text_fragment_to_line_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `text_fragment_id` int(10) unsigned NOT NULL,
  `line_id` int(10) unsigned NOT NULL,
  `creator_id` int(11) unsigned NOT NULL DEFAULT 1,
  PRIMARY KEY (`text_fragment_to_line_id`),
  UNIQUE KEY `text_fragment_line_idx` (`text_fragment_id`,`line_id`) USING BTREE,
  KEY `fk_text_fragment_to_line_to_line_idx` (`line_id`) USING BTREE,
  KEY `fk_text_fragment_to_line_to_creator_id` (`creator_id`),
  CONSTRAINT `fk_text_fragment_to_line_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_text_fragment_to_line_to_line` FOREIGN KEY (`line_id`) REFERENCES `line` (`line_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_text_fragment_to_line_to_text_fragment` FOREIGN KEY (`text_fragment_id`) REFERENCES `text_fragment` (`text_fragment_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=54448 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table links lines of an edition to a specific text fragment.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `text_fragment_to_line_owner`
--

DROP TABLE IF EXISTS `text_fragment_to_line_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `text_fragment_to_line_owner` (
  `text_fragment_to_line_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`text_fragment_to_line_id`,`edition_id`),
  KEY `fk_text_fragment_to_line_to_edition` (`edition_id`) USING BTREE,
  KEY `fk_text_fragment_to_linew_owner_to_scroll_version_idx` (`edition_editor_id`) USING BTREE,
  CONSTRAINT `fk_text_fragment_to_line_owner_to_text_fragment_to_line` FOREIGN KEY (`text_fragment_to_line_id`) REFERENCES `text_fragment_to_line` (`text_fragment_to_line_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_text_fragment_to_line_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_text_fragment_to_line_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `user_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'The user account email is used as the unique identifier for the account.  Users authenticate with a correct email + password.',
  `pw` char(56) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'A hashed password',
  `forename` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The user''s forename, may be null.  Neither forename or surname are unique (separately or combined)',
  `surname` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The user''s surname, may be null.  Neither forename or surname are unique (separately or combined)',
  `organization` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The user''s current organization, may be null.',
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `settings` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_scroll_version_id` int(11) unsigned NOT NULL DEFAULT 1,
  `activated` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean for whether a user has authenticaed registration via the emailed token.',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `unique_user` (`email`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores the data of all registered users,\nCreated by Martin 17/03/03\n\nThe email is the unique identifier for each user (i.d., the username).';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_contributions`
--

DROP TABLE IF EXISTS `user_contributions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_contributions` (
  `contribution_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `contribution` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entry_time` datetime DEFAULT NULL,
  PRIMARY KEY (`contribution_id`),
  KEY `fk_user_contributions_to_user` (`user_id`),
  CONSTRAINT `fk_user_contributions_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Created by Martin 17/03/29';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_email_token`
--

DROP TABLE IF EXISTS `user_email_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_email_token` (
  `user_id` int(11) unsigned NOT NULL,
  `token` char(36) CHARACTER SET utf8mb4 NOT NULL COMMENT 'Unique token the user will provide to verify the requested action.',
  `type` enum('RESET_PASSWORD','ACTIVATE_ACCOUNT','DELETE_EDITION','EDITOR_INVITE') CHARACTER SET utf8mb4 NOT NULL DEFAULT 'RESET_PASSWORD' COMMENT 'The type of action permitted with the specified token.',
  `date_created` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Date the token was created or updated.  This is used by an event that clears out all entries from this table that are older than 2 days.',
  PRIMARY KEY (`token`),
  KEY `date_created_index` (`date_created`) USING BTREE,
  KEY `fk_user_email_token_to_user` (`user_id`),
  CONSTRAINT `fk_user_email_token_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table holds a list of unique tokens that are sent to the user in order to confirm certain operations in the database.  These tokens are intended to expire and a scheduled event in the database clears out all entries that are over 2 days old.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_system_roles`
--

DROP TABLE IF EXISTS `users_system_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_system_roles` (
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `system_roles_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`,`system_roles_id`),
  KEY `users_system_roles_to_system_roles_id` (`system_roles_id`),
  CONSTRAINT `users_system_roles_to_system_roles_id` FOREIGN KEY (`system_roles_id`) REFERENCES `system_roles` (`system_roles_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `users_system_roles_to_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table applies individual system roles to each user.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `work_status`
--

DROP TABLE IF EXISTS `work_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `work_status` (
  `work_status_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `work_status_message` varchar(255) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT 'A status message on the ccurrent state of work.',
  PRIMARY KEY (`work_status_id`),
  UNIQUE KEY `unique_status_message` (`work_status_message`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores user-definable work status messages that can be applied to various data tables. They are used to indicate the current status of editor curation for the data entry.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'SQE'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `clear_old_email_tokens` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8mb4 */ ;;
/*!50003 SET character_set_results = utf8mb4 */ ;;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`%`*/ /*!50106 EVENT `clear_old_email_tokens` ON SCHEDULE EVERY 1 HOUR STARTS '2019-05-21 16:05:40' ON COMPLETION NOT PRESERVE ENABLE DO DELETE FROM user_email_token 
WHERE user_id IN (
    SELECT user_id
    FROM user_email_token
    WHERE date_created < NOW() - interval 2 day
    ) */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'SQE'
--
/*!50003 DROP FUNCTION IF EXISTS `set_to_json_array` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `set_to_json_array`(my_set VARCHAR(250)) RETURNS varchar(250) CHARSET utf8
    DETERMINISTIC
BEGIN
	 IF my_set IS NOT NULL AND my_set NOT LIKE '' THEN
				RETURN CONCAT('["', REPLACE(my_set,',','","'), '"]');
				ELSE
				RETURN '[]';
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `SPLIT_STRING` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `SPLIT_STRING`(x VARCHAR(255), delim VARCHAR(12), pos INT) RETURNS varchar(255) CHARSET utf8
    DETERMINISTIC
    SQL SECURITY INVOKER
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '') ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_commentary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `add_commentary`()
BEGIN

    DECLARE v_finished INTEGER DEFAULT 0;
    DECLARE v_table VARCHAR(100) DEFAULT '';
    DECLARE stmt VARCHAR(500) DEFAULT '';

    DECLARE column_cursor CURSOR FOR
    SELECT TABLE_NAME FROM `information_schema`.`tables` WHERE table_schema = 'SQE' AND table_name LIKE '%_owner';

    DECLARE CONTINUE HANDLER
    FOR NOT FOUND SET v_finished = 1;

    OPEN column_cursor;

    alter_tables: LOOP

        FETCH column_cursor INTO v_table;

        IF v_finished = 1 THEN
        LEAVE alter_tables;
        END IF;

        SET @prepstmt = CONCAT('ALTER TABLE SQE','.',v_table,'  ADD COLUMN commentary LONGTEXT;');
  
		PREPARE stmt FROM @prepstmt;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END LOOP alter_tables;

    CLOSE column_cursor;


	END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `cursor_proc` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`SQE`@`localhost` PROCEDURE `cursor_proc`()
BEGIN
   DECLARE art_id INT UNSIGNED DEFAULT 0;
   
   DECLARE exit_loop BOOLEAN;         
   
   DECLARE artefact_cursor CURSOR FOR
     SELECT artefact_id FROM artefact;
   
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET exit_loop = TRUE;
   
   OPEN artefact_cursor;
   
   artefact_loop: LOOP
     
     FETCH  artefact_cursor INTO art_id;
     
     
     IF exit_loop THEN
         CLOSE artefact_cursor;
         LEAVE artefact_loop;
     END IF;
     INSERT IGNORE INTO artefact_owner (artefact_id, scroll_version_id) VALUES(art_id, 1);
   END LOOP artefact_loop;
 END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getCatalogAndEdition` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`SQE`@`localhost` PROCEDURE `getCatalogAndEdition`(param_plate VARCHAR(45), param_fragment VARCHAR(45), param_side TINYINT(1))
    DETERMINISTIC
    SQL SECURITY INVOKER
select image_catalog.image_catalog_id, edition_catalog.edition_catalog_id 
from image_catalog 
left join image_to_edition_catalog USING(image_catalog_id) 
left join edition_catalog USING(edition_catalog_id)
where image_catalog.catalog_number_1 = param_plate AND image_catalog.catalog_number_2 = param_fragment 
AND image_catalog.catalog_side = param_side ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getMasterImageListings` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`SQE`@`localhost` PROCEDURE `getMasterImageListings`()
    DETERMINISTIC
    SQL SECURITY INVOKER
select edition_catalog.composition, image_catalog.institution, image_catalog.catalog_number_1, image_catalog.catalog_number_2,  edition_catalog.edition_name, edition_catalog.edition_volume, edition_catalog.edition_location_1, edition_catalog.edition_location_2, SQE_image.sqe_image_id
from SQE_image 
left join image_catalog USING(image_catalog_id)
left join edition_catalog USING(edition_catalog_id)
where SQE_image.is_master=1 AND image_catalog.catalog_side=0 order by edition_catalog.composition ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getScrollArtefacts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getScrollArtefacts`(scroll_id VARCHAR(128), side TINYINT)
    DETERMINISTIC
    SQL SECURITY INVOKER
SELECT distinct artefact.artefact_id as id, ST_AsText(ST_Envelope(artefact.region_in_master_image)) as rect, ST_AsText(artefact.region_in_master_image) as poly, ST_AsText(artefact.position_in_scroll) as pos, image_urls.url as url, image_urls.suffix as suffix, SQE_image.filename as filename, SQE_image.dpi as dpi from artefact inner join SQE_image USING(sqe_image_id) inner join image_urls USING(image_urls_id) inner join image_to_edition_catalog USING(image_catalog_id) inner join edition_catalog_to_discrete_reference USING(edition_catalog_id) inner join discrete_canonical_reference USING(discrete_canonical_reference_id) inner join scroll USING(scroll_id) inner join edition_catalog USING(edition_catalog_id) where scroll.scroll_id=scroll_id and edition_catalog.edition_side=side ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getScrollDimensions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `getScrollDimensions`(scroll_id_num int unsigned, version_id int unsigned)
    DETERMINISTIC
select artefact_id,
MAX(JSON_EXTRACT(transform_matrix, '$.matrix[0][2]') + ((ST_X(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(region_in_sqe_image)), 2)) - ST_X(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(region_in_sqe_image)), 1))) * (1215 / SQE_image.dpi))) as max_x,
MAX(JSON_EXTRACT(transform_matrix, '$.matrix[1][2]') + ((ST_Y(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(region_in_sqe_image)), 3)) - ST_Y(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(region_in_sqe_image)), 1))) * (1215 / SQE_image.dpi))) as max_y from artefact_position join artefact_position_owner using(artefact_position_id) join artefact_shape using(artefact_id) join artefact_shape_owner using(artefact_shape_id) join SQE_image USING(sqe_image_id) join image_catalog using(image_catalog_id) where artefact_position.scroll_id=scroll_id_num and artefact_position_owner.scroll_version_id = version_id and artefact_shape_owner.scroll_version_id = version_id and image_catalog.catalog_side=0 ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getScrollHeight` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`bronson`@`localhost` PROCEDURE `getScrollHeight`(scroll_id_num int unsigned, version_id int unsigned)
    DETERMINISTIC
    SQL SECURITY INVOKER
select artefact_id, MAX(JSON_EXTRACT(transform_matrix, '$.matrix[1][2]') + ((ST_Y(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(region_in_sqe_image)), 3)) - ST_Y(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(region_in_sqe_image)), 1))) * (1215 / SQE_image.dpi))) as max_y from artefact_position join artefact_position_owner using(artefact_position_id) join artefact_shape using(artefact_id) join artefact_shape_owner using(artefact_shape_id) join SQE_image USING(sqe_image_id) join image_catalog using(image_catalog_id) where artefact_position.scroll_id=scroll_id_num and artefact_position_owner.scroll_version_id = version_id and artefact_shape_owner.scroll_version_id = version_id and image_catalog.catalog_side=0 ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getScrollVersionArtefacts` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`bronson`@`localhost` PROCEDURE `getScrollVersionArtefacts`(scroll_id_num int unsigned, version_id int unsigned)
    DETERMINISTIC
    SQL SECURITY INVOKER
SELECT distinct artefact.artefact_id as id, ST_AsText(ST_Envelope(artefact.region_in_master_image)) as rect, ST_AsText(artefact.region_in_master_image) as poly, ST_AsText(artefact.position_in_scroll) as pos, image_urls.url as url, image_urls.suffix as suffix, SQE_image.filename as filename, SQE_image.dpi as dpi, artefact.rotation as rotation from artefact_owner join artefact using(artefact_id) join scroll_version using(scroll_version_id) inner join SQE_image USING(sqe_image_id) inner join image_urls USING(image_urls_id) inner join image_catalog using(image_catalog_id) where artefact.scroll_id=scroll_id_num and artefact_owner.scroll_version_id = version_id and image_catalog.catalog_side=0 ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getScrollWidth` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`bronson`@`localhost` PROCEDURE `getScrollWidth`(scroll_id_num int unsigned, version_id int unsigned)
    DETERMINISTIC
    SQL SECURITY INVOKER
select artefact_id, MAX(JSON_EXTRACT(transform_matrix, '$.matrix[0][2]') + ((ST_X(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(region_in_sqe_image)), 2)) - ST_X(ST_PointN(ST_ExteriorRing(ST_ENVELOPE(region_in_sqe_image)), 1))) * (1215 / SQE_image.dpi))) as max_x from artefact_position join artefact_position_owner using(artefact_position_id) join artefact_shape using(artefact_id) join artefact_shape_owner using(artefact_shape_id) join SQE_image USING(sqe_image_id) join image_catalog using(image_catalog_id) where artefact_position.scroll_id=scroll_id_num and artefact_position_owner.scroll_version_id = version_id and artefact_shape_owner.scroll_version_id = version_id and image_catalog.catalog_side=0 ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_fragment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_fragment`(
								IN scroll_id INTEGER,
								INOUT column_name VARCHAR(45),
								OUT column_count INTEGER,
								OUT column_id INTEGER,
								INOUT full_output LONGTEXT
							)
    DETERMINISTIC
BEGIN
	
	SET column_name = CONCAT('^', column_name, '( [iv]+)?$');
	SELECT  
		column_of_scroll.column_of_scroll_id, 
		column_of_scroll.name,
		count(column_of_scroll.column_of_scroll_id)
	INTO column_id, column_name, column_count
	FROM column_of_scroll
	WHERE column_of_scroll.scroll_id=scroll_id
	AND column_of_scroll.name REGEXP column_name;
	
	IF column_count = 0 THEN
		SET full_output = '{"ERROR_CODE":5, "ERROR_TEXT":"Fragment not found"}';
	END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_fragment_text` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_fragment_text`(
						IN scroll_name VARCHAR(45),
						IN column_name VARCHAR(45)
					)
get_fragment_text:BEGIN
	DECLARE next_id_var		INTEGER;
	DECLARE break_type_var	INTEGER;
	DECLARE full_output		LONGTEXT;
	DECLARE line_output		TEXT;
	DECLARE scroll_id		INTEGER;
	DECLARE column_count	INTEGER;
	DECLARE column_id	INTEGER;
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE old_column INTEGER DEFAULT 0;
	DECLARE new_column INTEGER DEFAULT 0;

	DECLARE my_cursor CURSOR FOR 
		SELECT 
			CONCAT( '{"LINE":"', line_of_column_of_scroll.name, 
				'","LINE_ID":', line_of_column_of_scroll.line_id, 
				',"SIGNS":['),
			position_in_stream.next_sign_id, column_of_scroll_id, column_of_scroll.name
		FROM column_of_scroll
		JOIN line_of_column_of_scroll ON line_of_column_of_scroll.column_id=column_of_scroll.column_of_scroll_id
		JOIN real_area ON real_area.line_of_scroll_id = line_of_column_of_scroll.line_id
		JOIN sign ON sign.real_areas_id=real_area.real_area_id
		JOIN position_in_stream ON position_in_stream.sign_id=sign.sign_id
		WHERE column_of_scroll.column_of_scroll_id in (
				SELECT  column_of_scroll.column_of_scroll_id
				FROM column_of_scroll
				WHERE column_of_scroll.scroll_id=scroll_id
				AND column_of_scroll.name REGEXP column_name
			)
		AND (sign.sign_id is null OR FIND_IN_SET('LINE_START', sign.break_type))
		ORDER BY ST_X(ST_CENTROID(real_area.area_in_scroll)), ST_Y(ST_CENTROID(real_area.area_in_scroll)) ;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
		
	CALL get_scroll(scroll_name, scroll_id, full_output);
	
	IF full_output IS NOT NULL THEN
		SELECT full_output;
		LEAVE get_fragment_text;		
	END IF;
	
	CALL get_fragment(scroll_id, column_name,column_count, column_id, full_output);

	IF full_output IS NOT NULL THEN
		SELECT full_output;
		LEAVE get_fragment_text;		
	END IF;
	
	SET full_output = CONCAT('{"SCROLL":"' , scroll_name, 
					'","SCROLL_ID":', scroll_id,
					',"FRAGMENTS":[');	
					
	SET line_output = '';	
	OPEN my_cursor;
	
	get_lines: LOOP	
		FETCH my_cursor into  line_output, next_id_var, new_column, column_name;
		
		IF finished = 1 THEN
			LEAVE get_lines;
		END IF;
		
		IF new_column != old_column THEN
			SET full_output = concat(
				full_output,
				'{"FRAGMENT":"', column_name,
				'","FRAGMENT_ID":', new_column,
				',"LINES":['
				);
			SET old_column=new_column;
		END IF;

		SET full_output = concat(full_output,line_output);
		CALL get_sign_json(next_id_var, full_output);
		SET full_output = concat(full_output, ']},');
	END LOOP get_lines;

	SET full_output = CONCAT(SUBSTRING(full_output, 1, CHAR_LENGTH(full_output)-1),']}]}');
	SELECT full_output;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_line_text` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_line_text`(
						IN scroll_name VARCHAR(45),
						IN column_name VARCHAR(45),
						IN line_name   VARCHAR(45)
					)
get_line_text:BEGIN
	DECLARE next_id_var		INTEGER;
	DECLARE break_type_var	INTEGER;
	DECLARE full_output		TEXT;
	DECLARE scroll_id		INTEGER;
	DECLARE column_count		INTEGER;
	DECLARE column_id	INTEGER;
	
	CALL get_scroll(scroll_name, scroll_id, full_output);
	
	IF full_output IS NOT NULL THEN
		SELECT full_output;
		LEAVE get_line_text;		
	END IF;
	
	call get_fragment(scroll_id, column_name,column_count, column_id, full_output);

	IF full_output IS NOT NULL THEN
		SELECT full_output;
		LEAVE get_line_text;		
	END IF;
	
	IF  column_count>1 THEN
		SELECT '{"ERROR_CODE":6, "ERROR_TEXT":"No unique fragment"}';
		LEAVE get_line_text;		
	END IF;
		
	SELECT 	CONCAT(',"LINES":[{"LINE":\"', line_of_column_of_scroll.name, 
					'","LINE_ID":', line_of_column_of_scroll.line_id, 
					',"SIGNS":['),		
			position_in_stream.next_sign_id
		INTO full_output, next_id_var
		FROM line_of_column_of_scroll
		JOIN real_area ON real_area.line_of_scroll_id = line_of_column_of_scroll.line_id
		JOIN sign ON sign.real_areas_id=real_area.real_area_id
		JOIN position_in_stream ON position_in_stream.sign_id=sign.sign_id
		WHERE line_of_column_of_scroll.column_id = column_id
		AND line_of_column_of_scroll.name like line_name
		AND (sign.sign_id is null OR FIND_IN_SET('LINE_START', sign.break_type));
	
	SET full_output=CONCAT('{"SCROLL":"' , scroll_name, 
					'","SCROLL_ID":', scroll_id, 
					',"FRAGMENTS":[{',
					'"FRAGMENT":"', column_name,
					'","FRAGMENT_ID":', column_id, full_output);
	
	CALL get_sign_json(next_id_var, full_output);
		
	SELECT CONCAT(full_output, ']}]}]}');

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_line_text_html` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_line_text_html`(
						IN scroll_name VARCHAR(45),
						IN column_name VARCHAR(45),
						IN line_name   VARCHAR(45)
					)
get_line_text:BEGIN
	DECLARE next_id_var		INTEGER;
	DECLARE break_type_var	INTEGER;
	DECLARE full_output		TEXT;
	DECLARE scroll_id		INTEGER;
	DECLARE column_count		INTEGER;
	DECLARE column_id	INTEGER;
	
	CALL get_scroll(scroll_name, scroll_id, full_output);
	
	IF full_output IS NOT NULL THEN
		SELECT full_output;
		LEAVE get_line_text;		
	END IF;
	
	call get_fragment(scroll_id, column_name,column_count, column_id, full_output);

	IF full_output IS NOT NULL THEN
		SELECT full_output;
		LEAVE get_line_text;		
	END IF;
	
	IF  column_count>1 THEN
		SELECT '{"ERROR_CODE":6, "ERROR_TEXT":"No unique fragment"}';
		LEAVE get_line_text;		
	END IF;
		
	SELECT 	CONCAT('<span class="QWB_LINE" data-line-i="', line_of_column_of_scroll.line_id, 
					'">', line_of_column_of_scroll.name, '</span>\n'),		
			position_in_stream.next_sign_id
		INTO full_output, next_id_var
		FROM line_of_column_of_scroll
		JOIN real_area ON real_area.line_of_scroll_id = line_of_column_of_scroll.line_id
		JOIN sign ON sign.real_areas_id=real_area.real_area_id
		JOIN position_in_stream ON position_in_stream.sign_id=sign.sign_id
		WHERE line_of_column_of_scroll.column_id = column_id
		AND line_of_column_of_scroll.name like line_name
		AND (sign.sign_id is null OR FIND_IN_SET('LINE_START', sign.break_type));
	
	SET full_output=CONCAT('<div class="QWB_LINE">\n<span class="QWB_SCROLL" data-scroll-id="' , scroll_id, 
					'">', scroll_name, 
					'</span>\n<span class="QWB_FRAGMENT" data-fragment-id="', column_id,
					'">', column_name, '</span>\n', full_output);
	
	CALL get_sign_html(next_id_var, full_output);
		
	SELECT CONCAT(full_output, ']}]}]}');

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_scroll` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_scroll`(
								INOUT scroll_name	VARCHAR(50),
								OUT scroll_id INTEGER,
								INOUT full_output LONGTEXT
								)
    DETERMINISTIC
BEGIN
	SELECT `scroll`.scroll_id
	INTO scroll_id
	FROM `scroll`
	WHERE `scroll`.name like scroll_name;
	
	IF scroll_id IS NULL THEN
		SET full_output = '{"ERROR_CODE":4, "ERROR_TEXT":"Scroll not found"}';
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_sign_json` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_sign_json`(
						IN 		next_id_var INTEGER	,
						INOUT full_output LONGTEXT
						)
BEGIN
	SET @output_text ='';
	SET @is_last = 0;
	SET @next_id_var=next_id_var;
	
	PREPARE stm FROM 
		"SELECT 
			IF(sign.sign_type_id=9, @output_text,
			CONCAT_WS('',@output_text,
					'{\"SIGN_ID\":',sign.sign_id,', ',
					'\"SIGN\":\"',if(sign.sign like '',' ', sign.sign),'\", ', 
					'\"SIGN_TYPE\":\"', sign_type.type,'\", ',
					'\"SIGN_WIDTH\":', sign.width ,', ',
					'\"MIGHT_BE_WIDER\":', if(might_be_wider, 'true', 'false') ,', ',
					'\"READABILITY\":\"', sign.readability,'\", ',
					'\"IS_RECONSTRUCTED\":',if(is_reconstructed, 'true', 'false') ,', ',
					'\"IS_RETRACED\":',if(is_retraced, 'true', 'false') ,', ',
					'\"CORRECTION\":', set_to_json_array(sign.correction) ,', ',
					'\"RELATIVE_POSITION\":[', (select 
							CONCAT('\"',GROUP_CONCAT(sign_relative_position.`type` ORDER BY LEVEL ASC SEPARATOR '\",\"'),
								 '\"')
							FROM sign_relative_position
							WHERE sign_relative_position.sign_relative_position_id=sign.sign_id), 
					']},')), 
			position_in_stream.next_sign_id,
			IFNULL(FIND_IN_SET('LINE_END',sign.break_type),0)
			INTO  @output_text, @next_id_var, @is_last	
			FROM sign
			JOIN position_in_stream ON position_in_stream.sign_id=sign.sign_id
			JOIN sign_type ON sign_type.sign_type_id=sign.sign_type_id
			WHERE sign.sign_id=?";
			
	WHILE @is_last = 0   DO
		EXECUTE stm USING @next_id_var;
	END WHILE;
	DEALLOCATE PREPARE stm;
	SET full_output = concat(full_output, SUBSTRING(@output_text, 1, CHAR_LENGTH(@output_text)-1));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `nyewe2w234556` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `nyewe2w234556`(
						IN 		next_id_var INTEGER	,
						INOUT full_output LONGTEXT
						)
BEGIN
	SET @output_text ='';
	SET @is_last = 0;
	SET @next_id_var=next_id_var;
	
	PREPARE stm FROM 
		"SELECT 
			IF(sign.sign_type_id=9, @output_text,
			CONCAT_WS('',@output_text,
					'<span class=QWB_SIGN',
					IF(FIND_IN_SET('OVERWRITTEN', sign.correction)>0, ' QWB_OVERWRITTEN', ''),
					IF(FIND_IN_SET('ERASED', sign.correction)>0, ' QWB_ERASED', ''),
					IF(sign.is_reconstructed=1, ' QWB_RECONSTRUCTED', ''),
					IF(sign.is_reconstructed=1, ' QWB_RECONSTRUCTED', ''),
					



sign.sign_id,', ',
					'\"SIGN\":\"',if(sign.sign like '',' ', sign.sign),'\", ', 
					'\"SIGN_TYPE\":\"', sign_type.type,'\", ',
					'\"SIGN_WIDTH\":', sign.width ,', ',
					'\"MIGHT_BE_WIDER\":', if(might_be_wider, 'true', 'false') ,', ',
					'\"READABILITY\":\"', sign.readability,'\", ',
					'\"IS_RECONSTRUCTED\":',if(is_reconstructed, 'true', 'false') ,', ',
					'\"IS_RETRACED\":',if(is_retraced, 'true', 'false') ,', ',
					'\"CORRECTION\":', set_to_json_array(sign.correction) ,', ',
					'\"RELATIVE_POSITION\":[', (select 
							CONCAT('\"',GROUP_CONCAT(sign_relative_position.`type` ORDER BY LEVEL ASC SEPARATOR '\",\"'),
								 '\"')
							FROM sign_relative_position
							WHERE sign_relative_position.sign_relative_position_id=sign.sign_id), 
					']},')), 
			position_in_stream.next_sign_id,
			IFNULL(FIND_IN_SET('LINE_END',sign.break_type),0)
			INTO  @output_text, @next_id_var, @is_last	
			FROM sign
			JOIN position_in_stream ON position_in_stream.sign_id=sign.sign_id
			JOIN sign_type ON sign_type.sign_type_id=sign.sign_type_id
			WHERE sign.sign_id=?";
			
	WHILE @is_last = 0   DO
		EXECUTE stm USING @next_id_var;
	END WHILE;
	DEALLOCATE PREPARE stm;
	SET full_output = concat(full_output, SUBSTRING(@output_text, 1, CHAR_LENGTH(@output_text)-1));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `image_text_fragment_match_catalogue`
--

/*!50001 DROP TABLE IF EXISTS `image_text_fragment_match_catalogue`*/;
/*!50001 DROP VIEW IF EXISTS `image_text_fragment_match_catalogue`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `image_text_fragment_match_catalogue` AS select `image_catalog`.`image_catalog_id` AS `image_catalog_id`,`image_catalog`.`institution` AS `institution`,`image_catalog`.`catalog_number_1` AS `catalog_number_1`,`image_catalog`.`catalog_number_2` AS `catalog_number_2`,`image_catalog`.`catalog_side` AS `catalog_side`,`image_catalog`.`object_id` AS `object_id`,`image_urls`.`image_urls_id` AS `image_urls_id`,`image_urls`.`url` AS `url`,`image_urls`.`proxy` AS `proxy`,`image_urls`.`suffix` AS `suffix`,`image_urls`.`license` AS `license`,`SQE_image`.`filename` AS `filename`,`iaa_edition_catalog`.`iaa_edition_catalog_id` AS `iaa_edition_catalog_id`,`iaa_edition_catalog`.`manuscript_id` AS `manuscript_id`,`iaa_edition_catalog`.`edition_name` AS `edition_name`,`iaa_edition_catalog`.`edition_volume` AS `edition_volume`,`iaa_edition_catalog`.`edition_location_1` AS `edition_location_1`,`iaa_edition_catalog`.`edition_location_2` AS `edition_location_2`,`iaa_edition_catalog`.`edition_side` AS `edition_side`,`iaa_edition_catalog`.`comment` AS `comment`,`iaa_edition_catalog_to_text_fragment`.`iaa_edition_catalog_to_text_fragment_id` AS `iaa_edition_catalog_to_text_fragment_id`,`iaa_edition_catalog_to_text_fragment`.`text_fragment_id` AS `text_fragment_id`,`text_fragment_data`.`name` AS `name`,`manuscript_data`.`name` AS `manuscript_name`,`edition`.`edition_id` AS `edition_id` from ((((((((((`image_catalog` join `SQE_image` on(`image_catalog`.`image_catalog_id` = `SQE_image`.`image_catalog_id`)) join `image_urls` on(`SQE_image`.`image_urls_id` = `image_urls`.`image_urls_id`)) join `image_to_iaa_edition_catalog` on(`image_catalog`.`image_catalog_id` = `image_to_iaa_edition_catalog`.`image_catalog_id`)) join `iaa_edition_catalog` on(`image_to_iaa_edition_catalog`.`iaa_edition_catalog_id` = `iaa_edition_catalog`.`iaa_edition_catalog_id`)) join `iaa_edition_catalog_to_text_fragment` on(`image_to_iaa_edition_catalog`.`iaa_edition_catalog_id` = `iaa_edition_catalog_to_text_fragment`.`iaa_edition_catalog_id`)) join `text_fragment_data` on(`iaa_edition_catalog_to_text_fragment`.`text_fragment_id` = `text_fragment_data`.`text_fragment_id`)) join `text_fragment_data_owner` on(`text_fragment_data`.`text_fragment_data_id` = `text_fragment_data_owner`.`text_fragment_data_id`)) join `manuscript_data` on(`iaa_edition_catalog`.`manuscript_id` = `manuscript_data`.`manuscript_id`)) join `manuscript_data_owner` on(`manuscript_data`.`manuscript_data_id` = `manuscript_data_owner`.`manuscript_data_id`)) join `edition` on(`edition`.`edition_id` = `text_fragment_data_owner`.`edition_id` and `edition`.`edition_id` = `manuscript_data_owner`.`edition_id`)) where `edition`.`public` = 1 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `recent_edition_catalog_to_col_confirmation`
--

/*!50001 DROP TABLE IF EXISTS `recent_edition_catalog_to_col_confirmation`*/;
/*!50001 DROP VIEW IF EXISTS `recent_edition_catalog_to_col_confirmation`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `recent_edition_catalog_to_col_confirmation` AS select `iaa_edition_catalog_to_text_fragment_confirmation`.`iaa_edition_catalog_to_text_fragment_id` AS `iaa_edition_catalog_to_text_fragment_id`,`iaa_edition_catalog_to_text_fragment_confirmation`.`confirmed` AS `confirmed`,`iaa_edition_catalog_to_text_fragment_confirmation`.`user_id` AS `user_id`,max(`iaa_edition_catalog_to_text_fragment_confirmation`.`time`) AS `MAX(``time``)` from `iaa_edition_catalog_to_text_fragment_confirmation` group by `iaa_edition_catalog_to_text_fragment_confirmation`.`iaa_edition_catalog_to_text_fragment_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
