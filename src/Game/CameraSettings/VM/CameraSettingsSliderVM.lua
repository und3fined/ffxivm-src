local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CameraSettingsDefine = require("Game/CameraSettings/CameraSettingsDefine")

---@class CameraSettingsSliderVM : UIViewModel
local CameraSettingsSliderVM = LuaClass(UIViewModel)

function CameraSettingsSliderVM:Ctor()
	self.GroupKey = ""
	self.PropKey = ""
	self.PropName = ""
	self.MinValue = 0
	self.MaxValue = 1
	self.CurrentValue = 0
	self.NumberType = CameraSettingsDefine.NumberType.Float
end

function CameraSettingsSliderVM:AdapterOnGetWidgetIndex()
	return 1
end

return CameraSettingsSliderVM