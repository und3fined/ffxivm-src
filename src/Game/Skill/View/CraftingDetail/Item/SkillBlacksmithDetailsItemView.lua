---
--- Author: henghaoli
--- DateTime: 2024-03-14 10:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CraftingDetailUtil = require("Game/Skill/View/CraftingDetail/Item/CraftingDetailUtil")

---@class SkillBlacksmithDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field ImgLine02 UFImage
---@field RichText01 URichTextBox
---@field RichText02 URichTextBox
---@field SizeBox1 USizeBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillBlacksmithDetailsItemView = LuaClass(UIView, true)

function SkillBlacksmithDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.ImgLine02 = nil
	--self.RichText01 = nil
	--self.RichText02 = nil
	--self.SizeBox1 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillBlacksmithDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillBlacksmithDetailsItemView:OnInit()
	CraftingDetailUtil.InitBPLocalStr_ArmorerBlacksmith(self, CraftingDetailUtil.EDetailProf.Blacksmith)
end

function SkillBlacksmithDetailsItemView:OnDestroy()

end

function SkillBlacksmithDetailsItemView:OnShow()

end

function SkillBlacksmithDetailsItemView:OnHide()

end

function SkillBlacksmithDetailsItemView:OnRegisterUIEvent()

end

function SkillBlacksmithDetailsItemView:OnRegisterGameEvent()

end

function SkillBlacksmithDetailsItemView:OnRegisterBinder()

end

return SkillBlacksmithDetailsItemView