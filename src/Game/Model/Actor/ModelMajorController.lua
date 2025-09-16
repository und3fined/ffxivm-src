--
-- Author: sammrli
-- Date: 2024-3-18
-- Description:主角展示控制
--

local LuaClass = require("Core/LuaClass")

local ModelDefine = require("Game/Model/Define/ModelDefine")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")

---@class ModelMajorController
local ModelMajorController = LuaClass()

function ModelMajorController:Ctor()
end

function ModelMajorController:GetFocusPoint()
end

function ModelMajorController:Create(LocationParam, RotationParam)
    local CharacterClass = _G.ObjectMgr:LoadClassSync(_G.EquipmentMgr:GetEquipmentCharacterClass())
    if CharacterClass then
        self.ChildActorComponent = _G.NewObject(_G.UE.UFMChildActorComponent, FWORLD())
        if self.ChildActorComponent then
            self.ChildActorComponentRef = UnLua.Ref(self.ChildActorComponent)
            self.ChildActorComponent:SetChildActorClass(CharacterClass)
            self.ChildActorComponent:CreateChildActor()
            self.ChildActor = self.ChildActorComponent:GetChildActor()
            self.SkeletalMeshComponent = self:GetSkeletalMeshComponent(self.ChildActor)
            if self.ChildActor then
                local Location = LocationParam and LocationParam or ModelDefine.DefaultLocation
                local Rotation = RotationParam and RotationParam or ModelDefine.DefaultRotation

                self.ChildActor:K2_SetActorLocation(Location, false, nil, false)
                self.ChildActor:K2_SetActorRotation(Rotation, false)

                self.ChildActorLocation = self.ChildActor:FGetActorLocation()
                local EntityID = MajorUtil.GetMajorEntityID()
                local CopyFromActor = ActorUtil.GetActorByEntityID(EntityID)
                if CopyFromActor then
                    self.ChildActor:CopySkeletalMesh(CopyFromActor)
                    self.ChildActor:ClearDelegateHandle()	--解除后续同步主角外观
                end
            end
        end
    end
end

function ModelMajorController:Release()
    if self.ChildActorComponent then
        self.ChildActorComponentRef = nil
        self.ChildActorComponent = nil
    end

    if self.ChildActor then
        CommonUtil.DestroyActor(self.ChildActor)
        self.ChildActor = nil
    end
    self.SkeletalMeshComponent = nil
    self.RideMeshComponent = nil
    self.bOnRide = false
end

-- ==================================================
-- 外部接口
-- ==================================================

---获取AUIComplexCharacter
---@return UE.AUIComplexCharacter
function ModelMajorController:GetChildActor()
    return self.ChildActor
end

function ModelMajorController:GetUIComplexCharacter()
    if self.ChildActor == nil then
        return nil
    end

    local UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    return UIComplexCharacter
end

-- ==================================================
-- 装备(坐骑)相关
-- ==================================================

function ModelMajorController:SetShowHead(bShow)
    -- body
end

function ModelMajorController:SetUIRideCharacter(MountID)
    if self.ChildActor == nil then return end
    
    self.ChildActor:AddRideAvatar(MountID)
end

function ModelMajorController:UpdateUIRideMeshComponent()
    if self.ChildActor == nil then return end

    self.RideMeshComponent = self.ChildActor:GetRideMeshComponent()
    self.bOnUIRide = self.ChildActor:IsOnRide()
end

function ModelMajorController:TakeOffRideAvatar()
    if not self.ChildActor then
        return
    end
    
    local RideComponent = self.ChildActor:GetRideComponent()
    if RideComponent then
        RideComponent:UnUseRide(false)
    end
end

function ModelMajorController:HidePlayer(bHidePlayer)
    if self.ChildActor then
        self.ChildActor:HidePlayerPart(bHidePlayer)
    end
end

---设置Character武器激活状态
function ModelMajorController:HoldOnWeapon(bHoldOn)
    -- body
end

---设置Character武器显示状态
function ModelMajorController:HideWeapon(bHide)
    -- body
end

---设置Character主手武器显示状态
function ModelMajorController:HideMasterHand(bHide)
    -- body
end

---设置Character副手武器显示状态
function ModelMajorController:HideSlaveHand(bHide)
    -- body
end

---设置Character主手武器挂件显示状态
function ModelMajorController:HideAttachMasterHand(bHide)
    -- body
end

---设置Character副手武器挂件显示状态
function ModelMajorController:HideAttachSlaveHand(bHide)
    -- body
end

---设置Character头部防具显示状态
function ModelMajorController:HideHead(bHide)
    -- body
end

---设置Character头部防具开关状态
function ModelMajorController:SwitchHelmet(bOn)
    -- body
end

-- ==================================================
-- 设置模型参数
-- ==================================================

function ModelMajorController:SetModelLocation(InX, InY, InZ)
    if self.ChildActor == nil then
        return
    end

    self.ChildActor:K2_SetActorLocation(_G.UE.FVector(InX + self.ChildActorLocation.x, InY + self.ChildActorLocation.y, InZ + self.ChildActorLocation.z), false, nil, false)
end

function ModelMajorController:GetModelLocation()
    if nil == self.ChildActor then
        return
    end
    
    return self.ChildActor:K2_GetActorLocation() - self.ChildActorLocation
end

function ModelMajorController:SetModelRotation(InPitch, InYaw, InRoll)
    if (self.SkeletalMeshComponent == nil) then
        return
    end
    
    if self.bOnUIRide == true and self.RideMeshComponent ~= nil and _G.UE.UCommonUtil.IsObjectValid(self.RideMeshComponent) then
        --坐骑专用旋转
        self.RideMeshComponent:K2_SetRelativeRotation(_G.UE.FRotator(InPitch, InYaw, InRoll), false, nil, false)
        self.SkeletalMeshComponent:K2_SetRelativeRotation(_G.UE.FRotator(0, 0, 0), false, nil, false)
    else
        self.SkeletalMeshComponent:K2_SetRelativeRotation(_G.UE.FRotator(InPitch, InYaw, InRoll), false, nil, false)
    end
end

function ModelMajorController:GetModelRotation()
    if nil == self.SkeletalMeshComponent then
        return
    end
    
    return self.SkeletalMeshComponent:GetRelativeRotation()
end

function ModelMajorController:SetModelScale(InScale)
    -- body
end

function ModelMajorController:GetModelScale()
    -- body
end

function ModelMajorController:GetSkeletalMeshComponent(Actor)
    if nil == Actor then
        return
    end

    local Component = Actor:GetComponentByClass(_G.UE.USkeletalMeshComponent)
    if Component == nil then
        return
    end
    return Component:Cast(_G.UE.USkeletalMeshComponent)
end

-- ==================================================
-- 动画相关
-- ==================================================



return ModelMajorController