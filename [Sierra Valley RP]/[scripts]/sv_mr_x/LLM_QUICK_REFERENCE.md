# sv_mr_x - LLM Quick Reference

## Overview

FiveM resource implementing Mr. X, an omniscient AI "fixer" character for QBX servers. Contacts players anonymously via lb-phone, assigns missions, tracks reputation, provides HELP services to allies and HARM to enemies.

**Core Concept:** Mr. X operates in the shadows - all communication is anonymous. High-rep players get valuable services; low-rep players face consequences.

**Version:** 2.0.0 - Psychology System Update

---

## Key Dependencies

- qbx_core (player data)
- lb-phone (communication)
- oxmysql (database)
- ox_lib (UI/callbacks)
- **tgg-banking** (financial operations)
- sv_nexus_tools (optional - AI missions)
- lb-tablet (optional - MDT integration)
- rcore_cam (optional - camera intel)

---

## Configuration Quick Reference

```lua
Config.TestMode = true                        -- BLOCKS all automated actions
Config.ChaosEngine.Enabled = false            -- Chaos engine off by default
Config.ProactiveContact.Enabled = true
Config.ProactiveContact.MinIntervalMinutes = 60
Config.ProactiveContact.MaxContactsPerDay = 3

-- New in v2.0
Config.Archetypes.MinEventsForClassification = 8     -- Wait for enough data
Config.Archetypes.MinTimeBeforeClassification = 7200 -- 2 hours minimum
Config.Archetypes.RequireDirectInteraction = true    -- Must interact with Mr. X first
Config.Services.Loans.UseRealTime = true             -- 48 REAL hours, not game hours
Config.OpenAI.UseCompactPrompt = true                -- Token optimization
Config.Banking.PrimaryResource = 'tgg-banking'       -- Banking integration
```

---

## The 9-Archetype System (NEW)

### Primary Buckets (by Job/Role)
| Bucket | Jobs | Description |
|--------|------|-------------|
| AUTHORITY | Police, EMS, DOJ | Usually exempt |
| CIVILIAN | Legit jobs | Gray area recruitment |
| CRIMINAL | Gangs, unemployed | Core targets |

### Alignment Axes
- **Method** (HOW): calculated / opportunistic / reckless
- **Loyalty** (WHO): civic / self / crew

### 9 Archetypes (3x3 Grid)
| | Civic | Self | Crew |
|---|-------|------|------|
| **Calculated** | Guardian | Fixer | Syndicate |
| **Opportunistic** | Reformer | Hustler | Soldier |
| **Reckless** | Loose Cannon | Wildcard | Enforcer |

### Classification Timing
Players stay `UNCLASSIFIED` until:
- 8+ behavior events recorded
- 2+ hours of gameplay
- At least one direct interaction with Mr. X
- Clear evidence (3.0+ score difference)

---

## Reputation Tiers

| Tier | Range | Access |
|------|-------|--------|
| EASY | 0-20 | Basic missions, $1k-5k payouts |
| DILEMMA | 21-50 | Moral choices, $5k-15k payouts, early warning |
| HIGH_RISK | 51-100 | Full services, loans, record clearing, $15k-50k payouts |

---

## Core Exports (Most Used)

### Profile & Psychology
```lua
exports['sv_mr_x']:GetProfile(citizenid)                    -- Get profile
exports['sv_mr_x']:GetReputation(citizenid)                 -- Get rep (0-100)
exports['sv_mr_x']:GetReputationTier(rep)                   -- 'easy'|'dilemma'|'high_risk'
exports['sv_mr_x']:AddReputation(citizenid, amount, reason) -- Modify rep
exports['sv_mr_x']:IsExempt(source)                         -- Check opt-out

-- NEW Psychology exports
exports['sv_mr_x']:RecordBehavior(cid, category, type, weight) -- Track behavior
exports['sv_mr_x']:ReevaluateArchetype(citizenid, source)      -- Recalculate archetype
exports['sv_mr_x']:CanClassify(profile)                        -- Check if enough data
exports['sv_mr_x']:GetPsychologySummary(citizenid)             -- Full psychology
exports['sv_mr_x']:GetInfluenceTactics(citizenid)              -- Manipulation tactics
```

### Communication
```lua
exports['sv_mr_x']:SendMrXMessage(source, message)          -- Send anonymous SMS
exports['sv_mr_x']:SendMrXEmail(source, subject, body)      -- Send email
exports['sv_mr_x']:SendMrXNotification(source, title, msg)  -- Push notification
```

### Missions
```lua
exports['sv_mr_x']:GenerateMission(source, forceType, callback)
exports['sv_mr_x']:ExecuteMission(source, mission, callback)
```

### HELP Services
```lua
exports['sv_mr_x']:IssueLoan(source)                        -- Rep 40+ loan ($5k-25k)
exports['sv_mr_x']:GetLocationTip(source)                   -- Rep 20+ tip ($5k)
exports['sv_mr_x']:CreateDiversion(source)                  -- Rep 65+ police diversion ($25k)
```

### HARM Actions
```lua
exports['sv_mr_x']:PostBounty(targetCid, amount, reason)    -- Post bounty
exports['sv_mr_x']:InitiateGangBetrayal(targetCid, reason)  -- Turn gang on itself
exports['sv_mr_x']:TriggerChaosSurprise(source, cid, type)  -- Trigger HARM
```

---

## HELP Service Pricing (v2.0)

### Record Clearing (EXPENSIVE!)
| Service | Cost | Min Rep |
|---------|------|---------|
| Clear BOLO | $25,000 | 50 |
| Clear Report | $50,000 | 60 |
| Clear Warrant | $75,000 | 70 |
| Clear Jail Record | $100,000 | 75 |
| Clear Case | $150,000 | 80 |
| **Clean Slate** | **$500k+ tiered** | **95** |

### Clean Slate Formula
```
$500,000 base + $100k/felony + $50k/warrant + $75k/case
```

### Other Services
| Service | Cost | Min Rep |
|---------|------|---------|
| Location Tip | $5,000 | 20 |
| Police Scanner | $10,000/30min | 35 |
| Target Intel | $15,000 | 45 |
| Gang Territory | $20,000 | 50 |
| Police Diversion | $25,000 | 65 |
| Safe House | $30,000/2hr | 55 |
| Fake Identity | $75,000/24hr | 70 |

### Loans
```
Amount: $5,000 - $25,000
Interest: 25%
Due: 48 REAL hours
Min Rep: 40
```

---

## Opt-Out System

Exempt players receive NO Mr. X contact (no HARM, no HELP, nothing).

**Exemption checks (in order):**
1. ACE permission `sv_mr_x.optout`
2. Always-exempt jobs
3. Job grade exemption (e.g., police grade 11+)
4. Exempt gangs
5. Database opted_out flag
6. Guardian archetype (auto-exempt)

```lua
-- Check exemption
local isExempt, reason = exports['sv_mr_x']:IsExempt(source)
-- reason: 'ace_permission' | 'exempt_job' | 'exempt_job_grade' | 'archetype_exempt' | etc.
```

---

## HARM Types (Chaos Engine)

| Type | Effect |
|------|--------|
| FAKE_WARRANT | Creates arrest warrant in police MDT |
| FAKE_REPORT | Creates incident report |
| FAKE_CASE | Opens investigation case |
| FAKE_BOLO | Bulletin about player/vehicle |
| FAKE_JAIL_RECORD | Adds conviction record |
| ANONYMOUS_TIP | Police dispatch to player location |
| HIT_SQUAD | 3 armed NPCs hunt player |
| DEBT_COLLECTOR | NPC demands loan repayment |
| PLAYER_BOUNTY | Posts bounty for other criminals |
| GANG_BETRAYAL | Turns same-gang members against target |
| LEAK_LOCATION | Sends player coords to rivals/police |

---

## Psychology-Based Manipulation

Mr. X uses Cialdini's 6 Principles:

| Principle | Example | Best For |
|-----------|---------|----------|
| Reciprocity | "I cleared that warrant. Now I need something." | Hustlers, Soldiers |
| Commitment | "You already took the money. You're in this now." | Everyone |
| Social Proof | "Others in your position succeeded." | Soldiers, Reformers |
| Authority | "I know things the police don't." | Fixers, Guardians |
| Liking | Mirror communication style | All |
| Scarcity | "This opportunity won't wait." | Wildcards, Hustlers |

**Loss Aversion:** Always frame as LOSS, not gain:
- ✓ "Refuse, and your reputation suffers."
- ✗ "Accept, and your reputation grows."

---

## Database Tables

| Table | Purpose |
|-------|---------|
| mr_x_profiles | Player profiles, archetype, psychology metrics |
| mr_x_behavior_events | Behavior tracking for classification |
| mr_x_eligible_gangs | Gangs eligible for bounties |
| mr_x_sessions | Conversation tracking |
| mr_x_events | Activity logging |
| mr_x_bounties | Active bounties |
| mr_x_loans | Loan tracking |
| mr_x_gang_relations | Gang betrayal state |

---

## Token Optimization

```lua
Config.OpenAI = {
    MaxTokens = {
        Mission = 500,      -- Was 1000
        Response = 150,     -- Brief responses
        Analysis = 300
    },
    UseCompactPrompt = true,
    CacheResponses = true,
    CacheDurationSec = 300
}
```

Saves ~85% on API costs per response.

---

## Admin Commands

`/mrx` - Opens admin panel (requires `admin` or `command.mrx` ACE)

---

## File Structure

```
sv_mr_x/
├── config.lua                 -- Configuration
├── db/mr_x_schema.sql         -- Database schema
├── db/migrations/001_archetype_system.sql -- Psychology tables
├── shared/constants.lua       -- 9 archetypes, behavior categories
├── data/MR_X_SYSTEM_PROMPT.md -- AI personality + psychology
├── server/
│   ├── profile.lua            -- Player profiles + psychology + opt-out
│   ├── reputation.lua         -- Rep system
│   ├── comms.lua              -- lb-phone integration
│   ├── mission_gen.lua        -- Mission generation (token-optimized)
│   ├── services.lua           -- HELP services
│   ├── tablet.lua             -- lb-tablet integration
│   ├── bounty.lua             -- Bounty + betrayal
│   ├── chaos.lua              -- Chaos engine
│   ├── webhook.lua            -- Web dashboard integration
│   ├── http_handler.lua       -- Manual commands endpoint
│   ├── admin.lua              -- Admin callbacks
│   └── main.lua               -- Entry point
└── client/
    └── admin_menu.lua         -- Admin UI
```

---

## Integration Points

### With tgg-banking (NEW)
- GetPlayerBalance, RemoveMoneyFromAccount
- Service payments, loan deposits

### With lb-phone
- SendMessage, SendMail, GetEquippedPhoneNumber
- Listens to `lb-phone:messages:messageSent`

### With lb-tablet
- CreatePoliceWarrant, CreatePoliceReport, CreatePoliceCase
- DeletePoliceWarrant (record clearing service)

### With sv_nexus_tools
- CallOpenAI (AI-powered conversations)
- GenerateMrXMission (AI mission generation)

### With rcore_cam
- Camera coverage checks for intel gathering
- Prevents omniscience in camera-free zones

---

## Common Patterns

### Check if player can receive Mr. X contact
```lua
local isExempt = exports['sv_mr_x']:IsExempt(source)
if isExempt then return end
```

### Track player behavior for classification
```lua
-- Violence indicator
exports['sv_mr_x']:RecordBehavior(citizenid, 'violence', 'player_kill', 2.0)

-- Loyalty indicator
exports['sv_mr_x']:RecordBehavior(citizenid, 'loyalty_crew', 'gang_activity', 1.5)

-- Method indicator
exports['sv_mr_x']:RecordBehavior(citizenid, 'calculated', 'stealth_mission', 1.0)
```

### Get manipulation tactics for a player
```lua
local tactics = exports['sv_mr_x']:GetInfluenceTactics(citizenid)
-- {primary = 'scarcity', secondary = 'reciprocity', frame = 'profit', use_loss_aversion = true}
```

### Check classification confidence
```lua
local profile = exports['sv_mr_x']:GetProfile(citizenid)
local canClassify, confidence = exports['sv_mr_x']:CanClassify(profile)
-- confidence: 'LOW' | 'MEDIUM' | 'HIGH'
```
