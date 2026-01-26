# Framework Bridge Guide

> **Understanding and customizing framework-bridge.lua for your server**

---

## What is the Framework Bridge?

The `server/framework-bridge.lua` file is an **open-source abstraction layer** that handles all framework-specific operations. It allows BDX-Sport-Hub to work seamlessly with different FiveM frameworks without modifying protected code.

### Purpose
- Provides a unified API regardless of framework
- Handles money, inventory, and player identification
- Manages database storage for purchases
- Registers useable items for each framework

---

## Supported Frameworks

| Framework | Config Value | Tested |
|-----------|--------------|--------|
| ESX | `"esx"` | Yes |
| QBCore | `"qb"` | Yes |
| vRP | `"vrp"` | Yes |
| Custom | `"custom"` | Manual setup required |

---

## How It Works

### 1. Framework Initialization
On resource start, the bridge detects your framework:

```lua
if Config.Framework == "qb" then
    QBCore = exports["qb-core"]:GetCoreObject()
elseif Config.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "vrp" then
    vRP = Proxy.getInterface("vRP")
end
```

### 2. Unified Functions
The bridge provides these functions that work across all frameworks:

| Function | Purpose |
|----------|---------|
| `GetPlayerMoney(src)` | Get player's cash amount |
| `RemoveMoney(src, amount)` | Remove money from player |
| `GiveItem(src, item, amount)` | Give item to player |
| `RemoveItem(src, item, amount)` | Remove item from player |
| `HasItem(src, item)` | Check if player has item |
| `GetPlayerIdentifier(src)` | Get unique player ID |
| `ShowNotification(src, message, type)` | Show notification |

---

## Custom Framework Setup

If you use a custom framework or economy system, edit the `"custom"` sections:

### Money Functions
```lua
function GetPlayerMoney(src)
    if Config.Framework == "custom" then
        -- Add your custom framework logic here
        -- Example:
        return exports["your_economy"]:GetMoney(src)
    end
end

function RemoveMoney(src, amount)
    if Config.Framework == "custom" then
        -- Example:
        return exports["your_economy"]:RemoveMoney(src, amount)
    end
end
```

### Inventory Functions
```lua
function GiveItem(src, item, amount)
    if Config.Framework == "custom" then
        -- Example:
        return exports["your_inventory"]:AddItem(src, item, amount)
    end
end

function HasItem(src, item)
    if Config.Framework == "custom" then
        -- Example:
        return exports["your_inventory"]:HasItem(src, item)
    end
end
```

### Player Identifier
```lua
function GetPlayerIdentifier(src)
    if Config.Framework == "custom" then
        -- Example:
        return exports["your_framework"]:GetIdentifier(src)
    end
end
```

---

## Useable Items Registration

The bridge automatically registers useable items for each gear type when the corresponding resource is running:

```lua
-- Skateboard (only if BDX-Skate is running)
if GetResourceState('BDX-Skate') == 'started' then
    if Config.Framework == "qb" then
        QBCore.Functions.CreateUseableItem("skateboard", function(source, item)
            TriggerClientEvent('bodhix-skating:client:start', source, item)
        end)
    elseif Config.Framework == "esx" then
        ESX.RegisterUsableItem("skateboard", function(source, item)
            TriggerClientEvent('bodhix-skating:client:start', source, item)
        end)
    end
end
```

### Supported Gear Items
| Item Name | Requires Resource |
|-----------|-------------------|
| `skateboard` | BDX-Skate |
| `hoverboard` | BDX-Hoverboard |
| `bmx` | BDX-Bmx |
| `scooter` | BDX-Scooter |
| `rollers` | BDX-Rollers |
| `skis` | BDX-Ski |
| `iceskates` | BDX-Ice-Skate |
| `snowboard` | BDX-Snowboarding |

---

## Database Storage

The bridge handles all purchase data storage in MySQL:

### Table Structure
```sql
sport_hub_purchases (
    identifier    -- Player unique ID
    item_type     -- Equipment category
    gender        -- Style name (male/female/ultra/retro/etc.)
    texture_id    -- Design number (0-indexed)
    is_equipped   -- Currently equipped (0/1)
)
```

### Storage Functions
```lua
-- Save a purchase
SavePurchase(identifier, itemType, gender, textureId, setAsEquipped)

-- Get equipped design
GetPurchase(identifier, itemType, gender)

-- Get all owned designs
GetAllPurchases(identifier, itemType, gender)

-- Change equipped design
SetEquippedDesign(identifier, itemType, gender, textureId)
```

---

## Server Exports

Use these exports from other resources:

```lua
-- Money
local money = exports['BDX-Sport-Hub']:GetPlayerMoney(source)
exports['BDX-Sport-Hub']:RemoveMoney(source, 1000)

-- Inventory
exports['BDX-Sport-Hub']:GiveItem(source, "skateboard", 1)
exports['BDX-Sport-Hub']:RemoveItem(source, "skateboard", 1)
local hasItem = exports['BDX-Sport-Hub']:HasItem(source, "skateboard")

-- Player Data
local identifier = exports['BDX-Sport-Hub']:GetPlayerIdentifier(source)

-- Purchases
exports['BDX-Sport-Hub']:SavePurchase(identifier, "skateboard", "modern", 5, true)
local textureId = exports['BDX-Sport-Hub']:GetPurchase(identifier, "skateboard", "modern")
local allPurchases = exports['BDX-Sport-Hub']:GetAllPurchases(identifier, "skateboard", "modern")
```

---

## Developer Commands

### /removedesigns [PlayerID]
Remove all purchased designs for a player (admin only).

```
/removedesigns 1
```

### /cleancorruptedpurchases
Clean up corrupted database entries (admin only).

```
/cleancorruptedpurchases
```

---

## Notifications

The bridge uses your framework's native notification system:

| Framework | Notification Method |
|-----------|---------------------|
| QBCore | `QBCore:Notify` |
| ESX | `esx:showNotification` |
| vRP | `vRP:Notify` |
| Custom | Configurable |

To customize for custom framework:
```lua
function ShowNotification(src, messageKey, type)
    if Config.Framework == "custom" then
        -- Your notification system
        TriggerClientEvent('your_notify', src, message, type)
    end
end
```

---

## Custom Resource Name

If your framework uses a non-standard resource name:

```lua
-- In config.lua
Config.FrameworkResourceName = "my-custom-esx"

-- The bridge will use this:
ESX = exports["my-custom-esx"]:getSharedObject()
```

---

## ox_inventory Support

The bridge automatically detects and uses ox_inventory when available:

```lua
if GetResourceState('ox_inventory') == 'started' then
    exports.ox_inventory:AddItem(src, item, amount)
else
    -- Fallback to standard ESX inventory
    xPlayer.addInventoryItem(item, amount)
end
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "MySQL not available" | Ensure `oxmysql` starts BEFORE `BDX-Sport-Hub` in server.cfg |
| Items not useable | Check if the gear resource (BDX-Skate, etc.) is running |
| Money not deducting | Verify `Config.Framework` matches your server |
| Identifier nil | Framework may not be fully loaded; check resource order |

### Debug Mode
Enable debug in config.lua to see detailed logs:
```lua
Config.Debug = true
```

---

## File Location

```
BDX-Sport-Hub/
  server/
    framework-bridge.lua  <-- This file
```

---

**Support**: https://discord.gg/PjN7AWqkpF
