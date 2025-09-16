---
--- Author: chunfengluo
--- DateTime: 2023-04-18 10:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

---@class FateMissionTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Text_Content URichTextBox
---@field AnimMission UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateMissionTipsView = LuaClass(InfoTipsBaseView, true)

function FateMissionTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Text_Content = nil
	--self.AnimMission = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateMissionTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateMissionTipsView:OnInit()

end

function FateMissionTipsView:OnDestroy()

end

function FateMissionTipsView:OnShow()
	self.Super:OnShow()
	self.Text_Content:SetText(self.Params.Content)
	self:PlayAnimation(self.AnimMission)
end

function FateMissionTipsView:OnHide()

end

function FateMissionTipsView:OnRegisterUIEvent()

end

function FateMissionTipsView:OnRegisterGameEvent()

end

function FateMissionTipsView:OnRegisterBinder()

end

function FateMissionTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

return FateMissionTipsView