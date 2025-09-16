-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class DeviceAdapterCfg : CfgBase
local DeviceAdapterCfg = {
	TableName = "c_device_adapter_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(DeviceAdapterCfg, { __index = CfgBase })

DeviceAdapterCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function DeviceAdapterCfg:FindCfgByDeviceModel(DeviceModel)
	local SearchConditions = string.format("DeviceModel='%s'", DeviceModel)

	return self:FindCfg(SearchConditions)
end

return DeviceAdapterCfg
