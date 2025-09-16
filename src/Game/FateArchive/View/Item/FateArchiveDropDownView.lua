---
--- Author: Administrator
--- DateTime: 2024-12-12 17:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FateArchiveDropDownView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RedDot CommonRedDotView
---@field RedDot2 CommonRedDot2View
---@field TableViewList UTableView
---@field TextContent UFTextBlock
---@field ToggleButtonArrow UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveDropDownView = LuaClass(UIView, true)

function FateArchiveDropDownView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RedDot = nil
	--self.RedDot2 = nil
	--self.TableViewList = nil
	--self.TextContent = nil
	--self.ToggleButtonArrow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveDropDownView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveDropDownView:OnInit()

end

function FateArchiveDropDownView:OnDestroy()

end

function FateArchiveDropDownView:OnShow()

end

function FateArchiveDropDownView:OnHide()

end

function FateArchiveDropDownView:OnRegisterUIEvent()

end

function FateArchiveDropDownView:OnRegisterGameEvent()

end

function FateArchiveDropDownView:OnRegisterBinder()

end

return FateArchiveDropDownView