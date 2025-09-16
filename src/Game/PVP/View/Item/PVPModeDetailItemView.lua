---
--- Author: Administrator
--- DateTime: 2024-11-29 15:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")

---@class PVPModeDetailItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextDesc UFTextBlock
---@field TextValue UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPModeDetailItemView = LuaClass(UIView, true)

function PVPModeDetailItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextDesc = nil
	--self.TextValue = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPModeDetailItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPModeDetailItemView:OnInit()
	self.Binders = {
		{ "Desc", UIBinderSetText.New(self, self.TextDesc) },
		{ "Value", UIBinderSetText.New(self, self.TextValue) },
	}
end

function PVPModeDetailItemView:OnDestroy()

end

function PVPModeDetailItemView:OnShow()

end

function PVPModeDetailItemView:OnHide()

end

function PVPModeDetailItemView:OnRegisterUIEvent()

end

function PVPModeDetailItemView:OnRegisterGameEvent()

end

function PVPModeDetailItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local VM = Params.Data
	if VM == nil then return end

	self:RegisterBinders(VM, self.Binders)
end

return PVPModeDetailItemView