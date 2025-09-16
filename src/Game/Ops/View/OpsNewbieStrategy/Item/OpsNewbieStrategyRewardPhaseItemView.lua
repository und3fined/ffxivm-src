---
--- Author: Administrator
--- DateTime: 2024-11-18 14:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsNewbieStrategyRewardPhaseItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FWidgetSwitcher_0 UFWidgetSwitcher
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyRewardPhaseItemView = LuaClass(UIView, true)

local GetState = 
{
	NoGet = 0,
	Get = 1
}

function OpsNewbieStrategyRewardPhaseItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FWidgetSwitcher_0 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyRewardPhaseItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyRewardPhaseItemView:OnInit()

end

function OpsNewbieStrategyRewardPhaseItemView:OnDestroy()

end

function OpsNewbieStrategyRewardPhaseItemView:OnShow()

end

function OpsNewbieStrategyRewardPhaseItemView:OnHide()

end

function OpsNewbieStrategyRewardPhaseItemView:OnRegisterUIEvent()

end

function OpsNewbieStrategyRewardPhaseItemView:OnRegisterGameEvent()

end

function OpsNewbieStrategyRewardPhaseItemView:OnRegisterBinder()

end

function OpsNewbieStrategyRewardPhaseItemView:SetIsGet(IsGet)
	if IsGet then
		self.FWidgetSwitcher_0:SetActiveWidgetIndex(GetState.Get)
	else
		self.FWidgetSwitcher_0:SetActiveWidgetIndex(GetState.NoGet)
	end
end

return OpsNewbieStrategyRewardPhaseItemView