-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TradeMarketMainTypeCfg : CfgBase
local TradeMarketMainTypeCfg = {
	TableName = "c_trade_market_main_type_cfg",
    LruKeyType = nil,
	KeyName = "MainType",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'MainTypeName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TradeMarketMainTypeCfg, { __index = CfgBase })

TradeMarketMainTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return TradeMarketMainTypeCfg
