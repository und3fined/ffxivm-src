
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class WorldMapListItemVM : UIViewModel
local WorldMapListItemVM = LuaClass(UIViewModel)

---Ctor
function WorldMapListItemVM:Ctor()
	self.ID = nil
    self.PlaceName = nil
	self.IsLocation = false
	self.IsSelect = false
	self.bHaveFlyRight = false -- 是否是可飞行地图
	self.IconFlyAdmitted = nil	-- 不同标记表现是否解锁所有飞行条件 path
	self.IconPath = nil
	self.IconVisible = true
end

function WorldMapListItemVM:SetIsSelect(IsSelect)
	self.IsSelect = IsSelect
end

function WorldMapListItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ID
end

function WorldMapListItemVM:UpdateVM(Value, Params)
	local IsUnlock = Value.IsUnlock
	self.ID = Value.ID
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