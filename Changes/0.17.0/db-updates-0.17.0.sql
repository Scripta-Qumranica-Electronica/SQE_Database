#####################################################################
## Updates to artifact_position

## Fix the artifact_position table for proper constraints when NULL is involved.
## NULL is unique in most RDMSs (NULL != NULL is true), so in general using nullable
## fields like translate_x and translate_y in uniqueness constraints leads to many
## identical entries (from our perspective).  This is taken care of in the API, but for
## the sake of safety I added a generated field that coalesces each translate field with
## 4294967295 (the highest possible unsigned int value) and used those generated fields
## in the table's uniqueness constraint so that no NULLs are involved.

## Fix to convert scale and rotate as floating point to decimal, with a slight decrease in 
## storage space used (float = 32 bit, DECIMAL(6,2) and DECIMAL(6,4) use 24 bits).
## This was necessary because floating-point values were not matching in the list
## equality statemants, e.g.: 
## WHERE (artefact_id, scale, rotation, translate_x, translate_y) = (1,1.1,0,100,100)
## would not match a row that had those exact values, when changed to decimal everything
## worked properly.  Since these are not used for mathematical operations in the DB, there
## seems to be no benefit to using float in any event.

## Update the z-index to a signed int match the frontend possibilities and needs. When reordering 
## they have a send to top/send to bottom, which finds the highest/lowest zIndex in all the visible
## artefacts and adds/subtracts 1.  This will minimize (or virtually always) eliminate mass reorderings
## of artefacts on a single send to top/send to bottom operation; calulating and performing such reorderings
## is computationally expensive and unpleasant for UI experience (GIS overlap searches, batch update 
## requests, batch UI reorderings for all concurrent editors)

UPDATE artefact_position
SET scale = 1
WHERE scale = 0 OR scale IS NULL;

UPDATE artefact_position
SET rotate = 0
WHERE rotate IS NULL;

ALTER TABLE `artefact_position` DROP INDEX `unique_artefact_transform_z_index`;

ALTER TABLE `artefact_position` CHANGE `z_index` `z_index` INT NOT NULL DEFAULT 0  COMMENT 'This value can move artefacts up or down in relation to other artefacts in the scroll.  That is, it sends an artefact further into the foreground or background.' AFTER `artefact_id`;

ALTER TABLE `artefact_position` CHANGE `scale` `scale` DECIMAL(6, 4) UNSIGNED NOT NULL DEFAULT 1  COMMENT 'Resizing to be applied to the artefact.' AFTER `z_index`;

ALTER TABLE `artefact_position` CHANGE `rotate` `rotate` DECIMAL(6, 2) UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Rotation to be applied to the artefact.' AFTER `scale`;

ALTER TABLE `artefact_position` ADD COLUMN `translate_x_non_null` INT(11) UNSIGNED GENERATED ALWAYS AS (COALESCE(translate_x, 4294967295)) VIRTUAL COMMENT 'This is a generated column for the sake of uniqueness constraints.  It reads the highest possible value of an int instead of NULL, since that value is basically never going to be used (no scroll or manuscript has pages of such a length).' AFTER `translate_y`;

ALTER TABLE `artefact_position` ADD COLUMN `translate_y_non_null` INT(11) UNSIGNED GENERATED ALWAYS AS (COALESCE(translate_y, 4294967295)) VIRTUAL COMMENT 'This is a generated column for the sake of uniqueness constraints.  I reads the highest possible value of an int instead of NULL, since that value is basically never going to be used (no scroll or manuscript has pages of such a length).' AFTER `translate_x_non_null`;

ALTER TABLE `artefact_position` ADD CONSTRAINT `fk_unique_artefact_position` UNIQUE (`artefact_id`,`rotate`,`scale`,`translate_x_non_null`,`translate_y_non_null`,`z_index`) USING BTREE;

## End artefact_position updates
#####################################################################


#####################################################################
## Updates to artefact_data

## These are a series of updates aimed at cleaning up the artefact naming scheme.

## Basically people do not need to know the "Q" numbers, etc., because the artefact
## is already related to an edition, so those are removed.

## The usage of Plate numbers (from DJD) are unhelpful whenever an artefact-text_fragment
## connection has been established.  Thos have been removed.

## Many artefacts (35%) have not been related to a text-fragment at all, and thus have
## titles like "4Q418 - -", these are renamed to "N/A".

## Artefacts that have been related to text fragment, are simply given the name "Frg. n" where
## n is the fragment identification.  If they are related to a column's fragment, they have 
## the name "Col. x - n" where x is the column designation and n is the fragment designation
## within that column.

## The updates are performed in many passes in order to catch all the edge cases.
## They are only performed on public editions. NOTE this could be problematic if run
## on a database that has public edition created by people other than the base SQE
## system data.  If so (though it is not very likely) add the constraint to either
## edition_editors with user_id 1 or edition_ids < 1646.


UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
JOIN artefact_shape USING(artefact_id)
JOIN SQE_image USING(sqe_image_id)
JOIN image_catalog USING(image_catalog_id)
JOIN image_to_iaa_edition_catalog USING(image_catalog_id)
JOIN iaa_edition_catalog_to_text_fragment USING(iaa_edition_catalog_id)
JOIN text_fragment_data USING(text_fragment_id)
SET artefact_data.name = IF(text_fragment_data.name LIKE "col%", REGEXP_REPLACE(artefact_data.name, '^[0-9]+Q[0-9a-z\-]+ - ', 'Col. '), REGEXP_REPLACE(artefact_data.name, '^[0-9]+Q[0-9a-z\-]+ - [0-9A-z]+ - ', 'Frg. '))
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
JOIN artefact_shape USING(artefact_id)
JOIN SQE_image USING(sqe_image_id)
JOIN image_catalog USING(image_catalog_id)
JOIN image_to_iaa_edition_catalog USING(image_catalog_id)
JOIN iaa_edition_catalog_to_text_fragment USING(iaa_edition_catalog_id)
JOIN text_fragment_data USING(text_fragment_id)
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^[0-9]+Q[0-9a-z\-]+ -  [0-9A-z]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
JOIN artefact_shape USING(artefact_id)
JOIN SQE_image USING(sqe_image_id)
JOIN image_catalog USING(image_catalog_id)
JOIN image_to_iaa_edition_catalog USING(image_catalog_id)
JOIN iaa_edition_catalog_to_text_fragment USING(iaa_edition_catalog_id)
JOIN text_fragment_data USING(text_fragment_id)
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, ' -  - $', '')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
JOIN artefact_shape USING(artefact_id)
JOIN SQE_image USING(sqe_image_id)
JOIN image_catalog USING(image_catalog_id)
JOIN image_to_iaa_edition_catalog USING(image_catalog_id)
JOIN iaa_edition_catalog_to_text_fragment USING(iaa_edition_catalog_id)
JOIN text_fragment_data USING(text_fragment_id)
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, ' - $', '')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
JOIN artefact_shape USING(artefact_id)
JOIN SQE_image USING(sqe_image_id)
JOIN image_catalog USING(image_catalog_id)
JOIN image_to_iaa_edition_catalog USING(image_catalog_id)
JOIN iaa_edition_catalog_to_text_fragment USING(iaa_edition_catalog_id)
JOIN text_fragment_data USING(text_fragment_id)
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^MUR[0-9]+ - [A-z]+ - ', 'Frg. ' )
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
JOIN artefact_shape USING(artefact_id)
JOIN SQE_image USING(sqe_image_id)
JOIN image_catalog USING(image_catalog_id)
JOIN image_to_iaa_edition_catalog USING(image_catalog_id)
JOIN iaa_edition_catalog_to_text_fragment USING(iaa_edition_catalog_id)
JOIN text_fragment_data USING(text_fragment_id)
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^WS[0-9]+ - [A-z]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
JOIN artefact_shape USING(artefact_id)
JOIN SQE_image USING(sqe_image_id)
JOIN image_catalog USING(image_catalog_id)
JOIN image_to_iaa_edition_catalog USING(image_catalog_id)
JOIN iaa_edition_catalog_to_text_fragment USING(iaa_edition_catalog_id)
JOIN text_fragment_data USING(text_fragment_id)
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^5/6Hev 1b [0-9]+ - [A-z]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
JOIN artefact_shape USING(artefact_id)
JOIN SQE_image USING(sqe_image_id)
JOIN image_catalog USING(image_catalog_id)
JOIN image_to_iaa_edition_catalog USING(image_catalog_id)
JOIN iaa_edition_catalog_to_text_fragment USING(iaa_edition_catalog_id)
JOIN text_fragment_data USING(text_fragment_id)
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^4Q519', CONCAT(UCASE(LEFT(text_fragment_data.name, 1)), SUBSTRING(text_fragment_data.name, 2)))
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = 'N/A'
WHERE edition.public = 1
AND artefact_data.name LIKE '%)';

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = 'N/A'
WHERE edition.public = 1
AND artefact_data.name LIKE '%-  - ';

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(REGEXP_REPLACE(artefact_data.name, '^.*? - ', 'Pl. '), ' -.*', '')
WHERE edition.public = 1
AND artefact_data.name LIKE '% - ';

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^[0-9]+Q[0-9a-z\- ]+? - [0-9A-z]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^[0-9]+Q[0-9a-z\- ]+? -  [0-9A-z]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^[0-9]+Se[0-9a-z\- ]+? - [0-9A-z]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^[0-9]+Hev[0-9a-z\- ]+? - [0-9A-z]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^MUR[0-9a-z\- ]+? - [0-9A-z]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^Mas[0-9a-z\- ]+? - [0-9A-z:]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^Wd[0-9a-z\- ]+? - [0-9A-z:]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^Ws[0-9a-z\- ]+? - [0-9A-z:]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^XHev/Se[0-9a-z\- ]+? - [0-9A-z:]+ - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^5/6Hev 1a 534 - XXIV - ', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^4Q29 -  - ', '')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^4Q400 -  - XVI:', 'Frg. ')
WHERE edition.public = 1;

UPDATE artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN edition ON edition.edition_id = artefact_data_owner.edition_id
SET artefact_data.name = REGEXP_REPLACE(artefact_data.name, '^4Q113', 'N/A')
WHERE edition.public = 1;

## End updates to artefact_data
#####################################################################