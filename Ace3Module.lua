local ADDON_NAME, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

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
