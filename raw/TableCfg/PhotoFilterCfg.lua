-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PhotoFilterCfg : CfgBase
local PhotoFilterCfg = {
	TableName = "c_PhotoFilter_cfg",
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

setmetatable(PhotoFilterCfg, { __index = CfgBase })

PhotoFilterCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return PhotoFilterCfg
