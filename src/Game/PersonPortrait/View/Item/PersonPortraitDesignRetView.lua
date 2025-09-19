---
--- Author: xingcaicao
--- DateTime: 2023-11-29 12:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MathUtil = require("Utils/MathUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local PortraitDesignCfg = require("TableCfg/PortraitDesignCfg")
local PersonPortraitUtil = require("Game/PersonPortrait/PersonPortraitUtil")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local WeatherDefine = require("Game/Weather/WeatherDefine")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ActorUtil = require("Utils/ActorUtil")

local MinDistance = PersonPortraitDefine.MinDistance
local MaxDistance = PersonPortraitDefine.MaxDistance
local MinFOV = PersonPortraitDefine.MinFOV
local MaxFOV = PersonPortraitDefine.MaxFOV
local MinRotate = PersonPortraitDefine.MinRotate
local MaxRotate = PersonPortraitDefine.MaxRotate
local MinPitch = PersonPortraitDefine.MinPitch
local MaxPitch = PersonPortraitDefine.MaxPitch

local EquipParts = ProtoCommon.equip_part
local DesignerType = ProtoCommon.DesignerType
local FVector2D = _G.UE.FVector2D
local FLOG_INFO = _G.FLOG_INFO
local ELookAtType = _G.UE.ELookAtType

local SCS_FinalColorLDRHasAlpha = _G.UE.ESceneCaptureSource.SCS_FinalColorLDRHasAlpha or 3

---@class PersonPortraitDesignRetView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DesignPanel UFCanvasPanel
---@field ImgBg UFImage
---@field ImgDecoration UFImage
---@field ImgFrame UFImage
---@field ModelToImage CommonRender2DToImageView
---@field PartOnePanel UFCanvasPanel
---@field PartTwoPanel UFCanvasPanel
---@field WarningPanel UFCanvasPanel
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitDesignRetView = LuaClass(UIView, true)

function PersonPortraitDesignRetView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DesignPanel = nil
	--self.ImgBg = nil
	--self.ImgDecoration = nil
	--self.ImgFrame = nil
	--self.ModelToImage = nil
	--self.PartOnePanel = nil
	--self.PartTwoPanel = nil
	--self.WarningPanel = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitDesignRetView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ModelToImage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitDesignRetView:OnInit()
	self.Binders = {
		{ "DecorateVisible", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedDecorateVisible) },
		{ "CurSelectBgID", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedBgID) },
		{ "CurSelectDecorateID", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedDecorationID) },
		{ "CurSelectFrameID", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedFrameID) },
		{ "IsPositionValid", 		UIBinderSetIsVisible.New(self, self.WarningPanel, true) },
	}
end

function PersonPortraitDesignRetView:OnDestroy()

end

function PersonPortraitDesignRetView:OnShow()
	PersonPortraitVM.ScreenshotWidget = self.DesignPanel

	self.bIsInitialized = false 
	self.IsCheckPositionsIsValid = false

	UIUtil.SetIsVisible(self.ModelToImage.ImageRole, false)

	--天气灯光 add by sammrli
	_G.LightMgr:EnableUIWeather(WeatherDefine.SystemID.PersonSystem)
	_G.LightMgr:SetWeatherTickEnable(false)
end

function PersonPortraitDesignRetView:OnHide()
	self.bIsInitialized = false
	self.IsCheckPositionsIsValid = false
	self.IsAnimInPlayed = false

	_G.LightMgr:DisableUIWeather()
	_G.LightMgr:SetWeatherTickEnable(true)
end

function PersonPortraitDesignRetView:OnRegisterUIEvent()

end

function PersonPortraitDesignRetView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PersonPortraitGetDataSuc, self.OnEventGetPortraitDataSuc)
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
end

function PersonPortraitDesignRetView:OnRegisterBinder()
	self:RegisterBinders(PersonPortraitVM, self.Binders)
end

function PersonPortraitDesignRetView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.5, 0)
end

function PersonPortraitDesignRetView:OnTimer()
	if self.IsCheckPositionsIsValid then
		self.IsCheckPositionsIsValid = false

		self:CheckPositionsIsValid()

		local CurTime = os.time() 
		local LastTime = self.RotateTipsTime or 0
		if CurTime - LastTime >= 3 then
			local Rotate = PersonPortraitVM.CurModelEditVM.Rotate
			if Rotate <= MinRotate or Rotate >= MaxRotate then
				MsgTipsUtil.ShowTips(_G.LSTR(60029)) -- "已旋转到最大角度"

				self.RotateTipsTime = CurTime
			end
		end
	end

	local Ref = self.ShowRoleImgRef or -1 
	if Ref >= 0 then
		if Ref == 0 then 
			UIUtil.SetIsVisible(self.ModelToImage.ImageRole, true)
		end

		self.ShowRoleImgRef = Ref - 1
	end
end

function PersonPortraitDesignRetView:InitModel()
	local ModelToImage = self.ModelToImage

    ModelToImage:CreateRenderActor(true, function()
		ModelToImage:SetCameraCaptureSource(SCS_FinalColorLDRHasAlpha)
		ModelToImage:DisableImageGamma()
		ModelToImage:SetBlockActionLookAtModeNotice(true)

		--self:UpdateModelEquipments()
		self.bIsInitialized = true

		self:UpdateModelData()
		---更新模型装备,UpdateModelServerData会设置一次装备显隐，清空颜色，把装备设置放在后面来
		self:UpdateModelEquipments()
		self.ShowRoleImgRef = 1
    end, false, false)

	local MaxZOffset = PersonPortraitUtil.GetDefaultFarZOffset()
	local MaxPitchOffset = PersonPortraitUtil.GetDefaultFarPitchOffset()
	ModelToImage:SetCameraControlParams(MinDistance, MaxDistance, MinFOV, MaxFOV, 3, nil, MaxZOffset, nil, MaxPitchOffset, MinPitch, MaxPitch)

	-- 缩放
	ModelToImage:SetZoomCallBack(function(Distance)
		if self.bIsInitialized then
			PersonPortraitVM.CurModelEditVM:SetDistance(math.floor(Distance))
			self.IsCheckPositionsIsValid = true 
		end
	end)

	-- 缩放FOV
	ModelToImage:SetFOVCallBack(function(FOV)
		if self.bIsInitialized then
			PersonPortraitVM.CurModelEditVM:SetFOV(math.floor(PersonPortraitUtil.FOV2SliderValue(FOV)))
			self.IsCheckPositionsIsValid = true 
		end
	end)

	-- 旋转
	ModelToImage:SetRotateCallBack(function(Angle)
		if self.bIsInitialized then
			PersonPortraitVM.CurModelEditVM:SetRotate(MathUtil.Round(Angle, 2))
			self.IsCheckPositionsIsValid = true 
		end
	end)

	-- 俯仰 
	ModelToImage:SetPitchCallBack(function(Pitch)
		if self.bIsInitialized then
			PersonPortraitVM.CurModelEditVM:SetPitch(MathUtil.Round(Pitch, 2))
			self.IsCheckPositionsIsValid = true 
		end
	end)

	-- 移动
	ModelToImage:SetMoveCallBack(function(x, y, z)
		if self.bIsInitialized then
			x = MathUtil.Round(x, 2) 
			y = MathUtil.Round(y, 2) 
			z = MathUtil.Round(z, 2) 

			PersonPortraitVM.CurModelEditVM:SetMove(x, y, z)
			self.IsCheckPositionsIsValid = true 
		end
	end)

	-- 相机滚动 
	ModelToImage:SetRollCallBack(function(Roll)
		if self.bIsInitialized then
			PersonPortraitVM.CurModelEditVM:SetRoll(Roll)
			self.IsCheckPositionsIsValid = true 
		end
	end)
end

function PersonPortraitDesignRetView:UpdateModelData()
	local ModelToImage = self.ModelToImage
	local CurModelEditVM = PersonPortraitVM.CurModelEditVM

	-- 武器
	ModelToImage:HideWeapon(CurModelEditVM.IsHideWeapon)

	-- 帽子
	ModelToImage:HideHead(CurModelEditVM.IsHideHat)

	---面向镜头/取消面向镜头、看向镜头/取消看向镜头(视线)
	self:UpdateLookAtType(CurModelEditVM.IsFace, CurModelEditVM.IsLook)

	-- 缩放
	ModelToImage:SetSpringArmDistance(CurModelEditVM.Distance)
	ModelToImage:SetCameraFOV(PersonPortraitUtil.SliderValue2CameraFOV(CurModelEditVM.FOV))

	-- 旋转
	ModelToImage:SetRotateLimitParams(MinRotate, MaxRotate)
	ModelToImage:SetModelRotation(0, CurModelEditVM.Rotate, 0, false)

	-- 俯仰
	ModelToImage:EnablePitch(true)
	ModelToImage:SetModelPitch(CurModelEditVM.Pitch)

	-- 滚动
	ModelToImage:SetCameraRoll(CurModelEditVM.Roll)

	-- 平移
	local X, Y, Z = table.unpack(CurModelEditVM.Move)
	ModelToImage:SetSpringArmLocation(X, Y, Z, false)

	-- 环境光
	local Color = CurModelEditVM.AmbientLightColor
	ModelToImage:SetAmbientLightColor(PersonPortraitUtil.NormalizedColor(table.unpack(Color)))

	local Intensity = PersonPortraitUtil.NormalizedIntensity(CurModelEditVM.AmbientLightIntensity)
	ModelToImage:SetAmbientLightIntensity(Intensity)

	-- 方向光
	Color = CurModelEditVM.DirectLightColor
	ModelToImage:SetDirectionalLightColor(PersonPortraitUtil.NormalizedColor(table.unpack(Color)))

	Intensity = PersonPortraitUtil.NormalizedIntensity(CurModelEditVM.DirectLightIntensity)
	ModelToImage:SetDirectionalLightIntensity(Intensity)

	-- 灯光方向
	local Dir = CurModelEditVM.DirectLightDir
	PersonPortraitUtil.SetDirectionalLightDir(ModelToImage, Dir[1] or 0, Dir[2] or 0)

	local ParentView = self.ParentView
	if ParentView then
		-- 播放动作
		local ActionID = PersonPortraitVM:GetPortraitSrcSetResID(DesignerType.DesignerType_Action)
		ParentView:PlayAction(ActionID, CurModelEditVM.ActionPostion)

		-- 播放表情
		local EmotionID = PersonPortraitVM:GetPortraitSrcSetResID(DesignerType.DesignerType_Emotion)
		ParentView:PlayEmotion(EmotionID)
	end

	self.IsCheckPositionsIsValid = true 
end

function PersonPortraitDesignRetView:OnValueChangedDecorateVisible(Value)
	UIUtil.SetIsVisible(self.PartOnePanel, Value)
	UIUtil.SetIsVisible(self.PartTwoPanel, Value)

	if Value then
		self:OpenClipping()
	else
		self:CloseClipping()
	end
end

function PersonPortraitDesignRetView:OnValueChangedBgID()
	self:SetIcon(self.ImgBg, DesignerType.DesignerType_BackGround)
end

function PersonPortraitDesignRetView:OnValueChangedDecorationID()
	self:SetIcon(self.ImgDecoration, DesignerType.DesignerType_Decoration)
end

function PersonPortraitDesignRetView:OnValueChangedFrameID()
	self:SetIcon(self.ImgFrame, DesignerType.DesignerType_Decoration_Frame)
end

function PersonPortraitDesignRetView:OnAnimationAnimInFinished()
	self.IsAnimInPlayed = true
end

--- 更新模型装备
function PersonPortraitDesignRetView:UpdateModelEquipments()
	local EquipList = PersonPortraitVM.CurEquipList
	if nil == EquipList then
		return
	end

	local ModelToImage = self.ModelToImage
	local UIComplexCharacter = ModelToImage:GetUIComplexCharacter()
	if nil == UIComplexCharacter then
		return
	end

	for _, v in pairs(EquipParts) do
		if v > 0 then
			local EquipAvatar = table.find_by_predicate(EquipList, function(e) return e.Part == v end) or {}
			local EquipID = WardrobeUtil.GetEquipID(EquipAvatar.EquipID, EquipAvatar.ResID, EquipAvatar.RandomID)

			ModelToImage:PreViewEquipmentEx(EquipID, v, EquipAvatar.ColorID, false)
			ActorUtil.UpdateEquipRegionDyes(UIComplexCharacter, v, EquipList)
		end
	end

	local AvatarComp = UIComplexCharacter:GetAvatarComponent()
	if AvatarComp then
		AvatarComp:ForceUpdateCurRoleAvatar()
		AvatarComp:SetForcedLODForAll(1)
	end
end

function PersonPortraitDesignRetView:SetIcon(Img, Type)
    local ResID = PersonPortraitVM:GetCurSelectResID(Type)
	if ResID and ResID ~= 0 then
		if PersonPortraitVM:IsSecretAndLocked(ResID) then
			return
		end

	else
		ResID = PersonPortraitVM:GetPortraitSrcSetResID(Type)
	end
	if ResID then
		---肖像框资源过期后，服务器会清理掉，PersonPortraitVM:GetPortraitSrcSetResID可能拿到空，添加判空
		local Cfg = PortraitDesignCfg:FindCfgByKey(ResID)
		if Cfg then
			local Icon = PersonPortraitUtil.GetDesignIconPath(Cfg.Icon)
			if not string.isnilorempty(Icon) then
				UIUtil.SetIsVisible(Img, true)
				UIUtil.ImageSetBrushFromAssetPath(Img, Icon)

				return
			end
		end
	end

	UIUtil.SetIsVisible(Img, false)
end

function PersonPortraitDesignRetView:CheckPositionsIsValid()
	if not self.IsAnimInPlayed then
		return
	end

	if not self.IsNotFirstCheck then
		self.ScreenPosEyeL = FVector2D(0, 0)
		self.ScreenPosEyeR = FVector2D(0, 0)

		self:CalculateCaptureRect()

		self.IsNotFirstCheck = true
	end

	local IsValid = true

	-- 左眼
	if self.ModelToImage:ProjectWorldLocationToScreen("EID_EYE_L", self.ScreenPosEyeL) then
		IsValid = IsValid and self:IsCaptureRectInside(self.ScreenPosEyeL)
	end

	-- 右眼
	if IsValid and self.ModelToImage:ProjectWorldLocationToScreen("EID_EYE_R", self.ScreenPosEyeR) then
		IsValid = IsValid and self:IsCaptureRectInside(self.ScreenPosEyeR)
	end

	PersonPortraitVM:UpdateIsPositionValid(IsValid)
end

function PersonPortraitDesignRetView:CalculateCaptureRect()
	local SrcLocalPos = UIUtil.CanvasSlotGetPosition(self.DesignPanel)
	local ViewportPos = UIUtil.LocalToViewport(self, SrcLocalPos)
	local LocalPos = UIUtil.ViewportToLocal(self.ModelToImage, ViewportPos) 
	local X = LocalPos.X
	local Y = LocalPos.Y

	local RectSize = UIUtil.GetWidgetSize(self.DesignPanel)
	local RTSize = UIUtil.GetWidgetSize(self.ModelToImage)
	local RTWidth = RTSize.X
	local RTHight = RTSize.Y

	self.CaptureRectMin = FVector2D(X / RTWidth, Y / RTHight)
	self.CaptureRectMax = FVector2D((X+RectSize.X) / RTWidth, (Y+RectSize.Y) / RTHight)
end

function PersonPortraitDesignRetView:IsCaptureRectInside(Position)
	local RectMin = self.CaptureRectMin
	local RectMax = self.CaptureRectMax
	if nil == RectMin or nil == RectMax then
		return false 
	end

	local X = Position.X
	local Y = Position.Y
	return (X >= RectMin.X) and (X <= RectMax.X) and (Y >= RectMin.Y) and (Y <= RectMax.Y)
end

function PersonPortraitDesignRetView:GetCommonRender2DToImageView()
	return self.ModelToImage
end

function PersonPortraitDesignRetView:IsModelLoading()
	return UIUtil.IsVisible(self.ModelToImage.ImageRole) ~= true 
end

function PersonPortraitDesignRetView:UpdateLookAtType(IsFace, IsLook)
	if IsFace == IsLook then
		self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.HeadAndEye, not IsFace, false)

	else
		if IsFace then
			self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.Head, false, false)
			self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.Eye, true, true)

		elseif IsLook then
			self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.Head, true, false)
			self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.Eye, false, true)
		end
	end
end

function PersonPortraitDesignRetView:ResetLookAtType(IsFace, IsLook)
	if IsFace == IsLook then
		self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.None, false, false)
	else
		if IsFace then
			self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.Head, false, false)
			self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.Eye, false, true, true) -- 重置eye
		elseif IsLook then
			self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.Eye, false, false)
			self.ModelToImage:SetMajorAnimLookAtType(ELookAtType.Head, false, true, true) -- 重置head
		end
	end
end
-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function PersonPortraitDesignRetView:OnEventGetPortraitDataSuc(IsSaveQueryCallback)
	if IsSaveQueryCallback then
		return
	end

	if not self.bIsInitialized then
		-- 初始化模型
		self:InitModel()

	else
		UIUtil.SetIsVisible(self.ModelToImage.ImageRole, false)
        self:UpdateModelEquipments()
	end

	-- 背景
	self:SetIcon(self.ImgBg, DesignerType.DesignerType_BackGround)

	-- 装饰 
	self:SetIcon(self.ImgDecoration, DesignerType.DesignerType_Decoration)

	-- 装饰框 
	self:SetIcon(self.ImgFrame, DesignerType.DesignerType_Decoration_Frame)
end

function PersonPortraitDesignRetView:OnAssembleAllEnd(Params)
	if not self.bIsInitialized then
		FLOG_INFO("PersonPortraitDesignRetView:OnAssembleAllEnd, The model creation is not complete")
		return
	end

	if Params and Params.ULongParam1 == self.ModelToImage:GetActorEntityID() then
		FLOG_INFO("PersonPortraitDesignRetView:OnAssembleAllEnd, UpdateModelData")
		self:UpdateModelData()

		self.ShowRoleImgRef = 1
	end
end

return PersonPortraitDesignRetView