---
--- Author: anypkvcai
--- DateTime: 2021-01-15 15:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")
--local TimeUtil = require("Utils/TimeUtil")

---@class MainWifiItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img_Empty UImage
---@field Img_Mid UImage
---@field Img_Strong UImage
---@field Img_Weak UImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainWifiItemView = LuaClass(UIView, true)

function MainWifiItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.Img_Empty = nil
	self.Img_Mid = nil
	self.Img_Strong = nil
	self.Img_Weak = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainWifiItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainWifiItemView:OnInit()

end

function MainWifiItemView:OnDestroy()

end

function MainWifiItemView:OnShow()
	--self:UpdateItem()
end

function MainWifiItemView:OnHide()

end

function MainWifiItemView:OnRegisterUIEvent()

end

function MainWifiItemView:OnRegisterGameEvent()

end

function MainWifiItemView:OnRegisterTimer()
	--self:RegisterTimer(self.UpdateItem, 2, 2, 0)
end

function MainWifiItemView:OnRegisterBinder()

end

--[[
function MainWifiItemView:UpdateItem()
	local Index = self:GetSwitcherIndex()
	self.WidgetSwitcherWiFi:SetActiveWidgetIndex(Index)
end

function MainWifiItemView:GetSwitcherIndex()
	local Value = TimeUtil.GetPingValue()
	if Value < 60 then return 0 end

	if Value < 200 then return 1 end

	return 2
end
--]]

return MainWifiItemView