---
--- Author: Administrator
--- DateTime: 2025-03-14 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommSidebarFrameBaseView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommTitleWidget CommonTitle_UIBP_C
---@field TitleShow bool
---@field TitleContentText text
---@field TitleColorAndOpacity SlateColor
---@field TitleFont SlateFontInfo
---@field TitleMinFontSize int
---@field TitleReductionStep int
---@field TitleTextAdaptation ETextAdaptation
---@field TitleTextOverflow ETextOverflow
---@field TitleEnableShowDetailTips bool
---@field TitleMaxNeedWidth float
---@field SubTitleShow bool
---@field SubTitleContentText text
---@field SubTitleColorAndOpacity SlateColor
---@field SubTitleFont SlateFontInfo
---@field SubTitleMinFontSize int
---@field SubTitleReductionStep int
---@field SubTitleTextAdaptation ETextAdaptation
---@field SubTitleTextOverflow ETextOverflow
---@field SubTitleEnableShowDetailTips bool
---@field SubMaxNeedWidth float
---@field HpInfoShow bool
---@field HelpInfoID int
---@field IsHorizontalTitleShow bool
---@field TitleHorizontalWidget FHorizontalBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSidebarFrameBaseView = LuaClass(UIView, true)

function CommSidebarFrameBaseView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommTitleWidget = nil
	--self.TitleShow = nil
	--self.TitleContentText = nil
	--self.TitleColorAndOpacity = nil
	--self.TitleFont = nil
	--self.TitleMinFontSize = nil
	--self.TitleReductionStep = nil
	--self.TitleTextAdaptation = nil
	--self.TitleTextOverflow = nil
	--self.TitleEnableShowDetailTips = nil
	--self.TitleMaxNeedWidth = nil
	--self.SubTitleShow = nil
	--self.SubTitleContentText = nil
	--self.SubTitleColorAndOpacity = nil
	--self.SubTitleFont = nil
	--self.SubTitleMinFontSize = nil
	--self.SubTitleReductionStep = nil
	--self.SubTitleTextAdaptation = nil
	--self.SubTitleTextOverflow = nil
	--self.SubTitleEnableShowDetailTips = nil
	--self.SubMaxNeedWidth = nil
	--self.HpInfoShow = nil
	--self.HelpInfoID = nil
	--self.IsHorizontalTitleShow = nil
	--self.TitleHorizontalWidget = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSidebarFrameBaseView:SetTitleText(Text)
	self.CommTitleWidget:SetTextTitleName(Text)
end

function CommSidebarFrameBaseView:SetSubTitleIsVisible(IsVisible)
	self.CommTitleWidget:SetSubTitleIsVisible(IsVisible)
end

function CommSidebarFrameBaseView:SetSubTitleText(Text)
	self.CommTitleWidget:SetTextSubtitle(Text)
end

function CommSidebarFrameBaseView:SetHelpInfoID(ID)
	if not ID then
		self.CommTitleWidget:SetCommInforBtnIsVisible(false)
	else
		self.CommTitleWidget:SetCommInforBtnIsVisible(true)
		self.CommTitleWidget.CommInforBtn.HelpInfoID = ID
	end
end

return CommSidebarFrameBaseView