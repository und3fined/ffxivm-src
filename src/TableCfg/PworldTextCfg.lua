-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PworldTextCfg : CfgBase
local PworldTextCfg = {
	TableName = "c_pworld_text_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Text',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PworldTextCfg, { __index = CfgBase })

PworldTextCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function PworldTextCfg:GetText(ID)
    local Cfg = self:FindCfgByKey(ID)
    if nil == Cfg then
        return ""
    end

    return Cfg.Text
end

return PworldTextCfg
