---
--- Author: Administrator
--- DateTime: 2025-02-26 16:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsHalloweenMancrTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot_UIBP CommonRedDotView
---@field IconLock UFImage
---@field TextNormal UFTextBlock
---@field TextSelect UFTextBlock
---@field ToggleBtnTab UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsHalloweenMancrTabItemView = LuaClass(UIView, true)

function OpsHalloweenMancrTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot_UIBP = nil
	--self.IconLock = nil
	--self.TextNormal = nil
	--self.TextSelect = nil
	--self.ToggleBtnTab = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsHalloweenMancrTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsHalloweenMancrTabItemView:OnInit()

end

function OpsHalloweenMancrTabItemView:OnDestroy()

end

function OpsHalloweenMancrTabItemView:OnShow()

end

function OpsHalloweenMancrTabItemView:SetText(Text)
	self.TextNormal:SetText(Text)
	self.TextSelect:SetText(Text)
end

function OpsHalloweenMancrTabItemView:SetChecked(IsSelelcted)
	self.ToggleBtnTab:SetChecked(IsSelelcted, false)
end

function OpsHalloweenMancrTabItemView:SetRedDotNameByString(RedDotName)
	self.CommonRedDot_UIBP:SetRedDotNameByString(RedDotName)
end

function OpsHalloweenMancrTabItemView:SetLock(IsLock)
	UIUtil.SetIsVisible(self.IconLock, IsLock)
end


function OpsHalloweenMancrTabItemView:OnHide()

end

function OpsHalloweenMancrTabItemView:OnRegisterUIEvent()

end

function OpsHalloweenMancrTabItemView:OnRegisterGameEvent()

end

function OpsHalloweenMancrTabItemView:OnRegisterBinder()

end

return OpsHalloweenMancrTabItemView