---
--- Author: chaooren
--- DateTime: 2023-06-13 15:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillWarriorDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichText01 URichTextBox
---@field RichText02 URichTextBox
---@field RichText03 URichTextBox
---@field TextTitle UFTextBlock
---@field TextWarrior UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillWarriorDetailsItemView = LuaClass(UIView, true)

function SkillWarriorDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichText01 = nil
	--self.RichText02 = nil
	--self.RichText03 = nil
	--self.TextTitle = nil
	--self.TextWarrior = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillWarriorDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillWarriorDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichText01:SetText(LSTR(140058))
	self.RichText02:SetText(LSTR(140059))
	self.RichText03:SetText(LSTR(140060))
	self.TextWarrior:SetText(LSTR(140061))
	self.TextTitle:SetText(LSTR(140081))
end

function SkillWarriorDetailsItemView:OnDestroy()

end

function SkillWarriorDetailsItemView:OnShow()

end

function SkillWarriorDetailsItemView:OnHide()

end

function SkillWarriorDetailsItemView:OnRegisterUIEvent()

end

function SkillWarriorDetailsItemView:OnRegisterGameEvent()

end

function SkillWarriorDetailsItemView:OnRegisterBinder()

end

return SkillWarriorDetailsItemView