---
--- Author: chriswang
--- DateTime: 2023-08-31 17:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CrafterSkillTipsTextItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextName URichTextBox
---@field TextBurial1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterSkillTipsTextItemView = LuaClass(UIView, true)

function CrafterSkillTipsTextItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextName = nil
	--self.TextBurial1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterSkillTipsTextItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterSkillTipsTextItemView:OnInit()

end

function CrafterSkillTipsTextItemView:OnDestroy()

end

function CrafterSkillTipsTextItemView:OnShow()
	if self.Params and self.Params.Data then
		local Title = self.Params.Data.Title or ""
		self.RichTextName:SetText(Title)

		local Text = self.Params.Data.Text or ""
		self.TextBurial1:SetText(Text)
	end

end

function CrafterSkillTipsTextItemView:OnHide()

end

function CrafterSkillTipsTextItemView:OnRegisterUIEvent()

end

function CrafterSkillTipsTextItemView:OnRegisterGameEvent()

end

function CrafterSkillTipsTextItemView:OnRegisterBinder()

end

return CrafterSkillTipsTextItemView