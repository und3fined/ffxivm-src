--[[
Date: 2021-09-23 10:42:22
LastEditors: moody
LastEditTime: 2021-09-23 10:42:23
--]]
local LuaClass = require("Core/LuaClass")
local UIBinder = require("UI/UIBinder")
local RaceCfg = require("TableCfg/RaceCfg")

---@class UIBinderSetRaceTribeName : UIBinder
local UIBinderSetRaceTribeName = LuaClass(UIBinder)

---Ctor
---@param View UIView
---@param Widget UTextBlock
function UIBinderSetRaceTribeName:Ctor(View, Widget)

end

---OnValueChanged
---@param NewValue number
---@param OldValue number
function UIBinderSetRaceTribeName:OnValueChanged(NewValue, OldValue)
	local TribeID = NewValue
	local Name = self:GetRaceTribeName(TribeID)

	self.Widget:SetText(Name)
end

---GetRaceTribeName
---@param TribeID number
---@return string
function UIBinderSetRaceTribeName:GetRaceTribeName(TribeID)
	return RaceCfg:GetRaceTribeName(TribeID)
end

return UIBinderSetRaceTribeName
