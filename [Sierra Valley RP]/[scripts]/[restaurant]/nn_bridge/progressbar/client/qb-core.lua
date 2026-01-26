func = {}

func.show = function(data, finish, cancel)
    exports["progressbar"]:Progress({
        name = data.title,
        duration = data.duration,
        label = data.title,
        useWhileDead = data.useWhileDead,
        canCancel = data.canCancel,
        animation = data.animation and {
            animDict = data.animation.dict,
            anim = data.animation.anim,
            flags = data.animation.flag,
        } or nil,
        controlDisables = data.disable and {
            disableMovement = data.disable.move,
            disableCarMovement = data.disable.car,
            disableMouse = data.disable.mouse,
            disableCombat = data.disable.combat,
        } or nil,
        prop = data.prop,
        propTwo = data.propTwo,
    }, function(cancelled)
        if cancelled then
            cancel()
            return
        end

        finish()
    end)
end

func.isActive = function()
    return exports["progressbar"]:isDoingSomething()
end

func.cancel = function()
    TriggerEvent("progressbar:client:cancel")
end

return func