CCTV = {}

CCTV.__index = CCTV

CCTV.__newindex = function(self, name, fn)
    rawset(self, name, fn)
end

function CCTV:new(homeId)
    local self = setmetatable({}, CCTV)
    self.list = {}
    self.identifier = homeId
    self.current = 1
    return self
end

function CCTV:Enter(data)
    self.list = data
    self.current = 1
    if #self.list > 0 then
        TriggerEvent('Housing:client:ViewCCTV', self.identifier, self.list[self.current].coords,
            self.list[self.current].cam,
            self.list[self.current].pitch,
            self.list[self.current].yaw)
    end
end

function CCTV:NextCamera()
    if #self.list >= self.current + 1 then
        self.current += 1
        TriggerEvent('Housing:client:NextCam', self.identifier, self.list[self.current].coords,
            self.list[self.current].cam,
            self.list[self.current].pitch,
            self.list[self.current].yaw)
    else
        self.current = 1
        TriggerEvent('Housing:client:NextCam', self.identifier, self.list[self.current].coords,
            self.list[self.current].cam,
            self.list[self.current].pitch,
            self.list[self.current].yaw)
    end
end
