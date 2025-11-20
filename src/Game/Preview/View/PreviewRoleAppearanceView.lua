---
--- Author: rock
--- DateTime: 2025-3-3 11:06
--- Description:时装预览界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

local PreviewRoleAppearanceVM = require("Game/Preview/VM/PreviewRoleAppearanceVM")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ItemCfg = require("TableCfg/ItemCfg")

local StoreMall = ProtoRes.StoreMall
local avatar_personal = ProtoCommon.avatar_personal
local ItemMainType = ProtoCommon.ItemMainType
local EquipmentType = ProtoRes.EquipmentType

---@class PreviewRoleAppearanceView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnEquipment UToggleButton
---@field BtnHand UToggleButton
---@field BtnHat UToggleButton
---@field BtnOrgan UToggleButton
---@field BtnPose UToggleButton
---@field BtnSwitch UToggleButton
---@field CloseBtn CommonCloseBtnView
---@field CommonTitle CommonTitleView
---@field ImgDisable3 UFImage
---@field PanelMask3 UFCanvasPanel
---@field PanelRoleBtn UFVerticalBox
---@field StoreRender2D StoreRender2DView
---@field TableViewSlot UTableView
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PreviewRoleAppearanceView = LuaClass(UIView, true)

function PreviewRoleAppearanceView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnEquipment = nil
	--self.BtnHand = nil
	--self.BtnHat = nil
	--self.BtnOrgan = nil
	--self.BtnPose = nil
	--self.BtnSwitch = nil
	--self.CloseBtn = nil
	--self.CommonTitle = nil
	--self.ImgDisable3 = nil
	--self.PanelMask3 = nil
	--self.PanelRoleBtn = nil
	--self.StoreRender2D = nil
	--self.TableViewSlot = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PreviewRoleAppearanceView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.StoreRender2D)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PreviewRoleAppearanceView:OnInit()
	self:InitPanelStaticText()
	self.DefaultModelGender = nil
	self.CurrentModelGender = nil
	self.CommRender2D = self.StoreRender2D:GetCommonRender2D()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if nil ~= AvatarComp then
        self.AttachType = AvatarComp:GetAttachTypeIgnoreChangeRole()
		self.NPCEntityID = nil
    end
	self.EquipTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnEquipPartSelectChanged, true, false)
end

function PreviewRoleAppearanceView:InitPanelStaticText()
	self.CommonTitle:SetTextTitleName(LSTR(950051))
end

function PreviewRoleAppearanceView:OnDestroy()

end

function PreviewRoleAppearanceView:OnShow()
	_G.LightMgr:EnableUIWeather(2)
	_G.BuoyMgr:ShowAllBuoys(false)

	self.IsFirstShowView = true
	self.StoreRender2D.bPerviewPanel = true
	self.StoreRender2D.CameraCenterOffsetY = 0 --预览不需要在全镜头下做向左偏移，因为要居中
	self.CommRender2D.bAutoInitSpringArm = false
	
	self:OnInitBtnState()

	-- 设置角色原始外观数据
	self.DefaultModelGender = MajorUtil.GetMajorGender()
	self.CurrentModelGender = self.DefaultModelGender
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil ~= RoleSimple then
		self.StoreRender2D:SetRawAvatar(RoleSimple.Avatar)
	end

	-- 设置当前预览的外观染色数据
	self.StoreRender2D:SetAppearRegionDyesInfo(PreviewRoleAppearanceVM.RegionDyesList)

	local EntityID = MajorUtil.GetMajorEntityID()
	self:CreateRenderActor(EntityID, true)

	-- 右边预览装备列表
	self:CheckGenderModel(PreviewRoleAppearanceVM.GenderLimit)
	self:WearSuit()

	--检查是否要显示头盔机关按钮
	self:UpdateNeedShowHatOrgan()
end

function PreviewRoleAppearanceView:OnInitBtnState()
	self.PreviewEquipIndex = 1 
	self.PreviewEquipementData = nil
	self.bIsShowPreviewEquip = true -- 预览的装备显隐状态

	--下面这块逻辑其实目前和VM初始化数据一样，所以不会触发后面的change逻辑
	--1、初始化左侧按钮状态
	--2、模型部件的显隐(此时模型没加载，但StoreRender2D里面会记录部件显隐状态，模型加载完StoreRender2D会根据记录的状态处理部件显隐)
	PreviewRoleAppearanceVM.bIsAllCameraState = true
	PreviewRoleAppearanceVM.bIsShowWeapon = true
	PreviewRoleAppearanceVM.bIsHoldWeapon = false
	PreviewRoleAppearanceVM.bIsShowHat = true
	PreviewRoleAppearanceVM.bIsShowHatOrgan = false
	PreviewRoleAppearanceVM.bIsShowRawAvatar = false
end

function PreviewRoleAppearanceView:OnHide()
	--重置选中的图标状态
	PreviewRoleAppearanceVM:ChangeEquipPart(nil, false)
	PreviewRoleAppearanceVM:ResetInitState()

	self.CommRender2D:SwitchOtherLights(true)
	_G.LightMgr:DisableUIWeather()
	_G.BuoyMgr:ShowAllBuoys(true)

	self.IsFirstShowView = false
end

function PreviewRoleAppearanceView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.BtnSwitch, self.OnChangedToggleBtnSwitch)
	UIUtil.AddOnStateChangedEvent(self, self.BtnHand, self.OnChangedBtnHand)
	UIUtil.AddOnStateChangedEvent(self, self.BtnPose, self.OnChangedBtnPose)
	UIUtil.AddOnStateChangedEvent(self, self.BtnHat, self.OnChangedToggleBtnHat)
	UIUtil.AddOnStateChangedEvent(self, self.BtnOrgan, self.OnChangedToggleBtnOrgan)
	UIUtil.AddOnStateChangedEvent(self, self.BtnEquipment, self.OnChangedToggleBtnEquipment)
end

function PreviewRoleAppearanceView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
end

function PreviewRoleAppearanceView:OnRegisterBinder()
	self.Binders = {
		{ "EquipPartList", 				UIBinderUpdateBindableList.New(self, self.EquipTableViewAdapter) },
		{ "ProductName", 				UIBinderSetText.New(self, self.TextName) },

		{ "bIsAllCameraState", 			UIBinderSetIsChecked.New(self, self.BtnSwitch) },
		{ "bIsShowWeapon", 			UIBinderSetIsChecked.New(self, self.BtnHand) },
		{ "bIsHoldWeapon", 				UIBinderSetIsChecked.New(self, self.BtnPose) },
		{ "bIsShowHat", 				UIBinderSetIsChecked.New(self, self.BtnHat) },
		{ "bIsShowHatOrgan", 			UIBinderSetIsChecked.New(self, self.BtnOrgan) },
		{ "bIsShowRawAvatar", 			UIBinderSetIsChecked.New(self, self.BtnEquipment) },

		{ "bIsShowHat",                 UIBinderValueChangedCallback.New(self, nil, self.OnIsShowHatChanged) },
		{ "bIsShowHatOrgan",            UIBinderValueChangedCallback.New(self, nil, self.OnIsShowHatOrganChanged) },
		{ "bIsShowRawAvatar",            UIBinderValueChangedCallback.New(self, nil, self.OnbIsShowRawAvatarChanged) },
	}
	self:RegisterBinders(PreviewRoleAppearanceVM, self.Binders)
end

function PreviewRoleAppearanceView:CreateRenderActor(EntityID)
	local Callback = function() 
		--self:OnChangedToggleBtnOrgan(nil, _G.UE.EToggleButtonState.UnChecked, nil)
		--self:OnChangedToggleBtnEquipment(nil, _G.UE.EToggleButtonState.UnChecked, nil)
		--注：需要Callback时，组件执行了CameraFocusCfgMap:SetAssetUserData才行，否则在StoreRender2DView:FocusView-->CameraFocusCfgMap:GetCfgByRaceAndProf时没部件的UserData数据
	end
	self.StoreRender2D:CreateRenderActor({EntityID = EntityID, SystemLightID = 29, Callback = Callback, bSyncLoad = true})
end

function PreviewRoleAppearanceView:OnAssembleAllEnd(Params)
	-- local ObjType = Params.IntParam1
	-- local IsUIActor = Params.BoolParam1
	if Params.ULongParam1 == ActorUtil.GetActorEntityID(self.CommRender2D.ChildActor) then
		if self.IsFirstShowView then
			if PreviewRoleAppearanceVM.IsPreviewSuit then
				--- 预览套装时切换全身镜头
				self:SwitchHalfBodyView(1)
			else
				self.EquipTableViewAdapter:SetSelectedIndex(1)
			end
			self.IsFirstShowView = false
		end
		self:UpdateWeaponPose()
		self:UpdateWeaponHideState()
		--更新灯光预设
		self.CommRender2D:UpdateAllLights()
	end
end

--- 切换角色外观pose
function PreviewRoleAppearanceView:UpdateWeaponPose()
	if self.PreviewEquipementData == nil then
		return
	end
	local PreviewEqtCfg = EquipmentCfg:FindCfgByKey(self.PreviewEquipementData.EquipmentID)
	if PreviewEqtCfg == nil then
		return
	end
	if not (PreviewEqtCfg.ItemMainType == ItemMainType.ItemArm or PreviewEqtCfg.ItemMainType == ItemMainType.ItemTool) then
		return
	end

	local EyeBtnState = PreviewRoleAppearanceVM:GetEquipPartEyeBtnState(self.PreviewEquipIndex)
	local ProfID = MajorUtil.GetMajorProfID()
	if EyeBtnState then
		ProfID = self:GetWeaponProfID(PreviewEqtCfg.AppearanceID)
	end
	--武器、工具装备默认拔出
	PreviewRoleAppearanceVM.bIsHoldWeapon = true
	self.CommRender2D:HoldOnWeapon(PreviewRoleAppearanceVM.bIsHoldWeapon)
	self.CommRender2D:OnProfSwitch({ProfID = ProfID})
end

function PreviewRoleAppearanceView:GetWeaponProfID(AppID)
    local TempItemCfg = ItemCfg:FindCfgByKey(WardrobeUtil.GetWeaponEquipIDByAppearanceID(AppID))
    return TempItemCfg and TempItemCfg.ProfLimit[1] or MajorUtil.GetMajorProfID()
end

--- 预览发型
function PreviewRoleAppearanceView:OnPreViewHair(HairID)
	local UIComplexCharacter = self.CommRender2D.UIComplexCharacter
	if UIComplexCharacter then
		UIComplexCharacter:SetAvatarPartCustomize(avatar_personal.AvatarPersonalHair, HairID)
	end
end


function PreviewRoleAppearanceView:CheckGenderModel(GenderLimit)
	if nil == GenderLimit or GenderLimit == 0 or GenderLimit == self.DefaultModelGender then
		self:ResetToDefaultGenderModel()
	else
		self:SwitchToOppositeGenderModel()
	end
end

function PreviewRoleAppearanceView:SwitchToOppositeGenderModel()
	if self.CurrentModelGender ~= self.DefaultModelGender then
		return
	end 
	self.CurrentModelGender = self.DefaultModelGender == ProtoCommon.role_gender.GENDER_MALE and ProtoCommon.role_gender.GENDER_FEMALE or
		ProtoCommon.role_gender.GENDER_MALE
	self.StoreRender2D:SwitchToPresetModel(MajorUtil.GetMajorRaceID(), self.CurrentModelGender)
end

function PreviewRoleAppearanceView:ResetToDefaultGenderModel()
	if self.CurrentModelGender == self.DefaultModelGender then
		return
	end
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	self.StoreRender2D:ResetToDefaultModel(RoleSimple)
	self.CurrentModelGender = self.DefaultModelGender
end

--- 预览装备列表
function PreviewRoleAppearanceView:WearSuit()
	-- if self.IsHidePlayer then 
	-- 	return
	-- end
	local EquipPartList = PreviewRoleAppearanceVM.EquipPartList.Items
	local Gender = self.CurrentModelGender
	local IsMale = Gender == ProtoCommon.role_gender.GENDER_MALE

	local SuitData = {}
	local Start, End, Step
	if IsMale then
		Start, End, Step = #EquipPartList, 1, -1  -- 倒序遍历
	else  
		Start, End, Step = 1, #EquipPartList, 1  -- 正序遍历
	end
	for i = Start, End, Step do
		local TempItemData = EquipPartList[i]
		local IsCanPreView = true

		-- 确定内层循环的起始和结束值
		local KStart, KEnd, KStep
		if IsMale then
			KStart, KEnd, KStep = #EquipPartList, i + 1, -1
		else
			KStart, KEnd, KStep = 1, i - 1, 1
		end

		for k = KStart, KEnd, KStep do
			if EquipPartList[k].Part == TempItemData.Part then
				EquipPartList[i].SelectBtnState = true
				EquipPartList[i].IsMask = true
				IsCanPreView = false
				break
			end
		end

		if IsCanPreView then
			--- 当前选中头部装备是否可调整特殊效果
			--- 禁用头部装饰功能  暂时不做
			-- if TempItemData.Part == EquipmentPartList.EQUIP_PART_HEAD then
			-- 	self:OnCheckBtnHatStyleDisabled(TempItemData.ResID)
			-- end
			table.insert(SuitData, TempItemData)
			PreviewRoleAppearanceVM.EquipPartList.Items[i].bSelected = true
		end
	end
	self.StoreRender2D:WearSuit(SuitData)
end

--- 全身/半身镜头切换
function PreviewRoleAppearanceView:SwitchHalfBodyView(Part)
	--- 1 全身  2 半身  使用部位镜头
	Part = Part == 1 and 0 or 3
	if Part == 0 then
		self.StoreRender2D:ResetView(true)
	else
		self:FocusView(Part)
	end
end

-- 展示对应部位镜头
function PreviewRoleAppearanceView:FocusView(Part)
	self.StoreRender2D:FocusView(Part)
end

function PreviewRoleAppearanceView:CheckEnableZoom()
	if self.EnableZoomTimerID ~= nil then
		self:UnRegisterTimer(self.EnableZoomTimerID)
		self.EnableZoomTimerID = nil
	end
	self.EnableZoomTimerID = self:RegisterTimer(
		function()
			self.CommRender2D:EnableZoom(true)
			self.EnableZoomTimerID = nil
		end, 0.5, 0, 1)
end

-----------------------------------------右边装备列表 start-------------------------------------------------------------------
--- 点击装备部位
function PreviewRoleAppearanceView:OnEquipPartSelectChanged(Index, ItemData, ItemView)
	self.PreviewEquipIndex = Index
	self.PreviewEquipementData = ItemData
	if ItemView ~= nil and ItemView.IsClickBtnView then
		if not ItemData.SelectBtnState then
			self.StoreRender2D:TakeOffAppear(ItemData.Part, true)
			self.bIsShowPreviewEquip = false
		else
			--- 预览时隐藏其他相同部位装备
			local EquipPartList = PreviewRoleAppearanceVM.EquipPartList.Items
			for _, value in ipairs(EquipPartList) do
				if value.Part == ItemData.Part then
					value.SelectBtnState = true
					value.IsMask = true
				end
			end
			self.StoreRender2D:WearAppearance(ItemData, true)
			self.bIsShowPreviewEquip = true
		end
		ItemData.SelectBtnState = not ItemData.SelectBtnState
		ItemData.IsMask = ItemData.SelectBtnState or ItemData.bOwned
		ItemView.IsClickBtnView = false
	else
		local PreviewEqtCfg = EquipmentCfg:FindCfgByKey(self.PreviewEquipementData.EquipmentID)
		--检查是否武器
		--武器特殊处理：1、镜头注视点检测范围变大(动作幅度大，镜头跟不上骨骼速度，永远达不到注视目标范围的0.1)   2、默认显示素体
		if PreviewEqtCfg ~= nil then
			if PreviewEqtCfg.ItemMainType == ItemMainType.ItemArm or PreviewEqtCfg.ItemMainType == ItemMainType.ItemTool then
				self.CommRender2D.TargetPositionOffsetRange = 2.0
				PreviewRoleAppearanceVM.bIsShowRawAvatar = true
			end
		end

		--- 切换部位镜头
		self:FocusView(ItemData.Part)
		if ItemData.Part == ProtoCommon.equip_part.EQUIP_PART_BODY_HAIR then
			if PreviewRoleAppearanceVM.TabSelecteType == StoreMall.STORE_MALL_MYSTERYBOX then
				self.TextName:SetText(ItemData.Name .. "\n" .. PreviewRoleAppearanceVM.ProductName)
			end
		end
		self.StoreRender2D:WearAppearance(ItemData, true)
		
		PreviewRoleAppearanceVM.bIsAllCameraState = false
		ItemData.IsMask = ItemData.bOwned
		if ItemData.SelectBtnState then
			--- 预览时隐藏其他相同部位装备
			local EquipPartList = PreviewRoleAppearanceVM.EquipPartList.Items
			for _, value in ipairs(EquipPartList) do
				if value.Part == ItemData.Part then
					value.SelectBtnState = true
					value.IsMask = true
				end
			end
		end
		ItemData.SelectBtnState = false	--- 切换时强制显示
		ItemData.IsMask = false
		PreviewRoleAppearanceVM:ChangeEquipPart(nil, false)
		PreviewRoleAppearanceVM:ChangeEquipPart(Index, true)
		self.bIsShowPreviewEquip = true
	end
end
-----------------------------------------右边装备列表 end---------------------------------------------------------------------

-----------------------------------------左边按钮列表 start-------------------------------------------------------------------
--- 全/半身视角切换
function PreviewRoleAppearanceView:OnChangedToggleBtnSwitch(ToggleGroup, ToggleButton, BtnState)
	PreviewRoleAppearanceVM.bIsAllCameraState = ToggleButton == _G.UE.EToggleButtonState.Checked
	if not PreviewRoleAppearanceVM.bIsAllCameraState then
		--- 上一次选中的部位镜头
		-- self.EquipTableViewAdapter:SetSelectedIndex(self.PreviewEquipIndex)
		local TempEquipItem = self.EquipTableViewAdapter:GetItemDataByIndex(self.PreviewEquipIndex)
		PreviewRoleAppearanceVM:ChangeEquipPart(self.PreviewEquipIndex, true)
		self:FocusView(TempEquipItem.Part)
	else
		--- 全身镜头
		self.StoreRender2D:ResetView(true)
	end
	-- self.CommRender2D:EnableZoom(false)
end

-- 手上武器，套件默认隐藏，散件默认显示(拔刀状态时，武器强制显示)
function PreviewRoleAppearanceView:OnChangedBtnHand(ToggleGroup, ToggleButton, BtnState)
	PreviewRoleAppearanceVM.bIsShowWeapon = ToggleButton == _G.UE.EToggleButtonState.Checked 
	-- self.CommRender2D:HideWeapon(not PreviewRoleAppearanceVM.bIsShowWeapon)
	self:UpdateWeaponHideState()
end

--- 武器拔出/收起状态，套件默认收起，散件默认拔出(拔刀状态时，武器强制显示)
function PreviewRoleAppearanceView:OnChangedBtnPose(ToggleGroup, ToggleButton, BtnState)
	PreviewRoleAppearanceVM.bIsHoldWeapon = ToggleButton == _G.UE.EToggleButtonState.Checked
	self.CommRender2D:HoldOnWeapon(PreviewRoleAppearanceVM.bIsHoldWeapon)
	self:UpdateWeaponHideState()
end

--- 头部装备显隐，默认显示
function PreviewRoleAppearanceView:OnChangedToggleBtnHat(ToggleGroup, ToggleButton, BtnState)
	PreviewRoleAppearanceVM.bIsShowHat = ToggleButton == _G.UE.EToggleButtonState.Checked
end

function PreviewRoleAppearanceView:OnIsShowHatChanged(bIsShowHat)
	self.StoreRender2D:HideHelmet(not bIsShowHat)
	if bIsShowHat then
		self.StoreRender2D:SwitchHelmet(PreviewRoleAppearanceVM.bIsShowHatOrgan)
	end
end

--- 头部装备机关，默认关
function PreviewRoleAppearanceView:OnChangedToggleBtnOrgan(ToggleGroup, ToggleButton, BtnState)
	if not PreviewRoleAppearanceVM.bEnableHatOrganBtn then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1050226))
		return
	end
	PreviewRoleAppearanceVM.bIsShowHatOrgan = ToggleButton == _G.UE.EToggleButtonState.Checked
end

function PreviewRoleAppearanceView:OnIsShowHatOrganChanged(bIsShowHatOrgan)
	self.StoreRender2D:SwitchHelmet(bIsShowHatOrgan)
end

-- 头部装备机关的按钮状态
function PreviewRoleAppearanceView:UpdateNeedShowHatOrgan()
	if not PreviewRoleAppearanceVM.bEnableHatOrganBtn then
		self.BtnOrgan:SetCheckedState(_G.UE.EToggleButtonState.Locked,false)
	end
end

--- 素体，开-显示原有装备/关-隐藏原有装备
function PreviewRoleAppearanceView:OnChangedToggleBtnEquipment(ToggleGroup, ToggleButton, BtnState)
	if self.DefaultModelGender ~= self.CurrentModelGender then
		-- 异性角色禁止原装备显示
		_G.MsgTipsUtil.ShowTipsByID(138007)
		PreviewRoleAppearanceVM.bIsShowRawAvatar = false
		self.BtnEquipment:SetChecked(false) -- UToggleButton::SlateOnToggleButtonClicked会默认切换按钮状态，这里强制给他切走
		return
	end
	PreviewRoleAppearanceVM.bIsShowRawAvatar = ToggleButton == _G.UE.EToggleButtonState.Checked
end

function PreviewRoleAppearanceView:OnbIsShowRawAvatarChanged(bIsShowRawAvatar)
	self.StoreRender2D:SetRawEquipsVisible(bIsShowRawAvatar)
end
-----------------------------------------左边按钮列表事件 end----------------------------------------------------------------------

------------------------------------------------------武器显隐--------------------------------------------------------------------
-- 判断是否隐藏主手武器，拔刀必定显示武器
-- 生产职业预览副手，隐藏主手
function PreviewRoleAppearanceView:IsHideMasterHand()
	local bIsHideWeapon = not (PreviewRoleAppearanceVM.bIsShowWeapon or PreviewRoleAppearanceVM.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local SelectSlotPart = self.PreviewEquipementData and self.PreviewEquipementData.Part or 0
	local bIsPreviewSlaveHand = SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND

	local TempHideMasterHand, TempHideSlaveHand = self:GetTwoHandWeaponHideState()
	return bIsHideWeapon or (bIsProductProf and bIsPreviewSlaveHand) or TempHideMasterHand
end

-- 判断是否隐藏副手武器，拔刀必定显示武器
-- 生产职业非预览副手状态隐藏副手
function PreviewRoleAppearanceView:IsHideSlaveHand()
	local bIsHideWeapon = not (PreviewRoleAppearanceVM.bIsShowWeapon or PreviewRoleAppearanceVM.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local SelectSlotPart = self.PreviewEquipementData and self.PreviewEquipementData.Part or 0
	local bIsPreviewSlaveHand = SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND

	local TempHideMasterHand, TempHideSlaveHand = self:GetTwoHandWeaponHideState()
	return bIsHideWeapon or (bIsProductProf and not bIsPreviewSlaveHand) or TempHideSlaveHand
end

-- 判断是否隐藏主手武器挂件，继承主手武器隐藏状态，但只有拔刀时才显示
function PreviewRoleAppearanceView:IsHideAttachMasterHand()
	return self:IsHideMasterHand() or not PreviewRoleAppearanceVM.bIsHoldWeapon
end

-- 判断是否隐藏副手武器挂件，继承副手武器隐藏状态，但只有拔刀时才显示
function PreviewRoleAppearanceView:IsHideAttachSlaveHand()
	return self:IsHideSlaveHand() or not PreviewRoleAppearanceVM.bIsHoldWeapon
end

-- 预览武器时，原始武器是剑+盾双手组合时，处理主副手武器的隐藏规则
function PreviewRoleAppearanceView:GetTwoHandWeaponHideState()
	if self.PreviewEquipementData == nil then
		return
	end
	local PreviewEqtCfg = EquipmentCfg:FindCfgByKey(self.PreviewEquipementData.EquipmentID)
	if PreviewEqtCfg == nil then
		return
	end

	--显示原始装备时，主副手都要显示武器
	if not self.bIsShowPreviewEquip then
		return false, false
	end

	--当前角色的原始主、副武器
	local MasterHandEquipData = nil
	local SlaveHandEquipData = nil
	if self.StoreRender2D.RawEquips[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND] ~= nil then
		MasterHandEquipData = EquipmentCfg:FindCfgByKey(self.StoreRender2D.RawEquips[ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND].EquipID)
	end
	if self.StoreRender2D.RawEquips[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND] ~= nil then
		SlaveHandEquipData = EquipmentCfg:FindCfgByKey(self.StoreRender2D.RawEquips[ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND].EquipID)
	end

	if PreviewEqtCfg.Part == ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND then
		--预览的是主手武器时，处理副手武器要不要隐藏
		--主手剑+副手盾可组合，副手武器不是盾，则要隐藏副手武器
		if SlaveHandEquipData ~= nil then
			if PreviewEqtCfg.EquipmentType ~= EquipmentType.ONE_HAND_SWORD or 
			(PreviewEqtCfg.EquipmentType == EquipmentType.ONE_HAND_SWORD and SlaveHandEquipData.EquipmentType ~= EquipmentType.ONE_HAND_SHIELD) then
				return false, true
		end
	end
	elseif PreviewEqtCfg.Part == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND then
		--预览的是副手武器，处理主手武器要不要隐藏
		--主手剑+副手盾可组合，主手不是剑，则把主手武器隐藏掉
		if MasterHandEquipData ~= nil then
			if PreviewEqtCfg.EquipmentType ~= EquipmentType.ONE_HAND_SHIELD or 
			(PreviewEqtCfg.EquipmentType == EquipmentType.ONE_HAND_SHIELD and MasterHandEquipData.EquipmentType ~= EquipmentType.ONE_HAND_SWORD) then
				return true, false
			end
		end
	end
	return false, false
end

function PreviewRoleAppearanceView:UpdateWeaponHideState()
	local bHideMasterHand = self:IsHideMasterHand()
	local bHideSlaveHand = self:IsHideSlaveHand()
	self.CommRender2D:HideMasterHand(bHideMasterHand)
	self.CommRender2D:HideSlaveHand(bHideSlaveHand)

	local PreviewEqtCfg = nil
	if self.PreviewEquipementData ~= nil then
		PreviewEqtCfg = EquipmentCfg:FindCfgByKey(self.PreviewEquipementData.EquipmentID)
	end
	--生产工具的主武器，默认隐藏主\副挂件
	if PreviewEqtCfg and PreviewEqtCfg.ItemMainType == ItemMainType.ItemTool then
		self.CommRender2D:HideAttachMasterHand(true)
		self.CommRender2D:HideAttachSlaveHand(true)
	-- else
	-- 	self.CommRender2D:HideAttachMasterHand(self:IsHideAttachMasterHand())
	-- 	self.CommRender2D:HideAttachSlaveHand(self:IsHideAttachSlaveHand())
	end
end

---------------------------------------------------武器显隐--------------------------------------------------------------------

return PreviewRoleAppearanceView