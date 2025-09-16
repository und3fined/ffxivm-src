---
--- Author: henghaoli
--- DateTime: 2024-03-14 10:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CraftingDetailUtil = require("Game/Skill/View/CraftingDetail/Item/CraftingDetailUtil")

---@class SkillArmorerDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field ImgLine02 UFImage
---@field RichText01 URichTextBox
---@field RichText02 URichTextBox
---@field SizeBox1 USizeBox
---@field SizeBox2 USizeBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillArmorerDetailsItemView = LuaClass(UIView, true)

function SkillArmorerDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.ImgLine02 = nil
	--self.RichText01 = nil
	--self.RichText02 = nil
	--self.SizeBox1 = nil
	--self.SizeBox2 = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillArmorerDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillArmorerDetailsItemView:OnInit()
	CraftingDetailUtil.InitBPLocalStr_ArmorerBlacksmith(self, CraftingDetailUtil.EDetailProf.Armorer)
end

function SkillArmorerDetailsItemView:OnDestroy()

end

function SkillArmorerDetailsItemView:OnShow()

end

function SkillArmorerDetailsItemView:OnHide()

end

function SkillArmorerDetailsItemView:OnRegisterUIEvent()

end

function SkillArmorerDetailsItemView:OnRegisterGameEvent()

end

function SkillArmorerDetailsItemView:OnRegisterBinder()

end

return SkillArmorerDetailsItemView