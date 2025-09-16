local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")

local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender

local LSTR

---@class ShopTabListItemNewVM : UIViewModel
local ShopTabListItemNewVM = LuaClass(UIViewModel)

---Ctor
function ShopTabListItemNewVM:Ctor()
	self.Key = nil
	self.Name = ""
end

function ShopTabListItemNewVM:OnInit()

end

---UpdateVM
---@param List table
function ShopTabListItemNewVM:UpdateVM(List)
	
end

function ShopTabListItemNewVM:OnBegin()

end

function ShopTabListItemNewVM:OnEnd()

end


return ShopTabListItemNewVM