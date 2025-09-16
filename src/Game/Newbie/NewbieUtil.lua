local NewbieUtil = {}

local ProtoRes = require("Protocol/ProtoRes")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local GuideGlobalCfg = require("TableCfg/GuideGlobalCfg")

local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify

---@type 获取被提出新人频道后能再次加入的冷却时间
---@param TargetIdentify byte @查询目标的身份
---@return Time number  @冷却时间（秒）
function NewbieUtil.GetBeKickOutNewbieChannelCDTime(TargetIdentify)
	local OnlineStatusIdentifyEnum = OnlineStatusUtil.QueryMentorRelatedIdentity(TargetIdentify)
	local TextTimeLimit = nil
	if OnlineStatusIdentifyEnum == OnlineStatusIdentify.OnlineStatusIdentifyMentor then
		TextTimeLimit = GuideGlobalCfg:FindValue(ProtoRes.GuideGlobalParam.GuideBeKickOutCoolingTime, "Value")[1]
	elseif OnlineStatusIdentifyEnum == OnlineStatusIdentify.OnlineStatusIdentifyReturner then
		TextTimeLimit = GuideGlobalCfg:FindValue(ProtoRes.GuideGlobalParam.GuideReturneeBeKickOutCoolingTime, "Value")[1]
	elseif OnlineStatusIdentifyEnum == OnlineStatusIdentify.OnlineStatusIdentifyNewHand then
		TextTimeLimit = GuideGlobalCfg:FindValue(ProtoRes.GuideGlobalParam.GuideNewbieBeKickOutCoolingTime, "Value")[1]
	end
	return tonumber(TextTimeLimit or "0")
end

return NewbieUtil