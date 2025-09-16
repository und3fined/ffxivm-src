-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TeamRecruitFastMsgCfg : CfgBase
local TeamRecruitFastMsgCfg = {
	TableName = "c_team_recruit_fast_msg_cfg",
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
    DefaultValues = {
        ID = 1,
    },
	LuaData = {
        {
        },
        {
            ID = 2,
        },
        {
            ID = 3,
        },
        {
            ID = 4,
        },
        {
            ID = 5,
        },
        {
            ID = 6,
        },
        {
            ID = 7,
        },
        {
            ID = 8,
        },
	},
}

setmetatable(TeamRecruitFastMsgCfg, { __index = CfgBase })

TeamRecruitFastMsgCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function TeamRecruitFastMsgCfg:GetAllText()
	if self.AllText == nil then
		self.AllText = {}
		local All = TeamRecruitFastMsgCfg:FindAllCfg()
		for ID, Cfg in pairs(All) do
			self.AllText[ID] = Cfg.Text
		end
	end

	return self.AllText
end

return TeamRecruitFastMsgCfg
