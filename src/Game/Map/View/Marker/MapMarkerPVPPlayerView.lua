---
--- Author: peterxie
--- DateTime:
--- Description: PVP地图玩家标记，PVP地图水晶bnpc也用了此蓝图
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local MapVM = require("Game/Map/VM/MapVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetProfIconSimple2nd = require("Binder/UIBinderSetProfIconSimple2nd")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local ViewPosition = _G.UE.FVector2D()
local ViewScale = _G.UE.FVector2D()


---@class MapMarkerPVPPlayerView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBgTips UFImage
---@field ImgCamara UFImage
---@field ImgCrystal2 UFImage
---@field ImgJob UFImage
---@field ImgJob1 UFImage
---@field ImgJob2 UFImage
---@field ImgJobBg UFImage
---@field ImgJobBg2 UFImage
---@field ImgJobMe UFImage
---@field ImgJobSelect UFImage
---@field ImgJobSelectBg UFImage
---@field PanelJob UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerPVPPlayerView = LuaClass(UIView, true)

function MapMarkerPVPPlayerView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.PanelIcon = nil
	--AUTO GENERATED CODE 1 END, PLEAS.E DON'T MODIFY
end

function MapMarkerPVPPlayerView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerPVPPlayerView:OnInit()
	self.Scale = 1

	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgJobBg) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.PanelMarker) },
		{ "IsSelected", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsSelected) },
		--{ "IsSelected", UIBinderSetIsVisible.New(self, self.ImgJobSelected) }, --TODO
		{ "TipsContent", UIBinderSetText.New(self, self.RichTextContent) },

		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgJobBg2) },
	}

	self.MajorBinders = {
		{ "MajorRotationAngle", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMajorRotationAngle) },
		{ "CameraRotationAngle", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCameraRotationAngle) },
		{ "MajorLeftTopPosition", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMajorPosition)},
	}

	self.TeamMemberBinders = {
		{ "ProfID", UIBinderSetProfIconSimple2nd.New(self, self.ImgJob) },
		{ "ProfID", UIBinderSetProfIconSimple2nd.New(self, self.ImgJob2) },
	}

	-- 旧版先隐藏
	if self.PanelSelect then
		UIUtil.SetIsVisible(self.PanelSelect, false)
	end
end

function MapMarkerPVPPlayerView:OnDestroy()

end

function MapMarkerPVPPlayerView:OnShow()
	self:SetProfIcon()
	self:UpdateMarkerView()

	-- 将标记缩小显示
	ViewScale.X = 0.5
	ViewScale.Y = 0.5
	self.PanelMarker:SetRenderScale(ViewScale)
end

function MapMarkerPVPPlayerView:OnHide()

end

function MapMarkerPVPPlayerView:OnRegisterUIEvent()

end

function MapMarkerPVPPlayerView:OnRegisterGameEvent()

end

function MapMarkerPVPPlayerView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	---@type MapMarkerPVPPlayer
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)

	if MapMarker.IsMajor then
		self:RegisterBinders(MapVM, self.MajorBinders)
	end

	if MapMarker.MemberVM then
		self:RegisterBinders(MapMarker.MemberVM, self.TeamMemberBinders)
	end
end

function MapMarkerPVPPlayerView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function MapMarkerPVPPlayerView:IsUnderLocation(ScreenPosition)
	return UIUtil.IsUnderLocation(self.PanelJob, ScreenPosition)
end

function MapMarkerPVPPlayerView:OnScaleChanged(Scale)
	self.Scale = Scale
end

function MapMarkerPVPPlayerView:SetProfIcon()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	-- 主角表现有差异
	UIUtil.SetIsVisible(self.ImgJobMe, MapMarker.IsMajor)
	UIUtil.SetIsVisible(self.ImgCamara, MapMarker.IsMajor)

	-- 高亮选中
	UIUtil.SetIsVisible(self.PanelTips, false)
end

-- PVP地图水晶bnpc，使用PVP地图玩家标记蓝图，原因是水晶和玩家一样可以被选
function MapMarkerPVPPlayerView:SetMonsterIcon()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	---@type MapMarkerMonster
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	if not MapMarker.IsColosseumCrystal then
		return
	end

	-- 水晶表现有差异
	UIUtil.SetIsVisible(self.ImgJobMe, false)
	UIUtil.SetIsVisible(self.ImgCamara, false)
	UIUtil.SetIsVisible(self.ImgJob, false)

	-- 高亮选中
	UIUtil.SetIsVisible(self.PanelTips, false)
end

-- 主角朝向
function MapMarkerPVPPlayerView:OnValueChangedMajorRotationAngle(Value)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self.ImgJobMe:SetRenderTransformAngle(Value - 90)
end

-- 主角相机朝向
function MapMarkerPVPPlayerView:OnValueChangedCameraRotationAngle(Value)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self.ImgCamara:SetRenderTransformAngle(Value)
end

-- 主角位置
function MapMarkerPVPPlayerView:OnValueChangedMajorPosition(MajorLeftTopPosition)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local Scale = ViewModel:GetScale()
	ViewPosition.X = MajorLeftTopPosition.X * Scale
	ViewPosition.Y = MajorLeftTopPosition.Y * Scale
	UIUtil.CanvasSlotSetPosition(self, ViewPosition)
end

function MapMarkerPVPPlayerView:OnTimer()
	self:UpdateMarkerView()
end

function MapMarkerPVPPlayerView:UpdateMarkerView()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	-- 其他玩家位置定时更新，主角位置更新方式和小地图保持一致
	if MapMarker.IsMajor then
		-- 小地图缩放时，重新计算位置
		local Scale = ViewModel:GetScale()
		local X, Y = ViewModel:GetPosition()
		ViewPosition.X = X * Scale
		ViewPosition.Y = Y * Scale
		UIUtil.CanvasSlotSetPosition(self, ViewPosition)
		return
	end

	if ViewModel:GetIsMarkerVisible() then
		local Scale = ViewModel:GetScale()
		local X, Y = MapUtil.AdjustMapMarkerPosition(self.Scale, ViewModel:GetPosition())
		ViewPosition.X = X * Scale
		ViewPosition.Y = Y * Scale
		UIUtil.CanvasSlotSetPosition(self, ViewPosition)
	end
end

function MapMarkerPVPPlayerView:UpdateMarkerViewScale(Scale)
	ViewScale.X = Scale
	ViewScale.Y = Scale
	self.PanelMarker:SetRenderScale(ViewScale)
end

function MapMarkerPVPPlayerView:OnValueChangedIsSelected(IsSelected)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	UIUtil.SetIsVisible(self.PanelTips, IsSelected)
	local RoleID = ViewModel.MapMarker and ViewModel.MapMarker.RoleID
	local IsPlayer = RoleID and RoleID > 0
	UIUtil.SetIsVisible(self.ImgCrystal2, not IsPlayer)
	UIUtil.SetIsVisible(self.ImgJobBg2, IsPlayer)
	UIUtil.SetIsVisible(self.ImgJob2, IsPlayer)
end
return MapMarkerPVPPlayerView