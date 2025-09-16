---
--- Author: Administrator
--- DateTime: 2023-11-01 15:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local TimerMgr = nil
local ChocoboRaceMainVM = nil

---@class ChocoboRacePlayerInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ChocoboAvatar ChocoboRaceAvatarItemView
---@field ImgRank UFImage
---@field ImgRankDown UFImage
---@field ImgRankLight UFImage
---@field ImgRankUp UFImage
---@field ProBarPhysical UProgressBar
---@field RaceNumber ChocoboRaceNumberItemView
---@field TableViewBuff UTableView
---@field TextNameBlue UFTextBlock
---@field TextNameRed UFTextBlock
---@field TextNameWhite UFTextBlock
---@field TextRemainder UFTextBlock
---@field AnimRankDownLoop UWidgetAnimation
---@field AnimRankUpLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRacePlayerInfoItemView = LuaClass(UIView, true)

function ChocoboRacePlayerInfoItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ChocoboAvatar = nil
	--self.ImgRank = nil
	--self.ImgRankDown = nil
	--self.ImgRankLight = nil
	--self.ImgRankUp = nil
	--self.ProBarPhysical = nil
	--self.RaceNumber = nil
	--self.TableViewBuff = nil
	--self.TextNameBlue = nil
	--self.TextNameRed = nil
	--self.TextNameWhite = nil
	--self.TextRemainder = nil
	--self.AnimRankDownLoop = nil
	--self.AnimRankUpLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRacePlayerInfoItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ChocoboAvatar)
	self:AddSubView(self.RaceNumber)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRacePlayerInfoItemView:OnInit()
    ChocoboRaceMainVM = _G.ChocoboRaceMainVM
    TimerMgr = _G.TimerMgr
    self.DurationTimerID = 0
    self.TableViewAdapterEffect = UIAdapterTableView.CreateAdapter(self, self.TableViewBuff, nil, true)
end

function ChocoboRacePlayerInfoItemView:OnDestroy()

end

function ChocoboRacePlayerInfoItemView:OnShow()
    UIUtil.SetIsVisible(self.ImgRankDown, false)
    UIUtil.SetIsVisible(self.ImgRankUp, false)

    if self.ItemVM then
        self.RaceNumber:SetIndex(self.ItemVM.Index or 0)
        self.RaceNumber:ShowImgArrow(false)
    end
end

function ChocoboRacePlayerInfoItemView:OnHide()
    if self.DurationTimerID ~= 0 then
        TimerMgr:CancelTimer(self.DurationTimerID)
        self.DurationTimerID = 0
    end
end

function ChocoboRacePlayerInfoItemView:OnRegisterUIEvent()

end

function ChocoboRacePlayerInfoItemView:OnRegisterGameEvent()

end

function ChocoboRacePlayerInfoItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    self.ItemVM = ViewModel
    
    local PanelBinders =
    {
        { "Name", UIBinderSetText.New(self, self.TextNameBlue) },
        { "Name", UIBinderSetText.New(self, self.TextNameWhite) },
        { "Name", UIBinderSetText.New(self, self.TextNameRed) },
        { "IsShowTextNameBlue", UIBinderSetIsVisible.New(self, self.TextNameBlue) },
        { "IsShowTextNameWhite", UIBinderSetIsVisible.New(self, self.TextNameWhite) },
        { "IsShowTextNameRed", UIBinderSetIsVisible.New(self, self.TextNameRed) },
        { "StaminaText", UIBinderSetText.New(self, self.TextRemainder) },
        { "StaminaProgress", UIBinderSetPercent.New(self, self.ProBarPhysical) },
        { "IsShowImgRankLight", UIBinderSetIsVisible.New(self, self.ImgRankLight) },
        { "IsShowImgRank", UIBinderSetIsVisible.New(self, self.ImgRank) },
        { "IsOver", UIBinderSetIsVisible.New(self, self.ChocoboAvatar.PanelAvatar01, true) },
        { "IsOver", UIBinderSetIsVisible.New(self, self.ChocoboAvatar.PanelAvatar02) },
        { "Color", UIBinderSetColorAndOpacity.New(self, self.ChocoboAvatar.ImgColor) },
        { "Color", UIBinderSetColorAndOpacity.New(self, self.ChocoboAvatar.ImgColor02) },
        { "EffectList", UIBinderUpdateBindableList.New(self, self.TableViewAdapterEffect) },
        { "IsOver", UIBinderValueChangedCallback.New(self, nil, self.OnGameIsOver) },
        { "Rank", UIBinderValueChangedCallback.New(self, nil, self.RankChange) },
        { "OtherRankPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgRank) },
        { "MajorRankPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgRankLight) },
    }
    self:RegisterBinders(self.ItemVM, PanelBinders)
end

function ChocoboRacePlayerInfoItemView:RankChange(NewValue, OldValue)
    if OldValue then
        if self.DurationTimerID ~= 0 then
            TimerMgr:CancelTimer(self.DurationTimerID)
            self.DurationTimerID = 0
        end
        self.DurationTimerID = TimerMgr:AddTimer(self, self.OnDurationTimer, 1)
        
        if NewValue > OldValue then
            UIUtil.SetIsVisible(self.ImgRankDown, true)
            UIUtil.SetIsVisible(self.ImgRankUp, false)
            self:PlayAnimation(self.AnimRankDownLoop, 0, 0)
        else
            UIUtil.SetIsVisible(self.ImgRankDown, false)
            UIUtil.SetIsVisible(self.ImgRankUp, true)
            self:PlayAnimation(self.AnimRankUpLoop, 0, 0)
        end
    end
end

function ChocoboRacePlayerInfoItemView:OnDurationTimer()
    if self.DurationTimerID ~= 0 then
        TimerMgr:CancelTimer(self.DurationTimerID)
        self.DurationTimerID = 0
    end
    UIUtil.SetIsVisible(self.ImgRankDown, false)
    UIUtil.SetIsVisible(self.ImgRankUp, false)
    self:StopAnimation(self.AnimRankDownLoop)
    self:StopAnimation(self.AnimRankUpLoop)
end

function ChocoboRacePlayerInfoItemView:OnGameIsOver(NewValue)
    if not NewValue then return end
    
    if self.ItemVM.IsMajor then
        UIUtil.SetIsVisible(self.ImgRankLight, false)
        UIUtil.SetIsVisible(self.ImgRank, true)
        UIUtil.ImageSetBrushFromAssetPathSync(self.ImgRank, self.ItemVM.MajorRankPath)
    end
end

return ChocoboRacePlayerInfoItemView