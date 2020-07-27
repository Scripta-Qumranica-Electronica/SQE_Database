###############################
## Create view to work with  ##
## image to fragment matches ##
###############################

CREATE VIEW image_text_fragment_match_catalogue
AS SELECT image_catalog.image_catalog_id, image_catalog.institution, image_catalog.catalog_number_1, image_catalog.catalog_number_2, image_catalog.catalog_side, image_catalog.object_id,
          image_urls.image_urls_id, image_urls.url, image_urls.proxy, image_urls.suffix, image_urls.license,
          SQE_image.filename,
          iaa_edition_catalog.iaa_edition_catalog_id, iaa_edition_catalog.manuscript_id, iaa_edition_catalog.edition_name, iaa_edition_catalog.edition_volume, iaa_edition_catalog.edition_location_1, iaa_edition_catalog.edition_location_2, iaa_edition_catalog.edition_side, iaa_edition_catalog.comment,
          iaa_edition_catalog_to_text_fragment.iaa_edition_catalog_to_text_fragment_id, iaa_edition_catalog_to_text_fragment.text_fragment_id, text_fragment_data.name,
          manuscript_data.name AS manuscript_name,
          edition.edition_id
   FROM image_catalog
            JOIN SQE_image USING(image_catalog_id)
            JOIN image_urls USING(image_urls_id)
            JOIN image_to_iaa_edition_catalog USING(image_catalog_id)
            JOIN iaa_edition_catalog USING(iaa_edition_catalog_id)
            JOIN iaa_edition_catalog_to_text_fragment USING(iaa_edition_catalog_id)
            JOIN text_fragment_data USING(text_fragment_id)
            JOIN text_fragment_data_owner USING(text_fragment_data_id)
            JOIN manuscript_data USING(manuscript_id)
            JOIN manuscript_data_owner USING(manuscript_data_id)
            JOIN edition ON edition.edition_id = text_fragment_data_owner.edition_id
                AND edition.edition_id = manuscript_data_owner.edition_id
   WHERE edition.public = 1;

#####################################
## Fix for artefact_position table ##
#####################################

ALTER TABLE `artefact_position` CHANGE COLUMN `translate_x_non_null` `translate_x_non_null` INT(11) GENERATED ALWAYS AS (coalesce(`translate_x`,-2147483648)) VIRTUAL COMMENT 'This is a generated column for the sake of uniqueness constraints.  It reads the lowest possible value of an int instead of NULL, since that value is basically never going to be used (no scroll or manuscript has pages of such a length).' AFTER `translate_y`;

ALTER TABLE `artefact_position` CHANGE COLUMN `translate_y_non_null` `translate_y_non_null` INT(11) GENERATED ALWAYS AS (coalesce(`translate_y`,-2147483648)) VIRTUAL COMMENT 'This is a generated column for the sake of uniqueness constraints.  It reads the lowest possible value of an int instead of NULL, since that value is basically never going to be used (no scroll or manuscript has pages of such a length).' AFTER `translate_x_non_null`;

