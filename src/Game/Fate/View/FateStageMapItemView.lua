---
--- Author: chunfengluo
--- DateTime: 2023-02-21 10:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local FateStageMapItemVM = require("Game/Fate/VM/FateStageMapItemVM")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ColorUtil = require("Utils/ColorUtil")

local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local ITEM_COLOR_TYPE = ProtoRes.ITEM_COLOR_TYPE

---@class FateStageMapItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTrack UFButton
---@field ImgIcon UFImage
---@field ImgTrackIcon UFImage
---@field PanelTips UFCanvasPanel
---@field TextNPCWaiting UFTextBlock
---@field TextName UFTextBlock
---@field TextProgress UFTextBlock
---@field TextTime UFTextBlock
---@field TimeProgressPanel UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateStageMapItemView = LuaClass(UIView, true)

function FateStageMapItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnTrack = nil
    --self.ImgIcon = nil
    --self.ImgTrackIcon = nil
    --self.PanelTips = nil
    --self.TextNPCWaiting = nil
    --self.TextName = nil
    --self.TextProgress = nil
    --self.TextTime = nil
    --self.TimeProgressPanel = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateStageMapItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateStageMapItemView:OnInit()
    self.LeftTimeAdapterCountDown = UIAdapterCountDown.CreateAdapter(self, self.TextTime, "mm:ss")

    self.Binders = {
        {"EndTimeMS", UIBinderUpdateCountDown.New(self, self.LeftTimeAdapterCountDown, 0.2, true, true)},
        {"TextProgress", UIBinderSetText.New(self, self.TextProgress)},
        {"TargetName", UIBinderSetText.New(self, self.TextName)},
        {"TextWaiting", UIBinderSetText.New(self, self.TextNPCWaiting)},
        {"IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
        {"IsDetailVisible", UIBinderSetIsVisible.New(self, self.TimeProgressPanel)},
        {"IsNPCWaitingVisible", UIBinderSetIsVisible.New(self, self.TextNPCWaiting)},
        {"IsShowTrack", UIBinderSetIsVisible.New(self, self.PanelTrack)},
        {"bSameMap", UIBinderValueChangedCallback.New(self, nil, self.OnDeferentMapChanged)}
    }
end

function FateStageMapItemView:OnDestroy()
end

function FateStageMapItemView:OnShow()
    UIUtil.SetIsVisible(self.ImgIcon, false)

    local ViewModel = self.Params
    self.FateID = ViewModel.FateID

    local MapMarker = self.Params.MapMarker
    local IconPath = MapUtil.GetMapMarkerStateIconPath(MapMarker)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgTrackIcon, IconPath)
end

function FateStageMapItemView:OnHide()
end

function FateStageMapItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnTrack, self.OnClickedFollow)
end

function FateStageMapItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.MapOnRemoveMarker, self.OnGameEventRemoveMarker)
end

function FateStageMapItemView:OnGameEventRemoveMarker(Params)
    local Marker = Params.Marker
    if Marker.FateID == self.FateID then
        _G.FLOG_INFO("[fate] Hide map item view")
        UIViewMgr:HideView(UIViewID.WorldMapMarkerFateStageInfoPanel)
    end
end

function FateStageMapItemView:OnRegisterBinder()
    local Params = self.Params
    if Params == nil then
        return
    end

    if (Params.EndTimeMS == nil) then
        Params.EndTimeMS = 0
    end
    self.ViewModel = FateStageMapItemVM.CreateVM(Params)
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function FateStageMapItemView:OnDeferentMapChanged(NewValue, OldValue)
    if (NewValue) then
        UIUtil.SetColorAndOpacityHex(self.TextNPCWaiting, "D5D5D5FF")
    else
        UIUtil.SetColorAndOpacityHex(self.TextNPCWaiting, "D1906DFF")
    end
end

function FateStageMapItemView:OnClickedFollow()
    local Params = self.Params
    local MapMarker = Params.MapMarker
    if (MapMarker ~= nil) then
        MapMarker:ToggleFollow()
    else
        FLOG_ERROR("错误，无法获取 MapMaker ，请检查")
    end

    UIViewMgr:HideView(UIViewID.WorldMapMarkerFateStageInfoPanel)
end

return FateStageMapItemView
