-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GameStyleCfg : CfgBase
local GameStyleCfg = {
	TableName = "c_game_style_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {
            {
                Name = 'Desc',
            },
		}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GameStyleCfg, { __index = CfgBase })

GameStyleCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

---获取所有游戏风格信息列表
---@return table
function GameStyleCfg:GetGameStyleList()
	local Ret = self:FindAllCfg()
	return Ret or {}
end

---获取风格信息
---@param ID number @风格ID 
---@return table 
function GameStyleCfg:GetGameStyleCfg( ID )
	local Ret = self:FindCfgByKey(ID)
	return Ret
end

return GameStyleCfg
