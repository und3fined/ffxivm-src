-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TimeLineWhiteListCfg : CfgBase
local TimeLineWhiteListCfg = {
	TableName = "c_TimeLine_WhiteList_cfg",
    LruKeyType = nil,
	KeyName = "WhiteListResourceName",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TimeLineWhiteListCfg, { __index = CfgBase })

TimeLineWhiteListCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return TimeLineWhiteListCfg
