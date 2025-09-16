---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class FishIngholeAreaBarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot2_UIBP CommonRedDot2View
---@field IconArrowSelect UFImage
---@field TextTitle UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeAreaBarItemView = LuaClass(UIView, true)

function FishIngholeAreaBarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot2_UIBP = nil
	--self.IconArrowSelect = nil
	--self.TextTitle = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeAreaBarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeAreaBarItemView:OnInit()
	self.Binders = {
		{ "AreaName", UIBinderSetText.New(self, self.TextTitle) },
		{ "AreaNameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTitle)},
		{ "bAreaChanged", UIBinderSetIsChecked.New(self, self.ToggleBtn) },
		{ "AreaName", UIBinderValueChangedCallback.New(self, nil, self.UpdateRedDot) },
		{ "IconArrow", UIBinderSetBrushFromAssetPath.New(self, self.IconArrowSelect) },
	}
end

function FishIngholeAreaBarItemView:UpdateRedDot()
	local AreaName = self.Params.Data.AreaName
	local Faction = _G.FishNotesMgr:GetFactionNameByAreaName(AreaName)
	local RedDotName = _G.FishNotesMgr:GetFishingholeRedDotName(Faction, AreaName)
	if RedDotName then
		self.CommonRedDot2_UIBP:SetRedDotNameByString(RedDotName)
	else
		self.CommonRedDot2_UIBP:SetRedDotNameByString("")
	end
end

function FishIngholeAreaBarItemView:OnDestroy()

end

function FishIngholeAreaBarItemView:OnShow()

end

function FishIngholeAreaBarItemView:OnHide()

end

function FishIngholeAreaBarItemView:OnRegisterUIEvent()

end

function FishIngholeAreaBarItemView:OnRegisterGameEvent()

end

function FishIngholeAreaBarItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	
	self:RegisterBinders(ViewModel, self.Binders)
end

return FishIngholeAreaBarItemView