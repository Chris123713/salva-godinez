# sv_nexus_tools LLM Reference Guide

This document provides structured information for LLM-based systems (like Mr. X) to understand and generate valid tool calls for the Sierra Valley RP mission system.

---

## How to Use This Reference

When generating missions, output a **tools array** - a JSON array of tool calls that will be executed in sequence. Each tool call has:

```json
{
    "name": "tool_name",
    "params": {
        "param1": "value1",
        "param2": "value2"
    }
}
```

### Coordinate Format

All coordinates should be provided as objects:
```json
{"x": 123.45, "y": 456.78, "z": 32.10}
```

### Player References

- `source`: Player's server ID (number) - used for targeting specific connected players
- `citizenid`: Player's unique identifier (string) - used for database operations and persistent tracking

---

## Tool Categories

| Category | Purpose | Example Tools |
|----------|---------|---------------|
| SPAWNING | Create entities in world | safe_spawn_npc, safe_spawn_vehicle |
| CRIMINAL | Heist/theft mechanics | hack_terminal, spawn_loot_container |
| POLICE | Law enforcement tools | spawn_evidence, create_bolo |
| SOCIAL | Faction/rumor systems | spread_rumor, bounty_system |
| WORLD | Environment events | traffic_block, spawn_ambient_event |
| ECONOMY | Money operations | award_money, deduct_money |
| INVENTORY | Item management | award_item, remove_item |
| MISSION | Objective tracking | set_objective, create_checkpoint |
| PHONE | lb-phone integration | send_phone_mail, send_phone_notification |

---

## Complete Tool Reference

### SPAWNING TOOLS

#### safe_spawn_npc
Spawn an NPC with collision verification and optional dialog.

```json
{
    "name": "safe_spawn_npc",
    "params": {
        "model": "s_m_m_scientist_01",
        "coords": {"x": 123.4, "y": 456.7, "z": 32.1},
        "heading": 90.0,
        "behavior": "idle",
        "dialog": "informant_tree_01",
        "networked": true
    }
}
```

**Behaviors:** `idle`, `wander`, `guard`, `cower`, `hostile`, `flee`

**Common Models:**
- Business: `a_m_m_business_01`, `a_f_y_business_02`
- Street: `a_m_m_tramp_01`, `s_m_y_dealer_01`
- Worker: `s_m_m_dockwork_01`, `s_m_m_warehouse_01`
- Security: `s_m_m_security_01`, `s_m_y_blackops_01`

---

#### safe_spawn_vehicle
Spawn a vehicle on valid ground.

```json
{
    "name": "safe_spawn_vehicle",
    "params": {
        "model": "sultan",
        "coords": {"x": 200.0, "y": 300.0, "z": 30.0},
        "heading": 180.0,
        "locked": true,
        "fuel": 80
    }
}
```

**Common Models:**
- Sports: `sultan`, `elegy`, `comet2`
- Trucks: `boxville`, `mule`, `benson`
- Luxury: `schafter2`, `oracle`, `tailgater`
- Utility: `police`, `ambulance`, `firetruk`

---

#### safe_spawn_prop
Spawn an interactive prop.

```json
{
    "name": "safe_spawn_prop",
    "params": {
        "model": "prop_box_wood02a",
        "coords": {"x": 150.0, "y": 250.0, "z": 30.0},
        "heading": 45.0,
        "interactive": true,
        "frozen": true
    }
}
```

---

### CRIMINAL TOOLS

#### hack_terminal
Create hackable terminal with minigame.

```json
{
    "name": "hack_terminal",
    "params": {
        "coords": {"x": 123.4, "y": 456.7, "z": 32.1},
        "difficulty": "hard",
        "reward": {"type": "password", "data": "vault_code_4521"},
        "missionId": "heist_001",
        "objectiveId": "hack_security"
    }
}
```

**Difficulties:** `easy`, `medium`, `hard`, `extreme`
**Reward Types:**
- `password` - Returns a code/phrase
- `item` - Gives item on success
- `money` - Gives cash on success

---

#### create_hostage_situation
Spawn hostage scenario for police standoff.

```json
{
    "name": "create_hostage_situation",
    "params": {
        "coords": {"x": 450.2, "y": -980.5, "z": 30.7},
        "hostageCount": 2,
        "demands": "Release prisoner #4521 and provide helicopter",
        "missionId": "bank_heist_001"
    }
}
```

---

#### spawn_loot_container
Create searchable container with target item.

```json
{
    "name": "spawn_loot_container",
    "params": {
        "coords": {"x": 100.0, "y": 200.0, "z": 30.0},
        "containerType": "safe",
        "targetItem": "intel_document",
        "additionalLoot": [{"name": "money", "count": 5000}],
        "locked": true,
        "missionId": "heist_001",
        "objectiveId": "retrieve_documents"
    }
}
```

**Container Types:** `safe`, `crate`, `locker`, `drawer`, `trunk`

---

#### vehicle_tracker
Place GPS tracker on vehicle.

```json
{
    "name": "vehicle_tracker",
    "params": {
        "plate": "ABC123",
        "faction": "police",
        "missionId": "surveillance_op",
        "duration": 3600
    }
}
```

**Factions:** `police`, `criminal`, or specific gang names

---

#### forge_identity
Create fake ID for undercover work.

```json
{
    "name": "forge_identity",
    "params": {
        "source": 1,
        "fakeName": "John Smith",
        "documentType": "drivers_license",
        "quality": "good",
        "duration": 7200
    }
}
```

**Quality:** `poor` (easy to detect), `average`, `good`, `excellent` (hard to detect)

---

### POLICE TOOLS

#### spawn_evidence
Create collectible evidence prop.

```json
{
    "name": "spawn_evidence",
    "params": {
        "coords": {"x": 300.0, "y": 400.0, "z": 30.0},
        "evidenceType": "shell_casing",
        "description": "9mm shell casing from shooting",
        "linkedTo": "ABC12345",
        "missionId": "investigation_001"
    }
}
```

**Evidence Types:** `weapon`, `document`, `blood`, `shell_casing`, `phone`, `drugs`, `money`, `generic`

---

#### mark_crime_scene
Create investigation zone with evidence.

```json
{
    "name": "mark_crime_scene",
    "params": {
        "coords": {"x": 500.0, "y": 600.0, "z": 30.0},
        "radius": 30.0,
        "crimeType": "homicide",
        "evidenceCount": 5,
        "missionId": "murder_case_001"
    }
}
```

**Crime Types:** `homicide`, `robbery`, `assault`, `shooting`, `arson`

---

#### spawn_barrier
Place police barriers or spike strips.

```json
{
    "name": "spawn_barrier",
    "params": {
        "coords": {"x": 200.0, "y": 300.0, "z": 30.0},
        "barrierType": "spike_strip",
        "heading": 90,
        "count": 3
    }
}
```

**Barrier Types:** `barrier`, `cone`, `spike_strip`, `barrier_large`, `police_barrier`

---

#### create_bolo
Broadcast alert to all police.

```json
{
    "name": "create_bolo",
    "params": {
        "type": "vehicle",
        "description": "Suspect vehicle fleeing bank robbery",
        "plate": "XYZ789",
        "model": "sultan",
        "priority": "high",
        "lastSeen": {"x": 150.0, "y": 250.0, "z": 30.0}
    }
}
```

**Priority:** `low`, `medium`, `high`, `critical`

---

#### medical_triage
Spawn injured NPC for EMS.

```json
{
    "name": "medical_triage",
    "params": {
        "coords": {"x": 350.0, "y": 450.0, "z": 30.0},
        "injuryType": "gunshot",
        "severity": "critical",
        "patientModel": "a_m_m_business_01",
        "missionId": "ems_call_001"
    }
}
```

**Injury Types:** `trauma`, `gunshot`, `burns`, `overdose`, `cardiac`
**Severity:** `minor`, `moderate`, `severe`, `critical`

---

#### lockdown_area
Create police perimeter zone.

```json
{
    "name": "lockdown_area",
    "params": {
        "coords": {"x": 400.0, "y": 500.0, "z": 30.0},
        "radius": 75.0,
        "reason": "Active shooter situation",
        "policeOnly": true,
        "duration": 1200
    }
}
```

---

### SOCIAL TOOLS

#### spread_rumor
Create ambient rumor NPCs share.

```json
{
    "name": "spread_rumor",
    "params": {
        "coords": {"x": 200.0, "y": 300.0, "z": 30.0},
        "content": "Word on the street is something big is going down at the docks tonight",
        "linkedInfo": "Shipment arriving at pier 4, 11pm",
        "spreadRadius": 100.0,
        "missionId": "investigation_001"
    }
}
```

---

#### spawn_informant
Create NPC who sells database info.

```json
{
    "name": "spawn_informant",
    "params": {
        "coords": {"x": 150.0, "y": 250.0, "z": 30.0},
        "model": "a_m_m_tramp_01",
        "infoType": "criminal_record",
        "targetCitizenId": "ABC12345",
        "price": 1000,
        "missionId": "find_suspect_001"
    }
}
```

**Info Types:** `phone_number`, `address`, `criminal_record`, `vehicle_plate`, `gang_affiliation`

---

#### create_meeting
Create zone where parties must convene.

```json
{
    "name": "create_meeting",
    "params": {
        "coords": {"x": 300.0, "y": 400.0, "z": 30.0},
        "radius": 15.0,
        "requiredParties": ["ABC12345", "DEF67890"],
        "title": "Gang negotiation",
        "missionId": "peace_talks_001"
    }
}
```

---

#### trigger_news_event
Broadcast server-wide news.

```json
{
    "name": "trigger_news_event",
    "params": {
        "headline": "BREAKING: Bank Robbery in Progress Downtown",
        "content": "Police have surrounded the Fleeca Bank on Alta Street. Multiple hostages reported.",
        "category": "breaking",
        "duration": 60000
    }
}
```

**Categories:** `breaking`, `crime`, `business`, `sports`

---

#### bounty_system
Place bounty on player.

```json
{
    "name": "bounty_system",
    "params": {
        "targetCitizenId": "ABC12345",
        "amount": 50000,
        "reason": "Snitched to the feds",
        "postedBy": "DEF67890",
        "faction": "ballas",
        "anonymous": true
    }
}
```

---

#### adjust_faction_rep
Modify player standing with faction.

```json
{
    "name": "adjust_faction_rep",
    "params": {
        "source": 1,
        "faction": "vagos",
        "amount": 25,
        "reason": "Completed drug delivery",
        "missionId": "gang_work_001"
    }
}
```

---

### WORLD TOOLS

#### traffic_block
Create AI traffic jam.

```json
{
    "name": "traffic_block",
    "params": {
        "coords": {"x": 250.0, "y": 350.0, "z": 30.0},
        "radius": 50.0,
        "severity": "heavy",
        "duration": 600
    }
}
```

**Severity:** `light`, `moderate`, `heavy`, `gridlock`

---

#### spawn_ambient_event
Create random world event.

```json
{
    "name": "spawn_ambient_event",
    "params": {
        "coords": {"x": 180.0, "y": 280.0, "z": 30.0},
        "eventType": "car_crash",
        "severity": "major",
        "alertEmergency": true,
        "missionId": "ems_response_001"
    }
}
```

**Event Types:** `car_crash`, `fight`, `fire`, `robbery`, `medical`

---

#### create_delivery_task
Create pickup/dropoff objective.

```json
{
    "name": "create_delivery_task",
    "params": {
        "source": 1,
        "pickupCoords": {"x": 100.0, "y": 200.0, "z": 30.0},
        "dropoffCoords": {"x": 500.0, "y": 600.0, "z": 30.0},
        "item": "delivery_package",
        "count": 1,
        "reward": 1500,
        "missionId": "courier_job_001"
    }
}
```

---

#### spawn_customer_npc
Create NPC buyer.

```json
{
    "name": "spawn_customer_npc",
    "params": {
        "coords": {"x": 220.0, "y": 320.0, "z": 30.0},
        "model": "a_m_y_business_02",
        "wantedItem": "weed_baggie",
        "wantedCount": 5,
        "paymentAmount": 250,
        "missionId": "dealer_sales_001",
        "objectiveId": "sell_product"
    }
}
```

---

#### witness_event
Spawn NPC with information.

```json
{
    "name": "witness_event",
    "params": {
        "coords": {"x": 270.0, "y": 370.0, "z": 30.0},
        "model": "a_f_y_business_01",
        "infoType": "saw_vehicle",
        "relatedCitizenId": "ABC12345",
        "infoContent": "I saw a red sports car speed off toward the highway. Plate started with XY.",
        "missionId": "investigation_001"
    }
}
```

**Info Types:** `saw_crime`, `heard_gunshots`, `saw_vehicle`, `knows_suspect`

---

### ECONOMY TOOLS

#### award_money
Give money to player.

```json
{
    "name": "award_money",
    "params": {
        "source": 1,
        "moneyType": "cash",
        "amount": 5000,
        "reason": "Heist completion bonus"
    }
}
```

**Money Types:** `cash`, `bank`, `crypto`

---

#### deduct_money
Take money from player.

```json
{
    "name": "deduct_money",
    "params": {
        "source": 1,
        "moneyType": "cash",
        "amount": 500,
        "reason": "Bribe payment"
    }
}
```

---

### INVENTORY TOOLS

#### award_item
Give item to player.

```json
{
    "name": "award_item",
    "params": {
        "source": 1,
        "item": "lockpick",
        "count": 3,
        "metadata": {"quality": "high"}
    }
}
```

---

#### remove_item
Take item from player.

```json
{
    "name": "remove_item",
    "params": {
        "source": 1,
        "item": "stolen_goods",
        "count": 1
    }
}
```

---

### MISSION TOOLS

#### set_objective
Update player objective status.

```json
{
    "name": "set_objective",
    "params": {
        "missionId": "heist_001",
        "citizenid": "ABC12345",
        "objectiveId": "hack_terminal",
        "status": "completed"
    }
}
```

**Status:** `pending`, `active`, `completed`, `failed`, `locked`

---

#### create_checkpoint
Create mission checkpoint zone.

```json
{
    "name": "create_checkpoint",
    "params": {
        "coords": {"x": 300.0, "y": 400.0, "z": 30.0},
        "radius": 5.0,
        "objectiveId": "reach_safehouse",
        "missionId": "heist_001"
    }
}
```

---

#### mark_escape_route
Set GPS waypoint for player.

```json
{
    "name": "mark_escape_route",
    "params": {
        "source": 1,
        "coords": {"x": 1000.0, "y": 2000.0, "z": 30.0},
        "blipSprite": 1,
        "blipColor": 2
    }
}
```

---

### PHONE TOOLS

#### send_phone_mail
Send email via lb-phone.

```json
{
    "name": "send_phone_mail",
    "params": {
        "source": 1,
        "subject": "New Job Available",
        "message": "Meet me at the usual spot. I have work for you.",
        "sender": "Mr. X"
    }
}
```

---

#### send_phone_notification
Push notification to player.

```json
{
    "name": "send_phone_notification",
    "params": {
        "source": 1,
        "title": "Mission Update",
        "message": "Target has been spotted at the docks",
        "icon": "fas fa-crosshairs"
    }
}
```

---

## Mission Generation Examples

### Example 1: Bank Heist (Criminal Mission)

```json
{
    "missionId": "bank_heist_001",
    "type": "criminal",
    "brief": "Hit the Fleeca Bank on Alta Street. Hack the terminal, grab the cash, and escape.",
    "tools": [
        {
            "name": "safe_spawn_vehicle",
            "params": {
                "model": "sultan",
                "coords": {"x": 150.0, "y": 250.0, "z": 30.0},
                "heading": 90.0,
                "locked": false
            }
        },
        {
            "name": "hack_terminal",
            "params": {
                "coords": {"x": 148.5, "y": -1042.3, "z": 29.3},
                "difficulty": "hard",
                "reward": {"type": "password", "data": "vault_7294"},
                "missionId": "bank_heist_001",
                "objectiveId": "hack_vault"
            }
        },
        {
            "name": "spawn_loot_container",
            "params": {
                "coords": {"x": 146.0, "y": -1044.5, "z": 29.3},
                "containerType": "safe",
                "targetItem": "money_bag",
                "additionalLoot": [{"name": "gold_bar", "count": 2}],
                "locked": true,
                "missionId": "bank_heist_001",
                "objectiveId": "grab_cash"
            }
        },
        {
            "name": "create_checkpoint",
            "params": {
                "coords": {"x": 1500.0, "y": 2500.0, "z": 30.0},
                "radius": 10.0,
                "objectiveId": "escape_zone",
                "missionId": "bank_heist_001"
            }
        },
        {
            "name": "alert_dispatch",
            "params": {
                "coords": {"x": 148.0, "y": -1042.0, "z": 29.0},
                "code": "10-31",
                "description": "Robbery in progress at Fleeca Bank, Alta Street"
            }
        }
    ],
    "objectives": {
        "criminal": [
            {"id": "hack_vault", "description": "Hack the security terminal"},
            {"id": "grab_cash", "description": "Empty the vault"},
            {"id": "escape_zone", "description": "Escape to the safehouse"}
        ],
        "police": [
            {"id": "respond", "description": "Respond to bank alarm"},
            {"id": "neutralize", "description": "Neutralize suspects"},
            {"id": "secure_scene", "description": "Secure the crime scene"}
        ]
    }
}
```

### Example 2: Investigation (Police Mission)

```json
{
    "missionId": "murder_investigation_001",
    "type": "police",
    "brief": "Investigate a homicide in the industrial district. Collect evidence and find witnesses.",
    "tools": [
        {
            "name": "mark_crime_scene",
            "params": {
                "coords": {"x": 500.0, "y": -1500.0, "z": 30.0},
                "radius": 40.0,
                "crimeType": "homicide",
                "evidenceCount": 4,
                "missionId": "murder_investigation_001"
            }
        },
        {
            "name": "witness_event",
            "params": {
                "coords": {"x": 520.0, "y": -1480.0, "z": 30.0},
                "model": "a_f_y_business_01",
                "infoType": "saw_crime",
                "infoContent": "I heard gunshots around midnight. Saw a guy in a red jacket run toward the docks.",
                "missionId": "murder_investigation_001"
            }
        },
        {
            "name": "spawn_informant",
            "params": {
                "coords": {"x": 480.0, "y": -1520.0, "z": 30.0},
                "model": "a_m_m_tramp_01",
                "infoType": "phone_number",
                "targetCitizenId": "SUSPECT123",
                "price": 500,
                "missionId": "murder_investigation_001"
            }
        },
        {
            "name": "lockdown_area",
            "params": {
                "coords": {"x": 500.0, "y": -1500.0, "z": 30.0},
                "radius": 50.0,
                "reason": "Active crime scene investigation",
                "policeOnly": true,
                "duration": 1800
            }
        }
    ],
    "objectives": {
        "police": [
            {"id": "collect_evidence", "description": "Collect all evidence at scene"},
            {"id": "interview_witness", "description": "Interview the witness"},
            {"id": "get_intel", "description": "Get suspect info from informant"},
            {"id": "file_report", "description": "File the investigation report"}
        ]
    }
}
```

### Example 3: Drug Deal (Mixed Criminal/Civilian)

```json
{
    "missionId": "drug_deal_001",
    "type": "criminal",
    "brief": "Complete the drug deal at the docks. Pick up the product and deliver to buyers.",
    "tools": [
        {
            "name": "spread_rumor",
            "params": {
                "coords": {"x": 1200.0, "y": -2800.0, "z": 30.0},
                "content": "Big shipment coming in tonight at the docks",
                "linkedInfo": "Pier 4, midnight delivery",
                "spreadRadius": 100.0,
                "missionId": "drug_deal_001"
            }
        },
        {
            "name": "spawn_loot_container",
            "params": {
                "coords": {"x": 1150.0, "y": -2850.0, "z": 30.0},
                "containerType": "crate",
                "targetItem": "drugs",
                "locked": false,
                "missionId": "drug_deal_001",
                "objectiveId": "pickup_product"
            }
        },
        {
            "name": "spawn_customer_npc",
            "params": {
                "coords": {"x": 200.0, "y": 500.0, "z": 30.0},
                "model": "a_m_y_hipster_01",
                "wantedItem": "drugs",
                "wantedCount": 10,
                "paymentAmount": 5000,
                "missionId": "drug_deal_001",
                "objectiveId": "complete_sale"
            }
        },
        {
            "name": "spawn_enemy_wave",
            "params": {
                "coords": {"x": 180.0, "y": 480.0, "z": 30.0},
                "count": 3,
                "model": "g_m_y_ballasout_01",
                "weapons": ["WEAPON_PISTOL"],
                "spread": 15.0
            }
        }
    ],
    "objectives": {
        "criminal": [
            {"id": "pickup_product", "description": "Pick up the shipment"},
            {"id": "complete_sale", "description": "Sell to the buyer"},
            {"id": "survive", "description": "Deal with rival gang interference"}
        ]
    }
}
```

---

## Detection & Completion Tracking

### How Tools Track Completion

| Tool | Detection Method |
|------|-----------------|
| hack_terminal | Minigame success callback |
| spawn_loot_container | ox_inventory stash close event |
| spawn_evidence | Collection callback with police check |
| create_checkpoint | lib.zones.sphere enter event |
| create_delivery_task | Item delivery at dropoff zone |
| spawn_customer_npc | Trade completion with item check |
| create_meeting | All required parties in radius |
| witness_event | Dialog completion callback |

### Objective Linking

When using `missionId` and `objectiveId` params:
1. Tool spawns entity/zone
2. Player interacts with entity
3. Tool handler calls `SetMissionObjective(missionId, citizenid, objectiveId, 'completed')`
4. Client UI updates automatically

---

## Best Practices for Mission Generation

1. **Always include missionId** - Links tools to a specific mission for tracking
2. **Use objectiveId for interactive tools** - Enables automatic completion detection
3. **Space out coordinates** - Don't cluster spawns too close together
4. **Balance difficulty** - Mix easy and hard objectives
5. **Consider both roles** - Criminal missions should have police response opportunities
6. **Use phone notifications** - Keep players informed of mission progress
7. **Include escape/completion zones** - Every mission needs a clear endpoint
8. **Add environmental context** - Use ambient events and rumors for immersion

---

## API Exports for Mr. X Module

```lua
-- Generate mission from tools array
exports['sv_nexus_tools']:ExecuteToolsArray(toolsArray, source)

-- Get all available tools for prompt building
exports['sv_nexus_tools']:GetAvailableTools()

-- Execute single tool
exports['sv_nexus_tools']:ExecuteTool(toolName, params, source)

-- Mission management
exports['sv_nexus_tools']:CreateMission(missionData)
exports['sv_nexus_tools']:GetActiveMission(citizenid)
exports['sv_nexus_tools']:SetMissionObjective(missionId, citizenid, objectiveId, status)
exports['sv_nexus_tools']:CompleteMission(missionId, status)

-- Blueprint management
exports['sv_nexus_tools']:GetBlueprintByType(type)
exports['sv_nexus_tools']:SpawnMissionFromBlueprint(blueprintId, participants)
```

---

## Version

- Document Version: 1.0
- sv_nexus_tools Version: 1.0.0
- Last Updated: 2025-01-24
