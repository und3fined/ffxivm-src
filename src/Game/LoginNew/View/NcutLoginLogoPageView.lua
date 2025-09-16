---
--- Author: sammrli
--- DateTime: 2025-02-05 15:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

---@class NcutLoginLogoPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field BtnGoBig UButton
---@field BtnGo_1 UFButton
---@field EffPanel UFCanvasPanel
---@field ImgLogo UFImage
---@field ImgLogoChina1 UFImage
---@field ImgLogoChina2 UFImage
---@field ImgLogoChinaLine UFImage
---@field ImgLogoEnglish1 UFImage
---@field ImgLogoEnglish2 UFImage
---@field ImgLogoEnglishLine UFImage
---@field MI_DX_2 UImage
---@field MI_DX_ADD_Performance_1 UImage
---@field MI_DX_Common_LoginNew UImage
---@field MI_DX_Common_LoginNew_1 UImage
---@field MI_DX_Common_LoginNew_2a UImage
---@field MI_DX_Common_LoginNew_2b UImage
---@field MI_DX_Common_LoginNew_3a UImage
---@field MI_DX_Common_LoginNew_3b UImage
---@field MI_DX_Common_LoginNew_4 UImage
---@field MaskBG CommonPopUpBGView
---@field PanelChina UFCanvasPanel
---@field PanelEnglish UFCanvasPanel
---@field PanelGo UFCanvasPanel
---@field PanelGoChina UFCanvasPanel
---@field PanelGoEnglish UFCanvasPanel
---@field PanelLogo UFCanvasPanel
---@field TextGo UFTextBlock
---@field TextTap UFTextBlock
---@field AnimClickGo UWidgetAnimation
---@field AnimInManual UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOutManual UWidgetAnimation
---@field AnimPanelGo UWidgetAnimation
---@field ReverseDelayTime float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NcutLoginLogoPageView = LuaClass(UIView, true)

function NcutLoginLogoPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.BtnGoBig = nil
	--self.BtnGo_1 = nil
	--self.EffPanel = nil
	--self.ImgLogo = nil
	--self.ImgLogoChina1 = nil
	--self.ImgLogoChina2 = nil
	--self.ImgLogoChinaLine = nil
	--self.ImgLogoEnglish1 = nil
	--self.ImgLogoEnglish2 = nil
	--self.ImgLogoEnglishLine = nil
	--self.MI_DX_2 = nil
	--self.MI_DX_ADD_Performance_1 = nil
	--self.MI_DX_Common_LoginNew = nil
	--self.MI_DX_Common_LoginNew_1 = nil
	--self.MI_DX_Common_LoginNew_2a = nil
	--self.MI_DX_Common_LoginNew_2b = nil
	--self.MI_DX_Common_LoginNew_3a = nil
	--self.MI_DX_Common_LoginNew_3b = nil
	--self.MI_DX_Common_LoginNew_4 = nil
	--self.MaskBG = nil
	--self.PanelChina = nil
	--self.PanelEnglish = nil
	--self.PanelGo = nil
	--self.PanelGoChina = nil
	--self.PanelGoEnglish = nil
	--self.PanelLogo = nil
	--self.TextGo = nil
	--self.TextTap = nil
	--self.AnimClickGo = nil
	--self.AnimInManual = nil
	--self.AnimLoop = nil
	--self.AnimOutManual = nil
	--self.AnimPanelGo = nil
	--self.ReverseDelayTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NcutLoginLogoPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MaskBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NcutLoginLogoPageView:OnInit()

end

function NcutLoginLogoPageView:OnDestroy()

end

function NcutLoginLogoPageView:OnShow()
	local IsChinese = CommonUtil.IsCurCultureChinese()
	UIUtil.SetIsVisible(self.PanelChina, IsChinese)
	UIUtil.SetIsVisible(self.PanelEnglish, not IsChinese)
end

function NcutLoginLogoPageView:OnHide()

end

function NcutLoginLogoPageView:OnRegisterUIEvent()

end

function NcutLoginLogoPageView:OnRegisterGameEvent()

end

function NcutLoginLogoPageView:OnRegisterBinder()

end

return NcutLoginLogoPageView