--@author star
--@date 2024--05--07

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

---@Class ArmySpecialEffectsItemVM : UIViewModel

local ArmySpecialEffectsItemVM = LuaClass(UIViewModel)

function ArmySpecialEffectsItemVM:Ctor()
    self.ID = nil
    self.IsEmpty = nil
    self.Icon = nil
    self.Name = nil
    self.Desc = nil
    self.EndTime = nil
    self.TimeStr = nil
    self.Time = nil
end

function ArmySpecialEffectsItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

function ArmySpecialEffectsItemVM:UpdateVM(Value)
    self.IsEmpty = Value.IsEmpty
    self.Index = self.Index
    if self.IsEmpty then
        return
    end
    self.ID = Value.ID
    self.Icon = Value.Icon
    self.Name = Value.Name
    self.Desc = Value.Desc
    self.EndTime = Value.EndTime
    self.SimpleDesc = Value.SimpleDesc
    if self.EndTime then
        local CurTime = TimeUtil.GetServerTime()
        self.Time = self.EndTime - CurTime
            ---小于一分钟倒计时
        if self.Time then
            --self.TimeStr = self:FormatEndTime(self.Time)
            self.TimeStr = LocalizationUtil.GetCountdownTimeForSimpleTime(self.Time, "s")
        end
    end
end

-- function ArmySpecialEffectsItemVM:AdapterOnGetCanBeSelected()
--     return true
-- end

function ArmySpecialEffectsItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

function ArmySpecialEffectsItemVM:FormatEndTime(Seconds)
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

function ArmySpecialEffectsItemVM:SetTimeStr(TimeStr)
    self.TimeStr = TimeStr
end

return ArmySpecialEffectsItemVM