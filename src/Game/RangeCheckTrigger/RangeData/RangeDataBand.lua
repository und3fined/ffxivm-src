--
-- Author: Alex
-- Date: 2025-02-25 20:01
-- Description:巡回乐团检测数据
-- 
--

local LuaClass = require("Core/LuaClass")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RangeDataBase = require("Game/RangeCheckTrigger/RangeData/RangeDataBase")
local DiscoverNoteMgr = require("Game/SightSeeingLog/DiscoverNoteMgr")
local CompleteSkillCfg = require("TableCfg/DiscoverNoteCompleteSkillCfg")
local TouringBandTimelineCfg = require("TableCfg/TouringBandTimelineCfg")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType
local PWorldMgr = _G.PWorldMgr
local EActorType = _G.UE.EActorType
local FLOG_INFO = _G.FLOG_INFO
--local FLOG_ERROR = _G.FLOG_ERROR

---@class RangeDataBand
local RangeDataBand = LuaClass(RangeDataBase)

---Ctor
function RangeDataBand:Ctor()
    
end

--- 处理相关进入范围逻辑
function RangeDataBand:OnEnterTheRange()
    DiscoverNoteMgr:AddTheDetectTargetInRange(self)
    FLOG_INFO("RangeDataBand:OnEnterTheRange TimeLineId = %d", self.CustomID)
    DiscoverNoteMgr:ShowDetectChatMsgTips()
end

--- 处理相关离开范围逻辑
function RangeDataBand:OnExitTheRange()
    DiscoverNoteMgr:RemoveTheDetectTargetInRange(self)
    FLOG_INFO("RangeDataBand:OnExitTheRange TimeLineId = %d", self.CustomID)
end

------ 必须实现 ------
--- 获取所属功能类型
function RangeDataBand:OnGetGamePlayType()
    return TriggerGamePlayType.Band
end

function RangeDataBand:GetLocation()
    local TimeLineID = self.CustomID
    if not TimeLineID then
        return
    end

    local BandTimeLineCfg = TouringBandTimelineCfg:FindCfgByKey(TimeLineID)
    if not BandTimeLineCfg then
        return
    end

    return BandTimeLineCfg.Pos
end

--- 获取具体的胶囊体触发器数据
function RangeDataBand:OnGetCylinderTriggerParams()
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
        Radius = 100,
        Height = 10000, -- 默认胶囊体100m
    }

    
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if CurMapID then
        local ActiveID = DiscoverNoteMgr:GetTheMapActiveID(CurMapID)
        if ActiveID then
            local SkillCfg = CompleteSkillCfg:FindCfgByKey(ActiveID)
            if SkillCfg then
                Cylinder.Radius = SkillCfg.ActiveRange or 0
            end
        end
    end

    return Cylinder
end

function RangeDataBand:GetEActorType()
    return EActorType.Npc
end

return RangeDataBand