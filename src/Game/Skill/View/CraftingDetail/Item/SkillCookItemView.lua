---
--- Author: henghaoli
--- DateTime: 2024-03-14 10:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class SkillCookItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon01 UFImage
---@field Icon02 UFImage
---@field Icon03 UFImage
---@field Icon04 UFImage
---@field Icon05 UFImage
---@field Icon06 UFImage
---@field Icon07 UFImage
---@field ImgLine02 UFImage
---@field RichText01 URichTextBox
---@field RichText02 URichTextBox
---@field RichText02_1 URichTextBox
---@field RichText03 URichTextBox
---@field Scroll UScrollBox
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field Text04 UFTextBlock
---@field Text05 UFTextBlock
---@field Text06 UFTextBlock
---@field Text07 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillCookItemView = LuaClass(UIView, true)

function SkillCookItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon01 = nil
	--self.Icon02 = nil
	--self.Icon03 = nil
	--self.Icon04 = nil
	--self.Icon05 = nil
	--self.Icon06 = nil
	--self.Icon07 = nil
	--self.ImgLine02 = nil
	--self.RichText01 = nil
	--self.RichText02 = nil
	--self.RichText02_1 = nil
	--self.RichText03 = nil
	--self.Scroll = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.Text04 = nil
	--self.Text05 = nil
	--self.Text06 = nil
	--self.Text07 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillCookItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillCookItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichText01:SetText(LSTR(150042))
	self.RichText02:SetText(LSTR(150043))
	self.RichText02_1:SetText(LSTR(150044))
	self.Text01:SetText(LSTR(150045))
	self.Text02:SetText(LSTR(150046))
	self.Text03:SetText(LSTR(150047))
	self.Text04:SetText(LSTR(150048))
	self.Text05:SetText(LSTR(150049))
	self.Text06:SetText(LSTR(150050))
	self.Text07:SetText(LSTR(150051))
	self.TextTitle:SetText(LSTR(150052))
end

function SkillCookItemView:OnDestroy()

end

function SkillCookItemView:OnShow()

end

function SkillCookItemView:OnHide()

end

function SkillCookItemView:OnRegisterUIEvent()

end

function SkillCookItemView:OnRegisterGameEvent()

end

function SkillCookItemView:OnRegisterBinder()

end

return SkillCookItemView