---
--- Author: v_vvxinchen
--- DateTime: 2025-06-30 09:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local StoreDefine = require("Game/Store/StoreDefine")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local LootCfg = require("TableCfg/LootCfg")

---@class OpsSkiFreeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field BtnPoster UFButton
---@field BtnSlot UFButton
---@field IconMoney UFImage
---@field ImgPoster UFImage
---@field ImgSlot UFImage
---@field PanelMoney UFHorizontalBox
---@field PanelOriginalPrice UFCanvasPanel
---@field PanelSlot UFCanvasPanel
---@field TextOriginalPrice UFTextBlock
---@field TextPrice UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimSelectIn UWidgetAnimation
---@field AnimSelectOut UWidgetAnimation
---@field Icon SlateBrush
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkiFreeItemView = LuaClass(UIView, true)

function OpsSkiFreeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.BtnPoster = nil
	--self.BtnSlot = nil
	--self.IconMoney = nil
	--self.ImgPoster = nil
	--self.ImgSlot = nil
	--self.PanelMoney = nil
	--self.PanelOriginalPrice = nil
	--self.PanelSlot = nil
	--self.TextOriginalPrice = nil
	--self.TextPrice = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimSelectIn = nil
	--self.AnimSelectOut = nil
	--self.Icon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSkiFreeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsSkiFreeItemView:OnInit()

end

function OpsSkiFreeItemView:OnDestroy()

end

function OpsSkiFreeItemView:OnShow()
	self.ViewModel = self.Params.ViewModel
	local SuitData = self.Params.SuitData
	self.SuitData = SuitData
	local DefaultSuit = SuitData.Color == nil
	UIUtil.SetIsVisible(self.PanelSlot, not DefaultSuit)

	local GoodsID = SuitData.GoodsID
	local GoodsData = _G.StoreMgr:GetProductDataByID(GoodsID)
	if table.is_nil_empty(GoodsData) then return end
	local GoodCfgData = GoodsData.Cfg
	self:SetPrice(GoodCfgData)
	local Name = string.isnilorempty(SuitData.Name) and GoodCfgData.Name or SuitData.Name
	local Space = DefaultSuit and "" or "      "
	self.TextTitle:SetText(Space..Name)

	local CfgItems = GoodCfgData.Items or {}
	local GoodsItemID = CfgItems[1].ID
	self.GoodsItemID = GoodsItemID
	self:SetSuitIcon(GoodsItemID)
	self:OnSetAnim(self.ViewModel.SelectedSuitGoodsID)
end

function OpsSkiFreeItemView:SetPrice(GoodCfgData)
	local IsOnTime = _G.StoreMgr:IsDuringSaleTime(GoodCfgData)
	if GoodCfgData.Discount == StoreDefine.DiscountMinValue or GoodCfgData.Discount >= StoreDefine.DiscountMaxValue or not IsOnTime then
		UIUtil.SetIsVisible(self.PanelOriginalPrice, false)
	else
		UIUtil.SetIsVisible(self.PanelOriginalPrice, true)
	end

	local PriceData = GoodCfgData.Price[StoreDefine.PriceDefaultIndex]
    local Discount = GoodCfgData.Discount
	local ScoreIcon = _G.ScoreMgr:GetScoreIconName(PriceData.ID)
	if ScoreIcon then
        UIUtil.ImageSetBrushFromAssetPath(self.IconMoney, ScoreIcon)
    end

    if not Discount then
        Discount = StoreDefine.DiscountMaxValue
    end

    if Discount <= 0 then
        Discount = StoreDefine.DiscountMaxValue - Discount
    end

	local BuyGoodPrice = math.floor(PriceData.Count * (Discount / StoreDefine.DiscountMaxValue))
	self.TextPrice:SetText(_G.ScoreMgr.FormatScore(BuyGoodPrice))
	self.TextOriginalPrice:SetText(_G.ScoreMgr.FormatScore(PriceData.Count))
end

function OpsSkiFreeItemView:SetSuitIcon(GoodsItemID)
	local IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(GoodsItemID))
	UIUtil.ImageSetBrushFromAssetPath(self.ImgSlot, IconPath)
end

function OpsSkiFreeItemView:OnHide()

end

function OpsSkiFreeItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPoster, self.OnSelected)
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnClickBtnCheck)
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickBtnSlot)
end

--套装选中
function OpsSkiFreeItemView:OnSelected()
	self.ViewModel:OnSelectedSuit(self.SuitData.GoodsID)
end

--外观预览
function OpsSkiFreeItemView:OnClickBtnCheck()
	local ProtoRes = require("Protocol/ProtoRes")
	local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE
	_G.OpsActivityMgr:Jump(OPS_JUMP_TYPE.TABLE_JUMP, self.SuitData.JumpID)
end

--套餐内容
function OpsSkiFreeItemView:OnClickBtnSlot()
	local DataList = self.ProduceList or self:GetProduceList(self.GoodsItemID)
	local BtnSize = UIUtil.CanvasSlotGetSize(self.PanelSlot)
	local XOffset = self.bSelected and BtnSize.X * 0.3 or 0
	local YOffset = self.bSelected and BtnSize.Y + 10 or BtnSize.Y - 20
	self:ShowSuitContentTips(DataList, self.PanelSlot, _G.UE.FVector2D(XOffset, YOffset), _G.UE.FVector2D(0,1))
end

function OpsSkiFreeItemView:ShowSuitContentTips(DataList, InTargetWidget, Offset, Alignment, ForbidRangeWidget)
	local Params = {}
	Params.DataList = DataList
	Params.InTagetView = InTargetWidget
	Params.Offset = Offset or _G.UE.FVector2D(0, 0)
	Params.Alignment = Alignment or _G.UE.FVector2D(0, 0)
	Params.ForbidRangeWidget = ForbidRangeWidget
    return _G.UIViewMgr:ShowView(_G.UIViewID.OpsSkiTips, Params)
end

--region 获取套餐内容列表数据-----------------------------
function OpsSkiFreeItemView:GetProduceList(GoodsItemID)
	local ProduceList = {}
	local LootProduce = self:GetLootProduceByItemID(GoodsItemID)
	local function AddToProduceList(Value)
		table.insert(ProduceList, {
			ItemID = Value.ID,
			Num = Value.MinValue
		})
	end
	for _, Value in pairs(LootProduce) do
		local Cfg = ItemCfg:FindCfgByKey(Value.ID)
		if Cfg ~= nil then
			if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.CONSUMABLES_TREASUREBOX then
				local ChildLootProduce = self:GetLootProduceByItemID(Value.ID)
				for _, v1 in pairs(ChildLootProduce) do
					AddToProduceList(v1)
				end
			else
				AddToProduceList(Value)
			end
		end
	end
	self.ProduceList = ProduceList
	return ProduceList
end

function OpsSkiFreeItemView:GetLootProduceByItemID(GoodsItemID)
	local LootProduce = {}
	local ItemTableData = GoodsItemID and ItemCfg:FindCfgByKey(GoodsItemID)
	if ItemTableData ~= nil then
		local FuncTableData = FuncCfg:FindCfgByKey(ItemTableData.UseFunc)
		if FuncTableData ~= nil and not table.is_nil_empty(FuncTableData.Func) and not table.is_nil_empty(FuncTableData.Func[1].Value) then
			local DropMappingID = FuncTableData.Func[1].Value[1]
			local MappingTableData = LootMappingCfg:FindCfg(string.format("ID = %d", DropMappingID))
			if not table.is_nil_empty(MappingTableData.Programs) then
				local LootID = MappingTableData.Programs[1].ID
				local LootTableData = LootCfg:FindCfgByKey(LootID)
				if LootTableData ~= nil and LootTableData.Produce ~= nil then
					for _, Value in pairs(LootTableData.Produce) do
						if (Value.ID ~= nil and Value.ID > 0 and Value.MinValue ~= nil and Value.MinValue > 0) then
							table.insert(LootProduce, Value)
						end
					end
				end
			end
		end
	end
	return LootProduce
end
--endregion


function OpsSkiFreeItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsSkiSelectSuit, self.OnSetAnim)
end

function OpsSkiFreeItemView:OnSetAnim(SelectedGoodsID)
	local bSelected = SelectedGoodsID == self.SuitData.GoodsID
	if self.bSelected == nil or self.bSelected ~= bSelected then
		self.bSelected = bSelected
		if bSelected then
			self:PlayAnimation(self.AnimSelectIn)
		else
			self:PlayAnimation(self.AnimSelectOut)
		end
	end
end

function OpsSkiFreeItemView:OnRegisterBinder()

end

return OpsSkiFreeItemView