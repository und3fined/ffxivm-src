---
--- Author: sammrli
--- DateTime: 2025-02-24 14:14
--- Description:邮递员职业解锁提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR

---@class InfoDoubtNulockTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconJob UFImage
---@field IconJobEFF UFImage
---@field ImgColor UFImage
---@field ModelToImage CommonModelToImageView
---@field PopUpBG CommonPopUpBGView
---@field RichTextJobUnlock URichTextBox
---@field RichTextTextQuestionMark URichTextBox
---@field TextHint UFTextBlock
---@field TextJobPostman UFTextBlock
---@field TextQuestionMark UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoDoubtNulockTipsView = LuaClass(UIView, true)

function InfoDoubtNulockTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconJob = nil
	--self.IconJobEFF = nil
	--self.ImgColor = nil
	--self.ModelToImage = nil
	--self.PopUpBG = nil
	--self.RichTextJobUnlock = nil
	--self.RichTextTextQuestionMark = nil
	--self.TextHint = nil
	--self.TextJobPostman = nil
	--self.TextQuestionMark = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoDoubtNulockTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ModelToImage)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoDoubtNulockTipsView:OnInit()

end

function InfoDoubtNulockTipsView:OnDestroy()

end

function InfoDoubtNulockTipsView:OnShow()
	self.TextJobPostman:SetText(LSTR(930005)) --930005("邮递员")
	self.TextQuestionMark:SetText("?")
	self.RichTextJobUnlock:SetText(LSTR(930006)) --930006("解锁职业")
	self.RichTextTextQuestionMark:SetText("?")
	self.TextHint:SetText(LSTR(10056)) --10056("点击空白处关闭")
end

function InfoDoubtNulockTipsView:OnHide()

end

function InfoDoubtNulockTipsView:OnRegisterUIEvent()

end

function InfoDoubtNulockTipsView:OnRegisterGameEvent()

end

function InfoDoubtNulockTipsView:OnRegisterBinder()

end

return InfoDoubtNulockTipsView