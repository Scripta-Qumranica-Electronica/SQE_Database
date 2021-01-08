UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
JOIN image_catalog updated_image 
    ON updated_image.institution = image_catalog.institution
    AND updated_image.catalog_number_1 =  REPLACE(image_catalog.catalog_number_1, "/Rec", "")
    AND updated_image.catalog_number_2 = image_catalog.catalog_number_2
    AND updated_image.catalog_side = image_catalog.catalog_side
SET SQE_image.image_catalog_id = updated_image.image_catalog_id
WHERE image_catalog.catalog_number_1 LIKE "%/Rec%";

UPDATE SQE_image
JOIN image_catalog USING(image_catalog_id)
JOIN image_catalog updated_image 
    ON updated_image.institution = image_catalog.institution
    AND updated_image.catalog_number_1 =  REPLACE(image_catalog.catalog_number_1, "/Vrs", "")
    AND updated_image.catalog_number_2 = image_catalog.catalog_number_2
    AND updated_image.catalog_side = image_catalog.catalog_side
SET SQE_image.image_catalog_id = updated_image.image_catalog_id
WHERE image_catalog.catalog_number_1 LIKE "%/Vrs%";

DELETE image_catalog
FROM image_catalog
LEFT JOIN SQE_image USING(image_catalog_id)
WHERE image_catalog.catalog_number_1 LIKE "%/Rec%"
    AND SQE_image.sqe_image_id IS NULL;

DELETE image_catalog
FROM image_catalog
LEFT JOIN SQE_image USING(image_catalog_id)
WHERE image_catalog.catalog_number_1 LIKE "%/Vrs%"
    AND SQE_image.sqe_image_id IS NULL;

UPDATE image_catalog
SET catalog_number_1 = REPLACE(catalog_number_1, "/Rec", "")
WHERE catalog_number_1 LIKE "%/Rec%";

UPDATE image_catalog
SET catalog_number_1 = REPLACE(catalog_number_1, "/Vrs", "")
WHERE catalog_number_1 LIKE "%/Vrs%";