----------
Config.MakeTournamentBlipShortRange = false -- Make this true if you want the tournament blip short range only on the minimap.
----------
----------
Config.TournamentCooldowns = 150 -- (Minutes) how much time inbetween tournaments | Default is set to 2 hours and 30 minutes (# In minutes)
Config.LengOfActiveTournament = 35 -- (Minutes) how much time the actual torunament happens for | Default is set to 35 minutes (# In minutes)
Config.TournamentTimeToSignUp = 15 -- (Minutes) How long do player have to sign up after a tournament becomes available aka how many seconds is Config.TournamentCooldowns | Default is set to 15 minutes
----------
----------
Config.MaxFisherMan = 100 -- Max players in a tournaments
Config.MinFisherMan = 1 -- Min players in the tournament for a torunament to start
----------
----------
Config.TournamentZoneBlip = 316 -- Tournament Zone Blip Sprite
Config.TournamentZoneBlipColor = 31 -- Tournament Zone Blip color
----------
----------
Config.FirstPlacePayout = 2000 -- this is the payout times the amount of people in the tournament
Config.SecondPlacePayout = 1500 -- this is the payout times the amount of people in the tournament
Config.ThirdPlacePayout = 1000 -- this is the payout times the amount of people in the tournament
----------
----------
-- Tournament zone locations
Config.TournamentZone = {
    ["CanyonRiverUnderBridge"] = {
        location = vector3(-1758.8, 4535.23, 6.72),
        radius = 100.0
    },
    ["CanyyonRiver"] = {
        location = vector3(-269.97, 4345.12, 37.33),
        radius = 100.0
    },
    ["GreatOceanDocks"] = {
        location = vector3(-3416.7, 967.79, 8.35),
        radius = 100.0
    },
    ["PaletoCoveDocks"] = {
        location = vector3(-1595.29, 5225.13, 3.98),
        radius = 100.0
    },
    ["SandyLake"] = {
        location = vector3(1788.1, 4221.97, 32.53),
        radius = 100.0
    },
}
