---
---@author Lucas
---DateTime: 2023-04-24 10:45:00
---Description:钓鱼闹钟列表条目VM

local LuaClass = require("Core/LuaClass")
local TimeUtil = require("Utils/TimeUtil")
local UIViewModel = require("UI/UIViewModel")
local FishNotesMgr = require("Game/FishNotes/FishNotesMgr")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local LocalizationUtil = require("Utils/LocalizationUtil")

---@class FishNotesClockVM: UIViewModel
---@field ClockFishIcon string @鱼的图标
---@field ClockFishName string @鱼的名字
---@field ClockTime string @倒计时
---@field ClockInWindowTimeColor string @鱼的名字和时间的窗口期的颜色
---@field ClockIsSelected boolean @闹钟是否选中
---
---@field WindowTime table @窗口时间
---@field IsResetWindowTime @是否重置窗口期
---@field Index number @索引
local FishNotesClockVM = LuaClass(UIViewModel)

function FishNotesClockVM:Ctor()
    self.bUnknowVisible = false
    self.bIconVisible = false
    self.ClockFishIcon = ""
    self.TextPlace = ""
    self.ClockFishName = ""
    self.ClockTime = ""
    self.ClockIsSelected = 0
    self.WindowTime = nil
    self.ProgressValue = nil
    self.IsResetWindowTime = false
    self.ClockInWindowTimeColor = FishNotesDefine.Color.ClockTextNow
    self.bActive = false
end

function FishNotesClockVM:IsEqualVM(Value)
    return self.FishDetailsName == Value.Name and self.LocationID == Value.LocationID
end

function FishNotesClockVM:UpdateVM(Value)
    self.Index = Value.Index
    self.FishID = Value.FishID
    self.ItemData = Value.ItemData
    self.LocationID = Value.LocationID
    self.Tab = Value.Tab
    ----------------------------------------
    self.TextPlace = not FishNotesMgr:CheckFishLocationbLock(Value.LocationID) and FishNotesMgr:GetLocationNameByID(Value.LocationID) or " "
    self.FishDetailsName = Value.Name
    self.ClockFishName = Value.Name
    self.SlotData = {ID = Value.FishID, LocationID = Value.LocationID, IsLocationFish = false}
    if FishNotesMgr:CheckFishUnlockInFround(Value.FishID, Value.LocationID) then
        self.bUnknowVisible = false
        self.bIconVisible = true
    else
        self.bUnknowVisible = true
        self.bIconVisible = false
        if Value.CanPrint and Value.CanPrint ~= 0 then
            self.UnknowIcon = FishNotesDefine.FishSlotCanPink
        else
            self.UnknowIcon = FishNotesDefine.FishSlotNotCanPink
        end
    end
    self.ClockIsSelected = Value.IsSelected
    ----------------------------------------
    self.WindowTime = Value.WindowTime
    if not table.is_nil_empty( Value.WindowTime) then
        self:UpdateTime(TimeUtil.GetServerTime())
    end
end

function FishNotesClockVM:UpdateTime(Now)
    local WindowTime = self.WindowTime
    if WindowTime.Begin ~= nil and WindowTime.End ~= nil then
        if Now >= WindowTime.End then
            if self.Tab ~= nil then
                _G.FishIngholeVM:SelectedClockTabItem(2)
            else
                self.WindowTime = FishNotesMgr:CheckClockData(self.FishID, self.LocationID, Now) or self.WindowTime
            end
        end
        self.bActive = Now >= WindowTime.Begin and Now < WindowTime.End
        if self.bActive then
            local TotalWindowTime = WindowTime.End - WindowTime.Begin
            local LeftTime = WindowTime.End - Now
            self.TotalWindowTime = TotalWindowTime
            self.LeftTime = LeftTime
            if self.Tab ~= nil then
                self.ClockTime = LocalizationUtil.GetCountdownTimeForShortTime(LeftTime, "hh:mm:ss")
            else
                self.ClockTime = _G.LSTR(180066)--"活跃中"
            end
            self.ProgressValue = LeftTime / TotalWindowTime
            self.ClockInWindowTimeColor = FishNotesDefine.Color.ClockTextNow
        else
            local RemainSeconds = WindowTime.Begin - Now
            self.ClockTime = _G.FishIngholeVM:Seconds2DisplayTime(RemainSeconds, FishNotesDefine.TimeLimitText)
            self.ClockInWindowTimeColor = FishNotesDefine.Color.ClockTextNormal
            self.ProgressValue = nil
        end
    else
        self.ClockTime = _G.LSTR(180068) --暂不出现
        self.ClockInWindowTimeColor = FishNotesDefine.Color.ClockTextNormal
        self.ProgressValue = nil
    end
end

function FishNotesClockVM:SetClockSelected(IsSelected)
    self.ClockIsSelected = IsSelected
end

function FishNotesClockVM:GetFishID()
    return self.FishID
end

function FishNotesClockVM:GetFishLocationID()
    return self.LocationID
end

return FishNotesClockVM