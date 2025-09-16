local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local ObjectGCType = require("Define/ObjectGCType")
local ActorUtil = require("Utils/ActorUtil")
local CommonDefine = require("Define/CommonDefine")
local MathUtil = require("Utils/MathUtil")
local FMath = _G.UE.UKismetMathLibrary
--local RenderActorPath = "Class'/Game/UI/Render2D/Render2DLoginActor.Render2DLoginActor_C'"
--local SkeletalMeshPath = "SkeletalMesh'/Game/Assets/Character/Human/Skeleton/c0101/SK_c0101b9999.SK_c0101b9999'"
--local AnimationPath = "BlendSpace'/Game/Assets/Character/Human/Animation/run_idle.run_idle'"

local LoginConfig = require("Define/LoginConfig")
local UILevelMgr = require("Game/Common/Render2D/Level/UILevelMgr")
local LightMgr = require("Game/Light/LightMgr")
local AnimMgr = require("Game/Anim/AnimMgr")

local RootLocationZ = 100000
local SpringTargetArmLengthMax = 600
local SpringTargetArmLengthMin = 100
local SpringTargetDefaultZ = 90
local ZoomSpeedFactor = 0.75
local ZoomInterpVelocity = 8.0
local FINGER_NUM_ONE =  1
local FINGER_NUM_TWO =  2

---@class CameraStatus
local CameraStatus = LuaClass()
function CameraStatus:Ctor()
	self.ViewDistance = 0
	self.SpringArmLocation = nil
	self.SpringArmRotation = nil
	self.FOV = 0
end

---@class CharacterStatus
local CharacterStatus = LuaClass()
function CharacterStatus:Ctor()
	self.Location = nil
	self.Rotation = nil
end

---@class AdventureRender2dView : UIView
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
---@field bTODReflectionDeactivated bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureRender2dView = LuaClass(UIView, true)

AdventureRender2dView.ShowCount = 0

function AdventureRender2dView:Ctor()
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
	--self.bTODReflectionDeactivated = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureRender2dView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureRender2dView:OnInit()
    self.bEnableZoom = true
    self.bEnableRotator = true
    self.bEnableMove = false
    self.bEnableMoveImmediately = false
    self.AutoRotator = false
    self.CenterOffsetY = 0
    self.RideSkelentonMesh = nil
    self.RideMeshComponent = nil
    self.bOnRide = false
    self.CamToTargetRadians = 0
	self.CamLocInterpVelocity = nil
	self.CamControlParams = nil
	self.SavedCamStatus = nil
	self.SavedCharaStatus = nil
	self.FOVInterpVelocity = nil
	self.CamRotInterpVelocity = nil
	self.bIsFullScreen = false
	self.bIgnoreBackground = false
    self.bCanControlCamRot = false
    
    self.DoActive = nil
	self.bForceVisible = false
    self.bIsShowHead = true

    self.CallBackMove = nil
    self.CallBackRotate = nil
    self.CallBackZoom = nil
    self.CallBackSetFullScreen = nil
    self.MoveLimiParams = nil
    self.RotateLimiParams = nil
    self.bCanRotate = true
	self.CachedFOV = 0
	self.bAutoInitSpringArm = true

	self.DefaultSpringArmLength = SpringTargetArmLengthMax
	self.DefaultSpringArmLocationZ = SpringTargetDefaultZ
    --默认不是登录相关的
    self.bLogin = false

	self.MouseWheelCallbackView = nil
	self.MouseWheelCallback = nil
	self.DefaultIsCanZoom = true

    self.bIgnoreTodAffective = false

	self.bCombatRestEnabled = false

    --其他Npc
    self.OtherNpcTable = {}
    self.NeedSetCamera = false
    self.SpecialCameraLocation = {}
    self.SpecialCameraRotation = {}
    self.CenterPoint = nil
end

--- 滚轮事件回调
---@param IsCanZoom 是否支持缩放 默认为true
function AdventureRender2dView:SetMouseWheelCallBack(View, CallBack, IsCanZoom)
	self.MouseWheelCallbackView = View
	self.MouseWheelCallback = CallBack
	if IsCanZoom ~= false then
		IsCanZoom = true
	end
	self.DefaultIsCanZoom = IsCanZoom
end

function AdventureRender2dView:OnMouseWheel(InGeometry, InMouseEvent)
	self:SetCanZoom(self.DefaultIsCanZoom)
	local WheelDelta = UE.UKismetInputLibrary.PointerEvent_GetWheelDelta(InMouseEvent)
	self.ZoomScale = WheelDelta

	if self.MouseWheelCallback and self.MouseWheelCallbackView then
		self.MouseWheelCallback(self.MouseWheelCallbackView, WheelDelta)
	end

	return _G.UE.UWidgetBlueprintLibrary:Handled()
end

function AdventureRender2dView:OnDestroy()
end

function AdventureRender2dView:OnShow()
    AdventureRender2dView.ShowCount = AdventureRender2dView.ShowCount + 1
    FLOG_INFO("AdventureRender2dView:OnShow ShowCount:%d", AdventureRender2dView.ShowCount)

	-- 禁用关卡流送，避免主视角切换导致子关卡被卸载
	UILevelMgr:SwitchLevelStreaming(false)
end

function AdventureRender2dView:OnHide()
	-- 恢复关卡流送
	UILevelMgr:SwitchLevelStreaming(true)
    AdventureRender2dView.ShowCount = AdventureRender2dView.ShowCount - 1
    FLOG_INFO("AdventureRender2dView:OnShow OnHide:%d", AdventureRender2dView.ShowCount)

    self:ReleaseActor()
end

function AdventureRender2dView:SetCanRotate(flag)
    self.bCanRotate = flag
end

-- 将布局扩展到全屏并将渲染层级置顶
function AdventureRender2dView:SetFullScreen(bIsFullScreen)
    if bIsFullScreen then
		self.DefaultZOrder = UIUtil.CanvasSlotGetZOrder(self.Object)
		self.DefaultLayout = UIUtil.CanvasSlotGetLayout(self.Object)
		local AnchorData = _G.UE.FAnchorData()
		AnchorData.Anchors.Maximum = _G.UE.FVector2D(1, 1)
		UIUtil.CanvasSlotSetLayout(self.Object, AnchorData)
		UIUtil.CanvasSlotSetZOrder(self.Object, 1000)
        if self.CallBackSetFullScreen then
            self.CallBackSetFullScreen(1000)
        end
	else
		UIUtil.CanvasSlotSetLayout(self.Object, self.DefaultLayout)
		UIUtil.CanvasSlotSetZOrder(self.Object, self.DefaultZOrder)
        if self.CallBackSetFullScreen then
            self.CallBackSetFullScreen(nil)
        end
	end
	self.bIsFullScreen = bIsFullScreen
end

-- 强制场景Actor在非活跃状态可见，一次性设置，页面再次激活时取消强制
function AdventureRender2dView:SetForceVisible(bForceVisible)
	self.bForceVisible = bForceVisible
end

function AdventureRender2dView:SetActiveFlag(bActive)
    self.DoActive = bActive
end

function AdventureRender2dView:GetActiveFlag()
    return self.DoActive
end

function AdventureRender2dView:OnActive()
    if self.DoActive ~= false and not self.bForceVisible then
        self:ShowRenderActor(true)
        self:SwitchOtherLights(false)
        self:UpdateAllLights()
		if self.CachedFOV > 0 then
			self:SetCameraFOV(self.CachedFOV)
		end
    end
	self:SetForceVisible(false)
end

function AdventureRender2dView:OnInactive()
    if self.DoActive ~= false and not self.bForceVisible then
        self:ShowRenderActor(false)
    end
end

function AdventureRender2dView:OnRegisterUIEvent()
end

function AdventureRender2dView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.Avatar_Update_Master, self.OnUpdateMaster)
	self:RegisterGameEvent(_G.EventID.MajorProfSwitch, self.OnProfSwitch)
end

function AdventureRender2dView:OnRegisterTimer()
end

function AdventureRender2dView:OnRegisterBinder()
end

function AdventureRender2dView:SaveCameraStatus()
	if nil == self.SavedCamStatus then
		self.SavedCamStatus = CameraStatus.New()
	end
	self.SavedCamStatus.ViewDistance = self:GetSpringArmDistance()
	self.SavedCamStatus.SpringArmLocation = self:GetSpringArmLocation()
	self.SavedCamStatus.SpringArmRotation = self:GetSpringArmRotation()
	self.SavedCamStatus.FOV = self:GetFOV()
end

function AdventureRender2dView:RecoverCameraStatus(bInterp)
	local SavedCamStatus = self.SavedCamStatus
	if nil == SavedCamStatus then
		return
	end
	self:SetSpringArmDistance(SavedCamStatus.ViewDistance, bInterp)
	self:SetSpringArmLocation(SavedCamStatus.SpringArmLocation.X, SavedCamStatus.SpringArmLocation.Y, SavedCamStatus.SpringArmLocation.Z, bInterp)
	self:SetSpringArmRotation(SavedCamStatus.SpringArmRotation.Pitch, SavedCamStatus.SpringArmRotation.Yaw, SavedCamStatus.SpringArmRotation.Roll, bInterp)
	self:SetCameraFOV(SavedCamStatus.FOV, bInterp)
end

function AdventureRender2dView:SaveCharacterStatus()
	if nil == self.SavedCharaStatus then
		self.SavedCharaStatus = CharacterStatus.New()
	end
	self.SavedCharaStatus.Location = self:GetModelLocation()
	self.SavedCharaStatus.Rotation = self:GetModelRotation()
end

function AdventureRender2dView:RecoverCharacterStatus(bInterp)
	local SavedCharaStatus = self.SavedCharaStatus
	if nil == SavedCharaStatus then
		return
	end

	if nil ~= SavedCharaStatus.Location then
		self:SetModelLocation(SavedCharaStatus.Location.X, SavedCharaStatus.Location.Y, SavedCharaStatus.Location.Z, bInterp)
	end
	if nil ~= SavedCharaStatus.Rotation then
		self:SetModelRotation(SavedCharaStatus.Rotation.Pitch, SavedCharaStatus.Rotation.Yaw, SavedCharaStatus.Rotation.Row, bInterp)
	end
end

function AdventureRender2dView:GetEquipmentConfigAssetUserData()
	if nil == self.ChildActorComponent then
		return nil
	end
    return self.ChildActorComponent:GetEquipmentConfigAssetUserData()
end

function AdventureRender2dView:GetCameraControlAssetUserData()
	if nil == self.ChildActorComponent then
		return nil
	end
    return self.ChildActorComponent:GetCameraControlAssetUserData()
end

function AdventureRender2dView:ReCreateActorWhenDestroy()
    local EquipUserData = self:GetEquipmentConfigAssetUserData()
	local CameraUserData = self:GetCameraControlAssetUserData()
    self:CreateActor()
    self:SetUICharacterByEntityID(self.ShowEntityID)
    self.ChildActorComponent:SetEquipmentConfigAssetUserData(EquipUserData)
	self.ChildActorComponent:SetCameraControlAssetUserData(CameraUserData)
    if self.ReCreateCallBack then
        self.ReCreateCallBack()
    end
end

function AdventureRender2dView:CreateActor()
    if not self.RenderActor or not CommonUtil.IsObjectValid(self.RenderActor) then
        FLOG_WARNING("AdventureRender2dView:CreateActor RenderActor is nil")
        return false
    end

    self.ChildActorComponent = self.RenderActor:GetComponentByClass(_G.UE.UFMChildActorComponent)
    self.DirectionalLightComponent = self.RenderActor:GetComponentByClass(_G.UE.UDirectionalLightComponent)
    --设置ChildClass
    --self.ChildActorComponent:SetChildActorClass(_G.UE.AUIComplexCharacter)
    self.ChildActorComponent:SetChildActorClass(self.CharacterClass)
    self.ChildActor = self.ChildActorComponent:GetChildActor()
    _G.ProfMgr:SetCurUIActor(self.ChildActor)
    self.SkeletalMeshComponent = self:GetSkeletalMeshComponent(self.ChildActor)
	self.PostProcessComp = self.RenderActor:GetComponentByClass(_G.UE.UPostProcessComponent)
    local ActorComponent = nil
    if not self.bLogin then
        ActorComponent = self.RenderActor:GetComponentByClass(_G.UE.USpringArmComponent)
    else
        local CameraActor = _G.LoginUIMgr:GetCameraActor()
        if CameraActor then
            ActorComponent = CameraActor:GetComponentByClass(_G.UE.USpringArmComponent)
        end
    end
    
    if ActorComponent ~= nil then
        self.SpringArmComponent = ActorComponent:Cast(_G.UE.USpringArmComponent)
    end

	local CameraComp = self.RenderActor:GetComponentByClass(_G.UE.UCameraComponent)
	if nil ~= CameraComp then
		self:SetCameraFOV(CameraComp.FieldOfView, false)
	end
    return true
end

function AdventureRender2dView:CreateRenderActor(RenderActorPath, CharacterClass, LightPresetPath, bSample, CallBack, ReCreateCallBack)
    if self.RenderActor ~= nil then
        FLOG_WARNING("=======AdventureRender2dView:CreateRenderActor, self.RenderActor is ok")
        return
    end

    if CommonUtil.IsWithEditor() then
        _G.LightMgr:PrintLightPreset(LightPresetPath)
    end

	local function CallBack1()
        if self.RenderActor ~= nil then
            FLOG_WARNING("#####AdventureRender2dView:CreateRenderActor, self.RenderActor is ok")
            return
        end

        if (self.bReleaseActor == true) then
            CallBack(false)
            return
        end

        local Class1 = _G.ObjectMgr:GetClass(RenderActorPath)
        if Class1 == nil then
            return
        end

        self.CharacterClass = _G.ObjectMgr:LoadClassSync(CharacterClass)
        if self.CharacterClass == nil then
            return
        end

        local Z = RootLocationZ
        local Ratation = _G.UE.FRotator(0, 0, 0)
        
        if self.bLogin then
            Z = 0
            Ratation = _G.UE.FRotator(0, _G.LoginMapMgr:GetActorYawOffset(), 0)
        end

        self.RenderActor = CommonUtil.SpawnActor(Class1, _G.UE.FVector(0, 0, Z), Ratation)
        if self.RenderActor == nil then
            return
        end
		self.RenderActor.Tags:AddUnique(CommonDefine.UIActorTag)
		self.RenderActor.OnEndPlay:Add(self, self.OnRenderActorEndPlay)

        self.PostProcessComp = self.RenderActor:GetComponentByClass(_G.UE.UPostProcessComponent)

        self.LightPreset = _G.ObjectMgr:LoadObjectSync(LightPresetPath)

        self.ReCreateCallBack = ReCreateCallBack

        local Rlt = self:CreateActor(bSample)
        if not Rlt then
            return
        end
        
        self.ChildActorComponent.ChildActorReCreateDelegate = { self.RenderActor, function ()
            self:ReCreateActorWhenDestroy()
        end }

        if (CallBack) then
            CallBack(true)
        end
    end

    --异步写法
    self.bReleaseActor = false
    _G.ObjectMgr:LoadClassAsync(RenderActorPath, CallBack1, ObjectGCType.LRU)
end

function AdventureRender2dView:SetOhterActor(ActorEidList)
    self.OtherNpcTable = ActorEidList
end

function AdventureRender2dView:SetShadowDistanceCurve()
end

function AdventureRender2dView:ResetLightPreset(LightPresetPath)
    self.LightPreset = _G.ObjectMgr:LoadObjectSync(LightPresetPath)
    if CommonUtil.IsWithEditor() then
        _G.LightMgr:PrintLightPreset(LightPresetPath)
    end

    -- 更新与相机距离相关灯光效果
    if nil ~= self.RenderActor and CommonUtil.IsObjectValid(self.RenderActor) and nil ~= self.RenderActor.ShadowDistanceCurve then
        local ShadowDistance = self.RenderActor.ShadowDistanceCurve:GetFloatValue(self:GetSpringArmDistance())
        self:SetShadowQuality(ShadowDistance)
        -- if nil ~= self.DirectionalLightComponent then
        --     self.DirectionalLightComponent:SetDynamicShadowDistanceMovableLight(ShadowDistance)
        -- end
    end

    self:UpdateAllLights()
end

---@return USkeletalMeshComponent
function AdventureRender2dView:GetSkeletalMeshComponent(Actor)
    if nil == Actor then
        return
    end

    local Component = Actor:GetComponentByClass(_G.UE.USkeletalMeshComponent)
    if Component == nil then
        return
    end
    return Component:Cast(_G.UE.USkeletalMeshComponent)
end

function AdventureRender2dView:ReleaseActor()
    self.CameraRollAngle = 0 
    self.DirectionalLightComponent = nil
    self.CharacterClass = nil
    self.bReleaseActor = true
    self:SwitchActorAutoRotator(false)
    if not self.bLogin then
        self:ChangeUIState(true)
    end
    _G.ProfMgr:SetCurUIActor(nil)
    self.ChildActor = nil
    self.SkeletalMeshComponent = nil
    self.SpringArmComponent = nil
    self.ChildActorComponent = nil
    self.UIComplexCharacter = nil
    self.PostProcessComp = nil

    self.FocusSocketName = nil
    
    self.ModelRotationTarget = nil
    self.ModelScaleTarget = nil
    self.ModelLocationTarget = nil
    self.SpringArmDistanceTarget = nil
    self.SpringArmLocationTarget = nil
    self.SpringArmRotationTarget = nil
	self.FOVTarget = nil

    self.RideMeshComponent = nil
    self.bOnRide = false
    self.CallBackMove = nil
    self.CallBackRotate = nil
    self.CallBackZoom = nil
    self.MoveLimiParams = nil
    self.RotateLimiParams = nil

    self.OtherNpcTable = {}
    self.NeedSetCamera = false
    self.SpecialCameraLocation = {}
    self.SpecialCameraRotation = {}

	if nil ~= self.RenderActor and CommonUtil.IsObjectValid(self.RenderActor) then
		self.RenderActor.OnEndPlay:Remove(self, self.OnRenderActorEndPlay)
    	CommonUtil.DestroyActor(self.RenderActor)
	end
	self.RenderActor = nil
end

function AdventureRender2dView:OnRenderActorEndPlay(Actor, EndPlayReason)
	self:ReleaseActor()
end

function AdventureRender2dView:ShowCharacter(bShow)
    if self.ChildActor and CommonUtil.IsObjectValid(self.ChildActor) then
        self.ChildActor:SetActorHiddenInGame(not bShow)
    end
end

function AdventureRender2dView:IgnoreBackground(bIgnore)
	self.bIgnoreBackground = bIgnore
end

function AdventureRender2dView:ShowRenderActor(bShow)
    if self.RenderActor then
        -- self.RenderActor:SetActorHiddenInGame(not bShow)
		local LightComps = self.RenderActor:K2_GetComponentsByClass(_G.UE.USpotLightComponent)
		for Index = 1, LightComps:Length() do
			local LightComp = LightComps:GetRef(Index)
			if nil ~= LightComp then
				LightComp:SetVisibility(bShow, false)
			end
		end
		if not self.bIgnoreBackground then
			self:SetParticleVisibility(bShow)
		end
    end
	if nil ~= self.PostProcessComp then
		self.PostProcessComp.bEnabled = bShow
	end
    self:ShowCharacter(bShow)
end

function AdventureRender2dView:SetParticleVisibility(bShow)
	if nil == self.RenderActor then
		return
	end
	-- 特效组件直接设置可见性，会晚一帧才生效，因此改为设置缩放
	local ParticleComp = self.RenderActor:GetComponentByClass(_G.UE.UParticleSystemComponent)
	if nil ~= ParticleComp then
		local Scale = bShow and _G.UE.FVector(1, 1, 1) or _G.UE.FVector(0, 0, 0)
		ParticleComp:SetRelativeScale3D(Scale)
	end
end

---ChangeUIState
---切换相机显示状态
---@param ShowUI 是否显示UI
function AdventureRender2dView:ChangeUIState(ShowUI)
    if ShowUI then
        local CameraMgr = _G.UE.UCameraMgr.Get()
        if CameraMgr ~= nil then
            if not self.bLogin then
                CameraMgr:ResumeCamera(0, true, self.RenderActor)
            else
                CameraMgr:ResumeCamera(0, true, _G.LoginUIMgr:GetCameraActor())
            end
        end
    else
        --切换相机
        local CameraMgr = _G.UE.UCameraMgr.Get()
        if CameraMgr ~= nil then
            if not self.bLogin then
                CameraMgr:SwitchCamera(self.RenderActor, 0)
            else
                if not _G.LoginUIMgr.IsAlreadySwitchCamera then
                    _G.LoginUIMgr.IsAlreadySwitchCamera = true
                    CameraMgr:SwitchCamera(_G.LoginUIMgr:GetCameraActor(), 0)
                end
            end
        end
    end
end

-- 初始化默认的注视点位置
function AdventureRender2dView:InitSpringArmEndPos()
	if not self.bAutoInitSpringArm then
		return
	end

    if self.RenderActor ~= nil and self.DefaultFocusLoc == nil and self.UIComplexCharacter ~= nil and
	 _G.UE.UCommonUtil.IsObjectValid(self.UIComplexCharacter) and (self.UIComplexCharacter:IsAssembleAllEnd() == true) then
		self:UpdateFocusLocation()
    end
end

function AdventureRender2dView:UpdateFocusLocation()
    if nil == self.RenderActor or nil == self.UIComplexCharacter then
		return
	end
	local ActorTransform = self.RenderActor:GetTransform()
	local SocketLocation = self.UIComplexCharacter:GetSocketLocationByName("head_M")
	if nil ~= self.CamControlParams and nil ~= self.CamControlParams.FocusEID then
		local EIDTransform = _G.UE.FTransform()
		self.UIComplexCharacter:GetEidTransform(self.CamControlParams.FocusEID, EIDTransform)
		local DummyRotator = _G.UE.FRotator()
		local DummyScale = _G.UE.FVector()
		_G.UE.UKismetMathLibrary.BreakTransform(EIDTransform, SocketLocation, DummyRotator, DummyScale)
		print("Default focus location: "..tostring(SocketLocation))
	end
	self.DefaultFocusLoc = _G.UE.UKismetMathLibrary.InverseTransformLocation(ActorTransform, SocketLocation)

    local TargetViewDist = self:GetSpringArmDistance()
    local bInterp = true
	self:ResetViewDistanceInternal(TargetViewDist, bInterp)

end

-- --补偿光，10号等
-- function AdventureRender2dView:OpenExtraRoomLight()
--     if self.RenderActor then
--         -- local AttributeComp = self.UIComplexCharacter:GetAttributeComponent()
--         self.RenderActor:OpenExtraRoomLight()
--     end
-- end

function AdventureRender2dView:SetLightLookatHead(LightName)
    if self.RenderActor and self.UIComplexCharacter then
        local TargetEIDTransform = _G.UE.FTransform()
        self.UIComplexCharacter:GetEidTransform("EID_LOOK_AT", TargetEIDTransform)
        self.RenderActor:SetLightLookatHead(LightName,  TargetEIDTransform:GetLocation())
    end
end

function AdventureRender2dView:OnSingleClick()
    if (self.SingleClick) then
        self.SingleClick(self.ClickView)
    end
end

function AdventureRender2dView:OnDoubleClick()
    if (self.DoubleClick) then
        self.DoubleClick(self.ClickView)
    end
end

--会重写蓝图中的Tick函数
function AdventureRender2dView:Tick(_, InDeltaTime)
    self:InitSpringArmEndPos()
    --缩放时不能旋转
    local FingerNum = self.FingerNum
    if FingerNum == FINGER_NUM_TWO and self.bEnableZoom then
        local Touch1CurX  = self.Touch1CurX
        local Touch2CurX =  self.Touch2CurX
        local Touch1CurY  = self.Touch1CurY
        local Touch2CurY =  self.Touch2CurY
        local TouchOffset = math.sqrt((self.Touch1StartX - self.Touch2StartX)^2 + (self.Touch1StartY - self.Touch2StartY)^2)
        local CurOffset = math.sqrt((Touch1CurX - Touch2CurX)^2 + (Touch1CurY - Touch2CurY)^2)

        -- local Zoom = CurOffset * 1.0 / TouchOffset

        -- if Zoom > 1.005 and Zoom < 1.2 then
        --     self.ZoomScale = 0.5
        -- elseif Zoom > 0.8 and Zoom < 0.995 then
        --     self.ZoomScale = -0.5
        -- else
        --     self.ZoomScale = 0
        -- end
		self.ZoomScale = (CurOffset - TouchOffset) * InDeltaTime * ZoomSpeedFactor
        self.Touch1StartX = Touch1CurX
        self.Touch2StartX = Touch2CurX
		self.Touch1StartY = Touch1CurY
		self.Touch2StartY = Touch2CurY
        self:SetCanZoom(true)
        self.CanRotate = false
    end

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

    --是否开启移动
    if (self.bEnableMove or self.bEnableMoveImmediately) and FingerNum == FINGER_NUM_ONE then
        if not self:GetCanZoom() and not self:GetCanMove() and (self.CurPosX == 0 or FMath.abs(self.StartPosX - self.CurPosX) <= 5) then
            self.PressTime = self.PressTime + InDeltaTime
            if self.PressTime > 0.5 or self.bEnableMoveImmediately then
                self:SetCanMove(true)
                self.CanRotate = false
                self.PressTime = 0
                self.SpringArmLocationTarget = nil
            end
        end
    end

	self:HandlePan()

    --缩放：直接访问、设置self.CanZoom有问题，用Get/Set函数正常
    if self:GetCanZoom() == true then
       self:SetSelfActorZoom()
    end

    --移动
    if self:GetCanMove() and (self.CurPosX ~= 0 or self.CurPosY ~= 0) then
        local OffsetX = self.CurPosX - self.PrePosX
        local OffsetY = self.CurPosY - self.PrePosY
        if self.CameraRollAngle then --如果相机Roll,求XY轴的分量
            local X = OffsetX
            local Y = OffsetY
            local Angle = math.rad(self.CameraRollAngle)
            OffsetX = X * math.cos(Angle) - Y * math.sin(Angle)
            OffsetY = X * math.sin(Angle) + Y * math.cos(Angle)
        end
        local Pixed = self:GetSpringArmDistance() * math.tan(math.rad(20)) * 2 / UIUtil.GetViewportSize().Y
        local Location = self:GetSpringArmLocation()
        Location.y = Location.y + OffsetX * Pixed
        Location.z = Location.z + OffsetY * Pixed
        if self.MoveLimiParams then
            Location.y = math.clamp(Location.y, self.MoveLimiParams.MinHorizontal, self.MoveLimiParams.MaxHorizontal)
            Location.z = math.clamp(Location.z, self.MoveLimiParams.MinVertical, self.MoveLimiParams.MaxVertical)
        end
        self:SetSpringArmLocation(Location.x, Location.y, Location.z, false)
        self.CamToTargetRadians = math.atan(Location.y, self:GetSpringArmDistance())
        --self.DefaultFocusLoc = Location
        self.PrePosX = self.CurPosX
        self.PrePosY = self.CurPosY
    end

    ---进行插值动画start
	-- FOV插值
    if self.FOVTarget ~= nil then
        local CurFOV = self:GetFOV()
		local InterpVelocity = self.FOVInterpVelocity or ZoomInterpVelocity
        local InterpFOV = FMath.FInterpTo(CurFOV, self.FOVTarget, InDeltaTime, InterpVelocity)
        if MathUtil.IsNearlyEqual(self.FOVTarget, InterpFOV, 0.1) then
            -- 插值结束
			self:SetCameraFOV(self.FOVTarget, false)
        end
        self:SetCameraFOV(InterpFOV)
        self:SwitchActorAutoRotator(false)
    end
    --SpringArm插值
    if self.SpringArmDistanceTarget ~= nil then
        local CurDistance = self:GetSpringArmDistance()
        local InterpDistance = FMath.FInterpTo(CurDistance, self.SpringArmDistanceTarget, InDeltaTime, ZoomInterpVelocity)
        if self.SpringArmDistanceTarget == InterpDistance then
            --插值动画结束
            --print("SpringArm插值动画结束")
            self.SpringArmDistanceTarget = nil
        end
        self:SetSpringArmDistance(InterpDistance)
        self:SwitchActorAutoRotator(false)
    end

    --SpringRotation插值
    if self.SpringArmRotationTarget ~= nil then
        local CurRotation = self:GetSpringArmRotation()
        local Speed = self.CamRotInterpVelocity or _G.math.exp(self.SpringArmRotationTimeCount)
        local InterpRotation = UIUtil.QInterpTo(CurRotation, self.SpringArmRotationTarget, InDeltaTime, Speed)
        local DeltaMove = (self.SpringArmRotationTarget - InterpRotation):GetNormalized()
        local Tolerance = 0.001
        self.SpringArmRotationTimeCount = self.SpringArmRotationTimeCount + InDeltaTime
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
        local InterpLocation = FMath.VInterpTo(CurLocation, self.SpringArmLocationTarget, InDeltaTime, InterpVelocity)
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
        local InterpScale = FMath.FInterpTo(CurScale.x, self.ModelScaleTarget, InDeltaTime, 4.0)
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
        local InterpRotation = FMath.RInterpTo(CurRotation, self.ModelRotationTarget, InDeltaTime, 4.0)
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
    if self.ModelLocationTarget ~= nil then
        local CurLocation = self.ChildActor:K2_GetActorLocation();
        CurLocation.x = CurLocation.x - self.ChildActorLocation.x;
        CurLocation.y = CurLocation.y - self.ChildActorLocation.y;
        CurLocation.z = CurLocation.z - self.ChildActorLocation.z;
        local InterpLocation = FMath.VInterpTo(CurLocation, self.ModelLocationTarget, InDeltaTime, 4.0)
        if InterpLocation.x == self.ModelLocationTarget.x and 
            InterpLocation.y == self.ModelLocationTarget.y and 
            InterpLocation.z == self.ModelLocationTarget.z then
            --插值动画结束
            --print("Location插值动画结束")
            self.ModelLocationTarget = nil
        end
        self:SetModelLocation(InterpLocation.x, InterpLocation.y, InterpLocation.z)
    end
    ---进行插值动画end

    ---CameraFocus插值
    if self.FocusSocketName ~= nil then
        self:DoCameraFocusScreenLocation(true)
    end

    --自动旋转
    if self.AutoRotator == true and self.SkeletalMeshComponent ~= nil then
		local AutoRotateVel = nil ~= self.RenderActor and self.RenderActor.AutoRotateVel or 0.02
        if self.bOnUIRide == true then
            --坐骑专用旋转
            self.RideMeshComponent:K2_AddLocalRotation(_G.UE.FRotator(0, AutoRotateVel / InDeltaTime, 0), false, _G.UE.FHitResult(), false)
            self.SkeletalMeshComponent:K2_AddLocalRotation(_G.UE.FRotator(0, 0, 0), false, _G.UE.FHitResult(), false)
        else
            self.SkeletalMeshComponent:K2_AddLocalRotation(_G.UE.FRotator(0, AutoRotateVel / InDeltaTime, 0), false, _G.UE.FHitResult(), false)
        end
    end

    --设置VignetteIntensity
    if self.PostProcess_VignetteIntensity ~= nil and self.PostProcessComp ~= nil then
        local CurValue = self.PostProcessComp.Settings.VignetteIntensity
        local Interp_VignetteIntensity = FMath.FInterpTo(CurValue, self.PostProcess_VignetteIntensity, InDeltaTime, 3)
        --FLOG_ERROR("Interp_VignetteIntensity = %f", Interp_VignetteIntensity)
        self.PostProcessComp.Settings.VignetteIntensity = Interp_VignetteIntensity
        if FMath.Abs(self.PostProcess_VignetteIntensity - Interp_VignetteIntensity) < 0.005 then
            self.PostProcessComp.Settings.VignetteIntensity = self.PostProcess_VignetteIntensity
            self.PostProcess_VignetteIntensity = nil
        end
    end
end

-- 处理单指滑动
function AdventureRender2dView:HandlePan()
	local OffsetX = self.PrePosX - self.CurPosX
	local OffsetY = self.PrePosY - self.CurPosY
	local IsXAxisMainOffset = math.abs(OffsetX) > math.abs(OffsetY)

    -- 旋转 旋转距离太小时不触发旋转
    if not self:GetCanZoom() and self.CanRotate and self.bCanRotate and self.CurPosX ~= 0 and
	  FMath.abs(self.StartPosX - self.CurPosX) > 5 and IsXAxisMainOffset then
        if OffsetX > 15.0 then
            OffsetX = 15.0
        elseif OffsetX < -15.0 then
            OffsetX = -15.0
        end
        self:SetSelfActorRotation(OffsetX)
    end

   -- 相机俯仰 滑动差异太小时不触发俯仰
	if self.CanRotate and self.bCanRotate and self.bEnableRotator and self.CurPosY ~= 0
	  and FMath.abs(self.StartPosY - self.CurPosY) > 5 and not IsXAxisMainOffset then
		local Rotation = self:GetSpringArmRotation()
    	self.CameraRotateScale = self.CameraRotateScale or 0.1
		local NewPitch = Rotation.Pitch + OffsetY * self.CameraRotateScale
		NewPitch = nil ~= self.CamControlParams and math.clamp(NewPitch, self.CamControlParams.MinPitch,
			self.CamControlParams.MaxPitch) or NewPitch
		self:SetSpringArmRotation(NewPitch, Rotation.Yaw, Rotation.Roll, false)
	end
	self.PrePosX = self.CurPosX
	self.PrePosY = self.CurPosY
end

--Tick函数旋转
function AdventureRender2dView:SetSelfActorRotation(OffsetX)
    --自身旋转
    if self.SkeletalMeshComponent ~= nil and _G.UE.UCommonUtil.IsObjectValid(self.SkeletalMeshComponent) then
        --停止Rotation的插值
        self.ModelRotationTarget = nil
        if self.bEnableRotator then
            if self.RotateLimiParams then
                local Rotation = self.SkeletalMeshComponent:GetRelativeRotation()
                if Rotation.Yaw + OffsetX < self.RotateLimiParams.MinYaw then
                    OffsetX = self.RotateLimiParams.MinYaw - Rotation.Yaw
                elseif Rotation.Yaw + OffsetX > self.RotateLimiParams.MaxYaw then
                    OffsetX = self.RotateLimiParams.MaxYaw - Rotation.Yaw
                end
            end
            if self.bOnUIRide == true and self.RideMeshComponent ~= nil then
                --坐骑专用旋转
                self.SkeletalMeshComponent:K2_AddLocalRotation(_G.UE.FRotator(0, 0, 0), false, _G.UE.FHitResult(), false)
                self.RideMeshComponent:K2_AddLocalRotation(_G.UE.FRotator(0, OffsetX, 0), false, _G.UE.FHitResult(), false)
            else
                self.SkeletalMeshComponent:K2_AddLocalRotation(_G.UE.FRotator(0, OffsetX, 0), false, _G.UE.FHitResult(), false)
            end
            --self.ChildActor:SetForceCharacterRotation(_G.UE.FRotator(0, OffsetX, 0))
        end
        if self.CallBackRotate then
            local Rotation = self.SkeletalMeshComponent:GetRelativeRotation()
            self.CallBackRotate(Rotation.Yaw)
        end
        self.PrePosX = self.CurPosX
        self.PressTime = -999999
    end
    --外部配置的Npc旋转，暂定绕中心点旋转
    if self.OtherNpcTable and next(self.OtherNpcTable) then
        for key, value in pairs(self.OtherNpcTable) do
            local tActor = ActorUtil.GetActorByEntityID(value)
            local tActorLocation = tActor:K2_GetActorLocation()
            local tActorRotation = tActor:K2_GetActorRotation()
            local RotationCenter = self.CenterPoint or _G.UE.FVector(-120, 0, 100000)
            local tRelativeLocation = tActorLocation - RotationCenter
            local tNewRelativeLocation = tRelativeLocation:RotateAngleAxis(OffsetX, _G.UE.FVector(0, 0, 1))
            local NewLocation = tNewRelativeLocation + RotationCenter;
            tActor:K2_SetActorLocationAndRotation(NewLocation, tActorRotation + _G.UE.FRotator(0, OffsetX, 0), false, nil, false);
        end
    end
end

function AdventureRender2dView:SetSelfActorZoom()
    if self.bEnableZoom then
        if self.DefaultFocusLoc ~= nil then
            local CurViewDist = self:NormalizeTargetArmLength(self:GetSpringArmDistance() - self.ZoomScale * 60)
            local CallBack = function()
                if self.isSpecialCamera then
                    --这里不能用插值，不然Tick刷新会卡住镜头
                    self:RecoverCameraStatus()
                    self.isSpecialCamera = false
                else
                    self:SaveCameraStatus()
                end
                self:SetSpringArmDistance(CurViewDist, true)
                --缩放时设置位置偏移，默认为0
                local Location = _G.UE.FVector(0, self.CamToTargetRadians * CurViewDist, self.DefaultFocusLoc.z + self:GetZoomZOffset(CurViewDist))
                self:SetSpringArmLocation(Location.x, Location.y, Location.z, true, ZoomInterpVelocity) 
                -- 缩放时设置俯仰角偏移，默认为0
                -- local Rotation = self:GetSpringArmRotation()
                -- self:SetSpringArmRotation(self:GetZoomPitchOffset(CurViewDist), Rotation.Yaw, Rotation.Roll, true, ZoomInterpVelocity)
                -- 缩放时设置FOV
                self:SetFOVY(self:GetZoomFOV(CurViewDist), true, ZoomInterpVelocity)
                self:SetCanZoom(false)
                if self.CallBackZoom then
                    self.CallBackZoom(self:GetSpringArmDistance())
                end
            end
            if CurViewDist < 320 then
                local ViewPortSizeY = UIUtil.GetViewportSize().Y
                --缩放规则需要两只手指的触摸开始坐标在屏幕上方
                if self.Touch1CurY < ViewPortSizeY / 2 and self.Touch2CurY < ViewPortSizeY / 2 then
                    --特写镜头1
                    if self.NeedSetCamera then
                        local Location = _G.UE.FVector(self.SpecialCameraLocation[1].X,self.SpecialCameraLocation[1].Y, 
                        self.SpecialCameraLocation[1].Z)
                        self:SetSpringArmLocation(Location.x, Location.y, Location.z, true, ZoomInterpVelocity) 
                        self:SetSpringArmRotation(self.SpecialCameraRotation[1].X, self.SpecialCameraRotation[1].Y, 
                        self.SpecialCameraRotation[1].Z, true, ZoomInterpVelocity)
                        self.isSpecialCamera = true
                    else
                        CallBack()
                    end
                else
                    --特写镜头2
                    if self.NeedSetCamera then
                        local Location = _G.UE.FVector(self.SpecialCameraLocation[2].X,self.SpecialCameraLocation[2].Y, 
                        self.SpecialCameraLocation[2].Z)
                        self:SetSpringArmLocation(Location.x, Location.y, Location.z, true, ZoomInterpVelocity) 
                        self:SetSpringArmRotation(self.SpecialCameraRotation[1].X, self.SpecialCameraRotation[2].Y, 
                        self.SpecialCameraRotation[2].Z, true, ZoomInterpVelocity)
                        self.isSpecialCamera = true
                    else
                        CallBack()
                    end
                end
            else
                CallBack()
            end
        end
    else
        self:SetCanZoom(false)
    end
end

function AdventureRender2dView:SetSpecialCameraPoint(NeedSetCamera, Location, Rotation, CenterPoint)
    self.NeedSetCamera = NeedSetCamera
    self.SpecialCameraLocation = Location
    self.SpecialCameraRotation = Rotation
    self.CenterPoint = CenterPoint
end

---SetUICharacterByEntityIDS
---设置Character同步哪个EntityID
---@param EntityID EntityID
function AdventureRender2dView:SetUICharacterByEntityID(EntityID)
    if (self.ChildActor == nil) then
        return
    end

    local CopyFromActor = ActorUtil.GetActorByEntityID(EntityID)
    if (CopyFromActor == nil) then
        return
    end

    self.UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    if (self.UIComplexCharacter == nil) then
        return
    end

    self.UIComplexCharacter:CopySkeletalMesh(CopyFromActor, self.DirectionalLightComponent)
    self.UIComplexCharacter:HideHead(not self.bIsShowHead, true)
    self.ShowEntityID = EntityID
    self.ChildActorLocation = self.ChildActor:FGetActorLocation()
    self.DefaultFocusLoc = nil;
end

function AdventureRender2dView:SetShowHead(bShow)
    self.bIsShowHead = bShow
    if self.UIComplexCharacter then
        self.UIComplexCharacter:HideHead(not self.bIsShowHead, true)
    end
end

function AdventureRender2dView:SetUIRideCharacter(MountID)
    if self.UIComplexCharacter == nil then return end
    self.UIComplexCharacter:SetUIMeshLoaded(true)
    self.UIComplexCharacter:AddRideAvatar(MountID)
    self.RideMeshComponent = self.UIComplexCharacter:GetRideMeshComponent()
    self.bOnUIRide = self.UIComplexCharacter:IsOnRide()

	_G.UIViewMgr:OnCommonModelShow()
end

function AdventureRender2dView:ChangeMountPart(EquipID, ImechanID, StainID, AvatarPartType)
    if self.UIComplexCharacter == nil then return end
    if self.bOnUIRide == false then return end
    local RideComponent = self.UIComplexCharacter:GetRideComponent()
    if RideComponent then
        RideComponent:ChangeMountPart(EquipID, ImechanID, StainID, AvatarPartType)
    end
end

function AdventureRender2dView:TakeOffMountPart(AvatarPartType)
    if self.UIComplexCharacter == nil then return end
    if self.bOnUIRide == false then return end
    local RideComponent = self.UIComplexCharacter:GetRideComponent()
    if RideComponent then
        RideComponent:TakeOffMountPart(AvatarPartType)
    end
end

function AdventureRender2dView:TakeOffRideAvatar()
    if not self.UIComplexCharacter then
        return
    end
    local RideComponent = self.UIComplexCharacter:GetRideComponent()
    if RideComponent then
        RideComponent:UnUseRide(false)
    end
end

function AdventureRender2dView:HidePlayer(bHidePlayer)
    if self.UIComplexCharacter then
        self.UIComplexCharacter:HidePlayerPart(bHidePlayer)
    end
end

function AdventureRender2dView:SetSpringArmCenterOffsetY(OffsetY, TargetArmLength)
    self.CenterOffsetY = OffsetY
    --[sammrli] 计算偏移后相机和目标点的角度，角度*领边(springDistance)可以求出对边offsetY缩放后的值
	local ArmLength = nil ~= TargetArmLength and TargetArmLength or self:GetSpringArmDistance()
    self.CamToTargetRadians = math.atan(OffsetY, ArmLength)
end
-- --创建角色用到
-- function AdventureRender2dView:ReCreateCharacter(RaceCfg)
--     -- local UserData = self:GetEquipmentConfigAssetUserData()
--     self:CreateActor()
--     self:SetUICharacterByRaceCfg(RaceCfg)
--     -- self.ChildActorComponent:SetEquipmentConfigAssetUserData(UserData)
--     if self.ReCreateCallBack then
--         self.ReCreateCallBack()
--     end
-- end

--不走复制主角的方式，自定义的形式（先更新完属性组件，然后调用过来）
--外部已经提前给UIComplexCharacter赋值了
function AdventureRender2dView:SetUICharacterAfterAttrSet()
    self.UIComplexCharacter:OnActorAttrSetComplete(self.DirectionalLightComponent)
    -- self.UIComplexCharacter:SetAnimClass(LoginConfig.CharacterAnimClass)
    self.ShowEntityID = 0
    self.ChildActorLocation = self.ChildActor:FGetActorLocation()
    self.DefaultFocusLoc = nil;
end

--获取ui模型的Mesh
function AdventureRender2dView:GetUIMeshComponent()
    if (self.UIComplexCharacter) then
        return self.UIComplexCharacter:GetMeshComponent()
    end

    return nil
end

---SetModelLocation
---设置Character坐标
function AdventureRender2dView:SetModelLocation(InX, InY, InZ, bInterp)
    if (self.ChildActor == nil) then
        return
    end
    if bInterp == true then
        self.ModelLocationTarget = _G.UE.FVector(InX, InY, InZ);
    else
        self.ChildActor:K2_SetActorLocation(_G.UE.FVector(InX + self.ChildActorLocation.x, InY + self.ChildActorLocation.y, InZ + self.ChildActorLocation.z), false, nil, false)
    end
end

---GetModelLocation
---获取Character旋转
function AdventureRender2dView:GetModelLocation()
	if nil == self.ChildActor then
		return
	end
	return self.ChildActor:K2_GetActorLocation() - self.ChildActorLocation
end

---SetModelRotation
---设置Character旋转
function AdventureRender2dView:SetModelRotation(InPitch, InYaw, InRoll, bInterp)
    if (self.SkeletalMeshComponent == nil) then
        return
    end
    if bInterp == true then
        self.ModelRotationTarget = _G.UE.FRotator(InPitch, InYaw, InRoll)
    else
        if self.bOnUIRide == true and self.RideMeshComponent ~= nil then
            --坐骑专用旋转
            self.RideMeshComponent:K2_SetRelativeRotation(_G.UE.FRotator(InPitch, InYaw, InRoll), false, nil, false)
            self.SkeletalMeshComponent:K2_SetRelativeRotation(_G.UE.FRotator(0, 0, 0), false, nil, false)
        else
            self.SkeletalMeshComponent:K2_SetRelativeRotation(_G.UE.FRotator(InPitch, InYaw, InRoll), false, nil, false)
        end
    end
end

---GetModelRotation
---获取Character旋转
function AdventureRender2dView:GetModelRotation()
	if nil == self.SkeletalMeshComponent then
		return
	end
	return self.SkeletalMeshComponent:GetRelativeRotation()
end

---SetModelScale
---设置Character缩放
function AdventureRender2dView:SetModelScale(InScale, bInterp)
    if (self.ChildActor == nil) then
        return
    end
    if bInterp == true then
        self.ModelScaleTarget = InScale
    else
        self.ChildActor:SetModelScale(InScale)
    end
end

---GetModelScale
---获取Character缩放
function AdventureRender2dView:GetModelScale()
	if nil == self.ChildActor then
		return
	end
	return self.ChildActor:GetActorScale3D().X
end

---HoldOnWeapon
---设置Character武器激活状态
function AdventureRender2dView:HoldOnWeapon(bHoldOn)
    if (self.ChildActor == nil) then
        return
    end

    local UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    if (UIComplexCharacter == nil) then
        return
    end
    UIComplexCharacter:HoldWeapon(bHoldOn)
end

---HideWeapon
---设置Character武器显示状态
function AdventureRender2dView:HideWeapon(bHide)
    if (self.ChildActor == nil) then
        return
    end

    local UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    if (UIComplexCharacter == nil) then
        return
    end
    UIComplexCharacter:HideWeapon(bHide)
end

---HideMasterHand
---设置Character主手武器显示状态
function AdventureRender2dView:HideMasterHand(bHide)
    local UIComplexCharacter = self:GetUIComplexCharacter()
    if nil == UIComplexCharacter then
        return
    end
    UIComplexCharacter:HideMasterHand(bHide)
end

---HideSlaveHand
---设置Character副手武器显示状态
function AdventureRender2dView:HideSlaveHand(bHide)
	local UIComplexCharacter = self:GetUIComplexCharacter()
    if nil == UIComplexCharacter then
        return
    end
    UIComplexCharacter:HideSlaveHand(bHide)
end

---HideAttachMasterHand
---设置Character主手武器挂件显示状态
function AdventureRender2dView:HideAttachMasterHand(bHide)
	local UIComplexCharacter = self:GetUIComplexCharacter()
    if nil == UIComplexCharacter then
        return
    end
    UIComplexCharacter:HideAttachMasterHand(bHide)
end

---HideAttachSlaveHand
---设置Character副手武器挂件显示状态
function AdventureRender2dView:HideAttachSlaveHand(bHide)
    local UIComplexCharacter = self:GetUIComplexCharacter()
    if nil == UIComplexCharacter then
        return
    end
    UIComplexCharacter:HideAttachSlaveHand(bHide)
end

---HideHead
---设置Character头部防具显示状态
function AdventureRender2dView:HideHead(bHide)
    if (self.ChildActor == nil) then
        return
    end

    local UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    if (UIComplexCharacter == nil) then
        return
    end
    UIComplexCharacter:HideHead(bHide, true)
end

---SwitchHelmet
---设置Character头部防具开关状态
function AdventureRender2dView:SwitchHelmet(bOn)
    if nil == self.ChildActor then
        return
    end

    local UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    if nil == UIComplexCharacter then
        return
    end
    UIComplexCharacter:SwitchHelmet(bOn)
end

-- 相机
function AdventureRender2dView:GetMinViewDistance()
    local Params = self.CamControlParams
	return Params and Params.MinViewDistParams and Params.MinViewDistParams.ViewDistance or SpringTargetArmLengthMin
end

function AdventureRender2dView:GetMaxViewDistance()
    local Params = self.CamControlParams
	return Params and Params.MaxViewDistParams and Params.MaxViewDistParams.ViewDistance or SpringTargetArmLengthMax
end

function AdventureRender2dView:GetZoomRatio(CurViewDist)
	local MinViewDist = self:GetMinViewDistance()
	local MaxViewDist = self:GetMaxViewDistance()
	return (CurViewDist - MinViewDist) / (MaxViewDist - MinViewDist)
end

function AdventureRender2dView:GetZoomZOffset(CurViewDist)
	local Ratio = self:GetZoomRatio(CurViewDist)
	local ZOffsetMinViewDist = 0
	local ZOffsetMaxViewDist = SpringTargetDefaultZ
	if nil ~= self.DefaultFocusLoc then
		ZOffsetMaxViewDist = ZOffsetMaxViewDist - self.DefaultFocusLoc.z
	end
	if nil ~= self.CamControlParams then
		ZOffsetMinViewDist = self.CamControlParams.MinViewDistParams.ZOffset
		ZOffsetMaxViewDist = self.CamControlParams.MaxViewDistParams.ZOffset
	end
	return Ratio * (ZOffsetMaxViewDist - ZOffsetMinViewDist) + ZOffsetMinViewDist
end

function AdventureRender2dView:GetZoomFOV(CurViewDist)
	local Ratio = self:GetZoomRatio(CurViewDist)
	local FOVMinViewDist = 0
	local FOVMaxViewDist = 0
	if nil ~= self.CamControlParams then
		FOVMinViewDist = self.CamControlParams.MinViewDistParams.FOV
		FOVMaxViewDist = self.CamControlParams.MaxViewDistParams.FOV
	end
	return Ratio * (FOVMaxViewDist - FOVMinViewDist) + FOVMinViewDist
end

function AdventureRender2dView:GetZoomPitchOffset(CurViewDist)
	local Ratio = self:GetZoomRatio(CurViewDist)
	local PitchMinViewDist = 0
	local PitchMaxViewDist = 0
	if nil ~= self.CamControlParams then
		PitchMinViewDist = self.CamControlParams.MinViewDistParams.PitchOffset
		PitchMaxViewDist = self.CamControlParams.MaxViewDistParams.PitchOffset
	end
	return Ratio * (PitchMaxViewDist - PitchMinViewDist) + PitchMinViewDist
end

function AdventureRender2dView:NormalizeTargetArmLength(InDistance)
    return math.clamp(InDistance, self:GetMinViewDistance(), self:GetMaxViewDistance())
end

---SetSpringArmDistance
---设置Character相机弹簧臂距离，外部调用请将bInterp设为false，以终止当前插值
function AdventureRender2dView:SetSpringArmDistance(InDistance, bInterp)
    if nil == self.RenderActor or nil == self.SpringArmComponent then
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
		if nil ~= self.RenderActor and nil ~= self.RenderActor.ShadowDistanceCurve then
            local ArmDistance = self:GetSpringArmDistance()
			local ShadowDistance = self.RenderActor.ShadowDistanceCurve:GetFloatValue(ArmDistance)
            self:SetShadowQuality(ShadowDistance)

            -- FLOG_INFO("Login Camera Distance:%f, ArmDistance:%f", ShadowDistance, ArmDistance)
			-- if nil ~= self.DirectionalLightComponent then
			-- 	self.DirectionalLightComponent:SetDynamicShadowDistanceMovableLight(ShadowDistance)
			-- end
		end
    end
end

---设置相机Roll
function AdventureRender2dView:SetCameraRoll(Val)
    if self.RenderActor then
        local CameraComp = self.RenderActor:GetComponentByClass(_G.UE.UCameraComponent)
        if CameraComp then
            self.CameraRollAngle = Val
            CameraComp:K2_SetRelativeRotation(_G.UE.FRotator(0, 0, Val), false, nil, false)
        end
    end
end

function AdventureRender2dView:SetShadowQuality(ShadowDistance)
    --local TodMainActor = nil
    --if not self.DirectionalLightComponent then
     --   TodMainActor = _G.UE.UEnvMgr:Get():GetTodSystem()
   -- end
    -- FLOG_INFO("Login Camera Distance:%f", ShadowDistance)

    --if self.bLogin then
    --    _G.UE.UCommonUtil.SetShadowQualityFromCurveCharctorCreation(ShadowDistance, self.DirectionalLightComponent, TodMainActor)
    --else
    --    _G.UE.UCommonUtil.SetShadowQualityFromEquipment(ShadowDistance, self.DirectionalLightComponent, TodMainActor)
   -- end
    
end

---GetSpringArmDistance
---获取Character相机弹簧臂距离
function AdventureRender2dView:GetSpringArmDistance()
    if self.SpringArmComponent ~= nil and _G.UE.UCommonUtil.IsObjectValid(self.SpringArmComponent) then
        return self.SpringArmComponent.TargetArmLength
    end
    return 0
end

function AdventureRender2dView:SetSpringArmCompArmLength(ArmLength)
    ArmLength = ArmLength or 600
    if self.SpringArmComponent then
        self.SpringArmComponent.TargetArmLength = ArmLength
    end
end

-- 设置相机控制参数
function AdventureRender2dView:SetCameraControlParams(CamControlParams)
	self.CamControlParams = CamControlParams
end

function AdventureRender2dView:GetCameraControlParams()
    return self.CamControlParams
end

---设置移动限制参数
---@param MinH number@水平最小值
---@param MaxH number@水平最大值
---@param MinV number@垂直最小值
---@param MaxV number@垂直最大值
function AdventureRender2dView:SetMoveLimiParams(MinH, MaxH, MinV, MaxV)
    ---@class MoveLimiParams
    self.MoveLimiParams = {}
    self.MoveLimiParams.MinHorizontal = MinH
    self.MoveLimiParams.MaxHorizontal = MaxH
    self.MoveLimiParams.MinVertical = MinV
    self.MoveLimiParams.MaxVertical = MaxV
end

---设置旋转限制参数
---@param MinYaw number@最小角度
---@param MaxYaw number@最大角度
function AdventureRender2dView:SetRotateLimiParams(MinYaw, MaxYaw)
    ---@class RotateLimiParams
    self.RotateLimiParams = {}
    self.RotateLimiParams.MinYaw = MinYaw
    self.RotateLimiParams.MaxYaw = MaxYaw
end

-- 恢复相机视距到默认视距
function AdventureRender2dView:ResetViewDistance(bInterp)
	if nil == self.SpringArmComponent then
		return
	end
	if nil == bInterp then
		bInterp = true
	end
	if nil == self.CamControlParams or nil == self.DefaultFocusLoc then
		return
	end

    if _G.WorldMsgMgr.IsShowLoadingView then
        bInterp = false
    end

	local TargetViewDist = self.CamControlParams.DefaultViewDistance
	self:ResetViewDistanceInternal(TargetViewDist, bInterp)
end

function AdventureRender2dView:ResetViewDistanceInternal(TargetViewDist, bInterp)
    self:SetSpringArmDistance(TargetViewDist, bInterp)
	-- 位置偏移，默认为0
	local Location = _G.UE.FVector(0, self.CamToTargetRadians * TargetViewDist, self.DefaultFocusLoc.z +
	self:GetZoomZOffset(TargetViewDist))
    local sss = self:GetZoomZOffset(TargetViewDist)
     FLOG_WARNING("======LoginDistance Location:(%f, %f, %f)", Location.x, Location.y, self.DefaultFocusLoc.z)
     FLOG_WARNING("=============================="..tostring(sss))
    self:SetSpringArmLocation(Location.x, Location.y, Location.z, bInterp, ZoomInterpVelocity)

    -- 俯仰角偏移，默认为0
    local Rotation = self:GetSpringArmRotation()
    self:SetSpringArmRotation(self:GetZoomPitchOffset(TargetViewDist), Rotation.Yaw, Rotation.Roll, bInterp, ZoomInterpVelocity)

    -- FOV
	self:SetFOVY(self:GetZoomFOV(TargetViewDist), bInterp, ZoomInterpVelocity)
end

---SetSpringArmRotation
---设置Character相机弹簧臂旋转
function AdventureRender2dView:SetSpringArmRotation(InPitch, InYaw, InRoll, bInterp, InterpVelocity)
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

---GetSpringArmRotation
---获取Character相机弹簧臂旋转
function AdventureRender2dView:GetSpringArmRotation()
    if self.SpringArmComponent ~= nil then
        return self.SpringArmComponent:GetRelativeRotation() 
    end 
    return _G.UE.FRotator(0, 0, 0);
end

---SetSpringArmLocation
---设置Character相机弹簧臂坐标
function AdventureRender2dView:SetSpringArmLocation(InX, InY, InZ, bInterp, InterpVelocity)
    if self.SpringArmComponent == nil or not _G.UE.UCommonUtil.IsObjectValid(self.SpringArmComponent) then
        return
    end
    -- FLOG_INFO("Login Distance Location (%f, %f, %f) bInterp:%s", InX, InY, InZ, tostring(bInterp))
    if bInterp == true then
        self.SpringArmLocationTarget = _G.UE.FVector(InX, InY, InZ);
		self.CamLocInterpVelocity = InterpVelocity
    else
		if bInterp == false then
			self.SpringArmLocationTarget = nil
			self.CamLocInterpVelocity = nil
		end
        
        local Location = _G.UE.FVector(InX, InY, InZ)
        self.LastLoginRoleArmLoc = Location
        self.SpringArmComponent:K2_SetRelativeLocation(Location, false, nil, false);
    end

    if self.CallBackMove then
        self.CallBackMove(InX, InY, InZ)
    end
end

function AdventureRender2dView:GetFOVY()
	local FOVX = self:GetFOV()
	if nil == FOVX then
		return nil
	end
	local AspectRatio = _G.UE.UCameraMgr.Get():GetAspectRatio()
	local TanHalfFOVY = (1 / AspectRatio) * math.tan(math.rad(FOVX) * 0.5)
	local FOVY = math.deg(2 * math.atan(TanHalfFOVY))

	return FOVY
end

function AdventureRender2dView:GetFOV()
    local CameraMgr = _G.UE.UCameraMgr.Get()
	if CameraMgr ~= nil then
        return CameraMgr:GetCurrentPlayerManagerLockedFOV()
    end

	return nil
end

-- 设置竖直方向上的FOV（UE的FOV默认为水平方向）
function AdventureRender2dView:SetFOVY(InFOVY, bInterp, InterpVelocity)
	if nil == InFOVY or nil == self.RenderActor then
		return
	end

    local AspectRatio = _G.UE.UCameraMgr.Get():GetAspectRatio()
	local TanHalfFOVX = AspectRatio * math.tan(math.rad(InFOVY) * 0.5)
	local FOVX = math.deg(2 * math.atan(TanHalfFOVX))
	self:SetCameraFOV(FOVX, bInterp, InterpVelocity)
end

function AdventureRender2dView:SetCameraFOV(InFOV, bInterp, InterpVelocity)
    if InFOV == nil or InFOV == 0 or self.RenderActor == nil then
        return
    end
    local CameraMgr = _G.UE.UCameraMgr.Get()
	if bInterp == true then
		self.FOVTarget = InFOV
		self.FOVInterpVelocity = InterpVelocity

        self.LastFOV = InFOV
		return
	end
	if bInterp == false then
		self.FOVTarget = nil
		self.FOVInterpVelocity = nil
	end
    if CameraMgr ~= nil then
        -- FLOG_ERROR("LoginDistance Set Fov %f", InFOV)
        CameraMgr:SetCurrentPlayerManagerLockedFOV(InFOV)
		self.CachedFOV = InFOV
    end
end

---GetSpringArmLocation
---获取Character相机弹簧臂坐标
function AdventureRender2dView:GetSpringArmLocation()
    if self.SpringArmComponent ~= nil then
        return self.SpringArmComponent:GetRelativeLocation()
    end
    return _G.UE.FVector(0, 0, 0);
end

---EnableZoom
---设置是否允许缩放
function AdventureRender2dView:EnableZoom(bEnable)
    self.bEnableZoom = bEnable
end

---EnableRotator
---设置是否允许旋转
function AdventureRender2dView:EnableRotator(bEnable)
    self.bEnableRotator = bEnable
end

---EnableMove
---设置是否允许移动
function AdventureRender2dView:EnableMove(bEnable)
    self.bEnableMove = bEnable
end

---EnableMoveImmediately
---设置是否允许立即移动（开启后旋转会失效）
function AdventureRender2dView:EnableMoveImmediately(bEnable)
    self.bEnableMoveImmediately = bEnable
end

---SetCameraFocusScreenLocation
---设置相机聚焦
function AdventureRender2dView:SetCameraFocusScreenLocation(UIX, UIY, SocketName, CameraDistance)
    self.FocusUIX = UIX
    self.FocusUIY = UIY
    self.FocusSocketName = SocketName
    self.FocusDistance = CameraDistance
end

function AdventureRender2dView:DoCameraFocusScreenLocation(bInterp)
	if nil == self.ChildActor then
		return
	end
	
    local WorldPosition = _G.UE.FVector()
	local WorldDirection = _G.UE.FVector()

    local ScreenLocation = _G.UE.FVector2D(self.FocusUIX, self.FocusUIY)
    
	local PlayerIndex = 1
    if CommonDefine.NoCreateController == true then
        PlayerIndex = 0
    end
	UIUtil.DeprojectScreenToWorld(ScreenLocation, WorldPosition, WorldDirection, PlayerIndex)

	local TargetPosition = WorldPosition + WorldDirection * self.FocusDistance
	local SocketWorldPosition = self.ChildActor:GetSocketLocationByName(self.FocusSocketName)
	local NeedMoveVector = TargetPosition - SocketWorldPosition

	local function EndFocus()
		--Focus动画结束
        self.FocusSocketName = nil
        self.SpringArmLocationTarget = nil
	end
    if NeedMoveVector:SizeSquared() < 0.1 and self.SpringArmRotationTarget == nil then
        EndFocus()
    else
		local TargetLocation = self:GetSpringArmLocation() - NeedMoveVector
		bInterp = nil == bInterp or bInterp == true
        self:SetSpringArmLocation(TargetLocation.x, TargetLocation.y, TargetLocation.z, bInterp)
		if bInterp == false then
			EndFocus()
		end
    end
end

---PreViewEquipment
---装备预览
function AdventureRender2dView:PreViewEquipment(EquipID, Part, ColorID)
    if (self.ChildActor == nil) then
        return
    end

    local UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    if (UIComplexCharacter == nil) then
        return
    end

    UIComplexCharacter:PreViewEquipment(EquipID, Part, ColorID)
end

---ResumeAvatar
---恢复到创建时的外观
function AdventureRender2dView:ResumeAvatar()
    if (self.ChildActor == nil) then
        return
    end

    local UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    if (UIComplexCharacter == nil) then
        return
    end

    UIComplexCharacter:ResumeAvatar()
end

function AdventureRender2dView:SwitchOtherLights(bOpen)
    self:SwitchLights(bOpen)
end

function AdventureRender2dView:SwitchRenderLights(bOpen)
    if self.DirectionalLightComponent then
        self.DirectionalLightComponent:SetVisibility(bOpen)
    end
end

function AdventureRender2dView:SetClick(UIView, InSingleClick, InDoubleClick)
    self.ClickView = UIView
    self.SingleClick = InSingleClick
    self.DoubleClick = InDoubleClick
end

function AdventureRender2dView:SwitchActorAutoRotator(bOpen)
    if bOpen ~= nil then
        self.AutoRotator = bOpen
    else
        self.AutoRotator = not self.AutoRotator 
    end

    --关闭所有插值动画
    if self.AutoRotator == true then
        self.SpringArmDistanceTarget = nil
        --SpringRotation插值
        self.SpringArmRotationTarget = nil
        --SpringLocation插值
        self.SpringArmLocationTarget = nil
        --Scale插值
        self.ModelScaleTarget = nil
        --Rotator插值
        self.ModelRotationTarget = nil
        --Location插值
        self.ModelLocationTarget = nil
        ---CameraFocus插值
        self.FocusSocketName = nil
    end
end

function AdventureRender2dView:UpdateAllLights()
    if (self.RenderActor == nil or self.LightPreset == nil) then
        return
    end
    self.RenderActor:UpdateLights(self.ChildActor, self.LightPreset)
    LightMgr:RecordLightPreset(self.RenderActor, self.LightPreset)

    if _G.LoginMapMgr:IsInRoomMap() then
        self:SetLightLookatHead(4)
        -- self:OpenExtraRoomLight()
    end
end

--接口用不着了
-- function AdventureRender2dView:UpdateSpecularScale(LightName, Scale)
--     if self.RenderActor then
--         self.RenderActor:UpdateSpecularScale(LightName, Scale)
--     end
-- end

function AdventureRender2dView:SetPostProcessVignetteIntensity(InValue)
    if(self.PostProcessComp == nil) then
        return
    end
    self.PostProcess_VignetteIntensity = tonumber(InValue)
    --FLOG_ERROR("self.PostProcess_VignetteIntensity = %f", self.PostProcess_VignetteIntensity)
end

function AdventureRender2dView:GetPostProcessVignetteIntensity()
    if(self.PostProcessComp == nil) then
        return
    end
    return self.PostProcessComp.Settings.VignetteIntensity
end

function AdventureRender2dView:GetCharacter()
    if CommonUtil.IsObjectValid(self.ChildActor) then
        return self.ChildActor
    end

    return nil
end

function AdventureRender2dView:PlayAnyAsMontage(AnimPath, Slot, Callback, AnimInst, Section, PlayRate, bStopAllMontages)
    PlayRate = PlayRate or 1.0
    bStopAllMontages = bStopAllMontages or true

    if (self.UIComplexCharacter == nil) then
        FLOG_ERROR("Login PlayAnyAsMontage UIComplexCharacter is nil")
        return
    end

    local AnimComp = self.UIComplexCharacter:GetAnimationComponent()
    if not AnimComp then
        FLOG_ERROR("Login PlayAnyAsMontage AnimComp is nil")
        return
    end

	local AnimRes = _G.ObjectMgr:LoadObjectSync(AnimPath, ObjectGCType.LRU)
    if not AnimRes then
        FLOG_ERROR("Login PlayAnyAsMontage AnimRes is nil")
        return
    end

    local Montage = AnimRes:Cast(_G.UE.UAnimMontage)
    local AnimSeq = AnimRes:Cast(_G.UE.UAnimSequence)
    Callback = CommonUtil.GetDelegatePair(Callback, true)
    if Montage then
        AnimComp:PlayMontage(Montage, Callback, Section, PlayRate, 0.25, 0.25, AnimInst, bStopAllMontages)
        return Montage
    elseif AnimSeq then
        return AnimComp:PlaySequenceToMontage(AnimSeq, Slot, Callback, Section, PlayRate, 0.25, 0.25, AnimInst, 1, bStopAllMontages)
    end
end

function AdventureRender2dView:IsShowingCharacter( EntityID )
    if nil == self.ShowEntityID or 0 == self.ShowEntityID then
        return false
    end

    return EntityID == self.ShowEntityID
end

function AdventureRender2dView:DestroyActorSequence()
    if self.ActorSeqPlayer ~= nil then
        self.ActorSeqPlayer.OnFinished:Clear()
        self.ActorSeqPlayer = nil
    end
end

-- 生成蓝图actor，无需uicharacter
function AdventureRender2dView:CreateSimpleRenderActor(RenderActorPath, bSample, CallBack)
    if self.RenderActor ~= nil then
        return
    end
    local function CallBack1()
        if (self.bReleaseActor == true) then
            CallBack(false)
            return
        end

        local Class1 = ObjectMgr:GetClass(RenderActorPath)
        if Class1 == nil then
            return
        end

        self.RenderActor = CommonUtil.SpawnActor(Class1, _G.UE.FVector(0, 0, RootLocationZ))
        if self.RenderActor == nil then
            return
        end
		self.RenderActor.OnEndPlay:Add(self, self.OnRenderActorEndPlay)

        self.PostProcessComp = self.RenderActor:GetComponentByClass(_G.UE.UPostProcessComponent)
        --self.LightPreset = ObjectMgr:LoadObjectSync(LightPresetPath)

        --self:CreateActor(bSample)
        --self.ChildActorComponent.ChildActorReCreateDelegate = { self.RenderActor, function ()
            --self:ReCreateActorWhenDestroy()
        --end }
        local ActorComponent = self.RenderActor:GetComponentByClass(_G.UE.USpringArmComponent)
        if ActorComponent ~= nil then
            self.SpringArmComponent = ActorComponent:Cast(_G.UE.USpringArmComponent)
        end

        if (CallBack) then
            CallBack(true)
        end
    end

    --异步写法
    self.bReleaseActor = false
    ObjectMgr:LoadClassAsync(RenderActorPath, CallBack1, ObjectGCType.LRU)
end

function AdventureRender2dView:OnUpdateMaster(Params)
	if Params.IntParam1 == _G.UE.EActorType.UIActor then
		if nil ~= self.UIComplexCharacter then
			self:SetCombatRestEnabled(self.UIComplexCharacter, self.bCombatRestEnabled)
		end
	end
end

-- 更新动画资产
function AdventureRender2dView:OnProfSwitch(Params)
	if nil == self.UIComplexCharacter then
		return
	end
	local AttrComp = self.UIComplexCharacter:GetAttributeComponent()
	if nil == AttrComp then
		return
	end
	AttrComp.ProfID = Params.ProfID
	local AnimComp = self.UIComplexCharacter:GetAnimationComponent()
	if nil == AnimComp then
		return
	end
	local AnimInst = AnimComp:GetPlayerAnimInstance()
	if nil == AnimInst then
		return
	end
	AnimInst:OnCharacterProfChanged()
end

function AdventureRender2dView:GetUIComplexCharacter()
	if self.ChildActor == nil then
        return nil
    end

    local UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    return UIComplexCharacter
end

function AdventureRender2dView:DisableEnvironmentLights()
	if nil == self.RenderActor then
		return
	end

	local CompsToDisable = {}
	table.insert(CompsToDisable, self.RenderActor:GetComponentByClass(_G.UE.USkyLightComponent))
	table.insert(CompsToDisable, self.RenderActor:GetComponentByClass(_G.UE.UDirectionalLightComponent))
	table.insert(CompsToDisable, self.RenderActor:GetComponentByClass(_G.UE.UPlanarReflectionComponent))
	table.insert(CompsToDisable, self.RenderActor:GetComponentByClass(_G.UE.UChildActorComponent))
	table.insert(CompsToDisable, self.RenderActor:GetComponentByClass(_G.UE.UPostProcessComponent))
	for _, Comp in ipairs(CompsToDisable) do
		Comp:SetVisibility(false)
		if nil ~= Comp.bEnabled then
			Comp.bEnabled = false
		end
	end

end

function AdventureRender2dView:SwitchCharacterIK(bOn)
	if nil == self.ChildActor then
		return
	end
	self.ChildActor:SetIKState(bOn)
end

function AdventureRender2dView:SetCombatRestEnabled(Character, bEnabled)
	self.bCombatRestEnabled = bEnabled
	AnimMgr:UpdatePlayerAnimParam(Character, "bCanRest", bEnabled)
	if bEnabled then
		AnimMgr:UpdatePlayerAnimParam(Character, "IdleToRestTime", 0.5)
	end
end

function AdventureRender2dView:ReSetFovTarget()
	self.FOVTarget = nil
end

return AdventureRender2dView
