---
--- Author: henghaoli
--- DateTime: 2024-06-21 16:17
--- Description:
---

local LuaClass = require("Core/LuaClass")
local SkillBtnItemView = require("Game/Skill/View/SkillBtnItemView")

---@class SkillExpandWinBtnItemView : SkillBtnItemView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_57 UFCanvasPanel
---@field FImg_Mask UFImage
---@field FImg_Select UFImage
---@field FImg_Slot UFImage
---@field Icon_Skill UFImage
---@field AnimSelectedIn UWidgetAnimation
---@field AnimSelectedOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field Super SkillBtnItemView
local SkillExpandWinBtnItemView = LuaClass(SkillBtnItemView, true)

function SkillExpandWinBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_57 = nil
	--self.FImg_Mask = nil
	--self.FImg_Select = nil
	--self.FImg_Slot = nil
	--self.Icon_Skill = nil
	--self.AnimSelectedIn = nil
	--self.AnimSelectedOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillExpandWinBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillExpandWinBtnItemView:OnInit()
	self.Super:OnInit()
end

function SkillExpandWinBtnItemView:OnDestroy()
	self.Super:OnDestroy()
end

function SkillExpandWinBtnItemView:OnShow()
	self.Super:OnShow()
	self:OnSelectChanged(false)
end

function SkillExpandWinBtnItemView:OnHide()
	self.Super:OnHide()
end

function SkillExpandWinBtnItemView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()
end

function SkillExpandWinBtnItemView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

function SkillExpandWinBtnItemView:OnRegisterBinder()
	self.Super:OnRegisterBinder()
end

return SkillExpandWinBtnItemView