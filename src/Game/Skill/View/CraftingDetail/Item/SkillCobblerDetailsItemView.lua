---
--- Author: henghaoli
--- DateTime: 2024-03-14 10:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CraftingDetailUtil = require("Game/Skill/View/CraftingDetail/Item/CraftingDetailUtil")

---@class SkillCobblerDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon01 UFImage
---@field Icon02 UFImage
---@field Icon03 UFImage
---@field Icon04 UFImage
---@field ImgBlacksmith1 UFImage
---@field ImgLine UFImage
---@field ImgLine02 UFImage
---@field RichText01 URichTextBox
---@field RichText02 URichTextBox
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
local SkillCobblerDetailsItemView = LuaClass(UIView, true)

function SkillCobblerDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon01 = nil
	--self.Icon02 = nil
	--self.Icon03 = nil
	--self.Icon04 = nil
	--self.ImgBlacksmith1 = nil
	--self.ImgLine = nil
	--self.ImgLine02 = nil
	--self.RichText01 = nil
	--self.RichText02 = nil
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

function SkillCobblerDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillCobblerDetailsItemView:OnInit()
	CraftingDetailUtil.InitBPLocalStr_WeaverLeather(self, CraftingDetailUtil.EDetailProf.Leather)
end

function SkillCobblerDetailsItemView:OnDestroy()

end

function SkillCobblerDetailsItemView:OnShow()

end

function SkillCobblerDetailsItemView:OnHide()

end

function SkillCobblerDetailsItemView:OnRegisterUIEvent()

end

function SkillCobblerDetailsItemView:OnRegisterGameEvent()

end

function SkillCobblerDetailsItemView:OnRegisterBinder()

end

return SkillCobblerDetailsItemView