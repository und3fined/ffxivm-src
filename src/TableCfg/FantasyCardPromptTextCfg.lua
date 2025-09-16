-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FantasyCardPromptTextCfg : CfgBase
local FantasyCardPromptTextCfg = {
	TableName = "c_fantasy_card_prompt_text_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'DisplayText',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FantasyCardPromptTextCfg, { __index = CfgBase })

FantasyCardPromptTextCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

local AllCfgs
function FantasyCardPromptTextCfg:GetAllCfgs()
	if not AllCfgs then
		AllCfgs = self:FindAllCfg()
	end
	return AllCfgs
end


function FantasyCardPromptTextCfg:FindCfgByKeyText(KeyText)
    local AllCfg = self:GetAllCfgs()
    for _, Row in ipairs(AllCfg) do
		if Row.KeyText == KeyText then
			return Row
		end
	end
end

function FantasyCardPromptTextCfg:FindCfgByRule(RuleEnum)
	local AllCfg = self:GetAllCfgs()
    for _, Row in ipairs(AllCfg) do
		if Row.Rule == RuleEnum then
			return Row
		end
	end
end

return FantasyCardPromptTextCfg
