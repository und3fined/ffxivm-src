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
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local MeetTradeMgr = _G.MeetTradeMgr
local LSTR = _G.LSTR
local MeetTradeVM = require("Game/MeetTrade/VM/MeetTradeVM")
---@class MeetTradeConfirmationWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field Btnsure CommBtnLView
---@field ImgArrow01 UFImage
---@field ImgArrow01effect UFCanvasPanel
---@field ImgArrow02 UFImage
---@field ImgArrow02effect UFCanvasPanel
---@field PanelConfirmed UFCanvasPanel
---@field PanelConfirmed_1 UFCanvasPanel
---@field PanelToBeConfirmed UFCanvasPanel
---@field PanelToBeConfirmed_1 UFCanvasPanel
---@field PlayerHeadSlot PersonInfoPlayerItemView
---@field PlayerHeadSlot_1 PersonInfoPlayerItemView
---@field TextConfirmed UFTextBlock
---@field TextConfirmed_1 UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextPlayerName_1 UFTextBlock
---@field TextPlayerName_2 UFTextBlock
---@field TextToBeConfirmed UFTextBlock
---@field TextToBeConfirmed_1 UFTextBlock
---@field AnimHighArrow UWidgetAnimation
---@field AnimLeftCheck UWidgetAnimation
---@field AnimRightCheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MeetTradeConfirmationWinView = LuaClass(UIView, true)

function MeetTradeConfirmationWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.Btnsure = nil
	--self.ImgArrow01 = nil
	--self.ImgArrow01effect = nil
	--self.ImgArrow02 = nil
	--self.ImgArrow02effect = nil
	--self.PanelConfirmed = nil
	--self.PanelConfirmed_1 = nil
	--self.PanelToBeConfirmed = nil
	--self.PanelToBeConfirmed_1 = nil
	--self.PlayerHeadSlot = nil
	--self.PlayerHeadSlot_1 = nil
	--self.TextConfirmed = nil
	--self.TextConfirmed_1 = nil
	--self.TextPlayerName = nil
	--self.TextPlayerName_1 = nil
	--self.TextPlayerName_2 = nil
	--self.TextToBeConfirmed = nil
	--self.TextToBeConfirmed_1 = nil
	--self.AnimHighArrow = nil
	--self.AnimLeftCheck = nil
	--self.AnimRightCheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MeetTradeConfirmationWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.Btnsure)
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.PlayerHeadSlot_1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MeetTradeConfirmationWinView:OnInit()
	--- 设置文字
	self.BG:SetTitleText(LSTR(1490013)) ---"交易确认"
	self.TextPlayerName_2:SetText(LSTR(1490014)) ---"确认与该玩家进行交易吗？"
	self.TextToBeConfirmed:SetText(LSTR(1490015)) ---"待确认..."
	self.TextToBeConfirmed_1:SetText(LSTR(1490015)) ---"待确认..."
	self.TextConfirmed_1:SetText(LSTR(10033)) ---"确认"
	self.TextConfirmed:SetText(LSTR(10033)) ---"确认"
	self.Btnsure.TextContent:SetText(LSTR(10033)) ---"确认"
	self.BtnCancel.TextContent:SetText(LSTR(10034)) ---"取消"
	---TODO 还有一个控件但是重名了
	self.Binders = {

	}
	self.BindersOtherVM = {
		{ "HeadFrameID", 		UIBinderSetFrameIcon.New(self, self.PlayerHeadSlot.ImgFrame) },
		{ "HeadInfo", 			UIBinderSetHead.New(self, self.PlayerHeadSlot.ImgPlayer) },
		{ "Name", 				UIBinderSetText.New(self, self.TextPlayerName) },
	}

	self.BindersMajorVM = {
		{ "HeadFrameID", 		UIBinderSetFrameIcon.New(self, self.PlayerHeadSlot_1.ImgFrame) },
		{ "HeadInfo", 			UIBinderSetHead.New(self, self.PlayerHeadSlot_1.ImgPlayer) },
		{ "Name", 				UIBinderSetText.New(self, self.TextPlayerName_1) },
	}
end

function MeetTradeConfirmationWinView:OnDestroy()

end

function MeetTradeConfirmationWinView:OnShow()
	--- 其他几个组件的显示、隐藏和网络、按钮事件有关，直接在相应的事件中处理
	UIUtil.SetIsVisible(self.PanelConfirmed,false)
	UIUtil.SetIsVisible(self.PanelConfirmed_1,false)
	UIUtil.SetIsVisible(self.ImgArrow01effect,false)
	UIUtil.SetIsVisible(self.ImgArrow02effect,false)
	self.BG:SetClickCloseCallback(self,self.OnClickCancelButton)
	self.Btnsure:SetBtnName(LSTR(10033)) ---"等待确认..."
	self.Btnsure:SetIsEnabled(true, true)
end

function MeetTradeConfirmationWinView:OnHide()

end

function MeetTradeConfirmationWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btnsure, self.OnClickSureButton)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickCancelButton)
end

function MeetTradeConfirmationWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MeetTradeConfirmStateChange, self.OnMeetTradeConfirmStateChange) 
end

function MeetTradeConfirmationWinView:OnRegisterBinder()
	--玩家数据
	local RoleVM = MeetTradeVM:GetRoleVM()
	local MajorVM = MeetTradeVM:GetMajorVM()
	self:RegisterBinders(RoleVM, self.BindersOtherVM)
	self:RegisterBinders(MajorVM, self.BindersMajorVM)
end

function MeetTradeConfirmationWinView:OnClickSureButton()
	--- 发送确认信号
	MeetTradeMgr:SendMeetTradeConfirm()
end

function MeetTradeConfirmationWinView:OnClickCancelButton()
	---拉起弹窗
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1490016), LSTR(1490017), self.StopTradeCallback, nil, nil, nil, nil)
end


function MeetTradeConfirmationWinView:StopTradeCallback()
	---关闭自身
	self:Hide()
	if UIViewMgr:IsViewVisible(UIViewID.MeetTradeMainView) then
		---关闭界面后触发中断交易
		UIViewMgr:HideView(UIViewID.MeetTradeMainView)
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

return MeetTradeConfirmationWinView