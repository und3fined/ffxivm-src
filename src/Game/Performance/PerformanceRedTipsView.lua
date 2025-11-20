---
--- Author: rock
--- DateTime: 2025-06-23 15:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PerformanceRedTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SpacerL USpacer
---@field SpacerR USpacer
---@field TextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceRedTipsView = LuaClass(UIView, true)

function PerformanceRedTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SpacerL = nil
	--self.SpacerR = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceRedTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceRedTipsView:OnInit()
	self.TextContent:SetText(_G.LSTR(830133))
end

function PerformanceRedTipsView:OnDestroy()

end

function PerformanceRedTipsView:OnShow()

end

function PerformanceRedTipsView:OnHide()

end

function PerformanceRedTipsView:OnRegisterUIEvent()

end

function PerformanceRedTipsView:OnRegisterGameEvent()

end

function PerformanceRedTipsView:OnRegisterBinder()

end

return PerformanceRedTipsView