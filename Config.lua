-- Addon name and private table
local ADDON_NAME, Addon = ...
local L = Addon.L

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

    local panels = {}

    -- Setup module options
    for name, module in self:IterateModules() do
        if module.options then
            self.options.args[name] = module.options
            tinsert(panels, module.options)
        end
    end

    -- And options for profiles
    self.options.args.profile = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
    self.options.args.profile.order = -1
    tinsert(panels, self.options.args.profile)

    -- And sort the options
    table.sort(panels, function(a, b)
        if not a then return true end
        if not b then return false end
        local orderA, orderB = a.order or 10000, b.order or 10000
        if orderA == orderB then
            return strupper(a.name or "") < strupper(b.name or "")
        end
        if orderA < 0 then
            if orderB > 0 then return false end
        else
            if orderB < 0 then return true end
        end
        return orderA < orderB
    end)

    -- Create the General options link
    Registry:RegisterOptionsTable(ADDON_NAME, self.options.args.general)
    self.optionPanels = {
        Dialog:AddToBlizOptions(ADDON_NAME, Addon:GetName())
    }

    -- And then a link for all modules
    for i=1, #panels do
        local name = panels[i].name
        Registry:RegisterOptionsTable(ADDON_NAME..name, panels[i])
        self.optionPanels[i+1] = Dialog:AddToBlizOptions(ADDON_NAME..name, name, ADDON_NAME)
    end

    -- Self Destruct.
    self.SetupOptions = self.noop
end
