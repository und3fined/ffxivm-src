-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TradeMarketGoodsTypeCfg : CfgBase
local TradeMarketGoodsTypeCfg = {
	TableName = "c_trade_market_goods_type_cfg",
    LruKeyType = nil,
	KeyName = "ID",
	Localization = {
        Config = {
            {
                Name = "MainTypeShow",
            },
            {
                Name = "SubTypeShow",
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TradeMarketGoodsTypeCfg, { __index = CfgBase })

TradeMarketGoodsTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return TradeMarketGoodsTypeCfg
