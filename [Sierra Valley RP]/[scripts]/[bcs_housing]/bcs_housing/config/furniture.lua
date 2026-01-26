Config = Config or {}

Config.FurnitureShop = {
    locations = {
        {
            coords = vec3(2753.46, 3470.33, 56.0),
            size = vec3(13.0, 4.0, 2.5),
            rotation = 65.0,
            -- Camera
            furnitureSpawn = vec3(2769.7773, 3467.4678, 55.5595),
        },
        {
            coords = vec3(-56.5972, 6524.1138, 31.4908),
            size = vec3(13.0, 4.0, 2.5),
            rotation = 313.4947,
            -- Camera
            furnitureSpawn = vec3(-43.3576, 6534.8525, 31.4909),
        }
    },
    -- Blip
    blip = {
        label = 'Furniture Store',
        sprite = 566,
        colour = 27,
        scale = 0.8,
    }
}

Config.IsometricFurnitures = {
    'bathroom',
    'bedroom',
    'kitchen',
    'living_room',
    'others'
}

Config.LimitFurniture = {
    ['computer'] = 4
}
