---
--- Author: Administrator
--- DateTime: 2024-11-29 15:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local PVPInfoMgr = _G.PVPInfoMgr

---@class PVPModeDetailItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PVPColosseumStar1 PVPColosseumStarItemView
---@field PVPColosseumStar2 PVPColosseumStarItemView
---@field PVPColosseumStar3 PVPColosseumStarItemView
---@field TextDesc UFTextBlock
---@field TextValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPModeDetailItemView = LuaClass(UIView, true)

function PVPModeDetailItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PVPColosseumStar1 = nil
	--self.PVPColosseumStar2 = nil
	--self.PVPColosseumStar3 = nil
	--self.TextDesc = nil
	--self.TextValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPModeDetailItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PVPColosseumStar1)
	self:AddSubView(self.PVPColosseumStar2)
	self:AddSubView(self.PVPColosseumStar3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPModeDetailItemView:OnInit()
	self.Binders = {
		{ "Desc", UIBinderSetText.New(self, self.TextDesc) },
		{ "Value", UIBinderSetText.New(self, self.TextValue) },
		{ "StarVisible", UIBinderValueChangedCallback.New(self, nil, self.OnStarVisibleChanged) },
	}
end

function PVPModeDetailItemView:OnDestroy()

end

function PVPModeDetailItemView:OnShow()

end

function PVPModeDetailItemView:OnHide()

end

function PVPModeDetailItemView:OnRegisterUIEvent()

end

function PVPModeDetailItemView:OnRegisterGameEvent()

end

function PVPModeDetailItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local VM = Params.Data
	if VM == nil then return end

	self.ViewModel = VM
	self:RegisterBinders(VM, self.Binders)
end

function PVPModeDetailItemView:OnStarVisibleChanged(NewValue, OldValue)
	for Index = 1, PVPInfoMgr:GetCrystallineRankWinStarMax() do
		local VariableName = "PVPColosseumStar" .. Index
		UIUtil.SetIsVisible(self[VariableName], NewValue)

		if NewValue then
			local StarGlow = self.ViewModel.StarCount >= Index
			self[VariableName]:SetStarGlow(StarGlow)
		end
	end
end

return PVPModeDetailItemView