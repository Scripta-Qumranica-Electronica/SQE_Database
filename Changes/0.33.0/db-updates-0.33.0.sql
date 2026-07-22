-- Publish the masked, laid-out 1Q7 artefacts into the public edition 808.
--
-- The 1Q7 artefact shapes (masks) and manuscript placement were made in the
-- private working copy edition 2015 ("1Q7 - OSU Demo") but were never published
-- to the public edition 808 (1Q7), which was left essentially empty. This shares
-- edition 2015's existing artefact_data / artefact_shape / artefact_position
-- entities into edition 808 via 808's system editor (user 1). Nothing is
-- duplicated: 808 simply gains ownership rows pointing at the same entity rows,
-- so the artefacts remain the work of their original creators.
--
-- Result: edition 808 gains 16 artefacts, 16 masks and 13 positions (8 placed).

START TRANSACTION;

-- Set the version of this update
SELECT @VER := "0.33.0";

-- 808's system editor (user 1, sqe_api) -- owns the public edition
SET @ee808 := (
    SELECT edition_editor_id FROM edition_editor
    WHERE edition_id = 808 AND user_id = 1 LIMIT 1
);

-- Clear 808's stray artefact ownership (a few orphaned shape rows)
DELETE FROM artefact_data_owner     WHERE edition_id = 808;
DELETE FROM artefact_shape_owner    WHERE edition_id = 808;
DELETE FROM artefact_position_owner WHERE edition_id = 808;

-- Share edition 2015's artefacts, masks and placement into edition 808
INSERT INTO artefact_data_owner     (artefact_data_id, edition_editor_id, edition_id)
    SELECT artefact_data_id,     @ee808, 808 FROM artefact_data_owner     WHERE edition_id = 2015;
INSERT INTO artefact_shape_owner    (artefact_shape_id, edition_editor_id, edition_id)
    SELECT artefact_shape_id,    @ee808, 808 FROM artefact_shape_owner    WHERE edition_id = 2015;
INSERT INTO artefact_position_owner (artefact_position_id, edition_editor_id, edition_id)
    SELECT artefact_position_id, @ee808, 808 FROM artefact_position_owner WHERE edition_id = 2015;

-- Record the completion of the update
INSERT INTO `db_version` (version) VALUES (@VER)
    ON DUPLICATE KEY UPDATE version = version;
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;

-- Housekeeping: drop the manual backup tables created during the production run
-- (if present). Kept outside the transaction above because DROP TABLE forces an
-- implicit commit in MariaDB.
DROP TABLE IF EXISTS _bak_808_data_owner;
DROP TABLE IF EXISTS _bak_808_shape_owner;
DROP TABLE IF EXISTS _bak_808_position_owner;

