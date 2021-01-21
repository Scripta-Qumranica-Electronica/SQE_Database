-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.22.7";

INSERT INTO `db_version` (version)
VALUES (@VER);

UPDATE artefact_shape
JOIN SQE_image USING(SQE_image_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto = SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
SET artefact_shape.sqe_image_id = si2.SQE_image_id
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE image_to_image_map_author
FROM SQE_image
JOIN image_to_image_map ON image_to_image_map.image1_id = SQE_image.sqe_image_id
JOIN image_to_image_map_author USING(image_to_image_map_id)
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto = SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE image_to_image_map_author
FROM SQE_image
JOIN image_to_image_map ON image_to_image_map.image2_id = SQE_image.sqe_image_id
JOIN image_to_image_map_author USING(image_to_image_map_id)
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto = SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE image_to_image_map
FROM SQE_image
JOIN image_to_image_map ON image_to_image_map.image1_id = SQE_image.sqe_image_id
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto = SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE image_to_image_map
FROM SQE_image
JOIN image_to_image_map ON image_to_image_map.image2_id = SQE_image.sqe_image_id
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto = SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE SQE_image_author
FROM SQE_image
JOIN SQE_image_author ON SQE_image_author.sqe_image_id = SQE_image.sqe_image_id
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto = SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE SQE_image
FROM SQE_image
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto = SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
 
UPDATE artefact_shape
JOIN SQE_image USING(SQE_image_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto != SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
SET artefact_shape.sqe_image_id = si2.SQE_image_id
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;  
    
DELETE image_to_image_map_author
FROM SQE_image
JOIN image_to_image_map ON image_to_image_map.image1_id = SQE_image.sqe_image_id
JOIN image_to_image_map_author USING(image_to_image_map_id)
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto != SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE image_to_image_map_author
FROM SQE_image
JOIN image_to_image_map ON image_to_image_map.image2_id = SQE_image.sqe_image_id
JOIN image_to_image_map_author USING(image_to_image_map_id)
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto != SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE image_to_image_map
FROM SQE_image
JOIN image_to_image_map ON image_to_image_map.image1_id = SQE_image.sqe_image_id
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto != SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE image_to_image_map
FROM SQE_image
JOIN image_to_image_map ON image_to_image_map.image2_id = SQE_image.sqe_image_id
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto != SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE SQE_image_author
FROM SQE_image
JOIN SQE_image_author ON SQE_image_author.sqe_image_id = SQE_image.sqe_image_id
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto != SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;
    
DELETE SQE_image
FROM SQE_image
JOIN image_catalog USING(image_catalog_id)
LEFT JOIN SQE_image si2 ON si2.image_catalog_id = SQE_image.image_catalog_id
    AND si2.type = SQE_image.type
    AND si2.is_recto != SQE_image.is_recto
    AND (si2.filename NOT LIKE "%.jpg" AND si2.filename NOT LIKE "%.tif")
WHERE SQE_image.image_urls_id = 2
    AND (SQE_image.filename LIKE "%.jpg" OR SQE_image.filename LIKE "%.tif")
    AND si2.filename IS NOT NULL;

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;