-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class StoreGiftstyleCfg : CfgBase
local StoreGiftstyleCfg = {
	TableName = "c_store_giftstyle_cfg",
    LruKeyType = nil,
	KeyName = "StyleID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'StyleName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(StoreGiftstyleCfg, { __index = CfgBase })

StoreGiftstyleCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return StoreGiftstyleCfg
