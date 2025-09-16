---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local SocialSettings = require("Game/Social/SocialSettings")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class FriendListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChat UFButton
---@field BtnTeamInvite UFButton
---@field BtnTeamRecruitShare UFButton
---@field CommPlayerItem CommPlayerItemView
---@field HorBoxBtns UFHorizontalBox
---@field ImgInvited UFImage
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field TextFavors UFTextBlock
---@field TextHide UFTextBlock
---@field TextSignature UFTextBlock
---@field ToggleBtnSignature UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendListItemView = LuaClass(UIView, true)

function FriendListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChat = nil
	--self.BtnTeamInvite = nil
	--self.BtnTeamRecruitShare = nil
	--self.CommPlayerItem = nil
	--self.HorBoxBtns = nil
	--self.ImgInvited = nil
	--self.ProfSlot = nil
	--self.TextFavors = nil
	--self.TextHide = nil
	--self.TextSignature = nil
	--self.ToggleBtnSignature = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerItem)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendListItemView:OnInit()
	self.Binders = {
		{ "IsFriend", 	UIBinderValueChangedCallback.New(self, nil, self.OnIsFriendChanged) },
		{ "IsOnline", 	UIBinderValueChangedCallback.New(self, nil, self.OnIsOnlineChanged) },
		{ "Signature", 	UIBinderValueChangedCallback.New(self, nil, self.OnSignatureChanged) },
	}

	self.BindersTeamInviteVM = {
		{ "CurInvitedRoleNum", UIBinderValueChangedCallback.New(self, nil, self.OnCurInvitedRoleChanged) },
	}

	self.TextHide:SetText(_G.LSTR(30055)) -- "显示签名"
end

function FriendListItemView:OnDestroy()

end

function FriendListItemView:OnShow()

end

function FriendListItemView:OnHide()

end

function FriendListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnClickButtonChat)
	UIUtil.AddOnClickedEvent(self, self.BtnTeamInvite, self.OnClickButtonTeamInvite)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnSignature, self.OnToggleStateChangedSignature)
end

function FriendListItemView:OnRegisterGameEvent()

end

function FriendListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local EntryVM = Params.Data
	self.RoleID = EntryVM.RoleID
	self.ViewModel = EntryVM 

	-- 是否隐藏签名
	local IsHideSign = SocialSettings.IsFriendHideSign(EntryVM.RoleID)
	self.ToggleBtnSignature:SetChecked(not IsHideSign, false)

	self:RegisterBinders(EntryVM, self.Binders)
	self:RegisterBinders(TeamInviteVM, self.BindersTeamInviteVM)
end

function FriendListItemView:OnIsFriendChanged(NewValue)
	UIUtil.SetIsVisible(self.HorBoxBtns, NewValue)

	-- 非好友隐藏签名操作
	self.ToggleBtnSignature:SetIsEnabled(NewValue)
end

function FriendListItemView:OnIsOnlineChanged()
	self:UpdateBtnsVisible()
end

function FriendListItemView:OnSignatureChanged(NewValue)
	self.TextSignature:SetText(NewValue or "")
	self.ToggleBtnSignature:SetIsEnabled(not string.isnilorempty(NewValue), true)
end

function FriendListItemView:OnCurInvitedRoleChanged()
	self:UpdateBtnsVisible()
end

function FriendListItemView:UpdateBtnsVisible()
	local VM = self.ViewModel or {}
	local IsOnline = VM.IsOnline
	if IsOnline then
		local IsInvited = false
		local RoleID = VM.RoleID
		if RoleID then
			IsInvited = table.contain(TeamInviteVM.CurInvitedRoleIDs, RoleID) 
		end

		UIUtil.SetIsVisible(self.BtnTeamInvite, not IsInvited, true)
		UIUtil.SetIsVisible(self.ImgInvited, IsInvited)

	else
		UIUtil.SetIsVisible(self.BtnTeamInvite, false)
		UIUtil.SetIsVisible(self.ImgInvited, false)
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function FriendListItemView:OnClickButtonChat()
	_G.ChatMgr:GoToPlayerChatView(self.RoleID)
end

function FriendListItemView:OnClickButtonTeamInvite()
	local ProtoCS = require("Protocol/ProtoCS")
	_G.TeamMgr:InviteJoinTeam(self.RoleID, ProtoCS.Team.Team.ReqSource.ReqSourceFriend)
end

function FriendListItemView:OnToggleStateChangedSignature(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		SocialSettings.DeleteFriendHideSignInfo(self.RoleID)

	else
		SocialSettings.AddFriendHideSignInfo(self.RoleID)
	end
end

return FriendListItemView