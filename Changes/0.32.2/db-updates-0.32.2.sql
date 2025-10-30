-- Add default users
START TRANSACTION;

-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.32.2";

# Fix test user id 2 to have full admin status
INSERT INTO users_system_roles (user_id, system_roles_id)
VALUES (2,2), (2,3), (2,4)
ON DUPLICATE KEY UPDATE user_id=2
;

-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;