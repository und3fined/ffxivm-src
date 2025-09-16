---
--- Author: Administrator
--- DateTime: 2025-04-09 14:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")

---@class DepartureBannerBubbleRItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon UFImage
---@field AnimChange UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureBannerBubbleRItemView = LuaClass(UIView, true)

function DepartureBannerBubbleRItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon = nil
	--self.AnimChange = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureBannerBubbleRItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureBannerBubbleRItemView:OnInit()

end

function DepartureBannerBubbleRItemView:OnDestroy()

end

function DepartureBannerBubbleRItemView:OnShow()

end

function DepartureBannerBubbleRItemView:OnHide()

end

function DepartureBannerBubbleRItemView:OnRegisterUIEvent()

end

function DepartureBannerBubbleRItemView:OnRegisterGameEvent()

end

function DepartureBannerBubbleRItemView:OnRegisterBinder()

end

function DepartureBannerBubbleRItemView:OnDepartActivitySelectedChanged()
	self:UnRegisterAllTimer()
end

function DepartureBannerBubbleRItemView:OnIconChanged(AnimDelay)
	local function PlayAnim()
		self:PlayAnimation(self.AnimChange)
		AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.BubbleAnim)
	end

	if AnimDelay and AnimDelay > 0 then
		self:RegisterTimer(PlayAnim, AnimDelay)
	else
		PlayAnim()
	end
	local AnimLength = self.AnimChange:GetEndTime()
	return AnimLength
end

function DepartureBannerBubbleRItemView:SetIcon(IconPath)
	UIUtil.ImageSetBrushFromAssetPath(self.Icon, IconPath)
end



return DepartureBannerBubbleRItemView