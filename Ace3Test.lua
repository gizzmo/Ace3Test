--[[----------------------------------------------------------------------------

------------------------------------------------------------------------------]]

local ADDON_NAME, Addon = ...

_G[ADDON_NAME] = LibStub('AceAddon-3.0'):NewAddon(Addon, ADDON_NAME, 'AceConsole-3.0', 'AceEvent-3.0')

LibStub('AceLocale-3.0'):NewLocale(ADDON_NAME, 'enUS', true, true)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
Addon.L = L

--------------------------------------------------------------------------------

Addon.defaultDB = {
    profile = {

    }
}

function Addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(ADDON_NAME.."DB", self.defaultDB, true)

    -- Callback for when a database profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

    -- Register our options
    LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable(ADDON_NAME, self.options)
    self.options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
    self.options.args.profile.order = -1

    -- Register our modules
    for name,module in self:IterateModules() do
        Addon:RegisterModule(name, module)
    end

    -- Easy reload slashcmd
    LibStub('AceConsole-3.0'):RegisterChatCommand('rl', function() ReloadUI() end)
end

function Addon:OnEnable()
    self:SetupOptions()
end

function Addon:OnProfileRefresh()
    self:ResetModules()
end

--------------------------------------------------------------------------------

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

function Addon:ToggleOptions()
    -- Start by showing the interface options so things can load
    InterfaceOptionsFrame_Show()
    InterfaceOptionsFrame_OpenToCategory(self.optionPanels[2])
    InterfaceOptionsFrame_OpenToCategory(self.optionPanels[1])
    InterfaceOptionsFrame:Raise()
end

function Addon:SetupOptions()
    local Command = LibStub("AceConfigCmd-3.0")
    local Dialog = LibStub("AceConfigDialog-3.0")

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

    -- Find all the module options
    local panels = {}
    for k,v in pairs(self.options.args) do
        if k ~= 'general' then
            tinsert(panels, k)
        end
    end

    -- .. and sort them
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

    -- Start adding the option links
    self.optionPanels = {
        Dialog:AddToBlizOptions(ADDON_NAME, nil, nil, 'general')
    }

    -- Get all the panes and create a link to them
    for i=1, #panels do
        local path = panels[i]
        local name = self.options.args[path].name
        self.optionPanels[i+1] = Dialog:AddToBlizOptions(ADDON_NAME, name, ADDON_NAME, path)
    end

    -- self destruct
    self.SetupOptions = function() end
end

--------------------------------------------------------------------------------

Addon.modulePrototype = {
    core = Addon,
}

Addon:SetDefaultModulePrototype(Addon.modulePrototype)
Addon:SetDefaultModuleLibraries('AceConsole-3.0', 'AceEvent-3.0')

--------------------------------------------------------------------------------

local registeredModules = {}
function Addon:RegisterModule(name, module)
    if registeredModules[module] then return end

    if not module.db then
        module.db = self.db:RegisterNamespace(name, { profile = module.defaultDB or {} })
    end

    if module.options then
        self.options.args[name] = module.options
    end

    registeredModules[module] = true
end

function Addon:ResetModules()
    for nane, module in self:IterateModules() do
        if type(module.Rest) == 'function' then
            module:Reset()
        end
    end
end
