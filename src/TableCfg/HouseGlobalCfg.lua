-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class HouseGlobalCfg : CfgBase
local HouseGlobalCfg = {
	TableName = "c_house_global_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(HouseGlobalCfg, { __index = CfgBase })

HouseGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

--- 通过类别获取Value
function HouseGlobalCfg:GetValueByTypeID(TypeID, Index)
	if TypeID == nil then return end
	local SearchConditions = string.format("ID=%d", TypeID)
	local Cfg = self:FindCfg(SearchConditions)
	if nil == Cfg then return end
	return Cfg.Value[Index or 1]
end

return HouseGlobalCfg
