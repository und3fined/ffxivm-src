---
--- Author: Administrator
--- DateTime: 2024-08-28 14:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local EventID = require("Define/EventID")
local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
local FateModelParamCfg = require("TableCfg/FateModelParamCfg")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR

---@class FateArchiveEventNewTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field HorizontalText UFHorizontalBox
---@field ImgChallenge UFImage
---@field ImgEventState UFImage
---@field ImgFinish UFImage
---@field ImgMonster UFImage
---@field ImgMountBG UFImage
---@field PanelText UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---@field SwitcherStateBg UFWidgetSwitcher
---@field TextDoing UFTextBlock
---@field TextEventInfo UFTextBlock
---@field TextLevel UFTextBlock
---@field TextUnlock UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimSwitcherNormalBg UWidgetAnimation
---@field AnimSwitcherSelectBg UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveEventNewTabItemView = LuaClass(UIView, true)

function FateArchiveEventNewTabItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Btn = nil
    --self.HorizontalText = nil
    --self.ImgChallenge = nil
    --self.ImgEventState = nil
    --self.ImgFinish = nil
    --self.ImgMonster = nil
    --self.ImgMountBG = nil
    --self.PanelText = nil
    --self.RedDot2 = nil
    --self.SwitcherStateBg = nil
    --self.TextDoing = nil
    --self.TextEventInfo = nil
    --self.TextLevel = nil
    --self.TextUnlock = nil
    --self.AnimIn = nil
    --self.AnimSwitcherNormalBg = nil
    --self.AnimSwitcherSelectBg = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveEventNewTabItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.RedDot2)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveEventNewTabItemView:OnInit()
    UIUtil.SetIsVisible(self.ImgNormalBg, true)
    UIUtil.SetIsVisible(self.ImgSelectBg, false)
    local Binders = {
        {"FateLevel", UIBinderSetText.New(self, self.TextLevel)},
        {"FateName", UIBinderSetText.New(self, self.TextEventInfo)},
        {"FateTypeIcon", UIBinderSetImageBrush.New(self, self.ImgEventState)},
        {"bShowDoingText", UIBinderSetIsVisible.New(self, self.ImgChallenge)},
        {"bShowUpperPart", UIBinderSetIsVisible.New(self, self.HorizontalText)},
        {"bIsNew", UIBinderValueChangedCallback.New(self, nil, self.OnIsNewChanged)},
        {"bFinish", UIBinderSetIsVisible.New(self, self.ImgFinish)},
        {"ID", UIBinderValueChangedCallback.New(self, nil, self.OnIDChanged)},
        {"bSelected", UIBinderValueChangedCallback.New(self, nil, self.OnSelectedChanged)},
    }
    self.Binders = Binders
end

function FateArchiveEventNewTabItemView:OnSelectedChanged(NewValue, OldValue)
    if (NewValue == true) then
        UIUtil.SetIsVisible(self.ImgNormalBg, false)
        UIUtil.SetIsVisible(self.ImgSelectBg, true)
    else
        UIUtil.SetIsVisible(self.ImgNormalBg, true)
        UIUtil.SetIsVisible(self.ImgSelectBg, false)
    end
end

function FateArchiveEventNewTabItemView:OnIDChanged(NewValue, OldValue)
    self:InternalSetDataAfterFateIDChanged(NewValue)
end

function FateArchiveEventNewTabItemView:OnIsNewChanged(NewValue, OldValue)
    UIUtil.SetIsVisible(self.RedDot2, NewValue)
    self.RedDot2.ItemVM:SetIsVisible(NewValue)
end

function FateArchiveEventNewTabItemView:OnDestroy()
end

function FateArchiveEventNewTabItemView:InternalSetDataAfterFateIDChanged(InFateID)
    self.FateID = InFateID or 0
    local ModelData = FateModelParamCfg:FindCfgByKey(self.FateID)
    local MonsterIcon = nil

    if (ModelData ~= nil) then
        MonsterIcon = ModelData.MonsterSmallIcon
        local Scale = ModelData.FirstPanelPicScale
        local Scale2D = _G.UE.FVector2D(Scale, Scale)
        self.ImgMonster:SetRenderScale(Scale2D)
        local BGPath = ModelData.MonsterTabBGIcon or FateMgr.DefaultMonsterTabBGIcon
        UIUtil.ImageSetBrushFromAssetPath(self.ImgMountBG, BGPath)
    else
        self.ImgMonster:SetRenderScale(_G.UE.FVector2D(1, 1))
        _G.FLOG_ERROR("无法获取 FateModelParamCfg 数据, ID是 : %s", self.FateID)
        local BGPath = FateMgr.DefaultMonsterTabBGIcon
        UIUtil.ImageSetBrushFromAssetPath(self.ImgMountBG, BGPath)
        MonsterIcon = _G.FateMgr:GetUnknownIcon()
    end

    local FateInfo = _G.FateMgr:GetFateInfo(self.FateID)
    local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
    if (MonsterIcon == nil or MonsterIcon == "") then
        MonsterIcon = _G.FateMgr:GetUnknownIcon()
    end
    UIUtil.ImageSetBrushFromAssetPath(self.ImgMonster, MonsterIcon)

    if FateInfo == nil and (not FateArchiveMainVM.bForceShowAll) then
        -- 还没有打的
        UIUtil.ImageSetColorAndOpacityHex(self.ImgMonster, _G.FateMgr:GetUnknownMonsterIconColor())
    else
        -- 已经打了
        UIUtil.ImageSetColorAndOpacityHex(self.ImgMonster, "ffffffff")
    end
end

function FateArchiveEventNewTabItemView:OnShow()
    if (self.IsSelected == true) then
        self:StopAnimation(self.AnimShow)
    else
        self:PlayAnimation(self.AnimShow)
    end

    -- 这里去根据表格去设置一下模型图片缩放
    if (self.Params ~= nil and self.Params.Data) then
        local FateID = self.Params.Data.ID
        self:InternalSetDataAfterFateIDChanged(FateID)
    else
        self.ImgMonster:SetRenderScale(_G.UE.FVector2D(1, 1))
    end

    self.RedDot2:SetText(LSTR(10030))
end

function FateArchiveEventNewTabItemView:OnHide()
end

function FateArchiveEventNewTabItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickButtonItem)
end

function FateArchiveEventNewTabItemView:OnRegisterGameEvent()
end

function FateArchiveEventNewTabItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

function FateArchiveEventNewTabItemView:OnClickButtonItem()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end

    Adapter:OnItemClicked(self, Params.Index)

    local ViewModel = self.Params.Data
    if nil == ViewModel then
        return
    end

    if (self.Params ~= nil and self.Params.Data ~= nil) then
        _G.FateMgr:ClearNewTriggerFateByFateID(self.Params.Data.ID)
    end
end

function FateArchiveEventNewTabItemView:OnSelectChanged(IsSelected)
    if (IsSelected) then
        self.IsSelected = true
        self:StopAnimation(self.AnimShow)
        self:StopAnimation(self.AnimSwitcherNormalBg)
        self:PlayAnimation(self.AnimSwitcherSelectBg)
    else
        self.IsSelected = false
        self:StopAnimation(self.AnimShow)
        self:StopAnimation(self.AnimSwitcherSelectBg)
        self:PlayAnimation(self.AnimSwitcherNormalBg)
    end
end

return FateArchiveEventNewTabItemView
