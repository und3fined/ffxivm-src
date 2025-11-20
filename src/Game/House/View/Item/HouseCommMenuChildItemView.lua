---
--- Author: skysong
--- DateTime: 2025-05-10 10:12
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local NomalOutLineColor = _G.UE.FLinearColor.FromHex("#2121217F")
local SelectOutLineColor = _G.UE.FLinearColor.FromHex("#8066447F")

---@class HouseCommMenuChildItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot2_UIBP CommonRedDot2View
---@field CommonRedDot_UIBP CommonRedDotView
---@field IconLock USizeBox
---@field ImgBg1 UFImage
---@field ImgBgGradient UFImage
---@field ImgIcon UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field ImgUnlock UFImage
---@field PanelItem UFCanvasPanel
---@field SizeBox1 USizeBox
---@field TextName UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseCommMenuChildItemView = LuaClass(UIView, true)

function HouseCommMenuChildItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot2_UIBP = nil
	--self.CommonRedDot_UIBP = nil
	--self.IconLock = nil
	--self.ImgBg1 = nil
	--self.ImgBgGradient = nil
	--self.ImgIcon = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.ImgUnlock = nil
	--self.PanelItem = nil
	--self.SizeBox1 = nil
	--self.TextName = nil
	--self.AnimCheck = nil
	--self.AnimIn = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseCommMenuChildItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2_UIBP)
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseCommMenuChildItemView:OnInit()
	self.IsSelected = nil
	self.TextNameFont = self.TextName.Font

	--需求不显示底图
	UIUtil.SetIsVisible(self.ImgNormal, false)

	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "Bg1Visible", UIBinderSetIsVisible.New(self, self.ImgBg1) },
		{ "BgCradientVisible", UIBinderSetIsVisible.New(self, self.ImgBgGradient) },
	}
end

function HouseCommMenuChildItemView:OnDestroy()

end

function HouseCommMenuChildItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	self:UpdateItem(Params.Data)
end

function HouseCommMenuChildItemView:OnHide()

end

function HouseCommMenuChildItemView:OnRegisterUIEvent()

end

function HouseCommMenuChildItemView:OnRegisterGameEvent()

end

function HouseCommMenuChildItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil ~= Adapter then
		self:InitTab(Adapter.Params)
	end

	local ViewModel = Params.Data

	self:RegisterBinders(ViewModel, self.Binders)
end

function HouseCommMenuChildItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if nil == Params then return end

	local ViewModel = Params.Data

	self.IsSelected = IsSelected
	--UIUtil.SetIsVisible(self.ImgNormal, not IsSelected)
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
	self:RefreshShowColor()

	ViewModel:SetShowTogetherWithChildItem(IsSelected)
end

function HouseCommMenuChildItemView:InitTab(Params)
	if nil == Params then
		return
	end

	self.ColorSelect = Params.ColorSelect
	self.ColorNormal = Params.ColorNormal
end

function HouseCommMenuChildItemView:SetReddotShowByData(Data)
	if Data.RedDotID then
		self.CommonRedDot_UIBP:SetRedDotIDByID(Data.RedDotID)
	elseif Data.RedDotName then
		self.CommonRedDot_UIBP:SetRedDotNameByString(Data.RedDotName)
	else
		self.CommonRedDot_UIBP:SetRedDotIDByID()
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
	elseif Data.RedDot2Name then
		self.CommonRedDot2_UIBP:SetRedDotNameByString(Data.RedDot2Name)
	else
		self.CommonRedDot2_UIBP:SetRedDotIDByID()
	end

	if Data.RedDot2Text then
		self.CommonRedDot2_UIBP:SetText(Data.RedDot2Text)
	end
end

function HouseCommMenuChildItemView:UpdateItem(Data)
	if nil == Data then return end
	self:SetReddotShowByData(Data)

	UIUtil.SetIsVisible(self.ImgUnlock, not Data.IsUnLock)
end

function HouseCommMenuChildItemView:RefreshShowColor()
	local Params = self.Params
	if nil == Params then return end

	UIUtil.SetColorAndOpacity(self.ImgIcon, 1, 1, 1, 1)
	local ViewModel = Params.Data
	local Color = self.IsSelected and self.ColorSelect or self.ColorNormal
	self.TextName:SetColorAndOpacity(Color)
	self.TextNameFont.OutlineSettings.OutlineSize = 2

	if not self.IsSelected then
		--UIUtil.SetColorAndOpacity(self.ImgIcon, 1, 1, 1, 0.5)
		self.TextNameFont.OutlineSettings.OutlineColor = NomalOutLineColor
	else
		self.TextNameFont.OutlineSettings.OutlineColor = SelectOutLineColor
	end

	self.TextName:SetFont(self.TextNameFont)
end

return HouseCommMenuChildItemView