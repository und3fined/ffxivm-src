--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-17 17:15:07
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-17 18:51:24
FilePath: \Client\Source\Script\Game\FishNotesNew\View\Item\FishTime2ItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local TipsUtil = require("Utils/TipsUtil")

---@class FishTime2ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgArrow UFImage
---@field TextTime UFTextBlock
---@field TextTime2 UFTextBlock
---@field TextWeather UFTextBlock
---@field WeatherBallISlot1 WeatherBallISlotItemView
---@field WeatherBallISlot2 WeatherBallISlotItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishTime2ItemView = LuaClass(UIView, true)

function FishTime2ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgArrow = nil
	--self.TextTime = nil
	--self.TextTime2 = nil
	--self.TextWeather = nil
	--self.WeatherBallISlot1 = nil
	--self.WeatherBallISlot2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishTime2ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.WeatherBallISlot1)
	self:AddSubView(self.WeatherBallISlot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishTime2ItemView:OnInit()
	self.Binders = {
		{ "StartTime", UIBinderSetText.New(self, self.TextTime) },
		{ "TextWeather", UIBinderSetText.New(self, self.TextWeather) },
		{ "Duration", UIBinderSetText.New(self, self.TextTime2) },
		{ "bPreWeatherVisible", UIBinderSetIsVisible.New(self, self.WeatherBallISlot1) },
		{ "bPreWeatherVisible", UIBinderSetIsVisible.New(self, self.ImgArrow) },
		{ "bWeatherVisible", UIBinderSetIsVisible.New(self, self.WeatherBallISlot2) },

		--{ "WeatherIcon", UIBinderSetBrushFromAssetPath.New(self, self.WeatherBallISlot1.IconWeather) },
		--{ "PreWeatherIcon", UIBinderSetBrushFromAssetPath.New(self, self.WeatherBallISlot2.IconWeather) },
	}
end

function FishTime2ItemView:OnDestroy()

end

function FishTime2ItemView:OnShow()
	--UIUtil.SetIsVisible(self.WeatherBallISlot1.TextWeather, false)
	--UIUtil.SetIsVisible(self.WeatherBallISlot2.TextWeather, false)
end

function FishTime2ItemView:OnHide()

end

function FishTime2ItemView:OnRegisterUIEvent()
	self.WeatherBallISlot1:SetBtnSeltCallBack(self.OnClickWeatherBall)
	self.WeatherBallISlot2:SetBtnSeltCallBack(self.OnClickWeatherBall)
	--UIUtil.AddOnClickedEvent(self, self.WeatherBallISlot1.BtnSlot, self.OnClickPreWeatherBall)
	--UIUtil.AddOnClickedEvent(self, self.WeatherBallISlot2.BtnSlot, self.OnClickWeatherBall)
end

function FishTime2ItemView:OnRegisterGameEvent()
end

function FishTime2ItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.WeatherBallISlot1:UpdWeather(ViewModel.PreWeatherVM)
	self.WeatherBallISlot2:UpdWeather(ViewModel.WeatherVM)
	self.ViewModel = ViewModel
end

function FishTime2ItemView.OnClickWeatherBall(VM, View)
	TipsUtil.ShowInfoTips(VM.Name, View, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), false)
end

return FishTime2ItemView