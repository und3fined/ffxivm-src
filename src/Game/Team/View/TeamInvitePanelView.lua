---
--- Author: xingcaicao
--- DateTime: 2023-05-11 19:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local TeamDefine = require("Game/Team/TeamDefine")
local UIBindableList = require("UI/UIBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local TeamRecruitVM = require("Game/TeamRecruit/VM/TeamRecruitVM")

local LSTR = _G.LSTR
local InviteFilterTypes = TeamDefine.InviteFilterTypes

---@class TeamInvitePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRefresh UFButton
---@field CommBackpackEmpty CommBackpackEmptyView
---@field CommSearchBar CommSearchBarView
---@field CommSidebarTabFrame CommSidebarTabFrameView
---@field ImgBg UFImage
---@field ImgBg1 UFImage
---@field ImgPWorld UFImage
---@field ImgTeam UFImage
---@field PanelBtns UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelMember UFCanvasPanel
---@field PanelMyTeam UFCanvasPanel
---@field TableViewChannelPublic UTableView
---@field TableViewInvitePlayers UTableView
---@field TableViewList UTableView
---@field TextDesc UFTextBlock
---@field AnimEmptyIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamInvitePanelView = LuaClass(UIView, true)

function TeamInvitePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRefresh = nil
	--self.CommBackpackEmpty = nil
	--self.CommSearchBar = nil
	--self.CommSidebarTabFrame = nil
	--self.ImgBg = nil
	--self.ImgBg1 = nil
	--self.ImgPWorld = nil
	--self.ImgTeam = nil
	--self.PanelBtns = nil
	--self.PanelEmpty = nil
	--self.PanelMember = nil
	--self.PanelMyTeam = nil
	--self.TableViewChannelPublic = nil
	--self.TableViewInvitePlayers = nil
	--self.TableViewList = nil
	--self.TextDesc = nil
	--self.AnimEmptyIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamInvitePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBackpackEmpty)
	self:AddSubView(self.CommSearchBar)
	self:AddSubView(self.CommSidebarTabFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamInvitePanelView:OnPostInit()
	self.CommSearchBar:SetCallback(self, self.OnSearchTextChanged, self.OnSearchTextCommitted, self.OnClickCancelSearchBar)
	self.TbvProfList = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.TbvTabChannel = UIAdapterTableView.CreateAdapter(self, self.TableViewChannelPublic, self.OnTabItemSelect)
	self.TbvPlayers = UIAdapterTableView.CreateAdapter(self, self.TableViewInvitePlayers, nil, false, false, true)

	self.Binders = {
		{ "IsEmptyMember", 		UIBinderValueChangedCallback.New(self, nil, self.OnPlayersEmpty) },
		{ "TeamProfVMList", 		UIBinderUpdateBindableList.New(self, self.TbvProfList) },
		{ "TabVMList", UIBinderUpdateBindableList.New(self, self.TbvTabChannel)},
		{ "ViewingPlayerItemVMList", UIBinderUpdateBindableList.New(self, self.TbvPlayers)},
		{ "TeamProfListText", UIBinderSetText.New(self, self.TextDesc)},
	}

	self.RecruitBinders = {
		{"IsRecruiting", UIBinderSetIsVisible.New(self, self.ImgPWorld)},
		{"IsRecruiting", UIBinderSetIsVisible.New(self, self.ImgTeam, true)},
		{"IsRecruiting", UIBinderValueChangedCallback.New(self, nil, self.OnRecruitChanged)},
	}

	TeamInviteVM:InitTabVMOnce()
end

function TeamInvitePanelView:OnShow()
	self:SetEmptyText(LSTR(1300036))
	self.CommSearchBar:SetHintText(_G.LSTR(1300071))
	self.CommSidebarTabFrame.CommonTitle:SetTextTitleName(_G.LSTR(self:IsRecruitView() and 1300069 or 1300056))

	UIUtil.SetIsVisible(self.PanelBtns, true)

	self.CommSidebarTabFrame:SetSubTitleIsVisible(true)
	self:Refresh()
	self:UpdateTeamProfInfo()

	self.TbvTabChannel:SetSelectedIndex(1)
end

function TeamInvitePanelView:OnHide()
	self.CommSearchBar:SetText("")
	TeamInviteVM:Clear()
end

function TeamInvitePanelView:OnRegisterTimer()
	self:RegisterTimer(function ()
		TeamInviteVM:QueryRoleInviteStatusTimed()
	end, 0, 1, 0)
end

function TeamInvitePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRefresh, self.OnClickedButtonRefresh)
end

function TeamInvitePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamInviteJoin, self.OnGameEventTeamInviteJoin)
	self:RegisterGameEvent(EventID.TeamMemberInfoUpate, self.UpdateTeamProfInfo)
	self:RegisterGameEvent(EventID.TeamUpdateMember, self.UpdateTeamProfInfo)
	self:RegisterGameEvent(EventID.RecuitShareFromChild, self.OnRecruitShareFromChild)
	self:RegisterGameEvent(EventID.TeamInviteFromChild, self.OnTeamInviteFromChild)
end

function TeamInvitePanelView:OnRegisterBinder()
	self:RegisterBinders(TeamInviteVM, self.Binders)
	self:RegisterBinders(TeamRecruitVM, self.RecruitBinders)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function TeamInvitePanelView:OnGameEventTeamInviteJoin( RoleID )
	if nil == RoleID then
		return
	end

	TeamInviteVM:AddInvitedRole(RoleID)
end

function TeamInvitePanelView:OnSearchTextCommitted(SearchText)
	self:HandleSearchText(SearchText)
end

local function GetProcessedText(SearchText)
	return (SearchText or ""):gsub("^%s*", "")
end

function TeamInvitePanelView:OnSearchTextChanged(SearchText)
	TeamInviteVM.FilterKeyword = GetProcessedText(SearchText)
end

function TeamInvitePanelView:HandleSearchText(SearchText)
	TeamInviteVM:FilterParentItemByKeyword(GetProcessedText(SearchText), self:GetInviteReuseType())
end

--- 关闭搜索框
function TeamInvitePanelView:OnClickCancelSearchBar()
	self.CommSearchBar:SetText("")
	self:SetEmptyText(LSTR(1300036))

	TeamInviteVM:ClearFilterData()

	UIUtil.SetIsVisible(self.PanelBtns, true)
end

function TeamInvitePanelView:OnClickedButtonMask()
	self:Hide()
end

function TeamInvitePanelView:OnClickedButtonRefresh()
	if (os.time() - (self.LastRefreshTime or 0)) <= 3 then
		_G.MsgTipsUtil.ShowTipsByID(301034)
		return
	end

	self.LastRefreshTime = os.time()
	self:Refresh(self.TbvTabChannel:GetSelectedIndex())
	TeamInviteVM:ClearInvitedRoleInfo()
end

function TeamInvitePanelView:OnClickedButtonSearch()
	TeamInviteVM.IsEmptyMember = false
	self:SetEmptyText(LSTR(1300037))

	UIUtil.SetIsVisible(self.PanelBtns, false)
end

function TeamInvitePanelView:SetEmptyText(Text)
	self.CommBackpackEmpty:SetTipsContent(Text)
end

function TeamInvitePanelView:UpdateTeamProfInfo()
	TeamInviteVM:UpdateTeamMemberProfs()
end

function TeamInvitePanelView:OnRecruitShareFromChild(RoleID)
	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	local ChatDefine = require("Game/Chat/ChatDefine")
	local ProtoCS = require("Protocol/ProtoCS")
	local ChatParams = _G.TeamRecruitMgr.MakeClipboardData(TeamRecruitUtil.GatherShareData(TeamRecruitVM.RecruitingDetailVM))
	local Param = _G.ChatMgr:EncodeChatParams({TeamRecruit = ChatParams})
	local Params = { Type = ProtoCS.PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_RECRUIT, Direct = true, Param = Param }
	local ParamList = table.pack(Params)
	_G.ChatMgr:SendChatMsgPushMessage(ChatDefine.ChatChannel.Person, RoleID, ChatDefine.ChatMacros.TeamRecruit, 0, ParamList)
	_G.TeamRecruitMgr:AddRecruitShareTipTimer(RoleID)
end

function TeamInvitePanelView:OnTeamInviteFromChild(RoleID, OnlineStatus)
	local ProtoRes = require("Protocol/ProtoRes")
	local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")

	if OnlineStatusUtil.CheckBit(OnlineStatus, ProtoRes.OnlineStatus.OnlineStatusBusy) then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1300044))
		return
	end

	local Index <const> = self.TbvTabChannel:GetSelectedIndex()
	local ProtoCS = require("Protocol/ProtoCS")
	local Source = ProtoCS.Team.Team.ReqSource.ReqSourceUnknown
	if Index == 1 then
		Source = ProtoCS.Team.Team.ReqSource.ReqSourceNearby
	elseif Index == 2 then
		Source = ProtoCS.Team.Team.ReqSource.ReqSourceFriend
	elseif Index == 3 then
		Source = ProtoCS.Team.Team.ReqSource.ReqSourceGroup
	end
	_G.TeamMgr:InviteJoinTeam(RoleID, Source)
end

function TeamInvitePanelView:OnTabItemSelect(Index)
	self:Refresh(Index)
end

function TeamInvitePanelView:OnRecruitChanged(bRecruiting)
	local Text = ""
	if bRecruiting then
		local Cfg = _G.TeamRecruitMgr:GetRecruitingCfg()
		local TypeInfo = _G.TeamRecruitMgr:GetRecruitingTypeCfg()
		if Cfg and TypeInfo then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgPWorld, TypeInfo.Icon)
			Text = string.format("%s - %s", TypeInfo.Name or "", Cfg.TaskName or "")
		end
	else
		Text = _G.LSTR(1300066)
	end

	TeamInviteVM.TeamProfListText = Text
end

function TeamInvitePanelView:OnPlayersEmpty(bEmpty)
	UIUtil.SetIsVisible(self.PanelEmpty, bEmpty)
	UIUtil.SetIsVisible(self.PanelMember, not bEmpty)
	if bEmpty then
		self:PlayAnimation(self.AnimEmptyIn)
	end
end

function TeamInvitePanelView:IsRecruitView()
	return self.Params and self.Params.RecruitShare == true
end

function TeamInvitePanelView:GetInviteReuseType()
	if self:IsRecruitView() then
		return TeamDefine.InviteReuseType.SHARE
	end

	return TeamDefine.InviteReuseType.INVITE
end

function TeamInvitePanelView:Refresh(Index)
	TeamInviteVM:RefreshInviteMemberData(Index, self:GetInviteReuseType())

	local SubTextID
	if Index == 1 or Index == nil then
		SubTextID = 1300076
	elseif Index == 2 then
		SubTextID = 1300077
	elseif Index == 3 then
		SubTextID = 1300078
	end
	if SubTextID then
		self.CommSidebarTabFrame:SetSubTitleText(_G.LSTR(SubTextID))
	end
end

function TeamInvitePanelView:OnMouseButtonDown(InGeometry, InTouchEvent)
	local MousePosition = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	if not UIUtil.IsUnderLocation(self.CommSidebarTabFrame.Sidebar, MousePosition) then
		self:Hide()
		-- return _G.UE.UWidgetBlueprintLibrary.Handled()
	end

	return _G.UE.UWidgetBlueprintLibrary.Unhandled()
end

return TeamInvitePanelView