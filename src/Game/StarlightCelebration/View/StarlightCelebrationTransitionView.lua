---
--- Author: Administrator
--- DateTime: 2025-10-31 11:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class StarlightCelebrationTransitionView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field AnimShow UWidgetAnimation
---@field bakAnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StarlightCelebrationTransitionView = LuaClass(UIView, true)

function StarlightCelebrationTransitionView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonBkgMask_UIBP = nil
	--self.AnimShow = nil
	--self.bakAnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StarlightCelebrationTransitionView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonBkgMask_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StarlightCelebrationTransitionView:OnInit()

end

function StarlightCelebrationTransitionView:OnDestroy()

end

function StarlightCelebrationTransitionView:OnShow()

end

function StarlightCelebrationTransitionView:OnHide()

end

function StarlightCelebrationTransitionView:OnRegisterUIEvent()

end

function StarlightCelebrationTransitionView:OnRegisterGameEvent()

end

function StarlightCelebrationTransitionView:OnRegisterBinder()

end

return StarlightCelebrationTransitionView