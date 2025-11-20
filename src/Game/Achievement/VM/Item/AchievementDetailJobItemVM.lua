---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local JobItemVM = LuaClass(UIViewModel)

function JobItemVM:Ctor()
	self.ProfID = nil
end

function JobItemVM:IsEqualVM(Value)
	return true
end

function JobItemVM:OnInit()

end

function JobItemVM:OnBegin()

end

function JobItemVM:OnEnd()

end

function JobItemVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function JobItemVM:UpdateVM(Value, Params)
	self.ProfID = Value
end

return JobItemVM