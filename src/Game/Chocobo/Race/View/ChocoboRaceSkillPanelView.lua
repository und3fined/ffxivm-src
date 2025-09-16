---
--- Author: Administrator
--- DateTime: 2023-11-01 14:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ChocoboRaceSkillDisplayCfg = require("TableCfg/ChocoboRaceSkillDisplayCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ChocoboUiIconCfg = require("TableCfg/ChocoboUiIconCfg")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EventID = require("Define/EventID")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local ChocoboRaceUtil = require("Game/Chocobo/Race/ChocoboRaceUtil")

local ChocoboRaceMgr = _G.ChocoboRaceMgr

---@class ChocoboRaceSkillPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBox UFButton
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field IconBox UFImage
---@field IconBoxMask UFImage
---@field ImgBox UFImage
---@field PanelBox UFCanvasPanel
---@field PanelSkill UFCanvasPanel
---@field ScaleBoxAppear UScaleBox
---@field SkillChocoboAttackBtn SkillChocoboAttackBtnView
---@field SkillItem01 ChocoboRaceSkillItemView
---@field SkillItem02 ChocoboRaceSkillItemView
---@field SkillItem03 ChocoboRaceSkillItemView
---@field SkillSprintMountUpBtn SkillSprintMountUpBtnView
---@field TextBoxAppear UFTextBlock
---@field TextNumber UFTextBlock
---@field AnimBoxHide UWidgetAnimation
---@field AnimBoxShow UWidgetAnimation
---@field AnimHide UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRaceSkillPanelView = LuaClass(UIView, true)

function ChocoboRaceSkillPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBox = nil
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.IconBox = nil
	--self.IconBoxMask = nil
	--self.ImgBox = nil
	--self.PanelBox = nil
	--self.PanelSkill = nil
	--self.ScaleBoxAppear = nil
	--self.SkillChocoboAttackBtn = nil
	--self.SkillItem01 = nil
	--self.SkillItem02 = nil
	--self.SkillItem03 = nil
	--self.SkillSprintMountUpBtn = nil
	--self.TextBoxAppear = nil
	--self.TextNumber = nil
	--self.AnimBoxHide = nil
	--self.AnimBoxShow = nil
	--self.AnimHide = nil
	--self.AnimIn = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRaceSkillPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SkillChocoboAttackBtn)
	self:AddSubView(self.SkillItem01)
	self:AddSubView(self.SkillItem02)
	self:AddSubView(self.SkillItem03)
	self:AddSubView(self.SkillSprintMountUpBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRaceSkillPanelView:OnInit()
    self.LeftPressTimer = 0
    self.RightPressTimer = 0
    self.SprintPressTimer = 0
    rawset(self, "LongClickTimerID", nil)
end

function ChocoboRaceSkillPanelView:OnDestroy()

end

function ChocoboRaceSkillPanelView:OnShow()
    UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Btn_Attack, true, true)
    UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Img_CD, false)
    UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Text_SkillCD, false)
    self.SkillChocoboAttackBtn:SetDisabled(false)
end

function ChocoboRaceSkillPanelView:OnHide()

end

function ChocoboRaceSkillPanelView:OnRegisterUIEvent()
    UIUtil.AddOnPressedEvent(self, self.SkillSprintMountUpBtn.BtnRun, self.OnPressedBtnJump)
    UIUtil.AddOnReleasedEvent(self, self.SkillSprintMountUpBtn.BtnRun, self.OnReleasedBtnJump)

    UIUtil.AddOnPressedEvent(self, self.SkillChocoboAttackBtn.Btn_Attack, self.OnPressedBtnSprint)
    UIUtil.AddOnReleasedEvent(self, self.SkillChocoboAttackBtn.Btn_Attack, self.OnReleasedBtnSprint)
    
    UIUtil.AddOnPressedEvent(self, self.BtnRight, self.OnPressedBtnRight)
    UIUtil.AddOnReleasedEvent(self, self.BtnRight, self.OnReleasedBtnRight)
    
    UIUtil.AddOnPressedEvent(self, self.BtnLeft, self.OnPressedBtnLeft)
    UIUtil.AddOnReleasedEvent(self, self.BtnLeft, self.OnReleasedBtnLeft)
    
    UIUtil.AddOnPressedEvent(self, self.BtnBox, self.OnBtnBoxPressed)
    UIUtil.AddOnReleasedEvent(self, self.BtnBox, self.OnBtnBoxReleased)
end

function ChocoboRaceSkillPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ChocoboRaceGameBegin, self.OnGameEventRaceGameBegin)
    self:RegisterGameEvent(EventID.ChocoboRaceGameGoal, self.OnGameEventRaceGameGoal)
end

function ChocoboRaceSkillPanelView:OnRegisterBinder()
    self.ViewMode = _G.ChocoboRaceMainVM
    local Binders = {
        { "IsShowTreasureTips", UIBinderValueChangedCallback.New(self, nil, self.OnShowTreasureTips) },
        { "ItemID", UIBinderValueChangedCallback.New(self, nil, self.OnItemIDChange) },
        { "IsShowItemMask", UIBinderSetIsVisible.New(self, self.IconBoxMask) },
        { "IsShowItemCount", UIBinderSetIsVisible.New(self, self.TextNumber) },
        { "ItemCountText", UIBinderSetText.New(self, self.TextNumber) },
    }
    self:RegisterBinders(self.ViewMode, Binders)
end

function ChocoboRaceSkillPanelView:OnShowTreasureTips(NewValue, OldValue)
    if NewValue then
        self:PlayAnimation(self.AnimBoxShow)
    else
        self:PlayAnimation(self.AnimBoxHide)
    end
end

function ChocoboRaceSkillPanelView:OnGameEventRaceGameBegin()
    self:PlayAnimation(self.AnimShow)
end

function ChocoboRaceSkillPanelView:OnGameEventRaceGameGoal()
    self:PlayAnimation(self.AnimHide)
end

function ChocoboRaceSkillPanelView:OnAnimationFinished(Animation)
    if Animation == self.AnimHide then
        UIUtil.SetIsVisible(self.PanelSkill, false)
    end
end

function ChocoboRaceSkillPanelView:OnItemIDChange(NewValue, OldValue)
    local IconPath = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.DEFAULT_EMPTY_ITEM)
    local SkillCfg = ChocoboRaceSkillDisplayCfg:FindCfgByKey(NewValue)
    if SkillCfg ~= nil then
        IconPath = SkillCfg.Icon
    end
    UIUtil.ImageSetBrushFromAssetPath(self.IconBox, IconPath)
end

function ChocoboRaceSkillPanelView:OnPressedBtnJump()
    local Racer = _G.ChocoboRaceMgr:GetRacerByIndex()
    if Racer == nil then return end

    Racer:SetKeyJump(true)
    _G.ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbilityJump)
end

function ChocoboRaceSkillPanelView:OnReleasedBtnJump()
    local Racer = _G.ChocoboRaceMgr:GetRacerByIndex()
    if Racer == nil then return end

    Racer:SetKeyJump(false)
end

function ChocoboRaceSkillPanelView:OnPressedBtnSprint()
    local Racer = ChocoboRaceMgr:GetRacerByIndex()
    if Racer == nil then return end
    
    Racer:SetKeyUp(true)
    ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbilityAcc, true)
end

function ChocoboRaceSkillPanelView:OnReleasedBtnSprint()
    local Racer = ChocoboRaceMgr:GetRacerByIndex()
    if Racer == nil then return end
    
    Racer:SetKeyUp(false)
    ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbilityAcc, false)
end

function ChocoboRaceSkillPanelView:OnPressedBtnRight()
    local Racer = ChocoboRaceMgr:GetRacerByIndex()
    if Racer == nil then return end

    Racer:SetKeyRight(true)
    ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamRight, true)
end

function ChocoboRaceSkillPanelView:OnReleasedBtnRight()
    local Racer = ChocoboRaceMgr:GetRacerByIndex()
    if Racer == nil then return end
    
    Racer:SetKeyRight(false)
    ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamRight, false)
end

function ChocoboRaceSkillPanelView:OnPressedBtnLeft()
    local Racer = ChocoboRaceMgr:GetRacerByIndex()
    if Racer == nil then return end

    Racer:SetKeyLeft(true)
    ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamLeft, true)
end

function ChocoboRaceSkillPanelView:OnReleasedBtnLeft()
    local Racer = ChocoboRaceMgr:GetRacerByIndex()
    if Racer == nil then return end
    
    Racer:SetKeyLeft(false)
    ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamLeft, false)
end

function ChocoboRaceSkillPanelView:OnLongClick()
    if not self.ViewMode then
        return
    end

    local ItemID = self.ViewMode:GetItemID()
    self.SkillTipsHandle = ChocoboRaceUtil.ShowSkillTips(ItemID, self.BtnBox)
end

function ChocoboRaceSkillPanelView:OnLongClickReleased()
    if self.SkillTipsHandle then
        _G.SkillTipsMgr:HideTipsByHandleID(self.SkillTipsHandle)
        self.SkillTipsHandle = nil
    end
end

function ChocoboRaceSkillPanelView:StartLongClickTimer()
    local LongClickTimerID = rawget(self, "LongClickTimerID")
    if LongClickTimerID then
        self:UnRegisterTimer(LongClickTimerID)
    end

    self.StartLongClickTime = _G.UE.UTimerMgr:Get().GetLocalTimeMS()
    LongClickTimerID = self:RegisterTimer(self.OnLongClick, SkillCommonDefine.SkillTipsClickTime, 1, 1)
    rawset(self, "LongClickTimerID", LongClickTimerID)
end

function ChocoboRaceSkillPanelView:StopLongClickTimer()
    local LongClickTimerID = rawget(self, "LongClickTimerID")
    if LongClickTimerID then
        self:OnLongClickReleased()
        self:UnRegisterTimer(LongClickTimerID)
        rawset(self, "LongClickTimerID", nil)
    end
end

function ChocoboRaceSkillPanelView:OnBtnBoxPressed()
    if not self.ViewMode then
        return
    end

    local ItemID = self.ViewMode:GetItemID()
    if ItemID <= 0 then
        return
    end

    self:StartLongClickTimer()
end

function ChocoboRaceSkillPanelView:OnBtnBoxReleased()
    if rawget(self, "LongClickTimerID") then
        local CurTime = _G.UE.UTimerMgr:Get().GetLocalTimeMS()
        if CurTime - self.StartLongClickTime > SkillCommonDefine.SkillTipsClickTime * 1000 then
            self:StopLongClickTimer()
            self:OnLongClickReleased()
            return
        else
            self:StopLongClickTimer()
        end
    end

    self:OnCastBox()
end


function ChocoboRaceSkillPanelView:OnCastBox()
    if not self.ViewMode then
        return
    end
    
    if self.ViewMode.IsItemSeal then
        return
    end
    
    if self.ViewMode.IsItemDisable then
        return
    end

    local ItemID = self.ViewMode:GetItemID()
    if ItemID > 0 then
        ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbilityItem, true, false)
        ChocoboRaceMgr:GetRacerByIndex():PlayActionTimeLineMonTage(ProtoRes.CHOCOBO_ACTION_TIMELINE_TYPE.EXD_ACTION_TIMELINE_CHOCOBORACE_ITEM)
    end
end


return ChocoboRaceSkillPanelView