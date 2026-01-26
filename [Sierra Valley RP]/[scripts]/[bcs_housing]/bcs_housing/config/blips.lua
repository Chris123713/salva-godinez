Config = Config or {}

Config.Blips = {
    house_sell = {
        enable = true,
        sprite = 350,
        colour = 43,
        scale = 0.5,
        label = 'House for Sale',
        category = 12
    },
    -- For Admin to be able to see other player houses
    admin_owned_house = {
        label = 'Player House',
        enable = true,
        sprite = 40,
        colour = 50,
        scale = 0.6,
        category = 13
    },
    -- For Realestate to be able to see other player houses
    agent = {
        label = 'Realestate house',
        enable = true,
        sprite = 40,
        colour = 74,
        scale = 0.6,
        category = 14
    },
    agent_owned_house = {
        label = 'Player Estate House',
        enable = true,
        sprite = 40,
        colour = 65,
        scale = 0.6,
        category = 15
    },
    owned_house = {
        enable = true,
        sprite = 40,
        colour = 60,
        scale = 0.8,
        category = 16,
        label = 'Owned House'
    },
    apartment_sell = {
        enable = true,
        sprite = 476,
        colour = 43,
        scale = 0.5,
        label = 'Apartment for Sale',
        category = 17
    },
    owned_apartment = {
        enable = true,
        sprite = 475,
        colour = 60,
        scale = 0.8,
        category = 18,
        label = 'Owned Apartment'
    },
    owned_flat = {
        enable = true,
        sprite = 475,
        colour = 47,
        scale = 0.8,
        category = 19,
        label = 'Owned Flat'
    },
    flat_available = {
        enable = true,
        sprite = 476,
        colour = 2,
        scale = 0.8,
        label = 'Flat for Sale',
        category = 20
    },
    flat_unavailable = {
        enable = true,
        sprite = 475,
        colour = 76,
        scale = 0.8,
        label = 'Flat Unavailable',
        category = 21
    },
    disabled_house = {
        enable = true,
        sprite = 374,
        colour = 1,
        scale = 0.7,
        label = 'Disabled House',
        category = 22
    }
}
