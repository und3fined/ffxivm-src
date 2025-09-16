---
--- Author: xingcaicao
--- DateTime: 2023-04-21 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local Json = require("Core/Json")

---@class PersonInfoGameStyleSetItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GameStyleItem PersonInfoGameStyleItemView
---@field SingleBox CommSingleBoxView
---@field TextStyle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoGameStyleSetItemView = LuaClass(UIView, true)

function PersonInfoGameStyleSetItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GameStyleItem = nil
	--self.SingleBox = nil
	--self.TextStyle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoGameStyleSetItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GameStyleItem)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoGameStyleSetItemView:OnInit()
	self.Binders = {
		{ "Desc", UIBinderSetText.New(self, self.TextStyle) },
	}

	self.BindersPersonInfoVM = {
		{ "StrGameStyleMyTempSet", UIBinderValueChangedCallback.New(self, nil, self.OnGameStyleChanged) },
	}
end

function PersonInfoGameStyleSetItemView:OnDestroy()

end

function PersonInfoGameStyleSetItemView:OnShow()

end

function PersonInfoGameStyleSetItemView:OnHide()

end

function PersonInfoGameStyleSetItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnToggleStateChanged)
end

function PersonInfoGameStyleSetItemView:OnRegisterGameEvent()

end

function PersonInfoGameStyleSetItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel

	if ViewModel ~= nil then
		self:RegisterBinders(ViewModel, self.Binders)
	end

	self:RegisterBinders(PersonInfoVM, self.BindersPersonInfoVM)
end

function PersonInfoGameStyleSetItemView:OnGameStyleChanged(StrSet)
	if nil == self.ViewModel then
		self.SingleBox:SetChecked(false, false)
		return
	end

	local ID = self.ViewModel.ID
	if nil == ID then
		self.SingleBox:SetChecked(false, false)
		return
	end

	local IDList = Json.decode(StrSet or "[]")
	self.SingleBox:SetChecked(table.contain(IDList, ID), false)
end

function PersonInfoGameStyleSetItemView:OnToggleStateChanged(ToggleButton, State)
	if nil == self.ViewModel or nil == self.ViewModel.ID then
		return
	end

	-- local Count = PersonInfoVM.AllGameStyleVMList:Length()

	-- if Count >= 5 then
	-- 	self.SingleBox:SetChecked(false, false)
	-- 	return
	-- end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if PersonInfoVM:UpdateMyTempGameStyle(self.ViewModel.ID, IsChecked) == false then
		self.SingleBox:SetChecked(false, false)
	end
end

return PersonInfoGameStyleSetItemView