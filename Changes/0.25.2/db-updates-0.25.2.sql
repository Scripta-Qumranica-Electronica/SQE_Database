START TRANSACTION;

-- Set the version of this update (CURRENT_DATABASE_VERSION)
SELECT @VER := "0.25.2";

INSERT INTO `db_version` (version)
VALUES (@VER);

-- Insert missing artefact_shape_owner table entries
insert into artefact_shape_owner (artefact_shape_id, edition_editor_id, edition_id)
SELECT DISTINCT artefact_shape.artefact_shape_id, artefact_data_owner.edition_id, artefact_data_owner.edition_id
from artefact_shape
join artefact_data USING(artefact_id)
join artefact_data_owner using(artefact_data_id)
left join artefact_shape_owner using(artefact_shape_id)
where artefact_shape_owner.edition_id is null and artefact_data_owner.edition_id < 1646;


-- Record the completion of the update
UPDATE `db_version`
SET completed = current_timestamp()
WHERE version = @VER;

COMMIT;
