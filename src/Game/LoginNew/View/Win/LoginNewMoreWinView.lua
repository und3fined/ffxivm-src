---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local MSDKDefine = require("Define/MSDKDefine")
local UIUtil = require("Utils/UIUtil")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR

---@class LoginNewMoreWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnLine UFButton
---@field BtnX UFButton
---@field HorizontalLogin UHorizontalBox
---@field ImgLine UFImage
---@field ImgX UFImage
---@field PopUpBG CommonPopUpBGView
---@field RichTextBoxTitle URichTextBox
---@field TextLine UFTextBlock
---@field TextX UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewMoreWinView = LuaClass(UIView, true)

function LoginNewMoreWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnLine = nil
	--self.BtnX = nil
	--self.HorizontalLogin = nil
	--self.ImgLine = nil
	--self.ImgX = nil
	--self.PopUpBG = nil
	--self.RichTextBoxTitle = nil
	--self.TextLine = nil
	--self.TextX = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewMoreWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewMoreWinView:OnInit()
	self.RichTextBoxTitle:SetText(LSTR(LoginStrID.SwitchLoginAccount))
	self.TextX:SetText(LSTR(LoginStrID.Twitter))
	self.TextLine:SetText(LSTR(LoginStrID.Line))
end

function LoginNewMoreWinView:OnDestroy()

end

function LoginNewMoreWinView:OnShow()

end

function LoginNewMoreWinView:OnHide()

end

function LoginNewMoreWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnX, self.OnClickBtnTwitter)
	UIUtil.AddOnClickedEvent(self, self.BtnLine, self.OnClickBtnLine)
end

function LoginNewMoreWinView:OnRegisterGameEvent()

end

function LoginNewMoreWinView:OnRegisterBinder()

end

function LoginNewMoreWinView:OnClickBtnTwitter()
	FLOG_INFO("[LoginNewMoreWinView:OnClickBtnTwitter]")
	self:StopMedia()
	_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.Twitter, "", "", "{\"loginUsingWeb\":true}")
end

function LoginNewMoreWinView:OnClickBtnLine()
	FLOG_INFO("[LoginNewMoreWinView:OnClickBtnLine]")
	self:StopMedia()
	_G.UE.UAccountMgr.Get():Login(MSDKDefine.Channel.Line, table.concat(MSDKDefine.LoginPermissions.Line, ","), "", "")
end

return LoginNewMoreWinView