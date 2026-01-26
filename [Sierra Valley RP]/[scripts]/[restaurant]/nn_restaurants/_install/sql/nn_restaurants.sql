
CREATE TABLE IF NOT EXISTS `sn_restaurants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(50) NOT NULL DEFAULT '0',
  `owner` varchar(50) DEFAULT '0',
  `info` longtext NOT NULL,
  `employees` longtext NOT NULL DEFAULT '[]',
  `positions` longtext DEFAULT '[]',
  `description` varchar(50) DEFAULT NULL,
  `is_open` int(11) DEFAULT NULL,
  `theme_color` varchar(50) DEFAULT NULL,
  `secondary_color` varchar(7) DEFAULT '#FFD700',
  `logo_url` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_restaurants_label` (`label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_menu_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `display_order` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `sn_rest_menu_categories_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_menu_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `image_url` text DEFAULT NULL,
  `recipe_id` int(11) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  `display_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `category_id` (`category_id`),
  KEY `recipe_id` (`recipe_id`),
  CONSTRAINT `sn_rest_menu_items_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sn_rest_menu_items_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `sn_rest_menu_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_employees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `identifier` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `position` varchar(100) NOT NULL,
  `salary` int(11) DEFAULT 0,
  `performance` int(11) DEFAULT 50,
  `hire_date` date NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `is_boss` tinyint(1) DEFAULT 0,
  `is_manager` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `identifier` (`identifier`),
  KEY `idx_employees_performance` (`performance`),
  KEY `idx_employees_roles` (`is_boss`,`is_manager`),
  CONSTRAINT `sn_rest_employees_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `order_number` varchar(50) NOT NULL,
  `customer_identifier` varchar(50) DEFAULT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `pos_id` int(11) DEFAULT NULL,
  `order_type` varchar(50) NOT NULL DEFAULT 'dine_in',
  `status` enum('pending','cooking','ready','completed','cancelled') NOT NULL DEFAULT 'pending',
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `payment_method` varchar(50) DEFAULT NULL,
  `order_data` longtext DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_number` (`order_number`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `employee_id` (`employee_id`),
  KEY `pos_id` (`pos_id`),
  KEY `idx_orders_status` (`status`),
  KEY `idx_orders_date` (`created_at`),
  CONSTRAINT `sn_rest_orders_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sn_rest_orders_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `sn_rest_employees` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `menu_item_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `unit_price` decimal(10,2) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `special_instructions` text DEFAULT NULL,
  `status` enum('pending','cooking','ready','served') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `menu_item_id` (`menu_item_id`),
  CONSTRAINT `sn_rest_order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `sn_rest_orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sn_rest_order_items_ibfk_2` FOREIGN KEY (`menu_item_id`) REFERENCES `sn_rest_menu_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_analytics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `total_orders` int(11) DEFAULT 0,
  `total_revenue` decimal(10,2) DEFAULT 0.00,
  `avg_order_value` decimal(10,2) DEFAULT 0.00,
  `customer_count` int(11) DEFAULT 0,
  `peak_hour` tinyint(4) DEFAULT NULL,
  `most_popular_item_id` int(11) DEFAULT NULL,
  `employee_performance` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_restaurant_date` (`restaurant_id`,`date`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `most_popular_item_id` (`most_popular_item_id`),
  KEY `idx_analytics_date` (`date`),
  CONSTRAINT `sn_rest_analytics_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_finance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `current_balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_revenue` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_expenses` decimal(10,2) NOT NULL DEFAULT 0.00,
  `pending_salaries` decimal(10,2) NOT NULL DEFAULT 0.00,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_restaurant_finance` (`restaurant_id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `sn_rest_finance_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `item_label` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `min_quantity` int(11) DEFAULT 10,
  `max_quantity` int(11) DEFAULT 100,
  `unit_cost` decimal(10,2) DEFAULT 0.00,
  `supplier` varchar(255) DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `last_restocked` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_restaurant_item` (`restaurant_id`,`item_name`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `idx_inventory_quantity` (`quantity`),
  CONSTRAINT `sn_rest_inventory_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_invitations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `inviter_identifier` varchar(50) NOT NULL,
  `inviter_name` varchar(255) NOT NULL,
  `invitee_identifier` varchar(50) NOT NULL,
  `invitee_name` varchar(255) NOT NULL,
  `position` varchar(100) NOT NULL,
  `salary` int(11) DEFAULT 0,
  `is_boss` tinyint(1) DEFAULT 0,
  `is_manager` tinyint(1) DEFAULT 0,
  `status` enum('pending','accepted','declined','expired') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL DEFAULT (current_timestamp() + interval 24 hour),
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `invitee_identifier` (`invitee_identifier`),
  KEY `status` (`status`),
  CONSTRAINT `sn_rest_invitations_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_pending_salaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `employee_identifier` varchar(50) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `paid_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `claimed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `employee_id` (`employee_id`),
  KEY `employee_identifier` (`employee_identifier`),
  KEY `claimed_at` (`claimed_at`),
  CONSTRAINT `sn_rest_pending_salaries_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sn_rest_pending_salaries_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `sn_rest_employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_pos_systems` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `device_type` enum('pos','kiosk') NOT NULL DEFAULT 'pos',
  `position_x` float DEFAULT NULL,
  `position_y` float DEFAULT NULL,
  `position_z` float DEFAULT NULL,
  `heading` float DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `sn_rest_pos_systems_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_recipes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `ingredients` longtext NOT NULL,
  `output_item` varchar(255) NOT NULL,
  `cook_time` int(11) DEFAULT 5,
  `difficulty` varchar(50) DEFAULT 'Easy',
  `image_url` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_drink` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Flag to indicate if recipe is a drink (1) or food (0)',
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `sn_rest_recipes_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_recipe_instructions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recipe_id` int(11) NOT NULL,
  `step_number` int(11) NOT NULL,
  `instruction_text` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `recipe_id` (`recipe_id`),
  KEY `step_number` (`step_number`),
  CONSTRAINT `sn_rest_recipe_instructions_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `sn_rest_recipes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_recipe_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recipe_id` int(11) NOT NULL,
  `note_text` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `recipe_id` (`recipe_id`),
  CONSTRAINT `sn_rest_recipe_notes_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `sn_rest_recipes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_recipe_tips` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `recipe_id` int(11) NOT NULL,
  `tip_text` text NOT NULL,
  `tip_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `recipe_id` (`recipe_id`),
  CONSTRAINT `sn_rest_recipe_tips_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `sn_rest_recipes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` longtext DEFAULT NULL,
  `setting_type` enum('string','number','boolean','json') NOT NULL DEFAULT 'string',
  `description` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_restaurant_setting` (`restaurant_id`,`setting_key`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `sn_rest_settings_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `transaction_type` enum('income','expense','salary','withdrawal','deposit') NOT NULL,
  `description` varchar(255) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `employee_id` (`employee_id`),
  KEY `order_id` (`order_id`),
  KEY `transaction_type` (`transaction_type`),
  KEY `created_at` (`created_at`),
  CONSTRAINT `sn_rest_transactions_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sn_rest_transactions_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `sn_rest_employees` (`id`) ON DELETE SET NULL,
  CONSTRAINT `sn_rest_transactions_ibfk_3` FOREIGN KEY (`order_id`) REFERENCES `sn_rest_orders` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_tv_displays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `display_type` enum('kitchen','order_queue','custom') NOT NULL DEFAULT 'kitchen',
  `custom_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`custom_content`)),
  `model` varchar(100) DEFAULT 'prop_tv_flat_01',
  `position_x` float DEFAULT NULL,
  `position_y` float DEFAULT NULL,
  `position_z` float DEFAULT NULL,
  `heading` float DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `restaurant_id` (`restaurant_id`),
  CONSTRAINT `sn_rest_tv_displays_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `sn_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


CREATE TABLE IF NOT EXISTS `sn_rest_drinks_machine_supplies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `restaurant_id` varchar(50) NOT NULL,
  `machine_index` int(11) NOT NULL,
  `machine_type` enum('soda_juice','coffee') NOT NULL,
  `supplies` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '{}' CHECK (json_valid(`supplies`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_machine` (`restaurant_id`, `machine_index`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `machine_type` (`machine_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;