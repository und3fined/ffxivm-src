---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:12
--- Description:
---


local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderSetCheckedState =  require("Binder/UIBinderSetCheckedState")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local AchievementDefine = require("Game/Achievement/AchievementDefine")
local UIUtil = require("Utils/UIUtil")


---@class Achievement1stTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot_UIBP CommonRedDotView
---@field ImgArrowDown UFImage
---@field ImgArrowUp UFImage
---@field TextContent UFTextBlock
---@field ToggleBtn UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Achievement1stTabItemView = LuaClass(UIView, true)

function Achievement1stTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot_UIBP = nil
	--self.ImgArrowDown = nil
	--self.ImgArrowUp = nil
	--self.TextContent = nil
	--self.ToggleBtn = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Achievement1stTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Achievement1stTabItemView:OnInit()
	self.Binders = {
		{ "TypeID", UIBinderValueChangedCallback.New(self, nil, self.OnTypeIDChanged) },
		{ "TextContent", UIBinderSetText.New(self, self.TextContent) },
		{ "ToggleBtnState", UIBinderSetCheckedState.New(self, self.ToggleBtn) },
		{ "ArrowUp",  UIBinderValueChangedCallback.New(self, nil, self.OnArrowUpChanged) },
	}
end

function Achievement1stTabItemView:OnDestroy()

end

function Achievement1stTabItemView:OnShow()

end

function Achievement1stTabItemView:OnHide()
end

function Achievement1stTabItemView:OnRegisterUIEvent()

end

function Achievement1stTabItemView:OnRegisterGameEvent()

end

function Achievement1stTabItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function Achievement1stTabItemView:OnTypeIDChanged(NewValue)
	self.CommonRedDot_UIBP:SetRedDotNameByString(AchievementDefine.RedDotName .. '/' .. tostring(NewValue))
end

function Achievement1stTabItemView:OnArrowUpChanged(NewValue)
	UIUtil.SetIsVisible(self.ImgArrowUp, NewValue == true)
	UIUtil.SetIsVisible(self.ImgArrowDown, NewValue == false)
end

return Achievement1stTabItemView