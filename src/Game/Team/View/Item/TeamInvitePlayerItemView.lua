---
--- Author: xingcaicao
--- DateTime: 2023-05-11 20:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TeamDefine = require("Game/Team/TeamDefine")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local EventID = require("Define/EventID")
local InviteParentListItemVM = require("Game/Team/VM/InviteParentListItemVM")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIBinderSetIsVisiblePred = require("Binder/UIBinderSetIsVisiblePred")
local UIBinderSetText = require("Binder/UIBinderSetText")

local InviteItemBgEnum = TeamDefine.InviteItemBgEnum

---@class TeamInvitePlayerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInvite UFButton
---@field BtnQQ UFButton
---@field BtnShare UFButton
---@field BtnWeChat UFButton
---@field FCanvasPanel_0 UFCanvasPanel
---@field ImgBg UFImage
---@field ImgForbidden UFImage
---@field ImgInvited UFImage
---@field ImgOnlineStatus UFImage
---@field ImgServer UFImage
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field SizeBoxServer USizeBox
---@field TextLocation UFTextBlock
---@field TextPlayerName URichTextBox
---@field TextState UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamInvitePlayerItemView = LuaClass(UIView, true)

function TeamInvitePlayerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInvite = nil
	--self.BtnQQ = nil
	--self.BtnShare = nil
	--self.BtnWeChat = nil
	--self.FCanvasPanel_0 = nil
	--self.ImgBg = nil
	--self.ImgForbidden = nil
	--self.ImgInvited = nil
	--self.ImgOnlineStatus = nil
	--self.ImgServer = nil
	--self.PlayerHeadSlot = nil
	--self.ProfSlot = nil
	--self.SizeBoxServer = nil
	--self.TextLocation = nil
	--self.TextPlayerName = nil
	--self.TextState = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamInvitePlayerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamInvitePlayerItemView:OnInit()
	self.BtnInviteShowBinder = UIBinderSetIsVisiblePred.NewByPred(function()
		if self.ViewModel then
			local RVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
			if RVM and RVM.IsOnline then
				local Status = self.ViewModel.InviteDisplayStatus
				return Status == InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.NOT_DISPLAY or Status == InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.NO_INVITE
			end
		end
	end, self, self.BtnInvite, nil, true)

	self.ForbidShowBinder = UIBinderSetIsVisiblePred.NewByPred(function()
		if self.ViewModel then
			local RVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
			local Status = self.ViewModel.InviteDisplayStatus
			return Status == InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.HAS_TEAM or Status == InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.INVITED or RVM == nil or not RVM.IsOnline
		end
	end, self, self.ImgForbidden)

	self.InviteVMBinders = {
		{ "CurInvitedRoleNum", UIBinderValueChangedCallback.New(self, nil, self.OnCurInvitedRoleChanged) },
	}

	self.ItemVMBinders = {
		{ "ProfID", 			UIBinderValueChangedCallback.New(self, nil, self.OnProfIDChanged) },
		{ "InviteDisplayStatus", UIBinderValueChangedCallback.New(self, nil, self.OnInviteDisplayStatusChanged)},
		{ "InviteDisplayStatus", self.BtnInviteShowBinder},
		{ "InviteDisplayStatus", self.ForbidShowBinder},
		{ "ReuseType",			UIBinderValueChangedCallback.New(self, nil, self.OnReuseTypeChanged) },
		{ "Name", 				UIBinderSetText.New(self, self.TextPlayerName) },
	}

	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	self.RoleVMBinders = {
		{ "OnlineStatusIcon", 	UIBinderSetImageBrush.New(self, self.ImgOnlineStatus) },
		{ "CurWorldID", TeamRecruitUtil.NewCrossServerShowBinder(nil, self, self.SizeBoxServer)},
		{ "IsOnline", UIBinderValueChangedCallback.New(self, nil, function(_, V)
			UIUtil.SetRenderOpacity(self.FCanvasPanel_0, V and 1 or 0.5)
		end)},
		{ "IsOnline", self.BtnInviteShowBinder},
		{ "IsOnline", self.ForbidShowBinder},
	}
	TeamRecruitUtil.AddRoleLocationShowBinders(self.RoleVMBinders, function()
		return self:GetRoleID()
	end, self, self.TextLocation)
end

function TeamInvitePlayerItemView:OnShow()
	self:OnCurInvitedRoleChanged()
end

function TeamInvitePlayerItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnInvite, self.OnClickButtonInvite)
end

function TeamInvitePlayerItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamInviteUpdate, function()
		self:LocalUpdateInviteStatus()
	end)
	self:RegisterGameEvent(EventID.TeamJoinReject, function (_, RoleID)
		if RoleID == self.ViewModel.RoleID then
			self.ViewModel:UpadateInviteStatus()
		end
	end)

	self:RegisterGameEvent(EventID.TeamInviteJoin, function(_, RoleID)
		if RoleID == self:GetRoleID() then
			self.ViewModel:UpadateInviteStatus(InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.INVITE_SELF)
		end
	end)

	self:RegisterGameEvent(EventID.OnlineStatusChangedInVision, function(_, Params)
		if self:GetRoleID() and self:GetRoleID() == ActorUtil.GetRoleIDByEntityID(Params.EntityID) then
			local RoleVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
			if RoleVM then
				RoleVM:SetOnlineStatus(Params.OnlineStatus)
			end
		end
	end)

	self:RegisterGameEvent(EventID.OnlineStatusMajorChanged, function(_, NewStatus, OldStatus)
		if self:GetRoleID() and self:GetRoleID() == MajorUtil.GetMajorRoleID() then
			local RoleVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
			if RoleVM then
				RoleVM:SetOnlineStatus(NewStatus)
			end
		end
	end)
end

function TeamInvitePlayerItemView:OnRegisterTimer()
	self:RegisterTimer(function()
		self:LocalUpdateInviteStatus()
	end, 0, 1, 0)
end

function TeamInvitePlayerItemView:LocalUpdateInviteStatus()
	self.ViewModel:UpadateInviteStatus()
end

function TeamInvitePlayerItemView:OnRegisterBinder()
	self.ViewModel = self.Params and self.Params.Data or nil
	if self.ViewModel == nil then
		return
	end

	--职业
	self.ProfSlot:SetParams({ Data = self.ViewModel.ProfInfoVM })
	--玩家头像
	self.PlayerHeadSlot:SetInfo(self:GetRoleID())

	self:RegisterBinders(self.ViewModel, self.ItemVMBinders)
	self:RegisterBinders(TeamInviteVM, self.InviteVMBinders)

	local RVM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true) 
	if RVM then
		self:RegisterBinders(RVM, self.RoleVMBinders)
	end
	
end

function TeamInvitePlayerItemView:OnInviteDisplayStatusChanged(Status)
	if Status == InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.NO_INVITE then
		UIUtil.SetIsVisible(self.ImgInvited, false)
	elseif Status == InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.INVITE_SELF then
		UIUtil.SetIsVisible(self.ImgInvited, true)
	elseif Status == InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.INVITED then
		UIUtil.SetIsVisible(self.ImgInvited, false)
	elseif Status == InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.HAS_TEAM then
		UIUtil.SetIsVisible(self.ImgInvited, false)
	elseif Status == InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.NOT_DISPLAY then
		UIUtil.SetIsVisible(self.ImgInvited, false)
	elseif Status ==  InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.SHARED then
		UIUtil.SetIsVisible(self.ImgInvited, true)
	end
end

function TeamInvitePlayerItemView:OnProfIDChanged(ProfID)
	if nil == ProfID then
		return
	end

    local ProfFunc = RoleInitCfg:FindFunction(ProfID)
	if nil == ProfFunc then
		return
	end

	local Bg = InviteItemBgEnum[ProfFunc]
	if string.isnilorempty(Bg) then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgBg, Bg)
end

function TeamInvitePlayerItemView:OnCurInvitedRoleChanged()
	if self.ViewModel then
		self.ViewModel:UpadateInviteStatus(table.contain(TeamInviteVM.CurInvitedRoleIDs, self:GetRoleID()) and InviteParentListItemVM.DEF_INVITE_DISPLAY_STATUS.INVITE_SELF or nil)
	end
end


-------------------------------------------------------------------------------------------------------
---Component CallBack

function TeamInvitePlayerItemView:OnClickButtonInvite()
	if self.ViewModel then
		if self.ViewModel.ReuseType == TeamDefine.InviteReuseType.INVITE or self.ViewModel.ReuseType == nil then
			self:Invite()
		elseif self.ViewModel.ReuseType == TeamDefine.InviteReuseType.SHARE then
			self:ShareRecruit()
		end
	end
end

function TeamInvitePlayerItemView:Invite()
	_G.EventMgr:SendEvent(EventID.TeamInviteFromChild, self:GetRoleID(), self:GetOnlineStatus())
end

function TeamInvitePlayerItemView:ShareRecruit()
	_G.EventMgr:SendEvent(EventID.RecuitShareFromChild, self:GetRoleID())
end

function TeamInvitePlayerItemView:OnReuseTypeChanged(Type)
	if Type == nil or Type == TeamDefine.InviteReuseType.INVITE then
		self:SetInviteIcon()
	elseif Type == TeamDefine.InviteReuseType.SHARE then
		self:SetRecruitShareIcon()
	end
end

function TeamInvitePlayerItemView:GetRoleID()
	return self.ViewModel and self.ViewModel.RoleID or nil
end

function TeamInvitePlayerItemView:GetOnlineStatus()
	local VM = _G.RoleInfoMgr:FindRoleVM(self:GetRoleID(), true)
	return VM and VM.OnlineStatus or 0
end

return TeamInvitePlayerItemView