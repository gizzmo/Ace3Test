local ADDON_NAME, private = ...

--------------------------------------------------------------------------------
-- TEMP LANG
LibStub('AceLocale-3.0'):NewLocale(ADDON_NAME, 'enUS', true, true)

--------------------------------------------------------------------------------
-- Addon Delaration
local Addon = LibStub('AceAddon-3.0'):NewAddon(ADDON_NAME, 'AceConsole-3.0', 'AceEvent-3.0')
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

--------------------------------------------------------------------------------

Addon.options = {
    name = ADDON_NAME,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = L['General Settings'],
            get = optGetter,
            set = optSetter,
            args = {
                -- addon-wide settings here
            },
        },
    },
}

Addon.defaultDB = {
    profile = {

    }
}

function Addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(ADDON_NAME.."DB", self.defaultDB, true)

    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

    -- Register out options
    LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable(ADDON_NAME, self.options)
    self.options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
    self.options.args.profile.order = -1

    -- easy reload slashcmd
    LibStub('AceConsole-3.0'):RegisterChatCommand('rl', function() ReloadUI() end)
end

function Addon:OnEnable()
    if self.SetupOptions then
        self:SetupOptions()
    end
end

function Addon:OnProfileRefresh()
    -- Loop though all modules and only update if it needs to be.
    for name, module in self:IterateModules() do
        if type(module.OnProfileRefresh) == 'function' then
            module:OnProfileRefresh()
        end
    end
end

--------------------------------------------------------------------------------

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

    self:RegisterChatCommand('ace', function(input)
        if input then input = strtrim(input) end

        if not input or input == '' then
            self:ToggleOptions()
        elseif strmatch(strlower(input), '^ve?r?s?i?o?n?$') then
            local version = GetAddOnMetadata(ADDON_NAME, 'Version')

            self:Print(format(L['You are using version %s'], version))
        else
            Command.HandelCommand(Addon, nil, ADDON_NAME, input)
        end
    end)

    local panels = {}
    for k,v in pairs(self.options.args) do
        if k ~= 'general' then
            tinsert(panels, k)
        end
    end

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

    self.optionPanels = {
        Dialog:AddToBlizOptions(ADDON_NAME, nil, nil, 'general')
    }

    for i=1, #panels do
        local path = panels[i]
        local name = self.options.args[path].name
        self.optionPanels[i+1] = Dialog:AddToBlizOptions(ADDON_NAME, name, ADDON_NAME, path)
    end


    -- self destruct
    self.SetupOptions = nil

end

--------------------------------------------------------------------------------

Addon.modulePrototype = {
    core = Addon,
}

function Addon.modulePrototype.OnInitialize(self)
    self.db = Addon.db:RegisterNamespace(self.moduleName, { profile = self.defaultDB or {} })

    if self.options then
        Addon.options.args[self.moduleName] = self.options
    end

    if type(self.PostInitialize) == "function" then
        self:PostInitialize()
    end
end

function Addon.modulePrototype.OnEnable(self)


    if type(self.PostEnable) == "function" then
        self:PostEnable()
    end
end

Addon:SetDefaultModulePrototype(Addon.modulePrototype)
Addon:SetDefaultModuleLibraries("AceEvent-3.0")
