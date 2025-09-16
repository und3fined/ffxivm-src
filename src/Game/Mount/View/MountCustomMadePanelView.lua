---
--- Author: chunfengluo
--- DateTime: 2024-11-19 15:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MountCustomShotGroupCfg = require("TableCfg/MountCustomShotGroupCfg")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local MountVM = require("Game/Mount/VM/MountVM")
local MountCustomMadeVM = require("Game/Mount/VM/MountCustomMadeVM")
local MountCustomMadeSlotVM = require("Game/Mount/VM/MountCustomMadeSlotVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local MajorUtil = require("Utils/MajorUtil")
local JumpUtil = require("Utils/JumpUtil")
local ProtoRes = require("Protocol/ProtoRes")
local DataReportUtil = require("Utils/DataReportUtil")
local EquipmentMgr = _G.EquipmentMgr

local LSTR = _G.LSTR
local UE = _G.UE
local CameraInitOffsetY = 80
local GuidelineCount = 3

---@class MountCustomMadePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field CommBtn CommBtnLView
---@field CommMoney CommMoneyBarView
---@field CommonTitle CommonTitleView
---@field ModelToImage CommonRender2DView
---@field Money StoreMoneyItemUBPView
---@field MountGuidelineItem1 MountGuidelineItemView
---@field MountGuidelineItem2 MountGuidelineItemView
---@field MountGuidelineItem3 MountGuidelineItemView
---@field SingleBox CommSingleBoxView
---@field TableViewSkateboard UTableView
---@field TextPropsName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountCustomMadePanelView = LuaClass(UIView, true)

function MountCustomMadePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.CommBtn = nil
	--self.CommMoney = nil
	--self.CommonTitle = nil
	--self.ModelToImage = nil
	--self.Money = nil
	--self.MountGuidelineItem1 = nil
	--self.MountGuidelineItem2 = nil
	--self.MountGuidelineItem3 = nil
	--self.SingleBox = nil
	--self.TableViewSkateboard = nil
	--self.TextPropsName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountCustomMadePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommBtn)
	self:AddSubView(self.CommMoney)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.ModelToImage)
	self:AddSubView(self.Money)
	self:AddSubView(self.MountGuidelineItem1)
	self:AddSubView(self.MountGuidelineItem2)
	self:AddSubView(self.MountGuidelineItem3)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountCustomMadePanelView:OnInit()
	self.MountCustomTableAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkateboard, self.OnMountCustomTableViewSelectChange, true)
	self.MountCustomTableAdapter:SetScrollbarIsVisible(false)
	self.CurrentSelectedCustomMadeID = -1
	self.ModelToImage:SetClick(self, self.OnSingleClick, self.OnDoubleClick)
	self.bIsGuidelinesCleared = false
	self.IsModelShown = false
	self.GuidelineViewList = { self.MountGuidelineItem1, self.MountGuidelineItem2, self.MountGuidelineItem3 }
	
	self.Binders = {
		{"CustomList", UIBinderUpdateBindableList.New(self, self.MountCustomTableAdapter)},
		{"CustomList", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateCustomList)},
		{"FunctionButtonText", UIBinderSetText.New(self, self.CommBtn)},
		{"NameText", UIBinderSetText.New(self, self.TextPropsName)},
		{"Price", UIBinderSetTextFormatForMoney.New(self, self.Money.TextPrice)},
		{"PriceBeforeDiscounted", UIBinderSetText.New(self, self.Money.TextOriginalPrice)},
		{"bIsDiscounted", UIBinderSetIsVisible.New(self, self.Money.PanelOriginalPrice, false, false, true)},
		{"bIsDiscounted", UIBinderSetIsVisible.New(self, self.Money.IconCoupons, false, false, true)},
		{"CurPriceTextColor", UIBinderSetColorAndOpacityHex.New(self, self.Money.TextPrice) },
		{"bMoneyVisible", UIBinderSetIsVisible.New(self, self.Money)},
		{"bShowUnlockedOnly", UIBinderValueChangedCallback.New(self, nil, self.OnShowUnlockedOnlyChanged)},
		{"NewMap", UIBinderValueChangedCallback.New(self, nil, self.OnCustomMadeNewMapChanged) },
	}

	self.CommonTitle:SetTextTitleName(LSTR(1100001))
	self.ShotGroupCfg = nil
	UIUtil.SetIsVisible(self.ModelToImage, true, true)
end

function MountCustomMadePanelView:OnDestroy()

end

function MountCustomMadePanelView:OnShow()
	-- local UnlockList = {
	-- 	[1] = { Unlocked = true, },
	-- 	[2] = { Unlocked = true, },
	-- }
	self.CurrentSelectedCustomMadeID = -1

	--MountVM:ClearNewByResID(self.Params.MountResID)
	MountCustomMadeVM:MountRemoveNew(self.Params.MountResID)
	MountCustomMadeVM:UpdateCustomList(self.Params.MountResID)
	self.SingleBox:SetText(LSTR(1100002))
	self:ShowPlayerMountActor()
	_G.LightMgr:EnableUIWeather(10)
	self.bSetSelectedIndexOnShow = true
	self.MountCustomTableAdapter:SetSelectedIndex(1)
	self.ModelToImage.bAutoInitSpringArm = false
	MountCustomMadeVM.bShowUnlockedOnly = false

	local function CallbackRotate(Yaw)
		self:OnModelRotate(Yaw)
	end
	self.ModelToImage.CallBackRotate = CallbackRotate

	local function SingleClick()
		self:OnSingleClick()
	end
	self.ModelToImage:SetClick(nil, SingleClick, nil)
	self:SetMoneyBar()
end

function MountCustomMadePanelView:OnHide()
	_G.LightMgr:DisableUIWeather()
	self.ModelToImage:SwitchOtherLights(true)
end

function MountCustomMadePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtn, self.OnClickCommBtn)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnSingleBoxClick)
end

function MountCustomMadePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MountAssembleAllEnd, self.OnMountAssembleAllEnd)
	self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(_G.EventID.BagUpdate, self.OnBagUpdate)
end

function MountCustomMadePanelView:OnRegisterBinder()
    self:RegisterBinders(MountCustomMadeVM, self.Binders)
end

function MountCustomMadePanelView:OnUpdateCustomList()
	self:UpdateFunctionButton()
end

function MountCustomMadePanelView:OnMountCustomTableViewSelectChange(Index, ItemData, ItemView)
	local bChanged = self.CurrentSelectedCustomMadeID ~= ItemData.ID
	self.CurrentSelectedCustomMadeID = ItemData.ID
	MountCustomMadeVM:SetSelectID(ItemData.ID)
	if not self.bSetSelectedIndexOnShow then
		MountCustomMadeVM:RemoveNew(MountCustomMadeVM.CurrentSelectedSlot.ID)
	end
	if bChanged then
		self:OnSelectIndexChanged()
	end
end

function MountCustomMadePanelView:OnSelectIndexChanged()
	if MountCustomMadeVM == nil or MountCustomMadeVM.CurrentSelectedSlot == nil then return end
	self:ClearGuidelines()
	self:UpdateFunctionButton()
	self.ShotGroupCfg = MountCustomShotGroupCfg:FindCfgByKey(MountCustomMadeVM.CurrentSelectedSlot.CameraGroupID)
	self:ResetToGlobalShot(not self.bSetSelectedIndexOnShow)
	self:UpdateModel()
	self.bSetSelectedIndexOnShow = false
end

function MountCustomMadePanelView:OnEquipIndexChanged()
	MountCustomMadeVM:UpdateCustomList()
end

function MountCustomMadePanelView:OnShowUnlockedOnlyChanged()
	MountCustomMadeVM:UpdateCustomList()
	self.MountCustomTableAdapter:SetSelectedIndex(1)
end

function MountCustomMadePanelView:OnCustomMadeNewMapChanged()
	MountCustomMadeVM:UpdateCustomList()
end

function MountCustomMadePanelView:OnBagUpdate()
	MountCustomMadeVM:UpdateCustomList()
end

function MountCustomMadePanelView:UpdateFunctionButton()
	if MountCustomMadeVM == nil or MountCustomMadeVM.CurrentSelectedSlot == nil then return end

	if MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.Invalid then

	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.Owned then
		self.CommBtn:SetIsRecommendState(true)
		self.CommBtn:SetText(LSTR(1100007))
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.OwnedNotUnlockedInBag then
		self.CommBtn:SetIsRecommendState(true)
		self.CommBtn:SetText(LSTR(1100008))
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.OwnedNotUnlockedInMail then
		self.CommBtn:SetIsDisabledState(true, true)
		self.CommBtn:SetText(LSTR(1100008))
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.NotOwnedCanBuy then
		self.CommBtn:SetIsRecommendState(true)
		self.CommBtn:SetText(LSTR(1100011))
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.NotOwnedCanGet then
		self.CommBtn:SetIsRecommendState(true)
		self.CommBtn:SetText(LSTR(1100009))
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.NotOwnedCannotGet then
		self.CommBtn:SetIsDoneState(true, LSTR(1100010))
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.Equiped then
		-- self.CommBtn:SetIsDisabledState(true, true)
		-- self.CommBtn:SetText(LSTR(1100012))
		self.CommBtn:SetIsDoneState(true, LSTR(1100012))
	end
	MountCustomMadeVM.bMoneyVisible = MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.NotOwnedCanBuy
end

function MountCustomMadePanelView:OnClickCommBtn()
	if MountCustomMadeVM == nil or MountCustomMadeVM.CurrentSelectedSlot == nil then return end

	if MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.Invalid then

	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.Owned then
		MountCustomMadeVM:SetEquipedID(MountCustomMadeVM.SelectedID)
		_G.MountMgr:SendEquipCustomMade(MountCustomMadeVM.MountID, MountCustomMadeVM.CurrentSelectedSlot.ID)
		self:OnEquipIndexChanged()
		DataReportUtil.ReportCustomizeUIFlowData(6, MountCustomMadeVM.MountID,"", MountCustomMadeVM.CurrentSelectedSlot.ID, MountCustomMadeVM.NameText, 1)
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.OwnedNotUnlockedInBag then
		local ItemGID = _G.BagMgr:GetItemGIDByResID(MountCustomMadeVM.CurrentSelectedSlot.ItemID)
		_G.BagMgr:UseItem(ItemGID)
		DataReportUtil.ReportCustomizeUIFlowData(5, MountCustomMadeVM.MountID,"", MountCustomMadeVM.CurrentSelectedSlot.ID, MountCustomMadeVM.NameText, 1)
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.OwnedNotUnlockedInMail then
		MsgTipsUtil.ShowTips(LSTR(1100013))
		DataReportUtil.ReportCustomizeUIFlowData(5, MountCustomMadeVM.MountID,"", MountCustomMadeVM.CurrentSelectedSlot.ID, MountCustomMadeVM.NameText, 2)
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.NotOwnedCanBuy then
		_G.StoreMgr:OpenExternalPurchaseInterfaceByNewUIBP(MountCustomMadeVM.CurrentSelectedSlot.GoodsID)
		DataReportUtil.ReportCustomizeUIFlowData(3, MountCustomMadeVM.MountID,"", MountCustomMadeVM.CurrentSelectedSlot.ID, MountCustomMadeVM.NameText)
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.NotOwnedCanGet then
		JumpUtil.JumpTo(MountCustomMadeVM.CurrentSelectedSlot.JumpID, true)
		DataReportUtil.ReportCustomizeUIFlowData(4, MountCustomMadeVM.MountID,"", MountCustomMadeVM.CurrentSelectedSlot.ID, MountCustomMadeVM.NameText)
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.NotOwnedCannotGet then
		MsgTipsUtil.ShowTips(LSTR(1100015))
	elseif MountCustomMadeVM.CurrentSelectedSlot.OwnState == MountCustomMadeSlotVM.OwnState.Equiped then
		MsgTipsUtil.ShowTips(LSTR(1100016))
	end
end

function MountCustomMadePanelView:OnSingleBoxClick(ToggleButton, ButtonState)
	MountCustomMadeVM.bShowUnlockedOnly = ButtonState == _G.UE.EToggleButtonState.Checked
end

function MountCustomMadePanelView:SetMoneyBar()
	UIUtil.SetIsVisible(self.CommMoney.Money1,  true)
	UIUtil.SetIsVisible(self.CommMoney.Money2,  false)
	UIUtil.SetIsVisible(self.CommMoney.Money3,  false)

	self.CommMoney.Money1:UpdateView(ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS, true, -1, true)
end

--+++++++ 模型相关开始 +++++++++--

function MountCustomMadePanelView:UpdateModel()
	if MountCustomMadeVM.CurrentSelectedSlot == nil then return end
	local ImeChanID = MountCustomMadeVM.CurrentSelectedSlot.ImeChanID

	local UIComplexCharacter = self.ModelToImage.UIComplexCharacter
	if UIComplexCharacter then
		local RideComponent = UIComplexCharacter:GetRideComponent()
		RideComponent:SetImeChanID(MountCustomMadeVM.MountID, ImeChanID)
	end
end

-- 初始化三维展示模型
function MountCustomMadePanelView:ShowPlayerMountActor()
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	MountCustomMadeVM.AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachType()
	self.ModelToImage.bAutoInitSpringArm = false
	--根据种族取对应的RenderActor
	local RenderActorPathForRace = "Class'/Game/UI/Render2D/Mount/Bp_Reder2DForMount.Bp_Reder2DForMount_C'"

    local CallBack = function(bSucc)
        if (bSucc) then
			self.VignetteIntensityDefaultValue = self.ModelToImage:GetPostProcessVignetteIntensity()
			self.ModelToImage:SwitchOtherLights(false)
            self.ModelToImage:ChangeUIState(false)
            self.ModelToImage:SetUICharacterByEntityID(MajorUtil.GetMajorEntityID())
			self.ModelToImage:EnableRotator(true)
			self.ModelToImage:RotatorUseWorldRotation(true)
			self.ModelToImage:EnableZoom(false)
			self.CameraFocusCfgMap:SetAssetUserData(self.ModelToImage:GetEquipmentConfigAssetUserData())
            self:SetModelSpringArmToDefault(false)
			self.ModelToImage:UpdateAllLights()
			self.ModelToImage:HidePlayer(true)
			self:OnLoadMountModel()
			local Actor = self.ModelToImage:GetCharacter()
			if Actor then
				local AvatarComponent = Actor:GetAvatarComponent()
				if AvatarComponent then
					AvatarComponent:SetForcedLODForAll(1)
				end
			end
        end
    end
	local ReCreateCallBack = function()
        self.CameraFocusCfgMap:SetAssetUserData(self.ModelToImage:GetEquipmentConfigAssetUserData())
    end

    self.ModelToImage:CreateRenderActor(RenderActorPathForRace,
	EquipmentMgr:GetEquipmentCharacterClass(), EquipmentMgr:GetLightConfig(),
	false, CallBack, ReCreateCallBack)
end

function MountCustomMadePanelView:SetModelSpringArmToDefault(bInterp)

	if self.CameraFocusCfgMap ~= nil then
		self.ModelToImage:SetCameraFOV(self.CameraFocusCfgMap:GetOriginFOV("c0101"))
	end
	self.ModelToImage:SetPostProcessVignetteIntensity(self.VignetteIntensityDefaultValue)
	self:ResetToGlobalShot(bInterp)
	self:ClearPreView()
	MountCustomMadeVM.bIsHoldWeapon = false
end

function MountCustomMadePanelView:SetShot(Index, bInInterp, bForce)
	local bInterp = bInInterp
	if bInterp == nil then bInterp = true end
	if self.CurrentShotIndex == Index and not bForce then return end

	local Shot
	if self.ShotGroupCfg == nil or Index == nil then
		Shot = nil
	elseif Index == 0 then
		Shot = self.ShotGroupCfg.GlobalShot
	else
		Shot = self.ShotGroupCfg.Shot[Index]
	end

	if Shot then
		self.ModelToImage:SetSpringArmDistance(Shot.DefaultCameraDistance, bInterp)
		self.ModelToImage:SetSpringArmRotation(
			Shot.Pitch, Shot.Yaw + 180, Shot.Roll, bInterp)
		if self.CameraFocusCfgMap ~= nil then
			self.ModelToImage:SetSpringArmLocation(
				self.CameraFocusCfgMap:GetSpringArmOriginX("c0101") + Shot.OffsetX,
				CameraInitOffsetY + self.CameraFocusCfgMap:GetSpringArmOriginY("c0101") + Shot.OffsetY,
				self.CameraFocusCfgMap:GetSpringArmOriginZ("c0101") + Shot.OffsetZ, bInterp)
		else
			self.ModelToImage:SetSpringArmLocation(
				Shot.OffsetX, CameraInitOffsetY + Shot.OffsetY, Shot.OffsetZ, bInterp)
		end
	else
		self.ModelToImage:SetSpringArmDistance(600, bInterp)
		self.ModelToImage:SetSpringArmRotation(0, 180, 0, bInterp)
		if self.CameraFocusCfgMap ~= nil then
			self.ModelToImage:SetSpringArmLocation(
				self.CameraFocusCfgMap:GetSpringArmOriginX("c0101"),
				CameraInitOffsetY + self.CameraFocusCfgMap:GetSpringArmOriginY("c0101"),
				self.CameraFocusCfgMap:GetSpringArmOriginZ("c0101"), bInterp)
		else
			self.ModelToImage:SetSpringArmLocation(0, CameraInitOffsetY, 0, bInterp)
		end
	end
	self.CurrentShotIndex = Index

	if self.CurrentShotIndex == 0 then
		self.ModelToImage:EnableRotator(true)
	else
		self.ModelToImage:EnableRotator(false)
	end
end

function MountCustomMadePanelView:DebugSetShot(DefaultCameraDistance, OffsetX, OffsetY, OffsetZ, Pitch, Yaw, Roll)
	self.ModelToImage:SetSpringArmDistance(DefaultCameraDistance, true)
	self.ModelToImage:SetSpringArmRotation(
		Pitch, Yaw + 180, Roll, true)
	if self.CameraFocusCfgMap ~= nil then
		self.ModelToImage:SetSpringArmLocation(
			self.CameraFocusCfgMap:GetSpringArmOriginX("c0101") + OffsetX,
			CameraInitOffsetY + self.CameraFocusCfgMap:GetSpringArmOriginY("c0101") + OffsetY,
			self.CameraFocusCfgMap:GetSpringArmOriginZ("c0101") + OffsetZ, true)
	else
		self.ModelToImage:SetSpringArmLocation(
			OffsetX, CameraInitOffsetY + OffsetY, OffsetZ, true)
	end
end

function MountCustomMadePanelView:ResetToGlobalShot(bInterp)
	if self.ShotGroupCfg ~= nil then
		self:SetShot(0, bInterp, true)
	end
end

function MountCustomMadePanelView:CreateGuidelines(Shots)
	for i, Shot in ipairs(Shots) do
		if self.GuidelineViewList[i] then
			local VM = self.GuidelineViewList[i].ViewModel
			VM.Direction = Shot.DescDirection
			VM.Index = i
			if VM.Direction ~= 0 then
				VM.Text = Shot.Description
				if Shot.DescOffsetX ~= nil and Shot.DescOffsetY ~= nil then
					VM.Offset:SetValue(Shot.DescOffsetX, Shot.DescOffsetY + CameraInitOffsetY)
				end
			end
		end
	end
	self.bIsGuidelinesCleared = false
end

function MountCustomMadePanelView:ClearGuidelines()
	if self.bIsGuidelinesCleared then return end
	local GuidelineTable = {}
	for i = 1, GuidelineCount do
		local Shot = {
			Direction = 0,
		}
		table.insert(GuidelineTable, Shot)
	end
	self:CreateGuidelines(GuidelineTable)
	self.bIsGuidelinesCleared = true
end

function MountCustomMadePanelView:HideGuidelines()
	for i, Widget in ipairs(self.GuidelineViewList) do
		Widget:PlayAnimationHide()
	end
end

function MountCustomMadePanelView:OnClickGuideline(Index)
	if self.ShotGroupCfg ~= nil then
		self:SetShot(Index, true)
	end
	if self.bIsGuidelinesCleared then return end
	for i, Widget in ipairs(self.GuidelineViewList) do
		if i == Index then
			Widget:PlayAnimationClick()
		else
			Widget:PlayAnimationHide()
		end
	end
	if self.ShotGroupCfg ~= nil then
		DataReportUtil.ReportCustomizeUIFlowData(2, MountCustomMadeVM.MountID,"", MountCustomMadeVM.CurrentSelectedSlot.ID, MountCustomMadeVM.NameText, 2, self.ShotGroupCfg.ID, self.ShotGroupCfg.Shot[Index].Description)
	end
end

function MountCustomMadePanelView:ClearPreView()
	self.ModelToImage:ResumeAvatar()

end

function MountCustomMadePanelView:OnLoadMountModel()
	MountCustomMadeVM.bIsShowPlayer = false
end

function MountCustomMadePanelView:SetMountModel(MountID)
	local ImeChanID = -1
	if MountCustomMadeVM.CurrentSelectedSlot ~= nil then
		ImeChanID = MountCustomMadeVM.CurrentSelectedSlot.ImeChanID
	end
	self.ModelToImage:SetUIRideCharacter(MountID, ImeChanID)
	self.ModelToImage:HidePlayer(true)
end

function MountCustomMadePanelView:OnDoubleClick()

end

function MountCustomMadePanelView:OnAssembleAllEnd(Params)
	local ChildActor = self.ModelToImage:GetCharacter()
	local EntityID = Params.ULongParam1
	if not ChildActor then return end
	local AttrComp = ChildActor:GetAttributeComponent()
	if EntityID == AttrComp.EntityID then
		if self.IsModelShown then return end
		self.IsModelShown = true
		self:SetMountModel(MountCustomMadeVM.MountID)
	end
end

function MountCustomMadePanelView:OnMountAssembleAllEnd(Params)
	local ChildActor = self.ModelToImage:GetCharacter()
	local EntityID = Params.ULongParam1
	if not ChildActor then return end
	local AttrComp = ChildActor:GetAttributeComponent()
	if EntityID == AttrComp.EntityID then
		--处理贴图加载
		local UIComplexCharacter = self.ModelToImage.UIComplexCharacter
		if UIComplexCharacter then
			UIComplexCharacter:GetAvatarComponent():WaitForTextureMips()
			if UIComplexCharacter:GetRideComponent() ~= nil then
				UIComplexCharacter:GetRideComponent():EnableAnimationRotating(false)
			end
			self.ModelToImage:SetRideMeshComponent()
			self:InitModelTransform()
			self:InitGuidelines()
		else
			FLOG_WARNING("MountCustomMadePanelView:OnMountAssembleAllEnd UIComplexCharacter is nil")
		end
	end
end

function MountCustomMadePanelView:InitModelTransform()
	if self.ShotGroupCfg and self.ModelToImage.RideMeshComponent ~= nil then
		local Yaw = math.atan(CameraInitOffsetY, self.ShotGroupCfg.GlobalShot.DefaultCameraDistance) * 180 / 3.1415926
		self.ModelToImage:SetModelRotation(0, Yaw, 0)
		self.ModelToImage.RideMeshComponent:K2_AddLocalRotation(_G.UE.FRotator(self.ShotGroupCfg.ModelPitch, self.ShotGroupCfg.ModelYaw, self.ShotGroupCfg.ModelRoll), false, _G.UE.FHitResult(), false)
		self.ModelToImage:SetModelLocation(self.ShotGroupCfg.ModelOffsetX, self.ShotGroupCfg.ModelOffsetY, self.ShotGroupCfg.ModelOffsetZ)
	end
end

function MountCustomMadePanelView:OnModelRotate(Yaw)
	self:HideGuidelines()
end

function MountCustomMadePanelView:OnSingleClick()
	if self.CurrentShotIndex ~= 0 then
		self:ResetToGlobalShot()
		self:InitModelTransform()
		self:ClearGuidelines()
		self:InitGuidelines()
	end
end

function MountCustomMadePanelView:InitGuidelines()
	if self.ShotGroupCfg ~= nil then
		self:CreateGuidelines(self.ShotGroupCfg.Shot)
	else
		self:ClearGuidelines()
	end
end

--------- 模型相关结束 ----------

return MountCustomMadePanelView