--
-- Author: ds_yangyumian
-- Date: 2022-09-19 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local ShopGoodsListItemVM = require("Game/Shop/ItemVM/ShopGoodsListItemVM")


---@class ShopMainPanelVM : UIViewModel
local ShopMainPanelVM = LuaClass(UIViewModel)

---Ctor
function ShopMainPanelVM:Ctor()
	self.CurGoodsList = UIBindableList.New(ShopGoodsListItemVM)
end

function ShopMainPanelVM:OnInit()

end

---UpdateVM
---@param List table
function ShopMainPanelVM:UpdateVM(List)

end

function ShopMainPanelVM:UpdateGoodsListInfo(GoodsList)
	--FLOG_ERROR("TEST GoodsList? = %s",table_to_string(GoodsList))  
	if GoodsList == nil then
		return
	end

	self.CurGoodsList:UpdateByValues(GoodsList, nil, true)
end

function ShopMainPanelVM:OnBegin()

end

function ShopMainPanelVM:OnEnd()

end

function ShopMainPanelVM:GetJumpGoodsInfo(GoodsId)
	local Info = {}
	local Items = self.CurGoodsList:GetItems()
	if Items then
		for i = 1, #Items do
			if GoodsId == Items[i].GoodsId then
				Info = Items[i]
				return Info
			end
		end
	end

	return Info
end

return ShopMainPanelVM