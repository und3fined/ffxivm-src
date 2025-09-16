---
--- Author: chaooren
--- DateTime: 2023-03-16 17:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local JobSkillSelectItemVM = require("Game/Skill/View/JobSkillSelectItemVM")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")

---@class SkillJobSkillSelectItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnJobSkill UFButton
---@field ImgSelect UFImage
---@field JobSkillCanvas UFCanvasPanel
---@field SpectrumIcon UFImage
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillJobSkillSelectItemView = LuaClass(UIView, true)

function SkillJobSkillSelectItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnJobSkill = nil
	--self.ImgSelect = nil
	--self.JobSkillCanvas = nil
	--self.SpectrumIcon = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillJobSkillSelectItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillJobSkillSelectItemView:OnInit()
	self.JobSkillSelectItemVM = JobSkillSelectItemVM.New()
end

function SkillJobSkillSelectItemView:OnDestroy()

end

function SkillJobSkillSelectItemView:OnShow()

end

function SkillJobSkillSelectItemView:OnHide()

end

function SkillJobSkillSelectItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnJobSkill, self.OnJobSkillBtnClicked)
end

function SkillJobSkillSelectItemView:OnRegisterGameEvent()

end

function SkillJobSkillSelectItemView:OnRegisterBinder()
	local Binders = {
		{ "JobSkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.SpectrumIcon, true, true) },
		{ "bJobSkillShow", UIBinderSetIsVisible.New(self, self.JobSkillCanvas) },
	}
	self:RegisterBinders(self.JobSkillSelectItemVM, Binders)
	local SkillSystemVM = self.Params.SkillSystemVM
	if SkillSystemVM then
		local BBinders = {
			{ "bSpectrumSelected", UIBinderSetIsVisible.New(self, self.ImgSelect) },
			{ "bSpectrumSelected", UIBinderIsLoopAnimPlay.New(self, nil, self.AnimSelect) },
		}
		self:RegisterBinders(SkillSystemVM, BBinders)
	end
end

function SkillJobSkillSelectItemView:OnJobSkillBtnClicked()
	local SkillSystemVM = self.Params.SkillSystemVM
	if SkillSystemVM then
		SkillSystemVM:OnSpectrumSelected(true)
	end
end

function SkillJobSkillSelectItemView:SetParams(Params)
	self.Super:SetParams(Params)
	self.JobSkillSelectItemVM:SetProfInfo(Params)
end


return SkillJobSkillSelectItemView