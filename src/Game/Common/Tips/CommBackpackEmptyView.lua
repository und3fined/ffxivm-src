---
--- Author: anypkvcai
--- DateTime: 2021-08-17 10:57
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
---@class CommBackpackEmptyView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgBright UFImage
---@field ImgBrightM UFImage
---@field ImgDark UFImage
---@field ImgDarkM UFImage
---@field NonePanel UFCanvasPanel
---@field PanelBtn UFCanvasPanel
---@field PanelBtnBright UFCanvasPanel
---@field PanelBtnDark UFCanvasPanel
---@field RichTextBtnBright URichTextBox
---@field RichTextBtnDark URichTextBox
---@field RichTextNone URichTextBox
---@field RichTextNoneBright URichTextBox
---@field AnimInfo UWidgetAnimation
---@field TextTips text
---@field IsBrightImg bool
---@field IsImgeM bool
---@field IsBrightText bool
---@field IsBtn bool
---@field IsBirghtBtn bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBackpackEmptyView = LuaClass(UIView, true)

function CommBackpackEmptyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgBright = nil
	--self.ImgBrightM = nil
	--self.ImgDark = nil
	--self.ImgDarkM = nil
	--self.NonePanel = nil
	--self.PanelBtn = nil
	--self.PanelBtnBright = nil
	--self.PanelBtnDark = nil
	--self.RichTextBtnBright = nil
	--self.RichTextBtnDark = nil
	--self.RichTextNone = nil
	--self.RichTextNoneBright = nil
	--self.AnimInfo = nil
	--self.TextTips = nil
	--self.IsBrightImg = nil
	--self.IsImgeM = nil
	--self.IsBrightText = nil
	--self.IsBtn = nil
	--self.IsBirghtBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBackpackEmptyView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBackpackEmptyView:OnInit()

end

function CommBackpackEmptyView:OnDestroy()

end

function CommBackpackEmptyView:OnShow()
	---设置各个状态
	--- 设置亮图标可见，暗图标不可见
	if self.IsBrightImg then
		---选择与设置大小相符的图标显示
		if self.IsImgeM then
			UIUtil.SetIsVisible(self.ImgBright, false)
			UIUtil.SetIsVisible(self.ImgBrightM, true, false)
		else
			UIUtil.SetIsVisible(self.ImgBright, true, false)
			UIUtil.SetIsVisible(self.ImgBrightM, false)
		end
		UIUtil.SetIsVisible(self.ImgDark, false)
		UIUtil.SetIsVisible(self.ImgDarkM, false)
	--- 设置暗图标可见，亮图标不可见
	else
		---选择与设置大小相符的图标显示
		if self.IsImgeM then
			UIUtil.SetIsVisible(self.ImgDark, false)
			UIUtil.SetIsVisible(self.ImgDarkM, true, false)
		else
			UIUtil.SetIsVisible(self.ImgDark, true, false)
			UIUtil.SetIsVisible(self.ImgDarkM, false)
		end
		UIUtil.SetIsVisible(self.ImgBright, false)
		UIUtil.SetIsVisible(self.ImgBrightM, false)
	end
	---设置暗、亮文本的可见性
	if self.IsBrightText then
		UIUtil.SetIsVisible(self.RichTextNoneBright, true , false)
		UIUtil.SetIsVisible(self.RichTextNone, false)
	else
		UIUtil.SetIsVisible(self.RichTextNone, true , false)
		UIUtil.SetIsVisible(self.RichTextNoneBright, false)
	end
	if self.AnimInfo ~= nil then
		self:PlayAnimation(self.AnimInfo)
	end

	self:ShowPanelBtn(self.IsBtn)
end

function CommBackpackEmptyView:OnHide()

end

function CommBackpackEmptyView:OnRegisterUIEvent()

end

function CommBackpackEmptyView:OnRegisterGameEvent()

end

function CommBackpackEmptyView:OnRegisterBinder()

end

function CommBackpackEmptyView:GetContentText()
	if self.IsBrightText then
		return self.RichTextNoneBright
	else
		return self.RichTextNone
	end
end

function CommBackpackEmptyView:SetTipsContent(Text)
	if self.IsBrightText then
		self.RichTextNoneBright:SetText(Text)
	else
		self.RichTextNone:SetText(Text)
	end
end

function CommBackpackEmptyView:SetBtnText(Text)
	if self.IsBirghtBtn then
		self.RichTextBtnBright:SetText(Text)
	else
		self.RichTextBtnDark:SetText(Text)
	end
end

function CommBackpackEmptyView:ShowPanelBtn(bFlag)
    UIUtil.SetIsVisible(self.PanelBtn, bFlag)
	if bFlag then
		if self.IsBirghtBtn then
			UIUtil.SetIsVisible(self.PanelBtnBright, true)
			UIUtil.SetIsVisible(self.PanelBtnDark, false)
		else
			UIUtil.SetIsVisible(self.PanelBtnBright, false)
			UIUtil.SetIsVisible(self.PanelBtnDark, true)
		end
	end
end

return CommBackpackEmptyView