---
--- Author: usakizhang
--- DateTime: 2024-08-02 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommonTitleView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommInforBtn CommInforBtnView
---@field IconBlank USpacer
---@field IconTitle UFImage
---@field PanelIcon UFCanvasPanel
---@field TextSubtitle UFTextBlock
---@field TextTitleName UFTextBlock
---@field AnimUpdateSubtitle UWidgetAnimation
---@field AnimUpdateTitle UWidgetAnimation
---@field bTitleShow bool
---@field TitleContentText text
---@field TitleColorAndoOpacity SlateColor
---@field TitleFont SlateFontInfo
---@field TitleMinFontSize int
---@field TitleReductionStep int
---@field TitleTextAdaptation ETextAdaptation
---@field TitleTextOverflow ETextOverflow
---@field TitleEnableShowDetailTips bool
---@field TileMaxNeedWidth float
---@field bSubTitleShow bool
---@field SubTitleContentText text
---@field SubTitleColorAndoOpacity SlateColor
---@field SubTitleFont SlateFontInfo
---@field SubTitleMinFontSize int
---@field SubTitleReductionStep int
---@field SubTitleTextAdaptation ETextAdaptation
---@field SubTitleTextOverflow ETextOverflow
---@field SubTitleEnableShowDetailTips bool
---@field SubMaxNeedWidth float
---@field bHpInfoShow bool
---@field HelpInfoID int
---@field IconShow bool
---@field IconBlankShow bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonTitleView = LuaClass(UIView, true)

function CommonTitleView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommInforBtn = nil
	--self.IconBlank = nil
	--self.IconTitle = nil
	--self.PanelIcon = nil
	--self.TextSubtitle = nil
	--self.TextTitleName = nil
	--self.AnimUpdateSubtitle = nil
	--self.AnimUpdateTitle = nil
	--self.bTitleShow = nil
	--self.TitleContentText = nil
	--self.TitleColorAndoOpacity = nil
	--self.TitleFont = nil
	--self.TitleMinFontSize = nil
	--self.TitleReductionStep = nil
	--self.TitleTextAdaptation = nil
	--self.TitleTextOverflow = nil
	--self.TitleEnableShowDetailTips = nil
	--self.TileMaxNeedWidth = nil
	--self.bSubTitleShow = nil
	--self.SubTitleContentText = nil
	--self.SubTitleColorAndoOpacity = nil
	--self.SubTitleFont = nil
	--self.SubTitleMinFontSize = nil
	--self.SubTitleReductionStep = nil
	--self.SubTitleTextAdaptation = nil
	--self.SubTitleTextOverflow = nil
	--self.SubTitleEnableShowDetailTips = nil
	--self.SubMaxNeedWidth = nil
	--self.bHpInfoShow = nil
	--self.HelpInfoID = nil
	--self.IconShow = nil
	--self.IconBlankShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonTitleView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommInforBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonTitleView:OnInit()

end

function CommonTitleView:OnDestroy()

end

function CommonTitleView:OnShow()
	
end

function CommonTitleView:OnHide()

end

function CommonTitleView:OnRegisterUIEvent()

end

function CommonTitleView:OnRegisterGameEvent()

end

function CommonTitleView:OnRegisterBinder()

end

function CommonTitleView:SetSubTitleIsVisible(bVisible)
	self.bSubTitleShow = bVisible
	UIUtil.SetIsVisible(self.TextSubtitle, bVisible)
end

function CommonTitleView:SetCommInforBtnIsVisible(bVisible)
	self.bHpInfoShow = bVisible
	UIUtil.SetIsVisible(self.CommInforBtn, bVisible)
end

function CommonTitleView:SetTextTitleName(Text)
	if Text ~= self.TitleContentText then
		self.TitleContentText = Text
		self.TextTitleName:SetText(Text)
		self:PlayAnimation(self.AnimUpdateTitle)
	end
end

function CommonTitleView:SetTextSubtitle(Text)
	if Text ~= self.SubTitleContentText then
		self.SubTitleContentText = Text
		self.TextSubtitle:SetText(Text)
		self:PlayAnimation(self.AnimUpdateSubtitle)
	end
end

function CommonTitleView:SetTitleIcon(IconPath)
	if IconPath ~= nil then
		UIUtil.ImageSetBrushFromAssetPath(self.IconTitle, IconPath)
	end

end
return CommonTitleView