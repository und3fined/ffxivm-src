-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EquipImproveMaterialCfg : CfgBase
local EquipImproveMaterialCfg = {
	TableName = "c_equip_improve_Material_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(EquipImproveMaterialCfg, { __index = CfgBase })

EquipImproveMaterialCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function EquipImproveMaterialCfg:CheckIsInVersion(ID)
    local Cfg = self:FindCfgByKey(ID)
    if Cfg and next(Cfg) then
        local VersionName = Cfg.Version
        local IsInVersion = _G.WardrobeMgr:BeIncludedInGameVersion(VersionName)
        return IsInVersion
    end
    return false
end

function EquipImproveMaterialCfg:GetCanExchange(MaterialID)
    local SearchConditions = string.format("ID=%d", MaterialID)
	local Cfg = self:FindCfg(SearchConditions)

	return Cfg ~= nil and Cfg.IsTicket == 1
end
return EquipImproveMaterialCfg
