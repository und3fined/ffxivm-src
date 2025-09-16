-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class EquipReceiptCfg : CfgBase
local EquipReceiptCfg = {
	TableName = "c_equip_receipt_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(EquipReceiptCfg, { __index = CfgBase })

EquipReceiptCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function EquipReceiptCfg:CheckEquipCanExchange(ResID, MaterialID)
    local Cfg = self:FindCfgByKey(ResID)
    if Cfg and Cfg.MaterialID == MaterialID then
        return Cfg
    end
end

function EquipReceiptCfg:GetFristMaterial()
    local AllCfg = self:FindAllCfg()
    if AllCfg and next(AllCfg) then
        return AllCfg[1]
    end
end

return EquipReceiptCfg
