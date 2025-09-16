---
--- Author: Administrator
--- DateTime: 2024-10-16 17:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyShowInfoLeaderPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLeaderInfo UFButton
---@field CommPlayerHeadSlot_UIBP CommPlayerHeadSlotView
---@field TextCaptain UFTextBlock
---@field TextCaptainName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimUpdate UWidgetAnimation
---@field Styles ArmyShowInfoStyle
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyShowInfoLeaderPageView = LuaClass(UIView, true)

function ArmyShowInfoLeaderPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnLeaderInfo = nil
	--self.CommPlayerHeadSlot_UIBP = nil
	--self.TextCaptain = nil
	--self.TextCaptainName = nil
	--self.AnimIn = nil
	--self.AnimUpdate = nil
	--self.Styles = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyShowInfoLeaderPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerHeadSlot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyShowInfoLeaderPageView:OnInit()

end

function ArmyShowInfoLeaderPageView:OnDestroy()

end

function ArmyShowInfoLeaderPageView:OnShow()
	-- LSTR string:部队长
	self.TextCaptain:SetText(LSTR(910264))
end

function ArmyShowInfoLeaderPageView:OnHide()

end

function ArmyShowInfoLeaderPageView:OnRegisterUIEvent()

end

function ArmyShowInfoLeaderPageView:OnRegisterGameEvent()

end

function ArmyShowInfoLeaderPageView:OnRegisterBinder()

end

return ArmyShowInfoLeaderPageView