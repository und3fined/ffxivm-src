
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GuideDescribeCfg = require("TableCfg/GuideDescribeCfg")
local LogMgr = require("Log/LogMgr")
local ItemUtil = require("Utils/ItemUtil")
local RichTextUtil = require("Utils/RichTextUtil")

local FLOG_ERROR = LogMgr.Error

---@class MentorConditionItemViewVM : UIViewModel
local MentorConditionItemViewVM = LuaClass(UIViewModel)

---Ctor
function MentorConditionItemViewVM:Ctor()
	self.TextID = nil
	self.TextCondition = ""
	self.ImgConditionTrue = nil
end

function MentorConditionItemViewVM:OnInit()

end

function MentorConditionItemViewVM:OnBegin()

end

function MentorConditionItemViewVM:IsEqualVM(Value)
	return nil ~= Value and Value.TextID == self.TextID
end

function MentorConditionItemViewVM:OnEnd()

end

function MentorConditionItemViewVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function MentorConditionItemViewVM:UpdateVM(Value, Params)
	local TextId = Value.TextId
	if TextId == -1  then
		return
	end
	self.TextID = TextId
	local bFinish = Value.Finish
	self.ImgConditionTrue = bFinish

	local GuideCfg = GuideDescribeCfg:FindCfgByKey(TextId)
	if nil == GuideCfg then
		FLOG_ERROR(string.format("Query GuideDescribeCfg No data is queried! ID： %d", TextId))
		return
	end

	self.TextCondition = GuideCfg.Describe or ""
	if GuideCfg.ShowProgress == 1 then
		local CurProgress = 0
		local TotleProgress = GuideCfg.StatValue[2] or 0
		local bGoldSauserType = Value.bGoldSauserType
		if not bGoldSauserType then
			local CounterID = GuideCfg.StatValue[1] or 0
			CurProgress = _G.CounterMgr:GetCounterCurrValue(CounterID)
		else
			CurProgress = bFinish and TotleProgress or (Value.Progress or 0)
		end
		local TextProgress = RichTextUtil.GetText(ItemUtil.GetItemNumText(tonumber(CurProgress)), "bd8213") .. 
				'/' .. ItemUtil.GetItemNumText(tonumber(TotleProgress))
		self.TextCondition = self.TextCondition .. " (" .. TextProgress .. ")"
	end
end

return MentorConditionItemViewVM