---
--- Author: Administrator
--- DateTime: 2023-06-26 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CommScreenerTableViewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropDownList CommDropDownListView
---@field DropDownList2 CommDropDownListView
---@field PanelClass UFCanvasPanel
---@field PanelClass2 UFCanvasPanel
---@field SingleBox CommSingleBoxView
---@field TableViewDetailTag UTableView
---@field TextClassName UFTextBlock
---@field TextClassName2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommScreenerTableViewItemView = LuaClass(UIView, true)

function CommScreenerTableViewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropDownList = nil
	--self.DropDownList2 = nil
	--self.PanelClass = nil
	--self.PanelClass2 = nil
	--self.SingleBox = nil
	--self.TableViewDetailTag = nil
	--self.TextClassName = nil
	--self.TextClassName2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommScreenerTableViewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.DropDownList2)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommScreenerTableViewItemView:OnInit()
	self.SelectListTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewDetailTag)
	self.SelectListTableViewAdapter:SetOnClickedCallback(self.OnScreenerItemClicked)

end

function CommScreenerTableViewItemView:OnDestroy()
end

function CommScreenerTableViewItemView:OnShow()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self:SetDropDown1Info(ViewModel.DropDown1List)
	self:SetDropDown2Info(ViewModel.DropDown2List)

	--还原上次选中的情况
	if ViewModel.DropDown1Visible == true then
		ViewModel:SetDropDownSelectedInfo(ViewModel.ScreenerSelectedInfo)
	elseif ViewModel.SelectListVisible == true then
		ViewModel:SetSelectListSelectedInfo(ViewModel.ScreenerSelectedInfo)
	elseif ViewModel.CheckBoxVisible == true then
		ViewModel:SetCheckBoxSelectedInfo(ViewModel.ScreenerSelectedInfo)
	end
end

function CommScreenerTableViewItemView:SetDropDown1Info(DropDownList)
	if DropDownList == nil or #DropDownList == 0 then
		return
	end
	local ListData = {}

	local ListLen = #DropDownList

	for i = 1, ListLen do
		table.insert(ListData, {Name = DropDownList[i].ScreenerName})
	end

	self.DropDownList:UpdateItems(ListData, 1)
end

function CommScreenerTableViewItemView:SetDropDown2Info(DropDownList)
	if DropDownList == nil or #DropDownList == 0 then
		return
	end
	local ListData = {}

	local ListLen = #DropDownList

	for i = 1, ListLen do
		table.insert(ListData, {Name = DropDownList[i].ScreenerName})
	end

	self.DropDownList2:UpdateItems(ListData, 1)
end

function CommScreenerTableViewItemView:OnHide()
end

function CommScreenerTableViewItemView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnSelectionChangedDropDown1List)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList2, self.OnSelectionChangedDropDown2List)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnClickSingleBox)
end

function CommScreenerTableViewItemView:OnRegisterGameEvent()

end

function CommScreenerTableViewItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	local Binders = {
		{ "DropDown1Visible", UIBinderSetIsVisible.New(self, self.DropDownList) },
		{ "DropDown2Visible", UIBinderSetIsVisible.New(self, self.DropDownList2) },
		{ "SelectListVisible", UIBinderSetIsVisible.New(self, self.TableViewDetailTag) },
		{ "Title1Visible", UIBinderSetIsVisible.New(self, self.PanelClass) },
		{ "Title2Visible", UIBinderSetIsVisible.New(self, self.PanelClass2) },
		{ "CheckBoxVisible", UIBinderSetIsVisible.New(self, self.SingleBox) },

		{ "SelectListVMList", UIBinderUpdateBindableList.New(self, self.SelectListTableViewAdapter) },
		{ "Title1Text", UIBinderSetText.New(self, self.TextClassName) },
		{ "Title2Text", UIBinderSetText.New(self, self.TextClassName2) },
		{ "CheckBoxText", UIBinderSetText.New(self, self.SingleBox.TextContent) },
	}

	self:RegisterBinders(ViewModel, Binders)

	ViewModel:SetDropDown1Callback(function (Index)
		return self:SetDropDown1Index(Index)
	end)

	ViewModel:SetDropDown2Callback(function (Index)
		return self:SetDropDown2Index(Index)
	end)

	ViewModel:SetCheckBoxCallback(function (State)
		return self:SetCheckBox(State)
	end)
end

function CommScreenerTableViewItemView:SetDropDown1Index(Index)
	if self.DropDownList == nil then
		return
	end

	self.DropDownList:SetDropDownIndex(Index)
end

function CommScreenerTableViewItemView:SetDropDown2Index(Index)
	if self.DropDownList2 == nil then
		return
	end

	self.DropDownList2:SetDropDownIndex(Index)
end

function CommScreenerTableViewItemView:SetCheckBox(State)
	if self.SingleBox == nil then
		return
	end
	self.SingleBox:SetToggleState(State)
	self:OnClickSingleBox(self.SingleBox, State)
end

function CommScreenerTableViewItemView:OnSelectionChangedDropDown1List(Index)
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	ViewModel:SetDropDown1Index(Index)
end

function CommScreenerTableViewItemView:OnSelectionChangedDropDown2List(Index)
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	ViewModel:SetDropDown2Index(Index)
end

function CommScreenerTableViewItemView:OnScreenerItemClicked(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end

	if ItemData.SelectedTagVisible == true then
		return
	end

	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	ViewModel:ResetLastSingleSelectIndex(Index)

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, ViewModel.Index)
end

function CommScreenerTableViewItemView:OnClickSingleBox(View, State)
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data
	if nil == ViewModel then return end

	ViewModel:SetCheckedSingleBox(State)
end

return CommScreenerTableViewItemView