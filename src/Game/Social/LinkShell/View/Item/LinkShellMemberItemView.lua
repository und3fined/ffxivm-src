---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
local TeamRecruitMgr = require("Game/TeamRecruit/TeamRecruitMgr")
local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")

local LINKSHELL_IDENTIFY = LinkShellDefine.LINKSHELL_IDENTIFY
local CREATOR = LINKSHELL_IDENTIFY.CREATOR
local MANAGER = LINKSHELL_IDENTIFY.MANAGER
local NORMAL = LINKSHELL_IDENTIFY.NORMAL

---@class LinkShellMemberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChat UFButton
---@field BtnMore UFButton
---@field BtnTeamInvite UFButton
---@field BtnTeamRecruitShare UFButton
---@field CommPlayerItem CommPlayerItemView
---@field HorizontalBtn UFHorizontalBox
---@field ImgSuc UFImage
---@field MoreNode UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellMemberItemView = LuaClass(UIView, true)

function LinkShellMemberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChat = nil
	--self.BtnMore = nil
	--self.BtnTeamInvite = nil
	--self.BtnTeamRecruitShare = nil
	--self.CommPlayerItem = nil
	--self.HorizontalBtn = nil
	--self.ImgSuc = nil
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
	UIUtil.AddOnClickedEvent(self, self.BtnTeamRecruitShare, self.OnClickButtonRecruitShare)
end

function LinkShellMemberItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.TeamRecruitStateChanged, self.OnEventMsgTeamRecruitStateChanged)
    self:RegisterGameEvent(EventID.TeamRecruitShareToPlayerSuc, self.OnEventMsgShareTeamRecruitToPlayerSuc)
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
	local BtnInvitedVisible = false 
	local BtnRecruitVisible = false
	local ImgSucVisible = false 

	local VM = self.ViewModel or {}
	local IsOnline = VM.IsOnline
	if IsOnline then
		local RoleID = VM.RoleID

		if TeamRecruitMgr:IsRecruiting() then -- 招募中
			local IsShared = RoleID and table.contain(TeamRecruitVM.CurSharedRoleIDs, RoleID) 
			BtnRecruitVisible = not IsShared
			ImgSucVisible = IsShared
		else
			local IsInvited = RoleID and table.contain(TeamInviteVM.CurInvitedRoleIDs, RoleID) 
			BtnInvitedVisible = not IsInvited 
			ImgSucVisible = IsInvited
		end
	end

	UIUtil.SetIsVisible(self.BtnTeamInvite, BtnInvitedVisible, BtnInvitedVisible)
	UIUtil.SetIsVisible(self.BtnTeamRecruitShare, BtnRecruitVisible, BtnRecruitVisible)
	UIUtil.SetIsVisible(self.ImgSuc, ImgSucVisible)
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
---Client Event CallBack 

function LinkShellMemberItemView:OnEventMsgTeamRecruitStateChanged()
	self:UpdateBtnsVisible()
end

function LinkShellMemberItemView:OnEventMsgShareTeamRecruitToPlayerSuc()
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

function LinkShellMemberItemView:OnClickButtonRecruitShare()
	local VM = self.ViewModel
	if VM then
		TeamRecruitUtil.ShareSelfRecruitToPlayer(VM.RoleID)
	end
end

return LinkShellMemberItemView