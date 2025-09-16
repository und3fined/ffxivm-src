-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class RechargeGlobalCfg : CfgBase
local RechargeGlobalCfg = {
	TableName = "c_recharge_global_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(RechargeGlobalCfg, { __index = CfgBase })

RechargeGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function RechargeGlobalCfg:FindFirstAsInt(ID)
	return tonumber(self:FindFirst(ID))
end

function RechargeGlobalCfg:FindFirst(ID)
	local CfgData = self:FindValue(ID, "Value")
	if nil == CfgData then
		return nil
	end
	return CfgData[1]
end

return RechargeGlobalCfg
