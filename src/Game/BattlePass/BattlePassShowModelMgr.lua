
local MgrBase = require("Common/MgrBase")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
---主角模型控制
local ModelMajorController = require("Game/Model/Actor/ModelMajorController")
---宠物模型控制
local ModelCompanionController = require("Game/Model/Actor/ModelCompanionController")
---相机模型控制
local ModelCameraController = require("Game/Model/Camera/ModelCameraController")
local StageUniverseController = require("Game/Model/Stage/StageUniverseController")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local BattlePassDefine = require("Game/BattlePass/BattlePassDefine")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")

local FMath = _G.UE.UKismetMathLibrary

---@class BattlePassShowModelMgr : MgrBase
local BattlePassShowModelMgr = LuaClass(MgrBase)

function BattlePassShowModelMgr:Ctor()
    self.CurUIType = 1
    self.CommGesture = nil
    self.OnCreateSuccessCallBack = nil
    self.DoActive = true
    self.LoadingCount = -1
    self.IsCreate = false
    self.bEnableZoom = false
    self.bEnableRotator = false
    self.SingleClick = nil
    self.bCanRotate = true
    self.AutoRotator = false
    self.AutoRotateVel = 0.5
    self.IsInit = false
    self.LastDragX = 0
    self.DurationTimerID = 0
    self.DurationDeltaTime = 0
    self.IsRotateAroundPoint = true

end

function BattlePassShowModelMgr:OnInit()
    self.PlayerPos = ModelDefine.DefaultLocation
    self.CompanionPos = ModelDefine.DefaultLocation
end

function BattlePassShowModelMgr:OnBegin()
end

function BattlePassShowModelMgr:OnEnd()
    self:OnHide()
end

function BattlePassShowModelMgr:OnShutdown()
end

function BattlePassShowModelMgr:OnRegisterGameEvent()
end

function BattlePassShowModelMgr:OnHide()

    self.CurUIType = 1
    self.CommGesture = nil
    self.OnCreateSuccessCallBack = nil
    self.DoActive = true
    self.LoadingCount = -1
    self.IsCreate = false
    self.bEnableZoom = false
    self.bEnableRotator = false
    self.SingleClick = nil
    self.AutoRotator = false
    self.AutoRotateVel = 0.5
    self.LastDragX = 0
    self.bCanRotate = true
    self.PlayerPos = ModelDefine.DefaultLocation
    self.CompanionPos = ModelDefine.DefaultLocation
    self.IsInit = false
    self.DurationDeltaTime = 0.1
    self.IsRotateAroundPoint = true

    if self.ModelMajorController then
        self.ModelMajorController:Release()
        self.ModelMajorController = nil
    end

    if self.ModelCompanionController then
        self.ModelCompanionController:Release()
    end

    if self.StageUniverseController then
        self.StageUniverseController:Release()
        self.StageUniverseController = nil
    end

    if self.ModelCameraController then
        _G.LightMgr:SwitchSceneLights(true)
        self.ModelCameraController:Switch(false)
        self.ModelCameraController = nil
    end

    if self.DurationTimerID ~= 0 then
        _G.TimerMgr:CancelTimer(self.DurationTimerID)
        self.DurationTimerID = 0
    end

    self:UnRegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
end

function BattlePassShowModelMgr:OnActive()
    if self:IsCreateFinish() and not self:GetActiveFlag() then
        self:SetActiveFlag(true)
        self:ShowRenderActor(true)
    end
end

function BattlePassShowModelMgr:OnInactive()
    if self:IsCreateFinish() and self:GetActiveFlag() then
        self:SetActiveFlag(false)
        self:ShowRenderActor(false)
    end
end

function BattlePassShowModelMgr:CreateModel(OnCreateSuccessCallBack)
    if self.IsInit and self:IsCreateFinish() == false then
        self.OnCreateSuccessCallBack = OnCreateSuccessCallBack
        return
    end

    self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)

    self.ModelCameraController = ModelCameraController.New()
    self.ModelMajorController = ModelMajorController.New()
    self.ModelCompanionController = ModelCompanionController.New()
    self.StageUniverseController = StageUniverseController.New()
    self.StageUniverseController:SetCreateFinish(self, self.OnCreateStageFinish)

    self.LoadingCount = 2
    self.IsCreate = false
    self.IsInit = true
    self.OnCreateSuccessCallBack = OnCreateSuccessCallBack

    self.PlayerPos = ModelDefine.DefaultLocation
    self.CompanionPos = ModelDefine.DefaultLocation
    local PlayerDir = 0
    local CompanionDir = 0

    local Offset = _G.UE.FVector(0, 0, 0)
    local Length = 400
    local FOV = 0

    self.ModelMajorController:Create(_G.UE.FVector(self.PlayerPos.X, self.PlayerPos.Y, ModelDefine.DefaultLocation.Z - 50), _G.UE.FRotator(0, PlayerDir, 0))
    do
        local ChildActor = self.ModelMajorController:GetChildActor()
        if ChildActor ~= nil then
            local MoveComponent = ChildActor.CharacterMovement
            if _G.UE.UCommonUtil.IsObjectValid(MoveComponent) then
                MoveComponent.MaxWalkSpeed = 0;
                MoveComponent.MaxFlySpeed = 0;
                MoveComponent.MaxCustomMovementSpeed = 0;
                MoveComponent.MaxSwimSpeed = 0;
                ChildActor:SetScaleFactor(1.0, true)
            end
        end
    end

    self.ModelCompanionController:Create(0, _G.UE.FVector(self.PlayerPos.X, self.PlayerPos.Y,  ModelDefine.DefaultLocation.Z ), _G.UE.FRotator(0, CompanionDir, 0))
    do
        local ChildActor = self.ModelCompanionController:GetCompanionActor()
        if ChildActor ~= nil then
            local MoveComponent = ChildActor.CharacterMovement
            if _G.UE.UCommonUtil.IsObjectValid(MoveComponent) then
                MoveComponent.MaxWalkSpeed = 0;
                MoveComponent.MaxFlySpeed = 0;
                MoveComponent.MaxCustomMovementSpeed = 0;
                MoveComponent.MaxSwimSpeed = 0;
            end
        end
    end

    self.StageUniverseController:Create()
    self.StageUniverseController:BindUIComplexCharacter(self.ModelMajorController:GetChildActor())
    self.ModelCameraController:EnableMove(false)
    _G.LightMgr:SwitchSceneLights(false)

    self.ModelCameraController:SetSpringArmLocation(_G.UE.FVector(0, 0 ,0), false)
    self.ModelCameraController:SetSpringArmCompArmLength(Length, false)
    self.ModelCameraController:SetCameraFOV(FOV)

end

function BattlePassShowModelMgr:OnCreateStageFinish()
    _G.FLOG_INFO("BattlePassShowModelMgr:OnCreateStageFinish ")
    if self.ModelCameraController == nil then
        _G.FLOG_WARNING("BattlePassShowModelMgr:OnCreateStageFinish ModelCameraController is nil")
        return
    end

    if self.StageUniverseController == nil then
        _G.FLOG_WARNING("BattlePassShowModelMgr:OnCreateStageFinish StageUniverseController is nil")
        return
    end
    self.ModelCameraController:BindCameraActor(self.StageUniverseController:GetActor())
    self.ModelCameraController:Switch(true)
end

-- 模型组装完成
function BattlePassShowModelMgr:OnAssembleAllEnd(Params)

    if Params.ULongParam1 == 0 and Params.IntParam1 == _G.UE.EActorType.UIActor then
        if not self.IsCreate then
            self.LoadingCount = self.LoadingCount - 1
            if self.LoadingCount == 0 then
                self.DoActive = true
                self.IsCreate = true

                self:SetActorLOD(1)
                if self.OnCreateSuccessCallBack then
                    self.OnCreateSuccessCallBack()
                    self.OnCreateSuccessCallBack = nil
                end
            end
        end
    end

    if Params.ULongParam1 == 0 and Params.IntParam1 == _G.UE.EActorType.Companion then
        if not self.IsCreate then
            self.LoadingCount = self.LoadingCount - 1
            if self.LoadingCount == 0 then
                self.DoActive = true
                self.IsCreate = true

                self:SetActorLOD(1)
                if self.OnCreateSuccessCallBack then
                    self.OnCreateSuccessCallBack()
                    self.OnCreateSuccessCallBack = nil
                end
            end
        end
    end

end

function BattlePassShowModelMgr:OnChangeModel(Params)
	local PosX = Params.PosX
	local PosY = Params.PosY
	local PosZ = Params.PosZ
	local RotZ = Params.RotZ
	local Distance = Params.Distance
	print("<janlog>   PosX == " .. PosX .. "  PosY == " .. PosY .. "  PosZ == " .. PosZ .."  RotZ == " .. RotZ .. "   Distance == " .. Distance)
	-- self.Common_Render2DToImage:SetSpringArmDistance(Distance, false)
	self.ModelMajorController:SetModelLocation(PosX, PosY, PosZ)
	-- self.Common_Render2DToImage:SetModelRotation(0, RotZ, 0, false)
	self.IsNeedChangeModel  = false
end

function BattlePassShowModelMgr:IsCreateFinish()
    return self.IsCreate and self.LoadingCount == 0
end

function BattlePassShowModelMgr:SetActiveFlag(bActive)
    self.DoActive = bActive
end

function BattlePassShowModelMgr:GetActiveFlag()
    return self.DoActive
end

function BattlePassShowModelMgr:SetUIType(InType)
    self.CurUIType = InType
end

function BattlePassShowModelMgr:GetMajorController()
    return self.ModelMajorController
end

function BattlePassShowModelMgr:GetCompanionController()
    return self.ModelCompanionController
end

function BattlePassShowModelMgr:GetCameraController()
    return self.ModelCameraController
end

function BattlePassShowModelMgr:SetCameraFocus()
    self.ModelCameraController:set(_G.UE.FVector(0, 0, 0))
end

function BattlePassShowModelMgr:EnableZoom(bEnable)
    self.bEnableZoom = bEnable
end

function BattlePassShowModelMgr:SwitchActorAutoRotator(bOpen)
    if bOpen ~= nil then
        self.AutoRotator = bOpen
    else
        self.AutoRotator = not self.AutoRotator
    end

    if self.AutoRotator then
        if self.DurationTimerID ~= 0 then
            _G.TimerMgr:CancelTimer(self.DurationTimerID)
        end
        self.DurationTimerID = _G.TimerMgr:AddTimer(self, self.OnDurationTimer, 0, self.DurationDeltaTime, 0)
    else
        if self.DurationTimerID ~= 0 then
            _G.TimerMgr:CancelTimer(self.DurationTimerID)
        end
    end
end

function BattlePassShowModelMgr:OnDurationTimer()
    if not self:IsCreateFinish() then
        return
    end

    --自动旋转
    if self.AutoRotator == true and self.bCanRotate then
        do
            if self.ModelMajorController ~= nil then
                local SkeletalMeshComponent = self.ModelMajorController.SkeletalMeshComponent
                if SkeletalMeshComponent ~= nil and _G.UE.UCommonUtil.IsObjectValid(SkeletalMeshComponent) then
                    local NewRotation = _G.UE.FRotator(0, self.AutoRotateVel, 0)
                    local RotateAroundPoint = _G.UE.FVector(0, 0, 0)
                    if self.IsRotateAroundPoint then
                        RotateAroundPoint =  _G.UE.FVector(0, self.PlayerPos.Y, 0)
                    end
                    local ActorLocation = self.ModelMajorController:GetModelLocation()
                    local OffsetToActor = ActorLocation - RotateAroundPoint
                    local RotatedOffset = NewRotation:RotateVector(OffsetToActor)
                    local NewLocation = RotateAroundPoint + RotatedOffset
                    self.ModelMajorController:SetModelLocation(NewLocation.X, NewLocation.Y, NewLocation.Z)
                    SkeletalMeshComponent:K2_AddLocalRotation(NewRotation, false, _G.UE.FHitResult(), false)
                end
            end
        end
    end
end

function BattlePassShowModelMgr:EnableRotator(bEnable)
    self.bEnableRotator = bEnable
end

---设置旋转限制参数
---@param MinYaw number@最小角度
---@param MaxYaw number@最大角度
function BattlePassShowModelMgr:SetRotateLimiParams(MinYaw, MaxYaw)
    self.RotateLimiParams = {}
    self.RotateLimiParams.MinYaw = MinYaw
    self.RotateLimiParams.MaxYaw = MaxYaw
end

--需要LOD强制设置为0时，参数传1
function BattlePassShowModelMgr:SetActorLOD(LODLevel)
    if self.ModelMajorController then
        do
            local UIComplexCharacter = self.ModelMajorController:GetUIComplexCharacter()
            if UIComplexCharacter then
                local AvatarComponent = UIComplexCharacter:GetAvatarComponent()
                if AvatarComponent == nil then
                    return
                end

                AvatarComponent:SetForcedLODForAll(LODLevel)
            end
        end
    end
   
    if self.ModelCompanionController then
        do
            local UIComplexCharacter = self.ModelCompanionController:GetUIComplexCharacter()
            if UIComplexCharacter then
                local AvatarComponent = UIComplexCharacter:GetAvatarComponent()
                if AvatarComponent == nil then
                    return
                end

                AvatarComponent:SetForcedLODForAll(LODLevel)
            end
        end
    end
end

function BattlePassShowModelMgr:ShowRenderActor(bShow)
    if self.ModelMajorController and self.ModelMajorController:GetChildActor() then
        self.ModelMajorController:GetChildActor():SetActorHiddenInGame(not bShow)
    end

    if self.ModelCompanionController and self.ModelCompanionController:GetCompanionActor() then
        self.ModelCompanionController:GetCompanionActor():SetActorHiddenInGame(not bShow)
    end

    if self.StageUniverseController and self.StageUniverseController:GetActor() then
        self.StageUniverseController:GetActor():SetActorHiddenInGame(not bShow)
    end
end

function BattlePassShowModelMgr:SetModelDefaultPos()
    if self.ModelMajorController == nil then
        return
    end

    if self.ModelCompanionController == nil then
        return
    end
    
    local PlayerPos = ModelDefine.DefaultLocation
    local Rotation = ModelDefine.DefaultRotation
    self.ModelMajorController:SetModelLocation(PlayerPos.X, PlayerPos.Y, PlayerPos.Z)
    self.ModelMajorController:SetModelRotation(0, Rotation.Y, 0)

    self.ModelCompanionController:SetModelLocation(PlayerPos.X, PlayerPos.Y, PlayerPos.Z)
    self.ModelCompanionController:SetModelRotation(0, Rotation.Y, 0)

end

function BattlePassShowModelMgr:UpdateMajorModel()
end

function BattlePassShowModelMgr:UpdateCompanionModel(CompanionID)
    if self.ModelCompanionController then
        self.ModelCompanionController:SwitchModel(CompanionID)
    end
end 

function BattlePassShowModelMgr:BindCommGesture(UIView, InSingleClick)
    self.CommGesture = UIView
    self.SingleClick = InSingleClick
    UIView:SetOnClickedCallback(function(ScreenPosition)
        self:OnClickedHandle(ScreenPosition)
    end)
    UIView:SetOnPositionChangedCallback(function(X, Y)
        self:OnDragHandle(X, Y)
    end)
end

function BattlePassShowModelMgr:OnClickedHandle(ScreenPosition)
    if self.SingleClick then
        self.SingleClick(ScreenPosition)
    end
end

function BattlePassShowModelMgr:OnDragHandle(X, Y)
    local OffsetX = self.LastDragX - X
    if FMath.abs(OffsetX) <= 5 then
        return
    end

    if OffsetX > 15.0 then
        OffsetX = 15.0
    elseif OffsetX < -15.0 then
        OffsetX = -15.0
    end

    if self.bEnableRotator then
        do
            if self.ModelMajorController ~= nil then
                local SkeletalMeshComponent = self.ModelMajorController.SkeletalMeshComponent
                if SkeletalMeshComponent ~= nil and _G.UE.UCommonUtil.IsObjectValid(SkeletalMeshComponent) then
                    local NewRotation = _G.UE.FRotator(0, OffsetX, 0)
                    local RotateAroundPoint = _G.UE.FVector(0, 0, 0)
                    if self.IsRotateAroundPoint then
                        RotateAroundPoint =  _G.UE.FVector(0, self.PlayerPos.Y, 0)
                    end
                    local ActorLocation = self.ModelMajorController:GetModelLocation()
                    local OffsetToActor = ActorLocation - RotateAroundPoint
                    local RotatedOffset = NewRotation:RotateVector(OffsetToActor)
                    local NewLocation = RotateAroundPoint + RotatedOffset
                    self.ModelMajorController:SetModelLocation(NewLocation.X, NewLocation.Y, NewLocation.Z)
                    SkeletalMeshComponent:K2_AddLocalRotation(NewRotation, false, _G.UE.FHitResult(), false)
                end
            end
        end
    end
    self.LastDragX = X
end

------------------------------------ 对外接口 ------------------------------------

function BattlePassShowModelMgr:ShowRiderCharacter(MountID)
    if self.ModelMajorController == nil then
        return
    end

    self.ModelMajorController:SetUIRideCharacter(MountID)
end

function BattlePassShowModelMgr:TakeOffRideAvatar()
    if self.ModelMajorController == nil then
        return
    end

    self.ModelMajorController:TakeOffRideAvatar()
end

function BattlePassShowModelMgr:ShowMajor(bShow)
    if self.ModelMajorController and self.ModelMajorController:GetChildActor() then
        self.ModelMajorController:GetChildActor():SetActorHiddenInGame(not bShow)
    end
end

function BattlePassShowModelMgr:HidePlayer(bShowPlayer)
    if self.ModelMajorController then
        self.ModelMajorController:HidePlayer(bShowPlayer)
        self.IsRotateAroundPoint = bShowPlayer
    end
end

function BattlePassShowModelMgr:PreviewEquipment(EquipID, PartID, ColorID)
  if self.ModelMajorController == nil then
    _G.FLOG_INFO("BattlePassShowModelMgr:PreviewEquipment ModelMajorController is Nil")
    return 
  end
  local UIComplexCharacter = self.ModelMajorController:GetUIComplexCharacter()
  if UIComplexCharacter == nil then
    _G.FLOG_INFO("BattlePassShowModelMgr:PreviewEquipment UIComplexCharacter is Nil")
    return
  end

  if EquipID == nil or EquipID == 0 then
        local PosKey = EquipmentDefine.EquipmentTypeMap[PartID]
        if PosKey then
            UIComplexCharacter:TakeOffAvatarEquip(PosKey, false)
        else
            local Equip = EquipmentMgr:GetEquipedItemByPart(PartID)
            if Equip then
                local EquipCfg = EquipmentCfg:FindCfgByKey(Equip.ResID)
                if EquipCfg then
                    UIComplexCharacter:TakeOffAvatarEquip(EquipCfg.EquipmentType, false)
                end
            end
        end
  else
    UIComplexCharacter:HandleAvatarEquip(EquipID, PartID, ColorID)
  end

  UIComplexCharacter:StartLoadAvatar()
end

function  BattlePassShowModelMgr:GetStageUniverseCameraActor()
    if self.StageUniverseController then
        return self.StageUniverseController:GetActor()
    end
end

function BattlePassShowModelMgr:SetRiderCfg(Cfg)
    self.RiderCfg = Cfg
end

function BattlePassShowModelMgr:SetModelScale()
    if self.ModelMajorController == nil then
        return
    end

    local ChildActor = self.ModelMajorController:GetChildActor()
    if ChildActor then
        local Scale = 1.0
        if self.RiderCfg ~= nil then
            Scale = self.RiderCfg.ModelScaling * 0.8
        end
        ChildActor:SetScaleFactor(Scale, true)
    end

end

return BattlePassShowModelMgr