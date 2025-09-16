--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:启程活动列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local DepartOfLightVMUtils = require("Game/Departure/DepartOfLightVMUtils")

---@class DepartActivityItemVM : UIViewModel
local DepartActivityItemVM = LuaClass(UIViewModel)

function DepartActivityItemVM:Ctor()
    self.ActivityName = ""
    self.IsLock = false -- 是否锁住
    self.ActivityID = 0 -- 活动ID/玩法节点
    self.IsGetAllReward = false -- 是否已领取所有奖励
    self.NormalIcon = ""
    self.SelectedIcon = ""
    self.GameID = 0 -- 玩法ID，本模块定义
end


function DepartActivityItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.ActivityName == self.ActivityName
end

function DepartActivityItemVM:UpdateVM(Value)
    self.ActivityID = Value.ActivityID
    self.IsGetAllReward = Value.IsGetAllReward
    if self.ActivityID then
        local ActivityInfo = DepartOfLightVMUtils.GetActivityInfo(self.ActivityID)
        self.ActivityName = ActivityInfo and ActivityInfo.Title
        local ActivityDesc = DepartOfLightVMUtils.GetActivityDescInfoByActivityID(self.ActivityID)
        self.GameID = ActivityDesc and ActivityDesc.GameID or 0
        if self.GameID > 0 then
            local TableIconPath = DepartOfLightDefine.TableIconPath and DepartOfLightDefine.TableIconPath[self.GameID]
            if TableIconPath then
                self.NormalIcon = TableIconPath.Default
                self.SelectedIcon = TableIconPath.Selected
            end
        end
    end
    -- Value.EmergencyShutDown：紧急关闭 
    -- Value.Effected：是否已生效/生效条件 
    -- Value.Hiden：是否隐藏/仅隐藏活动逻辑事件正常触发
    self.IsLock = Value.EmergencyShutDown or not Value.Effected or Value.Hiden
end

return DepartActivityItemVM