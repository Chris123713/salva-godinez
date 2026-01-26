func = {}

func.add = function(plate)
    exports["wasabi_carlock"]:GiveKey(plate)
end

func.remove = function(plate)
    exports["wasabi_carlock"]:RemoveKey(plate)
end

return func