---
--- Author: Administrator
--- DateTime: 2024-11-18 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")

---@class OpsNewbieStrategyAetherLightListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon UFImage
---@field TextAetherLight UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyAetherLightListItemView = LuaClass(UIView, true)

function OpsNewbieStrategyAetherLightListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon = nil
	--self.TextAetherLight = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyAetherLightListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyAetherLightListItemView:OnInit()
	self.Binders = {
		{ "CrystalName", UIBinderSetText.New(self, self.TextAetherLight)},
		{ "CrystalIcon", UIBinderSetImageBrush.New(self, self.Icon)},
	}
end

function OpsNewbieStrategyAetherLightListItemView:OnDestroy()

end

function OpsNewbieStrategyAetherLightListItemView:OnShow()

end

function OpsNewbieStrategyAetherLightListItemView:OnHide()

end

function OpsNewbieStrategyAetherLightListItemView:OnRegisterUIEvent()

end

function OpsNewbieStrategyAetherLightListItemView:OnRegisterGameEvent()

end

function OpsNewbieStrategyAetherLightListItemView:OnRegisterBinder()
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

return OpsNewbieStrategyAetherLightListItemView