local ADDON_NAME, Addon = ...
local L = Addon.L

local Module = Addon:NewModule('ModuleA')

--------------------------------------------------------------------------------

Module.defaultDB = {

}

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