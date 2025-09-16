-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ItemExchangeCfg : CfgBase
local ItemExchangeCfg = {
	TableName = "c_item_exchange_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ItemExchangeCfg, { __index = CfgBase })

ItemExchangeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function ItemExchangeCfg:FindAllCfgByGroup(GroupValue)
    local Cfg = self:FindAllCfg()
	if Cfg == nil then
		return nil
	end

    local TempCfg = {}
    for _, value in pairs(Cfg) do
        -- body
        if value.Group == GroupValue then
            table.insert(TempCfg, value)
        end
    end
	return TempCfg
end

return ItemExchangeCfg
