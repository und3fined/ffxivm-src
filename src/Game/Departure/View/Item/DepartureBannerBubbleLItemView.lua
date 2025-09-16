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

---@class DepartureBannerBubbleLItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon UFImage
---@field AnimChange UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureBannerBubbleLItemView = LuaClass(UIView, true)

function DepartureBannerBubbleLItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon = nil
	--self.AnimChange = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureBannerBubbleLItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureBannerBubbleLItemView:OnInit()

end

function DepartureBannerBubbleLItemView:OnDestroy()

end

function DepartureBannerBubbleLItemView:OnShow()

end

function DepartureBannerBubbleLItemView:OnHide()

end

function DepartureBannerBubbleLItemView:OnRegisterUIEvent()

end

function DepartureBannerBubbleLItemView:OnRegisterGameEvent()

end

function DepartureBannerBubbleLItemView:OnRegisterBinder()

end

function DepartureBannerBubbleLItemView:OnDepartActivitySelectedChanged()
	self:UnRegisterAllTimer()
	FLOG_ERROR("取消音效")
end

function DepartureBannerBubbleLItemView:OnIconChanged(AnimDelay)
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

function DepartureBannerBubbleLItemView:GetChangeAnimLength()
	local AnimLength = self.AnimChange:GetEndTime()
	return AnimLength
end

function DepartureBannerBubbleLItemView:SetIcon(IconPath)
	UIUtil.ImageSetBrushFromAssetPath(self.Icon, IconPath)
end

return DepartureBannerBubbleLItemView