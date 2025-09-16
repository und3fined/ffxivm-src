-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class NewbieChannelExaminationQuestionCfg : CfgBase
local NewbieChannelExaminationQuestionCfg = {
	TableName = "c_NewbieChannelExaminationQuestion_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'ExamQuestion',
            },
            {
                Name = 'AnswerA',
            },
            {
                Name = 'AnswerB',
            },
            {
                Name = 'CorrectAnswer',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(NewbieChannelExaminationQuestionCfg, { __index = CfgBase })

NewbieChannelExaminationQuestionCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return NewbieChannelExaminationQuestionCfg
