-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PhotoParamCfg : CfgBase
local PhotoParamCfg = {
	TableName = "c_PhotoParam_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PhotoParamCfg, { __index = CfgBase })

PhotoParamCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return PhotoParamCfg
