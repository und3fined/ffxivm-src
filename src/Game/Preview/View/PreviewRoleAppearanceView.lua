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
local StoreMgr = require("Game/Store/StoreMgr")
local ActorUtil = require("Utils/ActorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")

-- local SCS_FinalColorLDRHasAlpha = _G.UE.ESceneCaptureSource.SCS_FinalColorLDRHasAlpha or 3
local StoreMall = ProtoRes.StoreMall
local avatar_personal = ProtoCommon.avatar_personal

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
---@field PanelRoleBtn UFVerticalBox
---@field StoreRender2D StoreRender2DView
---@field TableViewSlot UTableView
---@field TextName UFTextBlock
---@field TextTitle UFTextBlock
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
	--self.PanelRoleBtn = nil
	--self.StoreRender2D = nil
	--self.TableViewSlot = nil
	--self.TextName = nil
	--self.TextTitle = nil
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
	self.CommRender2D = self.StoreRender2D:GetCommonRender2D()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    if nil ~= AvatarComp then
        self.AttachType = AvatarComp:GetAttachTypeIgnoreChangeRole()
		self.NPCEntityID = nil
		-- if self.AttachType ~= nil then
		-- 	self.NPCEntityID = StoreMgr:CreatNPCAndGetNPCModelEntityID(self.AttachType) --异性角色模型ID
		-- end
    end
	self.EquipTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnEquipPartSelectChanged, true, false)
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
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil ~= RoleSimple then
		self.StoreRender2D:SetRawAvatar(RoleSimple.Avatar)
	end

	local EntityID = PreviewRoleAppearanceVM.IsMajorSameGender and MajorUtil.GetMajorEntityID() or self.NPCEntityID
	self:CreateRenderActor(EntityID)

	-- 右边预览装备列表
	self:WearSuit()

	--检查是否要显示头盔机关按钮
	self:UpdateNeedShowHatOrgan()
end

function PreviewRoleAppearanceView:OnInitBtnState()
	self.PreviewEquipIndex = 1 

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
		{ "TitleText", 				UIBinderSetText.New(self, self.TextTitle) },
		{ "ProductName", 				UIBinderSetText.New(self, self.TextName) },

		{ "bIsAllCameraState", 			UIBinderSetIsChecked.New(self, self.BtnSwitch) },
		{ "bIsShowWeapon", 			UIBinderSetIsChecked.New(self, self.BtnHand) },
		{ "bIsHoldWeapon", 				UIBinderSetIsChecked.New(self, self.BtnPose) },
		{ "bIsShowHat", 				UIBinderSetIsChecked.New(self, self.BtnHat) },
		{ "bIsShowHatOrgan", 			UIBinderSetIsChecked.New(self, self.BtnOrgan) },
		{ "bIsShowRawAvatar", 			UIBinderSetIsChecked.New(self, self.BtnEquipment) },
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
		self:UpdateWeaponHideState()
		--更新灯光预设
		self.CommRender2D:UpdateAllLights()
	end
end

--- 预览发型
function PreviewRoleAppearanceView:OnPreViewHair(HairID)
	local UIComplexCharacter = self.CommRender2D.UIComplexCharacter
	if UIComplexCharacter then
		UIComplexCharacter:SetAvatarPartCustomize(avatar_personal.AvatarPersonalHair, HairID)
	end
end

--- 预览装备列表
function PreviewRoleAppearanceView:WearSuit()
	-- if self.IsHidePlayer then 
	-- 	return
	-- end
	local EquipPartList = PreviewRoleAppearanceVM.EquipPartList.Items
	local Gender = MajorUtil.GetMajorGender()
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
	if ItemView ~= nil and ItemView.IsClickBtnView then
		if not ItemData.SelectBtnState then
			self.StoreRender2D:TakeOffAppear(ItemData.Part, true)
		else
			--- 预览时隐藏其他相同部位装备
			local EquipPartList = PreviewRoleAppearanceVM.EquipPartList.Items
			for _, value in ipairs(EquipPartList) do
				if value.Part == ItemData.Part then
					value.SelectBtnState = true
					value.IsMask = true
				end
			end
			self.StoreRender2D:WearAppearance(ItemData)
		end
		ItemData.SelectBtnState = not ItemData.SelectBtnState
		ItemData.IsMask = ItemData.SelectBtnState or ItemData.bOwned
		ItemView.IsClickBtnView = false
	else
		--- 切换部位镜头
		self:FocusView(ItemData.Part)
		if ItemData.Part == ProtoCommon.equip_part.EQUIP_PART_BODY_HAIR then
			if PreviewRoleAppearanceVM.TabSelecteType == StoreMall.STORE_MALL_MYSTERYBOX then
				self.TextName:SetText(ItemData.Name .. "\n" .. PreviewRoleAppearanceVM.ProductName)
			end
		end
		--武器部件默认拔出
		if ItemData.Part == ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND or ItemData.Part == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND then
			self:OnChangedBtnPose(nil, _G.UE.EToggleButtonState.Checked, nil)
		end

		self.StoreRender2D:WearAppearance(ItemData)
		self.PreviewEquipIndex = Index
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

-- 手上武器，套件默认隐藏，散件默认显示
function PreviewRoleAppearanceView:OnChangedBtnHand(ToggleGroup, ToggleButton, BtnState)
	PreviewRoleAppearanceVM.bIsShowWeapon = ToggleButton == _G.UE.EToggleButtonState.Checked 
	-- self.CommRender2D:HideWeapon(not PreviewRoleAppearanceVM.bIsShowWeapon)
	self:UpdateWeaponHideState()
end

--- 武器拔出/收起状态，套件默认收起，散件默认拔出
function PreviewRoleAppearanceView:OnChangedBtnPose(ToggleGroup, ToggleButton, BtnState)
	PreviewRoleAppearanceVM.bIsHoldWeapon = ToggleButton == _G.UE.EToggleButtonState.Checked
	self.CommRender2D:HoldOnWeapon(PreviewRoleAppearanceVM.bIsHoldWeapon)
	self:UpdateWeaponHideState()
end

--- 头部装备显隐，默认显示
function PreviewRoleAppearanceView:OnChangedToggleBtnHat(ToggleGroup, ToggleButton, BtnState)
	PreviewRoleAppearanceVM.bIsShowHat = ToggleButton == _G.UE.EToggleButtonState.Checked
	self.CommRender2D:HideHead(not PreviewRoleAppearanceVM.bIsShowHat)
	if PreviewRoleAppearanceVM.bIsShowHat then
		self:UpdateSwitchHelmet(PreviewRoleAppearanceVM.bIsShowHatOrgan, false)
	end
end

--- 头部装备机关，默认关
function PreviewRoleAppearanceView:OnChangedToggleBtnOrgan(ToggleGroup, ToggleButton, BtnState)
	local IsCheck = ToggleButton == _G.UE.EToggleButtonState.Checked
	self:UpdateSwitchHelmet(IsCheck, true)
end

function PreviewRoleAppearanceView:UpdateSwitchHelmet(IsCheck, IsShowTips)
	if not PreviewRoleAppearanceVM.bEnableHatOrganBtn then
		if IsShowTips then
			_G.MsgTipsUtil.ShowTips(_G.LSTR(1050226))
		end
		return
	end
	PreviewRoleAppearanceVM.bIsShowHatOrgan = IsCheck
	self.CommRender2D:SwitchHelmet(PreviewRoleAppearanceVM.bIsShowHatOrgan)
end

-- 头部装备机关的按钮状态
function PreviewRoleAppearanceView:UpdateNeedShowHatOrgan()
	if not PreviewRoleAppearanceVM.bEnableHatOrganBtn then
		self.BtnOrgan:SetCheckedState(_G.UE.EToggleButtonState.Locked,false)
	end
end

--- 素体，开-显示原有装备/关-隐藏原有装备
function PreviewRoleAppearanceView:OnChangedToggleBtnEquipment(ToggleGroup, ToggleButton, BtnState)
	PreviewRoleAppearanceVM.bIsShowRawAvatar = ToggleButton == _G.UE.EToggleButtonState.Checked
	self.StoreRender2D:SetRawEquipsVisible(PreviewRoleAppearanceVM.bIsShowRawAvatar)
end
-----------------------------------------左边按钮列表事件 end----------------------------------------------------------------------

------------------------------------------------------武器显隐--------------------------------------------------------------------
-- 判断是否隐藏主手武器，拔刀必定显示武器
-- 生产职业预览副手，隐藏主手
function PreviewRoleAppearanceView:IsHideMasterHand()
	local bIsHideWeapon = not (PreviewRoleAppearanceVM.bIsShowWeapon or PreviewRoleAppearanceVM.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = self.SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND
	return bIsHideWeapon or (bIsProductProf and bIsPreviewSlaveHand)
end

-- 判断是否隐藏副手武器，拔刀必定显示武器
-- 生产职业非预览副手状态隐藏副手
function PreviewRoleAppearanceView:IsHideSlaveHand()
	local bIsHideWeapon = not (PreviewRoleAppearanceVM.bIsShowWeapon or PreviewRoleAppearanceVM.bIsHoldWeapon)
	local bIsProductProf = RoleInitCfg:FindProfSpecialization(MajorUtil.GetMajorProfID()) == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION
	local bIsPreviewSlaveHand = self.SelectSlotPart == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND
	return bIsHideWeapon or (bIsProductProf and not bIsPreviewSlaveHand)
end

-- 判断是否隐藏主手武器挂件，继承主手武器隐藏状态，但只有拔刀时才显示
function PreviewRoleAppearanceView:IsHideAttachMasterHand()
	return self:IsHideMasterHand() or not PreviewRoleAppearanceVM.bIsHoldWeapon
end

-- 判断是否隐藏副手武器挂件，继承副手武器隐藏状态，但只有拔刀时才显示
function PreviewRoleAppearanceView:IsHideAttachSlaveHand()
	return self:IsHideSlaveHand() or not PreviewRoleAppearanceVM.bIsHoldWeapon
end

function PreviewRoleAppearanceView:UpdateWeaponHideState()
	local bHideMasterHand = self:IsHideMasterHand()
	local bHideSlaveHand = self:IsHideSlaveHand()
	self.CommRender2D:HideMasterHand(bHideMasterHand)
	self.CommRender2D:HideSlaveHand(bHideSlaveHand)

	self.CommRender2D:HideAttachMasterHand(self:IsHideAttachMasterHand())
	self.CommRender2D:HideAttachSlaveHand(self:IsHideAttachSlaveHand())
end
---------------------------------------------------武器显隐--------------------------------------------------------------------

return PreviewRoleAppearanceView