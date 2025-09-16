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
local ActorUtil = require("Utils/ActorUtil")
local UILevelMgr = require("Game/Common/Render2D/Level/UILevelMgr")
local LightMgr = require("Game/Light/LightMgr")
local CompanionCfg = require ("TableCfg/CompanionCfg")
local SystemLightCfg = require("TableCfg/SystemLightCfg")

local SceneBGPath = "Class'/Game/UI/Render2D/Equipment/BP_EquipmentBackground.BP_EquipmentBackground_C'"

local ActorZLocation = 100000
local SpringTargetArmLengthMax = 800
local SpringTargetArmLengthMin = 200
local SpringTargetDefaultZ = 90
local ZoomSpeedFactor = 0.75
local ZoomInterpVelocity = 8.0
local FINGER_NUM_ONE =  1
local FINGER_NUM_TWO =  2
local CompanionLightSystemID = 9

local ObjectMgr = _G.ObjectMgr
local FMath = UE.UKismetMathLibrary
local UE = _G.UE
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

---@class CompanionRender2DView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ShadowImage UFImage
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
local CompanionRender2DView = LuaClass(UIView, true)

function CompanionRender2DView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ShadowImage = nil
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

function CompanionRender2DView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanionRender2DView:OnInit()
    self.bIsFullScreen = false
	self.bEnableZoom = true
	self.bEnableRotator = true
    self.bEnableMove = false
    self.CamToTargetRadians = 0
    self.ShowTickLogAlready = false
    self.CanTick = false
    self.Rotating = false
    self.TimeAfterEndRotate = -1
    self.SingleClickCallback = nil
    self.ActorVisibleBeforeInactive = nil
    self.IsNeedShadow = true
    self.ShadowActor = nil
    self.CreateParam = nil
end

function CompanionRender2DView:OnDestroy()

end

function CompanionRender2DView:OnShow()
	
end

function CompanionRender2DView:OnHide()
	self:ReleaseActor()
end

function CompanionRender2DView:OnActive()
    self:SetSceneVisible(true)
    self:SetBackgroundVisible(true)
    if self.ActorVisibleBeforeInactive ~= nil then
        self:SetActorVisible(self.ActorVisibleBeforeInactive)
        self.ActorVisibleBeforeInactive = nil
    end
    self:SetFocusLocation()
    self:SwitchToModelCamera(true)
end

function CompanionRender2DView:OnInactive()
    self:SwitchToModelCamera(false)
    self.ActorVisibleBeforeInactive = self:GetActorVisible()
    self:SetActorVisible(false)
    self:SetSceneVisible(false)
    self:SetBackgroundVisible(false)
end

function CompanionRender2DView:OnRegisterUIEvent()

end

function CompanionRender2DView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
end

function CompanionRender2DView:OnRegisterBinder()

end

function CompanionRender2DView:OnAssembleAllEnd(Params)
    if self.CompanionActor == nil then return end

	local AssembleEndEntityID = Params.ULongParam1
    if AssembleEndEntityID == self.CompanionEntityID then
        FLOG_INFO(string.format("[CompanionRender2DView][OnAssembleAllEnd]Companion:%s EntityID:%d", self:GetCompanionName(self.CompanionActor:GetAttributeComponent().ResID), AssembleEndEntityID))
        self.CanTick = true
        self.SkeletalMeshComponent = self:GetSkeletalMeshComponent(self.CompanionActor)
        self:SetFocusLocation()
        self:SetActorLOD(1)
        self:CreateShadow()
        self:SetupLightPreset(self.CreateParam)
        if self.RenderActorCallback then
            self.RenderActorCallback(self.CompanionEntityID, self.CompanionActor)
        end
    end
end

--- 基本展示宠物接口
---@param RenderScenePath string 场景BP路径
---@param CompanionID int32 宠物ID
---@param RenderSceneCallBack Callback 加载场景回调
---@param RenderActorCallBack Callback 加载宠物回调
---@param CreateParam table@{ Location 必要, Rotation 必要, IsNeedShadow 选传-是否需要假阴影, SystemID 选传-需要UITOD/灯光预设时可填, NoNeedUITOD 选传-不需要UITOD可填true, NoNeedLightPreset 选传-不需要灯光预设可填true }
function CompanionRender2DView:ShowCompanion(RenderScenePath, CompanionID, RenderSceneCallBack, RenderActorCallBack, CreateParam)
	if self.SceneActor ~= nil then
		FLOG_WARNING("[CompanionRender2D][ShowCompanion]Render scene already")
		return
	end

	local function SuccessCallback()
        _G.FLOG_INFO("[CompanionRender2DView][ShowCompanion]Load scene success")
		local SceneClass = ObjectMgr:GetClass(RenderScenePath)
		self.SceneActor = CommonUtil.SpawnActor(SceneClass, CreateParam.Location, CreateParam.Rotation)
		self.SceneActor.OnEndPlay:Add(self, self.OnSceneActorEndPlay)

        local SceneBGClass = ObjectMgr:GetClass(SceneBGPath)
        self.BackgroundActor = CommonUtil.SpawnActor(SceneBGClass, CreateParam.Location)

		self.DirectionalLightComponent = self.SceneActor:GetComponentByClass(UE.UDirectionalLightComponent)
        self.PostProcessComponent = self.SceneActor:GetComponentByClass(UE.UPostProcessComponent)
		local SpringArmComponent = self.SceneActor:GetComponentByClass(UE.USpringArmComponent)
		self.SpringArmComponent = SpringArmComponent:Cast(UE.USpringArmComponent)
        self:SwitchToModelCamera(true)
        self:SetupUITOD(CreateParam)
        
        if self.RenderSceneCallBack then
            RenderSceneCallBack(true)
            self.RenderSceneCallBack = nil
        end

        -- 场景加载好了再加载宠物
        self:CreateCompanionActor(CompanionID, CreateParam)
	end

	local function FailCallback()
        FLOG_ERROR("[CompanionRender2DView][ShowCompanion]Load scene failed")
        if self.RenderSceneCallBack then
            RenderSceneCallBack(false)
            self.RenderSceneCallBack = nil
        end
    end

    self.RenderSceneCallBack = RenderSceneCallBack
    self.RenderActorCallback = RenderActorCallBack
    self.CreateParam = CreateParam
    ObjectMgr:LoadClassAsync(RenderScenePath, SuccessCallback, ObjectGCType.LRU, FailCallback)
end

function CompanionRender2DView:CreateCompanionActor(CompanionID, CreateParam)
    local Location = CreateParam.Location
	local Rotation = CreateParam.Rotation
    local ListID = 0
    local CreateClientActorParam = UE.FCreateClientActorParams()
	CreateClientActorParam.bUIActor = true
	self.CompanionEntityID = UE.UActorManager:Get():CreateClientActorByParams(UE.EActorType.Companion, ListID, CompanionID, Location, Rotation, CreateClientActorParam)
	self.CompanionActor = ActorUtil.GetActorByEntityID(self.CompanionEntityID)
    if self.CompanionActor then
        UE.UVisionMgr.Get():RemoveFromVision(self.CompanionActor)
    end

    -- 是否需要阴影
    local IsNeedShadow = true
    if CreateParam.IsNeedShadow ~= nil then
        IsNeedShadow = CreateParam.IsNeedShadow
    end
    self.IsNeedShadow = IsNeedShadow

	FLOG_INFO(string.format("[CompanionRender2DView][CreateCompanionActor]Companion:%s EntityID:%d", self:GetCompanionName(CompanionID), self.CompanionEntityID))
end

function CompanionRender2DView:OnSceneActorEndPlay(Actor, EndPlayReason)
	self:ReleaseActor()
end

function CompanionRender2DView:GetSkeletalMeshComponent(Actor)
	if Actor == nil then return end

	local Component = Actor:GetComponentByClass(UE.USkeletalMeshComponent)
	return Component:Cast(UE.USkeletalMeshComponent)
end

function CompanionRender2DView:ReleaseActor()
	self:SwitchToModelCamera(false)
    self:DestroyShadow()
    self.SingleClickCallback = nil
    self.RenderSceneCallBack = nil
    self.RenderActorCallback = nil
    self.CreateParam = nil
    self.CanTick = false
    self.ShowTickLogAlready = false
    self.DirectionalLightComponent = nil
    if self.CompanionActor then
		CommonUtil.DestroyActor(self.CompanionActor)
    end
    self.CompanionEntityID = nil
    self.CompanionActor = nil
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
	self.FOVYTarget = nil

    if self.BackgroundActor then
		CommonUtil.DestroyActor(self.BackgroundActor)
    end
    self.BackgroundActor = nil

	if self.SceneActor then
		self.SceneActor.OnEndPlay:Remove(self, self.OnSceneActorEndPlay)
		CommonUtil.DestroyActor(self.SceneActor)
	end
	self.SceneActor = nil
	LightMgr:DisableUIWeather()
end

---@param IsSwitch boolean 是否切换到模型镜头
function CompanionRender2DView:SwitchToModelCamera(IsSwitch)
    local CameraMgr = UE.UCameraMgr.Get()
    if CameraMgr == nil then return end

	if IsSwitch then
        -- 禁用关卡流送，避免主视角切换导致子关卡被卸载
	    UILevelMgr:SwitchLevelStreaming(false)
        --切换相机
        CameraMgr:SwitchCamera(self.SceneActor, 0)
    else
        CameraMgr:ResumeCamera(0, true, self.SceneActor)
        -- 恢复关卡流送
	    UILevelMgr:SwitchLevelStreaming(true)
    end
end

function CompanionRender2DView:Tick(_, DeltaTime)
    if self.CanTick == false then return end
    
    if self.SkeletalMeshComponent == nil then
        if self.ShowTickLogAlready == false then
            self.ShowTickLogAlready = true
            FLOG_ERROR("[CompanionRender2DView][Tick]SkeletalMeshComponent is nil")
        end
        return
    end

	self:UpdateFocusLocation()
    local FingerNum = self.FingerNum
	-- if FingerNum == FINGER_NUM_TWO and self.bEnableZoom then
    --     local Touch1CurX  = self.Touch1CurX
    --     local Touch2CurX =  self.Touch2CurX
    --     local Touch1CurY  = self.Touch1CurY
    --     local Touch2CurY =  self.Touch2CurY
    --     local TouchOffset = math.sqrt((self.Touch1StartX - self.Touch2StartX)^2 + (self.Touch1StartY - self.Touch2StartY)^2)
    --     local CurOffset = math.sqrt((Touch1CurX - Touch2CurX)^2 + (Touch1CurY - Touch2CurY)^2)
	-- 	self.ZoomScale = (CurOffset - TouchOffset) * DeltaTime * ZoomSpeedFactor
    --     self.Touch1StartX = Touch1CurX
    --     self.Touch2StartX = Touch2CurX
	-- 	self.Touch1StartY = Touch1CurY
	-- 	self.Touch2StartY = Touch2CurY
    --     self:SetCanZoom(true)
    --     self.CanRotate = false
    -- end

	if FingerNum > FINGER_NUM_TWO then
        self.FingerNum = FINGER_NUM_TWO
    elseif FingerNum < 0 then
        self.FingerNum = 0
    end

    if self.FingerNum == 0 and self.bIsFullScreen then
		self:SetFullScreen(false)
	end
	if self.FingerNum > 0 and not self.bIsFullScreen then
		self:SetFullScreen(true)
	end

	-- 长按0.5秒开启移动
	if FingerNum == FINGER_NUM_ONE and self.bEnableMove then
        if not self:GetCanZoom() and not self:GetCanMove() and (self.CurPosX == 0 or FMath.abs(self.StartPosX - self.CurPosX) <= 5) then
            self.PressTime = self.PressTime + DeltaTime
            if self.PressTime > 0.5 then
                self:SetCanMove(true)
                self.CanRotate = false
                self.PressTime = 0
                self.SpringArmLocationTarget = nil
            end
        end
    end

	-- 旋转距离太小时不触发
	if not self:GetCanZoom() and self.CanRotate and self.CurPosX ~= 0 and FMath.abs(self.StartPosX - self.CurPosX) > 5 then
        local OffsetX = self.PrePosX - self.CurPosX
        if OffsetX > 15.0 then
            OffsetX = 15.0
        elseif OffsetX < -15.0 then
            OffsetX = -15.0
        end

        if self.SkeletalMeshComponent ~= nil and CommonUtil.IsObjectValid(self.SkeletalMeshComponent) then
            --停止Rotation的插值
            self.ModelRotationTarget = nil
            --if self.bEnableRotator then
				self.SkeletalMeshComponent:K2_AddLocalRotation(UE.FRotator(0, OffsetX, 0), false, UE.FHitResult(), false)
            --end
        end
        self.PrePosX = self.CurPosX
        self.PressTime = -999999

        self:MarkStartRotate()
    else
        self:MarkEndRotate()
    end

	-- 设置self.CanZoom有问题，用Getter/Setter正常
	-- if self:GetCanZoom() == true then
    --     if self.bEnableZoom then
    --         if self.DefaultFocusLocation ~= nil then
    --             local CurViewDist = self:NormalizeTargetArmLength(self:GetSpringArmDistance() - self.ZoomScale * 40)
    --             self:SetSpringArmDistance(CurViewDist, true)
    --             local Location = self.DefaultSpringLocation
    --             self:SetSpringArmLocation(Location.x, Location.y, Location.z, true, ZoomInterpVelocity)
	-- 			-- 缩放时设置俯仰角偏移，默认为0
	-- 			local Rotation = self:GetSpringArmRotation()
	-- 			self:SetSpringArmRotation(self:GetZoomPitchOffset(CurViewDist), Rotation.Yaw, Rotation.Roll, true, ZoomInterpVelocity)
	-- 			-- 缩放时设置FOV
	-- 			self:SetFOVY(self:GetZoomFOV(CurViewDist), true, ZoomInterpVelocity)
    --             self:SetCanZoom(false)
    --         end
    --     else
    --         self:SetCanZoom(false)
    --     end
    -- end

	--移动
    if self:GetCanMove() and (self.CurPosX ~= 0 or self.CurPosY ~= 0) then
        local OffsetX = self.PrePosX - self.CurPosX
        local OffsetY = self.PrePosY - self.CurPosY
        local Pixed = self:GetSpringArmDistance() * math.tan(math.rad(20)) * 2 / UIUtil.GetViewportSize().Y
        local Location = self:GetSpringArmLocation()
        Location.y = Location.y + OffsetX * Pixed
        Location.z = Location.z + OffsetY * Pixed
        self:SetSpringArmLocation(Location.x, Location.y, Location.z, false)
        self.CamToTargetRadians = math.atan(Location.y, self:GetSpringArmDistance())
        self.DefaultFocusLoc = Location
        self.PrePosX = self.CurPosX
        self.PrePosY = self.CurPosY
    end

	---进行插值动画start
	-- FOV插值
    if self.FOVYTarget ~= nil then
        local CurFOVY = self:GetFOVY()
		local InterpVelocity = self.FOVInterpVelocity or ZoomInterpVelocity
        local InterpFOVY = FMath.FInterpTo(CurFOVY, self.FOVYTarget, DeltaTime, InterpVelocity)
        if self.FOVYTarget == InterpFOVY then
            -- 插值结束
            self.FOVYTarget = nil
			self.FOVInterpVelocity = nil
        end
        self:SetFOVY(InterpFOVY)
    end
    --SpringArm插值
    if self.SpringArmDistanceTarget ~= nil then
        local CurDistance = self:GetSpringArmDistance()
        local InterpDistance = FMath.FInterpTo(CurDistance, self.SpringArmDistanceTarget, DeltaTime, ZoomInterpVelocity)
        if self.SpringArmDistanceTarget == InterpDistance then
            --插值动画结束
            --print("SpringArm插值动画结束")
            self.SpringArmDistanceTarget = nil
        end
        self:SetSpringArmDistance(InterpDistance)
    end
    --SpringRotation插值
    if self.SpringArmRotationTarget ~= nil then
        local CurRotation = self:GetSpringArmRotation()
        local Speed = self.CamRotInterpVelocity or _G.math.exp(self.SpringArmRotationTimeCount)
        local InterpRotation = UIUtil.QInterpTo(CurRotation, self.SpringArmRotationTarget, DeltaTime, Speed)
        local DeltaMove = (self.SpringArmRotationTarget - InterpRotation):GetNormalized()
        local Tolerance = 0.001
        self.SpringArmRotationTimeCount = self.SpringArmRotationTimeCount + DeltaTime
        --print("InterpRotation = "..table_to_string(InterpRotation).."; DeltaMove = "..table_to_string(DeltaMove))
        if _G.math.abs(DeltaMove.Pitch)<=Tolerance and
		    _G.math.abs(DeltaMove.Yaw)<=Tolerance and
		    _G.math.abs(DeltaMove.Roll)<=Tolerance then
            --插值动画结束
            --print("SpringRotation插值动画结束")
            self.SpringArmRotationTimeCount = 0
            self.SpringArmRotationTarget = nil
			self.CamRotInterpVelocity = nil
        end
        self:SetSpringArmRotation(InterpRotation.Pitch, InterpRotation.Yaw, InterpRotation.Roll)
    end

    --SpringLocation插值
    if self.SpringArmLocationTarget ~= nil then
        local CurLocation = self:GetSpringArmLocation()
        -- FLOG_WARNING("LoginDistance SpringCompArmLocation(%f, %f, %f)", CurLocation.x, CurLocation.y, CurLocation.z)
		local InterpVelocity = self.CamLocInterpVelocity or 4.0
        local InterpLocation = FMath.VInterpTo(CurLocation, self.SpringArmLocationTarget, DeltaTime, InterpVelocity)
        if InterpLocation.x == self.SpringArmLocationTarget.x and
            InterpLocation.y == self.SpringArmLocationTarget.y and
            InterpLocation.z == self.SpringArmLocationTarget.z then
            --插值动画结束
            --print("SpringLocation插值动画结束")
            self.SpringArmLocationTarget = nil
			self.CamLocInterpVelocity = nil
        end
        self:SetSpringArmLocation(InterpLocation.x, InterpLocation.y, InterpLocation.z)
    end

    --Scale插值
    if self.ModelScaleTarget ~= nil then
        local CurScale = self.ChildActor:GetActorScale3D();
        local InterpScale = FMath.FInterpTo(CurScale.x, self.ModelScaleTarget, DeltaTime, 4.0)
        if self.ModelScaleTarget == InterpScale then
            --插值动画结束
            --print("Scale插值动画结束")
            self.ModelScaleTarget = nil
        end
        self:SetModelScale(InterpScale)
    end

    --Rotator插值
    if self.ModelRotationTarget ~= nil and self.SkeletalMeshComponent ~= nil then
        local CurRotation = self.SkeletalMeshComponent:GetRelativeRotation();
        local InterpRotation = FMath.RInterpTo(CurRotation, self.ModelRotationTarget, DeltaTime, 4.0)
        if self.ModelRotationTarget.Pitch == InterpRotation.Pitch and 
            self.ModelRotationTarget.Yaw == InterpRotation.Yaw and 
            self.ModelRotationTarget.Roll == InterpRotation.Roll then
            --插值动画结束
            --print("Rotator插值动画结束")
            self.ModelRotationTarget = nil
        end
        self:SetModelRotation(InterpRotation.Pitch, InterpRotation.Yaw, InterpRotation.Roll)
    end

    --Location插值
    -- if self.ModelLocationTarget ~= nil then
    --     local CurLocation = self.ChildActor:K2_GetActorLocation();
    --     CurLocation.x = CurLocation.x - self.ChildActorLocation.x;
    --     CurLocation.y = CurLocation.y - self.ChildActorLocation.y;
    --     CurLocation.z = CurLocation.z - self.ChildActorLocation.z;
    --     local InterpLocation = FMath.VInterpTo(CurLocation, self.ModelLocationTarget, DeltaTime, 4.0)
    --     if InterpLocation.x == self.ModelLocationTarget.x and 
    --         InterpLocation.y == self.ModelLocationTarget.y and 
    --         InterpLocation.z == self.ModelLocationTarget.z then
    --         --插值动画结束
    --         --print("Location插值动画结束")
    --         self.ModelLocationTarget = nil
    --     end
    --     self:SetModelLocation(InterpLocation.x, InterpLocation.y, InterpLocation.z)
    -- end
    ---进行插值动画end

    -- if self.PostProcessVignetteIntensity ~= nil and self.PostProcessComponent ~= nil then
    --     local CurValue = self.PostProcessComponent.Settings.VignetteIntensity
    --     local Interp_VignetteIntensity = FMath.FInterpTo(CurValue, self.PostProcessVignetteIntensity, DeltaTime, 3)
    --     self.PostProcessComponent.Settings.VignetteIntensity = Interp_VignetteIntensity
    --     if FMath.Abs(self.PostProcessVignetteIntensity - Interp_VignetteIntensity) < 0.005 then
    --         self.PostProcessComponent.Settings.VignetteIntensity = self.PostProcessVignetteIntensity
    --         self.PostProcessVignetteIntensity = nil
    --     end
    -- end

    self:CheckRotateState(DeltaTime)
end

function CompanionRender2DView:UpdateFocusLocation()
	if self.CompanionActor == nil or self.DefaultFocusLocation ~= nil or CommonUtil.IsObjectValid(self.CompanionActor) == false then return end
	self:SetFocusLocation()
end

function CompanionRender2DView:SetFocusLocation()
    if not self.SceneActor or not self.CompanionActor then return end
    
    local ActorTransform = self.SceneActor:GetTransform()
	local SocketLocation = self.CompanionActor:GetSocketLocationByName("root_M")
	self.DefaultFocusLocation = UE.UKismetMathLibrary.InverseTransformLocation(ActorTransform, SocketLocation)
end

function CompanionRender2DView:SetFullScreen(bIsFullScreen)
	if bIsFullScreen then
		self.DefaultZOrder = UIUtil.CanvasSlotGetZOrder(self.Object)
		self.DefaultLayout = UIUtil.CanvasSlotGetLayout(self.Object)
		local AnchorData = UE.FAnchorData()
		AnchorData.Anchors.Maximum = UE.FVector2D(1, 1)
		UIUtil.CanvasSlotSetLayout(self.Object, AnchorData)
		UIUtil.CanvasSlotSetZOrder(self.Object, 1000)
	else
		UIUtil.CanvasSlotSetLayout(self.Object, self.DefaultLayout)
		UIUtil.CanvasSlotSetZOrder(self.Object, self.DefaultZOrder)
	end
	self.bIsFullScreen = bIsFullScreen
end

function CompanionRender2DView:NormalizeTargetArmLength(InDistance)
    return math.clamp(InDistance, SpringTargetArmLengthMin, SpringTargetArmLengthMax)
end

---设置Character相机弹簧臂距离，外部调用请将bInterp设为false，以终止当前插值
function CompanionRender2DView:SetSpringArmDistance(InDistance, bInterp)
    if nil == self.SceneActor or nil == self.SpringArmComponent then return end

    InDistance = math.clamp(InDistance, SpringTargetArmLengthMin, SpringTargetArmLengthMax)
    
    if bInterp == true then
        self.SpringArmDistanceTarget = InDistance
    else
		if bInterp == false then
            self.SpringArmDistanceTarget = nil
		end
        self.SpringArmComponent.TargetArmLength = InDistance
		-- 更新与相机距离相关灯光效果
		-- if nil ~= self.SceneActor and nil ~= self.SceneActor.ShadowDistanceCurve then
        --     local ArmDistance = self:GetSpringArmDistance()
		-- 	local ShadowDistance = self.SceneActor.ShadowDistanceCurve:GetFloatValue(ArmDistance)
        --     self:SetShadowQuality(ShadowDistance)
		-- end
    end
end

function CompanionRender2DView:GetZoomRatio(CurViewDist)
	local MinViewDist = SpringTargetArmLengthMin
	local MaxViewDist = SpringTargetArmLengthMax
	return (CurViewDist - MinViewDist) / (MaxViewDist - MinViewDist)
end

function CompanionRender2DView:GetZoomZOffset(CurViewDist)
	local Ratio = self:GetZoomRatio(CurViewDist)
	local ZOffsetMinViewDist = 0
	local ZOffsetMaxViewDist = self.bEnableMove and 0 or (SpringTargetDefaultZ - self.DefaultFocusLocation.z)
	if nil ~= self.CamControlParams then
		ZOffsetMinViewDist = self.CamControlParams.MinViewDistParams.ZOffset
		ZOffsetMaxViewDist = self.CamControlParams.MaxViewDistParams.ZOffset
	end
	return Ratio * (ZOffsetMaxViewDist - ZOffsetMinViewDist) + ZOffsetMinViewDist
end

function CompanionRender2DView:GetZoomPitchOffset(CurViewDist)
	local Ratio = self:GetZoomRatio(CurViewDist)
	local PitchMinViewDist = 0
	local PitchMaxViewDist = 0
	if nil ~= self.CamControlParams then
		PitchMinViewDist = self.CamControlParams.MinViewDistParams.PitchOffset
		PitchMaxViewDist = self.CamControlParams.MaxViewDistParams.PitchOffset
	end
	return Ratio * (PitchMaxViewDist - PitchMinViewDist) + PitchMinViewDist
end

function CompanionRender2DView:GetZoomFOV(CurViewDist)
	local Ratio = self:GetZoomRatio(CurViewDist)
	local FOVMinViewDist = 0
	local FOVMaxViewDist = 0
	if nil ~= self.CamControlParams then
		FOVMinViewDist = self.CamControlParams.MinViewDistParams.FOV
		FOVMaxViewDist = self.CamControlParams.MaxViewDistParams.FOV
	end
	return Ratio * (FOVMaxViewDist - FOVMinViewDist) + FOVMinViewDist
end

function CompanionRender2DView:GetSpringArmDistance()
    if self.SpringArmComponent ~= nil and CommonUtil.IsObjectValid(self.SpringArmComponent) then
        return self.SpringArmComponent.TargetArmLength
    end
    return 0
end

function CompanionRender2DView:GetSpringArmRotation()
    if self.SpringArmComponent ~= nil then
        return self.SpringArmComponent:GetRelativeRotation() 
    end 
    return UE.FRotator(0, 0, 0);
end

function CompanionRender2DView:GetSpringArmLocation()
    if self.SpringArmComponent ~= nil then
        return self.SpringArmComponent:GetRelativeLocation()
    end
    return UE.FVector(0, 0, 0);
end

function CompanionRender2DView:SetSpringArmLocation(InX, InY, InZ, bInterp, InterpVelocity)
    if self.SpringArmComponent == nil or not CommonUtil.IsObjectValid(self.SpringArmComponent) then
        return
    end
    -- FLOG_INFO("Login Distance Location (%f, %f, %f) bInterp:%s", InX, InY, InZ, tostring(bInterp))
    if bInterp == true then
        self.SpringArmLocationTarget = UE.FVector(InX, InY, InZ);
		self.CamLocInterpVelocity = InterpVelocity
    else
		if bInterp == false then
			self.SpringArmLocationTarget = nil
			self.CamLocInterpVelocity = nil
		end
        
        local Location = UE.FVector(InX, InY, InZ)
        self.LastLoginRoleArmLoc = Location
        self.SpringArmComponent:K2_SetRelativeLocation(Location, false, nil, false);
    end
end

function CompanionRender2DView:SetFOVY(InFOVY, bInterp, InterpVelocity)
	if nil == InFOVY or nil == self.SceneActor then
		return
	end

    local AspectRatio = UE.UCameraMgr.Get():GetAspectRatio()
	local TanHalfFOVX = AspectRatio * math.tan(math.rad(InFOVY) * 0.5)
	local FOVX = math.deg(2 * math.atan(TanHalfFOVX))
	self:SetCameraFOV(FOVX, bInterp, InterpVelocity)
end

function CompanionRender2DView:SetCameraFOV(InFOV, bInterp, InterpVelocity)
    if InFOV == nil or InFOV == 0 or self.SceneActor == nil then
        return
    end
    local CameraMgr = UE.UCameraMgr.Get()
	if bInterp == true then
		self.FOVYTarget = InFOV
		self.FOVInterpVelocity = InterpVelocity

        self.LastFOV = InFOV
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

function CompanionRender2DView:SetSpringArmRotation(InPitch, InYaw, InRoll, bInterp, InterpVelocity)
    if self.SpringArmComponent == nil then
        return
    end
    if bInterp == true then
        self.SpringArmRotationTimeCount = 0
        self.SpringArmRotationTarget = UE.FRotator(InPitch, InYaw, InRoll)
		self.CamRotInterpVelocity = InterpVelocity
    else
		if bInterp == false then
			self.SpringArmRotationTimeCount = nil
			self.SpringArmRotationTarget = nil
			self.CamRotInterpVelocity = nil
		end
        self.SpringArmComponent:K2_SetRelativeRotation(UE.FRotator(InPitch, InYaw, InRoll), false, nil, false)
    end
end

function CompanionRender2DView:SetModelScale(InScale, bInterp)
    if self.CompanionActor == nil then return end

    if bInterp == true then
        self.ModelScaleTarget = InScale
    else
        self.CompanionActor:SetModelScale(InScale)
    end
end

function CompanionRender2DView:SetShadowQuality(ShadowDistance)
    local TodMainActor = nil
    if not self.DirectionalLightComponent then
       TodMainActor = UE.UEnvMgr:Get():GetTodSystem()
    end
    FLOG_INFO("Camera Distance:%f", ShadowDistance)
    UE.UCommonUtil.SetShadowQualityFromCurve(ShadowDistance, self.DirectionalLightComponent, TodMainActor)
end

function CompanionRender2DView:SetModelLocation(InX, InY, InZ, bInterp)
    if self.SkeletalMeshComponent == nil then return end

    if bInterp == true then
        self.ModelLocationTarget = UE.FVector(InX, InY, InZ);
    else
        self.SkeletalMeshComponent:K2_SetRelativeLocation(UE.FVector(InX, InY, InZ), false, nil, false)
    end
end

function CompanionRender2DView:SetModelRotation(InPitch, InYaw, InRoll, bInterp)
    if self.SkeletalMeshComponent == nil then return end

    if bInterp == true then
        self.ModelRotationTarget = UE.FRotator(InPitch, InYaw, InRoll)
    else
		self.SkeletalMeshComponent:K2_SetRelativeRotation(UE.FRotator(InPitch, InYaw, InRoll), false, nil, false)
    end
end

function CompanionRender2DView:SetActorVisible(IsVisible)
	if self.CompanionActor == nil or IsVisible == nil then return end
	local CompanionCharacter = self.CompanionActor:Cast(UE.ACompanionCharacter)
	CompanionCharacter:SetActorVisibility(IsVisible, _G.UE.EHideReason.Common)
end

function CompanionRender2DView:GetActorVisible()
	if self.CompanionActor == nil then return end
	local CompanionCharacter = self.CompanionActor:Cast(UE.ACompanionCharacter)
	return CompanionCharacter:GetActorVisibility()
end

function CompanionRender2DView:EnableRotator(bEnable)
    self.bEnableRotator = bEnable
end

function CompanionRender2DView:SetSpringArmCenterOffsetY(OffsetY)
    self.CenterOffsetY = OffsetY
    --[sammrli] 计算偏移后相机和目标点的角度，角度*领边(springDistance)可以求出对边offsetY缩放后的值
    self.CamToTargetRadians = math.atan(OffsetY, self:GetSpringArmDistance())
end

function CompanionRender2DView:SetCompanionActor(Actor)
	self.CompanionActor = Actor
end

function CompanionRender2DView:UpdateAllLights()
    if self.SceneActor == nil or self.LightPreset == nil then return end
    self.SceneActor:UpdateLights(self.CompanionActor, self.LightPreset)
    LightMgr:RecordLightPreset(self.SceneActor, self.LightPreset)
end

function CompanionRender2DView:GetPostProcessVignetteIntensity()
    if self.PostProcessComponent == nil then return end
    return self.PostProcessComponent.Settings.VignetteIntensity
end

function CompanionRender2DView:SetPostProcessVignetteIntensity(InValue)
    if self.PostProcessComponent == nil then return end

    self.PostProcessVignetteIntensity = tonumber(InValue)
end

function CompanionRender2DView:SwitchSceneLights(IsOn)
    local LightList = self.SceneActor:K2_GetComponentsByClass(UE.ULightComponentBase)
    local Count = LightList:Length()
    for i = 1, Count do
        local LightComponent = LightList:Get(i)
        LightComponent:SetVisibility(IsOn)
    end
end

function CompanionRender2DView:SwitchOtherLights(IsOn)
    self:SwitchLights(IsOn)
end

function CompanionRender2DView:GetCameraComponent()
    return self.SceneActor:GetComponentByClass(UE.UCameraComponent)
end

--需要LOD强制设置为0时，参数传1
function CompanionRender2DView:SetActorLOD(LODLevel)
    local AvatarComponent = self:GetCompanionAvatarComponent()
    if AvatarComponent == nil then return end
    
    AvatarComponent:SetForcedLODForAll(LODLevel)
end

function CompanionRender2DView:MarkStartRotate()
    self.Rotating = true
    self.TimeAfterEndRotate = 0
    _G.EventMgr:SendEvent(EventID.CompanionArchiveModelStartRotate)
end

function CompanionRender2DView:MarkEndRotate()
    self.Rotating = false
end

function CompanionRender2DView:CheckRotateState(DeltaTime)
    if self.Rotating then return end

    if not self.Rotating and self.TimeAfterEndRotate ~= -1 then
        self.TimeAfterEndRotate = self.TimeAfterEndRotate + DeltaTime
    end

    if self.TimeAfterEndRotate >= 1 then
        _G.EventMgr:SendEvent(EventID.CompanionArchiveModelEndRotate)
        self.TimeAfterEndRotate = -1
    end
end

function CompanionRender2DView:SetSingleClickCallback(Caller, Callback)
    self.SingleClickCallback = {}
    self.SingleClickCallback.Caller = Caller
    self.SingleClickCallback.Callback = Callback
end

function CompanionRender2DView:OnSingleClick()
   if self.SingleClickCallback then
    self.SingleClickCallback.Callback(self.SingleClickCallback.Caller)
   end
end

function CompanionRender2DView:SetInteractionActive(IsActive)
    self.CanTick = IsActive
end

function CompanionRender2DView:SetRenderTextureGamma(Gamma)
    local CaptureComp2D = self.SceneActor.SceneCaptureComponent2D
	if nil == CaptureComp2D then return end

	local RT = CaptureComp2D.TextureTarget
	if nil == RT then return end

	RT.TargetGamma = Gamma
end

function CompanionRender2DView:SetCameraCaptureSource(Source) 
	local CaptureComp2D = self.SceneActor.SceneCaptureComponent2D
	if CaptureComp2D then
		CaptureComp2D.CaptureSource = Source 
	end
end

function CompanionRender2DView:SetBackgroundLocation(Location)
    if self.BackgroundActor then
        self.BackgroundActor:K2_SetActorLocation(Location, false, nil, false)
    end
end

function CompanionRender2DView:GetCompanionAvatarComponent()
    return self.CompanionActor and self.CompanionActor:GetAvatarComponent()
end

function CompanionRender2DView:SetSceneVisible(Visible)
    if self.SceneActor and CommonUtil.IsObjectValid(self.SceneActor) then
        self.SceneActor:SetActorHiddenInGame(not Visible)
	end
end

function CompanionRender2DView:SetBackgroundVisible(Visible)
    if self.BackgroundActor and CommonUtil.IsObjectValid(self.BackgroundActor) then
        self.BackgroundActor:SetActorHiddenInGame(not Visible)
	end
end

function CompanionRender2DView:GetFOVY()
	local FOVX = self:GetFOV()
	if nil == FOVX then
		return nil
	end
	local AspectRatio = UE.UCameraMgr.Get():GetAspectRatio()
	local TanHalfFOVY = (1 / AspectRatio) * math.tan(math.rad(FOVX) * 0.5)
	local FOVY = math.deg(2 * math.atan(TanHalfFOVY))

	return FOVY
end

function CompanionRender2DView:GetFOV()
    local CameraMgr = UE.UCameraMgr.Get()
	if CameraMgr ~= nil then
        return CameraMgr:GetCurrentPlayerManagerLockedFOV()
    end

	return nil
end

function CompanionRender2DView:GetCompanionName(CompanionID)
	local Cfg = CompanionCfg:FindCfgByKey(CompanionID)
	return Cfg and Cfg.Name or ""
end

--- 切换加载的宠物
---@param CompanionID int32 宠物ID
function CompanionRender2DView:SwitchModel(CompanionID)
	if self.CompanionActor == nil then return end

	FLOG_INFO(string.format("[CompanionRender2DView][SwitchModel]Load %s model", self:GetCompanionName(CompanionID)))
	local CompanionCharacter = self.CompanionActor:Cast(UE.ACompanionCharacter)
	CompanionCharacter:SwitchRole(CompanionID)
end

function CompanionRender2DView:CreateShadow()
    if not self.IsNeedShadow then return end
    if self.ShadowActor then return end

    local SystemType = ActorUtil.ShadowType.Companion
    self.ShadowActor = ActorUtil.CreateUIActorShandow(self, self.CompanionActor, self.ShadowImage, nil, SystemType)
end

function CompanionRender2DView:DestroyShadow()
    if self.ShadowActor then
        CommonUtil.DestroyActor(self.ShadowActor)
        self.ShadowActor = nil
    end
end

function CompanionRender2DView:SetupUITOD(CreateParam)
    local SystemID = CompanionLightSystemID
    if CreateParam then
        if CreateParam.SystemID then
            SystemID = CreateParam.SystemID
        elseif CreateParam.NoNeedUITOD then
            -- 以防万一有的系统就是不要UITOD则不处理
            return
        end
    end
    if SystemID == 0 then return end

    LightMgr:EnableUIWeather(SystemID)
end

function CompanionRender2DView:SetupLightPreset(CreateParam)
    local SystemID = CompanionLightSystemID
    if CreateParam then
        if CreateParam.SystemID then
            SystemID = CreateParam.SystemID 
        elseif CreateParam.NoNeedLightPreset then
            -- 以防万一有的系统就是不要灯光预设则不处理
            return
        end
    end
    if SystemID == 0 then return end

    local LightCfg = SystemLightCfg:FindCfgByKey(SystemID)
    if LightCfg then
        local PathList = LightCfg.LightPresetPaths
        self.LightPreset = ObjectMgr:LoadObjectSync(PathList[1])
        if self.LightPreset then
            if CommonUtil.IsWithEditor() then
                _G.LightMgr:PrintLightPreset(PathList[1])
            end
            self:UpdateAllLights()
        else
            FLOG_ERROR("[CompanionRender2DView][SetupLightPreset]SystemID:" .. SystemID .. " Invalid light preset path")
        end
    end
end

return CompanionRender2DView