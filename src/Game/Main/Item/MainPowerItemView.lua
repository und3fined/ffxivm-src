---
--- Author: anypkvcai
--- DateTime: 2021-01-15 15:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")

---@class MainPowerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img_Battery UImage
---@field Img_Empty UImage
---@field Img_Full UImage
---@field Img_Low UImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainPowerItemView = LuaClass(UIView, true)

function MainPowerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.Img_Battery = nil
	self.Img_Empty = nil
	self.Img_Full = nil
	self.Img_Low = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainPowerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainPowerItemView:OnInit()

end

function MainPowerItemView:OnDestroy()

end

function MainPowerItemView:OnShow()
	--self:UpdateItem()
end

function MainPowerItemView:OnHide()

end

function MainPowerItemView:OnRegisterUIEvent()

end

function MainPowerItemView:OnRegisterGameEvent()
	self:RegisterTimer(self.UpdateItem, 20, 20, 0)
end

function MainPowerItemView:OnRegisterTimer()

end

function MainPowerItemView:OnRegisterBinder()

end

--[[
function MainPowerItemView:UpdateItem()
	local Index = self:GetSwitcherIndex()
	self.WidgetSwitcherBattery:SetActiveWidgetIndex(Index)
end

function MainPowerItemView:GetSwitcherIndex()
	local Level = CommonUtil.GetBatteryLevel()

	if Level < 10 then return 0 end

	if Level < 50 then return 1 end

	return 2
end
--]]

return MainPowerItemView