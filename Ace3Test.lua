local ADDON_NAME, private = ...

--------------------------------------------------------------------------------
-- TEMP LANG
LibStub('AceLocale-3.0'):NewLocale(ADDON_NAME, 'enUS', true, true)

--------------------------------------------------------------------------------
-- Addon Delaration
local Addon = LibStub('AceAddon-3.0'):NewAddon(ADDON_NAME, 'AceConsole-3.0', 'AceEvent-3.0')
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

--------------------------------------------------------------------------------
-- Our db upvalue and db defaults
local db
local defaults = {
    profile = {
        modules = {
            ['*'] = true,
        },

    }
}

function Addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MyTestAddonDB", defaults, true)
    db = self.db.profile -- for ease of access

    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

    self:SetupOptions()

    LibStub('AceConsole-3.0'):RegisterChatCommand('rl', function() ReloadUI() end)
end

function Addon:OnEnable()

end

function Addon:OnProfileRefresh()
    db = self.db.profile

    for k,v in self:IterateModules() do
        local IsEnabled, shouldEnable = v:IsEnabled(), self:GetModuleEnabled(k)
        if shouldEnable and not IsEnabled then
            self:EnableModule(k)
        elseif IsEnabled and not shouldEnable then
            self:DisableModule(k)
        end

        if type(v.OnProfileRefresh) == 'function' then
            v:OnProfileRefresh()
        end
    end
end

function Addon:GetModuleEnabled(moduleName)
    return db.modules[moduleName]
end

function Addon:SetModuleEnabled(module, newState)
    local oldState = db.modules[module]
    db.modules[module] = newState

    if oldState ~= newState then
        if newState then
            self:EnableModule(module)
        else
            self:DisableModule(module)
        end
    end
end
