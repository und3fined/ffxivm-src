---
--- Author: anypkvcai
--- DateTime: 2021-04-06 14:24
--- Description:
---

local LuaClass = require("Core/LuaClass")
local TeamDefine = require("Game/Team/TeamDefine")
local ATeamVM = require("Game/Team/Abs/ATeamVM")

local MaxMemberNum = TeamDefine.MaxMemberNum
local ModuleType = TeamDefine.ModuleType

---@class TeamVM : ATeamVM
---@field BindableListMember UIBindableList
---@field JoinRedDotVisible boolean
local TeamVM = LuaClass(ATeamVM)

---Ctor
function TeamVM:Ctor()
	self.IsCanOpInvite = true

	self.TeamWinAddIconIndex = -1
	self.bFull = false
end

function TeamVM:OnInit()
	self.Super.OnInit(self)
end

function TeamVM:OnBegin()
	self.Super.OnBegin(self)
end

function TeamVM:OnEnd()
	self.Super.OnEnd(self)
end

function TeamVM:OnShutdown()
	self.Super.OnShutdown(self)
end

-------------------------------------------------------------------------------------------------------
---@see override
local function TeamMainTeamMemSort(lhs, rhs)
	-- major
	if lhs.IsMajor ~= rhs.IsMajor then
		return lhs.IsMajor and not rhs.IsMajor
	end
	-- captain
	local LCapTest = _G.TeamMgr:IsCaptainByRoleID(lhs.RoleID)
	local RCapTest = _G.TeamMgr:IsCaptainByRoleID(rhs.RoleID)
	if LCapTest ~= RCapTest then
		return LCapTest and not RCapTest
	end
	-- join time
	return lhs.JoinTime < rhs.JoinTime
end

function TeamVM:GetMainTeamMemSort()
	return TeamMainTeamMemSort
end

local function SimpleMemSort(a, b)
	if a.RoleID == b.RoleID then
		return false	
	end

	if a.RoleID == nil or b.RoleID == nil then
		return a.RoleID ~= nil
	end

	local LCapTest = _G.TeamMgr:IsCaptainByRoleID(a.RoleID)
	local RCapTest = _G.TeamMgr:IsCaptainByRoleID(b.RoleID)

	if a.IsMajor ~= b.IsMajor then
		return a.IsMajor == true
	elseif LCapTest ~= RCapTest then
		return LCapTest == true
	elseif b.JoinTime ~= a.JoinTime then
		return a.JoinTime < b.JoinTime
	else
		return a.SortID < b.SortID
	end
end

function TeamVM:GetSimpleMemSort()
	return SimpleMemSort
end

function TeamVM:UpdateTeamMembers(ListMember)
	self.Super.UpdateTeamMembers(self, ListMember)
end

function TeamVM:OnMemListUpdate()
	self.Super.OnMemListUpdate(self)
	self:UpdateInviteOpInfo()
	self.bFull = self:GetMemberNum() >= MaxMemberNum
end

-------------------------------------------------------------------------------------------------------
---@see 邀请和招募等
function TeamVM:UpdateInviteOpInfo( )
	local MemNum = self.MemberNumber
	local CanOpInvite = self.MemberNumber <= 1 or _G.TeamMgr:IsCaptain() 

	local TeamRecruitMgr = require("Game/TeamRecruit/TeamRecruitMgr")
	if TeamRecruitMgr:IsRecruiting() then
		self.TeamWinAddIconIndex = (MemNum < MaxMemberNum) and (MemNum <= 1 and 2 or MemNum + 1) or -1
	else
		self.TeamWinAddIconIndex = (CanOpInvite and MemNum < MaxMemberNum) and (MemNum <= 1 and 2 or MemNum + 1) or -1
	end

	self.IsCanOpInvite = CanOpInvite
end

function TeamVM:SetJoinRedDotVisible(Visible)
	self.JoinRedDotVisible = Visible
end

function TeamVM:OnTeamRecruitStateChanged( IsRecruiting )
	self:UpdateInviteOpInfo()

	if nil == self.ModuleVMList then
		return
	end

	local Items = self.ModuleVMList:GetItems() or  {}

    for _, v in ipairs(Items) do
		v:SetIsPlayPointAni(IsRecruiting and v.Type == ModuleType.Recruit)
    end
end

return TeamVM