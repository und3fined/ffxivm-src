---
--- Author: zimuyi
--- DateTime: 2025-02-24 19:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local ActorUtil = require("Utils/ActorUtil")
local AnimMgr = require("Game/Anim/AnimMgr")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")
local CameraUtil = require("Game/Common/Camera/CameraUtil")
local CommonUtil = require("Utils/CommonUtil")
local CompanionCfg = require("TableCfg/CompanionCfg")
local CompanionGlobalCfg = require("TableCfg/CompanionGlobalCfg")
local CompanionMgr = require("Game/Companion/CompanionMgr")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local EquipmentCameraControlDataLoader = require("Game/Equipment/EquipmentCameraControlDataLoader")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local EquipmentDefine = require("Game/Equipment/EquipmentDefine")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local MathUtil = require("Utils/MathUtil")
local ModelPreviewCameraControlDataLoader = require("Game/Preview/ModelPreviewCameraControlDataLoader")
local ModelPreviewSubstituteCfg = require("TableCfg/ModelPreviewSubstituteCfg")
local ObjectMgr = require("Object/ObjectMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local RideCfg = require("TableCfg/RideCfg")
local SystemLightCfg = require("TableCfg/SystemLightCfg")
local UIUtil = require("Utils/UIUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local UE = _G.UE
local UnLua = _G.UnLua
local EquipmentType = ProtoRes.EquipmentType

local RenderActorPathFormat = "Class'/Game/UI/Render2D/StoreRender/BP_Render2DLoginActor_%s.BP_Render2DLoginActor_%s_C'"
local CloseUpViewPathFormat = "CloseUpViewDataAsset'/Game/UI/Render2D/StoreRender/CloseUpViewConfig/DA_CloseUpView_%s.DA_CloseUpView_%s'"
local DefaultLightPresetPath = "LightPreset'/Game/UI/Render2D/LightPresets/Login/UniversalLightingPreset/UniversalLightingPreset01.UniversalLightingPreset01'"
local LightPresetType =
{
	Common = 1,
	Roegadyn = 2,
	Lalafell = 3,
}

local RenderActorCreateCallbackType =
{
	ModelSwitch = 1, -- 身体模型切换
	PlayEmotion = 2, -- 播放情感动作
}

local CompanionInteractActionPaths =
{
	[1] = "normal/idle_inactive1",
	[2] = "normal/idle_inactive2"
}

---@class StoreRender2DView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommRender2D CommonRender2DView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreRender2DView = LuaClass(UIView, true)

function StoreRender2DView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommRender2D = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreRender2DView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommRender2D)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreRender2DView:OnInit()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	self.CameraCenterOffsetY = -25
	self.SkeletonName = ""

	self.RenderActorCreateCallback = {} -- RenderActor加载完后的回调

	-- 灯光
	self.bOtherLightSwitched = false

	-- 相机
	self.DefaultCamCtrlDataLoader = EquipmentCameraControlDataLoader.New()
	self.ModelPreviewCamCtrlDataLoader = ModelPreviewCameraControlDataLoader.New()
	self.CloseUpViewConfigRefMap = {} -- 特写镜头配置Map
	self.ViewGroupID = 0 -- 为0时使用角色系统镜头参数，>0时使用模型预览镜头参数

	-- 外观
	self.RawEquips = {}
	self.RawCustoms = {}
	self.AppearEquips = {} --当前预览的外观装备
	self.AppearRegionDyesInfo = {} --预览的外观染色数据
	self.AppearCustoms = {}
	self.bRawEquipsVisible = false
	self.bHelmetGimmickOn = false
	self.bHelmetHidden = false

	-- 宠物
	self.CompanionEntityID = -1
	self.InteractTimelineID = 1

	self.bPerviewPanel = false -- 是否预览界面
end

function StoreRender2DView:OnDestroy()

end

function StoreRender2DView:OnShow()
	self.bInInteractCD = false
	self.CommRender2D.bAutoInitSpringArm = false
	self.CommRender2D.bCreateShandowActor = true
end

function StoreRender2DView:OnHide()
	if self.bOtherLightSwitched then
		self.CommRender2D:SwitchOtherLights(true)
		self.bOtherLightSwitched = false
	end
	self:RemoveCompanion()
	self.RenderActorCreateCallback = {}
	for _, CloseUpViewConfig in pairs(self.CloseUpViewConfigRefMap) do
		CloseUpViewConfig = nil
	end
	self.CloseUpViewConfigRefMap = {}
	self.ViewGroupID = 0
end

function StoreRender2DView:OnActive()
	local Companion = self:GetCompanion()
	if nil ~= Companion and CommonUtil.IsObjectValid(Companion) then
        Companion:SetActorVisibility(true, _G.UE.EHideReason.Common) -- Reason与CommonRender2DView:ShowCharacter保持一致
	end
end

function StoreRender2DView:OnInactive()
	if nil ~= self.CommRender2D.SkeletalMeshComponent and CommonUtil.IsObjectValid(self.CommRender2D.SkeletalMeshComponent) then
		self.CommRender2D.SkeletalMeshComponent.VisibilityBasedAnimTickOption =
			_G.UE.EVisibilityBasedAnimTickOption.OnlyTickPoseWhenRendered -- 停止动画更新，避免动作里的特效带入其他界面
	end
	local Companion = self:GetCompanion()
	if nil ~= Companion and CommonUtil.IsObjectValid(Companion) then
        Companion:SetActorVisibility(false, _G.UE.EHideReason.Common)
	end
end

function StoreRender2DView:OnRegisterUIEvent()

end

function StoreRender2DView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PostEmotionEnd, self.OnGameEventPostEmotionEnd)
end

function StoreRender2DView:OnRegisterBinder()

end

--region 游戏事件

function StoreRender2DView:OnGameEventPostEmotionEnd(Params)
	if nil == Params or Params.ULongParam1 ~= ActorUtil.GetActorEntityID(self.CommRender2D.ChildActor) then
		return
	end
	local bInterupted = Params.BoolParam1
	if bInterupted then
		return
	end
	local EmotionID = Params.IntParam1
	self:UnRegisterEmotionTimer()
	self.EmotionTimer = self:RegisterTimer(function() self:PlayEmotion(EmotionID) end, 3)
end

--endregion

function StoreRender2DView:UnRegisterEmotionTimer()
	if self.EmotionTimer then
		self:UnRegisterTimer(self.EmotionTimer)
	end
end

function StoreRender2DView:GetCommonRender2D()
	return self.CommRender2D
end

function StoreRender2DView:UpdateSkeletonName(SkeletonName)
	if self.SkeletonName == SkeletonName then
		return
	end
	self.SkeletonName = SkeletonName
	if nil == self.SkeletonName then
		return
	end
	self:UpdateCloseUpViewConfig(SkeletonName)
end

--region RenderActor相关
-- 创建RenderActor以及默认角色、灯光、相机配置
function StoreRender2DView:CreateRenderActor(Params)
	local EntityID = Params.EntityID or MajorUtil.GetMajorEntityID()
	local InCallback = Params.Callback
	local bSyncLoad = Params.bSyncLoad

	local CallBack = function()
		FLOG_INFO("StoreRender2D: Render actor created callback")

		-- 角色模型
		self.CommRender2D:SetUICharacterByEntityID(EntityID)
		self:UpdateAvatar()
		self:HideHelmet(self.bHelmetHidden)
		self:SwitchHelmet(self.bHelmetGimmickOn)

		-- 灯光
		self.bOtherLightSwitched = true
		self.CommRender2D:SwitchOtherLights(false)

		-- 相机
		self:CheckCameraControlParams()
		self.CommRender2D:ChangeUIState(false)
		if nil ~= self.CommRender2D.CamControlParams then
			self.CommRender2D:SetSpringArmCenterOffsetY(self.CameraCenterOffsetY,
				self.CommRender2D.CamControlParams.DefaultViewDistance)
		end

		if not table.is_nil_empty(self.RenderActorCreateCallback) then
			for _, Callback in pairs(self.RenderActorCreateCallback) do
				Callback()
			end
			self.RenderActorCreateCallback = {}
		end
		if nil ~= InCallback then
			InCallback()
		end
	end
	local ReCreateCallBack = function()
		self.CameraFocusCfgMap:SetAssetUserData(self.CommRender2D:GetEquipmentConfigAssetUserData())
	end
	local LightPresetPath = DefaultLightPresetPath
	local AttributeComp = ActorUtil.GetActorAttributeComponent(EntityID)
	if nil ~= AttributeComp then
		local SystemLightID = Params.SystemLightID and Params.SystemLightID or 2 
		local RaceLightPreset = self:GetLightPresetPath(AttributeComp.RaceID, SystemLightID)
		if RaceLightPreset ~= "" then
			LightPresetPath = RaceLightPreset
		end
	end
	local CopyFromActor = ActorUtil.GetActorByEntityID(EntityID)
	if nil == CopyFromActor or nil == CopyFromActor:GetAvatarComponent() then
		return
	end
	self:UpdateSkeletonName(CopyFromActor:GetAvatarComponent():GetAttachTypeIgnoreChangeRole())
	local RenderActorPath = string.format(RenderActorPathFormat, self.SkeletonName, self.SkeletonName)
	self.CommRender2D:CreateRenderActor(RenderActorPath,
		EquipmentMgr:GetEquipmentCharacterClass(), LightPresetPath,
		false, CallBack, ReCreateCallBack, nil, {bSyncLoad = bSyncLoad})
end

function StoreRender2DView:AddRenderActorCreateCallback(CallbackType, Callback)
	if nil == CallbackType or nil == Callback then
		return
	end
	self.RenderActorCreateCallback[CallbackType] = Callback
end

--endregion

--region 灯光相关

function StoreRender2DView:GetLightPresetPath(Race, SystemLightID)
	if nil == Race then
		return ""
	end
	local SystemLightCfgData = SystemLightCfg:FindCfgByKey(SystemLightID)
    if nil == SystemLightCfgData then
		return ""
	end

	local PathList = SystemLightCfgData.LightPresetPaths
	if nil == PathList or nil == next(PathList) then
		return ""
	end

	local PathIndex = 1
	if Race == ProtoCommon.race_type.RACE_TYPE_Roegadyn then
		PathIndex = 2
	elseif Race == ProtoCommon.race_type.RACE_TYPE_Lalafell then
		PathIndex = 3
	end

	return PathList[PathIndex]
end

--endregion

--region 相机相关

-- 根据骨骼名更新特写镜头配置
function StoreRender2DView:UpdateCloseUpViewConfig(SkeletonName)
	if nil == SkeletonName then
		return
	end
	local CloseUpViewConfig = self.CloseUpViewConfigRefMap[SkeletonName] and self.CloseUpViewConfigRefMap[SkeletonName]:GetObject()
	if nil == CloseUpViewConfig then
		CloseUpViewConfig = ObjectMgr:LoadObjectSync(string.format(CloseUpViewPathFormat, SkeletonName, SkeletonName))
		if nil == CloseUpViewConfig then
			return
		end
		self.CloseUpViewConfigRefMap[SkeletonName] = UnLua.Ref(CloseUpViewConfig)
	end
	self.CameraFocusCfgMap:SetAssetUserData(CloseUpViewConfig.CloseUpViewData)
end

-- 根据骨骼名更新默认镜头控制参数
function StoreRender2DView:CheckCameraControlParams()
	if nil == self.SkeletonName then
		return
	end
	local CamControlParams = nil
	if self.ViewGroupID ~= 0 then
		CamControlParams = self.ModelPreviewCamCtrlDataLoader:GetCameraControlParams(self.SkeletonName, self.ViewGroupID)
	end
	if nil == CamControlParams then
		CamControlParams = self.DefaultCamCtrlDataLoader:GetCameraControlParams(self.SkeletonName, CameraControlDefine.FocusType.WholeBody)
	end
	self.CommRender2D:SetCameraControlParams(CamControlParams)
end

-- 更新默认镜头组ID
function StoreRender2DView:UpdateViewGroupID(ViewGroupID)
	self.ViewGroupID = ViewGroupID
end

-- 更新相机水平偏移
function StoreRender2DView:UpdateCameraOffsetY(InOffsetY)
	self.CameraCenterOffsetY = InOffsetY
	local DefaultSpringArmLength = nil
	if nil ~= self.CommRender2D.CamControlParams then
		DefaultSpringArmLength = self.CommRender2D.CamControlParams.DefaultViewDistance
	end
	self.CommRender2D:SetSpringArmCenterOffsetY(InOffsetY, DefaultSpringArmLength)
end

-- 聚焦相机到某一部位（包含角色旋转）
function StoreRender2DView:FocusView(Part, Prof)
	if nil == Part then
		FLOG_ERROR("[StoreRender2DView:ShowModelFocusPart] Part is not provided!")
		return
	end
	Prof = Prof or MajorUtil.GetMajorProfID()
	local CameraFocusCfg = self.CameraFocusCfgMap:GetCfgByRaceAndProf(self.SkeletonName, Prof, Part)
	if nil == CameraFocusCfg then
		FLOG_ERROR("[StoreRender2DView:ShowModelFocusPart] Cannot find focus for Skeleton " .. tostring(self.SkeletonName) ..
			" Part " .. tostring(Part) .. " Prof " .. tostring(Prof))
		return
	end

	-- 相机
	self.CommRender2D:SetCameraLockedFOV(CameraFocusCfg.FOV)
	self.CommRender2D:SetCameraFOV(CameraFocusCfg.FOV, true)
	local DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
	local ViewportSize = UIUtil.GetViewportSize() / DPIScale
	local UIX = ViewportSize.X / 2 + (self.bPerviewPanel and CameraFocusCfg.UIX + 100 or CameraFocusCfg.UIX)
	local UIY = ViewportSize.Y / 2 + CameraFocusCfg.UIY
	self.CommRender2D:SetCameraFocusScreenLocation(UIX * DPIScale, UIY * DPIScale, CameraFocusCfg.SocketName,
	CameraFocusCfg.Distance)

	-- 角色模型
	self.CommRender2D:SetModelRotation(0, CameraFocusCfg.Yaw , 0, true)

	-- 输入限制
	self.CommRender2D:EnableZoom(false)
	self.CommRender2D:EnablePitch(false)
	self.CommRender2D:EnableRotator(false)
	self.CommRender2D:SetCameraFocusEndCallback(function() self.CommRender2D:EnableRotator(true) end)
end

-- 恢复相机到默认位置（包含角色旋转）
function StoreRender2DView:ResetView(bInterp, ViewportPos)
	if nil == bInterp then
		bInterp = true
	end
	self.CommRender2D.bAutoInitSpringArm = true
	self:CheckCameraControlParams()
	local DefaultSpringArmLength = 0
	if nil ~= self.CommRender2D.CamControlParams then
		DefaultSpringArmLength = self.CommRender2D.CamControlParams.DefaultViewDistance
	end
	-- 相机
	if nil ~= ViewportPos then
		self.CameraCenterOffsetY = -CameraUtil.GetCameraOffsetY(ViewportPos.X,
			CameraUtil.FOVYToFOVX(self.CommRender2D:GetZoomFOV(DefaultSpringArmLength)),
			DefaultSpringArmLength)
	end
	self.CommRender2D:SetSpringArmCenterOffsetY(self.CameraCenterOffsetY, DefaultSpringArmLength)
	self.CommRender2D:EndCameraFocusScreenLocation()
	self.CommRender2D:ResetViewDistance(bInterp)

	-- 角色模型
	-- 朝向镜头
	local YawAngle = -math.deg(math.atan(-self.CameraCenterOffsetY, self:GetViewDistance()))
	self.CommRender2D:SetModelRotation(0, YawAngle , 0, bInterp)

	-- 输入限制
	self.CommRender2D:EnableZoom(true)
	self.CommRender2D:EnablePitch(true)
	self.CommRender2D:EnableRotator(true)
end

-- 计算叠加了相机臂距离与X轴偏移的视距
function StoreRender2DView:GetViewDistance()
	local ViewDist = 0

	if self.CommRender2D:IsInterpolatingSpringArmLocation() then
		ViewDist = ViewDist + self.CommRender2D.SpringArmLocationTarget.X
	else
		ViewDist = ViewDist + self.CommRender2D:GetSpringArmLocation().X
	end
	if self.CommRender2D:IsInterpolatingSpringArmDistance() then
		ViewDist = ViewDist + self.CommRender2D.SpringArmDistanceTarget
	else
		ViewDist = ViewDist + self.CommRender2D:GetSpringArmDistance()
	end

	return ViewDist
end

function StoreRender2DView:GetSpringArmLocationTarget()
	if nil ~= self.CommRender2D.SpringArmLocationTarget then
		return self.CommRender2D.SpringArmLocationTarget
	else
		return self.CommRender2D:GetSpringArmLocation()
	end
end

--endregion

--region 换装相关

-- 设置原始外观
---@param RoleAvatar common.RoleAvatar

-- 切换到预设的模型外观
function StoreRender2DView:SwitchToPresetModel(Race, Gender)
	if nil == Race or nil == Gender then
		return
	end
	local SubstituteCfgData = ModelPreviewSubstituteCfg:FindCfgByKey(Race)
	if nil == SubstituteCfgData then
		return
	end
	local NPCBaseID = Gender == ProtoCommon.role_gender.GENDER_MALE and SubstituteCfgData.MaleNPCBaseID
		or SubstituteCfgData.FemaleNPCBaseID
	local Character = self.CommRender2D:GetCharacter()
	if nil == Character then
		self:AddRenderActorCreateCallback(RenderActorCreateCallbackType.ModelSwitch,
			function() self:SwitchToPresetModel(Race, Gender) end)
		return
	end
	local AvatarComp = Character:GetAvatarComponent()
	if nil == AvatarComp then
		return
	end
	-- 加载Npcbase数据并更新模型
	AvatarComp:LoadByAvatarNpcbaseID(NPCBaseID, true)
	Character:MarkUIActor()
	self:UpdateSkeletonName(AvatarComp:GetAttachTypeIgnoreChangeRole())
	-- 更新原始AvatarFace数据
	local FaceMap = _G.UE.TMap(_G.UE.int32, _G.UE.int32)
	AvatarComp:GetAvatarFaceMapByProfile(FaceMap)
	self:UpdateRawCustoms(FaceMap)
	-- 根据新Face数据更新模型
	self:UpdateAvatar()
end

-- 恢复到默认模型外观
function StoreRender2DView:ResetToDefaultModel(RoleSimple)
	if nil == RoleSimple then
		return
	end
	local Character = self.CommRender2D:GetCharacter()
	if nil == Character then
		self:AddRenderActorCreateCallback(RenderActorCreateCallbackType.ModelSwitch,
			function() self:ResetToDefaultModel(RoleSimple) end)
		return
	end
	local AvatarComp = Character:GetAvatarComponent()
	if nil == AvatarComp then
		return
	end
	local AttributeComp = Character:GetAttributeComponent()
	if nil == AttributeComp then
		return
	end
	-- 还原种族与性别
	AttributeComp.Gender = RoleSimple.Gender
	AttributeComp.RaceID = RoleSimple.Race
	AttributeComp:SetTribeID(RoleSimple.Tribe)
	AvatarComp:ResetHasRoleAvatar()
	AvatarComp:UpdateDefaultBody()
	self:UpdateSkeletonName(AvatarComp:GetAttachTypeIgnoreChangeRole())
	-- 还原原始AvatarFace数据
	self:SetRawAvatar(RoleSimple.Avatar)
	-- 根据新Face数据更新模型
	self:UpdateAvatar()
end

function StoreRender2DView:SetRawAvatar(RoleAvatar)
	for _, Equip in pairs(RoleAvatar.EquipList) do
		--这里接口可能有问题，不能传入RandomID，不然会直接返回RandomID，有时候不是EquipID
		local EquipID = WardrobeUtil.GetEquipID(Equip.EquipID, Equip.ResID, nil)
		self.RawEquips[Equip.Part] = {EquipID = EquipID, ColorID = Equip.ColorID}
	end
	self.RawCustoms = table.deepcopy(RoleAvatar.Face)
	-- 下面几个外观设置受界面控制，不保存原始数据
	self.RawCustoms[ProtoCommon.avatar_personal.AvatarEquipHeadShow] = nil
	self.RawCustoms[ProtoCommon.avatar_personal.AvatarEquipHandShow] = nil
	self.RawCustoms[ProtoCommon.avatar_personal.AvatarEquipSwitchShow] = nil
end

-- 更新原始AvatarFace数据，默认只更新传入部分数据
function StoreRender2DView:UpdateRawCustoms(AvatarFaceMap)
	for Key, Value in pairs(AvatarFaceMap) do
		self.RawCustoms[Key] = Value
	end
end

-- 设置原始装备可见性（默认关）
function StoreRender2DView:SetRawEquipsVisible(bVisible)
	self.bRawEquipsVisible = bVisible
	self:UpdateAvatar()
end

-- 设置当前预览的外观染色数据
function StoreRender2DView:SetAppearRegionDyesInfo(RegionDyesInfo)
	self.AppearRegionDyesInfo = RegionDyesInfo
end

-- 头盔显隐
function StoreRender2DView:HideHelmet(bHide)
	self.bHelmetHidden = bHide
	if nil == self.CommRender2D.ChildActor then
		-- 角色未创建，待创建回调后根据bHelmetHidden设置
		return
	end
	self.CommRender2D:HideHead(bHide)
end

-- 头盔开关
function StoreRender2DView:SwitchHelmet(bOn)
	self.bHelmetGimmickOn = bOn
	if nil == self.CommRender2D.ChildActor then
		-- 角色未创建，待创建回调后根据bHelmetGimmickOn设置
		return
	end
	self.CommRender2D:SwitchHelmet(bOn)
end

-- 穿上当前点击的外观装备
---@param AppearData table @{EquipmentID: number, Part: number, ItemType: ProtoCommon.ITEM_TYPE_DETAIL}
function StoreRender2DView:WearAppearance(AppearData, bLoadInstantly)
	if nil == AppearData.EquipmentID or nil == AppearData.Part then
		return
	end
	if AppearData.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_COIFFURE then
		local Part = ProtoCommon.avatar_personal.AvatarPersonalHair
		self.AppearCustoms[Part] = AppearData
		self:PreviewCustom(Part, AppearData.EquipmentID)
	else
		self.AppearEquips[AppearData.Part] = AppearData
		self:PreviewEquipment(AppearData.EquipmentID, AppearData.Part, AppearData.ColorID, self.AppearRegionDyesInfo, bLoadInstantly)
	end
end

-- 穿着套装外观
function StoreRender2DView:WearSuit(SuitData)
	-- 脱掉旧外观
	for Part, _ in pairs(self.AppearEquips) do
		self:TakeOffAppearEquip(Part, false)
	end
	for Part, _ in pairs(self.AppearCustoms) do
		self:TakeOffAppearCustom(Part, false)
	end

	-- 穿上新外观
	for _, PartData in pairs(SuitData) do
		self:WearAppearance(PartData, false)
	end

	-- 加载模型
	self:LoadAvatar()
end

function StoreRender2DView:SetOrnamentCompData(Type, ID)
	self.CommRender2D.ChildActor:SetOrnamentCompData(Type, ID)
end

function StoreRender2DView:DeleteOrnamentData(Type)
	self.CommRender2D.ChildActor:DeleteOrnamentData(Type)
end

-- 根据当前外观数据与原始装备数据更新模型
function StoreRender2DView:UpdateAvatar()
	-- 穿上外观
	for _, EquipData in pairs(self.AppearEquips) do
		self:PreviewEquipment(EquipData.EquipmentID, EquipData.Part, EquipData.ColorID, self.AppearRegionDyesInfo, false)
	end
	for _, CustomData in pairs(self.AppearCustoms) do
		self:PreviewCustom(CustomData, CustomData.EquipmentID)
	end

	--获取原始装备的染色数据
	local RegionDyesInfo = nil
	if self.bRawEquipsVisible then
		RegionDyesInfo = ActorUtil.GetActorRegionDyesInfo(MajorUtil.GetMajorEntityID())
	end

	-- 穿上外观部位没有的原始装备与妆容
	for Part, EquipData in pairs(self.RawEquips) do
		if nil == self.AppearEquips[Part] then
			local EquipID = self.bRawEquipsVisible and EquipData.EquipID or 0
			self:PreviewEquipment(EquipID, Part, EquipData.ColorID, RegionDyesInfo, false)
		end
	end
	for Part, CustomValue in pairs(self.RawCustoms) do
		if nil == self.AppearCustoms[Part] then
			self:PreviewCustom(Part, CustomValue)
		end
	end

	-- 加载模型
	self:LoadAvatar()
end

--脱掉对应Part预览的外观
function StoreRender2DView:TakeOffAppear(Part, bLoadInstantly)
	if Part == ProtoCommon.equip_part.EQUIP_PART_BODY_HAIR then
		local CustomPart = EquipmentDefine.AvatarPersonalMap[Part]
		self:TakeOffAppearCustom(CustomPart, bLoadInstantly)
	else
		self:TakeOffAppearEquip(Part, bLoadInstantly)
	end
end

function StoreRender2DView:TakeOffAppearEquip(Part, bLoadInstantly)
	local EquipID = 0
	local ColorID = 0
	local RegionDyesInfo = nil
	if nil ~= self.RawEquips[Part] and self.bRawEquipsVisible then
		EquipID = self.RawEquips[Part].EquipID
		ColorID = self.RawEquips[Part].ColorID
		RegionDyesInfo = ActorUtil.GetActorRegionDyesInfo(MajorUtil.GetMajorEntityID())
	end
	self:PreviewEquipment(EquipID, Part, ColorID, RegionDyesInfo, bLoadInstantly)
	if nil ~= self.AppearEquips[Part] then
		self.AppearEquips[Part] = nil
	end
	if bLoadInstantly then
		self:LoadAvatar()
	end
end

function StoreRender2DView:TakeOffAppearCustom(Part, bLoadInstantly)
	local ID = 0
	if nil ~= self.RawCustoms[Part] then
		ID = self.RawCustoms[Part]
	end
	self:PreviewCustom(Part, ID)
	self.AppearCustoms[Part] = nil
end

function StoreRender2DView:GetAvatarComp()
	local Character = self.CommRender2D.ChildActor
	if nil == Character then
		return nil
	end
	local AvatarComp = Character:GetAvatarComponent()
	return AvatarComp
end

-- 预览衣服，bLoadInstantly设为false可只存储数据，暂时不执行模型加载
function StoreRender2DView:PreviewEquipment(EquipID, Part, ColorID, RegionDyesInfo, bLoadInstantly)
	local AvatarComp = self:GetAvatarComp()
	if nil == AvatarComp then
		return
	end
	AvatarComp:UpdateEquipAppearData(Part, EquipID, ColorID)
	ActorUtil.UpdateEquipRegionDyes(self.CommRender2D.ChildActor, Part, RegionDyesInfo)

	if nil == bLoadInstantly or bLoadInstantly then
		AvatarComp:ForceUpdateCurRoleAvatar()
	end
end

-- 根据当前外观数据进行加载
function StoreRender2DView:LoadAvatar()
	local AvatarComp = self:GetAvatarComp()
	if nil == AvatarComp then
		return
	end
	AvatarComp:ForceUpdateCurRoleAvatar()
end

-- 预览妆容（脸型、发型、刺青等）
---@param CustomPart ProtoCommon.avatar_personal
---@param ID number
function StoreRender2DView:PreviewCustom(CustomPart, ID)
	local AvatarComp = self:GetAvatarComp()
	if nil == AvatarComp then
		return
	end
	AvatarComp:SetAvatarPartCustomize(CustomPart, ID, true)
end

--endregion

--region 动作相关
function StoreRender2DView:PlayEmotion(EmotionID)
	if nil == self.CommRender2D.ChildActor then
		self:AddRenderActorCreateCallback(RenderActorCreateCallbackType.PlayEmotion, function() self:PlayEmotion(EmotionID) end)
		return
	end
	EmotionMgr:PlayEmotionIDFromEntityID(EmotionID, self.CommRender2D.ChildActor:GetActorEntityID())
end

function StoreRender2DView:StopEmotion()
	if nil == self.CommRender2D.ChildActor then
		self:AddRenderActorCreateCallback(RenderActorCreateCallbackType.PlayEmotion, function() self:StopEmotion() end)
		return
	end
	EmotionMgr:StopAllEmotions(self.CommRender2D.ChildActor:GetActorEntityID())
end

--endregion

--region 宠物相关

---@param CreateParam table @{Location: UE.FVector, Rotation: UE.FVector}
function StoreRender2DView:CreateCompanion(CompanionID, CreateParam)
	-- 同时只允许存在一个宠物
	self:RemoveCompanion()

    local Location = CreateParam.Location
	local Rotation = CreateParam.Rotation
	
    local CreateClientActorParam = UE.FCreateClientActorParams()
	CreateClientActorParam.bUIActor = true
	CreateClientActorParam.bAsync = true
	CreateClientActorParam.bNoFadeInOut = CreateParam.bNoFadeInOut or false
	self.CompanionEntityID = UE.UActorManager:Get():CreateClientActorByParams(UE.EActorType.Companion, 0, CompanionID,
		Location, Rotation, CreateClientActorParam)
end

function StoreRender2DView:RemoveCompanion()
	if self.CompanionEntityID > 0 then
		local Companion = ActorUtil.GetActorByEntityID(self.CompanionEntityID)
        if Companion then
            _G.UE.UActorManager.Get():RemoveClientActor(self.CompanionEntityID)
			self.CompanionEntityID = -1
        end
	end
end

function StoreRender2DView:GetCompanion()
	if self.CompanionEntityID < 0 then
		return nil
	end
	return ActorUtil.GetActorByEntityID(self.CompanionEntityID)
end

function StoreRender2DView:InitCompanionTransform(CompanionID)
	local CompanionActor = self:GetCompanion()
	if nil == CompanionActor then
		return
	end
	if nil == CompanionID then
		CompanionID = ActorUtil.GetActorResID(self.CompanionEntityID)
	end
	local CfgData = CompanionMgr:GetCompanionExternalCfg(CompanionID)

	-- 缩放
	local ScaleBase = 100
	if nil ~= CfgData and not MathUtil.IsNearlyEqual(CfgData.ArchiveModelScale, 0) then
		ScaleBase = CfgData.ArchiveModelScale
	end
	local ScaleFactor = ScaleBase / 100
	CompanionActor:SetScaleFactor(ScaleFactor, true)

	-- 模型偏移
	if nil ~= CfgData and nil ~= CfgData.ArchiveModelLocation then
		local CfgZ = CfgData.ArchiveModelLocation.Z
		if not MathUtil.IsNearlyEqual(CfgZ, 0) then
			CompanionActor:SetModelFloatHeight(CfgZ, true)
		end
	end

	-- 朝向
	-- 面向相机
	local ViewDist = self:GetViewDistance()
	local OffsetY = 0
	local SpringArmLocation = self:GetSpringArmLocationTarget()
	if nil ~= SpringArmLocation then
		OffsetY = SpringArmLocation.Y
	end
	local YawAngle = -math.deg(math.atan(-OffsetY, ViewDist))
	-- 叠加配表偏移
	local ConfigYawAngle = 0
	if nil ~= CfgData and not MathUtil.IsNearlyEqual(CfgData.ArchiveModelRotation, 0) then
		ConfigYawAngle = CfgData.ArchiveModelRotation
	end
	YawAngle = YawAngle + ConfigYawAngle - 6 -- 表里配置自带6度偏移

	self.CommRender2D:SetModelRotation(0, YawAngle, 0, false)
end

function StoreRender2DView:TryPlayInteractTimeline()
	if self.bInInteractCD then
		return
	end
	self.bInInteractCD = true
	if nil == self.InteractCD then
		local CfgData = CompanionGlobalCfg:FindCfgByKey(ProtoRes.CompanionParamCfgID.CompanionParamCfgIDArchiveModelInteractCD)
		if nil ~= CfgData then
			self.InteractCD = CfgData.Value[1]
		else
			self.InteractCD = 0.5
		end
	end
	local CompanionCfgData = CompanionCfg:FindCfgByKey(ActorUtil.GetActorResID(self.CompanionEntityID))
	local InteractTimelineID = 1
	if nil ~= CompanionCfgData and nil ~= CompanionCfgData.InactiveIdle2 and CompanionCfgData.InactiveIdle2 ~= 0 then
		InteractTimelineID = self.InteractTimelineID
		self.InteractTimelineID = self.InteractTimelineID % 2 + 1
	end
	local AnimPath = CompanionInteractActionPaths[InteractTimelineID]
	AnimMgr:PlayActionTimeLine(self.CompanionEntityID, AnimPath)
	self:RegisterTimer(function() self.bInInteractCD = false end,
		self.InteractCD)
end

--endregion

--region 坐骑相关

function StoreRender2DView:InitMountTransform(MountID)
	local Character = self.CommRender2D.ChildActor
	if nil == Character then
		FLOG_ERROR("Mount transform init failed. Character is not created yet.")
		return
	end

	if nil == self.CommRender2D.ChildActor then
		return
	end
	local RideComp = self.CommRender2D.ChildActor:GetRideComponent()
	if nil == RideComp then
		FLOG_ERROR("Mount transform init failed. Ride component not found.")
		return
	end
	if nil == MountID then
		MountID = RideComp:GetRideResID()
	end

	-- 缩放
	local MountCfgData = RideCfg:FindCfgByKey(MountID)
	if nil == MountCfgData then
		FLOG_ERROR("RideCfg cannot find record for mount ID " .. tostring(MountID))
		return
	end
	local Scale = MountCfgData.ModelScaling
	if nil == Scale or Scale < 0.1 then
		Scale = 1.0
	end
	Character:SetScaleFactor(Scale, true)

	-- 模型偏移
	local MountMeshComp = self.CommRender2D.RideMeshComponent
	if nil ~= MountMeshComp then
		MountMeshComp:K2_AddRelativeLocation(UE.FVector(MountCfgData.OriginOffsetX or 0, 0, 0), false, nil, false)
	end
	local ModelLocationX = MountCfgData.LocationX or 0
	self.CommRender2D:SetModelLocation(ModelLocationX, 0, MountCfgData.LocationZ or 0)

	-- 朝向
	RideComp:EnableAnimationRotating(false)
	if MountID == 1001 then
		--特殊处理滑板的倾斜
		-- Character:SetRideUseTpose(true)	--为避免在设置旋转时被蓝图tick回默认0角度
		-- Character:SetModelFloatHeight(Character:GetUnscaledCapsuleHalfHeight(), true) -- 让滑板旋转轴位于场景中心
		self.CommRender2D:RotatorUseWorldRotation(true)
	else
		Character:SetRideUseTpose(false)
	end
	self.CommRender2D:EnableRotateAttachParent(true)

	-- 面向相机
	local ViewDist = self:GetViewDistance() - ModelLocationX
	local OffsetY = 0
	local SpringArmLocation = self:GetSpringArmLocationTarget()
	if nil ~= SpringArmLocation then
		OffsetY = SpringArmLocation.Y
	end
	local YawAngle = -math.deg(math.atan(-OffsetY, ViewDist))
	-- 叠加配表偏移
	YawAngle = MountCfgData.RotationX + YawAngle - 6 -- 表里配置自带6度偏移
	self.CommRender2D:SetModelRotation(0, 0, 0, false) -- 停止旋转
	if nil ~= MountMeshComp and nil ~= MountMeshComp:GetAttachParent() then
		MountMeshComp:GetAttachParent():K2_SetRelativeRotation(UE.FRotator(MountCfgData.RotationY, YawAngle, MountCfgData.RotationZ),
			false, nil, false)
	end

end

--endregion

--region 假阴影相关

-- 更新假阴影捕获目标
function StoreRender2DView:UpdateShadowTarget(Actor)
	local ShadowActor = self.CommRender2D.ShadowActor
	if nil == ShadowActor or not CommonUtil.IsObjectValid(ShadowActor) then
		return
	end
	if _G.StoreMainVM.TabSelecteType ~= ProtoRes.StoreMall.STORE_MALL_PET then
		local AllActor = _G.UE.TArray(_G.UE.AActor)
		AllActor:Add(Actor)
		_G.UIShadowMgr:UpdateActorList(AllActor)
	else
		_G.UIShadowMgr:UpdateCompnent(Actor)
	end
end

---@param ShadowType ActorUtil.ShadowType
function StoreRender2DView:SwitchShadowType(ShadowType)
	local ShadowActor = self.CommRender2D.ShadowActor
	if nil == ShadowActor or not CommonUtil.IsObjectValid(ShadowActor) then
		return
	end
	ShadowActor:UseSetting(ShadowType)
end

--endregion

return StoreRender2DView