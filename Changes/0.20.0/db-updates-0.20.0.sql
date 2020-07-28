###############################
## Create system_roles table ##
###############################

CREATE TABLE `system_roles` (
  `system_roles_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `role_title` varchar(128) NOT NULL DEFAULT '' COMMENT 'A short title for the role.',
  `role_description` text NOT NULL COMMENT 'A description of what an API that manages the database should consider as permissable for this role to do within the database.',
  PRIMARY KEY (`system_roles_id`),
  UNIQUE(role_title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

########################################
## Create the user_system_roles table ##
########################################

CREATE TABLE `users_system_roles` (
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `system_roles_id` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`,`system_roles_id`),
  KEY `users_system_roles_to_system_roles_id` (`system_roles_id`),
  CONSTRAINT `users_system_roles_to_system_roles_id` FOREIGN KEY (`system_roles_id`) REFERENCES `system_roles` (`system_roles_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `users_system_roles_to_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='This table applies individual system roles to each user.';

############################################
## Populate system_roles and assign users ##
############################################

INSERT INTO system_roles (role_title,role_description)
VALUES 
    ('REGISTERED_USER', 'This role is for all general users of the system. It should permit all activities related to the edition system. Such users may perform CREATE on all *_owner table, they may UPDATE/DELETE only those rows with an edition_id for which they have write permissions. They may CREATE in any data table with a corresponding *_owned table.'),
    ('CATALOGUE_CURATOR', 'This role is for users who may edit cataloguing data. This refers mainly to CREATE/UPDATE/DELETE operations on tables that contain references to cataloguing information, such as textual references and museum numbers. Any operations performed by such users should maintain a record of who made the changes—see, e.g., the *_author tables.'),
    ('IMAGE_DATA_CURATOR', 'This role is for users who can add images to the system and alter information related to the images. Mainly this constitutes CREATE/UPDATE/DELETE access to the SQE_image and image_urls table.'),
    ('USER_ADMIN', 'This role is for administrators of the user access system. It permits CREATE/UPDATE/DELETE access to the user, system_roles, and users_system_roles tables.');

INSERT INTO users_system_roles (user_id,system_roles_id)
SELECT user.user_id, system_roles.system_roles_id
FROM user
LEFT JOIN system_roles ON system_roles.role_title = 'REGISTERED_USER';

## Remove the REGISTERED_USER role for user_id 1 (sqe_api)
DELETE FROM users_system_roles
WHERE users_system_roles.user_id = 1;

##################################
## Create the creator_id system ##
##################################

# Note that the connection will most likely drop before this finishes
# so change the settings for this session
SET @@session.wait_timeout=1200;
SET @@session.interactive_timeout=1200;

DROP PROCEDURE IF EXISTS processOwnerT;

DELIMITER //
CREATE PROCEDURE processOwnerT()
BEGIN
    DECLARE doneProc INT;
    DECLARE tableName VARCHAR(256);
    
    DECLARE cur CURSOR FOR SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_NAME LIKE '%_owner' ORDER BY TABLE_NAME ASC;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET doneProc = 1;
    
    OPEN cur;
    
    SET doneProc = 0;
    REPEAT
    
        FETCH cur INTO tableName;
        set @ownedTable = TRIM(TRAILING '_owner' FROM tableName);
        SET @alterQuery = CONCAT('ALTER TABLE ', @ownedTable, ' ADD COLUMN IF NOT EXISTS `creator_id` INT(11) UNSIGNED NOT NULL DEFAULT 1');
        PREPARE updateQuery FROM @alterQuery;
        EXECUTE updateQuery;
        DEALLOCATE PREPARE updateQuery;
        
        SET @fkdQuery = CONCAT('ALTER TABLE ', @ownedTable, ' DROP CONSTRAINT IF EXISTS`fk_', @ownedTable, '_to_creator_id');
        PREPARE fkdQ FROM @fkdQuery;
        EXECUTE fkdQ;
        DEALLOCATE PREPARE fkdQ;
        
        SET @fkQuery = CONCAT('ALTER TABLE ', @ownedTable, ' ADD CONSTRAINT `fk_', @ownedTable, '_to_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION');
        PREPARE fkQ FROM @fkQuery;
        EXECUTE fkQ;
        DEALLOCATE PREPARE fkQ;
        
        SET @origCreatorQuery = CONCAT('UPDATE ', @ownedTable,', (SELECT user_id, id_in_table FROM single_action
JOIN main_action USING(main_action_id)
JOIN edition_editor USING(edition_editor_id)
WHERE single_action.table = "', @ownedTable,'"
GROUP BY single_action.id_in_table
HAVING MIN(main_action.time)) AS creators
SET ', @ownedTable,'.creator_id = creators.user_id
WHERE ', @ownedTable,'.', @ownedTable,'_id = creators.id_in_table');
        PREPARE cQ FROM @origCreatorQuery;
        EXECUTE cQ;
        DEALLOCATE PREPARE cQ;
    
    UNTIL doneProc
    END REPEAT;
    
    CLOSE cur;
END
    
//
DELIMITER ;

CALL processOwnerT();

DROP PROCEDURE IF EXISTS processOwnerT;