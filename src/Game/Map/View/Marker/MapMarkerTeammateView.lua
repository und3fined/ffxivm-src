---
--- Author: anypkvcai
--- DateTime: 2023-12-12 10:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MathUtil = require("Utils/MathUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local MapVM = require("Game/Map/VM/MapVM")
local TeamHelper = require("Game/Team/TeamHelper")
local PWorldMgr = require("Game/PWorld/PWorldMgr")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")

local MapConstant = MapDefine.MapConstant
local MapContentType = MapDefine.MapContentType
local MAP_PANEL_HALF_WIDTH = MapConstant.MAP_PANEL_HALF_WIDTH
local RADIUS = MapConstant.MAP_RADIUS
local ESlateVisibility = _G.UE.ESlateVisibility
local ViewPosition = _G.UE.FVector2D()


---@class MapMarkerTeammateView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgDirection UFImage
---@field ImgIcon UFImage
---@field PanelMarker UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerTeammateView = LuaClass(UIView, true)

function MapMarkerTeammateView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgDirection = nil
	--self.ImgIcon = nil
	--self.PanelMarker = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerTeammateView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerTeammateView:OnInit()
	self.Scale = 1

	self.Binders = {
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.PanelMarker) },
		{ "IsMarkerVisible", UIBinderSetIsVisible.New(self, self.ImgIcon) },
		{ "IsMarkerVisible", UIBinderSetIsVisible.New(self, self.ImgDirection, true) },
	}
end

function MapMarkerTeammateView:OnDestroy()

end

function MapMarkerTeammateView:OnShow()
	UIUtil.SetIsVisible(self.ImgDirection, false)
	self:UpdateMarkerView()
end

function MapMarkerTeammateView:OnHide()

end

function MapMarkerTeammateView:OnRegisterUIEvent()

end

function MapMarkerTeammateView:OnRegisterGameEvent()

end

function MapMarkerTeammateView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerTeammateView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function MapMarkerTeammateView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.ImgIcon, ScreenPosition)
end

function MapMarkerTeammateView:OnScaleChanged(Scale)
	self.Scale = Scale

	self:UpdateMarkerView()
end

function MapMarkerTeammateView:OnTimer()
	self:UpdateMarkerView()
end

function MapMarkerTeammateView:UpdateMarkerView()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	if ViewModel.IconVisibility == ESlateVisibility.Collapsed then
		-- 标记本身不显示
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	local ParentView = self.ParentView
	if nil == ParentView then
		return
	end

	if MapContentType.MiniMap ~= ParentView.ContentType then
		-- 【大地图】
		if MapMarker.RoleID then
			--[[
			判断队友图标是否显示：
			（1）判断队友位置数据是否存在
			（2）判断队友所在MapID不是当前查看UIMapID的MapID。这个判断消耗小
			（3）如果当前查看地图是主角当前所在地图，则进一步判断队友副本实例ID是否和主角副本实例ID相同
			（4）判断队友所在UIMapID是否当前查看UIMapID。这个判断消耗更高，会通过队友pos来计算实际所在的UIMapID，主要解决同个地图有多层的情况
			--]]
			local MemberLocation = TeamHelper.GetTeamMgr():GetTeamMemberNetPositionInfoByRoleID(MapMarker.RoleID)
			if MemberLocation == nil then
				UIUtil.SetIsVisible(self.PanelMarker, false)
				return
			end
			local MarkerMapID = MapUtil.GetMapID(MapMarker:GetUIMapID())
			if MemberLocation.MapID ~= MarkerMapID then
				UIUtil.SetIsVisible(self.PanelMarker, false)
				return
			end
			if MarkerMapID == PWorldMgr:GetCurrMapResID() then
				if MemberLocation.SceneInstID ~= PWorldMgr:GetCurrPWorldInstID() then
					UIUtil.SetIsVisible(self.PanelMarker, false)
					return
				end
			end
			local MemberUIMapID = _G.MapAreaMgr:GetUIMapIDByLocation(MemberLocation.Pos, MemberLocation.MapID)
			if MemberUIMapID ~= MapMarker:GetUIMapID() then
				UIUtil.SetIsVisible(self.PanelMarker, false)
				return
			end

		elseif MapMarker.EntityID then
			-- 剧情AI队友没有RoleID
			local MemberUIMapID = 0
			local _, _, _, Location = MapMarker:GetWorldPos()
			if Location then
				MemberUIMapID = _G.MapAreaMgr:GetUIMapIDByLocation(Location, _G.MapMgr:GetMapID())
			end
			if MemberUIMapID ~= MapMarker:GetUIMapID() then
				UIUtil.SetIsVisible(self.PanelMarker, false)
				return
			end
		end

		UIUtil.SetIsVisible(self.PanelMarker, true)

		local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, ViewModel:GetPosition())
		ViewPosition.X = X
		ViewPosition.Y = Y
		UIUtil.CanvasSlotSetPosition(self, ViewPosition)
		ViewModel:SetIsShowMarker(true)
		self.PanelMarker:SetRenderTransformAngle(0)
		return
	end

	-- 【小地图】
	-- 根据视野内队友pos计算实际所在的UIMapID，如果队友UIMapID和当前UIMapID不同则隐藏队友标记
	local MemberUIMapID = 0
	local _, _, _, Location = MapMarker:GetWorldPos()
	if Location then
		MemberUIMapID = _G.MapAreaMgr:GetUIMapIDByLocation(Location, _G.MapMgr:GetMapID())
	end
	if MemberUIMapID ~= _G.MapMgr:GetUIMapID() then
		UIUtil.SetIsVisible(self.PanelMarker, false)
		return
	end

	local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, ViewModel:GetPosition())
	local MajorPos = MapVM:GetMajorPosition()

	local OffsetX = X - MAP_PANEL_HALF_WIDTH - MajorPos.X
	local OffsetY = Y - MAP_PANEL_HALF_WIDTH - MajorPos.Y

	if X == 0 and Y == 0 then
		UIUtil.SetIsVisible(self.PanelMarker, false)
	else
		UIUtil.SetIsVisible(self.PanelMarker, true)
	end

	if math.abs(OffsetX) > RADIUS or math.abs(OffsetY) > RADIUS then
		ViewPosition.X = MAP_PANEL_HALF_WIDTH + MajorPos.X
		ViewPosition.Y = MAP_PANEL_HALF_WIDTH + MajorPos.Y
		UIUtil.CanvasSlotSetPosition(self, ViewPosition)

		ViewModel:SetIsShowMarker(false)
		local Angle = MathUtil.GetAngle(OffsetX, OffsetY)
		self.PanelMarker:SetRenderTransformAngle(Angle)
	else
		ViewPosition.X = X
		ViewPosition.Y = Y
		UIUtil.CanvasSlotSetPosition(self, ViewPosition)

		ViewModel:SetIsShowMarker(true)
		self.PanelMarker:SetRenderTransformAngle(0)
	end
end

return MapMarkerTeammateView