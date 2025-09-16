---
--- Author: sammrli
--- DateTime: 2024-02-26 20:07
--- Description:运输陆行鸟地图主界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")

local MapVM = require("Game/Map/VM/MapVM")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")

local EventID = require("Define/EventID")
local MapDefine = require("Game/Map/MapDefine")

local MapUICfg = require("TableCfg/MapUICfg")

local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local UE = _G.UE

local UIMapMinScale = MapDefine.MapConstant.MAP_SCALE_MIN
local UIMapMaxScale = MapDefine.MapConstant.MAP_SCALE_MAX

---@class ChocoboTransportMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnWeather_1 UFButton
---@field MapContent ChocoboTransportMapContentView
---@field MapScalePanel_1 WorldMapScaleItemView
---@field TextCoordinate UFTextBlock
---@field TextCoordinate_1 UFTextBlock
---@field WeatherTimeBar_1 WeatherTimeBarItemView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTransportMainPanelView = LuaClass(UIView, true)

function ChocoboTransportMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnWeather_1 = nil
	--self.MapContent = nil
	--self.MapScalePanel_1 = nil
	--self.TextCoordinate = nil
	--self.TextCoordinate_1 = nil
	--self.WeatherTimeBar_1 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTransportMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.MapContent)
	self:AddSubView(self.MapScalePanel_1)
	self:AddSubView(self.WeatherTimeBar_1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTransportMainPanelView:OnInit()
	self.CurrentNpcID = 0
	self.PointList = nil

	self.Binder = {
		{ "MapScale", UIBinderSetSlider.New(self, self.MapScalePanel_1.Slider) },
		{ "MapScale", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangeSetProgressBar) },
	}

	self.MapScalePanel_1:UpdateSlider(UIMapMinScale, UIMapMaxScale)
end

function ChocoboTransportMainPanelView:OnDestroy()
end

function ChocoboTransportMainPanelView:OnShow()
	self.CurrentNpcID = 0
	if self.Params then
		local NpcResID = self.Params[2]
		if NpcResID then
			local NpcEditData = _G.MapEditDataMgr:GetNpc(NpcResID)
			if NpcEditData then
				self.CurrentNpcID = NpcEditData.NpcID
			end
		end
	end

	local CurrentMapResID = _G.PWorldMgr:GetCurrMapResID()
	local UIMapID = MapUtil.GetUIMapID(CurrentMapResID)
	_G.WorldMapMgr:ChangeMap(UIMapID, CurrentMapResID, false)

	self.TextCoordinate_1:SetText("")
	local Position = MapVM:GetMajorLeftTopPosition()
	local InfoText = string.format("%s  %s", MapUtil.GetCoordinateText(Position), MapUtil.GetMapFullName())

	local CurrLineID = _G.PWorldMgr:GetCurrPWorldLineID()
	if CurrLineID > 0 then
		InfoText = string.format("%s（%02d）", InfoText, CurrLineID)
	end
	self.TextCoordinate:SetText(InfoText)

	_G.ChocoboTransportMgr:SetCurrentInteractiveNpcID(self.CurrentNpcID)

	_G.ChocoboTransportMgr:ClearLastRequestInfo()

end

function ChocoboTransportMainPanelView:OnHide()
	self.PointList = nil
	self.MapContent.MovePath_UIBP:Clear()
	_G.WorldMapMgr:ResetUIMapInfo()
end

function ChocoboTransportMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnValueChangedEvent(self, self.MapScalePanel_1.Slider, self.OnValueChangedScale)
	UIUtil.AddOnClickedEvent(self, self.MapScalePanel_1.BtnAdd, self.OnClickedBtnScaleAdd)
	UIUtil.AddOnClickedEvent(self, self.MapScalePanel_1.BtnSub, self.OnClickedBtnScaleSub)
end

function ChocoboTransportMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateChocoboTransportNpcBookStatus, self.OnUpdateChocoboTransports)
	self:RegisterGameEvent(EventID.UpdateChocoboTransportFindPath, self.OnUpdateFindPath)
	self:RegisterGameEvent(EventID.ChocoboTransportBegin, self.OnGameEventChocoboTransportBegin)
end

function ChocoboTransportMainPanelView:OnRegisterBinder()
	self:RegisterBinders(WorldMapVM, self.Binder)
end

function ChocoboTransportMainPanelView:UpdateFindPathPosition(Position)
	UIUtil.CanvasSlotSetPosition(self.MapContent.MovePath_UIBP, Position)
end

function ChocoboTransportMainPanelView:UpdateFindPath()
	if not self.PointList then
		return
	end

	local Points = UE.TArray(UE.FVector2D)
	local MapID = _G.PWorldMgr:GetCurrMapResID()
	local UIMapID = MapUtil.GetUIMapID(MapID)
	local Scale = self.MapContent.RenderScale.X
	local Cfg = MapUICfg:FindCfgByKey(UIMapID)
	if Cfg then
		local MapScale = Cfg.Scale
		local MapOffsetX = Cfg.OffsetX
		local MapOffsetY = Cfg.OffsetY
		for i=1, #self.PointList do
			local Point = self.PointList[i].point_data
			local UIX, UIY = MapUtil.ConvertMapPos2UI(Point.X, Point.Y, MapOffsetX, MapOffsetY, MapScale, true)
			local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, UIX, UIY)
			Points:Add(UE.FVector2D(X, Y))
		end
	end

	self.MapContent.MovePath_UIBP:DrawLine(Points)
end

function ChocoboTransportMainPanelView:OnValueChangedScale(_, Value)
	_G.WorldMapMgr:OnMapScaleChange(Value)
end

function ChocoboTransportMainPanelView:OnClickedBtnScaleAdd()
	local Value = self.MapScalePanel_1.Slider:GetValue()
	local NewValue = Value + 0.2
	NewValue = math.clamp(NewValue, UIMapMinScale, UIMapMaxScale)
	_G.WorldMapMgr:OnMapScaleChange(NewValue)
end

function ChocoboTransportMainPanelView:OnClickedBtnScaleSub()
	local Value = self.MapScalePanel_1.Slider:GetValue()
	local NewValue = Value - 0.2
	NewValue = math.clamp(NewValue, UIMapMinScale, UIMapMaxScale)
	_G.WorldMapMgr:OnMapScaleChange(NewValue)
end

function ChocoboTransportMainPanelView:OnValueChangeSetProgressBar(Value)
	self.MapScalePanel_1.ProgressBar:SetPercent((Value - UIMapMinScale) / (UIMapMaxScale - UIMapMinScale))
end

function ChocoboTransportMainPanelView:OnUpdateChocoboTransports()
	--[[
	if self.CurrentNpcID > 0 then
		local MapID = PWorldMgr:GetCurrMapResID()
		if not ChocoboTransportMgr:IsBook(MapID, self.CurrentNpcID) then
			ChocoboTransportMgr:SendChocoboTransferBook(MapID, self.CurrentNpcID)
			return
		end
	end
	]]
	self.MapContent:UpdateChocoboStableMarkers()
end

function ChocoboTransportMainPanelView:OnUpdateFindPath(PointList)
	self.PointList = PointList
	self:UpdateFindPath()
end

function ChocoboTransportMainPanelView:OnGameEventChocoboTransportBegin()
	self:Hide()
end

return ChocoboTransportMainPanelView