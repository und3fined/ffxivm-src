
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local RangeDataFactory = require("Game/RangeCheckTrigger/RangeDataFactory")
local ActorUtil = require("Utils/ActorUtil")
--local DynDataTriggerRangeCheck = require("Game/PWorld/DynData/DynDataTriggerRangeCheck")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType
local AuthenticationType = RangeCheckTriggerDefine.AuthenticationType
local EActorType = _G.UE.EActorType
local FLOG_ERROR = _G.FLOG_ERROR

---@class RangeCheckTriggerMgr : MgrBase
local RangeCheckTriggerMgr = LuaClass(MgrBase)

function RangeCheckTriggerMgr:OnInit()

end

function RangeCheckTriggerMgr:OnBegin()
    self.RangeCheckDataExistMap = {} 
    self.RangeCheckDataEditorMap = {}
    self.RangeCheckDataCustomMap = {}
end

function RangeCheckTriggerMgr:OnEnd()
    self.RangeCheckDataExistMap = nil
    self.RangeCheckDataEditorMap = nil
    self.RangeCheckDataCustomMap = nil
end

function RangeCheckTriggerMgr:OnShutdown()
    
end

function RangeCheckTriggerMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
end


function RangeCheckTriggerMgr:OnGameEventPWorldExit()
    self:ClearAllRange()
end

function RangeCheckTriggerMgr:ClearExistRange()
    local RangeDataMap = self.RangeCheckDataExistMap
    if not RangeDataMap then
        return
    end
    for _, RangeData in pairs(RangeDataMap) do
        RangeData:Destroy()
    end
    self.RangeCheckDataExistMap = {}
end

function RangeCheckTriggerMgr:ClearEditorRange()
    local RangeDataMap = self.RangeCheckDataEditorMap
    if not RangeDataMap then
        return
    end
    for _, RangeDataResMap in pairs(RangeDataMap) do
        for _, RangeData in pairs(RangeDataResMap) do
            RangeData:Destroy()
        end
    end
    self.RangeCheckDataEditorMap = {}
end

function RangeCheckTriggerMgr:ClearCustomRange()
    local RangeDataMap = self.RangeCheckDataCustomMap
    if not RangeDataMap then
        return
    end
    for _, RangeDataResMap in pairs(RangeDataMap) do
        for _, RangeData in pairs(RangeDataResMap) do
            RangeData:Destroy()
        end
    end
    self.RangeCheckDataCustomMap = {}
end

function RangeCheckTriggerMgr:ClearAllRange()
    self:ClearEditorRange()
    self:ClearExistRange()
    self:ClearCustomRange()
end

--- 为已创建的目标生成范围检测数据
---@param TriggerGamePlayType RangeCheckTriggerDefine.TriggerGamePlayType
---@param EntityID number@Actor实例id
function RangeCheckTriggerMgr:AddRangeCheckActorCreated(TriggerGamePlayType, EntityID)
    if not EntityID then
        return
    end
    local RangeDataMap = self.RangeCheckDataExistMap or {}
 
    if RangeDataMap[EntityID] then
        FLOG_ERROR("RangeCheckTriggerMgr:AddRangeCheck the range have existed")
        return
    end
    
    local RangeData = RangeDataFactory.CreateRangeDataInstance(TriggerGamePlayType)
    if not RangeData then
        return
    end

    local Params = {
        EntityID = EntityID
    }
    RangeData:Init(Params)
    RangeDataMap[EntityID] = RangeData
    self.RangeCheckDataExistMap = RangeDataMap
end

function RangeCheckTriggerMgr:RemoveRangeCheckActorCreated(EntityID)
    if not EntityID then
        return
    end
    local RangeDataMap = self.RangeCheckDataExistMap
    if not RangeDataMap then
        return
    end
    local RemoveRangeData = RangeDataMap[EntityID]
    if not RemoveRangeData then
        return
    end
    RemoveRangeData:Destroy()
    RangeDataMap[EntityID] = nil
end

--- 为未创建的目标生成范围检测数据
---@param TriggerGamePlayType RangeCheckTriggerDefine.TriggerGamePlayType
---@param ResID number@Actor实例资源id
---@param ListID number@Actor关卡编辑器id
function RangeCheckTriggerMgr:AddRangeCheckActorNotCreated(TriggerGamePlayType, ResID, ListID)
    if not ResID then
        return
    end

    local ConvertListID = ListID or 0

    local RangeDataMap = self.RangeCheckDataEditorMap or {}
    if RangeDataMap[ResID] and RangeDataMap[ResID][ConvertListID] then
        return
    end
    local FirstMap = RangeDataMap[ResID] or {}
    local RangeData = RangeDataFactory.CreateRangeDataInstance(TriggerGamePlayType)
    if not RangeData then
        return
    end

    local Params = {
        ResID = ResID,
        ListID = ListID,
    }
    RangeData:Init(Params)
    FirstMap[ConvertListID] = RangeData
    RangeDataMap[ResID] = FirstMap
    self.RangeCheckDataEditorMap = RangeDataMap
end


--- 移出未创建的目标范围检测数据
---@param ResID number@Actor实例资源id
---@param ListID number@Actor关卡编辑器id(若为纯客户端单独创建，可能为nil)
function RangeCheckTriggerMgr:RemoveRangeCheckActorNotCreated(ResID, ListID)
    if not ResID then
        return
    end

    local ConvertListID = ListID or 0

    local RangeDataMap = self.RangeCheckDataEditorMap
    if not RangeDataMap then
        return
    end

    local FirstMap = RangeDataMap[ResID]
    if not FirstMap then
        return
    end
    local RemoveRangeData = FirstMap[ConvertListID]
    if not RemoveRangeData then
        return
    end
    RemoveRangeData:Destroy()
    FirstMap[ConvertListID] = nil
end

--- 为未创建的目标生成范围检测数据
---@param TriggerGamePlayType RangeCheckTriggerDefine.TriggerGamePlayType
---@param ResID number@Actor实例资源id
---@param ListID number@Actor关卡编辑器id(若为纯客户端单独创建，可能为nil)
function RangeCheckTriggerMgr:AddRangeCheckCustomMap(TriggerGamePlayType, CustomID)
    if not CustomID then
        return
    end

    local RangeDataMap = self.RangeCheckDataCustomMap or {}
    if RangeDataMap[TriggerGamePlayType] and RangeDataMap[TriggerGamePlayType][CustomID] then
        return
    end
    local FirstMap = RangeDataMap[TriggerGamePlayType] or {}
    local RangeData = RangeDataFactory.CreateRangeDataInstance(TriggerGamePlayType)
    if not RangeData then
        return
    end

    local Params = {
        CustomID = CustomID,
    }
    RangeData:Init(Params)
    FirstMap[CustomID] = RangeData
    RangeDataMap[TriggerGamePlayType] = FirstMap
    self.RangeCheckDataCustomMap = RangeDataMap
end


--- 移出未创建的目标范围检测数据
---@param ResID number@Actor实例资源id
function RangeCheckTriggerMgr:RemoveRangeCheckCustomMap(TriggerGamePlayType, CustomID)
    if not TriggerGamePlayType or not CustomID then
        return
    end

 
    local RangeDataMap = self.RangeCheckDataCustomMap
    if not RangeDataMap or not next(RangeDataMap) then
        return
    end

    local FirstMap = RangeDataMap[TriggerGamePlayType]
    if not FirstMap then
        return
    end
    local RemoveRangeData = FirstMap[CustomID]
    if not RemoveRangeData then
        return
    end
    RemoveRangeData:Destroy()
    FirstMap[CustomID] = nil
end

function RangeCheckTriggerMgr.GetAuthenticationType(GamePlayType)
    if TriggerGamePlayType.Band == GamePlayType then
        return AuthenticationType.Custom
    elseif TriggerGamePlayType.WildBox == GamePlayType then
        return AuthenticationType.Editor
    elseif TriggerGamePlayType.MysterMerchant == GamePlayType then
        return AuthenticationType.Editor
    end
end

function RangeCheckTriggerMgr.GetEActorType(GamePlayType)
    if TriggerGamePlayType.Band == GamePlayType then
        return EActorType.Npc
    elseif TriggerGamePlayType.WildBox == GamePlayType then
        return EActorType.EObj
    elseif TriggerGamePlayType.MysterMerchant == GamePlayType then
        return EActorType.Npc
    end
end

--- 获取特定目标的世界坐标位置（目前为探索笔记地图范围检测显示Marker技能服务，只涉及编辑器以及自定义配表使用）
function RangeCheckTriggerMgr:GetLocation(GamePlayType, AuthenID)
    local AuthenType = self.GetAuthenticationType(GamePlayType)
    if AuthenType == AuthenticationType.Custom then
        local SearchMap = self.RangeCheckDataCustomMap
        if not SearchMap or not next(SearchMap) then
            return
        end
        local FirstMap = SearchMap[GamePlayType]
        if not FirstMap then
            return
        end
        local RangeData = FirstMap[AuthenID]
        if not RangeData then
            return
        end
        return RangeData:GetLocation()
    elseif AuthenType == AuthenticationType.Editor then
        local ActorType = self.GetEActorType(GamePlayType)
        if ActorType == EActorType.Npc then
            local NpcData = _G.MapEditDataMgr:GetNpcByListID(AuthenID)
            if NpcData then
                return NpcData.BirthPoint
            end
        elseif ActorType == EActorType.EObj then
            local EObjData = _G.MapEditDataMgr:GetEObjByListID(AuthenID)
            if EObjData then
                return EObjData.Point
            end
        end
    end
end

return RangeCheckTriggerMgr