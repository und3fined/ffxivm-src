---
--- Author: Administrator
--- DateTime: 2024-10-10 16:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local LSTR = _G.LSTR

---@class SightSeeingLogActChooseLeftItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field FCanvasPanel_2 UFCanvasPanel
---@field Icon UFImage
---@field ImgLock UFImage
---@field PanelAct UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field RichText URichTextBox
---@field TextRightAct UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SightSeeingLogActChooseLeftItemView = LuaClass(UIView, true)

function SightSeeingLogActChooseLeftItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.FCanvasPanel_2 = nil
	--self.Icon = nil
	--self.ImgLock = nil
	--self.PanelAct = nil
	--self.PanelTips = nil
	--self.RichText = nil
	--self.TextRightAct = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SightSeeingLogActChooseLeftItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SightSeeingLogActChooseLeftItemView:InitConstStringInfo()
	self.TextRightAct:SetText(LSTR(330009))
end

function SightSeeingLogActChooseLeftItemView:OnInit()
	self.Binders = {
		{"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
		{"EmotionName", UIBinderSetText.New(self, self.RichText)},
		{"bGot", UIBinderSetIsVisible.New(self, self.ImgLock, true)},
		{"Opacity", UIBinderSetRenderOpacity.New(self, self.FCanvasPanel_2)},
		{"bCorrect", UIBinderSetIsVisible.New(self, self.PanelTips)},
	}
	self:InitConstStringInfo()
end

function SightSeeingLogActChooseLeftItemView:OnDestroy()

end

function SightSeeingLogActChooseLeftItemView:OnShow()
	UIUtil.SetIsVisible(self.Btn, false)
end

function SightSeeingLogActChooseLeftItemView:OnHide()

end

function SightSeeingLogActChooseLeftItemView:OnRegisterUIEvent()

end

function SightSeeingLogActChooseLeftItemView:OnRegisterGameEvent()

end

function SightSeeingLogActChooseLeftItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

return SightSeeingLogActChooseLeftItemView