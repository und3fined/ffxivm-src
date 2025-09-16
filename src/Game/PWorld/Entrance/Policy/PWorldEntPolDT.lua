--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2024-11-13 14:42:25
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-11-20 15:25:26
FilePath: \Script\Game\PWorld\Entrance\Policy\PWorldEntPolDT.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local PWorldEntPolDR = require("Game/PWorld/Entrance/Policy/PWorldEntPolDR")
local PWorldEntPolDT = LuaClass(PWorldEntPolDR)
local PolUtil        = require("Game/PWorld/Entrance/Policy/PWorldEntPolUtil")
local LSTR = _G.LSTR
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneCombatCfg = require("TableCfg/SceneCombatCfg")
local MajorUtil = require("Utils/MajorUtil")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local MentorDefine = require("Game/Mentor/MentorDefine")
local PworldCfg = require("TableCfg/PworldCfg")
local ProfUtil = require("Game/Profession/ProfUtil")

local function IsAllFinished(ID)
    local RandList = PolUtil.GetDRPoolList(ID)
    local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
    local PworldCfg = require('TableCfg/PworldCfg')
    for _, PWorldID in ipairs(RandList) do
        local ECfg = SceneEnterCfg:FindCfgByKey(PWorldID)
        if ECfg == nil then
           return false 
        end

        if not PolUtil.HasPreQuestFinish(ECfg.PreQuestID) then
            return false
        end

        local PCfg = PworldCfg:FindCfgByKey(PWorldID)
        if PCfg == nil then
           return false 
        end

        if _G.CounterMgr:GetCounterCurrValue(PCfg.SucceedCounterID or 0) == 0 then
            return false
        end
    end

    return true
end

function PWorldEntPolDT:CheckJoinPre(EntID)
    local RVM = MajorUtil.GetMajorRoleVM(true)
    if RVM == nil then
       return false, {} 
    end

    local Lv = RVM.Level
    local EquipLv = _G.EquipmentMgr:CalculateEquipScore()
    local ReqEquipLv = self:GetRequireEquipLv(EntID)
    local ReqLv = self:GetRequireLv(EntID)
    local Prof = RVM.Prof
    local IsCombatProf = ProfUtil.IsCombatProf(Prof)

    local Ret = {
        IsPassMem = IsCombatProf,
        IsPassLv = Lv >= ReqLv,
        IsPassEquipLv = EquipLv >= ReqEquipLv,
    }

    local IsPass = true

    for _, V in pairs(Ret) do
        IsPass = IsPass and V
    end

    local Unlock = self:CheckCondPWorldUnlock(EntID)
    IsPass = IsPass and Unlock

    if IsPass then
        IsPass = IsAllFinished(EntID)
    end
    
    return IsPass, Ret
end

function PWorldEntPolDT:CheckJoin()
    return true
end

function PWorldEntPolDT:CheckFilter(EntID)
    return self.IsPassPreQuest(EntID, true)
end

function PWorldEntPolDT:CheckEnter(EntID)
    return false
end

function PWorldEntPolDT:CheckCondPWorldUnlock(EntID)
    if not _G.MentorMgr:VerifyMentorIdentity(MentorDefine.GuideType.GUIDE_TYPE_FIGHT) then
        return false
    end

    local PList = PolUtil.GetDRPoolList(EntID)
    local NList = {}
    for _, EID in pairs(PList) do
        local ECfg = SceneEnterCfg:FindCfgByKey(EID)
        if ECfg then
            if not PolUtil.HasPreQuestFinish(ECfg.PreQuestID) then
                local PCfg = PworldCfg:FindCfgByKey(EID)
                if PCfg then
                    table.insert(NList, PCfg.PWorldName)
                else
                    _G.FLOG_ERROR("zhg Util.GetEntDirectorPreCheckReason PCfg = NIL EID = " .. tostring(EID))
                end
            end
        else
            _G.FLOG_ERROR("zhg Util.GetEntDirectorPreCheckReason ECfg = NIL EID = " .. tostring(EID))
        end
    end

    if table.empty(NList) then
        return true
    else
        local NameStr = table.concat(NList, "，")
        return false, NameStr
    end

    
end

return PWorldEntPolDT
