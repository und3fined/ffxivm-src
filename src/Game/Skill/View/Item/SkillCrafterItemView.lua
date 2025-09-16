---
--- Author: henghaoli
--- DateTime: 2024-11-12 14:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class SkillCrafterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FHorizontalCD UFHorizontalBox
---@field TextCD UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillCrafterItemView = LuaClass(UIView, true)

function SkillCrafterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FHorizontalCD = nil
	--self.TextCD = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillCrafterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillCrafterItemView:OnInit()

end

function SkillCrafterItemView:OnDestroy()

end

function SkillCrafterItemView:OnShow()
	local Params = self.Params
	if not Params then
		return
	end
	local Data = Params.Data
	if not Data then
		return
	end

	local Title = Data.Title .. ":" or ""
	self.TextCD:SetText(Title)

	local Text = self.Params.Data.Text or ""
	self.TextTime:SetText(Text)
end

function SkillCrafterItemView:OnHide()

end

function SkillCrafterItemView:OnRegisterUIEvent()

end

function SkillCrafterItemView:OnRegisterGameEvent()

end

function SkillCrafterItemView:OnRegisterBinder()

end

return SkillCrafterItemView