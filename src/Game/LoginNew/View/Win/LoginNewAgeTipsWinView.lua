---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID
local LSTR = _G.LSTR

---@class LoginNewAgeTipsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnOK CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewAgeTipsWinView = LuaClass(UIView, true)

function LoginNewAgeTipsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnOK = nil
	--self.Comm2FrameM_UIBP = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewAgeTipsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnOK)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewAgeTipsWinView:OnInit()

end

function LoginNewAgeTipsWinView:OnDestroy()

end

function LoginNewAgeTipsWinView:OnShow()
	self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(LoginStrID.AgeTips))
	self.TextTips:SetText(LSTR(LoginStrID.AgeTipsContent))
	self.BtnOK.TextContent:SetText(LSTR(LoginStrID.ConfirmBtnStr))
end

function LoginNewAgeTipsWinView:OnHide()

end

function LoginNewAgeTipsWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnOK, self.OnClickBtnOk)
end

function LoginNewAgeTipsWinView:OnRegisterGameEvent()

end

function LoginNewAgeTipsWinView:OnRegisterBinder()

end

function LoginNewAgeTipsWinView:OnClickBtnOk()
	UIViewMgr:HideView(UIViewID.LoginAgeAppropriate)
end

return LoginNewAgeTipsWinView