# BDX-BMX

BMX Bikes - Perform tricks, stunts and extreme sports across Los Santos.

Part of the **BDX-Sport-Hub** collection by Bodhix Studio.

---

## ⚠️ CRITICAL - DEPENDENCY REQUIREMENT

> **BDX-Sport-Hub MUST be started BEFORE this resource!**
>
> This resource depends on `BDX-Sport-Hub` for framework integration, store management, and item registration.
> If `BDX-Sport-Hub` is not started first, **this resource will NOT work**.

### server.cfg - Correct Load Order:
```cfg
ensure BDX-Sport-Hub
ensure BDX-Bmx
```

**IMPORTANT:** Always ensure `BDX-Sport-Hub` appears BEFORE `BDX-Bmx` in your server.cfg to guarantee proper loading order.

---

## 📋 Requirements

- **BDX-Sport-Hub** (required for framework integration and store management)
- QB-Core, ESX, or vRP framework

---

## 🎒 Item Setup

The BMX item must be added to your inventory system. The inventory image is located at:

```
assets/inventory_images/bmx.png
```

Copy this image to your inventory's image folder and add the item configuration below.

### QB-Core (qb-core/shared/items.lua)

```lua
['bmx'] = {
    ['name'] = 'bmx',
    ['label'] = 'BMX',
    ['weight'] = 3000,
    ['type'] = 'item',
    ['image'] = 'bmx.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'A BMX bike for tricks and stunts'
},
```

**Image Location:** Copy `bmx.png` to `qb-inventory/html/images/`

---

### ESX (es_extended or ox_inventory)

#### Standard ESX Inventory

Add to your items database or items configuration:

```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('bmx', 'BMX', 3000, 0, 1);
```

**Image Location:** Copy `bmx.png` to your inventory resource's image folder

#### ox_inventory (data/items.lua)

```lua
['bmx'] = {
    label = 'BMX',
    weight = 3000,
    stack = false,
    close = true,
    description = 'A BMX bike for tricks and stunts'
},
```

**Image Location:** Copy `bmx.png` to `ox_inventory/web/images/`

---

### qs-inventory (qs-inventory/shared/items.lua)

```lua
['bmx'] = {
    ['name'] = 'bmx',
    ['label'] = 'BMX',
    ['weight'] = 3000,
    ['type'] = 'item',
    ['image'] = 'bmx.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'A BMX bike for tricks and stunts'
},
```

**Image Location:** Copy `bmx.png` to `qs-inventory/html/images/`

---

### ps-inventory (ps-inventory/shared/items.lua)

```lua
['bmx'] = {
    ['name'] = 'bmx',
    ['label'] = 'BMX',
    ['weight'] = 3000,
    ['type'] = 'item',
    ['image'] = 'bmx.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'A BMX bike for tricks and stunts'
},
```

**Image Location:** Copy `bmx.png` to `ps-inventory/html/images/`

---

### Custom Inventory

If using a custom inventory system, create the item with these values:

- **Name:** `bmx`
- **Label:** `BMX`
- **Weight:** `3000`
- **Type:** `item`
- **Image:** `bmx.png`
- **Unique:** `true`
- **Useable:** `true`
- **Should Close:** `true`
- **Description:** `A BMX bike for tricks and stunts`

---

## 🎮 Controls

| Action | Key (Keyboard) | Key (Controller) |
|--------|----------------|------------------|
| Pickup BMX | E | DPAD RIGHT |
| Bar Spin | Left Mouse Button | RT |
| Bike Flip | G | Left Stick |
| Bri Flip | E | DPAD RIGHT |
| HD Flip | R | B |
| Invert | Q | DPAD LEFT |
| Superman | Left Shift | X |
| Tailwhip | C | Right Stick |
| Tuck No Hander | Space | RB |
| Turn Down | X | LT |
| Wheelie | L Ctrl | L Stick |

---

## ⚙️ Configuration (config.lua)

The configuration file is located at `BDX-Bmx/config.lua`.

### General Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Config.Debug` | boolean | `false` | Enable/disable debug messages in console |
| `Config.Framework` | string | `"esx"` | Your framework: `"qb"`, `"esx"`, `"vrp"`, or `"custom"` |
| `Config.ItemName` | string | `"bmx"` | The item name in your inventory system |
| `Config.Target` | string | `"ox"` | Target system: `"qb"`, `"ox"`, or `"none"` |
| `Config.FrameworkResourceName` | string/nil | `nil` | Custom framework resource name (only if not in default location) |
| `Config.ActiveWhitelist` | boolean | `false` | Enable whitelist system (see Whitelist.lua) |
| `Config.UseAsItem` | boolean | `false` | Set to `false` to auto-detect BMX vehicles without needing an item |

### BMX Physics

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Config.minimumSpeed` | number | `1.0` | Minimum km/h to perform a trick |
| `Config.maxFallSurvival` | number | `150` | Maximum fall height before taking damage |

### Trick Keys (Key Codes)

| Option | Default | Key |
|--------|---------|-----|
| `Config.BarSpin` | `24` | Left Mouse Button / RT |
| `Config.BikeFlip` | `113` | G / Left Stick |
| `Config.BriFlip` | `51` | E / DPAD RIGHT |
| `Config.HDFlip` | `80` | R / B |
| `Config.Invert` | `52` | Q / DPAD LEFT |
| `Config.Superman` | `131` | Left Shift / X |
| `Config.Tailwhip` | `79` | C / Right Stick |
| `Config.TuckNoHander` | `76` | Space / RB |
| `Config.TurnDown` | `252` | X / LT |

### Allowed Vehicles

Configure which BMX models can perform tricks:

```lua
Config.allowedVehicles = {
    [`bmx_1`] = true,
    [`bmx_2`] = true,
    [`bmx_3`] = true,
    [`bmx_4`] = true,
    [`bmx_5`] = true,
    [`bmx_6`] = true,
    [`bmx_7`] = true,
    [`bmx_8`] = true,
    [`bmx_9`] = true,
    [`bmx_10`] = true,
}
```

### Language Customization

```lua
Config.Language = {
    Info = {
        ['controls'] = 'Press E to Pickup or Target',
    },
    Bmx = {
        ['target'] = 'Save BMX.',
        ['text'] = '[E] Save BMX.'
    },
}
```

---

## 🛒 Store Integration

BMX bikes can be purchased from any Sport Hub store location. Configure store locations in:

```
BDX-Sport-Hub/config.lua
```

Add `"bmx"` to the `availableCategories` array for any store location where you want BMX bikes to be sold.

---

## 🎨 Customization

BMX bikes come with **10 different designs**. Players can customize their BMX at the Sport Hub store.

Design pricing is configured in:
```
BDX-Bmx/config.lua
```

---

## 📞 Support

For support and updates, visit:
- **Discord:** https://discord.com/invite/PjN7AWqkpF
- **Tebex:** https://bodhix.tebex.io

---

## 📝 Notes

- **Framework Registration:** Item useable registration is automatically handled by BDX-Sport-Hub
- **No Duplicate Registration:** Do NOT register the useable item in this resource, it's handled centrally
- **Sport Hub Required:** This resource requires BDX-Sport-Hub to function properly

---

**Developed by Bodhix Studio**
