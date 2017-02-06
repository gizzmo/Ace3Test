-- First variable is the name of the addon folder and corresponding .toc file
-- Second is a private table passed to all included files
local ADDON_NAME, Addon = ...

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

------------------------------------------------------------------- Constants --

Addon.noop = function() --[[No Operation]] end

-------------------------------------------------------------- Initialization --

Addon.defaultDB = {
    profile = {

    },
    global = {

    }
}

function Addon:OnInitialize()
    -- Initialize our database
    self.db = LibStub("AceDB-3.0"):New(ADDON_NAME.."DB", self.defaultDB, true)

    -- Callback for when a database profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

    -- Setup our modules
    for name, module in self:IterateModules() do
        if module.defaultDB and not module.db then
            module.db = self.db:RegisterNamespace(name, { profile = module.defaultDB or {} })
        end
    end

    -- Easy reload slashcmd
    self:RegisterChatCommand('rl', ReloadUI)
end

function Addon:OnEnable()
    -- Setup options here so modules can be initialized
    self:SetupOptions()
end

function Addon:OnProfileRefresh()
    -- Let our modules know so they can react to the changes
    for name, module in self:IterateModules() do
        if type(module.OnProfileRefresh) == 'function' then
            module:OnProfileRefresh()
        end
    end
end

--------------------------------------------------------------------- Modules --

-- Module prototype table supplies methods and properties to all modules
Addon.modulePrototype = {}
Addon:SetDefaultModulePrototype(Addon.modulePrototype)

-- Libraries that are embeded into every module created.
Addon:SetDefaultModuleLibraries('AceConsole-3.0', 'AceEvent-3.0')

------------------------------------------------------------------------ Fin! --
