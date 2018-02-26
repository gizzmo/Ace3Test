local ADDON_NAME, Addon = ...

---------------------------------------------------------------- Setup Module --
local MODULE_NAME = 'OtherModule'
local Module = Addon:NewModule(MODULE_NAME)
local L = Addon.L

-------------------------------------------------------------------- Database --
local defaultDB = {
    profile = {

    }
}

---------------------------------------------------------------- Core Methods --
function Module:OnInitialize()
    self.db = Addon.db:RegisterNamespace(MODULE_NAME, defaultDB)

    self:Print('OnInitialize Trigered')
end

function Module:OnEnable()
    self:Print('OnEnabled Trigered')
end

function Module:OnDisable()
    self:Print('OnDisable Trigered')
end

------------------------------------------------------------------------- Fin --
