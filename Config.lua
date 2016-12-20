local ADDON_NAME, ns = ...
local Addon = LibStub('AceAddon-3.0'):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local options, moduleOptions, optionsFrames = nil, {}, {}

local function optGetter(info)
    local key = info[#info]
    return Addon.db.profile[key]
end

local function optSetter(info, value)
    local key = info[#info]
    Addon.db.profile[key] = value
    Addon:OnProfileRefresh()
end

-- Generate the options table
local function getOptions()
    if not options then
        options = {
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

        -- Include all the provided module options
        for key,v in pairs(moduleOptions) do
            options.args[key] = (type(v) == 'function') and v() or v
        end
    end

    return options
end

local function openOptions()
    InterfaceOptionsFrame_Show()
    -- open the profiles tab before, so the menu expands
    InterfaceOptionsFrame_OpenToCategory(optionsFrames.profiles)
    InterfaceOptionsFrame_OpenToCategory(optionsFrames[ADDON_NAME])
    InterfaceOptionsFrame:Raise()
end

function Addon:SetupOptions()
    LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable(ADDON_NAME, getOptions)

    -- create a link in the interface options
    optionsFrames[ADDON_NAME] = LibStub('AceConfigDialog-3.0'):AddToBlizOptions(ADDON_NAME, nil, nil, 'general')

    -- add profile options link -- this link will always be first because its the first registred
    self:RegisterModuleOptions('profiles', LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db), 'Profiles')

    -- slash command to open options
    LibStub('AceConsole-3.0'):RegisterChatCommand('ace', openOptions)
end

function Addon:RegisterModuleOptions(key, optionsTbl, displayName)
    moduleOptions[key] = optionsTbl
    optionsFrames[key] = LibStub('AceConfigDialog-3.0'):AddToBlizOptions(ADDON_NAME, displayName, ADDON_NAME, key)
end
