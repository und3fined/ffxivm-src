---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local CommonUtil = require("Utils/CommonUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local LoginUtils = require("Game/LoginNew/LoginUtils")
local LuaClass = require("Core/LuaClass")
local RichTextUtil = require("Utils/RichTextUtil")
local SaveKey = require("Define/SaveKey")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local LSTR = _G.LSTR

local EDataReportLoginPhase = _G.UE.EDataReportLoginPhase

---@class LoginNewUserAgreementWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAgree CommBtnLView
---@field BtnRefuse CommBtnLView
---@field BtnVolume UFButton
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field RichText URichTextBox
---@field TableViewDrop UTableView
---@field TextHealthy UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewUserAgreementWinView = LuaClass(UIView, true)

function LoginNewUserAgreementWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAgree = nil
	--self.BtnRefuse = nil
	--self.BtnVolume = nil
	--self.Comm2FrameM_UIBP = nil
	--self.RichText = nil
	--self.TableViewDrop = nil
	--self.TextHealthy = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewUserAgreementWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAgree)
	self:AddSubView(self.BtnRefuse)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewUserAgreementWinView:OnInit()
	local HyperLink1 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.License), 1, "#6FB1E9FF",
			nil, nil, nil, nil, nil, false)
	local HyperLink2 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.FFPrivacy), 2, "#6FB1E9FF",
			nil, nil, nil, nil, nil, false)
	local HyperLink3 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.ChildrenPrivacy), 3, "#6FB1E9FF",
			nil, nil, nil, nil, nil, false)
	local HyperLink4 = RichTextUtil.GetHyperlink(LSTR(LoginStrID.InfoShareList), 4, "#6FB1E9FF",
			nil, nil, nil, nil, nil, false)
	local Msg1 = LSTR(LoginStrID.ClickToView)
	local Msg = string.format("%s%s、%s、%s、%s。", Msg1, HyperLink1, HyperLink2, HyperLink3, HyperLink4)
	self.RichText:SetText(Msg)

	self.TableViewDropAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewDrop)

	DataReportUtil.ReportLoginFlowData(EDataReportLoginPhase.PrivacyDialog)
	_G.UE.UGPMMgr.Get():PostLoginStepEvent(EDataReportLoginPhase.PrivacyDialog, 0, 0, "success", "", false, false)
end

function LoginNewUserAgreementWinView:OnDestroy()

end

function LoginNewUserAgreementWinView:OnShow()
	UIUtil.SetIsVisible(self.Comm2FrameM_UIBP.ButtonClose, false);

	local IndicatorConfig = {
		{ IsSelected = true },
		{ IsSelected = false }
	}
	self.TableViewDropAdapter:UpdateAll(IndicatorConfig)
	self.TableViewDropAdapter:SetSelectedIndex(1)
end

function LoginNewUserAgreementWinView:OnHide()

end

function LoginNewUserAgreementWinView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichText, self.OnClickRichTextAgreement, nil)
	UIUtil.AddOnClickedEvent(self, self.BtnAgree, self.OnClickBtnAgree)
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse, self.OnClickBtnRefuse)
	UIUtil.AddOnClickedEvent(self, self.BtnVolume, self.OnClickBtnVolume)
	UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.ButtonClose, self.OnClickBtnRefuse)
end

function LoginNewUserAgreementWinView:OnRegisterGameEvent()

end

function LoginNewUserAgreementWinView:OnRegisterBinder()

end

function LoginNewUserAgreementWinView:OnClickRichTextAgreement(_, LinkID)
	LoginUtils:OpenAgreementUrl(LinkID);
end

function LoginNewUserAgreementWinView:OnClickBtnAgree()
	DataReportUtil.ReportLoginFlowData(EDataReportLoginPhase.PrivacyAgree)
	_G.UE.UGPMMgr.Get():PostLoginStepEvent(EDataReportLoginPhase.PrivacyAgree, 0, 0, "success", "", false, false)

	-- 保存同意标志
	local SaveMgr = _G.UE.USaveMgr
	SaveMgr.LoadFile("PreLoginData", false, false)
	SaveMgr.SetInt(SaveKey.UserAgreement, 1, false)
	local RequirePermissionFlag = SaveMgr.GetInt(SaveKey.RequirePermission, 0, false)
	SaveMgr.SaveFile("PreLoginData", false)

	if 0 == RequirePermissionFlag and CommonUtil.IsAndroidPlatform() then
		UIViewMgr:ShowView(UIViewID.RequirePermission)
	else
		UIViewMgr:ShowView(UIViewID.LoginSplash)
	end
end

function LoginNewUserAgreementWinView:OnClickBtnRefuse()
	DataReportUtil.ReportLoginFlowData(EDataReportLoginPhase.PrivacyRefuse)
	_G.UE.UGPMMgr.Get():PostLoginStepEvent(EDataReportLoginPhase.PrivacyRefuse, 0, 0, "success", "", false, false)

	local MsgBoxUtil = require("Utils/MsgBoxUtil")
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(LoginStrID.TipsTitle), LSTR(LoginStrID.RefusePrivacyTips), self.OnClickBtnAgree, nil, LSTR(LoginStrID.CancelBtnStr), LSTR(LoginStrID.ConfirmBtnStr))
end

function LoginNewUserAgreementWinView:OnClickBtnVolume()
	-- TODO 静音

end

return LoginNewUserAgreementWinView