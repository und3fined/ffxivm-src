-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class PworldUiInteractiveCfg : CfgBase
local PworldUiInteractiveCfg = {
	TableName = "c_pworld_ui_interactive_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'StrParam',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(PworldUiInteractiveCfg, { __index = CfgBase })

PworldUiInteractiveCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function PworldUiInteractiveCfg:FindAllCfgByUIType(UIType)
	local FindCfg = {}
	local AllCfg = self:FindAllCfg()
	for i = 1, #AllCfg do
		if AllCfg[i].UIType == UIType then
			table.insert(FindCfg, AllCfg[i])
		end
	end
	return FindCfg
end

function PworldUiInteractiveCfg:FindCfgByInteractiveID(InteractiveID)
	local AllCfg = self:FindAllCfg()
	for i = 1, #AllCfg do
		if AllCfg[i].InteractiveID == InteractiveID then
			return AllCfg[i]
		end
	end
	return nil
end

return PworldUiInteractiveCfg
