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

----------------------------------------------------------- Declare Variables --
Addon.noop = function() --[[No Operation]] end

----------------------------------------------------- Default Database Values --
Addon.defaultDB = {
    profile = {

    },
    global = {

    }
}

-------------------------------------------------------------- Initialization --
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

    -- Setup options here to insure the options are always available
    self:SetupOptions()

    self:Print("OnInitialize Triggered")
end

function Addon:OnEnable()
    self:Print("OnEnable Triggered")
end

function Addon:OnDisable()
    self:Print("OnDisable Triggered")
end

function Addon:OnProfileRefresh()
    self:Print("OnProfileRefresh Triggered")

    -- Let our modules know so they can react to the changes
    self:FireModuleMethod('OnProfileRefresh')
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
