local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class ReportItemVM : UIViewModel
local ReportItemVM = LuaClass(UIViewModel)

---Ctor
function ReportItemVM:Ctor()
	self.ReasonsID = 0
	self.Selected = false
end

function ReportItemVM:OnInit()

end

function ReportItemVM:OnBegin()

end

function ReportItemVM:IsEqualVM(Value)
	return true
end

function ReportItemVM:OnEnd()

end

function ReportItemVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function ReportItemVM:UpdateVM(Value, Params)
	self.ReasonsID = Value
	self.Selected = false
end

return ReportItemVM