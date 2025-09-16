---
--- Author: Administrator
--- DateTime: 2024-08-27 10:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

---@class InfoTextTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnIcon UFButton
---@field Icon UFImage
---@field PanelBtn UFCanvasPanel
---@field PanelComm UFCanvasPanel
---@field PanelPositiveBig UFCanvasPanel
---@field PanelPositiveSmall UFCanvasPanel
---@field TextCommTitle UFTextBlock
---@field TextPositiveBigSubTitle UFTextBlock
---@field TextPositiveBigTitle UFTextBlock
---@field TextPositiveCommonSubTitle UFTextBlock
---@field TextPositiveSmallSubTitle UFTextBlock
---@field TextPositiveSmallTitle UFTextBlock
---@field TipsImageItem InfoTextTipsImageItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoTextTipsView = LuaClass(InfoTipsBaseView, true)

function InfoTextTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnIcon = nil
	--self.Icon = nil
	--self.PanelBtn = nil
	--self.PanelComm = nil
	--self.PanelPositiveBig = nil
	--self.PanelPositiveSmall = nil
	--self.TextCommTitle = nil
	--self.TextPositiveBigSubTitle = nil
	--self.TextPositiveBigTitle = nil
	--self.TextPositiveCommonSubTitle = nil
	--self.TextPositiveSmallSubTitle = nil
	--self.TextPositiveSmallTitle = nil
	--self.TipsImageItem = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoTextTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.TipsImageItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoTextTipsView:OnInit()
	self.Type = 1
end

function InfoTextTipsView:OnDestroy()

end

function InfoTextTipsView:OnShow()
	local Params = self.Params
	if Params == nil then 
		return
	end
	self.Super:OnShow()
	self.Type = Params.Type
	self.TipsImageItem:SetImagePanel(Params.ImagePanel)
	UIUtil.SetIsVisible(self.TipsImageItem, Params.ImagePanel ~= nil)
	UIUtil.SetIsVisible(self.PanelComm, 1 == Params.Type)
	UIUtil.SetIsVisible(self.PanelPositiveSmall, 2 == Params.Type)
	UIUtil.SetIsVisible(self.PanelPositiveBig, 3 == Params.Type)
	UIUtil.SetIsVisible(self.PanelBtn, true == Params.ShowBtn, true)
	
	if 1 == Params.Type then
		self:PanelCommContent(Params)
	elseif 2 == Params.Type then
		self:PanelSmallContent(Params)
	elseif 3 == Params.Type then
		self:PanelBigContent(Params)
	end
end

function InfoTextTipsView:PanelCommContent(Params)
	self.TextCommTitle:SetText(Params.Content)
	self.TextPositiveCommonSubTitle:SetText(Params.HintText)
end

function InfoTextTipsView:PanelBigContent(Params)
	self.TextPositiveBigTitle:SetText(Params.Content)
	self.TextPositiveBigSubTitle:SetText(Params.HintText)
end

function InfoTextTipsView:PanelSmallContent(Params)
	self.TextPositiveSmallTitle:SetText(Params.Content)
	self.TextPositiveSmallSubTitle:SetText(Params.HintText)
end

function InfoTextTipsView:OnHide()

end

function InfoTextTipsView:OnRegisterUIEvent()

end

function InfoTextTipsView:OnRegisterGameEvent()

end

function InfoTextTipsView:OnRegisterBinder()

end

function InfoTextTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

return InfoTextTipsView