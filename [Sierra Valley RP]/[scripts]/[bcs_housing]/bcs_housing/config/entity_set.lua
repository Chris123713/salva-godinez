Config = Config or {}

Config.EntitySet = {
    {
        coords = vec3(1676.1017, 3652.6152, 36.8470),
        LoadDefault = function()
            exports.bob74_ipl:SetIplPropState(GetInteriorFromEntity(cache.ped), {
                'bedroom1',
                'bedroom3',
                'bathroom2',
                'doorframe1',
                'windowframe1',
                'wallframe1'
            }, false, true)
            exports.bob74_ipl:SetIplPropState(GetInteriorFromEntity(cache.ped), {
                'bedroom2',
                'bathroom1',
                'doorframe2',
                'windowframe2',
                'wallframe2'
            }, true, true)
        end,
        list = {
            {
                name = 'Door Frames',
                values = { 'doorframe1', 'doorframe2' },
                price = 50,
            },
            {
                name = 'Window Frames',
                values = { 'windowframe1', 'windowframe2' },
                price = 60,
            },
            {
                name = 'Wall Frames',
                values = { 'wallframe1', 'wallframe2' },
                price = 150,
            },
            {
                name = 'Bedroom Set',
                values = { 'bedroom1', 'bedroom2', 'bedroom3' },
                price = 125,
            },
            {
                name = 'Bathroom Set',
                values = { 'bathroom1', 'bathroom2' },
                price = 80,
            }
        },
        lights = {
            { value = 'bathroomlight',   label = 'Bathroom' },
            { value = 'livingroomlight', label = 'Living Room' },
            { value = 'kitchenlight',    label = 'Kitchen' },
            { value = 'bedroomlight',    label = 'Bedroom' }
        }
    }
}
