--
-- Author: ds_yangyumian
-- Date: 2022-09-19 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local ShopInletListItemNewVM = require("Game/Shop/ItemVM/ShopInletListItemNewVM")


---@class ShopInletPanelNewVM : UIViewModel
local ShopInletPanelNewVM = LuaClass(UIViewModel)

---Ctor
function ShopInletPanelNewVM:Ctor()
	self.CurShopList = UIBindableList.New(ShopInletListItemNewVM)
end

function ShopInletPanelNewVM:OnInit()

end

---UpdateVM
---@param List table
function ShopInletPanelNewVM:UpdateVM()

end

function ShopInletPanelNewVM:UpdateShopListInfo(ShopList)
	if ShopList == nil then
		return
	end

	self.CurShopList:UpdateByValues(ShopList)
end

function ShopInletPanelNewVM:OnBegin()

end

function ShopInletPanelNewVM:OnEnd()

end


return ShopInletPanelNewVM