---
--- Author: qibaoyiyi
--- DateTime: 2023-03-17 11:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class ArmyRuleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RichTextTitle URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyRuleItemView = LuaClass(UIView, true)

function ArmyRuleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RichTextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyRuleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyRuleItemView:OnInit()

end

function ArmyRuleItemView:OnDestroy()

end

function ArmyRuleItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	self.RichTextTitle:SetText(Params.Data.Tips)
end

function ArmyRuleItemView:OnHide()

end

function ArmyRuleItemView:OnRegisterUIEvent()

end

function ArmyRuleItemView:OnRegisterGameEvent()

end

function ArmyRuleItemView:OnRegisterBinder()

end

return ArmyRuleItemView