local ADDON_NAME, private = ...

--------------------------------------------------------------------------------
-- TEMP LANG
LibStub('AceLocale-3.0'):NewLocale(ADDON_NAME, 'enUS', true, true)

--------------------------------------------------------------------------------
-- Addon Delaration
local Addon = LibStub('AceAddon-3.0'):NewAddon(ADDON_NAME, 'AceConsole-3.0', 'AceEvent-3.0')
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

--------------------------------------------------------------------------------
local defaults = {
    profile = {
        modules = {
            ['*'] = true,
        },

    }
}

function Addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(ADDON_NAME.."DB", defaults, true)
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

    self:SetupOptions()

    -- easy reload slashcmd
    LibStub('AceConsole-3.0'):RegisterChatCommand('rl', function() ReloadUI() end)
end

function Addon:OnEnable()

end

function Addon:OnProfileRefresh()
    -- Loop though all modules and only update if it needs to be.
    for name, module in self:IterateModules() do
        self:UpdateModulesState()

        if type(module.OnProfileRefresh) == 'function' then
            module:OnProfileRefresh()
        end
    end
end

--------------------------------------------------------------------------------

function Addon:UpdateModulesState()
    for name, module in self:IterateModules() do
        local isEnabled, shouldEnable = v:IsEnabled(), self:GetModuleEnabled(name)
        if shouldEnable and not isEnabled then
            module:Enable()
        elseif isEnabled and not shouldEnable then
            module:Disable()
        end
    end
end

function Addon:GetModuleEnabledState(name)
    return self.db.profile.modules[name]
end

function Addon:SetModuleEnabledState(module, newState)
    local oldState = self.db.profile.modules[module]
    self.db.profile.modules[module] = newState

    self:UpdateModulesState()
end
