---
--- Author: anypkvcai
--- DateTime: 2024-08-16 00:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class RegionClearInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UToggleButton
---@field BtnTips CommInforBtnView
---@field CommTextSlide CommTextSlideView
---@field ImgDown UFImage
---@field ImgUp UFImage
---@field PanelCountdown UFCanvasPanel
---@field PanelRegionClear UFCanvasPanel
---@field ProBar UProgressBar
---@field RichTextTips URichTextBox
---@field TextProgress UFTextBlock
---@field AnimHighlightIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimProgressUpdate UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RegionClearInfoPanelView = LuaClass(UIView, true)

function RegionClearInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.BtnTips = nil
	--self.CommTextSlide = nil
	--self.ImgDown = nil
	--self.ImgUp = nil
	--self.PanelCountdown = nil
	--self.PanelRegionClear = nil
	--self.ProBar = nil
	--self.RichTextTips = nil
	--self.TextProgress = nil
	--self.AnimHighlightIn = nil
	--self.AnimIn = nil
	--self.AnimProgressUpdate = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RegionClearInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnTips)
	self:AddSubView(self.CommTextSlide)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RegionClearInfoPanelView:OnInit()

end

function RegionClearInfoPanelView:OnDestroy()

end

function RegionClearInfoPanelView:OnShow()

end

function RegionClearInfoPanelView:OnHide()

end

function RegionClearInfoPanelView:OnRegisterUIEvent()

end

function RegionClearInfoPanelView:OnRegisterGameEvent()

end

function RegionClearInfoPanelView:OnRegisterBinder()

end

return RegionClearInfoPanelView