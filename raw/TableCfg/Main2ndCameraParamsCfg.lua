-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class Main2ndCameraParamsCfg : CfgBase
local Main2ndCameraParamsCfg = {
	TableName = "c_Main2ndCameraParams_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TribeType',
            },
            {
                Name = 'RacialType',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(Main2ndCameraParamsCfg, { __index = CfgBase })

Main2ndCameraParamsCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return Main2ndCameraParamsCfg
