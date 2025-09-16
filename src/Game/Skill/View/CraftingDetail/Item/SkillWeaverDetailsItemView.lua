---
--- Author: henghaoli
--- DateTime: 2024-03-28 20:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CraftingDetailUtil = require("Game/Skill/View/CraftingDetail/Item/CraftingDetailUtil")

---@class SkillWeaverDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon01 UFImage
---@field Icon02 UFImage
---@field Icon03 UFImage
---@field Icon04 UFImage
---@field ImgBlacksmith1 UFImage
---@field RichText01 URichTextBox
---@field RichText03 URichTextBox
---@field SizeBox1 USizeBox
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field Text04 UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillWeaverDetailsItemView = LuaClass(UIView, true)

function SkillWeaverDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon01 = nil
	--self.Icon02 = nil
	--self.Icon03 = nil
	--self.Icon04 = nil
	--self.ImgBlacksmith1 = nil
	--self.RichText01 = nil
	--self.RichText03 = nil
	--self.SizeBox1 = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.Text04 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillWeaverDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillWeaverDetailsItemView:OnInit()
	CraftingDetailUtil.InitBPLocalStr_WeaverLeather(self, CraftingDetailUtil.EDetailProf.Weaver)
end

function SkillWeaverDetailsItemView:OnDestroy()

end

function SkillWeaverDetailsItemView:OnShow()

end

function SkillWeaverDetailsItemView:OnHide()

end

function SkillWeaverDetailsItemView:OnRegisterUIEvent()

end

function SkillWeaverDetailsItemView:OnRegisterGameEvent()

end

function SkillWeaverDetailsItemView:OnRegisterBinder()

end

return SkillWeaverDetailsItemView