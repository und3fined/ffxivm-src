---
--- Author: chunfengluo
--- DateTime: 2025-01-21 17:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local MoveConfig = require("Define/MoveConfig")

local KIL = _G.UE.UKismetInputLibrary
local WBL = _G.UE.UWidgetBlueprintLibrary
local KML = _G.UE.UKismetMathLibrary
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local SettingsTabRole = require("Game/Settings/SettingsTabRole")

local OneVector2D = _G.UE.FVector2D(1, 1)

---@class SkillSprintUpBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRun UFButton
---@field HoldDownBtn SkillJumpUpHoldDownBtnView
---@field Icon_Skill UFImage
---@field ImgUp UFImage
---@field ImgUpCDmask UFImage
---@field TextCD UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillSprintUpBtnView = LuaClass(UIView, true)

function SkillSprintUpBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRun = nil
	--self.HoldDownBtn = nil
	--self.Icon_Skill = nil
	--self.ImgUp = nil
	--self.ImgUpCDmask = nil
	--self.TextCD = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillSprintUpBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.HoldDownBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillSprintUpBtnView:OnInit()
    self.FirstShow = true
end

function SkillSprintUpBtnView:OnDestroy()

end

function SkillSprintUpBtnView:OnShow()
    UIUtil.SetIsVisible(self, true, true)
    --禁用BtnRun的输入，否则会挡到当前View接收鼠标点击事件
    UIUtil.SetIsVisible(self.BtnRun, true, false)
    self.HoldDownBtn:InitGeometryData()
    UIUtil.SetIsVisible(self.HoldDownBtn, false, false, true)
    self.FirstShow = true
end

function SkillSprintUpBtnView:OnHide()

end

function SkillSprintUpBtnView:OnRegisterUIEvent()
end

function SkillSprintUpBtnView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BeginTrueJump, self.OnGameEvenBeginTrueJump)
	self:RegisterGameEvent(EventID.MajorJumpStart, self.OnGameEvenMajorJumpStart)
	self:RegisterGameEvent(EventID.FightSkillPanelShowed, self.OnFightSkillPanelShowed)
end

function SkillSprintUpBtnView:OnRegisterBinder()

end

function SkillSprintUpBtnView:OnFightSkillPanelShowed(IfShowed,IsCrafterProf)
    self.FightState = IfShowed
end

function SkillSprintUpBtnView:OnMouseButtonDown(MyGeometry, MouseEvent)
    --由于关闭了BtnRun的输入，需要模拟点击的效果
    self.BtnRun:SetRenderScale(OneVector2D * 0.9)
	local Handled = WBL.Handled()
	self.CurPos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
    print("SkillSprintUpBtnView:OnMouseButtonDown", self.CurPos)

    local MajorController = MajorUtil.GetMajorController()
    if not MajorController then
        return
    end

    local DelayShowJoystick = function()
		UIUtil.SetIsVisible(self.HoldDownBtn, true)
        self.SpecialJump = true
        --特殊跳跃时不自动触发跳跃，因为要等摇杆显示结束后才触发跳跃
        MajorController:NewJumpStartAuto(false)

        -- 第一次显示时，摇杆显示1帧后再初始化，才能正确计算位置和大小
        if self.FirstShow then
            self.FirstShow = false
            self:UnRegisterTimer(self.JoystickShowTimer)
            self.JoystickShowTimer = self:RegisterTimer(function()
                self.HoldDownBtn:InitGeometryData()
                self.HoldDownBtn:OnJoyStickMove(self.CurPos)
                self:UpdateMajorNewJumpInfo()
            end, 0.001, 0.001, 1)
        end
        --回调时需要使用CurPos更新一下摇杆的位置和跳跃的方向，以防之后鼠标不再移动
        self.HoldDownBtn:InitGeometryData()
        self.HoldDownBtn:OnJoyStickMove(self.CurPos)
        self:UpdateMajorNewJumpInfo()

        self.SpecialJumpStartTime = _G.TimeUtil.GetLocalTimeMS()
        -- print("SkillSprintUpBtnView:OnMouseButtonDown Callback", self.CurPos, self.HoldDownBtn:GetAngle())
        _G.SingBarMgr.HideBreakText = true
        local SingBarTime = _G.UE.AMajorController:GetMaxJumpPressDuration() * 1000 - _G.SingBarMgr.SingLifeAddTime - 20
        _G.SingBarMgr:MajorSingByParamTable({Time=SingBarTime, UIStyle=ProtoRes.SingStateUIStyle.UISTYLE_NORMAL, SingName=""}, 
            function()  --读条结束或打断后的回调，触发特殊跳跃
                self:SetMajorFacingToJumpDirection()
                MajorController:NewJumpEnd()
                self.HasJumped = true
                _G.SingBarMgr.HideBreakText = false
            end, false)
    end

    -- 跳跃前离开坐下的状态
    _G.EmotionMgr:ExitSitToJump()

    local EnableSpecialJump = SettingsTabRole:GetEnableSpecialJump() == 1
    local IsMoving = CommonStateUtil.IsInState(ProtoCommon.CommStatID.COMM_STAT_MOVING)

    self.HasJumped = false
    self.SpecialJump = false
    self:UnRegisterTimer(self.SpecialJumpTimer)
    if EnableSpecialJump and (not IsMoving and not self.FightState) then
        self.SpecialJumpTimer = self:RegisterTimer(DelayShowJoystick, MoveConfig.SpecialJumpJoystickShowTime, 0, 1)
    else
        --移动状态下立刻跳跃
        MajorController:NewJumpStart()
        MajorController:NewJumpEnd()
        self.HasJumped = true
    end

	return WBL.CaptureMouse(Handled, self)
end

function SkillSprintUpBtnView:OnMouseMove(MyGeometry, MouseEvent)
    --鼠标移动这个方法才会调用，因此这里需要持续更新CurPos，来处理长按过后鼠标不再移动的情况，此时仍然能使用最新的鼠标位置来更新摇杆
	self.CurPos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
    if not self.SpecialJump then
        -- print("SkillSprintUpBtnView:OnMouseMove, not SpecialJump", self.CurPos, self.HoldDownBtn:GetAngle())
        return WBL.Handled()
    end
    -- print("SkillSprintUpBtnView:OnMouseMove, SpecialJump", self.CurPos, self.HoldDownBtn:GetAngle())

    self.HoldDownBtn:OnJoyStickMove(self.CurPos)

    -- 为此次跳跃指定跳跃方向
    self:UpdateMajorNewJumpInfo()

	return WBL.Handled()
end

function SkillSprintUpBtnView:OnMouseButtonUp(MyGeometry, MouseEvent)
    self:ResetJoystick()
	local Handled = WBL.Handled()
	self.CurPos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
    -- print("SkillSprintUpBtnView:OnMouseButtonUp", self.CurPos, self.HoldDownBtn:GetAngle())
    local MajorController = MajorUtil.GetMajorController()
    if MajorController == nil then
        return WBL.ReleaseMouseCapture(Handled)
    end
    if not self.HasJumped then
        if not self.SpecialJump then
            MajorController:NewJumpStart()
            MajorController:NewJumpEnd()
            self.HasJumped = true
            return WBL.ReleaseMouseCapture(Handled)
        else
            -- 特殊跳跃通过打断读条触发跳跃
            _G.SingBarMgr:OnMajorSingOver(MajorUtil.GetMajorEntityID(), true, true)
        end
    end

    return WBL.ReleaseMouseCapture(Handled)
end

function SkillSprintUpBtnView:OnGameEvenBeginTrueJump(Params)
    local EntityID = Params.ULongParam1
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if EntityID == MajorEntityID then
        print("SkillSprintUpBtnView:OnGameEvenBeginTrueJump")
        self:ResetJoystick()
        -- 跳跃时设置主角朝向
        if self.SpecialJump then
            -- 跳跃时设置主角朝向
            self:SetMajorFacingToJumpDirection()
            self.SpecialJump = false
        end
        -- _G.SingBarMgr:BreakCurSingDisplay(MajorUtil.GetMajorEntityID())
        -- _G.SingBarMgr:OnMajorSingOver(MajorUtil.GetMajorEntityID(), true, true)
    end
end

function SkillSprintUpBtnView:OnGameEvenMajorJumpStart(Params)
    print("SkillSprintUpBtnView:OnGameEvenMajorJumpStart")
end

function SkillSprintUpBtnView:ResetJoystick()
    --由于关闭了BtnRun的输入，需要模拟点击的效果
    self.BtnRun:SetRenderScale(OneVector2D)
    UIUtil.SetIsVisible(self.HoldDownBtn, false)
    self:UnRegisterTimer(self.SpecialJumpTimer)
end

function SkillSprintUpBtnView:ComputeNewMajorFacing()
    -- 设置主角转向
    local Major = MajorUtil.GetMajor()
    if not Major then
       return _G.UE.FVector(0, 0, 0)
    end
    local CameraRotation = Major:GetCameraBoomRelativeRotation()
    local CameraForward = KML.Conv_RotatorToVector(CameraRotation)
    local CameraForwardProj = KML.Vector_Normal2D(CameraForward)
    local angle = self.HoldDownBtn:GetAngle()
    local NewForward = KML.RotateAngleAxis(CameraForwardProj, angle, _G.UE.FVector(0, 0, 1))
    return NewForward
end

function SkillSprintUpBtnView:UpdateMajorNewJumpInfo(NewJumpDirection)
    if NewJumpDirection == nil then
        NewJumpDirection = self:ComputeNewMajorFacing()
    end
    if KML.Vector_IsNearlyZero(NewJumpDirection) then
       return
    end
    local MajorController = MajorUtil.GetMajorController()
    if MajorController then
        local percent = self.HoldDownBtn:GetPercent()
        if percent <= MoveConfig.SpecialJumpJoystickDeadZoneSize then
            --小于死区，不指定跳跃方向，强制跳跃速度为0
            MajorController:SetOverrideJumpDirection(false, NewJumpDirection)
            MajorController:SetOverrideJumpSpeed(true, 0)
        else
            --大于死区，指定跳跃方向，不修改跳跃速度
            MajorController:SetOverrideJumpDirection(true, NewJumpDirection)
            MajorController:SetOverrideJumpSpeed(false, 0)
        end
    end
end

function SkillSprintUpBtnView:SetMajorFacingToJumpDirection(NewForward)
    --小于死区，不改变主角转向
    local percent = self.HoldDownBtn:GetPercent()
    if percent <= MoveConfig.SpecialJumpJoystickDeadZoneSize then
        return
    end
    if NewForward == nil then
        NewForward = self:ComputeNewMajorFacing()
    end
    if KML.Vector_IsNearlyZero(NewForward) then
       return
    end
    local Major = MajorUtil.GetMajor()
    if not Major then
       return
    end
    local EndRotator = KML.Conv_VectorToRotator(NewForward)
    Major:FSetRotationForServerNoInterp(EndRotator)
    -- print("SkillSprintUpBtnView:SetMajorFacingToJumpDirection", NewForward, EndRotator)
end

return SkillSprintUpBtnView