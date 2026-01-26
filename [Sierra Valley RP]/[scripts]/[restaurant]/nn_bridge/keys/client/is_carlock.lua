func = {}

func.add = function(plate)
    exports["is_carlock"]:GiveKey(plate)
end

func.remove = function(plate)
    exports["is_carlock"]:RemoveKey(plate)
end

return func