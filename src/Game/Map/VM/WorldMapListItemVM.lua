
--
-- Author:
-- Date:
-- Description: 地图列表，如大地图的下拉列表
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class WorldMapListItemVM : UIViewModel
local WorldMapListItemVM = LuaClass(UIViewModel)

function WorldMapListItemVM:Ctor()
	self.ID = nil -- UIMapID
    self.PlaceName = nil -- 地名

	self.IsLocation = false -- 主角是否在当前地图
	self.IsSelect = false -- 是否当前查看的地图

	self.bHaveFlyRight = false -- 是否是可飞行地图
	self.IconFlyAdmitted = nil	-- 不同图标表现是否解锁所有飞行条件

	self.IconPath = nil -- 三级地图中楼层地图的显示图标
	self.IconVisible = true -- 三级地图中楼层地图的显示图标是否可见
end

function WorldMapListItemVM:SetIsSelect(IsSelect)
	self.IsSelect = IsSelect
end

function WorldMapListItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ID
end

function WorldMapListItemVM:UpdateVM(Value, Params)
	self.ID = Value.ID

	local IsUnlock = Value.IsUnlock
	local Name
	if IsUnlock then
		Name = Value.Name
	else
		Name = "????"
	end
	if nil == Name then
		return
	end
	self.PlaceName = Name

	self.IsLocation = Value.IsLocation
	self.IsSelect = Value.IsSelect

	self.bHaveFlyRight = Value.bHaveFlyRight
	self.IconFlyAdmitted = Value.IconFlyAdmitted

	self.IconPath = Value.IconPath
	self.IconVisible = Value.IconVisible
end

return WorldMapListItemVM