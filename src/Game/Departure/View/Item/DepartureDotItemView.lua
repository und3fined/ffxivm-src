---
--- Author: Administrator
--- DateTime: 2025-03-13 14:21
--- Description:玩法说明图片索引ItemView
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class DepartureDotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureDotItemView = LuaClass(UIView, true)

function DepartureDotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureDotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureDotItemView:OnInit()

end

function DepartureDotItemView:OnDestroy()

end

function DepartureDotItemView:OnShow()
	self.ToggleBtn:SetChecked(false, false)
	UIUtil.SetIsVisible(self.ToggleBtn, true, false)
end

function DepartureDotItemView:OnHide()

end

function DepartureDotItemView:OnRegisterUIEvent()

end

function DepartureDotItemView:OnRegisterGameEvent()

end

function DepartureDotItemView:OnRegisterBinder()

end

function DepartureDotItemView:OnSelectChanged(IsSelected)
	self.ToggleBtn:SetChecked(IsSelected, false)
end

return DepartureDotItemView