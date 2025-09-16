--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-10-09 17:25:33
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-02-18 10:35:23
FilePath: \Client\Source\Script\Game\Map\Marker\MapMarkerFish.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--
-- Author: anypkvcai
-- Date: 2023-07-03 23:37
-- Description:
--


local LuaClass = require("Core/LuaClass")
local MapMarker = require("Game/Map/Marker/MapMarker")
local MapDefine = require("Game/Map/MapDefine")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")

local FVector2D = _G.UE.FVector2D
local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerBPType = MapDefine.MapMarkerBPType

---@class MapMarkerFish
local MapMarkerFish = LuaClass(MapMarker)

---Ctor
function MapMarkerFish:Ctor()
	self.Radius = 0 -- 钓鱼点半径
	self.bSelected = false
end

function MapMarkerFish:GetType()
	return MapMarkerType.Fish
end

function MapMarkerFish:GetBPType()
	return MapMarkerBPType.FishRange
end

function MapMarkerFish:InitMarker(Params)
	self.Name = Params.Name
	self.Radius = Params.HorizontalDistance
	self.bSelected = Params.Status

	self:UpdateMarker(Params)
end

function MapMarkerFish:UpdateMarker(Params)
    self:UpdateFollow()
end

function MapMarkerFish:OnTriggerMapEvent(EventParams)
	local FishIngholeVM = _G.FishIngholeVM
	local PlaceIndex = FishIngholeVM:GetPlaceIndexByName(self.Name)
	FishIngholeVM:SelectedLocation(FishIngholeVM.SelectAreaIndex, PlaceIndex, nil, true)
	_G.FishNotesMgr:RegisterTimer(function ()
		local FishIngholePanel = _G.UIViewMgr:FindVisibleView(_G.UIViewID.FishInghole)
		if FishIngholePanel then
			local MapContent = FishIngholePanel.MapContent
			local MarkerView = MapContent:GetMapMarkerViewByMarker(self)
			if MarkerView then
				local ScreenPosition = UIUtil.LocalToAbsolute(MarkerView, FVector2D(0,-50))
				EventParams.ScreenPosition = ScreenPosition
			end
		end
		MapUtil.ShowWorldMapMarkerFollowTips(self, EventParams)
	end, 0.1, 0, 1)
end

function MapMarkerFish:IsNameVisible(Scale)
	return true
end

function MapMarkerFish:IsIconVisible(Scale)
	return true
end

function MapMarkerFish:GetTipsName()
	return self:GetName()
end

function MapMarkerFish:GetRadius()
	return self.Radius
end

function MapMarkerFish:SetIsSelected(bSelected)
	self.bSelected = bSelected
end

function MapMarkerFish:GetIsSelected()
	return self.bSelected
end


return MapMarkerFish