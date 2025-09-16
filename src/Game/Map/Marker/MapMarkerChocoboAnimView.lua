---
--- Author: sammrli
--- DateTime: 2024-04-23 20:55
--- Description:地图标记-陆行鸟动画
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local MapVM = require("Game/Map/VM/MapVM")

local UE = _G.UE

---@class MapMarkerChocoboAnimView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ChocoboTransportBirdFlyItem_UIBP ChocoboTransportBirdFlyItemView
---@field ChocoboTransportBirdRunItem_UIBP ChocoboTransportBirdRunItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerChocoboAnimView = LuaClass(UIView, true)

function MapMarkerChocoboAnimView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ChocoboTransportBirdFlyItem_UIBP = nil
	--self.ChocoboTransportBirdRunItem_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerChocoboAnimView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ChocoboTransportBirdFlyItem_UIBP)
	self:AddSubView(self.ChocoboTransportBirdRunItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerChocoboAnimView:OnInit()
	self.Scale = 1.0
	self.RenderScale = UE.FVector2D(0.6, 0.6)
	self.IsChocoboVisible = nil
end

function MapMarkerChocoboAnimView:OnDestroy()

end

function MapMarkerChocoboAnimView:OnShow()

end

function MapMarkerChocoboAnimView:OnHide()

end

function MapMarkerChocoboAnimView:OnRegisterUIEvent()

end

function MapMarkerChocoboAnimView:OnRegisterGameEvent()

end

function MapMarkerChocoboAnimView:OnRegisterBinder()
	local MapBinder = {
		--{ "MajorLeftTopPosition", UIBinderValueChangedCallback.New(self, nil, self.OnMajorPositionValueChanged)},
		{ "MajorRotationAngle", UIBinderValueChangedCallback.New(self, nil, self.OnMajorRotationAngleValueChanged)},
		{ "IsMajorVisible", UIBinderValueChangedCallback.New(self, nil, self.OnIsMajorVisibleValueChanged)},
	}
	self:RegisterBinders(MapVM, MapBinder)
end

function MapMarkerChocoboAnimView:OnScaleChanged(Scale)
	self.Scale = Scale

	local MajorLeftTopPosition = MapVM:GetMajorLeftTopPosition()
	local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, MajorLeftTopPosition.X, MajorLeftTopPosition.Y)
	UIUtil.CanvasSlotSetPosition(self, UE.FVector2D(X, Y))
end

function MapMarkerChocoboAnimView:IsUnderLocation(ScreenPosition)
	return false
end

--[[
function MapMarkerChocoboAnimView:OnMajorPositionValueChanged(MajorLeftTopPosition)
	if not self.IsChocoboVisible then
		return
	end
	if not MajorLeftTopPosition then
		return
	end
	local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, MajorLeftTopPosition.X, MajorLeftTopPosition.Y)
	UIUtil.CanvasSlotSetPosition(self, UE.FVector2D(X, Y))
	--朝向
	if MapVM.MajorRotationAngle >= -90 and MapVM.MajorRotationAngle < 90 then
		self.RenderScale.X = -0.6
	else
		self.RenderScale.X = 0.6
	end
	local IsRun = true
	if IsRun then
		self.ChocoboTransportBirdRunItem_UIBP:SetRenderScale(self.RenderScale)
	else
		self.ChocoboTransportBirdFlyItem_UIBP:SetRenderScale(self.RenderScale)
	end
end
]]

function MapMarkerChocoboAnimView:OnMajorRotationAngleValueChanged(MajorRotationAngle)
	if not self.IsChocoboVisible then
		return
	end
	--朝向
	if MajorRotationAngle >= -90 and MajorRotationAngle < 90 then
		self.RenderScale.X = -0.6
	else
		self.RenderScale.X = 0.6
	end
	local IsRun = not _G.ChocoboTransportMgr:IsFlyMode()
	if IsRun then
		self.ChocoboTransportBirdRunItem_UIBP:SetRenderScale(self.RenderScale)
	else
		self.ChocoboTransportBirdFlyItem_UIBP:SetRenderScale(self.RenderScale)
	end
end

function MapMarkerChocoboAnimView:OnIsMajorVisibleValueChanged(IsMajorVisible)
	self.IsChocoboVisible = not IsMajorVisible
	local IsRun = not _G.ChocoboTransportMgr:IsFlyMode()
	if self.IsChocoboVisible then
		UIUtil.SetIsVisible(self.ChocoboTransportBirdRunItem_UIBP, IsRun)
		UIUtil.SetIsVisible(self.ChocoboTransportBirdFlyItem_UIBP, not IsRun)
		--获取当前朝向
		if MapVM.MajorRotationAngle >= -90 and MapVM.MajorRotationAngle < 90 then
			self.RenderScale.X = -0.6
		else
			self.RenderScale.X = 0.6
		end
		if IsRun then
			self.ChocoboTransportBirdRunItem_UIBP:SetRenderScale(self.RenderScale)
		else
			self.ChocoboTransportBirdFlyItem_UIBP:SetRenderScale(self.RenderScale)
		end
	else
		UIUtil.SetIsVisible(self.ChocoboTransportBirdRunItem_UIBP, false)
		UIUtil.SetIsVisible(self.ChocoboTransportBirdFlyItem_UIBP, false)
	end
end

return MapMarkerChocoboAnimView