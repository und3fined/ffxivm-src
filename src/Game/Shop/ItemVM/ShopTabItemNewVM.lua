local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ShopMgr = require("Game/Shop/ShopMgr")
---@class ShopTabItemNewVM : UIViewModel
local ShopTabItemNewVM = LuaClass(UIViewModel)

---Ctor
function ShopTabItemNewVM:Ctor()
	self.TabName = ""
	self.IsSelected = false
end

function ShopTabItemNewVM:OnInit()

end

---UpdateVM
---@param List table
function ShopTabItemNewVM:UpdateVM(List)
	self.TabName = List.Name
end

function ShopTabItemNewVM:OnBegin()

end

function ShopTabItemNewVM:OnEnd()

end


return ShopTabItemNewVM