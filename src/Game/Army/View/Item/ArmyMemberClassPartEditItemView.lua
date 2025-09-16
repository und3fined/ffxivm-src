---
--- Author: daniel
--- DateTime: 2023-03-15 15:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local LSTR = _G.LSTR

---@class ArmyMemberClassPartEditItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgClassIcon UFImage
---@field ImgMemberNum UFTextBlock
---@field TextClassName UFTextBlock
---@field TextClassNum UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassPartEditItemView = LuaClass(UIView, true)

function ArmyMemberClassPartEditItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgClassIcon = nil
	--self.ImgMemberNum = nil
	--self.TextClassName = nil
	--self.TextClassNum = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassPartEditItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassPartEditItemView:OnInit()
	self.Binders = {
		{ "CategoryIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgClassIcon)},
		{ "ShowIndex", UIBinderSetText.New(self, self.TextClassNum)},
		{ "CategoryName", UIBinderSetText.New(self, self.TextClassName)},
		{ "MemberNum", UIBinderSetText.New(self, self.ImgMemberNum)},
		{ "bSelected", UIBinderSetIsChecked.New(self, self.ToggleBtn, true)},
	}
end

function ArmyMemberClassPartEditItemView:OnDestroy()

end

function ArmyMemberClassPartEditItemView:OnShow()

end

function ArmyMemberClassPartEditItemView:OnHide()

end

function ArmyMemberClassPartEditItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickedItem)
end

function ArmyMemberClassPartEditItemView:OnRegisterGameEvent()

end

function ArmyMemberClassPartEditItemView:OnRegisterBinder()
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


function ArmyMemberClassPartEditItemView:OnClickedItem()
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

-- ---@field IsSelected boolean
-- function ArmyMemberClassPartEditItemView:OnSelectChanged(IsSelected)
-- 	self.ToggleBtn:SetChecked(IsSelected, false)
-- end

return ArmyMemberClassPartEditItemView