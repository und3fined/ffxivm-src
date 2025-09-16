---
--- Author: Administrator
--- DateTime: 2024-12-31 18:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")


---@class ArmySignListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableView_65 UTableView
---@field TextName UFTextBlock
---@field TextPeople UFTextBlock
---@field TextShortName UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySignListItemView = LuaClass(UIView, true)

function ArmySignListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableView_65 = nil
	--self.TextName = nil
	--self.TextPeople = nil
	--self.TextShortName = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySignListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySignListItemView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_65)
	--self.TableViewAdapter:SetOnClickedCallback(self.OnClickedSelectItem)
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName)},
		{ "ShortName", UIBinderSetText.New(self, self.TextShortName)},
		{ "MemberAmount", UIBinderSetText.New(self, self.TextPeople)},
		{ "IsSelected", UIBinderSetIsChecked.New(self, self.ToggleBtn, true) },
		{ "SignList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },

	}
end

function ArmySignListItemView:OnDestroy()

end

function ArmySignListItemView:OnShow()
end

function ArmySignListItemView:OnHide()

end

function ArmySignListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickedItem)
end

function ArmySignListItemView:OnRegisterGameEvent()

end

function ArmySignListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ArmySignListItemView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

return ArmySignListItemView