---
--- Author: chaooren
--- DateTime: 2023-03-23 16:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")

---@class SkillJobSkillMonkDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextBoxGathering URichTextBox
---@field RichTextBoxMonkFight URichTextBox
---@field TextGasGathering UFTextBlock
---@field TextMonkFight UFTextBlock
---@field TextName UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillJobSkillMonkDetailsItemView = LuaClass(UIView, true)

function SkillJobSkillMonkDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextBoxGathering = nil
	--self.RichTextBoxMonkFight = nil
	--self.TextGasGathering = nil
	--self.TextMonkFight = nil
	--self.TextName = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillJobSkillMonkDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillJobSkillMonkDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichTextBoxGathering:SetText(LSTR(140022))
	self.RichTextBoxMonkFight:SetText(LSTR(140023))
	self.TextGasGathering:SetText(LSTR(140024))
	self.TextMonkFight:SetText(LSTR(140025))
	self.TextTitle:SetText(LSTR(140026))
end

function SkillJobSkillMonkDetailsItemView:OnDestroy()

end

function SkillJobSkillMonkDetailsItemView:OnShow()

end

function SkillJobSkillMonkDetailsItemView:OnHide()

end

function SkillJobSkillMonkDetailsItemView:OnRegisterUIEvent()

end

function SkillJobSkillMonkDetailsItemView:OnRegisterGameEvent()

end

function SkillJobSkillMonkDetailsItemView:OnRegisterBinder()

end

return SkillJobSkillMonkDetailsItemView