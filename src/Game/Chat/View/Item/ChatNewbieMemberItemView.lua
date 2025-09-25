---
--- Author: xingcaicao
--- DateTime: 2024-12-24 20:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")

---@class ChatNewbieMemberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnChat UFButton
---@field BtnRemove UFButton
---@field BtnTeamInvite UFButton
---@field CommPlayerItem CommPlayerItemView
---@field ImgInvited UFImage
---@field ProfSlot CommPlayerSimpleJobSlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatNewbieMemberItemView = LuaClass(UIView, true)

function ChatNewbieMemberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnChat = nil
	--self.BtnRemove = nil
	--self.BtnTeamInvite = nil
	--self.CommPlayerItem = nil
	--self.ImgInvited = nil
	--self.ProfSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatNewbieMemberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerItem)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatNewbieMemberItemView:OnInit()
	self.Binders = {
		{ "IsOnline", 			UIBinderValueChangedCallback.New(self, nil, self.OnIsOnlineChanged) },
	}

	self.BindersTeamInviteVM = {
		{ "CurInvitedRoleNum", UIBinderValueChangedCallback.New(self, nil, self.OnCurInvitedRoleChanged) },
	}
end

function ChatNewbieMemberItemView:OnDestroy()

end

function ChatNewbieMemberItemView:OnShow()
	local IsMentor = OnlineStatusUtil.IsMentorMajor()
	-- UIUtil.SetIsVisible(self.BtnRemove, IsMentor, IsMentor)
	UIUtil.SetIsVisible(self.BtnRemove, false)  -- 暂时隐藏移除按钮
end

function ChatNewbieMemberItemView:OnHide()

end

function ChatNewbieMemberItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRemove, self.OnClickButtonRemove)
	UIUtil.AddOnClickedEvent(self, self.BtnTeamInvite, self.OnClickButtonTeamInvite)
	UIUtil.AddOnClickedEvent(self, self.BtnChat, self.OnClickButtonChat)
end

function ChatNewbieMemberItemView:OnRegisterGameEvent()

end

function ChatNewbieMemberItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ItemVM = Params.Data
	self.RoleID = ItemVM.RoleID
	self.ViewModel = ItemVM 

	self:RegisterBinders(ItemVM, self.Binders)
	self:RegisterBinders(TeamInviteVM, self.BindersTeamInviteVM)
end

function ChatNewbieMemberItemView:OnIsOnlineChanged()
	self:UpdateBtnsVisible()
end

function ChatNewbieMemberItemView:OnCurInvitedRoleChanged()
	self:UpdateBtnsVisible()
end

function ChatNewbieMemberItemView:UpdateBtnsVisible()
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

function ChatNewbieMemberItemView:OnClickButtonRemove()
	_G.NewbieMgr:EvictNewbieChannel(self.RoleID)
end

function ChatNewbieMemberItemView:OnClickButtonTeamInvite()
	_G.TeamMgr:InviteJoinTeam(self.RoleID, ProtoCS.Team.Team.ReqSource.ReqSourceNewbieChannel)
end

function ChatNewbieMemberItemView:OnClickButtonChat()
	_G.ChatMgr:GoToPlayerChatView(self.RoleID) 
end

return ChatNewbieMemberItemView