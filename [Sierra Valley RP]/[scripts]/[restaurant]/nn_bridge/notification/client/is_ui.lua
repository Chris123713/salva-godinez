func = {}

func.show = function(data)
    exports["is_ui"]:Notify(data.title, data.message, data.duration, data.style)
end

return func