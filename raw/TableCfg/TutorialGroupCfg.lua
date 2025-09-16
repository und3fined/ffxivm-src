-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TutorialGroupCfg : CfgBase
local TutorialGroupCfg = {
	TableName = "c_tutorial_group_cfg",
    LruKeyType = nil,
	KeyName = "GuideGroupID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TutorialGroupCfg, { __index = CfgBase })

TutorialGroupCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function TutorialGroupCfg:GetTutorialCfg()
    return self:FindAllCfg()
end

return TutorialGroupCfg
