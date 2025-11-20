---
--- Author: jususchen
--- DateTime: 2025-07-29 17:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsMoggleCollectTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonRedDot CommonRedDotView
---@field TextNormal UFTextBlock
---@field TextSelect UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMoggleCollectTabItemView = LuaClass(UIView, true)

function OpsMoggleCollectTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonRedDot = nil
	--self.TextNormal = nil
	--self.TextSelect = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectTabItemView:OnInit()

end

function OpsMoggleCollectTabItemView:OnDestroy()

end

function OpsMoggleCollectTabItemView:OnShow()

end

function OpsMoggleCollectTabItemView:OnHide()

end

function OpsMoggleCollectTabItemView:OnRegisterUIEvent()

end

function OpsMoggleCollectTabItemView:OnRegisterGameEvent()

end

function OpsMoggleCollectTabItemView:OnRegisterBinder()

end

return OpsMoggleCollectTabItemView