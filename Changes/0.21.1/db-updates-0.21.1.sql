##################################################################
## Recreate the latest edition catalog to col confirmation view ##
##################################################################

DROP VIEW IF EXISTS recent_edition_catalog_to_col_confirmation;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY INVOKER VIEW `recent_edition_catalog_to_col_confirmation` AS select `t1`.`iaa_edition_catalog_to_text_fragment_id` AS `iaa_edition_catalog_to_text_fragment_id`,`t1`.`confirmed` AS `confirmed`,`t1`.`user_id` AS `user_id`,`t1`.`time` AS `time` from (`iaa_edition_catalog_to_text_fragment_confirmation` `t1` left join `iaa_edition_catalog_to_text_fragment_confirmation` `t2` on(`t1`.`iaa_edition_catalog_to_text_fragment_id` = `t2`.`iaa_edition_catalog_to_text_fragment_id` and (`t1`.`time` < `t2`.`time` or `t1`.`time` = `t2`.`time` and `t1`.`confirmed` > `t2`.`confirmed`))) where `t2`.`iaa_edition_catalog_to_text_fragment_id` is null group by `t1`.`iaa_edition_catalog_to_text_fragment_id`;