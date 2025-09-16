local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class CommBottomTabItemVM : UIViewModel
local CommBottomTabItemVM = LuaClass(UIViewModel)

---Ctor
function CommBottomTabItemVM:Ctor()
	self.TabName = ""
end

function CommBottomTabItemVM:OnInit()

end

---UpdateVM
---@param List table
function CommBottomTabItemVM:UpdateVM(List)
	self.TabName = List.Name
end

function CommBottomTabItemVM:OnBegin()

end

function CommBottomTabItemVM:OnEnd()

end


return CommBottomTabItemVM