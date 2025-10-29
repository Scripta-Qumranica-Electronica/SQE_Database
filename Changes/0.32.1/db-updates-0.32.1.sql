-- Add default users
START TRANSACTION;

-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.32.1";

INSERT INTO `db_version` (version)
VALUES (@VER);

DELETE user_data_store
FROM user_data_store
LEFT JOIN user USING(user_id)
WHERE user.user_id IS NULL;

DELETE users_system_roles
FROM users_system_roles
LEFT JOIN user USING(user_id)
WHERE user.user_id IS NULL;

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;