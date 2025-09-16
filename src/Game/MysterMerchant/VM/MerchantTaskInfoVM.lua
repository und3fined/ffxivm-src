--
-- Author: Carl
-- Date: 2024-05-10 16:57:14
-- Description:右上方的任务信息栏VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MysterMerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")
local MysterMerchantUtils = require("Game/MysterMerchant/MysterMerchantUtils")
local TimeUtil = _G.TimeUtil
local EToggleStage = _G.UE.EToggleButtonState
-- _G.UE.EToggleButtonState.Checked/Unchecked

---@class MerchantTaskInfoVM : UIViewModel


---@field CountDownVisible boolean @时间显示
---@field TaskProgressText string @任务进度
---@field TaskName string @任务名字
---

local MerchantTaskInfoVM = LuaClass(UIViewModel)

function MerchantTaskInfoVM:Ctor()
    self.TaskName = MysterMerchantDefine.Title
    self.EndTime = 0
    self.CountDownVisible = false
    self.TaskProgressText = ""
    self.TaskInfoMap = {}
    self.TaskStatus = 0
    self.TaskType = 0
end

function MerchantTaskInfoVM:OnEnterMerchantRange()

end

function MerchantTaskInfoVM:OnExitMerchantRange()

end

function MerchantTaskInfoVM:UpdateTaskInfo(TaskInfo)
    if TaskInfo == nil then
        return
    end

    local TaskType = TaskInfo.TaskType or 0
    local Progress = TaskInfo.Progress or 0
    local FinishNum = TaskInfo.FinishNum or 0
    self.TaskType = TaskType
    self.EndTime = TaskInfo.EndTime
    self.CountDownVisible = self.EndTime and self.EndTime > 0
    self.TaskStatus = TaskInfo.Status or MysterMerchantDefine.MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED
    if self.TaskStatus == MysterMerchantDefine.MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED then
        self.TaskProgressText = string.format(MysterMerchantDefine.TaskProgressText[TaskType][self.TaskStatus], Progress, FinishNum)
    else
        self.TaskProgressText = MysterMerchantDefine.TaskProgressText[TaskType][self.TaskStatus]
    end
end

function MerchantTaskInfoVM:GetTaskStatus()
    return self.TaskStatus
end

return MerchantTaskInfoVM