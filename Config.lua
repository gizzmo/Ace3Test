local ADDON_NAME, Addon = ...
local L = Addon.L

-- Keep track of panels in the blizzard options.
Addon.optionPanels = {}

--------------------------------------------------------------------- Options --

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

function Addon:SetupOptions()
    -- Custom /slash command
    self:RegisterChatCommand('ace', 'SlashHandler')

    -- Register the options table
    LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable(ADDON_NAME, self.options)

    -- Module options
    for name, module in self:IterateModules() do
        if module.options then
            self.options.args[name] = module.options
        end
    end

    -- Profile options
    self.options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
    self.options.args.profile.order = -1

    --------------------------------------- Add to Blizzard interface options --
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
    self.optionPanels['general'] = Dialog:AddToBlizOptions(ADDON_NAME, self:GetName(), nil, 'general')

    -- Create a link for all the panels
    for i=1,#panels do
        local path = panels[i]
        local name = self.options.args[path].name
        self.optionPanels[path] = Dialog:AddToBlizOptions(ADDON_NAME, name, ADDON_NAME, path)
    end

    self.SetupOptions = self.noop
end

function Addon:SlashHandler(input)
    local arg = self:GetArgs(input, 1)

    -- No argument, open options
    if not arg then
        -- Start by opening the interface options so things can load
        InterfaceOptionsFrame_Show()

        -- Open to the second panel to expand the options
        InterfaceOptionsFrame_OpenToCategory(self.optionPanels['profile'])
        InterfaceOptionsFrame_OpenToCategory(self.optionPanels['general'])
        InterfaceOptionsFrame:Raise()

        -- TODO: Figure out why it wont open if its not visable
        -- the user has to manually scroll the list to get access to it.

    -- Version Checking
    -- TODO: find better pattern matching
    elseif strmatch(strlower(arg), '^ve?r?s?i?o?n?$') then
        local version = GetAddOnMetadata(ADDON_NAME, 'Version')
        self:Print(format(L['You are using version %s'], version))
    end
end
