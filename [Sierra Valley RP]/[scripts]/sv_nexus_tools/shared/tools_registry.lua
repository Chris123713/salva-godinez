-- Tool definitions for AI prompt building and validation
-- This file describes available tools - actual handlers are in server/tools.lua

ToolsDefinitions = {}

-- Spawning Tools
ToolsDefinitions['safe_spawn_npc'] = {
    description = 'Spawn an NPC with collision and ground verification',
    category = Constants.ToolCategory.SPAWNING,
    params = {
        model = {type = 'string', required = true, description = 'Ped model name'},
        coords = {type = 'vector3', required = true, description = 'Target coordinates'},
        heading = {type = 'number', required = false, default = 0.0, description = 'Facing direction'},
        behavior = {type = 'string', required = false, default = 'idle', description = 'NPC behavior type'},
        dialog = {type = 'string', required = false, description = 'Dialog tree ID to attach'},
        networked = {type = 'boolean', required = false, default = true, description = 'Create as networked entity'}
    },
    returns = {netId = 'number', coords = 'vector3', adjusted = 'boolean'},
    roleHint = 'any'
}

ToolsDefinitions['safe_spawn_vehicle'] = {
    description = 'Spawn a vehicle on valid ground with optional mods',
    category = Constants.ToolCategory.SPAWNING,
    params = {
        model = {type = 'string', required = true, description = 'Vehicle model name'},
        coords = {type = 'vector3', required = true, description = 'Target coordinates'},
        heading = {type = 'number', required = false, default = 0.0, description = 'Facing direction'},
        locked = {type = 'boolean', required = false, default = false, description = 'Vehicle locked state'},
        fuel = {type = 'number', required = false, default = 100, description = 'Fuel level 0-100'},
        color = {type = 'table', required = false, description = 'Primary and secondary colors'},
        networked = {type = 'boolean', required = false, default = true, description = 'Create as networked entity'}
    },
    returns = {netId = 'number', coords = 'vector3', plate = 'string'},
    roleHint = 'any'
}

ToolsDefinitions['safe_spawn_prop'] = {
    description = 'Spawn a prop with clearance verification',
    category = Constants.ToolCategory.SPAWNING,
    params = {
        model = {type = 'string', required = true, description = 'Prop model name'},
        coords = {type = 'vector3', required = true, description = 'Target coordinates'},
        heading = {type = 'number', required = false, default = 0.0, description = 'Rotation'},
        interactive = {type = 'boolean', required = false, default = false, description = 'Add ox_target interaction'},
        frozen = {type = 'boolean', required = false, default = true, description = 'Freeze in place'}
    },
    returns = {netId = 'number', coords = 'vector3'},
    roleHint = 'any'
}

ToolsDefinitions['verify_spawn_zone'] = {
    description = 'Pre-check if coordinates are valid for spawning',
    category = Constants.ToolCategory.SPAWNING,
    params = {
        coords = {type = 'vector3', required = true, description = 'Coordinates to check'},
        radius = {type = 'number', required = false, default = 2.0, description = 'Check radius'},
        type = {type = 'string', required = false, default = 'any', description = 'Entity type to check for'}
    },
    returns = {valid = 'boolean', adjustedCoords = 'vector3', reason = 'string'},
    roleHint = 'any'
}

ToolsDefinitions['get_safe_coords'] = {
    description = 'Get valid spawn coordinates by theme/area type',
    category = Constants.ToolCategory.SPAWNING,
    params = {
        theme = {type = 'string', required = true, description = 'Zone theme (alley, parking, industrial, etc)'},
        nearCoords = {type = 'vector3', required = false, description = 'Prefer coords near this location'},
        radius = {type = 'number', required = false, default = 100.0, description = 'Search radius'}
    },
    returns = {coords = 'vector3', heading = 'number', theme = 'string'},
    roleHint = 'any'
}

-- Economy Tools
ToolsDefinitions['award_money'] = {
    description = 'Give money to a player',
    category = Constants.ToolCategory.ECONOMY,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        moneyType = {type = 'string', required = false, default = 'cash', description = 'cash, bank, or crypto'},
        amount = {type = 'number', required = true, description = 'Amount to give'},
        reason = {type = 'string', required = false, default = 'Mission reward', description = 'Transaction reason'}
    },
    returns = {success = 'boolean', newBalance = 'number'},
    roleHint = 'any'
}

ToolsDefinitions['deduct_money'] = {
    description = 'Take money from a player',
    category = Constants.ToolCategory.ECONOMY,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        moneyType = {type = 'string', required = false, default = 'cash', description = 'cash, bank, or crypto'},
        amount = {type = 'number', required = true, description = 'Amount to take'},
        reason = {type = 'string', required = false, default = 'Purchase', description = 'Transaction reason'}
    },
    returns = {success = 'boolean', error = 'string'},
    roleHint = 'any'
}

ToolsDefinitions['check_money'] = {
    description = 'Check player money balance',
    category = Constants.ToolCategory.ECONOMY,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        moneyType = {type = 'string', required = false, default = 'cash', description = 'cash, bank, or crypto'}
    },
    returns = {balance = 'number'},
    roleHint = 'any'
}

-- Inventory Tools
ToolsDefinitions['award_item'] = {
    description = 'Give an item to a player',
    category = Constants.ToolCategory.INVENTORY,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        item = {type = 'string', required = true, description = 'Item name'},
        count = {type = 'number', required = false, default = 1, description = 'Quantity'},
        metadata = {type = 'table', required = false, description = 'Item metadata'}
    },
    returns = {success = 'boolean'},
    roleHint = 'any'
}

ToolsDefinitions['remove_item'] = {
    description = 'Remove an item from a player',
    category = Constants.ToolCategory.INVENTORY,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        item = {type = 'string', required = true, description = 'Item name'},
        count = {type = 'number', required = false, default = 1, description = 'Quantity'}
    },
    returns = {success = 'boolean', error = 'string'},
    roleHint = 'any'
}

ToolsDefinitions['check_item'] = {
    description = 'Check if player has an item',
    category = Constants.ToolCategory.INVENTORY,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        item = {type = 'string', required = true, description = 'Item name'},
        minCount = {type = 'number', required = false, default = 1, description = 'Minimum required quantity'}
    },
    returns = {hasItem = 'boolean', count = 'number'},
    roleHint = 'any'
}

-- Dialog Tools
ToolsDefinitions['trigger_dialog'] = {
    description = 'Start an NPC conversation with a player',
    category = Constants.ToolCategory.DIALOG,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        npcNetId = {type = 'number', required = true, description = 'NPC network ID'},
        dialogTree = {type = 'table', required = true, description = 'Dialog tree structure'}
    },
    returns = {success = 'boolean'},
    roleHint = 'any'
}

-- Mission Tools
ToolsDefinitions['set_objective'] = {
    description = 'Update a player objective status',
    category = Constants.ToolCategory.MISSION,
    params = {
        missionId = {type = 'string', required = true, description = 'Mission UUID'},
        citizenid = {type = 'string', required = true, description = 'Player citizen ID'},
        objectiveId = {type = 'string', required = true, description = 'Objective identifier'},
        status = {type = 'string', required = true, description = 'pending, active, completed, failed, locked'}
    },
    returns = {success = 'boolean'},
    roleHint = 'any'
}

ToolsDefinitions['unlock_objective'] = {
    description = 'Unlock a locked objective for a player',
    category = Constants.ToolCategory.MISSION,
    params = {
        missionId = {type = 'string', required = true, description = 'Mission UUID'},
        citizenid = {type = 'string', required = true, description = 'Player citizen ID'},
        objectiveId = {type = 'string', required = true, description = 'Objective to unlock'}
    },
    returns = {success = 'boolean'},
    roleHint = 'any'
}

-- Phone Tools
ToolsDefinitions['send_phone_mail'] = {
    description = 'Send an email via lb-phone',
    category = Constants.ToolCategory.PHONE,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        subject = {type = 'string', required = true, description = 'Email subject'},
        message = {type = 'string', required = true, description = 'Email body'},
        sender = {type = 'string', required = false, default = 'Unknown', description = 'Sender name'}
    },
    returns = {success = 'boolean', mailId = 'number'},
    roleHint = 'any'
}

ToolsDefinitions['send_phone_notification'] = {
    description = 'Push a notification to player phone',
    category = Constants.ToolCategory.PHONE,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        title = {type = 'string', required = true, description = 'Notification title'},
        message = {type = 'string', required = true, description = 'Notification message'},
        icon = {type = 'string', required = false, default = 'fas fa-info-circle', description = 'Font Awesome icon'}
    },
    returns = {success = 'boolean'},
    roleHint = 'any'
}

-- Advanced Mission Tools (Phase 2)
ToolsDefinitions['spawn_enemy_wave'] = {
    description = 'Spawn a wave of hostile NPCs',
    category = Constants.ToolCategory.SPAWNING,
    params = {
        coords = {type = 'vector3', required = true, description = 'Center point for spawn'},
        count = {type = 'number', required = true, description = 'Number of enemies'},
        model = {type = 'string', required = false, default = 's_m_y_blackops_01', description = 'Ped model'},
        weapons = {type = 'table', required = false, description = 'Weapons to give'},
        spread = {type = 'number', required = false, default = 10.0, description = 'Spawn spread radius'}
    },
    returns = {netIds = 'table', count = 'number'},
    roleHint = 'any'
}

ToolsDefinitions['create_checkpoint'] = {
    description = 'Create a mission checkpoint zone',
    category = Constants.ToolCategory.MISSION,
    params = {
        coords = {type = 'vector3', required = true, description = 'Checkpoint location'},
        radius = {type = 'number', required = false, default = 5.0, description = 'Trigger radius'},
        objectiveId = {type = 'string', required = true, description = 'Objective to complete on enter'},
        missionId = {type = 'string', required = true, description = 'Associated mission'}
    },
    returns = {zoneId = 'string'},
    roleHint = 'any'
}

ToolsDefinitions['mark_escape_route'] = {
    description = 'Set GPS waypoint for escape',
    category = Constants.ToolCategory.MISSION,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        coords = {type = 'vector3', required = true, description = 'Destination coordinates'},
        blipSprite = {type = 'number', required = false, default = 1, description = 'Blip sprite ID'},
        blipColor = {type = 'number', required = false, default = 1, description = 'Blip color'}
    },
    returns = {success = 'boolean'},
    roleHint = 'criminal'
}

ToolsDefinitions['alert_dispatch'] = {
    description = 'Send alert to police dispatch',
    category = Constants.ToolCategory.MISSION,
    params = {
        coords = {type = 'vector3', required = true, description = 'Incident location'},
        code = {type = 'string', required = true, description = 'Alert code (10-31, etc)'},
        description = {type = 'string', required = true, description = 'Alert description'}
    },
    returns = {success = 'boolean', alertId = 'string'},
    roleHint = 'any'
}

-- ============================================
-- CRIMINAL TOOLS
-- ============================================

ToolsDefinitions['hack_terminal'] = {
    description = 'Create hackable terminal that reveals password/code on successful minigame completion',
    category = Constants.ToolCategory.CRIMINAL,
    params = {
        coords = {type = 'vector3', required = true, description = 'Terminal location'},
        difficulty = {type = 'string', required = false, default = 'medium', description = 'easy, medium, hard, extreme'},
        reward = {type = 'table', required = false, description = 'Reward on success: {type, data} - password, item, or money'},
        missionId = {type = 'string', required = false, description = 'Link to mission for objective tracking'},
        objectiveId = {type = 'string', required = false, description = 'Objective to complete on success'}
    },
    returns = {success = 'boolean', terminalId = 'string', netId = 'number'},
    roleHint = 'criminal',
    example = {
        name = 'hack_terminal',
        params = {
            coords = {x = 123.4, y = 456.7, z = 32.1},
            difficulty = 'hard',
            reward = {type = 'password', data = 'vault_code_4521'},
            missionId = 'mission_123',
            objectiveId = 'hack_security'
        }
    }
}

ToolsDefinitions['create_hostage_situation'] = {
    description = 'Spawn hostage NPC with negotiation mechanics for police standoff scenarios',
    category = Constants.ToolCategory.CRIMINAL,
    params = {
        coords = {type = 'vector3', required = true, description = 'Hostage location'},
        hostageCount = {type = 'number', required = false, default = 1, description = 'Number of hostages'},
        demands = {type = 'string', required = false, description = 'Ransom demands text'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', situationId = 'string', hostageNetIds = 'table'},
    roleHint = 'criminal',
    example = {
        name = 'create_hostage_situation',
        params = {
            coords = {x = 450.2, y = -980.5, z = 30.7},
            hostageCount = 2,
            demands = 'Release prisoner #4521 and provide helicopter',
            missionId = 'bank_heist_001'
        }
    }
}

ToolsDefinitions['spawn_loot_container'] = {
    description = 'Create searchable container with target item for collection objectives',
    category = Constants.ToolCategory.CRIMINAL,
    params = {
        coords = {type = 'vector3', required = true, description = 'Container location'},
        containerType = {type = 'string', required = false, default = 'safe', description = 'safe, crate, locker, drawer, trunk'},
        targetItem = {type = 'string', required = true, description = 'Primary item player must collect'},
        additionalLoot = {type = 'table', required = false, description = 'Extra items: [{name, count}]'},
        locked = {type = 'boolean', required = false, default = false, description = 'Requires lockpick'},
        missionId = {type = 'string', required = false, description = 'Link to mission'},
        objectiveId = {type = 'string', required = false, description = 'Objective to complete on collection'}
    },
    returns = {success = 'boolean', containerId = 'string', stashId = 'string'},
    roleHint = 'criminal',
    example = {
        name = 'spawn_loot_container',
        params = {
            coords = {x = 100.0, y = 200.0, z = 30.0},
            containerType = 'safe',
            targetItem = 'intel_document',
            additionalLoot = {{name = 'money', count = 5000}},
            locked = true,
            missionId = 'heist_001',
            objectiveId = 'retrieve_documents'
        }
    }
}

ToolsDefinitions['vehicle_tracker'] = {
    description = 'Place GPS tracker on vehicle for tracking objectives (police or criminal)',
    category = Constants.ToolCategory.CRIMINAL,
    params = {
        plate = {type = 'string', required = true, description = 'Vehicle license plate'},
        faction = {type = 'string', required = false, description = 'Which faction can see tracker: police, criminal, or specific gang'},
        missionId = {type = 'string', required = false, description = 'Link to mission'},
        duration = {type = 'number', required = false, default = 1800, description = 'Tracker duration in seconds'}
    },
    returns = {success = 'boolean', trackerId = 'string'},
    roleHint = 'any',
    example = {
        name = 'vehicle_tracker',
        params = {
            plate = 'ABC123',
            faction = 'police',
            missionId = 'surveillance_op',
            duration = 3600
        }
    }
}

ToolsDefinitions['forge_identity'] = {
    description = 'Create temporary fake ID documents for undercover missions',
    category = Constants.ToolCategory.CRIMINAL,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        fakeName = {type = 'string', required = true, description = 'Name on forged documents'},
        documentType = {type = 'string', required = false, default = 'drivers_license', description = 'drivers_license, passport, work_permit'},
        quality = {type = 'string', required = false, default = 'average', description = 'poor, average, good, excellent'},
        duration = {type = 'number', required = false, default = 3600, description = 'How long before expiry in seconds'}
    },
    returns = {success = 'boolean', identityId = 'string', expiresAt = 'number'},
    roleHint = 'criminal',
    example = {
        name = 'forge_identity',
        params = {
            source = 1,
            fakeName = 'John Smith',
            documentType = 'drivers_license',
            quality = 'good',
            duration = 7200
        }
    }
}

-- ============================================
-- POLICE & EMERGENCY TOOLS
-- ============================================

ToolsDefinitions['spawn_evidence'] = {
    description = 'Create collectible evidence prop linked to suspect for investigation',
    category = Constants.ToolCategory.POLICE,
    params = {
        coords = {type = 'vector3', required = true, description = 'Evidence location'},
        evidenceType = {type = 'string', required = false, default = 'generic', description = 'weapon, document, blood, shell_casing, phone, drugs, money, generic'},
        description = {type = 'string', required = false, description = 'Evidence description for collection'},
        linkedTo = {type = 'string', required = false, description = 'Suspect citizenid to link evidence'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', evidenceId = 'string', netId = 'number'},
    roleHint = 'police',
    example = {
        name = 'spawn_evidence',
        params = {
            coords = {x = 300.0, y = 400.0, z = 30.0},
            evidenceType = 'shell_casing',
            description = '9mm shell casing from shooting',
            linkedTo = 'ABC12345',
            missionId = 'investigation_001'
        }
    }
}

ToolsDefinitions['mark_crime_scene'] = {
    description = 'Create investigation zone with multiple evidence points',
    category = Constants.ToolCategory.POLICE,
    params = {
        coords = {type = 'vector3', required = true, description = 'Crime scene center'},
        radius = {type = 'number', required = false, default = 25.0, description = 'Scene radius'},
        crimeType = {type = 'string', required = true, description = 'homicide, robbery, assault, shooting, arson'},
        evidenceCount = {type = 'number', required = false, default = 3, description = 'Number of evidence pieces to spawn'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', sceneId = 'string', evidenceIds = 'table'},
    roleHint = 'police',
    example = {
        name = 'mark_crime_scene',
        params = {
            coords = {x = 500.0, y = 600.0, z = 30.0},
            radius = 30.0,
            crimeType = 'homicide',
            evidenceCount = 5,
            missionId = 'murder_case_001'
        }
    }
}

ToolsDefinitions['spawn_barrier'] = {
    description = 'Place police barriers or spike strips for roadblocks',
    category = Constants.ToolCategory.POLICE,
    params = {
        coords = {type = 'vector3', required = true, description = 'Barrier location'},
        barrierType = {type = 'string', required = false, default = 'barrier', description = 'barrier, cone, spike_strip, barrier_large, police_barrier'},
        heading = {type = 'number', required = false, default = 0, description = 'Barrier rotation'},
        count = {type = 'number', required = false, default = 1, description = 'Number of barriers in line'}
    },
    returns = {success = 'boolean', barrierId = 'string', count = 'number'},
    roleHint = 'police',
    example = {
        name = 'spawn_barrier',
        params = {
            coords = {x = 200.0, y = 300.0, z = 30.0},
            barrierType = 'spike_strip',
            heading = 90,
            count = 3
        }
    }
}

ToolsDefinitions['create_bolo'] = {
    description = 'Broadcast Be On Lookout alert to all police players',
    category = Constants.ToolCategory.POLICE,
    params = {
        type = {type = 'string', required = true, description = 'vehicle or person'},
        description = {type = 'string', required = true, description = 'BOLO description'},
        plate = {type = 'string', required = false, description = 'Vehicle plate if applicable'},
        model = {type = 'string', required = false, description = 'Vehicle model if applicable'},
        suspectDescription = {type = 'string', required = false, description = 'Person description if applicable'},
        lastSeen = {type = 'vector3', required = false, description = 'Last known location'},
        priority = {type = 'string', required = false, default = 'medium', description = 'low, medium, high, critical'}
    },
    returns = {success = 'boolean', boloId = 'string'},
    roleHint = 'police',
    example = {
        name = 'create_bolo',
        params = {
            type = 'vehicle',
            description = 'Suspect vehicle fleeing bank robbery',
            plate = 'XYZ789',
            model = 'sultan',
            priority = 'high',
            lastSeen = {x = 150.0, y = 250.0, z = 30.0}
        }
    }
}

ToolsDefinitions['medical_triage'] = {
    description = 'Spawn injured NPC for EMS rescue scenarios',
    category = Constants.ToolCategory.POLICE,
    params = {
        coords = {type = 'vector3', required = true, description = 'Patient location'},
        injuryType = {type = 'string', required = false, default = 'trauma', description = 'trauma, gunshot, burns, overdose, cardiac'},
        severity = {type = 'string', required = false, default = 'moderate', description = 'minor, moderate, severe, critical'},
        patientModel = {type = 'string', required = false, description = 'Ped model for patient'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', patientId = 'string', netId = 'number'},
    roleHint = 'emergency',
    example = {
        name = 'medical_triage',
        params = {
            coords = {x = 350.0, y = 450.0, z = 30.0},
            injuryType = 'gunshot',
            severity = 'critical',
            patientModel = 'a_m_m_business_01',
            missionId = 'ems_call_001'
        }
    }
}

ToolsDefinitions['lockdown_area'] = {
    description = 'Create police perimeter with restricted access zone',
    category = Constants.ToolCategory.POLICE,
    params = {
        coords = {type = 'vector3', required = true, description = 'Lockdown center'},
        radius = {type = 'number', required = false, default = 50.0, description = 'Perimeter radius'},
        reason = {type = 'string', required = false, default = 'Police operation', description = 'Reason for lockdown'},
        policeOnly = {type = 'boolean', required = false, default = true, description = 'Only allow police entry'},
        duration = {type = 'number', required = false, default = 600, description = 'Duration in seconds'}
    },
    returns = {success = 'boolean', lockdownId = 'string'},
    roleHint = 'police',
    example = {
        name = 'lockdown_area',
        params = {
            coords = {x = 400.0, y = 500.0, z = 30.0},
            radius = 75.0,
            reason = 'Active shooter situation',
            policeOnly = true,
            duration = 1200
        }
    }
}

-- ============================================
-- SOCIAL & FACTION TOOLS
-- ============================================

ToolsDefinitions['spread_rumor'] = {
    description = 'Create ambient rumor that NPCs share with players in area',
    category = Constants.ToolCategory.SOCIAL,
    params = {
        coords = {type = 'vector3', required = true, description = 'Rumor origin area'},
        content = {type = 'string', required = true, description = 'Rumor text NPCs share'},
        linkedInfo = {type = 'string', required = false, description = 'Intel revealed when rumor heard'},
        spreadRadius = {type = 'number', required = false, default = 50.0, description = 'Area where rumor spreads'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', rumorId = 'string'},
    roleHint = 'any',
    example = {
        name = 'spread_rumor',
        params = {
            coords = {x = 200.0, y = 300.0, z = 30.0},
            content = 'Word on the street is something big is going down at the docks tonight',
            linkedInfo = 'Shipment arriving at pier 4, 11pm',
            spreadRadius = 100.0,
            missionId = 'investigation_001'
        }
    }
}

ToolsDefinitions['spawn_informant'] = {
    description = 'Create NPC informant who sells real database information',
    category = Constants.ToolCategory.SOCIAL,
    params = {
        coords = {type = 'vector3', required = true, description = 'Informant location'},
        model = {type = 'string', required = false, description = 'Ped model'},
        infoType = {type = 'string', required = true, description = 'phone_number, address, criminal_record, vehicle_plate, gang_affiliation'},
        targetCitizenId = {type = 'string', required = true, description = 'Who the info is about'},
        price = {type = 'number', required = false, default = 500, description = 'Cost to buy info'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', informantId = 'string', netId = 'number'},
    roleHint = 'any',
    example = {
        name = 'spawn_informant',
        params = {
            coords = {x = 150.0, y = 250.0, z = 30.0},
            model = 'a_m_m_tramp_01',
            infoType = 'criminal_record',
            targetCitizenId = 'ABC12345',
            price = 1000,
            missionId = 'find_suspect_001'
        }
    }
}

ToolsDefinitions['create_meeting'] = {
    description = 'Create meeting zone where multiple parties must convene',
    category = Constants.ToolCategory.SOCIAL,
    params = {
        coords = {type = 'vector3', required = true, description = 'Meeting location'},
        radius = {type = 'number', required = false, default = 10.0, description = 'Meeting area radius'},
        requiredParties = {type = 'table', required = true, description = 'Array of citizenids who must attend'},
        title = {type = 'string', required = false, description = 'Meeting name'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', meetingId = 'string'},
    roleHint = 'any',
    example = {
        name = 'create_meeting',
        params = {
            coords = {x = 300.0, y = 400.0, z = 30.0},
            radius = 15.0,
            requiredParties = {'ABC12345', 'DEF67890'},
            title = 'Gang negotiation',
            missionId = 'peace_talks_001'
        }
    }
}

ToolsDefinitions['trigger_news_event'] = {
    description = 'Broadcast server-wide news notification',
    category = Constants.ToolCategory.SOCIAL,
    params = {
        headline = {type = 'string', required = true, description = 'News headline'},
        content = {type = 'string', required = true, description = 'Full news story'},
        category = {type = 'string', required = false, default = 'breaking', description = 'breaking, crime, business, sports'},
        duration = {type = 'number', required = false, default = 30000, description = 'Display duration in ms'}
    },
    returns = {success = 'boolean', newsId = 'string'},
    roleHint = 'any',
    example = {
        name = 'trigger_news_event',
        params = {
            headline = 'BREAKING: Bank Robbery in Progress Downtown',
            content = 'Police have surrounded the Fleeca Bank on Alta Street. Multiple hostages reported.',
            category = 'breaking',
            duration = 60000
        }
    }
}

ToolsDefinitions['bounty_system'] = {
    description = 'Place bounty on player visible to faction members',
    category = Constants.ToolCategory.SOCIAL,
    params = {
        targetCitizenId = {type = 'string', required = true, description = 'Target player citizenid'},
        amount = {type = 'number', required = true, description = 'Bounty reward amount'},
        reason = {type = 'string', required = false, description = 'Why bounty was placed'},
        postedBy = {type = 'string', required = true, description = 'Who posted the bounty (citizenid)'},
        faction = {type = 'string', required = false, description = 'Which faction can see/claim bounty'},
        anonymous = {type = 'boolean', required = false, default = true, description = 'Hide poster identity'}
    },
    returns = {success = 'boolean', bountyId = 'string'},
    roleHint = 'criminal',
    example = {
        name = 'bounty_system',
        params = {
            targetCitizenId = 'ABC12345',
            amount = 50000,
            reason = 'Snitched to the feds',
            postedBy = 'DEF67890',
            faction = 'ballas',
            anonymous = true
        }
    }
}

ToolsDefinitions['adjust_faction_rep'] = {
    description = 'Modify player standing with gang or faction',
    category = Constants.ToolCategory.SOCIAL,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        faction = {type = 'string', required = true, description = 'Gang/faction name'},
        amount = {type = 'number', required = true, description = 'Rep change (positive or negative)'},
        reason = {type = 'string', required = false, description = 'Reason for rep change'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', newRep = 'number'},
    roleHint = 'any',
    example = {
        name = 'adjust_faction_rep',
        params = {
            source = 1,
            faction = 'vagos',
            amount = 25,
            reason = 'Completed drug delivery',
            missionId = 'gang_work_001'
        }
    }
}

-- ============================================
-- WORLD & ECONOMY TOOLS
-- ============================================

ToolsDefinitions['traffic_block'] = {
    description = 'Create AI traffic jam for chase scenarios',
    category = Constants.ToolCategory.WORLD,
    params = {
        coords = {type = 'vector3', required = true, description = 'Block location'},
        radius = {type = 'number', required = false, default = 30.0, description = 'Traffic affected radius'},
        severity = {type = 'string', required = false, default = 'moderate', description = 'light, moderate, heavy, gridlock'},
        duration = {type = 'number', required = false, default = 300, description = 'Duration in seconds'}
    },
    returns = {success = 'boolean', blockId = 'string'},
    roleHint = 'any',
    example = {
        name = 'traffic_block',
        params = {
            coords = {x = 250.0, y = 350.0, z = 30.0},
            radius = 50.0,
            severity = 'heavy',
            duration = 600
        }
    }
}

ToolsDefinitions['spawn_ambient_event'] = {
    description = 'Create random world event for immersion or response',
    category = Constants.ToolCategory.WORLD,
    params = {
        coords = {type = 'vector3', required = true, description = 'Event location'},
        eventType = {type = 'string', required = true, description = 'car_crash, fight, fire, robbery, medical'},
        severity = {type = 'string', required = false, default = 'moderate', description = 'minor, moderate, major'},
        alertEmergency = {type = 'boolean', required = false, default = true, description = 'Notify police/EMS'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', eventId = 'string', netIds = 'table'},
    roleHint = 'any',
    example = {
        name = 'spawn_ambient_event',
        params = {
            coords = {x = 180.0, y = 280.0, z = 30.0},
            eventType = 'car_crash',
            severity = 'major',
            alertEmergency = true,
            missionId = 'ems_response_001'
        }
    }
}

ToolsDefinitions['create_delivery_task'] = {
    description = 'Create pickup/dropoff delivery objective',
    category = Constants.ToolCategory.WORLD,
    params = {
        source = {type = 'number', required = true, description = 'Player server ID'},
        pickupCoords = {type = 'vector3', required = true, description = 'Pickup location'},
        dropoffCoords = {type = 'vector3', required = true, description = 'Delivery destination'},
        item = {type = 'string', required = true, description = 'Item to deliver'},
        count = {type = 'number', required = false, default = 1, description = 'Item quantity'},
        reward = {type = 'number', required = false, default = 500, description = 'Completion reward'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', deliveryId = 'string'},
    roleHint = 'civilian',
    example = {
        name = 'create_delivery_task',
        params = {
            source = 1,
            pickupCoords = {x = 100.0, y = 200.0, z = 30.0},
            dropoffCoords = {x = 500.0, y = 600.0, z = 30.0},
            item = 'delivery_package',
            count = 1,
            reward = 1500,
            missionId = 'courier_job_001'
        }
    }
}

ToolsDefinitions['spawn_customer_npc'] = {
    description = 'Create NPC who wants to buy/trade with player',
    category = Constants.ToolCategory.WORLD,
    params = {
        coords = {type = 'vector3', required = true, description = 'Customer location'},
        model = {type = 'string', required = false, description = 'Ped model'},
        wantedItem = {type = 'string', required = true, description = 'Item customer wants to buy'},
        wantedCount = {type = 'number', required = false, default = 1, description = 'Quantity wanted'},
        paymentAmount = {type = 'number', required = true, description = 'Amount customer will pay'},
        missionId = {type = 'string', required = false, description = 'Link to mission'},
        objectiveId = {type = 'string', required = false, description = 'Objective to complete on sale'}
    },
    returns = {success = 'boolean', customerId = 'string', netId = 'number'},
    roleHint = 'civilian',
    example = {
        name = 'spawn_customer_npc',
        params = {
            coords = {x = 220.0, y = 320.0, z = 30.0},
            model = 'a_m_y_business_02',
            wantedItem = 'weed_baggie',
            wantedCount = 5,
            paymentAmount = 250,
            missionId = 'dealer_sales_001',
            objectiveId = 'sell_product'
        }
    }
}

ToolsDefinitions['witness_event'] = {
    description = 'Spawn NPC witness with information from database',
    category = Constants.ToolCategory.WORLD,
    params = {
        coords = {type = 'vector3', required = true, description = 'Witness location'},
        model = {type = 'string', required = false, description = 'Ped model'},
        infoType = {type = 'string', required = true, description = 'saw_crime, heard_gunshots, saw_vehicle, knows_suspect'},
        relatedCitizenId = {type = 'string', required = false, description = 'Who the info is about'},
        infoContent = {type = 'string', required = true, description = 'Information witness shares'},
        missionId = {type = 'string', required = false, description = 'Link to mission'}
    },
    returns = {success = 'boolean', witnessId = 'string', netId = 'number'},
    roleHint = 'any',
    example = {
        name = 'witness_event',
        params = {
            coords = {x = 270.0, y = 370.0, z = 30.0},
            model = 'a_f_y_business_01',
            infoType = 'saw_vehicle',
            relatedCitizenId = 'ABC12345',
            infoContent = 'I saw a red sports car speed off toward the highway. Plate started with XY.',
            missionId = 'investigation_001'
        }
    }
}

-- Utility function to get all tool definitions for AI prompts
function GetToolDefinitionsForAI()
    local definitions = {}
    for name, def in pairs(ToolsDefinitions) do
        definitions[#definitions + 1] = {
            name = name,
            description = def.description,
            category = def.category,
            params = def.params,
            roleHint = def.roleHint
        }
    end
    return definitions
end
