local ADDON_NAME, Addon = ...
local L = Addon.L

local Module = Addon:NewModule('OtherModule')

--------------------------------------------------------------------------------
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
