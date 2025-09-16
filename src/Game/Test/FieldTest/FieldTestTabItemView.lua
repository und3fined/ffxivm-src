---
--- Author: sammrli
--- DateTime: 2023-05-22 10:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class FieldTestTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field Normal UOverlay
---@field Selected UOverlay
---@field TextNormal UFTextBlock
---@field TextSelected UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FieldTestTabItemView = LuaClass(UIView, true)

function FieldTestTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Normal = nil
	--self.Selected = nil
	--self.TextNormal = nil
	--self.TextSelected = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FieldTestTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FieldTestTabItemView:OnInit()

end

function FieldTestTabItemView:OnDestroy()

end

function FieldTestTabItemView:OnShow()

end

function FieldTestTabItemView:OnHide()

end

function FieldTestTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Button, self.OnClickHandle)
end

function FieldTestTabItemView:OnRegisterGameEvent()

end

function FieldTestTabItemView:OnRegisterBinder()
	if nil == self.Params then return end

	self.ViewModel = self.Params.Data

	local Binders = {
		{ "NormalName", UIBinderSetText.New(self, self.TextNormal) },
		{ "SelectedName", UIBinderSetText.New(self, self.TextSelected) },
		{ "IsNormalVisible", UIBinderSetIsVisible.New(self, self.Normal) },
		{ "IsSelectedVisible", UIBinderSetIsVisible.New(self, self.Selected) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

---由UIAdapterTableView调用SetSelectedIndex触发，点击不会触发
function FieldTestTabItemView:OnSelectChanged(IsSelected)
	if self.ViewModel then
		self.ViewModel.IsNormalVisible = not IsSelected
		self.ViewModel.IsSelectedVisible = IsSelected
	end
end

function FieldTestTabItemView:OnClickHandle()
	if self.ViewModel and self.ViewModel.CallBack and self.ViewModel.PanelView then
		self.ViewModel.CallBack(self.ViewModel.PanelView, self.ViewModel.Key)
	end
end


return FieldTestTabItemView