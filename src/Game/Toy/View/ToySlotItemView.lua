---
--- Author: Administrator
--- DateTime: 2025-07-28 20:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local TimeUtil = require("Utils/TimeUtil")
local DateTimeTools = require("Common/DateTimeTools")
local ToyCfg = require("TableCfg/ToyCfg")
local ItemCfg = require("TableCfg/ItemCfg")

---@class ToySlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot UFButton
---@field ImgEmpty UFImage
---@field ImgFavorite UFImage
---@field ImgHide UImage
---@field ImgIcon UFImage
---@field ImgMask UFImage
---@field ImgNew UFImage
---@field ImgQuality UFImage
---@field ImgSelect UFImage
---@field Img_CD URadialImage
---@field PanelMount UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextCD UFTextBlock
---@field TextDuration UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ToySlotItemView = LuaClass(UIView, true)

function ToySlotItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.ImgEmpty = nil
	--self.ImgFavorite = nil
	--self.ImgHide = nil
	--self.ImgIcon = nil
	--self.ImgMask = nil
	--self.ImgNew = nil
	--self.ImgQuality = nil
	--self.ImgSelect = nil
	--self.Img_CD = nil
	--self.PanelMount = nil
	--self.RedDot = nil
	--self.TextCD = nil
	--self.TextDuration = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ToySlotItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ToySlotItemView:OnInit()
    self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(
        self,
        self.TextCD,
        "mm:ss",
        nil,
        self.TimeOutCallback,
        self.TimeUpdateCallback
    )

    self.Binders = {
        {"ResID", UIBinderValueChangedCallback.New(self, nil, self.OnResIDChanged, nil)},
        {"bSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
        {"bFavorite", UIBinderSetIsVisible.New(self, self.ImgFavorite)},
        {"CD", UIBinderValueChangedCallback.New(self, nil, self.OnCDChanged, nil)},
        {"LastTimeStamp", UIBinderValueChangedCallback.New(self, nil, self.OnLastTimeStampChanged, nil)},
    }
end

function ToySlotItemView:OnLastTimeStampChanged()
    self:InternalRefreshCDStatus()
end

function ToySlotItemView:TimeOutCallback()
    -- 倒计时完了，这里发个消息给主界面
    _G.EventMgr:SendEvent(EventID.ToyCDOver, self.ViewModel.ResID)

    self:InternalRefreshCDStatus()
end

-- 更新倒计时相关
function ToySlotItemView:InternalUpdateCDMask(InLeftTime)
    if (InLeftTime < 0) then
        self.Img_CD:SetPercent(0)
    else
        local Percentage = 1 - (InLeftTime / self.CountDownTime)
        self.Img_CD:SetPercent(Percentage)
    end
    local TimeStr = DateTimeTools.TimeFormat(InLeftTime, "mm:ss", nil)
    self.TextCD:SetText(TimeStr)
    self.TextDuration:SetText(TimeStr)
    return TimeStr
end

function ToySlotItemView:TimeUpdateCallback(InLeftTime)
    return self:InternalUpdateCDMask(InLeftTime)
end

function ToySlotItemView:OnCDChanged(NewValue, OldValue)
    -- CD 发生了改变
    self:InternalRefreshCDStatus()
end

function ToySlotItemView:OnResIDChanged(NewValue, OldValue)
    local ToyDataCfg = ToyCfg:FindCfgByKey(NewValue)
    if (ToyDataCfg == nil) then
        _G.FLOG_ERROR("ToyCfg:FindCfgByKey 错误，无法找到目标，ID : %s", NewValue)
        return
    end

    self.ToyDataCfg = ToyDataCfg

    local IconPath = UIUtil.GetIconPath(ToyDataCfg.Icon)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)

    local ItemTableCfg = ItemCfg:FindCfgByKey(ToyDataCfg.Item)
    if (ItemTableCfg) then
        UIUtil.SetIsVisible(self.ImgQuality, true)
        local QualityIconPath = ItemUtil.GetSlotColorIcon(ToyDataCfg.Item, ItemDefine.ItemSlotType.Item126Slot)
        UIUtil.ImageSetBrushFromAssetPath(self.ImgQuality, QualityIconPath)
    else
        _G.FLOG_ERROR("ItemCfg:FindCfgByKey 错误，无法找到数据，ID是 : %s ，将不显示品质", ToyDataCfg.Item)
        UIUtil.SetIsVisible(self.ImgQuality, false)
    end

    self.TextName:SetText(ToyDataCfg.Name)
end

function ToySlotItemView:OnDestroy()
end

function ToySlotItemView:OnShow()
    self:InternalRefreshCDStatus()
end

function ToySlotItemView:InternalRefreshCDStatus()
    local CurTimeMS = TimeUtil.GetServerLogicTimeMS()
    if (self.ViewModel.LastTimeStamp ~= nil and self.ViewModel.LastTimeStamp > 0 and CurTimeMS < self.ViewModel.LastTimeStamp) then
        -- 显示持续时间
        UIUtil.SetIsVisible(self.Img_CD, false, false)
        UIUtil.SetIsVisible(self.TextCD, false, false)
        UIUtil.SetIsVisible(self.TextDuration, true, false)
        self.AdapterCountDownTime:Start(self.ViewModel.LastTimeStamp, 1, true, true)
        self.CountDownTime = self.ToyDataCfg.EffectiveTime
    elseif (self.ViewModel.CD ~= nil and self.ViewModel.CD > 0 and CurTimeMS < self.ViewModel.CD) then
        -- 显示CD的MASK
        UIUtil.SetIsVisible(self.Img_CD, true, false)
        UIUtil.SetIsVisible(self.TextCD, true, false)
        UIUtil.SetIsVisible(self.TextDuration, false, false)
        self.AdapterCountDownTime:Start(self.ViewModel.CD , 1, true, true)
        self.CountDownTime = self.ToyDataCfg.CDTime
    else
        -- 隐藏CD的MASK
        UIUtil.SetIsVisible(self.Img_CD, false, false)
        UIUtil.SetIsVisible(self.TextCD, false, false)
        UIUtil.SetIsVisible(self.TextDuration, false, false)
    end
end

function ToySlotItemView:OnHide()
end

function ToySlotItemView:OnRegisterUIEvent()
end

function ToySlotItemView:OnRegisterGameEvent()
end

function ToySlotItemView:OnRegisterBinder()
    local Params = self.Params
    if Params == nil then
        return
    end

    self.ViewModel = self.Params.Data
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return ToySlotItemView
