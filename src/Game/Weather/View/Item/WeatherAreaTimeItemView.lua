---
--- Author: v_hggzhang
--- DateTime: 2023-11-28 16:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

---@class NewWeatherAreaTimeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextRegionCurrent UFTextBlock
---@field TextTime00 UFTextBlock
---@field TextTime08 UFTextBlock
---@field TextTime16 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherAreaTimeItemView = LuaClass(UIView, true)

function NewWeatherAreaTimeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextRegionCurrent = nil
	--self.TextTime00 = nil
	--self.TextTime08 = nil
	--self.TextTime16 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherAreaTimeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherAreaTimeItemView:OnInit()
	self.Binder = 
	{
		{ "Name", 					UIBinderSetText.New(self, self.TextRegionCurrent) },
		{ "TimeShow1", 				UIBinderSetText.New(self, self.TextTime00) },
		{ "TimeShow2", 				UIBinderSetText.New(self, self.TextTime08) },
		{ "TimeShow3", 				UIBinderSetText.New(self, self.TextTime16) },
		{ "IsShowTime", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChgShowTime) },
	}

	self.WeatherBinder = 
	{
		{ "ShowAreaVM", 			UIBinderValueChangedCallback.New(self, nil, self.OnBindShowAreaVM) },
	}
end

function NewWeatherAreaTimeItemView:OnValueChgShowTime(Value)
	if self.IsBanner then
		return
	end

	local Alpha = Value and 1 or 0
	self.ContentPanel:SetRenderOpacity(Alpha)
end

function NewWeatherAreaTimeItemView:OnDestroy()

end

function NewWeatherAreaTimeItemView:OnShow()
	if self.IsBanner then
		return
	end

	local Params = self.Params
    if nil == Params then
        return
    end

    self.VM = self.Params.Data
    if nil == self.VM then
        return
    end

	-- _G.FLOG_INFO(string.format('[Weather][NewWeatherAreaTimeItemView][OnShow] AreaName = %s',tostring(self.VM.Name)))

	_G.WeatherVM:TryUpdTopItem(self.VM.AreaID, true, false)


	local Alpha = self.VM.IsShowTime and 1 or 0
	self.ContentPanel:SetRenderOpacity(Alpha)
end

function NewWeatherAreaTimeItemView:OnHide()
	if self.IsBanner then
		return
	end

    if nil == self.VM then
        return
    end

	-- _G.FLOG_INFO(string.format('[Weather][NewWeatherAreaTimeItemView][OnHide] AreaName = %s',tostring(self.VM.Name)))


	_G.WeatherVM:TryUpdTopItem(self.VM.AreaID, false, false)
end

function NewWeatherAreaTimeItemView:OnRegisterUIEvent()

end

function NewWeatherAreaTimeItemView:OnRegisterGameEvent()

end

function NewWeatherAreaTimeItemView:OnRegisterBinder()
	if not self.IsBanner then
		local Params = self.Params
		if nil == Params then
			return
		end

		self.VM = self.Params.Data
		if nil == self.VM then
			return
		end

		self.ItemVMBindID = self:RegisterBinders(self.VM, 				self.Binder)
	else
		self:RegisterBinders(_G.WeatherVM, 				self.WeatherBinder)
	end

end

function NewWeatherAreaTimeItemView:OnBindShowAreaVM(New, Old)
	if New then
		self:SetVM(New)
	end
end

function NewWeatherAreaTimeItemView:SetVM(VM)
	if not VM then 
		return
	end

	if self.VM then
		self:UnRegisterBinders(self.VM, self.Binder)
	end

	self.VM = VM

	self:RegisterBinders(self.VM, 				self.Binder)
end

function NewWeatherAreaTimeItemView:SetIsBanner(V)
	self.IsBanner = V
end

return NewWeatherAreaTimeItemView