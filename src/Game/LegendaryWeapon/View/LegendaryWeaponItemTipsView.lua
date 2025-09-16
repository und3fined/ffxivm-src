---
--- Author: guanjiewu
--- DateTime: 2024-01-11 14:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIUtil = require("Utils/UIUtil")
local ItemTipsFrameVM = require("Game/ItemTips/VM/ItemTipsFrameVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local ItemCfg = require("TableCfg/ItemCfg")
local FLOG_WARNING = _G.FLOG_WARNING

---@class LegendaryWeaponItemTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnToGet UFButton
---@field FHorizontalBag UFHorizontalBox
---@field FHorizontalWarehouse UFHorizontalBox
---@field IconBag UFImage
---@field IconHigh UFImage
---@field IconHigh2 UFImage
---@field IconWarehouse UFImage
---@field PanelIntro UFCanvasPanel
---@field PanelOther UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelToGet UFCanvasPanel
---@field RichTextQuality URichTextBox
---@field RichText_Desc URichTextBox
---@field ScrollBox UScrollBox
---@field TextBP UFTextBlock
---@field TextBag UFTextBlock
---@field TextBuyPrice UFTextBlock
---@field TextHigh UFTextBlock
---@field TextHigh2 UFTextBlock
---@field TextIntro UFTextBlock
---@field TextName UFTextBlock
---@field TextOwn UFTextBlock
---@field TextSP UFTextBlock
---@field TextSellPrice UFTextBlock
---@field TextSlash1 UFTextBlock
---@field TextSlash2 UFTextBlock
---@field TextToGet UFTextBlock
---@field TextType UFTextBlock
---@field TextWarehouse UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponItemTipsView = LuaClass(UIView, true)

function LegendaryWeaponItemTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnToGet = nil
	--self.FHorizontalBag = nil
	--self.FHorizontalWarehouse = nil
	--self.IconBag = nil
	--self.IconHigh = nil
	--self.IconHigh2 = nil
	--self.IconWarehouse = nil
	--self.PanelIntro = nil
	--self.PanelOther = nil
	--self.PanelTips = nil
	--self.PanelToGet = nil
	--self.RichTextQuality = nil
	--self.RichText_Desc = nil
	--self.ScrollBox = nil
	--self.TextBP = nil
	--self.TextBag = nil
	--self.TextBuyPrice = nil
	--self.TextHigh = nil
	--self.TextHigh2 = nil
	--self.TextIntro = nil
	--self.TextName = nil
	--self.TextOwn = nil
	--self.TextSP = nil
	--self.TextSellPrice = nil
	--self.TextSlash1 = nil
	--self.TextSlash2 = nil
	--self.TextToGet = nil
	--self.TextType = nil
	--self.TextWarehouse = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponItemTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponItemTipsView:OnInit()
	self.ViewModel = ItemTipsFrameVM.New()
	self.MultiBinders = {
		{
			ViewModel = self.ViewModel,
			Binders = {
				{ "TypeName",    	UIBinderSetText.New(self, self.TextType) },
				{ "ItemName",			UIBinderSetText.New(self, self.TextName) },
				{ "LevelText",			UIBinderSetText.New(self, self.RichTextQuality) },		
			--	{ "OwnRichText", UIBinderSetText.New(self, self.RichTextOwn) },	  --废弃
				{ "ToGetVisible", UIBinderSetIsVisible.New(self, self.PanelToGet) },
				
				{ "DepotNumText", UIBinderSetItemNumFormat.New(self, self.TextWarehouse) },
				{ "DepotHQVisible", UIBinderSetIsVisible.New(self, self.TextSlash1) },
				{ "DepotHQVisible", UIBinderSetIsVisible.New(self, self.IconHigh) },
				{ "DepotHQVisible", UIBinderSetIsVisible.New(self, self.TextHigh) },
				{ "DepotHQNumText", UIBinderSetItemNumFormat.New(self, self.TextHigh) },

				{ "BagNumText", UIBinderSetItemNumFormat.New(self, self.TextBag) },
				{ "BagHQNumText", UIBinderSetItemNumFormat.New(self, self.TextHigh2) },
				{ "BagHQVisible", UIBinderSetIsVisible.New(self, self.TextSlash2) },
				{ "BagHQVisible", UIBinderSetIsVisible.New(self, self.IconHigh2) },
				{ "BagHQVisible", UIBinderSetIsVisible.New(self, self.TextHigh2) },
			}
		},
		{
			ViewModel = self.ViewModel.ItemTipsMaterialVM,	--道具
			Binders = {
				{ "IntroText", UIBinderSetText.New(self, self.RichText_Desc) },
				{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
				{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },
			}
		},
	}
end

function LegendaryWeaponItemTipsView:OnDestroy()

end

function LegendaryWeaponItemTipsView:OnShow()
	self.TextToGet:SetText(LSTR(220001))	--"获取"
	self.TextIntro:SetText(LSTR(220052))	--"描述"
	self.TextBP:SetText(LSTR(220053))		--"商店贩售价格"
	self.TextSP:SetText(LSTR(220054))		--"收购价格"
	self.TextOwn:SetText(LSTR(220055))		--"持有"
end

function LegendaryWeaponItemTipsView:OnHide()

end

function LegendaryWeaponItemTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnToGet, self.OnClickedToGetBtn)
end

function LegendaryWeaponItemTipsView:OnRegisterGameEvent()

end

function LegendaryWeaponItemTipsView:OnRegisterBinder()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end
	self:RegisterMultiBinders(self.MultiBinders)
end

function LegendaryWeaponItemTipsView:Setup(ResID)
	self:SetVM(ResID)
	local ItemDataParams = {
		GID = -1,
		ResID = ResID,
	}
	self.ViewModel:UpdateVM(ItemDataParams)
end

function LegendaryWeaponItemTipsView:OnClickedToGetBtn()
	local ViewModel = self.ViewModel
	if ViewModel == nil then
		return
	end

	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelTips, InTagetView = self.BtnToGet}
	ItemTipsUtil.OnClickedToGetBtn(Params)

--	_G.EventMgr:SendEvent(_G.EventID.LegendaryUpdateEquipTips, {IsActive = true})
end

function LegendaryWeaponItemTipsView:SetVM(ResID)
	if nil == ResID or ResID <= 0 then
		FLOG_WARNING("[LegendaryWeapon] 传奇武器制作材料的物品ID为空或小于等0")
		return
	end
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
		FLOG_WARNING("[LegendaryWeapon] 传奇武器制作材料的物品ID:%d无效",ResID)
		return
	end
	if self.MultiBinders == nil then
		return
	end
	local IsMedicine = self.ViewModel:IsMedicineItem(Cfg)
	if IsMedicine then
		self.MultiBinders[2] = 
		{
			ViewModel = self.ViewModel.ItemTipsMedicineVM,	-- 单独处理药品
			Binders = {
				{ "IntroText", UIBinderSetText.New(self, self.RichText_Desc) },
				{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
				{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },
			}
		}
	else
		self.MultiBinders[2] = 
		{
			ViewModel = self.ViewModel.ItemTipsMaterialVM,	--道具
			Binders = {
				{ "IntroText", UIBinderSetText.New(self, self.RichText_Desc) },
				{ "BuyPriceText", UIBinderSetText.New(self, self.TextBuyPrice) },
				{ "SellPriceText", UIBinderSetText.New(self, self.TextSellPrice) },
			}
		}
	end
	self:OnRegisterBinder()
end

return LegendaryWeaponItemTipsView