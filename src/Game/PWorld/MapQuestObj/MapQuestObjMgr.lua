--
-- Author: lydianwang
-- Date: 2021-12-13
-- Description: 任务对象管理
--

local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local QuestMgr = require("Game/Quest/QuestMgr")

local ProtoRes = require ("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local NpcCfg = require("TableCfg/NpcCfg")

local UActorManager = nil

---@class MapQuestObjMgr
local MapQuestObjMgr = {}

function MapQuestObjMgr:Init()
    -- self.CliNpcEntityIDList = {}
    self.TriggerAreaList = {}

    if UActorManager == nil then
        UActorManager = _G.UE.UActorManager.Get()
    end
end

function MapQuestObjMgr:Reset()
    if self.TriggerAreaList ~= nil then
        for _, DynArea in pairs(self.TriggerAreaList) do
            DynArea:Destroy()
        end
    end

    -- self.CliNpcEntityIDList = {}
    self.TriggerAreaList = {}
end

--任务有变化重新刷下当前视野：有可能视野内种植的npc需要进入/离开视野
function MapQuestObjMgr:OnUpdateQuest()
    ClientVisionMgr:VisionTick()
    
    local CurrMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if (CurrMapEditCfg == nil) then
        return
    end

    -- 触发器
    self:LoadTriggerArea(CurrMapEditCfg)
end

function MapQuestObjMgr:LoadTriggerArea(CurrMapEditCfg)
    local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    local AreaList = CurrMapEditCfg.AreaList
    for _, Area in ipairs(AreaList) do
        if (Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_QUEST) then
            local DynArea = self.TriggerAreaList[Area.ID]
            local MapID = _G.MapEditDataMgr:GetMapEditCfg().MapID
            if QuestMgr:CanCreateQuestTriggerArea(Area.ID, MapID) then
                if DynArea == nil then
                    DynArea = PWorldDynDataMgr:LoadSingleMapArea(Area)
                    if (DynArea ~= nil) then
                        self.TriggerAreaList[Area.ID] = DynArea
                    end
                end
            else
                if DynArea ~= nil then
                    DynArea:Destroy()
                    self.TriggerAreaList[Area.ID] = nil
                end
            end
        end
    end
end

return MapQuestObjMgr