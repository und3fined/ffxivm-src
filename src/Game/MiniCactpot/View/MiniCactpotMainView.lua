---
--- Author: chriswang
--- DateTime: 2022-09-23 14:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MiniCactpotMainVM = require("Game/MiniCactpot/MiniCactpotMainVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local RichTextUtil = require("Utils/RichTextUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

local Utils = require("Game/MagicCard/Module/CommonUtils")
local SaveKey = require("Define/SaveKey")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")

local BuyAccess = {
	FirstBuy = 1,	-- 一次购买
	ReBuy = 2,  -- 再次购买
}

local EventID = _G.EventID
local TimerMgr = _G.TimerMgr
local MiniCactpotMgr = _G.MiniCactpotMgr
local LSTR = _G.LSTR
---@class MiniCactpotMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Arrow01 MiniCactpotArrowItemView
---@field Arrow02 MiniCactpotArrowItemView
---@field Arrow03 MiniCactpotArrowItemView
---@field Arrow04 MiniCactpotArrowItemView
---@field Arrow05 MiniCactpotArrowItemView
---@field Arrow06 MiniCactpotArrowItemView
---@field Arrow07 MiniCactpotArrowItemView
---@field Arrow08 MiniCactpotArrowItemView
---@field Board UFCanvasPanel
---@field BoradBtn UHorizontalBox
---@field BtnBuyOne UFButton
---@field CloseBtn CommonCloseBtnView
---@field FBtn_CloseCheck UFButton
---@field FBtn_Decide UFButton
---@field FBtn_Help CommInforBtnView
---@field FBtn_Mask UFButton
---@field FCanvasPanel_DX UFCanvasPanel
---@field FText_Grid1 UFTextBlock
---@field FText_Grid2 UFTextBlock
---@field FText_Grid3 UFTextBlock
---@field FText_Grid4 UFTextBlock
---@field FText_Grid5 UFTextBlock
---@field FText_Grid6 UFTextBlock
---@field FText_Grid7 UFTextBlock
---@field FText_Grid8 UFTextBlock
---@field FText_Grid9 UFTextBlock
---@field Grid1 UFCanvasPanel
---@field Grid2 UFCanvasPanel
---@field Grid3 UFCanvasPanel
---@field Grid4 UFCanvasPanel
---@field Grid5 UFCanvasPanel
---@field Grid6 UFCanvasPanel
---@field Grid7 UFCanvasPanel
---@field Grid8 UFCanvasPanel
---@field Grid9 UFCanvasPanel
---@field HorizontalBuyOne UFHorizontalBox
---@field HorizontalRemainder UFHorizontalBox
---@field Line1 UFImage
---@field Line2 UFImage
---@field Line3 UFImage
---@field Line4 UFImage
---@field Line5 UFImage
---@field Line6 UFImage
---@field Line7 UFImage
---@field Line8 UFImage
---@field MoneySlot CommMoneySlotView
---@field PanelAgain UFCanvasPanel
---@field PanelBuyOne UFCanvasPanel
---@field PanelMain UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field PopUpBG01 CommonPopUpBGView
---@field RewardPreviewPanel UFCanvasPanel
---@field RichTextRemainder URichTextBox
---@field RichTextRemainder01 URichTextBox
---@field RichTextremainderTimes URichTextBox
---@field RichTextremainderTimes_1 URichTextBox
---@field T1_MiniCactpot UFTextBlock
---@field TableView_Keys UTableView
---@field TableView_List1 UTableView
---@field TableView_List2 UTableView
---@field TextBuyOne UFTextBlock
---@field TextReward UFTextBlock
---@field TextReward_1 UFTextBlock
---@field TextTomorrow UFTextBlock
---@field TextTotal UFTextBlock
---@field TextTotal_1 UFTextBlock
---@field Text_CloseCheck UFTextBlock
---@field Text_Content UFTextBlock
---@field Text_Decide UFTextBlock
---@field Text_Quarter UFTextBlock
---@field Text_Tips UFTextBlock
---@field Ticket UFCanvasPanel
---@field TitleBar UFCanvasPanel
---@field ToggleArrow UToggleGroup
---@field AnimBG UWidgetAnimation
---@field AnimBubbleTipsHidden UWidgetAnimation
---@field AnimBubbleTipsLoop UWidgetAnimation
---@field AnimBubbleTipsShow UWidgetAnimation
---@field AnimControlTips UWidgetAnimation
---@field AnimFirstTipsHidden UWidgetAnimation
---@field AnimFirstTipsLoop UWidgetAnimation
---@field AnimFirstTipsShow UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLines UWidgetAnimation
---@field AnimOpenGrid1 UWidgetAnimation
---@field AnimOpenGrid2 UWidgetAnimation
---@field AnimOpenGrid3 UWidgetAnimation
---@field AnimOpenGrid4 UWidgetAnimation
---@field AnimOpenGrid5 UWidgetAnimation
---@field AnimOpenGrid6 UWidgetAnimation
---@field AnimOpenGrid7 UWidgetAnimation
---@field AnimOpenGrid8 UWidgetAnimation
---@field AnimOpenGrid9 UWidgetAnimation
---@field AnimShake UWidgetAnimation
---@field AnimTickerShake UWidgetAnimation
---@field AnimTicketZoomIn UWidgetAnimation
---@field AnimTicketZoomOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MiniCactpotMainView = LuaClass(UIView, true)

function MiniCactpotMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Arrow01 = nil
	--self.Arrow02 = nil
	--self.Arrow03 = nil
	--self.Arrow04 = nil
	--self.Arrow05 = nil
	--self.Arrow06 = nil
	--self.Arrow07 = nil
	--self.Arrow08 = nil
	--self.Board = nil
	--self.BoradBtn = nil
	--self.BtnBuyOne = nil
	--self.CloseBtn = nil
	--self.FBtn_CloseCheck = nil
	--self.FBtn_Decide = nil
	--self.FBtn_Help = nil
	--self.FBtn_Mask = nil
	--self.FCanvasPanel_DX = nil
	--self.FText_Grid1 = nil
	--self.FText_Grid2 = nil
	--self.FText_Grid3 = nil
	--self.FText_Grid4 = nil
	--self.FText_Grid5 = nil
	--self.FText_Grid6 = nil
	--self.FText_Grid7 = nil
	--self.FText_Grid8 = nil
	--self.FText_Grid9 = nil
	--self.Grid1 = nil
	--self.Grid2 = nil
	--self.Grid3 = nil
	--self.Grid4 = nil
	--self.Grid5 = nil
	--self.Grid6 = nil
	--self.Grid7 = nil
	--self.Grid8 = nil
	--self.Grid9 = nil
	--self.HorizontalBuyOne = nil
	--self.HorizontalRemainder = nil
	--self.Line1 = nil
	--self.Line2 = nil
	--self.Line3 = nil
	--self.Line4 = nil
	--self.Line5 = nil
	--self.Line6 = nil
	--self.Line7 = nil
	--self.Line8 = nil
	--self.MoneySlot = nil
	--self.PanelAgain = nil
	--self.PanelBuyOne = nil
	--self.PanelMain = nil
	--self.PopUpBG = nil
	--self.PopUpBG01 = nil
	--self.RewardPreviewPanel = nil
	--self.RichTextRemainder = nil
	--self.RichTextRemainder01 = nil
	--self.RichTextremainderTimes = nil
	--self.RichTextremainderTimes_1 = nil
	--self.T1_MiniCactpot = nil
	--self.TableView_Keys = nil
	--self.TableView_List1 = nil
	--self.TableView_List2 = nil
	--self.TextBuyOne = nil
	--self.TextReward = nil
	--self.TextReward_1 = nil
	--self.TextTomorrow = nil
	--self.TextTotal = nil
	--self.TextTotal_1 = nil
	--self.Text_CloseCheck = nil
	--self.Text_Content = nil
	--self.Text_Decide = nil
	--self.Text_Quarter = nil
	--self.Text_Tips = nil
	--self.Ticket = nil
	--self.TitleBar = nil
	--self.ToggleArrow = nil
	--self.AnimBG = nil
	--self.AnimBubbleTipsHidden = nil
	--self.AnimBubbleTipsLoop = nil
	--self.AnimBubbleTipsShow = nil
	--self.AnimControlTips = nil
	--self.AnimFirstTipsHidden = nil
	--self.AnimFirstTipsLoop = nil
	--self.AnimFirstTipsShow = nil
	--self.AnimIn = nil
	--self.AnimLines = nil
	--self.AnimOpenGrid1 = nil
	--self.AnimOpenGrid2 = nil
	--self.AnimOpenGrid3 = nil
	--self.AnimOpenGrid4 = nil
	--self.AnimOpenGrid5 = nil
	--self.AnimOpenGrid6 = nil
	--self.AnimOpenGrid7 = nil
	--self.AnimOpenGrid8 = nil
	--self.AnimOpenGrid9 = nil
	--self.AnimShake = nil
	--self.AnimTickerShake = nil
	--self.AnimTicketZoomIn = nil
	--self.AnimTicketZoomOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MiniCactpotMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Arrow01)
	self:AddSubView(self.Arrow02)
	self:AddSubView(self.Arrow03)
	self:AddSubView(self.Arrow04)
	self:AddSubView(self.Arrow05)
	self:AddSubView(self.Arrow06)
	self:AddSubView(self.Arrow07)
	self:AddSubView(self.Arrow08)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.FBtn_Help)
	self:AddSubView(self.MoneySlot)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.PopUpBG01)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MiniCactpotMainView:OnInit()

	self.CellsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_Keys)

	Utils.Init()
	self.WardPreviewAdapter1 = UIAdapterTableView.CreateAdapter(self, self.TableView_List1)
	self.WardPreviewAdapter2 = UIAdapterTableView.CreateAdapter(self, self.TableView_List2)
	self.bInAnimIn = false

end

function MiniCactpotMainView:OnDestroy()

end

function MiniCactpotMainView:CloseTimer()
	if self.DelayTipTimerID then
		TimerMgr:CancelTimer(self.DelayTipTimerID)
		self.DelayTipTimerID = nil
	end
end

function MiniCactpotMainView:OnShow()
	self.BuyAccess = BuyAccess.FirstBuy
	self.OnShowHourTime = TimeUtil.GetServerTimeFormat("%H")
    MiniCactpotMainVM.OwnerJDCoins = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	MiniCactpotMgr:EndInteraction()
	self:CloseTimer()
	self.MoneySlot.BtnMoney:SetIsEnabled(false)
	local JDResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
	self.MoneySlot:UpdateView(JDResID, true, -1, true)
	self.TextBuyOne:SetText(LSTR(230012)) -- 购买1次
	UIUtil.SetIsVisible(self.BoradBtn, true)
	UIUtil.SetIsVisible(self.RewardPreviewPanel, false)
	UIUtil.SetIsVisible(self.Board, false)
	UIUtil.SetIsVisible(self.Ticket, false)
	UIUtil.SetIsVisible(self.PanelMain, true)

	UIUtil.SetIsVisible(self.TextTomorrow, false)
	UIUtil.SetIsVisible(self.FBtn_CloseCheck, true)
	UIUtil.SetIsVisible(self.HorizontalRemainder, true)
	UIUtil.SetIsVisible(self.FBtn_Decide, true, true)
	UIUtil.SetIsVisible(self.Text_Decide, true)
	self.BtnBuyOne:SetIsEnabled(true)
	self.FBtn_CloseCheck:SetIsEnabled(true)

	self.PreviewOpening = false

	--重置到都遮挡每个格子的数字
	for index = 1, 9 do
		self:PlayAnimation(self["AnimOpenGrid" .. index], 0, 1, _G.UE.EUMGSequencePlayMode.Reverse)
	end

	self:PlayAnimation(self.AnimBG, 0, 1)
	UIUtil.TextBlockSetColorAndOpacityHex(self.Text_Decide, "#D9D9D9FF")

	self:UnLockMiniCactpotGameplay()
	MiniCactpotMgr:ChangCostCoin()

	self:InitLSTRText()
end

function MiniCactpotMainView:InitLSTRText()
	self.T1_MiniCactpot:SetText(LSTR(230016)) --仙人微彩
	self.Text_Decide:SetText(LSTR(230017)) -- 决  定
	self.Text_CloseCheck:SetText(LSTR(230018)) -- 再次购买
	self.TextTotal:SetText(LSTR(230021)) -- 合计
	self.TextReward:SetText(LSTR(230022)) -- 奖励

	self.TextTotal_1:SetText(LSTR(230021)) -- 合计
	self.TextReward_1:SetText(LSTR(230022)) -- 奖励
	self.TextTomorrow:SetText(LSTR(230023)) -- 次数耗尽，请明日再参与！
end

function MiniCactpotMainView:OnHide()
	self.bInAnimIn = false
	self:CloseTimer()
	MiniCactpotMainVM:Reset()	--否则  选择一条线的tip就要显示出来了，清空数据
end

function MiniCactpotMainView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleArrow, self.OnToggleGroupStateChanged)
	UIUtil.AddOnClickedEvent(self, self.FBtn_Decide, self.OnDecideBtnClick, nil)
	UIUtil.AddOnClickedEvent(self, self.FBtn_Mask, self.OnMaskBtnClick, nil)
	-- UIUtil.AddOnClickedEvent(self, self.MoneySlot.BtnAdd, self.OnBtnAddClick, nil)

	UIUtil.AddOnClickedEvent(self, self.FBtn_CloseCheck, self.OnPrevieweCloseBtnClick, nil)
	UIUtil.AddOnClickedEvent(self, self.BtnBuyOne, self.OnBtnPurOnceClicked, nil)
	self.CloseBtn:SetCallback(self, self.OnCloseBtnClick)
end

function MiniCactpotMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MiniCactpotOpenRemuner, self.OpenRemunerList)--
	self:RegisterGameEvent(EventID.MiniCactpotAnimOpenGrid, self.PlayAnimCallBack)
	self:RegisterGameEvent(EventID.UpdateScore, self.OnUpdateScoreValue)
	self:RegisterGameEvent(EventID.MiniCactpotBuyOneSuccess, self.OnNotifyBuySuccess)

	
end

function MiniCactpotMainView:OnRegisterBinder()
	local Binders = {
		--多少期
		{ "CurTermStr", UIBinderSetText.New(self, self.Text_Quarter) },
		-- 1-9个格子的数字
		{ "GridNum1", UIBinderSetText.New(self, self.FText_Grid1) },
		{ "GridNum2", UIBinderSetText.New(self, self.FText_Grid2) },
		{ "GridNum3", UIBinderSetText.New(self, self.FText_Grid3) },
		{ "GridNum4", UIBinderSetText.New(self, self.FText_Grid4) },
		{ "GridNum5", UIBinderSetText.New(self, self.FText_Grid5) },
		{ "GridNum6", UIBinderSetText.New(self, self.FText_Grid6) },
		{ "GridNum7", UIBinderSetText.New(self, self.FText_Grid7) },
		{ "GridNum8", UIBinderSetText.New(self, self.FText_Grid8) },
		{ "GridNum9", UIBinderSetText.New(self, self.FText_Grid9) },
		{ "OwnerJDCoins", UIBinderSetTextFormatForMoney.New(self, self.MoneySlot.TextMoneyAmount) },

		{ "CostCoinValue", UIBinderSetText.New(self, self.RichTextRemainder01) },
		{ "CostCoinColor", UIBinderSetColorAndOpacityHex.New(self, self.RichTextRemainder01) },
		{ "CostCoinValue", UIBinderSetText.New(self, self.RichTextRemainder) },
		{ "CostCoinColor2", UIBinderSetColorAndOpacityHex.New(self, self.RichTextRemainder) },

		{ "RemainPurCount", UIBinderSetText.New(self, self.RichTextremainderTimes_1) },
		{ "RemainPurCount", UIBinderSetText.New(self, self.RichTextremainderTimes) },

		{ "ClearGridNums", UIBinderValueChangedCallback.New(self, nil, self.OnClearGridNums) },

		--9个格子上层的这招的顶层panel，隐藏后，所有格子都会显示出来
		{ "GridMaskPanel", UIBinderSetIsVisible.New(self, self.FCanvasPanel_DX) },

		--tips回调：请刮开任意3个格子、还可刮开2个格子、请选择一条线
		{ "OperationTip", UIBinderSetText.New(self, self.Text_Tips) },

		--8个箭头的state，控制ToggleArrow这个group
		{ "ArrowGroupState", UIBinderValueChangedCallback.New(self, nil, self.SetArrowState) },
		{ "ArrowGroupOpacity", UIBinderSetRenderOpacity.New(self, self.ToggleArrow) },

		{ "CellVMList", UIBinderUpdateBindableList.New(self, self.CellsTableViewAdapter) },

		{ "MiniCactpotFinish", UIBinderValueChangedCallback.New(self, nil, self.OnMiniCactpotFinish) },

		{ "AwardVMList1", UIBinderUpdateBindableList.New(self, self.WardPreviewAdapter1) },
		{ "AwardVMList2", UIBinderUpdateBindableList.New(self, self.WardPreviewAdapter2) },
	}

	self:RegisterBinders(MiniCactpotMainVM, Binders)
end

function MiniCactpotMainView:OnClearGridNums()
	for index = 1, 9 do
		self["FText_Grid" .. index]:SetText("")
	end
end

function MiniCactpotMainView:OnCloseBtnClick()
	if  MiniCactpotMgr.bIsInProgress then
		local function OkBtnCallback()
			-- MiniCactpotMgr:OnNetMsgExit(1)
			MiniCactpotMgr:SendMiniCactpotExit()
		end                             -- 提 示		-- 退出竞猜不返还次数和金碟币。\n确定要退出吗？
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(230013), _G.LSTR(230014), OkBtnCallback)
		return
	end
	MiniCactpotMgr:UnRegisterAllTimer()
	self.FBtn_Help.BtnInfor:SetIsEnabled(true)
	self:Hide()
end

function MiniCactpotMainView:OnRsqExitMsg()
	MiniCactpotMgr.bIsInProgress = false
	self.FBtn_Help.BtnInfor:SetIsEnabled(true)
	self:Hide()
end

function MiniCactpotMainView:OnDecideBtnClick()
	--self.MoneySlot:SetbForceNotUpdateVal(true)
	self.FBtn_CloseCheck:SetIsEnabled(true)
	if MiniCactpotMgr:GetArrowIndex() <= 0 then
		self:PlayAnimation(self.AnimFirstTipsShow)
		return
	end
	MiniCactpotMgr:SendFinishReq()
	for index = 1, 9 do
		self:PlayAnimation(self["AnimOpenGrid" .. index], 0, 1, _G.UE.EUMGSequencePlayMode.Reverse)
	end
end

function MiniCactpotMainView:OnMaskBtnClick()
	local OperationTip = MiniCactpotMainVM.OperationTip
	local Str
	if OperationTip == LSTR(230004) then 	 -- 请点击箭头选择一条线
		Str = LSTR(230004) 					 -- 请点击箭头选择一条线
	else
		Str = LSTR(230015)					 -- 请先选择3个格子刮开
	end
	MsgTipsUtil.ShowTips(Str)
end

-- function MiniCactpotMainView:OnBtnAddClick()
-- 	MsgTipsUtil.ShowTips(LSTR("可通过参与机遇临门获取金碟币"))
-- end

--打开报酬一栏
function MiniCactpotMainView:OpenRemunerList()
	if self.PreviewOpening then
		UIUtil.SetIsVisible(self.Ticket, true)

		self:PlayAnimation(self.AnimTicketZoomOut)
		self.FBtn_Help.BtnInfor:SetIsEnabled(true)

		self.PreviewOpening = false
	else
		local IsMinicactpotNoBubbleTip = _G.UE.USaveMgr.GetInt(SaveKey.MinicactpotNoBubbleTip, 0, true)
		if IsMinicactpotNoBubbleTip == 0 then
			_G.UE.USaveMgr.SetInt(SaveKey.MinicactpotNoBubbleTip, 1, true)
		end

		UIUtil.SetIsVisible(self.Ticket, false)
		self:PlayAnimation(self.AnimTicketZoomIn)
		self.FBtn_Help.BtnInfor:SetIsEnabled(false)

		self.PreviewOpening = true
	end

	UIUtil.SetIsVisible(self.RewardPreviewPanel, true)
	UIUtil.SetIsVisible(self.FBtn_CloseCheck, false)
	UIUtil.SetIsVisible(self.PanelAgain, false)
	self:PlayAnimation(self.AnimFirstTipsShow)

end

--开奖后的
function MiniCactpotMainView:OnPrevieweCloseBtnClick()
	self.BuyAccess = BuyAccess.ReBuy
	MiniCactpotMgr:SendMiniCactpotEnterReq()
	self.FBtn_CloseCheck:SetIsEnabled(false)
	self:RegisterTimer(function() self.FBtn_CloseCheck:SetIsEnabled(true) end, 1)

end

--- @type 点击购买一次按钮
function MiniCactpotMainView:OnBtnPurOnceClicked()
	self.BtnBuyOne:SetIsEnabled(false)
	self:RegisterTimer(function() self.BtnBuyOne:SetIsEnabled(true) end, 1)
	MiniCactpotMgr:OnBtnPurOnceClicked()
end

--- @type 点击购买一次购买成功
function MiniCactpotMainView:OnBtnPurOnceSuccess()
	self:BuySucessTip()
	self:UpdateCurTerm()

	UIUtil.SetIsVisible(self.FBtn_Mask, true, true)
	UIUtil.SetIsVisible(self.PanelMain, false)
	UIUtil.SetIsVisible(self.Board, true)
	UIUtil.SetIsVisible(self.Ticket, true)
	self:PlayAnimation(self.AnimIn)
	self.bInAnimIn = true

	local function OnAnimInEnd()
		self.bInAnimIn = false
	end
	self:RegisterTimer(OnAnimInEnd, 1.5)

	self:PlayAnimation(self.AnimFirstTipsShow)
	local function TipAnimLoop()
		self:PlayAnimation(self.AnimFirstTipsLoop, 0, 0, _G.UE.EUMGSequencePlayMode.Forward)
	end
	self:RegisterTimer(TipAnimLoop, 0.8, 0, 1, nil)
end

--- @type 再次购买成功
function MiniCactpotMainView:OnReBuySuccess()
	MiniCactpotMgr.IsFinished = false
	UIUtil.SetIsVisible(self.Ticket, true)
	UIUtil.SetIsVisible(self.FBtn_Mask, true, true)
	UIUtil.SetIsVisible(self.PanelAgain, false)

	-- 点击一个数字
	MiniCactpotMainVM.OperationTip = LSTR(230001) -- 请刮开任意3个格子
	self:PlayAnimation(self.AnimFirstTipsShow)
	local function TipAnimLoop()
		self:PlayAnimation(self.AnimFirstTipsLoop, 0, 0, _G.UE.EUMGSequencePlayMode.Forward)
	end
	self:RegisterTimer(TipAnimLoop, 0.73, 0.63, 1, nil)

	if self.PreviewOpening then
		self:PlayAnimation(self.AnimTicketZoomOut)
		self.FBtn_Help.BtnInfor:SetIsEnabled(true)

		--self:PlayAnimation(self.AnimFirstTipsShow)
		self.PreviewOpening = false
	else
		self:PlayAnimation(self.AnimTicketZoomIn)
		self.FBtn_Help.BtnInfor:SetIsEnabled(false)

		self.PreviewOpening = true
	end
	local function HideRewardPanel()
		UIUtil.SetIsVisible(self.RewardPreviewPanel, false)
	end
	self:RegisterTimer(HideRewardPanel, 0.33, 0, 1, nil)

	self:UpdateCurTerm()
	
	self:PlayAnimation(self.AnimIn)
end

--- @type 购买成功网络事件回调
function MiniCactpotMainView:OnNotifyBuySuccess()
	if self.BuyAccess == BuyAccess.FirstBuy then
		self:OnBtnPurOnceSuccess()
	elseif self.BuyAccess == BuyAccess.ReBuy then
		self:OnReBuySuccess()
	end
	MiniCactpotMgr:ResetWait()
end

--选择一个格子、选择一条线
-- function MiniCactpotMainView:ShowControlTip(TipContent)
-- 	if TipContent == "" or TipContent == nil then
-- 		return
-- 	end

-- 	self.Text_Content:SetText(TipContent)
-- 	self:PlayAnimation(self.AnimControlTips)
-- end

--Index是是parent下的0-7
function MiniCactpotMainView:SetArrowState(ArrowInfo)
	if ArrowInfo.Index < 0 then
		if ArrowInfo.State == MiniCactpotMainVM.ArrowState.Gray then		--不可点击
			self.ToggleArrow:SetCheckedIndex(-1)

			for index = 1, 8 do
				local Arrow = self["Arrow0" .. index]
				if Arrow then
					Arrow:PlayAnimation(Arrow.AnimToGray)
				end
			end
		elseif ArrowInfo.State == MiniCactpotMainVM.ArrowState.Normal then	--可以点选   选择一条线
			for index = 1, 8 do
				local Arrow = self["Arrow0" .. index]
				if Arrow then
					Arrow:PlayAnimation(Arrow.AnimToNormal)
				end
			end
		elseif ArrowInfo.State == MiniCactpotMainVM.ArrowState.Locked then
			self.ToggleArrow:SetCheckedIndex(-1)

			local SelectArrowIdx = MiniCactpotMgr:GetArrowIndex()
			for index = 1, 8 do
				local i = index
				local Arrow = self["Arrow0" .. i]

				if Arrow.Index ~= SelectArrowIdx then
					Arrow:PlayAnimation(Arrow.AnimToGray)
				else
					self.ToggleArrow:SetLocked(self.LastLockIndex, true)
				end
			end
		end
		return
	end

	local ArrowName = "Arrow0" .. ArrowInfo.CtrlIdex
	local Arrow = self[ArrowName]
	if ArrowInfo.State == MiniCactpotMainVM.ArrowState.Locked then	--确定了那条线
		-- self.ToggleArrow:SetCheckedIndex(-1)
		self.ToggleArrow:SetLocked(ArrowInfo.Index, true)
		self.LastLockIndex = ArrowInfo.Index		--是parent下的0-7

		if Arrow then
			Arrow:PlayAnimation(Arrow.AnimSelectLight)
		end
	elseif ArrowInfo.State == MiniCactpotMainVM.ArrowState.AwardView then	--预览奖励
		self.ToggleArrow:SetCheckedIndex(ArrowInfo.Index, false)
		self.ToggleArrow:SetLocked(self.LastLockIndex, true)

		if Arrow then
			Arrow:PlayAnimation(Arrow.AnimToNormal)
		end
	end
end

--pcw todo 箭头的umg gray normal的要干掉，如果group使用ok的话
function MiniCactpotMainView:OnToggleGroupStateChanged(ToggleGroup, ToggleButton, Index, State)
	if MiniCactpotMgr.IsFinished then
		MiniCactpotMainVM.ArrowGroupState = {Index = -1, State = MiniCactpotMainVM.ArrowState.Locked}
		return
	end

	if MiniCactpotMgr.CanClickCellNum > 0 then
		--开完格子或者开奖后才可以点击
		self.ToggleArrow:SetCheckedIndex(-1)

		self.FBtn_Decide:SetIsEnabled(false)

		return
	end

	local ArrowIdx = Index
	local Arrow = self.ToggleArrow:GetChildAt(Index)
	if Arrow then
		ArrowIdx = Arrow.Index
	end

	FLOG_INFO("MiniCactpot ArrowToggleGroup NameIndex:%d, Svr ArrowIdx:%d", Index, ArrowIdx)

	--出结果后，是选择奖励预览的线，而不是选择一条线进行开奖了
	if MiniCactpotMgr:GetIsFinished() then
		-- local SelectIdx = MiniCactpotMgr:GetArrowIndex()
		-- if SelectIdx ~= ArrowIdx then	--得选择非开奖的线才可以预览

		-- 	-- --设置3个为Check状态
		-- 	-- for index = 1, 9 do
		-- 	-- 	local CellVM = MiniCactpotMainVM.CellVMList:Get(index)
		-- 	-- 	CellVM.CellIsChecked = false
		-- 	-- end


		-- 	MiniCactpotMainVM.ArrowGroupState =
		-- 		{Index = Index, State = MiniCactpotMainVM.ArrowState.AwardView, CtrlIdex = ArrowIdx}

		-- 	--预览的线是ArrowIdx
		-- 	-- local CellIdxList = MiniCactpotMainVM.Arrow2CellList[ArrowIdx]
		-- 	-- for idx = 1, #CellIdxList do
		-- 	-- 	local CellVM = MiniCactpotMainVM.CellVMList:Get(CellIdxList[idx])
		-- 	-- 	CellVM.CellIsChecked = true
		-- 	-- end

		-- 	MiniCactpotMainVM:OnPreviewArrow(ArrowIdx)
		-- end
	else
		MiniCactpotMgr:SetArrowIndex(ArrowIdx)
		MiniCactpotMgr:ShowSelectLineTip()
		self.FBtn_Decide:SetIsEnabled(true)
		UIUtil.SetIsVisible(self.FBtn_Mask, false)
		UIUtil.TextBlockSetColorAndOpacityHex(self.Text_Decide, "#F0E3CFFF")

		--设置3个为Check状态
		for index = 1, 9 do
			local CellVM = MiniCactpotMainVM.CellVMList:Get(index)
			CellVM.CellIsChecked = false
		end

		MiniCactpotMainVM:OnSelectArrow(ArrowIdx)

		MiniCactpotMainVM.ArrowGroupState =
			{Index = Index, State = MiniCactpotMainVM.ArrowState.Locked, CtrlIdex = ArrowIdx}
	end
end

function MiniCactpotMainView:OnMiniCactpotFinish(FinishData)
	if not FinishData.IsFinish then
		return
	end

	--self.MoneySlot:SetbForceNotUpdateVal(false)

	self.FBtn_Decide:SetIsEnabled(false)
	UIUtil.SetIsVisible(self.TextTomorrow, false)
	UIUtil.SetIsVisible(self.FBtn_CloseCheck, true, true)
	MiniCactpotMainVM.ArrowGroupState = {Index = -1, State = MiniCactpotMainVM.ArrowState.Locked}

	for index = 1, 9 do
		local CellVM = MiniCactpotMainVM.CellVMList:Get(index)
		CellVM.CellIsChecked = false
	end

	self.PreviewOpening = true

	self:PlayAnimation(self.AnimFirstTipsHidden)

	self:UpdateCurTerm()
	self:RegisterTimer(self.ShowBugAgainTips, 3, 0, 1, self)
end

function MiniCactpotMainView:UpdateCurTerm()
	local OnFinishCurHour = TimeUtil.GetServerTimeFormat("%H")
	local TimeTable = {
		PreUpdateTime = 4,
		UpdateTime = 5
	} 
	if tonumber(self.OnShowHourTime) == TimeTable.PreUpdateTime and tonumber(OnFinishCurHour) == TimeTable.UpdateTime then
		MiniCactpotMgr:SendMiniCactpotInfoReq(false)
	end
end

function MiniCactpotMainView:ShowBugAgainTips()
	UIUtil.SetIsVisible(self.PanelAgain, true)
	if MiniCactpotMgr.MiniCactpotInfo.LeftChance <= 0 then
		UIUtil.SetIsVisible(self.TextTomorrow, true)
		UIUtil.SetIsVisible(self.FBtn_CloseCheck, false)
		UIUtil.SetIsVisible(self.HorizontalRemainder, false)
		UIUtil.SetIsVisible(self.FBtn_Decide, false) --
		UIUtil.SetIsVisible(self.Text_Decide, false)
		local RichText = RichTextUtil.GetText("0", "#af4c58")
		MiniCactpotMainVM.RemainPurCount = string.format(LSTR(230006), RichText, MiniCactpotMgr.MiniCactpotInfo.MaxChance) -- "(剩余购买次数: %s/%s)"
	else
		UIUtil.SetIsVisible(self.TextTomorrow, false)
		UIUtil.SetIsVisible(self.FBtn_CloseCheck, true, true)
		UIUtil.SetIsVisible(self.HorizontalRemainder, true)
		UIUtil.SetIsVisible(self.FBtn_Decide, true, true)
		UIUtil.SetIsVisible(self.Text_Decide, true)

	end
end

function MiniCactpotMainView:ShowAwardBtnBubbleTip()
	self:PlayAnimation(self.AnimBubbleTipsShow)
	self:PlayAnimation(self.AnimBubbleTipsLoop, 0, 0)
end

function MiniCactpotMainView:HideAwardBtnBubbleTip()
	self:PlayAnimation(self.AnimBubbleTipsHidden)
	self:StopAnimation(self.AnimBubbleTipsLoop)
end

function MiniCactpotMainView:PlayAnimCallBack(AnimName)
	if AnimName == "" or not AnimName then
		return
	end

	local Anim = self[AnimName]
	if Anim then
		self:PlayAnimation(Anim)
	end
end

function MiniCactpotMainView:OnUpdateScoreValue(ScoreID)
    if ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE and not self.MoneySlot.bForceNotUpdateVal then
        MiniCactpotMgr:ChangCostCoin()
    end
end

 --- @type 玩法解锁
function MiniCactpotMainView:UnLockMiniCactpotGameplay()
	local function ShowMiniCactpotOpenThreeBoxTutorial(Params)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.UnlockGameplay--新手引导触发类型
        EventParams.Param1 = TutorialDefine.GameplayType.MiniCactpot
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowMiniCactpotOpenThreeBoxTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

 --- @type 玩法解锁
 function MiniCactpotMainView:BuySucessTip()
	local function ShowMiniCactpotBuySucessTutorial(Params)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
        EventParams.Param1 = TutorialDefine.GameplayType.MiniCactpot
        EventParams.Param2 = TutorialDefine.GamePlayStage.MiniCactpotOpenThreeBoxNoMoney
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
	FLOG_INFO("Show Select Line Tip")
    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowMiniCactpotBuySucessTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end


return MiniCactpotMainView