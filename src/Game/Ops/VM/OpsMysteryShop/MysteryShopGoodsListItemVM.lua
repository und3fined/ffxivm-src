local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GoodsCfg = require("TableCfg/GoodsCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local StoreUtil = require("Game/Store/StoreUtil")
local StoreMgr = require("Game/Store/StoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local ShopDefine = require("Game/Shop/ShopDefine")
local MysteryShopWinItemVM = require("Game/Ops/VM/OpsMysteryShop/MysteryShopWinItemVM")
local UIBindableList = require("UI/UIBindableList")
local ClosetCfg = require("TableCfg/ClosetCfg")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local FuncCfg = require("TableCfg/FuncCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local LootCfg = require("TableCfg/LootCfg")
local CondCfg = require("TableCfg/CondCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local GoodsShowConditionType = ProtoRes.GoodsShowConditionType
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local FuncType = ProtoRes.FuncType

---@class MysteryShopGoodsListItemVM : UIViewModel
local MysteryShopGoodsListItemVM = LuaClass(UIViewModel)
---Ctor
function MysteryShopGoodsListItemVM:Ctor()
    self.Name = nil
    self.ItemName = nil
    self.Num = nil
    self.ItemQuality = nil
    self.Icon = nil
    self.TagVisible = nil
    self.DiscountText = nil
    self.TimeVisible = nil
    self.TimeText = nil
    self.MaskVisible = nil
    self.ImgXVisible = nil
    self.IsCanPreView = nil
    self.MoneyImg = nil
    self.FormatCostPrice1 = nil
    self.FormatCostPrice2 = nil
    self.CostPrice2Visiable = nil
    self.ImgTagVisiable = nil
    self.ImgTag = nil
    self.ItemVMList = UIBindableList.New(MysteryShopWinItemVM)
end

function MysteryShopGoodsListItemVM:UpdateVM(Value)
    local ShopGoodsCfg = GoodsCfg:FindCfgByKey(Value.GoodID)
    if not ShopGoodsCfg then return end

    local ItemCfg = ItemCfg:FindCfgByKey(ShopGoodsCfg.Items[1].ID)
    if not ItemCfg then return end
    self.GoodsID = Value.GoodID
    self.ShopGoodsCfg = ShopGoodsCfg
    self.ItemID = ItemCfg.ItemID
    self.ItemName = ItemCfg.ItemName
    local ItemType = ItemCfg.ItemType
    self.ItemType = ProtoEnumAlias.GetAlias(ProtoCommon.ITEM_TYPE_DETAIL, ItemType or "")
    self.ItemDescription = ItemCfg.ItemDesc
    self.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ShopGoodsCfg.Items[1].ID))
    self.ItemQuality = OpsActivityDefine.ItemQuality[ItemCfg.ItemColor]
    local ItemColor = ItemCfg.ItemColor
    local IsHQ = ItemCfg.IsHQ
    if IsHQ == 1 then
		self.HQVisible = true
		self.HQColor = ShopDefine.HQColor[ItemColor]
	else
		self.HQVisible = false
	end
	self.HQImage = ShopDefine.ItemColor[ItemColor]
    self.OnceLimitation = ShopGoodsCfg.OnceLimitation
    local EquipmentID = ItemCfg.EquipmentID
    local ClosetCfgItem = ClosetCfg:FindCfg(string.format("EquipID = %d", EquipmentID) )
    if ClosetCfgItem ~= nil and ClosetCfgItem.SpecialEffectType ~= 0 then
        self.ImgTagVisiable = true
        local SpecialEffectType = ClosetCfgItem.SpecialEffectType
        self.ImgTag = WardrobeDefine.TraitTypeIcon[SpecialEffectType]
    else
        self.ImgTagVisiable = false
    end

    local HasDiscount = ShopGoodsCfg.ShowDiscount ~= 0 and ShopGoodsCfg.Discount ~= 0
    local EndTimeStamp = StoreMgr:GetTimeInfo(ShopGoodsCfg.DiscountDurationEnd)
    local IsOnSale = HasDiscount and StoreMgr:IsDuringSaleTime(ShopGoodsCfg)
    local Num = ShopGoodsCfg.Items[1].Num
    if Num > 1 then
        self.Name = string.format("%s ×%s", self.ItemName, Num)
    else
        self.Name = self.ItemName
    end
    self.Num = Num
    self.TagVisible = IsOnSale
    self.TimeVisible = IsOnSale and EndTimeStamp ~= 0
    self.CostPrice2Visiable = IsOnSale
    self.DiscountText = IsOnSale and StoreUtil.GetDiscountText(ShopGoodsCfg.Discount) or nil

    self.PriceItemID = ShopGoodsCfg.Price[1].ID
    self.MoneyImg = UIUtil.GetIconPath(ItemUtil.GetItemIcon(self.PriceItemID))
    if IsOnSale then
        self.TimeText = self.TimeVisible and select(2, StoreMgr:GetTimeLimit(EndTimeStamp)) or nil

        self.CostPrice1 = math.floor(ShopGoodsCfg.Price[1].Count * ShopGoodsCfg.Discount/100)
        self.CostPrice2 = ShopGoodsCfg.Price[1].Count
    else
        self.TimeText = nil
        self.CostPrice1 = ShopGoodsCfg.Price[1].Count
        self.CostPrice2 = nil
    end

    self.FormatCostPrice1 = _G.ScoreMgr.FormatScore(self.CostPrice1)
    if self.CostPrice2Visiable then
        self.FormatCostPrice2 = _G.ScoreMgr.FormatScore(self.CostPrice2)
    end

    if Value.Counter == 1 then
        self.IsCanBuy = false
        self.MaskVisible = true
    else
        self.IsCanBuy = true
        self.MaskVisible = false
    end

    self.IsGenderCan = true
    local MajorGender = MajorUtil.GetMajorGender()
	if ItemCfg.UseCond ~= 0 and ItemCfg.ItemType == ITEM_TYPE_DETAIL.COLLAGE_FASHION then
		local TempCondCfg = CondCfg:FindCfgByKey(ItemCfg.UseCond)
		if TempCondCfg ~= nil and #TempCondCfg.Cond > 0 then
			local CondData1 = TempCondCfg.Cond[1]
			if #CondData1.Value > 0 then
				local EquipGender = CondData1.Value[1]
				if MajorGender ~= EquipGender then
					self.IsGenderCan = false
				end
			end
		end
	end
    self.ImgXVisible = not self.IsGenderCan
	self.IsCanPreView = ItemUtil.IsCanPreviewByResID(self.ItemID)
    local UseFunc = ItemCfg.UseFunc
    local Func = FuncCfg:FindCfgByKey(UseFunc)
    self.IsSuit = false
    self.ItemsData = {}
    if Func ~= nil and Func.Func[1].Type == FuncType.ItemLoot then
        local LootmapCfg = LootMappingCfg:FindCfg(string.format("ID = %d", Func.Func[1].Value[1]))
        if LootmapCfg ~= nil then
            local LootCfg = LootCfg:FindCfgByKey(LootmapCfg.Programs[1].ID)
            if LootCfg ~= nil then
                self.IsSuit = true
                local Produces = LootCfg.Produce
                for _, Produce in ipairs(Produces) do
                    if Produce.ID ~= nil and Produce.ID ~= 0 then
                        table.insert(self.ItemsData, {ItemID = Produce.ID, Num = 1})
                    end
                end
            end
        end
    end
end

function MysteryShopGoodsListItemVM:UpdateDiscountAndTime()
    local IsOnDiscountTime = StoreMgr:IsDuringSaleTime(self.ShopGoodsCfg)
    if IsOnDiscountTime then
        self.TimeText = select(2, StoreMgr:GetTimeLimit(self.ShopGoodsCfg.EndTimeStamp))
    else
        self.TagVisible = false
        self.TimeVisible = false
        self.CostPrice2Visiable = false
        self.CostPrice1 = self.ShopGoodsCfg.Price[1].Count
    end
end

function MysteryShopGoodsListItemVM:IsEqualVM(Value)
    return true
end


return MysteryShopGoodsListItemVM