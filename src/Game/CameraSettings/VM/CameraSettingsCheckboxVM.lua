local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CameraSettingsMgr = require("Game/CameraSettings/CameraSettingsMgr")

---@class CameraSettingsCheckboxVM : UIViewModel
local CameraSettingsCheckboxVM = LuaClass(UIViewModel)

function CameraSettingsCheckboxVM:Ctor()
	self.GroupKey = ""
	self.PropKey = ""
	self.PropName = ""
	self.bIsChecked = false
end

function CameraSettingsCheckboxVM:AdapterOnGetWidgetIndex()
	return 0
end

return CameraSettingsCheckboxVM