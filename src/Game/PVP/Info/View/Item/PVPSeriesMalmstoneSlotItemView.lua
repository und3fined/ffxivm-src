---
--- Author: Administrator
--- DateTime: 2024-11-18 11:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class PVPSeriesMalmstoneSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnReceiveReward UFButton
---@field ImgBGBreakThrough UFImage
---@field ImgBGNormal UFImage
---@field ImgIcon UFImage
---@field ImgLock UFImage
---@field ImgSelect UFImage
---@field PanelReceived UFCanvasPanel
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPSeriesMalmstoneSlotItemView = LuaClass(UIView, true)

function PVPSeriesMalmstoneSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnReceiveReward = nil
	--self.ImgBGBreakThrough = nil
	--self.ImgBGNormal = nil
	--self.ImgIcon = nil
	--self.ImgLock = nil
	--self.ImgSelect = nil
	--self.PanelReceived = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPSeriesMalmstoneSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPSeriesMalmstoneSlotItemView:OnInit()
	self.Binders = {
		{ "IsReceivedReward", UIBinderSetIsVisible.New(self, self.PanelReceived) },
		{ "IsLocked", UIBinderSetIsVisible.New(self, self.ImgLock) },
		{ "IsBreakThroughLevel", UIBinderSetIsVisible.New(self, self.ImgBGBreakThrough) },
		{ "IsBreakThroughLevel", UIBinderSetIsVisible.New(self, self.ImgBGNormal, true) },
		{ "Num", UIBinderSetText.New(self, self.TextNum) },
		{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
	}
end

function PVPSeriesMalmstoneSlotItemView:OnDestroy()

end

function PVPSeriesMalmstoneSlotItemView:OnShow()

end

function PVPSeriesMalmstoneSlotItemView:OnHide()

end

function PVPSeriesMalmstoneSlotItemView:OnRegisterUIEvent()
	
end

function PVPSeriesMalmstoneSlotItemView:OnRegisterGameEvent()

end

function PVPSeriesMalmstoneSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPSeriesMalmstoneSlotItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	ViewModel:OnSelectChanged(IsSelected)
end

return PVPSeriesMalmstoneSlotItemView