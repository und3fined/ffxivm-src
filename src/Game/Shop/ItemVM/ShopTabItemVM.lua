local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ShopMgr = require("Game/Shop/ShopMgr")
---@class ShopTabItemVM : UIViewModel
local ShopTabItemVM = LuaClass(UIViewModel)

---Ctor
function ShopTabItemVM:Ctor()
	self.TabName = ""
	self.FirstType = nil
	self.IsSelected = false
	self.CounterImgPath = nil
	self.CounterID = nil
end

function ShopTabItemVM:OnInit()

end

---UpdateVM
---@param List table
function ShopTabItemVM:UpdateVM(List)
	self.TabName = List.Name
	self.FirstType = List.FirstType
	self.CounterImgPath = List.FilterInfo.CounterImgPath
	self.CounterID = List.FilterInfo.CounterID
end

function ShopTabItemVM:OnBegin()

end

function ShopTabItemVM:OnEnd()

end


return ShopTabItemVM