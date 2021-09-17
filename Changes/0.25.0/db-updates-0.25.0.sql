START TRANSACTION;

-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.25.0";

INSERT INTO `db_version` (version)
VALUES (@VER);

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;