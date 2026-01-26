local HomeStructure = {
    ['mortgages'] = 'm',
    ['name'] = 'n',
    ['identifier'] = 'i',
    ['doors'] = 'do',
    ['price'] = 'p',
    ['entry'] = 'e',
    ['locked'] = 'l',
    ['players'] = 'pl',
    ['owner'] = 'o',
    ['type'] = 't',
    ['lastPayment'] = 'lp',
    ['wardrobes'] = 'wa',
    ['bought_at'] = 'ba',
    ['complex'] = 'c',
    ['furniture'] = 'f',
    ['data'] = 'd',
    ['area'] = 'a',
    ['payment'] = 'pa',
    ['permission'] = 'pe',
    ['created_at'] = 'ca',
    ['keys'] = 'k',
    ['configuration'] = 'co',
    ['storages'] = 's',
    ['apartments'] = 'ap',
    ['realestate'] = 'r',
    ['lastLogin'] = 'll',
    ['interior'] = 'in',
    ['moveGarage'] = 'mg',
    ['interest'] = 'ir',
    ['downpayment'] = 'dp',
    ['placement'] = 'pm',
    ['duration'] = 'du',
    ['rentable'] = 'rn',
    ['disableBuy'] = 'db',
    ['disabled'] = 'dd',
    ['model'] = 'mo',
    ['transfer'] = 'tr',
    ['key'] = 'ke',
    ['holders'] = 'hl',
    ['house'] = 'ho',
    ['list'] = 'li',
    ['coords'] = 'cr',
    ['rotation'] = 'ro',
    ['cctv'] = 'cc',
    ['result'] = 're',
    ['doorlock'] = 'dl',
    ['garage'] = 'g',
    ['heading'] = 'h',
    ['rename'] = 'rm',
    ['sell'] = 'se',
    ['storage'] = 'st',
    ['garages'] = 'gs',
    -- Furniture List
    ['isometric'] = 'is',
    ['label'] = 'la',
    ['category'] = 'cg',
    ['teleports'] = 'ts',
    ['thumbnail'] = 'tl'
}

local ReverseHomeStructure = {
    ['o'] = 'owner',
    ['l'] = 'locked',
    ['i'] = 'identifier',
    ['ca'] = 'created_at',
    ['f'] = 'furniture',
    ['co'] = 'configuration',
    ['e'] = 'entry',
    ['wa'] = 'wardrobes',
    ['do'] = 'doors',
    ['a'] = 'area',
    ['s'] = 'storages',
    ['t'] = 'type',
    ['k'] = 'keys',
    ['m'] = 'mortgages',
    ['p'] = 'price',
    ['pe'] = 'permission',
    ['lp'] = 'lastPayment',
    ['d'] = 'data',
    ['ba'] = 'bought_at',
    ['pl'] = 'players',
    ['pa'] = 'payment',
    ['c'] = 'complex',
    ['n'] = 'name',
    ['ap'] = 'apartments',
    ['r'] = 'realestate',
    ['ll'] = 'lastLogin',
    ['in'] = 'interior',
    ['pm'] = 'placement',
    ['dp'] = 'downpayment',
    ['g'] = 'garage',
    ['du'] = 'duration',
    ['ir'] = 'interest',
    ['re'] = 'result',
    ['rn'] = 'rentable',
    ['rm'] = 'rename',
    ['cc'] = 'cctv',
    ['db'] = 'disableBuy',
    ['dd'] = 'disabled',
    ['dl'] = 'doorlock',
    ['mg'] = 'moveGarage',
    ['tr'] = 'transfer',
    ['se'] = 'sell',
    ['mo'] = 'model',
    ['h'] = 'heading',
    ['ro'] = 'rotation',
    ['cr'] = 'coords',
    ['li'] = 'list',
    ['ho'] = 'house',
    ['hl'] = 'holders',
    ['ke'] = 'key',
    ['st'] = 'storage',
    ['gs'] = 'garages',
    -- Furniture List
    ['is'] = 'isometric',
    ['la'] = 'label',
    ['cg'] = 'category',
    ['ts'] = 'teleports',
    ['tl'] = 'thumbnail'
}

function Minify(home)
    local minified = {}
    for k, v in pairs(home) do
        if not HomeStructure[k] then
            if type(v) == 'table' then
                minified[k] = Minify(v)
            else
                minified[k] = v
            end
        else
            if type(v) == 'table' then
                minified[HomeStructure[k]] = Minify(v)
            else
                minified[HomeStructure[k]] = v
            end
        end
    end
    return minified
end

function Unminify(home)
    local unminified = {}
    for k, v in pairs(home) do
        if not ReverseHomeStructure[k] then
            if type(v) == 'table' then
                unminified[k] = Unminify(v)
            else
                unminified[k] = v
            end
        else
            if type(v) == 'table' then
                unminified[ReverseHomeStructure[k]] = Unminify(v)
            else
                unminified[ReverseHomeStructure[k]] = v
            end
        end
    end
    return unminified
end
