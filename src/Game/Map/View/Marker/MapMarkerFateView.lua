---
--- Author: chunfengluo
--- DateTime: 2023-03-31 11:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderCanvasSlotSetPosition = require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local TimeUtil = require("Utils/TimeUtil")
local FateTargetCfgTable = require("TableCfg/FateTargetCfg")

local EventID = _G.EventID

---@class MapMarkerFateView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRegion UFButton
---@field ImgArrow UFImage
---@field ImgFateRange UFImage
---@field ImgFateRange02 UFImage
---@field ImgIcon UFImage
---@field ImgIconFateNpc UFImage
---@field MI_DX_Icon_Fate_1 UFImage
---@field PanelIcon UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field PanelTrack UFCanvasPanel
---@field ProbarFate UFProgressBar
---@field T_DX_Icon_Fate_1 UFImage
---@field AnimIconFatePowerful UWidgetAnimation
---@field AnimIconFateWeak UWidgetAnimation
---@field AnimScaleIn UWidgetAnimation
---@field AnimScaleOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapMarkerFateView = LuaClass(UIView, true)

function MapMarkerFateView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRegion = nil
	--self.ImgArrow = nil
	--self.ImgFateRange = nil
	--self.ImgFateRange02 = nil
	--self.ImgIcon = nil
	--self.ImgIconFateNpc = nil
	--self.MI_DX_Icon_Fate_1 = nil
	--self.PanelIcon = nil
	--self.PanelProbar = nil
	--self.PanelTrack = nil
	--self.ProbarFate = nil
	--self.T_DX_Icon_Fate_1 = nil
	--self.AnimIconFatePowerful = nil
	--self.AnimIconFateWeak = nil
	--self.AnimScaleIn = nil
	--self.AnimScaleOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapMarkerFateView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapMarkerFateView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function MapMarkerFateView:OnTimer()
    if (self.EndTimeMS == nil or self.EndTimeMS <= 0) then
        return
    end
    local CurTimeMS = TimeUtil.GetServerLogicTimeMS()
    local TimeLeft = self.EndTimeMS - CurTimeMS

    if (not self.bPlayedHightMention and TimeLeft < 60000) then -- 进入倒计时1分钟的提示
        UIUtil.SetIsVisible(self.T_DX_Icon_Fate_1, true)
        UIUtil.SetIsVisible(self.MI_DX_Icon_Fate_1, true)
        self.bPlayedHightMention = true
        self:PlayAnimation(self.AnimIconFatePowerful, 0, 0)
    elseif (not self.bPlayedNormalMention and TimeLeft < 120000) then  -- 进入倒计时2分钟的提示
        UIUtil.SetIsVisible(self.T_DX_Icon_Fate_1, true)
        UIUtil.SetIsVisible(self.MI_DX_Icon_Fate_1, true)
        self.bPlayedNormalMention = true
        self:PlayAnimation(self.AnimIconFateWeak, 0, 0)
    end
end

function MapMarkerFateView:OnInit()
    self.Binders = {
        {"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
        {"IconVisibility", UIBinderSetVisibility.New(self, self.PanelIcon)},
        {"ImgIconFateNpcVisible", UIBinderSetIsVisible.New(self, self.ImgIconFateNpc)},
        {"ImgIconFateNpcPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIconFateNpc)},
        {"IsFollow", UIBinderValueChangedCallback.New(self, nil, self.OnFollowStateChange)},
        {"Progress", UIBinderValueChangedCallback.New(self, nil, self.OnProgressChange)},
        {"bHighRisk", UIBinderSetIsVisible.New(self, self.ImgArrow)}
    }
end

function MapMarkerFateView:OnProgressChange(NewValue, OldValue)
    if (NewValue > 0) then
        local ViewModel = self.Params
        local Percentage = NewValue * 0.01
        if (ViewModel ~= nil) then
            local FateID = ViewModel.MapMarker.ID
            local FateTargetCfg = FateTargetCfgTable:FindCfgByKey(FateID)
            if FateTargetCfg then
                if FateTargetCfg.TargetScore ~= nil and FateTargetCfg.TargetScore ~= 0 then
                    Percentage = NewValue / FateTargetCfg.TargetScore
                else
                    Percentage = NewValue * 0.01
                end
            else
                Percentage = NewValue * 0.01
            end            
        end
        self.ProbarFate:SetPercent(Percentage)
        
        UIUtil.SetIsVisible(self.PanelProbar, true)
    else
        UIUtil.SetIsVisible(self.PanelProbar, false)
    end
end

function MapMarkerFateView:OnDestroy()
end

function MapMarkerFateView:OnShow()
    --UIUtil.SetIsVisible(self.FateNpcEffect, false)
    UIUtil.SetIsVisible(self.T_DX_Icon_Fate_1, false)
    UIUtil.SetIsVisible(self.MI_DX_Icon_Fate_1, false)
end

function MapMarkerFateView:OnHide()
    self.bPlayedNormalMention = false -- 进入倒计时2分钟的提示
    self.bPlayedHightMention = false -- 进入倒计时1分钟的提示
    if self.TrackAnimView then
        self.TrackAnimView:RemoveFromParent()
        _G.UIViewMgr:RecycleView(self.TrackAnimView)
        self.TrackAnimView = nil
    end
end

function MapMarkerFateView:OnRegisterUIEvent()
end

function MapMarkerFateView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MapOnUpdateMarker, self.OnUpdateMarker)
end

function MapMarkerFateView:OnRegisterBinder()
    local ViewModel = self.Params
    if nil == ViewModel then
        return
    end
    self.EndTimeMS = ViewModel.EndTimeMS
    self:RegisterBinders(ViewModel, self.Binders)
end

function MapMarkerFateView:OnScaleChanged(Scale)
    self.Scale = Scale
    local ViewModel = self.Params
    if nil == ViewModel then
        return
    end

    local SelfX, SelfY = ViewModel:GetPosition()
    local X, Y = MapUtil.AdjustMapMarkerPosition(Scale, SelfX, SelfY)
    UIUtil.CanvasSlotSetPosition(self, _G.UE.FVector2D(X, Y))

    ---@type MapMarkerFate
	local MapMarker = ViewModel:GetMapMarker()
	if nil == MapMarker then
		return
	end

    local CorrectedFactor = 2
    local MapScale = MapUtil.GetMapScale(MapMarker:GetUIMapID())
    if (MapScale == 200) then
        CorrectedFactor = 8
    end
    local SizeValue = MapMarker:GetRadius() / MapScale * Scale * CorrectedFactor
    local FateID = self.Params.MapMarker.ID
    local bHighRiskFate = _G.FateMgr:IsHighRiskFate(FateID)
    local Size = _G.UE.FVector2D(SizeValue, SizeValue)
    if (bHighRiskFate) then
        UIUtil.SetIsVisible(self.ImgFateRange, false)
        UIUtil.SetIsVisible(self.ImgFateRange02, true)
        UIUtil.CanvasSlotSetSize(self.ImgFateRange02, Size)
    else
        UIUtil.SetIsVisible(self.ImgFateRange, true)
        UIUtil.SetIsVisible(self.ImgFateRange02, false)
        UIUtil.CanvasSlotSetSize(self.ImgFateRange, Size)
    end

    local FateNpcX, FateNpcY = ViewModel:GetFateNpcPosition()
    if FateNpcX ~= 0 and FateNpcY ~= 0 then
        local FateNpcUIX = FateNpcX - SelfX
        local FateNpcUIY = FateNpcY - SelfY
        UIUtil.CanvasSlotSetPosition(self.ImgIconFateNpc, _G.UE.FVector2D(FateNpcUIX * Scale, FateNpcUIY * Scale))
    end
end

function MapMarkerFateView:OnUpdateMarker(Params)
    if Params.Marker.ID == self.Params.MapMarker.ID then
        self:OnScaleChanged(self.Scale)
    end
end

function MapMarkerFateView:IsUnderLocation(ScreenPosition)
    return UIUtil.IsUnderLocation(self.BtnRegion, ScreenPosition)
end

function MapMarkerFateView:OnFollowStateChange(NewValue)
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

return MapMarkerFateView
