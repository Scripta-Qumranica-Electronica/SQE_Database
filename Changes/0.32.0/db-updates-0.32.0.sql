-- Add publication date column to the edition table
START TRANSACTION;

-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.32.0";

INSERT INTO `db_version` (version)
VALUES (@VER);

ALTER TABLE `edition` ADD COLUMN IF NOT EXISTS  `publication_date` datetime null 
comment 'This is the date that the edition was published. When an edition has not yet been made public (i.e., published), this will be NULL.';

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;