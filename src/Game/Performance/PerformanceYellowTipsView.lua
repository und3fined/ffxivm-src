---
--- Author: rock
--- DateTime: 2025-06-23 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PerformanceYellowTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SpacerL USpacer
---@field SpacerR USpacer
---@field TextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceYellowTipsView = LuaClass(UIView, true)

function PerformanceYellowTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SpacerL = nil
	--self.SpacerR = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceYellowTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceYellowTipsView:OnInit()
	self.TextContent:SetText(_G.LSTR(830134))
end

function PerformanceYellowTipsView:OnDestroy()

end

function PerformanceYellowTipsView:OnShow()

end

function PerformanceYellowTipsView:OnHide()

end

function PerformanceYellowTipsView:OnRegisterUIEvent()

end

function PerformanceYellowTipsView:OnRegisterGameEvent()

end

function PerformanceYellowTipsView:OnRegisterBinder()

end

return PerformanceYellowTipsView