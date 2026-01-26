# PD Boss Menu

A comprehensive police department management system for QBX Core (FiveM). Supports multiple departments (LSPD, LSCSO) with role-based permissions, offline employee management, department banking, bonus payments, and Discord webhook integration.

## Features

### Employee Management
- **View Employees**: See all department employees (both online and offline)
- **Hire New Employees**: Recruit new officers from nearby civilians
- **Fire Employees**: Terminate employees (works for both online and offline players)
- **Rank Changes**: Promote or demote employees through 14-15 rank tiers
- **Offline Support**: Full management capabilities for offline players

### Financial Management
- **Department Funds**: Central banking system for department finances
- **Deposits**: Add money to department funds from your cash
- **Withdrawals**: Withdraw department funds to your cash
- **Bonus Payments**: Pay one-time bonuses to employees (Command+ only)
- **Transaction History**: Complete audit trail of all financial actions

### Permission System
- **Role-Based Access**: Granular permissions per rank grade
- **Configurable Permissions**:
  - `viewEmployees` - View employee roster
  - `viewBanking` - Access financial information
  - `viewDisciplinary` - View disciplinary records
  - `hireEmployees` - Hire new employees
  - `fireEmployees` - Terminate employees
  - `changeRanks` - Promote/demote employees
  - `viewReports` - Access reports
  - `accessSettings` - Manage menu settings
  - `payBonuses` - Pay performance bonuses (Grade 11+ by default)

### Multi-Department Support
- **LSPD (Los Santos Police Department)**: 14 ranks from Cadet to Chief
- **LSCSO (Los Santos County Sheriff's Office)**: 15 ranks from Cadet to Sheriff
- **Department Themes**: Unique UI themes for each department
- **Separate Configurations**: Per-department boss ranks and bonus permissions

### Discord Webhooks
- **Personnel Actions**: Hiring, firing, promotions, demotions
- **Financial Actions**: Deposits, withdrawals, bonus payments
- **Department Theming**: Color-coded embeds per department
- **Detailed Logging**: Performer info, recipient info, amounts, reasons

## Dependencies

| Resource | Required | Purpose |
|----------|----------|---------|
| `qbx_core` | Yes | Core framework (QBX/Qbox) |
| `ox_lib` | Yes | UI notifications and library functions |
| `ox_target` | Yes | Interaction targeting system |
| `oxmysql` | Yes | Database operations |

## Installation

1. **Download** the resource and place it in your `resources/[standalone]` folder
2. **Add** to your `server.cfg`:
   ```cfg
   ensure pd_boss_menu
   ```
3. **Configure** `shared/config.lua` with your settings
4. **Restart** your server

## Configuration

### config.lua

```lua
-- Supported jobs that can use this boss menu
Config.SupportedJobs = {'police', 'lscso'}

-- Boss ranks by job (ranks that have isboss = true)
Config.BossRanks = {
    police = {'commander', 'deputy chief', 'assistant chief', 'chief'},
    lscso = {'assistant chief deputy', 'chief deputy', 'assistant sheriff', 'under sheriff', 'sheriff'}
}

-- Minimum grade required to pay bonuses (command+)
Config.BonusMinGrade = {
    police = 11,  -- Commander+
    lscso = 11    -- Assistant Chief Deputy+
}

-- Menu location (target zone)
Config.MenuLocation = vector3(4461.6486, -978.0023, 30.5359)

-- Blip settings
Config.Blip = {
    enabled = true,
    sprite = 60,
    color = 29,
    scale = 0.8,
    label = 'PD Boss Menu'
}

-- Hiring proximity (distance to search for nearby players)
Config.HiringProximity = 10.0
```

### Discord Webhooks

```lua
Config.Webhooks = {
    -- Webhook for personnel actions (hire, fire, promotions)
    personnel = 'https://discord.com/api/webhooks/xxx/xxx',

    -- Webhook for financial actions (deposits, withdrawals, bonuses)
    finance = 'https://discord.com/api/webhooks/xxx/xxx',

    -- Optional: Use a single webhook for all actions (fallback)
    all = 'https://discord.com/api/webhooks/xxx/xxx'
}
```

Leave webhook URLs empty (`''`) to disable webhooks.

## Rank Structure

### LSPD (Police) - 14 Ranks
| Grade | Rank | Boss Access |
|-------|------|-------------|
| 1 | Cadet | No |
| 2 | Probationary Officer | No |
| 3 | Officer | No |
| 4 | Senior Officer | No |
| 5 | Corporal | No |
| 6 | Sergeant | No |
| 7 | Staff Sergeant | No |
| 8 | Lieutenant | No |
| 9 | Captain | No |
| 10 | Major | No |
| 11 | Commander | Yes |
| 12 | Deputy Chief | Yes |
| 13 | Assistant Chief | Yes |
| 14 | Chief | Yes |

### LSCSO (Sheriff) - 15 Ranks
| Grade | Rank | Boss Access |
|-------|------|-------------|
| 1 | Cadet | No |
| 2 | Deputy | No |
| 3 | Senior Deputy | No |
| 4 | Corporal | No |
| 5 | Sergeant | No |
| 6 | Staff Sergeant | No |
| 7 | Master Sergeant | No |
| 8 | Lieutenant | No |
| 9 | Captain | No |
| 10 | Major | No |
| 11 | Assistant Chief Deputy | Yes |
| 12 | Chief Deputy | Yes |
| 13 | Assistant Sheriff | Yes |
| 14 | Under Sheriff | Yes |
| 15 | Sheriff | Yes |

## Commands

| Command | Description |
|---------|-------------|
| `/pdboss` | Open the boss menu (permission required) |
| `/closeboss` | Force close the menu |
| `/fixmenu` | Fix stuck menu state |

## Client Events

| Event | Description |
|-------|-------------|
| `pd_boss:client:updateData` | Receive updated menu data |
| `pd_boss:client:getBossPosition` | Get boss position for nearby player search |
| `pd_boss:client:updateNearbyPlayers` | Receive nearby players list |
| `pd_boss:client:updateRankPermissions` | Receive rank permission data |
| `pd_boss:client:updateUserPermissions` | Receive user's permissions |
| `pd_boss:client:receiveTransactions` | Receive transaction history |

## Server Events

| Event | Description |
|-------|-------------|
| `pd_boss:server:directGetData` | Request menu data |
| `pd_boss:server:hire` | Hire a new employee |
| `pd_boss:server:fire` | Fire an employee |
| `pd_boss:server:setRank` | Change employee rank |
| `pd_boss:server:deposit` | Deposit to department funds |
| `pd_boss:server:withdraw` | Withdraw from department funds |
| `pd_boss:server:payBonus` | Pay bonus to employee |
| `pd_boss:server:getNearbyPlayers` | Get nearby civilians for hiring |
| `pd_boss:server:getRankPermissions` | Get rank permission settings |
| `pd_boss:server:saveRankPermissions` | Save rank permission settings |
| `pd_boss:server:getUserPermissions` | Get current user's permissions |
| `pd_boss:server:getTransactions` | Get transaction history |

## Database Tables

The resource automatically creates the following tables:

### pd_funds
Stores department fund balance.

```sql
CREATE TABLE `pd_funds` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `amount` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`)
)
```

### pd_transactions
Stores transaction history for auditing.

```sql
CREATE TABLE `pd_transactions` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `transaction_type` varchar(20) NOT NULL,
    `amount` int(11) NOT NULL,
    `officer_name` varchar(100) NOT NULL,
    `officer_citizenid` varchar(50) NOT NULL,
    `reason` text,
    `balance_after` int(11) NOT NULL,
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
)
```

### pd_rank_permissions
Stores customized rank permissions.

```sql
CREATE TABLE `pd_rank_permissions` (
    `grade` int(11) NOT NULL,
    `viewEmployees` tinyint(1) NOT NULL DEFAULT 0,
    `viewBanking` tinyint(1) NOT NULL DEFAULT 0,
    `viewDisciplinary` tinyint(1) NOT NULL DEFAULT 0,
    `hireEmployees` tinyint(1) NOT NULL DEFAULT 0,
    `fireEmployees` tinyint(1) NOT NULL DEFAULT 0,
    `changeRanks` tinyint(1) NOT NULL DEFAULT 0,
    `viewReports` tinyint(1) NOT NULL DEFAULT 0,
    `accessSettings` tinyint(1) NOT NULL DEFAULT 0,
    `payBonuses` tinyint(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (`grade`)
)
```

## UI Themes

### LSPD Theme (Blue/White/Black)
- Primary colors inspired by LA Police Department
- Dark blue headers and accents
- Professional law enforcement aesthetic

### LSCSO Theme (Browns/Tans)
- Colors inspired by county sheriff aesthetics
- Brown and tan color scheme
- Rustic law enforcement aesthetic

## File Structure

```
pd_boss_menu/
├── client/
│   └── client.lua          # Client-side logic
├── server/
│   └── server.lua          # Server-side logic
├── shared/
│   └── config.lua          # Configuration file
├── web/
│   ├── index.html          # Main UI page
│   ├── style.css           # UI styling
│   ├── script.js           # Main UI logic
│   ├── animations.js       # Animation utilities
│   ├── admin_logs.js       # Admin log functionality
│   ├── time_tracking.js    # Time tracking features
│   ├── transaction_display.js # Transaction history UI
│   └── lib/
│       ├── chart.min.js    # Chart library
│       └── xlsx.min.js     # Excel export library
├── fxmanifest.lua          # Resource manifest
└── README.md               # This file
```

## Troubleshooting

### Menu won't open
- Verify you have an authorized job (police or lscso)
- Check you're at the correct target location
- Ensure ox_target is running
- Check server console for errors

### Employees not showing
- Verify employees are in the correct job
- Check database connection
- Review server console for SQL errors

### Webhooks not working
- Verify webhook URLs are correct
- Check Discord webhook permissions
- Ensure URLs are not empty strings

### Permission issues
- Verify your rank grade in jobs.lua matches config
- Check pd_rank_permissions table
- Review boss rank configuration

## Support

For issues and feature requests, please contact your server administrator or resource maintainer.

## License

This resource is provided as-is for use on your FiveM server. Redistribution or resale is not permitted without authorization.

## Changelog

### v1.0.0
- Initial release
- Multi-department support (LSPD, LSCSO)
- Offline employee management
- Department fund management
- Bonus payment system
- Discord webhook integration
- Department-themed UI
- Comprehensive permission system
