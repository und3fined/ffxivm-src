---
--- Author: Administrator
--- DateTime: 2025-03-17 15:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CardsPrepareRuleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock UFTextBlock
---@field FTextBlock_2 UFTextBlock
---@field FTextBlock_55 UFTextBlock
---@field ImgBanner UFImage
---@field PanelOneTitle UFCanvasPanel
---@field PanelTwoTitle UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsPrepareRuleItemView = LuaClass(UIView, true)

function CardsPrepareRuleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock = nil
	--self.FTextBlock_2 = nil
	--self.FTextBlock_55 = nil
	--self.ImgBanner = nil
	--self.PanelOneTitle = nil
	--self.PanelTwoTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsPrepareRuleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsPrepareRuleItemView:OnInit()
	self.TitlePanelList = {
		[1] = {PanelView = self.PanelOneTitle, TextWidgetList = {self.FTextBlock_2}},
		[2] = {PanelView = self.PanelTwoTitle, TextWidgetList = {self.FTextBlock_55, self.FTextBlock}},
	}
end

function CardsPrepareRuleItemView:OnDestroy()

end

function CardsPrepareRuleItemView:OnShow()
	
end

function CardsPrepareRuleItemView:OnHide()

end

function CardsPrepareRuleItemView:OnRegisterUIEvent()

end

function CardsPrepareRuleItemView:OnRegisterGameEvent()

end

function CardsPrepareRuleItemView:OnRegisterBinder()

end

function CardsPrepareRuleItemView:UpdateInfo(Icon, Titles)
	for _, TitlePanel in ipairs(self.TitlePanelList) do
		UIUtil.SetIsVisible(TitlePanel.PanelView, false)
	end

	if string.isnilorempty(Icon) then
		UIUtil.SetIsVisible(self.ImgBanner, false)
	else
		UIUtil.SetIsVisible(self.ImgBanner, true)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgBanner, Icon)
	end

	local Length = Titles and #Titles or 0
	if Length <= 0 then
		return
	end

	local MatchedTitlePanel = self.TitlePanelList[Length]
	if MatchedTitlePanel then
		UIUtil.SetIsVisible(MatchedTitlePanel.PanelView, true)
		local TextWidgetList = MatchedTitlePanel.TextWidgetList
		if TextWidgetList then
			for Index, TextWidget in ipairs(TextWidgetList) do
				local Title = Titles[Index]
				if Title then
					TextWidget:SetText(Title)
				end
			end
		end
	end
end

return CardsPrepareRuleItemView