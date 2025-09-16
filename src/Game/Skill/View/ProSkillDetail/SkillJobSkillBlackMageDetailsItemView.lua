---
--- Author: chaooren
--- DateTime: 2023-03-23 16:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillJobSkillBlackMageDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextBoxHeavenlyLanguage URichTextBox
---@field RichTextBoxObsceneTurbidity URichTextBox
---@field RichTextBoxSpiritualIce URichTextBox
---@field RichTextBoxStarFire URichTextBox
---@field TextHeavenlyLanguage UFTextBlock
---@field TextObsceneTurbidity UFTextBlock
---@field TextSpiritualIce UFTextBlock
---@field TextStarFire UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillJobSkillBlackMageDetailsItemView = LuaClass(UIView, true)

function SkillJobSkillBlackMageDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextBoxHeavenlyLanguage = nil
	--self.RichTextBoxObsceneTurbidity = nil
	--self.RichTextBoxSpiritualIce = nil
	--self.RichTextBoxStarFire = nil
	--self.TextHeavenlyLanguage = nil
	--self.TextObsceneTurbidity = nil
	--self.TextSpiritualIce = nil
	--self.TextStarFire = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillJobSkillBlackMageDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillJobSkillBlackMageDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichTextBoxHeavenlyLanguage:SetText(LSTR(140001))
	self.RichTextBoxObsceneTurbidity:SetText(LSTR(140002))
	self.RichTextBoxSpiritualIce:SetText(LSTR(140003))
	self.RichTextBoxStarFire:SetText(LSTR(140004))
	self.TextHeavenlyLanguage:SetText(LSTR(140005))
	self.TextObsceneTurbidity:SetText(LSTR(140006))
	self.TextSpiritualIce:SetText(LSTR(140007))
	self.TextStarFire:SetText(LSTR(140008))
	self.TextTitle:SetText(LSTR(140009))
end

function SkillJobSkillBlackMageDetailsItemView:OnDestroy()

end

function SkillJobSkillBlackMageDetailsItemView:OnShow()

end

function SkillJobSkillBlackMageDetailsItemView:OnHide()

end

function SkillJobSkillBlackMageDetailsItemView:OnRegisterUIEvent()

end

function SkillJobSkillBlackMageDetailsItemView:OnRegisterGameEvent()

end

function SkillJobSkillBlackMageDetailsItemView:OnRegisterBinder()

end

return SkillJobSkillBlackMageDetailsItemView