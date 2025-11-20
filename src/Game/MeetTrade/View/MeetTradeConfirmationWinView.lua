---
--- Author: usakizhang
--- DateTime: 2024-12-26 20:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetFrameIcon = require("Binder/UIBinderSetFrameIcon")
local UIBinderSetHead = require("Binder/UIBinderSetHead")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MeetTradeConfirmationWinViewVM = require("Game/MeetTrade/VM/MeetTradeConfirmationWinViewVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local MonthCardMgr = require("Game/MonthCard/MonthCardMgr")
local HelpCfg = require("TableCfg/HelpCfg")
local TipsUtil = require("Utils/TipsUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local MeetTradeMgr = _G.MeetTradeMgr
local LSTR = _G.LSTR
local MeetTradeVM = require("Game/MeetTrade/VM/MeetTradeVM")
---@class MeetTradeConfirmationWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTaxInfo CommInforBtnView
---@field Btnsure CommBtnLView
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field FTextBlock UFTextBlock
---@field FTextBlock_71 UFTextBlock
---@field Icon UFImage
---@field Icon_1 UFImage
---@field ImgArrow01 UFImage
---@field ImgArrow01effect UFImage
---@field ImgArrow02 UFImage
---@field ImgArrow02effect UFImage
---@field ImgCoin UFImage
---@field ImgState UFImage
---@field ImgState_1 UFImage
---@field PanelConfirmed UFCanvasPanel
---@field PanelConfirmed_1 UFCanvasPanel
---@field PanelToBeConfirmed UFCanvasPanel
---@field PanelToBeConfirmed_1 UFCanvasPanel
---@field TableViewSlot UTableView
---@field TableViewSlot_1 UTableView
---@field TextAmount UFTextBlock
---@field TextAmount_1 UFTextBlock
---@field TextConfirmed UFTextBlock
---@field TextConfirmed_1 UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextPlayerName02 UFTextBlock
---@field TextPlayerName_1 UFTextBlock
---@field TextTax URichTextBox
---@field TextTaxCost UFTextBlock
---@field TextToBeConfirmed UFTextBlock
---@field TextToBeConfirmed_1 UFTextBlock
---@field AnimHighArrow UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLeftCheck UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimRightCheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MeetTradeConfirmationWinView = LuaClass(UIView, true)

function MeetTradeConfirmationWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTaxInfo = nil
	--self.Btnsure = nil
	--self.Comm2FrameL_UIBP = nil
	--self.FTextBlock = nil
	--self.FTextBlock_71 = nil
	--self.Icon = nil
	--self.Icon_1 = nil
	--self.ImgArrow01 = nil
	--self.ImgArrow01effect = nil
	--self.ImgArrow02 = nil
	--self.ImgArrow02effect = nil
	--self.ImgCoin = nil
	--self.ImgState = nil
	--self.ImgState_1 = nil
	--self.PanelConfirmed = nil
	--self.PanelConfirmed_1 = nil
	--self.PanelToBeConfirmed = nil
	--self.PanelToBeConfirmed_1 = nil
	--self.TableViewSlot = nil
	--self.TableViewSlot_1 = nil
	--self.TextAmount = nil
	--self.TextAmount_1 = nil
	--self.TextConfirmed = nil
	--self.TextConfirmed_1 = nil
	--self.TextPlayerName = nil
	--self.TextPlayerName02 = nil
	--self.TextPlayerName_1 = nil
	--self.TextTax = nil
	--self.TextTaxCost = nil
	--self.TextToBeConfirmed = nil
	--self.TextToBeConfirmed_1 = nil
	--self.AnimHighArrow = nil
	--self.AnimIn = nil
	--self.AnimLeftCheck = nil
	--self.AnimOut = nil
	--self.AnimRightCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MeetTradeConfirmationWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnTaxInfo)
	self:AddSubView(self.Btnsure)
	self:AddSubView(self.Comm2FrameL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MeetTradeConfirmationWinView:OnInit()
	---TODO 还有一个控件但是重名了
	---创建TableView的适配器
	self.OtherItemsTable = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.MajorItemTable = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot_1)
	self.Binders = {
		{ "RoleTradeItemVMList", 			UIBinderUpdateBindableList.New(self, self.OtherItemsTable) },
		{ "MajorTradeItemVMList", 		UIBinderUpdateBindableList.New(self, self.MajorItemTable) },
		{ "RoleGoldForTradeText", 		UIBinderSetText.New(self, self.TextAmount) },
		{ "MajorGoldForTradeText",      UIBinderSetText.New(self, self.TextAmount_1)},
		{ "MajorGoldTaxText", 		UIBinderSetText.New(self, self.TextTaxCost) },
		{ "MajorGoldTaxRateText", 		UIBinderSetText.New(self, self.TextTax) },
	}
	self.BindersOtherVM = {
		{ "Name", 				UIBinderSetText.New(self, self.TextPlayerName) },
		{ "NickName", 				UIBinderSetText.New(self, self.TextPlayerName02) },
		{ "NickNameVisible", 				UIBinderSetIsVisible.New(self, self.TextPlayerName02) },

	}
	self.BindersMajorVM = {
		{ "Name", 				UIBinderSetText.New(self, self.TextPlayerName_1) },
	}
	self.ViewModel = MeetTradeConfirmationWinViewVM.New()
end

function MeetTradeConfirmationWinView:OnDestroy()
	self.ViewModel = nil
end

function MeetTradeConfirmationWinView:OnShow()
	--- 设置文字
	-- self.BG:SetTitleText(LSTR(1490013)) ---"交易确认"
	-- self.TextPlayerName_2:SetText(LSTR(1490014)) ---"确认与该玩家进行交易吗？"
	self.TextToBeConfirmed:SetText(LSTR(1490015)) ---"待确认..."
	self.TextToBeConfirmed_1:SetText(LSTR(1490015)) ---"待确认..."
	self.TextConfirmed_1:SetText(LSTR(10033)) ---"确认"
	self.TextConfirmed:SetText(LSTR(10033)) ---"确认"
	self.Btnsure.TextContent:SetText(LSTR(10033)) ---"确认"
	-- self.BtnCancel.TextContent:SetText(LSTR(10034)) ---"取消"
	--- 其他几个组件的显示、隐藏和网络、按钮事件有关，直接在相应的事件中处理
	UIUtil.SetIsVisible(self.PanelConfirmed,false)
	UIUtil.SetIsVisible(self.PanelConfirmed_1,false)
	UIUtil.SetIsVisible(self.ImgArrow01effect,false)
	UIUtil.SetIsVisible(self.ImgArrow02effect,false)
	UIUtil.SetIsVisible(self.PanelToBeConfirmed, true)
	UIUtil.SetIsVisible(self.PanelToBeConfirmed_1,true)
	self.Comm2FrameL_UIBP:SetCloseCallback(self,self.OnClickCancelButton)
	self.Comm2FrameL_UIBP:SetTitleText(LSTR(1490066)) ---"交易最终确认"
	self.Btnsure:SetBtnName(LSTR(10033)) ---"等待确认..."
	self.Btnsure:SetIsEnabled(true, true)
	self.IsClickLock = false
	if self.ViewModel then
		self.ViewModel:Update()
	end
	self.BtnTaxInfo:SetButtonStyle(4)
	---根据当前的月卡状态设置Help Info按钮状态
	self.BtnTaxInfo:SetCallback(self, self.OnInforBtnClickHelp)
	MeetTradeMgr:RegisterMeetTradeCountDownCallback(self.ViewID, self, self.OnMeetTradeCountDown)
	self.FTextBlock_71:SetText(LSTR(1490065))
	self:OnMeetTradeCountDown(MeetTradeMgr.TradeStartTime)
end

function MeetTradeConfirmationWinView:OnHide()
	_G.LootMgr:SetDealyState(false)
	MeetTradeMgr:UnRegisterMeetTradeCountDownCallback(self.ViewID)
end

function MeetTradeConfirmationWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btnsure, self.OnClickSureButton)
end

function MeetTradeConfirmationWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MeetTradeConfirmStateChange, self.OnMeetTradeConfirmStateChange)
	self:RegisterGameEvent(EventID.MeetTradeConfirmLock, self.OnMeetTradeConfirmLock)
end

function MeetTradeConfirmationWinView:OnRegisterBinder()
	--玩家数据
	local RoleVM = MeetTradeVM:GetRoleVM()
	local MajorVM = MeetTradeVM:GetMajorVM()
	self:RegisterBinders(RoleVM, self.BindersOtherVM)
	self:RegisterBinders(MajorVM, self.BindersMajorVM)
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function MeetTradeConfirmationWinView:OnClickSureButton()
	--- 发送确认信号
	_G.LootMgr:SetDealyState(true)
	MeetTradeMgr:SendMeetTradeConfirm()
end

function MeetTradeConfirmationWinView:OnClickCancelButton()
	if self.IsClickLock then
		return
	end
	---拉起弹窗
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1490016), LSTR(1490017), self.StopTradeCallback, nil, nil, nil, nil)
end


function MeetTradeConfirmationWinView:StopTradeCallback()
	---关闭自身
	self:Hide()
	if UIViewMgr:IsViewVisible(UIViewID.MeetTradeMainView) then
		---关闭界面后触发中断交易
		UIViewMgr:HideView(UIViewID.MeetTradeMainView, nil, {TradeIsEnd = false})
	end
end

--- @param IsSureForTrade boolean 是否确认交易
function MeetTradeConfirmationWinView:UpdateMajorSureSituation(IsSureForTrade)
	UIUtil.SetIsVisible(self.PanelToBeConfirmed_1, not IsSureForTrade)
	UIUtil.SetIsVisible(self.PanelConfirmed_1, IsSureForTrade)
	---播放动效和动画
	UIUtil.SetIsVisible(self.ImgArrow01effect,true)
	self:PlayAnimation(self.AnimRightCheck)
end

--- @param IsSureForTrade boolean 是否确认交易
function MeetTradeConfirmationWinView:UpdateRoleSureSituation(IsSureForTrade)
	UIUtil.SetIsVisible(self.PanelToBeConfirmed, not IsSureForTrade)
	UIUtil.SetIsVisible(self.PanelConfirmed, IsSureForTrade)
	---播放动效和动画
	UIUtil.SetIsVisible(self.ImgArrow02effect,true)
	self:PlayAnimation(self.AnimLeftCheck)
end

function MeetTradeConfirmationWinView:OnMeetTradeConfirmStateChange(Member)
	if not Member or not Member.RoleID then
		return
	end
	---检查是否是自身的状态
	if Member.RoleID == MajorUtil.GetMajorRoleID() then
		self:SetMajorIsSureForTrade(Member.State == 2)
	else
		self:SetOtherIsSureForTrade(Member.State == 2)
	end
end

function MeetTradeConfirmationWinView:SetMajorIsSureForTrade(IsSure)
	self:UpdateMajorSureSituation(IsSure)
	if IsSure then
		self.Btnsure:SetBtnName(LSTR(1490035)) ---"等待确认..."
		self.Btnsure:SetIsEnabled(false, false)
		--- 如果Major已经确认
		if MeetTradeMgr:GetOtherIsSureForTrade() and IsSure then
			self:PlayAnimation(self.AnimHighArrow)
		end
	end
end

function MeetTradeConfirmationWinView:SetOtherIsSureForTrade(IsSure)
	self:UpdateRoleSureSituation(IsSure)
	--- 如果Major已经确认
	if MeetTradeMgr:GetMajorIsSureForTrade() and IsSure then
		self:PlayAnimation(self.AnimHighArrow)
	end
end

function MeetTradeConfirmationWinView:OnMeetTradeConfirmLock(ItemList)
	local CallBack = function()
		if UIViewMgr:IsViewVisible(UIViewID.MeetTradeConfirmationView) then
            UIViewMgr:HideView(UIViewID.MeetTradeConfirmationView)
		end
		MeetTradeMgr:MeetTradeEnd({TradeIsEnd = false})
		MeetTradeMgr:OpenRewardPanel(ItemList)
		if MeetTradeVM.MajorGoldTax > 0 then
			_G.ChatMgr:AddSysChatMsg(string.format(LSTR(1490068), MeetTradeVM.MajorGoldTax))
		end
	end
	self.IsClickLock = true
	self:RegisterTimer(CallBack, MeetTradeMgr.FinalDelayTime, 0)
end

function MeetTradeConfirmationWinView:OnInforBtnClickHelp()
	local TipsContent = nil
	if MonthCardMgr:GetMonthCardStatus() == true then
		local FilterFunction = function (Index, Value)
			return Index == 2
		end
		local HelpCfgs = HelpCfg:FindAllHelpIDCfg(20)
		local HelpContent = HelpInfoUtil.ParseContent(HelpCfgs)
		local RemainTime = math.floor(MonthCardMgr:GetMonthCardRemainTime() / 86400)
		local RemainTimeText = tostring(RemainTime)
		if RemainTime < 1 then
			RemainTimeText = LSTR(1490053)
		end
		local TaxRate = string.format("%d", MeetTradeVM.MajorGoldTaxRate*100).."%"
		TipsContent = HelpInfoUtil.ParseTextWithPlaceholders(HelpContent, FilterFunction, TaxRate, RemainTimeText)
	else
		local HelpCfgs = HelpCfg:FindAllHelpIDCfg(19)
		TipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(HelpCfgs))
	end

	if TipsContent == nil then
		return
	end
	TipsUtil.ShowInfoTitleTips(TipsContent, self.BtnTaxInfo, _G.UE.FVector2D(0, 15), _G.UE.FVector2D(0, 0))
end
function MeetTradeConfirmationWinView:OnMeetTradeCountDown(CountDownTime)
	local Text = LocalizationUtil.GetCountdownTime(CountDownTime, "mm:ss")
	self.FTextBlock:SetText(Text)
	if CountDownTime <= 10 then
		UIUtil.SetColorAndOpacityHex(self.FTextBlock, "DC5868FF")
	else
		UIUtil.SetColorAndOpacityHex(self.FTextBlock, "FFF5D0FF")
	end
end
return MeetTradeConfirmationWinView