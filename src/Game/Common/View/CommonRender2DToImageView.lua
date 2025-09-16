---
--- Author: sammrli
--- DateTime: 2023-06-09 19:05
--- Description:公共渲染角色模型到Image(可选普通模式)
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local LoginConfig = require("Define/LoginConfig")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local EventID = require("Define/EventID")
local LoginRoleMainPanelVM = require("Game/LoginRole/LoginRoleMainPanelVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local CameraControlParams = require("Game/Common/Render2d/CameraControlParams")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ActorUtil = require("Utils/ActorUtil")

local ModelDefine = require("Game/Model/Define/ModelDefine")

local LightIntensityCoefficient = 2

local UE = _G.UE
local CommonUtil = _G.CommonUtil

---缩放聚焦位置
local ZoomFocusParam = {
	[0] = "EID_CMAKE_ALL",
	[1] = "EID_CMAKE_UPPER",
	[2] = "EID_CMAKE_LOWER",
	[3] = "EID_CMAKE_FACE",
}

---@class CommonRender2DToImageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Common_Render2D_UIBP CommonRender2DView
---@field ImageRole UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonRender2DToImageView = LuaClass(UIView, true)

function CommonRender2DToImageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Common_Render2D_UIBP = nil
	--self.ImageRole = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.IsInitImageMode = false
	self.IsRotateFullScreenModel = false
	self.RenderTexture = nil
	self.DistanceOffset = 0
end

function CommonRender2DToImageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_Render2D_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonRender2DToImageView:OnInit()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
end

function CommonRender2DToImageView:OnDestroy()
	self:Reset()
end

function CommonRender2DToImageView:OnShow()
	if self.IsRotateFullScreenModel then
		self.DefaultZOrder = UIUtil.CanvasSlotGetZOrder(self)
		self.DefaultLayout = UIUtil.CanvasSlotGetLayout(self)
		--取消ImageRole全屏锚点
		local ImageRoleLayout = UIUtil.CanvasSlotGetLayout(self.ImageRole)
		ImageRoleLayout.Anchors.Maximum = UE.FVector2D(0.5, 0.5)
		ImageRoleLayout.Anchors.Minimum = UE.FVector2D(0.5, 0.5)
		local Width = self.DefaultLayout.Offsets.Right
		local Height = self.DefaultLayout.Offsets.Bottom
		ImageRoleLayout.Offsets.Left = Width * -0.5
		ImageRoleLayout.Offsets.Top = Height * -0.5
		ImageRoleLayout.Offsets.Right = Width
		ImageRoleLayout.Offsets.Bottom = Height
		UIUtil.CanvasSlotSetLayout(self.ImageRole, ImageRoleLayout)

		self.FullScreenLayout = UIUtil.CanvasSlotGetLayout(self)
		self.FullScreenLayout.Offsets.Right = 3000
		self.FullScreenLayout.Offsets.Bottom = 3000
		local OnSetFullScreenCallBack = function(Order)
			if Order then
				UIUtil.CanvasSlotSetZOrder(self, Order)
				UIUtil.CanvasSlotSetLayout(self, self.FullScreenLayout)
			else
				UIUtil.CanvasSlotSetZOrder(self, self.DefaultZOrder)
				UIUtil.CanvasSlotSetLayout(self, self.DefaultLayout)
			end
		end
		self.Common_Render2D_UIBP.CallBackSetFullScreen = OnSetFullScreenCallBack
	end
end

function CommonRender2DToImageView:OnHide()
	self:Reset()
end

function CommonRender2DToImageView:OnRegisterUIEvent()

end

function CommonRender2DToImageView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(EventID.Avatar_Update_Master, self.OnUpdateMaster)
	self:RegisterGameEvent(EventID.MountAssembleAllEnd, self.OnMountAssembleAllEnd)
end

function CommonRender2DToImageView:OnRegisterBinder()

end

function CommonRender2DToImageView:Reset()
	local RT = self.RenderTexture
	if RT then
		--self:ReleaseRenderTarget(self.RenderTexture)
		local Gamma = self.RawRTGamma 
		if Gamma then
			RT.TargetGamma = Gamma 
		end

		_G.CommonModelToImageMgr:ReleaseRenderTarger2D(RT)
		self.RenderTexture = nil
	end
	if self.IsInitImageMode then
		if self.Common_Render2D_UIBP.RenderActor then
			local CaptureComp2D = self.Common_Render2D_UIBP.RenderActor.SceneCaptureComponent2D
			if CaptureComp2D then
				CaptureComp2D.TextureTarget = nil
				CaptureComp2D.bCaptureEveryFrame = false
				CaptureComp2D:SetVisibility(false)
			end
		end
	end
	self.IsInitImageMode = false
	self.Common_Render2D_UIBP:SwitchOtherLights(true)
	self.CameraFocusCfgMap:SetAssetUserData(nil)
	self.IsCreated = false
	self.DefaultDistance = nil
	self.IsSetDefaultDisUseInterp = nil
	self.DistanceOffset = 0
	self.CallBackRoll = nil
	self.CallBackFOV = nil
	self.IsCreateSuccess = false
	self.IsCreateMountSuccess = false
	self.IsAssembleAllEnd = false
	self.OnCreateSuccessCallBack = nil
	self.OnCreateMountSuccessCallBack = nil
	self.Scale2D = nil
	self.IsHDModel = false
	self.RawRTGamma = nil
	self.ImageRole:SetDrawEffectNoGamma(false)
end

-- ==================================================
-- 内部调用
-- ==================================================

---获取RenderActor的Component
function CommonRender2DToImageView:GetRenderActorComponent(Class)
	local TodSystemMainActor = UE.UEnvMgr:Get():GetTodSystem()
	if TodSystemMainActor then
		return TodSystemMainActor:GetComponentByClass(Class)
	end
	return nil
end

---获取tod天气数据适配器
function CommonRender2DToImageView:GetTodWeatherData()
	if not self.TodSystemMainActor or not CommonUtil.IsObjectValid(self.TodSystemMainActor) then
		self.TodSystemMainActor = UE.UGameplayStatics.GetActorOfClass(FWORLD(), UE.ATodSystemMainActor.StaticClass())
	end
	if self.TodSystemMainActor then
		return  self.TodSystemMainActor.MainWeatherAdapter, self.TodSystemMainActor.FadeWeatherAdapter
	end
end

---设置渲染到Image模式
function CommonRender2DToImageView:SetRenderToImageMode(IsShowImage)
	if self.IsInitImageMode then
		return
	end
	self.IsInitImageMode = true

	local Size = UIUtil.GetWidgetSize(self)
	if Size then
		--self.RenderTexture = self.Common_Render2D_UIBP.RenderActor:RenderToImage(Size.X,  Size.Y)
		--UIUtil.ImageSetMaterialTextureParameterValue(self.ImageRole, "RenderTarget", self.RenderTexture)
		local CaptureComp2D = self.Common_Render2D_UIBP.RenderActor.SceneCaptureComponent2D
		if CaptureComp2D then
			self.RenderTexture, self.Scale2D = _G.CommonModelToImageMgr:CreateRenderTarget2D(self, Size.X, Size.Y, self.IsHDModel)
			CaptureComp2D.TextureTarget = self.RenderTexture
			CaptureComp2D.bCaptureEveryFrame = true

			self.RawRTGamma =  self.RenderTexture.TargetGamma

			CaptureComp2D:SetVisibility(true)
            CaptureComp2D:ClearShowOnlyComponents()
			CaptureComp2D:ShowOnlyActorComponents(self.Common_Render2D_UIBP.UIComplexCharacter)
			UIUtil.ImageSetMaterialTextureParameterValue(self.ImageRole, "RenderTarget", self.RenderTexture)
		end
	end

	UIUtil.SetIsVisible(self.ImageRole, IsShowImage ~= false)

	if self.Scale2D then
		self.ImageRole:SetRenderScale(self.Scale2D)
	end
end

function CommonRender2DToImageView:UpdateRender()
	if not self.IsInitImageMode then
		return
	end
	local CaptureComp2D = self.Common_Render2D_UIBP.RenderActor.SceneCaptureComponent2D
	if CaptureComp2D then
		CaptureComp2D:ClearShowOnlyComponents()
		CaptureComp2D:ShowOnlyActorComponents(self.Common_Render2D_UIBP.UIComplexCharacter)
	end
end

function CommonRender2DToImageView:UpdateAnimLookAtType(Character)
	Character = Character or self.Common_Render2D_UIBP:GetUIComplexCharacter()

	if not Character then
		return
	end

	if not self.IsLookAtWithEye and not self.IsLookAtWithHead then
		Character:UseAnimLookAt(false)
		return
	end

	Character:UseAnimLookAt(true)

	if Character then
		local AnimComp = Character:GetAnimationComponent()
		if AnimComp then
			local AnimInst = AnimComp:GetAnimInstance()
			if AnimInst then
				if self.IsLookAtWithEye and self.IsLookAtWithHead then
					AnimInst:SetLookAtType(2)
				elseif self.IsLookAtWithEye then
					AnimInst:SetLookAtType(1)
				elseif self.IsLookAtWithHead then
					AnimInst:SetLookAtType(4)
				end
			end
		end
	end
end

function CommonRender2DToImageView:UpdateAnimLookAtLimit()
	local Character = self.Common_Render2D_UIBP:GetUIComplexCharacter()
	if Character then
		local AnimComp = Character:GetAnimationComponent()
		if AnimComp then
			local AnimInst = AnimComp:GetAnimInstance()
			if AnimInst and AnimInst.SetLookAtLimit then
				AnimInst:SetLookAtLimit(-60, 0, 60, 0)
			end
		end
	end
end

-- 使用MajorAnim的Lookat
-- LookAtType _G.UE.ELookAtType eg:_G.UE.ELookAtType.Head
-- bKeepCurrent bool 保持当前旋转
-- bAddictive bool 允许多部位不同操作
-- 单部位关闭
function CommonRender2DToImageView:SetMajorAnimLookAtType(ELookAtType, bKeepCurrent, bAddictive, bReset)
	if nil == self.Common_Render2D_UIBP then return end
	local Character = self.Common_Render2D_UIBP:GetUIComplexCharacter()
	local CameraComp = self.Common_Render2D_UIBP:GetCameraComponent()
	if CameraComp and Character then
		--local TargatLocation = CameraComp:GetComponentLocation()
		Character:UpdateLookAtLayer(true)
		local LookAtParams = _G.UE.FLookAtParams()
		LookAtParams.LookAtType = ELookAtType
		LookAtParams.Target.Type = bReset and _G.UE.ELookAtTargetType.None or _G.UE.ELookAtTargetType.SceneComponent
		LookAtParams.Target.Target = CameraComp
		LookAtParams.bKeepCurrent = bKeepCurrent
		LookAtParams.bAddictive = bAddictive
		ActorUtil.SetCharacterLookAtParams(Character, LookAtParams)
	end
end

function CommonRender2DToImageView:OnAssembleAllEnd(Params)
	local EntityID = self:GetActorEntityID()
	if Params.ULongParam1 == EntityID then
		self.Common_Render2D_UIBP:UpdateAllLights()
		self:UpdateRender()

		self.IsAssembleAllEnd = true

		if self.IsCreateSuccess then
			self:ResetCamera()
			self.IsCreateSuccess = false

			if self.OnCreateSuccessCallBack then
				self.OnCreateSuccessCallBack()
				self.OnCreateSuccessCallBack = nil
			end
		end
	end
end

function CommonRender2DToImageView:OnMountAssembleAllEnd(Params)
	if Params.ULongParam1 == 0  then
		if self.IsCreateMountSuccess then
			self.IsCreateMountSuccess = false
			
			if self.OnCreateMountSuccessCallBack then
				self.OnCreateMountSuccessCallBack()
				self.OnCreateMountSuccessCallBack = nil
			end
		end
	end
end

function CommonRender2DToImageView:OnUpdateMaster()
	self:UpdateAnimLookAtType()
	self:UpdateAnimLookAtLimit()
end

-- ==================================================
-- 外部系统调用 镜头相关接口
-- ==================================================

---创建角色
---@param IsImageMode boolean 渲染到Image模式
---@param OnCreateSuccessCallBack function 创建完成回调
---@param IsShowImage boolean Image模式下，是否显示图片，默认true
---@param IsChangeAnim boolean 是否改变Character动画蓝图，默认true
function CommonRender2DToImageView:CreateRenderActor(IsImageMode, OnCreateSuccessCallBack, IsShowImage, IsChangeAnim)
	if self.IsCreated then
		FLOG_ERROR("[CommonRender2DToImageView] had been created")
		return
	end
	self.IsCreated = true
	self.OnCreateSuccessCallBack = OnCreateSuccessCallBack
	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if AvatarComp then
        local AttachType = AvatarComp:GetAttachTypeIgnoreChangeRole()
        local RenderActorPathForRace = string.format(ModelDefine.StagePath.Universe, AttachType, AttachType)
        local CallBack = function(bSucc)
            if self.IsCreated and bSucc then
				local Render2D = self.Common_Render2D_UIBP
                Render2D:SwitchOtherLights(false)
                Render2D:ChangeUIState(false)

                Render2D:SetUICharacterByEntityID(MajorUtil.GetMajorEntityID())
                self.CameraFocusCfgMap:SetAssetUserData(Render2D:GetEquipmentConfigAssetUserData())

                Render2D:EnableRotator(true)
                Render2D:SetCameraFocusScreenLocation(nil, nil, nil, nil)

                local SpringArmRotation = Render2D:GetSpringArmRotation()
                Render2D:SetSpringArmRotation(0, SpringArmRotation.Yaw, SpringArmRotation.Roll, false)
				Render2D:SetModelRotation(0, 0, 0, false)

				local DefaultArmDistance = 0
				if self.DefaultDistance then
					DefaultArmDistance = self.DefaultDistance
				else
					DefaultArmDistance = self.CameraFocusCfgMap:GetSpringArmDistance(AttachType) + self.DistanceOffset
				end
                DefaultArmDistance = Render2D:NormalizeTargetArmLength(DefaultArmDistance)
				Render2D:SetSpringArmDistance(DefaultArmDistance, self.IsSetDefaultDisUseInterp)
				local Location = {X=0, Y= self.CameraFocusCfgMap:GetSpringArmOriginY(AttachType),
									Z = self.CameraFocusCfgMap:GetSpringArmOriginZ(AttachType)}
				Render2D:SetSpringArmLocation(Location.X, Location.Y, Location.Z, false)
				Render2D:SetCameraFOV(self.CameraFocusCfgMap:GetOriginFOV(AttachType))
				Render2D:ResumeAvatar()

				if IsChangeAnim ~= false then
					local Character = self:GetUIComplexCharacter()
					if Character then
						Character:SetAnimClass(LoginConfig.CharacterAnimClass)
					end
				end

				if IsImageMode then
					self:SetRenderToImageMode(IsShowImage)
				end

				self.IsCreateSuccess = true
				--if OnCreateSuccessCallBack then
				--	OnCreateSuccessCallBack()
				--end
            end
        end
        local ReCreateCallBack = function()
            if self.IsCreated then
				self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
			end
        end
        self.Common_Render2D_UIBP:CreateRenderActor(RenderActorPathForRace, EquipmentMgr:GetEquipmentCharacterClass(),
        EquipmentMgr:GetLightConfig(), false, CallBack, ReCreateCallBack)
	end
end

function CommonRender2DToImageView:SetUIRideCharacter(MountID, InCallBack)
	self.IsCreateMountSuccess = true
	self.OnCreateMountSuccessCallBack = InCallBack
	self.Common_Render2D_UIBP:SetUIRideCharacter(MountID)
end

function CommonRender2DToImageView:GetRender2DBP()
	return self.Common_Render2D_UIBP
end

---@deprecated 禁止设置高清模式
function CommonRender2DToImageView:SetHDModel()
	self.IsHDModel = true
end

---设置旋转可全屏操作模式
function CommonRender2DToImageView:SetRotateFullScreenModel()
 	self.IsRotateFullScreenModel = true
end

---开启平移(长按0.5秒拖动平移)
---@param bEnable boolean
function CommonRender2DToImageView:EnableMove(bEnable)
	self.Common_Render2D_UIBP:EnableMove(bEnable)
	--if bEnable then
	--	self.Common_Render2D_UIBP.DefaultFocusLoc = self.Common_Render2D_UIBP:GetSpringArmLocation()
	--end
end

---开始俯仰
---@param bEnable boolean
function CommonRender2DToImageView:EnablePitch(bEnable)
	self.Common_Render2D_UIBP:EnablePitch(bEnable)
end

---开启立即平移（开启后旋转功能会失效）
---@param bEnable boolean
function CommonRender2DToImageView:EnableMoveImmediately(bEnable)
	self.Common_Render2D_UIBP:EnableMoveImmediately(bEnable)
end

---重置相机
function CommonRender2DToImageView:ResetCamera()
	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if AvatarComp then
        local AttachType = AvatarComp:GetAttachTypeIgnoreChangeRole()
		local Rended2D = self.Common_Render2D_UIBP
		Rended2D:SetCameraFocusScreenLocation(nil, nil, nil, nil)
		local SpringArmRotation = Rended2D:GetSpringArmRotation()
		Rended2D:SetSpringArmRotation(0, SpringArmRotation.Yaw, SpringArmRotation.Roll, false)
		Rended2D:SetModelRotation(0, 0, 0, false)
		local DefaultArmDistance = 0
		if self.DefaultDistance then
			DefaultArmDistance = self.DefaultDistance
		else
			DefaultArmDistance = self.CameraFocusCfgMap:GetSpringArmDistance(AttachType) + self.DistanceOffset
		end
		DefaultArmDistance = Rended2D:NormalizeTargetArmLength(DefaultArmDistance)
		Rended2D:SetSpringArmDistance(DefaultArmDistance, self.IsSetDefaultDisUseInterp)
		Rended2D:InitSpringArmEndPos()
		local DefaultFocusLocZ = 0
		if Rended2D.DefaultFocusLoc then
			DefaultFocusLocZ = Rended2D.DefaultFocusLoc.z
		else
			DefaultFocusLocZ = self.CameraFocusCfgMap:GetSpringArmOriginZ(AttachType)
		end
		local Location = {X = 0, Y = Rended2D.CamToTargetRadians * DefaultArmDistance,
						  Z = DefaultFocusLocZ + Rended2D:GetZoomZOffset(DefaultArmDistance)}
		--处理偏移部分
		Rended2D.CamToTargetRadians = self.InitialCamToTargetRadians or 0--恢复初始设置偏移时的参数
		local PosY = Rended2D.CamToTargetRadians * DefaultArmDistance
		Location.Y = PosY
		Rended2D:SetSpringArmLocation(Location.X, Location.Y, Location.Z, false)
		Rended2D:SetCameraFOV(self.CameraFocusCfgMap:GetOriginFOV(AttachType), false)
		Rended2D.SpringArmDistanceTarget = nil
		Rended2D.SpringArmLocationTarget = nil
	end
end

---重置相机位置
---@param Disctance number @传nil则用默认值
function CommonRender2DToImageView:ResetSpringArmLocation(Disctance)
	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if AvatarComp then
		local AttachType = AvatarComp:GetAttachTypeIgnoreChangeRole()
		local Render2D = self.Common_Render2D_UIBP
		local DefaultArmDistance = 0
		if Disctance then
			DefaultArmDistance = Disctance
		else
			if self.DefaultDistance then
				DefaultArmDistance = self.DefaultDistance
			else
				DefaultArmDistance = self.CameraFocusCfgMap:GetSpringArmDistance(AttachType) + self.DistanceOffset
			end
		end
		local DefaultFocusLocZ = 0
		if Render2D.DefaultFocusLoc then
			DefaultFocusLocZ = Render2D.DefaultFocusLoc.z
		else
			DefaultFocusLocZ = self.CameraFocusCfgMap:GetSpringArmOriginZ(AttachType)
		end
		Render2D.CamToTargetRadians = self.InitialCamToTargetRadians or 0--恢复初始设置偏移时的参数
		local Location = {X = 0, Y = Render2D.CamToTargetRadians * DefaultArmDistance,
						Z = DefaultFocusLocZ + Render2D:GetZoomZOffset(DefaultArmDistance)}
		Render2D:SetSpringArmLocation(Location.X, Location.Y, Location.Z, false)
		
		if Render2D.CallBackMove then
			Render2D.CallBackMove(Location.X, Location.Y, Location.Z)
		end
	end
end

---设置左右偏移 负数左边 正数右边
---@param Offset number
function CommonRender2DToImageView:SetOffset(Offset)
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(Offset)
	self.InitialCamToTargetRadians = self.Common_Render2D_UIBP.CamToTargetRadians
	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if AvatarComp then
		local AttachType = AvatarComp:GetAttachTypeIgnoreChangeRole()
		local DefaultArmDistance = 0
		if self.DefaultDistance then
			DefaultArmDistance = self.DefaultDistance
		else
			DefaultArmDistance = self.CameraFocusCfgMap:GetSpringArmDistance(AttachType) + self.DistanceOffset
		end
		DefaultArmDistance = self.Common_Render2D_UIBP:NormalizeTargetArmLength(DefaultArmDistance)
		local PosY = self.Common_Render2D_UIBP.CamToTargetRadians * DefaultArmDistance
		local Location = self.Common_Render2D_UIBP:GetSpringArmLocation()
		Location.Y = PosY
		self.Common_Render2D_UIBP:SetSpringArmLocation(Location.X, Location.Y, Location.Z, false)
	end
end

---设置镜头参数
---@param MinDist number 最小距离
---@param MaxDist number 最大距离
---@param MinFOV number 最小FOV
---@param MaxFOV number 最大FOV
---@param ZoomFocusType number @0=All, 1=Upper, 2=Lower, 3=Face
---@param MinZOffset number @最近上下偏移
---@param MaxZOffset number @最远上下偏移
---@param MinPitchOffset number @最近角度偏移
---@param MaxPitchOffset number @最远角度偏移
---@param MinPitch number @仰视角度
---@param MaxPitch number @俯视角度
function CommonRender2DToImageView:SetCameraControlParams(MinDist, MaxDist, MinFOV, MaxFOV, ZoomFocusType, MinZOffset, MaxZOffset, MinPitchOffset, MaxPitchOffset, MinPitch, MaxPitch)
	local Param = CameraControlParams.New()
	Param.FocusEID = ZoomFocusParam[ZoomFocusType or 1]
	Param.MinViewDistParams.ViewDistance = MinDist or 100
	Param.MinViewDistParams.FOV = MinFOV or 15
	Param.MinViewDistParams.ZOffset = MinZOffset or 0 
	Param.MinViewDistParams.PitchOffset = MinPitchOffset or 0 

	Param.MaxViewDistParams.ViewDistance = MaxDist or 600
	Param.MaxViewDistParams.FOV = MaxFOV or 18
	Param.MaxViewDistParams.ZOffset = MaxZOffset or 0 
	Param.MaxViewDistParams.PitchOffset = MaxPitchOffset or 0 
	Param.MinPitch = MinPitch or 0
	Param.MaxPitch = MaxPitch or 0

	self.Common_Render2D_UIBP:SetCameraControlParams(Param)
end

---设置移动限制参数
---@param MinH number@水平最小值
---@param MaxH number@水平最大值
---@param MinV number@垂直最小值
---@param MaxV number@垂直最大值
function CommonRender2DToImageView:SetMoveLimiParams(MinH, MaxH, MinV, MaxV)
	self.Common_Render2D_UIBP:SetMoveLimiParams(MinH, MaxH, MinV, MaxV)
end

---设置旋转限制参数
---@param MinYaw number@最小角度
---@param MaxYaw number@最大角度
function CommonRender2DToImageView:SetRotateLimitParams(MinYaw, MaxYaw)
	self.Common_Render2D_UIBP:SetRotateLimiParams(MinYaw, MaxYaw)
end

---设置相机距臂的距离偏移值(有歧义弃用)
---@param Val number
function CommonRender2DToImageView:SetDistanceOffset(Val)
	self.DistanceOffset = Val
end

---设置相机距臂默认距离(CreateRenderActor回调前调用)
---@param Val number
---@param Interp boolean 是否开启插值效果（镜头拉近）
function CommonRender2DToImageView:SetDefaultDistance(Val, Interp)
	self.DefaultDistance = Val
	self.IsSetDefaultDisUseInterp = Interp
end

---设置相机距臂当前距离
---@param Val number
---@param Interp boolean 是否开启插值效果（镜头拉近）
function CommonRender2DToImageView:SetSpringArmDistance(Val, Interp)
	if not self.IsAssembleAllEnd and not self.DefaultDistance then
		self.DefaultDistance = Val
	end
	Val = self.Common_Render2D_UIBP:NormalizeTargetArmLength(Val)
	self.Common_Render2D_UIBP:SetSpringArmDistance(Val, Interp or false)

	if self.Common_Render2D_UIBP.CallBackZoom then
		self.Common_Render2D_UIBP.CallBackZoom(Val)
	end
end

---设置相机Roll(CreateRender结束后调用)
---@param Val number@-90~90
function CommonRender2DToImageView:SetCameraRoll(Val)
	Val = math.clamp(Val, -90, 90)
	self.Common_Render2D_UIBP:SetCameraRoll(Val)
	if self.CallBackRoll then
		self.CallBackRoll(Val)
	end
end

function CommonRender2DToImageView:SetSpringArmLocation(InX, InY, InZ, bInterp, InterpVelocity)
	self.Common_Render2D_UIBP:SetSpringArmLocation(InX, InY, InZ, bInterp, InterpVelocity)
end

---设置移动回调
---@param Func function@func(LocationY, LocationZ)
function CommonRender2DToImageView:SetMoveCallBack(Func)
	self.Common_Render2D_UIBP.CallBackMove = Func
end

function CommonRender2DToImageView:SetModelRotation(InPitch, InYaw, InRoll, bInterp)
	self.Common_Render2D_UIBP:SetModelRotation(InPitch, InYaw, InRoll, bInterp)
end

function CommonRender2DToImageView:SetModelPitch(InPitch)
	local Rended2D = self.Common_Render2D_UIBP
	local SpringArmRotation = Rended2D:GetSpringArmRotation()
	Rended2D:SetSpringArmRotation(InPitch, SpringArmRotation.Yaw, SpringArmRotation.Roll, false)
end

---设置旋转回调
---@param Func function@func(Angle)
function CommonRender2DToImageView:SetRotateCallBack(Func)
	self.Common_Render2D_UIBP.CallBackRotate = Func
end

---设置俯仰回调
---@param Func function@func(Angle)
function CommonRender2DToImageView:SetPitchCallBack(Func)
	self.Common_Render2D_UIBP.CallBackPitch = Func
end

---设置缩放回调
---@param Func function@func(Distance)
function CommonRender2DToImageView:SetZoomCallBack(Func)
	self.Common_Render2D_UIBP.CallBackZoom = Func
end

---设置FOV回调
---@param Func function@func(FOV)
function CommonRender2DToImageView:SetFOVCallBack(Func)
	self.CallBackFOV = Func
end

---设置Roll回调
---@param Func function@func()
function CommonRender2DToImageView:SetRollCallBack(Func)
	self.CallBackRoll = Func
end

-- ==================================================
-- 外部系统调用 动画相关接口
-- ==================================================

---设置是否眼睛注视
---@param Flag boolean
function CommonRender2DToImageView:SetUseAnimLookAtWithEye(Flag)
	self.IsLookAtWithEye = Flag
	local Character = self.Common_Render2D_UIBP:GetUIComplexCharacter()
	if Character then
		self:UpdateAnimLookAtType(Character)
	end
end

---设置是否头部注视
---@param Flag boolean
function CommonRender2DToImageView:SetUseAnimLookAtWithHead(Flag)
	self.IsLookAtWithHead = Flag
	local Character = self.Common_Render2D_UIBP:GetUIComplexCharacter()
	if Character then
		self:UpdateAnimLookAtType(Character)
	end
end

-- ==================================================
-- 外部系统调用 灯光相关
-- ==================================================

---获取环境光亮度
---@return number
function CommonRender2DToImageView:GetAmbientLightIntensity()
	local WeatherData = self:GetTodWeatherData()
	if WeatherData then
		return WeatherData.Lighting_AmbientLightScale
	end
	return 0
end

---获取环境光颜色
---@return UE.FLinearColor
function CommonRender2DToImageView:GetAmbientLightColor()
	local WeatherData = self:GetTodWeatherData()
	if WeatherData then
		return WeatherData.Lighting_SkyLightColor
	end
	return UE.FLinearColor(1, 1, 1, 1)
end

---获取方向光亮度
---@return number
function CommonRender2DToImageView:GetDirectionalLightIntensity()
	local WeatherData = self:GetTodWeatherData()
	if WeatherData then
		return WeatherData.Lighting_Intensity
	end
	return 0
end

---获取方向光颜色
---@return UE.FLinearColor
function CommonRender2DToImageView:GetDirectionalLightColor()
	local WeatherData = self:GetTodWeatherData()
	if WeatherData then
		return WeatherData.Lighting_SunlightColor
	end
	return UE.FLinearColor(1, 1, 1, 1)
end

---获取方向光方向
---@return UE.FRotator
function CommonRender2DToImageView:GetDirectionalLightDirection()
	if not self.DirectionalLight or not CommonUtil.IsObjectValid(self.DirectionalLight) then
		self.DirectionalLight = self:GetRenderActorComponent(UE.UDirectionalLightComponent)
	end
	if self.DirectionalLight then
		return self.DirectionalLight:K2_GetComponentRotation()
	end
	return UE.FRotator(0, 0, 0)
end

---设置环境光亮度
---@param Value number
function CommonRender2DToImageView:SetAmbientLightIntensity(Value)
	local WeatherData, FadeWeatherData = self:GetTodWeatherData()
	if WeatherData then
		WeatherData.Lighting_AmbientLightScale = Value
	end
	if FadeWeatherData then
		FadeWeatherData.Lighting_AmbientLightScale = Value
	end
end

---设置环境光RGB
---@param R number@(0~1)
---@param G number@(0~1)
---@param B number@(0~1)
function CommonRender2DToImageView:SetAmbientLightColor(R, G, B)
	local WeatherData, FadeWeatherData = self:GetTodWeatherData()
	if WeatherData then
		WeatherData.Lighting_SkyLightColor = UE.FLinearColor(R, G, B, 1)
	end
	if FadeWeatherData then
		FadeWeatherData.Lighting_SkyLightColor = UE.FLinearColor(R, G, B, 1)
	end
end

---设置方向光亮度
---@param Value number
function CommonRender2DToImageView:SetDirectionalLightIntensity(Value)
	local WeatherData, FadeWeatherData = self:GetTodWeatherData()
	if WeatherData then
		WeatherData.Lighting_Intensity = Value
	end
	if FadeWeatherData then
		FadeWeatherData.Lighting_Intensity = Value
	end
end

---设置方向光RGB
---@param R number@(0~1)
---@param G number@(0~1)
---@param B number@(0~1)
function CommonRender2DToImageView:SetDirectionalLightColor(R, G, B)
	local WeatherData, FadeWeatherData = self:GetTodWeatherData()
	if WeatherData then
		WeatherData.Lighting_SunlightColor = UE.FLinearColor(R, G, B, 1)
	end
	if FadeWeatherData then
		FadeWeatherData.Lighting_SunlightColor = UE.FLinearColor(R, G, B, 1)
	end
end

---设置方向光方向
---@param InPitch number@0~360
---@param InYaw number@0~360
---@param InRoll number@0~360
function CommonRender2DToImageView:SetDirectionalLightDirection(InPitch, InYaw, InRoll)
	if not self.DirectionalLight or not CommonUtil.IsObjectValid(self.DirectionalLight) then
		self.DirectionalLight = self:GetRenderActorComponent(UE.UDirectionalLightComponent)
	end
	if self.DirectionalLight then
		self.DirectionalLight:K2_SetRelativeRotation(UE.FRotator(InPitch, InYaw, InRoll), false, nil, false)
		--self.DirectionalLight:K2_SetWorldRotation(UE.FRotator(Roll, Pitch, Yaw), false, nil, false)
	end
end

-- ==================================================
-- 外部系统调用 装备相关
-- ==================================================

---装备预览
function CommonRender2DToImageView:PreViewEquipment(EquipID, Part, ColorID)
	--FLOG_ERROR("PreViewEquipment: Part="..tostring(Part).." EquipID="..tostring(EquipID).."\n"..debug.traceback())
	if self.Common_Render2D_UIBP.ChildActor then
		local UIComplexCharacter = self.Common_Render2D_UIBP.ChildActor:Cast(UE.AUIComplexCharacter)
		if UIComplexCharacter then
			if EquipID == nil or EquipID == 0 then
				local PosKey = EquipmentDefine.EquipmentTypeMap[Part]
				if PosKey then
					UIComplexCharacter:TakeOffAvatarEquip(PosKey, false)
				else
					local Equip = EquipmentMgr:GetEquipedItemByPart(Part)
					if Equip then
						local EquipCfg = EquipmentCfg:FindCfgByKey(Equip.ResID)
						if EquipCfg then
							UIComplexCharacter:TakeOffAvatarEquip(EquipCfg.EquipmentType, false)
						end
					end
				end
			else
				UIComplexCharacter:HandleAvatarEquip(EquipID, Part, ColorID)
			end
			UIComplexCharacter:StartLoadAvatar()
		end
	end
end

-- 预览装备，bLoadInstantly设为false可只存储数据，暂时不执行模型加载
function CommonRender2DToImageView:PreViewEquipmentEx(EquipID, Part, ColorID, bLoadInstantly)
	if self.Common_Render2D_UIBP.ChildActor then
		local UIComplexCharacter = self.Common_Render2D_UIBP.ChildActor:Cast(UE.AUIComplexCharacter)
		if UIComplexCharacter then
			local AvatarComp = UIComplexCharacter:GetAvatarComponent()
			AvatarComp:UpdateEquipAppearData(Part, EquipID, ColorID)

			if nil == bLoadInstantly or bLoadInstantly then
				AvatarComp:ForceUpdateCurRoleAvatar()
			end
		end
	end
end

---设置素体装备
function CommonRender2DToImageView:SetRoleSimpleEquips()
	if self.Common_Render2D_UIBP.ChildActor then
		local UIComplexCharacter = self.Common_Render2D_UIBP.ChildActor:Cast(UE.AUIComplexCharacter)
		if UIComplexCharacter then
			local RoleSimple = LoginRoleMainPanelVM:GetSelectRoleSimple()
			if RoleSimple and RoleSimple.Avatar then
				local EquipList = RoleSimple.Avatar.EquipList
				for idx = 1, #EquipList do
					local Equip = EquipList[idx]
					local EquipID = WardrobeUtil.GetEquipID(Equip.EquipID, Equip.ResID, Equip.RandomID)
					UIComplexCharacter:PreViewEquipment(EquipID, Equip.Part)
				end
			end
			UIComplexCharacter:ClearDelegateHandle()
		end
	end
end

--清除所有装备
function CommonRender2DToImageView:ClearAllEquips()
	if self.Common_Render2D_UIBP.ChildActor then
		local UIComplexCharacter = self.Common_Render2D_UIBP.ChildActor:Cast(UE.AUIComplexCharacter)
		if UIComplexCharacter then
			for _,Part in pairs(ProtoCommon.equip_part) do
				local PosKey = EquipmentDefine.EquipmentTypeMap[Part]
				if PosKey then
					UIComplexCharacter:TakeOffAvatarEquip(PosKey, false)
				else
					local Equip = EquipmentMgr:GetEquipedItemByPart(Part)
					if Equip then
						local EquipCfg = EquipmentCfg:FindCfgByKey(Equip.ResID)
						if EquipCfg then
							UIComplexCharacter:TakeOffAvatarEquip(EquipCfg.EquipmentType, false)
						end
					end
				end
			end
			UIComplexCharacter:StartLoadAvatar()
			UIComplexCharacter:ClearDelegateHandle()
		end
	end
end

--- 是否隐藏头部（头盔）
--- @param bHide boolean 是否隐藏	
function CommonRender2DToImageView:HideHead(bHide)
	self.Common_Render2D_UIBP:HideHead(bHide)
end

--- 是否隐藏手部（主手和副手武器）
--- @param bHide boolean 是否隐藏	
function CommonRender2DToImageView:HideWeapon(bHide)
	self.Common_Render2D_UIBP:HideWeapon(bHide)
end

-- ==================================================
-- 外部系统调用 拓展
-- ==================================================

function CommonRender2DToImageView:GetUIComplexCharacter()
	return self.Common_Render2D_UIBP:GetUIComplexCharacter()
end

function CommonRender2DToImageView:GetCharacter()
	return self.Common_Render2D_UIBP:GetCharacter()
end

function CommonRender2DToImageView:GetAnimationComponent()
	local Character = self:GetUIComplexCharacter()
	if Character then
		return Character:GetAnimationComponent()
	end
end

function CommonRender2DToImageView:GetEmojiAnimInst()
	local Character = self:GetUIComplexCharacter()
	if Character then
		return Character:GetEmojiAnimInst()
	end
end

function CommonRender2DToImageView:CancelAsyncRoleChange()
	if self.Common_Render2D_UIBP.ChildActor then
		local UIComplexCharacter = self.Common_Render2D_UIBP.ChildActor:Cast(UE.AUIComplexCharacter)
		if UIComplexCharacter then
			UIComplexCharacter:ClearDelegateHandle()
		end
	end
end

function CommonRender2DToImageView:ProjectWorldLocationToScreen(SocketName, ScreenLocation)
    local ChildActor = self.Common_Render2D_UIBP.ChildActor
	if ChildActor then
		local CaptureComp2D = self.Common_Render2D_UIBP.RenderActor.SceneCaptureComponent2D
		if CaptureComp2D then
			local WorldLocation = ChildActor:GetSocketLocationByName(SocketName)
			return UIUtil.ProjectWorldLocationToScreenCaptureScene(CaptureComp2D, WorldLocation, ScreenLocation)
		end
    end
end

function CommonRender2DToImageView:EnableZoom(b)
	self.Common_Render2D_UIBP:EnableZoom(b)
end

function CommonRender2DToImageView:SetCameraFOV(InFOV, bInterp, InterpVelocity)
	if self.IsInitImageMode then
		local CaptureComp2D = self.Common_Render2D_UIBP.RenderActor.SceneCaptureComponent2D
		if CaptureComp2D then
			CaptureComp2D.FOVAngle = InFOV
		end

	else
		self.Common_Render2D_UIBP:SetCameraFOV(InFOV, bInterp, InterpVelocity)
	end

	if self.CallBackFOV then
		self.CallBackFOV(InFOV)
	end
end

function CommonRender2DToImageView:DisableImageGamma() 
	local CaptureComp2D = self.Common_Render2D_UIBP.RenderActor.SceneCaptureComponent2D
	if nil == CaptureComp2D then
		return
	end

	local RT = CaptureComp2D.TextureTarget
	if nil == RT then
		return
	end

	RT.TargetGamma = 2.2
	self.ImageRole:SetDrawEffectNoGamma(true)
end

function CommonRender2DToImageView:SetCameraCaptureSource(Source) 
	local CaptureComp2D = self.Common_Render2D_UIBP.RenderActor.SceneCaptureComponent2D
	if CaptureComp2D then
		CaptureComp2D.CaptureSource = Source 
	end
end


function CommonRender2DToImageView:UpdateFocusLocation()
	self.Common_Render2D_UIBP:UpdateFocusLocation()
end

function CommonRender2DToImageView:GetActorEntityID()
	local Character = self.Common_Render2D_UIBP:GetUIComplexCharacter()
	if nil == Character then
		return
	end

	return Character:GetActorEntityID()
end

--- 设置是否屏蔽动作LookAt模式通知影响
--- @param bIgnore boolean 是否屏蔽
function CommonRender2DToImageView:SetBlockActionLookAtModeNotice(bIgnore)
	local Character = self:GetUIComplexCharacter()
	if Character then
		Character:SetIgnoreLookAtMode(bIgnore == true)
	end
end

return CommonRender2DToImageView