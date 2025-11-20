---
--- Author: bowxiong
--- DateTime: 2024-09-25 16:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local GoldSaucerMiniGameMgr = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameMgr")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local ObjectGCType = require("Define/ObjectGCType")
local EventID = require("Define/EventID")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MoogleBallCaughtState = GoldSaucerMiniGameDefine.MoogleBallCaughtState
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local MoogleActBtnActiveType = GoldSaucerMiniGameDefine.MoogleActBtnActiveType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MogulBallType = ProtoRes.Game.MogulBallType
local AudioType = GoldSaucerMiniGameDefine.AudioType
local BLESSED_KIND = ProtoCS.Game.FairyBlessed.BLESSED_KIND
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR


local TempResultAniTotalTime = 3
local ShootingTipsBPName = "GoldSaucerGame/MooglePaw/GoldSaucer_MooglePawShootingTipsItem_UIBP"

---@class GoldSaucerMooglePawGamePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClickCactus UFButton
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field ChallengeBegins GoldSaucerCuffchallengeBeginsItemView
---@field EFFCaughtMove UFCanvasPanel
---@field EFFRoundBg UFCanvasPanel
---@field ImgBtnLeftNornal UFImage
---@field ImgBtnRightNornal UFImage
---@field ImgCactusPeople UFImage
---@field ImgCaughtGreen UFImage
---@field ImgCaughtNormal UFImage
---@field ImgPowerOnBg UFImage
---@field ImgSuccessNormalBG UFImage
---@field Moogle GoldSaucerMooglePawMoogleItemView
---@field PanelCactus UFCanvasPanel
---@field PanelCaughtGreen UFCanvasPanel
---@field PanelCaughtNormal UFCanvasPanel
---@field PanelMachine UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field RoundTips GoldSaucerMooglePawRoundTipsItemView
---@field SpineCactusPeople1 USpineWidget
---@field SpineCactusPeople2 USpineWidget
---@field StageTips GoldSaucerMooglePawStageTipsItemView
---@field TableViewBall UTableView
---@field TextCountDown UFTextBlock
---@field AnimClickCactus UWidgetAnimation
---@field AnimCountdownRedLight UWidgetAnimation
---@field AnimFail UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimRound0 UWidgetAnimation
---@field AnimRound3 UWidgetAnimation
---@field AnimRound4 UWidgetAnimation
---@field AnimRound4Loop UWidgetAnimation
---@field AnimSectionGreenShow UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMooglePawGamePanelView = LuaClass(UIView, true)

function GoldSaucerMooglePawGamePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClickCactus = nil
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.ChallengeBegins = nil
	--self.EFFCaughtMove = nil
	--self.EFFRoundBg = nil
	--self.ImgBtnLeftNornal = nil
	--self.ImgBtnRightNornal = nil
	--self.ImgCactusPeople = nil
	--self.ImgCaughtGreen = nil
	--self.ImgCaughtNormal = nil
	--self.ImgPowerOnBg = nil
	--self.ImgSuccessNormalBG = nil
	--self.Moogle = nil
	--self.PanelCactus = nil
	--self.PanelCaughtGreen = nil
	--self.PanelCaughtNormal = nil
	--self.PanelMachine = nil
	--self.PanelMain = nil
	--self.RoundTips = nil
	--self.SpineCactusPeople1 = nil
	--self.SpineCactusPeople2 = nil
	--self.StageTips = nil
	--self.TableViewBall = nil
	--self.TextCountDown = nil
	--self.AnimClickCactus = nil
	--self.AnimCountdownRedLight = nil
	--self.AnimFail = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimRound0 = nil
	--self.AnimRound3 = nil
	--self.AnimRound4 = nil
	--self.AnimRound4Loop = nil
	--self.AnimSectionGreenShow = nil
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
		{"TotalTimeText", UIBinderSetText.New(self, self.TextCountDown)},
		{"bKeyTime", UIBinderValueChangedCallback.New(self, nil, self.OnComeInKeyTime)},
		{"bBless", UIBinderSetIsVisible.New(self, self.PanelCactus)},
		{"TextHint", UIBinderSetText.New(self, self.StageTips.TextTips)},
	}
	-- 初始化相关数据
	self.VM = self.Params and self.Params.Data
	self.MoogleDcfg = MiniGameClientConfig[MiniGameType.MooglesPaw]
end

function GoldSaucerMooglePawGamePanelView:OnDestroy()

end

function GoldSaucerMooglePawGamePanelView:OnShow()
	-- 初始化游戏界面
	self:ControlTheActBtnShowState(MoogleActBtnActiveType.Invalid)
	self:InitGameReadyUIState()
	self:ShowTheGameReadyBP()

	-- 赐福仙人掌动画种类切换
	local GameInst = self.VM and self.VM.MiniGame
	if not GameInst then
		return
	end

	local bBigBlessMode = GameInst:IsBigBlessMode()
	UIUtil.SetIsVisible(self.SpineCactusPeople1, not bBigBlessMode)
	UIUtil.SetIsVisible(self.SpineCactusPeople2, bBigBlessMode)
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
	UIUtil.AddOnClickedEvent(self, self.BtnClickCactus, self.OnBtnClickCactus)
end

function GoldSaucerMooglePawGamePanelView:OnRegisterGameEvent()

end

function GoldSaucerMooglePawGamePanelView:OnRegisterBinder()
    self.VM = self.Params and self.Params.Data
    self:RegisterBinders(self.VM, self.Binders)
end

function GoldSaucerMooglePawGamePanelView:OnBtnClickCactus()
	self:PlayAnimation(self.AnimClickCactus)
end

--- 玩家游玩时间减少
function GoldSaucerMooglePawGamePanelView:OnComeInKeyTime(bInKeyTime)
	if bInKeyTime then
		self:PlayAnimation(self.AnimCountdownRedLight, 0, 0, nil, 1.0)
	else
		self:PlayAnimation(self.AnimCountdownRedLight, 0.67) -- 动画单次时长
	end
	FLOG_INFO("GoldSaucerMooglePawGamePanelView:OnComeInKeyTime bInKeyTime %s", bInKeyTime)
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
	self:PlayAnimation(self.AnimSectionGreenShow, 0.2, 1, _G.UE.EUMGSequencePlayMode.Reverse)
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
	elseif OldValue == MiniGameStageType.End and NewValue == MiniGameStageType.ExtraRound then
		self:EnterTheExtraRoundReadyStep()
	elseif OldValue == MiniGameStageType.ExtraRound and NewValue == MiniGameStageType.ExtraRoundStart then
		self:EnterTheExtraRoundStartStep()
	end
end

function GoldSaucerMooglePawGamePanelView:UpdateEndStateInfo()
	if self.VM == nil then
		return
	end
	--self:ResetMoogle()
	--self:SetVisible(false)
	-- 清一遍控件
	--self.VM:ClearBall()
end

function GoldSaucerMooglePawGamePanelView:ResetMoogle()
	-- 还原莫古力
	local MoogleInitPos = GoldSaucerMiniGameDefine.MoogleInitPos
	self.VM.MooglePosition:SetValue(MoogleInitPos.X, MoogleInitPos.Y)
	self:InitMoogleEffectState()
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
	
	local BallType = GameInst.CatchBallType
	UIUtil.SetIsVisible(self.PanelCaughtNormal, BallType ~= MogulBallType.MogulBallTypeStar)
	UIUtil.SetIsVisible(self.PanelCaughtGreen, BallType == MogulBallType.MogulBallTypeStar)
	--GameInst:StopGameTimeLoop(true) -- 该阶段就暂停游戏循环进行表现

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
		--GameInst:RecoverGameTimeLoop()
		GameInst:PushGameProcessAfterCatchResultShow()
		local BlessResetMoogleMinTimeSeconds = 1 -- 赐福模式重置莫古位置的最小时间限制
		if GameInst:IsBless() and GameInst:GetRemainSeconds() > BlessResetMoogleMinTimeSeconds then
			self:ResetMoogle()
			self:ControlTheActBtnShowState(MoogleActBtnActiveType.Horizontal)
		end
		--self.VM:ResetBallShowStateWhenShowCatchResult()
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

	local RoundIndex = MiniGameInst:GetRoundIndex()
	self.VM.RewardGot = MiniGameInst:GetRoundScoreByIndex(RoundIndex)
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

--- 切换游戏面板背景图
function GoldSaucerMooglePawGamePanelView:ChangeTheGamePanelBg()
	local ViewModel = self.VM
    if ViewModel == nil then
        return
    end

    local MiniGameInst = ViewModel.MiniGame
    if MiniGameInst == nil then
        return
    end
	--- 设定背景特效
	local RoundIndex = MiniGameInst:GetRoundIndex() + 1 or 1

	local MoogleDcfg = self.MoogleDcfg
	if MoogleDcfg then
		local BgPath = MoogleDcfg.PanelBgPath
		if BgPath then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgPowerOnBg, BgPath[RoundIndex])
		end
	end
	if self:IsAnimationPlaying(self.AnimRound4Loop) then
		self:StopAnimation(self.AnimRound4Loop)
	end
	if RoundIndex == 1 then
		self:PlayAnimation(self.AnimRound0)
	elseif RoundIndex == 3 then
		self:PlayAnimation(self.AnimRound3)
	elseif RoundIndex == 4 then
		self:PlayAnimation(self.AnimRound4)
		self:PlayAnimation(self.AnimRound4Loop, 0, 0)
	end
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

	self:ControlTheActBtnShowState(MoogleActBtnActiveType.Horizontal)
	self:StartGameRunState()
	self:ChangeTheGamePanelBg()
end

function GoldSaucerMooglePawGamePanelView:UpdateRestartInfo()
	self:ControlTheActBtnShowState(MoogleActBtnActiveType.Invalid)
	self:ResetMoogle()
	self:ShowGoldSauserCommRoundTips()
	self:SetTheMoogleSize()
	self:InitBallDistribute()
	self:ChangeTheGamePanelBg()
end

--- 进行大赐福的额外回合的准备开始阶段
function GoldSaucerMooglePawGamePanelView:ShowTheBlessExtraRoundReadyBP()
	local ChallengeBegins = self.ChallengeBegins
	if not ChallengeBegins then
		return
	end
	UIUtil.SetIsVisible(ChallengeBegins, true)
	ChallengeBegins:SetBlessRoundReady(function()
		local MiniGameInst = self.VM and self.VM.MiniGame
		if MiniGameInst == nil then
			return
		end
		_G.EventMgr:SendEvent(EventID.DetailMiniGameRestart, {Type = MiniGameInst.MiniGameType or MiniGameType.OutOnALimb, bRestart = true}) --与服务器约定由翻倍协议获取额外轮的球体数据
	end)
end

--- 显示大赐福额外回合进入动效
function GoldSaucerMooglePawGamePanelView:EnterTheExtraRoundReadyStep()
	self:PlayAnimation(self.AnimSectionGreenShow)
	self:InitMoogleEffectState()
	self:ShowTheBlessExtraRoundReadyBP()
end

--- 正式开始额外回合
function GoldSaucerMooglePawGamePanelView:EnterTheExtraRoundStartStep()
	UIUtil.SetIsVisible(self.TableViewBall, true)
	self:InitBallDistribute()
	UIUtil.SetIsVisible(self.ChallengeBegins, false)
	self:ControlTheActBtnShowState(MoogleActBtnActiveType.Horizontal)
	self:SetTheMoogleSize()
	UIUtil.SetIsVisible(self.Moogle, true)
	self:StartGameRunState()
end

--- 显示通用回合提示
function GoldSaucerMooglePawGamePanelView:ShowGoldSauserCommRoundTips()
	local RoundTips = self.RoundTips
	if RoundTips then
		UIUtil.SetIsVisible(RoundTips, true)
		RoundTips:ShowRoundTips(self.VM, function()
			self:ControlTheActBtnShowState(MoogleActBtnActiveType.Horizontal)
			self:StartGameRunState()
			UIUtil.SetIsVisible(RoundTips, false)
		end)
	end
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