commands = {
    raid = {
        name = 'raid',
        help = 'Raid home door for police',
        perm = 'Police', -- Only for tag, doesnt affect the permission
        params = {}
    },
    deletehomedoor = {
        name = 'deletehomedoor',
        help = 'Delete a door for your home',
        perm = 'Admin / Realtor', -- Only for tag, doesnt affect the permission
        params = {}
    },
    createhome = {
        name = 'createhome',
        help = 'Create a new home',
        perm = 'Admin / Realtor', -- Only for tag, doesnt affect the permission
        params = {}
    },
    deletehome = {
        name = 'deletehome',
        help = 'Remove nearby home',
        perm = 'Admin / Realtor', -- Only for tag, doesnt affect the permission
        params = {}
    },
    deleteflat = {
        name = 'deleteflat',
        help = 'Remove a flat room',
        perm = 'Admin / Realtor', -- Only for tag, doesnt affect the permission
        params = {
            { name = "name", help = "apt room name" },
        }
    },
    deleteapartment = {
        name = 'deleteapartment',
        help = 'Remove an apartment',
        perm = 'Admin / Realtor', -- Only for tag, doesnt affect the permission
        params = {}
    },
    managehomes = {
        name = 'managehomes',
        help = 'Open your owned houses manager',
        perm = 'Public', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'option', help = '(OPTIONAL) Options: [rented]' }
        }
    },
    createsign = {
        name = 'createsign',
        help = 'Create a signboard for a property',
        perm = 'Admin / Realtor', -- Only for tag, doesnt affect the permission
        params = {}
    },
    realestatehomes = {
        name = 'realestatehomes',
        help = 'Open a list of all created real estate houses',
        perm = 'Realtor', -- Only for tag, doesnt affect the permission
        params = {}
    },
    starterapartment = {
        name = 'starterapartment',
        help = 'Manage Starter Apartment',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {}
    },
    adminhomes = {
        name = 'adminhomes',
        help = 'Open a list of all houses',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {}
    },
    setarea = {
        name = 'setarea',
        help = 'Set an area for Home IPL / Shell to enable furniture',
        perm = 'Admin / Realtor', -- Only for tag, doesnt affect the permission
        params = {}
    },
    furnish = {
        disabled = false,
        name = 'furnish',
        help = 'Furnish your home',
        perm = 'Public', -- Only for tag, doesnt affect the permission
        params = {}
    },
    editfurniture = {
        disabled = false,
        name = 'editfurniture',
        help = 'Edit existing furniture in your home',
        perm = 'Public', -- Only for tag, doesnt affect the permission
        params = {}
    },
    houseblip = {
        name = 'houseblip',
        help = 'Hide / show house blip',
        perm = 'Public', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'type', help = 'owned/sell/admin_owned/agent/agent_owned' }
        }
    },
    givehome = {
        name = 'givehome',
        help = 'Admin command for giving home',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'homeId', help = 'Home Identifier' },
            { name = 'target', help = 'Player Id' },
        }
    },
    revokehome = {
        name = 'revokehome',
        help = 'Admin command to revoke home',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'homeId', help = 'Home Identifier' },
            { name = 'target', help = '(OPTIONAL) Player Id' },
        }
    },
    extendhome = {
        name = 'extendhome',
        help = 'Admin command to extend a house expiry',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'homeId', help = 'Home Identifier' },
            { name = 'target', help = '(OPTIONAL) Player Id' },
        }
    },
    givefurniture = {
        name = 'givefurniture',
        help = 'Give a furniture to a target',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'target', help = 'Player Id' },
            { name = 'model',  help = 'Model Name' },
        }
    },
    startfurniturescreenshot = {
        name = 'startfurniturescreenshot',
        help = 'Cycle through furniture list to screenshot',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'option', help = 'control / auto (if control, enables cam & prop control)' }
        }
    },
    screenshotfurniture = {
        debug = true,
        name = 'screenshotfurniture',
        help = 'Screenshot individual furniture',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'model', help = 'Model Name' },
        }
    },
    screenshotinterior = {
        debug = true,
        name = 'screenshotinterior',
        help = 'Screenshot individual interior',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'type',     help = '[ipl/shell]' },
            { name = 'interior', help = 'Shell or IPL name' }
        }
    },
    renameflat = {
        name = 'renameflat',
        help = 'Rename a flat name',
        perm = 'Admin', -- Only for tag, doesnt affect the permission
        params = {}
    },
    redeemhome = {
        name = 'redeemhome',
        help = 'Redeem a home purchased via tebex',
        perm = 'Public', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'homeId',  help = 'Your 5 digit home id example 25131' },
            { name = 'tbxCode', help = 'the tebex code' }
        }
    },
    copyhome = {
        name = 'copyhome',
        help = 'Copy a house multiple times',
        perm = 'Admin / Realtor', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'homeId', help = 'Your 5 digit home id example 25131' },
        }
    },
    createzonepreset = {
        name = 'createzonepreset',
        help = 'Create a new zone preset',
        perm = 'Admin / Realtor', -- Only for tag, doesnt affect the permission
        params = {
            { name = 'name', help = 'Zone name preset' },
        }
    }
}
