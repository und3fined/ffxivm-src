---
--- Author: lydianwang
--- DateTime: 2022-05-17
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")

local UIViewID = require("Define/UIViewID")
local ProtoCommon = require("Protocol/ProtoCommon")

local SceneEnterCfg = require("TableCfg/SceneEnterCfg")

local MajorUtil = require("Utils/MajorUtil")

local class_type = ProtoCommon.class_type

---@class TargetFinishPWorld
local TargetFinishPWorld = LuaClass(TargetBase, true)

function TargetFinishPWorld:Ctor(_, Properties)
    self.PWorldIDList = {}
    local PWorldIDStrList = string.split(Properties[1], "|")
    for _, Str in ipairs(PWorldIDStrList) do
        table.insert(self.PWorldIDList, tonumber(Str))
    end

    self.NpcID = tonumber(Properties[2])
    self.EObjID = tonumber(Properties[3])
    self.AreaID = tonumber(Properties[4])
    self.MapID = tonumber(Properties[5])
end

---@return int32
function TargetFinishPWorld:GetNpcID()
    return self.NpcID or 0
end

---@return int32
function TargetFinishPWorld:GetEObjID()
    return self.EObjID or 0
end

function TargetFinishPWorld:PushTrack()
    if _G.PWorldMgr:CurrIsInDungeon() then --条件1：不在副本中
        return false
    end
    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    if not RoleSimple then
        return false
    end
    local CurrProf = RoleSimple.Prof
    if not _G.ProfMgr.CheckProfClass(CurrProf, class_type.CLASS_TYPE_COMBAT) then --条件2：战斗职业
        return false
    end

    local QuestParamList = _G.QuestTrackMgr:GetTrackingQuestParam()
    if QuestParamList then
        local QuestParam = QuestParamList[1]
        if QuestParam then
            if QuestParam.MapID ~= _G.PWorldMgr:GetCurrMapResID() then --条件3：与副本入口不在同一个地图
                return self:TryShowPWorldEnterPanel()
            end
        end
    end
    return false
end

function TargetFinishPWorld:TryShowPWorldEnterPanel()
    --多人副本只会配一个,取第一个即可
    local PWroldID = self.PWorldIDList[1]
    if PWroldID then
        local SceneEnterCfgItem = SceneEnterCfg:FindCfgByKey(PWroldID)
        if SceneEnterCfgItem then --条件4：多人副本
            local Params = {
                EID = PWroldID,
                TypeID = SceneEnterCfgItem.TypeID,
            }
            _G.UIViewMgr:ShowView(UIViewID.PWorldEntranceSelectPanel, Params)
            return true
        end
    end
    return false
end

function TargetFinishPWorld:TryDoEObjInteractive()
end

return TargetFinishPWorld