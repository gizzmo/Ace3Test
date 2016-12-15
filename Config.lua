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

local function getOptions()
    if not options then
        options = {
            type = 'group',
            name = 'Ace3Test',
            args = {
                general = {
                    order = 1,
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

        for k,v in pairs(moduleOptions) do
            options.args[k] = (type(v) == 'function') and v() or v
        end
    end

    return options
end

local function openOptions()
    InterfaceOptionsFrame_Show()
    -- open the profiles tab before, so the menu expands
    InterfaceOptionsFrame_OpenToCategory(optionsFrames.Profiles)
    InterfaceOptionsFrame_OpenToCategory(optionsFrames[ADDON_NAME])
    InterfaceOptionsFrame:Raise()
end

function Addon:SetupOptions()
    LibStub('AceConfigRegistry-3.0'):RegisterOptionsTable(ADDON_NAME, getOptions)
    optionsFrames[ADDON_NAME] = LibStub('AceConfigDialog-3.0'):AddToBlizOptions(ADDON_NAME, nil, nil, 'general')

    self:RegisterModuleOptions('Profiles', LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db), 'Profiles')

    LibStub('AceConsole-3.0'):RegisterChatCommand('ace', openOptions)
end

function Addon:RegisterModuleOptions(name, optionTbl, displayName)
    moduleOptions[name] = optionTbl
    optionsFrames[name] = LibStub('AceConfigDialog-3.0'):AddToBlizOptions(ADDON_NAME, displayName, ADDON_NAME, name)
end
