CREATE TABLE `gruppe6_players` (
  `identifier` VARCHAR(128) NOT NULL,
  `ranks` TEXT NOT NULL DEFAULT '{}',
  `contracts` TEXT NOT NULL DEFAULT '{}',
PRIMARY KEY (`identifier`));