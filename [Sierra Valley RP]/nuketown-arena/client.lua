-- This is all just for creating invisible walls and a very few visible walls
local function LoadModel(model)
    if HasModelLoaded(model) then return end
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end
end
local InvisibleWallsToPlace = {}
local InvisibleWalls = {
    {
        PedCoords = {x = -3263.259521484375, y = 7029.10791015625, z = 636.6229858398438},
        Feature = "props",
        Target = {x = -3263.259521484375, y = 7029.10791015625, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        Heading = 345.0,
    },
    {
        PedCoords = {x = -3270.30224609375, y = 7019.13720703125, z = 636.623291015625},
        Feature = "props",
        Target = {x = -3270.30224609375, y = 7019.13720703125, z = 636.623291015625},
        UsedProp = "prop_const_fence01a",
        Heading = 75.0,
    },
    {
        PedCoords = {x = -3271.36279296875, y = 7015.69873046875, z = 636.581298828125},
        Feature = "props",
        Target = {x = -3271.36279296875, y = 7015.69873046875, z = 636.581298828125},
        UsedProp = "prop_const_fence01a",
        Heading = 75.0,
    },
    {
        PedCoords = {x = -3272.3984375, y = 7011.884765625, z = 636.581298828125},
        Feature = "props",
        Target = {x = -3272.3984375, y = 7011.884765625, z = 636.581298828125},
        UsedProp = "prop_const_fence01a",
        Heading = 75.0,
    },
    {
        PedCoords = {x = -3272.93798828125, y = 7009.92431640625, z = 636.623291015625},
        Feature = "props",
        Target = {x = -3272.93798828125, y = 7009.92431640625, z = 636.623291015625},
        UsedProp = "prop_const_fence01a",
        Heading = 75.0,
    },
    {
        PedCoords = {x = -3272.878173828125, y = 7009.876953125, z = 639.6171875},
        Feature = "props",
        Target = {x = -3272.878173828125, y = 7009.876953125, z = 639.6171875},
        UsedProp = "prop_const_fence01a",
        Heading = 75.0,
    },
    {
        PedCoords = {x = -3271.828369140625, y = 7013.74169921875, z = 639.6301879882813},
        Feature = "props",
        Target = {x = -3271.828369140625, y = 7013.74169921875, z = 639.6301879882813},
        UsedProp = "prop_const_fence01a",
        Heading = 75.0,
    },
    {
        PedCoords = {x = -3270.636474609375, y = 7017.619140625, z = 639.53857421875},
        Feature = "props",
        Target = {x = -3270.636474609375, y = 7017.619140625, z = 639.53857421875},
        UsedProp = "prop_const_fence01a",
        Heading = 75.0,
    },
    {
        PedCoords = {x = -3270.13134765625, y = 7019.5048828125, z = 639.5545043945313},
        Feature = "props",
        Target = {x = -3270.13134765625, y = 7019.5048828125, z = 639.5545043945313},
        UsedProp = "prop_const_fence01a",
        Heading = 75.0,
    },
    {
        PedCoords = {x = -3268.938232421875, y = 7021.3193359375, z = 637.3821411132813},
        Feature = "props",
        Target = {x = -3268.938232421875, y = 7021.3193359375, z = 637.3821411132813},
        UsedProp = "prop_const_fence01a",
        Heading = 15.0,
    },
    {
        PedCoords = {x = -3265.56005859375, y = 7021.3115234375, z = 637.3821411132813},
        Feature = "props",
        Target = {x = -3265.56005859375, y = 7021.3115234375, z = 637.3821411132813},
        UsedProp = "prop_const_fence01a",
        Heading = 345.0,
    },
    {
        PedCoords = {x = -3263.37841796875, y = 7020.724609375, z = 637.3821411132813},
        Feature = "props",
        Target = {x = -3263.37841796875, y = 7020.724609375, z = 637.3821411132813},
        UsedProp = "prop_const_fence01a",
        Heading = 345.0,
    },
    {
        PedCoords = {x = -3261.167236328125, y = 7022.2392578125, z = 637.3821411132813},
        Feature = "props",
        Target = {x = -3261.167236328125, y = 7022.2392578125, z = 637.3821411132813},
        UsedProp = "prop_const_fence01a",
        Heading = 80.0,
    },
    {
        PedCoords = {x = -3260.604736328125, y = 7026.13916015625, z = 637.3821411132813},
        Feature = "props",
        Target = {x = -3260.604736328125, y = 7026.13916015625, z = 637.3821411132813},
        UsedProp = "prop_const_fence01a",
        Heading = 80.0,
    },
    {
        PedCoords = {x = -3260.06298828125, y = 7029.12890625, z = 637.3821411132813},
        Feature = "props",
        Target = {x = -3260.06298828125, y = 7029.12890625, z = 637.3821411132813},
        UsedProp = "prop_const_fence01a",
        Heading = 80.0,
    },
    {
        PedCoords = {x = -3258.4853515625, y = 7031.39013671875, z = 636.6427612304688},
        Feature = "props",
        Target = {x = -3258.4853515625, y = 7031.39013671875, z = 636.6427612304688},
        UsedProp = "prop_const_fence01a",
        Heading = 80.0,
    },
    {
        PedCoords = {x = -3259.0712890625, y = 7032.00732421875, z = 636.6229858398438},
        Feature = "props",
        Target = {x = -3259.0712890625, y = 7032.00732421875, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        Heading = 60.0,
    },
    {
        PedCoords = {x = -3271.550537109375, y = 7007.32763671875, z = 637.3821411132813},
        Feature = "props",
        Target = {x = -3271.550537109375, y = 7007.32763671875, z = 637.3821411132813},
        UsedProp = "prop_const_fence01a",
        Heading = 165.0,
    },
    {
        PedCoords = {x = -3270.896484375, y = 7007.12744140625, z = 637.3821411132813},
        Feature = "props",
        Target = {x = -3270.896484375, y = 7007.12744140625, z = 637.3821411132813},
        UsedProp = "prop_const_fence01a",
        Heading = 165.0,
    },
    {
        PedCoords = {x = -3268.89013671875, y = 7005.1875, z = 636.6229858398438},
        Feature = "props",
        Target = {x = -3268.89013671875, y = 7005.1875, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        Heading = 85.0,
    },
    {
        PedCoords = {x = -3269.245361328125, y = 7001.21533203125, z = 636.6229858398438},
        Feature = "props",
        Target = {x = -3269.245361328125, y = 7001.21533203125, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        Heading = 85.0,
    },
    {
        PedCoords = {x = -3269.80029296875, y = 6998.1142578125, z = 636.6229858398438},
        Feature = "props",
        Target = {x = -3269.80029296875, y = 6998.1142578125, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        Heading = 85.0,
    },
    {
        PedCoords = {x = -3269.742431640625, y = 6997.9697265625, z = 639.6156005859375},
        Feature = "props",
        Target = {x = -3269.742431640625, y = 6997.9697265625, z = 639.6156005859375},
        UsedProp = "prop_const_fence01a",
        Heading = 85.0,
    },
    {
        PedCoords = {x = -3269.38134765625, y = 6994.7880859375, z = 637.5648803710938},
        Feature = "props",
        Target = {x = -3269.38134765625, y = 6994.7880859375, z = 637.5648803710938},
        UsedProp = "prop_const_fence01a",
        Heading = 90.0,
    },
    {
        PedCoords = {x = -3223.346435546875, y = 7034.88671875, z = 636.6229858398438},
        Feature = "props",
        Target = {x = -3223.346435546875, y = 7034.88671875, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        Heading = 240.0,
    },
    {
        PedCoords = {x = -3220.678466796875, y = 7035.5771484375, z = 636.6229858398438},
        Feature = "props",
        Target = {x = -3220.678466796875, y = 7035.5771484375, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        Heading = 150.0,
    },
    {
        PedCoords = {x = -3222.62451171875, y = 7032.2158203125, z = 636.6229858398438},
        Feature = "props",
        Target = {x = -3222.62451171875, y = 7032.2158203125, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        Heading = 330.0,
    },
    {
        PedCoords = {x = -3261.035888671875, y = 7007.35546875, z = 638.882568359375},
        Feature = "props",
        Target = {x = -3261.035888671875, y = 7007.35546875, z = 638.882568359375},
        UsedProp = "prop_const_fence01a",
        Heading = 255.0,
    },
    {
        Feature = "props",
        Target = {y = 7051.60595703125, x = -3239.789306640625, z = 636.6229858398438},
        PedCoords = {y = 7051.60595703125, x = -3239.789306640625, z = 636.6229858398438},
        Heading = 330.0,
        UsedProp = "prop_const_fence01a",
        VisibleWall = true,
        Business = "criminal"
    },
    {
        Feature = "props",
        Heading = 330.0,
        PedCoords = {y = 7051.220703125, x = -3239.120361328125, z = 636.6229858398438},
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        VisibleWall = true,
        Target = {y = 7051.220703125, x = -3239.120361328125, z = 636.6229858398438}
    },
    {
        Feature = "props",
        Business = "criminal",
        PedCoords = {y = 7052.08984375, x = -3231.632568359375, z = 636.6229858398438},
        Target = {y = 7052.08984375, x = -3231.632568359375, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        VisibleWall = true,
        Heading = 330.0
    },
    {
        Feature = "props",
        Business = "criminal",
        PedCoords = {y = 7046.65087890625, x = -3228.9990234375, z = 636.6229858398438},
        Target = {y = 7046.65087890625, x = -3228.9990234375, z = 636.6229858398438},
        UsedProp = "prop_const_fence01a",
        VisibleWall = true,
        Heading = 325.0
    },
    {
        Feature = "props",
        Target = {y = 7014.13720703125, x = -3231.2314453125, z = 636.6229858398438},
        PedCoords = {y = 7014.13720703125, x = -3231.2314453125, z = 636.6229858398438},
        Heading = 280.0,
        UsedProp = "prop_const_fence01a",
        VisibleWall = true,
        Business = "criminal"
    },
    {
        Feature = "props",
        Heading = 235.0,
        PedCoords = {y = 6991.7578125, x = -3236.30810546875, z = 636.6229858398438},
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        VisibleWall = true,
        Target = {y = 6991.7578125, x = -3236.30810546875, z = 636.6229858398438}
    },
    {
        Feature = "props",
        Business = "criminal",
        PedCoords = {y = 6997.85888671875, x = -3263.24609375, z = 636.6229858398438},
        Target = {y = 6997.85888671875, x = -3263.24609375, z = 636.6229858398438},
        UsedProp = "imp_prop_impexp_boxwood_01",
        VisibleWall = true,
        Heading = 90.0
    },
    {
        PedCoords = {x = -3248.639404296875, y = 7021.25830078125, z = 636.6229858398438},
        Feature = "props",
        Target = {x = -3248.639404296875, y = 7021.25830078125, z = 636.6229858398438},
        Heading = 55.0,
        UsedProp = "imp_prop_impexp_boxwood_01",
        VisibleWall = true,
        Business = "criminal"
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 185.0,
        Target = {y = 7015.86083984375, x = -3257.66845703125, z = 639.267578125},
        Feature = "props",
        PedCoords = {y = 7015.86083984375, x = -3257.66845703125, z = 639.267578125}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 265.0,
        Target = {y = 7014.1484375, x = -3259.708740234375, z = 639.3917846679688},
        Feature = "props",
        PedCoords = {y = 7014.1484375, x = -3259.708740234375, z = 639.3917846679688}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 10.0,
        Target = {y = 7013.27197265625, x = -3257.88232421875, z = 639.2821044921875},
        Feature = "props",
        PedCoords = {y = 7013.27197265625, x = -3257.88232421875, z = 639.2821044921875}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 5.0,
        Target = {y = 7013.56884765625, x = -3254.194091796875, z = 639.3165283203125},
        Feature = "props",
        PedCoords = {y = 7013.56884765625, x = -3254.194091796875, z = 639.3165283203125}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 5.0,
        Target = {y = 7013.857421875, x = -3250.374755859375, z = 639.321533203125},
        Feature = "props",
        PedCoords = {y = 7013.857421875, x = -3250.374755859375, z = 639.321533203125}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 90.0,
        Target = {y = 7014.8955078125, x = -3248.802490234375, z = 639.2413330078125},
        Feature = "props",
        PedCoords = {y = 7014.8955078125, x = -3248.802490234375, z = 639.2413330078125}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 185.0,
        Target = {y = 7016.23388671875, x = -3250.505126953125, z = 639.2767333984375},
        Feature = "props",
        PedCoords = {y = 7016.23388671875, x = -3250.505126953125, z = 639.2767333984375}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 185.0,
        Target = {y = 7016.0478515625, x = -3253.896484375, z = 639.34619140625},
        Feature = "props",
        PedCoords = {y = 7016.0478515625, x = -3253.896484375, z = 639.34619140625}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 170.0,
        Target = {y = 7007.84521484375, x = -3258.919677734375, z = 639.35400390625},
        Feature = "props",
        PedCoords = {y = 7007.84521484375, x = -3258.919677734375, z = 639.35400390625}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 345.0,
        Target = {y = 7006.0390625, x = -3259.8115234375, z = 639.3318481445313},
        Feature = "props",
        PedCoords = {y = 7006.0390625, x = -3259.8115234375, z = 639.3318481445313}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 240.0,
        Target = {y = 7034.58935546875, x = -3250.36083984375, z = 639.3131713867188},
        Feature = "props",
        PedCoords = {y = 7034.58935546875, x = -3250.36083984375, z = 639.3131713867188}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 325.0,
        Target = {y = 7027.62255859375, x = -3247.779052734375, z = 640.0025024414063},
        Feature = "props",
        PedCoords = {y = 7027.62255859375, x = -3247.779052734375, z = 640.0025024414063}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 325.0,
        Target = {y = 7029.4248046875, x = -3251.33642578125, z = 640.0438842773438},
        Feature = "props",
        PedCoords = {y = 7029.4248046875, x = -3251.33642578125, z = 640.0438842773438}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 240.0,
        Target = {y = 7031.46435546875, x = -3251.773193359375, z = 640.61962890625},
        Feature = "props",
        PedCoords = {y = 7031.46435546875, x = -3251.773193359375, z = 640.61962890625}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 240.0,
        Target = {y = 7033.54443359375, x = -3249.992431640625, z = 640.58935546875},
        Feature = "props",
        PedCoords = {y = 7033.54443359375, x = -3249.992431640625, z = 640.58935546875}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 145.0,
        Target = {y = 7034.9248046875, x = -3247.872802734375, z = 639.33349609375},
        Feature = "props",
        PedCoords = {y = 7034.9248046875, x = -3247.872802734375, z = 639.33349609375}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 150.0,
        Target = {y = 7033.634765625, x = -3245.1953125, z = 640.1193237304688},
        Feature = "props",
        PedCoords = {y = 7033.634765625, x = -3245.1953125, z = 640.1193237304688}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 150.0,
        Target = {y = 7032.9716796875, x = -3244.17431640625, z = 640.147705078125},
        Feature = "props",
        PedCoords = {y = 7032.9716796875, x = -3244.17431640625, z = 640.147705078125}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 150.0,
        Target = {y = 7033.10302734375, x = -3244.134521484375, z = 641.373291015625},
        Feature = "props",
        PedCoords = {y = 7033.10302734375, x = -3244.134521484375, z = 641.373291015625}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 80.0,
        Target = {y = 7031.36279296875, x = -3258.419189453125, z = 639.6967163085938},
        Feature = "props",
        PedCoords = {y = 7031.36279296875, x = -3258.419189453125, z = 639.6967163085938}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 35.0,
        Target = {y = 7029.7001953125, x = -3259.891357421875, z = 640.1965942382813},
        Feature = "props",
        PedCoords = {y = 7029.7001953125, x = -3259.891357421875, z = 640.1965942382813}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 80.0,
        Target = {y = 7027.77685546875, x = -3260.23046875, z = 640.0614013671875},
        Feature = "props",
        PedCoords = {y = 7027.77685546875, x = -3260.23046875, z = 640.0614013671875}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 80.0,
        Target = {y = 7030.90283203125, x = -3259.62841796875, z = 639.6527709960938},
        Feature = "props",
        PedCoords = {y = 7030.90283203125, x = -3259.62841796875, z = 639.6527709960938}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 80.0,
        Target = {y = 7023.83935546875, x = -3260.814208984375, z = 640.1581420898438},
        Feature = "props",
        PedCoords = {y = 7023.83935546875, x = -3260.814208984375, z = 640.1581420898438}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 80.0,
        Target = {y = 7021.85009765625, x = -3261.1650390625, z = 640.3676147460938},
        Feature = "props",
        PedCoords = {y = 7021.85009765625, x = -3261.1650390625, z = 640.3676147460938}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 345.0,
        Target = {y = 7020.64208984375, x = -3263.339599609375, z = 640.4351196289063},
        Feature = "props",
        PedCoords = {y = 7020.64208984375, x = -3263.339599609375, z = 640.4351196289063}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 345.0,
        Target = {y = 7021.62890625, x = -3267.013671875, z = 640.3781127929688},
        Feature = "props",
        PedCoords = {y = 7021.62890625, x = -3267.013671875, z = 640.3781127929688}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 15.0,
        Target = {y = 7021.34130859375, x = -3268.5859375, z = 640.370849609375},
        Feature = "props",
        PedCoords = {y = 7021.34130859375, x = -3268.5859375, z = 640.370849609375}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 160.0,
        Target = {y = 7007.34716796875, x = -3271.3544921875, z = 640.192626953125},
        Feature = "props",
        PedCoords = {y = 7007.34716796875, x = -3271.3544921875, z = 640.192626953125}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 85.0,
        Target = {y = 7005.1875, x = -3268.81982421875, z = 639.6029663085938},
        Feature = "props",
        PedCoords = {y = 7005.1875, x = -3268.81982421875, z = 639.6029663085938}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 165.0,
        Target = {y = 7007.0703125, x = -3270.320556640625, z = 639.551513671875},
        Feature = "props",
        PedCoords = {y = 7007.0703125, x = -3270.320556640625, z = 639.551513671875}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 85.0,
        Target = {y = 7001.62451171875, x = -3269.13916015625, z = 639.1168823242188},
        Feature = "props",
        PedCoords = {y = 7001.62451171875, x = -3269.13916015625, z = 639.1168823242188}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 95.0,
        Target = {y = 6994.81591796875, x = -3269.3115234375, z = 639.8779296875},
        Feature = "props",
        PedCoords = {y = 6994.81591796875, x = -3269.3115234375, z = 639.8779296875}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 90.0,
        Target = {y = 6994.24755859375, x = -3243.60107421875, z = 639.4462280273438},
        Feature = "props",
        PedCoords = {y = 6994.24755859375, x = -3243.60107421875, z = 639.4462280273438}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 180.0,
        Target = {y = 6995.9267578125, x = -3245.554443359375, z = 639.8182373046875},
        Feature = "props",
        PedCoords = {y = 6995.9267578125, x = -3245.554443359375, z = 639.8182373046875}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 90.0,
        Target = {y = 6990.7236328125, x = -3243.693359375, z = 639.5647583007813},
        Feature = "props",
        PedCoords = {y = 6990.7236328125, x = -3243.693359375, z = 639.5647583007813}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 90.0,
        Target = {y = 6986.83349609375, x = -3243.79541015625, z = 639.56591796875},
        Feature = "props",
        PedCoords = {y = 6986.83349609375, x = -3243.79541015625, z = 639.56591796875}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 90.0,
        Target = {y = 6983.37451171875, x = -3243.885986328125, z = 639.554931640625},
        Feature = "props",
        PedCoords = {y = 6983.37451171875, x = -3243.885986328125, z = 639.554931640625}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 5.0,
        Target = {y = 6981.56494140625, x = -3245.78857421875, z = 639.9360961914063},
        Feature = "props",
        PedCoords = {y = 6981.56494140625, x = -3245.78857421875, z = 639.9360961914063}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 5.0,
        Target = {y = 6981.7236328125, x = -3251.85302734375, z = 641.5650024414063},
        Feature = "props",
        PedCoords = {y = 6981.7236328125, x = -3251.85302734375, z = 641.5650024414063}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 355.0,
        Target = {y = 6973.98974609375, x = -3240.25146484375, z = 639.7269287109375},
        Feature = "props",
        PedCoords = {y = 6973.98974609375, x = -3240.25146484375, z = 639.7269287109375}
    },
    {
        Business = "criminal",
        UsedProp = "prop_const_fence01a",
        Heading = 185.0,
        Target = {x = -3238.94189453125-3238.94189453125, y = 6977.36962890625, z = 639.6742553710938},
        Feature = "props",
        PedCoords = {x = -3238.94189453125, y = 6977.36962890625, z = 639.6742553710938}
    },
}
CreateThread(function()
    for _, i in pairs(InvisibleWalls) do
        local Info = i
        ClosestObject = GetClosestObjectOfType(vector3(Info.Target.x,Info.Target.y,Info.Target.z), 5.0, GetHashKey(Info.UsedProp))
        if DoesEntityExist(ClosestObject) then
            TriggerEvent("FullyDeleteEntitysNuketown", ClosestObject)
        end
        InvisibleWallsToPlace[#InvisibleWallsToPlace+1] = {
            Prop = Info.UsedProp,
            Coords = Info.Target, 
            Heading = Info.Heading,
            Spawned = nil,
            Visible = Info.VisibleWall
        }
    end
    for k, v in pairs(InvisibleWallsToPlace) do
        InvisibleWallsToPlace[k].Spawned = CreateObject(GetHashKey(v.Prop), vector3(v.Coords.x,v.Coords.y,v.Coords.z))
        while not DoesEntityExist(InvisibleWallsToPlace[k].Spawned) do Wait(100) end
        SetEntityHeading(InvisibleWallsToPlace[k].Spawned, v.Heading)
        FreezeEntityPosition(InvisibleWallsToPlace[k].Spawned, true)
        if InvisibleWallsToPlace[k].Visible then
        else
            SetEntityVisible(InvisibleWallsToPlace[k].Spawned, false)
        end
    end
end)

RegisterNetEvent("FullyDeleteEntitysNuketown", function(vehicle)
    local entity = vehicle
    NetworkRequestControlOfEntity(entity)
    local timeout = 2000
    while timeout > 0 and not NetworkHasControlOfEntity(entity) do
        Wait(100)
        timeout = timeout - 100
    end
    SetEntityAsMissionEntity(entity, true, true)
    local timeout = 2000
    while timeout > 0 and not IsEntityAMissionEntity(entity) do
        Wait(100)
        timeout = timeout - 100
    end
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
    if ( DoesEntityExist( entity ) ) then 
        DeleteEntity(entity)
        if ( DoesEntityExist( entity ) ) then     
            return false
        else 
            return true
        end
    else 
        return true
    end 
end)

