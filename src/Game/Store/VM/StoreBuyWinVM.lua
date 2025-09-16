local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")
local StoreCfg = require("TableCfg/StoreCfg")
local StoreMgr = require("Game/Store/StoreMgr")
local UIBindableList = require("UI/UIBindableList")
local ProtoCommon = require("Protocol/ProtoCommon")
local StoreEquipPartVM = require("Game/Store/VM/ItemVM/StoreEquipPartVM")
local ITEM_TYPE = ProtoCommon.ITEM_TYPE_DETAIL


---@class StoreBuyWinVM : UIViewModel
local StoreBuyWinVM = LuaClass(UIViewModel)

---Ctor
function StoreBuyWinVM:Ctor()
	self.ItemVMList = UIBindableList.New(ItemVM,
		{IsCanBeSelected = true, IsShowNum = false, IsShowSelectStatus = false})
	self.ProductName = ""
	self.TextHint = ""
	self.BuyGoodDesc = ""
	self.PanelSlotVisible = true

	self.GoodsID = 0
end

---@param GoodsID number @商城商品ID
function StoreBuyWinVM:UpdateByGoodsID(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if GoodsCfgData == nil then
		return
	end
	self:ChangeItemVMListBind(true)
	self.GoodsID = GoodsID
	self.ProductName = GoodsCfgData.Name
	self.TextHint = "" --todo:确认是否还需要
	self.BuyGoodDesc = GoodsCfgData.Desc
	self.bPanelSlotVisible = false
    self:UpdateItemVMList(GoodsCfgData.Items)
end

---@param GoodsData table @奇遇盲盒数据
function StoreBuyWinVM:UpdateByMysteryBoxData(GoodsData)
	if nil == GoodsData or table.is_nil_empty(GoodsData.Items) then
		return
	end
	self:ChangeItemVMListBind(false)
	self.GoodsID = GoodsData.ID
	self.bPanelSlotVisible = true
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
    self:UpdateItemVMList(Items, true)
end

---@param Items table @GoodsItem
function StoreBuyWinVM:UpdateItemVMList(Items, IsMysterBox)
	self.ItemVMList:Clear()
	local ItemList = {}
    for _, Item in ipairs(Items) do
        if Item.ID ~= 0 then
            ItemList[#ItemList + 1] = {
				ResID = Item.ID,
                Num = Item.Num,
				ItemID = Item.ID,
				ItemType = IsMysterBox and ITEM_TYPE.COLLAGE_COIFFURE or nil
            }
        end
    end
    self.ItemVMList:UpdateByValues(ItemList)
end

function StoreBuyWinVM:ChangeItemVMListBind(IsItemVM)
	if IsItemVM then
		self.ItemVMList = UIBindableList.New(ItemVM, {IsCanBeSelected = true, IsShowNum = false, IsShowSelectStatus = false})
	else
		--- 发型的特殊显示逻辑，在ItemVM里没有，这里更新盲盒数据的时候，用这个VM，盲盒道具Item图片要显示发型
		self.ItemVMList = UIBindableList.New(StoreEquipPartVM)
	end
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