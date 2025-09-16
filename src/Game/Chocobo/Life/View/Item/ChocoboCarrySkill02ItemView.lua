---
--- Author: Administrator
--- DateTime: 2023-12-28 20:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIUtil = require("Utils/UIUtil")
local ChocoboRaceUtil = require("Game/Chocobo/Race/ChocoboRaceUtil")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

---@class ChocoboCarrySkill02ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkill UFButton
---@field ImgAdd UFImage
---@field ImgBG UFImage
---@field ImgCheck UFImage
---@field ImgSelect UFImage
---@field ImgSkillIcon UFImage
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboCarrySkill02ItemView = LuaClass(UIView, true)

function ChocoboCarrySkill02ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSkill = nil
	--self.ImgAdd = nil
	--self.ImgBG = nil
	--self.ImgCheck = nil
	--self.ImgSelect = nil
	--self.ImgSkillIcon = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboCarrySkill02ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboCarrySkill02ItemView:OnInit()

end

function ChocoboCarrySkill02ItemView:OnDestroy()

end

function ChocoboCarrySkill02ItemView:OnShow()

end

function ChocoboCarrySkill02ItemView:OnHide()

end

function ChocoboCarrySkill02ItemView:OnRegisterUIEvent()
    --UIUtil.AddOnPressedEvent(self, self.BtnSkill, self.OnPressed)
    --UIUtil.AddOnReleasedEvent(self, self.BtnSkill, self.OnReleased)
    UIUtil.AddOnClickedEvent(self, self.BtnSkill, self.OnClicked)
	UIUtil.AddOnLongClickedEvent(self, self.BtnSkill, self.OnLongClicked)
	UIUtil.AddOnLongClickReleasedEvent(self, self.BtnSkill, self.OnLongClickReleased)
end

function ChocoboCarrySkill02ItemView:OnRegisterGameEvent()

end

function ChocoboCarrySkill02ItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    self.SkillVM = ViewModel

    local Binders = {
        { "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgSkillIcon) },
        { "IsAdd", UIBinderSetIsVisible.New(self, self.ImgAdd) },
        { "IsAdd", UIBinderSetIsVisible.New(self, self.ImgSkillIcon, true) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
        { "IsCheck", UIBinderSetIsVisible.New(self, self.ImgCheck) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

function ChocoboCarrySkill02ItemView:OnSelectChanged(Value)
    if self.SkillVM ~= nil then
        self.SkillVM:SetSelect(Value)
    end
end

function ChocoboCarrySkill02ItemView:OnLongClicked()
    if not self.SkillVM then
        print("ChocoboCarrySkill02ItemView:OnLongClicked SkillVM is nil")
        return
    end

    if not self.SkillVM.bAllowLongClickTips then
        return
    end

    local SkillID = self.SkillVM.SkillID
    self.SkillTipsHandle = ChocoboRaceUtil.ShowSkillTips(SkillID, self)
end

function ChocoboCarrySkill02ItemView:OnLongClickReleased()
    if self.SkillTipsHandle then
        _G.SkillTipsMgr:HideTipsByHandleID(self.SkillTipsHandle)
        self.SkillTipsHandle = nil
    end
end

function ChocoboCarrySkill02ItemView:StartLongClickTimer()
    local LongClickTimerID = rawget(self, "LongClickTimerID")
    if LongClickTimerID then
        self:UnRegisterTimer(LongClickTimerID)
    end

    self.StartLongClickTime = _G.UE.UTimerMgr:Get().GetLocalTimeMS()
    LongClickTimerID = self:RegisterTimer(self.OnLongClick, SkillCommonDefine.SkillTipsClickTime, 1, 1)
    rawset(self, "LongClickTimerID", LongClickTimerID)
end

function ChocoboCarrySkill02ItemView:StopLongClickTimer()
    local LongClickTimerID = rawget(self, "LongClickTimerID")
    if LongClickTimerID then
        self:OnLongClickReleased()
        self:UnRegisterTimer(LongClickTimerID)
        rawset(self, "LongClickTimerID", nil)
    end
end

function ChocoboCarrySkill02ItemView:OnPressed()
    if not self.SkillVM then
        return
    end

    local SkillID = self.SkillVM.SkillID
    if SkillID <= 0 then
        return
    end

    if self.SkillVM.bAllowLongClickTips then
        self:StartLongClickTimer()
    end
end

function ChocoboCarrySkill02ItemView:OnReleased()
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

    self:OnClickButtonItem()
end

function ChocoboCarrySkill02ItemView:OnClicked()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end

    Adapter:OnItemClicked(self, Params.Index)
end

return ChocoboCarrySkill02ItemView