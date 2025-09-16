---
--- Author: chriswang
--- DateTime: 2025-02-22 16:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DataReportUtil = require("Utils/DataReportUtil")

--@ViewModel
local LoginRoleSetNameVM = require("Game/LoginRole/LoginRoleSetNameVM")

--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local CommonUtil = require("Utils/CommonUtil")
local LSTR = _G.LSTR

---@class LoginCreateMakeNamePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnOK UFButton
---@field CommInputBox CommInputBoxView
---@field ImgBg UFImage
---@field ImgFeather UFImage
---@field ImgNameBg UFImage
---@field ImgNameFlame UFImage
---@field ImgNameFlame2 UFImage
---@field PopUpBG CommonPopUpBGView
---@field TextFailed UFTextBlock
---@field TextOK UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateMakeNamePanelView = LuaClass(UIView, true)

function LoginCreateMakeNamePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnOK = nil
	--self.CommInputBox = nil
	--self.ImgBg = nil
	--self.ImgFeather = nil
	--self.ImgNameBg = nil
	--self.ImgNameFlame = nil
	--self.ImgNameFlame2 = nil
	--self.PopUpBG = nil
	--self.TextFailed = nil
	--self.TextOK = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateMakeNamePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommInputBox)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateMakeNamePanelView:OnInit()
	self.bForbidAnim = true
    self.ViewModel = LoginRoleSetNameVM
	self.CommInputBox:SetCallback(self, self.OnInputBoxTextChanged, self.OnTextCommitted)

end

function LoginCreateMakeNamePanelView:OnDestroy()

end

function LoginCreateMakeNamePanelView:OnShow()
	self.LastbEnable = nil
	self.TextTitle:SetText(LSTR(980056))	--冒险者，怎么称呼你呢？
	self.TextFailed:SetText(LSTR(980057))	--*昵称不可用	
	self.CommInputBox:SetHintText(LSTR(980058))--输入昵称

    self.ViewModel:SetInputTextRoleName(self.ViewModel.RoleName)
	self.TextOK:SetText(LSTR(980088))
	
	if string.isnilorempty(self.ViewModel.RoleName) then
		self:SetOKBtnEnable(false, true)
	else
		self:SetOKBtnEnable(true, true)
		self.NeedCheckName = true
	end

	local PreName = _G.LoginMgr:GetPreName()
	if not string.isnilorempty(PreName) then
		self.NeedCheckName = true
		self.ViewModel.RoleName = PreName
		self.CommInputBox:SetText(PreName)
		self:SetOKBtnEnable(true, true)
	else
		self:SetPlatformNickName()
	end
	
	self.LastbEnable = false

	if self.Params and self.Params.ShowBg then
		UIUtil.SetIsVisible(self.ImgBg, true)
		UIUtil.SetIsVisible(self.CommonBkg02, true)
	else
		UIUtil.SetIsVisible(self.ImgBg, false)
		UIUtil.SetIsVisible(self.CommonBkg02, false)
	end

	_G.UE.UGPMMgr.Get():PostLoginStepEvent(_G.DataReportLoginPhase.LoginCreateMakeName
		, 0, 0, "Success", "", false, false)

	local AppStartTime = CommonUtil.GetAppStartTime()
	DataReportUtil.ReportLoginCreateData("29", _G.UE.UPlatformUtil.GetDeviceName()	--29: 起名界面出现
		, _G.LoginMgr.OpenID, tostring(AppStartTime), tostring(_G.LoginMgr:GetRoleID()))
end

function LoginCreateMakeNamePanelView:OnHide()
	self.bForbidAnim = true
	self.NeedCheckName = nil
end

function LoginCreateMakeNamePanelView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.FButton_RandomName, self.OnRandomNameBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnOK, self.OnMakeNameBtnClick)
end

function LoginCreateMakeNamePanelView:OnRegisterGameEvent()

end

function LoginCreateMakeNamePanelView:OnRegisterBinder()
	local Binders = {
		{ "bSetNameError", UIBinderSetIsVisible.New(self, self.TextFailed) },
		{ "RecordRoleNameFunc", UIBinderValueChangedCallback.New(self, nil, self.OnRecordRoleName) },
		{ "SetInputText", UIBinderValueChangedCallback.New(self, nil, self.OnSetInputText) },
		{ "SetBtnEnable", UIBinderValueChangedCallback.New(self, nil, self.OnSetBtnEnable) },
		{ "CheckNameRsp", UIBinderValueChangedCallback.New(self, nil, self.OnCheckNameRsp) },
	}
	
	self:RegisterBinders(self.ViewModel, Binders)
end

function LoginCreateMakeNamePanelView:OnAnimationFinished(Anim)
	if Anim == self.AnimIn then
		if self.NeedCheckName then
			self.NeedCheckName = nil
			self.LastbEnable = false
			_G.LoginMgr:CheckNameRepeat(self.ViewModel.RoleName)
			return
		end

		self.bForbidAnim = nil
		if self.LastbEnable then
			-- FLOG_WARNING("%s", debug.traceback())
			self:PlayAnimation(self.AnimActivation)
		else
			-- FLOG_ERROR("%s", debug.traceback())
			-- self:PlayAnimation(self.AnimActivationOut)
		end
	end
end

function LoginCreateMakeNamePanelView:OnCheckNameRsp(bCheckNameRsp)
	if bCheckNameRsp then
		if self.bForbidAnim then
			self.LastbEnable = false
			self.bForbidAnim = nil

			if _G.DemoMajorType == 0 then
				FLOG_WARNING("LoginCreateMakeNamePanelView OnCheckNameRsp DemoMajorType = 0")
				return
			end

			self:SetOKBtnEnable(true)
		end
	end
end

function LoginCreateMakeNamePanelView:SetOKBtnEnable(bEnable, bNoAnim)
	local OutlineSize = 2
	if bEnable then
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextOK, "#FFFCF1")
		-- UIUtil.SetIsVisible(self.ImgNameBg, true)
		-- UIUtil.SetIsVisible(self.ImgNameFlame2, true)
		if not bNoAnim and not self.bForbidAnim and not self.bAnimActiveState then
			-- FLOG_WARNING("%s", debug.traceback())
			self:StopAllAnimations()
			self:PlayAnimation(self.AnimActivation)
			self.bAnimActiveState = true
		end
	else
		UIUtil.TextBlockSetColorAndOpacityHex(self.TextOK, "#696969")
		-- UIUtil.SetIsVisible(self.ImgNameBg, false)
		-- UIUtil.SetIsVisible(self.ImgNameFlame2, false)
		if not bNoAnim and not self.bForbidAnim and self.bAnimActiveState then
			-- FLOG_ERROR("%s", debug.traceback())
			self.bAnimActiveState = false
			self:StopAllAnimations()
			self:PlayAnimation(self.AnimActivationOut)
		end

		OutlineSize = 0
	end

	self.LastbEnable = bEnable
	self.BtnOK:SetIsEnabled(bEnable)

	self.TextOK.Font.OutlineSettings.OutlineSize = OutlineSize
	self.TextOK:SetFont(self.TextOK.Font)	
end

function LoginCreateMakeNamePanelView:OnMakeNameBtnClick()
	if _G.DemoMajorType == 0 then
		FLOG_WARNING("LoginCreateMakeNamePanelView OnMakeNameBtnClick, DemoMajorType = 0")
		return
	end

	-- self:Hide()
	self.ViewModel:RecordRoleName()
	if not self.ViewModel:OnFinishName() then
		return
	end

	FLOG_INFO("LoginCreateMakeNamePanelView OnMakeNameBtnClick")
	if CommonUtil.GetPlatformName() == "Windows" then
		_G.LoginMgr.IsClickFinishCreateBtn = true
	end
	
	self.NeedCheckName = false
	self:SetOKBtnEnable(false)
end

function LoginCreateMakeNamePanelView:OnSetBtnEnable(IsEnable)
	if _G.DemoMajorType == 0 then
		FLOG_WARNING("LoginCreateMakeNamePanelView OnSetBtnEnable DemoMajorType = 0")
		return
	end

	self:SetOKBtnEnable(IsEnable)
end

function LoginCreateMakeNamePanelView:OnRecordRoleName(IsRecord)
	if IsRecord then
		self.ViewModel.RoleName = self.CommInputBox:GetText()
		FLOG_INFO("Login set role name: %s", self.ViewModel.RoleName)
		
		self.ViewModel.RecordRoleNameFunc = false
	end
end

function LoginCreateMakeNamePanelView:OnSetInputText(RoleName)
	self.CommInputBox:SetText(RoleName)
end

-- function LoginCreateMakeNamePanelView:OnRandomNameBtnClick()
-- 	local Name = self.ViewModel:GetRandomName()
-- 	FLOG_INFO("Login GetRandomName: %s", Name)
-- 	self.IgnoreNextState = true
-- 	self.CommInputBox:SetText(Name)
-- 	self.IgnoreNextState = false

-- 	_G.LoginMgr:CheckNameRepeat(Name)
-- 	self.ViewModel:RecordRoleName()
-- end

function LoginCreateMakeNamePanelView:OnInputBoxTextChanged(Text, Len)
	if not self.IgnoreNextState and not self.bForbidAnim then
		--手机：输入框内容变化，禁用与否不改变，然后输入法commit的时候（相当于输入法上点完成、输入法消失），才去发包检查重名
		--PC：输入框变化，按钮就可点击
		local DeviceType = CommonUtil.GetDeviceType()
		if DeviceType == 0 or DeviceType == 1 then	--手机平台：ios 0 android 1
			if Len <= 0 then
				self:SetOKBtnEnable(false, not self.LastbEnable)
			else
				self:SetOKBtnEnable(true, true)
			end
		else	--非手机
			if Len > 0 then
				self:SetOKBtnEnable(true, true)
			else
				self:SetOKBtnEnable(false, not self.LastbEnable)
			end
		end
	end
	
	if self.ViewModel.bSetNameError then
		self.ViewModel.bSetNameError = false
	end
	_G.FLOG_INFO("LoginCreateMakeNamePanelView:OnInputBoxTextChanged :%s", tostring(Text))
end

---@param Name string @回调的文本
function LoginCreateMakeNamePanelView:OnTextCommitted(Name)
	if not string.isnilorempty(Name) then
		_G.LoginMgr:CheckNameRepeat(Name)
    
		self.ViewModel:RecordRoleName()
	end
end

function LoginCreateMakeNamePanelView:SetPlatformNickName()
	local NickName =  _G.LoginMgr:GetNickName()
	_G.FLOG_INFO("LoginCreateMakeNamePanelView:SetPlatformNickName, NickName:%s", NickName)
	if not string.isnilorempty(NickName) then
		local RealNickNameLength = 0
		local UcharLen
		local NewNickName = ""
		local MatchPattern = "[%z\1-\127\194-\244][\128-\191]*"
		for Uchar in string.gmatch(NickName, MatchPattern) do
			UcharLen = string.len(Uchar)
			--FLOG_INFO("LoginCreateNamePanelView:SetPlatformNickName, Uchar:%s, Len:%d", Uchar, UcharLen)
			if UcharLen == 3 then
				RealNickNameLength = RealNickNameLength + 2
			elseif UcharLen == 1 then
				RealNickNameLength = RealNickNameLength + 1
			end
		end
		_G.FLOG_INFO("LoginCreateMakeNamePanelView:SetPlatformNickName, RealNickNameLength:%d", RealNickNameLength)

		if RealNickNameLength <= self.CommInputBox.MaxNum then
			for Uchar in string.gmatch(NickName, MatchPattern) do
				NewNickName = NewNickName..Uchar
			end
		else
			local CurNickNameLength = 0
			for Uchar in string.gmatch(NickName, MatchPattern) do
				UcharLen = string.len(Uchar)
				--FLOG_INFO("LoginCreateNamePanelView:SetPlatformNickName, Uchar:%s, Len:%d", Uchar, UcharLen)
				if UcharLen == 3 then
					CurNickNameLength = CurNickNameLength + 2
				elseif UcharLen == 1 then
					CurNickNameLength = CurNickNameLength + 1
				end

				if CurNickNameLength <= self.CommInputBox.MaxNum - 3 then
					NewNickName = NewNickName..Uchar
				else
					NewNickName = NewNickName.."..."
					break
				end
			end
		end

		self.CommInputBox:SetText(NewNickName)
		self.ViewModel.RoleName = NewNickName

		self.NeedCheckName = true
		self:SetOKBtnEnable(true, true)
	end
end

return LoginCreateMakeNamePanelView