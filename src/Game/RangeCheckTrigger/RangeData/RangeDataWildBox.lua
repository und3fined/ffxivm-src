--
-- Author: Alex
-- Date: 2025-02-21 16:30
-- Description:野外宝箱范围检测数据
-- 
--

local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local RangeDataBase = require("Game/RangeCheckTrigger/RangeData/RangeDataBase")
local DiscoverNoteMgr = require("Game/SightSeeingLog/DiscoverNoteMgr")
local CompleteSkillCfg = require("TableCfg/DiscoverNoteCompleteSkillCfg")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType
local PWorldMgr = _G.PWorldMgr
local EActorType = _G.UE.EActorType
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

---@class RangeDataWildBox
local RangeDataWildBox = LuaClass(RangeDataBase)

---Ctor
function RangeDataWildBox:Ctor()
    
end

--- 处理相关进入范围逻辑
function RangeDataWildBox:OnEnterTheRange()
    DiscoverNoteMgr:AddTheDetectTargetInRange(self)
    FLOG_INFO("MarkerDetectTarget  RangeDataWildBox:EnterTheRange")
    DiscoverNoteMgr:ShowDetectChatMsgTips()
end

--- 处理相关离开范围逻辑
function RangeDataWildBox:OnExitTheRange()
    DiscoverNoteMgr:RemoveTheDetectTargetInRange(self)
    FLOG_INFO("MarkerDetectTarget  RangeDataWildBox:ExitTheRange")
end

------ 必须实现 ------
--- 获取所属功能类型
function RangeDataWildBox:OnGetGamePlayType()
    return TriggerGamePlayType.WildBox
end

function RangeDataWildBox:GetLocation()
    local ActorType = self:GetEActorType()
    local ListID = self.ListID
    if ActorType and ListID then
        if ActorType == EActorType.Npc then
            local NpcData = _G.MapEditDataMgr:GetNpcByListID(ListID)
            if NpcData then
                return NpcData.BirthPoint
            end
        elseif ActorType == EActorType.EObj then
            local EObjData = _G.MapEditDataMgr:GetEObjByListID(ListID)
            if EObjData then
                return EObjData.Point
            end
        end
    end
end

--- 获取具体的胶囊体触发器数据
function RangeDataWildBox:OnGetCylinderTriggerParams()
    local PosInfo = self:GetLocation()
    if not PosInfo then
        FLOG_ERROR("PosInfo have error")
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

function RangeDataWildBox:GetEActorType()
    return EActorType.EObj
end

return RangeDataWildBox