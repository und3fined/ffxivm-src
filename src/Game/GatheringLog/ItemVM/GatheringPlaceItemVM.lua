---
--- Author: Leo
--- DateTime: 2023-03-30 17:50:34
--- Description: 采集笔记
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local GatheringLogMgr = require("Game/GatheringLog/GatheringLogMgr")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local StringTools = _G.StringTools
local LSTR = _G.LSTR
local MajorUtil = require("Utils/MajorUtil")
local ColorDefine = require("Define/ColorDefine")
local FLinearColor = _G.UE.FLinearColor

---@class GatheringPlaceItemVM : UIViewModel
---@field ID string@采集点ID
---@field GatherLevel int @采集点等级
---@field Name string @采集点名称
---@field CommonResourceID int @采集点物ID
---@field MapID int @所在地图ID
---@field TimeCondition string @可采集时间
---@field ShowTimeText string @还有多久出现/结束
---@field bUnknownLoc bool @是否未解锁
---@field bShowGoToBtn bool @是否显示前往地图图标
---@field bGatherItemSetClock bool @判断对应的采集物是否可以设置闹钟

local GatheringPlaceItemVM = LuaClass(UIViewModel)

---Ctor
function GatheringPlaceItemVM:Ctor()
    self.ShowTimeText = 0
    self.Name = ""
    self.ArrowIcon = ""
    self.bArrowShow = false
    self.bTextTimeVisible = false
    self.bSelect = false
    self.bImgLineVisible = false
    self.bGatherItemSetClock = false
    --表中信息
    self.ID = 0
    self.GatherLevel = 0
    --0是未知 1是已知
    self.bUnknownLoc = false
    self.CommonResourceID = 0
    self.MapID = 0
    -- 可采集时间
    self.TimeCondition = {}
    self.RightTime = 0
    self.TimeFormat = ""
    self.bInClockList = false
    self.bGathering = false
    self.bBeginGather = false
    self.GatherType = 0
    self.ArrowColorOpacity = FLinearColor(1, 1, 1, 1)
end

function GatheringPlaceItemVM:IsEqualVM(Value)
    return true
end

function GatheringPlaceItemVM:UpdateVM(Value)
    self.bImgLineVisible = Value.bImgLineVisible
    local LastFilterState = GatheringLogMgr.LastFilterState
    local SelectHorIndex = LastFilterState.HorTabsIndex or 1
    local HorBarIndex = GatheringLogDefine.HorBarIndex
    local ClockIndex = HorBarIndex.ClockIndex
    if SelectHorIndex == ClockIndex then
        self.bInClockList = true
    else
        self.bInClockList = false
    end
    self.bSelect = Value.bSelect or false
    self.ID = Value.ID
    self.GatherLevel = Value.GatherLevel
    self.bUnknownLoc = Value.bUnknownLoc 
    self.CommonResourceID = Value.CommonResourceID
    self.MapID = Value.MapID
    self.Name = string.format("%s%s   %s", Value.GatherLevel, LSTR(70022), Value.GatherDescribe)

    -- 可采集时间
    self.TimeCondition = Value.TimeCondition
    local TimeCondition = self.TimeCondition
    if not table.is_nil_empty(TimeCondition) then
        self:SetTimeTextTip(TimeCondition)
    else
        self.bTextTimeVisible = false
    end
    if self.bUnknownLoc then
        self.Name = "？？？？"
    end
    --self:SetbShowGoToBtn()
    self.bArrowShow = Value.bArrowShow
    self.GatherType = Value.GatherType
    self.GatherID = Value.GatherID
end

function GatheringPlaceItemVM:SetUnknownLocTrue(Value)
    self.bUnknownLoc = false
    self.Name = string.format("%s%s   %s", Value.GatherLevel, LSTR(70022), Value.GatherDescribe)
end


---@type 设置还有几分钟出现 或 多久结束
function GatheringPlaceItemVM:SetTimeTextTip(TimeCondition)
    local LastFilterState = GatheringLogMgr.LastFilterState
    local bInSearchPage = LastFilterState.bInSearchPage
    --方便测试先不打开 后期打开
    if not self.bInClockList and not bInSearchPage then
    --self.bTextTimeVisible = false
    --return
    end
    self.bTextTimeVisible = true
    local ServerTime = TimeUtil.GetServerLogicTime()
    local AozySecond = ServerTime * (12 / 35) * 60
    local OneDaySec = 86400
    local OneAozySecInReal = 7 / 144
    local DayTime = AozySecond % OneDaySec
    local StartAozyTime, EndAozyTime = self:GetStartAndEndAozyTime(TimeCondition[1])
    local TimeStamp = TimeUtil.GetServerLogicTimeMS()
    local NeedTime = 0
    if DayTime <= EndAozyTime and DayTime >= StartAozyTime then
        self.bGathering = true
        --1s等于显示世界中7/144秒 得到现实世界的s
        NeedTime = math.ceil((EndAozyTime - DayTime) * (OneAozySecInReal))
    elseif DayTime <= StartAozyTime then
        self.bGathering = false
        NeedTime = math.ceil((StartAozyTime - DayTime) * (OneAozySecInReal))
    elseif EndAozyTime <= DayTime then
        self.bGathering = false
        if #TimeCondition == 1 then
            NeedTime = math.ceil((OneDaySec - DayTime + StartAozyTime) * (OneAozySecInReal))
        else
            --后面再写
            local StartAozyTime2, EndAozyTime2 = self:GetStartAndEndAozyTime(TimeCondition[2])
            if DayTime <= EndAozyTime2 and DayTime >= StartAozyTime2 then
                self.bGathering = true
                NeedTime = math.ceil((EndAozyTime2 - DayTime) * (OneAozySecInReal))
            elseif DayTime <= StartAozyTime2 then
                self.bGathering = false
                NeedTime = math.ceil((StartAozyTime2 - DayTime) * (OneAozySecInReal))
            elseif EndAozyTime2 <= DayTime then
                self.bGathering = false
                -- 要按照第一次出现的时间计算
                NeedTime = math.ceil((OneDaySec - DayTime + StartAozyTime) * (OneAozySecInReal))
            end
        end
    end
    --秒转化到毫秒
    local InvertSecToMsNum = 1000
    self.ShowTimeText = TimeStamp + NeedTime * InvertSecToMsNum
end

---@type 得到时间戳 例：9：00~11：00 返回 9：00在当日对应的秒数 11：00在当日对应的秒数
function GatheringPlaceItemVM:GetStartAndEndAozyTime(Time)
    local StartAndEndTime = StringTools.StringSplit(Time, " - ")
    local StartTime = StartAndEndTime[1]
    local EndTime = StartAndEndTime[3]

    local OneHourSec = 3600
    local OneMinSec = 60
    local StartHourAndMinute = StringTools.StringSplit(StartTime, ":")
    local StartHour = tonumber(StartHourAndMinute[1])
    local MinIndex = 2
    local StartMinute = tonumber(StartHourAndMinute[MinIndex])
    local StartAozyTime = StartHour * OneHourSec + StartMinute * OneMinSec

    local EndHourAndMinute = StringTools.StringSplit(EndTime, ":")
    local EndHour = tonumber(EndHourAndMinute[1])
    local EndMinIndex = 2
    local EndMinute = tonumber(EndHourAndMinute[EndMinIndex])
    local EndAozyTime = EndHour * OneHourSec + EndMinute * OneMinSec
    return StartAozyTime, EndAozyTime
end

---@type 是否自动展开
function GatheringPlaceItemVM:AdapterOnGetIsAutoExpand()
    return false
end

---@type 设置返回的索引：0
function GatheringPlaceItemVM:AdapterOnGetWidgetIndex()
    return 1
end

function GatheringPlaceItemVM:AdapterOnGetCanBeSelected()
    return true
end

---@type 返回子节点列表
function GatheringPlaceItemVM:AdapterOnGetChildren()
    return {}
end

function GatheringPlaceItemVM:AdapterGetCategory()
    return self.MapID
end

return GatheringPlaceItemVM
