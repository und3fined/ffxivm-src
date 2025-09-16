-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class MovieseqContentCfg : CfgBase
local MovieseqContentCfg = {
	TableName = "c_movieseq_content",
    LruKeyType = "integer",
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(MovieseqContentCfg, { __index = CfgBase })

MovieseqContentCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return MovieseqContentCfg
