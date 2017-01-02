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

-------------------------------------------------------------- Initialization --

Addon.defaultDB = {
    profile = {

    },
    global = {

    }
}

function Addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(ADDON_NAME.."DB", self.defaultDB, true)

    -- Callback for when a database profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

    -- Add options for profiles
    self.options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
    self.options.args.profile.order = -1 -- always at the end of the list

    -- Setup our modules, add database and fetch options
    self:RegisterModules()

    -- Easy reload slashcmd
    LibStub('AceConsole-3.0'):RegisterChatCommand('rl', function() ReloadUI() end)
end

function Addon:OnEnable()
    -- Setup options here so modules can be initialized
    self:SetupOptions()
end

function Addon:OnProfileRefresh()
    -- Let our modules know so they can react to the changes
    self:ResetModules()
end

--------------------------------------------------------------------- Options --
-- Note: We could move this to a new file if it gets to large

Addon.options = {
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = L['General Settings'],
            order = 1,
            args = {
                -- addon-wide settings here
            },
        },
    },
}

-- NOTE: Should this actaully toggle the options open and closed?
--       Or Should we rename the method to `OpenOptions`?
function Addon:ToggleOptions()
    -- Start by showing the interface options so things can load
    InterfaceOptionsFrame_Show()
    -- Open to the second panel to expand the options
    InterfaceOptionsFrame_OpenToCategory(self.optionPanels[2])
    InterfaceOptionsFrame_OpenToCategory(self.optionPanels[1])
    InterfaceOptionsFrame:Raise()
end

function Addon:SetupOptions()
    local Command = LibStub("AceConfigCmd-3.0")
    local Dialog = LibStub("AceConfigDialog-3.0")
    local Registry = LibStub('AceConfigRegistry-3.0')

    -- Custom /slash command
    self:RegisterChatCommand('ace', function(input)
        if input then input = strtrim(input) end

        if not input or input == '' then
            self:ToggleOptions()
        elseif strmatch(strlower(input), '^ve?r?s?i?o?n?$') then
            local version = GetAddOnMetadata(ADDON_NAME, 'Version')

            self:Print(format(L['You are using version %s'], version))
        else
            Command.HandleCommand(Addon, 'ace', ADDON_NAME, input)
        end
    end)

    -- Find all the module options ...
    local panels = {}
    for k,v in pairs(self.options.args) do
        if k ~= 'general' then
            tinsert(panels, k)
        end
    end

    -- ... and then sort them.
    table.sort(panels, function(a, b)
        if not a then return true end
        if not b then return false end
        local orderA, orderB = self.options.args[a].order or 10000, self.options.args[b].order or 10000
        if orderA == orderB then
            return strupper(self.options.args[a].name or "") < strupper(self.options.args[b].name or "")
        end
        if orderA < 0 then
            if orderB > 0 then return false end
        else
            if orderB < 0 then return true end
        end
        return orderA < orderB
    end)

    -- Create the General options link ...
    Registry:RegisterOptionsTable(ADDON_NAME, self.options.args.general)
    self.optionPanels = {
        Dialog:AddToBlizOptions(ADDON_NAME, Addon:GetName())
    }

    -- ... then a link for all modules.
    for i=1, #panels do
        local name = self.options.args[panels[i]].name
        Registry:RegisterOptionsTable(ADDON_NAME..name, self.options.args[panels[i]])
        self.optionPanels[i+1] = Dialog:AddToBlizOptions(ADDON_NAME..name, name, ADDON_NAME)
    end

    -- Self Destruct.
    self.SetupOptions = function() end
end

--------------------------------------------------------------------- Modules --

-- Module prototype table supplies methods and properties to all modules
Addon.modulePrototype = {
    core = Addon,
}

Addon:SetDefaultModulePrototype(Addon.modulePrototype)

-- Libraries that are embeded into every module created.
Addon:SetDefaultModuleLibraries('AceConsole-3.0', 'AceEvent-3.0')

function Addon:RegisterModules()
    for name, module in self:IterateModules() do
        -- Setup the module database
        if module.defaultDB and not module.db then
            module.db = self.db:RegisterNamespace(name, { profile = module.defaultDB or {} })
        end

        -- Add module options if they are provided
        if module.options and not self.options.args[name] then
            self.options.args[name] = module.options
        end
    end
end

function Addon:ResetModules()
    for name, module in self:IterateModules() do
        if type(module.Reset) == 'function' then
            module:Reset()
        end
    end
end

------------------------------------------------------------------------ Fin! --
