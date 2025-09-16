---
--- Author: chriswang
--- DateTime: 2023-10-17 11:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UKismetInputLibrary = UE.UKismetInputLibrary
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")

---@class LoginCreateMorePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAction UToggleButton
---@field BtnArchive UFButton
---@field BtnCameraReset UToggleButton
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
---@field TextTips UFTextBlock
---@field AnimFold UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateMorePageView = LuaClass(UIView, true)

function LoginCreateMorePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAction = nil
	--self.BtnArchive = nil
	--self.BtnCameraReset = nil
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
	--self.TextTips = nil
	--self.AnimFold = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateMorePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateMorePageView:OnInit()
	self.IsHideUI = true
	self.IsGaze = false
	self.IsTieUpHair = false
end

function LoginCreateMorePageView:OnDestroy()

end

function LoginCreateMorePageView:OnShow()
	self.TextTips:SetText(_G.LSTR(980055))	--当前外观仅为预览
	self:UpdateArrows()
	self:ResetBtns()
end

function LoginCreateMorePageView:OnHide()
	self.LastClickBtn = nil
	-- self.IsGaze = false
	self.IsTieUpHair = false
end

function LoginCreateMorePageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnBtnMoreClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCameraReset, self.OnBtnCameraResetClick)
	
	UIUtil.AddOnStateChangedEvent(self, self.BtnAction, self.OnToggleBtnAction)			--动作
	UIUtil.AddOnStateChangedEvent(self, self.BtnHideUI, self.OnToggleBtnHideUI)			--隐藏UI
	-- UIUtil.AddOnStateChangedEvent(self, self.BtnSetting, self.OnToggleBtnSetting)		--设置
	UIUtil.AddOnStateChangedEvent(self, self.BtnGaze, self.OnToggleBtnGaze)				--注视
	UIUtil.AddOnStateChangedEvent(self, self.BtnTieUpHair, self.OnToggleBtnTieUpHair)	--束发
	UIUtil.AddOnStateChangedEvent(self, self.BtnShare, self.OnToggleBtnShare)			--Share
	-- UIUtil.AddOnStateChangedEvent(self, self.BtnEnv, self.OnToggleBtnEnv)				--环境
	-- UIUtil.AddOnStateChangedEvent(self, self.BtnTryOn, self.OnToggleBtnTryOn)			--试穿
	UIUtil.AddOnClickedEvent(self, self.BtnArchive, self.OnClickBtnArchive)             -- 存档
	UIUtil.AddOnClickedEvent(self, self.BtnRead, self.OnClickBtnRead)             		-- 读档
end

function LoginCreateMorePageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)

	self:RegisterGameEvent(_G.EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
end

function LoginCreateMorePageView:OnRegisterBinder()

end

function LoginCreateMorePageView:OnBtnCameraResetClick()
	_G.LoginUIMgr:ResetRenderActorCamera(true)
	_G.EventMgr:SendEvent(EventID.LoginCameraReset)
end

function LoginCreateMorePageView:OnBtnMoreClick()
	_G.LoginUIMgr.IsFixPageClickBtnMore = not _G.LoginUIMgr.IsFixPageClickBtnMore
	self:UpdateArrows()
	-- self:ResetBtns()
end

function LoginCreateMorePageView:OnPreprocessedMouseButtonDown(MouseEvent)
	if _G.LoginUIMgr.IsFixPageClickBtnMore then
		local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
		if UIUtil.IsUnderLocation(self.BtnMore, MousePosition) == false
			and UIUtil.IsUnderLocation(self.PanelMoreTips, MousePosition) == false then
			_G.LoginUIMgr.IsFixPageClickBtnMore = false
			self:UpdateArrows()
		end
	end
end

function LoginCreateMorePageView:UpdateArrows()
	UIUtil.SetIsVisible(self.BtnScanCode, false)
	UIUtil.SetIsVisible(self.BtnScanUpload, false)

	if _G.LoginUIMgr:GetCurRolePhase() == _G.LoginRolePhase.SelectRole then
		UIUtil.SetIsVisible(self.BtnRead, false)
	else
		UIUtil.SetIsVisible(self.BtnRead, true, true)
	end

	if _G.LoginUIMgr.IsFixPageClickBtnMore then
		-- UIUtil.SetIsVisible(self.HorizontalBtns, true)
		UIUtil.SetIsVisible(self.PanelMoreTips, true)
		-- self:PlayAnimation(self.AnimFold)
		-- UIUtil.SetIsVisible(self.BtnAction, true, true)	--动作
		-- UIUtil.SetIsVisible(self.BtnEnv, true, true)	--环境
		-- UIUtil.SetIsVisible(self.BtnTryOn, true, true)	--试穿

		-- self.BtnMore todo
		self.BtnMore:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
		-- UIUtil.SetIsVisible(self.ImgMore, false)
		-- UIUtil.SetIsVisible(self.ImgLess, true)
	else
		-- UIUtil.SetIsVisible(self.HorizontalBtns, false)
		UIUtil.SetIsVisible(self.PanelMoreTips, false)
		-- self:PlayAnimation(self.AnimUnfold)
		self.BtnMore:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)

		-- UIUtil.SetIsVisible(self.ImgMore, true)
		-- UIUtil.SetIsVisible(self.ImgLess, false)
	end
end

function LoginCreateMorePageView:ResetBtns()
	self.IsGaze = _G.LoginUIMgr.IsGaze
	-- self.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	-- self.BtnTieUpHair:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	-- self.BtnAction:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	-- self.BtnEnv:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	-- self.BtnTryOn:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	-- self.BtnHideUI:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	UIUtil.SetIsVisible(self.BtnAction, false)
	self:ResetHairBtn()
	self:RefreshBtnGaze()
	self.IsHideUI = _G.LoginUIMgr.IsHideUI
	self:OnToggleBtnHideUI()
end

function LoginCreateMorePageView:ResetHairBtn()
	-- 束发状态
	self.IsTieUpHair = _G.LoginAvatarMgr:GetTieUpHairState()
	if self.IsTieUpHair then
		self.BtnTieUpHair:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	else
		self.BtnTieUpHair:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	end
end

function LoginCreateMorePageView:ResetLastBtn()
	if self.LastClickBtn then
		self.LastClickBtn:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
		-- UIUtil.SetRenderOpacity(self.LastClickBtn, 0.5)
	end
end

function LoginCreateMorePageView:SetLastBtn(LastBtn)
	self.LastClickBtn = LastBtn
	-- UIUtil.SetRenderOpacity(self.LastClickBtn, 1)

	self.LastClickBtn:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
end

--动作
function LoginCreateMorePageView:OnToggleBtnAction()
	self:ResetLastBtn()
	_G.LoginUIMgr:OnShowPreviewPage()
	self:SetLastBtn(self.BtnAction)
end

--隐藏UI
function LoginCreateMorePageView:OnToggleBtnHideUI()
	_G.LoginUIMgr:OnHideUI(self.IsHideUI)

	if self.IsHideUI then
		self.IsHideUI = false
		self.BtnHideUI:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	else
		self.IsHideUI = true
		self.BtnHideUI:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	end

	self:ResetBtnsByHideUI(self.IsHideUI)
end

function LoginCreateMorePageView:ResetBtnsByHideUI(BtnHideUI)
	if BtnHideUI then
		UIUtil.SetIsVisible(self.PanelMoreTips, false)
		_G.LoginUIMgr.IsFixPageClickBtnMore = false
		
		UIUtil.SetIsVisible(self.BtnGaze, true, true)
		UIUtil.SetIsVisible(self.BtnMore, true, true)
		
		if not UIViewMgr:IsViewVisible(UIViewID.LoginSelectRoleNew) then
			UIUtil.SetIsVisible(self.BtnTieUpHair, true, true)
		end

		UIUtil.SetIsVisible(self.BtnShare, false)--true, true)
	else
		UIUtil.SetIsVisible(self.BtnGaze, false)
		UIUtil.SetIsVisible(self.BtnMore, false)
		UIUtil.SetIsVisible(self.BtnTieUpHair, false)
		UIUtil.SetIsVisible(self.BtnShare, false)
	end
end

--设置
-- function LoginCreateMorePageView:OnToggleBtnSetting()
-- 	self:ResetLastBtn()
-- 	MsgTipsUtil.ShowTips(LSTR(980026))
-- 	self:SetLastBtn(self.BtnSetting)
-- end

function LoginCreateMorePageView:GetIsGaze()
	return self.IsGaze
end

function LoginCreateMorePageView:ResetIsGaze(IsGaze)
	self.IsGaze = IsGaze
end

function LoginCreateMorePageView:OnAssembleAllEnd(Params)
	self:RefreshBtnGaze()
end

function LoginCreateMorePageView:RefreshBtnGaze()
	local Actor = _G.LoginUIMgr:GetUIComplexCharacter()
	if not Actor then
		return
	end
	_G.LoginAvatarMgr:UpdateLookAtLimit()
	if self.IsGaze then
		self.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	else
		self.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	end

	ActorUtil.SetUILookAt(Actor, self.IsGaze, _G.UE.ELookAtType.ALL, true)
end

--注视
function LoginCreateMorePageView:OnToggleBtnGaze()
	local Actor = _G.LoginUIMgr:GetUIComplexCharacter()
	if not Actor then
		return
	end

	if self.IsGaze then
		self.IsGaze = false
		self.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	else
		self.IsGaze = true
		self.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	end

	_G.LoginUIMgr:OnGazeStateChg(self.IsGaze)
	ActorUtil.SetUILookAt(Actor, self.IsGaze, _G.UE.ELookAtType.ALL, true)
end

--束发
function LoginCreateMorePageView:OnToggleBtnTieUpHair()
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

--分享
function LoginCreateMorePageView:OnToggleBtnShare()
	self:ResetLastBtn()
	MsgTipsUtil.ShowTips(LSTR(980026))
	self:SetLastBtn(self.BtnShare)
end

-- --环境
-- function LoginCreateMorePageView:OnToggleBtnEnv()
-- 	self:ResetLastBtn()
-- 	-- UIViewMgr:ShowView(UIViewID.LoginRoleShowPage, 3)
-- 	MsgTipsUtil.ShowTips(LSTR(980026))
-- 	self:SetLastBtn(self.BtnEnv)
-- end

-- --试穿
-- function LoginCreateMorePageView:OnToggleBtnTryOn()
-- 	self:ResetLastBtn()
-- 	_G.LoginUIMgr:OnSuitTryOn()
-- 	self:SetLastBtn(self.BtnTryOn)
-- end

-- 存档
function LoginCreateMorePageView:OnClickBtnArchive()
	_G.LoginAvatarMgr:DealServerFace(true)
end
-- 读档
function LoginCreateMorePageView:OnClickBtnRead()
	_G.LoginAvatarMgr:DealServerFace(false)
end
return LoginCreateMorePageView