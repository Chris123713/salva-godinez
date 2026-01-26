CREATE TABLE IF NOT EXISTS `billings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(46) NOT NULL,
  `company` varchar(50) NOT NULL,
  `price` int(11) NOT NULL,
  `deadline` timestamp NOT NULL,
  `issuer` varchar(255) NOT NULL,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `description` text DEFAULT NULL,
  `status` enum('paid','unpaid','overdue', 'canceled') NOT NULL DEFAULT 'unpaid',
  `items` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `duty` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(46) NOT NULL,
  `job` varchar(50) DEFAULT '',
  `start_shift` datetime DEFAULT NULL,
  `end_shift` datetime DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `weekly` int(11) DEFAULT 0,
  `total` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `transaction_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount` int(11) NOT NULL DEFAULT 0,
  `account` enum('black_money','money') NOT NULL DEFAULT 'money',
  `action` enum('deposit','withdraw','paid_off','pay_bill') NOT NULL,
  `reason` text NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  `company` varchar(50) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
);
