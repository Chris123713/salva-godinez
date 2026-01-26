Config = Config or {}
Config.Regions = { -- List of regions for UI and weather handlers
    {value = "santos", label = "Los Santos"},
    {value = "paleto", label = "Paleto"},
    {value = "sandy", label = "Sandy"},
    {value = "roxwood", label = "Roxwood"},
    {value = "chiliad", label = "Chiliad Mountain"},
    {value = "cayo", label = "Cayo Perico"},
}

-- All unlisted zones are automatically assigned to the Los Santos region
-- List of zone names: https://docs.fivem.net/docs/game-references/zones/
ZoneNames = {
    ["PALCOV"] = "paleto",
    ["PALETO"] = "paleto",
    ["PALFOR"] = "paleto",
    ["PROCOB"] = "paleto",
    ["BRADP"] = "paleto",
    ["BRADT"] = "paleto",
    ["ELGORL"] = "paleto",
    ["MTGORDO"] = "paleto",
    ["CMSW"] = "paleto",

    ["GRAPES"] = "sandy",
    ["GALFISH"] = "sandy",
    ["CALAFB"] = "sandy",
    ["ALAMO"] = "sandy",
    ["SLAB"] = "sandy",
    ["SANDY"] = "sandy",
    ["SANCHIA"] = "sandy",
    ["HUMLAB"] = "sandy",
    ["ZQ_UAR"] = "sandy",
    ["DESRT"] = "sandy",
    ["RTRAK"] = "sandy",
    ["HARMO"] = "sandy",
    ["JAIL"] = "sandy",
    ["WINDF"] = "sandy",
    ["PALMPOW"] = "sandy",

    ["ISHEIST"] = "cayo",

    -- ROXWOOD
    ["ROXAHOU"] = "roxwood",
    ["ROXLAGC"] = "roxwood",
    ["ROXJUNI"] = "roxwood",
    ["ROXCONT"] = "roxwood",
    ["ROXAIRP"] = "roxwood",
    ["RXFRMWN"] = "roxwood",
    ["ROXPARK"] = "roxwood",
    ["ROXMARB"] = "roxwood",
    ["ROXDOCK"] = "roxwood",
    ["ROXROCP"] = "roxwood",
    ["ROXWATP"] = "roxwood",
    ["ROXPWRA"] = "roxwood",
    ["ROXCFAR"] = "roxwood",
    ["ROXLOMB"] = "roxwood",

    -- Mount Chiliad
    ["MTCHIL"] = "chiliad",
}