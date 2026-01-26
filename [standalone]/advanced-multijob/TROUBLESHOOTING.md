# Troubleshooting Guide

## Issues You're Experiencing

### 1. "Not Clocked In" but also shows "Clocked In"
**Cause:** The encrypted client isn't properly communicating on-duty status to our wrapper.

### 2. Location Status Shows "Checking location..."
**Cause:** The location check isn't updating the UI properly.

### 3. Shift Duration Not Working
**Cause:** Clock-in timestamp not being passed from server to client.

---

## Quick Fix Steps

### Step 1: Restart the Resource
```
restart advanced-multijob
```

### Step 2: Run the SQL File
Make sure you've executed `install.sql` in your database.

### Step 3: Check Debug Output
Debug mode is now enabled. When you restart, you should see:
```
[MultiJob] Clock-in zones loaded successfully
[MultiJob] Use /jobdebug to check location and theme data
```

### Step 4: Test Debug Command
In-game, type:
```
/jobdebug
```

This will show:
- Your current job
- On duty status
- If you're at a clock-in location
- Distance to nearest location
- Theme info

### Step 5: Check Console for Errors
Look in your server console and F8 client console for any red errors.

---

## Common Issues & Solutions

### "Cannot find module 'ox_lib'"
**Solution:** Make sure `ox_lib` is started before `advanced-multijob` in your server.cfg

### "MySQL.query.await is not a function"
**Solution:** Make sure `oxmysql` is started and working

### Location status never updates
**Solution:** Check that:
1. You have the correct job in Config.ClockinLocations
2. The coordinates match your server's locations
3. You're within Config.MaxClockinDistance (default: 10 meters)

### Theme not applying
**Solution:** Make sure your job name exactly matches the key in Config.JobThemes

---

## Testing Checklist

1. **Database:**
   - [ ] Ran `install.sql`
   - [ ] Table `job_clockin_logs` exists
   - [ ] Can query: `SELECT * FROM job_clockin_logs`

2. **Server Start:**
   - [ ] No red errors in console
   - [ ] See "Clock-in zones loaded successfully"
   - [ ] ox_lib loads before advanced-multijob

3. **In-Game:**
   - [ ] Run `/jobdebug` - shows your job info
   - [ ] Visit your job's location (e.g., MRPD for police)
   - [ ] Debug shows "At Location: true"
   - [ ] Open menu with `/jobm`

4. **UI Check:**
   - [ ] See job name and department
   - [ ] Location status shows green "At [Location Name]"
   - [ ] Theme colors match your job
   - [ ] Clock In button is enabled

---

## Manual Testing Steps

### Test 1: Check Location Detection
```lua
-- In F8 console
/jobdebug
```
Expected: Shows your location and distance

### Test 2: Check Database
```sql
-- In database
SELECT * FROM job_clockin_logs ORDER BY id DESC LIMIT 5;
```
Expected: See recent clock-in entries

### Test 3: Check Theme
```lua
-- Open menu
/jobm
```
Expected: Colors should match your job (blue for police, red for medical, etc.)

---

## If Still Not Working

### Option 1: Disable Features Temporarily
In `config.lua`:
```lua
Config.RequirePhysicalClockin = false  -- Allow clock-in anywhere
Config.EnableTimeTracking = false      -- Disable database logging
```
Then restart and test basic functionality.

### Option 2: Check Encrypted Files
The issue might be that the encrypted `client/main.lua` and `server/main.lua` are incompatible with our wrapper approach.

**Test if encrypted files are the issue:**
1. Check if duty toggle works normally (without our modifications)
2. If basic duty toggle works, the wrapper should work too

### Option 3: Check F8 Browser Console
1. Open menu with `/jobm`
2. Press F8
3. Type in console: `console.log(currentData)`
4. Check if location data is present

---

## Enable/Disable Features

You can toggle features in `config.lua`:

```lua
-- Require physical location to clock in
Config.RequirePhysicalClockin = true/false

-- Track time in database
Config.EnableTimeTracking = true/false

-- Show shift duration timer
Config.ShowShiftDuration = true/false

-- Show distance when away from location
Config.ShowDistanceWhenTooFar = true/false
```

---

## Getting Help

If you're still stuck, provide:
1. Output of `/jobdebug`
2. Any red errors from server console
3. F8 browser console errors
4. Screenshot of the menu showing the issue

Debug mode is enabled, so you'll get detailed console output to help diagnose issues!
