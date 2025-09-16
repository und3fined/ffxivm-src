---
--- Author: chaooren
--- DateTime: 2023-03-22 17:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillJobSkillKnightDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextBox_0 URichTextBox
---@field RichTextBox_1 URichTextBox
---@field RichTextBox_2 URichTextBox
---@field RichTextBox_3 URichTextBox
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillJobSkillKnightDetailsItemView = LuaClass(UIView, true)

function SkillJobSkillKnightDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextBox_0 = nil
	--self.RichTextBox_1 = nil
	--self.RichTextBox_2 = nil
	--self.RichTextBox_3 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillJobSkillKnightDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillJobSkillKnightDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichTextBox_0:SetText(LSTR(140017))
	self.RichTextBox_1:SetText(LSTR(140018))
	self.RichTextBox_2:SetText(LSTR(140019))
	self.RichTextBox_3:SetText(LSTR(140020))
	self.TextTitle:SetText(LSTR(140021))
end

function SkillJobSkillKnightDetailsItemView:OnDestroy()

end

function SkillJobSkillKnightDetailsItemView:OnShow()

end

function SkillJobSkillKnightDetailsItemView:OnHide()

end

function SkillJobSkillKnightDetailsItemView:OnRegisterUIEvent()

end

function SkillJobSkillKnightDetailsItemView:OnRegisterGameEvent()

end

function SkillJobSkillKnightDetailsItemView:OnRegisterBinder()

end

return SkillJobSkillKnightDetailsItemView