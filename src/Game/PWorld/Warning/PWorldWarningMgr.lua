--
-- Author: haialexzhou
-- Date: 2021-08-27
-- Description:副本预警
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local TimeUtil = require("Utils/TimeUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")

---@class PWorldWarningMgr : MgrBase
local PWorldWarningMgr = LuaClass(MgrBase)

function PWorldWarningMgr:OnInit()
    self.WarningGroupData = nil
    self.StartTime = 0
end

function PWorldWarningMgr:OnBegin()
end

function PWorldWarningMgr:OnEnd()
end

function PWorldWarningMgr:OnShutdown()

end

function PWorldWarningMgr:OnRegisterTimer()
    self:RegisterTimer(self.OnUpdate, 0, 0, 0)
end

function PWorldWarningMgr:Reset()
    self.WarningDataList = nil
end

function PWorldWarningMgr:ClearWarningGroupData()
    local EventParams = _G.EventMgr:GetEventParams()
    EventMgr:SendEvent(EventID.PWorldWarningEnd, EventParams)
    self.WarningGroupData = nil
    self.StartTime = 0
end

function PWorldWarningMgr:UpdateWarningData(WarningID, BeginTime)
    if WarningID == 0 then
        self:OnSendWarningEndMsg()
        self.WarningGroupData = nil
        self.StartTime = 0
    else
        self.WarningGroupData = _G.MapEditDataMgr:GetMapEarlyWarningGroup(WarningID)

        if self.WarningGroupData ~= nil then
            table.sort(self.WarningGroupData.BaseInfos,function(a,b) return a.StartTime < b.StartTime end)
            self.StartTime = BeginTime
        else
            FLOG_ERROR("Cant find WarningGroup WarningID is %d",WarningID)
            self:OnSendWarningEndMsg()
            self.WarningGroupData = nil
            self.StartTime = 0
        end
    end
end

function PWorldWarningMgr:OnUpdate()
    if self.WarningGroupData ~= nil and self.WarningGroupData.BaseInfos ~= nil then
        local ServerTime = TimeUtil.GetServerTimeMS()
        local GroupLength = table.length(self.WarningGroupData.BaseInfos)

        if ServerTime >= self.StartTime and GroupLength > 0 then
            if self.WarningGroupData.BaseInfos[GroupLength] == nil then
                FLOG_INFO("self.WarningGroupData.BaseInfos is nil GroupLength is %d",GroupLength)
                self:OnSendWarningEndMsg()
                self.WarningGroupData = nil
                self.StartTime = 0
            elseif self.WarningGroupData.BaseInfos[GroupLength].StartTime == nil then
                FLOG_INFO("self.WarningGroupData.BaseInfos[GroupLength].StartTime is nil")
                self:OnSendWarningEndMsg()
                self.WarningGroupData = nil
                self.StartTime = 0
            elseif self.WarningGroupData.BaseInfos[GroupLength].LastTime == nil then
                FLOG_INFO("self.WarningGroupData.BaseInfos[GroupLength].LastTime is nil")
                self:OnSendWarningEndMsg()
                self.WarningGroupData = nil
                self.StartTime = 0
            else
                if ServerTime <= self.StartTime + (self.WarningGroupData.BaseInfos[GroupLength].StartTime + self.WarningGroupData.BaseInfos[GroupLength].LastTime) * 1000 then
                    self:OnSendWarningDuringMsg()
                else
                    self:OnSendWarningEndMsg()
                    self.WarningGroupData = nil
                    self.StartTime = 0
                end
            end
        end
    end
end

function PWorldWarningMgr:GetStartTime()
    return self.StartTime
end

--获取预警条目
---@field ActorClassType 角色职能
function PWorldWarningMgr:GetWarningItems(ActorClassType)
    local WarningItems = {}
    if self.WarningGroupData ~= nil then
        local ServerTime = TimeUtil.GetServerTimeMS()
        local index = 1

        for _,WarningItem in pairs(self.WarningGroupData.BaseInfos) do
            local time = self.StartTime + (WarningItem.StartTime + WarningItem.LastTime) * 1000 - ServerTime
            if time > 0 and time <= WarningItem.LastTime * 1000 then
                if WarningItem.Tank == true and ActorClassType == 1 then
                    table.insert(WarningItems,WarningItem)
                    index = index + 1
                elseif WarningItem.Attacker == true and (ActorClassType == 2 or ActorClassType == 3 or ActorClassType == 4) then
                    table.insert(WarningItems,WarningItem)
                    index = index + 1
                elseif WarningItem.Healer == true and ActorClassType == 5 then
                    table.insert(WarningItems,WarningItem)
                    index = index + 1
                end
            end

            if index > 4 then
                break
            end
        end
    end

    return  WarningItems
end

function PWorldWarningMgr:OnSendWarningEndMsg()
    local EventParams = _G.EventMgr:GetEventParams()

    if self.WarningGroupData ~= nil then
        EventParams.ULongParam1 = self.WarningGroupData.ID
        EventMgr:SendEvent(EventID.PWorldWarningEnd, EventParams)
    end
end

function PWorldWarningMgr:OnSendWarningDuringMsg()
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.ULongParam1 = self.WarningGroupData.ID
    EventMgr:SendEvent(EventID.PWorldWarningDuring, EventParams)
end

return PWorldWarningMgr