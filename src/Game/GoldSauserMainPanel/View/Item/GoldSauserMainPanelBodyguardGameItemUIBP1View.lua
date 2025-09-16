---
--- Author: Administrator
--- DateTime: 2023-12-29 20:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = _G.UIViewID
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local GoldSauserMainPanelBodyguardGameItemVM
local MsgTipsUtil = require("Utils/MsgTipsUtil")
--local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
--local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIBinderSetText = require("Binder/UIBinderSetText")
local GoldSaucerMinigameCfg = require("TableCfg/GoldSaucerMinigameCfg")
local BodyGuardSquareAnimState = GoldSauserMainPanelDefine.BodyGuardSquareAnimState
local FLOG_ERROR = _G.FLOG_ERROR

local PerActTimeCountInterval = 0.05

---@class GoldSauserMainPanelBodyguardGameItemUIBP1View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field FButtonTouch UFButton
---@field FImageGrain1 UFImage
---@field FImageGrain101 UFImage
---@field FImageGrain102 UFImage
---@field FImageGrain103 UFImage
---@field FImageGrain2 UFImage
---@field FImageGrain31 UFImage
---@field FImageGrain32 UFImage
---@field FImageGrain4 UFImage
---@field FImageGrain51 UFImage
---@field FImageGrain52 UFImage
---@field FImageGrain61 UFImage
---@field FImageGrain62 UFImage
---@field FImageGrain63 UFImage
---@field FImageGrain71 UFImage
---@field FImageGrain72 UFImage
---@field FImageGrain73 UFImage
---@field FImageGrain81 UFImage
---@field FImageGrain82 UFImage
---@field FImageGrain83 UFImage
---@field FImageGrain91 UFImage
---@field FImageGrain92 UFImage
---@field FImageGrain93 UFImage
---@field IconCurrent UFImage
---@field IconFinish UFImage
---@field IconUnopened1 UFImage
---@field IconUnopened2 UFImage
---@field ImageClickBg UFImage
---@field ImageTrace UFImage
---@field ImgBoamboo1 UFImage
---@field ImgBoamboo2 UFImage
---@field ImgBoamboo3 UFImage
---@field PanelBamboo UFCanvasPanel
---@field PanelBamboo_1 UFCanvasPanel
---@field PanelBamboo_10 UFCanvasPanel
---@field PanelBamboo_2 UFCanvasPanel
---@field PanelBamboo_3 UFCanvasPanel
---@field PanelBamboo_4 UFCanvasPanel
---@field PanelBamboo_5 UFCanvasPanel
---@field PanelBamboo_6 UFCanvasPanel
---@field PanelBamboo_7 UFCanvasPanel
---@field PanelBamboo_8 UFCanvasPanel
---@field PanelBamboo_9 UFCanvasPanel
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelBodyguardGameItemUIBP1View = LuaClass(UIView, true)

local BambooBatchCfg = 
{
	[1] = GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardOneBambooPool,
	[2] = GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardTwoBambooPool,
	[3] = GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardThreeBambooPool,
	[4] = GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardFourBambooPool,
}

function GoldSauserMainPanelBodyguardGameItemUIBP1View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.FButtonTouch = nil
	--self.FImageGrain1 = nil
	--self.FImageGrain101 = nil
	--self.FImageGrain102 = nil
	--self.FImageGrain103 = nil
	--self.FImageGrain2 = nil
	--self.FImageGrain31 = nil
	--self.FImageGrain32 = nil
	--self.FImageGrain4 = nil
	--self.FImageGrain51 = nil
	--self.FImageGrain52 = nil
	--self.FImageGrain61 = nil
	--self.FImageGrain62 = nil
	--self.FImageGrain63 = nil
	--self.FImageGrain71 = nil
	--self.FImageGrain72 = nil
	--self.FImageGrain73 = nil
	--self.FImageGrain81 = nil
	--self.FImageGrain82 = nil
	--self.FImageGrain83 = nil
	--self.FImageGrain91 = nil
	--self.FImageGrain92 = nil
	--self.FImageGrain93 = nil
	--self.IconCurrent = nil
	--self.IconFinish = nil
	--self.IconUnopened1 = nil
	--self.IconUnopened2 = nil
	--self.ImageClickBg = nil
	--self.ImageTrace = nil
	--self.ImgBoamboo1 = nil
	--self.ImgBoamboo2 = nil
	--self.ImgBoamboo3 = nil
	--self.PanelBamboo = nil
	--self.PanelBamboo_1 = nil
	--self.PanelBamboo_10 = nil
	--self.PanelBamboo_2 = nil
	--self.PanelBamboo_3 = nil
	--self.PanelBamboo_4 = nil
	--self.PanelBamboo_5 = nil
	--self.PanelBamboo_6 = nil
	--self.PanelBamboo_7 = nil
	--self.PanelBamboo_8 = nil
	--self.PanelBamboo_9 = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnInit()
	GoldSauserMainPanelBodyguardGameItemVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelBodyguardGameItemVM()

	self.BackBtn:AddBackClick(self, self.OnBackBtnClicked)

	--self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, "%.0f")
	self.Binders = {
		--{ "MiniGameTime", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 0.5, true, true)},
		{ "PerActCountTimeText", UIBinderSetText.New(self, self.TextTime)},
		
	}
	self.BambooStyle = nil
	self.TouchStartPos = nil
	self.TouchCurrentPos = nil
	self.TouchDirection = nil
	---第几画
	self.TouchCount = nil
	---当前批次绘制成功次数
	self.DrawRightCount = nil
	---当前批次
	self.BambooBatchIndex = nil

	---单次出手计时
	self.PerActTimeCount = 0
	self.PerActTimeLimit = 0

	---上层界面游戏结束回调
	self.ParentGameEnd = nil
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnDestroy()

end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnShow()
	for index, _ in ipairs(GoldSauserMainPanelDefine.BambooStyleList) do
		local Panel = "PanelBamboo_"..index
		UIUtil.SetIsVisible(self[Panel], false)
	end
	UIUtil.SetIsVisible(self.FButtonTouch, false)
	local EndTime = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardEndTime).Value[1] /1000
	self.MiniGameTimer = _G.TimerMgr:AddTimer(self, self.SetGameEnd, EndTime, 0, 1, GoldSauserMainPanelDefine.MiniGameEndCondition.Fail)
	self.BambooBatchIndex = 1

	self:BambooGenerate()

	local Params = self.Params
	if Params then
		self.ParentGameEnd = Params.ParentGameEnd
	end
end


function GoldSauserMainPanelBodyguardGameItemUIBP1View:BambooGenerate()
	if self.BambooBatchIndex > 4 then
		return
	end
	UIUtil.SetIsVisible(self.FButtonTouch, true,true)

	MsgTipsUtil.ShowTips(LSTR("开始绘制第"..self.BambooBatchIndex.."批"))
	---todo 需要读表配置时间
	---计时器销毁
	if self.BambooGenerateTimer then
		_G.TimerMgr:CancelTimer(self.BambooGenerateTimer)
		self.BambooGenerateTimer = nil
	end
	---随机竹子
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 3)))
	local BambooPoolIndex = math.random(1, 4)
	local BambooIndex = GoldSaucerMinigameCfg:FindCfgByKey(BambooBatchCfg[self.BambooBatchIndex]).Value[BambooPoolIndex]
	GoldSauserMainPanelBodyguardGameItemVM.RandomBambooWithSignIndex = BambooIndex
	GoldSauserMainPanelBodyguardGameItemVM:ChangeTheAnimState(BodyGuardSquareAnimState.Idle)

	self.BambooStyle = {}
	self.TouchCount = 0
	self.DrawRightCount = 0
	local StyleConfig = GoldSauserMainPanelDefine.BambooStyleList[BambooIndex]
	for i, Value in ipairs(StyleConfig) do
		self.BambooStyle[i] = Value
	end

	--- 初始化隐藏所有子划痕
	local BambooIndex = GoldSauserMainPanelBodyguardGameItemVM.RandomBambooWithSignIndex
	local Panel = string.format("PanelBamboo_%s", tostring(BambooIndex))
	UIUtil.SetIsVisible(self[Panel], true)
	local GrainTotalNum = #self.BambooStyle
	if GrainTotalNum <= 1 then
		local FImageGrainToShowName = string.format("FImageGrain%s", tostring(BambooIndex))
		local FImageGrainToShow = self[FImageGrainToShowName]
		if FImageGrainToShow then
			UIUtil.SetIsVisible(self[FImageGrainToShowName], false)
		end
	else
		local GrainTotalNum = #self.BambooStyle
		for index = 1, GrainTotalNum do
			local FImageGrainToShowName = string.format("FImageGrain%s%s", tostring(BambooIndex), tostring(index))
			local FImageGrainToShow = self[FImageGrainToShowName]
			if FImageGrainToShow then
				UIUtil.SetIsVisible(FImageGrainToShow, false)
			end
		end
	end

	self:StartPerActTimeCountDown()
end

--- 单次出手计时逻辑 ---
function GoldSauserMainPanelBodyguardGameItemUIBP1View:StartPerActTimeCountDown()
	local BambooShowTimer = self.BambooShowTimer
	if BambooShowTimer then
		FLOG_ERROR("GoldSauserMainPanelBodyguardGameItemUIBP1View:StartPerActTimeCountDown: Timer Exist")
		return
	end
	self.PerActTimeLimit = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardInputTime).Value[1] / 1000
	self.PerActTimeCount = 0
	self.BambooShowTimer = _G.TimerMgr:AddTimer(self, self.PerActTimeCountDown, 0, PerActTimeCountInterval, 0)
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:BreakPerActTimeCountDown()
	local BambooShowTimer = self.BambooShowTimer
	if not BambooShowTimer then
		FLOG_ERROR("GoldSauserMainPanelBodyguardGameItemUIBP1View:BreakPerActTimeCountDown: Timer not Exist")
		return
	end
	_G.TimerMgr:CancelTimer(BambooShowTimer)
	self.BambooShowTimer = nil
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:PerActTimeCountDown()
	local BambooShowTimer = self.BambooShowTimer
	if not BambooShowTimer then
		FLOG_ERROR("GoldSauserMainPanelBodyguardGameItemUIBP1View:PerActTimeCountDown: Timer not Exist")
		return
	end
	local PerActTimeMoved = self.PerActTimeCount + PerActTimeCountInterval
	local PerActTimeRemain = self.PerActTimeLimit - PerActTimeMoved
	if PerActTimeRemain < 0 then
		PerActTimeRemain = 0
		self:OutOfPerActTimeLimit()
		self:BreakPerActTimeCountDown()
	end
	GoldSauserMainPanelBodyguardGameItemVM.PerActCountTimeText = string.format("%.0f", PerActTimeRemain)
	self.PerActTimeCount = PerActTimeMoved 
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OutOfPerActTimeLimit()
	local FailTouchToShow = self.TouchCount + 1 -- 超时失败未经历Press事件，TouchCount还未自增
	local FImageGrainToShow = self:GetTheCurrentGrainToShow(FailTouchToShow)
	self:PerActFailShow(FImageGrainToShow)
end

--- 获取当前划动次数的划痕
function GoldSauserMainPanelBodyguardGameItemUIBP1View:GetTheCurrentGrainToShow(TouchCount)
	if not TouchCount or TouchCount <= 0 then
		FLOG_ERROR("GoldSauserMainPanelBodyguardGameItemUIBP1View:GetTheCurrentGrainToShow: Not Touch Happened")
		return
	end

	local BambooStyle = self.BambooStyle
	if not BambooStyle or not next(BambooStyle) then
		FLOG_ERROR("GoldSauserMainPanelBodyguardGameItemUIBP1View:GetTheCurrentGrainToShow: Style is not valid")
		return
	end
	local BambooPanelIndex = GoldSauserMainPanelBodyguardGameItemVM.RandomBambooWithSignIndex
	local GrainTotalNum = #BambooStyle
	local FImageGrainToShowName = GrainTotalNum <= 1 and string.format("FImageGrain%s", tostring(BambooPanelIndex)) 
			or string.format("FImageGrain%s%s", tostring(BambooPanelIndex), tostring(TouchCount))
	return self[FImageGrainToShowName]
end

--- 每次出手竹子的显示变化
function GoldSauserMainPanelBodyguardGameItemUIBP1View:BambooShowChangePerAct()
	local FImageGrainToShow = self:GetTheCurrentGrainToShow(self.TouchCount)
	if FImageGrainToShow then
		local IsTouchDrawRight = self.IsTouchDrawRight
		if IsTouchDrawRight then
			UIUtil.SetIsVisible(FImageGrainToShow, true)
		else
			self:PerActFailShow(FImageGrainToShow)
		end
	end
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:PerActFailShow(FImageGrainToShow)
	if not FImageGrainToShow then
		return
	end
	-- TODO 错误笔划需要播放闪烁动效,暂时用计时器代替
	GoldSauserMainPanelBodyguardGameItemVM:ChangeTheAnimState(BodyGuardSquareAnimState.ActFail)
	self:RegisterTimer(function()
		UIUtil.SetIsVisible(FImageGrainToShow, true)
		self:SetGameEnd(GoldSauserMainPanelDefine.MiniGameEndCondition.Fail)
		GoldSauserMainPanelBodyguardGameItemVM:ChangeTheAnimState(BodyGuardSquareAnimState.Idle)
	end, 2, nil, 1)
end
--- 单次出手计时逻辑 end ---


function GoldSauserMainPanelBodyguardGameItemUIBP1View:BambooHide()
	local BambooIndex = GoldSauserMainPanelBodyguardGameItemVM.RandomBambooWithSignIndex
	local Panel = string.format("PanelBamboo_%s", tostring(BambooIndex))
	UIUtil.SetIsVisible(self[Panel], false)
	GoldSauserMainPanelBodyguardGameItemVM.RandomBambooWithSignIndex = nil
	if self.BambooBatchIndex >= 4 then
		self:SetGameEnd(GoldSauserMainPanelDefine.MiniGameEndCondition.Succeed)
		return
	end
	self.BambooBatchIndex = self.BambooBatchIndex + 1
	local IntervalTime = GoldSaucerMinigameCfg:FindCfgByKey(GoldSauserMainPanelDefine.MiniGameEnum.BodyGuardBambooGenerateInterval).Value[1] / 1000
	self.BambooGenerateTimer = _G.TimerMgr:AddTimer(self, self.BambooGenerate, IntervalTime, 0, 1)
	UIUtil.SetIsVisible(self.FButtonTouch, false)
	self:BreakPerActTimeCountDown()
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:SetGameEnd(EndCondition)
	if EndCondition == GoldSauserMainPanelDefine.MiniGameEndCondition.Succeed then
		---todo 成功动画接入，消失可能要延时处理
		---小游戏成功协议发送
		GoldSauserMainPanelMgr:SendGoldSauserMainGameFinishedNumMsg(GoldSauserMainPanelBodyguardGameItemVM:GetMiniGameType())
		GoldSauserMainPanelBodyguardGameItemVM:ChangeTheAnimState(BodyGuardSquareAnimState.ChallengeSuccess)
		MsgTipsUtil.ShowTips(LSTR("游戏成功(本地)"))
		self:RegisterTimer(function ()
			self:BackToMainPanel()
			self:ClearAllTimerInGame()
		end, 3, nil, 1)
	elseif EndCondition == GoldSauserMainPanelDefine.MiniGameEndCondition.Fail then
		---失败动画放到统一接口 PerActFailShow
		MsgTipsUtil.ShowTips(LSTR("游戏失败"))
		self:BackToMainPanel()
		self:ClearAllTimerInGame()
	end
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:ClearAllTimerInGame()
	---游戏计时器销毁
	if self.MiniGameTimer then
		_G.TimerMgr:CancelTimer(self.MiniGameTimer)
		self.MiniGameTimer = nil
	end
	---计时器销毁
	if self.BambooGenerateTimer then
		_G.TimerMgr:CancelTimer(self.BambooGenerateTimer)
		self.BambooGenerateTimer = nil
	end
	---计时器销毁
	if self.BambooShowTimer then
		_G.TimerMgr:CancelTimer(self.BambooShowTimer)
		self.BambooShowTimer = nil
	end
	---计时器销毁
	if self.TouchTraceTimer then
		_G.TimerMgr:CancelTimer(self.TouchTraceTimer)
		self.TouchTraceTimer = nil
	end
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnHide()

end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButtonTouch, self.OnTouchBtnClicked)
	UIUtil.AddOnPressedEvent(self, self.FButtonTouch, self.OnTouchBtnPressed)
	UIUtil.AddOnReleasedEvent(self, self.FButtonTouch, self.OnTouchBtnReleased)
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnRegisterGameEvent()

end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnRegisterBinder()
	self:RegisterBinders(GoldSauserMainPanelBodyguardGameItemVM, self.Binders)
end
-- ---TouchMove
-- function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchMoved(InGeometry, InTouchEvent)
-- 	print("GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchMoved")
-- end

-- function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchStarted(InGeometry, InTouchEvent)
-- 	print("GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchStarted")
-- 	local CurMousePos = _G.UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.FWORLD())
-- 	print(CurMousePos)
-- end
-- ---OnTouchEnded
-- function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchEnded(InGeometry, InTouchEvent)
-- 	print("GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchEnded")
-- end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnBackBtnClicked()
	self:SetGameEnd(GoldSauserMainPanelDefine.MiniGameEndCondition.Fail) -- 游戏中退出直接判定失败
end

--- UI逻辑返回上层界面
function GoldSauserMainPanelBodyguardGameItemUIBP1View:BackToMainPanel()
	GoldSauserMainPanelMainVM:SetIsEventSquareCenter(false)
	self:Hide()
	local ParentGameEnd = self.ParentGameEnd
	if ParentGameEnd then
		ParentGameEnd()
		self.ParentGameEnd = nil
	end
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchBtnClicked()

end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchBtnPressed()
	if nil == self.BambooStyle or #self.BambooStyle == 0 then
		self:SetGameEnd(GoldSauserMainPanelDefine.MiniGameEndCondition.Interrupt)
		FLOG_ERROR("GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchBtnPressed: BambooStyle no data")
		return
	end
	self.TouchStartPos = _G.UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.FWORLD())
	self.TouchCurrentPos = self.TouchStartPos
	print("gold TouchPos X:%s Y:%s", self.TouchCurrentPos.X, self.TouchCurrentPos.Y)
	--self.CurrentTouchTexture = GoldSauserMainPanelDefine.BambooBaseTexture.None
	self.TouchCount = self.TouchCount + 1
	self.IsTouchDrawRight = true
	if self.BambooStyle[self.TouchCount] then
		self.TouchTraceTimer = _G.TimerMgr:AddTimer(self, self.TouchTrace, 0, 0.2, 0)
	end
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:UpdateTouchTracePath(TracePos)
	local StartPos = self.TouchStartPos
	if not StartPos then
		return
	end

	local CenterPos =  _G.UE.FVector2D(TracePos.X - StartPos.X, TracePos.Y - StartPos.Y)
	UIUtil.CanvasSlotSetPosition(self.ImageTrace, CenterPos)

	
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:TouchTrace()
	local TouchPos = _G.UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(_G.FWORLD())

	local LastTestedPos = self.TouchCurrentPos
	if LastTestedPos.X == TouchPos.X and LastTestedPos.Y == TouchPos.Y then
		-- 两次检测之间如果未发生移动，不做失败判定
		return
	end
	local MaxAngle
	local MinAngle
	local ReverseMaxAngle
	local ReverseMinAngle
	local Angle = self.BambooStyle[self.TouchCount]
	---todo 后续配表
	local OffsetAngle = 30
	---确认方向，右向为正
	-- if TouchPos.X > self.TouchStartPos.X then
	-- 	self.TouchDirection = true
	-- else
	-- 	self.TouchDirection = false
	-- end

	--- 误差取45度上下偏移OffsetAngle度,todo后续走配表
	MaxAngle = Angle + OffsetAngle
	MinAngle = Angle - OffsetAngle
	
	ReverseMaxAngle = Angle - 180 + OffsetAngle
	ReverseMinAngle = Angle - 180 - OffsetAngle


	print("gold 初始最大角度范围"..MaxAngle)
	print("gold 初始最小角度范围"..MinAngle)
	---范围是否在180度交界处
	local IsJunction = false
	local IsConversion
	ReverseMaxAngle, IsConversion = self.AngleConversion(ReverseMaxAngle)
	if IsConversion then
		IsJunction = not IsJunction
	end
	ReverseMinAngle, IsConversion = self.AngleConversion(ReverseMinAngle)
	if IsConversion then
		IsJunction = not IsJunction
	end
	print("gold 反转最大角度范围"..ReverseMaxAngle)
	print("gold 反转最小角度范围"..ReverseMinAngle)
	local OffsetVector = _G.UE.FVector2D(TouchPos.X - self.TouchCurrentPos.X, TouchPos.Y - self.TouchCurrentPos.Y)
	print("gold TouchPos X:%s Y:%s", TouchPos.X, TouchPos.Y)
	local CentreAngle = self:AngleCalculations(OffsetVector)
	print("gold 角度"..CentreAngle)
	if IsJunction then
		if (CentreAngle > MaxAngle or CentreAngle < MinAngle) and (CentreAngle > ReverseMaxAngle and CentreAngle < MinAngle) then
			self.IsTouchDrawRight = false
			print("gold 失败1角度"..CentreAngle)
		end
	else
		if (CentreAngle > MaxAngle or CentreAngle < MinAngle) and (CentreAngle > ReverseMaxAngle or CentreAngle < MinAngle) then
			self.IsTouchDrawRight = false
			print("gold 失败2角度"..CentreAngle)
		end
	end

	self.TouchCurrentPos = TouchPos
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnTouchBtnReleased()
	---计时器销毁
	if self.TouchTraceTimer then
		_G.TimerMgr:CancelTimer(self.TouchTraceTimer)
		self.TouchTraceTimer = nil
	end
	self:BreakPerActTimeCountDown()
	---点击视为失败
	if self.TouchStartPos.X == self.TouchCurrentPos.X and self.TouchStartPos.Y == self.TouchCurrentPos.X then
		self.IsTouchDrawRight = false
	end

	--- 开始挥砍动画
	GoldSauserMainPanelBodyguardGameItemVM:ChangeTheAnimState(BodyGuardSquareAnimState.Act)
	self:RegisterTimer(function()
		self:BambooShowChangePerAct()
		if self.IsTouchDrawRight then
			MsgTipsUtil.ShowTips(LSTR("第"..self.TouchCount.."划成功"))
			self.DrawRightCount = self.DrawRightCount + 1
			if self.BambooStyle and self.DrawRightCount >= #self.BambooStyle then
				GoldSauserMainPanelBodyguardGameItemVM:ChangeTheAnimState(BodyGuardSquareAnimState.ActSuccess)
				self:RegisterTimer(function()
					self:BambooHide()
					UIUtil.SetIsVisible(self.FButtonTouch, false)
					GoldSauserMainPanelBodyguardGameItemVM:ChangeTheAnimState(BodyGuardSquareAnimState.Idle)
				end, 2, nil, 1)
			else
				self:StartPerActTimeCountDown() -- 如果未进入结算开始下一次单次出手计时
				GoldSauserMainPanelBodyguardGameItemVM:ChangeTheAnimState(BodyGuardSquareAnimState.Idle)
			end
		else
			MsgTipsUtil.ShowTips(LSTR("第"..self.TouchCount.."划失败"))
			local FImageGrainToShow = self:GetTheCurrentGrainToShow(self.TouchCount)
			self:PerActFailShow(FImageGrainToShow)
		end
	end, 2, nil, 1)
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View.AngleConversion(Angle)
    ---换算超过180度的角度
	local IsConversion = false
    if Angle > 180 then
		IsConversion = true
		Angle = Angle - 360
	elseif Angle < -180 then
		IsConversion = true
		Angle = Angle + 360
	end
	return Angle, IsConversion 
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View:AngleCalculations(Vector)
    -- 计算相对X轴的角度，顺时针为正
    local XVector = {X = 1, Y = 0}
	_G.UE.FVector2D.Normalize(Vector)
	local CentreAngle = math.deg(math.acos(self.DotProduct2D(XVector, Vector)))
	if Vector.Y < 0 then
		CentreAngle = -CentreAngle
	end
	return CentreAngle
end

function GoldSauserMainPanelBodyguardGameItemUIBP1View.DotProduct2D(v1, v2)
    -- 计算点积
    local Dotproduct = v1.X * v2.X + v1.Y * v2.Y
	return Dotproduct
end

--- TODO 游戏结束数据变化放入动画结束回调
function GoldSauserMainPanelBodyguardGameItemUIBP1View:OnAnimationFinished(Animation)

end

--- TODO 不同批次的显示
function GoldSauserMainPanelBodyguardGameItemUIBP1View:UpdateBatchIndexPanel(BatchIndex)

end

return GoldSauserMainPanelBodyguardGameItemUIBP1View