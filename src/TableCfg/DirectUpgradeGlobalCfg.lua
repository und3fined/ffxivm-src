-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class DirectUpgradeGlobalCfg : CfgBase
local DirectUpgradeGlobalCfg = {
	TableName = "c_direct_upgrade_global_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(DirectUpgradeGlobalCfg, { __index = CfgBase })

DirectUpgradeGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function DirectUpgradeGlobalCfg:GetDirectUpgradeCfg(ID)
    return self:FindCfgByKey(ID)
end

return DirectUpgradeGlobalCfg
