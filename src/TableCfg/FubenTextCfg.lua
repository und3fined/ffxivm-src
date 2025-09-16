-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FubenTextCfg : CfgBase
local FubenTextCfg = {
	TableName = "c_fuben_text",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Content',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FubenTextCfg, { __index = CfgBase })

FubenTextCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return FubenTextCfg
