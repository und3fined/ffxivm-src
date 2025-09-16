---
--- Author: sammrli
--- DateTime: 2023-12-04 10:25
--- Description:模型转Image ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActorUtil = require("Utils/ActorUtil")
local RenderSceneDefine = require ("Game/Common/Render2D/RenderSceneDefine")

local UE = _G.UE
local LightMgr = _G.LightMgr
local CameraMgr = UE.UCameraMgr.Get()
local UFGameFXManager = UE.UFGameFXManager.Get()
local UPrimitiveComponent = UE.UPrimitiveComponent
local CommonModelToImageMgr = _G.CommonModelToImageMgr

local DEFAULT_CAMERA_FOV = 44.69
local SCS_SceneColorHDR = UE.ESceneCaptureSource.SCS_SceneColorHDR or 0
local SCS_FinalColorLDRHasAlpha = UE.ESceneCaptureSource.SCS_FinalColorLDRHasAlpha or 3

---@class CommonModelToImageVM : UIViewModel
---@field RenderTarget UE.UTextureRenderTarget2D
---@field IsVisible boolean
---@field Scale UE.FVector2D
local CommonModelToImageVM = LuaClass(UIViewModel)

function CommonModelToImageVM:Ctor()
	self.RenderTarget = nil
	self.IsVisible = nil
	self.Scale = nil

	self.TargetActor = nil
	self.CameraActor = nil
	self.CameraComponent = nil
	self.Distance = 120
	self.HightOffset = 0
	self.PanOffset = 0
	self.Angle = 0
	self.PitchAngle = 0
	self.FOV = DEFAULT_CAMERA_FOV
	self.IsAutoCreateDefaultScene = true

	self.ActorOriginLocation = nil
end

function CommonModelToImageVM:SetCameraLocation()
	if not self.TargetActor or not self.CameraActor then
		return
	end
	local ActorLocation = self.TargetActor:K2_GetActorLocation()
	local Rotator = UE.FRotator(self.PitchAngle, self.Angle, 0)
	self.CameraActor:K2_SetActorRotation(Rotator, false)
	local Dir = Rotator:GetForwardVector() * -1
	local PanDir = Rotator:GetRightVector()
	local CameraLocation = ActorLocation + Dir * self.Distance + PanDir * self.PanOffset + UE.FVector(0, 0, self.HightOffset)
	self.CameraActor:K2_SetActorLocation(CameraLocation, false, nil, false)
end

function CommonModelToImageVM:__AddEffectToShowByDocumentComponent(DocumentComponent, CaptureComp)
	if DocumentComponent.Childs then
		local ChildsNum = DocumentComponent.Childs:Length()
		for i=1, ChildsNum do
			local DocumentInstance = DocumentComponent.Childs:Get(i)
			if DocumentInstance then
				self:__AddEffectToShowByDocumentComponent(DocumentInstance, CaptureComp)
			end
		end
	end

	if DocumentComponent.GetParticleSystemComponentList then
		local PSCList = DocumentComponent:GetParticleSystemComponentList()
		local Num = PSCList:Length()
		for i=1, Num do
			local PSC = PSCList:Get(i)
			if PSC then
				CaptureComp:ShowOnlyComponent(PSC)
			end
		end
	end
end

function CommonModelToImageVM:__AddEffectToShow(TargetActor, CaptureComp)
	if TargetActor.GetAvatarComponent then
		local AvatarComp = TargetActor:GetAvatarComponent()
		if AvatarComp and AvatarComp.Effects then
			for _, HandleID in pairs(AvatarComp.Effects.VFXMap) do
				local VFXBase = UFGameFXManager:GetVfxInstance(HandleID)
				if VFXBase and VFXBase.DocumentInstance then
					self:__AddEffectToShowByDocumentComponent(VFXBase.DocumentInstance, CaptureComp)
				end
			end
		end
	end
end

-- ==================================================
-- View使用接口
-- ==================================================

function CommonModelToImageVM:Release()
	if self.CameraComponent then
		-- 重置参数
		local Comp2D = CameraMgr:AttachCaptureComponent2DToCamera(self.CameraComponent)
		if Comp2D then
			Comp2D.CaptureSource = SCS_SceneColorHDR
			Comp2D.TextureTarget = nil
			Comp2D.bCaptureEveryFrame = false
			Comp2D:SetVisibility(false)
		end
		self.CameraComponent = nil
	end
	if self.CameraActor then
		CommonModelToImageMgr:ReleaseCameraActor(self.CameraActor)
		self.CameraActor = nil
	end
	if self.RenderTarget then
		CommonModelToImageMgr:ReleaseRenderTarger2D(self.RenderTarget)
		self.RenderTarget = nil
	end
	---回退效果
	if self.TargetActor then
		--还原LOD
		local AvatarComp = self.TargetActor:GetAvatarComponent()
		if AvatarComp then
			AvatarComp:SetForcedLODForAll(0)
		end

		--还原位置
		if self.ActorOriginLocation then
			self.TargetActor:K2_SetActorLocation(self.ActorOriginLocation, false, nil, false)
		end
	end
	self.TargetActor = nil

	CommonModelToImageMgr:SetRenderSceneActorVisiable(false)
end

function CommonModelToImageVM:Show(TargetActor, CameraComponent, Size, Location)
	self.TargetActor = TargetActor

	if self.IsAutoCreateDefaultScene then
		-- 记录并设置target的位置，避免受到场景灯光影响
		self.ActorOriginLocation = TargetActor:K2_GetActorLocation()

		Location = Location or RenderSceneDefine.Location
		TargetActor:K2_SetActorLocation(Location, false, nil, false)
	end

	if not CameraComponent then
		if not self.CameraActor then
			self.CameraActor = CommonModelToImageMgr:CreateCameraActor()
			self:SetCameraLocation()
		end
		CameraComponent = self.CameraActor.CameraComponent
	end
	self.CameraComponent = CameraComponent

	---效果优化
	--设置LOD
	local AvatarComp = TargetActor:GetAvatarComponent()
	if AvatarComp then		
		AvatarComp:SetForcedLODForAll(1)
	end

	-- 如果actor受视野控制,反注册
	UE.UVisionMgr.Get():RemoveFromVision(TargetActor)
	local MeshComponent = TargetActor:GetMeshComponent()
	if MeshComponent then
		-- 保证相机未看向Target状态下动画正常
		MeshComponent.VisibilityBasedAnimTickOption = UE.EVisibilityBasedAnimTickOption.AlwaysTickPoseAndRefreshBones
		local CompList = self.TargetActor:K2_GetComponentsByClass(UPrimitiveComponent)
		if CompList then
			local Num = CompList:Length()
			for i = 1, Num do
				local Comp = CompList:Get(i)
				Comp.VisibilityBasedAnimTickOption = UE.EVisibilityBasedAnimTickOption.AlwaysTickPoseAndRefreshBones
			end
		end
	end

	local Comp2D = CameraMgr:AttachCaptureComponent2DToCamera(CameraComponent)
	if Comp2D then
		if not self.RenderTarget then
			local RenderTarget2D, Scale2D = CommonModelToImageMgr:CreateRenderTarget2D(TargetActor, Size.X, Size.Y, self.IsHDModel)
			self.RenderTarget = RenderTarget2D
			self.Scale = Scale2D
			Comp2D.FOVAngle = self.FOV
			Comp2D.CaptureSource = SCS_FinalColorLDRHasAlpha
			Comp2D.TextureTarget = RenderTarget2D
		end
		self.IsVisible = true
		Comp2D.bCaptureEveryFrame = true
		Comp2D:SetVisibility(true)
		Comp2D:ClearShowOnlyComponents()
		Comp2D:ShowOnlyActorComponents(TargetActor, true)
		local function AddEffectToShow()
			if _G.CommonUtil.IsObjectValid(TargetActor) and _G.CommonUtil.IsObjectValid(Comp2D) then
				self:__AddEffectToShow(TargetActor, Comp2D)
			end
		end
		_G.TimerMgr:AddTimer(nil, AddEffectToShow, 0, 0.05, 5)--临时方案,后续需要avatarComponent监听特效创建完成,回调里主动刷新rt,rt内部不做处理
	end

	if self.IsAutoCreateDefaultScene then
		CommonModelToImageMgr:SetRenderSceneActorVisiable(true)
	end
end

function CommonModelToImageVM:CreateAndShow(ModelPath, CameraComponent, Size)
	local function LoadModelCallback()
		local ModelClass = _G.ObjectMgr:GetClass(ModelPath)
		if (ModelClass == nil) then
			return
		end

		local TargetActor = _G.CommonUtil.SpawnActor(ModelClass)
		if not TargetActor then
			return
		end

		self:Show(TargetActor, CameraComponent, Size)
	end

	_G.ObjectMgr:LoadClassAsync(ModelPath, LoadModelCallback)
end

function CommonModelToImageVM:SetAutoCreateDefaultScene(Val)
	self.IsAutoCreateDefaultScene = Val
	if not Val then
		CommonModelToImageMgr:SetRenderSceneActorVisiable(false)
	end
end

---@deprecated @禁止使用
function CommonModelToImageVM:SetHDModel()
	self.IsHDModel = true
end

---@param Val number 相机离目标距离(默认120)
function CommonModelToImageVM:SetDistance(Val)
	if Val < 10 then
		Val = 10
	end

	self.Distance = Val
	self:SetCameraLocation()
end

---@param Val number 相机与模型高度(默认0)
function CommonModelToImageVM:SetHightOffset(Val)
	self.HightOffset = Val
	self:SetCameraLocation()
end

---@param Val number 相机与Target偏航角度
function CommonModelToImageVM:SetYawAngle(Val)
	self.Angle = Val
	self:SetCameraLocation()
end

---@param Val number 相机与Target俯仰角度
function CommonModelToImageVM:SetPitchAngle(Val)
	self.PitchAngle = Val
	self:SetCameraLocation()
end

---@param Val number 相机围绕Target旋转
function CommonModelToImageVM:RotateCamera(Val)
	self.Angle = self.Angle + Val
	self:SetCameraLocation()
end

---@param Val number 相机平移Val
function CommonModelToImageVM:SetPan(Val)
	self.PanOffset = Val
	self:SetCameraLocation()
end

---@param Val number 相机FOV
function CommonModelToImageVM:SetFOV(Val)
	self.FOV = Val
	if self.CameraComponent then
		local Comp2D = CameraMgr:AttachCaptureComponent2DToCamera(self.CameraComponent)
		if Comp2D then
			Comp2D.FOVAngle = Val
		end
	end
end

--- 自动设置摄像机距离,让摄像机能够看全Actor
function CommonModelToImageVM:AutoSetDistance(MaxExtent)
	if not MaxExtent then
		if not self.TargetActor then
			return
		end
		local Origin = UE.FVector(0, 0, 0)
		local BoxExtent = UE.FVector(0, 0, 0)
		self.TargetActor:GetActorBounds(true, Origin, BoxExtent, true)
		MaxExtent = math.max(math.max(BoxExtent.X, BoxExtent.Y), BoxExtent.Z)
	end

	local Rad = math.rad(self.FOV * 0.5)
	local Dis = MaxExtent / math.tan(Rad)

	self:SetDistance(Dis)
end

--- 刷新render
function CommonModelToImageVM:UpdateRender()
	if self.TargetActor then
		if self.CameraComponent then
			local Comp2D = CameraMgr:AttachCaptureComponent2DToCamera(self.CameraComponent)
			if Comp2D then
				Comp2D:ClearShowOnlyComponents()
				Comp2D:ShowOnlyActorComponents(self.TargetActor, true)
				local function AddEffectToShow()
					if _G.CommonUtil.IsObjectValid(self.TargetActor) and _G.CommonUtil.IsObjectValid(Comp2D) then
						self:__AddEffectToShow(self.TargetActor, Comp2D)
					end
				end
				_G.TimerMgr:AddTimer(nil, AddEffectToShow, 0, 0.05, 5)
			end
		end
	end
end

function CommonModelToImageVM:SwitchModelCamera(Show)
	local CameraMgr = UE.UCameraMgr.Get()
	if CameraMgr then
		if Show then
			_G.UILevelMgr:SwitchLevelStreaming(false)
			if self.CameraActor then
				CameraMgr:SwitchCamera(self.CameraActor, 0)
			else
				FLOG_WARNING("[CommonModelToImage] Camera Actor is nil")
			end
		else
			CameraMgr:ResumeCamera(0, true, self.CameraActor)
			_G.UILevelMgr:SwitchLevelStreaming(true)
		end
	end
end

return CommonModelToImageVM