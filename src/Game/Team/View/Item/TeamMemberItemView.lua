---
--- Author: xingcaicao
--- DateTime: 2023-05-09 16:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TeamVM = require("Game/Team/VM/TeamVM")
local MajorUtil = require("Utils/MajorUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetIsVisiblePred = require("Binder/UIBinderSetIsVisiblePred")
local TeamRecruitMgr = require("Game/TeamRecruit/TeamRecruitMgr")

local LSTR = _G.LSTR

---@class TeamMemberItemView : UIView
---@field ViewModel TeamMemberSimpleVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AddMarkNode UFCanvasPanel
---@field BtnClickInvite UFButton
---@field IconMicSaying UFImage
---@field ImgBg UFImage
---@field ImgInvite UFImage
---@field ImgOnlineStatus UFImage
---@field ImgServer UFImage
---@field PanelEmpty UFCanvasPanel
---@field PanelPlayer UFCanvasPanel
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field SizeBoxServer USizeBox
---@field TextInviteTips UFTextBlock
---@field TextLocation UFTextBlock
---@field TextPlayerName URichTextBox
---@field AnimMicLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamMemberItemView = LuaClass(UIView, true)

function TeamMemberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AddMarkNode = nil
	--self.BtnClickInvite = nil
	--self.IconMicSaying = nil
	--self.ImgBg = nil
	--self.ImgInvite = nil
	--self.ImgOnlineStatus = nil
	--self.ImgServer = nil
	--self.PanelEmpty = nil
	--self.PanelPlayer = nil
	--self.PlayerHeadSlot = nil
	--self.ProfSlot = nil
	--self.SizeBoxServer = nil
	--self.TextInviteTips = nil
	--self.TextLocation = nil
	--self.TextPlayerName = nil
	--self.AnimMicLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamMemberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamMemberItemView:OnInit()
	self.MemSimpleBinders = {
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, 	self.PanelEmpty) },
		{ "IsEmpty", 	UIBinderSetIsVisible.New(self, 	self.PanelPlayer, true) },
		{ "MemberItemBg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBg) },
		{ "RoleID", UIBinderValueChangedCallback.New(self, nil, self.OnRoleIDChanged) },
		{ "IsSaying", UIBinderValueChangedCallback.New(self, nil, function (View, bSaying)
			View:OnValueChangedIsSaying(bSaying)
		end) },
		{ "StatusIcon", UIBinderSetImageBrush.New(self, self.ImgOnlineStatus)},
		{ "bShowStatus", UIBinderSetIsVisible.New(self, self.ImgOnlineStatus)},
	}

	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	self.RoleBinders = {
		{ "Name", UIBinderSetText.New(self, self.TextPlayerName, function (V)
			if nil == self.ViewModel or nil == self.ViewModel.RoleID then
				return ""
			end
		
			local Color = MajorUtil.IsMajorByRoleID(self.ViewModel.RoleID) and "#FFEEBBFF" or "#D5D5D5FF"
			return string.sformat('<span color="%s">%s</>', Color, V or "")
		end)},
		{ "OnlineStatusIcon", UIBinderValueChangedCallback.New(self, nil, function ()
			if self.ViewModel then
				self.ViewModel:UpdateCaptain()
			end
		end)},
		{ "CurWorldID", TeamRecruitUtil.NewCrossServerShowBinder(nil, self, self.SizeBoxServer)},
	}
	TeamRecruitUtil.AddRoleLocationShowBinders(self.RoleBinders, function()
		return self.ViewModel and self.ViewModel.RoleID or nil
	end, self, self.TextLocation)

	self.ShowInviteBinder = UIBinderSetIsVisiblePred.NewByPred(function()
		if self.ViewModel then
			return TeamVM.TeamWinAddIconIndex == TeamVM.MemberSimpleVMList:GetItemIndex(self.ViewModel) and (TeamRecruitMgr:IsRecruiting() or not _G.TeamMgr:IsInTeam() or _G.TeamMgr:IsCaptain())
		end
	end, self, self.AddMarkNode)

	self.TeamBinders = {
		{ "IsCanOpInvite", 	 	 UIBinderValueChangedCallback.New(self, nil, self.OnIsInviteOpChanged) },
		{ "TeamWinAddIconIndex", UIBinderValueChangedCallback.New(self, nil, self.OnTeamWinAddIconIndexChanged) },
		{ "CaptainID", self.ShowInviteBinder },
		{ "TeamWinAddIconIndex", self.ShowInviteBinder },
		{ "IsTeam", self.ShowInviteBinder },
	}

	self.RecruitBinders = {
		{"IsRecruiting", UIBinderValueChangedCallback.New(self, nil, function(_, V)
			local AssetPath = V and "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_Share_png.UI_Team_Icon_Share_png'" or "Texture2D'/Game/UI/Texture/Icon/UI_Icon_PlusSign_Noraml.UI_Icon_PlusSign_Noraml'"
			UIUtil.ImageSetBrushFromAssetPath(self.ImgInvite, AssetPath, true)
			self.TextInviteTips:SetText(_G.LSTR(V and 1300069 or 1300050))
		end)},
		{ "IsRecruiting", self.ShowInviteBinder },
	}

	self.bDestroyed = false
end

function TeamMemberItemView:OnDestroy()
	self.bDestroyed = true
	self.RoleVM = nil
end

function TeamMemberItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClickInvite, self.OnClickButtonInvite)
end

function TeamMemberItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamCaptainChanged, function (_, mgr)
		if mgr == _G.TeammMgr and self.ViewModel then
			self.ViewModel:UpdateCaptain()
		end
	end)
end

function TeamMemberItemView:OnRegisterBinder()
	self.ViewModel = self.Params and self.Params.Data or nil
	if self.ViewModel == nil then
		return
	end

	-- simple vm
	self:RegisterBinders(self.ViewModel, self.MemSimpleBinders)

	-- team
	self:RegisterBinders(TeamVM, self.TeamBinders)

	-- role
	self:ReBindRoleBinder(self.ViewModel.RoleID)

	self.ProfSlot:SetParams({Data = self.ViewModel.ProfInfoVM})

	local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")
	self:RegisterBinders(TeamRecruitVM, self.RecruitBinders)
end

function TeamMemberItemView:OnBindArmyName(Name)
	-- local Str = string.isnilorempty(Name) and LSTR(1300045) or Name
	-- self.TextArmyName:SetText(Str)
end

function TeamMemberItemView:ReBindRoleBinder(RoleID)
	if self.RoleVM then
		self:UnRegisterBinders(self.RoleVM, self.RoleBinders)
		self.RoleVM = nil
	end

	if RoleID and RoleID ~= 0 then
		_G.RoleInfoMgr:QueryRoleSimple(RoleID, function(InRoleID, VM)
			if self and not self.bDestroyed and InRoleID == RoleID and self.ViewModel and self.ViewModel.RoleID == RoleID then
				self.RoleVM = VM
				self:RegisterBinders(VM, self.RoleBinders)
			end
		end, RoleID, true)
	end
end

function TeamMemberItemView:OnRoleIDChanged(RoleID)
	self:ReBindRoleBinder(RoleID)
	if nil == RoleID then
		UIUtil.SetIsVisible(self.ImgServer, false)
		return
	end

	--玩家头像
	self.PlayerHeadSlot:SetInfo(RoleID, PersonInfoDefine.SimpleViewSource.Team)
end

function TeamMemberItemView:OnIsInviteOpChanged()
	self:OnTeamWinAddIconIndexChanged()
end

function TeamMemberItemView:OnTeamWinAddIconIndexChanged()
	if nil == self.ViewModel then
		UIUtil.SetIsVisible(self.ImgBg, true)
		return
	end

	local IsVisible = TeamVM.TeamWinAddIconIndex == TeamVM.MemberSimpleVMList:GetItemIndex(self.ViewModel)
	UIUtil.SetIsVisible(self.BtnClickInvite, IsVisible, true)
	UIUtil.SetIsVisible(self.ImgBg, not IsVisible)
end

function TeamMemberItemView:OnValueChangedIsSaying(IsSaying)
	if IsSaying then
		self:PlayAnimation(self.AnimMicLoop, 0, 0)

	else
		self:StopAnimation(self.AnimMicLoop)
		UIUtil.SetIsVisible(self.IconMicSaying, false)
	end
end


-------------------------------------------------------------------------------------------------------
---Component CallBack

function TeamMemberItemView:OnClickButtonInvite()
	if TeamRecruitMgr:IsRecruiting() then
		_G.UIViewMgr:ShowView(_G.UIViewID.TeamInvite, {RecruitShare=true})
	else
		if not _G.TeamMgr:CheckCanOpTeam(true) then
			return
		end
	
		_G.UIViewMgr:ShowView(_G.UIViewID.TeamInvite)
	end
end

return TeamMemberItemView