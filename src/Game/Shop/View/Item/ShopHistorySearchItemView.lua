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

---@class ShopHistorySearchItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDelete UFButton
---@field BtnHistory UFButton
---@field TextHistoryContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopHistorySearchItemView = LuaClass(UIView, true)

function ShopHistorySearchItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDelete = nil
	--self.BtnHistory = nil
	--self.TextHistoryContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopHistorySearchItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopHistorySearchItemView:OnInit()
	self.Binders =  {
		{"Content", UIBinderSetText.New(self, self.TextHistoryContent)},
	}
end

function ShopHistorySearchItemView:OnDestroy()

end

function ShopHistorySearchItemView:OnShow()

end

function ShopHistorySearchItemView:OnHide()

end

function ShopHistorySearchItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnHistory, self.OnBtnHistoryClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnBtnDeleteClicked)
end

function ShopHistorySearchItemView:OnRegisterGameEvent()

end

function ShopHistorySearchItemView:OnRegisterBinder()
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

function ShopHistorySearchItemView:OnBtnHistoryClicked()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end
	ShopVM:SetSearchInputLastRecord("")
	ShopVM:ShowShopSearchResultPanel(ViewModel.Content)
	self:Hide()
end

function ShopHistorySearchItemView:OnBtnDeleteClicked()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

	ShopVM.ShopSearchPageVM:DeleteSearchRecord(ViewModel.Content)
end

return ShopHistorySearchItemView