---
--- Author: Administrator
--- DateTime: 2024-10-10 16:53
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
---@class SightSeeingLogActChooseRightItemView : UIView
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
local SightSeeingLogActChooseRightItemView = LuaClass(UIView, true)

function SightSeeingLogActChooseRightItemView:Ctor()
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

function SightSeeingLogActChooseRightItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SightSeeingLogActChooseRightItemView:InitConstStringInfo()
	self.TextRightAct:SetText(LSTR(330009))
end

function SightSeeingLogActChooseRightItemView:OnInit()
	self.Binders = {
		{"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
		{"EmotionName", UIBinderSetText.New(self, self.RichText)},
		{"bGot", UIBinderSetIsVisible.New(self, self.ImgLock, true)},
		{"Opacity", UIBinderSetRenderOpacity.New(self, self.FCanvasPanel_2)},
		{"bCorrect", UIBinderSetIsVisible.New(self, self.PanelTips)},
	}
	self:InitConstStringInfo()
end

function SightSeeingLogActChooseRightItemView:OnDestroy()

end

function SightSeeingLogActChooseRightItemView:OnShow()
	UIUtil.SetIsVisible(self.Btn, false)
end

function SightSeeingLogActChooseRightItemView:OnHide()

end

function SightSeeingLogActChooseRightItemView:OnRegisterUIEvent()

end

function SightSeeingLogActChooseRightItemView:OnRegisterGameEvent()

end

function SightSeeingLogActChooseRightItemView:OnRegisterBinder()
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

return SightSeeingLogActChooseRightItemView