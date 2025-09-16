-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EquipImproveCfg : CfgBase
local EquipImproveCfg = {
	TableName = "c_equip_improve_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(EquipImproveCfg, { __index = CfgBase })

EquipImproveCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function EquipImproveCfg:GetKeyByExchangeItem(ItemID)   
    local SearchConditions = string.format("ImprovedID=%d", ItemID)
	local Cfg = self:FindCfg(SearchConditions)

	return Cfg ~= nil and Cfg.ID or 0
end

function EquipImproveCfg:GetOpenVersion(ItemID)
	local Cfg = self:FindCfgByKey(ItemID)
	return Cfg~= nil and Cfg.Version or ""
end
return EquipImproveCfg
