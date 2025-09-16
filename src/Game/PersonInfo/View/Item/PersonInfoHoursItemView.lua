---
--- Author: xingcaicao
--- DateTime: 2023-04-13 16:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CommonUtil = require("Utils/CommonUtil")

---@class PersonInfoHoursItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FButtonClick UFButton
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoHoursItemView = LuaClass(UIView, true)

function PersonInfoHoursItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FButtonClick = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoHoursItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoHoursItemView:OnInit()

end

function PersonInfoHoursItemView:OnDestroy()

end

function PersonInfoHoursItemView:OnShow()

end

function PersonInfoHoursItemView:OnHide()
	self.IsPressed = false 
end

function PersonInfoHoursItemView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.FButtonClick, self.OnClickButtonPressed)
	UIUtil.AddOnReleasedEvent(self, self.FButtonClick, self.OnClickButtonReleased)
	UIUtil.AddOnHoveredEvent(self, self.FButtonClick, self.OnClickButtonHover)
end

function PersonInfoHoursItemView:OnRegisterGameEvent()

end

function PersonInfoHoursItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.Data = Params.Data

	if self.Data.IsSet then
		local Binders = {
			{ "ActiveHourTempSet", UIBinderValueChangedCallback.New(self, nil, self.OnActiveHourChanged) },
		}

		self:RegisterBinders(PersonInfoVM, Binders)

	else
		local Binders = {
			{ "ActiveHoursSet", UIBinderValueChangedCallback.New(self, nil, self.OnActiveHourChanged) },
		}

		self:RegisterBinders(PersonInfoVM, Binders)
	end
end

function PersonInfoHoursItemView:OnActiveHourChanged()
	if nil == self.Data or nil == self.Data.ID then
		UIUtil.SetIsVisible(self.ImgSelect, false) 
		return
	end

	local HourSet = self.Data.IsSet and PersonInfoVM.ActiveHourTempSet or PersonInfoVM.ActiveHoursSet
	if nil == HourSet then
		UIUtil.SetIsVisible(self.ImgSelect, false) 
		return
	end

	UIUtil.SetIsVisible(self.ImgSelect, (HourSet & (1 << self.Data.ID)) ~= 0) 
end

function PersonInfoHoursItemView:UpdateItemState()
	local IsSel = UIUtil.IsVisible(self.ImgSelect)
	UIUtil.SetIsVisible(self.ImgSelect, not IsSel) 

	PersonInfoVM:UpdateActiveHoursTempSet(self.Data.ID, not IsSel)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function PersonInfoHoursItemView:OnClickButtonPressed()
	if nil == self.Data or not self.Data.IsSet then
		return
	end

	self.IsPressed = true
	PersonInfoVM.HoursItemPressed = true
	self:UpdateItemState()
end

function PersonInfoHoursItemView:OnClickButtonReleased()
	if nil == self.Data or not self.Data.IsSet then
		return
	end

	self.IsPressed = false 
	PersonInfoVM.HoursItemPressed = false 
end

function PersonInfoHoursItemView:OnClickButtonHover()
	if nil == self.Data or not self.Data.IsSet or self.IsPressed then
		return
	end

	if not CommonUtil.IsMobilePlatform() and not PersonInfoVM.HoursItemPressed then
		return
	end

	self:UpdateItemState()
end

return PersonInfoHoursItemView