---
--- Author: Administrator
--- DateTime: 2024-10-16 15:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyEmptyPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextEmptyTip UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyEmptyPageView = LuaClass(UIView, true)

function ArmyEmptyPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextEmptyTip = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyEmptyPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyEmptyPageView:OnInit()

end

function ArmyEmptyPageView:SetTextEmptyTip(Text)
	self.TextEmptyTip:SetText(Text)
end

function ArmyEmptyPageView:OnDestroy()

end

function ArmyEmptyPageView:OnShow()

end

function ArmyEmptyPageView:OnHide()

end

function ArmyEmptyPageView:OnRegisterUIEvent()

end

function ArmyEmptyPageView:OnRegisterGameEvent()

end

function ArmyEmptyPageView:OnRegisterBinder()

end

return ArmyEmptyPageView