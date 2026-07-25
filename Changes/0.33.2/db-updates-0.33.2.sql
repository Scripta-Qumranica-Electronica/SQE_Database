-- Complete the manuscript_metrics data repair started in 0.33.1, and prevent recurrence.
--
-- (1) BACKFILL: ~274 editions own NO manuscript_metrics row at all (also a data error — every
--     edition should own exactly one). Give each its own default metrics row (all columns default:
--     x_origin/y_origin/width/height = 0, pixels_per_inch = 1215, creator_id = 1), owned by one of
--     the edition's editors. A cursor is used so each edition gets a fresh, independently-owned row
--     (matching the one-metrics-row-per-edition invariant, no sharing).
--
-- (2) CONSTRAINT: add a UNIQUE index on manuscript_metrics_owner(edition_id). After 0.33.1 (de-dup)
--     and the backfill above, every edition owns exactly one metrics row, so this makes the
--     "edition owns two metrics rows" corruption STRUCTURALLY impossible going forward. The API's
--     versioned update deletes the edition's old owner row before inserting the new one, so it
--     stays within the constraint.

DROP PROCEDURE IF EXISTS backfillMetricsOwners;
DELIMITER //
CREATE PROCEDURE backfillMetricsOwners()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_edition INT;
    DECLARE v_manuscript INT;
    DECLARE v_editor INT;
    DECLARE v_metrics INT;
    DECLARE cur CURSOR FOR
        SELECT e.edition_id,
               e.manuscript_id,
               (SELECT MIN(ee.edition_editor_id) FROM edition_editor ee WHERE ee.edition_id = e.edition_id)
        FROM edition e
        LEFT JOIN manuscript_metrics_owner o ON o.edition_id = e.edition_id
        WHERE o.edition_id IS NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_edition, v_manuscript, v_editor;
        IF done THEN
            LEAVE read_loop;
        END IF;
        -- Skip anything without a manuscript or an editor (defensive; there are none in practice).
        IF v_manuscript IS NOT NULL AND v_editor IS NOT NULL THEN
            INSERT INTO manuscript_metrics (manuscript_id) VALUES (v_manuscript);
            SET v_metrics = LAST_INSERT_ID();
            INSERT INTO manuscript_metrics_owner (manuscript_metrics_id, edition_id, edition_editor_id)
                VALUES (v_metrics, v_edition, v_editor);
        END IF;
    END LOOP;
    CLOSE cur;
END//
DELIMITER ;

START TRANSACTION;

-- Set the version of this update
SELECT @VER := "0.33.2";

CALL backfillMetricsOwners();

-- Record the completion of the update
INSERT INTO `db_version` (version) VALUES (@VER)
    ON DUPLICATE KEY UPDATE version = version;
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;

-- Housekeeping + the schema constraint (DDL forces an implicit commit, so it lives outside the
-- transaction above). Every edition now owns exactly one metrics row, so the UNIQUE index applies
-- cleanly and blocks the duplication from ever recurring.
DROP PROCEDURE IF EXISTS backfillMetricsOwners;
ALTER TABLE manuscript_metrics_owner
    ADD UNIQUE KEY uq_manuscript_metrics_owner_edition (edition_id);
