local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")

---@class BagTidyListItemVM : UIViewModel
local BagTidyListItemVM = LuaClass(UIViewModel)

---Ctor
function BagTidyListItemVM:Ctor()
    self.TextTitle = nil
    self.TextGoto = nil
    self.GotoVisiable = false
    self.Choose1TextVisiable = false
    self.Choose2TextVisiable = false
    self.SingleBox1Enabled = false
    self.SingleBox2Enabled = false
    self.IsToggle1Enabled = false
    self.IsToggle2Enabled = false
end

function BagTidyListItemVM:UpdateVM(Params)
    self.TextTitle = Params.TextTitle
    self.TextGoto = Params.TextGoto
    self.GotoVisiable = Params.GotoVisiable
    self.Choose1TextVisiable = Params.Choose1TextVisiable
    self.Choose2TextVisiable = Params.Choose2TextVisiable
    self.Choose1Text = Params.Choose1Text
    self.Choose2Text = Params.Choose2Text
    self.Index = Params.Index
    self.HelpInfoID = Params.HelpInfoID
    self.IsToggle1Enabled = Params.IsToggle1Enabled
    self.IsToggle2Enabled = Params.IsToggle2Enabled
    self.Value1 = Params.Value1
    self.Value2 = Params.Value2
    self.SingleBox1Enabled = Params.SingleBox1Enabled
    self.SingleBox2Enabled = Params.SingleBox2Enabled
end

function BagTidyListItemVM:IsEqualVM(Value)
    return true
end

return BagTidyListItemVM