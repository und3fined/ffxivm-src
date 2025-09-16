local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")


---@class UpgradeTaskItemVM : UIViewModel
local UpgradeTaskItemVM = LuaClass(UIViewModel)

---Ctor
function UpgradeTaskItemVM:Ctor()
    self.TaskText = nil
    self.TaskTitle = nil
    self.ImageColor = nil
    self.IconTask = nil
    self.IsTaskCompleted = false
end

function UpgradeTaskItemVM:UpdateVM(Params)
    self.TaskText = Params.TaskText
    self.TaskTitle = Params.TaskTitle
    self.Index = Params.Index
    self.IsTaskCompleted = Params.IsTaskCompleted
    self.ImageColor = Params.ImageColor
    self.IconTask = Params.IconTask
end

function UpgradeTaskItemVM:IsEqualVM(Value)
    return false
end

function UpgradeTaskItemVM:AdapterOnGetWidgetIndex()
    return self.Index
end

return UpgradeTaskItemVM