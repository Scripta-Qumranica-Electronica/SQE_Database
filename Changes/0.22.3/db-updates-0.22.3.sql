-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.22.3";

INSERT INTO `db_version` (version)
VALUES (@VER);

-- Delete artefacts that have no shape

DELETE artefact_data_owner
FROM artefact_data
JOIN artefact_data_owner USING(artefact_data_id)
JOIN artefact USING(artefact_id)
LEFT JOIN artefact_shape USING(artefact_id)
WHERE artefact_shape.region_in_sqe_image IS NULL AND artefact_shape.sqe_image_id IS NULL;

DELETE artefact_data
FROM artefact_data
JOIN artefact USING(artefact_id)
LEFT JOIN artefact_shape USING(artefact_id)
WHERE artefact_shape.region_in_sqe_image IS NULL AND artefact_shape.sqe_image_id IS NULL;

DELETE artefact
FROM artefact
LEFT JOIN artefact_data USING(artefact_id)
WHERE artefact_data.name IS NULL AND artefact_data.creator_id IS NULL;

-- Make region_in_sqe_image a nullable column

ALTER TABLE `artefact_shape` CHANGE COLUMN `region_in_sqe_image` `region_in_sqe_image` GEOMETRY NULL  COMMENT 'This is the exact polygon of the artefact’s location within the master image’s coordinate system, but alwaya at a resolution of 1215 PPI. If the master image is not 1215 PPI it should be scaled to that resolution before the artefact is drawn upon it.' AFTER `sqe_image_id`, ALTER COLUMN `region_in_sqe_image` DROP DEFAULT;

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;