---
--- Author: Administrator
--- DateTime: 2024-11-18 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class OpsNewbieStrategyListTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Text UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyListTitleItemView = LuaClass(UIView, true)

function OpsNewbieStrategyListTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Text = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyListTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyListTitleItemView:OnInit()
	self.Binders = 
	{
		{ "TitleText", UIBinderSetText.New(self, self.Text)},
	}
end

function OpsNewbieStrategyListTitleItemView:OnDestroy()

end

function OpsNewbieStrategyListTitleItemView:OnShow()

end

function OpsNewbieStrategyListTitleItemView:OnHide()

end

function OpsNewbieStrategyListTitleItemView:OnRegisterUIEvent()

end

function OpsNewbieStrategyListTitleItemView:OnRegisterGameEvent()

end

function OpsNewbieStrategyListTitleItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	self:RegisterBinders(VM, self.Binders)
end

return OpsNewbieStrategyListTitleItemView