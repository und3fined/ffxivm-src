---
--- Author: chriswang
--- DateTime: 2023-10-24 10:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

--@ViewModel
local LoginRoleSetNameVM = require("Game/LoginRole/LoginRoleSetNameVM")

--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local CommonUtil = require("Utils/CommonUtil")

---@class LoginCreateNamePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommInputBox_UIBP CommInputBoxView
---@field FButton_RandomName UFButton
---@field ImgMark05 UFImage
---@field InputText UEditableText
---@field PanelBirthday UFCanvasPanel
---@field PanelGod UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelNickName UFCanvasPanel
---@field PanelRace UFCanvasPanel
---@field PanelRole UFCanvasPanel
---@field PanelTribe UFCanvasPanel
---@field TextBDInfo UFTextBlock
---@field TextFailed UFTextBlock
---@field TextGodInfo UFTextBlock
---@field TextGodTitle UFTextBlock
---@field TextRaceInfo UFTextBlock
---@field TextRole UFTextBlock
---@field TextRoleInfo UFTextBlock
---@field TextTribeInfo UFTextBlock
---@field Text_Number UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateNamePanelView = LuaClass(UIView, true)

function LoginCreateNamePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommInputBox_UIBP = nil
	--self.FButton_RandomName = nil
	--self.ImgMark05 = nil
	--self.InputText = nil
	--self.PanelBirthday = nil
	--self.PanelGod = nil
	--self.PanelInfo = nil
	--self.PanelNickName = nil
	--self.PanelRace = nil
	--self.PanelRole = nil
	--self.PanelTribe = nil
	--self.TextBDInfo = nil
	--self.TextFailed = nil
	--self.TextGodInfo = nil
	--self.TextGodTitle = nil
	--self.TextRaceInfo = nil
	--self.TextRole = nil
	--self.TextRoleInfo = nil
	--self.TextTribeInfo = nil
	--self.Text_Number = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateNamePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	-- self:AddSubView(self.CommInputBox_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateNamePanelView:OnInit()
    self.ViewModel = LoginRoleSetNameVM
	-- self.CommInputBox_UIBP:SetCallback(self, self.OnInputBoxTextChanged, self.OnTextCommitted)
end

function LoginCreateNamePanelView:OnDestroy()

end

function LoginCreateNamePanelView:OnShow()
	--文本显示放在前面，幻想药会隐藏部分控件并return
	self.TextRace:SetText(_G.LSTR(980049))	--种族
	self.TextTribe:SetText(_G.LSTR(980050))	--部族
	self.TextBirthday:SetText(_G.LSTR(980051))	--创建日
	self.TextGod:SetText(_G.LSTR(980052))	--守护神
	self.TextRole:SetText(_G.LSTR(980053))	--职业

	-- self.TextCall:SetText(_G.LSTR(980056))	--冒险者，怎么称呼你呢？
	-- self.TextFailed:SetText(_G.LSTR(980057))	--*昵称不可用	
	-- self.CommInputBox_UIBP:SetHintText(_G.LSTR(980058))--输入昵称

	--幻想药复用了创建姓名的界面，用作完成创建的界面，对应Finishment阶段，需要隐藏姓名相关的组件，打开按钮
	if _G.LoginMapMgr.CurLoginMapType == _G.LoginMapType.Fantasia then
		_G.LoginUIMgr:SetNextBtnEnable(true)
		-- UIUtil.SetIsVisible(self.PanelNickName, false, false, false)
		UIUtil.SetIsVisible(self.PanelRole, false, false, false)
		self.ViewModel:OnShow()
		return
	else
		-- UIUtil.SetIsVisible(self.PanelNickName, true, false, false)
		UIUtil.SetIsVisible(self.PanelRole, true, false, false)
	end

	self.ViewModel:OnShow()

	-- local NameStr = self.CommInputBox_UIBP:GetText()
	-- if string.isnilorempty(NameStr) then
	-- 	_G.LoginUIMgr:SetNextBtnEnable(false)
	-- else
	-- 	_G.LoginUIMgr:SetNextBtnEnable(true)
	-- end
	_G.LoginUIMgr:SetNextBtnEnable(true)

	-- self:SetPlatformNickName()
end

function LoginCreateNamePanelView:OnHide()
	_G.LoginUIMgr:SetNextBtnEnable(true)
end

function LoginCreateNamePanelView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.FButton_RandomName, self.OnRandomNameBtnClick)
end

function LoginCreateNamePanelView:OnRegisterGameEvent()

end

function LoginCreateNamePanelView:OnRegisterBinder()
	local Binders = {
		-- { "bSetNameError", UIBinderSetIsVisible.New(self, self.TextFailed) },
		{ "RaceName", UIBinderSetText.New(self, self.TextRaceInfo) },
		{ "TribeName", UIBinderSetText.New(self, self.TextTribeInfo) },
		{ "Birthday", UIBinderSetText.New(self, self.TextBDInfo) },
		{ "GodName", UIBinderSetText.New(self, self.TextGodInfo) },
		{ "TitleName", UIBinderSetText.New(self, self.TextGodTitle) },
		{ "ProfName", UIBinderSetText.New(self, self.TextRoleInfo) },
		-- { "RecordRoleNameFunc", UIBinderValueChangedCallback.New(self, nil, self.OnRecordRoleName) },
		-- { "SetInputText", UIBinderValueChangedCallback.New(self, nil, self.OnSetInputText) },
	}
	
	self:RegisterBinders(self.ViewModel, Binders)
end

-- function LoginCreateNamePanelView:OnRecordRoleName(IsRecord)
-- 	if IsRecord then
-- 		self.ViewModel.RoleName = self.CommInputBox_UIBP:GetText()
-- 		FLOG_INFO("Login set role name: %s", self.ViewModel.RoleName)
		
-- 		self.ViewModel.RecordRoleNameFunc = false
-- 	end
-- end

-- function LoginCreateNamePanelView:OnSetInputText(RoleName)
-- 	self.CommInputBox_UIBP:SetText(RoleName)
-- end

-- function LoginCreateNamePanelView:OnRandomNameBtnClick()
-- 	local Name = self.ViewModel:GetRandomName()
-- 	FLOG_INFO("Login GetRandomName: %s", Name)
-- 	self.IgnoreNextState = true
-- 	self.CommInputBox_UIBP:SetText(Name)
-- 	self.IgnoreNextState = false

-- 	_G.LoginMgr:CheckNameRepeat(Name)
-- 	self.ViewModel:RecordRoleName()
-- end

-- function LoginCreateNamePanelView:OnInputBoxTextChanged(Text, Len)
-- 	if not self.IgnoreNextState then
-- 		--手机：输入框内容变化，禁用与否不改变，然后输入法commit的时候（相当于输入法上点完成、输入法消失），才去发包检查重名
-- 		--PC：输入框变化，按钮就可点击
-- 		local DeviceType = CommonUtil.GetDeviceType()
-- 		if DeviceType == 0 or DeviceType == 1 then	--手机平台：ios 0 android 1
-- 			if Len <= 0 then
-- 				_G.LoginUIMgr:SetNextBtnEnable(false)
-- 			else
-- 				_G.LoginUIMgr:SetNextBtnEnable(true)
-- 			end
-- 		else	--非手机
-- 			if Len > 0 then
-- 				_G.LoginUIMgr:SetNextBtnEnable(true)
-- 			else
-- 				_G.LoginUIMgr:SetNextBtnEnable(false)
-- 			end
-- 		end
-- 	end
	
-- 	if self.ViewModel.bSetNameError then
-- 		self.ViewModel.bSetNameError = false
-- 	end
-- 	_G.FLOG_INFO("LoginCreateNamePanelView:OnInputBoxTextChanged :%s", tostring(Text))
-- end

-- ---@param Name string @回调的文本
-- function LoginCreateNamePanelView:OnTextCommitted(Name)
-- 	if not string.isnilorempty(Name) then
-- 		_G.LoginMgr:CheckNameRepeat(Name)
    
-- 		self.ViewModel:RecordRoleName()
-- 	end
-- end

-- function LoginCreateNamePanelView:SetPlatformNickName()
-- 	local NickName =  _G.LoginMgr:GetNickName()
-- 	_G.FLOG_INFO("LoginCreateNamePanelView:SetPlatformNickName, NickName:%s", NickName)
-- 	if not string.isnilorempty(NickName) then
-- 		local NickNameLength = 0
-- 		local UcharLen
-- 		local NewNickName = ""
-- 		for Uchar in string.gmatch(NickName, "[%z\1-\127\194-\244][\128-\191]*") do
-- 			UcharLen = string.len(Uchar)
-- 			--FLOG_INFO("LoginCreateNamePanelView:SetPlatformNickName, Uchar:%s, Len:%d", Uchar, UcharLen)
-- 			if UcharLen == 3 then
-- 				NickNameLength = NickNameLength + 2
-- 			elseif UcharLen == 1 then
-- 				NickNameLength = NickNameLength + 1
-- 			end

-- 			if NickNameLength <= self.CommInputBox_UIBP.MaxNum - 3 then
-- 				NewNickName = NewNickName..Uchar
-- 			else
-- 				NewNickName = NewNickName.."..."
-- 				break
-- 			end
-- 		end
-- 		self.CommInputBox_UIBP:SetText(NewNickName)
-- 		_G.LoginUIMgr:SetNextBtnEnable(true)
-- 	end
-- end

return LoginCreateNamePanelView