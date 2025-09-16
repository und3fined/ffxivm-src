---
--- Author: Administrator
--- DateTime: 2024-11-26 11:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local Json = require("Core/Json")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local LSTR = _G.LSTR
local HttpMgr = _G.HttpMgr
local LoginMgr = _G.LoginMgr --提供请求数据
local DataReportUtil = require("Utils/DataReportUtil")
local ServerDomain = _G.UE.UGCloudMgr.Get():IsPublish() and
"https://external.fmgame.qq.com:30001/rpc.fgame.externalserviceagent.Ams/ExchangeCDK" or
"http://119.147.3.250:31003/rpc.fgame.externalserviceagent.Ams/ExchangeCDK"
---@class SettingsCDKWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnOK CommBtnLView
---@field CommInputBox CommInputBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsCDKWinView = LuaClass(UIView, true)
function SettingsCDKWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnOK = nil
	--self.CommInputBox = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsCDKWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnOK)
	self:AddSubView(self.CommInputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsCDKWinView:OnInit()
	self.CommInputBox:SetCallback(self, self.OnInputBoxTextChanged, self.OnTextCommitted)
end

function SettingsCDKWinView:OnShow()
	self.BG:SetTitleText(LSTR(110004)) -- "兑换码"
	self.BtnOK:SetIsDisabledState(true, true)
	self.BtnOK:SetBtnName(LSTR(110046))
	self.BtnCancel:SetBtnName(LSTR(110021))
	--- 若输入框内容不为空，则置空
	if not string.isnilorempty(self.CommInputBox:GetText()) then
		self.CommInputBox:SetText("")
	end
end

function SettingsCDKWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnOK, self.OnClickBtnUse)
end

function SettingsCDKWinView:OnClickBtnCancel()
	self:Hide()
end

function SettingsCDKWinView:OnClickBtnUse()
	if string.isnilorempty(self.CommInputBox:GetText()) then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(110005)) -- "请输入兑换码"
	else
		local SendData = {}
		local ChannelID = LoginMgr:GetChannelID()
		if ChannelID == "10" then
			ChannelID = "101"
		end
		SendData.ChannelID = ChannelID
		SendData.OpenID = LoginMgr:GetOpenID()
		SendData.RoleID = MajorUtil.GetMajorRoleID()
		SendData.WorldID = LoginMgr:GetWorldID()
		SendData.OS = CommonUtil.GetDeviceType()
		SendData.CDKCode = self.CommInputBox:GetText()
		SendData.Token = LoginMgr:GetToken()
		local SendDataStr = Json.encode(SendData)
		_G.FLOG_INFO("SettingsCDKWinView.SendData, Url: %s", ServerDomain)
		_G.FLOG_INFO("SettingsCDKWinView.SendData, Data: %s",tostring(SendDataStr))
		--测试用，研发登录不能触发这个
		if SendData.ChannelId ~= "101" then
			HttpMgr:Post(ServerDomain, LoginMgr:GetToken(), SendDataStr, self.OnExchangeResult, self)
		else
			_G.FLOG_INFO("SettingsCDKWinView.SendCDKeyInfo, 研发登录的请求")
		end
	end
end

function SettingsCDKWinView:OnInputBoxTextChanged(Text, Len)
	UIUtil.SetIsVisible(self.TextNameDisabled, false)
	self.CommInputBox:SetText(Text)
	if Len >= 1 then
		self.BtnOK:SetIsDisabledState(false)
	else
		self.BtnOK:SetIsDisabledState(true, true)
	end
end

function SettingsCDKWinView:OnTextCommitted(KeyStr)
	if not string.isnilorempty(KeyStr) then
		self.RecordKeyStr = KeyStr
	end
end

function SettingsCDKWinView:OnExchangeResult(MsgBody,Result)
	local Msg = Json.decode(MsgBody)

	if Msg == nil then
		_G.FLOG_ERROR("SettingsCDKWinView.SendCDKeyResult, MsgBody is nil")
		_G.MsgTipsUtil.ShowErrorTips(_G.LSTR(110009))
		return
	end

	if Msg.iRet ~= 0 then
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "8", "1", "0")
	end

	if Msg.iRet == 0 then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(110006)) --- "兑换成功"
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "8", "1", "1")
	elseif Msg.iRet == -184 or Msg.iRet == 10063 or Msg.iRet == 10064 then
		_G.MsgTipsUtil.ShowErrorTips(_G.LSTR(110008)) --- "该兑换码已达使用上限"
		---10061  抱歉，该兑换码不在有效期内10062
	elseif Msg.iRet == -183 or Msg.iRet == -163 or Msg.iRet ==-165 or Msg.iRet == 10060 or Msg.iRet == 10061 or Msg.iRet == 10062 then
		_G.MsgTipsUtil.ShowErrorTips(_G.LSTR(110009)) --- "兑换码不存在"
	else
		_G.MsgTipsUtil.ShowErrorTips(_G.LSTR(110007)) --- "过于频繁，请稍后再试"
	end
end

function SettingsCDKWinView:OnDestroy()

end

function SettingsCDKWinView:OnHide()

end

function SettingsCDKWinView:OnRegisterGameEvent()

end

function SettingsCDKWinView:OnRegisterBinder()

end

return SettingsCDKWinView