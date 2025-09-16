local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
-- local CameraSettingsCheckboxVM = require("Game/CameraSettings/VM/CameraSettingsCheckboxVM")
-- local CameraSettingsSliderVM = require("Game/CameraSettings/VM/CameraSettingsSliderVM")
-- local CameraSettingsDefine = require("Game/CameraSettings/VM/CameraSettingsDefine")

---@class CameraSettingsGroupVM : UIViewModel
local CameraSettingsGroupVM = LuaClass(UIViewModel)

function CameraSettingsGroupVM:Ctor()
	self.GroupKey = ""
	self.GroupName = ""
	self.PropertyVMList = {}
end

function CameraSettingsGroupVM:GenerateGroup(Params)
	if nil == Params then
		return
	end

	for _, PropertyVM in pairs(Params.PropertyVMList) do
		PropertyVM.GroupKey = Params.GroupKey
	end
	self.GroupKey = Params.GroupKey
	self.GroupName = Params.GroupName
	self.PropertyVMList = Params.PropertyVMList
end

return CameraSettingsGroupVM