---
--- Author: Administrator
--- DateTime: 2023-11-30 14:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")

---@class BuddySurfaceColorPanelItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgNormalColor UFImage
---@field ImgSelectColor UFImage
---@field PanelNormal UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddySurfaceColorPanelItemView = LuaClass(UIView, true)

function BuddySurfaceColorPanelItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgNormalColor = nil
	--self.ImgSelectColor = nil
	--self.PanelNormal = nil
	--self.PanelSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddySurfaceColorPanelItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddySurfaceColorPanelItemView:OnInit()
	self.Binders = {
		{ "NormalVisible", UIBinderSetIsVisible.New(self, self.PanelNormal) },
		{ "SelectedVisible", UIBinderSetIsVisible.New(self, self.PanelSelect)},
		{ "IconImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgNormalColor) },
		{ "Color", UIBinderSetBrushTintColorHex.New(self, self.ImgNormalColor) },
        { "IconImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgSelectColor) },
		{ "Color", UIBinderSetBrushTintColorHex.New(self, self.ImgSelectColor) },
	}
end

function BuddySurfaceColorPanelItemView:OnDestroy()

end

function BuddySurfaceColorPanelItemView:OnShow()

end

function BuddySurfaceColorPanelItemView:OnHide()

end

function BuddySurfaceColorPanelItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnClickButtonItem)
end

function BuddySurfaceColorPanelItemView:OnRegisterGameEvent()

end

function BuddySurfaceColorPanelItemView:OnRegisterBinder()
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

function BuddySurfaceColorPanelItemView:OnClickButtonItem()
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

return BuddySurfaceColorPanelItemView