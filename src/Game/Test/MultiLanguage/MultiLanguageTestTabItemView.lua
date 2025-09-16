---
--- Author: kofhuang
--- DateTime: 2025-04-03 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class MultiLanguageTestTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field Normal UOverlay
---@field Selected UOverlay
---@field TextNormal UFTextBlock
---@field TextSelected UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MultiLanguageTestTabItemView = LuaClass(UIView, true)

function MultiLanguageTestTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Normal = nil
	--self.Selected = nil
	--self.TextNormal = nil
	--self.TextSelected = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MultiLanguageTestTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MultiLanguageTestTabItemView:OnInit()

end

function MultiLanguageTestTabItemView:OnDestroy()

end

function MultiLanguageTestTabItemView:OnShow()

end

function MultiLanguageTestTabItemView:OnHide()

end

function MultiLanguageTestTabItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Button, self.OnClickHandle)
end

function MultiLanguageTestTabItemView:OnRegisterGameEvent()

end

function MultiLanguageTestTabItemView:OnRegisterBinder()
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

function MultiLanguageTestTabItemView:OnSelectChanged(IsSelected)
	if self.ViewModel then
		self.ViewModel.IsNormalVisible = not IsSelected
		self.ViewModel.IsSelectedVisible = IsSelected
	end
end

function MultiLanguageTestTabItemView:OnClickHandle()
	if self.ViewModel and self.ViewModel.CallBack and self.ViewModel.PanelView then
		self.ViewModel.CallBack(self.ViewModel.PanelView, self.ViewModel.Key)
	end
end

return MultiLanguageTestTabItemView