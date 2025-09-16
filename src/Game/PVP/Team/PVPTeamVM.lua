local LuaClass = require("Core/LuaClass")
local ATeamVM = require("Game/Team/Abs/ATeamVM")
local UIBindableList = require("UI/UIBindableList")
local TeamMemberVM = require("Game/Team/VM/TeamMemberVM")
local ProfUtil = require("Game/Profession/ProfUtil")
local ActorUtil = require("Utils/ActorUtil")


---@class PVPTeamVM : ATeamVM
---@field MajorCampID number | nil camp id of current major
---@field EnemyMemberVMList UIBindableList
local PVPTeamVM = LuaClass(ATeamVM)

function PVPTeamVM:Ctor()
    self.EnemyMemberVMList = UIBindableList.New(TeamMemberVM)

    self.IsShowBtnBar = true
end

function PVPTeamVM:SetMajorCampID(CampID)
    self.MajorCampID = CampID
end

---@param InEnemyMembers ProtoTeamMember[]
function PVPTeamVM:UpdateEnemyMembers(InEnemyMembers)
    self.EnemyMemberVMList:UpdateByValues(InEnemyMembers, self:GetMainTeamMemSort())
end

-- 排序：主角在前，其他按Prof排序
local function MemSort(lhs, rhs)
    if lhs.IsMajor ~= rhs.IsMajor then
		return lhs.IsMajor and not rhs.IsMajor
	end

    return ProfUtil.SortByProfID(lhs, rhs)
end

function PVPTeamVM:GetMainTeamMemSort()
	return MemSort
end

function PVPTeamVM:GetEnemyMemberNum()
	return self.EnemyMemberVMList:Length()
end

function PVPTeamVM:GetEnemyMemberList()
	return self.EnemyMemberVMList
end

---@see ATeamVM:UpdateTarget
function PVPTeamVM:UpdateEnemyTarget(EntityID)
	local EnemyMemberVMList = self.EnemyMemberVMList
	for i = 1, EnemyMemberVMList:Length() do
		local ViewModel = EnemyMemberVMList:Get(i) ---@type TeamMemberVM
		ViewModel:UpdateSelected(EntityID)
	end
end

function PVPTeamVM:OnTimerUpdateEnemy()
	local VMItems = self.EnemyMemberVMList:GetItems()
	for _, Item in ipairs(VMItems) do
		Item:TimerUpdate()
	end
end

function PVPTeamVM:FindEnemyMemberVMByRoleID(RoleID)
	if nil == RoleID or RoleID == 0 then
		return
	end

	local function Predicate(ViewModel)
		if ViewModel.RoleID == RoleID then
			return true
		end
	end

	return self.EnemyMemberVMList:Find(Predicate)
end

function PVPTeamVM:FindEnemyMemberVMByEntityID(EntityID)

	local function Predicate(ViewModel)
		local EID = ViewModel.EntityID or ActorUtil.GetEntityIDByRoleID(ViewModel.RoleID)
		if EID == EntityID and EID and EID ~= 0 then
			return true
		end
	end

	return self.EnemyMemberVMList:Find(Predicate)
end


return PVPTeamVM
