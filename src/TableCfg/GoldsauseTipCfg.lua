-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

---@class GoldsauseTipCfg : CfgBase
local GoldsauseTipCfg = {
	TableName = "c_goldsause_tip_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = nil,
	LuaData = nil,
}

setmetatable(GoldsauseTipCfg, { __index = CfgBase })

GoldsauseTipCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

--- @type 根据活动类型和活动状态来获取Cfg
function GoldsauseTipCfg:FindCfgByActivityTypeAndActivityState(ActivityType, ActivityState)
	local AllCfgs = self:FindAllCfg()
	for _, v in pairs(AllCfgs) do
		local Cfg = v
		if Cfg.ActivityType == ActivityType and Cfg.ActivityState == ActivityState then
			return Cfg
		end
	end
	return
end

return GoldsauseTipCfg
