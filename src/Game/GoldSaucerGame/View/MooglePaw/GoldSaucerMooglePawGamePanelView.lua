---
--- Author: bowxiong
--- DateTime: 2024-09-25 16:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local ObjectGCType = require("Define/ObjectGCType")
local MoogleBallCaughtState = GoldSaucerMiniGameDefine.MoogleBallCaughtState
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local MoogleActBtnActiveType = GoldSaucerMiniGameDefine.MoogleActBtnActiveType
local AudioType = GoldSaucerMiniGameDefine.AudioType
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR


local TempResultAniTotalTime = 3
local ShootingTipsBPName = "GoldSaucerGame/MooglePaw/GoldSaucer_MooglePawShootingTipsItem_UIBP"

---@class GoldSaucerMooglePawGamePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field ChallengeBegins GoldSaucerCuffchallengeBeginsItemView
---@field ImgBtnLeftNornal UFImage
---@field ImgBtnRightNornal UFImage
---@field Moogle GoldSaucerMooglePawMoogleItemView
---@field PanelMachine UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field RoundTips GoldSaucerMooglePawRoundTipsItemView
---@field StageTips GoldSaucerMooglePawStageTipsItemView
---@field TableViewBall UTableView
---@field AnimFail UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawGamePanelView = LuaClass(UIView, true)

function GoldSaucerMooglePawGamePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.ChallengeBegins = nil
	--self.ImgBtnLeftNornal = nil
	--self.ImgBtnRightNornal = nil
	--self.Moogle = nil
	--self.PanelMachine = nil
	--self.PanelMain = nil
	--self.RoundTips = nil
	--self.StageTips = nil
	--self.TableViewBall = nil
	--self.AnimFail = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawGamePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ChallengeBegins)
	self:AddSubView(self.Moogle)
	self:AddSubView(self.RoundTips)
	self:AddSubView(self.StageTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMooglePawGamePanelView:OnInit()
	self.AdapterTableViewBall = UIAdapterTableView.CreateAdapter(self, self.TableViewBall)
	self.Binders = {
		-- 球体分布
		{"BallItems", UIBinderUpdateBindableList.New(self, self.AdapterTableViewBall)},
		-- 莫古力位置更新
		{"MooglePosition", UIBinderCanvasSlotSetPosition.New(self, self.Moogle)},
		-- 操作按钮可用状态绑定
		{"bHorizontalActBtnEnable", UIBinderValueChangedCallback.New(self, nil, self.OnChangeBtnLeftInteractState)},
		{"bVerticalActBtnEnable", UIBinderValueChangedCallback.New(self, nil, self.OnChangeBtnRightInteractState)},

		-- 游戏状态变化
		{"GameState", UIBinderValueChangedCallback.New(self, nil, self.OnMiniGameStateChanged)},
		{"BallCaughtState", UIBinderValueChangedCallback.New(self, nil, self.OnBallCaughtStateChanged)},
		{"ReconnectSuccess", UIBinderValueChangedCallback.New(self, nil, self.OnReconnectSuccess)},
	}
	-- 初始化相关数据
	self.VM = self.Params and self.Params.Data
end

function GoldSaucerMooglePawGamePanelView:OnDestroy()

end

function GoldSaucerMooglePawGamePanelView:OnShow()
	-- 初始化游戏界面
	self:ControlTheActBtnShowState(MoogleActBtnActiveType.Invalid)
	self:InitGameReadyUIState()
	self:ShowTheGameReadyBP()
end

function GoldSaucerMooglePawGamePanelView:OnHide()
	self:StopAllAnimations()
	self:UnRegisterAllTimer()
	self:HideShootingTips()
end

function GoldSaucerMooglePawGamePanelView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.BtnLeft, self.OnActBtnPressed)
	UIUtil.AddOnReleasedEvent(self, self.BtnLeft, self.OnActBtnReleased)
	UIUtil.AddOnPressedEvent(self, self.BtnRight, self.OnActBtnPressed)
	UIUtil.AddOnReleasedEvent(self, self.BtnRight, self.OnActBtnReleased)
end

function GoldSaucerMooglePawGamePanelView:OnRegisterGameEvent()

end

function GoldSaucerMooglePawGamePanelView:OnRegisterBinder()
    self.VM = self.Params and self.Params.Data
    self:RegisterBinders(self.VM, self.Binders)
end

--- UI界面控制操作按钮的显示状态
function GoldSaucerMooglePawGamePanelView:ControlTheActBtnShowState(BtnActiveType)
	local GameInst = self.VM and self.VM.MiniGame
	if not GameInst then
		return
	end

	GameInst:ChangeActBtnTypeActive(BtnActiveType)
end

-- 准备阶段UI状态初始化
function GoldSaucerMooglePawGamePanelView:InitGameReadyUIState()
	self:InitMoogleEffectState()
	UIUtil.SetIsVisible(self.TableViewBall, false)
	UIUtil.SetIsVisible(self.StageTips, false)
	UIUtil.SetIsVisible(self.RoundTips, false)
	UIUtil.SetIsVisible(self.Moogle, false)
	UIUtil.SetIsVisible(self.ChallengeBegins, false)
	self:HideShootingTips()
end

--- 进行游戏的准备开始阶段
function GoldSaucerMooglePawGamePanelView:ShowTheGameReadyBP()
	local AnimIn = self.AnimIn
	if not AnimIn then
		return
	end
	GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleMachineShow)
	local AnimInEndTime = AnimIn:GetEndTime() or 0

	self:RegisterTimer(function()
		local ChallengeBegins = self.ChallengeBegins
		if not ChallengeBegins then
			return
		end
		UIUtil.SetIsVisible(ChallengeBegins, true)
		ChallengeBegins:SetPrepare(function()
			ChallengeBegins:SetBegin(function()
				self:InitGameStartUIState()
			end)
			GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleMachineStartTitle)
		end)
		GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType.MoogleMachineReadyTitle)
	end, AnimInEndTime + 0.5)
end

function GoldSaucerMooglePawGamePanelView:OnActBtnPressed()
	local GameInst = self.VM and self.VM.MiniGame
	if not GameInst then
		return
	end
	GameInst:OnActBtnPressDown()
end

function GoldSaucerMooglePawGamePanelView:OnActBtnReleased()
	local GameInst = self.VM and self.VM.MiniGame
	if not GameInst then
		return
	end
	GameInst:OnActBtnPressUp()
end

function GoldSaucerMooglePawGamePanelView:OnChangeBtnLeftInteractState(bHorizontalActBtnEnable)
	local BtnLeft = self.BtnLeft
	if not BtnLeft then
		FLOG_ERROR("GoldSaucerMooglePawGamePanelView:OnChangeBtnLeftInteractState BP is Invalid")
		return
	end
	UIUtil.SetIsVisible(self.ImgBtnLeftNornal, bHorizontalActBtnEnable)
	UIUtil.SetIsVisible(BtnLeft, true, bHorizontalActBtnEnable)
	FLOG_INFO("GoldSaucerMooglePawGamePanelView:OnChangeBtnLeftInteractState Enable State Changed")
end

function GoldSaucerMooglePawGamePanelView:OnChangeBtnRightInteractState(bVerticalActBtnEnable)
	local BtnRight = self.BtnRight
	if not BtnRight then
		FLOG_ERROR("GoldSaucerMooglePawGamePanelView:OnChangeBtnRightInteractState BP is Invalid")
		return
	end
	UIUtil.SetIsVisible(self.ImgBtnRightNornal, bVerticalActBtnEnable)
	UIUtil.SetIsVisible(BtnRight, true, bVerticalActBtnEnable)
	FLOG_INFO("GoldSaucerMooglePawGamePanelView:OnChangeBtnRightInteractState Enable State Changed")
end

function GoldSaucerMooglePawGamePanelView:OnMiniGameStateChanged(NewValue, OldValue)
    if OldValue == MiniGameStageType.Update and NewValue == MiniGameStageType.End then
		self:UpdateEndStateInfo()
	elseif OldValue == MiniGameStageType.End and NewValue == MiniGameStageType.Restart then
        self:UpdateRestartInfo()
	end
end

function GoldSaucerMooglePawGamePanelView:UpdateEndStateInfo()
	if self.VM == nil then
		return
	end
	-- 还原莫古力位置
	local MoogleInitPos = GoldSaucerMiniGameDefine.MoogleInitPos
	self.VM.MooglePosition:SetValue(MoogleInitPos.X, MoogleInitPos.Y)
	self:InitMoogleEffectState()
	self:SetVisible(false)
	-- 清一遍控件
	self.VM:ClearBall()
end


function GoldSaucerMooglePawGamePanelView:ShowShootingTips(CaughtResult)
	if self.ShootingTips then
		return
	end
	self.ShootingTips = _G.UIViewMgr:CreateViewByName(ShootingTipsBPName, ObjectGCType.NoCache, self, true, true, nil)
	if self.ShootingTips == nil then
		return
	end
	self.PanelMain:AddChildToCanvas(self.ShootingTips)
	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0.5, 0)
	Anchor.Maximum = _G.UE.FVector2D(0.5, 0)
	local Alignment = _G.UE.FVector2D(0.5, 0)
	local Size = _G.UE.FVector2D(100, 30)
	local Position = _G.UE.FVector2D(0, 84)
	UIUtil.CanvasSlotSetAnchors(self.ShootingTips, Anchor)
	UIUtil.CanvasSlotSetAlignment(self.ShootingTips, Alignment)
	UIUtil.CanvasSlotSetSize(self.ShootingTips, Size)
	UIUtil.CanvasSlotSetPosition(self.ShootingTips, Position)
	UIUtil.CanvasSlotSetAutoSize(self.ShootingTips, true)
	_G.UIViewMgr:ShowSubView(self.ShootingTips)
	self.ShootingTips:ShowResult(CaughtResult)
end

function GoldSaucerMooglePawGamePanelView:HideShootingTips()
	if self.ShootingTips == nil then
		return
	end
	_G.UIViewMgr:HideSubView(self.ShootingTips)
	self.PanelMain:RemoveChild(self.ShootingTips)
	_G.UIViewMgr:RecycleView(self.ShootingTips)
	self.ShootingTips = nil
end

function GoldSaucerMooglePawGamePanelView:OnBallCaughtStateChanged(NewValue)
	local GameInst = self.VM and self.VM.MiniGame
	if not GameInst then
		return
	end

	if NewValue == MoogleBallCaughtState.None then
		return
	end

	GameInst:StopGameTimeLoop(true) -- 该阶段就暂停游戏循环进行表现

	local SuccessCaught = NewValue == MoogleBallCaughtState.Caught
	self:ShowShootingTips(SuccessCaught)
	self.VM:HideTheOtherBallWhenShowCatchResult()

	local MoogleWidget = self.Moogle
	if SuccessCaught then
		self:ShowRewardChange() -- 播放奖励变化
		--成功的屏幕动画
		if MoogleWidget then
			local AnimSuccess = MoogleWidget.AnimSuccess
			local MI_DX_Common_MooglePaw_4a = MoogleWidget.MI_DX_Common_MooglePaw_4a
			if AnimSuccess and MI_DX_Common_MooglePaw_4a then
				UIUtil.SetIsVisible(MI_DX_Common_MooglePaw_4a, true)
				MoogleWidget:PlayAnimation(AnimSuccess)
				MoogleWidget:ShowSuccessCatchBallResult()
			end
		end
		self:PlayAnimation(self.AnimSuccess)
	else
		--失败的屏幕动画
		if MoogleWidget then
			local AnimFail = MoogleWidget.AnimCryLoop
			if AnimFail then
				MoogleWidget:PlayAnimation(AnimFail)
			end
		end
		self:PlayAnimation(self.AnimFail)
	end

	self:RegisterTimer(function()
		MoogleWidget:ResetAnimationState()
	end, TempResultAniTotalTime - 0.05)
	self:RegisterTimer(function()
		GameInst:RecoverGameTimeLoop()
		GameInst:TriggerTheRoundEnd()
		self.VM:ResetBallShowStateWhenShowCatchResult()
	end, TempResultAniTotalTime)
end

--- 还原莫古力的特效状态
function GoldSaucerMooglePawGamePanelView:InitMoogleEffectState()
	self:PlayAnimationTimeRange(self.AnimSuccess, 0, 0.01)
	self:PlayAnimationTimeRange(self.AnimFail, 0, 0.01)
	--成功的屏幕动画初始化，失败的屏幕动画走Moogle移动状态改变
	local MoogleWidget = self.Moogle
	if MoogleWidget then
		local MI_DX_Common_MooglePaw_4a = MoogleWidget.MI_DX_Common_MooglePaw_4a
		if MI_DX_Common_MooglePaw_4a then
			UIUtil.SetIsVisible(MI_DX_Common_MooglePaw_4a, false)
		end
	end
end

--- 刷新奖励变化
function GoldSaucerMooglePawGamePanelView:ShowRewardChange()
	local MiniGameInst = self.VM and self.VM.MiniGame
	if MiniGameInst == nil then
		return
	end

	local RoundID = MiniGameInst:GetCurRoundId()
	local _, CaughtBallID = MiniGameInst:GetTheCatchBallResult()
	local RewardThisRound = MiniGameInst:GetActualRoundScore(RoundID, CaughtBallID)
	self.VM.RewardGot = RewardThisRound
end

--- 设置莫古力大小
function GoldSaucerMooglePawGamePanelView:SetTheMoogleSize()
	if self.VM == nil then
		return
	end

	self.VM:SetMoogleSizeAndCanvasOffset()
end

--- 开启游戏时间循环
function GoldSaucerMooglePawGamePanelView:StartGameRunState()
	local GameInst = self.VM and self.VM.MiniGame
	if not GameInst then
		return
	end

	GameInst:StartGameTimeLoop(GameInst.GameRun)
end

--- 初始化创建球的分布
function GoldSaucerMooglePawGamePanelView:InitBallDistribute()
	if self.VM == nil then
		return
	end

	self.VM:InitBallDistribute()
end

function GoldSaucerMooglePawGamePanelView:InitGameStartUIState(bReconnect)
	-- 准备阶段UI状态初始化
	UIUtil.SetIsVisible(self.TableViewBall, true)
	self:InitBallDistribute()
	UIUtil.SetIsVisible(self.ChallengeBegins, false)
	if not bReconnect then
		self:ControlTheActBtnShowState(MoogleActBtnActiveType.Horizontal)
		local StageTips = self.StageTips
		if not StageTips then
			return
		end
		UIUtil.SetIsVisible(StageTips, true)
	else
		--UIUtil.SetIsVisible(StageTips, true)
	end
	self:SetTheMoogleSize()
	UIUtil.SetIsVisible(self.Moogle, true)
	
	self:StartGameRunState()
end

function GoldSaucerMooglePawGamePanelView:UpdateRestartInfo()
	self:ControlTheActBtnShowState(MoogleActBtnActiveType.Invalid)
	local RoundTips = self.RoundTips
	if RoundTips then
		UIUtil.SetIsVisible(RoundTips, true)
		RoundTips:ShowRoundTips(self.VM, function()
			self:ControlTheActBtnShowState(MoogleActBtnActiveType.Horizontal)
			self:StartGameRunState()
			UIUtil.SetIsVisible(RoundTips, false)
		end)
	end
	self:SetTheMoogleSize()
	self:InitBallDistribute()
end

--- 重连成功
function GoldSaucerMooglePawGamePanelView:OnReconnectSuccess(bSuccess)
	if not bSuccess then
		return
	end

	local ViewModel = self.VM
    if ViewModel == nil then
        return
    end

	local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end
	self:InitGameReadyUIState()
	self:InitGameStartUIState(true)
	if GoldSaucerMiniGameMgr.bWaitForCatchResult then
		GoldSaucerMiniGameMgr:FindAndSendCatchBall()
	end
	
	ViewModel.ReconnectSuccess = false
end

return GoldSaucerMooglePawGamePanelView