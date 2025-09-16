local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local CompanionCfg = require ("TableCfg/CompanionCfg")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local ObjectGCType = require("Define/ObjectGCType")
local ObjectMgr = _G.ObjectMgr
local FMath = _G.UE.UKismetMathLibrary
local FLOG_INFO = _G.FLOG_INFO

---@class ModelCompanionController
local ModelCompanionController = LuaClass()

function ModelCompanionController:Ctor()
    self.CompanionActorLocation = ModelDefine.DefaultLocation

end

function ModelCompanionController:GetFocusPoint()
end

function ModelCompanionController:SetFocusPoint()
    local ActorTransform = self.SceneActor:GetTransform()
	local SocketLocation = self.CompanionActor:GetSocketLocationByName("root_M")
	self.DefaultFocusLocation = _G.UE.UKismetMathLibrary.InverseTransformLocation(ActorTransform, SocketLocation)
end

function ModelCompanionController:Create(CompanionID, LocationParam, RotationParam)
    local AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachType()
    local RenderScenePath = string.format(ModelDefine.StagePath.Universe, AttachType, AttachType)
    local Params = _G.UE.FCreateClientActorParams()
    Params.bUIActor = true
    
    self.CompanionEntityID = _G.UE.UActorManager:Get():CreateClientActorByParams(_G.UE.EActorType.Companion, 0, CompanionID, LocationParam, RotationParam, Params)
	self.CompanionActor = ActorUtil.GetActorByEntityID(self.CompanionEntityID)
    
    local function SuccessCallback()
        self.CompanionActor:GetMovementComponent():SetComponentTickEnabled(false)
        _G.FLOG_INFO(" ModelCompanionController:Create SuccessCallback Success")
    end

    local function FailCallback()
        _G.FLOG_INFO(" ModelCompanionController:Create FailCallback Success")
    end

    ObjectMgr:LoadClassAsync(RenderScenePath, SuccessCallback , ObjectGCType.LRU, FailCallback)

end

function ModelCompanionController:Release()
    if self.CompanionActor then
        CommonUtil.DestroyActor(self.CompanionActor)
        self.CompanionActor = nil
    end
    self.SkeletalMeshComponent = nil
end


function ModelCompanionController:OnSceneActorEndPlay(Actor, EndPlayReason)
    self:Release()
end

---获取AUIComplexCharacter
---@return UE.AUIComplexCharacter
function ModelCompanionController:GetCompanionActor()
    return self.CompanionActor
end

function ModelCompanionController:GetUIComplexCharacter()
    if self.CompanionActor == nil then
        return nil
    end

    local UIComplexCharacter = self.CompanionActor:Cast(_G.UE.AUIComplexCharacter)
    return UIComplexCharacter
end

-- ==================================================
-- 设置模型参数
-- ==================================================

function ModelCompanionController:SetModelLocation(InX, InY, InZ)
    if self.CompanionActor == nil then
        return
    end

    self.CompanionActor:K2_SetActorLocation(_G.UE.FVector(InX + self.CompanionActorLocation.x, InY + self.CompanionActorLocation.y, InZ + self.CompanionActorLocation.z), false, nil, false)
end

function ModelCompanionController:GetModelLocation()
    if nil == self.CompanionActor then
        return
    end
    
    return self.CompanionActor:K2_GetActorLocation() - self.CompanionActorLocation
end

function ModelCompanionController:SetModelRotation(InPitch, InYaw, InRoll)
    if (self.SkeletalMeshComponent == nil) then
        return
    end
 
    self.SkeletalMeshComponent:K2_SetRelativeRotation(_G.UE.FRotator(InPitch, InYaw, InRoll), false, nil, false)
end

function ModelCompanionController:GetModelRotation()
    if nil == self.SkeletalMeshComponent then
        return
    end
    
    return self.SkeletalMeshComponent:GetRelativeRotation()
end

function ModelCompanionController:SetModelScale(InScale)
    if self.CompanionActor == nil then
        return 
    end
    
    self.CompanionActor:SetModelScale(InScale)
end

function ModelCompanionController:GetModelScale()
    if self.CompanionActor == nil then
        return 
    end

    return self.CompanionActor:GetActorScale3D().X
end

function ModelCompanionController:GetSkeletalMeshComponent(Actor)
    if nil == Actor then
        return
    end

    local Component = Actor:GetComponentByClass(_G.UE.USkeletalMeshComponent)
    if Component == nil then
        return
    end
    return Component:Cast(_G.UE.USkeletalMeshComponent)
end

function ModelCompanionController:SwitchModel(CompanionID)
    if self.CompanionActor == nil then return end

	FLOG_INFO(string.format(" ModelCompanionController:SwitchModelLoad %s model", self:GetCompanionName(CompanionID)))
	local CompanionCharacter = self.CompanionActor:Cast(_G.UE.ACompanionCharacter)
	CompanionCharacter:SwitchRole(CompanionID)
end

function ModelCompanionController:GetCompanionName(CompanionID)
	local Cfg = CompanionCfg:FindCfgByKey(CompanionID)
	if Cfg == nil then return "" end

	return Cfg.Name
end




return ModelCompanionController