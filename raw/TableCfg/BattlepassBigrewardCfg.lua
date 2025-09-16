-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BattlepassBigrewardCfg : CfgBase
local BattlepassBigrewardCfg = {
	TableName = "c_battlepass_bigreward_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BattlepassBigrewardCfg, { __index = CfgBase })

BattlepassBigrewardCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function BattlepassBigrewardCfg:FindCfgsByGroupID(GroupID)
	local AllCfgs = self:FindAllCfg(string.format("GroupID = %d", GroupID))
    return AllCfgs
end

return BattlepassBigrewardCfg
