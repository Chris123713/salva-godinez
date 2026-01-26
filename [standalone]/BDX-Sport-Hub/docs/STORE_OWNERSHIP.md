# 🏪 Store Ownership System

> **Optional Feature** - Allow players to purchase and manage Sport Hub stores

---

## 📋 Overview

The Store Ownership System allows players to buy stores, receive FREE items, collect revenue from customer purchases, and manage custom pricing and hours.

### Features
- ✅ **Purchase Stores** - Buy any available Sport Hub store
- ✅ **FREE Items** - Store owners get all items completely FREE
- ✅ **Revenue System** - Earn money from every customer purchase
- ✅ **Custom Pricing** - Set your own prices for all items
- ✅ **Custom Hours** - Configure when your store opens/closes
- ✅ **Sell Store** - List your store for sale or sell back

---

## 🚀 Quick Start (2 Steps)

### Step 1: Enable in Config
Edit `config.lua`:
```lua
Config.StoreOwnership = {
    enabled = true,  -- Change to true

    storePrices = {
        Skateshop = 500000,  -- $500,000
        Xtreme = 450000,     -- $450,000
        Future = 750000,     -- $750,000
        Snowmoh = 400000     -- $400,000
    }
}
```

### Step 2: Restart Resource
```
restart BDX-Sport-Hub
```

**That's it!** Database tables are created automatically.

---

## 🎮 Player Experience

### Purchasing a Store
1. Go to any Sport Hub store NPC
2. Use target interaction (E key)
3. Select **"Purchase Store ($XXX,XXX)"**
4. Confirm purchase - you're now the owner!

### As Store Owner
When you approach YOUR store NPC, you'll see:
1. **"Open Bodhix Studio"** - Shop for items (FREE!)
2. **"Manage Store"** - Configure prices, hours, and sell

### As Customer (Someone Else's Store)
- Shop normally with prices set by the owner
- Owner receives revenue from your purchases

---

## 💰 Revenue System

When customers purchase from your store:
- Money is **automatically** added to your account
- You receive notification: `"Revenue received from your store: $X,XXX"`

> **Note**: You must be online to receive revenue

---

## ⚙️ Configuration Options

### Store Prices
```lua
Config.StoreOwnership.storePrices = {
    Skateshop = 500000,  -- Venice Beach store
    Xtreme = 450000,     -- Downtown store
    Future = 750000,     -- Hoverboard exclusive store
    Snowmoh = 400000     -- Mountain ski shop
}
```

### Language Strings
```lua
Config.Language.Info = {
    ['store_purchased'] = 'You have purchased this store!',
    ['revenue_received'] = 'Revenue received from your store: $%s',
    ['store_purchase_failed'] = 'Store purchase failed. Not enough money.',
    -- ... more in config.lua
}
```

---

## 🗄️ Database

Three tables are **auto-created** on first start:

| Table | Purpose |
|-------|---------|
| `sport_hub_store_ownership` | Store ownership data |
| `sport_hub_store_prices` | Custom pricing per store |
| `sport_hub_store_hours` | Custom operating hours |

**No manual SQL import needed!**

---

## 🔧 Developer API

### Server Exports
```lua
-- Check if player owns a store
exports['BDX-Sport-Hub']:IsStoreOwner(identifier, storeName)

-- Get store ownership data
exports['BDX-Sport-Hub']:GetStoreOwnership(storeName)

-- Get custom price for an item
exports['BDX-Sport-Hub']:GetCustomPrice(storeName, category, itemType, style)

-- Get custom hours
exports['BDX-Sport-Hub']:GetCustomHours(storeName)

-- Send revenue to owner
exports['BDX-Sport-Hub']:SendRevenueToOwner(storeName, amount)
```

### Client Exports
```lua
-- Get ownership status
exports['BDX-Sport-Hub']:GetOwnershipStatus(storeName)

-- Check if player is owner
exports['BDX-Sport-Hub']:IsStoreOwner(storeName)
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Purchase option not showing | Ensure `Config.StoreOwnership.enabled = true` |
| Database errors | Verify `oxmysql` starts BEFORE `BDX-Sport-Hub` |
| Revenue not received | Owner must be online |
| Custom prices not working | Set via management menu after purchasing |

---

## 📝 How It Works (Technical)

### Free Items for Owners
1. Client sends `isOwner = true` in purchase data
2. Server sets `totalPrice = 0`
3. Items given normally, no money removed

### Revenue Flow
1. Customer purchases item
2. Server charges customer
3. Server calls `SendRevenueToOwner()`
4. If owner online, money added + notification

### Custom Pricing
1. Owner sets prices via management menu
2. Saved to `sport_hub_store_prices` table
3. Server checks custom price during purchase
4. Falls back to config price if no custom price

---

**Support**: https://discord.gg/PjN7AWqkpF
