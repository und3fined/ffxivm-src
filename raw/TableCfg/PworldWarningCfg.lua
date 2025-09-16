-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PworldWarningCfg : CfgBase
local PworldWarningCfg = {
	TableName = "c_pworld_warning_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PworldWarningCfg, { __index = CfgBase })

PworldWarningCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function PworldWarningCfg:GetWarningIcon(ID,IsDanger)
	local Cfg = self:FindCfgByKey(ID)
	if nil == Cfg then
		return
	end

	if IsDanger then
		return Cfg.Icon2
	else
		return Cfg.Icon
	end

end

return PworldWarningCfg
