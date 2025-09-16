local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")


---@class ArmyBatchGroupItemVM : UIViewModel
local ArmyBatchGroupItemVM = LuaClass(UIViewModel)
---Ctor
function ArmyBatchGroupItemVM:Ctor()
    self.RoleName = ""
    self.JobLevel = nil
    self.State = nil
    self.OnlineStatusIcon = nil
    self.JobIcon = nil
    self.bChecked = false
    self.bOnline = nil
    self.RoleID = 0
    self.CategoryID = nil
end

function ArmyBatchGroupItemVM:UpdateVM(Value)
    if nil == Value then
        return
    end
    self.IsEmpty = Value.IsEmpty
    local RoleSimData = Value.Simple
    if RoleSimData == nil then
        return
    end
    self.RoleID = RoleSimData.RoleID
    if self.IsEmpty then
        self.RoleName = "" ---用于比较时，空item排最后
        self.bOnline = false ---用于比较时，空item排最后
        return
    end
    self.bChecked = Value.bChecked
    self.RoleName = Value.RoleName
    local IsOnline = Value.IsOnline
    self.bOnline = IsOnline
    self.OnlineStatusIcon = Value.OnlineStatusIcon
    self.JobLevel = Value.Level
    self.JobIcon = Value.ProfIcon
    self.OnClickedSwitchCategory = Value.OnClickedSwitchCategory
    self.Owner = Value.Owner
    if IsOnline then
        local MapResName = Value.MapResName
        if string.isnilorempty(MapResName) then
            -- LSTR string:未知
            self.State = _G.LSTR(910162)
        else
            self.State = MapResName
        end
    else
        local LogoutTime = Value.LogoutTime
        if Value.LogoutTime then
            local CurTime = TimeUtil.GetServerTime()
            local OfflineTime =  CurTime - LogoutTime
            self.State = LocalizationUtil.GetTimerForLowPrecision(OfflineTime)
        end
    end
end

function ArmyBatchGroupItemVM:FormatOfflineTime(Seconds)
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

function ArmyBatchGroupItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Type == self.Type
end


--要返回当前类
return ArmyBatchGroupItemVM