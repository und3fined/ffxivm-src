local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local StoreCfg = require("TableCfg/StoreCfg")
local StoreUtil = require("Game/Store/StoreUtil")
local UIBindableList = require("UI/UIBindableList")


---@class StoreBuyWinVM : UIViewModel
local StoreBuyWinVM = LuaClass(UIViewModel)

---Ctor
function StoreBuyWinVM:Ctor()
	self.ItemVMList = UIBindableList.New(ItemVM,
		{IsCanBeSelected = true, IsShowNum = false, IsShowSelectStatus = false})
	self.ProductName = ""
	self.TextHint = ""
	self.BuyGoodDesc = ""
	self.bPanelSlotVisible = false

	self.GoodsID = 0
end

---@param GoodsID number @商城商品ID
function StoreBuyWinVM:UpdateByGoodsID(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if GoodsCfgData == nil then
		return
	end
	self.GoodsID = GoodsID
	self.ProductName = StoreUtil.GetGoodsName(GoodsID)
	self.TextHint = "" --todo:确认是否还需要
	self.BuyGoodDesc = StoreUtil.GetGoodsDesc(GoodsID)
	self.bPanelSlotVisible = false
	local Items = StoreUtil.GetSortedItems(GoodsCfgData.Items)
    self:UpdateItemVMList(Items)
end

---@param Items table @GoodsItem
function StoreBuyWinVM:UpdateItemVMList(Items)
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

function StoreBuyWinVM:OnInit()
end

function StoreBuyWinVM:OnBegin()
end

function StoreBuyWinVM:OnEnd()
end

function StoreBuyWinVM:OnShutdown()
end

return StoreBuyWinVM