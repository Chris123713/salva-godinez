local paths = {}

local function LoadIsometricFurnituresPath()
    for j = 1, #Config.IsometricFurnitures do
        local dir = Scandir(GetResourcePath(GetCurrentResourceName()) .. '/furniture/' .. Config.IsometricFurnitures[j])
        for i = 1, #dir, 1 do
            if dir[i]:match('.lua') then
                table.insert(paths, ('furniture/%s/%s'):format(Config.IsometricFurnitures[j], dir[i]:gsub('.lua', '')))
            end
        end
    end
end

local function LoadFurnituresPath()
    local dir = Scandir(GetResourcePath(GetCurrentResourceName()) .. '/furniture')
    if dir then
        for i = 1, #dir, 1 do
            if dir[i]:match('.lua') then
                table.insert(paths, ('furniture/%s'):format(dir[i]:gsub('.lua', '')))
            end
        end
    end
end

CreateThread(function()
    LoadFurnituresPath()
    LoadIsometricFurnituresPath()

    for i = 1, #paths, 1 do
        local furnitures = lib.load(paths[i])
        if furnitures.list then
            for j = 1, #furnitures.list, 1 do
                ModelList[furnitures.list[j].model] = furnitures.list[j]
                ModelList[furnitures.list[j].model].category = furnitures.label
            end
        end
    end
end)

lib.callback.register('Housing:server:GetFurniture', function(source)
    return paths
end)
