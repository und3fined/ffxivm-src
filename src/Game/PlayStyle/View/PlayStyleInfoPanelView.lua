---
--- Author: Administrator
--- DateTime: 2023-10-07 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GoldSauserMgr = require("Game/Gate/GoldSauserMgr")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MainPanelConfig = require("Game/Main/MainPanelConfig")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoRes = require("Protocol/ProtoRes")

local EntertainGameID = ProtoRes.Game.GameID

---@class PlayStyleInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExit UFButton
---@field BtnFold UToggleButton
---@field ImgDown UFImage
---@field ImgPlayStyleType UFImage
---@field ImgTime UFImage
---@field ImgUp UFImage
---@field PanelAvoid UFCanvasPanel
---@field PanelCountDown UFCanvasPanel
---@field PanelGateInfo UFCanvasPanel
---@field PanelGet UFCanvasPanel
---@field PanelGet02 UFCanvasPanel
---@field PanelSummary UFCanvasPanel
---@field RichTextAvoidTime URichTextBox
---@field RichTextGet URichTextBox
---@field RichTextGet02 URichTextBox
---@field TextDescription UFTextBlock
---@field TextSlideTitle CommTextSlideView
---@field TextTime UFTextBlock
---@field TextUntilTime UFTextBlock
---@field AnimGetUpdate UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleInfoPanelView = LuaClass(UIView, true)

function PlayStyleInfoPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExit = nil
	--self.BtnFold = nil
	--self.ImgDown = nil
	--self.ImgPlayStyleType = nil
	--self.ImgTime = nil
	--self.ImgUp = nil
	--self.PanelAvoid = nil
	--self.PanelCountDown = nil
	--self.PanelGateInfo = nil
	--self.PanelGet = nil
	--self.PanelGet02 = nil
	--self.PanelSummary = nil
	--self.RichTextAvoidTime = nil
	--self.RichTextGet = nil
	--self.RichTextGet02 = nil
	--self.TextDescription = nil
	--self.TextSlideTitle = nil
	--self.TextTime = nil
	--self.TextUntilTime = nil
	--self.AnimGetUpdate = nil
	--self.AnimIn = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleInfoPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.TextSlideTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleInfoPanelView:OnInit()
    self.LastCheck = false

    self.Binders = {
        {"ActivityName", UIBinderValueChangedCallback.New(self, nil, self.OnActivityNameChanged)}, -- 标题
        {"ActivityDesc", UIBinderSetText.New(self, self.TextDescription)}, -- 活动描述
        {"ActivityTime", UIBinderSetText.New(self, self.TextTime)}, -- 倒计时
        {"bShowPanelCountdown", UIBinderSetIsVisible.New(self, self.PanelCountDown)}, -- 倒计时是否显示
        {"bShowPanelAvoid", UIBinderSetIsVisible.New(self, self.PanelAvoid)}, -- 显示躲避，目前快刀和喷风用
        {"bAvoidTimesChanged", UIBinderValueChangedCallback.New(self, nil, self.OnAvoidTextChanged)}, -- 躲避次数改变
        {"bShowPanelGet", UIBinderSetIsVisible.New(self, self.PanelGet)}, -- 显示获取金币,目前快刀和喷风用
        {"bDescVisible", UIBinderSetIsVisible.New(self, self.PanelSummary)}, -- 描述文字
        {"bShowBtnQuit", UIBinderSetIsVisible.New(self, self.BtnExit, false, true, true)}, -- 退出按钮
        {"GoldText", UIBinderSetText.New(self, self.RichTextGet)}, -- 获取金币文字
        {"AvoidText", UIBinderSetText.New(self, self.RichTextAvoidTime)}, -- 躲避文字
        {"CountDownTitleText", UIBinderSetText.New(self, self.TextUntilTime)} -- 倒计时标题，目前就2个距离结束，距离开始
    }

    self.PanelBinder = {
        { "FunctionVisible", UIBinderValueChangedCallback.New(self, nil, self.OnFunctionVisibleChanged) },
    }
end

function PlayStyleInfoPanelView:OnFunctionVisibleChanged(NewValue, OldValue)
    if (NewValue == false and self.LastCheck) then
        local NeedCheck = not self.LastCheck
        local bInfoVisible = not NeedCheck
        self.BtnFold:SetIsChecked(NeedCheck)
        self.LastCheck = NeedCheck
        UIUtil.SetIsVisible(self.PanelGateInfo, bInfoVisible)
        if (bInfoVisible) then
            self:PlayAnimation(self.AnimUnfold)
        end
    end
end

function PlayStyleInfoPanelView:OnActivityNameChanged(NewValue, OldValue)
    self.TextSlideTitle:ShowSliderText(NewValue)
end

function PlayStyleInfoPanelView:OnIsBeginChanged()
end

function PlayStyleInfoPanelView:OnDestroy()
end

function PlayStyleInfoPanelView:OnShow()
    UIUtil.SetIsVisible(self.PanelGateInfo, true)

    self.LastCheck = false
    self.BtnFold:SetIsChecked(false)
    MainPanelVM:SetFunctionVisible(false, MainPanelConfig.TopRightInfoType.PlayStyleInfo)
end

function PlayStyleInfoPanelView:OnHide()
end

function PlayStyleInfoPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnFold, self.OnBtnFoldClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnBtnExitClicked)
end

function PlayStyleInfoPanelView:OnBtnExitClicked()
    _G.GoldSauserMgr:OnBtnExitClicked()
end

function PlayStyleInfoPanelView:OnAvoidTextChanged()
    self:PlayAnimation(self.AnimGetUpdate, 0)
end

function PlayStyleInfoPanelView:OnNetEndGame(Msg)
end

function PlayStyleInfoPanelView:OnRegisterGameEvent()
end

function PlayStyleInfoPanelView:OnRegisterBinder()
    self:RegisterBinders(GoldSauserMgr.GoldSauserVM, self.Binders)
    self:RegisterBinders(MainPanelVM, self.PanelBinder)
end

function PlayStyleInfoPanelView:OnBtnFoldClicked()
    local NeedCheck = not self.LastCheck
    local bInfoVisible = not NeedCheck
    self.BtnFold:SetIsChecked(NeedCheck)
    self.LastCheck = NeedCheck
    UIUtil.SetIsVisible(self.PanelGateInfo, bInfoVisible)
    MainPanelVM:SetFunctionVisible(not bInfoVisible, MainPanelConfig.TopRightInfoType.PlayStyleInfo)
    if (bInfoVisible) then
        self:PlayAnimation(self.AnimUnfold)
    end
end

return PlayStyleInfoPanelView
