func = {}

func.add = function(src, plate)
    exports["qb-vehiclekeys"]:GiveKeys(src, plate)
end

func.remove = function(src, plate)
    exports["qb-vehiclekeys"]:RemoveKeys(src, plate)
end

return func