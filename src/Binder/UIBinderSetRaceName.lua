---
--- Author: anypkvcai
--- DateTime: 2021-02-07 20:36
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local RaceCfg = require("TableCfg/RaceCfg")

---@class UIBinderSetRaceName : UIBinder
local UIBinderSetRaceName = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetRaceName:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetRaceName:OnValueChanged(NewValue, OldValue)
	local RaceID = NewValue
	local Name = self:GetRaceName(RaceID)

	self.Widget:SetText(Name)
end

---GetRaceName
---@param RaceID number
---@return string
function UIBinderSetRaceName:GetRaceName(RaceID)
	return RaceCfg:GetRaceName(RaceID)
end

return UIBinderSetRaceName