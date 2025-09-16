---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS =  require("Protocol/ProtoCS")
local MiniGameType = ProtoCS.MiniGameType
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSauserMainPanelBaseItemView = require("Game/GoldSauserMainPanel/View/Item/GoldSauserMainPanelBaseItemView")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
--local GoldSaucerAirplaneGameCfg = require("TableCfg/GoldSaucerAirplaneGameCfg")
--local MsgTipsUtil = require("Utils/MsgTipsUtil")
local AirplaneTailType = GoldSauserMainPanelDefine.AirplaneTailType
local AirplaneEndSpeed = GoldSauserMainPanelDefine.AirplaneEndSpeed
local AudioType = GoldSauserMainPanelDefine.AudioType
local FVector2D = _G.UE.FVector2D
local FLOG_INFO = _G.FLOG_INFO
local UpdateTimeInterval = 0.5

---@class GoldSauserMainPanelMainPanelAirplaneGameItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field MI_DX_Circle_MonthCard_1 UFImage
---@field MI_DX_Common_GoldSaucerMain_10 UFImage
---@field MI_DX_Common_GoldSaucerMain_13 UFImage
---@field MI_DX_Common_GoldSaucerMain_9 UFImage
---@field MI_DX_Sequence_GoldSaucerMain_3 UFImage
---@field MI_DX_Sequence_GoldSaucerMain_4 UFImage
---@field MI_DX_Sequence_GoldSaucerMain_5 UFImage
---@field MI_DX_Sequence_GoldSaucerMain_6 UFImage
---@field PanelAirplane UFCanvasPanel
---@field PanelRange UFCanvasPanel
---@field PanelSuccess UFCanvasPanel
---@field RoundSquare GoldSauserMainPanelRoundSquareItemView
---@field T_DX_UI_GoldSaucerMain_3 UFImage
---@field T_Icon_GoldSaucerMain_1 UFImage
---@field T_Icon_GoldSaucerMain_2 UFImage
---@field AnimCrash UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLine1 UWidgetAnimation
---@field AnimLine2 UWidgetAnimation
---@field AnimLine3 UWidgetAnimation
---@field AnimLine4 UWidgetAnimation
---@field AnimLoop1 UWidgetAnimation
---@field AnimQTE UWidgetAnimation
---@field AnimQTESuccess UWidgetAnimation
---@field AnimSpeedup UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelMainPanelAirplaneGameItemView = LuaClass(GoldSauserMainPanelBaseItemView, true)


function GoldSauserMainPanelMainPanelAirplaneGameItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.MI_DX_Circle_MonthCard_1 = nil
	--self.MI_DX_Common_GoldSaucerMain_10 = nil
	--self.MI_DX_Common_GoldSaucerMain_13 = nil
	--self.MI_DX_Common_GoldSaucerMain_9 = nil
	--self.MI_DX_Sequence_GoldSaucerMain_3 = nil
	--self.MI_DX_Sequence_GoldSaucerMain_4 = nil
	--self.MI_DX_Sequence_GoldSaucerMain_5 = nil
	--self.MI_DX_Sequence_GoldSaucerMain_6 = nil
	--self.PanelAirplane = nil
	--self.PanelRange = nil
	--self.PanelSuccess = nil
	--self.RoundSquare = nil
	--self.T_DX_UI_GoldSaucerMain_3 = nil
	--self.T_Icon_GoldSaucerMain_1 = nil
	--self.T_Icon_GoldSaucerMain_2 = nil
	--self.AnimCrash = nil
	--self.AnimIn = nil
	--self.AnimLine1 = nil
	--self.AnimLine2 = nil
	--self.AnimLine3 = nil
	--self.AnimLine4 = nil
	--self.AnimLoop1 = nil
	--self.AnimQTE = nil
	--self.AnimQTESuccess = nil
	--self.AnimSpeedup = nil
	--self.AnimSuccess = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RoundSquare)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnInit()
	self.Binders = {
		{ "IsGameStart", UIBinderValueChangedCallback.New(self, nil, self.OnIsGameStartChanged)},
	}

	-- 空军装甲小游戏相关内容
	self.AnimListsIsPlaying = nil -- 正在播出的所有动画
	self.ViewGameStart = false -- 界面游戏是否开始
	self.CurRound = 1 -- 当前游戏的轮数 
	self.QTEIntervalSecondCount = 0 -- QTE间隔的秒数计数
	self.QTEJudgeProcessing = false -- QTE判断过程中，不再接受点击
	self.AnimLineChoose = nil -- 本次小游戏使用路线
	self.QTEFailureOutTimeTimer = nil -- 单次QTE超时失败判定计时器
	self.SuccessContinueFly = false -- 游戏成功继续飞行
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnDestroy()

end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnShow()
	
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnHide()
	self:SetGameEnd(false, true)
	UIUtil.SetIsVisible(self.PanelAirplane, false)
	self.ItemVM:SetIsGameStart(false)
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.RoundSquare.BtnRoundSquare, self.OnBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnMiniGameQTEClicked)
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnRegisterGameEvent()
   
end

------ 空军装甲小游戏相关内容 ------

--- 小游戏启动统一UI监听事件
function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnMiniGameBtnClicked()
	local ViewGameStart = self.ViewGameStart
	if not ViewGameStart then
		self:LaunchTheGame()
		self.ViewGameStart = true
		GoldSauserMainPanelMgr:SetIsInPanelMiniGame(true)
	end
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnMiniGameQTEClicked()
	local ViewGameStart = self.ViewGameStart
	if not ViewGameStart then
		self:LaunchTheGame()
		self.ViewGameStart = true
		GoldSauserMainPanelMgr:SetIsInPanelMiniGame(true)
	else
		if not self:IsInQTEProcess() then
			return
		end

		if self.QTEJudgeProcessing then
			return
		end

		self:ClickToJudgeQTEResult()
	end
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnIsGameStartChanged(IsGameStart)
	if IsGameStart then
		self:SetGameStart()
	else
		UIUtil.SetIsVisible(self.PanelAirplane, false)
		GoldSauserMainPanelMgr:PlayAudio(AudioType.FlyJetStop)
		self.ViewGameStart = false
		GoldSauserMainPanelMgr:SetIsInPanelMiniGame(false)
	end
end

---- 实现多个在播动画停止逻辑，保证飞机动画正常 ----
function GoldSauserMainPanelMainPanelAirplaneGameItemView:AddAnimPlaying(Anim)
	local AnimListPlaying = self.AnimListsIsPlaying or {}
	if not AnimListPlaying[Anim] then
		AnimListPlaying[Anim] = true
	end
	self.AnimListsIsPlaying = AnimListPlaying
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:RemoveAnimPlaying(Anim)
	local AnimListPlaying = self.AnimListsIsPlaying
	if not AnimListPlaying or not next(AnimListPlaying) then
		return
	end
	
	AnimListPlaying[Anim] = nil
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:StopTheAnimPlaying()
	local AnimListPlaying = self.AnimListsIsPlaying or {}
	if not AnimListPlaying or not next(AnimListPlaying) then
		return
	end
	for Anim, _ in pairs(AnimListPlaying) do
		if Anim and self:IsAnimationPlaying(Anim) then
			self:StopAnimation(Anim)
		end
	end
	self.AnimListsIsPlaying = {}
	GoldSauserMainPanelMgr:PlayAudio(AudioType.FlyJetStop)
end

---- 实现多个在播动画停止逻辑，保证飞机动画正常 end ----

function GoldSauserMainPanelMainPanelAirplaneGameItemView:SetGameStart()
	UIUtil.SetIsVisible(self.PanelAirplane, true)
	UIUtil.SetIsVisible(self.T_Icon_GoldSaucerMain_2, false)
	self:SetTailImgVisibleByTailType(AirplaneTailType.SlowSmoke)
	self:TurnTheBtnSize(true)
	self:PlayAnimation(self.AnimLoop1, 0, 0, nil, 1, true)
	GoldSauserMainPanelMgr:PlayAudio(AudioType.FlyJetStart)
	self:AddAnimPlaying(self.AnimLoop1)
	self.ViewGameStart = false
	self.AnimLineChoose = nil
	self.QTEJudgeProcessing = false
	self.QTEFailureOutTimeTimer = nil
	self.CurRound = 1
	self.SuccessContinueFly = false
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:AnimLineToEndAndPlaySuccessAnim()
	--[[local Round = self.CurRound or 1
	local AirplaneCfg = self:GetRoundTableCfg(Round)
	if not AirplaneCfg then
		return
	end--]]
	local AnimLine = self.AnimLineChoose
	if not AnimLine then
		return
	end
	local NextOneAnimLineStartTime = self:PauseAnimation(AnimLine)
	self:PlayAnimation(AnimLine, NextOneAnimLineStartTime, 1, nil, AirplaneEndSpeed)--AirplaneCfg.AirplaneSpeed
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:SetGameEnd(bSuccess, bNotAnim)
	self:StopTheAnimPlaying()
	self:SetTheQTERangePanelVisibility(false)
	self:TurnTheBtnSize(false)
	self.SuccessContinueFly = bSuccess
	if bSuccess then
		if not bNotAnim then
			UIUtil.SetIsVisible(self.T_Icon_GoldSaucerMain_2, true)
			--self:PlayAnimation(self.AnimLittleHeart)
			self:AnimLineToEndAndPlaySuccessAnim()
			
		end
		GoldSauserMainPanelMgr:SendGoldSauserMainGameFinishedNumMsg(MiniGameType.MiniGameTypeAirForceOne)
	else
		if not bNotAnim then
			local AnimLineChoose = self.AnimLineChoose
			if AnimLineChoose then
				self:PauseAnimation(self.AnimLineChoose)
			end
			self:PlayAnimation(self.AnimCrash, 0, 1, nil, 1, true)
		end
	end
	GoldSauserMainPanelMgr:SendTlogMsgForGameResult(MiniGameType.MiniGameTypeAirForceOne, bSuccess)
	self.AnimListsIsPlaying = nil
	self.QTEFailureOutTimeTimer = nil
	self:UnRegisterAllTimer()
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:GetRoundTableCfg(Round)
	local EntranceVM = self.ItemVM
	if not EntranceVM then
		return
	end
	return EntranceVM:GetRoundTableCfg(Round)
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:SetTheQTEParam(Cfg)
	-- 初始化QTE参数
	local QTERangeOut = Cfg.QTERangeOut or 0
	self.MI_DX_Common_GoldSaucerMain_13:SetRenderScale(FVector2D(QTERangeOut, QTERangeOut))
	local QTERangeIn = Cfg.QTERangeIn or 0
	self.MI_DX_Common_GoldSaucerMain_10:SetRenderScale(FVector2D(QTERangeIn * -1, QTERangeIn))
	UIUtil.ImageSetMaterialScalarParameterValue(self.MI_DX_Circle_MonthCard_1, "U_Tiling", QTERangeOut)
	UIUtil.ImageSetMaterialScalarParameterValue(self.MI_DX_Circle_MonthCard_1, "V_Tiling", QTERangeOut)
	UIUtil.ImageSetMaterialScalarParameterValue(self.MI_DX_Circle_MonthCard_1, "Mask_UTile", QTERangeIn)
	UIUtil.ImageSetMaterialScalarParameterValue(self.MI_DX_Circle_MonthCard_1, "Mask_VTile", QTERangeIn)
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:SetTheQTERangePanelVisibility(bVisible)
	UIUtil.SetIsVisible(self.PanelRange, bVisible)
	UIUtil.SetIsVisible(self.MI_DX_Common_GoldSaucerMain_9, bVisible)
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:SetTailImgVisibleByTailType(TailType)
	if not TailType then
		return
	end

	local bPrimarySpeed = TailType == AirplaneTailType.SlowSmoke
	UIUtil.SetIsVisible(self.MI_DX_Sequence_GoldSaucerMain_3, bPrimarySpeed)
	UIUtil.SetRenderOpacity(self.MI_DX_Sequence_GoldSaucerMain_3, bPrimarySpeed and 1 or 0)
	local bMiddleSpeed = TailType == AirplaneTailType.QuickSmoke
	UIUtil.SetIsVisible(self.MI_DX_Sequence_GoldSaucerMain_6, bMiddleSpeed)
	UIUtil.SetRenderOpacity(self.MI_DX_Sequence_GoldSaucerMain_6, bMiddleSpeed and 1 or 0)
	local bHighSpeed = TailType == AirplaneTailType.Fire
	UIUtil.SetIsVisible(self.MI_DX_Sequence_GoldSaucerMain_5, bHighSpeed)
	UIUtil.SetRenderOpacity(self.MI_DX_Sequence_GoldSaucerMain_5, bHighSpeed and 1 or 0)
end


--- 进入小游戏关卡的下一个阶段
function GoldSauserMainPanelMainPanelAirplaneGameItemView:EnterTheLevelNextRound()
	local CurRound = self.CurRound or 1
	local NextRound = CurRound + 1
	local AirplaneCfg = self:GetRoundTableCfg(NextRound)
	if not AirplaneCfg then
		return
	end

	local RoundAnimSpeed = AirplaneCfg.AirplaneSpeed or 1
	self:SetPlaybackSpeed(self.AnimLineChoose, RoundAnimSpeed)
	self.CurRound = NextRound
	--self:SetTailImgVisibleByAirplaneState()
	self.QTEIntervalSecondCount = 0
	self:SetTheQTEParam(AirplaneCfg)
	self.QTEJudgeProcessing = false
end

--- QTE判定成功后加速动画与循环动画切换表现
function GoldSauserMainPanelMainPanelAirplaneGameItemView:QTESuccessAnimShow(Round, Callback)
	self:SetTheQTERangePanelVisibility(false)
	self:UnRegisterTimer(self.QTEFailureOutTimeTimer)
	self.QTEFailureOutTimeTimer = nil
	self:PlayAnimation(self.AnimQTESuccess)
	local AirplaneCfg = self:GetRoundTableCfg(Round)
	if not AirplaneCfg then
		return
	end
	local RoundAnimSpeed = AirplaneCfg.AirplaneSpeed or 1

	-- 加速动画与Loop动画切换
	local AnimSpeedup = self.AnimSpeedup
	self:SetTailImgVisibleByTailType(AirplaneTailType.QuickSmoke)
	self:PlayAnimation(AnimSpeedup)
	GoldSauserMainPanelMgr:PlayAudio(AudioType.FlyJetAcc)
	self:StopAnimation(self.AnimLoop1)
	GoldSauserMainPanelMgr:PlayAudio(AudioType.FlyJetStop)
	local SpeedUpEndTime = AnimSpeedup:GetEndTime()
	self:RegisterTimer(function()
		self:SetTailImgVisibleByTailType(AirplaneTailType.SlowSmoke)
		GoldSauserMainPanelMgr:PlayAudio(AudioType.FlyJetStart)
		self:PlayAnimation(self.AnimLoop1, 0, 0, nil, RoundAnimSpeed, true)
		if Callback then
			Callback()
		end
	end, SpeedUpEndTime)
end

---@deprecated
function GoldSauserMainPanelMainPanelAirplaneGameItemView:SetTailImgVisibleByAirplaneState()
	local Round = self.CurRound or 1
	local AirplaneCfg = self:GetRoundTableCfg(Round)
	if not AirplaneCfg then
		return
	end

	local AirplaneState = AirplaneCfg.AirplaneState or 1

	local bPrimarySpeed = AirplaneState == 2
	UIUtil.SetIsVisible(self.MI_DX_Sequence_GoldSaucerMain_3, bPrimarySpeed)
	UIUtil.SetRenderOpacity(self.MI_DX_Sequence_GoldSaucerMain_3, bPrimarySpeed and 1 or 0)
	local bMiddleSpeed = AirplaneState == 3
	UIUtil.SetIsVisible(self.MI_DX_Sequence_GoldSaucerMain_6, bMiddleSpeed)
	UIUtil.SetRenderOpacity(self.MI_DX_Sequence_GoldSaucerMain_6, bMiddleSpeed and 1 or 0)
	local bHighSpeed = AirplaneState == 4
	UIUtil.SetIsVisible(self.MI_DX_Sequence_GoldSaucerMain_5, bHighSpeed)
	UIUtil.SetRenderOpacity(self.MI_DX_Sequence_GoldSaucerMain_5, bHighSpeed and 1 or 0)
end

--- 开始游戏流程
function GoldSauserMainPanelMainPanelAirplaneGameItemView:LaunchTheGame()
	self.CurRound = 1
	local AirplaneCfg = self:GetRoundTableCfg(1)
	if not AirplaneCfg then
		return
	end

	self:SetTheQTEParam(AirplaneCfg)
	-- 选择飞行路线
	local AnimLine = AirplaneCfg.AnimLine or 1
	local AirplaneSpeed = AirplaneCfg.AirplaneSpeed or 1
	local AnimName = string.format("AnimLine%s", AnimLine)
	local AnimLineToPlay = self[AnimName]
	if AnimLineToPlay then
		--self:StopTheAnimPlaying() 路线动画不去除Loop动画
		self:PlayAnimation(AnimLineToPlay, 0, 0, nil, AirplaneSpeed)
		--self:AddAnimPlaying(AnimLineToPlay) 路线动画不参与到动画管理中，自己单独处理
		self.AnimLineChoose = AnimLineToPlay
	end
	--self:SetTailImgVisibleByAirplaneState()
	
	-- 启动QTE计时器
	self.QTEIntervalSecondCount = 0
	self.QTEIntervalCD = AirplaneCfg.QTEInterval or 0
	self:RegisterTimer(self.OnProcessUpdate, 0, UpdateTimeInterval, 0)
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:IsInQTEProcess()
	return self:IsAnimationPlaying(self.AnimQTE)
end

--- 是否有下一阶段
function GoldSauserMainPanelMainPanelAirplaneGameItemView:IsHaveNextRound()
	local Round = self.CurRound or 1
	local AirplaneCfg = self:GetRoundTableCfg(Round + 1)
	return AirplaneCfg ~= nil
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:StartTheQTE(Cfg)
	local AnimQTE = self.AnimQTE
	if not AnimQTE then
		return
	end

	if not Cfg then
		return
	end

	self:SetTheQTERangePanelVisibility(true)
	local QTEAnimSpeed = Cfg.QTEAnimSpeed or 1
	local QTEAnimStartTime = -0.97
	self:PlayAnimation(AnimQTE, QTEAnimStartTime, 1, nil, QTEAnimSpeed, true)
	GoldSauserMainPanelMgr:PlayAudio(AudioType.QTECircle)
	self:AddAnimPlaying(AnimQTE)

	--- QTE未点击判定失败
	local QTEAnimBaseTime = 4
	local QTEFailCostTime = QTEAnimBaseTime / QTEAnimSpeed
	self.QTEFailureOutTimeTimer = self:RegisterTimer(function()
		self:SetGameEnd(false)
	end, QTEFailCostTime)

	local AnimLine = self.AnimLineChoose
	if AnimLine then
		local AirplaneSpeedInQTE = Cfg.AirplaneSpeedInQTE or 1
		self:SetPlaybackSpeed(AnimLine, AirplaneSpeedInQTE)
	end
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:ClickToJudgeQTEResult()
	self.QTEJudgeProcessing = true
	local MoveCircle = self.MI_DX_Common_GoldSaucerMain_9
	if not MoveCircle then
		return
	end

	local Round = self.CurRound or 1
	local AirplaneCfg = self:GetRoundTableCfg(Round)
	if not AirplaneCfg then
		return
	end

	local RenderTransform = MoveCircle.RenderTransform
	if not RenderTransform then
		return
	end

	local Scale = RenderTransform.Scale or FVector2D(0, 0)
	local ScaleY = Scale.Y or 0

	FLOG_INFO("GoldSauserMainPanelMainPanelAirplaneGameItemView:ClickToJudgeQTEResult: CircleRadius:%s, MinRadius:%s, MaxRadius:%s", 
		ScaleY, AirplaneCfg.QTERangeIn, AirplaneCfg.QTERangeOut)

	if ScaleY >= AirplaneCfg.QTERangeIn and ScaleY <= AirplaneCfg.QTERangeOut then
		if self:IsHaveNextRound() then
			self:QTESuccessAnimShow(Round + 1, function()
				self:EnterTheLevelNextRound()
			end)
		else
			self:QTESuccessAnimShow(Round, function()
				self:SetGameEnd(true)
			end)
		end
	else
		self:SetGameEnd(false)
	end
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnProcessUpdate()
	local Round = self.CurRound or 1
	local AirplaneCfg = self:GetRoundTableCfg(Round)
	if not AirplaneCfg then
		return
	end

	-- 飞行表现判定
	--[[local SuccessContinueFly = self.SuccessContinueFly
	local AnimLineChoose = self.AnimLineChoose
	if AnimLineChoose then
		if SuccessContinueFly and self:GetAnimationCurrentTime(AnimLineChoose) <= 0.1 then
			self:StopAnimation(AnimLineChoose)
			self:PlayAnimation(self.AnimSuccess, 0, 1, nil, 1, true)
		end
	end--]]

	-- QTE触发判定
	if self:IsInQTEProcess() then
		return
	end

	local QTEIntervalSecondCount = self.QTEIntervalSecondCount
	if QTEIntervalSecondCount >= AirplaneCfg.QTEInterval then
		self:StartTheQTE(AirplaneCfg)
		return
	end

	self.QTEIntervalSecondCount = QTEIntervalSecondCount + UpdateTimeInterval
end

--- 改变Btn大小
function GoldSauserMainPanelMainPanelAirplaneGameItemView:TurnTheBtnSize(bLarger)
	local BtnWidget = self.Btn
	if not BtnWidget then
		return
	end
	local Offset = bLarger and -30 or 0
	local Margin = _G.UE.FMargin()
	Margin.Left = Offset
	Margin.Top = Offset
	Margin.Right = Offset
	Margin.Bottom = Offset
	UIUtil.CanvasSlotSetOffsets(BtnWidget, Margin)
end

------ 空军装甲小游戏相关内容 end ------

function GoldSauserMainPanelMainPanelAirplaneGameItemView:GetTheSelectedPanel()
	return self.RoundSquare.PanelFocus
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:GetTheHighlightPanel()
	return self.RoundSquare.PanelTobeViewed
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:GetTheRedDotWidget()
	return self.RoundSquare.RedDot
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:GetTheAnimClick()
	return self.RoundSquare.AnimClick
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:GetTheAnimOwner()
	return self.RoundSquare
end

function GoldSauserMainPanelMainPanelAirplaneGameItemView:OnAnimationFinished(Anim)
	if Anim == self.AnimCrash or Anim == self.AnimSuccess then
		local AnimLine = self.AnimLineChoose
		if AnimLine then
			self:StopAnimation(AnimLine)
		end
		local EntranceVM = self.ItemVM
		if EntranceVM then
			EntranceVM:SetIsGameStart(false)
		end
	else
		local AnimLine = self.AnimLineChoose
		if Anim == AnimLine and self.SuccessContinueFly then
			self:SetTailImgVisibleByTailType(AirplaneTailType.Fire)
			self:PlayAnimation(self.AnimSuccess, 0, 1, nil, 1, true)
			GoldSauserMainPanelMainVM.MiniGameSuccess = true
			GoldSauserMainPanelMainVM.MiniGameAirplaneSuccess = true
			self.SuccessContinueFly = false
		end
	end
	self:RemoveAnimPlaying(Anim)
end


return GoldSauserMainPanelMainPanelAirplaneGameItemView