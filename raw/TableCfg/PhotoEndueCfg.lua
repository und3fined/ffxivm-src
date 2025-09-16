-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PhotoEndueCfg : CfgBase
local PhotoEndueCfg = {
	TableName = "c_photo_endue_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Target',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PhotoEndueCfg, { __index = CfgBase })

PhotoEndueCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return PhotoEndueCfg
