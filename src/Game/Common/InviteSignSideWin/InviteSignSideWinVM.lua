---
--- Author: star_lightpaw
--- DateTime: 2025-03-05 11:20:49
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local InviteSignSideDefine = require("Game/Common/InviteSignSideWin/InviteSignSideDefine")
local InviteMenu = InviteSignSideDefine.InviteMenu
local InviteItemIcon = InviteSignSideDefine.InviteItemIcon
local MajorUtil = require("Utils/MajorUtil")

local InviteListItemVM = require("Game/Common/InviteSignSideWin/InviteListItemVM")
--local InviteMenuListItemVM = require("Game/Common/InviteSignSideWin/InviteMenuListItemVM")
local ChatPublicChannelItemVM = require("Game/Chat/VM/ChatPublicChannelItemVM")

local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

local function SortPlayerVMListPredicate(Lhs, Rhs)
	local LhsRoleVM = RoleInfoMgr:FindRoleVM(Lhs.RoleID, true)  ---@type RoleVM
	local RhsRoleVM = RoleInfoMgr:FindRoleVM(Rhs.RoleID, true)  ---@type RoleVM

	if LhsRoleVM.IsOnline ~= RhsRoleVM.IsOnline then
		return LhsRoleVM.IsOnline
	end

	if LhsRoleVM.IsOnline then
		return LhsRoleVM.LoginTime < RhsRoleVM.LoginTime
	else
		return LhsRoleVM.LogoutTime > RhsRoleVM.LogoutTime
	end
end

local function UpdatePlayerVMList(VMList, RoleIDList, ItemType, FilterKeyword)
	local Values = {}
	for _, v in ipairs(RoleIDList or {}) do
		local Value = {RoleID = v, ItemType = ItemType, FilterKeyword = FilterKeyword or "", BtnIcon = InviteItemIcon[ItemType]}
		table.insert(Values, Value)
	end

	table.sort(Values, SortPlayerVMListPredicate)

	if VMList then
		VMList:UpdateByValues(Values)
	end
end

---@class InviteSignSideWinVM : UIViewModel
local InviteSignSideWinVM = LuaClass(UIViewModel)

---Ctor
function InviteSignSideWinVM:Ctor()
	self.IsEmptyMember = nil 
	self.FilterKeyword = nil
	self.IsQuering = nil --- 是否正在查询角色数据
	self.Menus = nil ---页签数据
    self.Players = nil ---玩家数据
    self.MenuItemVMList = nil --页签列表
	self.PlayerItemVMList = nil --玩家列表
	self.ViewingPlayerItemVMList = nil --玩家列表（显示用）
	self.FilterPlayerItemVMList = nil --玩家列表（搜索用）
    self.MenuCurSelectItem = nil
	self.ItemType = nil
end

function InviteSignSideWinVM:OnInit()
    self:Reset()
end

function InviteSignSideWinVM:OnShutdown()
    self:Reset()
end

function InviteSignSideWinVM:Reset()
	self.IsEmptyMember = true 
	self.FilterKeyword = ""
	self.IsQuering = false --- 是否正在查询角色数据

    self.Menus = {}---页签数据
    self.Players = {} ---玩家数据
    self.MenuItemVMList = self:ResetBindableList(self.MenuItemVMList, 	ChatPublicChannelItemVM) --页签列表
	self.PlayerItemVMList = self:ResetBindableList(self.PlayerItemVMList, InviteListItemVM) --玩家列表
	self.ViewingPlayerItemVMList = self.PlayerItemVMList --玩家列表（显示用）
	self.FilterPlayerItemVMList = self:ResetBindableList(self.FilterPlayerItemVMList, InviteListItemVM) --玩家列表（搜索用）
    self.MenuCurSelectItem = nil
end

function InviteSignSideWinVM:RefreshInviteMemberDataByMenuID(MenuID)
    --- 如果在查询角色数据
	if self.IsQuering then
		_G.FLOG_WARNING("InviteSignSideWinVM:RefreshInviteMemberData querying while try to set %s, now is %s", MenuID, self.MenuID)
		return
	end

	self.IsQuering = true 

	--- 根据类型获取角色id列表
	local RoleIDList
	if MenuID == InviteMenu.Nearby then
		--附近
		RoleIDList = self:GetNearbyMemberRoleIDList()
	elseif MenuID == InviteMenu.Friend then
		--好友
		RoleIDList = self:GetFriendMemberRoleIDList()
	elseif MenuID == InviteMenu.Tribe then
		--部队
		RoleIDList = self:GetTribeMemberRoleIDList()
	end
	if RoleIDList == nil  then
		_G.FLOG_WARNING("InviteSignSideWinVM:RefreshInviteMemberData MenuID is UnKnown")
		return
	elseif #RoleIDList == 0 then
		self.PlayerItemVMList:Clear()
		self.ViewingPlayerItemVMList = self.PlayerItemVMList
		self:UpdateEmptyMark()
		return
	end
	local QueryCallback = function( )
		self.IsQuering = false
		UpdatePlayerVMList(self.PlayerItemVMList, RoleIDList, self.ItemType, self.FilterKeyword)
		self.ViewingPlayerItemVMList = self.PlayerItemVMList
		self:UpdateEmptyMark()
	end

	_G.RoleInfoMgr:QueryRoleSimples(RoleIDList, QueryCallback, nil, false)
end


function InviteSignSideWinVM:RefreshInviteMemberDataByMenuIndex(Index)
	local MenuItems = self.MenuItemVMList:GetItems()
	local Length = #MenuItems
	if Index <= Length then
		local MenuItemData = MenuItems[Index]
		if MenuItemData and MenuItemData.MenuID then
			self:RefreshInviteMemberDataByMenuID(MenuItemData.MenuID)
		end
	end
end

---获取好友的玩家ID列表
function InviteSignSideWinVM:GetFriendMemberRoleIDList()
	local Ret = {}
	for _, v in pairs(_G.FriendMgr:GetAllFriends() or {}) do
		local RoleID = v.RoleID
		table.insert(Ret, RoleID)
	end

	return Ret
end

---获取附近的玩家ID列表
function InviteSignSideWinVM:GetNearbyMemberRoleIDList()
	local function MatchCriteria(Player)
		if nil == Player then
			return false
		end

		local AttrComponent = Player:GetAttributeComponent()
		if nil == AttrComponent then
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

---获取公会的玩家ID列表
function InviteSignSideWinVM:GetTribeMemberRoleIDList()
	local RoleIDList = {}
	for _, RoleID in ipairs(_G.ArmyMgr:GetArmyAllMemberRoleID() or {}) do
		if RoleID ~= MajorUtil.GetMajorRoleID() then
			table.insert(RoleIDList, RoleID)
		end
	end
	return RoleIDList
end

---通过玩家名关键词过滤
---@param Keyword string @关键词 
function InviteSignSideWinVM:FilterParentItemByKeyword( Keyword )
	if  Keyword == "" then
		---按策划/视觉要求，空字符串搜索不进入搜索状态，直接清理
		self:ClearFilterData()
		return
	end
	Keyword = Keyword or ""
	UpdatePlayerVMList(self.FilterPlayerItemVMList, self:GetFilteredRoleIDList(Keyword), self.ItemType, Keyword)
	self.ViewingPlayerItemVMList = self.FilterPlayerItemVMList

	self:UpdateEmptyMark()
	self.FilterKeyword = Keyword
end

function InviteSignSideWinVM:GetFilteredRoleIDList(Keyword)
	local Ret = {}
	for _, v in ipairs(self.PlayerItemVMList:GetItems()) do
		local Name = v.Name
		if Name and (Keyword == nil or Keyword == "" or  Name == Keyword) then
			table.insert(Ret, v.RoleID)
		end
	end
	return Ret
end

function InviteSignSideWinVM:ClearFilterData()
	self.FilterKeyword = ""

	self.ViewingPlayerItemVMList = self.PlayerItemVMList
	self.FilterPlayerItemVMList:Clear()

	self:UpdateEmptyMark()
end

function InviteSignSideWinVM:Clear()
	self.IsQuering = false
	self.PlayerItemVMList:Clear()
	self:ClearFilterData()
end

function InviteSignSideWinVM:UpdateEmptyMark()
	self.IsEmptyMember = self.ViewingPlayerItemVMList:Length() == 0
end

function InviteSignSideWinVM:AddInvitedRole( RoleID )
	if nil == RoleID then
		return
	end

	table.insert(self.CurInvitedRoleIDs, RoleID)
	self.CurInvitedRoleNum = #self.CurInvitedRoleIDs
end

function InviteSignSideWinVM:RemoveInvitedRole( RoleID )
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

function InviteSignSideWinVM:SetTabVMByTabValues(TabValues)
	if self.MenuItemVMList == nil then
		return
	end

	self.MenuItemVMList:Clear()
	for _, v in ipairs(TabValues) do
		local VM = ChatPublicChannelItemVM.New()
		for k, value in pairs(v) do
			VM[k] = value
		end
		self.MenuItemVMList:Add(VM)
	end
end

function InviteSignSideWinVM:SetItemType(ItemType)
    self.ItemType = ItemType
end

return InviteSignSideWinVM