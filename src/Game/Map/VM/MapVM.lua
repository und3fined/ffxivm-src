--
-- Author: anypkvcai
-- Date: 2022-10-24 14:55
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")

---@class MapVM : UIViewModel
---@field MajorPosition table  @主角在UI上的地图坐标，中心点在地图中心
---@field MajorLeftTopPosition table  @主角在UI上的地图坐标，中心点在地图左上角
local MapVM = LuaClass(UIViewModel)

---Ctor
function MapVM:Ctor()
	self.WeatherID = 0  -- 当前地图天气

	--self.MapBackground = ""
	self.MapPath = ""
	self.MapName = ""
	self.MaskPath = ""
	self.MapFullName = ""
	self.MajorRotationAngle = 0
	self.CameraRotationAngle = 0
	self.MajorPosition = { X = 0, Y = 0 }
	self.MajorLeftTopPosition = { X = 0, Y = 0 }
	self.MajorWorldPosition = { X = 0, Y = 0, Z =0 }
	self.DiscoveryFlag = 0
	self.IsMajorVisible = true

	--Setting
	self.MarkerIconVisible = true
	self.MarkerTextVisible = true
	self.MapWeatherVisible = true
	self.MapTimeVisible = true
	self.MapCrystalIconVisible = true
	self.MapWildBoxVisible = false
	self.MapAetherCurrentVisible = false
	self.MapDiscoverNoteVisible = false
	self.WeatherShowType = 0
	self.MapQuestShowType = 0

	-- 地图中各玩法位置是否可见(透过GM展示，正常不显示)
	self.GameplayLocationVisible = false
end

function MapVM:OnInit()

end

function MapVM:OnBegin()

end

function MapVM:OnEnd()

end

function MapVM:OnShutdown()

end

-----SetMapBackground
-----@param MapBackground string
--function MapVM:SetMapBackground(MapBackground)
--	self.MapBackground = MapBackground
--end

---SetMapPath
---@param MapPath string
function MapVM:SetMapPath(MapPath)
	self.MapPath = MapPath
end

---SetMapName
---@param MapName string
function MapVM:SetMapName(MapName)
	self.MapName = MapName
end

---SetMapFullName 地图完整名称
---@param MapFullName string
function MapVM:SetMapFullName(MapFullName)
	self.MapFullName = MapFullName
end

---IsMapVisible
---@return boolean
function MapVM.IsMapVisible(MapPath)
	return nil ~= MapPath and string.len(MapPath) > 0
end

---SetMajorRotationAngle
---@param Angle number
function MapVM:SetMajorRotationAngle(Angle)
	self.MajorRotationAngle = Angle
end

---SetCameraRotationAngle
---@param Angle number
function MapVM:SetCameraRotationAngle(Angle)
	self.CameraRotationAngle = Angle
end

---SetWeatherID
---@param WeatherID number
function MapVM:SetWeatherID(WeatherID)
	self.WeatherID = WeatherID
end

---SetMapMaskPath
---@param MaskPath string
function MapVM:SetMapMaskPath(MaskPath)
	if not MaskPath or not string.find(MaskPath, 'Texture') then
		self.MaskPath = ""
		self.IsMaskVisible = false
		return
	end

	self.MaskPath = MaskPath
end

---SetDiscoveryFlag
---@param Flag number
function MapVM:SetDiscoveryFlag(Flag)
	self.DiscoveryFlag = Flag
end

---SetIsAllActivate
------@param Flag boolean
function MapVM:SetIsAllActivate(Flag)
	self.IsMaskVisible = not Flag and not string.isnilorempty(self.MaskPath)
end

---SetMajorPosition
---@param X number
---@param Y number
function MapVM:SetMajorPosition(X, Y)
	local OldX = self.MajorPosition.X
	local OldY = self.MajorPosition.Y

	self.MajorPosition.X = X
	self.MajorPosition.Y = Y

	local Changed = OldX ~= X or OldY ~= Y
	if Changed then
		self:PropertyValueChanged("MajorPosition")
	end
end

---GetMajorPosition
function MapVM:GetMajorPosition()
	return self.MajorPosition
end

---SetMajorPosition
---@param X number
---@param Y number
function MapVM:SetMajorLeftTopPosition(X, Y)
	local OldX = self.MajorLeftTopPosition.X
	local OldY = self.MajorLeftTopPosition.Y

	self.MajorLeftTopPosition.X = X
	self.MajorLeftTopPosition.Y = Y

	local Changed = OldX ~= X or OldY ~= Y
	if Changed then
		self:PropertyValueChanged("MajorLeftTopPosition")
	end
end

---GetMajorLeftTopPosition
function MapVM:GetMajorLeftTopPosition()
	return self.MajorLeftTopPosition
end

function MapVM:SetMajorWorldPosition(X, Y, Z)
	self.MajorWorldPosition.X = X
	self.MajorWorldPosition.Y = Y
	self.MajorWorldPosition.Z = Z
end

function MapVM:GetMajorWorldPosition()
	return self.MajorWorldPosition
end

function MapVM:GetWeatherShowType()
	return self.WeatherShowType
end

function MapVM:SetIsMajorVisible(Val)
	self.IsMajorVisible = Val
end

--function MapVM:SetSettingPropertyValue(PropertyName, Value)
--	self:SetPropertyValue()
--end

function MapVM:SetGameplayLocationVisible(Visible)
	self.GameplayLocationVisible = Visible
end

function MapVM:GetGameplayLocationVisible()
	return self.GameplayLocationVisible
end

return MapVM