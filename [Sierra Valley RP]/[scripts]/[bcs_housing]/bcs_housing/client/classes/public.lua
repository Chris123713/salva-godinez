Public = {}

Public.__index = Public

Public.__newindex = function(self, name, fn)
    rawset(self, name, fn)
end

function Public:new(home)
    local self = setmetatable({}, Public)
    self.name = home.name
    self.zones = {}
    self.points = {}
    self.identifier = home.identifier
    self:SetEntranceZone(home.entry, home.name)
    return self
end

function Public:SetEntranceZone(entry, label)
    local homeId = self.identifier
    if Config.target then
        AddTargetBoxZone('entrance-' .. label, {
            coords = ToVector3(entry),
            length = 2.0,
            width = 2.0,
            heading = entry.w,
            debugPoly = Config.debug,
            minZ = entry.z - 1.0,
            maxZ = entry.z + 2.0
        }, {
            options = {
                {
                    icon = "fas fa-door-open",
                    label = locale('enter_home'),
                    action = function()
                        TriggerEvent('Housing:client:EnterHome', self.identifier, false)
                    end
                },
            },
            distance = 3.5
        })
    else
        self.zones.entranceZone = lib.zones.box({
            name = 'entrance-' .. label,
            coords = ToVector3(entry),
            size = vec3(1.5, 1.5, 2.5),
            rotation = entry.w,
            debug = Config.debug,
            onExit = ExitZone,
            inside = function()
                if IsControlJustPressed(0, 38) then
                    TriggerEvent("Housing:client:CreateMenu", {
                        title = label,
                        subtitle = locale('house_entrance_menu'),
                        boxes = {
                            {
                                text = {
                                    title = locale('enter_home')
                                },
                                icon = 'eye',
                                event = "Housing:client:EnterHome",
                                args = { homeId, false }
                            }
                        }
                    })
                end
            end
        })
    end
    if Config.EnableMarkers.enable then
        self.points.entrance = lib.points.new({
            coords = ToVector3(entry),
            distance = 3,
            nearby = function()
                ---@diagnostic disable-next-line
                DrawMarker(Config.EnableMarkers.type, ToVector3(entry), 0.0, 0.0, 0.0, 0, 0.0, 0.0,
                    Config.EnableMarkers.size.x, Config.EnableMarkers.size.y, Config.EnableMarkers.size.z,
                    Config.EnableMarkers.color.r, Config.EnableMarkers.color.g, Config.EnableMarkers.color.b, 100, false,
                    ---@diagnostic disable-next-line
                    true, 2, false, false, false, false)
            end
        })
    end
end

function Public:DestroyZone(name)
    if self.zones.entranceZone then
        self.zones.entranceZone:remove()
    elseif Config.target then
        RemoveTargetZone('entrance-' .. name)
    end
    if Config.EnableMarkers.enable and self.points.entrance then
        self.points.entrance:remove()
    end
end
