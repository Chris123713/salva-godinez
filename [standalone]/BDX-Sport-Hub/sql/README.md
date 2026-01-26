# Sport Hub - SQL Database Files

## ⚠️ IMPORTANT NOTICE

**YOU DO NOT NEED TO MANUALLY IMPORT THESE FILES!**

All database tables are **automatically created** when the Sport Hub resource starts. These SQL files are provided only as a **backup/manual installation option** for servers experiencing issues with automatic table creation.

---

## 🗂️ Available SQL Files

### 1. `sport_hub_complete_install.sql` ⭐ **RECOMMENDED**
**Use this file if you want to manually install ALL tables at once.**

Contains all 8 Sport Hub tables:
- ✅ Gear/design purchases (skateboard, BMX, hoverboard, etc.)
- ✅ Equipment ownership (helmets, pads, guards)
- ✅ Store ownership system
- ✅ Custom store pricing
- ✅ Custom store hours
- ✅ Custom equipment pricing
- ✅ VIP package tracking (Tebex)
- ✅ Discord verification links

**When to use:**
- First-time installation on a new server
- Auto-creation is completely failing
- You want to ensure all tables exist before starting the resource

---

### 2. `sport_hub_gear_purchases.sql`
**For gear/design purchase issues only.**

Contains 3 tables:
- `sport_hub_purchases` - Gear/design purchases
- `sport_hub_tebex_packages` - VIP packages
- `sport_hub_discord_links` - Discord verification

**When to use:**
- Skateboard designs are not saving
- BMX/hoverboard/scooter purchases are not saving
- VIP content is not being recognized
- Players lose their designs after restart

---

### 3. `sport_hub_equipment.sql`
**For equipment system issues only.**

Contains 2 tables:
- `sport_hub_equipment` - Equipment ownership (helmets, pads, guards)
- `sport_hub_equipment_prices` - Custom equipment pricing

**When to use:**
- Equipment purchases (helmets, forearms, shinguards) are not saving
- Equipment equipped status is not saving

---

### 4. `sport_hub_ownership.sql`
**For store ownership system issues only.**

Contains 3 tables:
- `sport_hub_store_ownership` - Store ownership
- `sport_hub_store_prices` - Custom store pricing
- `sport_hub_store_hours` - Custom store hours

**When to use:**
- Store ownership system is not working
- Custom prices set by store owners are not saving
- Custom store hours are not saving

---

## 📖 How to Import SQL Files

### Method 1: phpMyAdmin (Easiest)
1. Open phpMyAdmin in your browser
2. Select your FiveM database (usually `essentialmode` or `es_extended`)
3. Click the "**Import**" tab at the top
4. Click "**Choose File**" and select the SQL file
5. Click "**Go**" at the bottom
6. Done! Tables are now created

### Method 2: HeidiSQL
1. Open HeidiSQL and connect to your database
2. Select your FiveM database
3. Go to **File** → **Load SQL file**
4. Select the SQL file you want to import
5. Click the "**Execute**" button (blue play icon)
6. Done! Tables are now created

### Method 3: Command Line (Advanced)
```bash
mysql -u your_username -p your_database_name < sport_hub_complete_install.sql
```

---

## 🔍 Troubleshooting

### Problem: Tables still not being created automatically
**Solution:** Check server console for SQL errors. Common issues:
- MySQL connection not configured in `server.cfg`
- Database user lacks `CREATE TABLE` permission
- Database name is incorrect

### Problem: Data saves but disappears after restart
**Solution:**
1. Check `Config.UseSQLStorage` in `config.lua` (should be `true` for SQL)
2. Verify tables exist in your database
3. Check for SQL errors in server console

### Problem: "Duplicate entry" errors
**Solution:**
- This is normal! It means the table already exists
- The `IF NOT EXISTS` clause prevents errors
- No action needed

### Problem: Old table structure causing issues
**Solution:**
1. **Backup your database first!**
2. Drop the old tables manually
3. Import the new SQL file
4. Or let the resource auto-recreate (it detects old structures)

---

## 📋 Table Structure Overview

### Gear/Design Purchases (`sport_hub_purchases`)
Stores all player-purchased gear designs:
- **Columns:** identifier, item_type, gender, texture_id, is_equipped
- **Purpose:** Tracks which skateboard designs, BMX designs, etc. players own
- **Equipped:** Stores which design is currently active

### Equipment Ownership (`sport_hub_equipment`)
Stores protective equipment ownership:
- **Columns:** identifier, sport, category, model, is_equipped
- **Purpose:** Tracks helmet, forearm, and shinguard ownership
- **Sport-specific:** Each sport has its own equipment

### Store Ownership (`sport_hub_store_ownership`)
Tracks who owns which stores:
- **Columns:** store_name, owner_identifier, owner_name, purchase_price
- **Purpose:** Store ownership system
- **For Sale:** Tracks if store is listed for sale

### Custom Store Pricing (`sport_hub_store_prices`)
Owner-set custom prices:
- **Columns:** store_name, category, item_type, style, price
- **Purpose:** Store owners can set their own prices
- **Flexible:** Supports all gear types and styles

### Custom Store Hours (`sport_hub_store_hours`)
Owner-set operating hours:
- **Columns:** store_name, open_hour, close_hour
- **Purpose:** Store owners can set custom hours
- **Dynamic:** NPCs appear/disappear based on hours

### Equipment Custom Pricing (`sport_hub_equipment_prices`)
Owner-set equipment prices:
- **Columns:** store_name, category, price
- **Purpose:** Store owners can set custom equipment prices
- **Categories:** Helmet, forearms, shinguards

### VIP Packages (`sport_hub_tebex_packages`)
Tebex package tracking:
- **Columns:** identifier, package_id, transaction_id
- **Purpose:** Tracks VIP package purchases
- **Backup:** Used when Discord verification fails

### Discord Links (`sport_hub_discord_links`)
Discord ID verification:
- **Columns:** identifier, discord_id, discord_username, verified
- **Purpose:** Links player accounts to Discord for VIP content
- **Manual:** Allows admin to manually verify players

---

## ✅ Verification Checklist

After importing, verify your installation:

- [ ] All tables are visible in phpMyAdmin/HeidiSQL
- [ ] No SQL errors in server console
- [ ] Resource starts without errors
- [ ] Test: Buy a skateboard design → restart server → design is still owned
- [ ] Test: Buy equipment → restart server → equipment is still owned
- [ ] Test: Store ownership features work (if enabled)

---

## 🆘 Still Having Issues?

If you continue experiencing problems after manual installation:

1. **Check MySQL Logs:** Look for permission errors
2. **Verify Connection:** Ensure `server.cfg` has correct MySQL settings
3. **Database Permissions:** User needs: SELECT, INSERT, UPDATE, CREATE
4. **Check Config:** Verify `Config.UseSQLStorage = true` in `config.lua`
5. **Console Errors:** Watch server console for specific error messages

---

## 📞 Support

For additional help:
- Check server console for specific error messages
- Verify all tables exist in your database
- Ensure MySQL connection is working
- Contact support with console error logs if issues persist

---

**Remember:** These files are a **backup solution**. The resource handles table creation automatically in 99% of cases!
