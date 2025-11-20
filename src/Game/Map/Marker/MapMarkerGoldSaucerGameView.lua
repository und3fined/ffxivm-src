---
--- Author: Alex
--- DateTime: 2025-06-20 19:05
--- Description:金碟游乐场小游戏标记
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSaucerBlessingDefine = require("Game/GoldSaucerMiniGame/GoldSaucerBlessingDefine")
local EBlessingState = GoldSaucerBlessingDefine.EBlessingState

---@class MapMarkerGoldSaucerGameView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgIcon UFImage
---@field ImgSmallIcon UFImage
---@field ImgSmallIcon02 UFImage
---@field ImgTextBG UFImage
---@field PanelAlignment UFCanvasPanel
---@field PanelIconS UFCanvasPanel
---@field PanelIconS02 UFCanvasPanel
---@field PanelTrack UFCanvasPanel
---@field TextName UFTextBlock
---@field AnimNormalLoop UWidgetAnimation
---@field AnimOpenBenedictionLoop UWidgetAnimation
---@field AnimReadyBenedictionLoop UWidgetAnimation
---@field AnimScaleIn UWidgetAnimation
---@field AnimScaleOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerGoldSaucerGameView = LuaClass(UIView, true)

function MapMarkerGoldSaucerGameView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgIcon = nil
	--self.ImgSmallIcon = nil
	--self.ImgSmallIcon02 = nil
	--self.ImgTextBG = nil
	--self.PanelAlignment = nil
	--self.PanelIconS = nil
	--self.PanelIconS02 = nil
	--self.PanelTrack = nil
	--self.TextName = nil
	--self.AnimNormalLoop = nil
	--self.AnimOpenBenedictionLoop = nil
	--self.AnimReadyBenedictionLoop = nil
	--self.AnimScaleIn = nil
	--self.AnimScaleOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerGoldSaucerGameView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerGoldSaucerGameView:OnInit()
	self.Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "IsMarkerVisible", UIBinderSetIsVisible.New(self, self.PanelAlignment) },
		{ "IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange) },
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "BlessState", UIBinderValueChangedCallback.New(self, nil, self.OnBlessStateChange) },
	}
end

function MapMarkerGoldSaucerGameView:OnDestroy()

end

function MapMarkerGoldSaucerGameView:OnShow()

end

function MapMarkerGoldSaucerGameView:OnHide()
	if self.TrackAnimView then
		self.TrackAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.TrackAnimView)
		self.TrackAnimView = nil
	end

	if self.HighlightAnimView then
		self.HighlightAnimView:RemoveFromParent()
		_G.UIViewMgr:RecycleView(self.HighlightAnimView)
		self.HighlightAnimView = nil
	end
end

function MapMarkerGoldSaucerGameView:OnRegisterUIEvent()
	
end

function MapMarkerGoldSaucerGameView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapOnUpdateMarker, self.OnUpdateMarker)
end

function MapMarkerGoldSaucerGameView:OnRegisterBinder()
	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerGoldSaucerGameView:OnUpdateMarker(Params)
	local ParamsMarker = Params.Marker
	if not ParamsMarker then
		return
	end

	local ViewModel = self.Params
	if nil == ViewModel then
		return
	end

	local Marker = ViewModel.MapMarker
	if not Marker then
		return
	end
	if ParamsMarker.ID ~= Marker.ID then
		return
	end
	ViewModel:UpdateVM(ParamsMarker)
end

function MapMarkerGoldSaucerGameView:OnBlessStateChange(NewValue)
	if not NewValue then
		return
	end

	self:StopAnimation(self.AnimNormalLoop)
	self:StopAnimation(self.AnimReadyBenedictionLoop)
	self:StopAnimation(self.AnimOpenBenedictionLoop)

	if NewValue == EBlessingState.InBlessingNormal or NewValue == EBlessingState.InBlessingWarning then
		self:PlayAnimation(self.AnimOpenBenedictionLoop, 0, 0)
	elseif NewValue == EBlessingState.Prepare then
		self:PlayAnimation(self.AnimReadyBenedictionLoop, 0, 0)
	else
		self:PlayAnimation(self.AnimNormalLoop, 0, 0)
	end
end

function MapMarkerGoldSaucerGameView:OnFollowStateChange(NewValue)
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

function MapMarkerGoldSaucerGameView:OnScaleChanged(Scale)
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

function MapMarkerGoldSaucerGameView:PlayHighlightEffect()
	if self.HighlightAnimView == nil then
		local View = MapUtil.CreateHighlightAnimView()
		if self.PanelTrack then
			self.PanelTrack:AddChild(View)
			self.HighlightAnimView = View
		end
	end
	if self.HighlightAnimView then
		self.HighlightAnimView:PlayAnimIn()
	end
end

function MapMarkerGoldSaucerGameView:IsUnderLocation(ScreenPosition)
    return UIUtil.IsUnderLocation(self.ImgIcon, ScreenPosition)
end

return MapMarkerGoldSaucerGameView