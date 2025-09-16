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

---@class DepartureBannerBubble2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon1 UFImage
---@field Icon2 UFImage
---@field AnimChange UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureBannerBubble2ItemView = LuaClass(UIView, true)

function DepartureBannerBubble2ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon1 = nil
	--self.Icon2 = nil
	--self.AnimChange = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureBannerBubble2ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureBannerBubble2ItemView:OnInit()

end

function DepartureBannerBubble2ItemView:OnDestroy()

end

function DepartureBannerBubble2ItemView:OnShow()

end

function DepartureBannerBubble2ItemView:OnHide()

end

function DepartureBannerBubble2ItemView:OnRegisterUIEvent()

end

function DepartureBannerBubble2ItemView:OnRegisterGameEvent()

end

function DepartureBannerBubble2ItemView:OnRegisterBinder()

end

-- function DepartureBannerBubble2ItemView:OnIconChanged()
-- 	self:PlayAnimation(self.AnimChange)
-- 	local function PlaySound()
-- 		AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.BubbleAnim)
-- 	end
-- 	PlaySound()
-- 	local AnimLength = self.AnimChange:GetEndTime()
-- 	self:RegisterTimer(PlaySound, AnimLength * 0.5)
-- 	return AnimLength
-- end

function DepartureBannerBubble2ItemView:OnIconChanged(AnimDelay)
	local AnimLength = self.AnimChange:GetEndTime()
	local function PlayAnim()
		self:PlayAnimation(self.AnimChange)
		local function PlaySound()
			AudioUtil.LoadAndPlayUISound(DepartOfLightDefine.UISoundPath.BubbleAnim)
		end
		PlaySound()
		self:RegisterTimer(PlaySound, AnimLength * 0.5)
	end

	if AnimDelay and AnimDelay > 0 then
		self:RegisterTimer(PlayAnim, AnimDelay)
	else
		PlayAnim()
	end

	return AnimLength
end

function DepartureBannerBubble2ItemView:SetIcon(Icon1, Icon2)
	UIUtil.ImageSetBrushFromAssetPath(self.Icon1, Icon1)
	UIUtil.ImageSetBrushFromAssetPath(self.Icon2, Icon2)
end


return DepartureBannerBubble2ItemView