---
--- Author: sammrli
--- DateTime: 2023-11-7 10:32
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CommScreenerTagItemVMParam
---@field TagText string

---@class CommScreenerTagItemVM : UIViewModel
local CommScreenerTagItemVM = LuaClass(UIViewModel)

---Ctor
function CommScreenerTagItemVM:Ctor()
   self.TagText = nil
end

function CommScreenerTagItemVM:IsEqualVM(Value)
	return false
end

---@param Param CommScreenerTagItemVMParam
function CommScreenerTagItemVM:UpdateVM(Param)
	self.TagText = Param.TagText
end

return CommScreenerTagItemVM