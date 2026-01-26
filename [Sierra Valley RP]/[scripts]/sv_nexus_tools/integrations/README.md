# Integration Snippets for sv_nexus_tools

This folder contains ready-to-use integration snippets for popular Sierra Valley RP scripts. These snippets show how to connect existing scripts to the sv_nexus_tools system, enabling Mr. X to generate dynamic, reactive missions based on real player activity.

## How to Use

1. **Copy** the relevant functions from these files into your target script
2. **Call** the functions at appropriate points in your existing code
3. **Done** - sv_nexus_tools will now track that activity for mission generation

## Available Integrations

| Script | File | What It Enables |
|--------|------|-----------------|
| **lb-phone** | `lb_phone_integration.lua` | Mr. X emails, mission briefings, phone notifications |
| **lb-tablet** | `lb_tablet_integration.lua` | Police MDT tracking, warrant detection, pressure mapping |
| **brutal_gangs** | `brutal_gangs_integration.lua` | Gang status queries, territory tracking, raid detection |
| **rcore_doorlock** | `rcore_doorlock_integration.lua` | Door control for heists, lockpicking tracking, area lockdown |
| **drugs_creator** | `drugs_creator_integration.lua` | Drug empire tracking, lab activity, shipment monitoring |
| **pug-robberycreator** | `pug_robberycreator_integration.lua` | Robbery pattern tracking, minigame stats, heist escalation |
| **nextgenfivem_crafting** | `crafting_integration.lua` | Crafting activity for criminal reputation, supply missions |
| **Generic Robbery** | `robbery_integration.lua` | Bank/store/jewelry robbery hooks |
| **Generic Police** | `police_integration.lua` | Dispatch, pursuit, arrest hooks |
| **Generic Criminal** | `criminal_integration.lua` | Drug sales, gang activity, weapon crafting |

## Quick Integration Example

In your existing script (e.g., bank robbery), add:

```lua
-- At the top of your server file
local function ReportToNexus(eventType, data, source)
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end
    exports['sv_nexus_tools']:ReportActivity(eventType, data, source)
end

-- When robbery starts
ReportToNexus('robbery_started', {
    robberyType = 'bank',
    coords = robberyCoords,
    estimatedValue = 50000
}, source)

-- When robbery completes
ReportToNexus('robbery_completed', {
    robberyType = 'bank',
    success = true,
    lootValue = actualLoot,
    policeResponded = wasPoliceHere
}, source)
```

## What Happens After Integration

Once integrated, sv_nexus_tools will:

1. **Track Activity** - Log all reported events with player info and coordinates
2. **Build Profiles** - Understand player patterns (robber, drug dealer, etc.)
3. **Generate Missions** - Mr. X creates contextual missions based on activity
4. **Reactive Content** - Trigger special missions when patterns emerge:
   - 5+ successful robberies → Mr. X offers a major heist
   - High gang activity → Territory war missions
   - Prolific drug dealer → Supplier/distribution missions

## Event Types Reference

### Criminal
- `robbery_started`, `robbery_completed`, `robbery_failed`
- `heist_started`, `heist_completed`
- `drug_sale`, `drug_production`, `drug_shipment`
- `vehicle_theft`, `weapon_sale`
- `gang_activity`, `hostage_taken`

### Police
- `dispatch_created`, `dispatch_received`
- `pursuit_started`, `pursuit_ended`
- `arrest_made`, `citation_issued`
- `evidence_collected`, `case_filed`

### Civilian/Economy
- `job_started`, `job_completed`
- `crafting_activity`, `business_transaction`
- `large_transaction`

## Notes

- These snippets are **examples** - adapt them to your specific script structure
- Many scripts use FiveM Asset Protection (escrow) - hook into unencrypted config/API files
- Always wrap nexus calls in `if GetResourceState('sv_nexus_tools') == 'started'`
- The integration is **optional** - scripts work normally without sv_nexus_tools

## Full Documentation

See `docs/INTEGRATION_GUIDE.md` for complete API reference and advanced usage.
