---
--- Author: anypkvcai
--- DateTime: 2021-02-07 17:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")

---@class CommonMaskPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ButtonMask UButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonMaskPanelView = LuaClass(UIView, true)

function CommonMaskPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonMask = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonMaskPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonMaskPanelView:OnInit()

end

function CommonMaskPanelView:OnDestroy()

end

function CommonMaskPanelView:OnShow()
end

function CommonMaskPanelView:OnHide()
end

function CommonMaskPanelView:OnRegisterUIEvent()

end

function CommonMaskPanelView:OnRegisterGameEvent()

end

function CommonMaskPanelView:OnRegisterTimer()

end

function CommonMaskPanelView:OnRegisterBinder()

end

function CommonMaskPanelView:SetOnClickedCallback(View, Callback)
	UIUtil.AddOnClickedEvent(View, self.ButtonMask, Callback)
end

function CommonMaskPanelView:SetOnPressedCallback(View, Callback)
	UIUtil.AddOnPressedEvent(View, self.ButtonMask, Callback)
end

return CommonMaskPanelView