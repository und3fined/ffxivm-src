-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class ClientGlobalCfg : CfgBase
local ClientGlobalCfg = {
	TableName = "c_client_global_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(ClientGlobalCfg, { __index = CfgBase })

ClientGlobalCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取客户端全局配置表的值
---@param ID number 客户端全局配置ID
---@param DefaultValue number 没有配置时的默认值
---@return number
function ClientGlobalCfg:GetConfigValue(ID, DefaultValue)
    DefaultValue = DefaultValue or 0

    local Cfg = self:FindCfgByKey(ID)
    if Cfg ~= nil then
        return Cfg.Value[1] or DefaultValue
    else
        return DefaultValue
    end
end

---获取客户端全局配置表的值列表
---@param ID number 客户端全局配置ID
---@return number[]
function ClientGlobalCfg:GetConfigValueList(ID)
    local Cfg = self:FindCfgByKey(ID)
    if Cfg ~= nil then
        return Cfg.Value
    else
        return {}
    end
end

return ClientGlobalCfg
