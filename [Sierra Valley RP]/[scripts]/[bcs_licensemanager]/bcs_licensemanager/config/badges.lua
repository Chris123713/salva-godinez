---@class Badge
---@field department string
---@field ped string
---@field coords table<number, vector4>

--- The name for this example will be 'lspd_badge'
Config.BadgeItemName = function(department)
    return department:lower() .. '_badge'
end

Config.Badges = {
    ['LSPD'] = {
        color = '#3693ed',
        manager = {
            'police', 'lscso'
        }
    },
    ['BCSO'] = {
        color = '#FFCC03',
        manager = {
            'police', 'lscso'
        }
    },
    ['SASP'] = {
        color = '#8D6F64',
        manager = {
            'police', 'lscso'
        }
    }
}

Config.BadgesManager = {
    police = {
        ped = 's_m_y_hwaycop_01',
        permissions = {
            viewManager = { ['police'] = 11 },
            creator = { ['police'] = 11 },
            edit = {
                ['police'] = 11,
            },
            delete = {
                ['police'] = 11
            }
        },
        coord = {
            vector4(463.297821, -984.891724, 30.689899, 175.007828)
        }
    }
}

Config.BadgesManager.lscso = {
    ped = 's_m_y_hwaycop_01',
    permissions = {
        viewManager = { ['lscso'] = 11 },
        creator = { ['lscso'] = 11 },
        edit = {
            ['lscso'] = 11,
        },
        delete = {
            ['lscso'] = 11
        }
    },
    coord = {
        vector4(1732.847534, 3889.170654, 39.780682, 40.923004),
        vector4(-459.231323, 6018.958496, 35.136333, 48.501511)
    }
}

for k, badge in pairs(Config.Badges) do
    if type(badge.manager) == 'string' and Config.BadgesManager[badge.manager] then
        if not Config.BadgesManager[badge.manager] then
            Config.BadgesManager[badge.manager].badges = {}
        end
        Config.BadgesManager[badge.manager].badges[k] = badge
    elseif type(badge.manager) == 'table' then
        for _, manager in pairs(badge.manager) do
            if Config.BadgesManager[manager].badges then
                Config.BadgesManager[manager].badges[k] = badge
            elseif Config.BadgesManager[manager] then
                Config.BadgesManager[manager].badges = {}
                Config.BadgesManager[manager].badges[k] = badge
            end
        end
    else
        print(string.format('[^1ERROR^0]: Please make sure ^2%s^0 in the badge ^2%s^0 exists in the ^badges.lua',
            badge.manager, k))
    end
end
