-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MagicsparInlayCfg : CfgBase
local MagicsparInlayCfg = {
	TableName = "c_magicspar_inlay_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MagicsparInlayCfg, { __index = CfgBase })

MagicsparInlayCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function MagicsparInlayCfg:FindCfgByPart(InPart)
	local SearchConditions = string.format("Part = %d", InPart)
	return self:FindCfg(SearchConditions)
end

return MagicsparInlayCfg
