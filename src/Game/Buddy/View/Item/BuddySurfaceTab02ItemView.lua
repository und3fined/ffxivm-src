---
--- Author: Administrator
--- DateTime: 2023-11-30 14:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class BuddySurfaceTab02ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgBgSelect UFImage
---@field TextName UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddySurfaceTab02ItemView = LuaClass(UIView, true)

function BuddySurfaceTab02ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgBgSelect = nil
	--self.TextName = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddySurfaceTab02ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddySurfaceTab02ItemView:OnInit()
	self.Binders = {
		{ "TabText", UIBinderSetText.New(self, self.TextName) },
		{ "SelectedVisible", UIBinderSetIsVisible.New(self, self.ImgBgSelect) },
		{ "SelectedAni", UIBinderValueChangedCallback.New(self, nil, self.PanelCheckChanged) },
	}
end

function BuddySurfaceTab02ItemView:OnDestroy()

end

function BuddySurfaceTab02ItemView:OnShow()

end

function BuddySurfaceTab02ItemView:OnHide()

end

function BuddySurfaceTab02ItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
end

function BuddySurfaceTab02ItemView:OnRegisterGameEvent()

end

--TabText
function BuddySurfaceTab02ItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function BuddySurfaceTab02ItemView:PanelCheckChanged()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	local IsShow = ViewModel.SelectedVisible
		if IsShow then
			self:PlayAnimation(self.AnimCheck)
		else
			self:PlayAnimation(self.AnimUncheck)
		end
end

function BuddySurfaceTab02ItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
	_G.ObjectMgr:CollectGarbage(false, true, false)
end

return BuddySurfaceTab02ItemView