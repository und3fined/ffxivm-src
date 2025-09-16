-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class QteSkilldisplayCfg : CfgBase
local QteSkilldisplayCfg = {
	TableName = "c_qte_skilldisplay_cfg",
    LruKeyType = nil,
	KeyName = "Prof",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(QteSkilldisplayCfg, { __index = CfgBase })

QteSkilldisplayCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY


function QteSkilldisplayCfg:FindCfgByProfID(ProfID)
    local Cfg =  self:FindCfgByKey(ProfID)
	if nil == Cfg then return end
	return Cfg
end

return QteSkilldisplayCfg
