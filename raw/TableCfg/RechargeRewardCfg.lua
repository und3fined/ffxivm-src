-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RechargeRewardCfg : CfgBase
local RechargeRewardCfg = {
	TableName = "c_recharge_reward_cfg",
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

setmetatable(RechargeRewardCfg, { __index = CfgBase })

RechargeRewardCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return RechargeRewardCfg
