# Sierra Valley RP - LB-Tablet Config Backup

**Version**: 1.5.5 (needs update to 1.5.6)
**Date**: 2026-01-19
**Purpose**: Config migration reference for updating lb-tablet

---

## CRITICAL SETTINGS

### DatabaseChecker (DISABLED - needs restore)
```lua
Config.DatabaseChecker.Enabled = false -- DISABLED: databaseChecker.lua is corrupted
Config.DatabaseChecker.AutoFix = false
```

### Framework & Scripts
```lua
Config.Framework = "auto"  -- Qbox detected
Config.BillingScript = "auto"
Config.HousingScript = "auto"
Config.JailScript = "auto"  -- WARNING: "No jail script detected" in logs
```

---

## GENERAL SETTINGS

### Item & Duty
```lua
Config.Item.Require = true
Config.Item.Name = "tablet"
Config.Item.Inventory = "auto"
Config.RequireItemDutyBlips = true
Config.RequireDutyMDT = true
Config.RequireDutyDispatch = true
```

### Open Command & Keybind
```lua
Config.OpenCommand = "tablet"
Config.KeyBinds.Open.bind = "F5"
```

### Locale & Currency
```lua
Config.DefaultLocale = "en"
Config.DateLocale = "en-US"
Config.CurrencyFormat = "$%s"
```

---

## DUTY BLIP OPTIONS
```lua
Config.DutyBlipOptions = {
    Show = true,
    Category = 7,
    Sprite = 1,
    Color = 0,
    FriendIndicator = true,
    Outline = false,
    OutlineColour = { 93, 182, 229 },
    Scale = 0.9,
    ShortRange = true,
    ShowHeading = true,
    Name = "{name} - {callsign}",
    VehicleTypes = {
        car = 56,
        bike = 226,
        heli = 64,
        boat = 455,
        plane = 423,
    }
}
Config.DutyBlipInterval = 5000
```

---

## DISPATCH SETTINGS

### Base Dispatch
```lua
Config.DispatchEnabled = true
Config.DispatchVisible = true
Config.DispatchPosition = "right"
Config.DispatchCompatibility = true
Config.AllowClientDispatch = true
Config.ShowDispatchWithoutItem = true
Config.HideDispatchWhenDead = true

Config.BaseDispatch.Enabled = true
Config.BaseDispatch.RequireWitness = true
Config.BaseDispatch.RequireLos = true
Config.BaseDispatch.MaxDistance = 100
Config.BaseDispatch.CallPolice = true
Config.BaseDispatch.Chance = 100
Config.BaseDispatch.IgnorePolice = true
```

### Dispatch Actions (Custom Cooldowns)
```lua
CarJacking = {
    police = true, ambulance = false,
    cooldown = 22, serverCooldown = 22,
    dispatch = { priority = "high", time = 180 }
}
VehicleTheft = {
    police = true, ambulance = false,
    cooldown = 37, serverCooldown = 37,
    dispatch = { priority = "medium", time = 180 }
}
Explosion = {
    police = true, ambulance = true,
    serverCooldown = 10,
    dispatch = { priority = "medium", time = 180 }
}
Gunshot = {
    police = true, ambulance = true,
    cooldown = 60, serverCooldown = 0,
    dispatch = { priority = "high", time = 300 }
}
Armed = {
    police = true, ambulance = false,
    cooldown = 120, serverCooldown = 0,
    dispatch = { priority = "medium", time = 120 }
}
```

### Dispatch Blip
```lua
Config.DispatchBlip = {
    Enabled = true,
    Default = {
        Enabled = true,
        Type = "default",
        Radius = 50.0,
        Sprite = 161,
        Color = 1,
        Size = 1.5,
        ShortRange = false,
        Label = "{dispatch_title}"
    }
}
```

---

## LOCATIONS
```lua
Config.Locations = {
    { position = vector2(428.9, -984.5), name = "MRPD", description = "Mission Row Police Department" },
    { position = vector2(-1088.584595, -813.173462), name = "Vespucci", description = "Vespucci Police Department" },
    { position = vector2(-444.768951, 6020.234375), name = "Paleto Sheriff's Office", description = "Paleto Bay Sheriff's Office (LSCSO)" },
    { position = vector2(304.2, -587.0), name = "Pillbox", description = "Pillbox Medical Hospital" }
}
```

---

## EXTERNAL IMAGE SETTINGS
```lua
Config.AllowExternal = {
    Police = true,
    lscso = true,
    Ambulance = true,
    Registration = true,
    Gallery = true,
    Mail = false,
    Other = false
}

Config.ExternalBlacklistedDomains = {
    "imgur.com", "discord.com", "discordapp.com"
}

Config.UploadWhitelistedDomains = {
    "fivemanage.com", "fmfile.com", "cfx.re"
}
```

---

## POLICE APP SETTINGS

### Header
```lua
Config.Police.Header = {
    Logo = "./assets/img/icons/police/logo.webp",
    Title = "Los Santos Police Department",
    Subtitle = "Mobile Police Terminal"
}
```

### Callsign
```lua
Config.Police.Callsign.AutoGenerate = true
Config.Police.Callsign.Format = "11-1111"
Config.Police.Callsign.RequireTemplate = true
Config.Police.Callsign.AllowChange = true
```

### Jail
```lua
Config.Police.Jail.Refresh = true
Config.Police.Jail.Interval = 60
Config.Police.Jail.CanUnjail = "auto"
Config.Police.Jail.AllowJailJailed = true
```

### Charges
```lua
Config.Police.Charges.CountMethod = "stack"
```

### Triangulation
```lua
Config.Police.Triangulation.RequireCall = false
Config.Police.Triangulation.CellTowerTime = 500
Config.Police.Triangulation.SuccessRate = 50
Config.Police.Triangulation.RangeMultiplier = 1.0
```

### Phone Unlock
```lua
Config.Police.PhoneUnlock.Time = { 120, 240 }
Config.Police.PhoneUnlock.Chance = 50
Config.Police.PhoneUnlock.Attempts = 2
```

### Profile Fields
```lua
Config.Police.Profile.Fields = {
    dob = true, phoneNumber = true, gender = true,
    job = true, identifier = false, fingerprint = true
}
```

### Vehicle Fields
```lua
Config.Police.Vehicle.Fields = {
    model = true, plate = true, color = true,
    location = true, owner = true
}
```

### Offence Classes
```lua
Config.Police.OffenceClasses = {
    infraction = "green",
    misdemeanor = "orange",
    felony = "red"
}
```

### Report Types
```lua
Config.Police.ReportTypes = {
    "Assault", "Robbery", "Burglary", "Theft", "Fraud", "Homicide",
    "Kidnapping", "Arson", "Vandalism", "Drug Offense", "Traffic Violation",
    "Domestic Violence", "Cybercrime", "Weapons Violation", "Public Disturbance",
    "Trespassing", "Harassment", "Missing Person", "Extortion", "Identity Theft",
    "Interrogation", "Other"
}
```

### Warrant Types
```lua
Config.Police.WarrantTypes = {
    "Arrest Warrant", "Search Warrant", "Bench Warrant", "Extradition Warrant",
    "Probation Violation Warrant", "Material Witness Warrant",
    "Execution Warrant", "Parole Violation Warrant"
}
```

### Warrant Statuses
```lua
Config.Police.WarrantStatuses = {
    active = { color = "red", label = "Active" },
    cancelled = { color = "orange", label = "Cancelled" },
    expired = { color = "red", label = "Expired" }
}
```

### Unit Statuses
```lua
Config.Police.UnitStatuses = {
    available = { label = "Available", color = "green" },
    busy = { label = "Busy", color = "red" },
    at_station = { label = "At Station", color = "blue" },
    on_call = { label = "On Call", color = "yellow" }
}
```

### Templates
```lua
Config.Police.Templates = {
    Report = "# Report template\n\n**Date:**\n**Reported By:** (Name & Callsign / Badge number)\n\n**Incident Details:**\n**Evidence Collected:**\n**Actions Taken:**\n\n**Additional Notes:**",
    Case = "# Case template\n\n**Date Opened:**\n**Filed by:** (Name & Callsign / Badge number)\n\n**Incident Details:**\n**Key Evidence:**\n**Investigation Progress:**\n\n**Additional Notes:**",
    Warrant = "# Warrant template\n\n**Date Issued:**\n**Requested By:** (Name & Callsign / Badge number)\n\n**Reason:**\n**Location / Target:**\n**Execution Details:**\n\n**Additional Notes:**"
}
```

---

## POLICE PERMISSIONS (3 DEPARTMENTS)

### Police Department (police)
| Permission | create | edit | delete | view |
|------------|--------|------|--------|------|
| home | - | - | - | 0 |
| dispatch | - | - | 11 | 0 |
| unit | 11 | 11 | 11 | 0 |
| profile | - | 1 | - | 1 |
| vehicle | - | 1 | - | 1 |
| property | - | 11 | - | 0 |
| weapon | 1 | 1 | 11 | 1 |
| report | 1 | 5 | 11 | 1 |
| case | 1 | 6 | 11 | 0 |
| warrant | 3 | 3 | 11 | 1 |
| **offence** | **1** | **11** | **11** | **1** |
| employee | - | - | - | 1 |
| chat | 11 | 11 | 11 | 1 |
| jail | 1 | 11 | unjail:11 | 1 |
| phone | - | - | - | 1 (all advanced: 11) |
| logs | - | - | - | 11 |
| tag | 1 | - | 1 | - |
| license | add:1 | - | revoke:1 | 1 |
| bulletin | 11 | 11 | 11 | 1 |
| stash | - | - | - | 1 |

### Sheriff's Office (lscso)
Same as police with these differences:
- report.edit = 4
- case.edit = 4
- warrant.create/edit = 2

### State Police (sasp)
Same as police with these differences:
- report.edit = 5
- case.edit = 5
- warrant.create/edit = 2

---

## AMBULANCE APP SETTINGS

### Header
```lua
Config.Ambulance.Header = {
    Logo = "./assets/img/icons/ambulance/logo.webp",
    Title = " Santos Medical Services",
    Subtitle = "Mobile Database Terminal"
}
```

### Callsign
```lua
Config.Ambulance.Callsign.AutoGenerate = true
Config.Ambulance.Callsign.Format = "11-1111"
Config.Ambulance.Callsign.RequireTemplate = true
Config.Ambulance.Callsign.AllowChange = true
```

### Profile Fields
```lua
Config.Ambulance.Profile.Fields = {
    dob = true, phoneNumber = true, gender = true,
    height = true, bloodType = true,
    identifier = false, fingerprint = false
}
```

### Report Types
```lua
Config.Ambulance.ReportTypes = {
    "Injury", "Illness", "Vehicle Accident", "Overdose", "Cardiac Arrest",
    "Stroke", "Respiratory Distress", "Burn Injury", "Fall Injury", "Drowning",
    "Poisoning", "Seizure", "Trauma", "Allergic Reaction", "Shock",
    "Heatstroke", "Hypothermia", "Labor and Delivery", "Mental Health Crisis", "Other"
}
```

### Severities
```lua
Config.Ambulance.Severities = {
    minor = "green",
    moderate = "orange",
    severe = "red",
    critical = "red"
}
```

### Ambulance Permissions (all at grade 3 except view at 0)
```lua
Config.Ambulance.Permissions = {
    ["ambulance"] = {
        home = { view = 0 },
        dispatch = { view = 0, delete = 3 },
        unit = { view = 0, edit = 3, create = 3, delete = 3 },
        profile = { edit = 3, view = 0, bill = 1 },
        report = { create = 3, edit = 3, delete = 3, view = 0 },
        condition = { create = 3, edit = 3, delete = 3, view = 0 },
        employee = { view = 0 },
        chat = { create = 3, edit = 3, kick = 3, invite = 3, view = 0 },
        logs = { view = 3 },
        tag = { create = 3, delete = 3 },
        bulletin = { create = 3, pin = 3, delete = 3, edit = 3, view = 0 }
    }
}
```

---

## SERVICES COMPANIES
```lua
Config.Services.Companies = {
    { job = "police", name = "Police", canMessage = true, location = { name = "Mission Row", coords = { x = 428.9, y = -984.5 } } },
    { job = "ambulance", name = "Ambulance", canMessage = true, location = { name = "Pillbox", coords = { x = 304.2, y = -587.0 } } },
    { job = "mechanic", name = "Mechanic", location = { name = "LS Customs", coords = { x = -336.6, y = -134.3 } } },
    { job = "taxi", name = "Taxi", canMessage = true, location = { name = "Taxi", coords = { x = 984.2, y = -219.0 } } }
}
```

---

## UPLOAD SETTINGS
```lua
Config.UploadMethod.Video = "Fivemanage"
Config.UploadMethod.Image = "Fivemanage"
Config.UploadMethod.Audio = "Fivemanage"

Config.Video.Bitrate = 400
Config.Video.FrameRate = 24
Config.Video.MaxSize = 25
Config.Video.MaxDuration = 60

Config.Image.Mime = "image/webp"
Config.Image.Quality = 0.95
```

---

## CAMERA SETTINGS
```lua
Config.Camera.ShowTip = true
Config.Camera.Roll = true
Config.Camera.AllowRunning = true
Config.Camera.MaxFOV = 60.0
Config.Camera.MinFOV = 10.0

Config.Camera.Freeze.Enabled = true
Config.Camera.Freeze.MaxDistance = 10.0
Config.Camera.Freeze.MaxTime = 60
```

---

## KEY BINDINGS
| Action | Key |
|--------|-----|
| Open | F5 |
| Focus | LMENU (ALT) |
| Notification Up | UP |
| Notification Down | DOWN |
| Notification Dismiss | O |
| Notification View | G |
| Notification Respond | Z |
| Notification Expand | J |
| Flip Camera | UP |
| Take Photo | RETURN |
| Toggle Flash | E |
| Camera Mode Left | LEFT |
| Camera Mode Right | RIGHT |
| Roll Left | Z |
| Roll Right | C |
| Freeze Camera | X |
| Toggle Camera Tip | H |
| Unlock Tablet | SPACE |

---

## MIGRATION CHECKLIST

1. [ ] Download lb-tablet 1.5.6
2. [ ] Backup current config folder
3. [ ] Compare new config.lua with this document
4. [ ] Transfer all customizations (especially permissions!)
5. [ ] Restore databaseChecker.lua from backup
6. [ ] Set Config.DatabaseChecker.Enabled = true
7. [ ] Configure jail script if needed
8. [ ] Test offence/penal code viewing
9. [ ] Test all 3 police departments
10. [ ] Test ambulance app
