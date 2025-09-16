local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

---@class OpsNewbieStrategyTabItemVM : UIViewModel
local OpsNewbieStrategyTabItemVM = LuaClass(UIViewModel)

---Ctor
function OpsNewbieStrategyTabItemVM:Ctor()
    self.Name = nil
    self.bSelected = nil
    self.RedDotName = nil
    self.RedDotStyle = nil
    self.IsUnLock = nil
end

function OpsNewbieStrategyTabItemVM:UpdateVM(Params)
    self.Index = Params.Index
	self.Name = Params.Name
	self.bSelected = Params.bSelected
    self.Key = Params.Key
    self.RedDotName = Params.RedDotName
    self.RedDotStyle = Params.RedDotStyle
    self.IsUnLock = Params.IsUnLock
end

function OpsNewbieStrategyTabItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Key == self.Key
end

function OpsNewbieStrategyTabItemVM:AdapterOnGetWidgetIndex()
    return self.Index
end

function OpsNewbieStrategyTabItemVM:SetSelected(InSelected)
    self.bSelected = InSelected
end

function OpsNewbieStrategyTabItemVM:GetRedDotName()
    return self.RedDotName
end

function OpsNewbieStrategyTabItemVM:SetIsUnLock(IsUnLock)
     self.IsUnLock = IsUnLock
end

function OpsNewbieStrategyTabItemVM:GetKey()
    return self.Key or 0
end

function OpsNewbieStrategyTabItemVM:SetRedDotStyle(RedDotStyle)
    self.RedDotStyle = RedDotStyle
end

return OpsNewbieStrategyTabItemVM