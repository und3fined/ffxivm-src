---
--- Author: Administrator
--- DateTime: 2024-10-15 18:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmySpecialEffectsEmptyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextNone UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySpecialEffectsEmptyItemView = LuaClass(UIView, true)

function ArmySpecialEffectsEmptyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextNone = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsEmptyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySpecialEffectsEmptyItemView:OnInit()

end

function ArmySpecialEffectsEmptyItemView:OnDestroy()

end

function ArmySpecialEffectsEmptyItemView:OnShow()
	-- LSTR string:未启用部队特效
	local Str = string.format("-%s-",LSTR(910278))
	self.TextNone:SetText(Str)
end

function ArmySpecialEffectsEmptyItemView:OnHide()

end

function ArmySpecialEffectsEmptyItemView:OnRegisterUIEvent()

end

function ArmySpecialEffectsEmptyItemView:OnRegisterGameEvent()

end

function ArmySpecialEffectsEmptyItemView:OnRegisterBinder()

end

return ArmySpecialEffectsEmptyItemView