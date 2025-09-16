local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")


---@class OpsVersionNoticeTaskItemVM : UIViewModel
local OpsVersionNoticeTaskItemVM = LuaClass(UIViewModel)

---Ctor
function OpsVersionNoticeTaskItemVM:Ctor()
    self.TextTask = nil
    self.TextQuantity = nil
    self.TextBtn = nil
    self.TaskFinished = nil
    self.JumpType = nil
    self.JumpParam = nil

    self.TextTask1 = nil
    self.TextTask2 = nil
    self.TextQuantity1 = nil
    self.TextQuantity2 = nil
    self.TextTag = nil
    self.TextBtn1 = nil
    self.TextBtn2 = nil
    self.Task1Finished = nil
    self.Task2Finished = nil
    self.JumpType1 = nil
    self.JumpParam1 = nil
    self.JumpType2 = nil
    self.JumpParam2 = nil
    self.NodeID1 = nil
    self.NodeID2 = nil

    self.PanelBtnVisiable = nil
    self.TextLockTime = nil
    self.Index = nil
    self.ActivityID = nil
    self.NodeID = nil
end

function OpsVersionNoticeTaskItemVM:UpdateVM(Params)
    self.Index = Params.Index
    self.ActivityID = Params.ActivityID
    self.NodeID = Params.NodeID
    if Params.Index == 0 then
        self.TextTask = Params.TextTask
        self.TextQuantity = Params.TextQuantity
        self.TextBtn = Params.TextBtn
        self.TaskFinished = Params.TaskFinished
        self.JumpType = Params.JumpType
        self.JumpParam = Params.JumpParam
        self.TextLockTime = Params.TextLockTime
        self.PanelBtnVisiable = Params.PanelBtnVisiable
        if Params.ShareNodeCfg then
           self.ShareNodeCfg = Params.ShareNodeCfg
        else
           self.ShareNodeCfg = nil
        end
    elseif Params.Index == 1 then
        self.TextTask1 = Params.TextTask1
        self.TextTask2 = Params.TextTask2
        self.TextQuantity1 = Params.TextQuantity1
        self.TextQuantity2 = Params.TextQuantity2
        self.TextTag = Params.TextTag
        self.TextBtn1 = Params.TextBtn1
        self.TextBtn2 = Params.TextBtn2
        self.Task1Finished = Params.Task1Finished
        self.Task2Finished = Params.Task2Finished
        self.JumpType1 = Params.JumpType1
        self.JumpParam1 = Params.JumpParam1
        self.JumpType2 = Params.JumpType2
        self.JumpParam2 = Params.JumpParam2
        self.NodeID1 = Params.NodeID1
        self.NodeID2 = Params.NodeID2
        self.PanelBtnVisiable1 = Params.PanelBtnVisiable1
        self.PanelBtnVisiable2 = Params.PanelBtnVisiable2
        self.TextLockTime1 = Params.TextLockTime1
        self.TextLockTime2 = Params.TextLockTime2
    end
end

function OpsVersionNoticeTaskItemVM:AdapterOnGetWidgetIndex()
    return self.Index
end

function OpsVersionNoticeTaskItemVM:IsEqualVM(Value)
    return false
end

return OpsVersionNoticeTaskItemVM