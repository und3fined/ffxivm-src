---
--- Author: Administrator
--- DateTime: 2023-11-01 09:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EventID = require("Define/EventID")
local CommonUtil = require("Utils/CommonUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local ChocoboRaceMainVM = nil
local ChocoboRaceMgr = nil
local TimeUtil = nil
local FVector2D = nil
local UIViewMgr = nil
local UIViewID = nil

---@class ChocoboRaceMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnQuit UFButton
---@field ButtonGM UFButton
---@field EFF_5 UFCanvasPanel
---@field FTextBlock_67 UFTextBlock
---@field ImgPurpleLine UFImage
---@field ImgWing01 UFImage
---@field ImgWing02 UFImage
---@field ImgWingsLine01 UFImage
---@field ImgWingsLine02 UFImage
---@field ImgWingsLine03 UFImage
---@field ImgWingsLine04 UFImage
---@field MiniMap MiniMapPanelView
---@field Number01 ChocoboRaceNumberItemView
---@field Number02 ChocoboRaceNumberItemView
---@field Number03 ChocoboRaceNumberItemView
---@field Number04 ChocoboRaceNumberItemView
---@field Number05 ChocoboRaceNumberItemView
---@field Number06 ChocoboRaceNumberItemView
---@field Number07 ChocoboRaceNumberItemView
---@field Number08 ChocoboRaceNumberItemView
---@field PanelNumber UFCanvasPanel
---@field PanelPhysical UFCanvasPanel
---@field PanelPlayer UFCanvasPanel
---@field PanelWings01 UFCanvasPanel
---@field PanelWings02 UFCanvasPanel
---@field Panelrank UFCanvasPanel
---@field ProBarPhysical UProgressBar
---@field RaceSkill ChocoboRaceSkillPanelView
---@field TableViewPlayer UTableView
---@field TestSpeed UFTextBlock
---@field TextExcited UFTextBlock
---@field TextHigh UFTextBlock
---@field TextLow UFTextBlock
---@field TextPhysical UFTextBlock
---@field TextTime UFTextBlock
---@field TextTired UFTextBlock
---@field TextureText_UIBP TextureTextView
---@field AnimBegin UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimMiniMapIn UWidgetAnimation
---@field AnimMiniMapOut UWidgetAnimation
---@field AnimPhysicalOut UWidgetAnimation
---@field AnimProBarLight UWidgetAnimation
---@field AnimStatusIn UWidgetAnimation
---@field AnimStatusOut UWidgetAnimation
---@field AnimWings1AreaIn UWidgetAnimation
---@field AnimWings1AreaOut UWidgetAnimation
---@field AnimWings1TriggerOut UWidgetAnimation
---@field AnimWings2AreaIn UWidgetAnimation
---@field AnimWings2AreaOut UWidgetAnimation
---@field AnimWings2TriggerOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRaceMainView = LuaClass(UIView, true)

function ChocoboRaceMainView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnQuit = nil
	--self.ButtonGM = nil
	--self.EFF_5 = nil
	--self.FTextBlock_67 = nil
	--self.ImgPurpleLine = nil
	--self.ImgWing01 = nil
	--self.ImgWing02 = nil
	--self.ImgWingsLine01 = nil
	--self.ImgWingsLine02 = nil
	--self.ImgWingsLine03 = nil
	--self.ImgWingsLine04 = nil
	--self.MiniMap = nil
	--self.Number01 = nil
	--self.Number02 = nil
	--self.Number03 = nil
	--self.Number04 = nil
	--self.Number05 = nil
	--self.Number06 = nil
	--self.Number07 = nil
	--self.Number08 = nil
	--self.PanelNumber = nil
	--self.PanelPhysical = nil
	--self.PanelPlayer = nil
	--self.PanelWings01 = nil
	--self.PanelWings02 = nil
	--self.Panelrank = nil
	--self.ProBarPhysical = nil
	--self.RaceSkill = nil
	--self.TableViewPlayer = nil
	--self.TestSpeed = nil
	--self.TextExcited = nil
	--self.TextHigh = nil
	--self.TextLow = nil
	--self.TextPhysical = nil
	--self.TextTime = nil
	--self.TextTired = nil
	--self.TextureText_UIBP = nil
	--self.AnimBegin = nil
	--self.AnimLoop = nil
	--self.AnimMiniMapIn = nil
	--self.AnimMiniMapOut = nil
	--self.AnimPhysicalOut = nil
	--self.AnimProBarLight = nil
	--self.AnimStatusIn = nil
	--self.AnimStatusOut = nil
	--self.AnimWings1AreaIn = nil
	--self.AnimWings1AreaOut = nil
	--self.AnimWings1TriggerOut = nil
	--self.AnimWings2AreaIn = nil
	--self.AnimWings2AreaOut = nil
	--self.AnimWings2TriggerOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRaceMainView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MiniMap)
	self:AddSubView(self.Number01)
	self:AddSubView(self.Number02)
	self:AddSubView(self.Number03)
	self:AddSubView(self.Number04)
	self:AddSubView(self.Number05)
	self:AddSubView(self.Number06)
	self:AddSubView(self.Number07)
	self:AddSubView(self.Number08)
	self:AddSubView(self.RaceSkill)
	self:AddSubView(self.TextureText_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRaceMainView:OnInit()
    TimeUtil = _G.TimeUtil
    FVector2D = _G.UE.FVector2D
    UIViewMgr = _G.UIViewMgr
    UIViewID = _G.UIViewID
    ChocoboRaceMainVM = _G.ChocoboRaceMainVM
    ChocoboRaceMgr = _G.ChocoboRaceMgr

    self.MaxMovePositionX = 0
    self.ProgressWidgetSizeX = 0
    self.AdpTableViewPlayerList = UIAdapterTableView.CreateAdapter(self, self.TableViewPlayer, nil, nil)
end

function ChocoboRaceMainView:OnDestroy()
end

function ChocoboRaceMainView:OnShow()
    self.TextPhysical:SetText(_G.LSTR(430018))
    self.TextHigh:SetText(_G.LSTR(430019))
    self.TextLow:SetText(_G.LSTR(430020))
    self.TextExcited:SetText(_G.LSTR(430021))
    self.TextTired:SetText(_G.LSTR(430022))
    
    if _G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_GM) then
        UIUtil.SetIsVisible(self.ButtonGM, true, true)
        UIUtil.SetIsVisible(self.TestSpeed, true)
    else
        UIUtil.SetIsVisible(self.ButtonGM, false)
        UIUtil.SetIsVisible(self.TestSpeed, false)
    end
    
    CommonUtil.DisableShowJoyStick(true)
    CommonUtil.HideJoyStick()
    local EndShowTime = LocalizationUtil.GetCountdownTimeForShortTime(0, "mm:ss") or ""
    self.TextTime:SetText(EndShowTime)
    self.MaxMovePositionX = UIUtil.CanvasSlotGetSize(self.Panelrank).x
    self.ProgressWidgetSizeX = UIUtil.CanvasSlotGetSize(self.ProBarPhysical).x
end

function ChocoboRaceMainView:OnHide()
    CommonUtil.DisableShowJoyStick(false)
    CommonUtil.ShowJoyStick()
end

function ChocoboRaceMainView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnQuit, self.OnClickBtnQuit)
    UIUtil.AddOnClickedEvent(self, self.ButtonGM, self.OnButtonGM)
end

function ChocoboRaceMainView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ChocoboRaceGameReady, self.OnGameEventRaceGameReady)
    self:RegisterGameEvent(EventID.ChocoboRaceGameQuerySuc, self.OnGameEventRaceGameQuerySuc)
end

function ChocoboRaceMainView:OnRegisterBinder()
    self.ChocoboBinders = {
        { "StaminaState", UIBinderValueChangedCallback.New(self, nil, self.OnStaminaStateChange) },
        { "StaminaProgress", UIBinderSetPercent.New(self, self.ProBarPhysical) },
        { "StaminaText", UIBinderValueChangedCallback.New(self, nil, self.OnStaminaTextChange) },
        { "Stamina", UIBinderValueChangedCallback.New(self, nil, self.OnStaminaChange) },
        --{ "IsOver", UIBinderValueChangedCallback.New(self, nil, self.OnMajorIsOver) },
    }

    local Binders = {
        { "RacePlayerSortList", UIBinderUpdateBindableList.New(self, self.AdpTableViewPlayerList) },
        { "MajorIndex", UIBinderValueChangedCallback.New(self, nil, self.IndexChange) },
        { "MajorSpeed", UIBinderSetText.New(self, self.TestSpeed) },
        { "IsShowSkillPanel", UIBinderSetIsVisible.New(self, self.RaceSkill) },
        { "IsShowPanelPhysical", UIBinderSetIsVisible.New(self, self.PanelPhysical) },
        { "IsShowPanelPlayer", UIBinderSetIsVisible.New(self, self.PanelPlayer) },
        { "IsShowMiniMap", UIBinderSetIsVisible.New(self, self.MiniMap) },
        { "IsShowPanelPhysical", UIBinderSetIsVisible.New(self, self.PanelPhysical) },
        { "IsShowPanelNumber", UIBinderSetIsVisible.New(self, self.PanelNumber) },
    }
    self:RegisterBinders(ChocoboRaceMainVM, Binders)
end

function ChocoboRaceMainView:OnStaminaChange(NewValue, OldValue)
    if self.ViewModel.IsShow30Mark then
        local Is30Active = NewValue >= 3000 and NewValue <= 3100

        if Is30Active then
            if not self.IsPlayAniWings1 then
                self.IsPlayAniWings1 = true
                self:PlayAnimation(self.AnimWings1AreaIn, 0, 0)
            end
        else
            if self.IsPlayAniWings1 then
                self.IsPlayAniWings1 = false
                if self:IsAnimationPlaying(self.AnimWings1AreaIn) then
                    self:StopAnimation(self.AnimWings1AreaIn)
                end
            end
        end

        UIUtil.SetIsVisible(self.PanelWings01, NewValue >= 3000)
    else
        UIUtil.SetIsVisible(self.PanelWings01, false)
        if self.IsPlayAniWings1 then
            self:StopAnimation(self.AnimWings1AreaIn)
            self.IsPlayAniWings1 = false
        end
    end

    if self.ViewModel.IsShow70Mark then
        local Is70Active = NewValue >= 7000 and NewValue <= 7100

        if Is70Active then
            if not self.IsPlayAniWings2 then
                self.IsPlayAniWings2 = true
                self:PlayAnimation(self.AnimWings2AreaIn, 0, 0)
            end
        else
            if self.IsPlayAniWings2 then
                self.IsPlayAniWings2 = false
                if self:IsAnimationPlaying(self.AnimWings2AreaIn) then
                    self:StopAnimation(self.AnimWings2AreaIn)
                end
            end
        end

        UIUtil.SetIsVisible(self.PanelWings02, NewValue >= 7000)
    else
        UIUtil.SetIsVisible(self.PanelWings02, false)
        if self.IsPlayAniWings2 then
            self:StopAnimation(self.AnimWings2AreaIn)
            self.IsPlayAniWings2 = false
        end
    end


    if NewValue <= ChocoboRaceMgr:GetRacerMaxStamina() * 0.01 or NewValue >= ChocoboRaceMgr:GetRacerMaxStamina() * 0.99 then
        self.EFF_5:SetRenderScale(FVector2D(0, 1))
    else
        if self:IsAnimationPlaying(self.AnimProBarLight) == false and self.ProgressWidgetSizeX > 0 then
            local PosX = NewValue / ChocoboRaceMgr:GetRacerMaxStamina() * self.ProgressWidgetSizeX
            PosX = PosX - (self.ProgressWidgetSizeX * 0.5)
            self.EFF_5:SetRenderScale(FVector2D(1, 1))
            self.EFF_5:SetRenderTranslation(FVector2D(PosX, 0))
        end
    end
end

function ChocoboRaceMainView:OnStaminaTextChange(NewValue)
    self.TextureText_UIBP:SetText(tostring(NewValue))
end

--function ChocoboRaceMainView:OnMajorIsOver(NewValue, OldValue)
--    if NewValue then
--        UIViewMgr:ShowView(UIViewID.ChocoboRaceCountDownView, { Mode = "ARRIVED" })
--        if UIViewMgr:IsViewVisible(UIViewID.ChocoboRaceMainView) then
--            _G.BusinessUIMgr:HideMainPanel(UIViewID.ChocoboRaceMainView)
--        end
--    end
--end

function ChocoboRaceMainView:IndexChange(NewValue, OldValue)
    if nil ~= OldValue then
        local ViewModel = ChocoboRaceMainVM:FindChocoboRaceVM(OldValue)
        if nil ~= ViewModel then
            self:UnRegisterBinders(ViewModel, self.ChocoboBinders)
        end
    end

    if nil ~= NewValue then
        local ViewModel = ChocoboRaceMainVM:FindChocoboRaceVM(NewValue)
        if nil ~= ViewModel then
            self.ViewModel = ViewModel
            self:RegisterBinders(ViewModel, self.ChocoboBinders)
        end
    end
end

function ChocoboRaceMainView:OnGameEventRaceGameReady()
    self:PlayAnimation(self.AnimBegin)
    self:PlayAnimation(self.AnimMiniMapIn)
    self:PlayAnimation(self.AnimLoop, 0, 0)
end

function ChocoboRaceMainView:OnGameEventRaceGameQuerySuc()
    for i = 1, ChocoboRaceMgr.MaxRacerNum do
        local ItemView = self[string.format("Number0%d", i)]
        ItemView:SetIndex(i)
        if ChocoboRaceMgr.ChocoboRacer[i] ~= nil then
            UIUtil.SetIsVisible(ItemView, true)
        else
            UIUtil.SetIsVisible(ItemView, false)
        end
    end
end

function ChocoboRaceMainView:OnStaminaStateChange(Value)
    UIUtil.SetIsVisible(self.TextHigh, Value == ChocoboDefine.STAMINA_STATE_ENUM.ACCELERATION)
    UIUtil.SetIsVisible(self.TextExcited, Value == ChocoboDefine.STAMINA_STATE_ENUM.EXCITED)
    UIUtil.SetIsVisible(self.TextLow, Value == ChocoboDefine.STAMINA_STATE_ENUM.LOW)
    UIUtil.SetIsVisible(self.TextTired, Value == ChocoboDefine.STAMINA_STATE_ENUM.TIRED)
    
    if Value == ChocoboDefine.STAMINA_STATE_ENUM.NORMAL then
        self:PlayAnimation(self.AnimStatusOut)
    else
        self:PlayAnimation(self.AnimStatusIn)
    end
end

function ChocoboRaceMainView:OnButtonGM()
    if UIViewMgr:IsViewVisible(UIViewID.GMMain) then
        UIViewMgr:HideView(UIViewID.GMMain)
    else
        UIViewMgr:ShowView(UIViewID.GMMain)
    end
end

function ChocoboRaceMainView:OnClickBtnQuit()
    local function QuitPworld()
        _G.PWorldMgr:SendLeavePWorld()
    end

    MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(430014), _G.LSTR(430015), QuitPworld)
end

function ChocoboRaceMainView:OnAnimationFinished(Anim)
    if Anim == self.AnimBegin then
        self:PlayAnimation(self.AnimProBarLight)
    end
end

function ChocoboRaceMainView:OnRegisterTimer()
    self:RegisterTimer(self.OnTimer, 0, 0.1, 0)
end

function ChocoboRaceMainView:OnTimer()
    if ChocoboRaceMgr.GoTime <= 0 then
        return
    end

    if TimeUtil.GetServerTime() - ChocoboRaceMgr.GoTime <= 0 then
        return
    end
    
    local ElapsedTime = math.ceil(TimeUtil.GetServerTime() - ChocoboRaceMgr.GoTime)
    ElapsedTime = ElapsedTime > 0 and ElapsedTime or 0
    if ElapsedTime <= 0 then
        return 
    end

    local EndShowTime = LocalizationUtil.GetCountdownTimeForShortTime(ElapsedTime, "mm:ss") or ""
    self.TextTime:SetText(EndShowTime)

    local VMList = ChocoboRaceMainVM:GetChocoboRaceVMList()
    for __, ItemVM in ipairs(VMList) do
        local ItemView = self[string.format("Number0%d", ItemVM.Index)]
        if ItemView ~= nil then
            if ItemVM.IsMajor then
                UIUtil.CanvasSlotSetZOrder(ItemView, ChocoboRaceMgr.MaxRacerNum)
                ItemView:ShowImgArrow(true)
            else
                UIUtil.CanvasSlotSetZOrder(ItemView, ChocoboRaceMgr.MaxRacerNum - ItemVM.Rank)
                ItemView:ShowImgArrow(false)
            end

            if ItemVM.Progress >= 100 then
                ItemView:PlayAnimReach()
            else
                UIUtil.CanvasSlotSetPosition(ItemView, FVector2D(ItemVM.Progress / 100 * self.MaxMovePositionX, 0))
            end
        else
            _G.FLOG_ERROR("ChocoboRaceMainView:GetChocoboRaceVMList ItemView is nil Index  = %d", ItemVM.Index)
        end
    end
end

return ChocoboRaceMainView