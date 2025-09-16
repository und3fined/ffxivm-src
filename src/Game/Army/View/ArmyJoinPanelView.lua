---
--- Author: qibaoyiyi
--- DateTime: 2023-03-08 09:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")

---@class ArmyJoinPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field InvitationPage ArmyInvitationPageView
---@field JoinPage ArmyJoinArmyPageView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyJoinPanelView = LuaClass(UIView, true)

function ArmyJoinPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.InvitationPage = nil
	--self.JoinPage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyJoinPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.InvitationPage)
	self:AddSubView(self.JoinPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyJoinPanelView:OnInit()
	self.Binders = {
		{ "bJoinPage", UIBinderSetIsVisible.New(self, self.JoinPage)},
		{ "bInvitationPage", UIBinderSetIsVisible.New(self, self.InvitationPage)}
	}
end

function ArmyJoinPanelView:OnDestroy()

end

function ArmyJoinPanelView:OnShow()

end

function ArmyJoinPanelView:OnHide()

end

function ArmyJoinPanelView:OnRegisterUIEvent()

end

function ArmyJoinPanelView:OnRegisterGameEvent()

end

function ArmyJoinPanelView:OnRegisterBinder()
	local VM = ArmyMainVM:GetJoinPanelVM()
	if nil == VM then
		return
	end
	self:RegisterBinders(VM, self.Binders)
end

function ArmyJoinPanelView:IsForceGC()
	return true
end

return ArmyJoinPanelView