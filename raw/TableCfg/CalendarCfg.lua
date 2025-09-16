-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CalendarCfg : CfgBase
local CalendarCfg = {
	TableName = "c_calendar_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CalendarCfg, { __index = CfgBase })

CalendarCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return CalendarCfg
