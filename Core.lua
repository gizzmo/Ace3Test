-- First variable is the name of the addon folder and corresponding .toc file
-- Second is a private table passed to all included files
local ADDON_NAME, Addon = ...

-- IDEA: make the private table truly private?
-- Do this by having NewAddon make its own table and keeping
-- the private table only for internal use

------------------------------------------------------ Addon and Locale setup --
-- Initialize Ace3 onto private table so its accessable without having
-- to to use LibStub('AceAddon-3.0'):GetAddon(). We expose it to the global
-- space so we can have access easy access to it for testing in game
_G[ADDON_NAME] = LibStub('AceAddon-3.0'):NewAddon(Addon, ADDON_NAME, 'AceConsole-3.0', 'AceEvent-3.0')

-- Create a default locale and attach it to the Addon for later use
-- We dont need to set any strings because we are using the key as the value
LibStub('AceLocale-3.0'):NewLocale(ADDON_NAME, 'enUS', true, true)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
Addon.L = L

Addon.noop = function() --[[No Operation]] end

-------------------------------------------------------------------- Database --
local defaultDB = {
    profile = {

    },
    global = {

    }
}

---------------------------------------------------------------- Core Methods --
-- Things that need to happen AFTER all our file are loaded
function Addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(ADDON_NAME.."DB", defaultDB, true)

    -- Register the database callbacks.
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

    self:AddToBlizOptions()

    self:Print("OnInitialize Triggered")
end

-- Register Events, Hook functions, Create Frames, Get information from
-- the game that wasn't available in OnInitialize
function Addon:OnEnable()
    self:Print("OnEnable Triggered")
end

-- Unhook, Unregister Events, Hide frames that you created.
function Addon:OnDisable()
    self:Print("OnDisable Triggered")
end

function Addon:OnProfileRefresh()
    self:Print("OnProfileRefresh Triggered")
end

--------------------------------------------------------------------- Modules --

-- Generalized method to call a method on all modules
function Addon:FireModuleMethod(method, ...)
    for name, module in self:IterateModules() do
        if type(module[method]) == 'function' then
           module[method](module, ...)
        end
    end
end

-- Module prototype table supplies methods and properties to all modules
Addon.modulePrototype = {}
Addon:SetDefaultModulePrototype(Addon.modulePrototype)

-- Libraries that are embeded into every module created.
Addon:SetDefaultModuleLibraries('AceConsole-3.0', 'AceEvent-3.0')

------------------------------------------------------------------------ Fin! --
