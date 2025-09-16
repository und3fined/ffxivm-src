---
--- Author: Administrator
--- DateTime: 2023-11-09 16:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local AudioType = GoldSaucerMiniGameDefine.AudioType

---@class OutOnALimbPointerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgPointer UFImage
---@field ImgState UFImage
---@field AnimHideLight UWidgetAnimation
---@field AnimRedLight UWidgetAnimation
---@field AnimRedLightLoop UWidgetAnimation
---@field AnimStateIn UWidgetAnimation
---@field AnimYellowLight UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OutOnALimbPointerItemView = LuaClass(UIView, true)

function OutOnALimbPointerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgPointer = nil
	--self.ImgState = nil
	--self.AnimHideLight = nil
	--self.AnimRedLight = nil
	--self.AnimRedLightLoop = nil
	--self.AnimStateIn = nil
	--self.AnimYellowLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OutOnALimbPointerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OutOnALimbPointerItemView:OnInit()
	
end

function OutOnALimbPointerItemView:OnDestroy()

end

function OutOnALimbPointerItemView:OnShow()

end

function OutOnALimbPointerItemView:OnHide()

end

function OutOnALimbPointerItemView:OnRegisterUIEvent()

end

function OutOnALimbPointerItemView:OnRegisterGameEvent()

end

function OutOnALimbPointerItemView:OnRegisterBinder()

end

function OutOnALimbPointerItemView:SetPointerPath(PointerPath)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgPointer, PointerPath)
end

function OutOnALimbPointerItemView:SetMarkPath(MarkPath)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgState, MarkPath)
end

function OutOnALimbPointerItemView:SetMarkState(bVisible)
	UIUtil.SetIsVisible(self.ImgState, bVisible)
	if bVisible then
		self:PlayAnimation(self.AnimStateIn)
	end
end

function OutOnALimbPointerItemView:PlayYellowPointerLight()
	self:PlayAnimation(self.AnimYellowLight)
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.PointerStop)
end

function OutOnALimbPointerItemView:PlayRedPointerLight()
	self:PlayAnimation(self.AnimRedLight)
end

function OutOnALimbPointerItemView:HideRedPointerLight()
	self:StopAnimation(self.AnimRedLightLoop)
	self:PlayAnimation(self.AnimHideLight)
end
--- 动画结束统一回调
function OutOnALimbPointerItemView:OnAnimationFinished(Animation)
	if Animation == self.AnimRedLight then
		self:PlayAnimation(self.AnimRedLightLoop, 0, 0, nil, 1.0)
	end
end

return OutOnALimbPointerItemView