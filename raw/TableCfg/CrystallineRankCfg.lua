-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class CrystallineRankCfg : CfgBase
local CrystallineRankCfg = {
	TableName = "c_CrystallineRank_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(CrystallineRankCfg, { __index = CfgBase })

CrystallineRankCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

--- 获取段位展示名
function CrystallineRankCfg:GetRankName(RankID)
    return self:FindValue(RankID, "RankName")
end

--- 获取段位胜利之星
function CrystallineRankCfg:GetRankWinStar(RankID)
    return self:FindValue(RankID, "WinStar")
end

--- 获取段位计算方式
function CrystallineRankCfg:GetRankScoreType(RankID)
    return self:FindValue(RankID, "ResultMode")
end

--- 获取段位类型
function CrystallineRankCfg:GetRankType(RankID)
    return self:FindValue(RankID, "Type")
end

return CrystallineRankCfg
