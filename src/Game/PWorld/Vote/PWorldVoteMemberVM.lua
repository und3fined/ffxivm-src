--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2024-05-20 17:56:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-15 16:15:14
FilePath: \Script\Game\PWorld\Vote\PWorldVoteMemberVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE：
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require ("Protocol/ProtoCS")

---@class PWorldVoteMemberVM: UIViewModel
local PWorldVoteMemberVM = LuaClass(UIViewModel)

function PWorldVoteMemberVM:Ctor()
    self.RoleVM = nil
    self:SetReady(false)
    self.IsTeamMateOrMajor = false
    self.IsShowJobSlot = false
    self.ReadyColor = "D5D5D5FF"
    self.PollType = ProtoCS.PollType.PollType_Invaild
end

function PWorldVoteMemberVM:UpdateVM(V)
    self:SetReady(V.HasReady or V.Option == 1)
    self.RoleID = V.ActorID
    self.IsTeamMateOrMajor = false
    self.ReadyColor = "D5D5D5FF"
    if self.RoleID ~= nil and self.RoleID > 0 then
        self.RoleVM = RoleInfoMgr:FindRoleVM(self.RoleID)
        self.IsTeamMateOrMajor = _G.TeamMgr:IsTeamMemberByRoleID(self.RoleID) or MajorUtil.IsMajorByRoleID(self.RoleID)
    end

    self.ShowCapIcon = false
    self.PollType = _G.PWorldVoteMgr:GetCurPollType()
    self.IsShowJobSlot = (self.PollType == ProtoCS.PollType.PollType_EnterScene
                        or self.PollType == ProtoCS.PollType.PoolType_Tournament
                        or self.PollType == ProtoCS.PollType.PoolType_CrystalConflict)
                        and self.IsTeamMateOrMajor
    self.IsShowChocoboLevel = self.PollType == ProtoCS.PollType.PollType_Chocobo and self.IsTeamMateOrMajor

    if self.PollType == ProtoCS.PollType.PollType_Chocobo then
        self.ReadyColor = self.HasReady and "FFEEBBFF" or "D5D5D5FF"
    end
    
    if self.IsTeamMateOrMajor then
        if _G.TeamMgr:IsCaptainByRoleID(self.RoleID) then
            self.ShowCapIcon = true
        end
    end

    self.bGetWeeklyReward = V.ZeroFormGot == true
end

function PWorldVoteMemberVM:IsEqualVM(Value)
    return Value and self.RoleID and self.RoleID == Value.RoleID
end

function PWorldVoteMemberVM:SetReady(V)
    self.HasReady = V
    
    if self.PollType == ProtoCS.PollType.PollType_Chocobo then
        self.ReadyColor = self.HasReady and "FFEEBBFF" or "D5D5D5FF"
    end
end

function PWorldVoteMemberVM:SetSyncProf(Prof)
    self.SyncProf = Prof
end

function PWorldVoteMemberVM:SetSyncLevel(Level)
    self.SyncLevel = Level
end

return PWorldVoteMemberVM