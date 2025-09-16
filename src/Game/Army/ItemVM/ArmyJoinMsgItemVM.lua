--@author daniel
--@date 2023-03-14

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")

---@class ArmyJoinMsgItemVM : UIViewModel
---@field Message string @留言
local ArmyJoinMsgItemVM = LuaClass(UIViewModel)

function ArmyJoinMsgItemVM:Ctor()
    self.RoleID = nil
    self.Message = nil
    self.Name = nil
    self.State = nil
    self.HeadIcon = nil
    self.OnlineStatusIcon = nil
    self.ApplyTime = nil
    self.bOnline = nil
    self.IsShowBtnReport = nil
end

function ArmyJoinMsgItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.RoleID == self.RoleID
end

function ArmyJoinMsgItemVM:UpdateVM(Data)
    self.Message = Data.Message
    self.ApplyTime = Data.ApplyTime
    self.RoleID = Data.RoleID
    self.Name = Data.Name
    self.OnlineStatusIcon = Data.OnlineStatusIcon
    local bOnline = Data.IsOnline
    self.bOnline = bOnline
    self.HeadIcon = Data.HeadIcon
    self.JobLevel = Data.Level
    self.JobIcon = Data.ProfIcon
    self.StateType = Data.StateType
    self.IsShowBtnReport = not string.isnilorempty(self.Message)
    if bOnline then
        local MapResName = Data.MapResName
        if string.isnilorempty(MapResName) then
            -- LSTR string:未知
            self.State = _G.LSTR(910162)
        else
            self.State = MapResName
        end
    else
        local LogoutTime = Data.LogoutTime
        if Data.LogoutTime then
            local CurTime = TimeUtil.GetServerTime()
            local OfflineTime = CurTime - LogoutTime
            self.State = self:FormatOfflineTime(OfflineTime)
        end
    end
end



function ArmyJoinMsgItemVM:AdapterOnGetCanBeSelected()
    return false
end

function ArmyJoinMsgItemVM:AdapterOnGetWidgetIndex()
    return self.ID
end

function ArmyJoinMsgItemVM:FormatOfflineTime(Seconds)
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

return ArmyJoinMsgItemVM