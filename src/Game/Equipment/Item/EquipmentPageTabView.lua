---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class EquipmentPageTabView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_Select UFCanvasPanel
---@field ImgSelect UFImage
---@field Img_TabNormal UFImage
---@field RedDot CommonRedDotView
---@field Text_TabName UFTextBlock
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentPageTabView = LuaClass(UIView, true)

local TextColor =
{
	Default = "878075",
	Selected = "fff4d0",
}

function EquipmentPageTabView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_Select = nil
	--self.ImgSelect = nil
	--self.Img_TabNormal = nil
	--self.RedDot = nil
	--self.Text_TabName = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentPageTabView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentPageTabView:OnInit()
end

function EquipmentPageTabView:OnDestroy()

end

function EquipmentPageTabView:OnShow()
	local IsVisible = false
	if self.Params and self.Params.Data then
		self.RedDot:SetRedDotIDByID(self.Params.Data.RedDotID)
		self.RedDot:SetStyle(1)
		IsVisible = self.Params.Data.ReCreate
	end
	UIUtil.SetIsVisible(self.PageTab, true, IsVisible)
end

function EquipmentPageTabView:OnHide()

end

function EquipmentPageTabView:OnRegisterUIEvent()

end

function EquipmentPageTabView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.EquipmentAnimFinish, self.EquipmentAnimFinish)
end

function EquipmentPageTabView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "Text", UIBinderSetText.New(self, self.Text_TabName) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentPageTabView:OnSelectChanged(bSelect)
	if (not bSelect == self.ViewModel.bSelect or not self.ViewModel.bSelect == nil) and bSelect then
		self:PlayAnimation(self.AnimSelect)
	end
	self.Text_TabName.Font.OutlineSettings.OutlineSize = 2
    local ContentColor = bSelect and _G.UE.FLinearColor.FromHex("806644") or _G.UE.FLinearColor.FromHex("212121")
	ContentColor.A = 50 / 100
	self.Text_TabName.Font.OutlineSettings.OutlineColor = ContentColor
	self.Text_TabName:SetFont(self.Text_TabName.Font)
	if bSelect then
		UIUtil.SetColorAndOpacityHex(self.Text_TabName, TextColor.Selected)
	elseif bSelect == false then
		UIUtil.SetColorAndOpacityHex(self.Text_TabName, TextColor.Default)
	end
	self.ViewModel.bSelect = bSelect
	UIUtil.SetIsVisible(self.ImgSelect, bSelect)
	UIUtil.SetIsVisible(self.EFF_Select, bSelect)

end

function EquipmentPageTabView:EquipmentAnimFinish()
	UIUtil.SetIsVisible(self.PageTab, true, true)
end

return EquipmentPageTabView