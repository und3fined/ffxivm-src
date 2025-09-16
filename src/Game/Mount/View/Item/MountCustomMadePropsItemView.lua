---
--- Author: chunfengluo
--- DateTime: 2024-11-28 10:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MountCustomMadeSlotVM = require("Game/Mount/VM/MountCustomMadeSlotVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")

local LSTR = _G.LSTR

---@class MountCustomMadePropsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot2_UIBP CommonRedDot2View
---@field IconMoney USizeBox
---@field ImgProps UFImage
---@field ImgQuality UFImage
---@field ImgSelect UFImage
---@field TextName UFTextBlock
---@field TextState UFTextBlock
---@field Textprice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountCustomMadePropsItemView = LuaClass(UIView, true)

function MountCustomMadePropsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot2_UIBP = nil
	--self.IconMoney = nil
	--self.ImgProps = nil
	--self.ImgQuality = nil
	--self.ImgSelect = nil
	--self.TextName = nil
	--self.TextState = nil
	--self.Textprice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountCustomMadePropsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountCustomMadePropsItemView:OnInit()
	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgProps, true) },
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "OwnState", UIBinderValueChangedCallback.New(self, nil, self.OnOwnStateChanged)},
		{ "IconMoneyVisible", UIBinderSetIsVisible.New(self, self.IconMoney)},
		{ "TextpriceVisible", UIBinderSetIsVisible.New(self, self.Textprice)},
		{ "TextStateVisible", UIBinderSetIsVisible.New(self, self.TextState)},
		{ "Price", UIBinderSetTextFormatForMoney.New(self, self.Textprice)},
		{ "TextStateColor", UIBinderSetColorAndOpacityHex.New(self, self.TextState)},
		{ "StateText", UIBinderSetText.New(self, self.TextState)},
		{ "bIsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "bIsNew", UIBinderValueChangedCallback.New(self, nil, self.OnSetRedDot) },
	}
end

function MountCustomMadePropsItemView:OnDestroy()

end

function MountCustomMadePropsItemView:OnShow()
	self.CommonRedDot2_UIBP:SetIsCustomizeRedDot(true)
end

function MountCustomMadePropsItemView:OnHide()

end

function MountCustomMadePropsItemView:OnRegisterUIEvent()

end

function MountCustomMadePropsItemView:OnRegisterGameEvent()

end

function MountCustomMadePropsItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel;
	self:RegisterBinders(ViewModel, self.Binders)
end

function MountCustomMadePropsItemView:OnOwnStateChanged(Value)
	if Value == MountCustomMadeSlotVM.OwnState.Invalid then
		self.ViewModel.IconMoneyVisible = false
		self.ViewModel.TextpriceVisible = false
		self.ViewModel.TextStateVisible = false
	elseif Value == MountCustomMadeSlotVM.OwnState.Owned then
		self.ViewModel.IconMoneyVisible = false
		self.ViewModel.TextpriceVisible = false
		self.ViewModel.TextStateVisible = true
		self.ViewModel.TextStateColor = "89bd88ff"
		self.ViewModel.StateText = LSTR(1100003)
	elseif Value == MountCustomMadeSlotVM.OwnState.OwnedNotUnlockedInBag then
		self.ViewModel.IconMoneyVisible = false
		self.ViewModel.TextpriceVisible = false
		self.ViewModel.TextStateVisible = true
		self.ViewModel.TextStateColor = "d5d5d5ff"
		self.ViewModel.StateText = LSTR(1100004)
	elseif Value == MountCustomMadeSlotVM.OwnState.OwnedNotUnlockedInMail then
		self.ViewModel.IconMoneyVisible = false
		self.ViewModel.TextpriceVisible = false
		self.ViewModel.TextStateVisible = true
		self.ViewModel.TextStateColor = "d5d5d5ff"
		self.ViewModel.StateText = LSTR(1100004)
	elseif Value == MountCustomMadeSlotVM.OwnState.NotOwnedCanBuy then
		self.ViewModel.IconMoneyVisible = true
		self.ViewModel.TextpriceVisible = true
		self.ViewModel.TextStateVisible = false
		self.ViewModel:UpdatePrice()
	elseif Value == MountCustomMadeSlotVM.OwnState.NotOwnedCanGet then
		self.ViewModel.IconMoneyVisible = false
		self.ViewModel.TextpriceVisible = false
		self.ViewModel.TextStateVisible = true
		self.ViewModel.TextStateColor = "d5d5d5ff"
		self.ViewModel.StateText = LSTR(1100005)
	elseif Value == MountCustomMadeSlotVM.OwnState.NotOwnedCannotGet then
		self.ViewModel.IconMoneyVisible = false
		self.ViewModel.TextpriceVisible = false
		self.ViewModel.TextStateVisible = true
		self.ViewModel.TextStateColor = "d5d5d5ff"
		self.ViewModel.StateText = LSTR(1100005)
	elseif Value == MountCustomMadeSlotVM.OwnState.Equiped then
		self.ViewModel.IconMoneyVisible = false
		self.ViewModel.TextpriceVisible = false
		self.ViewModel.TextStateVisible = true
		self.ViewModel.TextStateColor = "d5d5d5ff"
		self.ViewModel.StateText = LSTR(1100006)
	end
end

function MountCustomMadePropsItemView:OnSetRedDot(bVisible)
	self.CommonRedDot2_UIBP:SetRedDotUIIsShow(bVisible)
end

--ShopMgr:JumpToShopGoods(ShopId, ItemResID, OpenType, TransferData)

return MountCustomMadePropsItemView