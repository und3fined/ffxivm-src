---
--- Author: Administrator
--- DateTime: 2023-11-01 15:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoCS = require("Protocol/ProtoCS")
local ChocoboRaceMgr = _G.ChocoboRaceMgr
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local ChocoboRaceUtil = require("Game/Chocobo/Race/ChocoboRaceUtil")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

---@class ChocoboRaceSkillItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkill UFButton
---@field IconMask UFImage
---@field IconSkill UFImage
---@field IconSkillSwitcOff UFImage
---@field IconSkillSwitcOn UFImage
---@field ImgCD URadialImage
---@field ImgSlot UFImage
---@field PanelConsume UFCanvasPanel
---@field PanelSkill UFCanvasPanel
---@field TextCD UFTextBlock
---@field TextNum UFTextBlock
---@field TopPanel UFCanvasPanel
---@field AnimCD UWidgetAnimation
---@field AnimCDFinish UWidgetAnimation
---@field AnimReleaseFail UWidgetAnimation
---@field AnimReleaseSuccess UWidgetAnimation
---@field AnimSprintLoop UWidgetAnimation
---@field AnimSprintLoopStop UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRaceSkillItemView = LuaClass(UIView, true)

function ChocoboRaceSkillItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSkill = nil
	--self.IconMask = nil
	--self.IconSkill = nil
	--self.IconSkillSwitcOff = nil
	--self.IconSkillSwitcOn = nil
	--self.ImgCD = nil
	--self.ImgSlot = nil
	--self.PanelConsume = nil
	--self.PanelSkill = nil
	--self.TextCD = nil
	--self.TextNum = nil
	--self.TopPanel = nil
	--self.AnimCD = nil
	--self.AnimCDFinish = nil
	--self.AnimReleaseFail = nil
	--self.AnimReleaseSuccess = nil
	--self.AnimSprintLoop = nil
	--self.AnimSprintLoopStop = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRaceSkillItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRaceSkillItemView:OnInit()
    rawset(self, "LongClickTimerID", nil)
end

function ChocoboRaceSkillItemView:OnDestroy()

end

function ChocoboRaceSkillItemView:OnShow()
end

function ChocoboRaceSkillItemView:OnHide()

end

function ChocoboRaceSkillItemView:OnRegisterUIEvent()
    UIUtil.AddOnPressedEvent(self, self.BtnSkill, self.OnPressed)
    UIUtil.AddOnReleasedEvent(self, self.BtnSkill, self.OnReleased)
end

function ChocoboRaceSkillItemView:OnRegisterGameEvent()

end

function ChocoboRaceSkillItemView:OnRegisterBinder()
    local Binders = {
        { "IsVisible", UIBinderSetIsVisible.New(self, self.PanelSkill) },
        { "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconSkill) },
        { "NormalCDPercent", UIBinderSetPercent.New(self, self.ImgCD) },
        { "bNormalCD", UIBinderSetIsVisible.New(self, self.ImgCD) },
        { "SkillCDText", UIBinderSetText.New(self, self.TextCD) },
        { "IsShowLimitDash", UIBinderSetIsVisible.New(self, self.TopPanel) },
        { "IsLimitDash", UIBinderSetIsVisible.New(self, self.IconSkillSwitcOn) },
        { "IsLimitDash", UIBinderSetIsVisible.New(self, self.IconSkillSwitcOff, true) },
        { "IsShowMask", UIBinderSetIsVisible.New(self, self.IconMask) },
        { "IsShowConsume", UIBinderSetIsVisible.New(self, self.PanelConsume) },
        { "CostNum", UIBinderSetText.New(self, self.TextNum) },
        { "CostTextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNum) },
        { "PlayAnimCDFinish", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimCDFinish) },
        { "IsLimitDash", UIBinderValueChangedCallback.New(self, nil, self.OnIsLimitDashChange) },
    }
    
    self.SkillVM = _G.ChocoboRaceMainVM:FindSkillVM(self.ButtonIndex)
    self:RegisterBinders(self.SkillVM, Binders)
end

function ChocoboRaceSkillItemView:OnIsLimitDashChange(Value)
    if Value then
        self:PlayAnimation(self.AnimSprintLoop, 0, 0)
    else
        if self:IsAnimationPlaying(self.AnimSprintLoop) then
            self:StopAnimation(self.AnimSprintLoop)
            self:PlayAnimation(self.AnimSprintLoopStop)
        end
    end
end
    
function ChocoboRaceSkillItemView:OnPlayAnimCDFinish(Value)
    if Value then
        self:PlayAnimation(self.AnimCDFinish)
    end
end

function ChocoboRaceSkillItemView:OnLongClick()
    if not self.SkillVM then
        return
    end

    local SkillID = self.SkillVM.SkillID
    self.SkillTipsHandle = ChocoboRaceUtil.ShowSkillTips(SkillID, self)
end

function ChocoboRaceSkillItemView:OnLongClickReleased()
    if self.SkillTipsHandle then
        _G.SkillTipsMgr:HideTipsByHandleID(self.SkillTipsHandle)
        self.SkillTipsHandle = nil
    end
end

function ChocoboRaceSkillItemView:StartLongClickTimer()
    local LongClickTimerID = rawget(self, "LongClickTimerID")
    if LongClickTimerID then
        self:UnRegisterTimer(LongClickTimerID)
    end

    self.StartLongClickTime = _G.UE.UTimerMgr:Get().GetLocalTimeMS()
    LongClickTimerID = self:RegisterTimer(self.OnLongClick, SkillCommonDefine.SkillTipsClickTime, 1, 1)
    rawset(self, "LongClickTimerID", LongClickTimerID)
end

function ChocoboRaceSkillItemView:StopLongClickTimer()
    local LongClickTimerID = rawget(self, "LongClickTimerID")
    if LongClickTimerID then
        self:OnLongClickReleased()
        self:UnRegisterTimer(LongClickTimerID)
        rawset(self, "LongClickTimerID", nil)
    end
end

function ChocoboRaceSkillItemView:OnPressed()
    if not self.SkillVM then
        return
    end

    local SkillID = self.SkillVM.SkillID
    if SkillID <= 0 then
        return
    end
    
    self:StartLongClickTimer()
end

function ChocoboRaceSkillItemView:OnReleased()
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
    
    self:OnCastSkill()
end

function ChocoboRaceSkillItemView:OnCastSkill()
    if not self.SkillVM then
        return
    end
    
    local SkillID = self.SkillVM.SkillID
    if SkillID <= 0 then
        return
    end
    
    if not self.SkillVM:IsUsable() then
        self:PlayAnimation(self.AnimReleaseFail)
        return
    end

    if self.SkillVM.CostNum > 0 then
        local MajorRacer = ChocoboRaceMgr:GetRacerByIndex()
        local CurStamina = MajorRacer.Stamina or 0
        if CurStamina < self.SkillVM.CostNum * 100 then
            self:PlayAnimation(self.AnimReleaseFail)
            return
        end
    end

    -- 道具变换要检查是否有道具
    if self.SkillVM.Effect == ProtoRes.Game.GameRaceEffect.RaceEffectChange then
        if _G.ChocoboRaceMainVM:GetItemID() <= 0 then
            self:PlayAnimation(self.AnimReleaseFail)
            return
        end
    end
    
    local Close = false
    if self.SkillVM.Effect == ProtoRes.Game.GameRaceEffect.RaceEffectDash then
        --1是关闭
        local Racer = _G.ChocoboRaceMgr:GetRacerByIndex()
        if Racer then
            Close = Racer:InBuff(ProtoRes.CHOCOBO_RACE_STATUS.CHOCOBO_EFFECT_LIMIT_DASH)
        end
    end
    
    if self.ButtonIndex == 1 then
        ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbility1, true, Close)
    elseif self.ButtonIndex == 2 then
        ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbility2, true, Close)
    elseif self.ButtonIndex == 3 then
        ChocoboRaceMgr:ReqRaceCtrl(ProtoCS.ChocoboRaceCtrl.ChocoboRaceParamAbility3, true, Close)
    end
    self:PlayAnimation(self.AnimReleaseSuccess)
    ChocoboRaceMgr:GetRacerByIndex():PlayActionTimeLineMonTage(ProtoRes.CHOCOBO_ACTION_TIMELINE_TYPE.EXD_ACTION_TIMELINE_CHOCOBORACE_ABILITY)
end

return ChocoboRaceSkillItemView