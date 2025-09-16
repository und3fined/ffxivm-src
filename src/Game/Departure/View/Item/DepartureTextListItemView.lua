---
--- Author: Administrator
--- DateTime: 2025-03-13 14:22
--- Description:启程玩法回收界面高光ItemView
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class DepartureTextListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FTextBlock_19 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local DepartureTextListItemView = LuaClass(UIView, true)

function DepartureTextListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FTextBlock_19 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function DepartureTextListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function DepartureTextListItemView:OnInit()
	self.Binders = {
		{"HightLightContent", UIBinderSetText.New(self, self.FTextBlock_19)},
	}
end

function DepartureTextListItemView:OnDestroy()

end

function DepartureTextListItemView:OnShow()

end

function DepartureTextListItemView:OnHide()

end

function DepartureTextListItemView:OnRegisterUIEvent()

end

function DepartureTextListItemView:OnRegisterGameEvent()

end

function DepartureTextListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return DepartureTextListItemView