--[[
Date: 2024-08-20 17:56:27
    匹配确认成员vm
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require ("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TeamDefine = require("Game/Team/TeamDefine")

---@class MagicCardTourneyMatchMemberItemVM: UIViewModel
local MagicCardTourneyMatchMemberItemVM = LuaClass(UIViewModel)

function MagicCardTourneyMatchMemberItemVM:Ctor()
    self.RoleVM = nil
    self.HasReady = false
    self.IsTeamMateOrMajor = false
    self.IsShowJobSlot = false
    self.PollType = ProtoCS.PollType.PoolType_Tournament  --需要展示的元素和进入副本一样,所以取这个类型
    self.ShowCapIcon = false
end

function MagicCardTourneyMatchMemberItemVM:UpdateVM(Value)
	self.HasReady = Value.HasReady
    self.RoleID = Value.RoleID
    if self.RoleID then
        self.RoleVM = RoleInfoMgr:FindRoleVM(self.RoleID)
        self.IsTeamMateOrMajor = _G.TeamMgr:IsTeamMemberByRoleID(self.RoleID) or MajorUtil.IsMajorByRoleID(self.RoleID)
        if self.IsTeamMateOrMajor then
            -- if _G.TeamMgr:IsCaptainByRoleID(self.RoleID) then
            --     self.ShowCapIcon = true
            -- end
            self:SetSyncProf(_G.TeamMgr:GetTeamMemberProf(self.RoleID))
            self:SetSyncLevel(_G.TeamMgr:GetTeamMemberLevel(self.RoleID))
        end
    end

    --self.ShowCapIcon = false
    --self.PollType = _G.PWorldVoteMgr:GetCurPollType()
    self.IsShowJobSlot = self.PollType == ProtoCS.PollType.PoolType_Tournament and self.IsTeamMateOrMajor
    self.IsShowChocoboLevel = false --self.PollType == ProtoCS.PollType.PollType_Chocobo and self.IsTeamMateOrMajor

end

function MagicCardTourneyMatchMemberItemVM:IsEqualVM(Value)
    return Value and self.RoleID and self.RoleID == Value.RoleID
end

function MagicCardTourneyMatchMemberItemVM:SetReady(Value)
    self.HasReady = Value
end

function MagicCardTourneyMatchMemberItemVM:SetSyncProf(Prof)
    self.SyncProf = Prof
end

function MagicCardTourneyMatchMemberItemVM:SetSyncLevel(Level)
    self.SyncLevel = Level
end

return MagicCardTourneyMatchMemberItemVM