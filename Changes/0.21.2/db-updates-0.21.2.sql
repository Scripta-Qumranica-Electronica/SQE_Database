######################################
## Create the user data store table ##
######################################

CREATE TABLE `user_data_store` (
  `user_id` int(11) unsigned NOT NULL DEFAULT 0,
  `data` longtext NOT NULL COMMENT 'A JSON object storing non-system critical information related to a user account.',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `user_data_store_to_user_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='This table provides an area to store non-system critical information related to a user account.  It may be used by front end consumers to store application specific information. It is not intended for backend usage or integration with other data in the database.';

########################################
## Fill the new user data store table ##
########################################

INSERT INTO user_data_store (user_id, data)
SELECT user_id, "{}"
FROM user
LEFT JOIN user_data_store USING(user_id)
WHERE  user_data_store.user_id IS NULL;