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

---------------------------------------------------------------- Core Methods --
function Module:OnInitialize()
    self.db = Addon.db:RegisterNamespace(MODULE_NAME, defaultDB)

    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileRefresh")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileRefresh")

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
