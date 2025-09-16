---
--- Author: henghaoli
--- DateTime: 2024-06-21 16:18
--- Description:
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

---@class SkillUltimateAbilityItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconUltimateAbility1 UFImage
---@field IconUltimateAbility2 UFImage
---@field IconUltimateAbility3 UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillUltimateAbilityItemView = LuaClass(UIView, true)

function SkillUltimateAbilityItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconUltimateAbility1 = nil
	--self.IconUltimateAbility2 = nil
	--self.IconUltimateAbility3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillUltimateAbilityItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillUltimateAbilityItemView:OnInit()

end

function SkillUltimateAbilityItemView:OnDestroy()

end

function SkillUltimateAbilityItemView:OnShow()
	-- 现阶段策划希望只展示第三段, 其他的隐藏
	UIUtil.SetIsVisible(self.IconUltimateAbility1, false)
	UIUtil.SetIsVisible(self.IconUltimateAbility2, false)
	UIUtil.SetIsVisible(self.IconUltimateAbility3, true)
end

function SkillUltimateAbilityItemView:OnHide()

end

function SkillUltimateAbilityItemView:OnRegisterUIEvent()

end

function SkillUltimateAbilityItemView:OnRegisterGameEvent()

end

function SkillUltimateAbilityItemView:OnRegisterBinder()

end

local Handled <const> = UE.UWidgetBlueprintLibrary.Handled()
local OneVector2D <const> = UE.FVector2D(1, 1)

function SkillUltimateAbilityItemView:OnMouseCaptureLost()
	self:SetRenderScale(OneVector2D)
end

function SkillUltimateAbilityItemView:OnMouseButtonDown()
	self:SetRenderScale(OneVector2D * SkillCommonDefine.SkillBtnClickFeedback)
	return Handled
end

function SkillUltimateAbilityItemView:OnMouseButtonUp()
	self:SetRenderScale(OneVector2D)
	local ParentView = self.ParentView
	if ParentView and ParentView.OnLimitBtnClick then
		ParentView:OnLimitBtnClick()
	end
	return Handled
end

function SkillUltimateAbilityItemView:OnMouseLeave()
	self:SetRenderScale(OneVector2D)
end

return SkillUltimateAbilityItemView