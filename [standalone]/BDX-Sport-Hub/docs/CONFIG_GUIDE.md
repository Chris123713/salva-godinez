# Configuration Guide

> **Complete guide to customizing BDX-Sport-Hub using config.lua**

---

## Overview

The `config.lua` file is the **customer-editable** configuration file. All settings here can be modified to customize prices, locations, language, and features without touching protected code.

---

## Basic Settings

```lua
Config.Debug = false           -- Set to true to see debug messages in console
Config.Framework = "esx"       -- Your framework: "qb" / "esx" / "vrp" / "custom"
Config.Target = "ox"           -- Target system: "qb" / "ox" / "none"
Config.EnablePeds = true       -- Enable/disable store NPCs
```

### Framework Options
| Value | Description |
|-------|-------------|
| `"qb"` | QBCore Framework |
| `"esx"` | ESX Framework |
| `"vrp"` | vRP Framework |
| `"custom"` | Custom framework (requires editing framework-bridge.lua) |

### Target Options
| Value | Description |
|-------|-------------|
| `"ox"` | ox_target (recommended) |
| `"qb"` | qb-target |
| `"none"` | Text-based interaction (E key) |

### Custom Framework Resource Name
If your framework resource has a non-standard name:
```lua
Config.FrameworkResourceName = "my-custom-esx"  -- Default: nil (uses standard names)
```

---

## VIP Content Language

Set the language for exclusive/VIP content popups and notifications:

```lua
Config.VIPLanguage = "en"  -- Default: English
```

### Available Languages
| Code | Language |
|------|----------|
| `"en"` | English |
| `"es"` | Spanish |
| `"de"` | German |
| `"fr"` | French |
| `"it"` | Italian |
| `"pt"` | Portuguese |
| `"ru"` | Russian |
| `"tr"` | Turkish |
| `"ar"` | Arabic |
| `"zh"` | Chinese |
| `"ja"` | Japanese |
| `"ko"` | Korean |
| `"hi"` | Hindi |
| `"pl"` | Polish |
| `"nl"` | Dutch |

---

## Store Ownership System

Enable players to purchase and manage stores:

```lua
Config.StoreOwnership = {
    enabled = true,  -- Set to true to enable

    storePrices = {
        Skateshop = 500000,  -- Venice Beach store
        Xtreme = 450000,     -- Downtown store
        Future = 750000,     -- Hoverboard exclusive
        Snowmoh = 400000     -- Mountain ski shop
    }
}
```

> See [STORE_OWNERSHIP.md](STORE_OWNERSHIP.md) for full documentation.

---

## Background Music

Configure ambient music that plays near stores:

```lua
Config.BackgroundMusic = {
    enabled = true,   -- Set to false to disable music
    volume = 0.09,    -- Volume level (0.0 to 1.0)
    links = {
        "https://www.youtube.com/watch?v=VIDEO_ID_1",
        "https://www.youtube.com/watch?v=VIDEO_ID_2",
        -- Add more YouTube links...
    }
}
```

Music is randomly selected when a player approaches a store.

---

## Language Strings

Customize all text displayed to players:

```lua
Config.Language = {
    Info = {
        ['warning'] = 'The Workshop is currently in use by another player.',
        ['purchase'] = 'You have successfully purchased this design!',
        ['failed'] = 'You dont have enough money.',
        ['error'] = 'You already own this design.',
        -- ... more strings
    },
    Store = {
        ['target'] = 'Open Bodhix Studio.',
        ['text'] = '[E] Open Bodhix Studio.',
        -- ... more strings
    },
    Menu = {
        ["equipment"] = "CUSTOMIZE",
        ["gear"] = "EXPLORE",
        ["whats_new"] = "DISCOVER",
        -- ... category names
    }
}
```

---

## Equipment Prices

Set prices for protective gear:

```lua
Config.EquipmentPrices = {
    helmet = 5000,
    forearms = 3500,
    shinguards = 3500
}
```

---

## Category Configuration

Configure each equipment category:

### Skateboard (with parts)
```lua
Config.Categories.skateboard = {
    displayName = "Skateboard",
    icon = "images/skateboard.png",
    parts = {
        deck = {
            price = 4500,
            modern = { count = 18 },
            classic = { count = 18 }
        },
        trucks = {
            price = 2000,
            modern = { count = 10 },
            classic = { count = 13 }
        },
        wheels = {
            price = 1500,
            modern = { count = 10 },
            classic = { count = 13 }
        }
    },
    baseItemPrice = 30000,  -- Price to buy the base skateboard item
    itemName = "skateboard"  -- Inventory item name
}
```

### Simple Category (no parts)
```lua
Config.Categories.bmx = {
    displayName = "BMX",
    icon = "images/bmx.png",
    baseItemPrice = 20000,
    price = 15000,       -- Price per design
    count = 10,          -- Number of designs available
    itemName = "bmx"
}
```

### Category with Styles
```lua
Config.Categories.hoverboard = {
    displayName = "Hoverboard",
    icon = "images/hoverboard.png",
    styles = {
        ultra = {
            count = 16,
            displayName = "Ultra"
        },
        retro = {
            count = 16,
            displayName = "Retro"
        }
    },
    baseItemPrice = 50000,
    price = 35000,
    itemName = "hoverboard"
}
```

---

## Store Locations (Spots)

Configure each physical store location:

```lua
Config.Spots = {
    Skateshop = {
        -- Resource dependency (nil = always spawn)
        dependency = "BDX-XTreme-Stores",

        -- Store operating hours (24-hour format)
        hours = {
            open = 7,    -- 7 AM
            close = 22   -- 10 PM
        },

        -- NPC configuration
        npc = {
            x = -1395.0419,
            y = -1322.9249,
            z = 4.5094,
            heading = 257.9703,
            model = 'A_F_Y_Beach_02',
            sex = 'female',
            scenario = 'WORLD_HUMAN_STAND_IMPATIENT'
        },

        -- Music proximity settings
        musicDistance = {
            maxDistance = 20.0,       -- Music fades to 0
            maxVolumeDistance = 5.0   -- Max volume distance
        },

        -- Available categories at this store
        availableCategories = {
            "skateboard",
            "hoverboard",
            "bmx",
            "scooter",
            "rollers",
            "ski",
            "iceskates",
            "snowboard"
        },

        -- Camera and gear spawn positions (per category)
        cameras = { ... },
        gearSpawns = { ... },
    }
}
```

### Store Hours
```lua
-- Always open
hours = {
    open = 0,
    close = 24
}

-- Standard hours (8 AM - 10 PM)
hours = {
    open = 8,
    close = 22
}
```

### Store Closure Events
Trigger events when stores open/close:
```lua
closureEvents = {
    enabled = true,
    onOpen = "xtreme-store:venice:open",
    onClose = "xtreme-store:venice:close"
}
```

### Resource Dependency
Only spawn NPC if another resource is running:
```lua
dependency = "BDX-XTreme-Stores"  -- NPC only spawns if this resource exists
dependency = nil                   -- Always spawn NPC
```

---

## NPC Models

Common NPC models you can use:

| Model | Description |
|-------|-------------|
| `A_F_Y_Beach_02` | Female beach character |
| `a_m_m_skater_01` | Male skater |
| `a_m_y_motox_02` | Male motocross |
| `cs_chrisformage` | Male formal character |

Find more models at: https://docs.fivem.net/docs/game-references/ped-models/

---

## Quick Reference

| Setting | Default | Description |
|---------|---------|-------------|
| `Config.Debug` | `false` | Debug mode |
| `Config.Framework` | `"esx"` | Framework type |
| `Config.Target` | `"ox"` | Target system |
| `Config.EnablePeds` | `true` | Enable store NPCs |
| `Config.VIPLanguage` | `"en"` | VIP content language |
| `Config.StoreOwnership.enabled` | `false` | Store ownership system |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| NPCs not spawning | Check `dependency` setting and if resource exists |
| Store always closed | Verify `hours` configuration (24-hour format) |
| Wrong prices | Ensure you edited `config.lua` and restarted resource |
| Framework errors | Check `Config.Framework` matches your server |

---

**Support**: https://discord.gg/PjN7AWqkpF
