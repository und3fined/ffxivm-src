---
--- Author: xingcaicao
--- DateTime: 2025-03-31 18:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatVM = require("Game/Chat/ChatVM")
local TimeUtil = require("Utils/TimeUtil")
local ChatUtil = require("Game/Chat/ChatUtil")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR

---@class SidebarPrivateChatWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommBtnSView
---@field BtnCollapse UFButton
---@field BtnGoToChat CommBtnSView
---@field EFF_ProBarLight UFImage
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field ProBarCD UProgressBar
---@field RichTextMsg URichTextBox
---@field RichTextName URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimProBarLight UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarPrivateChatWinView = LuaClass(UIView, true)

function SidebarPrivateChatWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnCollapse = nil
	--self.BtnGoToChat = nil
	--self.EFF_ProBarLight = nil
	--self.PlayerHeadSlot = nil
	--self.ProBarCD = nil
	--self.RichTextMsg = nil
	--self.RichTextName = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimProBarLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarPrivateChatWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnGoToChat)
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarPrivateChatWinView:OnInit()
	self.BindersChatVM = {
		{ "LatestPrivateChatMsgItemVM", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMsgItemVM) },
	}

	self.BindersRoleVM = {
		{ "Name", 		UIBinderSetText.New(self, self.RichTextName) },
		{ "HeadInfo", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadInfo) },
		{ "HeadFrameID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadFrameID) },
	}

	self.BtnClose:SetText(LSTR(10066)) -- "关  闭"
	self.BtnGoToChat:SetText(LSTR(10025)) -- "查  看"
end

function SidebarPrivateChatWinView:OnDestroy()

end

function SidebarPrivateChatWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	--倒计时
	self.CountDown = Params.CountDown or 0

	local StartTime = Params.StartTime or 0
	self.LossTime = TimeUtil.GetServerTime() - StartTime
	if self.LossTime >= self.CountDown then
		self.ProBarCD:SetPercent(0)
		self:CloseUI()
		return
	end

	self:SetProBarCD(self.LossTime)
	self:RegisterTimer(self.OnTimer, 0, 0.01, 0)
end

function SidebarPrivateChatWinView:OnHide()

end

function SidebarPrivateChatWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCollapse,	self.OnClickButtonCollapse)
	UIUtil.AddOnClickedEvent(self, self.BtnGoToChat,self.OnClickButtonGoToChat)
	UIUtil.AddOnClickedEvent(self, self.BtnClose,	self.OnClickButtonClose)
end

function SidebarPrivateChatWinView:OnRegisterGameEvent()

end

function SidebarPrivateChatWinView:OnRegisterBinder()
	self:RegisterBinders(ChatVM, self.BindersChatVM)
end

function SidebarPrivateChatWinView:OnTimer( _, ElapsedTime )
	local CountDown = self.CountDown
	if nil == CountDown or CountDown <= 0 then
		return
	end

	ElapsedTime = (self.LossTime or 0) + ElapsedTime
	if ElapsedTime >= CountDown then
		self:CloseUI()
		return
	end

	self:SetProBarCD(ElapsedTime)
end

function SidebarPrivateChatWinView:SetProBarCD( ElapsedTime )
	local Percent  = math.clamp(1 - ElapsedTime / self.CountDown, 0, 1)
	self.ProBarCD:SetPercent(Percent)

	self:PlayAnimationTimeRange(self.AnimProBarLight, Percent, Percent, 1, nil, 0, false)
end


function SidebarPrivateChatWinView:CloseUI()
	SidebarMgr:TryOpenSidebarMainWin()
	ChatVM:ClearSidebarItem()

	self:Hide()
end

function SidebarPrivateChatWinView:OnValueChangedMsgItemVM(MsgItemVM)
	if nil == MsgItemVM then
		return
	end

	local RoleID = MsgItemVM.Sender
	if nil == RoleID then
		return
	end

	_G.RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
		if nil == RoleVM then
			return
		end	

		self.RoleID = RoleID

		-- 头像
		self.PlayerHeadSlot:SetInfo(RoleID)

		-- 名字
		self.RichTextName:SetText(RoleVM.Name or "")

		-- 消息内容 
		local Content = ChatUtil.GetChatContent(MsgItemVM)
		self.RichTextMsg:SetText(Content or "")
	end)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function SidebarPrivateChatWinView:OnClickButtonCollapse()
	SidebarMgr:TryOpenSidebarMainWin()

	self:Hide()
end

function SidebarPrivateChatWinView:OnClickButtonGoToChat()
	_G.ChatMgr:GoToPlayerChatView(self.RoleID)

	self:CloseUI()
end

function SidebarPrivateChatWinView:OnClickButtonClose()
	self:CloseUI()
end

return SidebarPrivateChatWinView
