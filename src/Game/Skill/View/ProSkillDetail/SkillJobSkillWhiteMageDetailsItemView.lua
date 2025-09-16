---
--- Author: chaooren
--- DateTime: 2023-03-23 16:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillJobSkillWhiteMageDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextBox URichTextBox
---@field RichTextBox_54 URichTextBox
---@field TextBloodlily UFTextBlock
---@field TextMysteriousLily UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillJobSkillWhiteMageDetailsItemView = LuaClass(UIView, true)

function SkillJobSkillWhiteMageDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextBox = nil
	--self.RichTextBox_54 = nil
	--self.TextBloodlily = nil
	--self.TextMysteriousLily = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillJobSkillWhiteMageDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillJobSkillWhiteMageDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichTextBox:SetText(LSTR(140044))
	self.RichTextBox_54:SetText(LSTR(140045))
	self.TextBloodlily:SetText(LSTR(140046))
	self.TextMysteriousLily:SetText(LSTR(140047))
	self.TextTitle:SetText(LSTR(140048))
end

function SkillJobSkillWhiteMageDetailsItemView:OnDestroy()

end

function SkillJobSkillWhiteMageDetailsItemView:OnShow()

end

function SkillJobSkillWhiteMageDetailsItemView:OnHide()

end

function SkillJobSkillWhiteMageDetailsItemView:OnRegisterUIEvent()

end

function SkillJobSkillWhiteMageDetailsItemView:OnRegisterGameEvent()

end

function SkillJobSkillWhiteMageDetailsItemView:OnRegisterBinder()

end

return SkillJobSkillWhiteMageDetailsItemView