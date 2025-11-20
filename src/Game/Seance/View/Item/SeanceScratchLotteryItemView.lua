---
--- Author: Administrator
--- DateTime: 2025-08-01 10:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetItemIcon = require("Binder/UIBinderSetItemIcon")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ScratchSoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Mini_Cactpot/Play_gs_kuji_scratch.Play_gs_kuji_scratch'"
local AudioUtil = require("Utils/AudioUtil")
---@class SeanceScratchLotteryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconReceive UFImage
---@field ImgBGBigPrize UFImage
---@field ImgBGNotOpen1 UFImage
---@field ImgBGNotOpen2 UFImage
---@field ImgBGOpenNormal UFImage
---@field ImgCanOPen UFImage
---@field ImgIcon UFImage
---@field PanelCanOpen UFCanvasPanel
---@field TextCount UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SeanceScratchLotteryItemView = LuaClass(UIView, true)

function SeanceScratchLotteryItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconReceive = nil
	--self.ImgBGBigPrize = nil
	--self.ImgBGNotOpen1 = nil
	--self.ImgBGNotOpen2 = nil
	--self.ImgBGOpenNormal = nil
	--self.ImgCanOPen = nil
	--self.ImgIcon = nil
	--self.PanelCanOpen = nil
	--self.TextCount = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SeanceScratchLotteryItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SeanceScratchLotteryItemView:OnInit()
    self.Binders = {
        {"bGetted", UIBinderValueChangedCallback.New(self, nil, self.OnbGettedChanged)},
        {"bCanGet", UIBinderValueChangedCallback.New(self, nil, self.OnbCanGetChanged)},
        {"bGetBigPrize", UIBinderValueChangedCallback.New(self, nil, self.OnbGetBigPrizeChanged)},
        {"Icon", UIBinderValueChangedCallback.New(self, nil, self.OnIconChanged)},
        {"Num", UIBinderSetText.New(self, self.TextCount)},
    }
end

function SeanceScratchLotteryItemView:OnIconChanged(NewValue, OldValue)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, NewValue)
    if (NewValue and not string.isnilorempty(NewValue)) then
        UIUtil.SetIsVisible(self.ImgIcon, true)
    end
end

function SeanceScratchLotteryItemView:OnbGetBigPrizeChanged(NewValue, OldValue)
    self:InternalRefreshBG()
end

function SeanceScratchLotteryItemView:OnbGettedChanged(NewValue, OldValue)
    self:InternalRefreshBG()
end

function SeanceScratchLotteryItemView:PlayNormalOpenAnim()
    self:StopAnimation(self.AnimNormal)
    self:PlayAnimation(self.AnimOpenNormal)
    AudioUtil.LoadAndPlayUISound(ScratchSoundPath)
end

function SeanceScratchLotteryItemView:PlayBigPrizeOpenAnim()
    self:StopAnimation(self.AnimNormal)
    self:PlayAnimation(self.AnimOpenBigPrize)
    AudioUtil.LoadAndPlayUISound(ScratchSoundPath)
end

function SeanceScratchLotteryItemView:InternalRefreshBG()
    self:PlayAnimation(self.AnimNormal)
    if (self.ViewModel.bGetted) then
        -- 已经获取了
        UIUtil.SetIsVisible(self.TextCount, true)
        UIUtil.SetIsVisible(self.ImgBGNotOpen1, false)
        UIUtil.SetIsVisible(self.ImgBGNotOpen2, false)
        UIUtil.SetIsVisible(self.PanelCanOpen, false)
        UIUtil.SetIsVisible(self.ImgIcon, true)
        UIUtil.SetIsVisible(self.IconReceive, true)
        if (self.ViewModel.bGetBigPrize) then
            UIUtil.SetIsVisible(self.ImgBGBigPrize, true)
            UIUtil.SetIsVisible(self.ImgBGOpenNormal, false)
        else
            UIUtil.SetIsVisible(self.ImgBGBigPrize, false)
            UIUtil.SetIsVisible(self.ImgBGOpenNormal, true)
        end
    else
        UIUtil.SetIsVisible(self.ImgBGBigPrize, false)
        UIUtil.SetIsVisible(self.ImgBGOpenNormal, false)
        UIUtil.SetIsVisible(self.TextCount, false)
        UIUtil.SetIsVisible(self.ImgIcon, false)
        UIUtil.SetIsVisible(self.IconReceive, false)
        -- 关闭着, 这里根据INDEX显示不同的BG
        if (self.ViewModel.SlotIndex % 2 == 0) then
            UIUtil.SetIsVisible(self.ImgBGNotOpen1, false)
            UIUtil.SetIsVisible(self.ImgBGNotOpen2, true)
        else
            UIUtil.SetIsVisible(self.ImgBGNotOpen1, true)
            UIUtil.SetIsVisible(self.ImgBGNotOpen2, false)
        end

        if (self.ViewModel.bCanGet) then
            UIUtil.SetIsVisible(self.PanelCanOpen, true)
        else
            UIUtil.SetIsVisible(self.PanelCanOpen, false)
        end
    end
end

function SeanceScratchLotteryItemView:GetSlotID()
    return self.ViewModel.SlotIndex
end

function SeanceScratchLotteryItemView:OnbCanGetChanged(NewValue, OldValue)
    self:InternalRefreshBG()
end

function SeanceScratchLotteryItemView:OnDestroy()
end

function SeanceScratchLotteryItemView:OnShow()
    self:SetItemTransformBP(self.ViewModel.SlotIndex)
end

function SeanceScratchLotteryItemView:OnHide()
end

function SeanceScratchLotteryItemView:OnRegisterUIEvent()
end

function SeanceScratchLotteryItemView:OnRegisterGameEvent()
end

function SeanceScratchLotteryItemView:OnRegisterBinder()
    if (self.Params == nil) then
        return
    end

    self.ViewModel = self.Params.Data

    self:RegisterBinders(self.ViewModel, self.Binders)
end

return SeanceScratchLotteryItemView
