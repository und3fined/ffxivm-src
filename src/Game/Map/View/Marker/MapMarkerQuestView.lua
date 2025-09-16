---
--- Author: anypkvcai
--- DateTime: 2023-03-29 16:48
--- Description: 任务标记
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderSetOpacity = require("Binder/UIBinderSetOpacity")
local UIBinderSetZOrder = require("Binder/UIBinderSetZOrder")
local EventID = require("Define/EventID")
local MapVM = require("Game/Map/VM/MapVM")
local MapDefine = require("Game/Map/MapDefine")
local MajorUtil = require("Utils/MajorUtil")

local MapContentType = MapDefine.MapContentType
local ESlateVisibility = _G.UE.ESlateVisibility


---@class MapMarkerQuestView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field ImgSpaceArrow UFImage
---@field ImgTrack UFImage
---@field PanelIcon UFCanvasPanel
---@field PanelTrack UFCanvasPanel
---@field PanelTrackTarget MapTrackView
---@field AnimNew UWidgetAnimation
---@field AnimScaleIn UWidgetAnimation
---@field AnimScaleOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerQuestView = LuaClass(UIView, true)

function MapMarkerQuestView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.ImgSpaceArrow = nil
	--self.ImgTrack = nil
	--self.PanelIcon = nil
	--self.PanelTrack = nil
	--self.PanelTrackTarget = nil
	--self.AnimNew = nil
	--self.AnimScaleIn = nil
	--self.AnimScaleOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerQuestView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PanelTrackTarget)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerQuestView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon, true) },
		{ "IconVisibility", UIBinderSetVisibility.New(self, self.PanelIcon) },
		{ "IsTrackQuest", UIBinderValueChangedCallback.New(self, nil, self.OnIsTrackQuestChange) },
		{ "IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
		{ "Alpha", UIBinderSetOpacity.New(self, self.ImgIcon) },
		{ "Alpha", UIBinderSetOpacity.New(self, self.ImgSpaceArrow) },
		{ "PriorityOrder", UIBinderSetZOrder.New(self, self)},
	}
end

function MapMarkerQuestView:OnDestroy()

end

function MapMarkerQuestView:OnShow()
	UIUtil.SetIsVisible(self.ImgSpaceArrow, false)
end

function MapMarkerQuestView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end
end

function MapMarkerQuestView:OnRegisterUIEvent()

end

function MapMarkerQuestView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapMarkerPlayAnimation, self.OnMapMarkerPlayAnimation)
end

function MapMarkerQuestView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerQuestView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function MapMarkerQuestView:IsUnderLocation(ScreenPosition)
	--return false
	return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerQuestView:OnScaleChanged(Scale)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	MapUtil.SetMapMarkerViewPosition(Scale, ViewModel, self)
end

function MapMarkerQuestView:OnTargetIDChange(NewValue)
	if _G.QuestMainVM.QuestTrackVM then
		if _G.QuestMainVM.QuestTrackVM.CurrTrackQuestVM then
			local TrackTargetID = _G.QuestMainVM.QuestTrackVM.CurrTrackQuestVM.TrackTargetID
			UIUtil.SetIsVisible(self.PanelTrackTarget, NewValue ~= 0 and TrackTargetID == NewValue)
		end
	end
end

function MapMarkerQuestView:OnIsTrackQuestChange(NewValue)
	if NewValue then
		-- 当一个任务有多个目标，追踪中的目标显示外扩特效，另外的目标显示原有发光特效
		if _G.QuestMainVM.QuestTrackVM then
			if _G.QuestMainVM.QuestTrackVM.CurrTrackQuestVM then
				local Major = MajorUtil.GetMajor()
				if Major ~= nil then
                    -- 寻找离自身最近的任务目标
					local MajorPos = Major:FGetLocation(_G.UE.EXLocationType.ServerLoc)
					MajorPos = MajorPos + _G.PWorldMgr:GetWorldOriginLocation()
					local NearestItem = _G.QuestTrackMgr:GetNearestItem(MajorPos)
					if NearestItem then
						local IsTrackTarget = self.Params.TargetID ~= 0 and NearestItem.TargetID == self.Params.TargetID
						UIUtil.SetIsVisible(self.PanelTrackTarget, IsTrackTarget)
						UIUtil.SetIsVisible(self.ImgTrack, not IsTrackTarget)
						return
					end
				end
			end
		end

		-- Exception处理
		UIUtil.SetIsVisible(self.PanelTrackTarget, not NewValue)
		UIUtil.SetIsVisible(self.ImgTrack, NewValue)
	else
		UIUtil.SetIsVisible(self.PanelTrackTarget, NewValue)
		UIUtil.SetIsVisible(self.ImgTrack, NewValue)
	end
end

function MapMarkerQuestView:OnFollowStateChange(NewValue)
	if NewValue then
		if self.TrackAnimView then
			self.TrackAnimView:PlayAnimLoop()
		else
			local View = MapUtil.CreateTrackAnimView()
			if self.PanelTrack then
				self.PanelTrack:AddChild(View)
				self.TrackAnimView = View
				self.TrackAnimView:PlayAnimLoop()
			end
		end
	else
		if self.TrackAnimView then
			self.TrackAnimView:StopAnimLoop()
		end
	end
end

function MapMarkerQuestView:OnMapMarkerPlayAnimation(TargetID)
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if MapMarker and MapMarker.ID == TargetID then
		self:playAnimation(self.AnimNew)
	end
end

function MapMarkerQuestView:OnTimer()
	self:UpdateMarkerView()
end

function MapMarkerQuestView:UpdateMarkerView()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	if ViewModel.IconVisibility == ESlateVisibility.Collapsed then
		-- 标记本身不显示
		return
	end

	local ParentView = self.ParentView
	if nil == ParentView then
		return
	end
	if MapContentType.MiniMap ~= ParentView.ContentType then
		-- 只处理小地图
		return
	end

	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

	local _, _, WorldPoxZ = MapMarker:GetWorldPos()
	local MajorPos = MapVM:GetMajorWorldPosition()
	local MAP_CHECK_MARKER_HEIGHT_DIFF = 1500 -- 参考端游，高度差用15米

	-- 标记位置和主角位置的高度差
	local DiffZ = WorldPoxZ - MajorPos.Z
	local HeightIconPath
	if DiffZ >= MAP_CHECK_MARKER_HEIGHT_DIFF then
		HeightIconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060541.UI_Icon_060541'"
	elseif DiffZ <= (MAP_CHECK_MARKER_HEIGHT_DIFF * -1) then
		HeightIconPath = "Texture2D'/Game/Assets/Icon/MapIconSnap/UI_Icon_060545.UI_Icon_060545'"
	else
		HeightIconPath = nil
	end

	if HeightIconPath then
		UIUtil.SetIsVisible(self.ImgSpaceArrow, true)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgSpaceArrow, HeightIconPath)
	else
		UIUtil.SetIsVisible(self.ImgSpaceArrow, false)
	end
end

return MapMarkerQuestView