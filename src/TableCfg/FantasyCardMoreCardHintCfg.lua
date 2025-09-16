-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class FantasyCardMoreCardHintCfg : CfgBase
local FantasyCardMoreCardHintCfg = {
	TableName = "c_fantasy_card_more_card_hint_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Hints',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(FantasyCardMoreCardHintCfg, { __index = CfgBase })

FantasyCardMoreCardHintCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---GetHints
---@return string[]
function FantasyCardMoreCardHintCfg:GetHints()
	local AllHints, Count = self:FindCfgByKey(1), 1
	for _,v in ipairs(self.DBData[1].Hints) do
		if v and v ~= "" then
			AllHints[Count] = v
			Count = Count + 1
		end
	end

	return AllHints
end


return FantasyCardMoreCardHintCfg
