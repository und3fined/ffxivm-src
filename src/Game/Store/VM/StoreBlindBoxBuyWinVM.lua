local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local StoreMgr = require("Game/Store/StoreMgr")
local UIBindableList = require("UI/UIBindableList")
local StoreMysteryBoxListItemVM = require("Game/Store/VM/ItemVM/StoreMysteryBoxListItemVM")

---@class StoreBlindBoxBuyWinVM : UIViewModel
local StoreBlindBoxBuyWinVM = LuaClass(UIViewModel)

---Ctor
function StoreBlindBoxBuyWinVM:Ctor()
	self.ItemVMList = UIBindableList.New(StoreMysteryBoxListItemVM)
	self.ProductName = ""
	self.TextHint = ""
	self.BuyGoodDesc = ""
	self.bPanelSlotVisible = false

	self.GoodsID = 0
end

---@param GoodsData table @奇遇盲盒数据
function StoreBlindBoxBuyWinVM:UpdateByMysteryBoxData(GoodsData)
	if nil == GoodsData or table.is_nil_empty(GoodsData.Items) then
		return
	end
	self.GoodsID = GoodsData.ID
	self.ProductName = GoodsData.Name
	self.BuyGoodDesc = GoodsData.BuyNote or ""
	local Items = {}
	for i = 1, #GoodsData.Items do
		local ID = GoodsData.Items[i].ID
		local IsOwned = StoreMgr.CheckItemOwned(ID)
		if not IsOwned then
			table.insert(Items, GoodsData.Items[i])
		end
	end
    self:UpdateItemVMList(Items)
end

---@param Items table @GoodsItem
function StoreBlindBoxBuyWinVM:UpdateItemVMList(Items)
	self.ItemVMList:Clear()
	local ItemList = {}
    for _, Item in ipairs(Items) do
        if Item.ID ~= 0 then
            ItemList[#ItemList + 1] = {
				ResID = Item.ID,
                Num = Item.Num,
				ItemID = Item.ID,
            }
        end
    end
    self.ItemVMList:UpdateByValues(ItemList)
end

function StoreBlindBoxBuyWinVM:OnInit()
end

function StoreBlindBoxBuyWinVM:OnBegin()
end

function StoreBlindBoxBuyWinVM:OnEnd()
end

function StoreBlindBoxBuyWinVM:OnShutdown()
end

return StoreBlindBoxBuyWinVM