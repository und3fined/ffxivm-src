---
--- Author: henghaoli
--- DateTime: 2023-09-12 16:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetSliderWithCurve = require("Binder/UIBinderSetSliderWithCurve")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CrafterCarpenterVM = require("Game/Crafter/View/Carpenter/CrafterCarpenterVM")



---@class CrafterCarpenterMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CarpenterSkill1 CrafterSkillItemView
---@field CarpenterSkill2 CrafterSkillItemView
---@field CarpenterSkill3 CrafterSkillItemView
---@field Carpenternervous UFCanvasPanel
---@field CrafterCarpenter CrafterCarpenterItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterCarpenterMainPanelView = LuaClass(UIView, true)

function CrafterCarpenterMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CarpenterSkill1 = nil
	--self.CarpenterSkill2 = nil
	--self.CarpenterSkill3 = nil
	--self.Carpenternervous = nil
	--self.CrafterCarpenter = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterCarpenterMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CarpenterSkill1)
	self:AddSubView(self.CarpenterSkill2)
	self:AddSubView(self.CarpenterSkill3)
	self:AddSubView(self.CrafterCarpenter)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterCarpenterMainPanelView:OnInit()
	self.CrafterCarpenterVM = CrafterCarpenterVM.New()
	self.BeginIndex = 1
	self.EndIndex = 3
	self.SliderMoveTime = self.CrafterCarpenter.AnimPointerControl:GetEndTime()

	local View = self.CrafterCarpenter
	self.PrupleZoneAnimMap = {
		[true]  = { View.AnimLeftShowPurple, View.AnimRightShowPurple },
		[false] = { View.AnimRightShowBlue,  View.AnimLeftShowGreen },
	}
end

function CrafterCarpenterMainPanelView:OnDestroy()

end

function CrafterCarpenterMainPanelView:OnShow()
	self.CrafterCarpenterVM:ResetParams()
	local Params = self.Params
	if not Params then
		return
	end

	self.CrafterCarpenterVM:UpdateFeatures(Params.Features)
	self:UpdateBuffEffects()

	if not Params.bIsReconnect then
		return
	end
	LifeSkillBuffMgr:MajorInitAllBuffInView(self, self.OnBuffAdd)
end

function CrafterCarpenterMainPanelView:OnHide()

end

function CrafterCarpenterMainPanelView:OnRegisterUIEvent()

end

function CrafterCarpenterMainPanelView:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
	self:RegisterGameEvent(EventID.MajorAddBuffLife, self.OnBuffAdd)
	self:RegisterGameEvent(EventID.MajorRemoveBuffLife, self.OnBuffRemove)
	self:RegisterGameEvent(EventID.CrafterSkillCDUpdate, self.OnCrafterSkillCDUpdate)
	self:RegisterGameEvent(EventID.CrafterSkillCostUpdate, self.OnCrafterSkillCostUpdate)
end

function CrafterCarpenterMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "TensionSliderPercent", UIBinderValueChangedCallback.New(self, nil, self.OnSliderPercentChanged) },
		{ "bIsPurpleZoneVisible", UIBinderValueChangedCallback.New(self, nil, self.OnPurpleZoneVisibleChanged) },
		{ "bInLeft", UIBinderValueChangedCallback.New(self, nil, self.CheckStateAndPlayHideAnim, "AnimLeftHide") },
		{ "bInRight", UIBinderValueChangedCallback.New(self, nil, self.CheckStateAndPlayHideAnim, "AnimRightHide") },
	}
	self:RegisterBinders(self.CrafterCarpenterVM, Binders)
end

function CrafterCarpenterMainPanelView:OnCrafterSkillCostUpdate(Params)
	local BeginIndex = self.BeginIndex
	local EndIndex = self.EndIndex
	for Index = BeginIndex, EndIndex do
		self["CarpenterSkill" .. tostring(Index)]:OnCrafterSkillCostUpdate(Params)
	end
end

function CrafterCarpenterMainPanelView:OnCrafterSkillCDUpdate(Params)
	local BeginIndex = self.BeginIndex
	local EndIndex = self.EndIndex
	for Index = BeginIndex, EndIndex do
		self["CarpenterSkill" .. tostring(Index)]:OnCrafterSkillCDUpdate(Params)
	end
end

function CrafterCarpenterMainPanelView:OnEventCrafterSkillRsp(MsgBody)
	if MsgBody and MsgBody.CrafterSkill then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then
			local VM = self.CrafterCarpenterVM
			-- 紧张条指针
			VM:UpdateFeatures(MsgBody.CrafterSkill.Features)

			local SliderMoveTime = 0  -- 本来应该是self.SliderMoveTime的, 但是重构后其他各个动画本身就有延迟
			-- 紧张条发光的效果, 等指针移动到对应区域再实现
			local BuffEffectTimer = self.BuffEffectTimer
			if BuffEffectTimer then
				self:UnRegisterTimer(BuffEffectTimer)
			end
			self.BuffEffectTimer = self:RegisterTimer(
				function()
					self:UpdateBuffEffects()
				end,
				SliderMoveTime, 0, 1)
        end
    end
end

function CrafterCarpenterMainPanelView:OnBuffAdd(BuffInfo)
	self.CrafterCarpenterVM:OnBuffChanged(BuffInfo.BuffID, true)
end

function CrafterCarpenterMainPanelView:OnBuffRemove(BuffInfo)
	self.CrafterCarpenterVM:OnBuffChanged(BuffInfo.BuffID, false)
end

-- VM中属性和对应Anim的Map
local AnimMap = {
	bIsTensionInLeftPurpleZone  = "AnimLeftShowPurple",
    bIsTensionInRightPurpleZone = "AnimRightShowPurple",
    bIsTensionInRedZone         = "AnimRightShowBlue",
    bIsTensionInBlueZone        = "AnimLeftShowGreen",
}

function CrafterCarpenterMainPanelView:UpdateBuffEffects()
	local VM = self.CrafterCarpenterVM
	local PropLastValueMap = {}
	for Prop, _ in pairs(AnimMap) do
		PropLastValueMap[Prop] = VM[Prop]
	end

	VM:UpdateBuffEffects()

	local View = self.CrafterCarpenter
	for Prop, Anim in pairs(AnimMap) do
		local CurrValue = VM[Prop]
		if CurrValue and CurrValue ~= PropLastValueMap[Prop] then
			View:PlayAnimation(View[Anim])
		end
	end
end

function CrafterCarpenterMainPanelView:CheckStateAndPlayHideAnim(Value, _, AnimName)
	if not Value then
		local View = self.CrafterCarpenter
		View:PlayAnimation(View[AnimName])
	end
end

local function ResetAnimState(View, Anim)
	View:PlayAnimationTimeRange(Anim, 0, 0.001, 1, nil, 1.0, false)
end

function CrafterCarpenterMainPanelView:OnPurpleZoneVisibleChanged(Value)
	if Value == nil then
		return
	end
	local View = self.CrafterCarpenter
	local PrupleZoneAnimMap = self.PrupleZoneAnimMap
	for _, Anim in pairs(PrupleZoneAnimMap[not Value]) do
		View:StopAnimation(Anim)
	end
	for _, Anim in pairs(PrupleZoneAnimMap[Value]) do
		ResetAnimState(View, Anim)
	end
end

function CrafterCarpenterMainPanelView:OnSliderPercentChanged(NewValue, OldValue)
	self.CrafterCarpenter:PlayAnimPointer(OldValue, NewValue)
end

return CrafterCarpenterMainPanelView