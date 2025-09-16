---
--- Author: chriswang
--- DateTime: 2023-10-26 20:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")

---@class LoginCreateDemoSkillView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack LoginCreateBackPageView
---@field SkillMainPanel_UIBP SkillMainPanelView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateDemoSkillView = LuaClass(UIView, true)

function LoginCreateDemoSkillView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.SkillMainPanel_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateDemoSkillView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.SkillMainPanel_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateDemoSkillView:OnInit()

end

function LoginCreateDemoSkillView:OnDestroy()

end

function LoginCreateDemoSkillView:OnShow()
	self.BtnBack.TextTitle:SetText(LSTR(980002))
	UIUtil.SetIsVisible(self.BtnBack.TextSubtile, false)
	UIUtil.SetIsVisible(self.SkillMainPanel_UIBP.BackBtn, false)
	-- UIUtil.SetIsVisible(self.SkillMainPanel_UIBP.GoToTraining, false)
end

function LoginCreateDemoSkillView:OnHide()

end

function LoginCreateDemoSkillView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack.BtnBack, self.OnBackBtnClick)
end

function LoginCreateDemoSkillView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.RoleLoginRes, self.OnRoleLoginRes)
end

function LoginCreateDemoSkillView:OnRegisterBinder()

end

function LoginCreateDemoSkillView:OnBackBtnClick()
	FLOG_INFO("LoginCreateDemoSkillView:OnBackBtnClick")
	_G.LoginUIMgr:BackToProfPhase(true)
end

function LoginCreateDemoSkillView:OnRoleLoginRes(Params)
	if Params.bReconnect then
		self.SkillMainPanel_UIBP:LoginDemoSkillReConnect()
	end
end

return LoginCreateDemoSkillView