-- updater_default.sql for gruppe6_players
-- This will update the default values for ranks and contracts columns to '{}'
-- Note: ALTER TABLE ... ALTER COLUMN ... SET DEFAULT is supported in MySQL 8.0+

ALTER TABLE gruppe6_players
  ALTER COLUMN ranks SET DEFAULT '{}',
  ALTER COLUMN contracts SET DEFAULT '{}';

-- For older MySQL versions, use:
-- ALTER TABLE gruppe6_players MODIFY ranks TEXT NOT NULL DEFAULT '{}';
-- ALTER TABLE gruppe6_players MODIFY contracts TEXT NOT NULL DEFAULT '{}';

