local ADDON_NAME, Addon = ...

---------------------------------------------------------------- Setup Module --
local MODULE_NAME = 'OtherModule'
local Module = Addon:NewModule(MODULE_NAME)
local L = Addon.L

-------------------------------------------------------------------- Database --
local defaultDB = {
    profile = {

    },
    global = {

    }
}

Module.db = Addon.db:RegisterNamespace(MODULE_NAME, defaultDB)

-- Needs to be defined before the callback is registered
function Module:OnProfileRefresh()
    self:Print("OnProfileRefresh Triggered")
end

Module.db.RegisterCallback(Module, "OnProfileChanged", "OnProfileRefresh")
Module.db.RegisterCallback(Module, "OnProfileCopied", "OnProfileRefresh")
Module.db.RegisterCallback(Module, "OnProfileReset", "OnProfileRefresh")

---------------------------------------------------------------- Core Methods --
function Module:OnInitialize()
    self:Print('OnInitialize Trigered')
end

function Module:OnEnable()
    self:Print('OnEnabled Trigered')
end

function Module:OnDisable()
    self:Print('OnDisable Trigered')
end

function Module:OnProfileRefresh()
    self:Print('OnProfileRefresh Trigered')
end

------------------------------------------------------------------------- Fin --
