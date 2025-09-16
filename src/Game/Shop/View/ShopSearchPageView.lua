---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ShopDefine = require("Game/Shop/ShopDefine")
local ShopVM = require("Game/Shop/ShopVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class ShopSearchPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInput CommSearchBarView
---@field BtnWipeHistory Comm2BtnSView
---@field CloseBtn CommonCloseBtnView
---@field PanelEmpty UFCanvasPanel
---@field TableViewHistory UTableView
---@field TextEmpty UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopSearchPageView = LuaClass(UIView, true)

function ShopSearchPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInput = nil
	--self.BtnWipeHistory = nil
	--self.CloseBtn = nil
	--self.PanelEmpty = nil
	--self.TableViewHistory = nil
	--self.TextEmpty = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopSearchPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInput)
	self:AddSubView(self.BtnWipeHistory)
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopSearchPageView:OnInit()
	self.BtnInput:SetHintText(ShopDefine.ShopMainInputHintText)
	self.BtnInput:SetCallback(self, nil, self.OnBtnInputCommitted, self.ExitSearchMode)
	--self.BtnInput.StoreRecord = true

	self.TableViewHistoryAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewHistory, nil, false)

	self.Binders = {
		{"ShopName", UIBinderSetText.New(self, self.TextTitle)},
		{"SearchPageList", UIBinderUpdateBindableList.New(self, self.TableViewHistoryAdapter)},
		{"SearchInputLastRecord", UIBinderSetText.New(self, self.BtnInput)}
	}
end

function ShopSearchPageView:OnDestroy()

end

function ShopSearchPageView:OnShow()

end

function ShopSearchPageView:OnHide()
	ShopVM:SetSearchInputBtnSize(self.BtnInput:GetText())
end

function ShopSearchPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnWipeHistory, self.OnBtnWipeHistoryClicked)
end

function ShopSearchPageView:OnRegisterGameEvent()

end

function ShopSearchPageView:OnRegisterBinder()
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

function ShopSearchPageView:OnBtnInputCommitted(SearchText)
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

	if SearchText == nil then
		return
	end
	ViewModel:AddSearchRecord(SearchText)
	ShopVM:ShowShopSearchResultPanel(SearchText)
	ShopVM:SetSearchInputLastRecord(SearchText)
end

function ShopSearchPageView:ExitSearchMode()
	self:Hide()
end

function ShopSearchPageView:OnBtnWipeHistoryClicked()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

	ViewModel.SearchPageList:Clear(true)
end

return ShopSearchPageView