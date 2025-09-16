---
--- Author: stellahxhu
--- DateTime: 2022-07-07 12:56:49
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
local UIBindableList = require("UI/UIBindableList")

local TeamDefine = require("Game/Team/TeamDefine")
local InviteItemType = TeamDefine.InviteItemType
local MajorUtil = require("Utils/MajorUtil")

local function UpdatePlayerVMList(VMList, RoleIDList, Type)
	local Values = {}
	for _, v in ipairs(RoleIDList or {}) do
		if v and v > 0 then
			table.insert(Values, {RoleID = v, ReuseType=Type})
		end
	end
	table.sort(Values, function (a, b)
		local Ra = _G.RoleInfoMgr:FindRoleVM(a.RoleID, true) or {}
		local Rb = _G.RoleInfoMgr:FindRoleVM(b.RoleID, true) or {}
		if Ra.IsOnline ~= Rb.IsOnline then
			return Ra.IsOnline == true
		end

		return a.RoleID < b.RoleID
	end)
	VMList:UpdateByValues(Values)
end

---@class TeamInviteVM : UIViewModel
local TeamInviteVM = LuaClass(UIViewModel)

---Ctor
function TeamInviteVM:Ctor()
	self.TeamProfVMList = UIBindableList.New(SimpleProfInfoVM)
	self.TeamProfListText = ""
end

function TeamInviteVM:OnInit()
	self:Reset(true)
end

function TeamInviteVM:OnShutdown()
    self:Reset()
end

function TeamInviteVM:Reset( IsInit )
	self.IsEmptyMember = true 
	self.FilterKeyword = ""
	self.IsQuering = false
	self.CurInvitedRoleIDs = {} 
	self.CurInvitedRoleNum = 0

	self.CurRefreshRoles = {}
	self.TimerIdRefreshRoles = nil

	local InviteParentListItemVM = require("Game/Team/VM/InviteParentListItemVM")
	self.PlayerItemVMList = self:ResetBindableList(self.PlayerItemVMList, InviteParentListItemVM)
	self.ViewingPlayerItemVMList = self.PlayerItemVMList
	self.FilterPlayerItemVMList = self:ResetBindableList(self.FilterPlayerItemVMList, InviteParentListItemVM)
end

function TeamInviteVM:QueryRoleInviteStatusTimed()
	if #self.CurRefreshRoles > 0 then
		_G.TeamMgr:QueryTeamRoleInfoTimed(self.CurRefreshRoles)
	end
end

function TeamInviteVM:RefreshInviteMemberData(PreviewIndex, Type)
	if self.IsQuering then
		_G.FLOG_WARNING("TeamInviteVM:RefreshInviteMemberData querying while try to set %s, now is %s", PreviewIndex, self.PreviewIndex)
		return
	end

	self.PreviewIndex = PreviewIndex or 1

	self.IsQuering = true 
	local TempData = {}

	--好友
	TempData[InviteItemType.Friend] = self:GetFriendMemberRoleIDList()
	--附近
	TempData[InviteItemType.Nearby] = self:GetNearbyMemberRoleIDList()
	--公会
	TempData[InviteItemType.Tribe] = self:GetTribeMemberRoleIDList()

	self.CachePlayerData = TempData

	self.CurRefreshRoles = {}
	for RoleID in pairs(table.makeset(TempData[InviteItemType.Friend], TempData[InviteItemType.Nearby], TempData[InviteItemType.Tribe])) do
		table.insert(self.CurRefreshRoles, RoleID)
	end
	self:QueryRoleInviteStatusTimed()

	local QueryCallback = function( )
		self.IsQuering = false
		UpdatePlayerVMList(self.PlayerItemVMList, TempData[self.PreviewIndex + 1], Type)
		if self.FilterKeyword and self.FilterKeyword ~= "" then
			self:FilterParentItemByKeyword(self.FilterKeyword, Type)
		else
			self.ViewingPlayerItemVMList = self.PlayerItemVMList
		end

		self:UpdateEmptyMark()
	end

	_G.RoleInfoMgr:QueryRoleSimples(self.CurRefreshRoles, QueryCallback, nil, false)
end

function TeamInviteVM:GetFriendMemberRoleIDList()
	local Ret = {}
	for _, v in pairs(_G.FriendMgr:GetAllFriends() or {}) do
		local RoleID = v.RoleID
		if not _G.TeamMgr:IsTeamMemberByRoleID(RoleID) then
			table.insert(Ret, RoleID)
		end
	end

	return Ret
end

function TeamInviteVM:GetNearbyMemberRoleIDList()
	local function MatchCriteria(Player)
		if nil == Player then
			return false
		end

		local AttrComponent = Player:GetAttributeComponent()
		if nil == AttrComponent or AttrComponent.TeamFlag > 0 or _G.TeamMgr:IsTeamMemberByRoleID(AttrComponent.RoleID) then
			return false
		end

		if Player:ClientGetDistanceSquareToMajor() > 2.5e7 then
			return false
		end

		return true
	end

	local Ret = {}
	local UActorManager = _G.UE.UActorManager.Get()
	local Players = UActorManager:GetAllPlayers()
	if nil == Players or Players:Length() <= 0 then
		return {} 
	end
	-- #TODO performance can be speed up by physics query
	for i = 1, Players:Length() do
		local Player = Players:Get(i)
		if MatchCriteria(Player) then
			local AttrComponent = Player:GetAttributeComponent()
			if AttrComponent then
				local RoleID = AttrComponent.RoleID
				if RoleID then
					table.insert(Ret, RoleID)
				end
			end
		end
	end

	return Ret
end

function TeamInviteVM:GetTribeMemberRoleIDList()
	local RoleIDList = {}
	for _, RoleID in ipairs(_G.ArmyMgr:GetArmyAllMemberRoleID() or {}) do
		if not _G.TeamMgr:IsTeamMemberByRoleID(RoleID) and RoleID ~= MajorUtil.GetMajorRoleID() then
			table.insert(RoleIDList, RoleID)
		end
	end
	return RoleIDList
end

---通过玩家名关键词过滤
---@param Keyword string @关键词 
function TeamInviteVM:FilterParentItemByKeyword( Keyword, Type )
	Keyword = Keyword or ""
	UpdatePlayerVMList(self.FilterPlayerItemVMList, self:GetFilteredRoleIDList(Keyword), Type)
	self.ViewingPlayerItemVMList = self.FilterPlayerItemVMList

	self:UpdateEmptyMark()
	self.FilterKeyword = Keyword
end

function TeamInviteVM:GetFilteredRoleIDList(Keyword)
	local Ret = {}
	for _, v in ipairs(self.PlayerItemVMList:GetItems()) do
		local Name = v.Name
		if Name and (Keyword == nil or Name == Keyword) then
			table.insert(Ret, v.RoleID)
		end
	end
	return Ret
end

function TeamInviteVM:ClearFilterData()
	self.FilterKeyword = ""

	self.ViewingPlayerItemVMList = self.PlayerItemVMList
	self.FilterPlayerItemVMList:Clear()

	self:UpdateEmptyMark()
end

function TeamInviteVM:Clear()
	self.IsQuering = false
	self.PlayerItemVMList:Clear()
	self:ClearFilterData()
	self:ClearInvitedRoleInfo()
end

function TeamInviteVM:UpdateEmptyMark()
	self.IsEmptyMember = self.ViewingPlayerItemVMList:Length() == 0
end

function TeamInviteVM:AddInvitedRole( RoleID )
	if nil == RoleID then
		return
	end

	table.insert(self.CurInvitedRoleIDs, RoleID)
	self.CurInvitedRoleNum = #self.CurInvitedRoleIDs
end

function TeamInviteVM:RemoveInvitedRole( RoleID )
	if nil == RoleID then
		return
	end

	local RoleIDList = self.CurInvitedRoleIDs or {}

    for i = #RoleIDList, 1, -1 do
		local v = RoleIDList[i]
        if v == RoleID then
            table.remove(RoleIDList, i)
        end
    end

	self.CurInvitedRoleNum = #self.CurInvitedRoleIDs
end

function TeamInviteVM:ClearInvitedRoleInfo()
	self.CurInvitedRoleIDs = {} 
	self.CurInvitedRoleNum = 0
end

function TeamInviteVM:UpdateTeamMemberProfs()
	local TeamVM = require("Game/Team/VM/TeamVM")
	local ProfValues = {}
	if TeamVM.IsTeam then
		for _, Item in ipairs(TeamVM.BindableListMember:GetItems()) do
			table.insert(ProfValues, {
				ProfID = Item.ProfID,
				LevelDesc = Item.Level,
			})
		end
	end

	if #ProfValues == 0 then
		table.insert(ProfValues, {
			ProfID = MajorUtil.GetMajorProfID(),
			LevelDesc = MajorUtil.GetMajorLevel(),
		})
	end

	local EmptyData = {IsEmpty=true}
	for _ = #ProfValues + 1, 8 do
		table.insert(ProfValues, EmptyData)
	end

	local ProfUtil = require("Game/Profession/ProfUtil")
	table.sort(ProfValues, ProfUtil.SortByProfID)
	self.TeamProfVMList:UpdateByValues(ProfValues)
end

function TeamInviteVM:InitTabVMOnce()
	if self.TabVMList ~= nil then
		return
	end

	local TabValues = {
		{
			Icon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_Chat_NearbyNormal.UI_Icon_SideTab_Chat_NearbyNormal'",
			IconSelect = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_Chat_NearbySelect.UI_Icon_SideTab_Chat_NearbySelect'",
			Name = "",
		},
		{
			Icon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_friend_Normal.UI_Icon_SideTab_friend_Normal'",
			IconSelect = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_friend_selected.UI_Icon_SideTab_friend_selected'",
			Name = "",
		},
		{
			Icon = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_Chat_ArmyNormal.UI_Icon_SideTab_Chat_ArmyNormal'",
			IconSelect = "Texture2D'/Game/UI/Texture/Icon/SideFrame/UI_Icon_SideTab_Chat_ArmySelect.UI_Icon_SideTab_Chat_ArmySelect'",
			Name = "",
		}
	}
	local ChatPublicChannelItemVM = require("Game/Chat/VM/ChatPublicChannelItemVM")
	self.TabVMList = UIBindableList.New(ChatPublicChannelItemVM)
	for _, v in ipairs(TabValues) do
		local VM = ChatPublicChannelItemVM.New()
		for k, value in pairs(v) do
			VM[k] = value
		end
		self.TabVMList:Add(VM)
	end
end

return TeamInviteVM