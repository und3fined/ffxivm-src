---
--- Author: xingcaicao
--- DateTime: 2024-06-18 19:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local TeamInviteVM = require("Game/Team/VM/TeamInviteVM")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local SocialDefine = require("Game/Social/SocialDefine")
local SocialSettings = require("Game/Social/SocialSettings")
local LoginMgr = require("Game/Login/LoginMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local LSTR = _G.LSTR
local TabType = SocialDefine.TabType

---@class SocialMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field CommMenu CommMenuView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field FriendAddPanel FriendAddPanelView
---@field FriendListPanel FriendListPanelView
---@field FriendPlatformPanel FriendPlatformPanelView
---@field LinkShellInvitedPanel LinkShellInvitedPanelView
---@field LinkShellJoinPanel LinkShellJoinPanelView
---@field LinkShellPanel LinkShellPanelView
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SocialMainPanelView = LuaClass(UIView, true)

function SocialMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.CommMenu = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonTitle = nil
	--self.FriendAddPanel = nil
	--self.FriendListPanel = nil
	--self.FriendPlatformPanel = nil
	--self.LinkShellInvitedPanel = nil
	--self.LinkShellJoinPanel = nil
	--self.LinkShellPanel = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SocialMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.FriendAddPanel)
	self:AddSubView(self.FriendListPanel)
	self:AddSubView(self.FriendPlatformPanel)
	self:AddSubView(self.LinkShellInvitedPanel)
	self:AddSubView(self.LinkShellJoinPanel)
	self:AddSubView(self.LinkShellPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SocialMainPanelView:OnInit()
	self.CommMenu:SetAlwaysNotifySelectChanged(true)
end

function SocialMainPanelView:OnDestroy()
	SocialSettings.CheckFriendHideSignInfo()
end

function SocialMainPanelView:OnShow()
	self:InitConstText()

	self.CurKey = nil

	local TabData = self:GetCurTabData()
	self.CommMenu:UpdateItems(TabData, false)

	-- 如果传入的参数有LinkShellID的话，会优先切到通讯贝页签，并且跳转到指定的通讯贝
	if self.Params ~= nil then
		-- 是否跳转到指定通讯贝
		local LinkShellID = self.Params.LinkShellID
		if LinkShellID ~= nil then
			self.CommMenu:SetSelectedKey(TabType.LinkShell)
			self.LinkShellPanel:GoToLinkShell(LinkShellID)
			return
		end
	end

	local Key = TabType.FriendList
	self.CommMenu:SetSelectedKey(Key)
end

function SocialMainPanelView:OnHide()
	UIViewMgr:HideView(UIViewID.CommHelpInfoTipsView)

	self.CommMenu:CancelSelected()
	TeamInviteVM:ClearInvitedRoleInfo()

	UIUtil.SetIsVisible(self.FriendListPanel, false)
	UIUtil.SetIsVisible(self.FriendPlatformPanel, false)
	UIUtil.SetIsVisible(self.FriendAddPanel, false)
	UIUtil.SetIsVisible(self.LinkShellPanel, false)
	UIUtil.SetIsVisible(self.LinkShellJoinPanel, false)
end

function SocialMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu, self.OnSelectionChangedCommMenu)
end

function SocialMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TeamInviteJoin, self.OnGameEventTeamInviteJoin)
end

function SocialMainPanelView:OnRegisterBinder()

end

function SocialMainPanelView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.TextTitle:SetText(LSTR(20008)) -- "社交"
end

function SocialMainPanelView:GetCurTabData()
	local Ret = {}

	for _, v in ipairs(SocialDefine.MainTabs) do
		local Key = v.Key
		if Key == TabType.QQFriend then
			if LoginMgr:IsQQLogin() then
				table.insert(Ret, v)
			end

		elseif Key == TabType.WeChatFriend then
			if LoginMgr:IsWeChatLogin() then
				table.insert(Ret, v)
			end

		else
			table.insert(Ret, v)
		end
	end

	return Ret
end

function SocialMainPanelView:SwitchToFindFriendTab()
	self.CommMenu:SetSelectedKey(TabType.FindFriend, true)
end

function SocialMainPanelView:SwitchToJoinLinkShellTab()
	self.CommMenu:SetSelectedKey(TabType.JoinLinkShell, true)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function SocialMainPanelView:OnGameEventTeamInviteJoin( RoleID )
	if nil == RoleID then
		return
	end

	TeamInviteVM:AddInvitedRole(RoleID)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function SocialMainPanelView:OnSelectionChangedCommMenu(_, ItemData)
	if nil == ItemData then
		return
	end

	local Key = ItemData:GetKey()
	if Key == self.CurKey then
		return
	end

	self.CurKey = Key

	local ListPanelVisible = false
	local PlatformPanelVisible = false
	local AddPanelVisible = false
	local LinkShellPanelVisible = false
	local LinkShellJoinPanelVisible = false
	local LinkShellInvitedPanelVisible = false

	if Key == TabType.FriendList then
		ListPanelVisible = true 

	elseif Key == TabType.WeChatFriend or Key == TabType.QQFriend then
		PlatformPanelVisible = true
		self.FriendPlatformPanel:SelectTab(Key)

	elseif Key == TabType.FindFriend or Key == TabType.ApplyList then
		AddPanelVisible = true 
		self.FriendAddPanel:SelectTab(Key)

	elseif Key == TabType.MyLinkShell then
		LinkShellPanelVisible = true 
		LinkShellMgr:SendMsgGetLinkShellListReq()

	elseif Key == TabType.JoinLinkShell then
		LinkShellJoinPanelVisible = true 
		UIUtil.SetIsVisible(self.LinkShellJoinPanel, true)

	elseif Key == TabType.InvitedLinkShell then
		LinkShellInvitedPanelVisible = true
		LinkShellMgr:SendMsgGetInvitedLinkShellListReq()
	end

	UIUtil.SetIsVisible(self.FriendListPanel, ListPanelVisible)
	UIUtil.SetIsVisible(self.FriendPlatformPanel, PlatformPanelVisible)
	UIUtil.SetIsVisible(self.FriendAddPanel, AddPanelVisible)
	UIUtil.SetIsVisible(self.LinkShellPanel, LinkShellPanelVisible)
	UIUtil.SetIsVisible(self.LinkShellJoinPanel, LinkShellJoinPanelVisible)
	UIUtil.SetIsVisible(self.LinkShellInvitedPanel, LinkShellInvitedPanelVisible)
end

return SocialMainPanelView