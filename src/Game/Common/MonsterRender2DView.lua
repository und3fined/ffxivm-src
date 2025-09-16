---
--- Author: Administrator
--- DateTime: 2023-12-25 19:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local ObjectGCType = require("Define/ObjectGCType")
local EventID = require("Define/EventID")
local UILevelMgr = require("Game/Common/Render2D/Level/UILevelMgr")
local ActorUtil = require("Utils/ActorUtil")
local LightMgr = require("Game/Light/LightMgr")
local ActorZLocation = 100000
local SpringTargetArmLengthMax = 400
local SpringTargetArmLengthMin = 200
local SpringTargetDefaultZ = 90
local ZoomSpeedFactor = 0.75
local ZoomInterpVelocity = 8.0
local FINGER_NUM_ONE = 1
local FINGER_NUM_TWO = 2
local ObjectMgr = _G.ObjectMgr
local FMath = _G.UE.UKismetMathLibrary

---@class MonsterRender2DView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CanRotate bool
---@field ZoomScale float
---@field CanZoom bool
---@field CurPosX float
---@field StartPosX float
---@field FingerNum int
---@field Touch1StartX float
---@field Touch2StartX float
---@field Touch1CurX float
---@field Touch2CurX float
---@field ClosedSceneComponents SceneComponent
---@field ClosedPostProcessVolumes PostProcessVolume
---@field AllSceneComponents SceneComponent
---@field AllPostProcessVolumes PostProcessVolume
---@field bCompleteOneClick bool
---@field GestureState int
---@field DelayGestureHandle TimerHandle
---@field PrePosX float
---@field AllWindDirectionalSource WindDirectionalSourceComponent
---@field AllWindStrength float
---@field CloseWindDirectionalSource WindDirectionalSourceComponent
---@field Touch1StartY float
---@field Touch2StartY float
---@field Touch1CurY float
---@field Touch2CurY float
---@field StartPosY float
---@field PrePosY float
---@field CurPosY float
---@field CanMove bool
---@field PressTime float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MonsterRender2DView = LuaClass(UIView, true)

function MonsterRender2DView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.CanRotate = nil
    --self.ZoomScale = nil
    --self.CanZoom = nil
    --self.CurPosX = nil
    --self.StartPosX = nil
    --self.FingerNum = nil
    --self.Touch1StartX = nil
    --self.Touch2StartX = nil
    --self.Touch1CurX = nil
    --self.Touch2CurX = nil
    --self.ClosedSceneComponents = nil
    --self.ClosedPostProcessVolumes = nil
    --self.AllSceneComponents = nil
    --self.AllPostProcessVolumes = nil
    --self.bCompleteOneClick = nil
    --self.GestureState = nil
    --self.DelayGestureHandle = nil
    --self.PrePosX = nil
    --self.AllWindDirectionalSource = nil
    --self.AllWindStrength = nil
    --self.CloseWindDirectionalSource = nil
    --self.Touch1StartY = nil
    --self.Touch2StartY = nil
    --self.Touch1CurY = nil
    --self.Touch2CurY = nil
    --self.StartPosY = nil
    --self.PrePosY = nil
    --self.CurPosY = nil
    --self.CanMove = nil
    --self.PressTime = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MonsterRender2DView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MonsterRender2DView:OnInit()
    self.bEnableZoom = true
    self.bEnableRotator = true
    self.bEnableMove = false
    self.CamToTargetRadians = 0
    self.ShowTickLogAlready = false
    self.Rotating = false
    self.TimeAfterEndRotate = -1
end

function MonsterRender2DView:OnDestroy()
end

function MonsterRender2DView:OnShow()
	-- 禁用关卡流送，避免主视角切换导致子关卡被卸载
	UILevelMgr:SwitchLevelStreaming(false)
end

function MonsterRender2DView:OnHide()
	-- 恢复关卡流送
	UILevelMgr:SwitchLevelStreaming(true)
    self:ReleaseActor()
end

function MonsterRender2DView:OnRegisterUIEvent()
end

function MonsterRender2DView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
end

function MonsterRender2DView:OnRegisterBinder()
end

function MonsterRender2DView:OnAssembleAllEnd(Params)
    local AssembleEndEntityID = Params.ULongParam1
    if self.MonsterActor == nil then
        return
    end
    
    local AttriComp =  self.MonsterActor:GetAttributeComponent()
    if (AttriComp == nil) then
        _G.FLOG_ERROR("无法获取 GetAttributeComponent")
        return
    end
    local MonsterEntityID = AttriComp.EntityID
    if AssembleEndEntityID == MonsterEntityID then
        if self.RenderActorCallback then
            self.RenderActorCallback(MonsterEntityID)
        end
    end
end

function MonsterRender2DView:ShowMonster(
    RenderScenePath,
    MonsterActor,
    LightPresetPath,
    RenderSceneCallBack,
    RenderActorCallBack,
    DefaultSpringLocation)
    if self.SceneActor ~= nil then
        if (MonsterActor ~= nil) then
            self.MonsterActor = MonsterActor
            self.SkeletalMeshComponent = self:GetSkeletalMeshComponent(MonsterActor)
        end
        return
    end

    if CommonUtil.IsWithEditor() then
        _G.LightMgr:PrintLightPreset(LightPresetPath)
    end

    local function SuccessCallback()
        self.MonsterActor = MonsterActor
        self.SkeletalMeshComponent = self:GetSkeletalMeshComponent(MonsterActor)

        local SceneClass = ObjectMgr:GetClass(RenderScenePath)
        local Location = _G.UE.FVector(0, 0, ActorZLocation)
        local Rotation = _G.UE.FRotator(0, 0, 0)
        self.SceneActor = CommonUtil.SpawnActor(SceneClass, Location, Rotation)
        self.SceneActor.OnEndPlay:Add(self, self.OnSceneActorEndPlay)

        self.DirectionalLightComponent = self.SceneActor:GetComponentByClass(_G.UE.UDirectionalLightComponent)
        self.PostProcessComponent = self.SceneActor:GetComponentByClass(_G.UE.UPostProcessComponent)
        if (LightPresetPath ~= nil) then
            self.LightPreset = _G.ObjectMgr:LoadObjectSync(LightPresetPath)
        end

        local SpringArmComponent = self.SceneActor:GetComponentByClass(_G.UE.USpringArmComponent)
        self.SpringArmComponent = SpringArmComponent:Cast(_G.UE.USpringArmComponent)
        self.DefaultSpringLocation = DefaultSpringLocation

        if self.RenderSceneCallBack then
            RenderSceneCallBack(true)
            self.RenderSceneCallBack = nil
        end
    end

    local function FailCallback()
        _G.FLOG_ERROR("[MonsterRender2DView][ShowMonster]Failed")
        if self.RenderSceneCallBack then
            RenderSceneCallBack(false)
            self.RenderSceneCallBack = nil
        end
    end

    self.RenderSceneCallBack = RenderSceneCallBack
    self.RenderActorCallback = RenderActorCallBack
    ObjectMgr:LoadClassAsync(RenderScenePath, SuccessCallback, ObjectGCType.LRU, FailCallback)
end

function MonsterRender2DView:OnSceneActorEndPlay(Actor, EndPlayReason)
    self:ReleaseActor()
end

function MonsterRender2DView:GetSkeletalMeshComponent(Actor)
    if Actor == nil then
        return nil
    end

    local Component = Actor:GetComponentByClass(_G.UE.USkeletalMeshComponent)
    if (Component == nil) then
        local ResID = 0
        local AttriComp = Actor:GetAttributeComponent()
        if (AttriComp ~= nil) then
            ResID = ActorUtil.GetActorResID( AttrComp.EntityID)
        else
            _G.FLOG_ERROR("无法获取 Actor 的 GetAttributeComponent ，请检查")
        end
        _G.FLOG_ERROR("错误，无法获取 Actor的USkeletalMeshComponent，请检查 , ResID 是 : "..ResID)
        return nil
    end
    return Component:Cast(_G.UE.USkeletalMeshComponent)
end

function MonsterRender2DView:ReleaseActor()
    self:SetIsShowUI(true)

    self.RenderSceneCallBack = nil
    self.RenderActorCallback = nil
    self.ShowTickLogAlready = false
    self.DirectionalLightComponent = nil
    if self.MonsterActor then
        CommonUtil.DestroyActor(self.MonsterActor)
    end
    self.MonsterActor = nil
    self.SkeletalMeshComponent = nil
    self.SpringArmComponent = nil
    self.SpringArmDistanceTarget = nil
    self.SpringArmLocationTarget = nil
    self.SpringArmRotationTarget = nil
    self.PostProcessComponent = nil
    self.ModelLocationTarget = nil
    self.ModelRotationTarget = nil
    self.ModelScaleTarget = nil
    self.DefaultFocusLocation = nil
    self.DefaultSpringLocation = nil
    self.FOVYTarget = nil
    if self.SceneActor then
        self.SceneActor.OnEndPlay:Remove(self, self.OnSceneActorEndPlay)
        CommonUtil.DestroyActor(self.SceneActor)
    end
    self.SceneActor = nil
end

function MonsterRender2DView:SetIsShowUI(IsShowUI)
    if IsShowUI then
        local CameraMgr = _G.UE.UCameraMgr.Get()
        if CameraMgr ~= nil then
            CameraMgr:ResumeCamera(0, true, self.SceneActor)
        end
    else
        --切换相机
        local CameraMgr = _G.UE.UCameraMgr.Get()
        if CameraMgr ~= nil then
            CameraMgr:SwitchCamera(self.SceneActor, 0)
        end
    end
end

function MonsterRender2DView:SetFullScreen(bIsFullScreen)
    if bIsFullScreen then
        self.DefaultZOrder = UIUtil.CanvasSlotGetZOrder(self.Object)
        self.DefaultLayout = UIUtil.CanvasSlotGetLayout(self.Object)
        local AnchorData = _G.UE.FAnchorData()
        AnchorData.Anchors.Maximum = _G.UE.FVector2D(1, 1)
        UIUtil.CanvasSlotSetLayout(self.Object, AnchorData)
        UIUtil.CanvasSlotSetZOrder(self.Object, 1000)
    else
        UIUtil.CanvasSlotSetLayout(self.Object, self.DefaultLayout)
        UIUtil.CanvasSlotSetZOrder(self.Object, self.DefaultZOrder)
    end
    self.bIsFullScreen = bIsFullScreen
end

function MonsterRender2DView:NormalizeTargetArmLength(InDistance)
    return math.clamp(InDistance, SpringTargetArmLengthMin, SpringTargetArmLengthMax)
end

---设置Character相机弹簧臂距离，外部调用请将bInterp设为false，以终止当前插值
function MonsterRender2DView:SetSpringArmDistance(InDistance, bInterp)
    if nil == self.SceneActor or nil == self.SpringArmComponent then
        return
    end

    if bInterp == true then
        self.SpringArmDistanceTarget = InDistance
    else
        if bInterp == false then
            self.SpringArmDistanceTarget = nil
        end
        self.SpringArmComponent.TargetArmLength = InDistance
        -- 更新与相机距离相关灯光效果
        if nil ~= self.SceneActor and nil ~= self.SceneActor.ShadowDistanceCurve then
            local ArmDistance = self:GetSpringArmDistance()
            local ShadowDistance = self.SceneActor.ShadowDistanceCurve:GetFloatValue(ArmDistance)
            self:SetShadowQuality(ShadowDistance)
        end
    end
end

function MonsterRender2DView:GetZoomRatio(CurViewDist)
    local MinViewDist = SpringTargetArmLengthMin
    local MaxViewDist = SpringTargetArmLengthMax
    return (CurViewDist - MinViewDist) / (MaxViewDist - MinViewDist)
end

function MonsterRender2DView:GetZoomZOffset(CurViewDist)
    local Ratio = self:GetZoomRatio(CurViewDist)
    local ZOffsetMinViewDist = 0
    local ZOffsetMaxViewDist = self.bEnableMove and 0 or (SpringTargetDefaultZ - self.DefaultFocusLocation.z)
    if nil ~= self.CamControlParams then
        ZOffsetMinViewDist = self.CamControlParams.MinViewDistParams.ZOffset
        ZOffsetMaxViewDist = self.CamControlParams.MaxViewDistParams.ZOffset
    end
    return Ratio * (ZOffsetMaxViewDist - ZOffsetMinViewDist) + ZOffsetMinViewDist
end

function MonsterRender2DView:GetZoomPitchOffset(CurViewDist)
    local Ratio = self:GetZoomRatio(CurViewDist)
    local PitchMinViewDist = 0
    local PitchMaxViewDist = 0
    if nil ~= self.CamControlParams then
        PitchMinViewDist = self.CamControlParams.MinViewDistParams.PitchOffset
        PitchMaxViewDist = self.CamControlParams.MaxViewDistParams.PitchOffset
    end
    return Ratio * (PitchMaxViewDist - PitchMinViewDist) + PitchMinViewDist
end

function MonsterRender2DView:GetZoomFOV(CurViewDist)
    local Ratio = self:GetZoomRatio(CurViewDist)
    local FOVMinViewDist = 0
    local FOVMaxViewDist = 0
    if nil ~= self.CamControlParams then
        FOVMinViewDist = self.CamControlParams.MinViewDistParams.FOV
        FOVMaxViewDist = self.CamControlParams.MaxViewDistParams.FOV
    end
    return Ratio * (FOVMaxViewDist - FOVMinViewDist) + FOVMinViewDist
end

function MonsterRender2DView:GetSpringArmDistance()
    if self.SpringArmComponent ~= nil and _G.UE.UCommonUtil.IsObjectValid(self.SpringArmComponent) then
        return self.SpringArmComponent.TargetArmLength
    end
    return 0
end

function MonsterRender2DView:GetSpringArmRotation()
    if self.SpringArmComponent ~= nil then
        return self.SpringArmComponent:GetRelativeRotation()
    end
    return _G.UE.FRotator(0, 0, 0)
end

function MonsterRender2DView:GetSpringArmLocation()
    if self.SpringArmComponent ~= nil then
        return self.SpringArmComponent:GetRelativeLocation()
    end
    return _G.UE.FVector(0, 0, 0)
end

function MonsterRender2DView:SetSpringArmLocation(InX, InY, InZ, bInterp, InterpVelocity)
    if self.SpringArmComponent == nil or not _G.UE.UCommonUtil.IsObjectValid(self.SpringArmComponent) then
        return
    end
    -- FLOG_INFO("Login Distance Location (%f, %f, %f) bInterp:%s", InX, InY, InZ, tostring(bInterp))
    if bInterp == true then
        self.SpringArmLocationTarget = _G.UE.FVector(InX, InY, InZ)
        self.CamLocInterpVelocity = InterpVelocity
    else
        if bInterp == false then
            self.SpringArmLocationTarget = nil
            self.CamLocInterpVelocity = nil
        end

        local Location = _G.UE.FVector(InX, InY, InZ)
        self.LastLoginRoleArmLoc = Location
        self.SpringArmComponent:K2_SetRelativeLocation(Location, false, nil, false)
    end
end

function MonsterRender2DView:SetFOVY(InFOVY, bInterp, InterpVelocity)
    if nil == InFOVY or nil == self.SceneActor then
        return
    end

    local AspectRatio = _G.UE.UCameraMgr.Get():GetAspectRatio()
    local TanHalfFOVX = AspectRatio * math.tan(math.rad(InFOVY) * 0.5)
    local FOVX = math.deg(2 * math.atan(TanHalfFOVX))
    self:SetCameraFOV(FOVX, bInterp, InterpVelocity)
end

function MonsterRender2DView:SetCameraFOV(InFOV, bInterp, InterpVelocity)
    if InFOV == nil or InFOV == 0 or self.SceneActor == nil then
        return
    end
    local CameraMgr = _G.UE.UCameraMgr.Get()
    if bInterp == true then
        self.FOVYTarget = InFOV
        self.FOVInterpVelocity = InterpVelocity

        self.LastFOV = InFov
        return
    end
    if bInterp == false then
        self.FOVYTarget = nil
        self.FOVInterpVelocity = nil
    end
    if CameraMgr ~= nil then
        -- FLOG_ERROR("LoginDistance Set Fov %f", InFOV)
        CameraMgr:SetCurrentPlayerManagerLockedFOV(InFOV)
    end
end

function MonsterRender2DView:SetSpringArmRotation(InPitch, InYaw, InRoll, bInterp, InterpVelocity)
    if self.SpringArmComponent == nil then
        return
    end
    if bInterp == true then
        self.SpringArmRotationTimeCount = 0
        self.SpringArmRotationTarget = _G.UE.FRotator(InPitch, InYaw, InRoll)
        self.CamRotInterpVelocity = InterpVelocity
    else
        if bInterp == false then
            self.SpringArmRotationTimeCount = nil
            self.SpringArmRotationTarget = nil
            self.CamRotInterpVelocity = nil
        end
        self.SpringArmComponent:K2_SetRelativeRotation(_G.UE.FRotator(InPitch, InYaw, InRoll), false, nil, false)
    end
end

function MonsterRender2DView:SetModelScale(InScale, bInterp)
    if self.MonsterActor == nil then
        return
    end

    if bInterp == true then
        self.ModelScaleTarget = InScale
    else
        self.MonsterActor:SetModelScale(InScale)
    end
end

function MonsterRender2DView:SetShadowQuality(ShadowDistance)
    --local TodMainActor = nil
    --if not self.DirectionalLightComponent then
    --    TodMainActor = _G.UE.UEnvMgr:Get():GetTodSystem()
    --end
    -- FLOG_INFO("Login Camera Distance:%f", ShadowDistance)

    --if self.bLogin then
    --   _G.UE.UCommonUtil.SetShadowQualityFromCurveCharctorCreation(
    --        ShadowDistance,
    --        self.DirectionalLightComponent,
    --        TodMainActor
    --    )
    -- else
    --    _G.UE.UCommonUtil.SetShadowQualityFromCurve(ShadowDistance, self.DirectionalLightComponent, TodMainActor)
   -- end
end

function MonsterRender2DView:SetModelLocation(InX, InY, InZ, bInterp)
    if self.SkeletalMeshComponent == nil then
        return
    end

    if bInterp == true then
        self.ModelLocationTarget = _G.UE.FVector(InX, InY, InZ)
    else
        if (self.SkeletalMeshComponent ~= nil) then
            self.SkeletalMeshComponent:K2_SetRelativeLocation(_G.UE.FVector(InX, InY, InZ), false, nil, false)
        end
    end
end

function MonsterRender2DView:SetActorVisible(IsVisible)
    if self.MonsterActor == nil or IsVisible == nil then
        return
    end
    self.MonsterActor:SetActorHiddenInGame(not IsVisible)
end

function MonsterRender2DView:EnableRotator(bEnable)
    self.bEnableRotator = bEnable
end

function MonsterRender2DView:SetSpringArmCenterOffsetY(OffsetY)
    self.CenterOffsetY = OffsetY
    --[sammrli] 计算偏移后相机和目标点的角度，角度*领边(springDistance)可以求出对边offsetY缩放后的值
    self.CamToTargetRadians = math.atan(OffsetY, self:GetSpringArmDistance())
end

function MonsterRender2DView:SetMonsterActor(Actor)
    self.MonsterActor = Actor
end

function MonsterRender2DView:UpdateAllLights()
    if self.SceneActor == nil or self.LightPreset == nil then
        return
    end
    self.SceneActor:UpdateLights(self.MonsterActor, self.LightPreset)
    LightMgr:RecordLightPreset(self.SceneActor, self.LightPreset)
end

function MonsterRender2DView:GetPostProcessVignetteIntensity()
    if self.PostProcessComponent == nil then
        return
    end
    return self.PostProcessComponent.Settings.VignetteIntensity
end

function MonsterRender2DView:SetPostProcessVignetteIntensity(InValue)
    if self.PostProcessComponent == nil then
        return
    end

    self.PostProcessVignetteIntensity = tonumber(InValue)
end

function MonsterRender2DView:SwitchLights(IsOn)
    local LightList = self.SceneActor:K2_GetComponentsByClass(_G.UE.ULightComponentBase)
    local Count = LightList:Length()
    for i = 1, Count do
        local LightComponent = LightList:Get(i)
        LightComponent:SetVisibility(IsOn)
    end
end

function MonsterRender2DView:GetCameraComponent()
    if (self.SceneActor == nil) then
        return nil
    end
    return self.SceneActor:GetComponentByClass(_G.UE.UCameraComponent)
end

--需要LOD强制设置为0时，参数传1
function MonsterRender2DView:SetActorLOD(LODLevel)
    if self.MonsterActor == nil then
        return
    end

    local avatarComponent = self.MonsterActor:GetAvatarComponent()
    if avatarComponent == nil then
        return
    end

    self.MonsterActor:GetAvatarComponent():SetForcedLODForAll(LODLevel)
end

function MonsterRender2DView:MarkStartRotate()
    self.Rotating = true
    self.TimeAfterEndRotate = 0
    _G.EventMgr:SendEvent(EventID.MonsterArchiveModelStartRotate)
end

function MonsterRender2DView:MarkEndRotate()
    self.Rotating = false
end

function MonsterRender2DView:CheckRotateState(DeltaTime)
    if self.Rotating then
        return
    end

    if not self.Rotating and self.TimeAfterEndRotate ~= -1 then
        self.TimeAfterEndRotate = self.TimeAfterEndRotate + DeltaTime
    end

    if self.TimeAfterEndRotate >= 1 then
        _G.EventMgr:SendEvent(EventID.MonsterArchiveModelEndRotate)
        self.TimeAfterEndRotate = -1
    end
end

return MonsterRender2DView
