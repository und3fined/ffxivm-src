-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class DialogueBranchCfg : CfgBase
local DialogueBranchCfg = {
	TableName = "c_dialogue_branch",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ChoiceList',
                Children = {
                    {
                        Name = 'Content',
                    },
				},
            },
            {
                Name = 'DialogQuestion',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(DialogueBranchCfg, { __index = CfgBase })

DialogueBranchCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return DialogueBranchCfg
