-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LandBuyConditionCfg : CfgBase
local LandBuyConditionCfg = {
	TableName = "c_land_buy_condition_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(LandBuyConditionCfg, { __index = CfgBase })

LandBuyConditionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


function LandBuyConditionCfg:FindAllCfgByBelongType(BelongType)
    if nil == BelongType then
        return {}
    end
    -- local SearchConditions = "BelongType = " .. BelongType
    local allCfg = self:FindAllCfg()
    local cfgResults = table.find_all_by_predicate(allCfg, function(item)
        return item.BelongType == BelongType or item.BelongType == 0
    end)
    return cfgResults
end

return LandBuyConditionCfg
