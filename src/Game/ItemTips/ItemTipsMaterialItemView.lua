---
--- Author: Administrator
--- DateTime: 2023-08-04 12:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoRes = require("Protocol/ProtoRes")

local MagicCardCollectionMgr = require("Game/MagicCardCollection/MagicCardCollectionMgr")

local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local LootCfg = require("TableCfg/LootCfg")

local LSTR = _G.LSTR


---@class ItemTipsMaterialItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCurrency UFImage
---@field ImgCurrency02 UFImage
---@field PanelCollectProgress UFCanvasPanel
---@field PanelMaker UFCanvasPanel
---@field RichText_Desc URichTextBox
---@field TextBP UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextMakerName UFTextBlock
---@field TextProgressTitle UFTextBlock
---@field TextProgressValue UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ItemTipsMaterialItemView = LuaClass(UIView, true)

function ItemTipsMaterialItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCurrency = nil
	--self.ImgCurrency02 = nil
	--self.PanelCollectProgress = nil
	--self.PanelMaker = nil
	--self.RichText_Desc = nil
	--self.TextBP = nil
	--self.TextBuyPrice = nil
	--self.TextMakerName = nil
	--self.TextProgressTitle = nil
	--self.TextProgressValue = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ItemTipsMaterialItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ItemTipsMaterialItemView:OnInit()
	local Key = ProtoRes.client_global_cfg_id.GLOBAL_CFG_ITEM_MAGIC_CARD_PACK_ID_TABLE
	local ClientGlobalCfg = ClientGlobalCfg:FindCfgByKey(Key)
	if (ClientGlobalCfg ~= nil) then
		self.MagicCardPackResIDTable = {}
		local SplitStr = string.split(ClientGlobalCfg.ValueStr[1], ",")
		for Key,Value in pairs(SplitStr) do
			table.insert(self.MagicCardPackResIDTable, tonumber(Value))
		end
	else
		_G.FLOG_ERROR("ClientGlobalCfg:FindCfgByKey 无法找到 GLOBAL_CFG_ITEM_MAGIC_CARD_PACK_ID_TABLE，请检查，将使用默认数据")
		-- 策划新需求，需要对幻卡包里面能开出的卡，做一个进度展示
		self.MagicCardPackResIDTable =
		{
			66600001, -- 九宫幻卡白金包
			66600002, -- 九宫幻卡铜包
			66600003, -- 九宫幻卡银包
			66600004, -- 九宫幻卡金包
		}
	end

	self.Binders = {
		{ "IntroText", UIBinderSetText.New(self, self.RichText_Desc) },

		{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
		{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },

		{ "MakerNameText", UIBinderSetText.New(self, self.TextMakerName) },
		{ "MakerNameVisible", UIBinderSetIsVisible.New(self, self.PanelMaker) },

		{ "BuyPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency) },
		{ "SellPriceIconVisible", UIBinderSetIsVisible.New(self, self.ImgCurrency02) },

	}
end

function ItemTipsMaterialItemView:OnDestroy()

end

function ItemTipsMaterialItemView:OnMagicCardCollectionUpdate(Params)
	self:CheckProgressPanelForMagicCardPack()
end

function ItemTipsMaterialItemView:OnShow()
	self.TextBP:SetText(LSTR(1020034)) -- 商店价格
	self.TextSP:SetText(LSTR(1020035)) -- 回收价格
	self.TextProgressTitle:SetText(LSTR(1020075)) -- 收集进度
	local bShowProgress = self:CheckProgressPanelForMagicCardPack()
	UIUtil.SetIsVisible(self.PanelCollectProgress, bShowProgress)
end

function ItemTipsMaterialItemView:CheckProgressPanelForMagicCardPack()
	if (self.ViewModel == nil) then
		return false
	end

	if (self.ViewModel.ResID == nil or self.ViewModel.ResID <= 0) then
		return false
	end

	local bShowProgress = false
	for _,Value in pairs (self.MagicCardPackResIDTable) do
		-- body
		if (self.ViewModel.ResID == Value) then
			bShowProgress = true
			break
		end
	end

	if (not bShowProgress) then
		return false
	end

	local ItemTableData = ItemCfg:FindCfgByKey(self.ViewModel.ResID)
	if (ItemTableData == nil) then
		_G.FLOG_ERROR("无法找到物品表数据，ID是：%s", self.ViewModel.ResID)
		return false
	end

	local FuncTableData = FuncCfg:FindCfgByKey(ItemTableData.UseFunc)
	if (FuncTableData == nil) then
		_G.FLOG_ERROR("无法找到使用功能数据，ID是:%s", ItemTableData.UseFunc)
		return false
	end

	if (FuncTableData.Func ==  nil or #FuncTableData.Func < 1) then
		_G.FLOG_WARNING("使用功能 Func为空，请检查,ID是:%s", ItemTableData.UseFunc)
		return false
	end

	if (FuncTableData.Func[1].Value == nil or #FuncTableData.Func[1].Value < 1) then
		_G.FLOG_WARNING("使用功能 Func1的Value为空，请检查,ID是:%s", ItemTableData.UseFunc)
		return false
	end

	local DropMappingID = FuncTableData.Func[1].Value[1]
	local MappingTableData = LootMappingCfg:FindCfg(string.format("ID = %d", DropMappingID))
	if (MappingTableData == nil) then
		_G.FLOG_ERROR("无法找到掉落映射表数据，ID是:%s", DropMappingID)
		return false
	end

	if (MappingTableData.Programs == nil or #MappingTableData.Programs < 1) then
		_G.FLOG_ERROR("无法找到掉落映射表的内容，请检查,id : %s", DropMappingID)
		return false
	end

	local LootID = MappingTableData.Programs[1].ID
	local LootTableData = LootCfg:FindCfgByKey(LootID)
	if (LootTableData == nil) then
		_G.FLOG_ERROR("无法找到掉落方案表内容，ID是:%s", LootID)
		return false
	end

	if (LootTableData.Produce == nil) then
		_G.FLOG_ERROR("掉落方案表的 Produce 为空，ID是:%s", LootID)
		return false
	end

	local MaxCount = 0
	
	for Key, Value in pairs(LootTableData.Produce) do
		if (Value.ID ~= nil and Value.ID > 0 and Value.MinValue ~= nil and Value.MinValue > 0) then
			MaxCount= MaxCount + 1
		end
	end
	local UnlockCount = 0
	for Key, Value in pairs (LootTableData.Produce) do
		-- body
		if (MagicCardCollectionMgr:IsCardUnlock(Value.ID)) then
			UnlockCount = UnlockCount + 1
		end
	end

	self.TextProgressValue:SetText(string.format("%d/%d", UnlockCount, MaxCount))

	return true
end

function ItemTipsMaterialItemView:OnHide()

end

function ItemTipsMaterialItemView:OnRegisterUIEvent()

end

function ItemTipsMaterialItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MagicCardCollectionUpdate, self.OnMagicCardCollectionUpdate)
end

function ItemTipsMaterialItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end

	self:RegisterBinders(self.ViewModel, self.Binders)
end

return ItemTipsMaterialItemView