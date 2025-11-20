---
--- Author: Administrator
--- DateTime: 2025-07-10 14:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsReturnTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot CommonRedDotView
---@field TextNoraml UFTextBlock
---@field TextSelect UFTextBlock
---@field ToggleButton UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsReturnTabItemView = LuaClass(UIView, true)

function OpsReturnTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot = nil
	--self.TextNoraml = nil
	--self.TextSelect = nil
	--self.ToggleButton = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsReturnTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsReturnTabItemView:OnInit()

end

function OpsReturnTabItemView:OnDestroy()

end

function OpsReturnTabItemView:OnShow()
end

function OpsReturnTabItemView:OnHide()
end

function OpsReturnTabItemView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.ToggleButton, self.OnClickedItem)
end

function OpsReturnTabItemView:OnRegisterGameEvent()

end

function OpsReturnTabItemView:OnRegisterBinder()
end

function OpsReturnTabItemView:SetText(Text)
	self.TextNoraml:SetText(Text)
	self.TextSelect:SetText(Text)
end

function OpsReturnTabItemView:SetChecked(IsSelelcted)
	self.ToggleButton:SetChecked(IsSelelcted, false)
end

return OpsReturnTabItemView