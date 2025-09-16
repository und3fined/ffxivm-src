---
--- Author: daniel
--- DateTime: 2023-03-20 16:15
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")

local UIBindableList = require("UI/UIBindableList")
local ArmyInfoTrendsItemVM = require("Game/Army/ItemVM/ArmyInfoTrendsItemVM")
local ArmyLogFilterType = ArmyDefine.ArmyLogFilterType

---@class ArmyInfoTrendsVM : UIViewModel
---@field LogList any @日志信息
local ArmyInfoTrendsVM = LuaClass(UIViewModel)
---Ctor
function ArmyInfoTrendsVM:Ctor()
    self.LogList = UIBindableList.New(ArmyInfoTrendsItemVM)
end

function ArmyInfoTrendsVM:OnInit()
    self.ArmyLogs = nil
    self.CurFilterType = 0
    self.IsEmpty = nil
end

function ArmyInfoTrendsVM:OnBegin()
end

function ArmyInfoTrendsVM:OnEnd()
    self.LogList:Clear()
end

function ArmyInfoTrendsVM:OnShutdown()
    self.ArmyLogs = nil
    self.CurFilterType = nil
end

function ArmyInfoTrendsVM:SetData(ArmyLogs)
    self.ArmyLogs = ArmyLogs
    self:UpdateLogsList(0)
end

function ArmyInfoTrendsVM:UpdateLogsList(Type)
    self.CurFilterType = Type
    if Type == 0 then
        self.LogList:UpdateByValues(self.ArmyLogs)
        if self.ArmyLogs == nil then
            self.IsEmpty = true
        elseif self.ArmyLogs and #self.ArmyLogs == 0 then
            self.IsEmpty = true
        else
            self.IsEmpty = false
        end
    else
        local FilterTypeData = table.find_item(ArmyLogFilterType, Type, "Type")
        local Filter = table.find_all_by_predicate(self.ArmyLogs, function(Element)
            return Element.FilterType == FilterTypeData.Name
        end)
        if Filter == nil then
            self.IsEmpty = true
        elseif Filter and #Filter == 0 then
            self.IsEmpty = true
        else
            self.IsEmpty = false
        end
        self.LogList:UpdateByValues(Filter)
    end
end

function ArmyInfoTrendsVM:AddLogsToList(ArmyLogs)
    if self.ArmyLogs == nil then
        self.ArmyLogs = {}
    end
    for _, LogData in ipairs(ArmyLogs) do
        local Result = table.find_by_predicate(self.ArmyLogs, function(Element)
            return Element.ID == LogData.ID
        end)
        if not Result then
            table.insert(self.ArmyLogs, LogData)
        end
    end
    self:UpdateLogsList(self.CurFilterType)
end

return ArmyInfoTrendsVM