---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ShopVM = require("Game/Shop/ShopVM")

---@class ShopFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFilterCondition UFButton
---@field TextConditionName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopFilterItemView = LuaClass(UIView, true)

function ShopFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFilterCondition = nil
	--self.TextConditionName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopFilterItemView:OnInit()
	self.Binders =  {
		{"TabName", UIBinderSetText.New(self, self.TextConditionName)},
	}
end

function ShopFilterItemView:OnDestroy()

end

function ShopFilterItemView:OnShow()

end

function ShopFilterItemView:OnHide()

end

function ShopFilterItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnFilterCondition, self.OnBtnFilterClicked)
end

function ShopFilterItemView:OnRegisterGameEvent()

end

function ShopFilterItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function ShopFilterItemView:OnBtnFilterClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	ShopVM:UpdateShopItemListAfterFiltered(ViewModel.ParentName, ViewModel.TabName, ViewModel.ParentIndex)
end


return ShopFilterItemView