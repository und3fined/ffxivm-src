local LuaClass = require("Core/LuaClass")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
local PolUtil = require("Game/PWorld/Entrance/Policy/PWorldEntPolUtil")
local PWorldEntPol = require("Game/PWorld/Entrance/Policy/PWorldEntPol")
local SceneDailyRandomRewardCfg = require("TableCfg/SceneDailyRandomRewardCfg")
local MajorUtil = require("Utils/MajorUtil")

---@class PWorldEntPolDR: PWorldEntPol
local PWorldEntPolDR = LuaClass(PWorldEntPol)

function PWorldEntPolDR:CheckFilter(EntID)
    local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
   return PWorldEntUtil.IsDailyRandomUnlocked(EntID)
end

function PWorldEntPolDR:GetRewardData(EntCfg)
    local RewardsData = {}
    self:FillRewardsData(RewardsData, EntCfg)
    return RewardsData
end

function PWorldEntPolDR:FillRewardsData(Rewards, EntCfg)
    if not EntCfg then
        return
    end

    local RewardsCfg = SceneDailyRandomRewardCfg:GetRewardByLevelType(EntCfg.ID, MajorUtil.GetTrueMajorLevel() or 0)
    if not RewardsCfg then
        return
    end

    local ExpID = 19000099
    if RewardsCfg.DailyExpReword and RewardsCfg.DailyExpReword > 0  then
        table.insert(Rewards, PolUtil.MakeRewardData(ExpID, RewardsCfg.DailyExpReword, PWorldEntDefine.RewardType.DailyRandom, EntCfg.ID))
    end

    for _, v in ipairs(RewardsCfg.DailyRewards or {}) do
        if v.Count > 0 then
            table.insert(Rewards, PolUtil.MakeRewardData(v.ResID, v.Count, PWorldEntDefine.RewardType.DailyRandom, EntCfg.ID))
        end
    end

    if RewardsCfg.LackExpReword and RewardsCfg.LackExpReword > 0  then
        table.insert(Rewards, PolUtil.MakeRewardData(ExpID, RewardsCfg.LackExpReword, PWorldEntDefine.RewardType.FewFunc, EntCfg.ID))
    end

    for _, v in ipairs(RewardsCfg.LackRewards or {}) do
        if v.Count > 0 then
            table.insert(Rewards, PolUtil.MakeRewardData(v.ResID, v.Count, PWorldEntDefine.RewardType.FewFunc, EntCfg.ID))
        end
    end
end


function PWorldEntPolDR:GetEntInfo(EntID)
    local Ret = {
        EntCfg                  = nil,
        PWorldID                = nil,
        BG                      = nil,
        PWorldName              = nil,
        MaxMatchCnt             = nil,
        PWorldRequireLv         = nil,
        PWorldRequireEquipLv    = nil,
        PWorldSyncLv            = nil,
        IsChocoboRandomTrack    = nil,
    }

    -- print("ZHG = CurEntID = " .. tostring(VM.CurEntID))
    local EntCfg = SceneEnterDailyRandomCfg:FindCfgByKey(EntID)
    Ret.EntCfg = EntCfg
    -- print("ZHG = EntranceCfg = " .. table_to_string_block(VM.EntranceCfg))
    if EntCfg then
        Ret.PWorldName = EntCfg.Name
        Ret.PWorldRequireEquipLv = EntCfg.EquipLv
        Ret.PWorldRequireLv = EntCfg.PlayerLv
        Ret.BG = EntCfg.BG
    else
        _G.FLOG_ERROR("DailyRandomPol.UpdateVM EntCfg = nil, id = " .. tostring(EntID) )
    end

    Ret.MaxMatchCnt = PWorldEntDefine.RandMatchMaxCnt
    Ret.PWorldID = nil
    Ret.PWorldSyncLv = nil

    return Ret
end

function PWorldEntPolDR:GetRequireLv(EntID)
    local PECfg = SceneEnterDailyRandomCfg:FindCfgByKey(EntID)
    return PECfg and PECfg.PlayerLv or 0
end

function PWorldEntPolDR:GetRequireEquipLv(EntID)
    local PECfg = SceneEnterDailyRandomCfg:FindCfgByKey(EntID)
    return PECfg and PECfg.EquipLv or 0
end

function PWorldEntPolDR:CheckJoinPre(EntID)
    local _, Result = self.Super:CheckJoinPre(EntID)
    Result = Result or {}
    Result.IsPassEquipLv = _G.EquipmentMgr:CalculateEquipScore() >= self:GetRequireEquipLv(EntID)

    for _, v in pairs(Result) do
        if not v then
           return false, Result 
        end
    end

    return true, Result
end

return PWorldEntPolDR
