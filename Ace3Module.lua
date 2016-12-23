local ADDON_NAME, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local Module = Addon:NewModule('ModuleA')

--------------------------------------------------------------------------------

Module.defaultDB = {
    ---
}

Module.options = {
    type = 'group',
    name = L['Test Module'],
    arg = MOD_NAME,
    args = {

    }
}

function Module:PostInitialize()

end

function Module:PostEnable()

end
