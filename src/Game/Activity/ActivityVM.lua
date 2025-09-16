---@author: fishhong 2023-02-02 15:53:09
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class ActivityVM : UIViewModel
---@--- Main Part
---@field ActivityNoticeVisible boolean @活动界面的开服通知界面是否可见
local ActivityVM = LuaClass(UIViewModel)

---Ctor
function ActivityVM:Ctor()
    self.ActivityNoticeVisible = true
end

--- func desc
function ActivityVM:OnInit()
end

--- func desc
function ActivityVM:OnBegin()
end

function ActivityVM:OnEnd()

end

function ActivityVM:OnShutdown()

end

return ActivityVM
