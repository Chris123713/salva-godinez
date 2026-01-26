# Quick Start Guide - Advanced Elevator System v2.0

## 🚀 Getting Started in 5 Minutes

### Step 1: Verify Installation
The elevator system is already in your resources folder. Just ensure it's configured correctly.

### Step 2: Add to server.cfg
Add these lines to your `server.cfg` (if not already added):
```cfg
ensure ox_lib
ensure custom_elevator
```

### Step 3: Restart Server
```
refresh
restart custom_elevator
```

### Step 4: Test It!
1. Go to coordinates: `440.84, -981.97, 30.69` (LSPD Lobby - Example elevator)
2. You should see either:
   - **ox_target:** Target prompt "Call Elevator"
   - **3D Text:** Green text "[E] Call Elevator"
3. Interact to test the system

## ✅ What You Get Out of the Box

The system comes pre-configured with 5 example elevators:

1. **LSPD Main Elevator** - Police department with job-locked roof
2. **LSPD Basement Access** - Separate shaft for evidence/garage
3. **Pillbox Hill Medical** - Hospital elevator with job locks
4. **Legion Square Office** - Public building (no restrictions)
5. **Eclipse Towers** - Luxury apartment elevator

## 🎯 Common Customizations

### Change Interaction Mode

Edit `config.lua`:
```lua
Config.Interaction = {
    mode = "both",  -- Options: "target", "text", "both"
}
```

- **"target"** - Requires ox_target (modern, best UX)
- **"text"** - Uses 3D text (works everywhere)
- **"both"** - Supports both (recommended)

### Adjust Travel Speed

Make elevators faster or slower:
```lua
Config.Movement = {
    speedPerFloor = 3000,  -- Lower = faster (in milliseconds)
}
```

**Recommendations:**
- Fast elevator: 2000ms (2 seconds per floor)
- Realistic: 3000ms (3 seconds per floor)  ← Default
- Slow/cinematic: 5000ms (5 seconds per floor)

### Disable Advanced Features

If you want the old simple teleport system:
```lua
Config.CallSystem = {
    enabled = false,  -- Disables call system, queue, state sync
}
```

### Turn Off Sounds

If you haven't added sound files yet:
```lua
Config.Sounds = {
    enabled = false,  -- No sound effects
}
```

## 📍 Adding Your First Custom Elevator

### 1. Find Coordinates

In-game, go to your location and use:
```
/getcoords
```
Or Lua command:
```lua
/lua local pos = GetEntityCoords(PlayerPedId()) print(pos)
```

### 2. Add to Config

Edit `config.lua` and add to `Config.ElevatorShafts`:

```lua
{
    name = "My Custom Elevator",
    floors = {
        {
            id = "my_floor1",
            name = "Ground Floor",
            coords = vector3(YOUR_X, YOUR_Y, YOUR_Z),
            heading = 0.0,  -- Direction player faces
            blip = true  -- Show on map
        },
        {
            id = "my_floor2",
            name = "Second Floor",
            coords = vector3(YOUR_X, YOUR_Y, YOUR_Z + 10),  -- Higher Z
            heading = 0.0
        }
    }
}
```

### 3. Restart Resource

```
restart custom_elevator
```

## 🔒 Adding Job Restrictions

To lock a floor to police only:

```lua
{
    id = "secure_floor",
    name = "Secure Area",
    coords = vector3(x, y, z),
    heading = 0.0,
    jobLock = {
        jobs = {"police", "sheriff"},  -- Allowed jobs
        requireOnDuty = true  -- Must be on duty
    }
}
```

**Common Job Names:**
- `police`, `sheriff`, `lscso`, `safr`
- `ambulance`, `doctor`
- `mechanic`
- `boss`, `ceo`

**Note:** Job names must match exactly what's in your `qbx_core/shared/jobs.lua`

## 🎨 UI Customization

### Change Colors

Edit `html/style.css`:

**Green "Ready" status to Blue:**
```css
.elevator-status.status-ready {
    background: rgba(33, 150, 243, 0.2);  /* Blue */
    color: #2196F3;
}
```

**Floor buttons to Red:**
```css
.floor-button:hover {
    border-color: rgba(244, 67, 54, 0.5);  /* Red */
}
```

## 🔊 Adding Sounds (Optional)

### 1. Download Sound Files

Get free elevator sounds from:
- Freesound.org
- Zapsplat.com
- YouTube Audio Library

### 2. Convert to OGG

Use https://convertio.co/mp3-ogg/

### 3. Name Files Correctly

Save in `html/sounds/` as:
- `elevator_ding.ogg`
- `elevator_doorOpen.ogg`
- `elevator_doorClose.ogg`
- `elevator_movement.ogg`

### 4. Enable Sounds

```lua
Config.Sounds = {
    enabled = true,
}
```

## 🐛 Quick Troubleshooting

### "Nothing happens when I press E"

**Solutions:**
1. Check interaction mode in config
2. Verify you're within 2.5m of coords
3. Check F8 console for errors
4. Try: `restart custom_elevator`

### "Job-locked floor won't let me in"

**Check:**
1. Are you the right job? `/showjob`
2. Do you need to be on duty? Check `requireOnDuty`
3. Job name spelling matches framework exactly

### "ox_target not working"

**Solutions:**
1. Ensure ox_target is installed and started
2. Set `Config.Interaction.mode = "target"` or `"both"`
3. Restart both resources:
   ```
   restart ox_target
   restart custom_elevator
   ```

### "Elevator moves but no effects"

**Check:**
1. `Config.CallSystem.enabled = true`
2. `Config.Effects.screenShake = true`
3. `Config.Effects.showDirectionArrows = true`

## 📊 Performance Check

After installation, check resource impact:

```
resmon
```

Look for `custom_elevator`:
- **Idle:** Should be ~0.00ms
- **Active:** Should be <0.05ms

If higher, try:
1. Reduce number of elevator shafts
2. Disable unused effects
3. Turn off sounds if not needed

## 🎓 Learning Path

1. **Day 1:** Test default elevators, understand basic config
2. **Day 2:** Add your first custom elevator
3. **Day 3:** Add job restrictions
4. **Day 4:** Add sounds and customize UI
5. **Day 5:** Create multiple shafts for complex buildings

## 💡 Pro Tips

1. **Test coordinates** before adding to production
   - Teleport there first: `/tp x y z`
   - Make sure it's a good spawn point

2. **Use multiple shafts** for realism
   - Main elevator (public)
   - Service elevator (staff)
   - VIP elevator (restricted)

3. **Keep travel times realistic**
   - Don't make elevators instant (breaks immersion)
   - 3 seconds per floor is realistic

4. **Add blips strategically**
   - Only on main entrances
   - Not on every floor (map clutter)

5. **Group by building**
   - Put all building elevators together in config
   - Use comments to organize

## 📞 Need Help?

1. Read full `README.md` for detailed documentation
2. Check `html/sounds/SOUNDS_README.md` for sound setup
3. Review example elevators in `config.lua`
4. Check F8 console for errors
5. Verify ox_lib is updated

## ✨ You're Ready!

The elevator system is now fully functional and ready to use. Start with the example elevators, then customize to fit your server's needs.

**Happy elevating!** 🚁

---

*For full documentation, see README.md*
*For system architecture, see the implementation plan*
