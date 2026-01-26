Jobs = {
    settings = {
        cancel_key = 167,           -- Cancel job button
        cooldown = 2,               -- Jobs refresh time (minutes)
    },
    available_loads = {
       -- LEVEL 1-2 - BEGINNER WORKS (MIXED DIFFICULTIES)
        { id = 2, trailer = "tanker2", name = "Water Tank Reinforcement", level = 1, difficulty = "easy", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 7, trailer = "docktrailer", name = "Furniture Transport", level = 1, difficulty = "easy", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 9, trailer = "docktrailer", name = "Brick Transport", level = 1, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 11, trailer = "docktrailer", name = "Plastics Transport", level = 1, difficulty = "easy", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 12, trailer = "docktrailer", name = "Clothing Transport", level = 1, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 13, trailer = "docktrailer", name = "Chair Transport", level = 1, difficulty = "easy", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 14, trailer = "docktrailer", name = "Appliance Transport", level = 2, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 15, trailer = "docktrailer", name = "Cleaning Supplies Transport", level = 2, difficulty = "easy", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 16, trailer = "docktrailer", name = "Refined Timber Transport", level = 2, difficulty = "hard", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 17, trailer = "docktrailer", name = "Stone Transport", level = 2, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},

       -- LEVEL 2-3 - MIXED DIFFICULTY CARGOES
        { id = 22, trailer = "trailers4", name = "Naval Articles Trailer", level = 2, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 34, trailer = "trailerlogs", name = "Log Transportation", level = 2, difficulty = "easy", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 35, trailer = "trailers", name = "Construction Transport", level = 3, difficulty = "hard", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 36, trailer = "trailers", name = "Rubber Transport", level = 3, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 40, trailer = "trailers", name = "Sawdust Transport", level = 3, difficulty = "easy", cargoType = "general", trucks = "packer,hauler,phantom"},

      -- LEVEL 3-4 - KEEPDRY CARGOES WITH VARIED DIFFICULTY (5% BONUS)
        { id = 41, trailer = "trailers2", name = "Grape Transport", level = 3, difficulty = "medium", cargoType = "keepdry", trucks = "packer,hauler,phantom"},
        { id = 42, trailer = "trailers2", name = "Pork Transport", level = 3, difficulty = "easy", cargoType = "keepdry", trucks = "packer,hauler,phantom"},
        { id = 43, trailer = "trailers2", name = "Beef Transport", level = 3, difficulty = "hard", cargoType = "keepdry", trucks = "packer,hauler,phantom"},
        { id = 44, trailer = "trailers2", name = "Carrot Transport", level = 4, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 45, trailer = "trailers2", name = "Potato Transport", level = 4, difficulty = "easy", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 46, trailer = "trailers2", name = "Milk Transport", level = 4, difficulty = "hard", cargoType = "keepdry", trucks = "packer,hauler,phantom"},
        { id = 47, trailer = "trailers2", name = "Canned Goods Transport", level = 4, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 1, trailer = "tanker", name = "Fuel Tank Transport", level = 4, difficulty = "hard", cargoType = "petrol", trucks = "packer,hauler,phantom"},

        -- LEVELS 5-7 - FRAGILE SHIPMENTS (12% BONUS)
        { id = 8, trailer = "docktrailer", name = "Refrigerator Transport", level = 5, difficulty = "easy", cargoType = "fragile", trucks = "packer,hauler,phantom"},
        { id = 19, trailer = "docktrailer", name = "Glass Transport", level = 5, difficulty = "medium", cargoType = "fragile", trucks = "packer,hauler,phantom"},
        { id = 48, trailer = "trailers2", name = "Frozen Meat Transport", level = 5, difficulty = "medium", cargoType = "keepdry,fragile", trucks = "packer,hauler,phantom"},
        { id = 49, trailer = "trailers2", name = "Bean Transport", level = 6, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 50, trailer = "trailers2", name = "Vinegar Transport", level = 6, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 51, trailer = "trailers2", name = "Lemonade Transport", level = 6, difficulty = "medium", cargoType = "keepdry", trucks = "packer,hauler,phantom"},
        { id = 52, trailer = "trailers2", name = "Bottled Water Transport", level = 7, difficulty = "medium", cargoType = "keepdry", trucks = "packer,hauler,phantom"},
        { id = 53, trailer = "trailers2", name = "Cheese Transport", level = 7, difficulty = "medium", cargoType = "keepdry", trucks = "packer,hauler,phantom"},
        { id = 54, trailer = "trailers3", name = "Tile Transport", level = 7, difficulty = "medium", cargoType = "fragile", trucks = "packer,hauler,phantom"},

        -- LEVEL 8-10 - OIL AND VALUABLE CARGO (18-22% BONUS)
        { id = 21, trailer = "tr4", name = "Luxury Car Transport", level = 8, difficulty = "medium", cargoType = "valuable", trucks = "packer,hauler,phantom"},
        { id = 27, trailer = "tanker", name = "Fuel Tank with Additives", level = 8, difficulty = "medium", cargoType = "petrol", trucks = "packer,hauler,phantom"},
        { id = 28, trailer = "tanker2", name = "Common Fuel Tank", level = 8, difficulty = "medium", cargoType = "petrol", trucks = "packer,hauler,phantom"},
        { id = 29, trailer = "tanker2", name = "Kerosene Tank", level = 9, difficulty = "medium", cargoType = "petrol", trucks = "packer,hauler,phantom"},
        { id = 30, trailer = "tanker2", name = "Oil Tank", level = 9, difficulty = "medium", cargoType = "petrol", trucks = "packer,hauler,phantom"},
        { id = 37, trailer = "trailers", name = "Appliance Transportation", level = 9, difficulty = "medium", cargoType = "fragile", trucks = "packer,hauler,phantom"},
        { id = 38, trailer = "trailers", name = "Vaccines Transport", level = 10, difficulty = "medium", cargoType = "fragile,keepdry,valuable", trucks = "packer,hauler,phantom"},

       -- LEVELS 11-14 - SHIPMENTS WITH HIGHER BONUS (25-30% BONUS)
        { id = 4, trailer = "tanker2", name = "Flammable Gas Tank", level = 11, difficulty = "medium", cargoType = "adr1", trucks = "packer,hauler,phantom"},
        { id = 10, trailer = "docktrailer", name = "Imported Products Transport", level = 11, difficulty = "medium", cargoType = "valuable", trucks = "packer,hauler,phantom"},
        { id = 25, trailer = "trailers4", name = "Materials for Shows Transport", level = 12, difficulty = "medium", cargoType = "fragile,valuable", trucks = "packer,hauler,phantom"},
        { id = 33, trailer = "docktrailer", name = "Armaments Transport", level = 12, difficulty = "hard", cargoType = "valuable,adr1", trucks = "packer,hauler,phantom"},
        { id = 55, trailer = "trailers3", name = "Rail Transport", level = 13, difficulty = "medium", cargoType = "valuable", trucks = "packer,hauler,phantom"},
        { id = 56, trailer = "trailers3", name = "Used Packaging Transport", level = 13, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 57, trailer = "trailers3", name = "Floor Plate Transport", level = 14, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},
        { id = 58, trailer = "trailers3", name = "Ceramic Transport", level = 14, difficulty = "medium", cargoType = "fragile", trucks = "packer,hauler,phantom"},
        { id = 59, trailer = "trailers3", name = "Scrap Transport", level = 14, difficulty = "medium", cargoType = "general", trucks = "packer,hauler,phantom"},

        -- LEVEL 15-17 - DANGEROUS CARGO (HIGH BONUS)
        { id = 3, trailer = "tanker2", name = "Corrosive Materials Tank", level = 15, difficulty = "hard", cargoType = "adr1", trucks = "packer,hauler,phantom"},
        { id = 5, trailer = "tanker2", name = "Toxic Gas Tank", level = 15, difficulty = "hard", cargoType = "adr1", trucks = "packer,hauler,phantom"},
        { id = 6, trailer = "trailers", name = "Materials Transport", level = 15, difficulty = "medium", cargoType = "adr1", trucks = "packer,hauler,phantom"},
        { id = 18, trailer = "docktrailer", name = "Jewels Transport", level = 16, difficulty = "hard", cargoType = "fragile,valuable", trucks = "packer,hauler,phantom"},
        { id = 20, trailer = "docktrailer", name = "Ammo Transport", level = 16, difficulty = "hard", cargoType = "adr1,valuable", trucks = "packer,hauler,phantom"},
        { id = 23, trailer = "trailers4", name = "Boat Trailer", level = 17, difficulty = "hard", cargoType = "fragile,valuable", trucks = "packer,hauler,phantom"},
        { id = 24, trailer = "tr4", name = "Stork Trailer", level = 17, difficulty = "hard", cargoType = "fragile,valuable", trucks = "packer,hauler,phantom"},
        
        -- LEVEL 18-20 - MOST DANGEROUS CARGOES (HIGHEST BONUS)
        { id = 26, trailer = "trailers4", name = "Event Materials Transport", level = 18, difficulty = "hard", cargoType = "valuable", trucks = "packer,hauler,phantom"},
        { id = 31, trailer = "docktrailer", name = "Exotic Materials Transport", level = 18, difficulty = "hard", cargoType = "fragile,valuable", trucks = "packer,hauler,phantom"},
        { id = 32, trailer = "docktrailer", name = "Rare Materials Transport", level = 19, difficulty = "hard", cargoType = "fragile,valuable", trucks = "packer,hauler,phantom"},
        { id = 39, trailer = "trailers", name = "Explosives Transport", level = 19, difficulty = "hard", cargoType = "adr1", trucks = "packer,hauler,phantom"},
        { id = 60, trailer = "trailers4", name = "Fireworks Transport", level = 19, difficulty = "hard", cargoType = "adr1,fragile", trucks = "packer,hauler,phantom"},
        { id = 61, trailer = "trailers4", name = "Explosives Transport", level = 20, difficulty = "hard", cargoType = "adr1", trucks = "packer,hauler,phantom"},
        { id = 62, trailer = "trailers4", name = "Dynamite Transport", level = 20, difficulty = "hard", cargoType = "adr1,fragile", trucks = "packer,hauler,phantom"},
        { id = 63, trailer = "trailers4", name = "White Phosphorus Transport", level = 20, difficulty = "hard", cargoType = "adr1", trucks = "packer,hauler,phantom"}
    }
}

return Jobs 