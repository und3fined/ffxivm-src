local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
local ProtoCS = require("Protocol/ProtoCS")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneDailyRandomTaskPoolCfg = require("TableCfg/SceneDailyRandomTaskPoolCfg")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
local JoinErrorCode = PWorldEntDefine.JoinErrorCode
local ProtoCommon = require("Protocol/ProtoCommon")
local SceneMode = ProtoCommon.SceneMode
local FUNCTION_TYPE = ProtoCommon.function_type
local ScenePoolType = ProtoCommon.ScenePoolType
local MajorUtil = require("Utils/MajorUtil")
local LevelExpCfg = require("TableCfg/LevelExpCfg")

local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local ProfUtil = require("Game/Profession/ProfUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

---@class PWorldEntPolUtil
local PWorldEntPolUtil = {}

function PWorldEntPolUtil.HasPreQuestFinish(ID)
    return _G.QuestMgr:GetQuestStatus(ID) == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_FINISHED
end

function PWorldEntPolUtil.MakeRewardData(ID, Cnt, Type, EntID)
    local LackFunc = nil
    local HasGot = nil

    if Type == PWorldEntDefine.RewardType.DailyRandom then
        HasGot = _G.PWorldMatchMgr:HasDailyRewardRecv(EntID)
    elseif Type == PWorldEntDefine.RewardType.FewFunc then
        LackFunc = _G.PWorldMatchMgr:GetLackProfFunc(EntID)
    elseif Type == PWorldEntDefine.RewardType.FirstPass then
        HasGot = _G.PWorldMatchMgr:HasPassRewardRecv(EntID)
    elseif Type == PWorldEntDefine.RewardType.Weekly then
        local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
        HasGot = PWorldEntUtil.IsWeeklyRewardGet(EntID)
    end

    return {
        HasGot = HasGot,
        ID = ID,
        ShowTipDaily = Type == PWorldEntDefine.RewardType.DailyRandom,
        ShowTipFirst = Type == PWorldEntDefine.RewardType.FirstPass,
        LackFunc = LackFunc,
        bWeekly = Type == PWorldEntDefine.RewardType.Weekly,
        RewardType = Type,
        Cnt = Cnt
    }
end

function PWorldEntPolUtil.IsDailyRandom(TypeID)
    return TypeID == ScenePoolType.ScenePoolRandom
end

function PWorldEntPolUtil.GetDRPreQuestList(EntID)
    local Ret = {}

    local PList = PWorldEntPolUtil.GetDRPoolList(EntID)
    for _, ID in pairs(PList) do
        local ECfg = SceneEnterCfg:FindCfgByKey(ID)
        if ECfg then
            table.insert(Ret, ECfg.PreQuestID)
        else
            _G.FLOG_ERROR("zhg Util.PWorldEntPolUtil ECfg = nil ID = " .. tostring(ID))
        end
    end

    return Ret
end

function PWorldEntPolUtil.GetDRPoolList(EntID)
    local Ret = {}
    local DRCfg = SceneEnterDailyRandomCfg:FindCfgByKey(EntID)
    if not DRCfg then
        return Ret
    end

    local PCfg = SceneDailyRandomTaskPoolCfg:FindCfgByKey(DRCfg.PoolID)
    if not PCfg then
        _G.FLOG_ERROR("zhg PWorldEntPolUtil.GetDRPoolList PCfg = nil PoolID = " .. tostring(DRCfg.PoolID) .. "EntID = " .. tostring(EntID))
        return Ret
    end

    for _, ID in pairs(PCfg.ID or {}) do
        table.insert(Ret, ID)
    end

    return Ret
end

function PWorldEntPolUtil.GetRequireMemProfFunc(PWEntID, Ty)
    Ty = Ty or SceneMode.SceneModeNormal
    local EntCfg = PWorldEntPolUtil.IsDailyRandom(Ty) and SceneEnterDailyRandomCfg:FindCfgByKey(PWEntID) or SceneEnterCfg:FindCfgByKey(PWEntID)
    if not EntCfg then
        return {}
    end
    local RecoverClassCnt = EntCfg.NurseProfNum
    local GuardClassCnt = EntCfg.GuardProfNum
    local AttackClassCnt = EntCfg.AttackProfNum

    local Ret = {}
    Ret[FUNCTION_TYPE.FUNCTION_TYPE_RECOVER] = RecoverClassCnt or 0
    Ret[FUNCTION_TYPE.FUNCTION_TYPE_GUARD] = GuardClassCnt or 0
    Ret[FUNCTION_TYPE.FUNCTION_TYPE_ATTACK] = AttackClassCnt or 0

    return Ret
end

function PWorldEntPolUtil.GetPWorldEntranceJoinMemIDList()
    local RoleList = {}
    if _G.TeamMgr:IsInTeam() then
        for _, RoleID in _G.TeamMgr:IterTeamMembers() do
            table.insert(RoleList, RoleID)
        end
    else
        table.insert(RoleList, MajorUtil.GetMajorRoleID())
    end
    return RoleList
end

function PWorldEntPolUtil.GetMemProfFuncDict(MemRoleIDList)
    local Mems = MemRoleIDList
    local MemFuncDict = {}
    for Idx = 1, #Mems do
        local RoleID = Mems[Idx]
        local RoleVM = RoleInfoMgr:FindRoleVM(RoleID)
        if RoleVM then
            local Prof = RoleVM.Prof
            local ProfFunc = RoleInitCfg:FindFunction(Prof)
            if ProfFunc then
                if not MemFuncDict[ProfFunc] then
                    MemFuncDict[ProfFunc] = 0
                end
                MemFuncDict[ProfFunc] = MemFuncDict[ProfFunc] + 1
            else
                _G.FLOG_ERROR('zhg  Util.GetMemProfFuncDict ProfFunc = nil Prof = ' .. tostring(Prof))
            end
        end
    end
    return MemFuncDict
end

-------------------------------------------------------------------------------------------------------
---@see EnterCheck

---@return PWorldEntDetailVM a vm
local function GetPWorldEntDetailVM()
    return require("Game/PWorld/Entrance/PWorldEntDetailVM")
end

function PWorldEntPolUtil.JoinCheck()
    local PWorldEntDetailVM = GetPWorldEntDetailVM()

    -- 惩罚
    if PWorldEntDetailVM.HasPunished then
        return JoinErrorCode.CodeMatchTeammetaPunishment
    end

    -- 解限没有限制
    if PWorldEntDetailVM.TaskType == SceneMode.SceneModeUnlimited or PWorldEntDetailVM.TaskType == SceneMode.SceneModeChallenge then
        return PWorldEntPolUtil.UnlimitOrChallengeEnterCheck()
    end
end

function PWorldEntPolUtil.UnlimitOrChallengeEnterCheck()
    -- 队友的任何检查都交给后台校验！！！
    local RVM = MajorUtil.GetMajorRoleVM(true)
    if not ProfUtil.IsCombatProf(RVM.Prof)then
        return JoinErrorCode.CodeMatchProfMismatchCondition, nil, RVM.Name
    end

    if RVM.Level < _G.PWorldEntDetailVM.PWorldRequireLv then
        return JoinErrorCode.CodeMatchTeammetaLvNotEnough, nil, RVM.Name
    end
end

return PWorldEntPolUtil