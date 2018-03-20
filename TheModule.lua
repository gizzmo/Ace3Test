local ADDON_NAME, Addon = ...

---------------------------------------------------------------- Setup Module --
local MODULE_NAME = 'TheModule'
local Module = Addon:NewModule(MODULE_NAME)
local L = Addon.L

-------------------------------------------------------------------- Database --
local defaultDB = {
    profile = {

    },
}

--------------------------------------------------------------------- Options --
-- Makes the order they are created the order they are displayed
local new_order
do
    local current = 0
    function new_order()
        current = current + 1
        return current
    end
end

Module.options = {
    type = 'group',
    name = L['The Module'],

    get = function(info) return Module.db.profile[info[#info]] end,
    set = function(info, value) Module.db.profile[info[#info]] = value end,

    args = {
        intro1 = {
            order = new_order(),
            type = 'description',
            name = L['Demo options'],
            fontSize = 'large',
        },
        intro2 = {
            order = new_order(),
            type = 'description',
            name = L['This module is just a space to test out how options are built. '
                ..'Each and every possible type of input type. Each type is '
                ..'grouped together.']
        },
    }
}

-- The options table is split here to show that you dont need to build it all at once.
Module.options.args.executes = {
    type = 'group', inline = true, order = new_order(),
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
    type = 'group', inline = true, order = new_order(),
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
            width = 'double',
        },

    }
}
Module.options.args.toggles = {
    type = 'group', inline = true, order = new_order(),
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
    type = 'group', inline = true, order = new_order(),
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
    type = 'group', inline = true, order = new_order(),
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
    type = 'group', inline = true, order = new_order(),
    name = L["Multi Selects types"],
    -- Multiselect requires a extra table to store the state of each value
    get = function(info, key)
        Module.db.profile[info[#info]] = Module.db.profile[info[#info]] or {}
        return Module.db.profile[info[#info]][key]
    end,
    set = function(info, key, value)
        Module.db.profile[info[#info]] = Module.db.profile[info[#info]] or {}
        Module.db.profile[info[#info]][key] = value
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
    type = 'group', inline = true, order = new_order(),
    name = L["Colors"],
    -- Colors deal with multiple values. r,g,b,a
    get = function(info) return unpack(Module.db.profile[info[#info]] or {}) end,
    set = function(info, ...) Module.db.profile[info[#info]] = {...} end,
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

-- Register the modules with the Addon
Addon.options.args[MODULE_NAME] = Module.options

---------------------------------------------------------------- Core Methods --
function Module:OnInitialize()
    -- Modules are responseable for setting their own database
    self.db = Addon.db:RegisterNamespace(MODULE_NAME, defaultDB)

    -- ... and their own databse callbacks
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

    self:RegisterSlashCommand('test', function(input)
        local arg = self:GetArgs(input, 1)

        self:Print('This is from the module.')
        if arg then
            self:Print('You passed the argument "'..arg..'"')
        else
            self:Print('You didnt pass anything')
        end
    end)

    self:Debug('OnInitialize Trigered')
end

function Module:OnEnable()
    self:Debug('OnEnabled Trigered')
end

function Module:OnDisable()
    self:Debug('OnDisable Trigered')
end

function Module:OnProfileRefresh()
    self:Debug('OnProfileRefresh Trigered')
end

------------------------------------------------------------------------- Fin --
