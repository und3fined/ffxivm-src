---
--- Author: richyczhou
--- DateTime: 2025-08-01 10:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local GMCharacterEditorMgr = require("Game/GM/CharacterEditor/GMCharacterEditorMgr")

local LSTR = _G.LSTR

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

---@class GMCharacterEditorView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CharacterRacePanel CharacterRacePanelView
---@field CloseButton UFButton
---@field EquipmentPanel EquipmentPanelView
---@field ResetButton UFButton
---@field RotationButton UFButton
---@field RotationSlider USlider
---@field RotationText UFTextBlock
---@field SwitchButton UFButton
---@field SwitchText UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMCharacterEditorView = LuaClass(UIView, true)

function GMCharacterEditorView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CharacterRacePanel = nil
	--self.CloseButton = nil
	--self.EquipmentPanel = nil
	--self.ResetButton = nil
	--self.RotationButton = nil
	--self.RotationSlider = nil
	--self.RotationText = nil
	--self.SwitchButton = nil
	--self.SwitchText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMCharacterEditorView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CharacterRacePanel)
	self:AddSubView(self.EquipmentPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMCharacterEditorView:OnInit()
    FLOG_INFO("[GMCharacterEditorView:OnInit]")
    GMCharacterEditorMgr:OnEnter()
    self.GMCharacterEditorVM = GMCharacterEditorMgr:GetCharacterEditorVM()

    GMCharacterEditorMgr.bIsManual = false
    self:RegisterTimer(function()
        GMCharacterEditorMgr.bIsManual = true
        FLOG_INFO("[GMCharacterEditorView:OnInit] Set bIsManual = true")
    end, 0, 2, 1)

    self:InitBinders()
end

function GMCharacterEditorView:OnDestroy()
    FLOG_INFO("[GMCharacterEditorView:OnDestroy]")
    GMCharacterEditorMgr:OnExit()
end

function GMCharacterEditorView:OnShow()
    FLOG_INFO("[GMCharacterEditorView:OnShow]")
    self.IsShowing = true
    self.SwitchText:SetText(LSTR("缩小"))

    --GMCharacterEditorMgr:LoadData()
    if self.RotateCameraTimerId then
        self.RotationText:SetText(LSTR("停止"))
    else
        self.RotationText:SetText(LSTR("旋转"))
    end

    self.RotationSlider:SetValue(GMCharacterEditorMgr.CameraRotationRate)
    self.RotationSlider:SetMinValue(-90)
    self.RotationSlider:SetMaxValue(90)
end

function GMCharacterEditorView:OnHide()

end

function GMCharacterEditorView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.CloseButton, self.OnCloseButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.SwitchButton, self.OnSwitchButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.RotationButton, self.OnRotationButtonClicked)
    UIUtil.AddOnClickedEvent(self, self.ResetButton, self.OnResetButtonClicked)

    UIUtil.AddOnValueChangedEvent(self, self.RotationSlider, self.OnRotationSliderValueChanged)
end

function GMCharacterEditorView:OnRegisterGameEvent()

end

function GMCharacterEditorView:OnRegisterBinder()
    self:RegisterBinders(self.GMCharacterEditorVM, self.Binders)
end

function GMCharacterEditorView:OnCloseButtonClicked()
    FLOG_INFO("[GMCharacterEditorView:OnCloseButtonClicked]")
    self:Hide()
end

function GMCharacterEditorView:OnSwitchButtonClicked()
    FLOG_INFO("[GMCharacterEditorView:OnSwitchButtonClicked]")
    self.IsShowing = not self.IsShowing
    self.SwitchText:SetText(self.IsShowing and LSTR("缩小") or LSTR("放大"))
    UIUtil.SetIsVisible(self.CharacterRacePanel, self.IsShowing)
    UIUtil.SetIsVisible(self.EquipmentPanel, self.IsShowing)
end

function GMCharacterEditorView:OnRotationButtonClicked()
    FLOG_INFO("[GMCharacterEditorView:OnRotationButtonClicked]")
    if self.RotateCameraTimerId then
        _G.TimerMgr:CancelTimer(self.RotateCameraTimerId)
        self.RotateCameraTimerId = nil
        self.RotationText:SetText(LSTR("旋转"))
    else
        local DeltaTime = 0.03
        local Offset = -GMCharacterEditorMgr.CameraRotationRate
        local DelayCallBack = function()
            local Major = MajorUtil.GetMajor()
            if Major == nil then
                FLOG_ERROR("[GMCharacterEditorView:OnRotationButtonClicked]  Major == nil")
                return
            end
            local CameraComp = Major:GetCameraControllComponent()
            if CameraComp then
                local CameraRotation = CameraComp:GetCameraBoomRelativeRotation()
                CameraComp:SetCameraBoomRelativeRotation(_G.UE.FRotator(CameraRotation.Pitch, CameraRotation.Yaw + Offset * DeltaTime, CameraRotation.Roll));
            end
        end
        _G.TimerMgr:CancelTimer(self.RotateCameraTimerId)
        self.RotateCameraTimerId = _G.TimerMgr:AddTimer(self, DelayCallBack, 0, DeltaTime, 0)
        self.RotationText:SetText(LSTR("停止"))
    end
end

function GMCharacterEditorView:OnResetButtonClicked()
    FLOG_INFO("[GMCharacterEditorView:OnResetButtonClicked]")
    local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if AvatarComp then
        --AvatarComp:ReassembleAvatar()
        self.CharacterRacePanel.RaceComboBox:SetSelectedOption(GMCharacterEditorMgr.OriginAttachType)
        AvatarComp:ChangeAttachType(GMCharacterEditorMgr.OriginAttachType, 0, 0)
        AvatarComp:ForceUpdateCurRoleAvatar()
    end
end

function GMCharacterEditorView:OnRotationSliderValueChanged()
    GMCharacterEditorMgr.CameraRotationRate = self.RotationSlider:GetValue()
end

function GMCharacterEditorView:InitBinders()
    self.Binders = {}
end

function GMCharacterEditorView:ResetData()
    self.CharacterRacePanel:ResetData()
    self.EquipmentPanel:ResetData()
end

return GMCharacterEditorView