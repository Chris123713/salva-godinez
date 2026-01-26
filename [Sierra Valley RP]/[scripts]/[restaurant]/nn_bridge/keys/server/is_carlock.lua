func = {}

func.add = function(src, plate)
    exports["is_carlock"]:GiveKey(src, plate)
end

func.remove = function(src, plate)
    exports["is_carlock"]:RemoveKey(src, plate)
end

return func