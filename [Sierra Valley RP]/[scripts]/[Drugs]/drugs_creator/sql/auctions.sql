CREATE TABLE IF NOT EXISTS `drugs_creator_auctions` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`label` VARCHAR(100) NOT NULL COLLATE 'latin1_swedish_ci',
	`config` LONGTEXT NOT NULL COLLATE 'utf8mb4_bin',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB;