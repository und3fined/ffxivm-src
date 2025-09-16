---
--- Author: chaooren
--- DateTime: 2023-03-23 16:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class SkillJobSkillEragonDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextBoxChangChun URichTextBox
---@field RichTextBoxDragonEye URichTextBox
---@field RichTextBoxRedLotus URichTextBox
---@field TextChangChun UFTextBlock
---@field TextDragonEye UFTextBlock
---@field TextRedLotus UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillJobSkillEragonDetailsItemView = LuaClass(UIView, true)

function SkillJobSkillEragonDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextBoxChangChun = nil
	--self.RichTextBoxDragonEye = nil
	--self.RichTextBoxRedLotus = nil
	--self.TextChangChun = nil
	--self.TextDragonEye = nil
	--self.TextRedLotus = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillJobSkillEragonDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillJobSkillEragonDetailsItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichTextBoxChangChun:SetText(LSTR(140010))
	self.RichTextBoxDragonEye:SetText(LSTR(140011))
	self.RichTextBoxRedLotus:SetText(LSTR(140012))
	self.TextChangChun:SetText(LSTR(140013))
	self.TextDragonEye:SetText(LSTR(140014))
	self.TextRedLotus:SetText(LSTR(140015))
	self.TextTitle:SetText(LSTR(140016))
end

function SkillJobSkillEragonDetailsItemView:OnDestroy()

end

function SkillJobSkillEragonDetailsItemView:OnShow()

end

function SkillJobSkillEragonDetailsItemView:OnHide()

end

function SkillJobSkillEragonDetailsItemView:OnRegisterUIEvent()

end

function SkillJobSkillEragonDetailsItemView:OnRegisterGameEvent()

end

function SkillJobSkillEragonDetailsItemView:OnRegisterBinder()

end

return SkillJobSkillEragonDetailsItemView