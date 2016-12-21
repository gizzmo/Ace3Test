local ADDON_NAME, ns = ...
local Addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local MOD_NAME = 'ModuleA'
local Module = Addon:NewModule(MOD_NAME)

--------------------------------------------------------------------------------

local defaults = {
    profile = {
        ---
    },
}

local function optGetter(info)
    local key = info[#info]
    return db.profile[key]
end

local function optSetter(info, value)
    local key = info[#info]
    db.profile[key] = value
    Module:OnProfileRefresh()
end

local options
local function getOptions()
    if not options then
        options = {
            type = 'group',
            name = L['Test Module'],
            arg = MOD_NAME,
            args = {

            }
        }
    end

    return options
end

function Module:OnInitialize()
    self.db = Addon.db:RegisterNamespace(MOD_NAME, defaults)

    self:SetEnabledState(Addon:GetModuleEnabledState(MOD_NAME))
    Addon:RegisterModuleOptions(MOD_NAME, getOptions, L['Test Module'])
end

function Module:OnEnable()

end
