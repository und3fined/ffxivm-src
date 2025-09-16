-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RacecolorCommonCfg : CfgBase
local RacecolorCommonCfg = {
	TableName = "c_racecolor_common_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RacecolorCommonCfg, { __index = CfgBase })

RacecolorCommonCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function RacecolorCommonCfg:FindAllColorCfg()
	local SearchConditions = "ID < 256"
	return self:FindAllCfg(SearchConditions)
end
return RacecolorCommonCfg
