-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class AttrParamCfg : CfgBase
local AttrParamCfg = {
	TableName = "c_attr_param_cfg",
    LruKeyType = nil,
	KeyName = "RoleLevel",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(AttrParamCfg, { __index = CfgBase })

AttrParamCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---FindCfgByID
---@param ID number
---@return table<string,any> | nil
function AttrParamCfg:FindCfgByID(ID)
	return self:FindCfgByKey(ID)
end

return AttrParamCfg
