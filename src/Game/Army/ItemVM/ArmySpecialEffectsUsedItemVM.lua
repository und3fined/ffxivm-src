--@author star
--@date 2024--06--04

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

---@Class ArmySpecialEffectsUsedItemVM : UIViewModel

local ArmySpecialEffectsUsedItemVM = LuaClass(UIViewModel)

function ArmySpecialEffectsUsedItemVM:Ctor()
    self.ID = nil
    self.IsEmpty = nil
    self.IsSelected = nil
    self.Name = nil
    self.Desc = nil
    self.EffectIcon = nil
    self.EndTime = nil
    self.TimeStr = nil
    self.Time = nil
    self.Index = nil
end

function ArmySpecialEffectsUsedItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmySpecialEffectsUsedItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.IsEmpty = Value.IsEmpty
    self.Index = Value.Index
    if  self.IsEmpty then
        return
    end
    self.EndTime = Value.EndTime
    self.IsSelected = Value.IsSelected
    self.Name = Value.Name
    self.Desc = Value.Desc
    self.Icon = Value.Icon
    self.GroupID = Value.GroupID
    self.Time = Value.Time
    ---小于一分钟倒计时
    if self.Time then
        self.TimeStr = LocalizationUtil.GetCountdownTimeForSimpleTime(self.Time, "s")
    end
end

function ArmySpecialEffectsUsedItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

function ArmySpecialEffectsUsedItemVM:FormatEndTime(Seconds)
    if Seconds < 3600 then
        -- LSTR string:分钟
        local MinStr = LSTR(910069)
        local Minutes = math.floor(Seconds / 60)
        return string.format("%d %s", Minutes, MinStr)
    elseif Seconds < 86400 then
        -- LSTR string:小时
        local HourStr = LSTR(910100)
        local Hours = math.floor(Seconds / 3600)
        return string.format("%d %s", Hours, HourStr)
    else
        -- LSTR string:天
        local DayStr = LSTR(910093)
        local Days
        if Seconds < 2592000 then  -- 30 天
            Days = math.floor(Seconds / 86400)
        else
            Days = 30
        end
        return string.format("%d %s", Days, DayStr)
    end
end

function ArmySpecialEffectsUsedItemVM:SetTimeStr(TimeStr)
    self.TimeStr = TimeStr
end

return ArmySpecialEffectsUsedItemVM