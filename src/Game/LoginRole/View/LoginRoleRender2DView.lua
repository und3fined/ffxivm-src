---
--- Author: chriswang
--- DateTime: 2023-02-21 16:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local LoginConfig = require("Define/LoginConfig")

-- local EmotionCfg = require("TableCfg/EmotionCfg")
-- local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
-- local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")

local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")
local CameraControlDataLoader = require("Game/Common/Render2d/CameraControlDataLoader")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")

---@class LoginRoleRender2DView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonSceneMaskBkg_UIBP CommonSceneMaskBkgView
---@field Common_Render2D_UIBP CommonRender2DView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginRoleRender2DView = LuaClass(UIView, true)

function LoginRoleRender2DView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonSceneMaskBkg_UIBP = nil
	--self.Common_Render2D_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginRoleRender2DView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonSceneMaskBkg_UIBP)
	self:AddSubView(self.Common_Render2D_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginRoleRender2DView:OnInit()
	self.CameraCtrlDataLoader = CameraControlDataLoader.New()
	self.FocusType = CameraControlDefine.FocusType.WholeBody
	-- self.IsDebugMode = false
	self.bIgnoreAssember = false
end

function LoginRoleRender2DView:OnDestroy()

end

function LoginRoleRender2DView:OnShow()
	FLOG_INFO("LoginRoleRender2DView:OnShow")
	_G.LoginUIMgr.Common_Render2D_UIBP = self.Common_Render2D_UIBP
	self.Common_Render2D_UIBP.bLogin = true
	_G.LoginUIMgr.Render2DView = self
	self.Common_Render2D_UIBP:SetCanRotate(true)

	UIUtil.CanvasSlotSetZOrder(self.Object, 0)
	self:RefreshBG()
end

function LoginRoleRender2DView:OnHide()
	FLOG_INFO("LoginRoleRender2DView:OnHide")
	self.CameraCtrlDataLoader:SetUserData(nil)
	_G.LoginUIMgr.Common_Render2D_UIBP = nil
	_G.LoginUIMgr.Render2DView = nil

	-- self.Common_Render2D_UIBP:SwitchOtherLights(true)
end

function LoginRoleRender2DView:OnRegisterUIEvent()

end

function LoginRoleRender2DView:RefreshBG()
	if not _G.LoginMapMgr:IsSelectRoleMap() then
		UIUtil.SetIsVisible(self.CommonSceneMaskBkg_UIBP, true)
	else
		UIUtil.SetIsVisible(self.CommonSceneMaskBkg_UIBP, false)
	end
end

function LoginRoleRender2DView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(_G.EventID.Avatar_Update_Master, self.OnUpdateMaster)
	self:RegisterGameEvent(_G.EventID.LoginCreateCameraChange, self.OnUpdateCameraFocus)
end

function LoginRoleRender2DView:OnRegisterBinder()

end

function LoginRoleRender2DView:CreateRenderActor(AttachType, RaceCfg, bReadAvatarRecord)
	self.AttachType = AttachType
	-- self.IsDebugMode = false
	_G.LoginUIMgr:SetRenderActorCreated(false)
	self:RefreshBG()

	--根据种族取对应的RenderActor
	local RenderActorPathForRace = string.format(LoginConfig.RenderActorPath, AttachType, AttachType)

    local CallBack = function(bSucc)
        if (bSucc) then
			FLOG_INFO("LoginRoleRender2DView:CreateRenderActor CallBack")
			
			local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
			if not ChildActor then
				FLOG_ERROR("CreateRenderActor ChildActor is nil")
				return
			end

			-- self.VignetteIntensityDefaultValue = self.Common_Render2D_UIBP:GetPostProcessVignetteIntensity()
			-- self.Common_Render2D_UIBP:SwitchOtherLights(false)
            -- self.Common_Render2D_UIBP:ChangeUIState(false)
            _G.LoginUIMgr:SetUICharacterByRaceCfg(RaceCfg)
			_G.LoginUIMgr:SetEquipByRoleSimple()
			_G.LoginUIMgr:UpdateRoleFacePreset(bReadAvatarRecord)
			-- self.CameraCtrlDataLoader:SetUserData(self.Common_Render2D_UIBP:GetCameraControlAssetUserData())
            -- self:SetModelSpringArmToDefault(true)
			
			local CamControlParams = self.CameraCtrlDataLoader:GetCameraControlParams(self.AttachType, self.FocusType)
			self.Common_Render2D_UIBP:SetCameraControlParams(CamControlParams)
			self.CamControlParams = CamControlParams

			-- if self.LastArmDistance then
			-- 	self.Common_Render2D_UIBP:SetSpringArmCompArmLength(self.LastArmDistance)
			-- 	if self.FocusType then
			-- 		self:ChangeFocusType(self.FocusType)
			-- 	end
			-- end
        end
    end

	local ReCreateCallBack = function()
		FLOG_INFO("LoginRoleRender2DView:CreateRenderActor ReCreateCallBack")
		-- local UserData = self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData()
		-- self.IsDebugMode = true
		_G.LoginUIMgr.RoleWearSuitCfg = nil
		_G.LoginUIMgr:SetUICharacterByRaceCfg(RaceCfg)
		_G.LoginUIMgr:SetEquipByRoleSimple()
		_G.LoginUIMgr:UpdateRoleFacePreset(bReadAvatarRecord)
		
		local CamControlParams = self.CameraCtrlDataLoader:GetCameraControlParams(self.AttachType, self.FocusType)
		self.Common_Render2D_UIBP:SetCameraControlParams(CamControlParams)
		self.CamControlParams = CamControlParams
    end

	if _G.LoginMapMgr:IsNeedShadowActorMap() then
		self.Common_Render2D_UIBP.bCreateShandowActor = true
		if not _G.LoginMapMgr:IsSelectRoleMap() then
			self.Common_Render2D_UIBP:SetShadowActorType(ActorUtil.ShadowType.LoginRole)
		else
			self.Common_Render2D_UIBP:SetShadowActorType(ActorUtil.LoginStarry)
		end
		self.Common_Render2D_UIBP:SetShadowActorPos(_G.UE.FVector(0, 0, 2))
	else
		self.Common_Render2D_UIBP:SetShadowActorPos(nil)
		self.Common_Render2D_UIBP.bCreateShandowActor = false
	end

	local LightPresetPath = _G.LoginMapMgr:GetLightPresetPath()
    self.Common_Render2D_UIBP:CreateRenderActor(RenderActorPathForRace, 
		LoginConfig.CharacterClass, LightPresetPath, false, CallBack
		, ReCreateCallBack)

	self.Common_Render2D_UIBP:UpdateAllLights()
end

function LoginRoleRender2DView:ClearPreView()
	self.PreViewMap = {}
	self.Common_Render2D_UIBP:ResumeAvatar()
end

function LoginRoleRender2DView:SetModelSpringArmToDefault(bInterp)
	-- self.Common_Render2D_UIBP:EnableRotator(true)
	self.Common_Render2D_UIBP:SetCameraFocusScreenLocation(nil, nil, nil, nil)

	local SpringArmRotation = self.Common_Render2D_UIBP:GetSpringArmRotation()
	self.Common_Render2D_UIBP:SetSpringArmRotation(0, SpringArmRotation.Yaw, SpringArmRotation.Roll, true)
	self.Common_Render2D_UIBP:SetModelRotation(0, 0 , 0, true)

	-- FLOG_WARNING("======Login DistanceTarget: %f ======(x:%f, y:%f, z:%f) bInterp:%s", self.LastArmDistance
	-- 	, self.LastArmOriginX, self.LastArmOriginY, self.LastArmOriginZ, tostring(bInterp))

	-- self.Common_Render2D_UIBP:SetCameraFOV(self.CameraFocusCfgMap:GetOriginFOV(self.AttachType))
	-- self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self:ClearPreView()
end

--装备界面角色拼装完成
function LoginRoleRender2DView:OnAssembleAllEnd(Params)
	local EntityID = Params.ULongParam1
	if EntityID > 0 then
		return
	end
	
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	if ChildActor then
		self.Common_Render2D_UIBP:UpdateAllLights()
		
		local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
		if UIComplexCharacter then
			--UIComplexCharacter:SetAnimClass(LoginConfig.CharacterAnimClass)
			UIComplexCharacter:GetAvatarComponent():SetForcedLODForAll(1)
			-- FLOG_ERROR("Login SetForcedLODForAll 1")

			local CurTime = _G.TimeUtil.GetServerTimeMS()
			UIComplexCharacter:GetAvatarComponent():WaitForTextureMips()
			FLOG_INFO("LoginRoleRender2DView OnAssembleAllEnd WaitForTextureMips end Cost:%d", _G.TimeUtil.GetServerTimeMS() - CurTime)
			
			if _G.LoginUIMgr:GetFeedbackAnimType() > 0 then
				_G.LoginUIMgr:PlayFeedbackAnim()
				_G.LoginUIMgr:SetFeedbackAnimType(0)
			end

			_G.LoginUIMgr:OnUIComplexCharacterLoaded(UIComplexCharacter)

			if self.FocusType and not self.bIgnoreAssember then
				self:ChangeFocusType(self.FocusType)
			end

			-- self.IsDebugMode = false
			-- local RaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
			-- if RaceCfg then
			-- 	local EmotionCfg = EmotionCfg:FindCfgByKey(RaceCfg.EnterAnimID)
			-- 	if EmotionCfg then
			-- 		local AnimPath = EmotionAnimUtils.GetActorEmotionAnimPath(EmotionCfg.AnimPath
			-- 							, UIComplexCharacter, EmotionDefines.AnimType.EMOT)
			-- 		local Render2DView = _G.LoginUIMgr:GetCommonRender2DView()
			-- 		if Render2DView then
			-- 			Render2DView:PlayAnyAsMontage(AnimPath, "WholeBody", nil, nil, "")
			-- 		end
			-- 	end
			-- end
		end
		_G.LoginUIMgr:SetRenderActorCreated(true)
		_G.LoginAvatarMgr:ResetSpringArm()
	end
end

function LoginRoleRender2DView:OnUpdateMaster(Params)
	if Params.IntParam1 == _G.UE.EActorType.UIActor then
		local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
		if UIComplexCharacter then
			UIComplexCharacter:SetAnimClass(LoginConfig.CharacterAnimClass)
		end
	end
end

function LoginRoleRender2DView:Reset()
	self.bIgnoreAssember = false
end

function LoginRoleRender2DView:ResetCamera(bInterp)
	if self.FocusType then
		-- self:ChangeFocusType(self.FocusType, bInterp)
		local CamControlParams = self.CameraCtrlDataLoader:GetCameraControlParams(self.AttachType, self.FocusType)
		self.Common_Render2D_UIBP:SetCameraControlParams(CamControlParams)
		self.CamControlParams = CamControlParams

		self.Common_Render2D_UIBP:UpdateFocusLocation()
		self.Common_Render2D_UIBP:ResetViewDistance(bInterp)
	end
end

function LoginRoleRender2DView:ChangeFocusType(InFocusType)
	FLOG_WARNING("Login ChangeFocusType:%d", InFocusType)
	local bBackToBody = false
	if self.FocusType ~= InFocusType and InFocusType == CameraControlDefine.FocusType.WholeBody then
		bBackToBody = true
	end

	self.FocusType = InFocusType
	
	local CamControlParams = self.CameraCtrlDataLoader:GetCameraControlParams(self.AttachType, self.FocusType)
	self.Common_Render2D_UIBP:SetCameraControlParams(CamControlParams)
	self.CamControlParams = CamControlParams

	self.Common_Render2D_UIBP:UpdateFocusLocation()

	-- if self.LastArmDistance then
	-- 	self.Common_Render2D_UIBP:SetSpringArmCompArmLength(self.LastArmDistance)
	-- end

	self.Common_Render2D_UIBP:ResetViewDistance()

	if bBackToBody then
		local Rotation = self.Common_Render2D_UIBP:GetSpringArmRotation()
		if Rotation.Pitch > CamControlParams.MaxPitch then
			self.Common_Render2D_UIBP:SetSpringArmRotation(CamControlParams.MaxPitch, -180, 0, true, 4)
		end
	end

	-- if self.CamControlParams then
	-- 	self.LastArmDistance = self.CamControlParams.DefaultViewDistance
	-- end
end

function LoginRoleRender2DView:OnUpdateCameraFocus(FocusParam)
	self.bIgnoreAssember = FocusParam.bIgnoreAssember
	
	if _G.LoginUIMgr.RenderActorCreated == false then
		self.bIgnoreAssember = false
	end

	local InFocusType = FocusParam.FocusType
	if InFocusType ~= nil then
		self:ChangeFocusType(InFocusType)
	end
	self.FocusType = InFocusType
end

return LoginRoleRender2DView