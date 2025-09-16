-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class SequenceSkipGroupCfg : CfgBase
local SequenceSkipGroupCfg = {
	TableName = "c_sequence_skip_group_cfg",
    LruKeyType = nil,
	KeyName = "SequenceID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(SequenceSkipGroupCfg, { __index = CfgBase })

SequenceSkipGroupCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return SequenceSkipGroupCfg
