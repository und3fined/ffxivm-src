-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class TeamRecruitTypeCfg : CfgBase
local TeamRecruitTypeCfg = {
	TableName = "c_team_recruit_type_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Name',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(TeamRecruitTypeCfg, { __index = CfgBase })

TeamRecruitTypeCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取招募类型信息
---@param ID number @ID 
---@return table
function TeamRecruitTypeCfg:GetRecruitTypeInfo( ID )
	local Ret = self:FindCfgByKey(ID)
	if Ret then
		return Ret
	end
end

return TeamRecruitTypeCfg
