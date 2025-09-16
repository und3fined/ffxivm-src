-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class QuestChapterCfg : CfgBase
local QuestChapterCfg = {
	TableName = "c_quest_chapter_cfg",
    LruKeyType = "integer",
	KeyName = "id",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'QuestName',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(QuestChapterCfg, { __index = CfgBase })

QuestChapterCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---临时用，避免测试任务配置带来的表现问题
function QuestChapterCfg:FindCfg(SearchConditions)
	local Cfg = CfgBase.FindCfg(self, SearchConditions)
	if Cfg == nil then return nil end

	if Cfg.QuestGenreID == 0 then
		Cfg.QuestType = 2 -- 支线
		Cfg.QuestGenreID = 30102 -- 随便选的支线
	end

	return Cfg
end

return QuestChapterCfg
