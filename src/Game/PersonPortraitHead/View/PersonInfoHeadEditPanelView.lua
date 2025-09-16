---
--- Author: Administrator
--- DateTime: 2024-07-29 10:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local PersonPortraitHeadUtil = require("Game/PersonPortraitHead/PersonPortraitHeadUtil")
local MajorUtil = require("Utils/MajorUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local MathUtil = require("Utils/MathUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local PortraitDesignCfg = require("TableCfg/PortraitDesignCfg")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local AnimationUtil = require("Utils/AnimationUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local ObjectMgr = require("Object/ObjectMgr")

local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")

local PersonPortraitHeadDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")

local MinFOV = PersonPortraitHeadDefine.MinFOV
local MaxFOV = PersonPortraitHeadDefine.MaxFOV

local EquipParts = ProtoCommon.equip_part
local DesignerType = ProtoCommon.DesignerType
local FVector2D = _G.UE.FVector2D

local LSTR = _G.LSTR
local SliderMaxFOV = PersonPortraitHeadDefine.SliderMaxFOV

local PersonPortraitHeadMgr 
local PersonPortraitVM
local PersonPortraitHeadVM
local RoleInitCfg = require("TableCfg/RoleInitCfg")

local WeatgerTODID = 26

---@class PersonInfoHeadEditPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BottomPanel UFCanvasPanel
---@field BtnBack UFButton
---@field BtnCameraReset UFButton
---@field BtnDelete UFButton
---@field BtnFaceReset UFButton
---@field BtnInfo CommInforBtnView
---@field BtnLookReset UFButton
---@field BtnSave CommBtnLView
---@field CameraPanel UFCanvasPanel
---@field CommSingleBox CommSingleBoxView
---@field IconLookCameraX UFImage
---@field ImgDashedBox UFImage
---@field ImgModelMask UFImage
---@field ImgModelMaskB UFImage
---@field ImgModelMaskL UFImage
---@field ImgModelMaskR UFImage
---@field ImgModelMaskT UFImage
---@field ImgModelMaskWhite UFImage
---@field MainPanel UFCanvasPanel
---@field MaskPanel UFCanvasPanel
---@field MiddlePanel UFCanvasPanel
---@field ModelToImage CommonRender2DToImageView
---@field PanelSave UFCanvasPanel
---@field PanelSaveBtn UFCanvasPanel
---@field RectPanel UFCanvasPanel
---@field ScaleBox UScaleBox
---@field SliderFOV PersonPortraitSliderOneView
---@field SliderRoll PersonPortraitSliderOneView
---@field TableViewCustom UTableView
---@field TableViewEmo UTableView
---@field TextNum UFTextBlock
---@field TextSave UFTextBlock
---@field TextSave2 UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleBtnFace UToggleButton
---@field ToggleBtnLook UToggleButton
---@field WarningPanel UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoHeadEditPanelView = LuaClass(UIView, true)

function PersonInfoHeadEditPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BottomPanel = nil
	--self.BtnBack = nil
	--self.BtnCameraReset = nil
	--self.BtnDelete = nil
	--self.BtnFaceReset = nil
	--self.BtnInfo = nil
	--self.BtnLookReset = nil
	--self.BtnSave = nil
	--self.CameraPanel = nil
	--self.CommSingleBox = nil
	--self.IconLookCameraX = nil
	--self.ImgDashedBox = nil
	--self.ImgModelMask = nil
	--self.ImgModelMaskB = nil
	--self.ImgModelMaskL = nil
	--self.ImgModelMaskR = nil
	--self.ImgModelMaskT = nil
	--self.ImgModelMaskWhite = nil
	--self.MainPanel = nil
	--self.MaskPanel = nil
	--self.MiddlePanel = nil
	--self.ModelToImage = nil
	--self.PanelSave = nil
	--self.PanelSaveBtn = nil
	--self.RectPanel = nil
	--self.ScaleBox = nil
	--self.SliderFOV = nil
	--self.SliderRoll = nil
	--self.TableViewCustom = nil
	--self.TableViewEmo = nil
	--self.TextNum = nil
	--self.TextSave = nil
	--self.TextSave2 = nil
	--self.TextTitle = nil
	--self.ToggleBtnFace = nil
	--self.ToggleBtnLook = nil
	--self.WarningPanel = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoHeadEditPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnInfo)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.CommSingleBox)
	self:AddSubView(self.ModelToImage)
	self:AddSubView(self.SliderFOV)
	self:AddSubView(self.SliderRoll)
	self:AddSubView(self.Stick)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoHeadEditPanelView:OnInit()
	PersonPortraitHeadMgr 		= _G.PersonPortraitHeadMgr
 	PersonPortraitVM 		= _G.PersonPortraitVM
	PersonPortraitHeadVM 	= _G.PersonPortraitHeadVM

	self.AdpTableHeadCust = UIAdapterTableView.CreateAdapter(self, self.TableViewCustom , self.OnAdpSletHeadCust, true)
	self.AdpTableHeadEmo = UIAdapterTableView.CreateAdapter(self, self.TableViewEmo, self.OnAdpSletHeadEmo)

	self.bIsInitialized = false

	self.Binders = 
	{
		{ "IsEnableHeadSave", 	UIBinderSetIsEnabled.New(self, self.BtnSave, nil, true)},
		{ "IsEditShowDelete", 	UIBinderSetIsChecked.New(self, self.ToggleBtn) },
		{ "IsEnableUse", 		UIBinderSetIsChecked.New(self, self.CommSingleBox.ToggleButton) },

		-- { "IsEnabledSaveBtn", 	UIBinderSetIsEnabled.New(self, self.BtnSave, nil, true) },
		-- { "DecorateVisible", 	UIBinderSetIsVisible.New(self, self.ImgDashedBox, true) },
		{ "IsPositionValid", 		UIBinderSetIsVisible.New(self, self.WarningPanel, true) },
		{ "HeadMainCustVMList", 	UIBinderUpdateBindableList.New(self, self.AdpTableHeadCust) },
		{ "EmoItemVMList", 			UIBinderUpdateBindableList.New(self, self.AdpTableHeadEmo) },
		{ "CustHeadCnt", 			UIBinderSetText.New(self, self.TextNum) },
	}

	self.EditBinders = 
	{
		{ "bIsShowWeapon", 			UIBinderSetIsChecked.New(self, self.ToggleBtnPullWeapon) },
		{ "bIsShowHead", 			UIBinderSetIsChecked.New(self, self.ToggleBtnHat) },

		{ "bIsShowWeapon", 			UIBinderValueChangedCallback.New(self, nil, self.PoseStyleSwitch) },
		{ "bIsShowHead", 			UIBinderValueChangedCallback.New(self, nil, self.HatVisibleSwitch) },
		{ "IsFace", 	UIBinderSetIsChecked.New(self, self.ToggleBtnFace) },
		{ "IsLook", 	UIBinderSetIsChecked.New(self, self.ToggleBtnLook) },
		{ "FOV", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedFOV) },
		{ "Roll", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRoll) },
	}

	self.SliderFOV:SetValueChangedCallback(function(Value)
		local ComImageView = self.ModelToImage
		if ComImageView then 
			self:DebugInfoFOV(PersonPortraitHeadUtil.SliderValue2CameraFOV(Value))
			ComImageView:SetCameraFOV(PersonPortraitHeadUtil.SliderValue2CameraFOV(Value))
		end
	end)

	-- 相机滚动
	self.SliderRoll:SetValueChangedCallback(function(Value)
		local ComImageView = self.ModelToImage
		if ComImageView then 
			ComImageView:SetCameraRoll(Value)
		end
	end)

	self:InitLSTR()
	
	self.MoveDelta = _G.UE.FVector2D(0, 0)
	local MoveStep = 0.5
	local MoveCB = function(NormVec)

		local ComImageView = self.ModelToImage
		-- local Location = self.ModelToImage.Common_Render2D_UIBP:GetSpringArmLocation()

		local CurModelEditVM = PersonPortraitHeadVM.CurModelEditVM

		self.MoveDelta.X = -NormVec.X * MoveStep
		self.MoveDelta.Y = -NormVec.Y * MoveStep

		local X = CurModelEditVM.Move[1]
		local Y = CurModelEditVM.Move[2]
		local Z = CurModelEditVM.Move[3]

		Y = Y + self.MoveDelta.X
		Z = Z + self.MoveDelta.Y

		local _, OY, OZ = table.unpack(PersonPortraitHeadUtil.GetDefaultMove())

		local DY = OY - Y
		local DZ = OZ - Z

		if math.sqrt(DZ * DZ + DY * DY) > 30 then
			return
		end

		ComImageView:SetSpringArmLocation(X, Y, Z, false)
		CurModelEditVM:SetMove(X, Y, Z)
		-- UIUtil.CanvasSlotSetPosition(self.ModelToImage, Pos)
	end

	local StartCB = function()
		self:OnMoveStat(true)
	end

	local EndCB = function()
		self:OnMoveStat(false)
	end
	
	self.Stick:SetParams(StartCB, MoveCB, EndCB)
end

function PersonInfoHeadEditPanelView:OnMoveStat(bOpen)
	UIUtil.SetIsVisible(self.InnerPanel, not bOpen)
end

function PersonInfoHeadEditPanelView:InitLSTR()
	self.TextTitle:SetText(LSTR(960032))
	self.TextTitle:SetText(LSTR(960032))
	self.TextSave:SetText(LSTR(960033))
	self.TextSave2:SetText(LSTR(960034))
	self.BtnSave:SetText(LSTR(960035))
	self.TextTitle:SetText(LSTR(960032))
end

local DebugLOG = _G.FLOG_INFO

--- @andre_lightpaw todo 临时调试代码
function PersonInfoHeadEditPanelView:DebugInfoDis(Val)
	local Dis, MinDis, MaxDis = PersonPortraitHeadUtil.GetDistanceParam()

	DebugLOG('[HeadEditDebug] CurDis = ' .. tostring(Val))
	DebugLOG('[HeadEditDebug] MaxDis = ' .. tostring(MaxDis))
	DebugLOG('[HeadEditDebug] MinDis = ' .. tostring(MinDis))
end

--- @andre_lightpaw todo 临时调试代码
function PersonInfoHeadEditPanelView:DebugInfoFOV(Val)
	DebugLOG('[HeadEditDebug] CurFOV = ' .. tostring(Val))
	DebugLOG('[HeadEditDebug] MaxFOV = ' .. tostring(PersonPortraitHeadDefine.MaxFOV))
	DebugLOG('[HeadEditDebug] MinFOV = ' .. tostring(PersonPortraitHeadDefine.MinFOV))
end

function PersonInfoHeadEditPanelView:OnDestroy()

end

function PersonInfoHeadEditPanelView:OnShow()
	PersonPortraitHeadMgr:ReqSetHeadGuideRedPoint()
	local ProfID = MajorUtil.GetMajorProfID()
	PersonPortraitHeadMgr:SendGetPersonalPortraitData(ProfID)
	PersonPortraitHeadVM.ScreenshotWidget = self.RectPanel
	PersonPortraitHeadVM:UpdEditInfo()
	-- PersonPortraitHeadMgr:SendRemoveAppearUpdateTips(ProfID)

	self.ModelToImage.bIgnoreTodAffective = true
    _G.LightMgr:EnableUIWeather(WeatgerTODID)

	self.SliderFOV:SetImgIcon(PersonPortraitHeadDefine.ScaleIconPath)
	self.SliderRoll:SetImgIcon(PersonPortraitHeadDefine.RotateIconPath)

	PersonPortraitHeadVM:UpdIsEnableUse()

	local CurModelEditVM = PersonPortraitHeadVM.CurModelEditVM
	self.OriRot = CurModelEditVM.Rotate
end

function PersonInfoHeadEditPanelView:OnHide()
	_G.LightMgr:DisableUIWeather()
end

function PersonInfoHeadEditPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, 		self.ToggleBtnPullWeapon, 				self.OnBtnPoseClick)
	UIUtil.AddOnStateChangedEvent(self, 		self.ToggleBtnHat, 				self.OnBtnHatClick)
	
	-- UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnDecorate, self.OnStateChangedToggleDecorate)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnFace, 	self.OnStateChangedToggleFace)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnLook, 	self.OnStateChangedToggleLook)

	UIUtil.AddOnClickedEvent(self, self.BtnDragReset, 	self.OnClickButtonRend2DReset)

	UIUtil.AddOnClickedEvent(self, self.BtnFaceReset, 	self.OnClickButtonFaceReset)
	UIUtil.AddOnClickedEvent(self, self.BtnLookReset, 	self.OnClickButtonLookReset)
	UIUtil.AddOnClickedEvent(self, self.BtnCameraReset, self.OnClickButtonCameraReset)

	-- UIUtil.AddOnClickedEvent(self, self.BtnDragStart, 	self.OnClickButtonDragStart)
	-- UIUtil.AddOnClickedEvent(self, self.BtnDragReset, 	self.OnClickButtonDragReset)
	-- UIUtil.AddOnClickedEvent(self, self.BtnDragSave, 	self.OnClickButtonDragSave)

	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickButtonSave)
	UIUtil.AddOnClickedEvent(self, self.BtnBack, self.OnClickButtonBack)

	
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtn, 	self.OnStateChangedToggleDelete)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox.ToggleButton, 	self.OnStateChangedToggleUse)
end

function PersonInfoHeadEditPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
    self:RegisterGameEvent(_G.EventID.PersonGetPortraitHeadDataSuc, self.OnEventGetPortraitDataSuc)
end

function PersonInfoHeadEditPanelView:OnRegisterBinder()
	self.SliderFOV:SetValueParam(0, SliderMaxFOV)
	self.SliderRoll:SetValueParam(-90, 90)

	self:RegisterBinders(PersonPortraitHeadVM, self.Binders)
	self:RegisterBinders(PersonPortraitHeadVM.CurModelEditVM, self.EditBinders)
end

function PersonInfoHeadEditPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.5, 0)
end

function PersonInfoHeadEditPanelView:OnTimer()
	if self.IsCheckPositionsIsValid then
		self.IsCheckPositionsIsValid = false
		self:CheckPositionsIsValid()
	end

	-- local Ref = self.ShowRoleImgRef or -1 
	-- if Ref >= 0 then
	-- 	if Ref == 0 then 
	-- 		UIUtil.SetIsVisible(self.ModelToImage.ImageRole, true)
	-- 	end

	-- 	self.ShowRoleImgRef = Ref - 1
	-- end
end

-------------------------------------------------------------------------------------------------------
---@region event handles

--- UI event

function PersonInfoHeadEditPanelView:OnAdpSletHeadCust(_, VM)
	if VM.IsEmpty then
		return
	end
	MsgTipsUtil.ShowTips(LSTR(960010))
end

function PersonInfoHeadEditPanelView:OnAdpSletHeadEmo(_, VM)
	PersonPortraitHeadVM.CurEmoVM = VM
	PersonPortraitHeadVM.IsEditShowDelete = false

	if VM.IsEmpty then
		self:StopAnim(self.EmoMtg)
	else
		local EmoID = VM.EmoResID
		self:PlayEmo(EmoID)
	end
end

function PersonInfoHeadEditPanelView:OnValueChangedFOV(Value)
	self.SliderFOV:SetValue(Value)
	self:HeadCentered()
end

function PersonInfoHeadEditPanelView:OnValueChangedRoll(Value)
	self.SliderRoll:SetValue(Value)
end

function PersonInfoHeadEditPanelView:OnStateChangedToggleDelete(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	PersonPortraitHeadVM.IsEditShowDelete = IsChecked
end

function PersonInfoHeadEditPanelView:OnStateChangedToggleDecorate(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	PersonPortraitHeadVM.DecorateVisible = IsChecked
end

function PersonInfoHeadEditPanelView:OnStateChangedToggleFace(ToggleButton, State)
	-- if self:CheckIsDraging() then
	-- 	return
	-- end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local ComImageView = self.ModelToImage
	if ComImageView then
		ComImageView:SetUseAnimLookAtWithHead(IsChecked)
	end

	PersonPortraitHeadVM.CurModelEditVM:SetIsFace(IsChecked)

	-- if self.IsFaceReset then
	-- 	self.IsFaceReset = nil

	-- 	MsgTipsUtil.ShowTips(LSTR(960018))

	-- else
	-- end

	self:UpdateLookAtType()
	MsgTipsUtil.ShowTips(IsChecked and LSTR(960014) or LSTR(960012))


    PersonPortraitHeadVM:UpdateSaveBtnState()
	PersonPortraitHeadVM.IsEditShowDelete = false
end

function PersonInfoHeadEditPanelView:UpdateLookAtType()
	local ELookAtType = _G.UE.ELookAtType

	local IsFace = self.ToggleBtnFace:GetChecked()
	local IsLook = self.ToggleBtnLook:GetChecked()

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

function PersonInfoHeadEditPanelView:OnStateChangedToggleUse(ToggleButton, State)
	-- if self:CheckIsDraging() then
	-- 	return
	-- end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	PersonPortraitHeadVM:SetIsEnableUse(IsChecked)
end

function PersonInfoHeadEditPanelView:OnStateChangedToggleLook(ToggleButton, State)
	-- if self:CheckIsDraging() then
	-- 	return
	-- end

	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local ComImageView = self.ModelToImage
	if ComImageView then
		ComImageView:SetUseAnimLookAtWithEye(IsChecked)
	end

	PersonPortraitHeadVM.CurModelEditVM:SetIsLook(IsChecked)

	-- if self.IsLookReset then
	-- 	self.IsLookReset = nil

	-- 	MsgTipsUtil.ShowTips(LSTR(960015))

	-- else
	-- end
	self:UpdateLookAtType()
	MsgTipsUtil.ShowTips(IsChecked and LSTR(960013) or LSTR(960011))


    PersonPortraitHeadVM:UpdateSaveBtnState()
	PersonPortraitHeadVM.IsEditShowDelete = false
end

function PersonInfoHeadEditPanelView:OnClickButtonRend2DReset()
	local ComImageView = self.ModelToImage
	if nil == ComImageView then 
		return
	end

	local X, Y, Z = table.unpack(PersonPortraitHeadUtil.GetDefaultMove())
	ComImageView:SetSpringArmLocation(X, Y, Z, false)
	PersonPortraitVM.CurModelEditVM:SetMove(X, Y, Z)
	self:HeadCentered()
end

function PersonInfoHeadEditPanelView:OnClickButtonFaceReset()
	-- if self:CheckIsDraging() then
	-- 	return
	-- end

	-- self:HeadCentered()

	self.IsFaceReset = true
	self.ToggleBtnFace:SetChecked(false, true)
	PersonPortraitHeadVM.IsEditShowDelete = false
end

function PersonInfoHeadEditPanelView:OnClickButtonLookReset()
	-- if self:CheckIsDraging() then
	-- 	return
	-- end

	self.IsLookReset = true
	self.ToggleBtnLook:SetChecked(false, true)
	PersonPortraitHeadVM.IsEditShowDelete = false
end

function PersonInfoHeadEditPanelView:OnClickButtonCameraReset()
	-- if self:CheckIsDraging() then
	-- 	return
	-- end
	local CurModelEditVM = PersonPortraitHeadVM.CurModelEditVM

	local ComImageView = self.ModelToImage
	if nil == ComImageView then 
		return
	end

	-- 缩放(视距+FOV)
    local Distance = PersonPortraitHeadUtil.GetDefaultDistance()
	ComImageView:SetSpringArmDistance(Distance)

	local FOV = PersonPortraitHeadUtil.GetDefaultFOV()
	ComImageView:SetCameraFOV(PersonPortraitHeadUtil.SliderValue2CameraFOV(FOV))

	-- 滚动 
    local Roll = PersonPortraitHeadUtil.GetDefaultRoll()
	ComImageView:SetCameraRoll(Roll)

	local ModelToImage = self.ModelToImage
	-- local CurModelEditVM = PersonPortraitHeadVM.CurModelEditVM
	ModelToImage:SetModelRotation(0, self.OriRot, 0, false)
	CurModelEditVM.Rotate = self.OriRot

	self:HeadCentered()
	-- 平移 
	-- self:ResetMove()

	MsgTipsUtil.ShowTips(LSTR(960017))
	PersonPortraitHeadVM.IsEditShowDelete = false
end

function PersonInfoHeadEditPanelView:OnClickButtonDragStart()
	-- self:StartOrEndDrag(true)
end

function PersonInfoHeadEditPanelView:OnClickButtonDragReset()
	-- self:ResetMove()
	MsgTipsUtil.ShowTips(LSTR(960016))
end

function PersonInfoHeadEditPanelView:OnClickButtonDragSave()
	-- self:StartOrEndDrag(false)
end

function PersonInfoHeadEditPanelView:OnClickButtonSave()
	-- 其他条件
	if not self:CheckSaveSettings() then
		return
	end

	local CustList = PersonPortraitHeadMgr.HeadCustList

	if #CustList >= 8 then
		MsgTipsUtil.ShowTips(LSTR(960028))
		return
	end

	local IsSet = self.CommSingleBox:GetChecked()
	local Tips = IsSet and LSTR(960041) or LSTR(960040) 
	MsgTipsUtil.ShowTips(Tips)
	PersonPortraitHeadMgr:ReqSaveHead(IsSet)
	PersonPortraitHeadVM.IsEditShowDelete = false
end

function PersonInfoHeadEditPanelView:OnClickButtonBack()
	-- 其他条件
	-- if not self:CheckSaveSettings() then
	-- 	return
	-- end

	PersonPortraitHeadVM.IsEditShowDelete = false
	self:Hide()
end

--- game event

function PersonInfoHeadEditPanelView:OnEventGetPortraitDataSuc()
	if not self.bIsInitialized then
		-- 初始化模型
		self:InitModel()

	else
		-- 更新模型数据
		-- 装备
		self:UpdateModelEquipments()
		-- self:UpdateModel()
	end
end

function PersonInfoHeadEditPanelView:OnAssembleAllEnd(Params)
	-- Fixed "暂停表情动作后仍然眨眼睛" 问题
	-- StartLoadAvatar 函数会重新刷新脸部 AninInstance，导致动画或表情播放异常，故在调用StartLoadAvatar之后才设置模型数据
	if Params and Params.ULongParam1 == self.ModelToImage:GetActorEntityID() then
		-- FLOG_INFO("PersonPortraitDesignRetView:OnAssembleAllEnd, UpdateModelData")
		self:UpdateModel()
	end
end
--- binder callback

function PersonInfoHeadEditPanelView:OnBindCBFOV(Value)
	self.SliderFOV:SetValue(Value)
end

function PersonInfoHeadEditPanelView:OnBindCBRoll(Value)
	self.SliderRoll:SetValue(Value)
end

-------------------------------------------------------------------------------------------------------
---@region drag

-- function PersonInfoHeadEditPanelView:StartOrEndDrag(IsStart)
-- 	self.IsDraging = IsStart 

-- 	-- 设置拖拽按钮可见性
-- 	UIUtil.SetIsVisible(self.BtnDragStart, not IsStart, true)
-- 	UIUtil.SetIsVisible(self.BtnDragReset, IsStart, true)
-- 	UIUtil.SetIsVisible(self.BtnDragSave, IsStart, true)

-- 	-- 设置一些操作物件的透明度
-- 	local Opacity = IsStart and 0.5 or 1
-- 	UIUtil.SetRenderOpacity(self.CameraPanel, Opacity)

-- 	self.SliderFOV:SetContentRenderOpacity(Opacity)
-- 	self.SliderRoll:SetContentRenderOpacity(Opacity)
-- 	UIUtil.SetRenderOpacity(self.BtnSave, Opacity)

-- 	local ComImageView = self.ModelToImage
-- 	if ComImageView then
-- 		-- 缩放
-- 		ComImageView:EnableZoom(not IsStart)

-- 		-- 移动
-- 		ComImageView:EnableMoveImmediately(IsStart)
-- 	end
-- end

-- function PersonInfoHeadEditPanelView:CheckIsDraging()
--     if self.IsDraging then
--         MsgTipsUtil.ShowTips(LSTR(960030))
--         return true
--     end

--     return false
-- end

-- function PersonInfoHeadEditPanelView:ResetMove()
-- 	local ComImageView = self.ModelToImage
-- 	if nil == ComImageView then 
-- 		return
-- 	end

-- 	local X, Y, Z = table.unpack(PersonPortraitHeadUtil.GetDefaultMove())
-- 	ComImageView:SetSpringArmLocation(X, Y, Z, false)

-- 	PersonPortraitVM.CurModelEditVM:SetMove(X, Y, Z)
-- end

-------------------------------------------------------------------------------------------------------
---@region charactor model

--- model set

local SCS_FinalColorLDRHasAlpha = _G.UE.ESceneCaptureSource.SCS_FinalColorLDRHasAlpha or 3

function PersonInfoHeadEditPanelView:InitModel()
	local ModelToImage = self.ModelToImage

    ModelToImage:CreateRenderActor(true, function()
        -- 更新模型数据
        -- self:UpdateModel()
		ModelToImage:SetCameraCaptureSource(SCS_FinalColorLDRHasAlpha)
		ModelToImage:DisableImageGamma()

		self:UpdateModelEquipments()
		self.bIsInitialized = true
		UIUtil.SetIsVisible(self.ModelToImage.ImageRole, true)
		-- ModelToImage:SwitchOtherLights(false)
		-- ModelToImage:DisableEnvironmentLights()

		self:HeadCentered()
		self:PoseStyleSwitch()
		self:HatVisibleSwitch()

		self.OriRot = ModelToImage.Common_Render2D_UIBP.Rotation

    end, false, false)

	local MaxZOffset = PersonPortraitHeadUtil.GetDefaultFarZOffset()
	local MaxPitchOffset = PersonPortraitHeadUtil.GetDefaultFarPitchOffset()

	local Dis, MinDis, MaxDis = PersonPortraitHeadUtil.GetDistanceParam()
	ModelToImage:SetCameraControlParams(MinDis, MaxDis, MinFOV, MaxFOV, 3, nil, MaxZOffset, nil, MaxPitchOffset, -70, 6)
	ModelToImage.Common_Render2D_UIBP.CamControlParams.DefaultViewDistance = MinDis
	-- 缩放
	ModelToImage:SetZoomCallBack(function(Distance)
		if self.bIsInitialized then
			PersonPortraitHeadVM.CurModelEditVM:SetDistance(math.floor(Distance))
			self:DebugInfoDis(math.floor(Distance))
			ModelToImage.Common_Render2D_UIBP.CamControlParams.DefaultViewDistance = Distance
			self.IsCheckPositionsIsValid = true 
		end
	end)

	-- 缩放FOV
	ModelToImage:SetFOVCallBack(function(FOV)
		if self.bIsInitialized then
			PersonPortraitHeadVM.CurModelEditVM:SetFOV(math.floor(PersonPortraitHeadUtil.FOV2SliderValue(FOV)))
			self.IsCheckPositionsIsValid = true 
		end
	end)

	-- 旋转
	ModelToImage:SetRotateCallBack(function(Angle)
		if self.bIsInitialized then
			PersonPortraitHeadVM.CurModelEditVM:SetRotate(MathUtil.Round(Angle, 2))
			self.IsCheckPositionsIsValid = true 
		end
	end)

	-- 移动
	ModelToImage:SetMoveCallBack(function(x, y, z)
		if self.bIsInitialized then
			x = MathUtil.Round(x, 2) 
			y = MathUtil.Round(y, 2) 
			z = MathUtil.Round(z, 2) 

			PersonPortraitHeadVM.CurModelEditVM:SetMove(x, y, z)
			self.IsCheckPositionsIsValid = true 
		end
	end)

	-- 相机滚动 
	ModelToImage:SetRollCallBack(function(Roll)
		if self.bIsInitialized then
			PersonPortraitHeadVM.CurModelEditVM:SetRoll(Roll)
			self.IsCheckPositionsIsValid = true 
		end
	end)
end

function PersonInfoHeadEditPanelView:UpdateModel()
	

	local ModelToImage = self.ModelToImage
	local CurModelEditVM = PersonPortraitHeadVM.CurModelEditVM

	---面向镜头/取消面向镜头
	ModelToImage:SetUseAnimLookAtWithHead(CurModelEditVM.IsFace)

	---看向镜头/取消看向镜头(视线)
	ModelToImage:SetUseAnimLookAtWithEye(CurModelEditVM.IsLook)

	-- 缩放
	ModelToImage:SetSpringArmDistance(CurModelEditVM.Distance)
	ModelToImage:SetCameraFOV(PersonPortraitHeadUtil.SliderValue2CameraFOV(CurModelEditVM.FOV))

	-- 旋转
	ModelToImage:SetRotateLimitParams(-90, 90)
	ModelToImage:SetModelRotation(0, CurModelEditVM.Rotate, 0, false)

	-- 俯仰
	ModelToImage:EnablePitch(true)

	-- 滚动
	ModelToImage:SetCameraRoll(CurModelEditVM.Roll)

	-- 平移
	local X, Y, Z = table.unpack(CurModelEditVM.Move)
	ModelToImage:SetSpringArmLocation(X, Y, Z, false)

	-- 环境光
	local Color = CurModelEditVM.AmbientLightColor
	ModelToImage:SetAmbientLightColor(PersonPortraitHeadUtil.NormalizedColor(table.unpack(Color)))

	local Intensity = PersonPortraitHeadUtil.NormalizedIntensity(CurModelEditVM.AmbientLightIntensity)
	ModelToImage:SetAmbientLightIntensity(Intensity)

	-- 方向光
	Color = CurModelEditVM.DirectLightColor
	ModelToImage:SetDirectionalLightColor(PersonPortraitHeadUtil.NormalizedColor(table.unpack(Color)))

	Intensity = PersonPortraitHeadUtil.NormalizedIntensity(CurModelEditVM.DirectLightIntensity)
	ModelToImage:SetDirectionalLightIntensity(Intensity)

	-- 灯光方向
	local Dir = CurModelEditVM.DirectLightDir
	ModelToImage:SetDirectionalLightDirection(Dir[2] or 0, Dir[1] or 0)

	-- local ParentView = self.ParentView
	-- if ParentView then
	-- 	-- 播放动作
	-- 	local ActionID = PersonPortraitVM:GetPortraitSrcSetResID(DesignerType.DesignerType_Action)
	-- 	ParentView:PlayAction(ActionID, CurModelEditVM.ActionPostion)

	-- 	-- 播放表情
	-- 	local EmotionID = PersonPortraitVM:GetPortraitSrcSetResID(DesignerType.DesignerType_Emotion)
	-- 	ParentView:PlayEmotion(EmotionID, CurModelEditVM.EmotionPostion)
	-- end

	self.IsCheckPositionsIsValid = true 

end

function PersonInfoHeadEditPanelView:UpdateModelEquipments()
	local EquipScheme = PersonPortraitHeadVM.CurEquipScheme
	if nil == EquipScheme then
		return
	end

	local ModelToImage = self.ModelToImage
	local UIComplexCharacter = ModelToImage:GetUIComplexCharacter()
	if nil == UIComplexCharacter then
		return
	end

	for _, v in pairs(EquipParts) do
		local EquipInfo = EquipScheme[v]
		if EquipInfo then
			-- 幻化
			local EquipID = EquipInfo.ResID
			local AppearanceID, ColorID, RandomID = WardrobeUtil.GetMajorAppearanceAndColorByPartID(v)
			EquipID = WardrobeUtil.GetEquipID(EquipID, AppearanceID, RandomID)
			ModelToImage:PreViewEquipment(EquipID, v, ColorID)

		else
			UIComplexCharacter:TakeOffAvatarEquip(v, false)
		end
	end

	UIComplexCharacter:StartLoadAvatar()
	-- UIComplexCharacter:ClearDelegateHandle()

	local AvatarComp = UIComplexCharacter:GetAvatarComponent()
	if AvatarComp then
		AvatarComp:SetForcedLODForAll(1)
	end
end

--- save valid check

function PersonInfoHeadEditPanelView:CheckPositionsIsValid()
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

	PersonPortraitHeadVM:UpdateIsPositionValid(IsValid)
end

function PersonInfoHeadEditPanelView:HeadCentered()
	self.ModelToImage:UpdateFocusLocation()
end

function PersonInfoHeadEditPanelView:CalculateCaptureRect()
	local RectSize = UIUtil.GetWidgetSize(self.RectPanel)
	local RTSize = UIUtil.GetWidgetSize(self.ModelToImage)
	local Rate = (RectSize.X / RTSize.X - 0.05) / 2

	self.CaptureRectMin = FVector2D(0.5 - Rate, 0.5 - Rate)
	self.CaptureRectMax = FVector2D(0.5 + Rate, 0.5 + Rate)
end

function PersonInfoHeadEditPanelView:IsCaptureRectInside(Position)
	local RectMin = self.CaptureRectMin
	local RectMax = self.CaptureRectMax
	if nil == RectMin or nil == RectMax then
		return false 
	end

	local X = Position.X
	local Y = Position.Y
	return (X >= RectMin.X) and (X <= RectMax.X) and (Y >= RectMin.Y) and (Y <= RectMax.Y)
end

function PersonInfoHeadEditPanelView:CheckSaveSettings()
    -- if PersonPortraitHeadMgr.IsSavingImg then
    --     MsgTipsUtil.ShowTips(LSTR(960024))
    --     return false
    -- end

	-- PersonPortraitHeadMgr.IsSavingImg = true

    -- -- 2.设置是否发生变化
    -- if not PersonPortraitVM:CheckIsSetsChanged() then
    --     MsgTipsUtil.ShowTips(LSTR(960022))
    --     return false
    -- end

    -- 3. 肖像模型位置是否合法
    if not PersonPortraitHeadVM.IsPositionValid then
        MsgTipsUtil.ShowErrorTips(LSTR(960029))
        return false
    end

    return true
end

-- anim

function PersonInfoHeadEditPanelView:PlayEmo(ResID)
	if self.EmoMtg then
		self:StopAnim(self.EmoMtg)
	end

	local ResPath = EmotionAnimUtils.GetEmotionAtlPath(ResID)
	if string.isnilorempty(ResPath) then
		return
	end

	local Callback = function() 
		local Montage = self:PlayAnim(ResPath)
		if nil == Montage then
			return
		end

		self.EmoMtg = Montage

		-- -- 设置位置
		-- self:SetAnimPosition(Montage, Position)
	end

	ObjectMgr:LoadObjectAsync(ResPath, Callback, nil, Callback)
end

function PersonInfoHeadEditPanelView:GetMotageResPath(ResID)
	return EmotionAnimUtils.GetEmotionAtlPath(ResID)
end

function PersonInfoHeadEditPanelView:StopAnim(Montage)
	local AnimInst = self:GetAnimInstance()
	if AnimInst and Montage then
		AnimationUtil.MontageStop(AnimInst, Montage) 
	end
end

function PersonInfoHeadEditPanelView:PlayAnim(ResPath)
	local AnimComp = self:GetAnimComponent()
	if nil == AnimComp then
		return
	end

	local AnimInst = self:GetAnimInstance()
	if nil == AnimInst then
		return
	end

	local AnimRes =  ObjectMgr:GetObject(ResPath)
	return AnimationUtil.PlayMontage(AnimComp, AnimRes, nil, nil, AnimInst, nil, 0.00001, false, 0, 0, 0.1)
end

function PersonInfoHeadEditPanelView:GetAnimComponent()
	local Ret = self.AnimComponent 
	if nil == Ret then
		local ComImageView = self.ModelToImage
		if ComImageView then
			Ret = ComImageView:GetAnimationComponent()
		end

		self.AnimComponent = Ret
	end

	return Ret
end

function PersonInfoHeadEditPanelView:GetAnimInstance()
	local AnimComp = self.AnimComponent
	if nil == AnimComp then
		return
	end

	local Ret = self.AnimInstance
	if nil == Ret then
		Ret = AnimComp:GetAnimInstance()
		self.AnimInstance = Ret
	end

	return Ret
end

-------------------------------------------------------------------------------------------------------
---@region expand weapon/hat, copy from EquipmentNewMainView

-- weapon
function PersonInfoHeadEditPanelView:OnBtnPoseClick(ToggleButton, ButtonState)
	local IsShow = ButtonState == _G.UE.EToggleButtonState.Checked
	PersonPortraitHeadVM.CurModelEditVM.bIsShowWeapon = IsShow
	self:ShowPoseStyleTips(IsShow)
end

function PersonInfoHeadEditPanelView:ShowPoseStyleTips(IsShow)
	local Contnet = (LSTR(1050028))
	--_G.MsgTipsUtil.ShowTips(Contnet)
end

-- hat
function PersonInfoHeadEditPanelView:OnBtnHatClick(ToggleButton, ButtonState)
	local IsShow = ButtonState == _G.UE.EToggleButtonState.Checked 
	PersonPortraitHeadVM.CurModelEditVM.bIsShowHead = IsShow
	self:ShowHatTips(IsShow)
end

function PersonInfoHeadEditPanelView:ShowHatTips(bHideHead)
	local OpenContent = (LSTR(1050060))
	local CloseContnet = (LSTR(1050023))
	local Text = bHideHead and CloseContnet or OpenContent
	--_G.MsgTipsUtil.ShowTips(Text)
end

function PersonInfoHeadEditPanelView:PoseStyleSwitch()
	-- self.ModelToImage.Common_Render2D_UIBP:HoldOnWeapon(PersonPortraitHeadVM.CurModelEditVM.bIsHoldWeapon)
	self:UpdateWeaponHideState()
end

function PersonInfoHeadEditPanelView:UpdateWeaponHideState()
	-- local bHideMasterHand = self:IsHideMasterHand()
	-- local bHideSlaveHand = self:IsHideSlaveHand()
	-- self.ModelToImage.Common_Render2D_UIBP:HideMasterHand(not PersonPortraitHeadVM.CurModelEditVM.bIsShowWeapon)
	-- self.ModelToImage.Common_Render2D_UIBP:HideSlaveHand(not PersonPortraitHeadVM.CurModelEditVM.bIsShowWeapon)


	self.ModelToImage.Common_Render2D_UIBP:HideWeapon(not PersonPortraitHeadVM.CurModelEditVM.bIsShowWeapon)

	-- self.ModelToImage.Common_Render2D_UIBP:HideAttachMasterHand(false)
	-- self.ModelToImage.Common_Render2D_UIBP:HideAttachSlaveHand(false)
end

-- -- 判断是否隐藏主手武器，拔刀必定显示武器
-- -- 生产职业预览副手，隐藏主手
-- function PersonInfoHeadEditPanelView:IsHideMasterHand()
-- 	return not PersonPortraitHeadVM.CurModelEditVM.bIsShowWeapon
-- end

-- -- 判断是否隐藏副手武器，拔刀必定显示武器
-- -- 生产职业非预览副手状态隐藏副手
-- function PersonInfoHeadEditPanelView:IsHideSlaveHand()
-- 	return not PersonPortraitHeadVM.CurModelEditVM.bIsShowWeapon
-- end

-- -- 判断是否隐藏主手武器挂件，继承主手武器隐藏状态，但只有拔刀时才显示
-- function PersonInfoHeadEditPanelView:IsHideAttachMasterHand()
-- 	return self:IsHideMasterHand() or not PersonPortraitHeadVM.CurModelEditVM.bIsHoldWeapon
-- end

-- -- 判断是否隐藏副手武器挂件，继承副手武器隐藏状态，但只有拔刀时才显示
-- function PersonInfoHeadEditPanelView:IsHideAttachSlaveHand()
-- 	return self:IsHideSlaveHand() or not PersonPortraitHeadVM.CurModelEditVM.bIsHoldWeapon
-- end

--hat

function PersonInfoHeadEditPanelView:HatVisibleSwitch()
	-- self:SendClientSetupPost(ClientSetupID.RoleHatVisible, self.ViewModel.bHideHead)
	local bHideHead = PersonPortraitHeadVM.CurModelEditVM.bIsShowHead
	self.ModelToImage.Common_Render2D_UIBP:HideHead(not bHideHead)
end

return PersonInfoHeadEditPanelView