local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTipsBaitVM = require("Game/ItemTips/VM/ItemTipsBaitVM")
local ItemTipsCardVM = require("Game/ItemTips/VM/ItemTipsCardVM")
local ItemTipsCollectionVM = require("Game/ItemTips/VM/ItemTipsCollectionVM")
local ItemTipsEquipmentVM = require("Game/ItemTips/VM/ItemTipsEquipmentVM")
local ItemTipsMaterialVM = require("Game/ItemTips/VM/ItemTipsMaterialVM")
local ItemTipsMealVM = require("Game/ItemTips/VM/ItemTipsMealVM")
local ItemTipsMedicineVM = require("Game/ItemTips/VM/ItemTipsMedicineVM")
local ItemTipsBuddyVM = require("Game/ItemTips/VM/ItemTipsBuddyVM")
local ItemTipsCompanionVM = require("Game/ItemTips/VM/ItemTipsCompanionVM")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local BagMgr = require("Game/Bag/BagMgr")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local DepotVM = require("Game/Depot/DepotVM")
local BuddyFoodCfg = require("TableCfg/BuddyFoodCfg")
local ScoreMgr = require("Game/Score/ScoreMgr")
local WearableState = EquipmentDefine.WearableState
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL 


local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE
local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR

local ItemTipsFrameVM = LuaClass(UIViewModel)

ItemTipsFrameVM.ItemColorType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Item_NQ_01.UI_Quality_Item_NQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Item_NQ_02.UI_Quality_Item_NQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Item_NQ_03.UI_Quality_Item_NQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Item_NQ_04.UI_Quality_Item_NQ_04'",
}

ItemTipsFrameVM.ItemHQColorType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Item_HQ_01.UI_Quality_Item_HQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Item_HQ_02.UI_Quality_Item_HQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Item_HQ_03.UI_Quality_Item_HQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Item_HQ_04.UI_Quality_Item_HQ_04'",
}

ItemTipsFrameVM.EquipColorType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Equipment_NQ_01.UI_Quality_Equipment_NQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Equipment_NQ_02.UI_Quality_Equipment_NQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Equipment_NQ_03.UI_Quality_Equipment_NQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Equipment_NQ_04.UI_Quality_Equipment_NQ_04'",
}

ItemTipsFrameVM.EquipHQColorType =
{
	[ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Equipment_HQ_01.UI_Quality_Equipment_HQ_01'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Equipment_HQ_02.UI_Quality_Equipment_HQ_02'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Equipment_HQ_03.UI_Quality_Equipment_HQ_03'",
	[ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Equipment_HQ_04.UI_Quality_Equipment_HQ_04'",
}

--蓝色6fbee9 红色dc5868
ItemTipsFrameVM.WearableColorMap =
{
	[WearableState.Unwearable] = "dc5868",
	[WearableState.OtherProfWearable] = "6fbee9",
}

---Ctor
function ItemTipsFrameVM:Ctor()
	self.Item = nil
    self.ResID = nil
	self.ItemTipsBaitVM = ItemTipsBaitVM.New()
	self.ItemTipsEquipmentVM = ItemTipsEquipmentVM.New()
	self.ItemTipsCardVM = ItemTipsCardVM.New()
	self.ItemTipsCollectionVM = ItemTipsCollectionVM.New()
	self.ItemTipsMaterialVM = ItemTipsMaterialVM.New()
	self.ItemTipsMealVM = ItemTipsMealVM.New()
	self.ItemTipsMedicineVM = ItemTipsMedicineVM.New()
	self.ItemTipsBuddyVM = ItemTipsBuddyVM.New()
	self.ItemTipsCompanionVM = ItemTipsCompanionVM.New()

	self.ItemQualityImg = nil

	self.BtnBindVisible = nil
	self.BtnOnlyVisible = nil
	--self.BtnOrnamentVisible = nil

	self.TypeName = nil
	self.ItemName = nil
	self.IconID = nil
	self.LevelText = nil

	self.LearnVisible = nil
	--self.ProfRestrictionsImgVisible = nil
	self.ProfRestrictionsImgColor = nil

	self.DepotNumText = nil
	self.DepotHQNumText = nil
	self.DepotHQVisible = nil
	self.BagNumText = nil
	self.BagHQNumText = nil
	self.BagHQVisible = nil
	self.OwnRichText = nil

	self.ToGetVisible = nil
	self.ShowDisCurEquipmentLevel = false
	self.ShowEquipmentColorType = false
------------------------------------------------------------------------------------------
	self.BaitItemVisible = nil
	self.CardItemVisible = nil
	self.CollectionItemVisible = nil
	self.EquipmentItemVisible = nil
	self.MealItemVisible = nil
	self.MedicineItemVisible = nil
	self.BuddyItemVisible = nil
	self.CompanionItemVisible = nil
	self.MaterialItemVisible = nil --通用界面

	self.ShowBindTips = nil
	self.ShowOnlyTips = nil
	self.ShowImproveTips = nil

	self.ShowTimeText = 0
	self.PanelTimeVisible = nil
	self.TimeValidityVisible = nil
	self.TimeExpiredVisible = nil

	self.IsCanImproved = false
end

---UpdateVM
---@param Value table @csproto.Item
function ItemTipsFrameVM:UpdateVM(Value)
	if Value == nil then
		return
	end
	local ItemResID = Value.ResID
	if ItemResID == nil then
		return
	end
	self.Item = Value
    self.ResID = ItemResID
	local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if nil == Cfg then
		FLOG_WARNING("ItemTipsFrameVM:UpdateVM can't find item cfg, ResID =%d", ItemResID)
		return
	end
    local BagNQNum = 0
	local BagHQNum = 0
	local DepotNQNum = 0
	local DepotHQNum = 0
	if 1 == Cfg.IsHQ then
		self.ItemQualityImg = not self.ShowEquipmentColorType and ItemTipsFrameVM.ItemHQColorType[Cfg.ItemColor] or ItemTipsFrameVM.EquipHQColorType[Cfg.ItemColor]
		local NQHQItemID = Cfg.NQHQItemID
		if NQHQItemID > 0 then
			BagNQNum = BagMgr:GetItemNum(NQHQItemID) + EquipmentMgr:GetEquipedItemNum(NQHQItemID)
			DepotNQNum = DepotVM:GetDepotItemNum(NQHQItemID)
		end
		BagHQNum = BagMgr:GetItemNum(ItemResID) + EquipmentMgr:GetEquipedItemNum(ItemResID)
		DepotHQNum = DepotVM:GetDepotItemNum(ItemResID)
	else
		self.ItemQualityImg = not self.ShowEquipmentColorType and ItemTipsFrameVM.ItemColorType[Cfg.ItemColor] or ItemTipsFrameVM.EquipColorType[Cfg.ItemColor]
		local NQHQItemID = Cfg.NQHQItemID
		if NQHQItemID > 0 then
			BagHQNum = BagMgr:GetItemNum(NQHQItemID) + EquipmentMgr:GetEquipedItemNum(NQHQItemID)
			DepotHQNum = DepotVM:GetDepotItemNum(NQHQItemID)
		end

		-- 某些货币可以通过点击大图标显示，这里去判断一下是不是货币
		local ScoreName = ScoreMgr:GetScoreName(ItemResID)
		if (ScoreName ~= nil and ScoreName ~= "Nil") then
			local ScoreValue = ScoreMgr:GetScoreValueByID(ItemResID)
			BagNQNum = ScoreValue or 0
		else
			BagNQNum = BagMgr:GetItemNum(ItemResID) + EquipmentMgr:GetEquipedItemNum(ItemResID)
		end
		DepotNQNum = DepotVM:GetDepotItemNum(ItemResID)
	end

	self.BagHQVisible = BagHQNum > 0
	self.DepotHQVisible = DepotHQNum >0 

	self.DepotNumText = DepotNQNum
	self.DepotHQNumText = DepotHQNum
	
	self.BagNumText = BagNQNum
	self.BagHQNumText = BagHQNum

	--持有数量
	local HQRichText = RichTextUtil.GetTexture("PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Icon_Quality_High_png.UI_Icon_Quality_High_png'", 30, 30, nil)
	if BagNQNum > 0 and BagHQNum > 0 then
		self.OwnRichText = string.format("%d/%s%d", BagNQNum, HQRichText, BagHQNum)
	elseif BagHQNum > 0 then
		self.OwnRichText = string.format("%s%d", HQRichText, BagHQNum)
	elseif BagNQNum > 0 then
		self.OwnRichText = string.format("%d", BagNQNum)
	else
		self.OwnRichText = string.format("%d", BagNQNum + BagHQNum)
	end


	local IsBind = Value.IsBind
	local IsUnique = Cfg.IsUnique > 0
	self:UpdateBindAndOnly(IsBind, IsUnique)

	local CfgItemType = Cfg.ItemType
	self.TypeName = ItemTypeCfg:GetTypeName(CfgItemType)
	self.IconID = Cfg.IconID
	self.ItemName = ItemCfg:GetItemName(ItemResID)

	local CommGetWayItems = ItemUtil.GetItemGetWayList(ItemResID)
    if CommGetWayItems ~= nil and #CommGetWayItems > 0 then
        self.ToGetVisible = true
    else
        self.ToGetVisible = false
    end

	self:UpdateItemLevel(Cfg.ItemLevel, self:GetCurEquipmentLevelByPart(ItemResID))
	self.LearnVisible = self:GetPossess(Cfg)

	self.PanelTimeVisible = BagMgr:IsTimeLimitItem(Value)
	local ItemExpired = BagMgr:TimeLimitItemExpired(Value)
	self:SetItemExpired(ItemExpired)
	if self.PanelTimeVisible and not ItemExpired then
		self.ShowTimeText = Value.ExpireTime *1000
	end

	----------------------------------------------
	--隐藏所有类型的界面
	self.BaitItemVisible = false
	self.CardItemVisible = false
	self.CollectionItemVisible = false
	self.EquipmentItemVisible = false
	self.MealItemVisible = false
	self.MedicineItemVisible = false
	self.BuddyItemVisible = false
	self.CompanionItemVisible = false
	self.MaterialItemVisible = false --通用界面

	--装备单独处理
	local IsEquipment = self:IsEquipmentItem(Cfg)
	if IsEquipment then
		self.EquipmentItemVisible = true
		self.IsCanImproved = _G.EquipmentMgr:CheckCanImprove(ItemResID)
		local CanWearable, OtherProfWearable = self:UpdateProfRestrictions(ItemResID)
		self.ItemTipsEquipmentVM:UpdateVM(Value, CanWearable, OtherProfWearable)
		return
	end

	--钓饵单独处理
	local IsBait = self:IsBaitItem(Cfg)
	if IsBait then
		self.BaitItemVisible = true
		local CanWearable, OtherProfWearable = self:UpdateProfRestrictions(ItemResID)
		self.ItemTipsBaitVM:UpdateVM(Value, CanWearable, OtherProfWearable)
		return
	end

	--非装备和钓饵不显示职业限制和幻化染色
	self.GlamoursImgVisible = false
	--self.ProfRestrictionsImgVisible = false

	--幻卡单独处理
	local IsCard = self:IsCardItem(Cfg)
	if IsCard then
		self.CardItemVisible = true
		self.ItemTipsCardVM:UpdateVM(Value)
		return
	end

	--收藏品单独处理
	local IsCollection = self:IsCollectionItem(Cfg)
	if IsCollection then
		self.CollectionItemVisible = true
		self.ItemTipsCollectionVM:UpdateVM(Value)
		return
	end

	--食品单独处理
	local IsMeal = self:IsMealItem(Cfg)
	if IsMeal then
		self.MealItemVisible = true
		self.ItemTipsMealVM:UpdateVM(Value)
		return
	end

	--药品单独处理
	local IsMedicine = self:IsMedicineItem(Cfg)
	if IsMedicine then
		self.MedicineItemVisible = true
		self.ItemTipsMedicineVM:UpdateVM(Value)
		return
	end

	local IsBuddy = self:IsBuddyItem(Cfg)
	if IsBuddy then
		self.BuddyItemVisible = true
		self.ItemTipsBuddyVM:UpdateVM(Value)
		return
	end

	-- 收集品都使用宠物的说明框
	local IsCompanion = self:IsCompanionItem(Cfg)
	if IsCompanion then
		self.CompanionItemVisible = true
		self.ItemTipsCompanionVM:UpdateVM(Value)
		return
	end

	--最后处理通用界面
	self.ItemTipsMaterialVM:UpdateVM(Value)
	self.MaterialItemVisible = true
end

function ItemTipsFrameVM:SetItemExpired(IsExpired)
	self.TimeValidityVisible = not IsExpired
	self.TimeExpiredVisible = IsExpired
end

function ItemTipsFrameVM:GetCurEquipmentLevelByPart(ItemResID)
	if self.ShowDisCurEquipmentLevel then
		local ECfg = EquipmentCfg:FindCfgByKey(ItemResID)
		if ECfg == nil then
			return
		end
		local EquipedItem = EquipmentMgr:GetEquipedContrastItemByPart(ECfg.Part)
		if EquipedItem then
			local EquipedItemCfg = ItemCfg:FindCfgByKey(EquipedItem.ResID)
			local CanEquiped = _G.EquipmentMgr:CanEquiped(ItemResID, false, nil, 9999)
			if EquipedItemCfg and CanEquiped then
				return EquipedItemCfg.ItemLevel
			end
		end
	end
end

function ItemTipsFrameVM:UpdateBindAndOnly(IsBind, IsOnly)
	self.BtnBindVisible = IsBind
	self.BtnOnlyVisible = IsOnly
end

function ItemTipsFrameVM:UpdateItemLevel(ItemLevel, CurEquipLevel)
	if CurEquipLevel == nil then
		self.LevelText = string.format(LSTR(1020028), ItemLevel)
	else
		if ItemLevel > CurEquipLevel then
			local DiffValueText = RichTextUtil.GetText(string.format("+%d", ItemLevel - CurEquipLevel), "89bd88", 0, nil)
			self.LevelText = string.format(LSTR(1020029), ItemLevel, DiffValueText)
		elseif ItemLevel < CurEquipLevel then
			local DiffValueText = RichTextUtil.GetText(string.format("-%d", CurEquipLevel - ItemLevel), "dc5868", 0, nil)
			self.LevelText = string.format(LSTR(1020029), ItemLevel, DiffValueText)
		else
			self.LevelText = string.format(LSTR(1020028), ItemLevel)
		end

	end
end

--穿戴职业限制
function ItemTipsFrameVM:UpdateProfRestrictions(ItemResID)
	local CanWearable,  OtherProfWearable= ItemUtil.UpdateProfRestrictions(ItemResID)
	--self.ProfRestrictionsImgVisible = (CanWearable == false)
	--if CanWearable == false then
		--self.ProfRestrictionsImgColor = OtherProfWearable and ItemTipsFrameVM.WearableColorMap[WearableState.OtherProfWearable] or ItemTipsFrameVM.WearableColorMap[WearableState.Unwearable]
	--end

	return CanWearable, OtherProfWearable
end

function ItemTipsFrameVM:GetPossess(Cfg)
	return BagMgr:IsItemUsed(Cfg)
end

function ItemTipsFrameVM:IsBaitItem(Cfg)
	return Cfg.ItemType == ITEM_TYPE_DETAIL.CONSUMABLES_BAIT
end

function ItemTipsFrameVM:IsCardItem(Cfg)
	return Cfg.ItemType == ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD
end

function ItemTipsFrameVM:IsCollectionItem(Cfg)
	return Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_COLLECTION
end

function ItemTipsFrameVM:IsEquipmentItem(Cfg)
	return ItemUtil.CheckIsEquipment(Cfg.Classify)
end

function ItemTipsFrameVM:IsMealItem(Cfg)
	return Cfg.ItemType == ITEM_TYPE_DETAIL.CONSUMABLES_MEAL
end

function ItemTipsFrameVM:IsMedicineItem(Cfg)
	return Cfg.ItemType == ITEM_TYPE_DETAIL.CONSUMABLES_MEDICINE
end

function ItemTipsFrameVM:IsBuddyItem(Cfg)
	local CfgSearchCond = string.format("ItemID == %d and IsBuff == 1", Cfg.ItemID)
	local AllCfg = BuddyFoodCfg:FindAllCfg(CfgSearchCond)
	return AllCfg ~= nil and #AllCfg > 0
end

function ItemTipsFrameVM:IsCompanionItem(Cfg)
	return Cfg.ItemMainType == ProtoCommon.ItemMainType.ItemCollage
end

function ItemTipsFrameVM:SetShowBindTips(IsVisible)
	self.ShowBindTips = IsVisible
end

function ItemTipsFrameVM:SetShowOnlyTips(IsVisible)
	self.ShowOnlyTips = IsVisible
end

function ItemTipsFrameVM:SetShowImproveTips(IsVisible)
	self.ShowImproveTips = IsVisible
end

return ItemTipsFrameVM