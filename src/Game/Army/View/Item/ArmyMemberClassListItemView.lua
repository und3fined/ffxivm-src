---
--- Author: daniel
--- DateTime: 2023-03-13 17:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class ArmyMemberClassListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgClassIcon UFImage
---@field TextClassName UFTextBlock
---@field TextClassNum UFTextBlock
---@field TextMemberNum UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassListItemView = LuaClass(UIView, true)

function ArmyMemberClassListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgClassIcon = nil
	--self.TextClassName = nil
	--self.TextClassNum = nil
	--self.TextMemberNum = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassListItemView:OnInit()
	self.Binders = {
		{ "CategoryIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgClassIcon)},
		{ "ShowIndex", UIBinderSetText.New(self, self.TextClassNum)},
		{ "Name", UIBinderSetText.New(self, self.TextClassName)},
		{ "MemberNum", UIBinderSetText.New(self, self.TextMemberNum)},
		{ "bSelected", UIBinderValueChangedCallback.New(self, nil, self.OnSelectedChanged)},
	}
end

function ArmyMemberClassListItemView:OnDestroy()

end

function ArmyMemberClassListItemView:OnShow()
end

function ArmyMemberClassListItemView:OnHide()

end

function ArmyMemberClassListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickedItem)
end

function ArmyMemberClassListItemView:OnRegisterGameEvent()

end

function ArmyMemberClassListItemView:OnRegisterBinder()
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

---@field IsSelected boolean
function ArmyMemberClassListItemView:OnSelectChanged(IsSelected)
	self.ToggleBtn:SetChecked(IsSelected, false)
end

function ArmyMemberClassListItemView:OnClickedItem()
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

function ArmyMemberClassListItemView:OnSelectedChanged(Value)
	self:OnSelectChanged(Value)
end

return ArmyMemberClassListItemView