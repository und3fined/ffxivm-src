---
--- Author: Administrator
--- DateTime: 2024-02-22 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

---@class WardrobeCollectItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF UFCanvasPanel
---@field EFF_1 UFCanvasPanel
---@field EFF_2 UFCanvasPanel
---@field IconJob UFImage
---@field ImgJob UFImage
---@field ImgLight UFImage
---@field ImgNormal UFImage
---@field ImgNumBg UFImage
---@field ImgShadow UFImage
---@field PanelName UFCanvasPanel
---@field PanelNum UFCanvasPanel
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeCollectItemView = LuaClass(UIView, true)

function WardrobeCollectItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF = nil
	--self.EFF_1 = nil
	--self.EFF_2 = nil
	--self.IconJob = nil
	--self.ImgJob = nil
	--self.ImgLight = nil
	--self.ImgNormal = nil
	--self.ImgNumBg = nil
	--self.ImgShadow = nil
	--self.PanelName = nil
	--self.PanelNum = nil
	--self.TextName = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeCollectItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeCollectItemView:OnInit()
	self.Binders = {
		{ "IsNormal", UIBinderSetIsVisible.New(self, self.ImgNormal) },
		{ "IsLight", UIBinderSetIsVisible.New(self, self.ImgLight) },
		{ "JobIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgJob) },
		{ "SmallJobIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconJob) },
		{ "JobName", UIBinderSetText.New(self, self.TextName) },
		{ "TotalNum", UIBinderSetText.New(self, self.TextNum) },
		{ "IsUnlock", UIBinderSetIsVisible.New(self, self.EFF)},
		{ "IsUnlockNoActive", UIBinderSetIsVisible.New(self, self.EFF_1)},
		{ "ActiveVisible", UIBinderSetIsVisible.New(self, self.EFF_2)},
		{ "UnlockColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNum)},
	}
end

function WardrobeCollectItemView:OnDestroy()

end

function WardrobeCollectItemView:OnShow()

end

function WardrobeCollectItemView:OnHide()

end

function WardrobeCollectItemView:OnRegisterUIEvent()

end

function WardrobeCollectItemView:OnRegisterGameEvent()

end

function WardrobeCollectItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return WardrobeCollectItemView