---
--- Author: Administrator
--- DateTime: 2023-05-19 10:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class TutorialGestureSelectItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field FCanvasPanel UFCanvasPanel
---@field AnimInInfo UWidgetAnimation
---@field AnimInTap UWidgetAnimation
---@field AnimLoopInfo UWidgetAnimation
---@field AnimLoopTap UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGestureSelectItemView = LuaClass(UIView, true)

function TutorialGestureSelectItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.FCanvasPanel = nil
	--self.AnimInInfo = nil
	--self.AnimInTap = nil
	--self.AnimLoopInfo = nil
	--self.AnimLoopTap = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGestureSelectItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGestureSelectItemView:OnInit()
	self.TimerHdl = nil
	self.IsShow = false
end

function TutorialGestureSelectItemView:OnDestroy()

end

function TutorialGestureSelectItemView:OnShow()

end

function TutorialGestureSelectItemView:OnHide()
	if self.TimerHdl then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end
end

function TutorialGestureSelectItemView:SetFunc(Func)
	if Func then
		self.AnimIn = self.AnimInTap
		self.AnimLoop = self.AnimLoopTap
	else
		self.AnimIn = self.AnimInInfo
		self.AnimLoop = self.AnimLoopInfo
	end

	self:PlayAnimation(self.AnimIn, nil, 1)

	if self.AnimIn then
		local MaxTime = self.AnimIn:GetEndTime()

		self.TimerHdl = self:RegisterTimer(function ()
			self:PlayAnimation(self.AnimLoop, nil, 0)
			self:UnRegisterTimer(self.TimerHdl)
			self.FCanvasPanel:SetVisibility(_G.UE.ESlateVisibility.SelfHitTestInvisible)
		end,MaxTime - 1,0,1)
	end
end

function TutorialGestureSelectItemView:OnRegisterUIEvent()
end

function TutorialGestureSelectItemView:OnRegisterGameEvent()

end

function TutorialGestureSelectItemView:OnRegisterBinder()

end

return TutorialGestureSelectItemView