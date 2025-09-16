---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local CommonUtil = require("Utils/CommonUtil")
local Json = require("Core/Json")
local LoginEmailVM = require("Game/LoginNew/VM/LoginEmailVM")
local LuaClass = require("Core/LuaClass")
local MSDKDefine = require("Define/MSDKDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local CommBtnLView = require("Game/Common/Btn/CommBtnLView")
local TimeUtil = require("Utils/TimeUtil")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID

local SaveKey = require("Define/SaveKey")
local USaveMgr = _G.UE.USaveMgr

local AccountMgr = _G.UE.UAccountMgr
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR

---@class LoginNewCodeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet CommBtnSView
---@field BtnStart CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommInputCode CommInputBoxView
---@field CommInputEmail CommInputBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewCodeWinView = LuaClass(UIView, true)

function LoginNewCodeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGet = nil
	--self.BtnStart = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommInputCode = nil
	--self.CommInputEmail = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	self.VerifyCodeLen = 0
end

function LoginNewCodeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGet)
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommInputCode)
	self:AddSubView(self.CommInputEmail)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewCodeWinView:OnInit()
	self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(LoginStrID.EmailLogin))
	self.BtnStart.TextContent:SetText(LSTR(LoginStrID.ConfirmBtnStr))
	self.CommInputEmail:SetHintText(LSTR(LoginStrID.InputEmail))
	self.CommInputCode:SetHintText(LSTR(LoginStrID.InputCode))

	---@type LoginLanguageVM
	self.LoginEmailVM = LoginEmailVM.New()

	self.CommInputEmail:SetCallback(self, self.OnTextEmailChanged)
	self.CommInputCode:SetCallback(self, self.OnTextVerifyCodeChanged)

	---@type UIAdapterCountDown
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.BtnGet, nil, "%ss", self.TimeOutCallback, self.TimeUpdateCallback)

	self.LoginEmailVM.IsCountdownTime = false
end

function LoginNewCodeWinView:OnDestroy()

end

function LoginNewCodeWinView:OnShow()
	local CurCultureName = CommonUtil.GetCurrentCultureName()
	if string.isnilorempty(CurCultureName) then
		CurCultureName = "zh_CN"
	end
	self.CurLangType = LoginNewDefine.EMailLangTypeMap[CurCultureName]
	FLOG_INFO("[LoginNewCodeWinView:OnShow] CurCultureName:%s, CurLangType:%s", CurCultureName, self.CurLangType)

	self.BtnGet:SetText(LSTR(LoginStrID.GetCode))

	local LastEmail = USaveMgr.GetString(SaveKey.LastEmail, "", false)
	self.LoginEmailVM:SetPropertyValue("Email", LastEmail)
	FLOG_INFO("[LoginNewCodeWinView:OnShow] LastEmail:%s", LastEmail)
	if LastEmail then
		self.CommInputEmail:SetText(LastEmail)
	end
	if string.len(self.CommInputEmail:GetText()) > 0 then
		self.BtnGet:SetIsRecommendState(true)
	else
		self.BtnGet:SetIsNormalState(true)
	end

	self.VerifyCodeLen = 0
	self.CommInputCode:SetText("")
	self.BtnStart:SetIsNormalState(true)

	if self.LoginEmailVM.IsCountdownTime then
		local ServerTime = TimeUtil.GetServerTime()
		local CodeCountdownTime = self.LoginEmailVM.CodeTotalTime - (ServerTime - self.LoginEmailVM.VerifyCodeSentTime)
		FLOG_INFO("[LoginNewCodeWinView:OnShow] NowTime:%d, SentTime:%d, LeftTime:%d", ServerTime, self.LoginEmailVM.VerifyCodeSentTime, CodeCountdownTime)
		if CodeCountdownTime > 0 then
			self.BtnGet:SetIsNormalState(true)
			self.AdapterCountDownTime:Start(CodeCountdownTime, 0.033, false, false)
		else
			self.LoginEmailVM.IsCountdownTime = false
		end
	end
end

function LoginNewCodeWinView:OnHide()
	--self.LoginEmailVM.IsCountdownTime = false
end

function LoginNewCodeWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnClickBtnSend)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnClickBtnStart)
end

function LoginNewCodeWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MSDKCustomAccountNotify, self.OnGameEventCustomAccountNotify)
end

function LoginNewCodeWinView:OnRegisterBinder()
	local Binders = {
		{ "Email", UIBinderSetText.New(self, self.InputBoxEmail) },
		{ "VerifyCode", UIBinderSetText.New(self, self.InputBoxCode) },
	}
	self:RegisterBinders(self.LoginEmailVM, Binders)
end

function LoginNewCodeWinView:OnTextEmailChanged(Text, Len)
	--FLOG_INFO("[LoginNewCodeWinView:OnTextEmailChanged] Text:%s", Text)
	-- TODO 判断是否符合邮箱地址
	rawset(self.LoginEmailVM, "Email", Text)
	if Len > 0 then
		self.BtnGet:SetIsRecommendState(true)
	else
		self.BtnGet:SetIsNormalState(true)
	end

	if Len > 0 and self.VerifyCodeLen > 0 then
		self.BtnStart:SetIsRecommendState(true)
	else
		self.BtnStart:SetIsNormalState(true)
	end
end

function LoginNewCodeWinView:OnTextVerifyCodeChanged(Text, Len)
	--FLOG_INFO("[LoginNewCodeWinView:OnTextVerifyCodeChanged] Text:%s", Text)
	rawset(self.LoginEmailVM, "VerifyCode", Text)
	self.VerifyCodeLen = Len
	if Len > 0 and string.len(self.LoginEmailVM.Email) > 0 then
		self.BtnStart:SetIsRecommendState(true)
	else
		self.BtnStart:SetIsNormalState(true)
	end
end

function LoginNewCodeWinView:OnGameEventCustomAccountNotify(AccountRet)
	FLOG_INFO("[LoginNewCodeWinView:OnGameEventCustomAccountNotify] RetCode:%d, MethodNameID:%d", AccountRet.RetCode, AccountRet.MethodNameID)
	if AccountRet.MethodNameID == MSDKDefine.MethodName.kMethodNameAccountVerifyCode then
		FLOG_INFO("[LoginNewCodeWinView:OnGameEventCustomAccountNotify] VerifyCode VerifyCodeExpireTime:%d", AccountRet.VerifyCodeExpireTime)
		if AccountRet.RetCode == MSDKDefine.MSDKError.SUCCESS then
			MsgTipsUtil.ShowTips(LSTR(LoginStrID.CodeSent))
			self.LoginEmailVM.CodeTotalTime = AccountRet.VerifyCodeExpireTime
			self.LoginEmailVM.IsCountdownTime = true
			self.BtnGet:SetIsNormalState(true)
			self.LoginEmailVM.VerifyCodeSentTime = TimeUtil.GetServerTime()
			self.AdapterCountDownTime:Start(AccountRet.VerifyCodeExpireTime, 0.033, false, false)
		end
	elseif AccountRet.MethodNameID == MSDKDefine.MethodName.kMethodNameAccountGetRegisterStatus then
		FLOG_INFO("[LoginNewCodeWinView:OnGameEventCustomAccountNotify] RegisterStatus IsRegister:%d", AccountRet.IsRegister)
		self.IsRegister = AccountRet.IsRegister
	end
end

--- 发送验证码
function LoginNewCodeWinView:OnClickBtnSend()
	if not self:IsValidEmail(self.LoginEmailVM.Email) then
		MsgTipsUtil.ShowTips(LSTR(LoginStrID.InvalidEmail))
		return
	end

	if self.LoginEmailVM.IsCountdownTime then
		MsgTipsUtil.ShowTips(LSTR(LoginStrID.WaitCD))
		return
	end

	USaveMgr.SetString(SaveKey.LastEmail, self.LoginEmailVM.Email, false)

	if CommonUtil.IsWithEditor() then
		-- TEST
		MsgTipsUtil.ShowTips(LSTR(LoginStrID.CodeSent))
		self.LoginEmailVM.IsCountdownTime = true
		self.BtnGet:SetIsNormalState(true)
		self.LoginEmailVM.VerifyCodeSentTime = TimeUtil.GetServerTime()
		self.AdapterCountDownTime:Start(self.LoginEmailVM.CodeTotalTime, 0.033, false, false)
		FLOG_INFO("[LoginNewCodeWinView:OnClickBtnSend] SentTime:%d", self.LoginEmailVM.VerifyCodeSentTime)
	else
		FLOG_INFO("[LoginNewCodeWinView:OnClickBtnSend] ")
		self:RequestVerifyCode()
	end
end

function LoginNewCodeWinView:OnClickBtnStart()
	if not self:IsValidEmail(self.LoginEmailVM.Email) then
		MsgTipsUtil.ShowTips(LSTR(LoginStrID.InvalidEmail))
		return
	end

	if self.VerifyCodeLen < 1 then
		MsgTipsUtil.ShowTips(LSTR(LoginStrID.InputCode))
		return
	end

	---@type EmailExtraJson
	local EmailExtraJson = {};
	EmailExtraJson.type = "loginWithCode"
	EmailExtraJson.account = self.LoginEmailVM.Email
	EmailExtraJson.verifyCode = tonumber(self.LoginEmailVM.VerifyCode)
	EmailExtraJson.accountType = 1
	EmailExtraJson.langType = self.CurLangType
	EmailExtraJson.areaCode = ""
	local ExtraJson = Json.encode(EmailExtraJson)
	FLOG_INFO("[LoginNewCodeWinView:OnClickBtnStart] ExtraJson:%s", ExtraJson)

	AccountMgr.Get():Login(MSDKDefine.Channel.Self, "", "", ExtraJson)
end

function LoginNewCodeWinView:GetRegisterStatus()
	--/**
	--* 用户账号是否注册查询接口
	--* @param Channel           【必填】渠道名称，"Self" 为自建账号渠道
	--* @param Account           【必填】注册的账号
	--* @param AccountType       【必填】账号类型，1-邮箱，2-手机号
	--* @param LangType          【必填】指定发送给用户的验证码短信或邮件所有语言
	--* @param AreaCode          【选填】手机区号，账号为手机类型时必填，邮箱渠道可直接填""，对于手机区号 areaCode 字段，业务在做 UI 页面设计的时候，建议让用户做选择，而不是手动输入
	--* @param ExtraJson         【选填】扩展字段，默认为空，会透传到后台
	--*/
	AccountMgr.Get():GetRegisterStatus(MSDKDefine.Channel.Self, self.LoginEmailVM.Email, 1, self.CurLangType, "", "");
end

function LoginNewCodeWinView:RequestVerifyCode()
	--/**
	--* 发送校验码接口
	--* @param Channel           【必填】渠道名称，"Self" 为自建账号渠道
	--* @param Account           【必填】注册的账号
	--* @param CodeType          【必填】生成的验证码类型，0-注册,1-修改密码,2-验证码登录,3-修改账号信息
	--* @param AccountType       【必填】账号类型，1-邮箱，2-手机号
	--* @param LangType          【必填】指定发送给用户的验证码短信或邮件所用语言
	--* @param AreaCode          【选填】手机区号，账号为手机类型时必填，邮箱渠道可直接填""，对于手机区号 areaCode 字段，业务在做 UI 页面设计的时候，建议让用户做选择，而不是手动输入
	--* @param ExtraJson         【选填】扩展字段，默认为空，会透传到后台
	--*/
	AccountMgr.Get():RequestVerifyCode(MSDKDefine.Channel.Self, self.LoginEmailVM.Email, 2, 1, self.CurLangType, "", "");
end

function LoginNewCodeWinView:IsValidEmail(Email)
	if not Email then
		return false
	end

	local pattern = "^[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?$"
	if string.match(Email, pattern) then
		return true
	else
		return false
	end
end

--- 当倒计时至最后
function LoginNewCodeWinView:TimeOutCallback()
	self.LoginEmailVM.VerifyCodeSentTime = 0
	self.LoginEmailVM.IsCountdownTime = false
	self.BtnGet:SetIsRecommendState(true)
	self.BtnGet:SetText(LSTR(LoginStrID.GetCode))
end

--- 此函数每1s调用一次 刷时间
---@param LeftTime number 剩余时间
function LoginNewCodeWinView:TimeUpdateCallback(LeftTime)
	if LeftTime < 0 then
		LeftTime = 0
	end

	--FLOG_INFO("[LoginNewCodeWinView:TimeUpdateCallback] LeftTime:%.2f", LeftTime)
	return math.floor(LeftTime)
end

return LoginNewCodeWinView