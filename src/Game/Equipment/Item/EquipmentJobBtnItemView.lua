---
--- Author: enqingchen
--- DateTime: 2021-12-27 15:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetBrushTintColorHex = require("Binder/UIBinderSetBrushTintColorHex")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local EquipmentMainVM = require("Game/Equipment/VM/EquipmentMainVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProfUtil = require("Game/Profession/ProfUtil")

---@class EquipmentJobBtnItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Canvas_Job UFCanvasPanel
---@field Icon_Normal UFImage
---@field Icon_Select UFImage
---@field RedDot CommonRedDotView
---@field AnimIn UWidgetAnimation
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentJobBtnItemView = LuaClass(UIView, true)

function EquipmentJobBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Canvas_Job = nil
	--self.Icon_Normal = nil
	--self.Icon_Select = nil
	--self.RedDot = nil
	--self.AnimIn = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentJobBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentJobBtnItemView:OnInit()

end

function EquipmentJobBtnItemView:OnDestroy()

end

function EquipmentJobBtnItemView:OnShow()
	self:SetRedDotID()
end

function EquipmentJobBtnItemView:OnHide()

end

function EquipmentJobBtnItemView:OnRegisterUIEvent()

end

function EquipmentJobBtnItemView:OnRegisterGameEvent()

end

function EquipmentJobBtnItemView:OnRegisterBinder()
	self.ViewModel = self.Params.Data
	local Binders = {
		{ "IconColor", UIBinderSetBrushTintColorHex.New(self, self.Icon_Normal) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.Icon_Select) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.RedDot, true) },
		{ "ProfID", UIBinderSetProfIcon.New(self, self.Icon_Normal) },
		{ "Opacity", UIBinderSetRenderOpacity.New(self, self.Canvas_Job) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function EquipmentJobBtnItemView:OnSelectChanged(bSelect, IsByClick)
	self.ViewModel:SetSelect(bSelect)

	if bSelect and IsByClick then
		local ProfID = self.ViewModel.ProfID
		FLOG_INFO("EquipmentJobBtnItemView:OnItemClicked  profID:%d", ProfID)
		self:PlayAnimation(self.AnimSelect)
		_G.EquipmentMgr:SwitchProfByID(ProfID)
	end
end

function EquipmentJobBtnItemView:SetRedDotID()
	local IsAdvancedProf = ProfUtil.IsAdvancedProf(self.ViewModel.ProfID)
	if not IsAdvancedProf then
		local RedDotID = tonumber("71"..string.format("%02d", self.ViewModel.ProfID))
		self.RedDot:SetRedDotIDByID(RedDotID)
		self.RedDot:SetStyle(1)
	end
end

return EquipmentJobBtnItemView