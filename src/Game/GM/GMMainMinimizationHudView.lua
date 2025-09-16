---
--- Author: v_zanchang
--- DateTime: 2022-05-05 16:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GMMainMinimizationHudView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GMMainMinimization_UIBP GMMainMinimizationView
---@field DragOffset Vector2D
---@field DragedWidget UserWidget
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMMainMinimizationHudView = LuaClass(UIView, true)
local GMMainMinimization_UIBP = nil
function GMMainMinimizationHudView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GMMainMinimization_UIBP = nil
	--self.DragOffset = nil
	--self.DragedWidget = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMMainMinimizationHudView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GMMainMinimization_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMMainMinimizationHudView:OnInit()
	GMMainMinimization_UIBP = self.GMMainMinimization_UIBP
end

function GMMainMinimizationHudView:OnDestroy()

end

function GMMainMinimizationHudView:OnShow()
	if not self.AttachOverlay:HasChild(GMMainMinimization_UIBP) then
		self.AttachOverlay:AddChild(GMMainMinimization_UIBP)
	end
	UIUtil.SetIsVisible(GMMainMinimization_UIBP, true, true)
end

function GMMainMinimizationHudView:OnHide()
	if not self.AttachOverlay:HasChild(GMMainMinimization_UIBP) then
		self.AttachOverlay:AddChild(GMMainMinimization_UIBP)
	end
	UIUtil.SetIsVisible(GMMainMinimization_UIBP, false, false)
end

function GMMainMinimizationHudView:OnRegisterUIEvent()

end

function GMMainMinimizationHudView:OnRegisterGameEvent()

end

function GMMainMinimizationHudView:OnRegisterBinder()

end

return GMMainMinimizationHudView