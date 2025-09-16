---
--- Author: richyczhou
--- DateTime: 2025-05-06 11:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class LoginNewCode2WinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet CommBtnSView
---@field BtnStart CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommHorTabs CommHorTabsView
---@field CommInputCode CommInputBoxView
---@field CommInputEmail CommInputBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewCode2WinView = LuaClass(UIView, true)

function LoginNewCode2WinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGet = nil
	--self.BtnStart = nil
	--self.Comm2FrameM_UIBP = nil
	--self.CommHorTabs = nil
	--self.CommInputCode = nil
	--self.CommInputEmail = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewCode2WinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGet)
	self:AddSubView(self.BtnStart)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommHorTabs)
	self:AddSubView(self.CommInputCode)
	self:AddSubView(self.CommInputEmail)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewCode2WinView:OnInit()

end

function LoginNewCode2WinView:OnDestroy()

end

function LoginNewCode2WinView:OnShow()

end

function LoginNewCode2WinView:OnHide()

end

function LoginNewCode2WinView:OnRegisterUIEvent()

end

function LoginNewCode2WinView:OnRegisterGameEvent()

end

function LoginNewCode2WinView:OnRegisterBinder()

end

return LoginNewCode2WinView