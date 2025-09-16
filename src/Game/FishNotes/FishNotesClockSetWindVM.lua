---
---@author carl
---DateTime: 2023-08-15 20:55:00
---Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class FishNotesClockSetWindVM: UIViewModel
---@field Trigger EToggleButtonState 主题界面提醒
---@field CloseNotify EToggleButtonState 封闭条件下提醒
---@field StartNotify EToggleButtonState 窗口期提醒
---@field IsComingNotify EToggleButtonState 提前提醒
---@field IsNotifySound EToggleButtonState 声音提醒
local FishNotesClockSetWindVM = LuaClass(UIViewModel)

function FishNotesClockSetWindVM:Ctor()
    self.Trigger = true
    self.CloseNotify = true
    self.StartNotify = true
    self.IsComingNotify = true
    self.IsNotifySound = true
    self.ComingNotify = 1
end

function FishNotesClockSetWindVM:IsEqualVM(Value)
    return Value ~= nil
end

function FishNotesClockSetWindVM:UpdateVM(Setting)
    if Setting == nil then
        self:Ctor()
        return
    end
    self.Trigger = Setting.Trigger
    self.CloseNotify = Setting.CloseNotify
    self.StartNotify = Setting.StartNotify
    self.IsComingNotify = Setting.IsComingNotify
    self.IsNotifySound = Setting.Sound
    self.ComingNotify = Setting.ComingNotify
end

function FishNotesClockSetWindVM:ChangeClockTrigger()
    self.Trigger = not self.Trigger
end

function FishNotesClockSetWindVM:ChangeCloseNotify()
    self.CloseNotify = not self.CloseNotify
end

function FishNotesClockSetWindVM:ChangeStartNotify()
    self.StartNotify = not self.StartNotify
end

function FishNotesClockSetWindVM:ChangeIsComingNotify()
    self.IsComingNotify = not self.IsComingNotify
end

function FishNotesClockSetWindVM:ChangeIsNotifySound()
    self.IsNotifySound = not self.IsNotifySound
end

---@type 提前通知时间
function FishNotesClockSetWindVM:ChangeComingNotifyValue(ComingNotify)
    self.ComingNotify = ComingNotify
end

function FishNotesClockSetWindVM:GetLastClockSetting()
    local Setting = {
        Trigger = self.Trigger,
        CloseNotify = self.CloseNotify,
        StartNotify = self.StartNotify,
        IsComingNotify = self.IsComingNotify,
        Sound = self.IsNotifySound,
        ComingNotify = self.ComingNotify,
    }
    return Setting
end

return FishNotesClockSetWindVM