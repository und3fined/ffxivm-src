--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-08-23 15:37:45
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-09-02 11:08:02
FilePath: \Client\Source\Script\Game\FishNotes\View\Item\FishNotesWeatherBallIItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: Administrator
--- DateTime: 2023-03-29 12:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")

---@class FishNotesWeatherBallIItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtn_Slot UFButton
---@field FImg_WeatherBar2 UFImage
---@field FImg_WeatherBar3 UFImage
---@field Icon_Weather UFImage
---@field PanelArrow UFCanvasPanel
---@field WeatherBallSlot UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNotesWeatherBallIItemView = LuaClass(UIView, true)

function FishNotesWeatherBallIItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FBtn_Slot = nil
	--self.FImg_WeatherBar2 = nil
	--self.FImg_WeatherBar3 = nil
	--self.Icon_Weather = nil
	--self.PanelArrow = nil
	--self.WeatherBallSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNotesWeatherBallIItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNotesWeatherBallIItemView:OnInit()
	self.Binders = {
		{ "FishWeatherIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Weather) },
		{ "bArrowVisible", UIBinderSetIsVisible.New(self, self.PanelArrow) },
		{ "bIconVisible", UIBinderSetIsVisible.New(self, self.Icon_Weather) },
	}
end

function FishNotesWeatherBallIItemView:OnDestroy()

end

function FishNotesWeatherBallIItemView:OnShow()

end

function FishNotesWeatherBallIItemView:OnHide()

end

function FishNotesWeatherBallIItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_Slot, self.OnNoticeBtnClicked)
end

function FishNotesWeatherBallIItemView:OnRegisterGameEvent()

end

function FishNotesWeatherBallIItemView:OnRegisterBinder()
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

function FishNotesWeatherBallIItemView:OnNoticeBtnClicked()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.bIconVisible then
		TipsUtil.ShowInfoTips(ViewModel.Name, self.FBtn_Slot, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), false)
	end
end

return FishNotesWeatherBallIItemView