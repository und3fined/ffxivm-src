---
--- Author: v_hggzhang
--- DateTime: 2023-11-28 16:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")

local WeatherBallVM = require("Game/Weather/VM/WeatherBallVM")

---@class NewWeatherDetailsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field GameEndTime NewWeatherDetailsTimeItemView
---@field GameStartTime NewWeatherDetailsTimeItemView
---@field LocalEndTime NewWeatherDetailsTimeItemView
---@field LocalStartTime NewWeatherDetailsTimeItemView
---@field WeatherArrow1 NewWeatherArrowItemView
---@field WeatherArrow2 NewWeatherArrowItemView
---@field WeatherBallI1 NewWeatherBallISlotItemView
---@field WeatherBallI2 NewWeatherBallISlotItemView
---@field WeatherBallI3 NewWeatherBallISlotItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherDetailsItemView = LuaClass(UIView, true)

function NewWeatherDetailsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.GameEndTime = nil
	--self.GameStartTime = nil
	--self.LocalEndTime = nil
	--self.LocalStartTime = nil
	--self.WeatherArrow1 = nil
	--self.WeatherArrow2 = nil
	--self.WeatherBallI1 = nil
	--self.WeatherBallI2 = nil
	--self.WeatherBallI3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherDetailsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.GameEndTime)
	self:AddSubView(self.GameStartTime)
	self:AddSubView(self.LocalEndTime)
	self:AddSubView(self.LocalStartTime)
	self:AddSubView(self.WeatherArrow1)
	self:AddSubView(self.WeatherArrow2)
	self:AddSubView(self.WeatherBallI1)
	self:AddSubView(self.WeatherBallI2)
	self:AddSubView(self.WeatherBallI3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherDetailsItemView:OnInit()
	self.WeatherBalls = {}
	self.WeatherData = {}


	for Idx = 1, 3 do
		self.WeatherBalls[Idx] = WeatherBallVM.New()
		self.WeatherData[Idx] = {TimeOff = Idx - 2}
	end

	self.TextStartTime:SetText(LSTR(610002))
	self.TextEndTime:SetText(LSTR(610003))
end

function NewWeatherDetailsItemView:OnDestroy()

end

function NewWeatherDetailsItemView:OnShow()
	local WeatherVM = _G.WeatherVM
	self.MapID = WeatherVM.DetailMapID
	self.TimeOff = WeatherVM.DetailTimeOff or 0
	self.SeltBallView = WeatherVM.DetailSeltBall
	self.BasePanel = WeatherVM.DetailBasePanel
	self.IsUnExpType = WeatherVM.IsUnExpBall
	self:UpdView()

	self:PlayAnimation(self.AnimShow)
end

function NewWeatherDetailsItemView:OnHide()
	
end

function NewWeatherDetailsItemView:OnRegisterUIEvent()
end

function NewWeatherDetailsItemView:OnRegisterGameEvent()

end

function NewWeatherDetailsItemView:OnRegisterBinder()

end

function NewWeatherDetailsItemView:UpdView()
	self:UpdWeatherBall()
	self:UpdTime()
	self:UpdPos()
end

function NewWeatherDetailsItemView:UpdWeatherBall()
	for Idx = 1, 3 do
		local BallVM = self.WeatherBalls[Idx]
		if BallVM then
			local Data = self.WeatherData[Idx]
			Data.MapID = self.MapID

			local TimeOff = self.TimeOff - 2 + Idx
			Data.TimeOff = TimeOff

			BallVM:UpdateVM(Data)

			local Alpha = 1
			local ShowBorder = false
			local NameColor = "D5D5D5"
			local ShowName = true
			local ShowGlow = false

			if Idx == 2 then
				ShowBorder = true
				NameColor = "FFF4D0"
				ShowGlow = true
			end

			BallVM:SetAlpha(Alpha)
			BallVM:SetShowBorder(ShowBorder)
			BallVM:SetShowName(ShowName)
			BallVM:SetIsGlow(ShowGlow)
			BallVM:SetNameColor(NameColor)

			self["WeatherBallI" .. Idx]:UpdWeather(BallVM)
		end
	end
end

function NewWeatherDetailsItemView:UpdTime()
	self.LocalStartTime:SetTime(self.TimeOff, false)
	self.GameStartTime:SetTime(self.TimeOff, true)
	self.LocalEndTime:SetTime(self.TimeOff + 1, false)
	self.GameEndTime:SetTime(self.TimeOff + 1, true)
end

function NewWeatherDetailsItemView:UpdPos()
	local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(self.SeltBallView)
	local ViewportSize = UIUtil.GetViewportSize()

	_G.FLOG_INFO(string.format('[Weather][NewWeatherDetailsItemView][UpdPos] TragetAbsoluteY = %s, ViewportSizeY = %s',
		tostring(TragetAbsolute.Y),
		tostring(ViewportSize.Y)
	))

	if self.IsUnExpType then
		local ScreenSize = UIUtil.GetScreenSize()
		local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute( _G.UE.FVector2D(0, 0), false)
		local OffY = (TragetAbsolute.Y - WindowAbsolute.Y) * ScreenSize.Y / ViewportSize.Y

		UIUtil.CanvasSlotSetPosition(self.DetailPanel, _G.UE.FVector2D(0, 0))
		UIUtil.CanvasSlotSetAlignment(self.DetailPanel, _G.UE.FVector2D(0, 0))
		TipsUtil.AdjustTipsPosition(self.DetailPanel, self.BasePanel,  _G.UE.FVector2D(0, OffY), _G.UE.FVector2D(0, 0), false)
	else
		if (TragetAbsolute.Y - 100) < (ViewportSize.Y)/2 then
			TipsUtil.AdjustTipsPosition(self.DetailPanel, self.SeltBallView,  _G.UE.FVector2D(-52, 80), _G.UE.FVector2D(0.5, 0), false)
		else
			TipsUtil.AdjustTipsPosition(self.DetailPanel, self.SeltBallView,  _G.UE.FVector2D(-52, -(20 + 460)), _G.UE.FVector2D(0.5, 0), false)
		end
	end
end

return NewWeatherDetailsItemView