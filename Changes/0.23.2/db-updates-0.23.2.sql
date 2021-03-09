START TRANSACTION;

-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.23.2";

INSERT INTO `db_version` (version)
VALUES (@VER);

-- Update the text transcription cache update
alter table cached_text_fragment modify transcription_json longtext /*!100301 COMPRESSED*/ default null null;

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;