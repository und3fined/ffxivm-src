local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ShopTabItemVM = require("Game/Shop/ItemVM/ShopTabItemVM")
local UIBindableList = require("UI/UIBindableList")

local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender

local LSTR

---@class ShopTabListItemVM : UIViewModel
local ShopTabListItemVM = LuaClass(UIViewModel)

---Ctor
function ShopTabListItemVM:Ctor()
	self.Key = nil
	self.Name = ""
	self.CurTabList = UIBindableList.New(ShopTabItemVM)
end

function ShopTabListItemVM:OnInit()

end

---UpdateVM
---@param List table
function ShopTabListItemVM:UpdateVM(List)
	
end

function ShopTabListItemVM:UpdateTabList(List)
	if List == nil then
		return
	end

	self.CurTabList:UpdateByValues(List)
end

function ShopTabListItemVM:OnBegin()

end

function ShopTabListItemVM:OnEnd()

end


return ShopTabListItemVM