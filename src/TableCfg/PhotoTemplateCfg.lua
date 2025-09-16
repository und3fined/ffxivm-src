-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PhotoTemplateCfg : CfgBase
local PhotoTemplateCfg = {
	TableName = "c_PhotoTemplate_cfg",
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

setmetatable(PhotoTemplateCfg, { __index = CfgBase })

PhotoTemplateCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return PhotoTemplateCfg
