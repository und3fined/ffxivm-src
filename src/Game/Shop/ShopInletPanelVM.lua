--
-- Author: ds_yangyumian
-- Date: 2022-09-19 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local ShopInletListItemVM = require("Game/Shop/ItemVM/ShopInletListItemVM")
local ShopGoodsListItemVM = require("Game/Shop/ItemVM/ShopGoodsListItemVM")

---@class ShopInletPanelVM : UIViewModel
local ShopInletPanelVM = LuaClass(UIViewModel)

---Ctor
function ShopInletPanelVM:Ctor()
	self.CurShopList = UIBindableList.New(ShopInletListItemVM)
	self.CurSearchList = UIBindableList.New(ShopGoodsListItemVM)
	self.TableView2Visible = false
	self.TableView3Visible = false
	self.TableView4Visible = false
	self.TableView6Visible = false
	self.TableSearchVisible = false
	self.EmptyVisible = false
	self.PanelContentVisible = true
end

function ShopInletPanelVM:OnInit()
	
end

---UpdateVM
---@param List table
function ShopInletPanelVM:UpdateVM()

end

function ShopInletPanelVM:UpdateShopListInfo(ShopList)
	if ShopList == nil then
		return
	end
	
	self.CurShopList:UpdateByValues(ShopList)
	local IsLongDataList = #ShopList >= 5
	self.TableView2Visible = #ShopList == 2
	self.TableView3Visible = #ShopList == 3
	self.TableView4Visible = not IsLongDataList and not self.TableView2Visible and not self.TableView3Visible
	self.TableView6Visible = IsLongDataList
	
end

function ShopInletPanelVM:MatchGoodsInfo(Input)
	local matches = {}
	if Input ~= nil then
		_G.JudgeSearchMgr:QueryTextIsLegal(Input, function( IsLegal )
			if not IsLegal then
				return
			end
		end)
		
		for ShopID, GoodsInfo in pairs(_G.ShopMgr.AllGoodsInfo) do
			if _G.ShopMgr:CurShopIsCanSearch(ShopID) and _G.ShopMgr:ShopIsUnLock(ShopID) then
				for i, j in pairs(GoodsInfo) do
					if j.ItemInfo then
						if j.ItemInfo.ItemName:find(Input) then
							local Data = {}
							Data.ShopID = ShopID
							Data.GoodsInfo = GoodsInfo[i].GoodsInfo
							table.insert(matches, Data)
						end
					else
						FLOG_ERROR("Error Search = %d", i)
					end
				end
			end
		end
	end

	return matches
end

function ShopInletPanelVM:SetSearchList(List)
	self.PanelContentVisible = false
	if #List > 0 then
		self.TableSearchVisible = true
		self.CurSearchList:UpdateByValues(List)
		self.EmptyVisible = false
	else
		self.TableSearchVisible = false
		self.EmptyVisible = true
	end
end

function ShopInletPanelVM:ExitSearch()
	self.TableSearchVisible = false
	self.EmptyVisible = false
	self.PanelContentVisible = true
end

function ShopInletPanelVM:OnBegin()

end

function ShopInletPanelVM:OnEnd()

end


return ShopInletPanelVM