---
--- Author: ashyuan
--- DateTime: 2024-05-07 15:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

---@class CommTextTipsBigStrongItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelTipsPurple UFCanvasPanel
---@field PanelTipsYellow UFCanvasPanel
---@field RichTextBigTetlePurple URichTextBox
---@field RichTextBigTetleYellow URichTextBox
---@field ScaleBox_0 UScaleBox
---@field TextSubTitle1 UFTextBlock
---@field DMI_Text MaterialInstanceDynamic
---@field Title text
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommTextTipsBigStrongItemView = LuaClass(InfoTipsBaseView, true)

function CommTextTipsBigStrongItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelTipsPurple = nil
	--self.PanelTipsYellow = nil
	--self.RichTextBigTetlePurple = nil
	--self.RichTextBigTetleYellow = nil
	--self.ScaleBox_0 = nil
	--self.TextSubTitle1 = nil
	--self.DMI_Text = nil
	--self.Title = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommTextTipsBigStrongItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommTextTipsBigStrongItemView:OnInit()

end

function CommTextTipsBigStrongItemView:OnDestroy()

end

function CommTextTipsBigStrongItemView:OnShow()
	self.Super:OnShow()

	local Content = self.Params.Content

	if self.Params.Result then
		UIUtil.SetIsVisible(self.PanelTipsYellow, true)
		UIUtil.SetIsVisible(self.PanelTipsPurple, false)
		self.RichTextBigTetleYellow:SetText(Content)
	else
		UIUtil.SetIsVisible(self.PanelTipsYellow, false)
		UIUtil.SetIsVisible(self.PanelTipsPurple, true)
		self.RichTextBigTetlePurple:SetText(Content)
	end
	
	UIUtil.SetIsVisible(self.TextSubTitle1, false)
end

function CommTextTipsBigStrongItemView:OnHide()

end

function CommTextTipsBigStrongItemView:OnRegisterUIEvent()

end

function CommTextTipsBigStrongItemView:OnRegisterGameEvent()

end

function CommTextTipsBigStrongItemView:OnRegisterBinder()

end

return CommTextTipsBigStrongItemView