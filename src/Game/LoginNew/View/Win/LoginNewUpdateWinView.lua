---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local UserAgreementConfig = require("Config/UserAgreementUpdateConfig")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local LSTR = _G.LSTR

---@class LoginNewUpdateWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAgree CommBtnLView
---@field BtnRefuse CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field RichText URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewUpdateWinView = LuaClass(UIView, true)

function LoginNewUpdateWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAgree = nil
	--self.BtnRefuse = nil
	--self.Comm2FrameM_UIBP = nil
	--self.RichText = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewUpdateWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAgree)
	self:AddSubView(self.BtnRefuse)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewUpdateWinView:OnInit()
	self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(LoginStrID.UpdateTipsTitle))
	self.RichText:SetText(string.format(LSTR(LoginStrID.UpdateContent), LSTR(UserAgreementConfig.UKey), LSTR(UserAgreementConfig.UKey)))
	self.BtnAgree.TextContent:SetText(LSTR(LoginStrID.Agree))
	self.BtnRefuse.TextContent:SetText(LSTR(LoginStrID.NoAgree))
end

function LoginNewUpdateWinView:OnDestroy()

end

function LoginNewUpdateWinView:OnShow()
	LoginNewVM.NeedShowUpdateAgreementView = false
end

function LoginNewUpdateWinView:OnHide()

end

function LoginNewUpdateWinView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichText, self.OnClickRichTextAgreement, nil)
	UIUtil.AddOnClickedEvent(self, self.BtnAgree, self.OnClickBtnAgree)
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse, self.OnClickBtnRefuse)
end

function LoginNewUpdateWinView:OnRegisterGameEvent()

end

function LoginNewUpdateWinView:OnRegisterBinder()

end

function LoginNewUpdateWinView:OnClickRichTextAgreement(_, LinkID)
	_G.AccountUtil.OpenUrl(UserAgreementConfig.Url, LinkID, false, true, "", false)
end

function LoginNewUpdateWinView:OnClickBtnAgree()
	LoginNewVM:SetAgreeProtocol(true)
	self:Hide()
end

function LoginNewUpdateWinView:OnClickBtnRefuse()
	_G.EventMgr:SendEvent(_G.EventID.LoginRefuseAgreement)
	LoginNewVM:SetAgreeProtocol(false)
	self:Hide()
end

return LoginNewUpdateWinView