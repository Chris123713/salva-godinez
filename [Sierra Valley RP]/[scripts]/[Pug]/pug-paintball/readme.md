# 🟢 Pug Advanced Paintball

## 💬 Support & Store
Join the support Discord: [https://discord.gg/jYZuWYjfvq]
## 🛍️ Browse my other scripts:
Shop here: [https://pug-webstore.tebex.io/]
## 📁 View the documentation here: 
documentation: [https://pugdocuments.gitbook.io/pug-development]

---
## 🛠️ Installation Instructions

1. Move the 'int_arcade' folder found inside of the pug-paintball/[ARCADE-MLO] folder into your resources folder and make sure that it is ensured if you do not already have this arcade mlo.
2. Add the MLOs `pug-nuketown-arena` and `pug-nuketown-mirrorpark` (found on cfx portal) to your `maps` folder and ensure them in your server config. (THIS IS OPTIONAL, YOU CAN DOWNLOAD EITHER MAP YOU WANT)
3. **OX Inventory Users:** Follow the section below. This is crucial for compatibility.
4. If you want to disable "shots fired" dispatch calls, follow the **Dispatch Integration** section below carefully. If your dispatch script does not have default support for paintball then CONTACT THE DISPATCH SCRIPT CREATOR AND TELL THEM TO ADD SUPPORT!!!!
---

## 📦 Ox Inventory Integration (REQUIRED)
### Add this export ANYWHERE at the VERY bottom of ox_inventory/client.lua and then restart your server.
```lua
exports("SetCurrentWeapon", function(ThisWeapon)
    local inPaintball = GetResourceState("pug-paintball") == "started" and exports["pug-paintball"]:IsInPaintball()
    local inBattleRoyale = GetResourceState("pug-battleroyale") == "started" and exports["pug-battleroyale"]:IsInBattleRoyale()
    if not inPaintball and not inBattleRoyale and string.lower(ThisWeapon) ~= "weapon_unarmed" then return end
	if string.lower(ThisWeapon) == "weapon_unarmed" then currentWeapon = nil return end
	currentWeapon = {}
	currentWeapon.metadata = {}
	currentWeapon.metadata.durability = 100
	currentWeapon.metadata.ammo = 100
	currentWeapon.metadata.specialAmmo = "false"
	currentWeapon.timer = false
	currentWeapon.name = ThisWeapon
end)
```

## 📌 Key Commands & Features
- `/redoutfit` and `/blueoutfit` — Save your current outfit for each team. (Dress yourself as a male and female ped in both Red Team and Blue Team outfits, then use the commands below to save each outfit)
- `G` — Opens the paintball scoreboard during a match.
- `/surrenderpaintball` — Use this to forfeit a match early.
- **Map creation tutorial:** https://youtu.be/wALLIIaNoPE  
  *(If you create new maps, feel free to share them in the Pug Discord snippet section!)*
---

---
## 🚓 Dispatch Integration

To prevent dispatch alerts while in a paintball match, REACH OUT TO YOUR DISPATCH CREATOR AND ASK THEM TO ADD SUPPORT BY adding this line at the top of your shot/discharge event if your disatch script does not already support this by default OPEN A TICKET WITH THEM AND REQUEST THEM TO ADD DEFAULT SUPPORT!:
```lua
if exports["pug-paintball"]:IsInPaintball() then return end
```
---

## 🛡️ QB-Anticheat Compatibility (QBCore Only)
If your weapon disappears at match start while using `qb-anticheat`, update the following loop in `qb-anticheat/client/main.lua`:
```lua
CreateThread(function()
    while true do
        Wait(5000)

        if LocalPlayer.state.isLoggedIn and not exports["pug-paintball"]:IsInPaintball() then
            local PlayerPed = PlayerPedId()
            local player = PlayerId()
            local CurrentWeapon = GetSelectedPedWeapon(PlayerPed)
            local WeaponInformation = QBCore.Shared.Weapons[CurrentWeapon]

            if WeaponInformation and WeaponInformation["name"] ~= "weapon_unarmed" then
                QBCore.Functions.TriggerCallback('qb-anticheat:server:HasWeaponInInventory', function(HasWeapon)
                    if not HasWeapon then
                        RemoveAllPedWeapons(PlayerPed, false)
                        TriggerServerEvent("qb-log:server:CreateLog", "anticheat", "Weapon removed!", "orange",
                            "** @everyone " .. GetPlayerName(player) .. "** had a weapon not present in inventory. QB Anticheat removed the weapon.")
                    end
                end, WeaponInformation)
            end
        end
    end
end)
```


# Advanced Paintball. For any questions please contact me here: here https://discord.gg/jYZuWYjfvq.
Advanced Paintball 4.0 release!

PREVIEW HERE: https://youtu.be/t9G0t4m3ZAs

​Full QBCore & ESX Compatibility. (supports custom qb-core names and all qb custom file dependency names)

This script is partially locked using escrow encryption. 90% of the script is accessible in client/open.lua, server/server.lua, and config.lua

Readme: https://imgur.com/UbaS5ix.png
Config: https://imgur.com/Y06kcq8.png

## 🎨🔥 Pug’s PAINTBALL 4.0 — The #1 Paintball Script in FiveM

A fully-featured, tournament-ready paintball system built for competitive FiveM servers.  
Fast, polished, customizable, and packed with content — everything you need for the perfect PvP experience.

**✔ Supports up to 24 players per match** (12v12)  
**✔ 24+ high-quality arenas included** (Nuketown, Grove St, Jurassic Park, High Rise, Sewer Rats & more)  
**✔ Unlimited custom maps** using simple in-game vector placement  
**✔ Multiple match types:** TDM, DM, FFA, CTF, Gun Game, One in the Chamber, Hold Your Own, Kill Confirmed  
**✔ Fully isolated arenas** — run as many paintball matches as you want at the same time  

### 🏁 LOBBY SYSTEM  
• Create unlimited lobbies simultaneously  
• Custom lobby names, passcodes, time limits  
• Transfer host instantly  
• All settings update for everyone in real time  

### 🛡️ TEAM & CLAN SYSTEM  
• Create permanent teams/clans  
• Upload custom logos  
• Choose team colors & outfits 
• Manage rosters and ranks  
• Scoreboard + UI theme updates automatically  

### 🎖️ PROGRESSION & LEADERBOARDS  
• 50 player levels  
• 10 prestige tiers with unique icons  
• XP scaling and match rewards  
• Global leaderboards displayed directly in world  

### 📊 ADVANCED SCOREBOARD UI  
• Live K/D, kills, deaths, points  
• Team scores  
• Prestige emblem + player level  
• Clean competitive layout  

### 💥 KILL FEED & HUD  
• Correct weapon model icons  
• Headshot indicators  
• Multiple screen positions  
• Smooth animation & clarity  

### 🔫 WEAPONS & LOADOUTS  
• Custom paintball gun model  
• 33+ weapon support  
• Pre-game weapon selection  
• Weapon icons + updated visuals  

### 🗺️ MAP & GAMEPLAY EXPERIENCE  
• 24+ included maps, unlimited custom maps  
• Team blips, UAV killstreaks, Death Machine streak  
• Unlimited sprint, smooth movement  
• Spectator mode  
• Starting intro sequence  

### 💼 SCRIPT SUPPORT  
• Full QBCore, QBOX, & ESX support
• Full qb-menu, ox_lib, & lation_ui support
• No specific target, EMS, or inventory script required. (all are supported)

### ⚙️ PERFORMANCE & QUALITY  
• 0.0ms idle usage  
• ~0.02ms during matches  
• Clean 2026-standard rewrite  
• Stable, optimized, scalable  

---

**Pug’s Paintball 4.0 delivers the deepest, cleanest, and most complete paintball experience available in FiveM — perfect for casual servers, competitive events, clans, leagues, and tournaments.**
