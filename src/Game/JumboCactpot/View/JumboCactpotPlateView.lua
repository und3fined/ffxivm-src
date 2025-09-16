---
--- Author: Administrator
--- DateTime: 2023-09-18 09:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCS = require("Protocol/ProtoCS")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local AudioUtil = require("Utils/AudioUtil")
local JumboUIAudioPath = JumboCactpotDefine.JumboUIAudioPath
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local UAudioMgr = _G.UE.UAudioMgr.Get()

local LSTR = _G.LSTR
---@class JumboCactpotPlateView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoExchange UFButton
---@field BtnHelp_1 CommInforBtnView
---@field BtnSkip UFButton
---@field CloseBtn CommonCloseBtnView
---@field Image_32 UImage
---@field MiddlePlate JumboCactpotPlatePanelView
---@field PanelBought UFCanvasPanel
---@field PanelGoeExchange UFCanvasPanel
---@field PanelPlate UFCanvasPanel
---@field PanelSkip UFCanvasPanel
---@field RichTextDate URichTextBox
---@field TableViewBought UTableView
---@field TextBought UFTextBlock
---@field TextCountDown UFTextBlock
---@field TextGoExchange UFTextBlock
---@field TextSkip UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotPlateView = LuaClass(UIView, true)

function JumboCactpotPlateView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoExchange = nil
	--self.BtnHelp_1 = nil
	--self.BtnSkip = nil
	--self.CloseBtn = nil
	--self.Image_32 = nil
	--self.MiddlePlate = nil
	--self.PanelBought = nil
	--self.PanelGoeExchange = nil
	--self.PanelPlate = nil
	--self.PanelSkip = nil
	--self.RichTextDate = nil
	--self.TableViewBought = nil
	--self.TextBought = nil
	--self.TextCountDown = nil
	--self.TextGoExchange = nil
	--self.TextSkip = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotPlateView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnHelp_1)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.MiddlePlate)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotPlateView:OnInit()
    self.BoughtAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBought, nil, true)

	self.IsRunTimer = nil
	self.SkipTimerHandles = {}
	self.Binders = {
		{ "PlateBoughtList", UIBinderUpdateBindableList.New(self, self.BoughtAdapter)},
	}
	self.PlateItem1 = self.MiddlePlate.JumboCactpotPlateItem_3
	self.PlateItem2 = self.MiddlePlate.JumboCactpotPlateItem_2
	self.PlateItem3 = self.MiddlePlate.JumboCactpotPlateItem_1
	self.PlateItem4 = self.MiddlePlate.JumboCactpotPlateItem

	self.AnimStartLength = self.PlateItem1.AnimStart:GetEndTime()
	self.LoopAnimLength = self.PlateItem1.AnimRotateLoop:GetEndTime()
	self.EndAnimLength = self.PlateItem1.AnimResult1:GetEndTime()
end

function JumboCactpotPlateView:OnDestroy()

end

function JumboCactpotPlateView:ResetDefaultAnim()
	for i = 1, 4 do
		local NameIndex = string.format("PlateItem%d", i)
		self[NameIndex]:PlayAnimation(self[NameIndex].AnimStill)
	end
end

function JumboCactpotPlateView:OnShow()
	-- 告诉服务器已经进来过了
	self.SkipTimerHandles = {}
	local FairyColorReportType = ProtoCS.FairyColorReportType
	local MsgBody = {
		Cmd = ProtoCS.FairyColorGameCmd.PlayEffect,
		PlayEffect = { ReportType = FairyColorReportType.FairyColorReportType_LotteryEffect }
	}
	JumboCactpotMgr:OnSendNetMsg(MsgBody)
	JumboCactpotMgr.RichBoughtNum = {}
	-- JumboCactpotMgr.bInOpenLotteryPro = false
	JumboCactpotMgr.bPlayLottoryAnim = false
	self.bClickSkipBtn = false
	self.bClickExchange = false
	self:ResetDefaultAnim()

	self.WinningNum = JumboCactpotMgr.WinNumber
	JumboCactpotMgr:UpdateIntervalTimeAndLoopCount()
	UIUtil.SetIsVisible(self.PanelSkip, true)

	local PushReward = JumboCactpotMgr.PushReward
    local LastTerm = PushReward ~= nil and PushReward.LastTerm or JumboCactpotMgr.LastTerm
	local Content = string.format(LSTR(240066), LastTerm) -- No.%s期
	self.RichTextDate:SetText(Content)

	local TipContent = string.format(LSTR(240067), LastTerm) -- "第%s期开奖开始！"
	MsgTipsUtil.ShowInfoTextTips(1, TipContent)

	UIUtil.SetIsVisible(self.PanelGoeExchange, false)
	UIUtil.SetIsVisible(self.BtnHelp_1, false)
	UIUtil.SetIsVisible(self.MiddlePlate, true)

	self.CloseBtn:SetCallback(self, self.OnBtnCloseBtnClick)

	AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelUp)

	self:InitLSTRText()
end

function JumboCactpotPlateView:InitLSTRText()
	self.TextTitle:SetText(LSTR(240084)) -- 仙彩开奖
	self.TextSkip:SetText(LSTR(240085)) -- 跳过动画
	self.TextGoExchange:SetText(LSTR(240086)) -- 去兑奖
	self.TextBought:SetText(LSTR(240078)) -- 已购：
end

function JumboCactpotPlateView:OnHide()
	self:UnRegisterAllTimer()
	AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopLoop)
	-- for i = 4, 1, -1 do
	-- 	local ItemName = string.format("PlateItem%d", i)
	-- 	self[ItemName]:PlayAnimation(self[ItemName]["AnimRotateLoop"])
	-- end
	if self.MiddlePlate2 then
		self.PanelPlate:RemoveChild(self.MiddlePlate2)
		UIViewMgr:RecycleView(self.MiddlePlate2)
		self.MiddlePlate2 = nil
	end
end

function JumboCactpotPlateView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoExchange, self.OnBtnGoExchangeClick)
	UIUtil.AddOnClickedEvent(self, self.BtnSkip, self.OnBtnSkipClick)
end

function JumboCactpotPlateView:OnRegisterGameEvent()

end

function JumboCactpotPlateView:OnRegisterBinder()
	self:RegisterBinders(JumboCactpotVM, self.Binders)
end


function JumboCactpotPlateView:PlayRotateAnim1()
	local Timer1 = self:RegisterTimer(self.PlayRotateAnim2, JumboCactpotMgr.IntervalTime, nil, 1, self)
	table.insert(self.SkipTimerHandles, Timer1)
	
	self.PlateItem1:PlayAnimation(self.PlateItem1.AnimStart)
	local AudioHandle1 = AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelBeginRotate, function(PlayingID)
		UAudioMgr.SetRTPCValueByPlayingID(JumboUIAudioPath.UISheelRotateRTPCName, 0, PlayingID, 0)
	end)
	

	local AnimStartLength = self.AnimStartLength
	local LoopAnimLength = self.LoopAnimLength
	local LoopCount = JumboCactpotMgr.LoopCount
	local Timer2 = self:RegisterTimer(function() 	
		self.PlateItem1:PlayAnimation(self.PlateItem1.AnimRotateLoop)
		UAudioMgr.SetRTPCValueByHandleID(JumboUIAudioPath.UISheelRotateRTPCName, 1, AudioHandle1, 0)
	end, AnimStartLength, LoopAnimLength, LoopCount, nil)
	table.insert(self.SkipTimerHandles, Timer2)


	local ResultAnim = self.PlateItem1[string.format("AnimResult%s", string.sub(self.WinningNum, 4, 4))]
	local EndDelayTime = LoopAnimLength * LoopCount + AnimStartLength
	local Timer3 = self:RegisterTimer(function() 	
		self.PlateItem1:PlayAnimation(ResultAnim)
		AudioUtil.StopAsyncAudioHandle(AudioHandle1)
	end, EndDelayTime)
	table.insert(self.SkipTimerHandles, Timer3)


	local ShowLottoryNumTime = EndDelayTime + self.EndAnimLength - 0.5
	local Timer4 =  self:RegisterTimer(function()
		if self.bClickSkipBtn then
			return
		end 	
		JumboCactpotMgr:UpdateRichText(string.sub(self.WinningNum, 4, 4), 4)
	end, ShowLottoryNumTime)
	table.insert(self.SkipTimerHandles, Timer4)

	local PlayStopAudio = function()
		AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopRotate)
	end

	local Timer5 =  self:RegisterTimer(PlayStopAudio, ShowLottoryNumTime - 0.5)
	table.insert(self.SkipTimerHandles, Timer5)
end

function JumboCactpotPlateView:PlayRotateAnim2()
	local Timer1 = self:RegisterTimer(self.PlayRotateAnim3, JumboCactpotMgr.IntervalTime, nil, 1, self)
	table.insert(self.SkipTimerHandles, Timer1)

	-- Play动画
	self.PlateItem2:PlayAnimation(self.PlateItem2.AnimStart)
	local AudioHandle = AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelBeginRotate, function(PlayingID)
		UAudioMgr.SetRTPCValueByPlayingID(JumboUIAudioPath.UISheelRotateRTPCName, 0, PlayingID, 0)
	end)
	local AnimStartLength = self.AnimStartLength
	local LoopAnimLength = self.LoopAnimLength
	local LoopCount = JumboCactpotMgr.LoopCount
	local Timer2 = self:RegisterTimer(function() 	
		self.PlateItem2:PlayAnimation(self.PlateItem2.AnimRotateLoop)
		UAudioMgr.SetRTPCValueByHandleID(JumboUIAudioPath.UISheelRotateRTPCName, 1, AudioHandle, 0)
	end, AnimStartLength, LoopAnimLength, LoopCount, nil)
	table.insert(self.SkipTimerHandles, Timer2)

	local ResultAnim = self.PlateItem2[string.format("AnimResult%s", string.sub(self.WinningNum, 3, 3))]
	local EndDelayTime = LoopAnimLength * LoopCount + AnimStartLength
	local Timer3 self:RegisterTimer(function() 	
		self.PlateItem2:PlayAnimation(ResultAnim)
		AudioUtil.StopAsyncAudioHandle(AudioHandle)
	end, EndDelayTime)
	table.insert(self.SkipTimerHandles, Timer3)

	local ShowLottoryNumTime = EndDelayTime + self.EndAnimLength - 0.5
	local Timer4 self:RegisterTimer(function() 
		if self.bClickSkipBtn then
			return
		end 	
		JumboCactpotMgr:UpdateRichText(string.sub(self.WinningNum, 3, 3), 3)
	end, ShowLottoryNumTime)
	table.insert(self.SkipTimerHandles, Timer4)

	local PlayStopAudio = function()
		-- AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopLoop)
		AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopRotate)
	end

	local Timer5 =  self:RegisterTimer(PlayStopAudio, ShowLottoryNumTime - 0.5)
	table.insert(self.SkipTimerHandles, Timer5)
end

function JumboCactpotPlateView:PlayRotateAnim3()

	local Timer1 = self:RegisterTimer(self.PlayRotateAnim4, JumboCactpotMgr.IntervalTime, nil, 1, self)
	table.insert(self.SkipTimerHandles, Timer1)

	-- Play动画
	self.PlateItem3:PlayAnimation(self.PlateItem3.AnimStart)
	local AudioHandle = AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelBeginRotate, function(PlayingID)
		UAudioMgr.SetRTPCValueByPlayingID(JumboUIAudioPath.UISheelRotateRTPCName, 0, PlayingID, 0)
	end)
	local AnimStartLength = self.AnimStartLength
	local LoopAnimLength = self.LoopAnimLength
	local LoopCount = JumboCactpotMgr.LoopCount
	local Timer2 = self:RegisterTimer(function() 	
		self.PlateItem3:PlayAnimation(self.PlateItem3.AnimRotateLoop)
		UAudioMgr.SetRTPCValueByHandleID(JumboUIAudioPath.UISheelRotateRTPCName, 1, AudioHandle, 0)
	end, AnimStartLength, LoopAnimLength, LoopCount, nil)
	table.insert(self.SkipTimerHandles, Timer2)

	local ResultAnim = self.PlateItem3[string.format("AnimResult%s", string.sub(self.WinningNum, 2, 2))]
	local EndDelayTime = LoopAnimLength * LoopCount + AnimStartLength
	local Timer3 = self:RegisterTimer(function() 	
		self.PlateItem3:PlayAnimation(ResultAnim)
		AudioUtil.StopAsyncAudioHandle(AudioHandle)
	end, EndDelayTime)
	table.insert(self.SkipTimerHandles, Timer3)

	local ShowLottoryNumTime = EndDelayTime + self.EndAnimLength - 0.5
	local Timer4 = self:RegisterTimer(function() 	
		if self.bClickSkipBtn then
			return
		end 
		JumboCactpotMgr:UpdateRichText(string.sub(self.WinningNum, 2, 2), 2)
	end, ShowLottoryNumTime)
	table.insert(self.SkipTimerHandles, Timer4)

	local PlayStopAudio = function()
		-- AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopLoop)
		AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopRotate)
	end

	local Timer5 =  self:RegisterTimer(PlayStopAudio, ShowLottoryNumTime - 0.5)
	table.insert(self.SkipTimerHandles, Timer5)

end

function JumboCactpotPlateView:PlayRotateAnim4()
	-- Play动画

	self.PlateItem4:PlayAnimation(self.PlateItem4.AnimStart)
	local AudioHandle = AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelBeginRotate, function(PlayingID)
		UAudioMgr.SetRTPCValueByPlayingID(JumboUIAudioPath.UISheelRotateRTPCName, 0, PlayingID, 0)
	end)	-- UAudioMgr.SetRTPCValue(JumboUIAudioPath.UISheelRotateRTPCName, 0, 0, nil)
	local AnimStartLength = self.AnimStartLength
	local LoopAnimLength = self.LoopAnimLength
	local LoopCount = JumboCactpotMgr.LoopCount
	local Timer1 = self:RegisterTimer(function() 	
		self.PlateItem4:PlayAnimation(self.PlateItem4.AnimRotateLoop)
		UAudioMgr.SetRTPCValueByHandleID(JumboUIAudioPath.UISheelRotateRTPCName, 1, AudioHandle, 0)
	end, AnimStartLength, LoopAnimLength, LoopCount, nil)
	table.insert(self.SkipTimerHandles, Timer1)

	local ResultAnim = self.PlateItem4[string.format("AnimResult%s", string.sub(self.WinningNum, 1, 1))]
	local EndDelayTime = LoopAnimLength * LoopCount + AnimStartLength
	local Timer2 = self:RegisterTimer(function() 	
		self.PlateItem4:PlayAnimation(ResultAnim)
		AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopLoop)
	end, EndDelayTime)
	table.insert(self.SkipTimerHandles, Timer2)

	local ShowLottoryNumTime = EndDelayTime + self.EndAnimLength - 0.5
	local Timer3 = self:RegisterTimer(function()
		if self.bClickSkipBtn then
			return
		end 	
		JumboCactpotMgr:UpdateRichText(string.sub(self.WinningNum, 1, 1), 1)
	end, ShowLottoryNumTime)
	table.insert(self.SkipTimerHandles, Timer3)

	local Timer4 = self:RegisterTimer(self.OnAnimEnd, ShowLottoryNumTime + 0.5, nil, 1, self)
	table.insert(self.SkipTimerHandles, Timer4)

	local PlayStopAudio = function()
		AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopRotate)
	end

	local Timer5 =  self:RegisterTimer(PlayStopAudio, ShowLottoryNumTime - 0.5)
	table.insert(self.SkipTimerHandles, Timer5)
end

function JumboCactpotPlateView:OnAnimEnd()
	UIUtil.SetIsVisible(self.PanelGoeExchange, true)
	UIUtil.SetIsVisible(self.PanelSkip, false)
	-- JumboCactpotMgr.RichBoughtNum = {}

	local RemainTime = 5
	local DelayShowResultTime = 1
	if JumboCactpotMgr:IsFirstPrize() then
		RemainTime = 8
		UIViewMgr:ShowView(UIViewID.JumboCactpotFirstPrize)
		DelayShowResultTime = 5
	end
	local ServerTime = TimeUtil.GetServerTime()
	local CountTime = RemainTime + ServerTime
	if not UIUtil.IsVisible(self.TextCountDown) then
		UIUtil.SetIsVisible(self.TextCountDown, true)
	end

	local Interval = 0.5
	local CheckCount = RemainTime / Interval + 3
	self.CountDownTimer = self:RegisterTimer(self.UpdateCountDown, 0, Interval, CheckCount, CountTime)

	self:RegisterTimer(function() MsgTipsUtil.ShowInfoTextTips(1, string.format(LSTR(240068), self.WinningNum)) end, DelayShowResultTime) -- 本期的一等奖号码为%s!
end

function JumboCactpotPlateView:UpdateCountDown(CountTime)
	local ServerTime = TimeUtil.GetServerTime()
	local RemainTime = CountTime - ServerTime
	if RemainTime < 0 then
		if UIViewMgr:IsViewVisible(UIViewID.JumboCactpotBuyTipsWin) then
			UIViewMgr:HideView(UIViewID.JumboCactpotBuyTipsWin)
		end
		self:OnBtnGoExchangeClick()
		UIUtil.SetIsVisible(self.TextCountDown, false)
	end

	local CountText = math.floor(RemainTime)
	local NeedText = string.format(LSTR(240069), CountText) -- %ss后前往进行兑换
	self.TextCountDown:SetText(NeedText)
end

--- @type 去兑换
function JumboCactpotPlateView:OnBtnGoExchangeClick()
	self.bClickExchange = true
	UIUtil.SetIsVisible(self.PanelGoeExchange, false)
	JumboCactpotMgr:ShowExchangeRewardPanel()

	local CountDownTimer = self.CountDownTimer
	if CountDownTimer ~= nil then
		self:UnRegisterTimer(CountDownTimer)
	end
	-- self:Hide()
end

--- @type 跳过动画
function JumboCactpotPlateView:OnBtnSkipClick()
	if self.bClickSkipBtn then
		return
	end
	self.bClickSkipBtn = true
	JumboCactpotMgr.RichBoughtNum = {}

	local SkipTimerHandles = self.SkipTimerHandles
	for _, v in pairs(SkipTimerHandles) do
		local Handle = v
		self:UnRegisterTimer(Handle)
	end
	-- self:UnRegisterAllTimer()

	local WinningNum = self.WinningNum
	UIUtil.SetIsVisible(self.MiddlePlate, false)
	self:CreateMiddlePlateView()
	AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopLoop)

	for i = 1, 4 do
		local ItemName = string.format("PausePlateItem%d", i)
		local AnimName = string.format("AnimResult%s", string.sub(WinningNum, i, i)) -- self.EndAnimLength - 0.01
		self[ItemName]:PlayAnimation(self[ItemName][AnimName])
	end
	self:RegisterTimer(function() 
		for i = 4, 1, -1 do
			JumboCactpotMgr:UpdateRichText(string.sub(WinningNum, i, i), i)
		end
		self:OnAnimEnd()
	end, self.EndAnimLength)

	self:RegisterTimer(function()	AudioUtil.LoadAndPlayUISound(JumboUIAudioPath.UISheelStopRotate) end, self.EndAnimLength - 0.5)
end


function JumboCactpotPlateView:CreateMiddlePlateView()
	self.MiddlePlate2 = UIViewMgr:CreateViewByName("JumboCactpot/JumboCactpotPlatePanel_UIBP", nil, self, true)
	if self.MiddlePlate2 then
		self.PanelPlate:AddChildToCanvas(self.MiddlePlate2)
		local Anchor = _G.UE.FAnchors()
		Anchor.Minimum = _G.UE.FVector2D(0, 0)
		Anchor.Maximum = _G.UE.FVector2D(1, 1)
		UIUtil.CanvasSlotSetAnchors(self.MiddlePlate2, Anchor)

		local Margin = _G.UE.FMargin()
		Margin.Top = -10.37037
		UIUtil.CanvasSlotSetOffsets(self.MiddlePlate2, Margin)

		self.PausePlateItem1 = self.MiddlePlate2.JumboCactpotPlateItem
		self.PausePlateItem2 = self.MiddlePlate2.JumboCactpotPlateItem_1
		self.PausePlateItem3 = self.MiddlePlate2.JumboCactpotPlateItem_2
		self.PausePlateItem4 = self.MiddlePlate2.JumboCactpotPlateItem_3
	end
end

--- @type 出现关闭提示
function JumboCactpotPlateView:OnBtnCloseBtnClick()
	local PushReward = JumboCactpotMgr.PushReward
    local LastTerm = PushReward ~= nil and PushReward.LastTerm or JumboCactpotMgr.LastTerm
	local Content = string.format(LSTR(240070), LastTerm) -- 当前正在开%s期仙彩奖，确认退出吗？
	local function Hide()
		self:UnRegisterAllTimer()

		self:Hide()
	end
	if not self.bClickExchange then
		JumboCactpotMgr:ShowCommTips(LSTR(240071), Content, Hide, nil, true) -- 提示
	else	
		self:Hide()
	end
end

--- 动画结束统一回调
function JumboCactpotPlateView:OnAnimationFinished(Animation)
	if Animation == self.AnimIn and not self.bClickSkipBtn then
		self:PlayRotateAnim1()
	end
end

return JumboCactpotPlateView