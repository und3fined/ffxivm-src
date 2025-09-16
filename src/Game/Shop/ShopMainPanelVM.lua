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
	self.EmptyVisible = false
	self.GoodsListVisible = true
	self.PreGoodsList = nil
	self.EmptyView = nil
end

function ShopMainPanelVM:OnInit()

end

---UpdateVM
---@param List table
function ShopMainPanelVM:UpdateVM(List)

end

function ShopMainPanelVM:UpdateGoodsListInfo(GoodsList, IsSearch)
	self.EmptyVisible = false
	--FLOG_ERROR("TEST GoodsList? = %s",table_to_string(GoodsList))  
	if GoodsList == nil then
		return
	end

	if not IsSearch then
		self.PreGoodsList = GoodsList
	end
	self.CurGoodsList:UpdateByValues(GoodsList, nil, true)
end

function ShopMainPanelVM:OnBegin()

end

function ShopMainPanelVM:OnEnd()
	self.EmptyView = nil
end

function ShopMainPanelVM:MatchGoodsInfo(Input)
	local matches = {}
	if Input ~= nil then
		_G.JudgeSearchMgr:QueryTextIsLegal(Input, function( IsLegal )
			if not IsLegal then
				return
			end
		end)
		
		for _, GoodsInfo in pairs(_G.ShopMgr.CurOpenShopGoodSList) do
			for _, j in pairs(GoodsInfo) do
				if j.ItemInfo then
					if j.ItemInfo.ItemName:find(Input) then
						table.insert(matches, j)
					end
				end
			end
		end
	end

	if #matches > 0 then
		table.sort(matches, _G.ShopMgr.SortShopGoodsPredicate)
		self.CurGoodsList:UpdateByValues(matches, nil, true)
		self:SetSearchState(true)
	else
		self:SetSearchState(false)
		self.EmptyView:SetSearchEmpty(_G.LSTR(1010050))
	end	
end

function ShopMainPanelVM:SetSearchState(Value)
	self.GoodsListVisible = Value
	self.EmptyVisible = not Value
end

function ShopMainPanelVM:RecoverGoodsList()
	self.CurGoodsList:UpdateByValues(self.PreGoodsList, nil, true)
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