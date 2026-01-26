func = {}

func.show = function(data, finish, cancel)
    local data = {
        duration = data.duration,
        label = data.title,
        useWhileDead = data.useWhileDead or false,
        canCancel = data.canCancel or true,
        anim = data.animation and {
            dict = data.animation.dict,
            clip = data.animation.anim,
            flag = data.animation.flag,
        } or nil,
        disable = data.disable and {
            move = data.disable.move,
            car = data.disable.car,
            combat = data.disable.combat,
            mouse = data.disable.mouse,
            sprint = data.disable.sprint,
        } or nil,
        prop = data.prop and {
            model = data.prop.model,
            pos = data.prop.coords,
            rot = data.prop.rotation,
            bone = data.prop.bone,
        } or nil,
    }
    if lib.progressBar(data) then finish() else cancel() end
end

func.isActive = function()
    return lib.progressActive()
end

func.cancel = function()
    lib.cancelProgress()
end

return func