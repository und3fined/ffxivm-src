---
--- Author: skysong
--- DateTime: 2025-05-06 15:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class HouseCommMenuParentItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot2_UIBP CommonRedDot2View
---@field CommonRedDot_UIBP CommonRedDotView
---@field ImgNormal UFImage
---@field ImgNormalDown UFImage
---@field ImgNormalUp UFImage
---@field ImgSelect UFImage
---@field ImgUnlock UFImage
---@field PanelIcon UFCanvasPanel
---@field TextName UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimFold UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseCommMenuParentItemView = LuaClass(UIView, true)
local SelectOutLineColor = _G.UE.FLinearColor.FromHex("#806644")
SelectOutLineColor.A = 0.5
local MenuGetSelectKeyFun = nil

function HouseCommMenuParentItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot2_UIBP = nil
	--self.CommonRedDot_UIBP = nil
	--self.ImgNormal = nil
	--self.ImgNormalDown = nil
	--self.ImgNormalUp = nil
	--self.ImgSelect = nil
	--self.ImgUnlock = nil
	--self.PanelIcon = nil
	--self.TextName = nil
	--self.AnimCheck = nil
	--self.AnimFold = nil
	--self.AnimIn = nil
	--self.AnimUncheck = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseCommMenuParentItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2_UIBP)
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseCommMenuParentItemView:OnInit()
	self.IsSelected = false
	self.TextNameFont = self.TextName.Font
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "UpArrowVisible", UIBinderSetIsVisible.New(self, self.ImgNormalUp) },
		{ "DownArrowVisible", UIBinderSetIsVisible.New(self, self.ImgNormalDown) },
		{ "IsExpanded", UIBinderValueChangedCallback.New(self, nil, self.OnExpandedChanged) },
		{ "IsShowTogetherWithChildItem", UIBinderValueChangedCallback.New(self, nil, self.OnShowTogetherWithChildItem) }
	}
end

function HouseCommMenuParentItemView:OnDestroy()

end

function HouseCommMenuParentItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	UIUtil.SetIsVisible(self.ImgNormalUp, not self.IsSelected)
	UIUtil.SetIsVisible(self.ImgNormalDown, self.IsSelected)
	UIUtil.SetIsVisible(self.ImgNormal, not self.IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, self.IsSelected)

	UIUtil.SetIsVisible(self.ImgUnlock, false)
	self:UpdateTextColorBySelect(false)
	self:UpdateItem(Params.Data)
	local ViewModel = Params.Data
	ViewModel:UpdateArrowVisible()
	self:PlayAnimation(self.AnimUncheck)
end

function HouseCommMenuParentItemView:OnHide()
	UIUtil.SetIsVisible(self.ImgNormalUp, false)
	UIUtil.SetIsVisible(self.ImgNormalDown, false)
	self:StopAllAnimations()
	MenuGetSelectKeyFun = nil
end

function HouseCommMenuParentItemView:OnRegisterUIEvent()

end

function HouseCommMenuParentItemView:OnRegisterGameEvent()

end

--- 红点ID设置表现刷新
function HouseCommMenuParentItemView:SetRedDotShowByData(Data)
	if Data.RedDotID then
		self.CommonRedDot_UIBP:SetRedDotIDByID(Data.RedDotID)
	else
		self.CommonRedDot_UIBP:SetRedDotNameByString(Data.RedDotName)
	end

	if Data.RedDotStyle then
		self.CommonRedDot_UIBP:SetStyle(Data.RedDotStyle)
		if Data.RedDotText then
			self.CommonRedDot_UIBP:SetRedDotText(Data.RedDotText)
		end
	end

	---第二种红点蓝图配置
	if Data.RedDot2ID then
		self.CommonRedDot2_UIBP:SetRedDotIDByID(Data.RedDot2ID)
	else
		self.CommonRedDot2_UIBP:SetRedDotNameByString(Data.RedDot2Name)
	end

	if Data.RedDot2Text then
		self.CommonRedDot2_UIBP:SetText(Data.RedDot2Text)
	end

	local ShowRedDot1 = (Data.RedDotID or Data.RedDotName) and true or false
	local ShowRedDot2 = (Data.RedDot2ID or Data.RedDot2Name) and true or false
	UIUtil.SetIsVisible(self.CommonRedDot_UIBP, ShowRedDot1)
	UIUtil.SetIsVisible(self.CommonRedDot2_UIBP, ShowRedDot2)
end

function HouseCommMenuParentItemView:UpdateItem(Data)
	if not Data then return end
	self:SetRedDotShowByData(Data)
	local IsSelected = self.IsSelected
	if MenuGetSelectKeyFun then
		local NowSelectKey = MenuGetSelectKeyFun()
		IsSelected = Data.Key == NowSelectKey
	end

	self:UpdateTextColorBySelect(IsSelected)
end

function HouseCommMenuParentItemView:InitTab(Params)
	if nil == Params then
		return
	end

	self.ColorSelect = Params.ColorSelect
	self.ColorNormal = Params.ColorNormal
	MenuGetSelectKeyFun = Params.GetKeyFun
end

function HouseCommMenuParentItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then return end

	local Adapter = Params.Adapter
	if nil ~= Adapter then
		self:InitTab(Adapter.Params)
	end

	local ViewModel = Params.Data

	self:RegisterBinders(ViewModel, self.Binders)
end

function HouseCommMenuParentItemView:OnSelectChanged(IsSelected)
	if self.IsSelected == IsSelected then return end

	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	--if not ViewModel.IsUnLock then return end

	self.IsSelected = IsSelected
	local Adapter = Params.Adapter
	if Adapter and not IsSelected then
		local Child = ViewModel:FindChild(Adapter.SelectedItem)
		if Child then
			self.IsSelected = true
		end
	end

	--UIUtil.SetIsVisible(self.ImgNormalUp, not self.IsSelected)
	--UIUtil.SetIsVisible(self.ImgNormalDown, self.IsSelected)
	UIUtil.SetIsVisible(self.ImgNormal, not self.IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, self.IsSelected)

	self:UpdateTextColorBySelect(self.IsSelected)
	self:UpdateArrowShow()
	if self.IsSelected then
		self:PlayAnimation(self.AnimCheck)
	else
		self:PlayAnimation(self.AnimUncheck)
	end
end

--- 更新选中非选中字色
function HouseCommMenuParentItemView:UpdateTextColorBySelect(IsSelected)
	local Color = IsSelected and self.ColorSelect or self.ColorNormal
	self.TextName:SetColorAndOpacity(Color)

	if IsSelected then
		self.TextNameFont.OutlineSettings.OutlineSize = 2
		self.TextNameFont.OutlineSettings.OutlineColor = SelectOutLineColor
	else
		self.TextNameFont.OutlineSettings.OutlineSize = 0
	end

	self.TextName:SetFont(self.TextNameFont)
end

function HouseCommMenuParentItemView:OnShowTogetherWithChildItem(IsShow)
	self:OnSelectChanged(IsShow)
end

function HouseCommMenuParentItemView:OnExpandedChanged(IsExpanded, OldValue)
	if not self.Params then return end

	local ViewModel = self.Params.Data
	if ViewModel and ViewModel.IsAutoExpand then
		if IsExpanded then
			self:PlayAnimation(self.AnimUnfold)
		else
			self:PlayAnimation(self.AnimFold)
		end
	end
end

function HouseCommMenuParentItemView:UpdateArrowShow()
	local Params = self.Params
	local ViewModel = Params.Data

	if ViewModel and ViewModel.IsAutoExpand then
		UIUtil.SetIsVisible(self.ImgNormalUp, self.IsSelected)
		UIUtil.SetIsVisible(self.ImgNormalDown, not self.IsSelected)
	else
		UIUtil.SetIsVisible(self.ImgNormalUp, false)
		UIUtil.SetIsVisible(self.ImgNormalDown, false)
	end
end

return HouseCommMenuParentItemView