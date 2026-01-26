func = {}

func.show = function(data, finish, cancel)
    local progress = exports["is_ui"]:ProgressBar(data)

    if progress == true then
        finish()
    elseif progress == false then
        cancel()
    end
end

func.isActive = function()
    return exports["is_ui"]:IsProgressBarActive()
end

func.cancel = function()
    exports["is_ui"]:cancelProgressBar()
end

return func