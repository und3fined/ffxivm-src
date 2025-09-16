---
--- Author: xingcaicao
--- DateTime: 2023-09-05 19:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatVM = require("Game/Chat/ChatVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")

local NumStyle = RedDotDefine.RedDotStyle.NumStyle
local SimpleViewSource = PersonInfoDefine.SimpleViewSource

---@class ChatPrivateChannelItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ComRedDot CommonRedDotView
---@field FVerBoxText UFVerticalBox
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field Spacer USpacer
---@field TextName UFTextBlock
---@field TextNoFriendTips UFTextBlock
---@field AnimSelectIn UWidgetAnimation
---@field AnimSelectOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatPrivateChannelItemView = LuaClass(UIView, true)

function ChatPrivateChannelItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ComRedDot = nil
	--self.FVerBoxText = nil
	--self.PlayerHeadSlot = nil
	--self.Spacer = nil
	--self.TextName = nil
	--self.TextNoFriendTips = nil
	--self.AnimSelectIn = nil
	--self.AnimSelectOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatPrivateChannelItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ComRedDot)
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatPrivateChannelItemView:OnInit()
	self.Binders = {
		{ "Name", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedName) },
		{ "IsFriend", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsFriend) },
		{ "IsOnline", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedOnline) },
		{ "HeadInfo", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadInfo) },
		{ "HeadFrameID", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadFrameID) },
	}

	self.BindersChannelVM = {
		{ "RedDotName", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRedDotName) },
	}

	self.BindersChatVM = {
		{ "IsWideMainWin", 	UIBinderSetIsVisible.New(self, self.FVerBoxText) },
		{ "IsWideMainWin", UIBinderSetIsVisible.New(self, self.Spacer, true) },
	}

	self.TextNoFriendTips:SetText(_G.LSTR(50141)) -- "非好友"
end

function ChatPrivateChannelItemView:OnDestroy()

end

function ChatPrivateChannelItemView:OnShow()

end

function ChatPrivateChannelItemView:OnHide()

end

function ChatPrivateChannelItemView:OnRegisterUIEvent()

end

function ChatPrivateChannelItemView:OnRegisterGameEvent()

end

function ChatPrivateChannelItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	local ViewModel = self.Params.Data
	local ChannelID = ViewModel.ChannelID

	self.Channel = ViewModel.Channel
	self.ChannelID = ChannelID 
	self.ViewModel = ViewModel

	local RoleID = ChannelID
	if RoleID then
		self.PlayerHeadSlot:SetBaseInfo(RoleID, SimpleViewSource.Chat)
	end

	local ChannelVM = ChatVM:FindChannelVM(self.Channel, ChannelID)
	if ChannelVM ~= nil then
		self:RegisterBinders(ChannelVM, self.BindersChannelVM)
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self:RegisterBinders(ChatVM, self.BindersChatVM)
end

-- 好友：正常 #d1ba8e  选中#ffeebb   不在线#d1ba8e  50%透明度
-- 非好友：正常 #828282  选中#d5d5d5   不在线#828282  50%透明度
function ChatPrivateChannelItemView:UpdateText( )
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	local Color = "#FFFFFF" 
	local IsSelected = self.IsSelected == true
	local IsFriend = ViewModel.IsFriend
	if IsFriend then
		Color = IsSelected and "#FFEEBB" or "#D1BA8E"
	else
		Color = IsSelected and "#D5D5D5" or "#828282"
	end

	local Opacity = ViewModel.IsOnline and "FF" or "7F"
	Color = Color .. Opacity

	UIUtil.SetColorAndOpacityHex(self.TextName, Color)

	if not IsFriend then
		UIUtil.SetColorAndOpacityHex(self.TextNoFriendTips, Color)
	end
end

function ChatPrivateChannelItemView:OnValueChangedName(NewValue)
	self.TextName:SetText(NewValue or "")

	self:UpdateText()
end

function ChatPrivateChannelItemView:OnValueChangedIsFriend(NewValue)
	UIUtil.SetIsVisible(self.TextNoFriendTips, not NewValue)

	self:UpdateText()
end

function ChatPrivateChannelItemView:OnValueChangedOnline( )
	self:UpdateText()

	local ViewModel = self.ViewModel
	if ViewModel then
		local IsOnline = ViewModel.IsOnline
		self.PlayerHeadSlot:SetIsGreyIcon(self.ChannelID, not IsOnline)
		self.PlayerHeadSlot:SetRenderOpacity(IsOnline and 1 or 0.5)
	end
end

function ChatPrivateChannelItemView:OnValueChangedHeadInfo(NewValue)
	if NewValue then
		self.PlayerHeadSlot:UpdateIcon()
	end
end

function ChatPrivateChannelItemView:OnValueChangedHeadFrameID(NewValue)
	self.PlayerHeadSlot:UpdateFrame()
end

function ChatPrivateChannelItemView:OnValueChangedRedDotName(RedDotName)
	if string.isnilorempty(RedDotName) then
		UIUtil.SetIsVisible(self.ComRedDot, false)
	else
		UIUtil.SetIsVisible(self.ComRedDot, true)
		self.ComRedDot:SetRedDotData(nil, RedDotName, NumStyle)
	end
end

function ChatPrivateChannelItemView:StopCurAnim()
	local Anim = self.CurAnim
	if Anim then
		self:StopAnimation(Anim)
	end
end

function ChatPrivateChannelItemView:OnSelectChanged(IsSelected)
	self.PlayerHeadSlot:SetClickEnable(IsSelected)

	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	self.IsSelected = IsSelected

	-- 名字
	self:UpdateText()

	-- 动效
	self:StopCurAnim()

	local Anim = IsSelected and self.AnimSelectIn or self.AnimSelectOut
	self.CurAnim = Anim 
	self:PlayAnimation(Anim)
end

return ChatPrivateChannelItemView