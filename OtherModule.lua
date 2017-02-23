local ADDON_NAME, Addon = ...

---------------------------------------------------------------- Setup Module --
local MODULE_NAME = 'OtherModule'
local Module = Addon:NewModule(MODULE_NAME)
local L = Addon.L

----------------------------------------------------- Default database values --
Module.defaultDB = {

}

-- No options for this module

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
