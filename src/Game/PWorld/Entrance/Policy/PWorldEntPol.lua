--[[
Author: v_hggzhang
Date: 2024-05-20 17:56:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-06-12 17:13:37
FilePath: \Script\Game\PWorld\Entrance\Policy\PWorldEntPol.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")

local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local ProfUtil = require("Game/Profession/ProfUtil")
local PolUtil = require("Game/PWorld/Entrance/Policy/PWorldEntPolUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local SceneMode = ProtoCommon.SceneMode
local LSTR = _G.LSTR

---@class PWorldEntPol
local PWorldEntPol = LuaClass(nil, nil)

function PWorldEntPol.IsPassPreQuest(EntID, bDailyRandom)
    local QID = (bDailyRandom and SceneEnterDailyRandomCfg or SceneEnterCfg):FindValue(EntID, "PreQuestID")
    return  PolUtil.HasPreQuestFinish(QID)
end

function PWorldEntPol:SetCheckPreReason(PrePassContext, Desc)
    PrePassContext.Succ = false
    table.insert(PrePassContext.Reason, Desc)
end

---@return PWorldEntDetailVM
local function GetPWorldEntDetailVM()
    return _G.PWorldEntDetailVM or require("Game/PWorld/Entrance/PWorldEntDetailVM")
end

local function CheckEquipScore(EntID, Score)
    Score = Score or 0
    local PworldEnterCheckCfg = require("TableCfg/PworldEnterCheckCfg")
    local ProtoRes = require("Protocol/ProtoRes")
    local TeamMemCount = 1
    if _G.TeamMgr:IsInTeam() then
        TeamMemCount = _G.TeamMgr:GetTeamMemberCount()
    end
    
    local Cfg
    for _, v in ipairs(PworldEnterCheckCfg:FindAllCfg(string.sformat("SceneID = %s and Mode = %s", EntID, GetPWorldEntDetailVM().TaskType)) or {}) do
        if TeamMemCount == 1 and v.TeamStatus == ProtoRes.Game.TeamStatus.TeamStatusNone then
            Cfg = v
        elseif v.MemberMax == TeamMemCount and v.TeamStatus == ProtoRes.Game.TeamStatus.TeamStatusFull then
            Cfg = v
        elseif TeamMemCount < v.MemberMax and v.TeamStatus == ProtoRes.Game.TeamStatus.TeamStatusNotFull then
            Cfg = v
        end

        if Cfg then
            break
        end
    end

    if Cfg then
        return Score >= (Cfg.EquipLv or 0)
    end
    
    return true
end

---@return boolean, PWorldEntPreCheckRlt
function PWorldEntPol:CheckJoinPre(EntID)
    -- config
    local ReqEquipLv = self:GetRequireEquipLv(EntID)
    local ReqLv = self:GetRequireLv(EntID)

    -- role
    local RoleVM = MajorUtil.GetMajorRoleVM(true)

    if not RoleVM then
        _G.FLOG_ERROR("zhg PWorldEntPol:CheckJoinPre RoleVM = NIL")
        return false, {}
    end

    local Prof = RoleVM.Prof
    local Lv = RoleVM.Level
    local EquipLv = _G.EquipmentMgr:CalculateEquipScore()
    local IsCombatProf = ProfUtil.IsCombatProf(Prof)

    ---@class PWorldEntPreCheckRlt
    local Ret = {
        IsPassMem = IsCombatProf,
        IsPassLv = Lv >= ReqLv,
        IsPassEquipLv = CheckEquipScore(EntID, EquipLv)
    }

    for _, V in pairs(Ret) do
        if not V then
            return false, Ret
        end
    end

    local IsPass = true
    if PWorldEntUtil.IsPrettyHardPWorld(EntID) then
        IsPass = PWorldEntUtil.IsPrettyHardEntranceJoinable(EntID)
    end

   local ECfg = SceneEnterCfg:FindCfgByKey(EntID)
   if ECfg and ECfg.PrepassEntID and ECfg.PrepassEntID ~= 0 then
        if not PWorldEntUtil.IsPassPWorld(ECfg.PrepassEntID) then
            IsPass = false
        end
   end

    return IsPass, Ret
end

---@return any nil or true if pass all check; or tip id, tip Params ...
function PWorldEntPol:CheckJoin(EntID)
    return PolUtil.JoinCheck()
end

function PWorldEntPol:CheckFilter(EntID)
    -- body
end

function PWorldEntPol:CheckEnter(EntID)
    if _G.PWorldEntDetailVM.TaskType == SceneMode.SceneModeUnlimited or _G.PWorldEntDetailVM.TaskType == SceneMode.SceneModeChallenge or _G.PWorldEntDetailVM.bMuren then
        return true
    end

    local Mems = PolUtil.GetPWorldEntranceJoinMemIDList()
    local MemCnt = #Mems
    local MaxMemCnt = _G.PWorldEntDetailVM.PWorldMaxMemCnt or 0
    return MemCnt == MaxMemCnt
end

function PWorldEntPol:GetRewardData(VM)
    -- body
end

function PWorldEntPol:GetEntInfo()
    return nil
end

function PWorldEntPol:GetRequireLv(EntID)
    return 0
end

function PWorldEntPol:GetRequireEquipLv(EntID)
    return 0
end

function PWorldEntPol:IsPassPWorld(EntID)
    return PWorldEntUtil.IsPassPWorld(EntID)
end



return PWorldEntPol

