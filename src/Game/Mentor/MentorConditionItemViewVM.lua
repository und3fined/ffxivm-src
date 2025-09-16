
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GuideDescribeCfg = require("TableCfg/GuideDescribeCfg")
local LogMgr = require("Log/LogMgr")

local LSTR = _G.LSTR
local FLOG_ERROR = LogMgr.Error

---@class MentorConditionItemViewVM : UIViewModel
local MentorConditionItemViewVM = LuaClass(UIViewModel)

---Ctor
function MentorConditionItemViewVM:Ctor()
	self.TextID = nil
	self.TextCondition = ""
	self.ImgConditionTrue = nil
	self.TextProgress = ""
	self.VisibleProgress = false
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
	self.TextProgress = ""
	local TextId = Value.TextId
	if TextId == -1  then
		return
	end
	self.TextID = TextId
	self.ImgConditionTrue = Value.Finish

	local GuideCfg = GuideDescribeCfg:FindCfgByKey(TextId)
	if nil == GuideCfg then
		FLOG_ERROR(string.format("Query GuideDescribeCfg No data is queried! ID： %d", TextId))
		return
	end

	self.TextCondition = GuideCfg.Describe
	self.VisibleProgress = GuideCfg.ShowProgress
	if GuideCfg.ShowProgress == 1 then
		local CounterID = GuideCfg.StatValue[1] or 0
		local TotleProgress = tostring(GuideCfg.StatValue[2] or 0)
		self.TextProgress = tostring(_G.CounterMgr:GetCounterCurrValue(CounterID)) .. '/' .. TotleProgress
	end
end

return MentorConditionItemViewVM