# Advanced MultiJob Menu

A professional multi-job management system for QBX Core and QB-Core frameworks. Seamlessly manage multiple jobs, toggle duty status, and switch between positions with an intuitive, modern interface.

## Features

- **Multi-Job Management**: View and manage all your jobs from one convenient menu
- **One-Click Job Switching**: Instantly switch between any of your available jobs
- **Duty Toggle**: Go on/off duty with a single button click
- **Unemployed Duty Control**: Configurable option to allow/disable duty toggle for civilian/unemployed job
- **Unemployed Job Protection**: Advanced button is hidden for unemployed job (cannot quit civilian job)
- **Real-Time Updates**: Menu automatically refreshes when job data changes
- **Modern UI Design**: Beautiful glassmorphism interface with smooth animations
- **Framework Auto-Detection**: Automatically detects and works with QBX Core or QB-Core
- **Debug Mode**: Enable detailed logging for troubleshooting
- **Zero Configuration**: Works out of the box, no setup required

## Dependencies

### Required
- **QBX Core** (`qbx_core`) **OR** **QB-Core** (`qb-core`)
  - Only one framework is required, not both
  - The script automatically detects which framework is running

### Optional
- **Multi-Job System**: For QBX Core, ensure multi-job is enabled by setting the convar:
  ```
  set qbx:max_jobs_per_player [number]
  ```
  - Example: `set qbx:max_jobs_per_player 5` (allows up to 5 jobs per player)
  - For QB-Core, multi-job support depends on your framework version

## Installation

### Step 1: Download and Extract
1. Download the resource files
2. Extract the `advanced-multijob` folder to your server's `resources/[standalone]` directory
   - Full path should be: `resources/[standalone]/advanced-multijob/`

### Step 2: Add to Server Configuration
1. Open your `server.cfg` file
2. Add the following line:
   ```
   ensure advanced-multijob
   ```
3. Save the file

### Step 3: Restart Server
1. Restart your FiveM server
2. The resource will automatically detect your framework (QBX Core or QB-Core)
3. No additional configuration needed!

## Configuration

All configuration options are located in `config.lua`. This file is editable even after encryption.

### Command Configuration

```lua
Config.Command = 'jobm'
```

Change this to whatever command you want (e.g., 'jobs', 'work', 'employment').

After changing the command, restart your server for the changes to take effect.

### Duty Toggle Configuration

```lua
Config.AllowUnemployedDuty = false
```

- **`false`** (default): Duty button is hidden for unemployed/civilian job
- **`true`**: Players can toggle duty for unemployed job

**Note:** When set to `false`, the duty toggle button will be hidden in the UI for unemployed players, and the server will block any attempts to toggle duty for the unemployed job.

### Debug Mode

```lua
Config.Debug = false
```

- **`false`** (default): No debug messages
- **`true`**: Enables detailed debug logging in server and client console

**When to use Debug Mode:**
- Menu not opening
- Jobs not showing correctly
- Framework detection issues
- Job switching not working
- Duty toggle problems
- Any unexpected behavior

Debug messages will appear in your server console and F8 client console with the prefix `[Advanced MultiJob - SERVER]` or `[Advanced MultiJob - CLIENT]`.

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `/jobm` (default) | Opens the multi-job management menu |

**Note:** The default command is `/jobm`, but you can customize it in `config.lua`.

### Exports

#### Client-Side Exports

```lua
-- Open the multi-job menu
exports['advanced-multijob']:OpenMultiJobMenu()

-- Close the multi-job menu
exports['advanced-multijob']:CloseMultiJobMenu()
```

#### Example Usage in Other Scripts

```lua
-- Open menu from another script
RegisterCommand('openjobmenu', function()
    exports['advanced-multijob']:OpenMultiJobMenu()
end, false)

-- Close menu programmatically
exports['advanced-multijob']:CloseMultiJobMenu()
```

### Keybinds

You can add a keybind to open the menu using your keybind system:

```lua
RegisterKeyMapping('jobm', 'Open MultiJob Menu', 'keyboard', 'F6')
```

**Note:** If you changed the command in `config.lua`, use your custom command name instead of `'jobm'` in the keybind.

Replace `F6` with your desired key.

## Menu Features

### Current Job Section
- Displays your active job name and label
- Shows current duty status (On Duty/Off Duty)
- **Toggle Duty Button**: Click to switch between on/off duty
  - Hidden for unemployed job if `Config.AllowUnemployedDuty = false`
- **Advanced Button**: Click to quit/resign from your current job
  - Hidden for unemployed job (cannot quit civilian job)
  - A confirmation dialog will appear before quitting

### Your Jobs Section
- Lists all jobs you have access to
- Displays job grade and grade name for each job
- **Switch Button**: Click to change your active job to this position
- **Advanced Button**: Click to quit/resign from this specific job
  - Hidden for unemployed job (cannot quit civilian job)
  - A confirmation dialog will appear before quitting
- Current job is highlighted with a checkmark (✓)
- Job count indicator showing total number of jobs

### Quitting Jobs
To quit a job:
1. **For Current Job**: Click the "Advanced" button in the Current Job section
2. **For Other Jobs**: Click the "Advanced" button next to the job in the Your Jobs list
3. Confirm your decision in the popup dialog
4. The job will be removed from your available jobs

**Important:** 
- Quitting a job cannot be undone
- If you quit your current job, you will automatically be set to unemployed
- You cannot quit the unemployed/civilian job (button is hidden)

## Framework Compatibility

### QBX Core
- ✅ Full multi-job support
- ✅ Job switching
- ✅ Duty toggle
- ✅ Unemployed duty toggle (configurable)
- ✅ Quit job functionality
- ✅ Real-time job updates

### QB-Core
- ✅ Full multi-job support (if enabled in your version)
- ✅ Job switching
- ✅ Duty toggle
- ✅ Unemployed duty toggle (configurable)
- ✅ Quit job functionality
- ✅ Real-time job updates

## Troubleshooting

### Menu Not Opening
- Ensure QBX Core or QB-Core is running and started
- Check that the resource is properly started: `ensure advanced-multijob`
- Verify framework detection in server console
- Enable `Config.Debug = true` to see detailed logs

### Jobs Not Showing
- For QBX Core: Ensure multi-job is enabled with the convar `qbx:max_jobs_per_player`
- Verify that players actually have multiple jobs assigned
- Check that job definitions exist in your framework's job system
- Enable debug mode to see what jobs are being detected

### Duty Toggle Not Working
- Ensure your framework version supports duty toggling
- Check that the job has duty functionality enabled
- If unemployed: Verify `Config.AllowUnemployedDuty` setting in `config.lua`
- Enable debug mode to see duty toggle attempts

### Duty Button Not Showing for Unemployed
- This is expected behavior when `Config.AllowUnemployedDuty = false`
- To show the button, set `Config.AllowUnemployedDuty = true` in `config.lua`
- Restart server after changing the config

### Advanced Button Not Showing for Unemployed
- This is intentional - you cannot quit the unemployed/civilian job
- The Advanced button is automatically hidden for unemployed job
- This cannot be changed (safety feature)

### Debug Mode
If you're experiencing issues:
1. Set `Config.Debug = true` in `config.lua`
2. Restart your server
3. Check server console and client F8 console for debug messages
4. Look for messages prefixed with `[Advanced MultiJob - SERVER]` or `[Advanced MultiJob - CLIENT]`
5. Share these messages when requesting support

## Support

For support, updates, and community:
- Check the resource documentation
- Contact the developer through your purchase platform
- Review framework-specific documentation for QBX Core or QB-Core
- Enable debug mode and check console logs for detailed information

## Version

**Current Version:** 1.0.0

## License

This resource is protected and encrypted. Unauthorized distribution or modification is prohibited.

---

**Note:** This resource requires a framework that supports multi-job functionality. Ensure your QBX Core or QB-Core installation has multi-job enabled before use.
