---
--- Author: Alex
--- DateTime: 2025-07-22 15:35
--- Description:保镖小游戏主界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MathUtil = require("Utils/MathUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local AudioUtil = require("Utils/AudioUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local GoldSaucerMinigameCfg = require("TableCfg/GoldSaucerMinigameCfg")
local GoldSaucerBodyguardSampleCfg = require("TableCfg/GoldSaucerBodyguardSampleCfg")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")

local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local ObjectGCType = require("Define/ObjectGCType")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local UWidgetBlueprintLibrary = _G.UE.UWidgetBlueprintLibrary
local UKismetInputLibrary = _G.UE.UKismetInputLibrary
local EnterEndTime = 5 -- 入场动画完成时间（秒）
--local RememberEnterEndTime = 1
local FVector2D = _G.UE.FVector2D
local MathLibrary = _G.UE.UKismetMathLibrary
local FLOG_INFO = _G.FLOG_INFO

local TraceMarkDefaultSizeY = 30 -- 显示轨迹划痕固定宽度为30
local TracePosTolerance = 0.5 -- 划动检测误差距离

--- 划动判定结果枚举
local CutJudgeRltType = {
	["Invalid"] = 1,
	["Success"] = 2,
    ["Fail"] = 3
}

local AudioPathCutWrong = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Minigame/Kanzhuzi/Play_kanzhuzi_shibai.Play_kanzhuzi_shibai'"

---@class GoldSauserMainBodyguardMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBackBtn CommBackBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field FCanvasPanel_249 UFCanvasPanel
---@field HorizontalTime UFHorizontalBox
---@field HorizontalTime_1 UFHorizontalBox
---@field ImgBGLong UFImage
---@field ImgBGShort UFImage
---@field ImgGreenTipsLine UFImage
---@field ImgShowFrame UFImage
---@field PanelBamboo UFCanvasPanel
---@field PanelBodyguard UFCanvasPanel
---@field PanelJudgeCut UFCanvasPanel
---@field PanelRememberTrace UFCanvasPanel
---@field PanelStage UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelTipsGreen UFCanvasPanel
---@field PanelTipsGreen_1 UFCanvasPanel
---@field PanelTipsRed UFCanvasPanel
---@field SpineBodyguard USpineWidget
---@field TableViewBamboo UTableView
---@field TableView_241 UTableView
---@field TextCountDown UFTextBlock
---@field TextCountDown_1 UFTextBlock
---@field TextGreenTips UFTextBlock
---@field TextGreenTips_1 UFTextBlock
---@field TextRedTips UFTextBlock
---@field TraceItem1 GoldSauserMainBodyguardTraceItem1View
---@field AnimBanbooIn UWidgetAnimation
---@field AnimCut1 UWidgetAnimation
---@field AnimCut2 UWidgetAnimation
---@field AnimCut3 UWidgetAnimation
---@field AnimCutWrong UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimRememberIn UWidgetAnimation
---@field AnimRememberOut UWidgetAnimation
---@field AnimRememberWrong UWidgetAnimation
---@field AnimShowFrame UWidgetAnimation
---@field AnimShowFrame2 UWidgetAnimation
---@field AnimSpineLoop UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---@field AnimWait UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainBodyguardMainView = LuaClass(UIView, true)

function GoldSauserMainBodyguardMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBackBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonTitle = nil
	--self.FCanvasPanel_249 = nil
	--self.HorizontalTime = nil
	--self.HorizontalTime_1 = nil
	--self.ImgBGLong = nil
	--self.ImgBGShort = nil
	--self.ImgGreenTipsLine = nil
	--self.ImgShowFrame = nil
	--self.PanelBamboo = nil
	--self.PanelBodyguard = nil
	--self.PanelJudgeCut = nil
	--self.PanelRememberTrace = nil
	--self.PanelStage = nil
	--self.PanelTips = nil
	--self.PanelTipsGreen = nil
	--self.PanelTipsGreen_1 = nil
	--self.PanelTipsRed = nil
	--self.SpineBodyguard = nil
	--self.TableViewBamboo = nil
	--self.TableView_241 = nil
	--self.TextCountDown = nil
	--self.TextCountDown_1 = nil
	--self.TextGreenTips = nil
	--self.TextGreenTips_1 = nil
	--self.TextRedTips = nil
	--self.TraceItem1 = nil
	--self.AnimBanbooIn = nil
	--self.AnimCut1 = nil
	--self.AnimCut2 = nil
	--self.AnimCut3 = nil
	--self.AnimCutWrong = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimRememberIn = nil
	--self.AnimRememberOut = nil
	--self.AnimRememberWrong = nil
	--self.AnimShowFrame = nil
	--self.AnimShowFrame2 = nil
	--self.AnimSpineLoop = nil
	--self.AnimSuccess = nil
	--self.AnimWait = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainBodyguardMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.TraceItem1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainBodyguardMainView:InitConstStringInfo()
	self.CommonTitle:SetTextTitleName(LSTR(350097))
	self.TextGreenTips_1:SetText(LSTR(350105))
end

function GoldSauserMainBodyguardMainView:OnInit()
	self.EntranceItemVM = nil
	self.TableViewBambooAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBamboo)
	self.TableViewRoundAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_241)
	self.TextCountDownAdapterCountDown = UIAdapterCountDown.CreateAdapter(self, self.TextCountDown, "mm:ss", nil, self.OnTimeOutCallback)
	self.RoundStateCountDownAdapterCountDown = UIAdapterCountDown.CreateAdapter(self, self.TextCountDown_1, "mm:ss", nil, self.OnRoundTimeOutCallback)
	--- 保镖小游戏的Binder
	self.Binders = {
		{"RememberBanbooListVM", UIBinderUpdateBindableList.New(self, self.TableViewBambooAdapter)},
		{"RoundStateListVM", UIBinderUpdateBindableList.New(self, self.TableViewRoundAdapter)},
		{"RememberLimitTimeText", UIBinderSetText.New(self, self.TextCountDown)},
		{"RememberLimitTime", UIBinderUpdateCountDown.New(self, self.TextCountDownAdapterCountDown, 0.1)},
		{"RoundDrawLimitTime", UIBinderUpdateCountDown.New(self, self.RoundStateCountDownAdapterCountDown, 0.1)},
		{"bRoundSuccess", UIBinderValueChangedCallback.New(self, nil, self.OnNotifyRoundResult)},
		{"bShowLongRoundBg", UIBinderSetIsVisible.New(self, self.ImgBGLong)},
		{"bShowLongRoundBg", UIBinderSetIsVisible.New(self, self.ImgBGShort, true)},
	}
	self:InitConstStringInfo()
	self.bInRememberStage = false -- 是否处于记忆阶段

	--- 划痕追踪
	self.StartPos = nil
	self.CurPos = nil
	self.TempCutMark = {} -- 缓存页面创建的划痕
	self.CurRoundActiveCutMarkSampleIDList = {} -- 缓存显示的划痕ID
	self.AnimRoundResult = nil -- 结果动画赋值用于恢复UI显示
end

function GoldSauserMainBodyguardMainView:OnDestroy()

end

function GoldSauserMainBodyguardMainView:OnShow()
	local Params = self.Params
	if Params then
		self.EntranceItemVM = Params.EntranceItemVM
	end
	local VM = self:GetTheViewModel()
	if VM then
		VM.bCutDrawBtnVisible = false
		VM:CreateRemeberBanbooList()
	end

	self:PlayAnimationTimeRange(self.AnimBanbooIn, 0.0, 0.01, 1, nil, 1.0, false)
	
	UIUtil.SetIsVisible(self.PanelRememberTrace, false)
	UIUtil.SetIsVisible(self.TraceItem1, false)
	self:ShowLevelTips()
	self:RegisterTimer(function()
		UIUtil.SetIsVisible(self.PanelRememberTrace, true)
		self:PlayAnimation(self.AnimRememberIn)
		UIUtil.SetIsVisible(self.PanelTipsGreen, true)
		UIUtil.SetIsVisible(self.PanelTipsRed, false)
		--[[self:RegisterTimer(function()
			if VM and VM.CreateRemeberBanbooList then
				
			end
		end, RememberEnterEndTime)--]]
		self.bInRememberStage = true
	end, EnterEndTime)
end

function GoldSauserMainBodyguardMainView:OnHide()
	self:ClearVMData()
end

function GoldSauserMainBodyguardMainView:ShowLevelTips()
	local EntranceItemVM = self.EntranceItemVM
	if not EntranceItemVM then
		return
	end

	local CurLevel = EntranceItemVM:GetCurLevel()
	if CurLevel == 1 then
		MsgTipsUtil.ShowInfoTextTips(1, LSTR(350098))
	elseif CurLevel == 2 then
		MsgTipsUtil.ShowInfoTextTips(1, LSTR(350100))
	elseif CurLevel == 3 then
		MsgTipsUtil.ShowInfoTextTips(1, LSTR(350101))
	elseif CurLevel == 4 then
		MsgTipsUtil.ShowInfoTextTips(1, LSTR(350102))
	elseif CurLevel == 5 then
		MsgTipsUtil.ShowInfoTextTips(1, LSTR(350103))
	elseif CurLevel == 6 then
		MsgTipsUtil.ShowInfoTextTips(1, LSTR(350104))
	end
end

function GoldSauserMainBodyguardMainView:ClearVMData()
	self.TextCountDownAdapterCountDown:ManuallyStop()
	self.RoundStateCountDownAdapterCountDown:ManuallyStop()
	local VM = self:GetTheViewModel()
	if VM then
		VM.RememberLimitTime = nil
		VM.RoundDrawLimitTime = nil
	end
end

function GoldSauserMainBodyguardMainView:OnRegisterUIEvent()
	self.CommBackBtn:AddBackClick(self, self.OnClickCommBackBtn)
end

function GoldSauserMainBodyguardMainView:OnClickCommBackBtn()
	local bInRememberStage = self.bInRememberStage
	if not bInRememberStage then
		self:SetGameEnd()
	else
		self:PlayAnimation(self.AnimRememberOut)
		self.bInRememberStage = false
		self.TextCountDownAdapterCountDown:ManuallyStop()
	end
end

function GoldSauserMainBodyguardMainView:OnRegisterGameEvent()

end

function GoldSauserMainBodyguardMainView:OnRegisterBinder()
	local ViewModel = self:GetTheViewModel()
	if not ViewModel then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)
end

function GoldSauserMainBodyguardMainView:OnTimeOutCallback()
	self:PlayAnimation(self.AnimRememberOut)
	self.bInRememberStage = false
end

function GoldSauserMainBodyguardMainView:OnRoundTimeOutCallback()
	local ViewModel = self:GetTheViewModel()
	if not ViewModel or not ViewModel.SetRoundResult then
		return
	end
	ViewModel.bCutDrawBtnVisible = false
	ViewModel:SetRoundResult(false)
end

function GoldSauserMainBodyguardMainView:OnNotifyRoundResult(NewValue)
	if NewValue == nil then
		return
	end
	
	local bRoundSuccess = NewValue
	if bRoundSuccess then
		local VM = self:GetTheViewModel()
		if VM then
			if VM:IsAllSampleFinished() then
				MsgTipsUtil.ShowInfoTextTips(1, LSTR(350099))
				local SucAnim = self.AnimSuccess
				if SucAnim then
					self:PlayAnimation(SucAnim)
					GoldSauserMainPanelMgr:SendGoldSauserMainGameFinishedNumMsg(VM:GetMiniGameType())
					local SucAnimEndTime = SucAnim:GetEndTime() or 0
					self:RegisterTimer(function()
						self:SetGameEnd()
					end, SucAnimEndTime)
				else
					GoldSauserMainPanelMgr:SendGoldSauserMainGameFinishedNumMsg(VM:GetMiniGameType())
					self:SetGameEnd()
					FLOG_ERROR("GoldSauserMainBodyguardMainView:OnNotifyRoundResult SucAnim is not Exist")
				end
			else
				local function PushToNextStage()
					VM:PushToNexRoundStage()
					local AnimBanbooIn = self.AnimBanbooIn
					self:PlayAnimation(AnimBanbooIn)
					local BanbooInEndTime = AnimBanbooIn:GetEndTime()
					self:RegisterTimer(function()
						self:PlayAnimation(self.AnimWait)
					end, BanbooInEndTime)
				end

				local SuccessAnimIdx = math.random(1, 3)
				local AnimKey = string.format("AnimCut%s", tostring(SuccessAnimIdx))
				local AnimToPlay = self[AnimKey]
				if AnimToPlay then
					self:PlayAnimation(AnimToPlay)
					local AnimEndTime = AnimToPlay:GetEndTime() or 0
					self:RegisterTimer(function()
						PushToNextStage()
					end, AnimEndTime)
				else
					PushToNextStage()
					FLOG_ERROR("GoldSauserMainBodyguardMainView:OnNotifyRoundResult AnimToPlay is not exist")
				end
			end
		end
	else
		self:PlayAnimation(self.AnimCutWrong)
		--AudioUtil.LoadAndPlayUISound(AudioPathCutWrong)
		self.AnimRoundResult = self.AnimCutWrong
	end
end

function GoldSauserMainBodyguardMainView:OnAnimationFinished(Anim)
	if Anim == self.AnimIn then
		self:PlayAnimation(self.AnimBanbooIn)
		self:PlayAnimation(self.AnimSpineLoop)
		local VM = self:GetTheViewModel()
		if VM and VM.CreateRoundStateList then
			VM:CreateRoundStateList()
		end
	elseif Anim == self.AnimRememberIn then
		local VM = self:GetTheViewModel()
		if VM and VM.SetRememberLimitTime then
			VM:SetRememberLimitTime()
		end
	elseif Anim == self.AnimRememberOut then
		self:PlayAnimation(self.AnimShowFrame)
		UIUtil.SetIsVisible(self.PanelRememberTrace, false)
	elseif Anim == self.AnimShowFrame then
		self:PlayAnimation(self.AnimWait)
	elseif Anim == self.AnimCutWrong then
		UIUtil.SetIsVisible(self.PanelRememberTrace, true)
		self:PlayAnimation(self.AnimRememberWrong)
		UIUtil.SetIsVisible(self.PanelTipsGreen, false)
		UIUtil.SetIsVisible(self.PanelTipsRed, true)
		local WrongPanelEnterFinishTime = 1
		self:RegisterTimer(function()
			local VM = self:GetTheViewModel()
			if VM and VM.TriggerCurRoundSampleAnimWrong then
				VM:TriggerCurRoundSampleAnimWrong()
			end
			local WrongItemAnimEnd = 3
			self:RegisterTimer(function()
				self:SetGameEnd()
			end, WrongItemAnimEnd)
		end, WrongPanelEnterFinishTime)
	elseif Anim == self.AnimWait then
		local VM = self:GetTheViewModel()
		if VM then
			VM:StartRoundCountDown() -- 开始计时放到动画后，确保不会响应玩家的额外操作
			VM.bCutDrawBtnVisible = true
		end
	end
end

function GoldSauserMainBodyguardMainView:GetTheViewModel()
	local Params = self.Params
	if not Params then
		return
	end

	return Params.Data
end

function GoldSauserMainBodyguardMainView:SetGameEnd()
	self:StopAllAnimations()
	self:RecycleTempCutMark()
	self:Hide()
	local EntranceItemVM = self.EntranceItemVM
	if EntranceItemVM then
		EntranceItemVM:SetIsGameStart(false)
	end
end

------ 竹子划痕判断 ------

--- 避免移动端的位置偏移，改用新的监听事件
function GoldSauserMainBodyguardMainView:OnTouchStarted(_, InTouchEvent)
	local PointerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	if PointerIndex ~= 0 then
		-- 非单指判定不做处理
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local VM = self:GetTheViewModel()
	if not VM or not VM.bCutDrawBtnVisible then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local TargetDrawWidget = self.TraceItem1
	if not TargetDrawWidget then
		return UWidgetBlueprintLibrary.UnHandled()
	end
	
	local ScreenSpacePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)

	local LocalPosition = UIUtil.AbsoluteToLocal(self.FCanvasPanel_249, ScreenSpacePosition)
	self.StartPos = LocalPosition
	
	--- 初始化划痕轨迹
	UIUtil.CanvasSlotSetPosition(TargetDrawWidget, LocalPosition)
	UIUtil.CanvasSlotSetSize(TargetDrawWidget, FVector2D(0, TraceMarkDefaultSizeY))
	UIUtil.SetIsVisible(TargetDrawWidget, true)
	FLOG_INFO("GoldSauserMainBodyguardMainView:OnBtnCutPressed StartPos %s SizeY %s", LocalPosition, TraceMarkDefaultSizeY)

	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.CaptureMouse(Handled, self)
end

function GoldSauserMainBodyguardMainView:OnTouchMoved(_, InTouchEvent)
	local PointerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	if PointerIndex ~= 0 then
		-- 非单指判定不做处理
		return UWidgetBlueprintLibrary.UnHandled()
	end

	self:DrawCutMarkLine(InTouchEvent)

	return UWidgetBlueprintLibrary.Handled()
end

function GoldSauserMainBodyguardMainView:OnTouchEnded(_, InTouchEvent)
	if not self.StartPos then
		-- 没有起始位置的记录，默认不进行判定
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local PointerIndex = UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	if PointerIndex ~= 0 then
		-- 非单指判定不做处理
		return UWidgetBlueprintLibrary.UnHandled()
	end

	self:DrawCutMarkLine(InTouchEvent) -- 刷新一次痕迹数据

	local VM = self:GetTheViewModel()
	if not VM or not VM.bCutDrawBtnVisible then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local TargetDrawWidget = self.TraceItem1
	if not TargetDrawWidget then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	UIUtil.SetIsVisible(self.TraceItem1, false)
	
	local RltType, MatchIdx = self:CheckPosAndAngleValid()
	if RltType == CutJudgeRltType.Success then
		self:ShowSampleIndexCutMark(MatchIdx)
		VM:MarkNeedListMinusOne(MatchIdx)
		if VM:IsSampleCutMarkFinished() then
			VM.bCutDrawBtnVisible = false
			self:RegisterTimer(function()
				self.RoundStateCountDownAdapterCountDown:ManuallyStop() -- 出轮次结果则停止计时器
				VM:SetRoundResult(true)
			end, 1)
			self:RegisterTimer(function()
				self:HideAllCutMark()
			end, 1.5)
		end
	elseif RltType == CutJudgeRltType.Fail then
		VM.bCutDrawBtnVisible = false
		self.RoundStateCountDownAdapterCountDown:ManuallyStop() -- 出轮次结果则停止计时器
		VM:SetRoundResult(false)
	else
		self:PlayAnimation(self.AnimShowFrame2)
	end
	--FLOG_INFO("GoldSauserMainBodyguardMainView:OnBtnCutReleased Released Listened")
	self.StartPos = nil
	self.CurPos = nil
	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.ReleaseMouseCapture(Handled)
end

--- 判定划痕是否符合要求
---@return boolean, number@是否符合要求，匹配划痕的序号
function GoldSauserMainBodyguardMainView:CheckPosAndAngleValid()
	local EndPos = self.CurPos
	if not EndPos then
		return CutJudgeRltType.Invalid
	end
	
	local VM = self:GetTheViewModel()
	if not VM then
		return CutJudgeRltType.Invalid
	end

	local StartPos = self.StartPos
	if not StartPos then
		FLOG_ERROR("GoldSauserMainBodyguardMainView:CheckPosAndAngleValid PosData is invalid")
		return CutJudgeRltType.Invalid
	end

    local AbsStartCoordinate = UIUtil.LocalToAbsolute(self.FCanvasPanel_249, StartPos)
	local AbsEndCoordinate = UIUtil.LocalToAbsolute(self.FCanvasPanel_249, EndPos)

	local RectRegionWidget = self.PanelJudgeCut
	if not RectRegionWidget then
		return CutJudgeRltType.Invalid
	end

	local AnchorePos = UIUtil.GetWidgetAbsolutePosition(RectRegionWidget)
	local RectSize = UIUtil.GetAbsoluteSize(RectRegionWidget)
	local RectCenter = {X = AnchorePos.X + RectSize.X / 2, Y = RectSize.Y / 2 + AnchorePos.Y} -- 绝对坐标不依赖锚点，均为左上到右下

	if not MathUtil.IsLineAcrossTheRect(AbsStartCoordinate, AbsEndCoordinate, RectCenter, RectSize, 0) then
		FLOG_ERROR("GoldSauserMainBodyguardMainView:CheckPosAndAngleValid Line is not cross the rect")
		return CutJudgeRltType.Invalid -- 判定与竹子不相交为无效划动
	end 
	
	local CurAngle = self:CalAngleByStartPosAndCurPos(true)
	if not CurAngle then
		return CutJudgeRltType.Invalid
	end

	-- 获取角度配置判定误差值
	local AngleTolerance = 0
	local ToleranceCfgItem = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardInputDeviation)
	if ToleranceCfgItem then
		local Value = ToleranceCfgItem.Value
		if Value and next(Value) then
			AngleTolerance = Value[1] or 0
		end
	end

	local SampleCutMarkList = VM.CutMarkSignList
	if not SampleCutMarkList or not next(SampleCutMarkList) then
		FLOG_ERROR("GoldSauserMainBodyguardMainView:CheckPosAndAngleValid MarkListSign is Empty")
		return CutJudgeRltType.Invalid
	end

	local function CheckAngleInTolerance(TargetAngle)
		local AngleLimitMin = TargetAngle - AngleTolerance
		local AngleLimitMax = TargetAngle + AngleTolerance
		if CurAngle >= AngleLimitMin and CurAngle <= AngleLimitMax then
			return true
		end
		return false
	end

	local Rlt = CutJudgeRltType.Fail
	local MatchIdx = 1
	for Index, Angle in pairs(SampleCutMarkList) do
		if CheckAngleInTolerance(Angle) then
			Rlt = CutJudgeRltType.Success
			MatchIdx = Index
			break
		end
		if Angle == 90 then
			-- 也要判断是否符合-90的误差范围内
			local ExtraAngleLimit = -1 * Angle
			if CheckAngleInTolerance(ExtraAngleLimit) then
				Rlt = CutJudgeRltType.Success
				MatchIdx = Index
				break
			end
		end
	end

	
	if Rlt == CutJudgeRltType.Fail then
		FLOG_INFO("GoldSauserMainBodyguardMainView:CheckPosAndAngleValid Angle is Error Angle %s", CurAngle)
		return Rlt --如果角度不对直接返回失败
	elseif Rlt == CutJudgeRltType.Success then
		return Rlt, MatchIdx
	else
		return CutJudgeRltType.Invalid 
	end
end

function GoldSauserMainBodyguardMainView:ShowSampleIndexCutMark(MatchIdx)
	local TempCutMark = self.TempCutMark or {}
	
	local VM = self:GetTheViewModel()
	if not VM then
		return
	end

	local SampleID = VM:GetCurSampleID()
	if not SampleID then
		return
	end

	local bNeedCreate = false
	local ExistWidget
	local TargetCutSample = TempCutMark[SampleID]
	if not TargetCutSample then
		bNeedCreate = true
	else
		local ExistWidget = TargetCutSample[MatchIdx]
		if not ExistWidget then
			bNeedCreate = true
		end
	end

	if bNeedCreate then
		self:CreateTraceMarkerWidgetDynamic(MatchIdx)
	else
		UIUtil.SetIsVisible(ExistWidget, true)
	end

	table.insert(self.CurRoundActiveCutMarkSampleIDList, string.format("%s,%s", SampleID, MatchIdx))
end

function GoldSauserMainBodyguardMainView:HideAllCutMark()
	local TempCutMark = self.TempCutMark
	if not TempCutMark then
		return
	end

	local CurRoundActiveCutMarkSampleIDList = self.CurRoundActiveCutMarkSampleIDList or {}
	for _, TargetStr in ipairs(CurRoundActiveCutMarkSampleIDList) do
		local KeyTable = string.split(TargetStr, ',')
		local SampleID = tonumber(KeyTable[1])
		local MatchIdx = tonumber(KeyTable[2])
		local TargetCutSample = TempCutMark[SampleID]
		if TargetCutSample then
			local ExistWidget = TargetCutSample[MatchIdx]
			if ExistWidget then
				UIUtil.SetIsVisible(ExistWidget, false)
			end
		end
	end
	self.CurRoundActiveCutMarkSampleIDList = {}
end

function GoldSauserMainBodyguardMainView:CreateTraceMarkerWidgetDynamic(MatchIdx)
	local ParentWidget = self.FCanvasPanel_249
	if not ParentWidget then
		return
	end

	local VM = self:GetTheViewModel()
	if not VM then
		return
	end

	local SampleID = VM:GetCurSampleID()
	if not SampleID then
		return
	end

	local SampleCfg = GoldSaucerBodyguardSampleCfg:FindCfgByKey(SampleID)
    if not SampleCfg then
        return
    end

	local AngleList = SampleCfg.CutMarkAngle
	local PosXList = SampleCfg.CutMarkPosX
	local PosYList = SampleCfg.CutMarkPosY
	if not AngleList or not PosXList or not PosYList then
		return
	end
	
	local Angle = tonumber(AngleList[MatchIdx])
	local PosX = tonumber(PosXList[MatchIdx])
	local PosY = tonumber(PosYList[MatchIdx])
	if not Angle or not PosX or not PosY then
		return
	end

	local function Callback(Widget)
		if CommonUtil.IsObjectValid(ParentWidget) then
			ParentWidget:AddChildToCanvas(Widget)
			self:AddSubView(Widget)
			UIUtil.CanvasSlotSetAlignment(Widget, FVector2D(0, 0.5))
			UIUtil.CanvasSlotSetPosition(Widget, FVector2D(PosX, PosY))
			UIUtil.CanvasSlotSetZOrder(Widget, 5)

			local LongLen = 640
			local ShortLen = 345
			if Angle == 90 then
				UIUtil.CanvasSlotSetSize(Widget, FVector2D(LongLen, TraceMarkDefaultSizeY))
			else
				UIUtil.CanvasSlotSetSize(Widget, FVector2D(ShortLen, TraceMarkDefaultSizeY))
			end
			Widget:SetRenderTransformAngle(Angle)
			UIUtil.SetIsVisible(Widget, true)
			local TempCutMark = self.TempCutMark or {}
			local TempSample = TempCutMark[SampleID] or {}
			TempSample[MatchIdx] = Widget
			TempCutMark[SampleID] = TempSample
			self.TempCutMark = TempCutMark
		else
			WidgetPoolMgr:RecycleWidget(Widget)
		end
	end
	WidgetPoolMgr:CreateWidgetAsyncByName("GoldSauserMainPanel/Bodyguard/Item/GoldSauserMainBodyguardTraceItem_UIBP", ObjectGCType.NoCache, Callback, true, false)	
end

function GoldSauserMainBodyguardMainView:RecycleTempCutMark()
	local TempCutMark = self.TempCutMark
	if not TempCutMark then
		return
	end

	local ParentWidget = self.FCanvasPanel_249
	if not ParentWidget then
		return
	end

	for _, Sample in pairs(TempCutMark) do
		for _, Widget in pairs(Sample) do
			self:RemoveSubView(Widget)
			ParentWidget:RemoveChild(Widget)
			WidgetPoolMgr:RecycleWidget(Widget)
		end
	end
	self.TempCutMark = nil
end

--- 计算向量极坐标系夹角(-180~-90度/90~180度的角需要转换到对应旋转对称的象限中去)
---@param bCheck boolean@是否用来验证操作结果
function GoldSauserMainBodyguardMainView:CalAngleByStartPosAndCurPos(bCheck)
	local StartPos = self.StartPos
	if not StartPos then
		return
	end
	local EndPos = self.CurPos
	if not EndPos then
		return
	end

	local VecY = EndPos.Y - StartPos.Y
	local VecX = EndPos.X - StartPos.X
	if bCheck and VecX < 0 then
		VecX = -1 * VecX
		VecY = -1 * VecY
	end
	local Angle = MathUtil.GetTransformAngle(VecX, VecY)
	return Angle
end

function GoldSauserMainBodyguardMainView:DrawCutMarkLine(InTouchEvent)
	local StartPos = self.StartPos
	if not StartPos then
		return
	end

	local ScreenSpacePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UIUtil.AbsoluteToLocal(self.FCanvasPanel_249, ScreenSpacePosition)

	local OldCurPos = self.CurPos
	local DeltaLength = MathLibrary.Distance2D(OldCurPos, LocalPosition)
	if DeltaLength < TracePosTolerance then
		return
	end
	
	local Length = MathLibrary.Distance2D(StartPos, LocalPosition)
	local TargetTraceWidget = self.TraceItem1
	if TargetTraceWidget then
		UIUtil.CanvasSlotSetSize(TargetTraceWidget, FVector2D(Length, TraceMarkDefaultSizeY))
		local Angle = self:CalAngleByStartPosAndCurPos()
		if Angle then
			TargetTraceWidget:SetRenderTransformAngle(Angle)
		end
	end
	
	self.CurPos = LocalPosition
end

------ 竹子划痕判断 end ------

return GoldSauserMainBodyguardMainView