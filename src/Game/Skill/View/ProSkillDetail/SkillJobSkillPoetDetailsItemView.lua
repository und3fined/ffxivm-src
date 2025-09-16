---
--- Author: chaooren
--- DateTime: 2023-03-23 16:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillJobSkillPoetDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextBox01 URichTextBox
---@field RichTextBox02 URichTextBox
---@field RichTextBox03 URichTextBox
---@field RichTextBox04 URichTextBox
---@field TextTitle UFTextBlock
---@field TextTitle_1 UFTextBlock
---@field TextTitle_2 UFTextBlock
---@field TextTitle_3 UFTextBlock
---@field TextTitle_4 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillJobSkillPoetDetailsItemView = LuaClass(UIView, true)

function SkillJobSkillPoetDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextBox01 = nil
	--self.RichTextBox02 = nil
	--self.RichTextBox03 = nil
	--self.RichTextBox04 = nil
	--self.TextTitle = nil
	--self.TextTitle_1 = nil
	--self.TextTitle_2 = nil
	--self.TextTitle_3 = nil
	--self.TextTitle_4 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillJobSkillPoetDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillJobSkillPoetDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichTextBox01:SetText(LSTR(140035))
	self.RichTextBox02:SetText(LSTR(140036))
	self.RichTextBox03:SetText(LSTR(140037))
	self.RichTextBox04:SetText(LSTR(140038))
	self.TextTitle:SetText(LSTR(140039))
	self.TextTitle_1:SetText(LSTR(140040))
	self.TextTitle_2:SetText(LSTR(140041))
	self.TextTitle_3:SetText(LSTR(140042))
	self.TextTitle_4:SetText(LSTR(140043))
end

function SkillJobSkillPoetDetailsItemView:OnDestroy()

end

function SkillJobSkillPoetDetailsItemView:OnShow()

end

function SkillJobSkillPoetDetailsItemView:OnHide()

end

function SkillJobSkillPoetDetailsItemView:OnRegisterUIEvent()

end

function SkillJobSkillPoetDetailsItemView:OnRegisterGameEvent()

end

function SkillJobSkillPoetDetailsItemView:OnRegisterBinder()

end

return SkillJobSkillPoetDetailsItemView