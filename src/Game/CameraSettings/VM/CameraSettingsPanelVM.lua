local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CameraSettingsDefine = require("Game/CameraSettings/CameraSettingsDefine")
local CameraSettingsConfig = require("Game/CameraSettings/CameraSettingsConfig")
local CameraSettingsMgr = require("Game/CameraSettings/CameraSettingsMgr")
local CameraSettingsGroupVM = require("Game/CameraSettings/VM/CameraSettingsGroupVM")
local CameraSettingsSliderVM = require("Game/CameraSettings/VM/CameraSettingsSliderVM")
local CameraSettingsCheckboxVM = require("Game/CameraSettings/VM/CameraSettingsCheckboxVM")

local PropertyType = CameraSettingsDefine.PropertyType
local NumberType = CameraSettingsDefine.NumberType

---@class CameraSettingsPanelVM : UIViewModel
local CameraSettingsPanelVM = LuaClass(UIViewModel)

function CameraSettingsPanelVM:Ctor()
	self.SettingsGroupVMList = {}
end

function CameraSettingsPanelVM:GenerateSettingsGroups()
	local GroupConfigs = CameraSettingsConfig.GroupConfigs

	local GroupVMList = {}
	for GroupKey, Group in pairs(GroupConfigs) do
		local PropVMList = {}
		for PropKey, Property in pairs(Group.Properties) do
			local PropertyVM = nil
			local CurrentValue = CameraSettingsMgr:GetCameraProperty(GroupKey, PropKey)
			if Property.PropType == PropertyType.Boolean then
				PropertyVM = CameraSettingsCheckboxVM.New()
				if nil ~= CurrentValue then
					PropertyVM.bIsChecked = CurrentValue
				end
			elseif Property.PropType == PropertyType.Scalar then
				PropertyVM = CameraSettingsSliderVM.New()
				if nil ~= CurrentValue then
					PropertyVM.MinValue = math.min(Property.MinValue, CurrentValue)
					PropertyVM.MaxValue = math.max(Property.MaxValue, CurrentValue)
					PropertyVM.CurrentValue = CurrentValue
					if Property.NumType == NumberType.Integer then
						PropertyVM.NumberType = NumberType.Integer
						PropertyVM.CurrentValue = math.ceil(PropertyVM.CurrentValue)
					end
				end
			end
			if nil ~= PropertyVM then
				PropertyVM.PropKey = PropKey
				PropertyVM.PropName = Property.PropName
				table.insert(PropVMList, PropertyVM)
			end
		end
		table.sort(PropVMList, function(Left, Right) return Left.PropKey < Right.PropKey end)
		local GroupVM = CameraSettingsGroupVM.New()
		GroupVM:GenerateGroup({GroupKey = GroupKey, GroupName = Group.GroupName, PropertyVMList = PropVMList})
		table.insert(GroupVMList, GroupVM)
	end
	table.sort(GroupVMList, function(Left, Right) return Left.GroupKey < Right.GroupKey end)
	self.SettingsGroupVMList = GroupVMList
end

return CameraSettingsPanelVM