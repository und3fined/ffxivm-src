---
--- Author: Administrator
--- DateTime: 2025-03-13 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class WardrobeSuitListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field TableViewSlot UTableView
---@field TableViewSlot2 UTableView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeSuitListView = LuaClass(UIView, true)

function WardrobeSuitListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.TableViewSlot = nil
	--self.TableViewSlot2 = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeSuitListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeSuitListView:OnInit()
	self.ItemListAdapter1 = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, nil, true)
	self.ItemListAdapter2 = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot2, nil, true)

	self.Binders = {
		{ "TitelName", UIBinderSetText.New(self, self.TextName)},
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "AppItems1",  UIBinderUpdateBindableList.New(self, self.ItemListAdapter1)},
		{ "AppItems2",  UIBinderUpdateBindableList.New(self, self.ItemListAdapter2)},
	}
end

function WardrobeSuitListView:OnDestroy()

end

function WardrobeSuitListView:OnShow()

end

function WardrobeSuitListView:OnHide()

end

function WardrobeSuitListView:OnRegisterUIEvent()

end

function WardrobeSuitListView:OnRegisterGameEvent()

end

function WardrobeSuitListView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function WardrobeSuitListView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.IsSelected = bSelected
end

return WardrobeSuitListView