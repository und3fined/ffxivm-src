---
--- Author: ccppeng
--- DateTime: 2024-11-22 18:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local FashionDecoSkillPanelVM = require("Game/FashionDeco/VM/FashionDecoSkillPanelVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
---@class FashionDecoSkillPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FashionDecoSkillBtn1 FashionDecoSkillBtnView
---@field FashionDecoSkillBtn2 FashionDecoSkillBtnView
---@field FashionDecoSkillBtn3 FashionDecoSkillBtnView
---@field FashionDecoSkillBtn4 FashionDecoSkillBtnView
---@field Root UFCanvasPanel
---@field SkillFashionSwitchBtn SkillFashionSwitchBtnView
---@field SkillMountBtn SkillMountBtnView
---@field AnimIn1 UWidgetAnimation
---@field AnimOut1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionDecoSkillPanelView = LuaClass(UIView, true)

function FashionDecoSkillPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FashionDecoSkillBtn1 = nil
	--self.FashionDecoSkillBtn2 = nil
	--self.FashionDecoSkillBtn3 = nil
	--self.FashionDecoSkillBtn4 = nil
	--self.Root = nil
	--self.SkillFashionSwitchBtn = nil
	--self.SkillMountBtn = nil
	--self.AnimIn1 = nil
	--self.AnimOut1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionDecoSkillPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.FashionDecoSkillBtn1)
	self:AddSubView(self.FashionDecoSkillBtn2)
	self:AddSubView(self.FashionDecoSkillBtn3)
	self:AddSubView(self.FashionDecoSkillBtn4)
	self:AddSubView(self.SkillFashionSwitchBtn)
	self:AddSubView(self.SkillMountBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionDecoSkillPanelView:OnInit()
	EventID = _G.EventID
	self.ViewModel = FashionDecoSkillPanelVM.New()
end

function FashionDecoSkillPanelView:OnDestroy()

end

function FashionDecoSkillPanelView:OnShow()

end

function FashionDecoSkillPanelView:OnHide()

end

function FashionDecoSkillPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.SkillFashionSwitchBtn.BtnRun, self.OnBtnSwitchClick)
end
function FashionDecoSkillPanelView:OnBtnSwitchClick()
	self.ViewModel:SwitchIdleStateWithnUmbrella()
end
function FashionDecoSkillPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FashionDecorateUpdateData, self.OnGameEventFashionDecorateUpdateData)
	self:RegisterGameEvent(EventID.FightSkillPanelShowed, self.OnFightSkillPanelShowed)
end
function FashionDecoSkillPanelView:OnFightSkillPanelShowed(IfShowed,IsCrafterProf)
	if IfShowed ~= nil then
		--技能面板显示，我隐藏
		if IfShowed then
			if not self.IsHidding and not IsCrafterProf then
				self:PlayAnimation(self.AnimOut1)
				self.IsHidding = IfShowed
			end
		else
			--技能面板隐藏我显示
			if self.IsHidding then
				self.IsHidding = IfShowed
				self:PlayAnimation(self.AnimIn1)
			end
		end
	end
end
function FashionDecoSkillPanelView:OnGameEventFashionDecorateUpdateData(InCurrentClothingMap)
	self.ViewModel:OnGameEventFashionDecorateUpdateData(InCurrentClothingMap)
end
function FashionDecoSkillPanelView:OnRegisterBinder()
	UIUtil.SetIsVisible(self.Root, true, false)
	self.ViewModel:SetSwitchViewModelAttr(self.FashionDecoSkillBtn4)
	self.ViewModel:SetActionUmAction1ViewModelAttr(self.FashionDecoSkillBtn3)
	self.ViewModel:SetActionWingViewModelAttr(self.FashionDecoSkillBtn1)
	self.ViewModel:SetActionUmAction2ViewModelAttr(self.FashionDecoSkillBtn2)
	self.Binders = {

		{ "ActionSwitchIdleEnable", UIBinderSetIsVisible.New(self, self.FashionDecoSkillBtn4,false,true)},
		{ "ActionWingSkillEnable", UIBinderSetIsVisible.New(self, self.FashionDecoSkillBtn1,false,true)},
		{ "ActionUmAction1Enable", UIBinderSetIsVisible.New(self, self.FashionDecoSkillBtn3,false,true)},
		{ "ActionUmAction2Enable", UIBinderSetIsVisible.New(self, self.FashionDecoSkillBtn2,false,true)},
		{ "SkillFashionSwitchBtnEnable", UIBinderSetIsVisible.New(self, self.SkillFashionSwitchBtn,false,true)},
		{ "UpdateAnimView", UIBinderValueChangedCallback.New(self,nil, self.OnNeedToUpdateFashdionDecoIcon)},
		
	}
	self.IsHidding = false
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.ViewModel:UpdateFashionDecorateUpdateData()
end
function FashionDecoSkillPanelView:OnNeedToUpdateFashdionDecoIcon(IfShowed)
	if IfShowed ~= nil then
		--技能面板显示，我隐藏
		if not IfShowed then
			self:PlayAnimation(self.AnimIn1)
		end
	end
end
function FashionDecoSkillPanelView:OnSwitchIdleClicked()
	self.ViewModel:OnSwitchIdleClicked()
end

return FashionDecoSkillPanelView