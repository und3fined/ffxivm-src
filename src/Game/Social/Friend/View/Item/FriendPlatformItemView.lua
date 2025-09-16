---
--- Author: xingcaicao
--- DateTime: 2025-04-17 19:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local OperationUtil = require("Utils/OperationUtil")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")

local LSTR = _G.LSTR

---@class FriendPlatformItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnQQInviteFriend UFButton
---@field BtnStart UFButton
---@field IconStart UFImage
---@field ImgInviteGrey UFImage
---@field ImgInviteNormal UFImage
---@field ImgOnlineStatus UFImage
---@field PanelQQInvite UFCanvasPanel
---@field PanelStart UFCanvasPanel
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field TextPlatformName URichTextBox
---@field TextPlatformNamePre UFTextBlock
---@field TextPlatformNameSuf UFTextBlock
---@field TextPlayerName URichTextBox
---@field TextServer UFTextBlock
---@field TextStart UFTextBlock
---@field TextState UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendPlatformItemView = LuaClass(UIView, true)

function FriendPlatformItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnQQInviteFriend = nil
	--self.BtnStart = nil
	--self.IconStart = nil
	--self.ImgInviteGrey = nil
	--self.ImgInviteNormal = nil
	--self.ImgOnlineStatus = nil
	--self.PanelQQInvite = nil
	--self.PanelStart = nil
	--self.PlayerHeadSlot = nil
	--self.ProfSlot = nil
	--self.TextPlatformName = nil
	--self.TextPlatformNamePre = nil
	--self.TextPlatformNameSuf = nil
	--self.TextPlayerName = nil
	--self.TextServer = nil
	--self.TextStart = nil
	--self.TextState = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendPlatformItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendPlatformItemView:OnInit()
	self.Binders = {
		{ "PlayerName", 		UIBinderSetText.New(self, self.TextPlayerName) },
		{ "State", 				UIBinderSetText.New(self, self.TextState) },
		{ "ServerName", 		UIBinderSetText.New(self, self.TextServer) },
		{ "IsShowInvitedBtn", 	UIBinderSetIsVisible.New(self, self.PanelQQInvite) },
		{ "IsInvited", 			UIBinderSetIsVisible.New(self, self.ImgInviteGrey) },
		{ "IsInvited", 			UIBinderSetIsVisible.New(self, self.ImgInviteNormal, true) },

		{ "PlatformName", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedPlatformName) },
		{ "HeadInfo", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadInfo) },
		{ "HeadFrameID", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadFrameID) },

		{ "OnlineStatusIcon",	UIBinderSetBrushFromAssetPath.New(self, self.ImgOnlineStatus) },
	}
end

function FriendPlatformItemView:OnDestroy()

end

function FriendPlatformItemView:OnShow()
	if nil ~= self.ViewModel and nil ~= self.ViewModel.LaunchType and self.ViewModel.LaunchType == 2 then
		local Cfg = OperationUtil.GetOperationChannelFuncConfig()
		if nil ~= Cfg and Cfg.IsEnableQQLaunchPrivileges == 0 then
			UIUtil.SetIsVisible(self.PanelStart, false)
		else
			self.TextStart:SetText(_G.LSTR(100004))
			UIUtil.SetIsVisible(self.PanelStart, true, true)
		end
	else
		UIUtil.SetIsVisible(self.PanelStart, false)
	end
end

function FriendPlatformItemView:OnHide()

end

function FriendPlatformItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnQQInviteFriend, self.OnClickButtonQQInvite)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnClickBtnStart)
end

function FriendPlatformItemView:OnRegisterGameEvent()

end

function FriendPlatformItemView:OnRegisterBinder()
	if self.Params == nil or self.Params.Data == nil then
		return
	end

	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel

	local RoleID = ViewModel.RoleID
	self.PlayerHeadSlot:SetBaseInfo(RoleID)

	self:RegisterBinders(ViewModel, self.Binders)
end

function FriendPlatformItemView:OnValueChangedPlatformName(NewValue)
	if string.isnilorempty(NewValue) then
		self.TextPlatformName:SetText("")

		UIUtil.SetIsVisible(self.TextPlatformNamePre, false)
		UIUtil.SetIsVisible(self.TextPlatformNameSuf, false)

	else
		self.TextPlatformName:SetText(NewValue)

		UIUtil.SetIsVisible(self.TextPlatformNamePre, true)
		UIUtil.SetIsVisible(self.TextPlatformNameSuf, true)
	end
end

function FriendPlatformItemView:OnValueChangedHeadInfo(NewValue)
	if NewValue then
		self.PlayerHeadSlot:UpdateIcon()
	end
end

function FriendPlatformItemView:OnValueChangedHeadFrameID(NewValue)
	self.PlayerHeadSlot:UpdateFrame()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function FriendPlatformItemView:OnClickButtonQQInvite()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	if ViewModel.IsInvited then
		MsgTipsUtil.ShowTips(LSTR(30072)) -- "邀请太频繁啦"
		return
	end

	MsgBoxUtil.ShowMsgBoxTwoOp(
		nil, 
		LSTR(30075), --"邀请上线提示"
		LSTR(30076), --"是否发送QQ消息告诉对方，邀请好友上线游戏？"
		function() 
			FriendMgr:InvitePlatformFriendOnline(ViewModel.OpenID, ViewModel.RoleID)
		end,
		nil, LSTR(10003), LSTR(10002)) -- "取 消"、"退 出"
end

function FriendPlatformItemView:OnClickBtnStart()
	_G.AccountUtil.OpenUrl(LoginNewDefine.QQPrivilegeUrl, 1, false, true, "", false)
end

return FriendPlatformItemView