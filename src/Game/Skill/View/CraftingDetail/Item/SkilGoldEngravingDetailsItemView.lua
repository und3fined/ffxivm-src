---
--- Author: henghaoli
--- DateTime: 2024-03-14 10:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CraftingDetailUtil = require("Game/Skill/View/CraftingDetail/Item/CraftingDetailUtil")

---@class SkilGoldEngravingDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field RichText01 URichTextBox
---@field RichText02 URichTextBox
---@field RichText03 URichTextBox
---@field RichText04 URichTextBox
---@field Scroll UScrollBox
---@field TextSkill2 UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkilGoldEngravingDetailsItemView = LuaClass(UIView, true)

function SkilGoldEngravingDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.RichText01 = nil
	--self.RichText02 = nil
	--self.RichText03 = nil
	--self.RichText04 = nil
	--self.Scroll = nil
	--self.TextSkill2 = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkilGoldEngravingDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkilGoldEngravingDetailsItemView:OnInit()
	CraftingDetailUtil.InitBPLocalStr_CarpenterGoldsmith(self, CraftingDetailUtil.EDetailProf.Goldsmith)
end

function SkilGoldEngravingDetailsItemView:OnDestroy()

end

function SkilGoldEngravingDetailsItemView:OnShow()

end

function SkilGoldEngravingDetailsItemView:OnHide()

end

function SkilGoldEngravingDetailsItemView:OnRegisterUIEvent()

end

function SkilGoldEngravingDetailsItemView:OnRegisterGameEvent()

end

function SkilGoldEngravingDetailsItemView:OnRegisterBinder()

end

return SkilGoldEngravingDetailsItemView