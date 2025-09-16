---
--- Author: henghaoli
--- DateTime: 2024-03-14 10:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class SkillAlchemistItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field ImgLine02 UFImage
---@field RichText01 URichTextBox
---@field RichText02 URichTextBox
---@field Scroll UScrollBox
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillAlchemistItemView = LuaClass(UIView, true)

function SkillAlchemistItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.ImgLine02 = nil
	--self.RichText01 = nil
	--self.RichText02 = nil
	--self.Scroll = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillAlchemistItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillAlchemistItemView:OnInit()
	local LSTR = _G.LSTR
	self.RichText01:SetText(LSTR(150014))
	self.RichText02:SetText(LSTR(150015))
	self.TextTitle:SetText(LSTR(150016))
end

function SkillAlchemistItemView:OnDestroy()

end

function SkillAlchemistItemView:OnShow()

end

function SkillAlchemistItemView:OnHide()

end

function SkillAlchemistItemView:OnRegisterUIEvent()

end

function SkillAlchemistItemView:OnRegisterGameEvent()

end

function SkillAlchemistItemView:OnRegisterBinder()

end

return SkillAlchemistItemView