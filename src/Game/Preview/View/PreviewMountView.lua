---
--- Author: rock
--- DateTime: 2024-12-12 11:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PreviewMounVM = require("Game/Preview/VM/PreviewMounVM")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local MajorUtil = require("Utils/MajorUtil")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local CommonUtil = require("Utils/CommonUtil")
local ActorUtil = require("Utils/ActorUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local RideCfg = require("TableCfg/RideCfg")
local RideSkillCfg = require("TableCfg/RideSkillCfg")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local SkillTipsMgr = require("Game/Skill/SkillTipsMgr")
local ObjectGCType = require("Define/ObjectGCType")
local SystemLightCfg = require("TableCfg/SystemLightCfg")
local CameraUtil = require("Game/Common/Camera/CameraUtil")

local RotationX = -6 --Yaw值偏移角度，偏移数据以图鉴为基准，而预览在中间，所以需要偏移才能保持和图鉴一致

---@class PreviewMountView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field Common_Render2D_UIBP CommonRender2DView
---@field HorizontalPeople UHorizontalBox
---@field SkillActionBG UFButton
---@field TableViewAction UTableView
---@field TextDescribe UFTextBlock
---@field TextMountName UFTextBlock
---@field TextRide UFTextBlock
---@field TextRideNumber UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleBtnBGM UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PreviewMountView = LuaClass(UIView, true)

function PreviewMountView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.Common_Render2D_UIBP = nil
	--self.HorizontalPeople = nil
	--self.SkillActionBG = nil
	--self.TableViewAction = nil
	--self.TextDescribe = nil
	--self.TextMountName = nil
	--self.TextRide = nil
	--self.TextRideNumber = nil
	--self.TextTitle = nil
	--self.ToggleBtnBGM = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PreviewMountView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.Common_Render2D_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PreviewMountView:OnInit()
	self.ViewModel = PreviewMounVM.New()
	self.ActionTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewAction, self.OnActionTableViewSelectChange, false)
	self:InitPanelStaticText()
	self.ZSMDHB = 1001	--滑板ID
end

function PreviewMountView:OnDestroy()

end

function PreviewMountView:OnShow()
	self:ShowPlayerMountActor()
	_G.LightMgr:EnableUIWeather(10, true)

	--禁止移动控制(虚拟摇杆)
	CommonUtil.DisableShowJoyStick(true)
	CommonUtil.HideJoyStick()

	_G.HUDMgr:SetIsDrawHUD(false)

	--假阴影
	self.Common_Render2D_UIBP.bCreateShandowActor = true
	self.Common_Render2D_UIBP:SetShadowActorType(ActorUtil.ShadowType.PreviewMount)
	self.Common_Render2D_UIBP:SetShadowActorPos(_G.UE.FVector(0, 0, 100000.0))

	self.ToggleBtnBGM:SetCheckedState(self.ViewModel.IsShowBGM and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.UnChecked, false)
end

function PreviewMountView:OnHide()
	self.Common_Render2D_UIBP:SwitchOtherLights(true)
	self:StopBGM()
	_G.LightMgr:DisableUIWeather()
	self:OnSkillTipsBGClick()

	self.ViewModel:ClearData()
	
	_G.HUDMgr:SetIsDrawHUD(true)

	--解除移动控制(虚拟摇杆)
	CommonUtil.DisableShowJoyStick(false)
	CommonUtil.ShowJoyStick()
end

function PreviewMountView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnBGM, self.OnShowBGM)
	UIUtil.AddOnClickedEvent(self, self.SkillActionBG, self.OnSkillTipsBGClick)
end

function PreviewMountView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
end

function PreviewMountView:OnRegisterBinder()
	local Binders = {
		{ "TextShowName", UIBinderSetText.New(self, self.TextMountName)},
		{ "TextShowMember", UIBinderSetText.New(self, self.TextRideNumber)},
		{ "TextShowExpository", UIBinderSetText.New(self, self.TextDescribe)},

		{ "IsShowSkillItem", UIBinderSetIsVisible.New(self, self.TableViewAction)},
		{ "ActionTableList", UIBinderUpdateBindableList.New(self, self.ActionTableViewAdapter) },
		{ "IsShowSkillTips", UIBinderSetIsVisible.New(self, self.SkillActionBG, nil, true) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

-- 初始化三维展示模型
function PreviewMountView:ShowPlayerMountActor()
	self.ViewModel.IsShowPlayer = false

	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	self.ViewModel.AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	
    local CallBack = function(bSucc)
        if (bSucc) then
			self.VignetteIntensityDefaultValue = self.Common_Render2D_UIBP:GetPostProcessVignetteIntensity()
			self.Common_Render2D_UIBP:SwitchOtherLights(false)
            self.Common_Render2D_UIBP:ChangeUIState(false)
            self.Common_Render2D_UIBP:SetUICharacterByEntityID(MajorUtil.GetMajorEntityID())
			self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
            self:SetModelSpringArmToDefault(false)
			-- self.Common_Render2D_UIBP:UpdateAllLights()
			self.Common_Render2D_UIBP:HidePlayer(self.ViewModel.IsShowPlayer)
			self:OnLoadMountModel()
			local Actor = self.Common_Render2D_UIBP:GetCharacter()
			if Actor then
				local AvatarComponent = Actor:GetAvatarComponent()
				if AvatarComponent then
					AvatarComponent:SetForcedLODForAll(1)
				end
			end
			if self.Params and self.Params.MountId then
				local MountId = self.Params.MountId
				self:OnShowMountModel(MountId)
			end
			self:SetLight()
        end
    end
	local ReCreateCallBack = function()
        self.CameraFocusCfgMap:SetAssetUserData(self.Common_Render2D_UIBP:GetEquipmentConfigAssetUserData())
    end

	self.Common_Render2D_UIBP.bCreateNewBackground = true
	self.Common_Render2D_UIBP.bAutoInitSpringArm = false -- 如果不忽视，OnAssembleAllEnd时，会把摄像机位置弄错(位置：CommonRender2DView:InitSpringArmEndPos())
    self.Common_Render2D_UIBP:CreateRenderActor(_G.PreviewMgr.MountSceneActorPath, EquipmentMgr:GetEquipmentCharacterClass(), EquipmentMgr:GetLightConfig(),
	false, CallBack, ReCreateCallBack, ObjectGCType.LRU)
	--隐藏武器
	--self.Common_Render2D_UIBP:HideWeapon(true)
	--self.Common_Render2D_UIBP:UpdateAllLights()
	--self.Common_Render2D_UIBP:ChangeUIState(false)
	--self.Common_Render2D_UIBP:ShowRenderActor(true)
end

-- 所选图鉴发生变化
function PreviewMountView:OnShowMountModel(MountID)
	local Mount = self.ViewModel:GetMountById(MountID)
	if Mount == nil then
		return
	end
	self.ViewModel.SelectedMountID = Mount.ResID

	-- 加载坐骑三维模型
	self:SetMountModel(self.ViewModel.SelectedMountID)
	-- 更新界面文本显示
	self.ViewModel:UpdateShowText(Mount)
	-- 技能图标
	self:UpdateSkillItem()

	self:PlayBGM()
end

-- 界面角色部件拼装完成
function PreviewMountView:OnAssembleAllEnd(Params)
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	local EntityID = Params.ULongParam1
	local ObjType = Params.IntParam1
	if not ChildActor then return end
	
	local AttrComp = ChildActor:GetAttributeComponent()
	local UIComplexCharacter = self.Common_Render2D_UIBP.UIComplexCharacter
	if UIComplexCharacter == nil or AttrComp == nil or self.ViewModel.SelectedMountID == nil then
		return
	end

	local RideComponent = UIComplexCharacter:GetRideComponent()
	if RideComponent == nil then
		return
	end

	local RideResID = RideComponent:GetRideResID()
	if EntityID == AttrComp.EntityID and ObjType == AttrComp.ObjType and self.ViewModel.SelectedMountID == RideResID then
		local Mount = self.ViewModel:GetMountById(self.ViewModel.SelectedMountID)
		if Mount then
			self.Common_Render2D_UIBP:SetRideMeshComponent()
			-- 缩放在此完成
			self:SetMountModelScale(Mount)
			--处理贴图加载
			UIComplexCharacter:GetAvatarComponent():WaitForTextureMips()
		
			if self.ViewModel.SelectedMountID == self.ZSMDHB then
				--特殊处理滑板的倾斜
				--为避免在设置旋转时被蓝图tick回默认0角度
				if UIComplexCharacter:GetRideComponent() ~= nil then
					UIComplexCharacter:GetRideComponent():EnableAnimationRotating(false)
				end
				self.Common_Render2D_UIBP:RotatorUseWorldRotation(true)
			else
				RideComponent:EnableAnimationRotating(true)
			end
			self.Common_Render2D_UIBP:SetModelRotation(Mount.RotationY, Mount.RotationX + RotationX, Mount.RotationZ)
			self.Common_Render2D_UIBP:SetModelLocation(Mount.LocationX or 0, Mount.LocationY or 0 , Mount.LocationZ or 0)

			--判断是否要显示坐骑上面的角色
			if self.ViewModel.IsShowPlayer then
				RideComponent:ShowRod()
			else
				RideComponent:HideRod()
			end

			self:SetMountActorState(true)
		end
	end
end

-- 根据坐骑ID切换模型
function PreviewMountView:SetMountModel(MountID)
	self.Common_Render2D_UIBP:SetUIRideCharacter(MountID)
	self.Common_Render2D_UIBP:HidePlayer(not self.ViewModel.IsShowPlayer)
end

-- 坐骑模型整体缩放
function PreviewMountView:SetMountModelScale(Mount)
	local Scale = Mount.ModelScaling
	if Scale == nil or Scale < 0.1 then
		Scale = 1.0
	end
	--self.Common_Render2D_UIBP:SetModelScale(Scale)
	local ChildActor = self.Common_Render2D_UIBP:GetCharacter()
	if ChildActor ~= nil then
	    ChildActor:SetScaleFactor(Scale, true)
	end
end

function PreviewMountView:OnLoadMountModel()
	
end

function PreviewMountView:SetMountActorState(bShow)
	if self.Common_Render2D_UIBP ~= nil then
		self.Common_Render2D_UIBP:ShowCharacter(bShow)
	end
end

function PreviewMountView:SetModelSpringArmToDefault(bInterp)
	local SpringArmRotation = self.Common_Render2D_UIBP:GetSpringArmRotation()
	self.Common_Render2D_UIBP:SetSpringArmRotation(0, SpringArmRotation.Yaw, SpringArmRotation.Roll, true)
	self.Common_Render2D_UIBP:SetSpringArmLocation(self.CameraFocusCfgMap:GetSpringArmOriginX("c0101"), 
													self.CameraFocusCfgMap:GetSpringArmOriginY("c0101"), 
													self.CameraFocusCfgMap:GetSpringArmOriginZ("c0101"), bInterp)
	local FovY = CameraUtil.FOVXToFOVY(self.CameraFocusCfgMap:GetOriginFOV("c0101"), 16/9)
	self.Common_Render2D_UIBP:SetFOVY(FovY)
	self.Common_Render2D_UIBP:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self:ResettModelSpringArm()
	self:ClearPreView()
	self.ViewModel.bIsHoldWeapon = false
end

function PreviewMountView:ResettModelSpringArm()
	if nil == self.CameraFocusCfgMap then return end
	local DefaultArmDistance = 350--self.CameraFocusCfgMap:GetSpringArmDistance("c0101")
	self.Common_Render2D_UIBP:SetSpringArmLocation(100, 0, 106, true)
	self.Common_Render2D_UIBP:SetSpringArmCompArmLength(DefaultArmDistance + 100)
	self.Common_Render2D_UIBP:EnableRotator(true)
	self.Common_Render2D_UIBP:SetModelRotation(0, 0 , 0, true)
	self.Common_Render2D_UIBP:SetSpringArmCenterOffsetY(80)
    self.Common_Render2D_UIBP:SetSpringArmDistance(DefaultArmDistance + 100, true)
	-- 应策划要求禁用缩放
	self.Common_Render2D_UIBP:EnableZoom(false)
end

function PreviewMountView:ClearPreView()
	--self.PreViewMap = {}
	self.Common_Render2D_UIBP:ResumeAvatar()
end

-- 音效控制
function PreviewMountView:OnShowBGM(_, State)
	self.ViewModel.IsShowBGM = State == _G.UE.EToggleButtonState.Checked

	if not self.ViewModel.IsShowBGM then
		self:StopBGM()
	else
		self:PlayBGM()
	end
end

function PreviewMountView:StopBGM()
	if self.PlayingID then
		_G.UE.UAudioMgr:Get():StopBGM(self.PlayingID)
		if _G.MountMgr:IsInRide() then
			_G.MountMgr:PlayMountBGM()
		end
		self.PlayingID = nil
	end
end

function PreviewMountView:PlayBGM()
	local Mount = self.ViewModel.AllMountMp[self.ViewModel.SelectedMountID]
	if Mount == nil then
		return
	end

	--先停止原来的BGM
	if self.PlayingID then
		_G.UE.UAudioMgr:Get():StopBGM(self.PlayingID)
	end

	-- local TempBgmCfg = BgmCfg:FindCfgByKey(Mount.BgmID)
	if _G.MountMgr:IsInRide() then
		_G.MountMgr:StopMountBGM()
	end
	self.PlayingID =_G.UE.UAudioMgr:Get():PlayBGM(tonumber(Mount.BgmID), _G.UE.EBGMChannel.UI)
end

function PreviewMountView:UpdateSkillItem()
	local RideCfgData = RideCfg:FindCfgByKey(self.ViewModel.SelectedMountID)
	if RideCfgData == nil or nil == RideCfgData.PlayAction then return end
	if nil == RideCfgData.PlayAction[1] then
		self.ViewModel.IsShowSkillItem = false
		return
	end
	self.ViewModel.IsShowSkillItem = true
	
	local SkillList = {}
	for k, v in pairs(RideCfgData.PlayAction) do
		if nil ~= v and 0 ~= v then
			local RideSkillCfgData = RideSkillCfg:FindCfgByKey(v)
			if nil ~= RideSkillCfgData then
				table.insert(SkillList, {ID = v, Cfg = RideSkillCfgData, ViewModel = self.ViewModel})
			end
		end
	end
	self.ViewModel.ActionTableList = SkillList
end

-- 空白处关掉技能弹窗
function PreviewMountView:OnSkillTipsBGClick()
	if SkillTipsMgr:HideMountSkillTips() then
		self.ViewModel.IsShowSkillTips = false
		self.ViewModel.SkillTagList = nil
		_G.EventMgr:SendEvent(_G.EventID.ActionSelectChanged, { ID = 0 } )
	end
end

function PreviewMountView:OnActionTableViewSelectChange(Params)

end

function PreviewMountView:SetLight()
	local LightCfg = SystemLightCfg:FindCfgByKey(31)
	local PathList = LightCfg and LightCfg.LightPresetPaths or nil
	if not PathList then return end
	local LightPresetPath = PathList[1]
	self.Common_Render2D_UIBP:ResetLightPreset(LightPresetPath)
end

function PreviewMountView:InitPanelStaticText()
	self.TextTitle:SetText(LSTR(1090037))
	self.TextRide:SetText(LSTR(1090036))
end

return PreviewMountView