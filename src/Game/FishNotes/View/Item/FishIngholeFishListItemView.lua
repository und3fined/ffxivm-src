---
--- Author: Administrator
--- DateTime: 2023-03-29 12:01
--- Description:钓鱼闹钟列表条目
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class FishIngholeFishListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FishNotesSlot FishNotesSlotItemView
---@field TextName UFTextBlock
---@field TextTime UFTextBlock
---@field ToggleButton_0 UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeFishListItemView = LuaClass(UIView, true)

function FishIngholeFishListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FishNotesSlot = nil
	--self.TextName = nil
	--self.TextTime = nil
	--self.ToggleButton_0 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeFishListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FishNotesSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeFishListItemView:OnInit()
	self.Binders = {
		{ "ClockFishIcon", UIBinderSetBrushFromAssetPath.New(self, self.FishNotesSlot.ImgIcon) },
		{ "ClockFishName", UIBinderSetText.New(self, self.TextName) },
		{ "ClockTime", UIBinderSetText.New(self, self.TextTime) },
		{ "ClockIsSelected", UIBinderSetIsChecked.New(self, self.ToggleButton_0)},
		{ "ClockInWindowTimeColor",UIBinderSetColorAndOpacityHex.New(self,self.TextName)},
		{ "ClockInWindowTimeColor",UIBinderSetColorAndOpacityHex.New(self,self.TextTime)},
	}
	self.ToggleButton_0:SetChecked(false)
end

function FishIngholeFishListItemView:OnDestroy()

end

function FishIngholeFishListItemView:OnShow()

end

function FishIngholeFishListItemView:OnHide()

end

function FishIngholeFishListItemView:OnRegisterUIEvent()	
end

function FishIngholeFishListItemView:OnRegisterGameEvent()

end

function FishIngholeFishListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return FishIngholeFishListItemView