-- MySQL dump 10.17  Distrib 10.3.15-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: SQE
-- ------------------------------------------------------
-- Server version	10.3.15-MariaDB-1:10.3.15+maria~bionic

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
  `filename` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Actual filename of the image as specified on the iiif server.',
  `native_width` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'We store internally the pixel width of the full size image.',
  `native_height` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'We store internally the pixel height of the full size image.',
  `dpi` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'The DPI of the full size image (used to calculate relative scaling of images).',
  `type` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Two values:\nColor = 0\nGrayscale = 1\nPerhaps remove in favor of “wavelength_start" and “wavelength_end”.',
  `wavelength_start` smallint(5) unsigned NOT NULL DEFAULT 445 COMMENT 'Starting wavelength of image in nanometers.',
  `wavelength_end` smallint(5) unsigned NOT NULL DEFAULT 704 COMMENT 'Ending wavelength of image in nanometers.',
  `is_master` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Boolean determining if the image is a “master image”.  Since we have multiple images of each fragment, one image is designated as the master (generally the full color image), all others are non master images and will have a corresponding entry in “image_to_image_map” which provides and transforms (translate, scale, rotate) necessary to line the two images up with each other.',
  `image_catalog_id` int(11) unsigned DEFAULT 0,
  `is_recto` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT 'Notes wether the original image is thought to show rect (1) or verso (0) of the fragment. This can be taken as default value for recto/verso-relation in artefact_stack',
  PRIMARY KEY (`sqe_image_id`),
  UNIQUE KEY `url_UNIQUE` (`image_urls_id`,`filename`) USING BTREE,
  KEY `fk_image_to_catalog` (`image_catalog_id`),
  CONSTRAINT `fk_image_to_catalog` FOREIGN KEY (`image_catalog_id`) REFERENCES `image_catalog` (`image_catalog_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_image_to_url` FOREIGN KEY (`image_urls_id`) REFERENCES `image_urls` (`image_urls_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=127474 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table defines an image.  It contains referencing data to access the image via iiif servers, it also stores metadata relating to the image itself, such as sizing, resolution, image color range, etc.  It also maintains a link to the institutional referencing system, and the referencing of the editio princeps (as provided by the imaging institution).';
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
-- Table structure for table `area_group`
--

DROP TABLE IF EXISTS `area_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `area_group` (
  `area_group_id` int(10) unsigned NOT NULL,
  `area_id` int(10) unsigned NOT NULL,
  `move_direction` set('x','y') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commentary` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `z_index` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`area_group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `area_group_member`
--

DROP TABLE IF EXISTS `area_group_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `area_group_member` (
  `area_group_id` int(10) unsigned NOT NULL,
  `area_id` int(11) NOT NULL,
  `area_type` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`area_group_id`,`area_id`),
  CONSTRAINT `fk_group_member_to_group` FOREIGN KEY (`area_group_id`) REFERENCES `area_group` (`area_group_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `area_group_owner`
--

DROP TABLE IF EXISTS `area_group_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `area_group_owner` (
  `area_group_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`area_group_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`area_group_id`,`edition_id`),
  KEY `fk_area_group_owner_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_area_group_to_edition` (`edition_id`),
  CONSTRAINT `fk_area_group_owner_to_area_group` FOREIGN KEY (`area_group_id`) REFERENCES `area_group` (`area_group_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_area_group_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_area_group_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
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
) ENGINE=InnoDB AUTO_INCREMENT=12927 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Every scroll combination is made up from artefacts.  The artefact is a polygon region of an image which the editor deems to constitute a coherent piece of material (different editors may come to different conclusions on what makes up an artefact).  This may correspond to what the editors of an editio princeps have designated a “fragment”, but often may not, since the columns and fragments in those publications are often made up of joins of various types.  Joined fragments should not, as a rule, be defined as a single artefact with the SQE system.  Rather, each component of a join should be a separate artefact, and those artefacts can then be positioned properly with each other via the artefact_position table.';
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
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`artefact_data_id`),
  UNIQUE KEY `unique_artefact_id_artefact_data_name` (`artefact_id`,`name`) USING BTREE,
  KEY `fk_artefact_data_to_artefact` (`artefact_id`),
  CONSTRAINT `fk_artefact_data_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=12927 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  PRIMARY KEY (`artefact_data_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`artefact_data_id`,`edition_id`),
  KEY `fk_artefact_data_owner_to_scroll_version_id` (`edition_editor_id`),
  KEY `fk_artefact_data_to_edition` (`edition_id`),
  CONSTRAINT `fk_artefact_data_owner_to_artefact_data_id` FOREIGN KEY (`artefact_data_id`) REFERENCES `artefact_data` (`artefact_data_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_data_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_artefact_data_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_position`
--

DROP TABLE IF EXISTS `artefact_position`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_position` (
  `artefact_position_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_id` int(10) unsigned NOT NULL,
  `transform_matrix` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '{"matrix":[[1,0,0],[0,1,0]]}' COMMENT 'Transform matrix to position the artefact on the “virtual scroll”',
  `z_index` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'This value can move artefacts up or down in relation to other artefacts in the scroll.  That is, it sends an artefact further into the foreground or background.',
  PRIMARY KEY (`artefact_position_id`),
  UNIQUE KEY `unique_artefact_transform_z_index` (`artefact_id`,`z_index`,`transform_matrix`) USING BTREE,
  KEY `fk_artefact_position_to_artefact` (`artefact_id`),
  CONSTRAINT `fk_artefact_position_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=7632 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table defines the location and rotation of an artefact within the scroll.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `SQE`.`after_artefact_position_insert` AFTER INSERT ON `SQE`.`artefact_position` FOR EACH ROW 
BEGIN
INSERT INTO artefact_positioned_shape (artefact_position_id, artefact_shape_id, positioned_shape)
SELECT NEW.artefact_position_id, artefact_shape_id, GEOMFROMTEXT(affine_transform(
    NEW.transform_matrix, 
    ASTEXT(ENVELOPE(region_in_sqe_image))
  ))
FROM artefact_shape
WHERE artefact_shape.artefact_id = NEW.artefact_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
  PRIMARY KEY (`artefact_position_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`artefact_position_id`,`edition_id`),
  KEY `fk_artefact_position_owner_to_scroll_version` (`edition_editor_id`),
  KEY `fk_artefact_position_to_edition` (`edition_id`),
  CONSTRAINT `fk_artefact_position_owner_to_artefact` FOREIGN KEY (`artefact_position_id`) REFERENCES `artefact_position` (`artefact_position_id`),
  CONSTRAINT `fk_artefact_position_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_artefact_position_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7632 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_positioned_shape`
--

DROP TABLE IF EXISTS `artefact_positioned_shape`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_positioned_shape` (
  `artefact_shape_id` int(11) unsigned NOT NULL DEFAULT 0,
  `artefact_position_id` int(11) unsigned NOT NULL DEFAULT 0,
  `positioned_shape` polygon DEFAULT st_geometryfromtext(''),
  PRIMARY KEY (`artefact_shape_id`,`artefact_position_id`),
  KEY `fk_artefact_positioned_shape_to_artefact_position_id` (`artefact_position_id`),
  CONSTRAINT `fk_artefact_positioned_shape_to_artefact_position_id` FOREIGN KEY (`artefact_position_id`) REFERENCES `artefact_position` (`artefact_position_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_positioned_shape_to_artefact_shape_id` FOREIGN KEY (`artefact_shape_id`) REFERENCES `artefact_shape` (`artefact_shape_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This is an experimental table. It does not seem realistic to transform the artefact shape using the artefact position transform matrix in real time.  This table is caches the transformed polygons in order to use MariaDB’s GIS functionality without significant delays.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `artefact_shape`
--

DROP TABLE IF EXISTS `artefact_shape`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `artefact_shape` (
  `artefact_shape_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `artefact_id` int(11) unsigned NOT NULL DEFAULT 0,
  `sqe_image_id` int(10) unsigned DEFAULT NULL COMMENT 'This points to the master image (see SQE_image table) in which this artefact is found.',
  `region_in_sqe_image` polygon NOT NULL COMMENT 'This is the exact polygon of the artefact’s location within the master image’s coordinate system.',
  `region_in_sqe_image_hash` binary(128) GENERATED ALWAYS AS (sha2(`region_in_sqe_image`,512)) STORED,
  PRIMARY KEY (`artefact_shape_id`) USING BTREE,
  UNIQUE KEY `unique_artefact_shape` (`artefact_id`,`sqe_image_id`,`region_in_sqe_image_hash`) USING BTREE,
  KEY `fk_artefact_shape_to_sqe_image_idx` (`sqe_image_id`) USING BTREE,
  KEY `fk_artefact_shape_to_artefact` (`artefact_id`) USING BTREE,
  CONSTRAINT `fk_artefact_shape_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_shape_to_sqe_image` FOREIGN KEY (`sqe_image_id`) REFERENCES `SQE_image` (`sqe_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=12927 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Every scroll combination is made up from artefacts.  The artefact is a polygon region of an image which the editor deems to constitute a coherent piece of material (different editors may come to different conclusions on what makes up an artefact).  This may correspond to what the editors of an editio princeps have designated a “fragment”, but often may not, since the columns and fragments in those publications are often made up of joins of various types.  Joined fragments should not, as a rule, be defined as a single artefact with the SQE system.  Rather, each component of a join should be a separate artefact, and those artefacts can then be positioned properly with each other via the artefact_position table.';
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `SQE`.`after_artefact_shape_insert` AFTER INSERT ON `SQE`.`artefact_shape` FOR EACH ROW 
BEGIN
INSERT INTO artefact_positioned_shape (artefact_position_id, artefact_shape_id, positioned_shape)
SELECT artefact_position_id, NEW.artefact_shape_id, GEOMFROMTEXT(affine_transform(
    transform_matrix, 
    ASTEXT(ENVELOPE(NEW.region_in_sqe_image))
  ))
FROM artefact_position
WHERE artefact_position.artefact_id = NEW.artefact_id;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

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
  PRIMARY KEY (`artefact_shape_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`artefact_shape_id`,`edition_id`),
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
  `artefact_A_id` int(10) unsigned NOT NULL,
  `artefact_B_id` int(10) unsigned NOT NULL,
  `artefact_B_offset` point DEFAULT NULL COMMENT 'Gives the offset by which the artefact B must be moved to match the artefact A',
  `layer_A` tinyint(3) unsigned NOT NULL DEFAULT 1 COMMENT 'Gives the number of the layer in the stack to which artefact A belongs. If ',
  `layer_B` tinyint(3) unsigned NOT NULL DEFAULT 1 COMMENT 'Gives the number of the layer in the stack to which artefact B belongs.',
  `A_is_verso` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `B_is_verso` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `reason` enum('RECTO_VERSO','FOUND_IN_A_STACK','PART_OF_A_WAD','RECONSTRUCTED_STACK') COLLATE utf8mb4_unicode_ci DEFAULT 'RECTO_VERSO',
  `shared` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'True if the given region of artefact_B represents a region which appears on the surface of artefact_A (bleeding through, ink glued to the next layer).',
  PRIMARY KEY (`artefact_stack_id`),
  UNIQUE KEY `unique_artefact_stack` (`A_is_verso`,`artefact_A_id`,`artefact_B_id`,`artefact_B_offset`(25),`B_is_verso`,`layer_A`,`layer_B`,`reason`,`shared`) USING BTREE,
  KEY `fk_af_stack_A_to_artefact_idx` (`artefact_A_id`),
  KEY `fk_af_stack_B_to_artefact_idx` (`artefact_B_id`),
  CONSTRAINT `fk_af_stack_A_to_artefact` FOREIGN KEY (`artefact_A_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_af_stack_B_to_artefact` FOREIGN KEY (`artefact_B_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4756 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores the relationship between artefacts which make up a stack, meaning, that the represent parallel layers in a stack. This could be:\na) Artefact A is and B represent recto/verso of one layer, than the layer_A and layer_B must be the same\nb) A and B represent parts of different layers of a already decomposed stack (reason= ‚found in a stack‘) or as part of wad (reason = ‚part of a wad‘) or as thought by the scholar to belong in the same perimeter of the scroll (reason=‚reconstructed‘).\n\nThe tables allow to create a sequence of artefacts: A = recto of layer 1 -> B = verso of layer 1 -> C = recto of recto of layer  2 -> D = verso of layer 2 … (where -> represents a record with the left as artefact_A and the right term as artefact_B)\n\nA special case is marked by shared. We could, e.g., have A as verso and B as recto and additionally a subregion of B as shared to A.';
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
  PRIMARY KEY (`artefact_stack_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`artefact_stack_id`,`edition_id`),
  KEY `fk_artefact_data_owner_to_scroll_version_id` (`edition_editor_id`),
  KEY `fk_artefact_stack_owner_to_artefact_stack_idx` (`artefact_stack_id`),
  KEY `fk_artefact_stack_to_edition` (`edition_id`),
  CONSTRAINT `fk_artefact_stack_owner_to_artefact_stack` FOREIGN KEY (`artefact_stack_id`) REFERENCES `artefact_stack` (`artefact_stack_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_artefact_stack_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_artefact_stack_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute`
--

DROP TABLE IF EXISTS `attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute` (
  `attribute_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('BOOLEAN','NUMBER','STRING') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`attribute_id`),
  UNIQUE KEY `unique_name_type` (`name`,`type`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute_numeric`
--

DROP TABLE IF EXISTS `attribute_numeric`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute_numeric` (
  `sign_char_attribute_id` int(10) unsigned NOT NULL,
  `value` float NOT NULL DEFAULT 0,
  PRIMARY KEY (`sign_char_attribute_id`,`value`),
  KEY `value` (`value`),
  CONSTRAINT `fk_attr_num_to_sign_char_attr` FOREIGN KEY (`sign_char_attribute_id`) REFERENCES `sign_char_attribute` (`sign_char_attribute_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  PRIMARY KEY (`attribute_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`attribute_id`,`edition_id`),
  KEY `fk_attribute_to_scroll_version` (`edition_editor_id`),
  KEY `fk_attribute_to_edition` (`edition_id`),
  CONSTRAINT `fk_attribute_owner_to_attribute` FOREIGN KEY (`attribute_id`) REFERENCES `attribute` (`attribute_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_attribute_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_attribute_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute_value`
--

DROP TABLE IF EXISTS `attribute_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute_value` (
  `attribute_value_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `attribute_id` int(10) unsigned NOT NULL,
  `string_value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`attribute_value_id`),
  UNIQUE KEY `unique_attribute_and_value` (`attribute_id`,`string_value`) USING BTREE,
  KEY `fk_att_val_to_att_idx` (`attribute_id`),
  CONSTRAINT `fk_att_val_to_att` FOREIGN KEY (`attribute_id`) REFERENCES `attribute` (`attribute_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `attribute_value_css`
--

DROP TABLE IF EXISTS `attribute_value_css`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attribute_value_css` (
  `attribute_value_css_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `attribute_value_id` int(10) unsigned NOT NULL DEFAULT 0,
  `css` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`attribute_value_css_id`),
  UNIQUE KEY `unique_attribute_value_css` (`attribute_value_id`,`css`) USING BTREE,
  KEY `fk_attribute_value_css_to_attribute_value` (`attribute_value_id`),
  CONSTRAINT `fk_attribute_value_css_to_attribute_value` FOREIGN KEY (`attribute_value_id`) REFERENCES `attribute_value` (`attribute_value_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  PRIMARY KEY (`attribute_value_css_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`attribute_value_css_id`,`edition_id`),
  KEY `fk_attribute_value_css_owner_to_scroll_version` (`edition_editor_id`),
  KEY `fk_attribute_value_css_to_edition` (`edition_id`),
  CONSTRAINT `fk_attribute_value_css_owner_to_attribute_value_css` FOREIGN KEY (`attribute_value_css_id`) REFERENCES `attribute_value_css` (`attribute_value_css_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_attribute_value_css_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_attribute_value_css_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
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
  PRIMARY KEY (`attribute_value_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`attribute_value_id`,`edition_id`),
  KEY `fk_attribute_value_to_scroll_version` (`edition_editor_id`),
  KEY `fk_attribute_value_to_edition` (`edition_id`),
  CONSTRAINT `fk_attribute_value_owner_to_attribute_value` FOREIGN KEY (`attribute_value_id`) REFERENCES `attribute_value` (`attribute_value_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_attribute_value_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_attribute_value_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `char_of_writing`
--

DROP TABLE IF EXISTS `char_of_writing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `char_of_writing` (
  `char_of_writing_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `form_of_writing_id` int(11) unsigned NOT NULL DEFAULT 0,
  `unicode_char` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `line_offset` smallint(6) NOT NULL DEFAULT 0,
  `commentary` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`char_of_writing_id`,`form_of_writing_id`),
  UNIQUE KEY `form_char` (`form_of_writing_id`,`unicode_char`),
  KEY `form_of_writing` (`form_of_writing_id`),
  KEY `char` (`unicode_char`),
  CONSTRAINT `fk_to_form_of_writing` FOREIGN KEY (`form_of_writing_id`) REFERENCES `form_of_writing` (`form_of_writing_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores info about the characters of a particular scribal hand.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `char_of_writing_owner`
--

DROP TABLE IF EXISTS `char_of_writing_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `char_of_writing_owner` (
  `char_of_writing_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`char_of_writing_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`char_of_writing_id`,`edition_id`),
  KEY `cow_owner_to_scrollversion_idx` (`edition_editor_id`),
  KEY `fk_char_of_writing_to_edition` (`edition_id`),
  CONSTRAINT `cow_owner_to_cow` FOREIGN KEY (`char_of_writing_id`) REFERENCES `char_of_writing` (`char_of_writing_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_char_of_writing_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_char_of_writing_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col`
--

DROP TABLE IF EXISTS `col`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `col` (
  `col_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`col_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_data`
--

DROP TABLE IF EXISTS `col_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `col_data` (
  `col_data_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `col_id` int(10) unsigned NOT NULL,
  `name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name designation for this fragment of text (usually col. x or frg. x).',
  PRIMARY KEY (`col_data_id`),
  UNIQUE KEY `unique_col_id_col_name` (`col_id`,`name`) USING BTREE,
  KEY `fk_col_data_to_col_idx` (`col_id`),
  CONSTRAINT `fk_col_data_to_col` FOREIGN KEY (`col_id`) REFERENCES `col` (`col_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table defines the properties of a column of text within a scroll.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_data_owner`
--

DROP TABLE IF EXISTS `col_data_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `col_data_owner` (
  `col_data_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`col_data_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`col_data_id`,`edition_id`),
  KEY `fk_col_data_owner_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_col_data_to_edition` (`edition_id`),
  CONSTRAINT `fk_col_data_owner_to_col_data` FOREIGN KEY (`col_data_id`) REFERENCES `col_data` (`col_data_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_col_data_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_col_data_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_sequence`
--

DROP TABLE IF EXISTS `col_sequence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `col_sequence` (
  `col_sequence_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `col_id` int(10) unsigned NOT NULL,
  `position` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`col_sequence_id`),
  UNIQUE KEY `unique_col_id_position` (`col_id`,`position`) USING BTREE,
  KEY `fk_cs_to_col_idx` (`col_id`),
  CONSTRAINT `fk_cs_to_col` FOREIGN KEY (`col_id`) REFERENCES `col` (`col_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_sequence_owner`
--

DROP TABLE IF EXISTS `col_sequence_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `col_sequence_owner` (
  `col_sequence_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`col_sequence_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`col_sequence_id`,`edition_id`),
  KEY `fk_cso_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_col_sequence_to_edition` (`edition_id`),
  CONSTRAINT `fk_col_sequence_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_col_sequence_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`),
  CONSTRAINT `ft_cs_owner_tocs` FOREIGN KEY (`col_sequence_id`) REFERENCES `col_sequence` (`col_sequence_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_to_line`
--

DROP TABLE IF EXISTS `col_to_line`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `col_to_line` (
  `col_to_line_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `col_id` int(10) unsigned NOT NULL,
  `line_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`col_to_line_id`),
  UNIQUE KEY `col_line_idx` (`col_id`,`line_id`),
  KEY `fk_col_to_line_to_line_idx` (`line_id`),
  CONSTRAINT `fk_col_to_line_to_col` FOREIGN KEY (`col_id`) REFERENCES `col` (`col_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_col_to_line_to_line` FOREIGN KEY (`line_id`) REFERENCES `line` (`line_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=54448 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table links lines of a scroll to a specific column.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `col_to_line_owner`
--

DROP TABLE IF EXISTS `col_to_line_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `col_to_line_owner` (
  `col_to_line_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`col_to_line_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`col_to_line_id`,`edition_id`),
  KEY `fk_col_to_linew_owner_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_col_to_line_to_edition` (`edition_id`),
  CONSTRAINT `fk_col_to_line_owner_to_col_to_line` FOREIGN KEY (`col_to_line_id`) REFERENCES `col_to_line` (`col_to_line_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_col_to_line_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_col_to_line_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `edition`
--

DROP TABLE IF EXISTS `edition`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `edition` (
  `edition_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `scroll_id` int(10) unsigned NOT NULL,
  `locked` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `copyright_holder` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'This is the person or institution who holds copyright for the edition.',
  `collaborators` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Each edition may have a set list of collaborators.  If NULL, then the API will automatically construct a list of collaborators based on the edition_editors.',
  PRIMARY KEY (`edition_id`),
  KEY `fk_edition_to_scroll` (`scroll_id`),
  CONSTRAINT `fk_edition_to_scroll` FOREIGN KEY (`scroll_id`) REFERENCES `scroll` (`scroll_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1646 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table provides a unique group id for scrollversions and the possibilty to lock all members of the group';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `edition_editor`
--

DROP TABLE IF EXISTS `edition_editor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `edition_editor` (
  `edition_editor_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'This is the version that will be found in all the x_to_owner tables .for this particular version of a scroll.',
  `may_write` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `may_lock` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `may_read` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `is_admin` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`edition_editor_id`),
  UNIQUE KEY `edition_user_idx` (`edition_id`,`user_id`),
  KEY `fk_edition_editor_to_user` (`user_id`),
  CONSTRAINT `fk_edition_editor_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_edition_editor_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1646 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table defines unique versions of a reconstructed scroll.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `external_font`
--

DROP TABLE IF EXISTS `external_font`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_font` (
  `external_font_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `font_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`external_font_id`),
  UNIQUE KEY `font_id_idx` (`font_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `external_font_glyph`
--

DROP TABLE IF EXISTS `external_font_glyph`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `external_font_glyph` (
  `external_font_glyph_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `external_font_id` int(10) unsigned NOT NULL,
  `unicode_char` varbinary(4) NOT NULL,
  `path` multipolygon DEFAULT NULL,
  `width` smallint(6) unsigned DEFAULT NULL,
  `height` smallint(5) unsigned DEFAULT NULL,
  PRIMARY KEY (`external_font_glyph_id`) USING BTREE,
  UNIQUE KEY `char_idx` (`unicode_char`) USING BTREE,
  KEY `fk_efg_to_external_font_idx` (`external_font_id`) USING BTREE,
  CONSTRAINT `fk_efg_to_external_font` FOREIGN KEY (`external_font_id`) REFERENCES `external_font` (`external_font_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2371 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_of_writing`
--

DROP TABLE IF EXISTS `form_of_writing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_of_writing` (
  `form_of_writing_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `scribes_scribe_id` int(10) unsigned NOT NULL,
  `pen` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `ink` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `scribal_font_type_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`form_of_writing_id`),
  KEY `fk_form_to_scribe_idx` (`scribes_scribe_id`),
  KEY `fk_form_to_char_style_idx` (`scribal_font_type_id`),
  CONSTRAINT `fk_form_to_char_style` FOREIGN KEY (`scribal_font_type_id`) REFERENCES `scribal_font_type` (`scribal_font_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_form_to_scribe` FOREIGN KEY (`scribes_scribe_id`) REFERENCES `scribe` (`scribe_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Defines the actual scribe of of sign. As actual scribe the scribe as person using at the very moment a special „font“ caused by the mood the scribe is in (conecentrated, sloppy, fast and furious) and the used equipment. Thus even change of quills or the status of a quill (fresh filled, new, old) could be distinguished. ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `form_of_writing_owner`
--

DROP TABLE IF EXISTS `form_of_writing_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_of_writing_owner` (
  `form_of_writing_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`form_of_writing_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`form_of_writing_id`,`edition_id`),
  KEY `fk_form_of_writing_to_scrollversion_idx` (`edition_editor_id`),
  KEY `fk_form_of_writing_to_edition` (`edition_id`),
  CONSTRAINT `fk_form_of_writing_owner_to_scribe` FOREIGN KEY (`form_of_writing_id`) REFERENCES `form_of_writing` (`form_of_writing_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_form_of_writing_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_form_of_writing_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
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
  `manuscript` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Standard designation of the manuscript.',
  `edition_name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name of the publication in which the editio princeps appears.',
  `edition_volume` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Volume of the publication in which the editio princeps appears.',
  `edition_location_1` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'First tier identifier (usually a page number).',
  `edition_location_2` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Second tier identifier (usually a fragment/column designation).',
  `edition_side` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Side designation in editio princeps.',
  `scroll_id` int(11) unsigned DEFAULT NULL,
  `comment` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`iaa_edition_catalog_id`),
  UNIQUE KEY `unique_edition_entry` (`edition_location_1`,`edition_location_2`,`edition_name`,`edition_side`,`edition_volume`,`manuscript`) USING BTREE,
  KEY `fk_edition_catalog_to_scroll_id` (`scroll_id`),
  CONSTRAINT `fk_edition_catalog_to_scroll_id` FOREIGN KEY (`scroll_id`) REFERENCES `scroll` (`scroll_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=40039 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table contains the IAA data for the editio princeps reference for all of their images.';
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
-- Table structure for table `iaa_edition_catalog_to_col`
--

DROP TABLE IF EXISTS `iaa_edition_catalog_to_col`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iaa_edition_catalog_to_col` (
  `iaa_edition_catalog_to_col_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `iaa_edition_catalog_id` int(11) unsigned NOT NULL,
  `col_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`iaa_edition_catalog_to_col_id`),
  UNIQUE KEY `unique_edition_catalog_id_col_id` (`col_id`,`iaa_edition_catalog_id`) USING BTREE,
  KEY `fk_edition_catalog_to_col_to_edition_catalog_id` (`iaa_edition_catalog_id`),
  CONSTRAINT `fk_edition_catalog_to_col_to_col_id` FOREIGN KEY (`col_id`) REFERENCES `col` (`col_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_edition_catalog_to_col_to_edition_catalog_id` FOREIGN KEY (`iaa_edition_catalog_id`) REFERENCES `iaa_edition_catalog` (`iaa_edition_catalog_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=15543 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This is a temporary table to curate matches between the image catalog system and the SQE scroll system.  It should eventually be deprecated in favor of matches inferred by spatial overlap on the virtual scroll of a the placement of a ROI linked to text transcription and an artefact linked to an image.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `iaa_edition_catalog_to_col_confirmation`
--

DROP TABLE IF EXISTS `iaa_edition_catalog_to_col_confirmation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `iaa_edition_catalog_to_col_confirmation` (
  `iaa_edition_catalog_to_col_id` int(11) unsigned NOT NULL DEFAULT 0,
  `confirmed` tinyint(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean for whether the match has been confirmed (1) or rejected (0).  If this is set to 0 and the user_id is NULL, then the match has neither been confirmed nor rejected (thus it should be queued for review).',
  `user_id` int(11) unsigned DEFAULT NULL COMMENT 'user_id of the person who has confirmed or rejected the match.  If NULL, the match has neither been confirmed nor rejected.',
  `time` datetime NOT NULL DEFAULT current_timestamp(),
  UNIQUE KEY `unique_edition_catalog_to_col_confirmation` (`iaa_edition_catalog_to_col_id`,`confirmed`,`user_id`,`time`) USING BTREE,
  KEY `fk_iaa_edition_catalog_to_col_confirmation_to_user` (`user_id`),
  CONSTRAINT `fk_edition_Catalog_to_col_confirmation_to_edition_catalog_to_col` FOREIGN KEY (`iaa_edition_catalog_to_col_id`) REFERENCES `iaa_edition_catalog_to_col` (`iaa_edition_catalog_to_col_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_iaa_edition_catalog_to_col_confirmation_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table is part of the temporary and preliminary catalog info matching system.  There are three possibilities here: 1. confirmed = 0 and user_id IS NULL (the match has neither been confirmed nor rejected); 2. confirmed = 0 and user_id IS NOT NULL (the user with user_id has rejected the match); 3. confirmed = 1 and user_id IS NOT NULL (the user with user_id has confirmed the match as valid).  The pairing confirmed = 1 and user_id IS NOT NULL is an invalid combination.';
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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `prevent_impossible_insert_to_edition_catalog_to_col_confirmation` BEFORE INSERT ON `iaa_edition_catalog_to_col_confirmation` FOR EACH ROW BEGIN

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
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `prevent_impossible_update_to_edition_catalog_to_col_confirmation` BEFORE UPDATE ON `iaa_edition_catalog_to_col_confirmation` FOR EACH ROW BEGIN

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
  `institution` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name of the institution providing the images.',
  `catalog_number_1` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'First tier object identifier',
  `catalog_number_2` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Second tier object identifier (if available)',
  `catalog_side` tinyint(1) unsigned DEFAULT 0 COMMENT 'Side reference designation.',
  `object_id` varchar(255) GENERATED ALWAYS AS (concat(`institution`,'-',`catalog_number_1`,'-',`catalog_number_2`)) STORED,
  PRIMARY KEY (`image_catalog_id`),
  UNIQUE KEY `unique_catalog_entry` (`catalog_number_1`,`catalog_number_2`,`catalog_side`,`institution`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=43479 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='The referencing system of the institution providing the images.';
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
  `image1_id` int(10) unsigned NOT NULL DEFAULT 0,
  `image2_id` int(10) unsigned NOT NULL DEFAULT 0,
  `region_on_image1` polygon NOT NULL COMMENT 'Region on image 1 that can be found in image 2.',
  `region_on_image2` polygon NOT NULL COMMENT 'Region in image 2 that can be found in image 1.',
  `transform_matrix` varchar(254) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '{"matrix":[[1,0,0],[0,1,0]]}' COMMENT 'Linear transform to apply to image 2 in order to align it with image 1.',
  `region1_hash` binary(128) GENERATED ALWAYS AS (sha2(`region_on_image1`,512)) STORED,
  `region2_hash` binary(128) GENERATED ALWAYS AS (sha2(`region_on_image2`,512)) STORED,
  PRIMARY KEY (`image_to_image_map_id`),
  UNIQUE KEY `unique_image_to_image_map` (`image1_id`,`image2_id`,`region1_hash`,`region2_hash`,`transform_matrix`) USING BTREE,
  KEY `fk_image1_to_image_id` (`image1_id`),
  KEY `fk_image2_to_image_id` (`image2_id`),
  CONSTRAINT `fk_image1_to_image_id` FOREIGN KEY (`image1_id`) REFERENCES `SQE_image` (`sqe_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_image2_to_image_id` FOREIGN KEY (`image2_id`) REFERENCES `SQE_image` (`sqe_image_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=71728 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table contains the mapping information to correlate images of the same object.';
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `image_urls`
--

DROP TABLE IF EXISTS `image_urls`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `image_urls` (
  `image_urls_id` int(11) unsigned NOT NULL DEFAULT 0,
  `url` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'URL prefix of the iiif server.',
  `suffix` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Special suffux for file name (if applicable).  Usually default.jpg.',
  `proxy` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Specify a proxy address if it is necessary to use a proxy for CORS compliance.',
  `license` text COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'License for this iiif servers resources.',
  PRIMARY KEY (`image_urls_id`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='URL’s for the iiif image servers providing our images.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `kerning_of_char`
--

DROP TABLE IF EXISTS `kerning_of_char`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kerning_of_char` (
  `kerning` smallint(6) NOT NULL DEFAULT 0 COMMENT 'Kerning in mm',
  `previous_char` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
  `chars_of_writing_char_of_writing_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`chars_of_writing_char_of_writing_id`,`previous_char`),
  CONSTRAINT `fk_to_chars_of_writing` FOREIGN KEY (`chars_of_writing_char_of_writing_id`) REFERENCES `char_of_writing` (`char_of_writing_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Describes character to character kerning relationships.';
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
) ENGINE=InnoDB AUTO_INCREMENT=54448 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  `name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name designation for this line.',
  PRIMARY KEY (`line_data_id`),
  UNIQUE KEY `unique_line_id_name` (`line_id`,`name`) USING BTREE,
  KEY `fk_line_data_to_line_idx` (`line_id`),
  CONSTRAINT `fk_line_data_to_line` FOREIGN KEY (`line_id`) REFERENCES `line` (`line_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=54448 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Data pertaining to the description of a line of transcribed text.';
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
  PRIMARY KEY (`line_data_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`line_data_id`,`edition_id`),
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
  PRIMARY KEY (`line_to_sign_id`),
  UNIQUE KEY `line_sign_idx` (`sign_id`,`line_id`) USING BTREE,
  KEY `fk_line_to_sign_to_line_idx` (`line_id`),
  CONSTRAINT `fk_line_to_sign_to_line` FOREIGN KEY (`line_id`) REFERENCES `line` (`line_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_line_to_sign_to_sign` FOREIGN KEY (`sign_id`) REFERENCES `sign` (`sign_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1733925 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Linking of signs to a line.';
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
  PRIMARY KEY (`line_to_sign_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`line_to_sign_id`,`edition_id`),
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
  `time` datetime(6) DEFAULT current_timestamp(6) COMMENT 'The time that the execution was performed.',
  `rewinded` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean relaying whether the particular action has been rewound or not.',
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`main_action_id`),
  UNIQUE KEY `all_idx` (`main_action_id`,`edition_id`,`edition_editor_id`),
  KEY `main_action_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_main_action_to_edition` (`edition_id`),
  CONSTRAINT `fk_main_action_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_main_action_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Table for an undo system.  This table stores the state of the action (rewound or not), the date of the change, and the version of the scroll that the action is associated with.  The table single_action links to the entries here and describe the table in which the action occurred, the id of the entry in that table that was involved, and the nature of the action (creating a connection between that entry and the scroll version of the main_action, or deleting the connection between that entry and the scroll version of the main_action).';
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
  PRIMARY KEY (`parallel_word_id`),
  UNIQUE KEY `unique_word_id_parallel_group_id_sup_group` (`parallel_group_id`,`sub_group`,`word_id`) USING BTREE,
  KEY `fk_par_word_to_group_idx` (`parallel_group_id`),
  KEY `fk_par_owrd_to_word_idx` (`word_id`),
  CONSTRAINT `fk_par_owrd_to_word` FOREIGN KEY (`word_id`) REFERENCES `word` (`word_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_par_word_to_group` FOREIGN KEY (`parallel_group_id`) REFERENCES `parallel_group` (`parallel_group_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
  PRIMARY KEY (`parallel_word_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`parallel_word_id`,`edition_id`),
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
  `point_on_image1` point NOT NULL COMMENT 'Single POINT coordinate on first image.',
  `point_on_image2` point NOT NULL COMMENT 'Corresponding single POINT coordinate on second image.',
  PRIMARY KEY (`point_to_point_map_id`),
  KEY `fK_p_to_p_toIm_to_im_idx` (`image_to_image_map_id`),
  CONSTRAINT `fK_p_to_p_toIm_to_im` FOREIGN KEY (`image_to_image_map_id`) REFERENCES `image_to_image_map` (`image_to_image_map_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `position_in_stream`
--

DROP TABLE IF EXISTS `position_in_stream`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `position_in_stream` (
  `position_in_stream_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Uinique identifiere',
  `sign_id` int(11) unsigned NOT NULL COMMENT 'References a sign',
  `next_sign_id` int(11) unsigned NOT NULL DEFAULT 0 COMMENT 'Links to another sign in order to create a linked list.',
  PRIMARY KEY (`position_in_stream_id`),
  UNIQUE KEY `sign_next` (`sign_id`,`next_sign_id`),
  KEY `position_in_stream_next_sign_id_IDX` (`sign_id`),
  KEY `fk_next_to_sign` (`next_sign_id`),
  CONSTRAINT `fk_next_to_sign` FOREIGN KEY (`next_sign_id`) REFERENCES `sign` (`sign_id`),
  CONSTRAINT `fk_to_sign` FOREIGN KEY (`sign_id`) REFERENCES `sign` (`sign_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1733729 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Put signs in one-dimensional stream (≈ text)\nThe reason for this table is, that the manuscripts may contain parallel text-streams created by corrections. Sometimes also scholars put superlinear signs at different places. Thus, this is a discrete layer of interpretation between signs and words.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `position_in_stream_owner`
--

DROP TABLE IF EXISTS `position_in_stream_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `position_in_stream_owner` (
  `position_in_stream_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`position_in_stream_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`position_in_stream_id`,`edition_id`),
  KEY `fk_position_in_stream_onwer_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_position_in_stream_to_edition` (`edition_id`),
  CONSTRAINT `fk_position_in_stream_owner_to_position_in_stream` FOREIGN KEY (`position_in_stream_id`) REFERENCES `position_in_stream` (`position_in_stream_id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `fk_position_in_stream_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_position_in_stream_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `position_in_stream_to_word_rel`
--

DROP TABLE IF EXISTS `position_in_stream_to_word_rel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `position_in_stream_to_word_rel` (
  `position_in_stream_id` int(10) unsigned NOT NULL COMMENT 'References a sign in a stream',
  `word_id` int(10) unsigned NOT NULL DEFAULT 0,
  `position_in_word` tinyint(3) unsigned DEFAULT NULL,
  PRIMARY KEY (`position_in_stream_id`,`word_id`),
  KEY `fk_sign_stream_has_words_sign_stream1_idx` (`position_in_stream_id`),
  KEY `fk_rel_to_word_idx` (`word_id`),
  CONSTRAINT `fk_rel_position_in_stream` FOREIGN KEY (`position_in_stream_id`) REFERENCES `position_in_stream` (`position_in_stream_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_rel_to_word` FOREIGN KEY (`word_id`) REFERENCES `word` (`word_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Links individual signs to words, which are then linked to data in the QWB database.';
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
  `ref_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `book_position` smallint(5) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`qwb_ref_id`),
  UNIQUE KEY `ref_text` (`ref_text`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qwb_variant`
--

DROP TABLE IF EXISTS `qwb_variant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qwb_variant` (
  `qwb_variant_id` int(10) unsigned NOT NULL,
  `qwd_word_data_id` int(10) unsigned NOT NULL,
  `text` varchar(83) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lemma` varchar(35) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `grammar` varchar(33) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meaning` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('variant','missing','addition') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commentary` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qwb_biblio_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`qwb_variant_id`),
  KEY `fk_qwb_var_to_qwb_data_idx` (`qwd_word_data_id`),
  KEY `fk_qwb_var_to_qwb_biblio_idx` (`qwb_biblio_id`),
  CONSTRAINT `fk_qwb_var_to_qwb_biblio` FOREIGN KEY (`qwb_biblio_id`) REFERENCES `qwb_biblio` (`qwb_biblio_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_qwb_var_to_qwb_data` FOREIGN KEY (`qwd_word_data_id`) REFERENCES `qwb_word_data` (`qwb_word_data_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qwb_variant_owner`
--

DROP TABLE IF EXISTS `qwb_variant_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qwb_variant_owner` (
  `qwb_variant_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`qwb_variant_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`qwb_variant_id`,`edition_id`),
  KEY `fk_qwb_var_owner_to_sc_idx` (`edition_editor_id`),
  KEY `fk_qwb_variant_to_edition` (`edition_id`),
  CONSTRAINT `fk_qwb_var_owner_to_var` FOREIGN KEY (`qwb_variant_id`) REFERENCES `qwb_variant` (`qwb_variant_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_qwb_variant_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_qwb_variant_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qwb_word_data`
--

DROP TABLE IF EXISTS `qwb_word_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qwb_word_data` (
  `qwb_word_data_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `qwb_word_id` int(10) unsigned NOT NULL,
  `text` varchar(33) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `qwb_ref_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`qwb_word_data_id`),
  KEY `fk_qwb_word_data_to_ref_idx` (`qwb_ref_id`),
  CONSTRAINT `fk_qwb_word_data_to_ref` FOREIGN KEY (`qwb_ref_id`) REFERENCES `qwb_ref` (`qwb_ref_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `qwb_word_data_owner`
--

DROP TABLE IF EXISTS `qwb_word_data_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `qwb_word_data_owner` (
  `qwb_word_data_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`qwb_word_data_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`qwb_word_data_id`,`edition_id`),
  KEY `fk_qwb_data_owner_to_sc_idx` (`edition_editor_id`),
  KEY `fk_qwb_word_data_to_edition` (`edition_id`),
  CONSTRAINT `fk_qwb_data_owner_to_data` FOREIGN KEY (`qwb_word_data_id`) REFERENCES `qwb_word_data` (`qwb_word_data_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_qwb_word_data_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_qwb_word_data_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `recent_edition_catalog_to_col_confirmation`
--

DROP TABLE IF EXISTS `recent_edition_catalog_to_col_confirmation`;
/*!50001 DROP VIEW IF EXISTS `recent_edition_catalog_to_col_confirmation`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `recent_edition_catalog_to_col_confirmation` (
  `iaa_edition_catalog_to_col_id` tinyint NOT NULL,
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
  `transform_matrix` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Transform details for placement of ROI.  This transform is carried out in the coordinate system of the linked artefact.  To get the location of the ROI in the coordinate system of the “virtual scroll”, one must multiply the transform_matrix of the attached artefact with the transform matrix of the ROI. This can by done with the UDF multiply_matrix(), which should have the ROI’s transform_matrix first and the artefact’s transform_matrix second.',
  `artefact_id` int(11) unsigned NOT NULL COMMENT 'ROI’s are linked to artefacts.  Each edition has an artefact that serves as the “virtual scroll” that is positioned at 0,0 and has a size of maxWidth and maxHeight, this artefact is used for reconstructed text.',
  PRIMARY KEY (`roi_position_id`),
  KEY `fk_roi_position_to_artefact` (`artefact_id`),
  CONSTRAINT `fk_roi_position_to_artefact` FOREIGN KEY (`artefact_id`) REFERENCES `artefact` (`artefact_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ROI’s are linked to artefacts.  Each edition has an artefact that serves as the “virtual scroll” that is positioned at 0,0 and has a size of maxWidth and maxHeight, this artefact is used for reconstructed text. The ROI transform_matrix is carried out in the coordinate system of the linked artefact, not the abstract “virtual scroll”.  To get the location of the ROI in the coordinate system of the “virtual scroll”, one must multiply the transform_matrix of the attached artefact with the transform matrix of the ROI. This can by done with the UDF multiply_matrix(), which should have the ROI’s transform_matrix first and the artefact’s transform_matrix second.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roi_shape`
--

DROP TABLE IF EXISTS `roi_shape`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roi_shape` (
  `roi_shape_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `path` polygon DEFAULT NULL,
  PRIMARY KEY (`roi_shape_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribal_font_type`
--

DROP TABLE IF EXISTS `scribal_font_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scribal_font_type` (
  `scribal_font_type_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Provides metadata for „Fonts“ used by scribes .\n\nToDo: Define the ontology (fromal …) which should be used',
  `font_name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`scribal_font_type_id`),
  UNIQUE KEY `style_name_idx` (`font_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scribal_font_type_owner`
--

DROP TABLE IF EXISTS `scribal_font_type_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scribal_font_type_owner` (
  `scribal_font_type_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`scribal_font_type_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`scribal_font_type_id`,`edition_id`),
  KEY `fk_font_owner_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_scribal_font_type_to_edition` (`edition_id`),
  CONSTRAINT `fk_font_owner_to_font` FOREIGN KEY (`scribal_font_type_id`) REFERENCES `scribal_font_type` (`scribal_font_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
  `description` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `commetary` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`scribe_id`)
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
  PRIMARY KEY (`scribe_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`scribe_id`,`edition_id`),
  KEY `fk_scribe_owner_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_scribe_to_edition` (`edition_id`),
  CONSTRAINT `fk_scribe_owner_to_scribe` FOREIGN KEY (`scribe_id`) REFERENCES `scribe` (`scribe_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_scribe_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_scribe_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scroll`
--

DROP TABLE IF EXISTS `scroll`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scroll` (
  `scroll_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`scroll_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1694 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scroll_data`
--

DROP TABLE IF EXISTS `scroll_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scroll_data` (
  `scroll_data_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `scroll_id` int(10) unsigned NOT NULL,
  `name` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Name designation of the scroll.',
  PRIMARY KEY (`scroll_data_id`),
  UNIQUE KEY `unique_scroll_id_name` (`scroll_id`,`name`) USING BTREE,
  KEY `fk_scroll_to_master_scroll_idx` (`scroll_id`),
  CONSTRAINT `fk_scroll_to_master_scroll` FOREIGN KEY (`scroll_id`) REFERENCES `scroll` (`scroll_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1372 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Description of a reconstructed scroll or combination.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scroll_data_owner`
--

DROP TABLE IF EXISTS `scroll_data_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scroll_data_owner` (
  `scroll_data_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`scroll_data_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`scroll_data_id`,`edition_id`),
  KEY `fk_scroll_owner_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_scroll_data_to_edition` (`edition_id`),
  CONSTRAINT `fk_scroll_data_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_scroll_data_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`),
  CONSTRAINT `fk_scroll_owner_to_scroll_data` FOREIGN KEY (`scroll_data_id`) REFERENCES `scroll_data` (`scroll_data_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scroll_to_col`
--

DROP TABLE IF EXISTS `scroll_to_col`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scroll_to_col` (
  `scroll_to_col_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `scroll_id` int(10) unsigned NOT NULL,
  `col_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`scroll_to_col_id`),
  UNIQUE KEY `scroll_col_idx` (`scroll_id`,`col_id`),
  KEY `fk_scroll_to_column_to_column_idx` (`col_id`),
  CONSTRAINT `fk_scroll_to_column_to_column` FOREIGN KEY (`col_id`) REFERENCES `col` (`col_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_scroll_to_column_to_scroll` FOREIGN KEY (`scroll_id`) REFERENCES `scroll` (`scroll_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11177 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Links an entry in the col table to a reconstructed scroll.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scroll_to_col_owner`
--

DROP TABLE IF EXISTS `scroll_to_col_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scroll_to_col_owner` (
  `scroll_to_col_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`scroll_to_col_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`scroll_to_col_id`,`edition_id`),
  KEY `fk_stco_toscroll_version_idx` (`edition_editor_id`),
  KEY `fk_scroll_to_col_to_edition` (`edition_id`),
  CONSTRAINT `fk_scroll_to_col_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_scroll_to_col_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`),
  CONSTRAINT `fk_stco_to_scroll_to_column` FOREIGN KEY (`scroll_to_col_id`) REFERENCES `scroll_to_col` (`scroll_to_col_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
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
) ENGINE=InnoDB AUTO_INCREMENT=1733943 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_char`
--

DROP TABLE IF EXISTS `sign_char`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_char` (
  `sign_char_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sign_id` int(10) unsigned NOT NULL,
  `is_variant` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean set to true when current entry is a variant interpretation of a sign.',
  `sign` char(1) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`sign_char_id`),
  UNIQUE KEY `unique_sign_id_is_variant_sign` (`is_variant`,`sign`,`sign_id`) USING BTREE,
  KEY `fk_sign_char_to_sign_idx` (`sign_id`),
  CONSTRAINT `fk_sign_char_to_sign` FOREIGN KEY (`sign_id`) REFERENCES `sign` (`sign_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1733925 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table describes signs on a manuscript.  Currently this includes both characters and spaces, it could perhaps also include other elements that one might want to define as a sign.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_char_attribute`
--

DROP TABLE IF EXISTS `sign_char_attribute`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_char_attribute` (
  `sign_char_attribute_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sign_char_id` int(10) unsigned NOT NULL,
  `attribute_value_id` int(10) unsigned NOT NULL,
  `sequence` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'Absolute ordering of this record.  This is used to define the order of all records for the same sign_char_id.',
  PRIMARY KEY (`sign_char_attribute_id`),
  UNIQUE KEY `unique_sign_char_id_attribute_value_id_sequence` (`attribute_value_id`,`sequence`,`sign_char_id`) USING BTREE,
  KEY `fk_sign_char_attr_to_sign_char_idx` (`sign_char_id`),
  KEY `fk_sign_char_attr_to_attr_value_idx` (`attribute_value_id`),
  CONSTRAINT `fk_sign_char_attr_to_attr_value` FOREIGN KEY (`attribute_value_id`) REFERENCES `attribute_value` (`attribute_value_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_char_attr_to_sign_char` FOREIGN KEY (`sign_char_id`) REFERENCES `sign_char` (`sign_char_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4970052 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_char_attribute_owner`
--

DROP TABLE IF EXISTS `sign_char_attribute_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_char_attribute_owner` (
  `sign_char_attribute_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`sign_char_attribute_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`sign_char_attribute_id`,`edition_id`),
  KEY `fk_sign_attr_owenr_to_sv_idx` (`edition_editor_id`),
  KEY `fk_sign_char_attribute_to_edition` (`edition_id`),
  CONSTRAINT `fk_sign_char_attr_owner_to_sca` FOREIGN KEY (`sign_char_attribute_id`) REFERENCES `sign_char_attribute` (`sign_char_attribute_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_char_attribute_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_sign_char_attribute_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_char_commentary`
--

DROP TABLE IF EXISTS `sign_char_commentary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_char_commentary` (
  `sign_char_commentary_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sign_char_id` int(10) unsigned NOT NULL,
  `attribute_id` int(10) unsigned DEFAULT NULL,
  `commentary` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`sign_char_commentary_id`),
  KEY `fk_scc_to_attribute_idx` (`attribute_id`),
  KEY `sign_char_id` (`sign_char_id`),
  CONSTRAINT `fk_scc_to_attribute` FOREIGN KEY (`attribute_id`) REFERENCES `attribute` (`attribute_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_scc_to_sign_char` FOREIGN KEY (`sign_char_id`) REFERENCES `sign_char` (`sign_char_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_char_commentary_owner`
--

DROP TABLE IF EXISTS `sign_char_commentary_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_char_commentary_owner` (
  `sign_char_commentary_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`sign_char_commentary_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`sign_char_commentary_id`,`edition_id`),
  KEY `fk_scc_owner_to_scrollversion_idx` (`edition_editor_id`),
  KEY `fk_sign_char_commentary_to_edition` (`edition_id`),
  CONSTRAINT `fk_scc_onwer_to_scc` FOREIGN KEY (`sign_char_commentary_id`) REFERENCES `sign_char_commentary` (`sign_char_commentary_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_char_commentary_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_sign_char_commentary_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_char_roi`
--

DROP TABLE IF EXISTS `sign_char_roi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_char_roi` (
  `sign_char_roi_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sign_char_id` int(10) unsigned NOT NULL,
  `roi_shape_id` int(10) unsigned NOT NULL,
  `roi_position_id` int(10) unsigned NOT NULL,
  `values_set` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `exceptional` tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`sign_char_roi_id`),
  UNIQUE KEY `char_shape_position` (`sign_char_id`,`roi_shape_id`,`roi_position_id`),
  KEY `fk_sign_area_to_sign_char_idx` (`sign_char_id`),
  KEY `fk_sign_area_to_area_idx` (`roi_shape_id`),
  KEY `fk_sign_area_to_area_position_idx` (`roi_position_id`),
  CONSTRAINT `fk_sign_area_to_roi_position` FOREIGN KEY (`roi_position_id`) REFERENCES `roi_position` (`roi_position_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_area_to_roi_shape` FOREIGN KEY (`roi_shape_id`) REFERENCES `roi_shape` (`roi_shape_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_sign_roi_to_sign_char` FOREIGN KEY (`sign_char_id`) REFERENCES `sign_char` (`sign_char_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sign_char_roi_owner`
--

DROP TABLE IF EXISTS `sign_char_roi_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sign_char_roi_owner` (
  `sign_char_roi_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`sign_char_roi_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`sign_char_roi_id`,`edition_id`),
  KEY `fk_sign_area_owner_to_sv_idx` (`edition_editor_id`),
  KEY `fk_sign_char_roi_to_edition` (`edition_id`),
  CONSTRAINT `fk_sign_area_owner_to_sign_area` FOREIGN KEY (`sign_char_roi_id`) REFERENCES `sign_char_roi` (`sign_char_roi_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sign_char_roi_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_sign_char_roi_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `single_action`
--

DROP TABLE IF EXISTS `single_action`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `single_action` (
  `single_action_id` bigint(19) unsigned NOT NULL AUTO_INCREMENT,
  `main_action_id` int(10) unsigned NOT NULL,
  `action` enum('add','delete') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The nature of the action applied.  A link to an edition was either added or deleted.',
  `table` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT 'NULL' COMMENT 'Table containing the entry that was either added to or deleted from the edition.',
  `id_in_table` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Id of the record that was added to or deleted from the edition (of the linked main_action) in the “table”_to_owner table.',
  PRIMARY KEY (`single_action_id`),
  KEY `fk_single_action_to_main_idx` (`main_action_id`),
  CONSTRAINT `fk_single_action_to_main` FOREIGN KEY (`main_action_id`) REFERENCES `main_action` (`main_action_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sqe_session`
--

DROP TABLE IF EXISTS `sqe_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sqe_session` (
  `sqe_session_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `scroll_version_id` int(10) unsigned NOT NULL,
  `session_start` timestamp(6) NOT NULL DEFAULT current_timestamp(6),
  `last_internal_session_end` timestamp(6) NULL DEFAULT NULL,
  `attributes` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`sqe_session_id`),
  KEY `fk_sqe_sesseio_to_user_idx` (`user_id`),
  CONSTRAINT `fk_sqe_session_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
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
  `email` varchar(126) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'The user account email is used as the unique identifier for the account.  Users authenticate with a correct email + password.',
  `pw` char(56) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'A hashed password',
  `forename` varchar(62) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The user''s forename, may be null.  Neither forename or surname are unique (separately or combined)',
  `surname` varchar(62) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The user''s surname, may be null.  Neither forename or surname are unique (separately or combined)',
  `organization` varchar(62) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'The user''s current organization, may be null.',
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `settings` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_scroll_version_id` int(11) unsigned NOT NULL DEFAULT 1,
  `activated` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT 'Boolean for whether a user has authenticaed registration via the emailed token.',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `unique_user` (`email`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores the data of all registered users,\nCreated by Martin 17/03/03';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_comment`
--

DROP TABLE IF EXISTS `user_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_comment` (
  `comment_id` int(10) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `comment_text` varchar(5000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entry_time` datetime DEFAULT NULL,
  PRIMARY KEY (`comment_id`,`user_id`),
  KEY `fk_user_comment_to_user_idx` (`user_id`),
  CONSTRAINT `fk_user_comment_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Created by Martin 17/03/03';
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
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `token` varchar(128) NOT NULL DEFAULT '''""''' COMMENT 'Secret token emailed to user when activating a new account or attempting to reset a forgotten password.',
  `type` enum('RESET_PASSWORD','ACTIVATE_ACCOUNT') NOT NULL DEFAULT 'RESET_PASSWORD' COMMENT 'Nature of verification request (either resetting a lost password or activating a new account).',
  `date_created` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`),
  KEY `date_created_index` (`date_created`) USING BTREE,
  CONSTRAINT `fk_user_email_token_to_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_sessions` (
  `session_id` int(10) NOT NULL AUTO_INCREMENT,
  `user_id` smallint(5) unsigned NOT NULL,
  `session_key` char(56) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `session_start` datetime DEFAULT NULL,
  `session_end` datetime DEFAULT NULL,
  `current` tinyint(1) DEFAULT NULL COMMENT 'Boolean determining whether the current session is still in progress or has been finished (user has exited).',
  PRIMARY KEY (`session_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='This table stores a record of all user sessions.\nCreated by Martin 17/03/03';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `word`
--

DROP TABLE IF EXISTS `word`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `word` (
  `word_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier',
  `qwb_word_id` int(11) unsigned DEFAULT NULL COMMENT 'Old word identifier from QWB.',
  `commentary` mediumtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`word_id`),
  KEY `old_word_idx` (`qwb_word_id`),
  CONSTRAINT `fk_word_to_qwb_word_data` FOREIGN KEY (`qwb_word_id`) REFERENCES `qwb_word_data` (`qwb_word_data_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=380474 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='A collection of signs from a stream. Maintains link to original QWB word id.';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `word_owner`
--

DROP TABLE IF EXISTS `word_owner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `word_owner` (
  `word_id` int(10) unsigned NOT NULL,
  `edition_editor_id` int(10) unsigned NOT NULL DEFAULT 0,
  `edition_id` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`word_id`,`edition_editor_id`),
  UNIQUE KEY `all_idx` (`word_id`,`edition_id`),
  KEY `fk_word_owner_to_scroll_version_idx` (`edition_editor_id`),
  KEY `fk_word_to_edition` (`edition_id`),
  CONSTRAINT `fk_word_owner_to_word` FOREIGN KEY (`word_id`) REFERENCES `word` (`word_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_word_to_edition` FOREIGN KEY (`edition_id`) REFERENCES `edition` (`edition_id`),
  CONSTRAINT `fk_word_to_edition_editor` FOREIGN KEY (`edition_editor_id`) REFERENCES `edition_editor` (`edition_editor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
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
/*!50001 VIEW `recent_edition_catalog_to_col_confirmation` AS select `iaa_edition_catalog_to_col_confirmation`.`iaa_edition_catalog_to_col_id` AS `iaa_edition_catalog_to_col_id`,`iaa_edition_catalog_to_col_confirmation`.`confirmed` AS `confirmed`,`iaa_edition_catalog_to_col_confirmation`.`user_id` AS `user_id`,max(`iaa_edition_catalog_to_col_confirmation`.`time`) AS `MAX(``time``)` from `iaa_edition_catalog_to_col_confirmation` group by `iaa_edition_catalog_to_col_confirmation`.`iaa_edition_catalog_to_col_id` */;
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
