---
--- Author: alex
--- DateTime: 2024-08-23 15:13
--- Description:风脉泉触发弹出tips
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")

---@class InfoAetherCurrentTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MI_DX_InfoTextTips_3 UFImage
---@field PanelBigTips UFCanvasPanel
---@field PanelSamll UFCanvasPanel
---@field TextBigSubTitle UFTextBlock
---@field TextBigTitle UFTextBlock
---@field TextSamllTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoAetherCurrentTipsView = LuaClass(UIView, true)

function InfoAetherCurrentTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MI_DX_InfoTextTips_3 = nil
	--self.PanelBigTips = nil
	--self.PanelSamll = nil
	--self.TextBigSubTitle = nil
	--self.TextBigTitle = nil
	--self.TextSamllTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoAetherCurrentTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoAetherCurrentTipsView:OnInit()

end

function InfoAetherCurrentTipsView:OnDestroy()

end

function InfoAetherCurrentTipsView:OnShow()
	local Params = self.Params
	if not Params then
		return
	end

	local bShowBigTitle = Params.bShowBigTitle
	UIUtil.SetIsVisible(self.PanelBigTips, bShowBigTitle)
	UIUtil.SetIsVisible(self.MI_DX_InfoTextTips_3, bShowBigTitle)
	UIUtil.SetIsVisible(self.PanelSamll, not bShowBigTitle)

	local ShowTextWidget = bShowBigTitle and self.TextBigTitle or self.TextSamllTitle
	local Content = Params.Content or ""
	ShowTextWidget:SetText(Content)

	local SubTitleWidget = self.TextBigSubTitle
	if SubTitleWidget then
		local bShowSubTitle = Params.bShowSubTitle
		local SubContent = Params.SubContent or ""
		UIUtil.SetIsVisible(SubTitleWidget, bShowSubTitle)
		if bShowSubTitle then
			SubTitleWidget:SetText(SubContent)
		end
	end

	self.Callback = Params.Callback

	local ShowTime = Params.ShowTime or AetherCurrentDefine.PanelTipsShowTime
	self:RegisterTimer(function()
		self:Hide()
		local Callback = self.Callback
		if Callback and type(Callback) == "function" then
			Callback()
		end
	end, ShowTime, 0, 1)
end

function InfoAetherCurrentTipsView:OnHide()

end

function InfoAetherCurrentTipsView:OnRegisterUIEvent()

end

function InfoAetherCurrentTipsView:OnRegisterGameEvent()

end

function InfoAetherCurrentTipsView:OnRegisterBinder()

end

return InfoAetherCurrentTipsView