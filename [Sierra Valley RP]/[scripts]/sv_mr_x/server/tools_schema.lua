--[[
    Mr. X Tools Schema
    ==================
    OpenAI function calling schemas for autonomous agent behavior.

    These schemas define what tools the AI can invoke:
    - Communication (send_message, offer_mission)
    - Prospect Management (welcome_prospect, nudge_toward_job)
    - Reputation (adjust_reputation, record_fact)
    - Services (offer_loan, offer_service)
    - Harm (place_bounty, trigger_surprise)
    - Query (get_player_context, get_online_players, get_my_status)
    - Scheduling (schedule_action)
]]

local MrXTools = {}

-- ============================================
-- TOOL SCHEMAS
-- ============================================

MrXTools.Schema = {
    -- ===========================================
    -- COMMUNICATION TOOLS
    -- ===========================================
    {
        type = "function",
        ["function"] = {
            name = "send_message",
            description = "Send SMS, email, or notification to a player. Use cryptic, professional tone. Keep messages SHORT (1-2 sentences max).",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    message = {
                        type = "string",
                        description = "Message content (keep short, cryptic, menacing but professional)"
                    },
                    channel = {
                        type = "string",
                        enum = {"sms", "email", "notification"},
                        description = "SMS for quick messages, email for formal offers, notification for urgent alerts"
                    }
                },
                required = {"citizenid", "message", "channel"}
            }
        }
    },

    -- ===========================================
    -- MISSION TOOLS
    -- ===========================================
    {
        type = "function",
        ["function"] = {
            name = "offer_mission",
            description = "Generate and offer a mission to a player based on their profile and reputation tier",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    type = {
                        type = "string",
                        enum = {"delivery", "collection", "surveillance", "heist", "elimination"},
                        description = "Mission type (optional - system will auto-select appropriate difficulty)"
                    },
                    difficulty = {
                        type = "string",
                        enum = {"easy", "medium", "hard"},
                        description = "Mission difficulty (optional - system will auto-select based on rep)"
                    }
                },
                required = {"citizenid"}
            }
        }
    },

    -- ===========================================
    -- PROSPECT TOOLS (for new players)
    -- ===========================================
    {
        type = "function",
        ["function"] = {
            name = "welcome_prospect",
            description = "Welcome a NEW player to the city. Be friendly and helpful to build loyalty. Only use for players with low money, no job, no gang.",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    with_gift = {
                        type = "boolean",
                        description = "Include $500 welcome gift (costs Mr. X money)"
                    }
                },
                required = {"citizenid"}
            }
        }
    },
    {
        type = "function",
        ["function"] = {
            name = "nudge_toward_job",
            description = "Suggest a job/career path that serves Mr. X's interests to a prospect",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    job = {
                        type = "string",
                        enum = {"mechanic", "taxi", "trucker", "police", "ems"},
                        description = "Job to suggest"
                    },
                    reason = {
                        type = "string",
                        description = "Why this job (for internal tracking only)"
                    }
                },
                required = {"citizenid", "job"}
            }
        }
    },

    -- ===========================================
    -- REPUTATION TOOLS
    -- ===========================================
    {
        type = "function",
        ["function"] = {
            name = "adjust_reputation",
            description = "Modify a player's standing with Mr. X. Use sparingly.",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    delta = {
                        type = "integer",
                        minimum = -50,
                        maximum = 50,
                        description = "Amount to add (positive) or subtract (negative)"
                    },
                    reason = {
                        type = "string",
                        description = "Reason for the change (logged)"
                    }
                },
                required = {"citizenid", "delta", "reason"}
            }
        }
    },
    {
        type = "function",
        ["function"] = {
            name = "record_fact",
            description = "Store a discovered fact about a player for future reference. Mr. X remembers everything.",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    fact_type = {
                        type = "string",
                        description = "Category of fact (e.g., 'weakness', 'associate', 'secret', 'debt', 'preference')"
                    },
                    value = {
                        type = "string",
                        description = "The fact content"
                    }
                },
                required = {"citizenid", "fact_type", "value"}
            }
        }
    },

    -- ===========================================
    -- SERVICE TOOLS
    -- ===========================================
    {
        type = "function",
        ["function"] = {
            name = "offer_loan",
            description = "Offer a loan to a player. Interest rates are non-negotiable. Failure to repay triggers consequences.",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    amount = {
                        type = "integer",
                        minimum = 1000,
                        maximum = 50000,
                        description = "Loan amount in dollars"
                    },
                    interest_percent = {
                        type = "integer",
                        minimum = 10,
                        maximum = 50,
                        description = "Interest rate (default 20%)"
                    },
                    days_to_repay = {
                        type = "integer",
                        minimum = 1,
                        maximum = 7,
                        description = "Days until due (default 3)"
                    }
                },
                required = {"citizenid", "amount"}
            }
        }
    },
    {
        type = "function",
        ["function"] = {
            name = "offer_service",
            description = "Offer a premium service to a trusted player (reputation 50+)",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    service = {
                        type = "string",
                        enum = {"intel", "record_clear", "protection", "tip"},
                        description = "Service type: intel=player info, record_clear=remove warrants, tip=location hint"
                    }
                },
                required = {"citizenid", "service"}
            }
        }
    },

    -- ===========================================
    -- HARM TOOLS (require justification)
    -- ===========================================
    {
        type = "function",
        ["function"] = {
            name = "place_bounty",
            description = "Place a bounty on a player. ONLY use for: betrayal, unpaid debts, repeated disobedience. Requires clear justification.",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    amount = {
                        type = "integer",
                        minimum = 5000,
                        maximum = 50000,
                        description = "Bounty amount"
                    },
                    reason = {
                        type = "string",
                        description = "Justification for the bounty (REQUIRED - logged and reviewed)"
                    }
                },
                required = {"citizenid", "amount", "reason"}
            }
        }
    },
    {
        type = "function",
        ["function"] = {
            name = "trigger_surprise",
            description = "Execute a punitive action against a player who has wronged Mr. X. ONLY for serious offenses.",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    type = {
                        type = "string",
                        enum = {"fake_warrant", "fake_report", "hit_squad", "leak_location", "debt_collector"},
                        description = "Surprise type"
                    },
                    reason = {
                        type = "string",
                        description = "Justification for the action (REQUIRED - logged)"
                    }
                },
                required = {"citizenid", "type", "reason"}
            }
        }
    },

    -- ===========================================
    -- QUERY TOOLS (read-only)
    -- ===========================================
    {
        type = "function",
        ["function"] = {
            name = "get_player_context",
            description = "Get full context about a player: profile, reputation, facts, history. USE THIS FIRST before making decisions about a player.",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    }
                },
                required = {"citizenid"}
            }
        }
    },
    {
        type = "function",
        ["function"] = {
            name = "get_online_players",
            description = "Get list of all online players with basic info (citizenid, name, job, reputation)",
            parameters = {
                type = "object",
                properties = {}
            }
        }
    },
    {
        type = "function",
        ["function"] = {
            name = "get_my_status",
            description = "Get Mr. X's current financial status and mood. This affects how generous or harsh you should be.",
            parameters = {
                type = "object",
                properties = {}
            }
        }
    },

    -- ===========================================
    -- SCHEDULING TOOL
    -- ===========================================
    {
        type = "function",
        ["function"] = {
            name = "schedule_action",
            description = "Schedule a tool call for later execution (e.g., follow-up message, escalation if debt unpaid)",
            parameters = {
                type = "object",
                properties = {
                    tool = {
                        type = "string",
                        description = "Name of the tool to execute later"
                    },
                    arguments = {
                        type = "object",
                        description = "Arguments to pass to the tool"
                    },
                    delay_minutes = {
                        type = "integer",
                        minimum = 1,
                        maximum = 10080,
                        description = "Minutes to wait before executing (max 7 days)"
                    }
                },
                required = {"tool", "arguments", "delay_minutes"}
            }
        }
    },

    -- ===========================================
    -- RESPONSE TOOL
    -- ===========================================
    {
        type = "function",
        ["function"] = {
            name = "generate_response",
            description = "Generate a text response to send as the final message. Use ONLY when you need to respond to a player's direct message.",
            parameters = {
                type = "object",
                properties = {
                    citizenid = {
                        type = "string",
                        description = "Target player's citizen ID"
                    },
                    message = {
                        type = "string",
                        description = "Response message (1-2 sentences, cryptic, professional)"
                    }
                },
                required = {"citizenid", "message"}
            }
        }
    }
}

-- ============================================
-- TOOL CATEGORIES (for safety checks)
-- ============================================

MrXTools.Categories = {
    query = {"get_player_context", "get_online_players", "get_my_status"},
    communication = {"send_message", "generate_response"},
    mission = {"offer_mission"},
    prospect = {"welcome_prospect", "nudge_toward_job"},
    reputation = {"adjust_reputation", "record_fact"},
    service = {"offer_loan", "offer_service"},
    harm = {"place_bounty", "trigger_surprise"},
    scheduling = {"schedule_action"}
}

-- ============================================
-- TOOL REQUIREMENTS
-- ============================================

MrXTools.Requirements = {
    place_bounty = {minRep = -100, requiresSafety = true, maxPerDay = 10},
    trigger_surprise = {minRep = -100, requiresSafety = true, maxPerDay = 5},
    offer_loan = {minRep = 50, requiresSafety = true, maxPerWeek = 1},
    record_clear = {minRep = 60},
    welcome_prospect = {targetMustBeProspect = true},
    nudge_toward_job = {targetMustBeProspect = true}
}

-- ============================================
-- EXPORTS
-- ============================================

exports('GetToolsSchema', function() return MrXTools.Schema end)
exports('GetToolCategories', function() return MrXTools.Categories end)
exports('GetToolRequirements', function() return MrXTools.Requirements end)

return MrXTools
