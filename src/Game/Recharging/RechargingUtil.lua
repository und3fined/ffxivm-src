local ScoreMgr = require("Game/Score/ScoreMgr")
local RechargingDefine = require("Game/Recharging/RechargingDefine")

local RechargingUtil = {}

function RechargingUtil.Crystas2PhysicalCurrency(Crystas)
	return Crystas / RechargingDefine.ExchangeRate
end

function RechargingUtil.PhysicalCurrency2Crystas(PhysicalCurrency)
	return PhysicalCurrency * RechargingDefine.ExchangeRate
end

function RechargingUtil.GetBalance()
	return ScoreMgr:GetScoreValueByID(RechargingDefine.CrystaScoreID)
end

return RechargingUtil