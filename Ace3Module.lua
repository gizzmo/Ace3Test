local ADDON_NAME, ns = ...
local Addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local MOD_NAME = 'ModuleA'
local Module = Addon:NewModule(MOD_NAME)

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
