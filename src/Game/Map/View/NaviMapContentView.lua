---
--- Author: anypkvcai
--- DateTime: 2023-03-13 19:11
--- Description:
---

local LuaClass = require("Core/LuaClass")
local MapContentView = require("Game/Map/View/MapContentView")
local MapVM = require("Game/Map/VM/MapVM")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local EventID = require("Define/EventID")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")
local UIBinderSetMaterialScalarParameterValue = require("Binder/UIBinderSetMaterialScalarParameterValue")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local MapMgr = _G.MapMgr


---@class NaviMapContentView : MapContentView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonCurve_UIBP CommonCurveView
---@field ImgBG UFImage
---@field ImgMap UFImage
---@field ImgMask UFImage
---@field ImgMiniMapBg UFImage
---@field MovePath_UIBP MovePathView
---@field PanelMap UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NaviMapContentView = LuaClass(MapContentView, true)

function NaviMapContentView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonCurve_UIBP = nil
	--self.ImgBG = nil
	--self.ImgMap = nil
	--self.ImgMask = nil
	--self.ImgMiniMapBg = nil
	--self.MovePath_UIBP = nil
	--self.PanelMap = nil
	--self.PanelMarker = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.Parent = nil
end

function NaviMapContentView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonCurve_UIBP)
	self:AddSubView(self.MovePath_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NaviMapContentView:OnInit()
	self.Super:OnInit()

	self.Binders = {
		{ "MapPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgMap, false, true, true) },
		{ "IsMaskVisible", UIBinderSetIsVisible.New(self, self.ImgMask)},
		{ "MaskPath", UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgMask, "Mask")},
		{ "DiscoveryFlag", UIBinderSetMaterialScalarParameterValue.New(self, self.ImgMask, "DiscoveryFlag")},

		{ "MarkerTextVisible", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerTextVisible) },

		{ "MarkerIconVisible", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible) },
		{ "MapCrystalIconVisible", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible) },
		{ "MapQuestShowType", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible) },
		{ "MapWildBoxVisible", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible, MapDefine.MapMarkerType.Gameplay) },
		{ "MapAetherCurrentVisible", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible, MapDefine.MapMarkerType.Gameplay) },
		{ "MapDiscoverNoteVisible", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMarkerIconVisible, MapDefine.MapMarkerType.Gameplay) },
	}

	_G.MapMarkerMgr:CreateProviders(self.ContentType)
end

function NaviMapContentView:OnDestroy()
	_G.MapMarkerMgr:ReleaseProviders(self.ContentType)
end

function NaviMapContentView:OnShow()
	self:OnGameEventMapChanged()
	self:UpdateChocoboTransportLine()
end

function NaviMapContentView:OnHide()
	self:ReleaseAllMarker()
	self.MovePath_UIBP:Clear()
end

function NaviMapContentView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()

	self:RegisterGameEvent(EventID.MapChanged, self.OnGameEventMapChanged)
	self:RegisterGameEvent(EventID.UpdateFogInfo, self.OnGameEventUpdateFogInfo)
	self:RegisterGameEvent(EventID.ChocoboTransportStartMove, self.OnGameEventChocoboTransportStartMove)
	self:RegisterGameEvent(EventID.ChocoboTransportFinish, self.OnGameEventChocoboTransportFinish)
	self:RegisterGameEvent(EventID.UpdateChocoboTransportPosition, self.OnGameEventUpdateChocoboTransportPosition)

	self:RegisterGameEvent(EventID.UpdateQuest, self.OnGameEventUpdateQuest)
	self:RegisterGameEvent(EventID.MapMarkerPriorityUpdate, self.OnGameEventMapMarkerPriorityUpdate)

end

function NaviMapContentView:OnRegisterBinder()
	self:RegisterBinders(MapVM, self.Binders)
end

function NaviMapContentView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function NaviMapContentView:OnTimer()
	_G.MapMarkerMgr:CheckVisionMarkerOnTimer(self.ContentType)
end

function NaviMapContentView:OnGameEventMapChanged()
	self:CreateAllMarkers(MapMgr:GetUIMapID(), MapMgr:GetMapID())
end

function NaviMapContentView:OnGameEventUpdateFogInfo()
	self:UpdateMarkerByFogInfo()
end

function NaviMapContentView:OnGameEventUpdateQuest(Params) 
	if Params.UpdatedRspQuests ~= nil then
		self:UpdateMarkerByOpenFlag()
	end
end

function NaviMapContentView:OnGameEventMapMarkerPriorityUpdate(Params)
	self:UpdateMarkerPriority()
end

function NaviMapContentView:OnGameEventChocoboTransportStartMove()
	self:UpdateChocoboTransportLine()
end

function NaviMapContentView:OnGameEventChocoboTransportFinish()
	self:UpdateChocoboTransportLine()
end

function NaviMapContentView:OnGameEventUpdateChocoboTransportPosition()
	self.MovePath_UIBP:UpdateProgress()
end

function NaviMapContentView:SetParent(Parent)
	self.Parent = Parent
end

function NaviMapContentView:OnCreateMarker(Marker, View)
	if MapUtil.IsQuestTargetBPType(Marker:GetBPType()) then
		self.Parent:AddChild(View)
		return
	end

	self.Super:OnCreateMarker(Marker, View)
end

function NaviMapContentView:SetContentPosition(Position)
	UIUtil.CanvasSlotSetPosition(self.PanelMap, Position)
	UIUtil.CanvasSlotSetPosition(self.PanelMarker, Position)
	UIUtil.CanvasSlotSetPosition(self.MovePath_UIBP, Position)
end

-- 更新陆行鸟运输路线（运输中显示）
function NaviMapContentView:UpdateChocoboTransportLine()
	if _G.ChocoboTransportMgr:GetIsTransporting() then
		local UIPoints = _G.ChocoboTransportMgr:GetUIMovePointList(MapMgr:GetUIMapID(), 1)
		self.MovePath_UIBP:DrawLine(UIPoints)
	else
		self.MovePath_UIBP:Clear()
	end
end

return NaviMapContentView