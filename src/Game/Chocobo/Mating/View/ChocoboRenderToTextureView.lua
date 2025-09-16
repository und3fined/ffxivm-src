---
--- Author: Administrator
--- DateTime: 2024-04-23 14:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")

local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local BuddyEquipCfg = require("TableCfg/BuddyEquipCfg")
local RideCfg = require("TableCfg/RideCfg")

local ModelDefine = require("Game/Model/Define/ModelDefine")
local RenderActorPath = ModelDefine.ChocoboStagePath.Universe
local DefaultLocation = UE.FVector(0, 0, 100000)
local DefaultRotation = UE.FRotator(0, 0, 0)

---@class ChocoboRenderToTextureView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImageRole UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRenderToTextureView = LuaClass(UIView, true)

function ChocoboRenderToTextureView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImageRole = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRenderToTextureView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRenderToTextureView:OnInit()
	self.RenderTexture = nil
	self.IsInitImageMode = false
	self.OnCreateSuccessCallBack = nil
	self.LoadingCount = -1
	self.IsCreate = false
	self.IsHDModel = true 
end

function ChocoboRenderToTextureView:OnDestroy()

end

function ChocoboRenderToTextureView:OnShow()
end

function ChocoboRenderToTextureView:OnHide()
	self:Reset()
end

function ChocoboRenderToTextureView:OnRegisterUIEvent()

end

function ChocoboRenderToTextureView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
end

function ChocoboRenderToTextureView:OnRegisterBinder()

end

function ChocoboRenderToTextureView:Reset()
    self.LoadingCount = -1
    self.IsCreate = false

    if self.IsInitImageMode then
		if self.SceneActor then
			local CaptureComp2D = self.SceneActor.SceneCaptureComponent2D
			if CaptureComp2D then
				CaptureComp2D.TextureTarget = nil
				CaptureComp2D.bCaptureEveryFrame = false
				CaptureComp2D:SetVisibility(false)
			end
		end
	end
	self.IsInitImageMode = false
	self:Release()
end

function ChocoboRenderToTextureView:CreateRenderRActor(OnCreateSuccessCallBack)
    local Location = _G.UE.FVector(400, 45, 100000-100)
    local Rotation = _G.UE.FRotator(0, -45, 0)
    self:CreateRenderActor(Location,Rotation,OnCreateSuccessCallBack)
end

function ChocoboRenderToTextureView:CreateRenderLActor(OnCreateSuccessCallBack)
    local Location = _G.UE.FVector(400, -55, 100000-100)
    local Rotation = _G.UE.FRotator(0, 45, 0)
    self:CreateRenderActor(Location,Rotation,OnCreateSuccessCallBack)
end

function ChocoboRenderToTextureView:CreateRenderActor(Location,Rotation,OnCreateSuccessCallBack)
	-- 创建模型
    self.LoadingCount = 2
    self.IsCreate = false
    self.OnCreateSuccessCallBack = OnCreateSuccessCallBack
    self:CreateActor(Location,Rotation)
   	self:CreateSceneActor(RenderActorPath)

    self:SetRenderToImageMode(true)
end

function ChocoboRenderToTextureView:IsCreateFinish()
	return self.IsCreate and self.LoadingCount == 0
end

function ChocoboRenderToTextureView:OnAssembleAllEnd(Params)
	if Params.ULongParam1 == 0 and Params.IntParam1 == _G.UE.EActorType.UIActor then
		self:UpdateRender()
        if not self.IsCreate then
            self.LoadingCount = self.LoadingCount - 1
            if self.LoadingCount == 0 then
                self.DoActive = true
                self.IsCreate = true

                --self:SetActorLOD(1)
                if self.OnCreateSuccessCallBack then
                    self.OnCreateSuccessCallBack()
                    self.OnCreateSuccessCallBack = nil
                end
            end
        end
    end
end

function ChocoboRenderToTextureView:SetRenderToImageMode(IsShowImage)
	if self.IsInitImageMode then return end
    if self.SceneActor == nil then return end 

	self.IsInitImageMode = true
	local Size = UIUtil.GetWidgetSize(self)
	if Size then
		local CaptureComp2D = self.SceneActor.SceneCaptureComponent2D
		if CaptureComp2D then
			self.RenderTexture, self.Scale2D = _G.CommonModelToImageMgr:CreateRenderTarget2D(self, Size.X, Size.Y, self.IsHDModel)
			CaptureComp2D.TextureTarget = self.RenderTexture
			CaptureComp2D.bCaptureEveryFrame = true
			CaptureComp2D:SetVisibility(true)
			CaptureComp2D:ShowOnlyActorComponents(self:GetUIComplexCharacter())
			UIUtil.ImageSetMaterialTextureParameterValue(self.ImageRole, "RenderTarget", self.RenderTexture)
		end
	end

	if IsShowImage ~= false then
		UIUtil.SetIsVisible(self.ImageRole, true)
	end

	if self.Scale2D then
		self.ImageRole:SetRenderScale(self.Scale2D)
	end
end

function ChocoboRenderToTextureView:UpdateRender()
	if not self.IsInitImageMode then return end
    if self.SceneActor == nil then return end
    
	local CaptureComp2D = self.SceneActor.SceneCaptureComponent2D
	if CaptureComp2D then
		CaptureComp2D:ShowOnlyActorComponents(self:GetUIComplexCharacter())
	end
end

function ChocoboRenderToTextureView:CreateActor(LocationParam, RotationParam)
    self.ChildActorComponent = _G.NewObject(_G.UE.UFMChildActorComponent, FWORLD())
    if self.ChildActorComponent ~= nil then
		self.ChildActorComponentRef = UnLua.Ref(self.ChildActorComponent)
    	local CharacterClass = _G.ObjectMgr:LoadClassSync(_G.EquipmentMgr:GetEquipmentCharacterClass())
    	if CharacterClass ~= nil then 
            self.ChildActorComponent:SetChildActorClass(CharacterClass)
            self.ChildActorComponent:CreateChildActor()
            self.ChildActor = self.ChildActorComponent:GetChildActor()
            if self.ChildActor then 
                local Location = LocationParam and LocationParam or DefaultLocation
                local Rotation = RotationParam and RotationParam or DefaultRotation

                self.ChildActor:K2_SetActorLocation(Location, false, nil, false)
                self.ChildActor:K2_SetActorRotation(Rotation, false)

                self.ChildActorLocation = self.ChildActor:FGetActorLocation()
                local EntityID = MajorUtil.GetMajorEntityID()
                local CopyFromActor = ActorUtil.GetActorByEntityID(EntityID)
                if CopyFromActor then
                    self.ChildActor:CopySkeletalMesh(CopyFromActor)
                end
            end
        end
    end
end

function ChocoboRenderToTextureView:CreateSceneActor(RenderScenePath)  
    local SceneClass = _G.ObjectMgr:LoadClassSync(RenderScenePath)
    if SceneClass == nil then return end
    self.SceneActor = CommonUtil.SpawnActor(SceneClass, DefaultLocation, DefaultRotation)
	if self.SceneActor == nil then return end
end

function ChocoboRenderToTextureView:Release()
    if self.RenderTexture then
        _G.CommonModelToImageMgr:ReleaseRenderTarger2D(self.RenderTexture)
        self.RenderTexture = nil
    end

	if nil ~= self.ChildActorComponent then
		self.ChildActorComponentRef = nil
		self.ChildActorComponent = nil
	end
    
    if self.ChildActor ~= nil then
        CommonUtil.DestroyActor(self.ChildActor)
        self.ChildActor = nil
    end

    if self.SceneActor ~= nil then 
        CommonUtil.DestroyActor(self.SceneActor)
        self.SceneActor = nil
    end

    self.RideMeshComponent = nil
end

function ChocoboRenderToTextureView:GetUIComplexCharacter()
	if self.ChildActor == nil then return end

    local UIComplexCharacter = self.ChildActor:Cast(_G.UE.AUIComplexCharacter)
    return UIComplexCharacter
end

function ChocoboRenderToTextureView:HidePlayer(bFlag)
	if self.ChildActor == nil then return end
	self.ChildActor:HidePlayerPart(bFlag)
end

function ChocoboRenderToTextureView:UpdateUIChocoboModel(Armor, StainID)
    local Head = Armor and Armor.Head or 0
    local Body = Armor and Armor.Body or 0
    local Feet = Armor and Armor.Feet or 0
    StainID = StainID or 0

    local HeadChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(Head)
    local HeadString = HeadChocoboEquipCfg and HeadChocoboEquipCfg.ModelString or ""
    local FeetChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(Feet)
    local FeetString = FeetChocoboEquipCfg and FeetChocoboEquipCfg.ModelString or ""
    local BodyChocoboEquipCfg = BuddyEquipCfg:FindCfgByKey(Body)
    local BodyString = BodyChocoboEquipCfg and BodyChocoboEquipCfg.ModelString or ""

    local RideComponent = self.ChildActor:GetRideComponent()
    if RideComponent ~= nil and _G.UE.UCommonUtil.IsObjectValid(RideComponent) then
        self:HidePlayer(true)
        RideComponent:UseRide(ChocoboDefine.CHOCOBO_RIDE_ID, 0, StainID, HeadString, BodyString, "", FeetString)
        RideComponent:EnableAnimationRotating(false)
        self.RideMeshComponent = self.ChildActor:GetRideMeshComponent()
    end
end

return ChocoboRenderToTextureView