--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2025-02-28 11:42:06
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-03-27 09:50:08
FilePath: \Script\Game\PWorld\Entrance\Policy\PWorldEntPolNM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneCombatCfg = require("TableCfg/SceneCombatCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local PWorldEntPol = require("Game/PWorld/Entrance/Policy/PWorldEntPol")

local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
local PolUtil = require("Game/PWorld/Entrance/Policy/PWorldEntPolUtil")

---@class PWorldEntPolNM : PWorldEntPol
local PWorldEntPolNM = LuaClass(PWorldEntPol)


function PWorldEntPolNM:CheckFilter(EntID)
    return self.IsPassPreQuest(EntID)
end

function PWorldEntPolNM:GetRewardData(EntCfg)
    local RewardsData = {}

    if not EntCfg then
        return
    end

    local Cfg = EntCfg

    local FirstPassRewards = Cfg.InitialRewards or {}
    local NormalRewards = Cfg.Rewards or {}

    for Idx, ID in ipairs(FirstPassRewards) do
        local Cnt = Cfg.InitialRewardCnt[Idx] or 0
        local Data = PolUtil.MakeRewardData(ID, Cnt, PWorldEntDefine.RewardType.FirstPass, Cfg.ID)
        table.insert(RewardsData, Data)
    end

    for Idx, ID in ipairs(NormalRewards) do
        local Cnt = Cfg.RewardCnt[Idx] or 0
        local Data = PolUtil.MakeRewardData(ID, Cnt, PWorldEntDefine.RewardType.Norm, Cfg.ID)
        table.insert(RewardsData, Data)
    end

    for i, v in ipairs(Cfg.WeeklyItem or {}) do
        table.insert(RewardsData, PolUtil.MakeRewardData(v, Cfg.WeeklyItemCnt[i] or 0, PWorldEntDefine.RewardType.Weekly, Cfg.ID))
    end

    return RewardsData
end

function PWorldEntPolNM:GetEntInfo(EntID)
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
        CombatCfg               = nil,
    }

    local EntCfg = SceneEnterCfg:FindCfgByKey(EntID)
    Ret.EntCfg = EntCfg or {}
    if EntCfg == nil then
        _G.FLOG_ERROR("PWorldEntPolNM:GetEntInfo invalid EntID ".. tostring(EntID) )
        return Ret 
    end

    Ret.PWorldID = EntCfg.ID
    Ret.BG = EntCfg.BG

    Ret.MaxMatchCnt = PWorldEntDefine.NormMatchMaxCnt

    local PCfg = PworldCfg:FindCfgByKey(Ret.PWorldID)
    local CombatCfg = SceneCombatCfg:FindCfgByKey(Ret.PWorldID)
    if PCfg then
        Ret.PWorldName = PCfg.PWorldName
        Ret.PWorldRequireLv = PCfg.PlayerLevel
    else
        Ret.PWorldName = ""
        Ret.PWorldRequireLv = 0
        _G.FLOG_ERROR("NormalPol.UpdateVM PCfg = nil PWorldID = " .. tostring(Ret.PWorldID) )
    end

    Ret.PWorldRequireEquipLv = CombatCfg and CombatCfg.EquipLv or 0
    Ret.PWorldSyncLv = CombatCfg and CombatCfg.SyncMaxLv or 0
    Ret.CombatCfg = CombatCfg
    
    return Ret
end

function PWorldEntPolNM:GetRequireLv(EntID)
    local PCfg = PworldCfg:FindCfgByKey(EntID)
    return PCfg and PCfg.PlayerLevel or 0
end

function PWorldEntPolNM:GetRequireEquipLv(EntID)
    local CombatCfg = SceneCombatCfg:FindCfgByKey(EntID)
    return CombatCfg and CombatCfg.EquipLv or 0
end

return PWorldEntPolNM


