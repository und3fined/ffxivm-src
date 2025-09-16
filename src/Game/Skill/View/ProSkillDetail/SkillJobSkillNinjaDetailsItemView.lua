---
--- Author: chaooren
--- DateTime: 2024-03-04 18:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")

---@class SkillJobSkillNinjaDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconSkill UFImage
---@field Img_Add UFImage
---@field RichTextNinja1 URichTextBox
---@field RichTextNinja2 URichTextBox
---@field RichTextSword2 URichTextBox
---@field TextName UFTextBlock
---@field TextNinja1 UFTextBlock
---@field TextNinja2 UFTextBlock
---@field TextSword UFTextBlock
---@field TextSword1 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillJobSkillNinjaDetailsItemView = LuaClass(UIView, true)

function SkillJobSkillNinjaDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconSkill = nil
	--self.Img_Add = nil
	--self.RichTextNinja1 = nil
	--self.RichTextNinja2 = nil
	--self.RichTextSword2 = nil
	--self.TextName = nil
	--self.TextNinja1 = nil
	--self.TextNinja2 = nil
	--self.TextSword = nil
	--self.TextSword1 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillJobSkillNinjaDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillJobSkillNinjaDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichTextNinja1:SetText(LSTR(140027))
	self.RichTextNinja2:SetText(LSTR(140028))
	self.RichTextSword2:SetText(LSTR(140029))
	self.TextNinja1:SetText(LSTR(140030))
	self.TextNinja2:SetText(LSTR(140031))
	self.TextSword:SetText(LSTR(140032))
	self.TextSword1:SetText(LSTR(140033))
	self.TextTitle:SetText(LSTR(140034))
end

function SkillJobSkillNinjaDetailsItemView:OnDestroy()

end

function SkillJobSkillNinjaDetailsItemView:OnShow()
	local AttrCom = MajorUtil.GetMajorAttributeComponent()
	if AttrCom then
		self.TextName:SetText(AttrCom.ActorName)
	end
end

function SkillJobSkillNinjaDetailsItemView:OnHide()

end

function SkillJobSkillNinjaDetailsItemView:OnRegisterUIEvent()

end

function SkillJobSkillNinjaDetailsItemView:OnRegisterGameEvent()

end

function SkillJobSkillNinjaDetailsItemView:OnRegisterBinder()

end

return SkillJobSkillNinjaDetailsItemView