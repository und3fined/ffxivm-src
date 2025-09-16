---
--- Author: chaooren
--- DateTime: 2022-06-29 16:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetAnimPlayPercentage = require("Binder/UIBinderSetAnimPlayPercentage")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class SkillBtnItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot01 CommonRedDotView
---@field FCanvasPanel_57 UFCanvasPanel
---@field FImg_Mask UFImage
---@field FImg_Select UFImage
---@field FImg_Slot UFImage
---@field Icon_Skill UFImage
---@field AnimSelectedIn UWidgetAnimation
---@field AnimSelectedOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillBtnItemView = LuaClass(UIView, true)

function SkillBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot01 = nil
	--self.FCanvasPanel_57 = nil
	--self.FImg_Mask = nil
	--self.FImg_Select = nil
	--self.FImg_Slot = nil
	--self.Icon_Skill = nil
	--self.AnimSelectedIn = nil
	--self.AnimSelectedOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot01)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillBtnItemView:OnInit()
	self.bManageSelected = false
end

function SkillBtnItemView:OnDestroy()

end

function SkillBtnItemView:OnShow()

end

function SkillBtnItemView:OnHide()

end

function SkillBtnItemView:OnRegisterUIEvent()

end

function SkillBtnItemView:OnRegisterGameEvent()

end

function SkillBtnItemView:OnRegisterBinder()
	local PassiveSkillVM = self.Params.Data
	if PassiveSkillVM then
		local Binders = {
			{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Skill) },
			{ "bSelected", UIBinderSetIsVisible.New(self, self.FImg_Select) },
			{ "SkillID", UIBinderValueChangedCallback.New(self, nil, self.OnSkillIDChanged) },
			--{ "bLearned", UIBinderSetIsVisible.New(self, self.FImg_Mask, true) },
			--{ "bLearned", UIBinderSetIsEnabled.New(self, self.FCanvasPanel_57)},
		}
		self:RegisterBinders(PassiveSkillVM, Binders)
		self.PassiveSkillVM = PassiveSkillVM
	end
end

function SkillBtnItemView:OnSelectChanged(bSelected)
	self.bManageSelected = bSelected
	if bSelected then
		if self:IsAnimationPlaying(self.AnimSelectedOut) then
			self:StopAnimation(self.AnimSelectedOut)
		end
		self:PlayAnimation(self.AnimSelectedIn)
		local VM = self.PassiveSkillVM
		if VM then
			_G.SkillSystemMgr:UpdateSkillRedDotCheckState(VM.SkillID)
		end
	else
		if self:IsAnimationPlaying(self.AnimSelectedIn) then
			self:StopAnimation(self.AnimSelectedIn)
		end
		self:PlayAnimation(self.AnimSelectedOut)
	end
end

function SkillBtnItemView:OnSkillIDChanged(NewSkillID, OldSkillID)
	local SkillSystemMgr = _G.SkillSystemMgr
	if OldSkillID then
		SkillSystemMgr:UnRegisterPassiveSkillRedDotWidget(OldSkillID)
	end
	if NewSkillID then
		SkillSystemMgr:RegisterPassiveSkillRedDotWidget(NewSkillID, self.CommonRedDot01)
	end
end

return SkillBtnItemView