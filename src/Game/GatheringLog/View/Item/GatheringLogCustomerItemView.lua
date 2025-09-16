---
--- Author: Leo
--- DateTime: 2023-03-29 10:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class GatheringLogCustomerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field TextNPC UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogCustomerItemView = LuaClass(UIView, true)

function GatheringLogCustomerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.TextNPC = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogCustomerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogCustomerItemView:OnInit()
	self.Binders = {
		{ "TypeTabName", UIBinderSetText.New(self, self.TextNPC) },
	}
end

function GatheringLogCustomerItemView:OnDestroy()

end

function GatheringLogCustomerItemView:OnShow()

end

function GatheringLogCustomerItemView:OnHide()

end

function GatheringLogCustomerItemView:OnRegisterUIEvent()

end

function GatheringLogCustomerItemView:OnRegisterGameEvent()

end

function GatheringLogCustomerItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)

end

return GatheringLogCustomerItemView