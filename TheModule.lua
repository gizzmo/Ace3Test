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
        input = {
            type = 'input',
            name = L['Input'],
            width = 'full',
        },
        input_multiline = {
            type = 'input',
            name = L['Input Multi-line'],
            multiline = true,
            width = 'full',
        },
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

-------------------------------------------------------------- Option Methods --
local values = {}
function Module:getValue(info)
    return values[info[#info]]
end
function Module:setValue(info, value)
    values[info[#info]] = value
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
