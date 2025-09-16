-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ChocoboModelShowCfg : CfgBase
local ChocoboModelShowCfg = {
	TableName = "c_chocobo_model_show_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ChocoboModelShowCfg, { __index = CfgBase })

ChocoboModelShowCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY
function ChocoboModelShowCfg:FindCfgByRaceIDAndUIType(RaceID, UIType)
	local Cfg = self:FindAllCfg(string.format("RaceID = %d and UIType = %d", RaceID, UIType))
	return Cfg
end

return ChocoboModelShowCfg
