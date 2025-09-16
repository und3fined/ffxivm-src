---
--- Author: Administrator
--- DateTime: 2024-01-18 20:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetText =  require("Binder/UIBinderSetText")

local FishCfg = require("TableCfg/FishCfg")
local ItemVM = require("Game/Item/ItemVM")

---@class FishNewSlotItem126pxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field FishSlot UFCanvasPanel
---@field ImgCheck UFImage
---@field ImgIcon UFImage
---@field ImgMask UFImage
---@field ImgQuality UFImage
---@field ImgSelect UFImage
---@field ImgUnknown UFImage
---@field TextNum UFTextBlock
---@field AnimNew UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNewSlotItem126pxView = LuaClass(UIView, true)

function FishNewSlotItem126pxView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnClick = nil
    --self.FishSlot = nil
    --self.ImgCheck = nil
    --self.ImgIcon = nil
    --self.ImgMask = nil
    --self.ImgQuality = nil
    --self.ImgSelect = nil
    --self.ImgUnknown = nil
    --self.TextNum = nil
    --self.AnimNew = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNewSlotItem126pxView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNewSlotItem126pxView:OnInit()
    self.ItemVM = nil

    self.Binder = {
        {"IsMask", UIBinderSetIsVisible.New(self, self.ImgMask, false, true)},
        {"IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect, false, true)},
        {"IsShowNum", UIBinderSetIsVisible.New(self, self.TextNum, false, true)},
        {"Num", UIBinderSetText.New(self, self.TextNum)},
        {"Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon)},
        {"IsSelectTick", UIBinderSetIsVisible.New(self, self.ImgCheck, false, true)}
    }
end

function FishNewSlotItem126pxView:OnDestroy()
end

function FishNewSlotItem126pxView:OnShow()
    -- 自动选中当前正在使用的鱼饵
    local ItemVM = self.ItemVM
    if ItemVM then
        if ItemVM.IsSelectTick then
            self:SetItemSelected(true)
        end
    end
end

function FishNewSlotItem126pxView:OnHide()
    -- 清理被选中的鱼饵的选中状态
    local ItemVM = self.ItemVM
    if ItemVM then
        if ItemVM.IsSelect then
            self:SetItemSelected(false)
        end
    end
end

function FishNewSlotItem126pxView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnBtnClick)
end

function FishNewSlotItem126pxView:SetBtClickCallback(InCallbackView, InCallbackFunc)
    self.CallbackView = InCallbackView
    self.CallbackFunc = InCallbackFunc
end

function FishNewSlotItem126pxView:OnBtnClick()
    if (self.CallbackFunc ~= nil) then
        self.CallbackFunc(self.CallbackView, self.ItemVM, self)
    else
        local ItemTipsUtil = require("Utils/ItemTipsUtil")
        ItemTipsUtil.ShowTipsByResID(self.ItemVM.AwardID, self)
    end
end

function FishNewSlotItem126pxView:OnRegisterGameEvent()
end

function FishNewSlotItem126pxView:OnRegisterBinder()
    local Params = self.Params
    local ViewModel = nil

    if nil ~= Params then
        ViewModel = Params.Data
    end

    if ViewModel then
        self.ItemVM = ViewModel
    end

    if not self.ItemVM then
        self.ItemVM = ItemVM.New()
    end

    self:RegisterBinders(self.ItemVM, self.Binder)
end

function FishNewSlotItem126pxView:FishReleaseTipInfoInit(FishID, FishCount)
    local Cfg = FishCfg:FindCfgByKey(FishID)
    local ItemID = 0
    if FishID > 0 then
        ItemID = Cfg and Cfg.ItemID or 0
    end
    self.ItemVM:UpdateVM({ResID = ItemID, Num = FishCount})
end

function FishNewSlotItem126pxView:SetItemSelected(bSelected)
    -- self.ItemVM:OnSelectedChange(bSelected)
    self.ItemVM.IsSelect = bSelected
end

function FishNewSlotItem126pxView:PlayAnimationNew()
    self:PlayAnimation(self.AnimNew)
end

return FishNewSlotItem126pxView
