-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TradeMarketTypeInfoCfg : CfgBase
local TradeMarketTypeInfoCfg = {
	TableName = "c_trade_market_type_info_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'SubTypeName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TradeMarketTypeInfoCfg, { __index = CfgBase })

TradeMarketTypeInfoCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return TradeMarketTypeInfoCfg
