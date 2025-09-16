---
--- Author: Administrator
--- DateTime: 2024-02-28 17:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderCanvasSlotSetScale = require("Binder/UIBinderCanvasSlotSetScale")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MooglePawBallCfg = require("TableCfg/MooglePawBallCfg")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameVM = require("Game/GoldSaucerMiniGame/MiniGameVM")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local MoogleMoveState = GoldSaucerMiniGameDefine.MoogleMoveState
local AudioType = GoldSaucerMiniGameDefine.AudioType
local FVector2D = _G.UE.FVector2D

local FLOG_INFO = _G.FLOG_INFO
local FootStepInterval = 0.2

---@class GoldSaucerMooglePawMoogleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_0 UFCanvasPanel
---@field GoldSaucer_MooglePawBallItem_UIBP GoldSaucerMooglePawBallItemView
---@field MI_DX_Common_MooglePaw_4a UFImage
---@field Spine_MooglePaw1 USpineWidget
---@field AnimCryLoop UWidgetAnimation
---@field AnimRunLoop UWidgetAnimation
---@field AnimStandLoop UWidgetAnimation
---@field AnimStop UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawMoogleItemView = LuaClass(UIView, true)

function GoldSaucerMooglePawMoogleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_0 = nil
	--self.GoldSaucer_MooglePawBallItem_UIBP = nil
	--self.MI_DX_Common_MooglePaw_4a = nil
	--self.Spine_MooglePaw1 = nil
	--self.AnimCryLoop = nil
	--self.AnimRunLoop = nil
	--self.AnimStandLoop = nil
	--self.AnimStop = nil
	--self.AnimSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawMoogleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GoldSaucer_MooglePawBallItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawMoogleItemView:OnInit()
	self.Binders = {
		{"MoogleScale", UIBinderCanvasSlotSetScale.New(self, self.Spine_MooglePaw1)},
		{"MoogleMoveState", UIBinderValueChangedCallback.New(self, nil, self.OnMoogleMoveStateChanged)},
		{"MoogleCanvasPos", UIBinderCanvasSlotSetPosition.New(self, self.FCanvasPanel_0)},
	}

	self.LoopStepTimerID = nil -- 循环播放脚步音效计时器
end

function GoldSaucerMooglePawMoogleItemView:OnDestroy()

end

function GoldSaucerMooglePawMoogleItemView:OnShow()

end

function GoldSaucerMooglePawMoogleItemView:OnHide()
	self:StopAllAnimations()
end

function GoldSaucerMooglePawMoogleItemView:OnRegisterUIEvent()

end

function GoldSaucerMooglePawMoogleItemView:OnRegisterGameEvent()

end

function GoldSaucerMooglePawMoogleItemView:OnRegisterBinder()
	local ViewModel = MiniGameVM:GetDetailMiniGameVM(MiniGameType.MooglesPaw)
	if not ViewModel then
		return
	end

	--FLOG_INFO("GoldSaucerMooglePawMoogleItemView:OnRegisterBinder: Binded  ViewModelAddress:%s", ViewModel)
	self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSaucerMooglePawMoogleItemView:OnMoogleMoveStateChanged(NewValue)
	self:StopAllAnimations()
	self:EndPlayFootStepAudio()
	self:HideCacheBallView()
 	-- 运动时的特效变化
	--FLOG_INFO("GoldSaucerMooglePawMoogleItemView:OnMoogleMoveStateChanged: %d", NewValue)
	if MoogleMoveState.Idle == NewValue then
		self:PlayAnimation(self.AnimStandLoop, 0)
	elseif MoogleMoveState.LinerMove == NewValue then
		local ViewModel = MiniGameVM:GetDetailMiniGameVM(MiniGameType.MooglesPaw)
		if not ViewModel then
			return
		end
		local MiniGame = ViewModel.MiniGame
		if not MiniGame then
			return
		end
		local SpeedTimes = MiniGame:GetTheMotionSpeedTimes() or 1
		self.Spine_MooglePaw1:SetTimeScale(SpeedTimes)
		self:PlayAnimation(self.AnimRunLoop, 0)
		self:StartPlayFootStepAudio()
	elseif MoogleMoveState.LowSpeedMoveH == NewValue or MoogleMoveState.LowSpeedMoveV == NewValue then
		self:PlayAnimation(self.AnimStop, 0)
	end
end

function GoldSaucerMooglePawMoogleItemView:ResetAnimationState()
	self:HideCacheBallView()
	self:StopAllAnimations()
	self:PlayAnimation(self.AnimStandLoop)
end

function GoldSaucerMooglePawMoogleItemView:HideCacheBallView()
	if self.GoldSaucer_MooglePawBallItem_UIBP then
		UIUtil.SetIsVisible(self.GoldSaucer_MooglePawBallItem_UIBP, false)
		self.GoldSaucer_MooglePawBallItem_UIBP:ResetRedParticle()
	end
end

function GoldSaucerMooglePawMoogleItemView:ResetAnimationToStart(Anim)
	local AnimLength = Anim:GetEndTime()
	self:PlayAnimation(Anim, AnimLength - 0.05, 1, _G.UE.EUMGSequencePlayMode.Reverse)
	self:PlayAnimation(self.AnimStandLoop)
end

function GoldSaucerMooglePawMoogleItemView:StartPlayFootStepAudio()
	local StepTimerID = self.LoopStepTimerID
	if StepTimerID then
		return
	end

	local ActualInterval
	local ViewModel = MiniGameVM:GetDetailMiniGameVM(MiniGameType.MooglesPaw)
	if not ViewModel then
		return
	end
	local MiniGame = ViewModel.MiniGame
	if not MiniGame then
		return
	end

	local Times = MiniGame:GetTheMotionSpeedTimes() or 1
	ActualInterval = FootStepInterval / Times
	if not ActualInterval then
		return
	end
	self.LoopStepTimerID = self:RegisterTimer(function()
		self:LoopPlayFootStepAudio()
	end, 0, ActualInterval, 0)
end

function GoldSaucerMooglePawMoogleItemView:EndPlayFootStepAudio()
	local StepTimerID = self.LoopStepTimerID
	if not StepTimerID then
		return
	end

	self:UnRegisterTimer(StepTimerID)
	self.LoopStepTimerID = nil
end

function GoldSaucerMooglePawMoogleItemView:LoopPlayFootStepAudio()
	--print("=========== play Foot step")
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleFootStep)
end

function GoldSaucerMooglePawMoogleItemView:ShowSuccessCatchBallResult()
	local ViewModel = MiniGameVM:GetDetailMiniGameVM(MiniGameType.MooglesPaw)
	if not ViewModel then
		return
	end
	
	local BallVM = ViewModel:GetTheCatchBallVM()
	if not BallVM then
		return
	end
	local BallType = BallVM.BallType
	local BallWidget = self.GoldSaucer_MooglePawBallItem_UIBP
	if BallWidget and BallType then
		UIUtil.SetIsVisible(BallWidget, true)
		BallWidget:ShowCatchResult(BallType)
		local BallCfg = MooglePawBallCfg:FindCfgByKey(BallType)
		if BallCfg then
			local BallSize = BallCfg.BodySize or 0
			local MoogleHalfSize = ViewModel:GetMoogleHalfSize() or 0
			UIUtil.CanvasSlotSetPosition(BallWidget, FVector2D(0, MoogleHalfSize + BallSize / 2))
		end
	end
end

return GoldSaucerMooglePawMoogleItemView