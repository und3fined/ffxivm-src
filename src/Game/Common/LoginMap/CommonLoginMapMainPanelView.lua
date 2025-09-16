---
--- Author: chriswang
--- DateTime: 2024-01-10 14:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require ("Utils/MajorUtil")

---@class CommonLoginMapMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAction UToggleButton
---@field BtnArchive UFButton
---@field BtnGaze UToggleButton
---@field BtnHideUI UToggleButton
---@field BtnMore UToggleButton
---@field BtnRead UFButton
---@field BtnScanCode UFButton
---@field BtnScanUpload UFButton
---@field BtnSetting UToggleButton
---@field BtnShare UToggleButton
---@field BtnTieUpHair UToggleButton
---@field HorizontalBtns UFHorizontalBox
---@field ImgArchive UFImage
---@field ImgRead UFImage
---@field ImgScanCode UFImage
---@field ImgScanUpload UFImage
---@field PanelMoreTips UFCanvasPanel
---@field SpacerBar USpacer
---@field SpacerBar2 USpacer
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonLoginMapMainPanelView = LuaClass(UIView, true)

function CommonLoginMapMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAction = nil
	--self.BtnArchive = nil
	--self.BtnGaze = nil
	--self.BtnHideUI = nil
	--self.BtnMore = nil
	--self.BtnRead = nil
	--self.BtnScanCode = nil
	--self.BtnScanUpload = nil
	--self.BtnSetting = nil
	--self.BtnShare = nil
	--self.BtnTieUpHair = nil
	--self.HorizontalBtns = nil
	--self.ImgArchive = nil
	--self.ImgRead = nil
	--self.ImgScanCode = nil
	--self.ImgScanUpload = nil
	--self.PanelMoreTips = nil
	--self.SpacerBar = nil
	--self.SpacerBar2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonLoginMapMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonLoginMapMainPanelView:OnInit()
	self.IsGaze = true
	self.IsTieUpHair = false

end

function CommonLoginMapMainPanelView:OnDestroy()

end

function CommonLoginMapMainPanelView:OnShow()
	self.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	self.BtnTieUpHair:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
end

function CommonLoginMapMainPanelView:OnHide()
	self.IsGaze = true
	self.IsTieUpHair = false

end

function CommonLoginMapMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnClose)
	UIUtil.AddOnStateChangedEvent(self, self.BtnAction, self.OnToggleBtnAction)			--动作
	UIUtil.AddOnStateChangedEvent(self, self.BtnGaze, self.OnToggleBtnGaze)				--注视
	UIUtil.AddOnStateChangedEvent(self, self.BtnTieUpHair, self.OnToggleBtnTieUpHair)	--束发

end

function CommonLoginMapMainPanelView:OnRegisterGameEvent()

end

function CommonLoginMapMainPanelView:OnRegisterBinder()

end

function CommonLoginMapMainPanelView:OnToggleBtnAction()
	_G.LoginUIMgr:OnShowPreviewPage()
end

function CommonLoginMapMainPanelView:GetIsGaze()
	return self.IsGaze
end

function CommonLoginMapMainPanelView:OnBtnClose()
	_G.PWorldMgr:SendLeavePWorld()
end

--注视
function CommonLoginMapMainPanelView:OnToggleBtnGaze()
	local Actor = _G.LoginUIMgr:GetUIComplexCharacter()
	if not Actor then
		return
	end

	-- _G.LoginAvatarMgr:SetCameraFocus(0, false, true)

	if self.IsGaze then
		self.IsGaze = false
		self.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	else
		self.IsGaze = true
		self.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	end

	_G.LoginUIMgr:OnGazeStateChg(self.IsGaze)
	Actor:UseAnimLookAt(self.IsGaze)
end

--束发
function CommonLoginMapMainPanelView:OnToggleBtnTieUpHair()
	if self.IsTieUpHair then
		self.IsTieUpHair = false
		self.BtnTieUpHair:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	else
		self.IsTieUpHair = true
		self.BtnTieUpHair:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	end

	_G.LoginUIMgr:OnTieUpHairStateChg(self.IsTieUpHair)
	_G.LoginAvatarMgr:TieUpHair(self.IsTieUpHair)
end

return CommonLoginMapMainPanelView