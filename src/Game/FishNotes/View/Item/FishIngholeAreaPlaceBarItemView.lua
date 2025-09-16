---
--- Author: Administrator
--- DateTime: 2023-03-31 15:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
---@class FishIngholeAreaPlaceBarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgTick UFImage
---@field RedDot2 CommonRedDot2View
---@field RichTextTitle URichTextBox
---@field TextLevel UFTextBlock
---@field TextNumber UFTextBlock
---@field ToggleButton_357 UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeAreaPlaceBarItemView = LuaClass(UIView, true)

function FishIngholeAreaPlaceBarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgTick = nil
	--self.RedDot2 = nil
	--self.RichTextTitle = nil
	--self.TextLevel = nil
	--self.TextNumber = nil
	--self.ToggleButton_357 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeAreaPlaceBarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeAreaPlaceBarItemView:OnInit()
	self.Binders = {
		{ "PlaceName", UIBinderSetText.New(self, self.RichTextTitle) },
		{ "PlaceNameColor", UIBinderSetColorAndOpacityHex.New(self, self.RichTextTitle)},
		{ "PlaceLevel", UIBinderSetText.New(self, self.TextNumber) },
		{ "bPlaceLevelJiText", UIBinderSetIsVisible.New(self, self.TextLevel) },
		{ "IsUnlockedAllFish", UIBinderSetIsVisible.New(self, self.ImgTick) },
		{ "bPlaceSelected", UIBinderSetIsChecked.New(self, self.ToggleButton_357) },

		{ "PlaceName", UIBinderValueChangedCallback.New(self, nil, self.UpdateRedDot) },
	}
end

function FishIngholeAreaPlaceBarItemView:UpdateRedDot()
	local Data = self.Params.Data
	local RedDotName = _G.FishNotesMgr:GetFishingholeRedDotName(nil,nil, Data.Key)
	if RedDotName then
		self.RedDot2:SetRedDotNameByString(RedDotName)
	else
		self.RedDot2:SetRedDotNameByString("")
	end
end

function FishIngholeAreaPlaceBarItemView:OnDestroy()

end

function FishIngholeAreaPlaceBarItemView:OnShow()
	self.TextLevel:SetText(_G.LSTR(70022))--级
end

function FishIngholeAreaPlaceBarItemView:OnHide()

end

function FishIngholeAreaPlaceBarItemView:OnRegisterUIEvent()
end

function FishIngholeAreaPlaceBarItemView:OnRegisterGameEvent()

end

function FishIngholeAreaPlaceBarItemView:OnRegisterBinder()
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

-- function FishIngholeAreaPlaceBarItemView:OnSelectChanged(IsSelect)
-- 	self.ToggleButton_357:SetChecked(IsSelect)
-- end

return FishIngholeAreaPlaceBarItemView