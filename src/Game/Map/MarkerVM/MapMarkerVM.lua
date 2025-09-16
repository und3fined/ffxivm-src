--
-- Author: anypkvcai
-- Date: 2022-12-08 16:40
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MapDefine = require("Game/Map/MapDefine")
local MapConstant = MapDefine.MapConstant


---@class MapMarkerVM : UIViewModel
---@field NameVisibility ESlateVisibility 名称可见性
---@field IconVisibility ESlateVisibility 图标可见性。有些标记类型，没有名称，图标不可见相当于整个标记不可见
---@field IsMarkerVisible boolean 标记可见性。配合IsShowMarker使用
---@field IsShowMarker boolean 逻辑上设置是否需要显示标记。有些是针对整个标记显隐，有些是针对标记图标显隐，比如队伍标记，除了图标还有箭头
local MapMarkerVM = LuaClass(UIViewModel)

function MapMarkerVM:Ctor()
	self:Reset()
end

function MapMarkerVM:Reset()
	self.MapMarker = nil

	self.Name = ""
	self.IconPath = ""
	self.Scale = 1
	self.NameVisibility = 0
	self.IconVisibility = 0
	self.IsMarkerVisible = true
	self.IsShowMarker = true

	self.IsActive = true
	self.IsFollow = false
	self.Alpha = 1
end

function MapMarkerVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ID
end

function MapMarkerVM:UpdateVM(Value)
	self.MapMarker = Value
	self.Name = Value:GetName()
	self.IconPath = Value:GetIconPath()
	self:UpdateNameVisibility()
	self:UpdateIconVisibility()
	self:UpdateMarkerVisible()
	self.IsActive = Value:GetIsActive()
	self.IsFollow = Value:GetIsFollow()
end

function MapMarkerVM:GetName()
	return self.Name
end

function MapMarkerVM:GetIconPath()
	return self.IconPath
end

function MapMarkerVM:GetMapMarker()
	return self.MapMarker
end

function MapMarkerVM:GetBPType()
	return self.MapMarker:GetBPType()
end

function MapMarkerVM:GetType()
	return self.MapMarker:GetType()
end

function MapMarkerVM:GetPosition()
	return self.MapMarker:GetPosition()
end

function MapMarkerVM:GetIsMarkerVisible()
	return self.IsMarkerVisible
end

function MapMarkerVM:SetIsShowMarker(IsShowMarker)
	self.IsShowMarker = IsShowMarker
	self:UpdateMarkerVisible()
end

function MapMarkerVM:UpdateMarkerVisible()
	local Marker = self.MapMarker
	local Scale = self.Scale
	self.IsMarkerVisible = self.IsShowMarker and (Marker:IsNameVisible(Scale) or Marker:IsIconVisible(Scale))
end

function MapMarkerVM:UpdateNameVisibility()
	self.NameVisibility = self.MapMarker:GetNameVisibility(self.Scale)
end

function MapMarkerVM:UpdateIconVisibility()
	self.IconVisibility = self.MapMarker:GetIconVisibility(self.Scale)
	self.Alpha = self.MapMarker:GetAlpha()
end

function MapMarkerVM:UpdatePriority()
	--self.PriorityOrder = self.MapMarker:GetPriority()
end

function MapMarkerVM:OnScaleChanged(Scale)
	local LastScale = self.Scale
	self.Scale = Scale

	local LastScaleLevel = self:GetScaleLevel(LastScale)
	local CurrentScaleLevel = self:GetScaleLevel(Scale)
	if LastScaleLevel == CurrentScaleLevel then
		-- 【优化】地图缩放时，连续两次的缩放没有跨越缩放等级，则不需要更新可见性，只需要更新位置
		return
	end

	self:UpdateNameVisibility()
	self:UpdateIconVisibility()
	self:UpdateMarkerVisible()
end

---根据缩放比例获取缩放等级
function MapMarkerVM:GetScaleLevel(Scale)
	if Scale >= MapConstant.MAP_SCALE_VISIBLE_LEVEL3 then
		return 3
	elseif Scale >= MapConstant.MAP_SCALE_VISIBLE_LEVEL2 then
		return 2
	elseif Scale >= MapConstant.MAP_SCALE_VISIBLE_LEVEL1 then
		return 1
	elseif Scale >= MapConstant.MAP_SCALE_MIN then
		return 0
	end
	return -1
end

return MapMarkerVM