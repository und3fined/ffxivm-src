---
--- Author: xingcaicao
--- DateTime: 2023-11-29 12:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local PersonPortraitUtil = require("Game/PersonPortrait/PersonPortraitUtil")

local LSTR = _G.LSTR
local SliderMaxFOV = PersonPortraitDefine.SliderMaxFOV
local ScaleIconPath = "PaperSprite'/Game/UI/Atlas/PersonPortrait/Frames/UI_PersonPortrait_Icon_Scale_png.UI_PersonPortrait_Icon_Scale_png'"
local RotateIconPath = "PaperSprite'/Game/UI/Atlas/PersonPortrait/Frames/UI_PersonPortrait_Icon_Rotate_png.UI_PersonPortrait_Icon_Rotate_png'"

---@class PersonPortraitModelEditPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BottomPanel UFCanvasPanel
---@field BtnCameraReset UFButton
---@field BtnFaceReset UFButton
---@field BtnLookReset UFButton
---@field BtnResetMove UFButton
---@field BtnSave CommBtnLView
---@field CameraPanel UFCanvasPanel
---@field CommStick CommStickView
---@field IconLookCameraX UFImage
---@field ImgDashedBox UFImage
---@field ImgModelMaskB UFImage
---@field ImgModelMaskL UFImage
---@field ImgModelMaskR UFImage
---@field ImgModelMaskT UFImage
---@field ImgModelMaskWhite UFImage
---@field MaskPanel UFCanvasPanel
---@field SliderFOV PersonPortraitSliderOneView
---@field SliderRoll PersonPortraitSliderOneView
---@field ToggleBtnDecorate UToggleButton
---@field ToggleBtnFace UToggleButton
---@field ToggleBtnHand UToggleButton
---@field ToggleBtnHat UToggleButton
---@field ToggleBtnLook UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonPortraitModelEditPanelView = LuaClass(UIView, true)

function PersonPortraitModelEditPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BottomPanel = nil
	--self.BtnCameraReset = nil
	--self.BtnFaceReset = nil
	--self.BtnLookReset = nil
	--self.BtnResetMove = nil
	--self.BtnSave = nil
	--self.CameraPanel = nil
	--self.CommStick = nil
	--self.IconLookCameraX = nil
	--self.ImgDashedBox = nil
	--self.ImgModelMaskB = nil
	--self.ImgModelMaskL = nil
	--self.ImgModelMaskR = nil
	--self.ImgModelMaskT = nil
	--self.ImgModelMaskWhite = nil
	--self.MaskPanel = nil
	--self.SliderFOV = nil
	--self.SliderRoll = nil
	--self.ToggleBtnDecorate = nil
	--self.ToggleBtnFace = nil
	--self.ToggleBtnHand = nil
	--self.ToggleBtnHat = nil
	--self.ToggleBtnLook = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonPortraitModelEditPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.CommStick)
	self:AddSubView(self.SliderFOV)
	self:AddSubView(self.SliderRoll)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonPortraitModelEditPanelView:OnInit()
	-- FOV 
	self.SliderFOV:SetValueChangedCallback(function(Value)
		local ComImageView = self.CommonRender2DToImageView
		if ComImageView then 
			ComImageView:SetCameraFOV(PersonPortraitUtil.SliderValue2CameraFOV(Value))
		end
	end)

	-- 相机滚动
	self.SliderRoll:SetValueChangedCallback(function(Value)
		local ComImageView = self.CommonRender2DToImageView
		if ComImageView then 
			ComImageView:SetCameraRoll(Value)
		end
	end)

	self.BindersPersonPortraitVM = {
		{ "DecorateVisible", UIBinderSetIsVisible.New(self, self.ImgDashedBox, true) },
	}

	self.BindersCurModelEditVM = {
		{ "IsHideWeapon", 		UIBinderSetIsChecked.New(self, self.ToggleBtnHand, nil, true) },
		{ "IsHideHat", 			UIBinderSetIsChecked.New(self, self.ToggleBtnHat, nil, true) },
		{ "IsFace", 			UIBinderSetIsChecked.New(self, self.ToggleBtnFace) },
		{ "IsLook", 			UIBinderSetIsChecked.New(self, self.ToggleBtnLook) },
		{ "FOV", 				UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedFOV) },
		{ "Roll", 				UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRoll) },
		{ "MoveResetBtnVisible", UIBinderSetIsVisible.New(self, self.BtnResetMove, false, true) },
	}

	self.BtnSave:SetBtnName(LSTR(10011)) -- "保  存"

	-------------------------------------------------------------------------------------------------------
	--- 平移

	local StartMoveCBFunc = function()
		self:StartOrEndDrag(true)

		PersonPortraitVM.CurModelEditVM:SetMoveResetBtnVisible(true)
	end

	local EndMoveCBFunc = function()
		self:StartOrEndDrag(false)

		if not PersonPortraitVM.IsPositionValid then
			MsgTipsUtil.ShowErrorTips(LSTR(60028)) -- "请在肖像范围内正确展示玩家角色表情"
		end
	end

	local MoveStep = 0.5 
	local MoveCBFunc = function(NormalVector)
		local CurMove = PersonPortraitVM.CurModelEditVM.Move
		if nil == CurMove then
			return
		end

		local ComImageView = self.CommonRender2DToImageView
		if nil == ComImageView then
			return
		end

		local X = CurMove[1] or 0
		local Y = CurMove[2] or 0
		local Z = CurMove[3] or 0

		Y = -NormalVector.X * MoveStep + Y
		Z = -NormalVector.Y * MoveStep + Z

		ComImageView:SetSpringArmLocation(X, Y, Z, false)
	end
	
	self.CommStick:SetParams(StartMoveCBFunc, MoveCBFunc, EndMoveCBFunc)
end

function PersonPortraitModelEditPanelView:OnDestroy()

end

function PersonPortraitModelEditPanelView:OnShow()
	self.CommonRender2DToImageView = self.ParentView:GetCommonRender2DToImageView()

	local IsShowDecorate = PersonPortraitVM.DecorateVisibleSet
	self.ToggleBtnDecorate:SetChecked(IsShowDecorate, false)

	-- 移动
	self:StartOrEndDrag(false)

	self.SliderFOV:SetImgIcon(ScaleIconPath)
	self.SliderRoll:SetImgIcon(RotateIconPath)
end

function PersonPortraitModelEditPanelView:OnHide()
	self:StartOrEndDrag(false)
	self.CommonRender2DToImageView = nil
end

function PersonPortraitModelEditPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnHand, 	self.OnStateChangedToggleHand)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnHat, 		self.OnStateChangedToggleHat)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnDecorate, self.OnStateChangedToggleDecorate)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnFace, 	self.OnStateChangedToggleFace)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnLook, 	self.OnStateChangedToggleLook)

	UIUtil.AddOnClickedEvent(self, self.BtnFaceReset, 	self.OnClickButtonFaceReset)
	UIUtil.AddOnClickedEvent(self, self.BtnLookReset, 	self.OnClickButtonLookReset)
	UIUtil.AddOnClickedEvent(self, self.BtnCameraReset, self.OnClickButtonCameraReset)

	UIUtil.AddOnClickedEvent(self, self.BtnResetMove, 	self.OnClickButtonResetMove)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickButtonSave)
end

function PersonPortraitModelEditPanelView:OnRegisterGameEvent()

end

function PersonPortraitModelEditPanelView:OnRegisterBinder()
	self.SliderFOV:SetValueParam(0, SliderMaxFOV)
	self.SliderRoll:SetValueParam(-90, 90)

	self:RegisterBinders(PersonPortraitVM, self.BindersPersonPortraitVM)
	self:RegisterBinders(PersonPortraitVM.CurModelEditVM, self.BindersCurModelEditVM)
end

function PersonPortraitModelEditPanelView:StartOrEndDrag(IsStart)
	self.IsDraging = IsStart 

	-- 设置一些操作物件的透明度
	local Opacity = IsStart and 0 or 1
	UIUtil.SetRenderOpacity(self.CameraPanel, Opacity)
	UIUtil.SetRenderOpacity(self.BottomPanel, Opacity)
	UIUtil.SetRenderOpacity(self.BtnSave, Opacity)
	UIUtil.SetRenderOpacity(self.BtnResetMove, Opacity)

	local ComImageView = self.CommonRender2DToImageView
	if ComImageView then
		-- 缩放
		ComImageView:EnableZoom(not IsStart)
	end
end

function PersonPortraitModelEditPanelView:CheckIsDraging()
    if self.IsDraging then
        MsgTipsUtil.ShowTips(LSTR(60019)) -- "请完成移动操作"
        return true
    end

    return false
end

function PersonPortraitModelEditPanelView:ResetMove()
	local ComImageView = self.CommonRender2DToImageView
	if nil == ComImageView then 
		return
	end

	local X, Y, Z = table.unpack(PersonPortraitUtil.GetDefaultMove())
	ComImageView:SetSpringArmLocation(X, Y, Z, false)

	PersonPortraitVM.CurModelEditVM:SetMove(X, Y, Z)
end

function PersonPortraitModelEditPanelView:UpdateLookAtType()
	local IsFace = self.ToggleBtnFace:GetChecked()
	local IsLook = self.ToggleBtnLook:GetChecked()
	self.ParentView:UpdateLookAtType(IsFace, IsLook)
end

function PersonPortraitModelEditPanelView:ResetLookAtType()
	local IsFace = self.ToggleBtnFace:GetChecked()
	local IsLook = self.ToggleBtnLook:GetChecked()
	self.ParentView:ResetLookAtType(IsFace, IsLook)
end
-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function PersonPortraitModelEditPanelView:OnValueChangedFOV(Value)
	self.SliderFOV:SetValue(Value)
end

function PersonPortraitModelEditPanelView:OnValueChangedRoll(Value)
	self.SliderRoll:SetValue(Value)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

---显示/隐藏 武器
function PersonPortraitModelEditPanelView:OnStateChangedToggleHand(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if self:CheckIsDraging() then
		self.ToggleBtnHand:SetChecked(not IsChecked, false)
		return
	end

	local IsHide = not IsChecked
	PersonPortraitVM.CurModelEditVM:SetIsHideWeapon(IsHide)

	local ComImageView = self.CommonRender2DToImageView
	if ComImageView then
		ComImageView:HideWeapon(IsHide)
	end
end

---显示/隐藏 头盔 
function PersonPortraitModelEditPanelView:OnStateChangedToggleHat(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if self:CheckIsDraging() then
		self.ToggleBtnHat:SetChecked(not IsChecked, false)
		return
	end

	local IsHide = not IsChecked
	PersonPortraitVM.CurModelEditVM:SetIsHideHat(IsHide)

	local ComImageView = self.CommonRender2DToImageView
	if ComImageView then
		ComImageView:HideHead(IsHide)
	end
end

---隐藏/显示装饰
function PersonPortraitModelEditPanelView:OnStateChangedToggleDecorate(ToggleButton, State)
	PersonPortraitVM:UpdateDecorateVisible(UIUtil.IsToggleButtonChecked(State))
end

---面向镜头/取消面向镜头
function PersonPortraitModelEditPanelView:OnStateChangedToggleFace(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	self:UpdateFaceState(IsChecked)
end

function PersonPortraitModelEditPanelView:UpdateFaceState(IsChecked)
	if self:CheckIsDraging() then
		self.ToggleBtnFace:SetChecked(not IsChecked, false)
		return
	end

	PersonPortraitVM.CurModelEditVM:SetIsFace(IsChecked)

	if self.IsFaceReset then
		self.IsFaceReset = nil
		return
	end

	self:UpdateLookAtType()

	-- "已开启面向镜头"、"已关闭面向镜头"
	MsgTipsUtil.ShowTips(IsChecked and LSTR(60021) or LSTR(60022))
end

---看向镜头/取消看向镜头(视线)
function PersonPortraitModelEditPanelView:OnStateChangedToggleLook(ToggleButton, State)
	self:UpdateLookState(UIUtil.IsToggleButtonChecked(State))
end

function PersonPortraitModelEditPanelView:UpdateLookState(IsChecked)
	if self:CheckIsDraging() then
		self.ToggleBtnLook:SetChecked(not IsChecked, false)
		return
	end

	PersonPortraitVM.CurModelEditVM:SetIsLook(IsChecked)

	if self.IsLookReset then
		self.IsLookReset = nil
		return
	end

	self:UpdateLookAtType()

	-- "已开启看向镜头" 、"已关闭看向镜头"
	MsgTipsUtil.ShowTips(IsChecked and LSTR(60024) or LSTR(60025))
end

---重置面向设置
function PersonPortraitModelEditPanelView:OnClickButtonFaceReset()
	if self:CheckIsDraging() then
		return
	end

	self.IsFaceReset = true
	self.ToggleBtnFace:SetChecked(false)
	self:UpdateFaceState(false)

	self:ResetLookAtType()
	MsgTipsUtil.ShowTips(LSTR(60020)) -- "已重置面向镜头"
end

---重置看向(视线)设置
function PersonPortraitModelEditPanelView:OnClickButtonLookReset()
	if self:CheckIsDraging() then
		return
	end

	self.IsLookReset = true
	self.ToggleBtnLook:SetChecked(false)
	self:UpdateLookState(false)

	self:ResetLookAtType()
	MsgTipsUtil.ShowTips(LSTR(60023)) -- "已重置看向镜头"
end

---重置镜头设置（缩放、滚动、平移）
function PersonPortraitModelEditPanelView:OnClickButtonCameraReset()
	if self:CheckIsDraging() then
		return
	end

	local ComImageView = self.CommonRender2DToImageView
	if nil == ComImageView then 
		return
	end

	-- 缩放(视距+FOV)
    local Distance = PersonPortraitUtil.GetDefaultDistance()
	ComImageView:SetSpringArmDistance(Distance)

	local FOV = PersonPortraitUtil.GetDefaultFOV()
	ComImageView:SetCameraFOV(PersonPortraitUtil.SliderValue2CameraFOV(FOV))

	-- 滚动 
    local Roll = PersonPortraitUtil.GetDefaultRoll()
	ComImageView:SetCameraRoll(Roll)

	-- 平移 
	self:ResetMove()

	MsgTipsUtil.ShowTips(LSTR(60026)) -- "已重置镜头设置"
end

---重置移动
function PersonPortraitModelEditPanelView:OnClickButtonResetMove()
	self:ResetMove()
	MsgTipsUtil.ShowTips(LSTR(60027)) -- "已重置移动"

	PersonPortraitVM.CurModelEditVM:SetMoveResetBtnVisible(false)
end

function PersonPortraitModelEditPanelView:OnClickButtonSave()
	-- 是否正处于移动状态
	if self:CheckIsDraging() then
		return
	end

	-- 其他条件
	if not self.ParentView:CheckSaveSettings() then
		return
	end

	-- 打开装饰
	self.ToggleBtnDecorate:SetChecked(true, true)

	_G.PersonPortraitMgr:SendSavePortraitImageData()

end

return PersonPortraitModelEditPanelView