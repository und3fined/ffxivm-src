-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ImagechangeCfg : CfgBase
local ImagechangeCfg = {
	TableName = "c_imagechange_cfg",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ImagechangeCfg, { __index = CfgBase })

ImagechangeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return ImagechangeCfg
