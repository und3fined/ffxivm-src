local LuaClass = require("Core/LuaClass")
local ATeamMgr = require("Game/Team/Abs/ATeamMgr")
local PVPTeamVM = require("Game/PVP/Team/PVPTeamVM")
local TeamHelper = require("Game/Team/TeamHelper")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")


---@class PVPTeamMgr : ATeamMgr
---@field EnemyMemList table 敌方队伍成员列表
---@field MemberVisionInfo table<number, VisionInfo> 队伍视野信息（也可以认为是阵营视野），后台按规则定时同步，主要存储主角视野外的数据，以供显示
local PVPTeamMgr = LuaClass(ATeamMgr, nil)

function PVPTeamMgr:OnInit()
    self.Super.OnInit(self)

    self.EnemyMemList = nil

    self.MemberVisionInfo = {}

	self:SetLogName("PVPTeamMgr")
end

function PVPTeamMgr:OnBegin()
    self.Super.OnBegin(PVPTeamMgr)
	self:SetTeamVM(PVPTeamVM)
end

function PVPTeamMgr:OnRegisterGameEvent()
    self.Super.OnRegisterGameEvent(self)

    self:RegisterGameEvent(_G.EventID.TeamSceneTeamDataUpdate, self.OnUpdateTeamData)
end

function PVPTeamMgr:IterEnemyTeamMembers()
    return self.TemplateMemberIterFunc, self:IsInTeam() and (self.EnemyMemList or {}) or {}, 0
end

function PVPTeamMgr:IsInTeam()
    return TeamHelper.GetTeamMgr() == self and self:GetTeamID() and self:GetTeamID() ~= 0
end

--- @return number | nil
function PVPTeamMgr:GetMajorCampID()
    --if self:IsInTeam() then
        return self:GetPVPTeamVM().MajorCampID
    --end
end

function PVPTeamMgr:OnUpdateTeamData()
    if TeamHelper.GetTeamMgr() ~= self then
        return
    end

    local IntermediateData = {}
    local MajorTeamID

    for _, V in ipairs(self:GetRawTeamData()) do
        local Mem = self.SceneTeamMemberToProtoTeamMember(V)
        if Mem.Type == ProtoCS.SceneTeamEntityType.SceneTeamEntityTypePlayer then
            if Mem.RoleID == MajorUtil.GetMajorRoleID() then
                self:GetPVPTeamVM():SetMajorCampID(Mem.CampID)
                MajorTeamID = Mem.TeamID
            end

            local RVM = self.FindRoleVM(Mem.RoleID, true)
            if RVM then
                RVM:SetTeamID(Mem.TeamID)
            end

            Mem.IsPVPPlayer = true
        end

        table.insert(IntermediateData, Mem)
    end

    local MajorMemList = {}
    local EnemyMemList = {}
    for _, Mem in ipairs(IntermediateData) do
        if Mem.CampID == self:GetMajorCampID() then
           table.insert(MajorMemList, Mem)
        else
           table.insert(EnemyMemList, Mem)
        end
    end

    self.MemberList = MajorMemList
    self.EnemyMemList = EnemyMemList

    local CaptainID
    local CaptainPriority = math.maxinteger
    for _, V in ipairs(MajorMemList) do
        if CaptainPriority < V.CaptainPriority then
           CaptainPriority = V.CaptainPriority
           CaptainID = V.RoleID
        end
    end

    self:SetTeamID(MajorTeamID)
    self:GetPVPTeamVM():UpdateTeamMembers(MajorMemList)
    self:SetCaptainByRoleID(CaptainID, true)
    self:GetPVPTeamVM():UpdateEnemyMembers(EnemyMemList)

    self:ClearMemberVisionInfo()
end

---@private
function PVPTeamMgr:GetRawTeamData()
    return _G.PWorldTeamMgr.SceneTeamData or {}
end

---@return PVPTeamVM
function PVPTeamMgr:GetPVPTeamVM()
    return self.TeamVM
end


---重写父类方法
---@overload
---@private
---@param RoleID number
---@return TeamMemberVM
function PVPTeamMgr:GetTeamMemberVMByRoleID(RoleID)
	return self:FindMemberVMByRoleID(RoleID)
end

---重写父类方法
---@overload
---@private
---@param EntityID number
---@return TeamMemberVM
function PVPTeamMgr:GetTeamMemberVMByEntityID(EntityID)
	return self:FindMemberVMByEntityID(EntityID)
end

---根据RoleID查找成员，可以是我方队伍成员，也可以是敌方队伍成员
---@return TeamMemberVM
function PVPTeamMgr:FindMemberVMByRoleID(RoleID)
	local VM = self.Super.GetTeamMemberVMByRoleID(self, RoleID)
	if VM then
		return VM
	end

    VM = self:GetPVPTeamVM():FindEnemyMemberVMByRoleID(RoleID)
	return VM
end

---根据EntityID查找成员，可以是我方队伍成员，也可以是敌方队伍成员
---@return TeamMemberVM
function PVPTeamMgr:FindMemberVMByEntityID(EntityID)
	local VM = self.Super.GetTeamMemberVMByEntityID(self, EntityID)
	if VM then
		return VM
	end

    VM = self:GetPVPTeamVM():FindEnemyMemberVMByEntityID(EntityID)
	return VM
end

---判断给定玩家RoleID是否是敌方队伍成员
---@return boolean
function PVPTeamMgr:IsEnemyTeamMemberByRoleID(RoleID)
	if self:IsInTeam() then
		for _, _RoleID in self:IterEnemyTeamMembers() do
			if _RoleID == RoleID and _RoleID ~= nil then
				return true
			end
		end
	end
end

---判断给定玩家EntityID是否是敌方队伍成员
---@return boolean
function PVPTeamMgr:IsEnemyTeamMemberByEntityID(EntityID)
	if self:IsInTeam() then
		for _, _, EID in self:IterEnemyTeamMembers() do
			if EID == EntityID and EID ~= nil and EID ~= 0 then
				return true
			end
		end
	end
end


---更新队伍成员复活时间戳
---@param RoleID number
---@param RespawnTime number 复活时间戳
function PVPTeamMgr:UpdateRespawnTime(RoleID, RespawnTime)
	local VM = self:FindMemberVMByRoleID(RoleID)
	if VM then
		VM:UpdateRespawnTime(RespawnTime)
	end
end

---清除视野信息
function PVPTeamMgr:ClearMemberVisionInfo()
    _G.TableTools.ClearTable(self.MemberVisionInfo)
end

---更新视野信息
---@param VisionInfo VisionInfo 后台同步的视野信息
function PVPTeamMgr:UpdateMemberVisionInfo(VisionInfo)
    if VisionInfo == nil then
        return
    end
    local RoleID = VisionInfo.role_id
    self.MemberVisionInfo[RoleID] = VisionInfo
end

---获取队伍视野成员坐标位置
---@param RoleID number
---@return CSPosition | nil
function PVPTeamMgr:GetTeamMemberNetPositionInfoByRoleID(RoleID)
    if RoleID then
        local VisionInfo = self.MemberVisionInfo[RoleID]
        if VisionInfo then
            return VisionInfo.pos
        end
    end

    return nil
end

---获取队伍视野成员HP百分比
---@param RoleID number
---@return number
function PVPTeamMgr:GetTeamMemberHPPercentByRoleID(RoleID)
    if RoleID then
        local VisionInfo = self.MemberVisionInfo[RoleID]
        if VisionInfo then
            return VisionInfo.hp_percent
        end
    end

    -- 如果数据不存在，返回1表示满血，比如比赛准备阶段后台还没下发数据
    return 1
end


return PVPTeamMgr
