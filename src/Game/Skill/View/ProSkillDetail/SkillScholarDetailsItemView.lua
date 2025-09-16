---
--- Author: chaooren
--- DateTime: 2023-06-13 15:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillScholarDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichText01 URichTextBox
---@field RichText02 URichTextBox
---@field RichTextBox03 URichTextBox
---@field TextContract UFTextBlock
---@field TextEther UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillScholarDetailsItemView = LuaClass(UIView, true)

function SkillScholarDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichText01 = nil
	--self.RichText02 = nil
	--self.RichTextBox03 = nil
	--self.TextContract = nil
	--self.TextEther = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillScholarDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillScholarDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichText01:SetText(LSTR(140049))
	self.RichText02:SetText(LSTR(140050))
	self.RichTextBox03:SetText(LSTR(140051))
	self.TextContract:SetText(LSTR(140052))
	self.TextEther:SetText(LSTR(140053))
	self.TextTitle:SetText(LSTR(140054))
end

function SkillScholarDetailsItemView:OnDestroy()

end

function SkillScholarDetailsItemView:OnShow()

end

function SkillScholarDetailsItemView:OnHide()

end

function SkillScholarDetailsItemView:OnRegisterUIEvent()

end

function SkillScholarDetailsItemView:OnRegisterGameEvent()

end

function SkillScholarDetailsItemView:OnRegisterBinder()

end

return SkillScholarDetailsItemView