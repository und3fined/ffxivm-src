---
--- Author: v_hggzhang
--- DateTime: 2023-11-28 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")


---@class NewWeatherAreaDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextRegion UFTextBlock
---@field WeatherArrow1 NewWeatherArrowItemView
---@field WeatherArrow2 NewWeatherArrowItemView
---@field WeatherBallI1 NewWeatherBallISlotItemView
---@field WeatherBallI2 NewWeatherBallISlotItemView
---@field WeatherBallI3 NewWeatherBallISlotItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherAreaDetailsItemView = LuaClass(UIView, true)

function NewWeatherAreaDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextRegion = nil
	--self.WeatherArrow1 = nil
	--self.WeatherArrow2 = nil
	--self.WeatherBallI1 = nil
	--self.WeatherBallI2 = nil
	--self.WeatherBallI3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherAreaDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	-- self:AddSubView(self.WeatherArrow1)
	-- self:AddSubView(self.WeatherArrow2)
	self:AddSubView(self.WeatherBallI1)
	self:AddSubView(self.WeatherBallI2)
	self:AddSubView(self.WeatherBallI3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherAreaDetailsItemView:OnInit()
	self.Binder = 
	{
		{ "Name", 					UIBinderSetText.New(self, self.TextRegion) },
	}
end

function NewWeatherAreaDetailsItemView:OnDestroy()

end

function NewWeatherAreaDetailsItemView:OnShow()
	self:RegWeatherBalls()

	local Params = self.Params
    if nil == Params then
        return
    end

    self.VM = self.Params.Data
    if nil == self.VM then
        return
    end

	if self.VM.IsLastOne then
		local AreaID = self.VM.ParentAreaVM.AreaID
		-- _G.FLOG_INFO(string.format('[Weather][NewWeatherAreaDetailsItemView][OnShow]  MapName = %s, AreaName = %s',
		-- 	tostring(self.VM.Name),
		-- 	tostring(self.VM.ParentAreaVM.Name)
		-- ))
		_G.WeatherVM:TryUpdTopItem(AreaID, true, true)
	end
end

function NewWeatherAreaDetailsItemView:OnHide()
	if nil == self.VM then
        return
    end

	if self.VM.IsLastOne then
		local AreaID = self.VM.ParentAreaVM.AreaID
		-- _G.FLOG_INFO(string.format('[Weather][NewWeatherBallIArrowLItemView][OnHide]  MapName = %s, AreaName = %s',
		-- 	tostring(self.VM.Name),
		-- 	tostring(self.VM.ParentAreaVM.Name)
		-- ))
		_G.WeatherVM:TryUpdTopItem(AreaID, false, true)
	end
end

function NewWeatherAreaDetailsItemView:OnRegisterUIEvent()

end

function NewWeatherAreaDetailsItemView:OnRegisterGameEvent()

end

function NewWeatherAreaDetailsItemView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then
        return
    end

    self.VM = self.Params.Data
    if nil == self.VM then
        return
    end

	self:RegisterBinders(self.VM, 				self.Binder)
end

function NewWeatherAreaDetailsItemView:RegWeatherBalls()
	local Params = self.Params
    if nil == Params then
        return
    end

    local VM = self.Params.Data
    if nil == VM then
        return
    end

	for Idx = 1, 3 do
		local BallVM = VM.WeatherBallDict[Idx]
		if BallVM then
			self["WeatherBallI" .. Idx]:UpdWeather(BallVM)
		end
	end
end

return NewWeatherAreaDetailsItemView