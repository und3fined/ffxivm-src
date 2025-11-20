---
--- Author: rock
--- DateTime: 2025-06-23 15:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PerformanceBlueTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SpacerL USpacer
---@field SpacerR USpacer
---@field TextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceBlueTipsView = LuaClass(UIView, true)

function PerformanceBlueTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SpacerL = nil
	--self.SpacerR = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceBlueTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceBlueTipsView:OnInit()
	self.TextContent:SetText(_G.LSTR(830132))
end

function PerformanceBlueTipsView:OnDestroy()

end

function PerformanceBlueTipsView:OnShow()

end

function PerformanceBlueTipsView:OnHide()

end

function PerformanceBlueTipsView:OnRegisterUIEvent()

end

function PerformanceBlueTipsView:OnRegisterGameEvent()

end

function PerformanceBlueTipsView:OnRegisterBinder()

end

return PerformanceBlueTipsView