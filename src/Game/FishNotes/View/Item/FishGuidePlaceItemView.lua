---
--- Author: Administrator
--- DateTime: 2023-03-28 15:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

local FishGuideVM = require("Game/FishNotes/FishGuideVM")

---@class FishGuidePlaceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPlace UFButton
---@field TextPlace UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishGuidePlaceItemView = LuaClass(UIView, true)

function FishGuidePlaceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPlace = nil
	--self.TextPlace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishGuidePlaceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishGuidePlaceItemView:OnInit()
	self.Binders = {
		{ "PlaceName", UIBinderSetText.New(self, self.TextPlace) }
	}
end

function FishGuidePlaceItemView:OnDestroy()

end

function FishGuidePlaceItemView:OnShow()

end

function FishGuidePlaceItemView:OnHide()

end

function FishGuidePlaceItemView:OnRegisterUIEvent()

end

function FishGuidePlaceItemView:OnRegisterGameEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPlace, self.OnClickPlaceBtn)
end

function FishGuidePlaceItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function FishGuidePlaceItemView:OnClickPlaceBtn(View)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	FishGuideVM:SkipToLocation(ViewModel.Index)
end

return FishGuidePlaceItemView