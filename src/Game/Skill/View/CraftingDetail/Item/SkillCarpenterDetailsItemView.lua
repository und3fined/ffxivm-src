---
--- Author: henghaoli
--- DateTime: 2024-01-09 19:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CraftingDetailUtil = require("Game/Skill/View/CraftingDetail/Item/CraftingDetailUtil")

---@class SkillCarpenterDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field ImgLine02 UFImage
---@field ImgLine04 UFImage
---@field RichText02 URichTextBox
---@field RichText03 URichTextBox
---@field RichText04 URichTextBox
---@field RichText04_1 URichTextBox
---@field RichText05 URichTextBox
---@field Scroll UScrollBox
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillCarpenterDetailsItemView = LuaClass(UIView, true)

function SkillCarpenterDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.ImgLine02 = nil
	--self.ImgLine04 = nil
	--self.RichText02 = nil
	--self.RichText03 = nil
	--self.RichText04 = nil
	--self.RichText04_1 = nil
	--self.RichText05 = nil
	--self.Scroll = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillCarpenterDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillCarpenterDetailsItemView:OnInit()
	CraftingDetailUtil.InitBPLocalStr_CarpenterGoldsmith(self, CraftingDetailUtil.EDetailProf.Carpenter)
end

function SkillCarpenterDetailsItemView:OnDestroy()

end

function SkillCarpenterDetailsItemView:OnShow()

end

function SkillCarpenterDetailsItemView:OnHide()

end

function SkillCarpenterDetailsItemView:OnRegisterUIEvent()

end

function SkillCarpenterDetailsItemView:OnRegisterGameEvent()

end

function SkillCarpenterDetailsItemView:OnRegisterBinder()

end

return SkillCarpenterDetailsItemView