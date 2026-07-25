-- DATA FIX: de-duplicate manuscript_metrics ownership.
--
-- Some editions own MORE THAN ONE manuscript_metrics row via manuscript_metrics_owner
-- (~380 seed editions, and any copies made from them). This is a data error: an edition
-- should have exactly one metrics row. Because of it, the API's metrics update
-- (UpdateEditionMetricsAsync, which requires exactly one owned metrics row) throws and a
-- scroll-canvas resize 404s / cannot persist.
--
-- The duplicates were verified to be lossless to collapse:
--   * every duplicated metrics row shares the SAME manuscript_id as its edition, and
--   * all duplicates for a given edition hold IDENTICAL values (width/height/origins/ppi),
-- so keeping any single one loses nothing and stays consistent with the GET read path
-- (which resolves metrics by the edition's manuscript_id).
--
-- Fix: keep one owner row per edition (the lowest manuscript_metrics_id) and drop the rest.
-- Orphaned manuscript_metrics rows (now owned by no edition) are left in place — harmless, and
-- avoids touching versioned entity rows that other editions might reference.

START TRANSACTION;

-- Set the version of this update
SELECT @VER := "0.33.1";

DELETE dup
FROM manuscript_metrics_owner dup
JOIN manuscript_metrics_owner keep
  ON keep.edition_id            = dup.edition_id
 AND keep.manuscript_metrics_id < dup.manuscript_metrics_id;

-- After this, every edition_id in manuscript_metrics_owner has exactly one row.

-- Record the completion of the update
INSERT INTO `db_version` (version) VALUES (@VER)
    ON DUPLICATE KEY UPDATE version = version;
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;
