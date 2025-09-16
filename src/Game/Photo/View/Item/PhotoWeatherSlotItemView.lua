---
--- Author: Administrator
--- DateTime: 2024-01-30 10:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class PhotoWeatherSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot UFButton
---@field IconWeather UFImage
---@field ImgWeatherBar2 UFImage
---@field WeatherBallSlot UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoWeatherSlotItemView = LuaClass(UIView, true)

function PhotoWeatherSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.IconWeather = nil
	--self.ImgWeatherBar2 = nil
	--self.WeatherBallSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoWeatherSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoWeatherSlotItemView:OnInit()
	self.Binders = 
	{
		{ "IsSelt", 			UIBinderSetIsVisible.New(self, self.ImgWeatherBar2) },
		{ "Icon", 				UIBinderSetBrushFromAssetPath.New(self, self.IconWeather) },
	}
end

function PhotoWeatherSlotItemView:OnDestroy()

end

function PhotoWeatherSlotItemView:OnShow()

end

function PhotoWeatherSlotItemView:OnHide()

end

function PhotoWeatherSlotItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,              self.BtnSlot,    self.OnBtn)
end

function PhotoWeatherSlotItemView:OnRegisterGameEvent()

end

function PhotoWeatherSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local VM = Params.Data
	if nil == VM then
		return
	end

	self:RegisterBinders(VM, self.Binders)
end

function PhotoWeatherSlotItemView:OnBtn()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Adapter = Params.Adapter
    if nil == Adapter then
        return
    end

   Adapter:OnItemClicked(self, Params.Index)
end

function PhotoWeatherSlotItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if nil == Params then
		return
	end

	local VM = Params.Data
	if nil == VM then
		return
	end

	VM.IsSelt = IsSelected

	if IsSelected then
		_G.PhotoSceneVM.WeatherName = VM.Name
	end
end

return PhotoWeatherSlotItemView