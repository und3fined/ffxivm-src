---
--- Author: Administrator
--- DateTime: 2025-03-13 14:22
--- Description:左侧玩法标签
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class DepartureTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconNormal UFImage
---@field IconReceived UFImage
---@field IconSelect UFImage
---@field RedDot CommonRedDotView
---@field Text UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureTabItemView = LuaClass(UIView, true)

function DepartureTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconNormal = nil
	--self.IconReceived = nil
	--self.IconSelect = nil
	--self.RedDot = nil
	--self.Text = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureTabItemView:OnInit()
	self.Binders = {
		{"ActivityName", UIBinderSetText.New(self, self.Text)},
		{"IsGetAllReward", UIBinderSetIsVisible.New(self, self.IconReceived)},
		{"NormalIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconNormal)},
		{"SelectedIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconSelect)},
	}
end

function DepartureTabItemView:OnDestroy()

end

function DepartureTabItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	self.RedDot:SetRedDotNameByString(_G.DepartOfLightMgr:GetRedDotName(ViewModel.ActivityID))
	self.RedDot:SetStyle(RedDotDefine.RedDotStyle.NormalStyle)
end

function DepartureTabItemView:OnHide()

end

function DepartureTabItemView:OnRegisterUIEvent()

end

function DepartureTabItemView:OnRegisterGameEvent()

end

function DepartureTabItemView:OnRegisterBinder()
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

function DepartureTabItemView:OnSelectChanged(IsSelected)
	self.ToggleBtn:SetChecked(IsSelected, false)
	if IsSelected then
		self.RedDot:SetStyle(RedDotDefine.RedDotStyle.NormalStyle)
	end
end

return DepartureTabItemView