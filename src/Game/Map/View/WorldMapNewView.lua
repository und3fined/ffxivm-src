---
--- Author: peterxie
--- DateTime: 2024-03-29 19:38
--- Description: 一级地图背景
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local WorldMapCityCfg = require("TableCfg/WorldMapCityCfg")

local FVector2D = _G.UE.FVector2D
local CityNum = 16


---@class WorldMapNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Dragon1 USpineWidget
---@field Dragon2 USpineWidget
---@field FCanvasPanel_247 UFCanvasPanel
---@field FCanvasPanel_335 UFCanvasPanel
---@field HorizontalPanel01 UFHorizontalBox
---@field HorizontalPanel04 UFHorizontalBox
---@field HorizontalPanel05 UFHorizontalBox
---@field HorizontalPanel06 UFHorizontalBox
---@field HorizontalPanel07 UFHorizontalBox
---@field HorizontalPanel08 UFHorizontalBox
---@field HorizontalPanel09 UFHorizontalBox
---@field HorizontalPanel12 UFHorizontalBox
---@field HorizontalPanel13 UFHorizontalBox
---@field ImgCityIcon01 UFImage
---@field ImgCityIcon04 UFImage
---@field ImgCityIcon05 UFImage
---@field ImgCityIcon06 UFImage
---@field ImgCityIcon07 UFImage
---@field ImgCityIcon08 UFImage
---@field ImgCityIcon09 UFImage
---@field ImgCityIcon12 UFImage
---@field ImgCityIcon13 UFImage
---@field ImgPlace01 UFImage
---@field ImgPlace01_1 UFImage
---@field ImgPlace09 UFImage
---@field ImgPlace09_1 UFImage
---@field ImgPlace10 UFImage
---@field ImgPlace10_1 UFImage
---@field ImgPlace11 UFImage
---@field ImgPlace11_1 UFImage
---@field ImgPlace12 UFImage
---@field ImgPlace12_1 UFImage
---@field Panel01 UFCanvasPanel
---@field Panel02 UFCanvasPanel
---@field Panel03 UFCanvasPanel
---@field Panel04 UFCanvasPanel
---@field Panel05 UFCanvasPanel
---@field Panel06 UFCanvasPanel
---@field Panel07 UFCanvasPanel
---@field Panel08 UFCanvasPanel
---@field Panel09 UFCanvasPanel
---@field Panel10 UFCanvasPanel
---@field Panel11 UFCanvasPanel
---@field Panel12 UFCanvasPanel
---@field Panel13 UFCanvasPanel
---@field Panel14 UFCanvasPanel
---@field Panel16 UFCanvasPanel
---@field Panel17 UFCanvasPanel
---@field Phoenix USpineWidget
---@field TextCityName01 UFTextBlock
---@field TextCityName03 UFTextBlock
---@field TextCityName04 UFTextBlock
---@field TextCityName05 UFTextBlock
---@field TextCityName06 UFTextBlock
---@field TextCityName07 UFTextBlock
---@field TextCityName08 UFTextBlock
---@field TextCityName09 UFTextBlock
---@field TextCityName10 UFTextBlock
---@field TextCityName11 UFTextBlock
---@field TextCityName12 UFTextBlock
---@field TextCityName13 UFTextBlock
---@field TextCityName14 UFTextBlock
---@field WaveItem WorldMapNewWaveItemView
---@field WaveItem1 WorldMapNewWaveItemView
---@field WaveItem1_1 WorldMapNewWaveItemView
---@field WaveItem1_10 WorldMapNewWaveItemView
---@field WaveItem1_11 WorldMapNewWaveItemView
---@field WaveItem1_12 WorldMapNewWaveItemView
---@field WaveItem1_13 WorldMapNewWaveItemView
---@field WaveItem1_14 WorldMapNewWaveItemView
---@field WaveItem1_2 WorldMapNewWaveItemView
---@field WaveItem1_3 WorldMapNewWaveItemView
---@field WaveItem1_4 WorldMapNewWaveItemView
---@field WaveItem1_5 WorldMapNewWaveItemView
---@field WaveItem1_6 WorldMapNewWaveItemView
---@field WaveItem1_7 WorldMapNewWaveItemView
---@field WaveItem1_8 WorldMapNewWaveItemView
---@field WaveItem1_9 WorldMapNewWaveItemView
---@field WaveItem_1 WorldMapNewWaveItemView
---@field Whale USpineWidget
---@field AnimIn UWidgetAnimation
---@field AnimLoop1 UWidgetAnimation
---@field AnimLoop2 UWidgetAnimation
---@field AnimLoop3 UWidgetAnimation
---@field AnimLoop4 UWidgetAnimation
---@field AnimMove UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapNewView = LuaClass(UIView, true)

function WorldMapNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Dragon1 = nil
	--self.Dragon2 = nil
	--self.FCanvasPanel_247 = nil
	--self.FCanvasPanel_335 = nil
	--self.HorizontalPanel01 = nil
	--self.HorizontalPanel04 = nil
	--self.HorizontalPanel05 = nil
	--self.HorizontalPanel06 = nil
	--self.HorizontalPanel07 = nil
	--self.HorizontalPanel08 = nil
	--self.HorizontalPanel09 = nil
	--self.HorizontalPanel12 = nil
	--self.HorizontalPanel13 = nil
	--self.ImgCityIcon01 = nil
	--self.ImgCityIcon04 = nil
	--self.ImgCityIcon05 = nil
	--self.ImgCityIcon06 = nil
	--self.ImgCityIcon07 = nil
	--self.ImgCityIcon08 = nil
	--self.ImgCityIcon09 = nil
	--self.ImgCityIcon12 = nil
	--self.ImgCityIcon13 = nil
	--self.ImgPlace01 = nil
	--self.ImgPlace01_1 = nil
	--self.ImgPlace09 = nil
	--self.ImgPlace09_1 = nil
	--self.ImgPlace10 = nil
	--self.ImgPlace10_1 = nil
	--self.ImgPlace11 = nil
	--self.ImgPlace11_1 = nil
	--self.ImgPlace12 = nil
	--self.ImgPlace12_1 = nil
	--self.Panel01 = nil
	--self.Panel02 = nil
	--self.Panel03 = nil
	--self.Panel04 = nil
	--self.Panel05 = nil
	--self.Panel06 = nil
	--self.Panel07 = nil
	--self.Panel08 = nil
	--self.Panel09 = nil
	--self.Panel10 = nil
	--self.Panel11 = nil
	--self.Panel12 = nil
	--self.Panel13 = nil
	--self.Panel14 = nil
	--self.Panel16 = nil
	--self.Panel17 = nil
	--self.Phoenix = nil
	--self.TextCityName01 = nil
	--self.TextCityName03 = nil
	--self.TextCityName04 = nil
	--self.TextCityName05 = nil
	--self.TextCityName06 = nil
	--self.TextCityName07 = nil
	--self.TextCityName08 = nil
	--self.TextCityName09 = nil
	--self.TextCityName10 = nil
	--self.TextCityName11 = nil
	--self.TextCityName12 = nil
	--self.TextCityName13 = nil
	--self.TextCityName14 = nil
	--self.WaveItem = nil
	--self.WaveItem1 = nil
	--self.WaveItem1_1 = nil
	--self.WaveItem1_10 = nil
	--self.WaveItem1_11 = nil
	--self.WaveItem1_12 = nil
	--self.WaveItem1_13 = nil
	--self.WaveItem1_14 = nil
	--self.WaveItem1_2 = nil
	--self.WaveItem1_3 = nil
	--self.WaveItem1_4 = nil
	--self.WaveItem1_5 = nil
	--self.WaveItem1_6 = nil
	--self.WaveItem1_7 = nil
	--self.WaveItem1_8 = nil
	--self.WaveItem1_9 = nil
	--self.WaveItem_1 = nil
	--self.Whale = nil
	--self.AnimIn = nil
	--self.AnimLoop1 = nil
	--self.AnimLoop2 = nil
	--self.AnimLoop3 = nil
	--self.AnimLoop4 = nil
	--self.AnimMove = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.WaveItem)
	self:AddSubView(self.WaveItem1)
	self:AddSubView(self.WaveItem1_1)
	self:AddSubView(self.WaveItem1_10)
	self:AddSubView(self.WaveItem1_11)
	self:AddSubView(self.WaveItem1_12)
	self:AddSubView(self.WaveItem1_13)
	self:AddSubView(self.WaveItem1_14)
	self:AddSubView(self.WaveItem1_2)
	self:AddSubView(self.WaveItem1_3)
	self:AddSubView(self.WaveItem1_4)
	self:AddSubView(self.WaveItem1_5)
	self:AddSubView(self.WaveItem1_6)
	self:AddSubView(self.WaveItem1_7)
	self:AddSubView(self.WaveItem1_8)
	self:AddSubView(self.WaveItem1_9)
	self:AddSubView(self.WaveItem_1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapNewView:OnInit()

end

function WorldMapNewView:OnDestroy()

end

function WorldMapNewView:OnShow()
	for PanelID = 1, CityNum do
		local PanelName = string.format("Panel%02d", PanelID)
		local PanelWidget = self[PanelName]
		if PanelWidget then
			local CityCfg = WorldMapCityCfg:FindCfg(string.format("PanelID = %d", PanelID))
			if CityCfg ~= nil then
				UIUtil.SetIsVisible(PanelWidget, CityCfg.ShowCity)

				-- Panel坐标
				if CityCfg.PosX ~= 0 and CityCfg.PosY ~= 0 then
					UIUtil.CanvasSlotSetPosition(PanelWidget, FVector2D(CityCfg.PosX, CityCfg.PosY))
				end

				-- 主城名称
				local TextCityName = string.format("TextCityName%02d", PanelID)
				local TextWidget = self[TextCityName]
				if TextWidget then
					TextWidget:SetText(MapUtil.GetPlaceName(CityCfg.CityNameID))
				end

				-- 主城图标
				local ImgCityIcon = string.format("ImgCityIcon%02d", PanelID)
				local ImgWidget = self[ImgCityIcon]
				if ImgWidget then
					UIUtil.ImageSetBrushFromAssetPath(ImgWidget, MapUtil.GetIconPath(CityCfg.CityIcon), false, true, true)

					-- 图标存起来，方便后面显隐判断使用
					local CityIconID = string.format("CityIconID%02d", PanelID)
					self[CityIconID] = CityCfg.CityIcon
				end
			else
				UIUtil.SetIsVisible(PanelWidget, false)
			end
		else
			print("[WorldMapNewView:OnShow] node not exist in BP: ", PanelName)
		end
	end

	-- 策划要求，后续会跟随地图开启更换
	UIUtil.SetIsVisible(self.FCanvasPanel_247, true)
	UIUtil.SetIsVisible(self.FCanvasPanel_335, false)

	self:PlayShowAnimLoop()
end

function WorldMapNewView:OnHide()

end

function WorldMapNewView:OnRegisterUIEvent()
	-- for PanelID = 1, CityNum do
	-- 	local BtnName = string.format("Btn%02d", PanelID)
	-- 	UIUtil.AddOnClickedEvent(self, self[BtnName], self.OnClickedBtnCity, PanelID)
	-- end
end

function WorldMapNewView:OnRegisterGameEvent()

end

function WorldMapNewView:OnRegisterBinder()

end

function WorldMapNewView:OnClickedBtnCity(Params)
	-- local PanelID = Params
	-- local Cfg = WorldMapCityCfg:FindCfg(string.format("PanelID = %d", PanelID))
	-- if Cfg and Cfg.UIMapID > 0 then
	-- 	_G.WorldMapMgr:ChangeMap(Cfg.UIMapID)
	-- end
end

function WorldMapNewView:ShowCityInfo(Visible)
	for PanelID = 1, CityNum do
		local PanelName = string.format("Panel%02d", PanelID)
		local PanelWidget = self[PanelName]
		if PanelWidget then
			local TextCityName = string.format("TextCityName%02d", PanelID)
			local TextWidget = self[TextCityName]
			if TextWidget then
				UIUtil.SetIsVisible(TextWidget, Visible)
			end

			local CityIconID = string.format("CityIconID%02d", PanelID)
			if self[CityIconID] and self[CityIconID] > 0 then
				local ImgCityIcon = string.format("ImgCityIcon%02d", PanelID)
				local ImgWidget = self[ImgCityIcon]
				if ImgWidget then
					UIUtil.SetIsVisible(ImgWidget, Visible)
				end
			end
		end
	end
end

function WorldMapNewView:PlayShowAnimLoop()
	self:PlayAnimation(self.AnimLoop1, 0, 0)
	self:PlayAnimation(self.AnimLoop2, 0, 0)
	self:PlayAnimation(self.AnimLoop3, 0, 0)
	self:PlayAnimation(self.AnimLoop4, 0, 0)
end

return WorldMapNewView