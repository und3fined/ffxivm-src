---
--- Author: Administrator
--- DateTime: 2024-02-20 20:20
--- Description:挑战外观列表ItemView(时尚达人)
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local FashionEvaluationMgr = require("Game/FashionEvaluation/FashionEvaluationMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FashionEvaluationscoreExteriorListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBtnBg UFImage
---@field ImgThing UFImage
---@field TextName UFTextBlock
---@field TextType UFTextBlock
---@field ToggleButton_61 UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionEvaluationscoreExteriorListItemView = LuaClass(UIView, true)

function FashionEvaluationscoreExteriorListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBtnBg = nil
	--self.ImgThing = nil
	--self.TextName = nil
	--self.TextType = nil
	--self.ToggleButton_61 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionEvaluationscoreExteriorListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionEvaluationscoreExteriorListItemView:OnInit()
	self.Binders = {
		{"AppearanceName", UIBinderSetText.New(self, self.TextName)},
		{"PartThemeName", UIBinderSetText.New(self, self.TextType)},
		{"AppearanceIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgThing)},
		{"EquipIconOpacity", UIBinderSetOpacity.New(self, self.ImgThing)},
		{"IsEmpty", UIBinderSetIsVisible.New(self, self.ToggleButton_61, true, true)},
		{"IsEmpty", UIBinderSetIsVisible.New(self, self.ImgBtnBg, true)},
		{"IsTracked", UIBinderSetIsChecked.New(self, self.ToggleButton_61)},
	}
end

function FashionEvaluationscoreExteriorListItemView:OnDestroy()

end

function FashionEvaluationscoreExteriorListItemView:OnShow()

end

function FashionEvaluationscoreExteriorListItemView:OnHide()

end

function FashionEvaluationscoreExteriorListItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleButton_61, self.OnChangedToggleBtnTrack)
end

function FashionEvaluationscoreExteriorListItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OnAppearanceTrackStateChanged, self.OnAppearanceTrackStateChanged)
end

function FashionEvaluationscoreExteriorListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function FashionEvaluationscoreExteriorListItemView:OnAppearanceTrackStateChanged(AppearanceID, IsTrack)
	-- 同步追踪界面衣橱目标
	local CurSelectAppID = self.ViewModel.AppearanceID
	if CurSelectAppID == AppearanceID then
		if not IsTrack then
			self.ToggleButton_61:SetChecked(false)
		end
	end
end

function FashionEvaluationscoreExteriorListItemView:OnChangedToggleBtnTrack()
	local CurSelectAppID = self.ViewModel.AppearanceID
	if CurSelectAppID == nil or CurSelectAppID <= 0 then
		return
	end

	local IsChecked = self.ToggleButton_61:GetChecked()
	if not FashionEvaluationMgr:OnEquipTrackClicked(CurSelectAppID, IsChecked) then
		if self.ToggleButton_61:GetChecked() then
			self.ToggleButton_61:SetChecked(false)
		end
	end 
end

return FashionEvaluationscoreExteriorListItemView