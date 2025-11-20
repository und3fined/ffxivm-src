---
--- Author: Administrator
--- DateTime: 2025-08-13 15:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class StarlightCelebrationTaskItemTabView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLock UFImage
---@field TextNumber UFTextBlock
---@field TextTask UFTextBlock
---@field ToggleButton_29 UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StarlightCelebrationTaskItemTabView = LuaClass(UIView, true)

function StarlightCelebrationTaskItemTabView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLock = nil
	--self.TextNumber = nil
	--self.TextTask = nil
	--self.ToggleButton_29 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StarlightCelebrationTaskItemTabView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StarlightCelebrationTaskItemTabView:OnInit()
	self.Binders = {
		{"TaskNumber", UIBinderSetTextFormat.New(self, self.TextNumber, "%d")},
		{"LockVisible", UIBinderSetIsVisible.New(self, self.ImgLock)},
		{"TaskColor", UIBinderSetColorAndOpacityHex.New(self, self.TextTask)},
		{"bIsSelect", UIBinderValueChangedCallback.New(self, nil, self.OnIsSelectChanged)},
	}
end

function StarlightCelebrationTaskItemTabView:OnDestroy()

end

function StarlightCelebrationTaskItemTabView:OnShow()

end

function StarlightCelebrationTaskItemTabView:OnHide()

end

function StarlightCelebrationTaskItemTabView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleButton_29, self.OnToggleBtnClicked)
end

function StarlightCelebrationTaskItemTabView:OnRegisterGameEvent()

end

function StarlightCelebrationTaskItemTabView:OnToggleBtnClicked()
	local Params = self.Params
	if(Params and Params.Adapter) then
		Params.Adapter:OnItemClicked(self, Params.Index)
	end
end

function StarlightCelebrationTaskItemTabView:OnIsSelectChanged(NewValue, OldValue)
	self.ToggleButton_29:SetCheckedState(NewValue)
end

function StarlightCelebrationTaskItemTabView:OnRegisterBinder()
	local Params = self.Params
	if not Params then return end
		
	local ViewModel = Params.Data

	self:RegisterBinders(ViewModel, self.Binders)
	self.TextTask:SetText(_G.LSTR(1700055))
end

return StarlightCelebrationTaskItemTabView