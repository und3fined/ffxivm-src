-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LoadingContentCfg : CfgBase
local LoadingContentCfg = {
	TableName = "c_loading_content_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TextBody',
            },
            {
                Name = 'TextTitle',
            },
            {
                Name = 'TextLabel',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(LoadingContentCfg, { __index = CfgBase })

LoadingContentCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return LoadingContentCfg
