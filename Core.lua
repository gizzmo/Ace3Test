-- First variable is the name of the addon folder and corresponding .toc file
-- Second is a private table passed to all included files.
local ADDON_NAME, Addon = ...

------------------------------------------------------------------ Core Addon --
-- Initialize Ace3 onto our private table so its accessable without having to
-- use LibStub('AceAddon-3.0'):GetAddon(). We expose it to the global space so
-- we can have easy access to it for testing in game.
_G[ADDON_NAME] = LibStub('AceAddon-3.0'):NewAddon(Addon, ADDON_NAME, 'AceConsole-3.0', 'AceEvent-3.0')
Addon.version = GetAddOnMetadata(ADDON_NAME, "Version")

---------------------------------------------------------------------- Locale --
-- Create a default locale and attach it to the Addon for later use.
-- We dont need to set any strings because we are using the key as the value.
-- And if we add new locales this will be extracted into its own file.
LibStub('AceLocale-3.0'):NewLocale(ADDON_NAME, 'enUS', true, true)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
Addon.L = L

-------------------------------------------------------------------- Database --
-- A database uses several data types, which detemins how its accessable.
--   char, class, race, realm, faction, factionrealm, global, profile
--
-- This default table can also enclude magic keys to deal with in inheritance.
--   ['*']   Any sibling key that doesnt exist uses this table.
--   ['**']  Works the same, but other defined tables will inherite from this.
local defaultDB = {
    profile = {

    },
    global = {
        -- We store the enabled status setting here, so modules dont have to
        -- deal with tracking it their self
        debug = {},
    }
}

---------------------------------------------------------------- Core Methods --
-- Called on ADDON_LOADED, when all files and saved varibles have been loaded.
function Addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(ADDON_NAME.."DB", defaultDB, true)

    -- The database has several callbacks available.
    --   OnNewProfile(db, profile)
    --   OnProfileChanged(db, newProfile)
    --   OnProfileDeleted(db, profile)
    --   OnProfileCopied(db, sourceProfile)
    --   OnProfileReset(db)
    --   OnProfileShutdown(db)
    --   OnDatabaseShutdown(db)

    -- These are a good starting point. When ever a profile is changed we may
    -- want to update a few things.
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

    self:InitializeOptions()

    self:Debug("OnInitialize Triggered")
end

-- Called on PLAYER_LOGIN, or when the addon is enabled
-- Register Events, Hook functions, Create Frames, Get information from the game
-- that wasn't available in OnInitialize
function Addon:OnEnable()
    self:Debug("OnEnable Triggered")

    -- Leaving combat for :RunAfterCombat
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

-- Unhook, Unregister Events, Hide frames that you created.
function Addon:OnDisable()
    self:Debug("OnDisable Triggered")
end

function Addon:OnProfileRefresh()
    self:Debug("OnProfileRefresh Triggered")
end

-------------------------------------------------------------------- Debuging --
function Addon:Debug(...)
    if not Addon.db.global.debug[self:GetName()] then return end
    self:Print("|cFFFFFF00Debug:|r", ...) -- Handover to AceConsole
end
function Addon:GetDebugStatus(module)
    return self.db.global.debug[module:GetName()]
end
function Addon:SetDebugStatus(module, value)
    local value = not not value  -- insure its a boolean
    self.db.global.debug[module:GetName()] = value
end

--------------------------------------------------------------------- Modules --

-- Call a given method on all modules if those modules have the method
function Addon:FireModuleMethod(method, ...)
    if type(method) ~= 'string' then
        error(("Usage: FireModuleMethod(method[, arg, arg, ...]): 'method' - string expcted got '%s'."):format(type(method)), 2)
    end

    for name, module in self:IterateModules() do
        if type(module[method]) == 'function' then
           module[method](module, ...)
        end
    end
end

-- This is called when a module is created.
function Addon:OnModuleCreated(module)
    self:SetupDebugOptions(module)
end

-- Libraries that are embeded into every module created.
Addon:SetDefaultModuleLibraries('AceConsole-3.0', 'AceEvent-3.0')

-- Module prototype table supplies methods and properties to all modules
local ModulePrototype = {}
Addon:SetDefaultModulePrototype(ModulePrototype)

-- Used to let modules register sub commands for the core slash command
Addon.ModuleSlashCommands = {}
function ModulePrototype:RegisterSlashCommand(command, func)
    if type(command) ~= 'string' then
       error(("Usage: RegisterSlashCommand(command, func): 'command' - string expected got '%s'."):format(type(command)), 2)
    end
    if type(func) ~= 'string' and type(func) ~= 'function' then
        error(("Usage: RegisterSlashCommand(command, func): 'func' - string or function expected got '%s'"):format(type(func)), 2)
    end
    if type(func) == 'string' and type(self[func]) ~= 'function' then
        error(("Usage: RegisterSlashCommand(command, func): 'func' - method '%s' not found."):format(func), 2)
    end

    Addon.ModuleSlashCommands[command] = Addon.ConvertMethodToFunction(self, func)
end

-- Inherit debugging
ModulePrototype.Debug = Addon.Debug

------------------------------------------------------------------- Utilities --
-- Can be used to overwrite a function without making it nil
Addon.noop = function() --[[No Operation]] end

-- Leave a function as-is or if a string is passed in, convert it to a
-- namespace-method function call.
function Addon.ConvertMethodToFunction(namespace, func_name)
    if type(func_name) == "function" then
        return func_name
    end

    if type(namespace[func_name]) ~= 'function' then
        error(("Usage: ConvertMethodToFunction(namespace, func_name): 'func_name' - method '%s' not found on namespace."):format(func_name), 2)
    end

    return function(...)
        return namespace[func_name](namespace, ...)
    end
end

-- Wrap the given function so that any call to it will be piped through
-- Addon:RunAfterCombat.
function Addon:OutOfCombatWrapper(func)
    if type(func) ~= 'function' then
        error(("Usage: OutOfCombatWrapper(func): 'func' - function expcted got '%s'."):format(type(func)), 2)
    end

    return function(...)
        Addon:RunAfterCombat(func, ...)
    end
end

do
    local action_queue = {}

    function Addon:PLAYER_REGEN_ENABLED()
        self:Debug('Leaving Combat')
        for i, action in ipairs(action_queue) do
            action.func(unpack(action, 1, action.num))
            action_queue[i] = nil
        end
    end

    -- Call a function if out of combat or schedule to run once combat ends.
    -- If currently out of combat, the function provided will be called without delay.
    function Addon:RunAfterCombat(func, ...)
        if type(func) ~= 'function' then
            error(("Usage: RunAfterCombat(func[, ...]): 'func' - function expcted got '%s'."):format(type(func)), 2)
        end

        -- Not in combat, call right away
        if not InCombatLockdown() then
            func(...)
            return
        end

        -- Buildup the action table
        local action = {
            func = func,
            num = select('#', ...)
        }

        -- Save the parameters passed
        for i=1, action.num do
            action[i] = select(i, ...)
        end

        action_queue[#action_queue+1] = action
    end
end

------------------------------------------------------------------------ Fin! --
