---
--- Author: sammrli
--- DateTime: 2024-02-26 10:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class ChocoboTransportEndTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BirdFly ChocoboTransportBirdFlyItemView
---@field BirdRun ChocoboTransportBirdRunItemView
---@field FTextBlock_59 UFTextBlock
---@field SwitchBird UFWidgetSwitcher
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTransportEndTipsItemView = LuaClass(UIView, true)

function ChocoboTransportEndTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BirdFly = nil
	--self.BirdRun = nil
	--self.FTextBlock_59 = nil
	--self.SwitchBird = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTransportEndTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BirdFly)
	self:AddSubView(self.BirdRun)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTransportEndTipsItemView:OnInit()

end

function ChocoboTransportEndTipsItemView:OnDestroy()

end

function ChocoboTransportEndTipsItemView:OnShow()

end

function ChocoboTransportEndTipsItemView:OnHide()

end

function ChocoboTransportEndTipsItemView:OnRegisterUIEvent()

end

function ChocoboTransportEndTipsItemView:OnRegisterGameEvent()

end

function ChocoboTransportEndTipsItemView:OnRegisterBinder()

end

---@type PlayRunAnimation
function ChocoboTransportEndTipsItemView:PlayRunAnimation()
	self.SwitchBird:SetActiveWidgetIndex(1)
	self:PlayAnimation(self.AnimIn)
end

---@type PlayFlyAnimation
function ChocoboTransportEndTipsItemView:PlayFlyAnimation()
	self:PlayAnimation(self.AnimIn)
	self.SwitchBird:SetActiveWidgetIndex(0)
end

function ChocoboTransportEndTipsItemView:SetText(Text)
	self.FTextBlock_59:SetText(Text)
end

return ChocoboTransportEndTipsItemView