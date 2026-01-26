# Mr. X - The Fixer

## Overview

sv_mr_x is a FiveM resource implementing an omniscient AI "fixer" character (Mr. X) who operates as a mysterious benefactor and threat to players. Mr. X contacts players via lb-phone, assigns personalized missions, maintains persistent player profiles with reputation-based scaling, and operates an autonomous chaos engine.

**Key Features:**
- Anonymous communication via lb-phone (SMS, email, calls, notifications)
- AI-powered mission generation using sv_nexus_tools (with token optimization)
- Persistent player profiles with psychology-based 9-archetype system
- HELP services for high-reputation players (loans, intel, record clearing)
- HARM options for punishments (fake warrants, bounties, hit squads, gang betrayal)
- Configurable proactive contact system
- Camera-aware intelligence (uses rcore_cam coverage)
- tgg-banking integration for financial operations
- Web dashboard for admin observation and manual control
- Comprehensive opt-out system for exempt players (PD/EMS leadership)
- Admin testing menu via `/mrx` command

**Version:** 2.0.0 (Psychology System Update)

---

## Table of Contents

1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Database Schema](#database-schema)
4. [Player Profiles & Psychology System](#player-profiles--psychology-system)
5. [Archetype Classification](#archetype-classification)
6. [Reputation System](#reputation-system)
7. [Communication System](#communication-system)
8. [Mission Generation](#mission-generation)
9. [Services (HELP Options)](#services-help-options)
10. [Chaos Engine & HARM Options](#chaos-engine--harm-options)
11. [Bounty & Betrayal System](#bounty--betrayal-system)
12. [Banking Integration](#banking-integration)
13. [Web Dashboard](#web-dashboard)
14. [Opt-Out System](#opt-out-system)
15. [Token Optimization](#token-optimization)
16. [Admin Interface](#admin-interface)
17. [Exports Reference](#exports-reference)
18. [Events Reference](#events-reference)
19. [Troubleshooting](#troubleshooting)

---

## Installation

### Dependencies

| Resource | Version | Required |
|----------|---------|----------|
| ox_lib | 3.32.2+ | Yes |
| oxmysql | 2.12.0+ | Yes |
| qbx_core | 1.23.0+ | Yes |
| lb-phone | 2.5.1+ | Yes |
| tgg-banking | 1.0.0+ | Yes (Financial ops) |
| sv_nexus_tools | 1.0.0+ | No (AI features) |
| lb-tablet | 1.5.5+ | No (MDT integration) |
| rcore_cam | 1.0.0+ | No (Camera intel) |

### Setup Steps

1. Place `sv_mr_x` in your resources folder
2. Run the SQL migrations:
   ```bash
   mysql -u root -p fivem < resources/[scripts]/sv_mr_x/db/mr_x_schema.sql
   mysql -u root -p fivem < resources/[scripts]/sv_mr_x/db/migrations/001_archetype_system.sql
   ```
3. Add to server.cfg:
   ```cfg
   ensure sv_mr_x
   ```
4. Configure `config.lua` as needed
5. **Important:** Resource starts in TEST MODE by default - use `/mrx` to disable for production
6. (Optional) Set up web dashboard - see [Web Dashboard](#web-dashboard) section

### ACE Permissions

```cfg
# Admin access to /mrx command
add_ace group.admin command.mrx allow

# Opt-out permission (for players who should never receive Mr. X contact)
add_ace identifier.discord:123456789 sv_mr_x.optout allow
```

---

## Configuration

### Master Control

```lua
Config.TestMode = true  -- When true, NO automated actions occur
```

### Reputation Tiers

```lua
Config.Reputation = {
    Tiers = {
        EASY = {min = 0, max = 20},        -- New players, simple tasks
        DILEMMA = {min = 21, max = 50},    -- Proven players, moral choices
        HIGH_RISK = {min = 51, max = 100}  -- Trusted operatives, high stakes
    },
    Changes = {
        MissionSuccess = 5,
        MissionFailure = -10,
        MissionAbandoned = -15,
        LoanRepaid = 3,
        LoanDefaulted = -20,
        BountyCompleted = 8
    }
}
```

### Banking Integration (NEW)

```lua
Config.Banking = {
    PrimaryResource = 'tgg-banking',    -- Primary banking script
    PaymentMethods = {'cash', 'bank'},  -- Available payment methods
    DefaultMethod = 'bank',
    AllowBalanceCheck = true,           -- Mr. X can check player balances
    AllowTransfers = true,              -- Enable bank transfers for payments
    MinBalanceForHighTier = 100000      -- Minimum for high-tier services
}
```

### Loan Settings

```lua
Config.Services.Loans = {
    MinAmount = 5000,
    MaxAmount = 25000,
    InterestRate = 0.25,    -- 25% interest
    DueHours = 48,          -- 48 REAL hours (not game hours)
    UseRealTime = true,     -- When true, uses real-world time
    DefaultPenalty = -25,
    minRep = 40
}
```

### Archetype Classification Timing (NEW)

```lua
Config.Archetypes = {
    -- Prevent premature classification
    MinEventsForClassification = 8,        -- Need 8+ behavior events
    MinTimeBeforeClassification = 7200,    -- 2 hours of gameplay minimum
    RequireDirectInteraction = true,       -- Must interact with Mr. X first

    -- Evidence thresholds
    AxisThresholds = {
        method = 3.0,   -- Score difference needed for method axis
        loyalty = 3.0   -- Score difference needed for loyalty axis
    },

    -- Confidence tracking
    ConfidenceLevels = {
        LOW = {minEvents = 0, label = 'Observing'},
        MEDIUM = {minEvents = 8, label = 'Preliminary'},
        HIGH = {minEvents = 20, label = 'Confident'}
    }
}
```

### Token Optimization (NEW)

```lua
Config.OpenAI = {
    Model = 'gpt-4o-mini',
    Temperature = 0.8,

    MaxTokens = {
        Mission = 500,      -- Mission generation
        Response = 150,     -- Conversation responses
        Analysis = 300      -- Player analysis
    },

    UseCompactPrompt = true,       -- Use condensed prompts
    CacheSystemPrompt = true,
    ExcludeVerboseContext = true,  -- Skip detailed history
    CacheResponses = true,
    CacheDurationSec = 300
}
```

---

## Database Schema

### Tables

| Table | Purpose |
|-------|---------|
| `mr_x_profiles` | Player profiles (rep, archetype, psychology metrics) |
| `mr_x_behavior_events` | Behavioral tracking for classification |
| `mr_x_eligible_gangs` | Gangs eligible for bounty hunting |
| `mr_x_sessions` | Conversation sessions |
| `mr_x_events` | Activity logging |
| `mr_x_bounties` | Active/claimed bounties |
| `mr_x_loans` | Emergency loans |
| `mr_x_gang_relations` | Gang betrayal tracking |

### Key Fields in mr_x_profiles

```sql
citizenid VARCHAR(50) PRIMARY KEY,
reputation INT DEFAULT 0,
archetype VARCHAR(50) DEFAULT 'unclassified',
bucket VARCHAR(20) DEFAULT 'civilian',       -- authority/civilian/criminal
method_axis VARCHAR(20) DEFAULT 'opportunistic',
loyalty_axis VARCHAR(20) DEFAULT 'self',
behavior_metrics JSON,                        -- Psychology tracking
classification_confidence VARCHAR(20),
history JSON,
known_facts JSON,
opted_out TINYINT(1) DEFAULT 0
```

---

## Player Profiles & Psychology System

### The 9-Archetype System (NEW)

Mr. X classifies players using a GTA-flavored alignment system inspired by D&D:

**3 Primary Buckets (Based on Job/Role):**
| Bucket | Jobs | Description |
|--------|------|-------------|
| AUTHORITY | Police, EMS, DOJ | Law enforcement, emergency services |
| CIVILIAN | Legitimate businesses | Gray area, potential recruitment |
| CRIMINAL | Gangs, unemployed + crime history | Core targets |

**2 Behavioral Axes:**

**Method Axis (HOW they operate):**
- **Calculated** - Plans carefully, patient, minimal collateral
- **Opportunistic** - Takes chances, flexible morals
- **Reckless** - Impulsive, violent, high heat

**Loyalty Axis (WHO they serve):**
- **Civic** - Follows rules, community-minded
- **Self** - Personal gain, looks out for #1
- **Crew** - Gang/family first, team player

### The 9 Archetypes

| Archetype | Method | Loyalty | Description | Mr. X Approach |
|-----------|--------|---------|-------------|----------------|
| GUARDIAN | Calculated | Civic | Clean cop, by-the-book | Exempt or rare intel |
| FIXER | Calculated | Self | Smart hustler | High-value services |
| SYNDICATE | Calculated | Crew | Organized crime boss | Strategic partnership |
| REFORMER | Opportunistic | Civic | Vigilante | Moral dilemmas |
| HUSTLER | Opportunistic | Self | Wheeler-dealer | Quick cash |
| SOLDIER | Opportunistic | Crew | Loyal gang member | Standard criminal work |
| LOOSE_CANNON | Reckless | Civic | Dirty cop | Chaos opportunities |
| WILDCARD | Reckless | Self | Unpredictable loner | High-risk/reward |
| ENFORCER | Reckless | Crew | Gang muscle | HARM-heavy missions |

### Classification Timing

**Important:** Mr. X doesn't classify players too early. He waits for clear signals:

1. Minimum 8 behavior events recorded
2. Minimum 2 hours of gameplay
3. At least one direct interaction with Mr. X
4. Clear evidence (3.0+ score difference between axes)

Until classified, players remain `UNCLASSIFIED` and receive generic missions.

### Psychology-Based Manipulation

Mr. X uses Cialdini's 6 Influence Principles:

| Principle | Example | Best For |
|-----------|---------|----------|
| **Reciprocity** | "I cleared that warrant. Now I need something." | Hustlers, Soldiers |
| **Commitment** | "You already took the money. You're in this now." | Everyone |
| **Social Proof** | "Others in your position succeeded." | Soldiers, Reformers |
| **Authority** | "I know things the police don't." | Fixers, Guardians |
| **Liking** | Mirror communication style | All |
| **Scarcity** | "This opportunity won't wait." | Wildcards, Hustlers |

**Loss Aversion:** Mr. X frames consequences as losses, not gains:
- ✓ "Refuse, and your reputation suffers."
- ✗ "Accept, and your reputation grows."

---

## Archetype Classification

### Behavior Tracking

```lua
-- Record player behaviors
exports['sv_mr_x']:RecordBehavior(citizenid, 'violence', 'player_kill', 2.0)
exports['sv_mr_x']:RecordBehavior(citizenid, 'calculated', 'stealth_mission', 1.0)
exports['sv_mr_x']:RecordBehavior(citizenid, 'loyalty_crew', 'gang_activity', 1.5)
```

**Behavior Categories:**
- `violence`, `stealth`, `trade` - Activity types
- `loyalty_crew`, `loyalty_self`, `loyalty_civic` - Loyalty indicators
- `reckless`, `calculated`, `opportunistic` - Method indicators

### Manual Reevaluation

```lua
-- Force archetype reevaluation
local newArchetype = exports['sv_mr_x']:ReevaluateArchetype(citizenid, source)

-- Get psychology summary
local summary = exports['sv_mr_x']:GetPsychologySummary(citizenid)
-- Returns: {archetype, bucket, method, loyalty, traits, tactics, reputation}

-- Get influence tactics for a player
local tactics = exports['sv_mr_x']:GetInfluenceTactics(citizenid)
-- Returns: {primary, secondary, frame, use_loss_aversion, boost_reciprocity, ...}
```

---

## Reputation System

### Tier Thresholds

| Tier | Range | Description |
|------|-------|-------------|
| EASY | 0-20 | New players, simple tasks, low payouts |
| DILEMMA | 21-50 | Proven players, moral choices, moderate payouts |
| HIGH_RISK | 51-100 | Trusted operatives, complex operations, high payouts |

### Reputation Functions

```lua
local rep = exports['sv_mr_x']:GetReputation(citizenid)
local tier = exports['sv_mr_x']:GetReputationTier(rep)
exports['sv_mr_x']:AddReputation(citizenid, 10, 'mission_success', source)
```

---

## Communication System

All communications from Mr. X appear as **anonymous/unknown** to the player.

### Sending Messages

```lua
exports['sv_mr_x']:SendMrXMessage(source, "I've been watching you.")
exports['sv_mr_x']:SendMrXEmail(source, "New Assignment", "Details here...", actions)
exports['sv_mr_x']:SendMrXNotification(source, "Mr. X", "Your presence is requested.")
```

---

## Mission Generation

### Payout Ranges by Tier

| Tier | Min Payout | Max Payout |
|------|------------|------------|
| EASY | $1,000 | $5,000 |
| DILEMMA | $5,000 | $15,000 |
| HIGH_RISK | $15,000 | $50,000 |

### Archetype-Specific Mission Content

| Archetype | Mission Types | Example Brief |
|-----------|---------------|---------------|
| GUARDIAN | Intel tips | "I need eyes on something the department can't touch." |
| FIXER | Trade, negotiation | "You understand return on investment." |
| SYNDICATE | Territory, coordination | "Your operation could be larger." |
| REFORMER | Gray-area justice | "The law can't touch them. You can." |
| HUSTLER | Quick cash, scams | "Fast money for someone who thinks fast." |
| SOLDIER | Gang work, delivery | "Your crew needs you." |
| LOOSE_CANNON | Revenge, chaos | "Someone needs to pay. I know who." |
| WILDCARD | High-risk | "No one else would take this job." |
| ENFORCER | Violence, intimidation | "Some messages need to be delivered personally." |

---

## Services (HELP Options)

### Record Clearing Services (lb-tablet integration)

**IMPORTANT:** Record clearing is EXPENSIVE and requires HIGH reputation.

| Service | Cost | Min Rep | Description |
|---------|------|---------|-------------|
| Clear Warrant | $75,000 | 70 | Remove single active warrant |
| Clear Report | $50,000 | 60 | Delete incident report from MDT |
| Clear Case | $150,000 | 80 | Dismiss ongoing investigation |
| Clear BOLO | $25,000 | 50 | Remove Be On Lookout alert |
| Clear Jail Record | $100,000 | 75 | Expunge conviction record |
| **Clean Slate** | **$500,000+** | **95** | **Complete record wipe** |

### Clean Slate Pricing (Tiered)

```lua
Total Cost = $500,000 base
           + $100,000 per felony conviction
           + $50,000 per active warrant
           + $75,000 per open case
```

Example: Player with 2 felonies, 1 warrant, 1 case = $500k + $200k + $50k + $75k = **$825,000**

### Intel Services

| Service | Cost | Min Rep |
|---------|------|---------|
| Location Tip | $5,000 | 20 |
| Target Intel | $15,000 | 45 |
| Gang Territory Intel | $20,000 | 50 |
| Police Scanner | $10,000/30min | 35 |

### Emergency Services

| Service | Cost | Min Rep |
|---------|------|---------|
| Police Diversion | $25,000 | 65 |
| Safe House | $30,000/2hr | 55 |
| Fake Identity | $75,000/24hr | 70 |

### Emergency Loans

```lua
Amount: $5,000 - $25,000
Interest: 25%
Due: 48 REAL hours
Min Rep: 40
Default Penalty: -25 rep
```

---

## Chaos Engine & HARM Options

### HARM Types

**Record Manipulation:**
| Type | Effect |
|------|--------|
| FAKE_WARRANT | Creates arrest warrant in MDT |
| FAKE_REPORT | Creates incident report |
| FAKE_CASE | Opens investigation case |
| FAKE_BOLO | Bulletin about player/vehicle |
| FAKE_JAIL_RECORD | Adds conviction record |

**Physical Threats:**
| Type | Effect |
|------|--------|
| HIT_SQUAD | 3 armed NPCs hunt player |
| AMBUSH | Hostile NPCs at location |
| DEBT_COLLECTOR | NPC demanding payment |

**Information Warfare:**
| Type | Effect |
|------|--------|
| ANONYMOUS_TIP | Police dispatch to location |
| LEAK_LOCATION | Coords sent to rivals |
| VEHICLE_TRACKER | Tracks player vehicle |

**Player vs Player:**
| Type | Effect |
|------|--------|
| PLAYER_BOUNTY | Bounty offered to criminals |
| GANG_CONTRACT | Contract sent to rival gang |
| GANG_BETRAYAL | Turn same gang members against target |

---

## Banking Integration

### tgg-banking Integration

Mr. X uses tgg-banking for financial operations:

```lua
-- Check player balance (requires AllowBalanceCheck = true)
local balance = exports['tgg-banking']:GetPlayerBalance(citizenid)

-- Transfer money (for service payments, loan deposits)
exports['tgg-banking']:RemoveMoneyFromAccount(citizenid, amount, 'Mr. X Service')
```

### Payment Processing

Services can be paid via:
- **Cash** - Taken from player's pocket
- **Bank** - Withdrawn from tgg-banking account

---

## Web Dashboard

### Overview

The web dashboard provides real-time observation and manual control of Mr. X activities.

**Features:**
- Live event log (messages, missions, chaos, bounties)
- Online player list with profiles
- Manual message sending with AI refactor
- Chaos engine controls
- Service administration

### Setup

1. Navigate to `mr_x_dashboard/` directory
2. Run `npm install`
3. Copy `.env.example` to `.env` and configure:
   ```
   PORT=3000
   ADMIN_USER=admin
   ADMIN_PASS=your_secure_password
   WEBHOOK_SECRET=mr_x_webhook_secret_change_me
   FIVEM_ENDPOINT=http://localhost:30120/mr_x/manual
   OPENAI_API_KEY=sk-your-key-here
   ```
4. Start dashboard: `npm start`
5. Enable in config.lua:
   ```lua
   Config.WebServer.Enabled = true
   Config.WebServer.Secret = 'mr_x_webhook_secret_change_me'
   ```

### Endpoints

| Endpoint | Purpose |
|----------|---------|
| `GET /` | Dashboard UI |
| `POST /api/events` | Receive webhooks from Lua |
| `GET /api/events` | Get recent events |
| `POST /api/manual` | Send manual message |
| `GET /api/players` | Get tracked players |

---

## Opt-Out System

Players can be exempted from ALL Mr. X contact.

### Exemption Hierarchy

1. **ACE Permission** - `sv_mr_x.optout`
2. **Exempt Jobs** - Configured list
3. **Exempt Job Grades** - e.g., Police Sergeant+ (grade 11+)
4. **Exempt Gangs** - Configured list
5. **Manual Opt-Out** - Database flag
6. **Guardian Archetype** - Auto-exempt

### Default Exemptions

```lua
Config.OptOut.ExemptJobGrades = {
    {job = 'police', minGrade = 11},   -- Police Sergeant+
    {job = 'lscso', minGrade = 11},    -- LSCSO Sergeant+
    {job = 'lspd', minGrade = 3},      -- LSPD Sergeant+
    {job = 'sast', minGrade = 8},      -- SASP Sergeant+
    {job = 'safr', minGrade = 3},      -- EMS Supervisor+
    {job = 'doj', minGrade = 0}        -- All DOJ members
}
```

---

## Token Optimization

### Why Optimize?

API calls cost money. The token optimization system reduces costs by:
- Using compact system prompts
- Caching responses for 5 minutes
- Limiting max tokens per request
- Excluding verbose context when possible

### Settings

```lua
Config.OpenAI = {
    MaxTokens = {
        Mission = 500,   -- Was 1000
        Response = 150,  -- Brief responses
        Analysis = 300
    },
    UseCompactPrompt = true,
    CacheResponses = true,
    CacheDurationSec = 300
}
```

### Token Savings

| Before | After | Savings |
|--------|-------|---------|
| ~1000 tokens/response | ~150 tokens/response | 85% |
| No caching | 5-min cache | Variable |
| Full context | Essential only | ~40% |

---

## Admin Interface

Access via `/mrx` command (requires admin ACE permission).

### Menu Sections

1. **Test Mode Toggle**
2. **Profile Management** (view, set rep, change archetype)
3. **Send Test Message** (SMS, Email, Notification)
4. **Generate Mission** (by tier, execute)
5. **Chaos Engine** (start/stop, scan, trigger)
6. **Services** (loans, records, bounties)
7. **Opt-Out Management**
8. **View Events**

---

## Exports Reference

### Profile Module

| Export | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `GetProfile` | citizenid | table\|nil | Get profile |
| `CreateProfile` | citizenid, playerData? | table | Create profile |
| `UpdateProfile` | citizenid, updates | boolean | Update profile |
| `GetOrCreateProfile` | citizenid, playerData? | table | Get or create |
| `DetermineBucket` | playerData | string | Get bucket |
| `ReevaluateArchetype` | citizenid, source? | string | Reevaluate |
| `CanClassify` | profile | boolean, string | Check classification |
| `RecordBehavior` | citizenid, category, type, weight?, context? | void | Track behavior |
| `GetInfluenceTactics` | citizenid | table | Get manipulation tactics |
| `GetPsychologySummary` | citizenid | table | Get full psychology |
| `IsExempt` | source | boolean, string | Check exemption |
| `IsGangEligible` | gangName | boolean | Check gang eligibility |

### Reputation Module

| Export | Parameters | Returns |
|--------|------------|---------|
| `GetReputation` | citizenid | number |
| `AddReputation` | citizenid, amount, reason, source? | number |
| `SetReputation` | citizenid, value, reason, source? | boolean |
| `GetReputationTier` | reputation | string |

### Communication Module

| Export | Parameters | Returns |
|--------|------------|---------|
| `SendMrXMessage` | source, message | boolean |
| `SendMrXEmail` | source, subject, body, actions? | boolean |
| `SendMrXNotification` | source, title, message | boolean |

### Mission Module

| Export | Parameters | Returns |
|--------|------------|---------|
| `GenerateMission` | source, forceType?, callback | void |
| `ExecuteMission` | source, mission, callback | void |
| `HandleMissionCompletion` | citizenid, missionId, outcome, source? | void |

### Webhook Module

| Export | Parameters | Returns |
|--------|------------|---------|
| `PostWebhook` | eventType, data, priority? | void |
| `PostWebhookMessage` | direction, citizenid, channel, content, source | void |
| `PostWebhookMission` | eventType, citizenid, missionData | void |

---

## Events Reference

### Server Events

| Event | Parameters |
|-------|------------|
| `sv_mr_x:server:acceptMission` | data |
| `sv_mr_x:server:requestLoan` | - |
| `sv_mr_x:server:repayLoan` | - |

### Internal Events

| Event | Parameters |
|-------|------------|
| `sv_mr_x:internal:generateResponse` | source, citizenid, message, session |
| `sv_mr_x:internal:playerBecameThreat` | citizenid, source |

---

## Troubleshooting

### Common Issues

**Players getting classified too early:**
- Increase `MinEventsForClassification` (default: 8)
- Increase `MinTimeBeforeClassification` (default: 7200 seconds)
- Enable `RequireDirectInteraction`

**API costs too high:**
- Enable `UseCompactPrompt`
- Enable `CacheResponses`
- Lower `MaxTokens.Response`
- Set `ExcludeVerboseContext = true`

**Banking not working:**
- Verify tgg-banking is started
- Check `Config.Banking.PrimaryResource` matches your banking script
- Ensure `AllowTransfers = true`

**Loans expiring too fast:**
- Verify `UseRealTime = true` (uses real hours, not game hours)
- Adjust `DueHours` as needed

### Debug Mode

```lua
Config.Debug = true
```

---

## Version History

### v2.0.0 (Current)
- 9-archetype psychology system
- Cialdini influence principles
- Classification timing controls
- tgg-banking integration
- Token optimization
- Web dashboard
- Enhanced HELP/HARM pricing

### v1.0.0
- Initial release
- Basic archetypes
- Core communication
- Chaos engine

---

## License

This resource is proprietary to Sierra Valley RP.
