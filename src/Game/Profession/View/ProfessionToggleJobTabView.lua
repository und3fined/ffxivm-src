---
--- Author: zimuyi
--- DateTime: 2023-06-28 10:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ProfessionToggleJobTabView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field PopUpBG CommonPopUpBGView
---@field ToggleJobPage ProfessionToggleJobPageView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ProfessionToggleJobTabView = LuaClass(UIView, true)

function ProfessionToggleJobTabView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSidebarFrameS_UIBP = nil
	--self.PopUpBG = nil
	--self.ToggleJobPage = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ProfessionToggleJobTabView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.ToggleJobPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ProfessionToggleJobTabView:OnInit()

end

function ProfessionToggleJobTabView:OnDestroy()

end

function ProfessionToggleJobTabView:OnShow()
	self.PopUpBG.Hide = self.Hide
	self.CommSidebarFrameS_UIBP.CommonTitle.TextTitleName:SetText(LSTR(1050174))
end

function ProfessionToggleJobTabView:OnHide()

end

function ProfessionToggleJobTabView:OnRegisterUIEvent()

end

function ProfessionToggleJobTabView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MajorProfSwitch, self.OnMajorProfSwitch)
end

function ProfessionToggleJobTabView:OnRegisterBinder()

end

function ProfessionToggleJobTabView:OnMajorProfSwitch()
	self:Hide()
end

return ProfessionToggleJobTabView