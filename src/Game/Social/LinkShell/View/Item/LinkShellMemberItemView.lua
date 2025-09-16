---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")

local LINKSHELL_IDENTIFY = LinkShellDefine.LINKSHELL_IDENTIFY
local CREATOR = LINKSHELL_IDENTIFY.CREATOR
local MANAGER = LINKSHELL_IDENTIFY.MANAGER
local NORMAL = LINKSHELL_IDENTIFY.NORMAL

---@class LinkShellMemberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChat UFButton
---@field BtnMore UFButton
---@field BtnTeamInvite UFButton
---@field CommPlayerItem CommPlayerItemView
---@field HorizontalBtn UFHorizontalBox
---@field ImgInvited UFImage
---@field MoreNode UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellMemberItemView = LuaClass(UIView, true)

function LinkShellMemberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChat = nil
	--self.BtnMore = nil
	--self.BtnTeamInvite = nil
	--self.CommPlayerItem = nil
	--self.HorizontalBtn = nil
	--self.ImgInvited = nil
	--self.MoreNode = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellMemberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellMemberItemView:OnInit()
	self.Binders = {
		{ "IsOnline", 	UIBinderValueChangedCallback.New(self, nil, self.OnIsOnlineChanged) },
	}

	self.BindersLinkShellVM = {
		{ "CurLinkShellIdentify", UIBinderValueChangedCallback.New(self, nil, self.OnCurLinkShellIdentifyChanged) },
	}

	self.BindersTeamInviteVM = {
		{ "CurInvitedRoleNum", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedInvitedTeamNum) },
	}
end

function LinkShellMemberItemView:OnDestroy()

end

function LinkShellMemberItemView:OnShow()

end

function LinkShellMemberItemView:OnHide()

end

function LinkShellMemberItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnChat, 		self.OnClickButtonChat)
	UIUtil.AddOnClickedEvent(self, self.BtnMore, 		self.OnClickButtonMore)
	UIUtil.AddOnClickedEvent(self, self.BtnTeamInvite, 	self.OnClickButtonTeamInvite)
end

function LinkShellMemberItemView:OnRegisterGameEvent()

end

function LinkShellMemberItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel 

	self:RegisterBinders(ViewModel, self.Binders)
	self:RegisterBinders(LinkShellVM, self.BindersLinkShellVM)
	self:RegisterBinders(TeamInviteVM, self.BindersTeamInviteVM)
end

function LinkShellMemberItemView:UpdateBtnsVisible()
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

function LinkShellMemberItemView:OnIsOnlineChanged()
	self:UpdateBtnsVisible()
end

function LinkShellMemberItemView:OnCurLinkShellIdentifyChanged(MajorIdentify)
	local VM = self.ViewModel
	if nil == VM then
		return
	end

	if MajorUtil.IsMajorByRoleID(VM.RoleID) then
		UIUtil.SetIsVisible(self.HorizontalBtn, false)

		return
	end

	UIUtil.SetIsVisible(self.MoreNode, (MajorIdentify == CREATOR) or (MajorIdentify == MANAGER and VM.Identify == NORMAL))
	UIUtil.SetIsVisible(self.HorizontalBtn, true)
end

function LinkShellMemberItemView:OnValueChangedInvitedTeamNum()
	self:UpdateBtnsVisible()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellMemberItemView:OnClickButtonChat()
	local VM = self.ViewModel
	if VM then
		_G.ChatMgr:GoToPlayerChatView(VM.RoleID)
	end
end

function LinkShellMemberItemView:OnClickButtonMore()
	if LinkShellVM.IsChangingIdentify then
		return
	end

	LinkShellVM:SetCurMoreMemberItem(self, self.ViewModel)
end

function LinkShellMemberItemView:OnClickButtonTeamInvite()
	local VM = self.ViewModel
	if VM then
		local ProtoCS = require("Protocol/ProtoCS")
		_G.TeamMgr:InviteJoinTeam(VM.RoleID, ProtoCS.Team.Team.ReqSource.ReqSourceFriend)
	end
end

return LinkShellMemberItemView