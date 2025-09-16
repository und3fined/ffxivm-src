---
--- Author: qibaoyiyi
--- DateTime: 2023-03-08 09:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMemberPanelVM = nil

---@class ArmyMemberPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MemberPage ArmyMemberPageView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberPanelView = LuaClass(UIView, true)

function ArmyMemberPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MemberPage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MemberPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberPanelView:OnInit()
    self.Binders = {
        {"bMemberPage", UIBinderSetIsVisible.New(self, self.MemberPage)},
    }
    ArmyMemberPanelVM = ArmyMainVM:GetMemberPanelVM()
end

function ArmyMemberPanelView:OnDestroy()
end

function ArmyMemberPanelView:OnShow()
end

function ArmyMemberPanelView:OnHide()
end

function ArmyMemberPanelView:OnRegisterUIEvent()
end

function ArmyMemberPanelView:OnRegisterGameEvent()
end

function ArmyMemberPanelView:OnRegisterBinder()
    self:RegisterBinders(ArmyMemberPanelVM, self.Binders)
end

function ArmyMemberPanelView:IsForceGC()
	return true
end

return ArmyMemberPanelView
