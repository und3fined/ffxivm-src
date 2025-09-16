-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class BattlepassTaskCfg : CfgBase
local BattlepassTaskCfg = {
	TableName = "c_battlepass_task_cfg",
    LruKeyType = nil,
	KeyName = "TaskID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(BattlepassTaskCfg, { __index = CfgBase })

BattlepassTaskCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function BattlepassTaskCfg:FindCfgsByGroupID(GroupID)
	local AllCfgs = self:FindAllCfg(string.format("GroupID = %d", GroupID))
    return AllCfgs
end

return BattlepassTaskCfg
