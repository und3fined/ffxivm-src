--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-03-19 15:06:03
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-03-19 15:46:10
FilePath: \Client\Source\Script\Game\CraftingLog\View\Item\CraftingLogShopItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-03-03 19:15:09
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-03-03 19:35:06
FilePath: \Client\Source\Script\Game\CraftingLog\View\Item\CraftingLogShopItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-02-27 18:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ItemUtil = require("Utils/ItemUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ProtoRes = require("Protocol/ProtoRes")

---@class CraftingLogShopItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommAmountSlider CommAmountSliderView
---@field CommBackpack96Slot CommBackpack96SlotView
---@field FTextBlock_60 UFTextBlock
---@field Money1 CommMoneySlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CraftingLogShopItemView = LuaClass(UIView, true)

function CraftingLogShopItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommAmountSlider = nil
	--self.CommBackpack96Slot = nil
	--self.FTextBlock_60 = nil
	--self.Money1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CraftingLogShopItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommAmountSlider)
	self:AddSubView(self.CommBackpack96Slot)
	self:AddSubView(self.Money1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CraftingLogShopItemView:OnInit()
	self.Binders = {
		{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.CommBackpack96Slot.Icon)},
		{"ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.CommBackpack96Slot.ImgQuanlity)},
		{"NumRatio",UIBinderSetText.New(self, self.CommBackpack96Slot.RichTextQuantity)},
		{"BuyNum", UIBinderSetText.New(self, self.FTextBlock_60)},
	}
	UIUtil.SetIsVisible(self.CommBackpack96Slot.RichTextLevel, false)
	UIUtil.SetIsVisible(self.CommBackpack96Slot.IconChoose, false)
end

function CraftingLogShopItemView:OnDestroy()

end

function CraftingLogShopItemView:OnShow()
	local MaxNum = self.ViewModel and self.ViewModel.OnceLimitation or 99
	self.CommAmountSlider:SetSliderValueMaxMin(MaxNum, 0)
	self.CommAmountSlider:SetValueChangedCallback(function (v) self.ViewModel:SetBuyNum(v) end)
	self.CommAmountSlider:SetSliderValue(self.ViewModel.BuyNum)
end

function CraftingLogShopItemView:OnHide()

end

function CraftingLogShopItemView:OnRegisterUIEvent()
	self.CommBackpack96Slot:SetClickButtonCallback(self, self.OnBtnItemClicked)
end

function CraftingLogShopItemView:OnBtnItemClicked(ItemView)
	local ItemID = self.ViewModel.ItemID
	if ItemID ~= nil and ItemID ~= 0 then
		ItemTipsUtil.ShowTipsByResID(ItemID, ItemView, _G.UE4.FVector2D(0, 0))
	end
end

function CraftingLogShopItemView:OnRegisterGameEvent()
	
end

function CraftingLogShopItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	self.ViewModel = ViewModel
	self.MultiBinders = {
		{
			ViewModel = ViewModel,
			Binders = {
				{"Icon", UIBinderSetBrushFromAssetPath.New(self, self.CommBackpack96Slot.Icon)},
				{"ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.CommBackpack96Slot.ImgQuanlity)},
				{"NumRatio",UIBinderSetText.New(self, self.CommBackpack96Slot.RichTextQuantity)},
				{"BuyNum", UIBinderSetText.New(self, self.FTextBlock_60)},
			}
		},
		{
			ViewModel = _G.CraftingLogShopWinVM,
			Binders = {
				{"GroupNum", UIBinderValueChangedCallback.New(self, nil, self.OnGroupNumChanged)},
			}
		},
	}
	self:RegisterMultiBinders(self.MultiBinders)
	self.CommBackpack96Slot:SetParams({Data = nil})
	self.Money1:SetParams({Data = ViewModel})
	self.Money1.ScoreID = ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
end

function CraftingLogShopItemView:OnGroupNumChanged(v)
	local BuyNum = self.ViewModel.NeedNum * v
	self.CommAmountSlider:SetSliderValue(BuyNum)
end

return CraftingLogShopItemView