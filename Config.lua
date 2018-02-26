local ADDON_NAME, Addon = ...
local L = Addon.L

--------------------------------------------------------------------- Options --
Addon.options = {
    type = 'group',
    childGroups = 'tab',
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

-- Called in ADDON:OnInitialize, used to setup our options
function Addon:InitializeOptions()
    LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable(ADDON_NAME, self.options)

    self.options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
    self.options.args.profile.order = -1

    -- REMOVE this line and if you're not using blizzard options.
    if self.AddToBlizOptions then return self:AddToBlizOptions() end
end

function Addon:OpenOptions()
    -- REMOVE this line and if you're not using blizzard options.
    if self.OpenBlizOptions then return self:OpenBlizOptions() end

    local Dialog = LibStub('AceConfigDialog-3.0')
    if Dialog.OpenFrames[ADDON_NAME] then
        Dialog:Close(ADDON_NAME)
    else
        Dialog:Open(ADDON_NAME)
    end
end

-------------------------------------------------- Blizzard interface options --
-- REMOVE this section if you're not using blizzard options.

-- Keep track of panels in the blizzard options.
local blizOptionsPanels = {}
function Addon:AddToBlizOptions()
    local panels = {}

    -- Grab a list of possible panels
    for k,v in pairs(self.options.args) do
        if k~='general' then tinsert(panels, k) end
    end

    -- Sort the panels
    table.sort(panels, function(a, b)
        if not a then return true end
        if not b then return false end
        local orderA = self.options.args[a].order or 100
        local orderB = self.options.args[b].order or 100
        if orderA == orderB then
            local nameA = self.options.args[a].name or ""
            local nameB = self.options.args[b].name or ""
            return nameA:upper() < nameB:upper()
        end
        if orderA < 0 then
            if orderB > 0 then return false end
        else
            if orderB < 0 then return true end
        end
        return orderA < orderB
    end)

    local Dialog = LibStub('AceConfigDialog-3.0')

    -- Create the link to the general options
    blizOptionsPanels['general'] = Dialog:AddToBlizOptions(ADDON_NAME, self:GetName(), nil, 'general')

    -- Create a link for all the panels
    for i=1,#panels do
        local path = panels[i]
        local name = self.options.args[path].name
        blizOptionsPanels[path] = Dialog:AddToBlizOptions(ADDON_NAME, name, ADDON_NAME, path)
    end

    -- All options need to be registered before this is run, and since this is
    -- run in ADDON:OnInitialize, modules need to setup their options before that.

    -- Once this is called, panels are no longer sortable, and all new panels
    -- will be added to the ned of the list.
end

-- TODO: Update to open to child elements
function Addon:OpenBlizOptions()
    -- Start by opening the interface options so things can load
    InterfaceOptionsFrame_Show()

    -- Open to the second panel to expand the options
    InterfaceOptionsFrame_OpenToCategory(blizOptionsPanels['profile'])
    InterfaceOptionsFrame_OpenToCategory(blizOptionsPanels['general'])
    InterfaceOptionsFrame:Raise()

    -- TODO: Figure out why it wont open if its not visable
    -- the user has to manually scroll the list to get access to it.
end

-------------------------------------------------------------- Slash commands --
Addon:RegisterChatCommand('rl', ReloadUI)

local function SlashHandler(input)
    local arg = Addon:GetArgs(input, 1)

    -- No argument, open options
    if not arg then
        Addon:OpenOptions()

    -- Version Checking
    -- TODO: find better pattern matching
    elseif strmatch(strlower(arg), '^ve?r?s?i?o?n?$') then
        Addon:Print(format(L['You are using version %s'], self.version))
    else
        -- Check for register module chat commands
        for command, func in pairs(Addon.ModuleSlashCommands) do
            if command == arg then
                return func(input:sub(#arg+2))
            end
        end
    end
end

-- Register multiple slash commands with the same handler.
Addon:RegisterChatCommand('ace', SlashHandler)
Addon:RegisterChatCommand('ace3test', SlashHandler)
