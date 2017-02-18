local ADDON_NAME, Addon = ...
local L = Addon.L

local Module = Addon:NewModule('TheModule')

--------------------------------------------------------------------------------
-- By adding this property, a db property is created for this module
Module.defaultDB = {

}

-- By adding this property, a option entry is created for this module
Module.options = {
    handler = Module,
    type = 'group',
    name = L['The Module'],
    get = 'getValue',
    set = 'setValue',
    args = {
        intro1 = {
            order = 1,
            type = 'header',
            name = L['Demo options'],
        },
        intro2 = {
            order = 2,
            type = 'description',
            name = L['This module is just a space to test out how options are built. '
                ..'Each and every possible type of input type. Each type is '
                ..'grouped together.']
        },
        executes = {
            type = 'group',
            name = L['Execute types'],
            inline = true,
            args = {
                execute = {
                    type = 'execute',
                    name = L['Execute'],
                    func = function() Module:Print('Execute type pressed!')end,
                }
            }
        },
        inputs = {
            type = 'group',
            inline = true,
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
        },
        toggles = {
            type = 'group',
            inline = true,
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
        },
        ranges = {
            type = 'group',
            inline = true,
            name = L['Range types'],
            args = {
                range = {
                    type = 'range',
                    name = L['Range'],
                    min = 1, max = 100,
                },
                range_percent = {
                    type = 'range',
                    name = L['Range'],
                    isPercent = true,
                    min = -1, max = 1,
                },
                range_bigstep = {
                    type = 'range',
                    name = L['Range Bigstep'],
                    min = 0, max = 100, bigStep = 10,
                },
            }
        },
        selects = {
            type = 'group',
            name = L['Select types'],
            inline = true,
            args = {
                select = {
                    order = 1,
                    type = 'select',
                    name = L['Select'],
                    values = 'getSelectValues',
                },
                radioselect = {
                    type = 'select',
                    name = L['Radio Select'],
                    style = 'radio',
                    values = 'getSelectValues',
                },
            }
        },
        multiselects = {
            type = 'group',
            name = L["Multi Selects types"],
            inline = true,
            get = 'getMultiselect',
            set = 'setMultiselect',
            args = {
                multiselect = {
                    type = 'multiselect',
                    name = L["Multi Select"],
                    values = 'getSelectValues',
                },
                multiselecttristate = {
                    type = 'multiselect',
                    name = L["Multi Select Tristate"],
                    tristate = true,
                    values = 'getSelectValues',
                }
            }
        },
        colors = {
            type = 'group',
            name = L["Colors"],
            inline = true,
            get = 'getColor',
            set = 'setColor',
            args = {
                color = {
                    type = 'color',
                    name = L["Color"],
                },
                coloralpha = {
                    type = 'color',
                    name = L["Color with Alpha"],
                    hasAlpha = true
                },
            }
        },
    }
}

-------------------------------------------------------------- Option Methods --
local values = {}
function Module:getValue(info)
    return values[info[#info]]
end
function Module:setValue(info, value)
    values[info[#info]] = value
end


function Module:getSelectValues()
    return {'First value','Second value','Third value','Fourth value','Fifth value','Sixth value'}
end

-- Multiselect requires a extra table of keys and values
function Module:getMultiselect(info, key)
    if not values[info[#info]] then
        values[info[#info]] = {}
    end

    return values[info[#info]][key]
end
function Module:setMultiselect(info, key, value)
    if not values[info[#info]] then
        values[info[#info]] = {}
    end

    values[info[#info]][key] = value
end

-- Colors return multiple values
function Module:getColor(info)
    return unpack(values[info[#info]] or {})
end
function Module:setColor(info, ...)
    values[info[#info]] = {...}
end

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


-- TODO: add more demo code
