-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GoldsauseNpcBahaviorCfg : CfgBase
local GoldsauseNpcBahaviorCfg = {
	TableName = "c_goldsause_npc_bahavior_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GoldsauseNpcBahaviorCfg, { __index = CfgBase })

GoldsauseNpcBahaviorCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

function GoldsauseNpcBahaviorCfg:FindCfgByNpcResID(NpcResID)
	local Cfgs = self:FindAllCfg()
	for _, v in pairs(Cfgs) do
		local Elem = v
		if Elem.RelateNpcResID == NpcResID then
			return Elem
		end
	end
	return
end

function GoldsauseNpcBahaviorCfg:FindCfgByNpcResIDAndState(NpcResID, State)
	local Cfgs = self:FindAllCfg()
	for _, v in pairs(Cfgs) do
		local Elem = v
		if Elem.RelateNpcResID == NpcResID and Elem.State == State then
			return Elem
		end
	end
	return
end

return GoldsauseNpcBahaviorCfg
