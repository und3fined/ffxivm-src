--
-- Author: Alex
-- Date: 2025-06-12 20:51
-- Description:金碟游戏仙人赐福机器检测
-- 
--

local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local RangeDataBase = require("Game/RangeCheckTrigger/RangeData/RangeDataBase")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local FairyBlessedParamCfg = require("TableCfg/FairyBlessedParamCfg")
local FairyBlessedWeightCfg = require("TableCfg/FairyBlessedWeightCfg")
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType
local FairyBlessedParamType = ProtoRes.Game.FairyBlessedParamType
local PWorldMgr = _G.PWorldMgr
local FLOG_INFO = _G.FLOG_INFO
--local FLOG_ERROR = _G.FLOG_ERROR

---@class RangeDataGoldSauserBlessMachineCheck
local RangeDataGoldSauserBlessMachineCheck = LuaClass(RangeDataBase)

---Ctor
function RangeDataGoldSauserBlessMachineCheck:Ctor()
    
end

--- 处理相关进入范围逻辑
function RangeDataGoldSauserBlessMachineCheck:OnEnterTheRange()
    _G.GoldSaucerBlessingMgr:EnterTheShowRightTopPanelRange()
    _G.GoldSaucerBlessingMgr:NotifyTriggerTheTutorial()
end

--- 处理相关离开范围逻辑
function RangeDataGoldSauserBlessMachineCheck:OnExitTheRange()
    _G.GoldSaucerBlessingMgr:ExitTheShowRightTopPanelRange()
end

------ 必须实现 ------
--- 获取所属功能类型
function RangeDataGoldSauserBlessMachineCheck:OnGetGamePlayType()
    return TriggerGamePlayType.GoldSauserBlessMachineCheck
end

function RangeDataGoldSauserBlessMachineCheck:GetLocation()
    local SgInstanceID = self.CustomID
    if type(SgInstanceID) ~= "number" then
        return
    end

    local WeightCfg = FairyBlessedWeightCfg:FindCfg(string.format("SgbID = %d", SgInstanceID))
    if not WeightCfg then
        return
    end

    local EObjID = WeightCfg.EObjResID
    if not EObjID then
        return
    end

    local EObjData = _G.MapEditDataMgr:GetEObjByResID(EObjID)
    if not EObjData then
        return
    end

    return EObjData.Point or _G.UE.FVector(0, 0, 0)
end

--- 获取具体的胶囊体触发器数据
function RangeDataGoldSauserBlessMachineCheck:OnGetCylinderTriggerParams()
    local PosInfo = self:GetLocation()
    if not PosInfo then
        return
    end
    local Cylinder = {
        Start = {
            X = PosInfo.X,
            Y = PosInfo.Y,
            Z = PosInfo.Z,
        },
        Radius = 2000,
        Height = 10000, -- 默认胶囊体100m
    }

    local RadiusConfig = FairyBlessedParamCfg:FindCfgByKey(FairyBlessedParamType.FairyBlessedParamTypeRadiusCheck)
    if RadiusConfig then
        local ConfigValue = RadiusConfig.Value
        if ConfigValue and ConfigValue > 1000 then
            Cylinder.Radius = ConfigValue
        end
    end--]]

    FLOG_INFO("GoldSauserBlessMachineCheck:OnGetCylinderTriggerParams Radius %s", Cylinder.Radius)
    return Cylinder
end

return RangeDataGoldSauserBlessMachineCheck