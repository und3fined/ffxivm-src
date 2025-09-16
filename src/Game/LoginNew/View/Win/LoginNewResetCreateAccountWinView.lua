---
--- Author: richyczhou
--- DateTime: 2025-05-06 11:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginNewResetCreateAccountWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet CommBtnSView
---@field BtnStart CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommInputCode CommInputBoxView
---@field CommInputConfirm CommInputBoxView
---@field CommInputEmail CommInputBoxView
---@field CommInputPassWord CommInputBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewResetCreateAccountWinView = LuaClass(UIView, true)

function LoginNewResetCreateAccountWinView:Ctor()
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

function LoginNewResetCreateAccountWinView:OnRegisterSubView()
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

function LoginNewResetCreateAccountWinView:OnInit()

end

function LoginNewResetCreateAccountWinView:OnDestroy()

end

function LoginNewResetCreateAccountWinView:OnShow()

end

function LoginNewResetCreateAccountWinView:OnHide()

end

function LoginNewResetCreateAccountWinView:OnRegisterUIEvent()

end

function LoginNewResetCreateAccountWinView:OnRegisterGameEvent()

end

function LoginNewResetCreateAccountWinView:OnRegisterBinder()

end

return LoginNewResetCreateAccountWinView