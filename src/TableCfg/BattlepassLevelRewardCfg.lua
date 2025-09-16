-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BattlepassLevelRewardCfg : CfgBase
local BattlepassLevelRewardCfg = {
	TableName = "c_battlepass_level_reward_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BattlepassLevelRewardCfg, { __index = CfgBase })

BattlepassLevelRewardCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function BattlepassLevelRewardCfg:FindCfgsByGroupID(GroupID)
	local AllCfgs = self:FindAllCfg(string.format("GroupID = %d", GroupID))
    return AllCfgs
end

function BattlepassLevelRewardCfg:FindCfgByGroupIDAndLevel(GroupID, Level)
	local Cfg = self:FindAllCfg(string.format("GroupID = %d and Level = %d", GroupID, Level))
	return Cfg
end

return BattlepassLevelRewardCfg
