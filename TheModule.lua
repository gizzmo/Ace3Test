local ADDON_NAME, Addon = ...

---------------------------------------------------------------- Setup Module --
local MODULE_NAME = 'TheModule'
local Module = Addon:NewModule(MODULE_NAME)
local L = Addon.L

-------------------------------------------------------------------- Database --
local defaultDB = {
    profile = {

    },
    global = {

    }
}

Module.db = Addon.db:RegisterNamespace(MODULE_NAME, defaultDB)

function Module:OnProfileRefresh()
    self:Print("OnProfileRefresh Triggered")
end

Module.db.RegisterCallback(Module, "OnProfileChanged", "OnProfileRefresh")
Module.db.RegisterCallback(Module, "OnProfileCopied", "OnProfileRefresh")
Module.db.RegisterCallback(Module, "OnProfileReset", "OnProfileRefresh")

--------------------------------------------------------------------- Options --
Module.options = {
    type = 'group',
    name = L['The Module'],
    args = {
        intro1 = {
            order = 1,
            type = 'description',
            name = L['Demo options'],
            fontSize = 'large',
        },
        intro2 = {
            order = 2,
            type = 'description',
            name = L['This module is just a space to test out how options are built. '
                ..'Each and every possible type of input type. Each type is '
                ..'grouped together.']
        },
    }
}

-- Register the modules with the Addon
Addon.options.args[MODULE_NAME] = Module.options

-- Table to store our options, most times it will just be the database
local values = {}
Module.options.get = function(info)
    return values[info[#info]]
end
Module.options.set = function(info, value)
    values[info[#info]] = value
end

-- The options table is split here to show that you dont need to build it all at once.
Module.options.args.executes = {
    type = 'group', inline = true,
    name = L['Execute types'],
    args = {
        execute = {
            type = 'execute',
            name = L['Execute'],
            func = function() Module:Print('Execute type pressed!')end,
        }
    }
}
Module.options.args.inputs = {
    type = 'group', inline = true,
    name = L['Inputs types'],
    args = {
        input = {
            type = 'input',
            name = L['Input'],
        },
        input_multiline = {
            type = 'input',
            name = L['Input Multi-line'],
            multiline = true,
        },

    }
}
Module.options.args.toggles = {
    type = 'group', inline = true,
    name = L['Toggle types'],
    args = {
        toggle = {
            type = 'toggle',
            name = L['Toggle'],
        },
        toggle_tristate = {
            type = 'toggle',
            name = L['Toggle Tristate'],
            tristate = true,
        }
    }
}
Module.options.args.ranges = {
    type = 'group', inline = true,
    name = L['Range types'],
    args = {
        range = {
            type = 'range',
            name = L['Range'],
            min = 1, max = 100,
        },
        range_percent = {
            type = 'range',
            name = L['Range Percent'],
            isPercent = true,
            min = -1, max = 1,
        },
        range_bigstep = {
            type = 'range',
            name = L['Range Bigstep'],
            min = 0, max = 100, bigStep = 10,
        },
    }
}

local function getSelectValues()
    return {'First value','Second value','Third value','Fourth value','Fifth value','Sixth value'}
end
Module.options.args.selects = {
    type = 'group', inline = true,
    name = L['Select types'],
    args = {
        select = {
            type = 'select',
            name = L['Select'],
            values = getSelectValues,
        },
        radioselect = {
            type = 'select',
            name = L['Radio Select'],
            style = 'radio',
            values = getSelectValues,
        },
    }
}
Module.options.args.multiselects = {
    type = 'group', inline = true,
    name = L["Multi Selects types"],
    -- Multiselect requires a extra table to store the state of each value
    get = function(info, key)
        values[info[#info]] = values[info[#info]] or {}
        return values[info[#info]][key]
        -- body...
    end,
    set = function(info, key, value)
        values[info[#info]] = values[info[#info]] or {}
        values[info[#info]][key] = value
        -- body...
    end,
    args = {
        multiselect = {
            type = 'multiselect',
            name = L["Multi Select"],
            values = getSelectValues,
        },
        multiselecttristate = {
            type = 'multiselect',
            name = L["Multi Select Tristate"],
            tristate = true,
            values = getSelectValues,
        }
    }
}
Module.options.args.colors = {
    type = 'group', inline = true,
    name = L["Colors"],
    -- Colors deal with multiple values. r,g,b,a
    get = function(info) return unpack(values[info[#info]] or {}) end,
    set = function(info, ...) values[info[#info]] = {...} end,
    args = {
        color = {
            type = 'color',
            name = L["Color"],
        },
        coloralpha = {
            type = 'color',
            name = L["Color with Alpha"],
            hasAlpha = true,
        },
    }
}

---------------------------------------------------------------- Core Methods --
function Module:OnInitialize()
    self:Print('OnInitialize Trigered')
end

function Module:OnEnable()
    self:Print('OnEnabled Trigered')
end

function Module:OnDisable()
    self:Print('OnDisable Trigered')
end

function Module:OnProfileRefresh()
    self:Print('OnProfileRefresh Trigered')
end

------------------------------------------------------------------------- Fin --