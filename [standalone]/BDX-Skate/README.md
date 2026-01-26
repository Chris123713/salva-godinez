# BDX-Skateboard

Skateboard - Classic street skating with fully customizable boards (deck, trucks, wheels).

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
ensure BDX-Skate
```

**IMPORTANT:** Always ensure `BDX-Sport-Hub` appears BEFORE `BDX-Skate` in your server.cfg to guarantee proper loading order.

---

## 📋 Requirements

- **BDX-Sport-Hub** (required for framework integration and store management)
- QB-Core, ESX, or vRP framework

---

## 🎒 Item Setup

The Skateboard item must be added to your inventory system. The inventory image is located at:

```
assets/inventory_images/skateboard.png
```

Copy this image to your inventory's image folder and add the item configuration below.

### QB-Core (qb-core/shared/items.lua)

```lua
['skateboard'] = {
    ['name'] = 'skateboard',
    ['label'] = 'Skateboard',
    ['weight'] = 3000,
    ['type'] = 'item',
    ['image'] = 'skateboard.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'A skateboard for tricks and stunts'
},
```

**Image Location:** Copy `skateboard.png` to `qb-inventory/html/images/`

---

### ESX (es_extended or ox_inventory)

#### Standard ESX Inventory

Add to your items database or items configuration:

```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('skateboard', 'Skateboard', 3000, 0, 1);
```

**Image Location:** Copy `skateboard.png` to your inventory resource's image folder

#### ox_inventory (data/items.lua)

```lua
['skateboard'] = {
    label = 'Skateboard',
    weight = 3000,
    stack = false,
    close = true,
    description = 'A skateboard for tricks and stunts'
},
```

**Image Location:** Copy `skateboard.png` to `ox_inventory/web/images/`

---

### qs-inventory (qs-inventory/shared/items.lua)

```lua
['skateboard'] = {
    ['name'] = 'skateboard',
    ['label'] = 'Skateboard',
    ['weight'] = 3000,
    ['type'] = 'item',
    ['image'] = 'skateboard.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'A skateboard for tricks and stunts'
},
```

**Image Location:** Copy `skateboard.png` to `qs-inventory/html/images/`

---

### ps-inventory (ps-inventory/shared/items.lua)

```lua
['skateboard'] = {
    ['name'] = 'skateboard',
    ['label'] = 'Skateboard',
    ['weight'] = 3000,
    ['type'] = 'item',
    ['image'] = 'skateboard.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'A skateboard for tricks and stunts'
},
```

**Image Location:** Copy `skateboard.png` to `ps-inventory/html/images/`

---

### Custom Inventory

If using a custom inventory system, create the item with these values:

- **Name:** `skateboard`
- **Label:** `Skateboard`
- **Weight:** `3000`
- **Type:** `item`
- **Image:** `skateboard.png`
- **Unique:** `true`
- **Useable:** `true`
- **Should Close:** `true`
- **Description:** `A skateboard for tricks and stunts`

---

## 🎮 Controls

| Action | Key |
|--------|-----|
| Pickup Skateboard / Put on Back | E |
| Ride Skateboard / Hold in Hand | G |
| Tricks | Configure in FiveM Settings → Key Bindings |

---

## ⚙️ Configuration (config.lua)

The configuration file is located at `BDX-Skate/config.lua`.

### General Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Config.Debug` | boolean | `false` | Enable/disable debug messages in console |
| `Config.Framework` | string | `"esx"` | Your framework: `"qb"`, `"esx"`, `"vrp"`, or `"custom"` |
| `Config.ItemName` | string | `"skateboard"` | The item name in your inventory system |
| `Config.Target` | string | `"ox"` | Target system: `"qb"`, `"ox"`, or `"none"` |
| `Config.FrameworkResourceName` | string/nil | `nil` | Custom framework resource name (only if not in default location) |

### Skateboard Physics

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Config.MaxSpeedKmh` | number | `40` | Maximum speed in km/h |
| `Config.maxJumpHeigh` | number | `5.0` | Maximum jump height (be careful with high values) |
| `Config.maxFallSurvival` | number | `45.0` | Maximum fall height before taking damage |
| `Config.LoseConnectionDistance` | number | `2.0` | Distance from player to skateboard before disconnecting |
| `Config.MinimumSkateSpeed` | number | `2.0` | Minimum speed to maintain skating |
| `Config.MinGroundHeight` | number | `1.0` | Minimum ground detection height |

### Control Keys

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Config.PickupKey` | number | `38` | Key to pickup skateboard (E key) |
| `Config.ConnectPlayer` | number | `113` | Key to connect/ride skateboard (G key) |

### Visual Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Config.TextFont` | number | `4` | Font style for UI text |
| `Config.ModernBack` | number | `-0.25` | Position adjustment for modern skateboard on back |
| `Config.ClassicBack` | number | `-0.32` | Position adjustment for classic skateboard on back (DLC) |

### Language Customization

```lua
Config.Language = {
    Info = {
        ['controls'] = 'Press E to Pickup | Press G to Ride',
    },
}
```

---

## 🔌 Custom Inventory Integration

If you need to trigger the skateboard from a custom inventory, use this event:

```lua
TriggerClientEvent('bodhix-skating:client:start', source, item)
```

---

## 🛒 Store Integration

Skateboards can be purchased from any Sport Hub store location. Configure store locations in:

```
BDX-Sport-Hub/config.lua
```

Add `"skateboard"` to the `availableCategories` array for any store location where you want skateboards to be sold.

---

## 🎨 Customization

Skateboards feature **full customization** with Modern and Classic styles:

- **Decks:** 17 Modern + 18 Classic designs
- **Trucks:** 10 Modern + 13 Classic designs
- **Wheels:** 10 Modern + 13 Classic designs

Players can mix and match parts to create unique skateboard combinations.

Pricing is configured in `BDX-Sport-Hub/config.lua` under the skateboard category.

---

## 🎨 Adding Custom Deck Designs

Want to add your own deck designs to the store? Follow these steps:

### Step 1: Update Design Count

Open `BDX-Sport-Hub/config.lua` and locate the skateboard category configuration:

```lua
skateboard = {
    parts = {
        deck = {
            modern = { count = 17, ... },  -- Increase this number
            classic = { count = 18, ... }  -- Or this one
        },
        ...
    }
}
```

**Example:** If adding a new Modern deck design, change `count = 17` to `count = 18`.

---

### Step 2: Duplicate Model Files

Navigate to `BDX-Skate/stream/Custom-Designs/` and duplicate the following files:

- **Modern Deck:** `board_17.yft` and `board_17.ytd`
- **Classic Deck:** `c_deck_18.yft` and `c_deck_18.ytd`

Rename them to the next number:
- **Modern:** `board_18.yft` and `board_18.ytd`
- **Classic:** `c_deck_19.yft` and `c_deck_19.ytd`

**Files Explained:**
- `.yft` = 3D Model (Drawable)
- `.ytd` = Texture Dictionary

---

### Step 3: Edit Texture Dictionary

1. Open the `.ytd` file in **CodeWalker** or **OpenIV**
2. Enable **Edit Mode**
3. Navigate to your FiveM resource folder (or create a temporary working folder)
4. Double-click the `.ytd` file to open the texture dictionary
5. You'll see the current texture - this is what we'll replace

---

### Step 4: Create Your Custom Design

Template files are located in `BDX-Skate/assets/Custom_Skate_Images/`:

**A) In-Game 3D Texture (`texture_base.png`):**
- This is the texture that wraps around the 3D skateboard model
- Open in your image editor (Photoshop, GIMP, etc.)
- Add your custom design to this template
- **IMPORTANT:** Keep the same dimensions and layout

**B) Menu Preview Image (`deck_base.png`):**
- This is the image shown in the customization menu
- Design your deck graphic to fit this template
- This will be visible to players when selecting designs

---

### Step 5: Convert and Replace Textures

**A) Convert 3D Texture to DDS:**
1. Save your edited `texture_base.png`
2. Convert PNG to DDS format using: [aconvert.com/image/png-to-dds/](https://aconvert.com/image/png-to-dds/)
3. In CodeWalker/OpenIV, replace the texture in the `.ytd` file
4. **IMPORTANT:** Keep the exact same texture name

**B) Add Menu Preview:**
1. Save your `deck_base.png` design
2. Rename it to match your design number:
   - Modern deck #18: `deck_18.png`
   - Classic deck #19: `c_deck_19.png`
3. Copy to: `BDX-Sport-Hub/nui/customs/skateboard/modern/` or `.../classic/`

---

### Step 6: Test In-Game

1. Restart both `BDX-Sport-Hub` and `BDX-Skate` resources
2. Open the Sport Hub store
3. Select Skateboard → Choose your style (Modern/Classic)
4. Your new design should appear in the list!

---

## 🔧 Troubleshooting Custom Designs

**Design not showing in menu?**
- Check that the PNG is in the correct folder (`BDX-Sport-Hub/nui/customs/skateboard/`)
- Verify the filename matches the design number exactly
- Ensure you updated the `count` in Sport Hub config

**3D model is wrong/missing texture?**
- Verify the texture name in the `.ytd` matches the original
- Make sure you converted to DDS format correctly
- Check that the `.ytd` and `.yft` files are in the stream folder

**Design shows but texture is glitched?**
- The `texture_base.png` layout must match exactly
- Ensure DDS conversion settings are correct (DXT5 recommended)
- Try re-exporting the DDS with different compression

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
- **Custom Designs:** Design count configuration is in `BDX-Sport-Hub/config.lua`, NOT in this resource
- **NUI Images:** Menu preview images are stored in `BDX-Sport-Hub/nui/customs/`, NOT in this resource

---

**Developed by Bodhix Studio**
