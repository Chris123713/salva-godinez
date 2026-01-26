function debugprint(...)
    if not Config.Debug then
        return
    end

    local data = {...}
    local str = ""

    for i = 1, #data do
        if type(data[i]) == "table" then
            str = str .. json.encode(data[i])
        elseif type(data[i]) ~= "string" then
            str = str .. tostring(data[i])
        else
            str = str .. data[i]
        end

        if i ~= #data then
            str = str .. " "
        end
    end

    print("^6[LB Radio] ^3[Debug]^7: " .. str, "^7")
end

local infoLevels = {
    success = "^2[SUCCESS]",
	info = "^5[INFO]",
	warning = "^3[WARNING]",
	error = "^1[ERROR]"
}

---@param level "success" | "info" | "warning" | "error"
---@param text string
function infoprint(level, text, ...)
	local prefix = infoLevels[level]

	if not prefix then
		prefix = "^5[INFO]^7:"
	end

	print("^6[LB Radio] " .. prefix .. "^7: " .. text, ...)
end

local locales = {}

local function FormatLocales(localeTable, prefix)
    for k, v in pairs(localeTable) do
        if type(v) == "table" then
            FormatLocales(v, prefix .. k .. ".")
        else
            locales[prefix .. k] = v
        end
    end
end

FormatLocales(Locales or {}, "")

function L(path, args)
    assert(type(path) == "string", "path must be a string")

    local translation = locales[path] or path

    if args then
        for k, v in pairs(args) do
            local safe_v = tostring(v):gsub("%%", "%%%%")  -- Escape % characters
            translation = translation:gsub("{" .. k .. "}", safe_v)
        end
    end

    return translation
end

---@return table<string, string>
function GetAllLocales()
    return locales
end

local intervals = {}

---@param cb function
---@param interval? integer
function SetInterval(cb, interval)
    local id
    interval = interval or 0

    Citizen.CreateThreadNow(function(ref)
        id = ref
        intervals[id] = true

        while intervals[id] do
            cb()
            Wait(interval)
        end

        intervals[id] = nil
    end)

    return id
end

function ClearInterval(id)
    if intervals[id] then
        intervals[id] = nil
    end
end

if Config.Framework == "auto" then
    debugprint("Framework set to auto, detecting...")

    if GetResourceState("es_extended") ~= "missing" then
        Config.Framework = "esx"
    elseif GetResourceState("qb-core") ~= "missing" then
        Config.Framework = "qb"
    else
        Config.Framework = "standalone"
    end

    debugprint("Detected framework: " .. Config.Framework)
end
