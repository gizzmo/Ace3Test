local ADDON_NAME, Addon = ...
local L = Addon.L

local Module = Addon:NewModule('ModuleA')

--------------------------------------------------------------------------------

-- By adding this property, a db property is automactly created for this module
Module.defaultDB = {

}

-- By adding this property, a option entry is created for this module
Module.options = {
    type = 'group',
    name = L['Test Module'],
    arg = MOD_NAME,
    args = {

    }
}

function Module:OnInitialize()
end

function Module:OnEnable()
end

function Module:Reset()
end
