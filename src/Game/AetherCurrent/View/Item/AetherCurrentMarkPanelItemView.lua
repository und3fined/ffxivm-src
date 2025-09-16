---
--- Author: Administrator
--- DateTime: 2023-09-04 14:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class AetherCurrentMarkPanelItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Mark01 AetherCurrentMarkItemView
---@field Mark02 AetherCurrentMarkItemView
---@field Mark03 AetherCurrentMarkItemView
---@field Mark04 AetherCurrentMarkItemView
---@field Mark05 AetherCurrentMarkItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AetherCurrentMarkPanelItemView = LuaClass(UIView, true)

function AetherCurrentMarkPanelItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Mark01 = nil
	--self.Mark02 = nil
	--self.Mark03 = nil
	--self.Mark04 = nil
	--self.Mark05 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AetherCurrentMarkPanelItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Mark01)
	self:AddSubView(self.Mark02)
	self:AddSubView(self.Mark03)
	self:AddSubView(self.Mark04)
	self:AddSubView(self.Mark05)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AetherCurrentMarkPanelItemView:OnInit()
	self.Binders = {
		{ "PointListLen", UIBinderValueChangedCallback.New(self, nil, self.OnPointListChangedCallback) },
	}

	self.AnimEndCallBack = nil
end

function AetherCurrentMarkPanelItemView:OnDestroy()
	self.AnimEndCallBack = nil
end

function AetherCurrentMarkPanelItemView:OnShow()

end

function AetherCurrentMarkPanelItemView:OnHide()

end

function AetherCurrentMarkPanelItemView:OnRegisterUIEvent()

end

function AetherCurrentMarkPanelItemView:OnRegisterGameEvent()

end

function AetherCurrentMarkPanelItemView:OnPointListChangedCallback(PointListLen)
	for i = 1, 5 do
		local MarkBPName = string.format("Mark0%d", i)
		local MarkSubView = self[MarkBPName]
		if MarkSubView then
			if PointListLen == 1 then
				UIUtil.SetIsVisible(MarkSubView, i == 3)
			else
				UIUtil.SetIsVisible(MarkSubView, i <= PointListLen)
			end
		end
	end
end

function AetherCurrentMarkPanelItemView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local PointListLen = ViewModel.PointListLen
	if PointListLen <= 0 then
		return
	end

	local PointContent = ViewModel.PointContent
	if PointListLen == 1 then
		local SubVM = PointContent[1]
		self.Mark03:SetParams(SubVM)
	else
		for i = 1, 5 do
			local MarkBPName = string.format("Mark0%d", i)
			local MarkSubView = self[MarkBPName]
			if MarkSubView then
				local SubVM = PointContent[i]
				if SubVM then
					MarkSubView:SetParams(SubVM)
				end
			end
		end
	end
	
	self:RegisterBinders(ViewModel, self.Binders)
end

function AetherCurrentMarkPanelItemView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel.MapMarker
	if nil == MapMarker then
		return
	end

	self.Scale = Scale

	local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, ViewModel:GetPosition())
	UIUtil.CanvasSlotSetPosition(self, _G.UE.FVector2D(X, Y))
end

return AetherCurrentMarkPanelItemView