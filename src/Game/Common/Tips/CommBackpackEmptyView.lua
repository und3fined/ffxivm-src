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
---@field Img UFImage
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
---@field IsImgeS bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBackpackEmptyView = LuaClass(UIView, true)

function CommBackpackEmptyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Img = nil
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
	--self.IsImgeS = nil
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
	---设置各个状态，IsImageM的优先级大于IsImageS
	---“Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty.UI_Com_Img_Empty'”  Dark
	---"Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty2.UI_Com_Img_Empty2'" Bright
	---"Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty3.UI_Com_Img_Empty3'" DarkM
	---"Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty4.UI_Com_Img_Empty4'" BrightM
	---"Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty5.UI_Com_Img_Empty5'" DarkS
	---"Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty6.UI_Com_Img_Empty6'" BrightS
	--- 设置图片节点
	if not self.IsBrightImg and not self.IsImgeM and not self.IsImgeS then
		UIUtil.ImageSetBrushFromAssetPath(self.Img, "Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty.UI_Com_Img_Empty'")
	elseif self.IsBrightImg and not self.IsImgeM and not self.IsImgeS then
		UIUtil.ImageSetBrushFromAssetPath(self.Img, "Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty2.UI_Com_Img_Empty2'")
	elseif not self.IsBrightImg and self.IsImgeM and not self.IsImgeS then
		UIUtil.ImageSetBrushFromAssetPath(self.Img, "Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty3.UI_Com_Img_Empty3'")
	elseif self.IsBrightImg and self.IsImgeM and not self.IsImgeS then
		UIUtil.ImageSetBrushFromAssetPath(self.Img, "Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty4.UI_Com_Img_Empty4'")
	elseif not self.IsBrightImg and not self.IsImgeM and self.IsImgeS then
		UIUtil.ImageSetBrushFromAssetPath(self.Img, "Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty5.UI_Com_Img_Empty5'")
	elseif self.IsBrightImg and not self.IsImgeM and self.IsImgeS then
		UIUtil.ImageSetBrushFromAssetPath(self.Img, "Texture2D'/Game/UI/Texture/CommPic/UI_Com_Img_Empty6.UI_Com_Img_Empty6'")
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