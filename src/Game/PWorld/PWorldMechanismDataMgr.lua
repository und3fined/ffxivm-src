--
-- Author: peterxie
-- Date: 2025-04-02
-- Description: 地图机制数据管理
--

local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local CS_Operate = ProtoCS.Operate


---@class PWorldMechanismDataMgr
---@field PWorldEntityList Entity[] 副本全地图显示实体，不仅仅是主角视野内的实体，由后台专门协议同步。给某些活动副本全地图显示使用，目前仅运营活动守护天节副本用到
local PWorldMechanismDataMgr = {}

function PWorldMechanismDataMgr:Init()
    self.PWorldEntityList = {}
end

function PWorldMechanismDataMgr:Reset()
    self.PWorldEntityList = {}
end

function PWorldMechanismDataMgr:OnPWorldMechanismData(PWorldMechanismData)
    local PWorldMechanismMapObjectDisplay = PWorldMechanismData.MapObjectDisplay
    if nil == PWorldMechanismMapObjectDisplay then
        return
    end
    local Operate = PWorldMechanismMapObjectDisplay.Op
    local EntityList = PWorldMechanismMapObjectDisplay.Entities

    if Operate == CS_Operate.List then
        self.PWorldEntityList = EntityList
        _G.EventMgr:SendEvent(EventID.PWorldEntityListSync)

    elseif Operate == CS_Operate.Add then
        for _, Entity in ipairs(EntityList) do
            table.insert(self.PWorldEntityList, Entity)
            _G.EventMgr:SendEvent(EventID.PWorldEntityAdd, Entity)
        end

    elseif Operate == CS_Operate.Remove then
        for _, Entity in ipairs(EntityList) do
            table.remove_item(self.PWorldEntityList, Entity.ID, "ID")
            _G.EventMgr:SendEvent(EventID.PWorldEntityRemove, Entity)
        end

    elseif Operate == CS_Operate.Update then
        for _, Entity in ipairs(EntityList) do
            local Item, Index = table.find_item(self.PWorldEntityList, Entity.ID, "ID")
            if Item then
                self.PWorldEntityList[Index] = Entity
                _G.EventMgr:SendEvent(EventID.PWorldEntityUpdate, Entity)
            end
        end
    end
end

function PWorldMechanismDataMgr:GetPWorldEntityList()
    return self.PWorldEntityList
end


return PWorldMechanismDataMgr