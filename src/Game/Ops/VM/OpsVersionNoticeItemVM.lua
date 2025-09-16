local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")

---@class OpsVersionNoticeItemVM : UIViewModel
local OpsVersionNoticeItemVM = LuaClass(UIViewModel)

---Ctor
function OpsVersionNoticeItemVM:Ctor()
    self.NodeID = nil
    self.TextTaskTitle = nil
    self.TextTaskDescribe = nil
    self.JumpButton = nil
    self.JumpType = nil
    self.JumpParam = nil
    self.ImgPoster = nil
end

function OpsVersionNoticeItemVM:UpdateVM(Params)
    self.NodeID = Params.NodeID
    self.TextTaskTitle = Params.TextTaskTitle
    self.TextTaskDescribe = Params.TextTaskDescribe
    self.JumpButton = Params.JumpButton
    self.JumpType = Params.JumpType
    self.JumpParam = Params.JumpParam
    self.ImgPoster = Params.ImgPoster
end


function OpsVersionNoticeItemVM:IsEqualVM(Value)
    return false
end

return OpsVersionNoticeItemVM