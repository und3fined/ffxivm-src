-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ChocoboUiIconCfg : CfgBase
local ChocoboUiIconCfg = {
	TableName = "c_chocobo_ui_icon_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ChocoboUiIconCfg, { __index = CfgBase })

ChocoboUiIconCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function ChocoboUiIconCfg:FindPathByKey(key)
	return self:FindValue(key, "IconPath")
end

return ChocoboUiIconCfg
