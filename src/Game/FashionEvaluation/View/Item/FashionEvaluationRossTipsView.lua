---
--- Author: Administrator
--- DateTime: 2024-11-01 15:49
--- Description:罗斯开场白
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")

---@class FashionEvaluationRossTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgRoss UFImage
---@field ProBarFull URadialImage
---@field Text UFTextBlock
---@field AnimProgress UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationRossTipsView = LuaClass(UIView, true)

function FashionEvaluationRossTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgRoss = nil
	--self.ProBarFull = nil
	--self.Text = nil
	--self.AnimProgress = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationRossTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationRossTipsView:OnInit()
	self.CountDown = 0
	self.Duration = 0
	self.StartID = 1
end

function FashionEvaluationRossTipsView:OnDestroy()

end

function FashionEvaluationRossTipsView:OnShow()
	self.CountDown = 0
	self.Duration = 0
	self.StartID = 1
end

function FashionEvaluationRossTipsView:OnHide()
	
end

function FashionEvaluationRossTipsView:OnRegisterUIEvent()

end

function FashionEvaluationRossTipsView:OnRegisterGameEvent()

end

function FashionEvaluationRossTipsView:OnRegisterBinder()

end

---@type 下一个开场白
function FashionEvaluationRossTipsView:OnShowNextPrologue()
	if self.ShowNextTimer then
		self:UnRegisterTimer(self.ShowNextTimer)
		self.ShowNextTimer = nil
	end

	local PrologueInfo = FashionEvaluationVMUtils.GetPrologueInfo(self.StartID)
	if PrologueInfo == nil then
		return
	end
	
	local MaxPrologueNum = PrologueInfo.MaxPrologueNum
	local Prologue = PrologueInfo.Prologue

	if self.StartID > MaxPrologueNum then
		FashionEvaluationMgr:OnPrologueEnd()
		UIUtil.SetIsVisible(self, false)
		return
	end

	if Prologue == nil then
		return
	end
	self.CountDown = 0
	self.Duration = Prologue.Duration
	local AnimIcon = Prologue.AnimIcon
	local Content = self.StartID == 2 and string.format(Prologue.Content, FashionEvaluationMgr:GetThemeName() or "") or Prologue.Content
	if not string.isnilorempty(AnimIcon) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgRoss, AnimIcon)
	end
	if not string.isnilorempty(Content) then
		self.Text:SetText(Content)
	end
	self.StartID = self.StartID + 1
	self.ShowNextTimer = self:RegisterTimer(self.UpdateTimeCountDown, 0, 0.03, 0)
end

function FashionEvaluationRossTipsView:UpdateTimeCountDown()
	self:PlayProgressAnim(self.Duration, self.CountDown)
	self.CountDown = self.CountDown + 0.03
	if self.CountDown >= self.Duration then
		self:OnShowNextPrologue()
	end
end

function FashionEvaluationRossTipsView:ShowSingleTips(AnimIcon, Content, Duration)
	if not string.isnilorempty(AnimIcon) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgRoss, AnimIcon)
	end
	if not string.isnilorempty(Content) then
		self.Text:SetText(Content)
	end

	self.CountDown = 0
	local function UpdateTimeCountDown()
		self:PlayProgressAnim(Duration, self.CountDown)
		self.CountDown = self.CountDown + 0.03
		if self.CountDown >= Duration then
			UIUtil.SetIsVisible(self, false)
		end
	end
	self.ShowNextTimer = self:RegisterTimer(UpdateTimeCountDown, 0, 0.03, 0)
end

function FashionEvaluationRossTipsView:GetProgressAnimDuration()
	if self.AnimProgress then
		return self.AnimProgress:GetEndTime()
	end
	return 0
end

function FashionEvaluationRossTipsView:PlayProgressAnim(Duration, CountDown)
	local Percent = math.clamp(CountDown / Duration, 0, 1.0)
	local ProgressAnimDuration = self:GetProgressAnimDuration()
	local Speed = ProgressAnimDuration / Duration
	local PrevPercent = math.clamp((CountDown - 0.03) / Duration, 0, 1.0)
	local StartTime = ProgressAnimDuration * PrevPercent
	local EndAnimTime = ProgressAnimDuration * Percent
	self:PlayAnimationTimeRange(self.AnimProgress, StartTime, EndAnimTime, 1, nil, Speed, false)
end

return FashionEvaluationRossTipsView