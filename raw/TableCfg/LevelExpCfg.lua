-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class LevelExpCfg : CfgBase
local LevelExpCfg = {
	TableName = "c_level_exp_cfg",
    LruKeyType = nil,
	KeyName = "Level",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(LevelExpCfg, { __index = CfgBase })

LevelExpCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function LevelExpCfg:GetMaxLevel()
	local MaxLevel = 0
	local Cfg = self:FindCfgByKey(1)
	if nil == Cfg then return MaxLevel end
	MaxLevel = Cfg.MaxLevel or 0
	return MaxLevel
end

return LevelExpCfg
