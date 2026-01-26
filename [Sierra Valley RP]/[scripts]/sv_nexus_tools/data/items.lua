--[[
    sv_nexus_tools Item Definitions
    Add these to your ox_inventory/data/items.lua or merge with existing items
]]

return {
    -- Evidence Collection
    ['evidence_bag'] = {
        label = 'Evidence Bag',
        weight = 100,
        stack = false,
        close = true,
        description = 'A sealed evidence bag containing forensic evidence',
        client = {
            image = 'evidence_bag.png'
        }
    },

    -- Vehicle Tracking
    ['vehicle_tracker'] = {
        label = 'GPS Tracker',
        weight = 50,
        stack = true,
        close = true,
        description = 'A small GPS tracking device that can be attached to vehicles',
        client = {
            image = 'gps_tracker.png'
        }
    },

    -- Forged Documents
    ['forged_id'] = {
        label = 'Forged ID',
        weight = 10,
        stack = false,
        close = true,
        description = 'A fake identification document',
        client = {
            image = 'fake_id.png'
        }
    },

    ['forged_license'] = {
        label = 'Forged License',
        weight = 10,
        stack = false,
        close = true,
        description = 'A forged drivers license',
        client = {
            image = 'fake_license.png'
        }
    },

    -- Hacking Tools
    ['usb_hack_device'] = {
        label = 'USB Hack Device',
        weight = 50,
        stack = true,
        close = true,
        description = 'A USB device loaded with hacking software',
        client = {
            image = 'usb_device.png'
        }
    },

    ['laptop_hacker'] = {
        label = 'Hacker Laptop',
        weight = 2000,
        stack = false,
        close = true,
        description = 'A laptop configured for network intrusion',
        client = {
            image = 'laptop.png'
        }
    },

    -- Intel Items
    ['intel_document'] = {
        label = 'Intel Document',
        weight = 20,
        stack = false,
        close = true,
        description = 'A document containing sensitive information',
        client = {
            image = 'document.png'
        }
    },

    ['burner_phone'] = {
        label = 'Burner Phone',
        weight = 100,
        stack = false,
        close = true,
        description = 'A disposable phone with stored contacts',
        client = {
            image = 'burner_phone.png'
        }
    },

    -- Hostage/Emergency Items
    ['zip_ties'] = {
        label = 'Zip Ties',
        weight = 20,
        stack = true,
        close = true,
        description = 'Plastic zip ties for restraining',
        client = {
            image = 'zip_ties.png'
        }
    },

    ['first_aid_kit'] = {
        label = 'First Aid Kit',
        weight = 500,
        stack = true,
        close = true,
        description = 'Basic medical supplies for emergency treatment',
        client = {
            image = 'first_aid.png'
        }
    },

    -- Delivery/Trade Items (examples - customize as needed)
    ['delivery_package'] = {
        label = 'Delivery Package',
        weight = 500,
        stack = false,
        close = true,
        description = 'A sealed package for delivery',
        client = {
            image = 'package.png'
        }
    },

    ['contraband_package'] = {
        label = 'Suspicious Package',
        weight = 1000,
        stack = false,
        close = true,
        description = 'A package of unknown contents',
        client = {
            image = 'suspicious_package.png'
        }
    },

    -- Bounty/Faction Items
    ['bounty_contract'] = {
        label = 'Bounty Contract',
        weight = 10,
        stack = false,
        close = true,
        description = 'A contract detailing a bounty target',
        client = {
            image = 'contract.png'
        }
    },

    ['faction_token'] = {
        label = 'Faction Token',
        weight = 10,
        stack = true,
        close = true,
        description = 'A token of faction membership or favor',
        client = {
            image = 'token.png'
        }
    },

    -- Police Equipment
    ['police_tape'] = {
        label = 'Police Tape',
        weight = 100,
        stack = true,
        close = true,
        description = 'Crime scene barrier tape',
        client = {
            image = 'police_tape.png'
        }
    },

    ['forensic_kit'] = {
        label = 'Forensic Kit',
        weight = 1000,
        stack = false,
        close = true,
        description = 'Professional forensic evidence collection kit',
        client = {
            image = 'forensic_kit.png'
        }
    },

    ['spike_strip'] = {
        label = 'Spike Strip',
        weight = 5000,
        stack = false,
        close = true,
        description = 'Tire puncture strip for vehicle pursuit',
        client = {
            image = 'spike_strip.png'
        }
    }
}
