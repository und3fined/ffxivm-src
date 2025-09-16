-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class QuestCfg : CfgBase
local QuestCfg = {
	TableName = "c_quest_cfg",
    LruKeyType = "integer",
	KeyName = "id",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'TaskDesc',
            },
            {
                Name = 'TargetGroupDesc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(QuestCfg, { __index = CfgBase })

QuestCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local QuestChapterCfg = require("TableCfg/QuestChapterCfg")

function QuestCfg:FindChapterID(QuestID)
	return self:FindValue(QuestID, "ChapterID")
end

function QuestCfg:FindChapterCfgByKey(QuestID)
	local ChapterID = self:FindChapterID(QuestID)
	return QuestChapterCfg:FindCfgByKey(ChapterID)
end

function QuestCfg:FindChapterValue(QuestID, ColumnName)
	local ChapterID = self:FindChapterID(QuestID)
	return QuestChapterCfg:FindValue(ChapterID, ColumnName)
end

return QuestCfg
