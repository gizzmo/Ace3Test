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

    self:Debug('OnInitialize Trigered')
end

function Module:OnEnable()
    self:Debug('OnEnabled Trigered')
end

function Module:OnDisable()
    self:Debug('OnDisable Trigered')
end

------------------------------------------------------------------------- Fin --
