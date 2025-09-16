---
--- Author: richyczhou
--- DateTime: 2025-05-06 11:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginNewResetPasswordWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet CommBtnSView
---@field BtnStart CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommInputCode CommInputBoxView
---@field CommInputConfirm CommInputBoxView
---@field CommInputEmail CommInputBoxView
---@field CommInputPassWord CommInputBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewResetPasswordWinView = LuaClass(UIView, true)

function LoginNewResetPasswordWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGet = nil
	--self.BtnStart = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommInputCode = nil
	--self.CommInputConfirm = nil
	--self.CommInputEmail = nil
	--self.CommInputPassWord = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewResetPasswordWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGet)
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommInputCode)
	self:AddSubView(self.CommInputConfirm)
	self:AddSubView(self.CommInputEmail)
	self:AddSubView(self.CommInputPassWord)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewResetPasswordWinView:OnInit()

end

function LoginNewResetPasswordWinView:OnDestroy()

end

function LoginNewResetPasswordWinView:OnShow()

end

function LoginNewResetPasswordWinView:OnHide()

end

function LoginNewResetPasswordWinView:OnRegisterUIEvent()

end

function LoginNewResetPasswordWinView:OnRegisterGameEvent()

end

function LoginNewResetPasswordWinView:OnRegisterBinder()

end

return LoginNewResetPasswordWinView