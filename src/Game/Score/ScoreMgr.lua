--
-- Author: lydianwang
-- Date: 2021-08-13
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local EquipmentCurrencyVM = require("Game/Equipment/VM/EquipmentCurrencyVM")
local ScoreCfg = require("TableCfg/ScoreCfg")
local ScoreConvertCfg = require("TableCfg/ScoreConvertCfg")
local MarketMgr = require("Game/Market/MarketMgr")
local MajorUtil = require("Utils/MajorUtil")

local CS_CMD = ProtoCS.CS_CMD
local ScoreSubCmd = ProtoCS.CS_SCORE_CMD
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local EventID = _G.EventID

---@class ScoreMgr : MgrBase
local ScoreMgr = LuaClass(MgrBase)


---@field MajorRoleID number
---@field ScoreValueMap luatable
function ScoreMgr:OnInit()
	self.MajorRoleID = nil
    self.ScoreValueMap = {}
    self.ScoreWeekValueMap = {} -- 本周已获取的积分
	self.ScoreConvertMap = {}
	self.IterationConvertInfos = {}     -- 用于保存货币转化协议数据
end

function ScoreMgr:OnBegin()
	self:InitScoreConvertMap()
end

function ScoreMgr:OnEnd()
end

function ScoreMgr:OnShutdown()

end

function ScoreMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_SCORE, ScoreSubCmd.SCORE_SELECT_CMD, self.OnNetMsgScoreSelect)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SCORE, ScoreSubCmd.SCORE_CONVERT_CMD, self.OnNetMsgScoreConvert)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SCORE, ScoreSubCmd.SCORE_UPDATE_CMD, self.OnNetMsgScoreUpdate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SCORE, ScoreSubCmd.SCORE_ITERATION_CONVERT_CMD, self.OnNetMsgScoreIterationConvert)
	-- self:RegisterGameNetMsg(CS_CMD.CS_CMD_SCORE, ScoreSubCmd.SCORE_LIMIT_INFO, self.OnNetMsgGetScoreLimitInfo)
end

function ScoreMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)
	self:RegisterGameEvent(EventID.NetworkReconnected, self.OnGameEventNetworkReconnected)
end

--- 闪断情况重连逻辑
function ScoreMgr:OnGameEventNetworkReconnected(Params)
    if not Params or not Params.bRelay then
        return
    end

	-- 请求全部积分数据
	self:SendSelectScore()
	--- 登陆时请求转化数据
	self:SendScoreIterationConvert()
end

---积分信息初始化
function ScoreMgr:InitScoreConvertMap()
    local ScoreConvertCfgList = ScoreConvertCfg:FindAllCfg("true")
	local ConvertMap = self.ScoreConvertMap
	for _, ConvertCfg in ipairs(ScoreConvertCfgList) do
		local DeductID = ConvertCfg.DeductID
		local TargetID = ConvertCfg.TargetID
		ConvertMap[DeductID] = ConvertMap[DeductID] or {}
		if ConvertMap[DeductID][TargetID] == nil then
			ConvertMap[DeductID][TargetID] = {
				DeductName = ConvertCfg.DeductName,
				DeductNum = ConvertCfg.DeductNum,
				TargetName = ConvertCfg.TargetName,
				TargetNum = ConvertCfg.TargetNum
		}
		end
	end
end

function ScoreMgr:OnGameEventRoleLoginRes(Params)
	self.MajorRoleID = MajorUtil.GetMajorRoleID()

	-- 刷新全部积分数据
	local RoleDetail = MajorUtil.GetMajorRoleDetail()
	if RoleDetail ~= nil then
		self:RefreshScore(RoleDetail.Score.ScoreList)
	end

	--- 登陆时请求转化数据
	self:SendScoreIterationConvert()
end

function ScoreMgr:SendExpUpdateEvent(ScoreData)
	-- 更新UI
	if ScoreData and ScoreData.ProfID then
		local MajorProf = MajorUtil.GetMajorProfID()
		if MajorProf == ScoreData.ProfID then
			local Params = _G.EventMgr:GetEventParams()
			Params.ULongParam3 = self:GetScoreValueByID(SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP)
			Params.ULongParam4 = ScoreData.ProfID
			_G.EventMgr:SendEvent(EventID.MajorExpUpdate, Params)
		else
			local Params = _G.EventMgr:GetEventParams()
			Params.ULongParam3 = ScoreData.Value
			Params.ULongParam4 = ScoreData.ProfID
			_G.EventMgr:SendEvent(EventID.LeveQuestExpUpdate, Params)
		end
	end

end

--------------- 网络：接收消息 ---------------

---收到积分选择消息
---@param MsgBody ScoreRsp
function ScoreMgr:OnNetMsgScoreSelect(MsgBody)
	local ScoreSelectRsp = MsgBody.ScoreSelect
	self:RefreshScore(ScoreSelectRsp.ScoreDatas)
end

---收到积分兑换消息
---@param MsgBody ScoreRsp
function ScoreMgr:OnNetMsgScoreConvert(MsgBody)
	local ScoreConvertRsp = MsgBody.ScoreConvert

	local bIsValidScoreConvert =
		ScoreConvertRsp.DeductIdTotal ~= -1
		and ScoreConvertRsp.TargetIdTotal ~= -1

	if bIsValidScoreConvert then
		self:SetScoreValueByID(ScoreConvertRsp.DeductID, ScoreConvertRsp.DeductIdTotal)
		self:SetScoreValueByID(ScoreConvertRsp.TargetID, ScoreConvertRsp.TargetIdTotal)
	end

	MarketMgr:ShowSysChatObtainScoreMsg(ScoreConvertRsp.TargetID, ScoreConvertRsp.Delta)
	_G.EventMgr:SendEvent(EventID.ScoreUpdate)

end

---收到积分更新消息
---@param MsgBody ScoreRsp
function ScoreMgr:OnNetMsgScoreUpdate(MsgBody)
	local ScoreDatas = MsgBody.ScoreUpdate.ScoreDatas
	for ScoreID, ScoreData in pairs(ScoreDatas) do
		self:GetScorePlayAni(ScoreID, ScoreData.Value)
		self:SetScoreValueByID(ScoreID, ScoreData.Value, ScoreData.WeekValue)

		if ScoreID == SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP then
			self:SendExpUpdateEvent(ScoreData)
		else
			_G.EventMgr:SendEvent(EventID.UpdateScore, ScoreID)
		end
	end

	-- 积分一览
	EquipmentCurrencyVM:UpdateScorePossesNum(self.ScoreValueMap)

	_G.EventMgr:SendEvent(EventID.ScoreUpdate)
end

-- 收到货币转化详情消息
function ScoreMgr:OnNetMsgScoreIterationConvert(MsgBody)
	local Infos = MsgBody.IterationConvert.Infos
	for i = 1, #Infos do
		local InfoItem = {}
		local OldScore = Infos[i].Src
		local NewScore = Infos[i].Dst
        if OldScore ~= nil and NewScore ~= nil then
            InfoItem.SourceID = OldScore.ResID
            InfoItem.SourceValue = OldScore.Value
            InfoItem.DestID = NewScore.ResID
            InfoItem.DestValue = NewScore.Value
            InfoItem.Added = NewScore.Added
            InfoItem.Overed = NewScore.Overed
            table.insert(self.IterationConvertInfos, InfoItem)
        end
	end
end

-- 收到积分周获取量回包消息-已弃用
-- function ScoreMgr:OnNetMsgGetScoreLimitInfo(MsgBody)
-- 	if MsgBody == nil then
-- 		return
-- 	end
-- 	if MsgBody.LimitInfo ~= nil then
-- 		EquipmentCurrencyVM:UpdateScoreWeekUpper(MsgBody.LimitInfo.Limits)
-- 	end
-- end
--------------- 网络：发送请求 ---------------

---向服务器发送积分相关请求
---@param MsgBody luatable
function ScoreMgr:SendNetMsgScore(MsgBody)
	local MsgID = CS_CMD.CS_CMD_SCORE
	local SubMsgID = MsgBody.Cmd
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---发送积分选择请求
---@param ScoreIDList luatable
function ScoreMgr:SendSelectScore(ScoreIDList)
	local MsgBody = {
		Cmd = ScoreSubCmd.SCORE_SELECT_CMD,
		ScoreSelect = {
			RoleID = self.MajorRoleID,
			ScoreIdList = ScoreIDList
		}
	}
	self:SendNetMsgScore(MsgBody)
end

---发送积分兑换请求
---@param DeductID int64
---@param DeductNum int64
---@param TargetID int64
---@param TargetNum int64
function ScoreMgr:SendConvertScore(DeductID, DeductNum, TargetID, TargetNum)
	local MsgBody = {
		Cmd = ScoreSubCmd.SCORE_CONVERT_CMD,
		ScoreConvert = {
			RoleID = self.MajorRoleID,
			DeductID = DeductID,
			DeductNum = DeductNum,
			TargetID = TargetID,
			TargetNum = TargetNum
		}
	}
	self:SendNetMsgScore(MsgBody)
end

---请求货币转化数据
function ScoreMgr:SendScoreIterationConvert(IsDel)
	local MsgBody = {
		Cmd = ScoreSubCmd.SCORE_ITERATION_CONVERT_CMD,
		IterationConvert = {Del = IsDel}
	}
	self:SendNetMsgScore(MsgBody)
end

---请求积分限制获取情况-已弃用
-- function ScoreMgr:SendGetScoreLimitInfo(ScoreIDList)
-- 	local MsgBody = {
-- 		Cmd = ScoreSubCmd.SCORE_LIMIT_INFO,
-- 		ScoreSelect = {
-- 			RoleID = self.MajorRoleID,
-- 			ScoreIdList = ScoreIDList
-- 		}
-- 	}
-- 	self:SendNetMsgScore(MsgBody)
-- end
--------------- 内部接口 ---------------

---@param ScoreDatas map< int32, ScoreData >
function ScoreMgr:RefreshScore(ScoreDatas)
	for ScoreID, ScoreData in pairs(ScoreDatas) do
		self:SetScoreValueByID(ScoreID, ScoreData.Value, ScoreData.WeekValue)
		if ScoreID == SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP then
			self:SendExpUpdateEvent()
		end
	end
	_G.EventMgr:SendEvent(EventID.ScoreUpdate)
	-- 积分一览
	EquipmentCurrencyVM:LoadAllScore()
	EquipmentCurrencyVM:UpdateScorePossesNum(self.ScoreValueMap)
end

---@param ScoreID int32
---@param ScoreValue int64
function ScoreMgr:SetScoreValueByID(ScoreID, ScoreValue, WeekValue)
	if ScoreValue ~= nil then
		self.ScoreValueMap[ScoreID] = ScoreValue
	end

	if WeekValue == 0 then
		self.ScoreWeekValueMap[ScoreID] = nil
	elseif WeekValue ~= nil then
		self.ScoreWeekValueMap[ScoreID] = WeekValue
	end
end

local function IsFloatCondValid(CondType, CondValues)
	local FCT = ProtoRes.FloatCondType
	if (CondType == FCT.None) or (CondValues == nil) or (#CondValues == 0) then
		return false
	elseif (CondType == FCT.BattlePassLv) then
        return (_G.BattlePassMgr:GetBattlePassGrade() == CondValues[1])
	else
		return false
	end
end

local function GetEmptyWeekUpper()
	return {
		Fixed = 0, -- 固定上限 0不设上限
		Float = 0, -- 浮动上限 0没有浮动上限
		CondType = ProtoRes.FloatCondType.None, -- 浮动条件类型
		CondValues = nil, -- 浮动条件值
	}
end

--------------- 外部接口 ---------------

---获取积分列表
---@return table
function ScoreMgr:GetScoreValueList()
	return self.ScoreValueMap
end

---根据积分ID获取或初始化对应积分值
---@param ScoreID int32
---@return number
function ScoreMgr:GetScoreValueByID(ScoreID)
	if ScoreID == nil then
		_G.FLOG_ERROR("ScoreMgr:GetScoreValueByID receive ScoreID=nil")
		return 0
	end
	local ScoreValue = self.ScoreValueMap[ScoreID]
	if ScoreValue == nil then
		self.ScoreValueMap[ScoreID] = 0
		return 0
	end
	return ScoreValue
end

---@param ScoreID int32
---@return number
function ScoreMgr:GetScoreWeekValueByID(ScoreID)
	if ScoreID == nil then
		_G.FLOG_ERROR("ScoreMgr:GetScoreWeekValueByID receive ScoreID=nil")
		return 0
	end
	local WeekValue = self.ScoreWeekValueMap[ScoreID]
	return WeekValue or 0
end

---@param RoleDetail RoleDetail
function ScoreMgr:SetExpByRoleDetail(RoleDetail)
	local ProfID = RoleDetail.Simple.Prof
	local ProfData = RoleDetail.Prof.ProfList[ProfID]
	if ProfData ~= nil then
		self:SetScoreValueByID(SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP, ProfData.Exp)
	else
		_G.FLOG_WARNING("ScoreMgr:SetExpByRoleDetail ProfData is nil for ProfID: %d", ProfID)
	end
end

---@return int64
function ScoreMgr:GetExpScoreValue()
	return self:GetScoreValueByID(SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP)
end

--- 获取玩家当前金币数值
---@return integer
function ScoreMgr:GetGoldScoreValue()
	return self:GetScoreValueByID(SCORE_TYPE.SCORE_TYPE_GOLD_CODE)
end

function ScoreMgr:GetSilverScoreValue()
	return self:GetScoreValueByID(SCORE_TYPE.SCORE_TYPE_SILVER_CODE)
end

function ScoreMgr:GetFormattedSilverScore()
	return ScoreMgr.FormatScore(self:GetSilverScoreValue())
end

---@param DeductID int64
---@param DeductNumTotal int64
---@param TargetID int64
function ScoreMgr:ConvertScoreByID(DeductID, DeductNumTotal, TargetID)
	if self.ScoreConvertMap[DeductID] == nil then return end
	local ScoreConvert = self.ScoreConvertMap[DeductID][TargetID]
	if ScoreConvert == nil then return end

	local Residual = DeductNumTotal % ScoreConvert.DeductNum
	local DeductUnit = DeductNumTotal / ScoreConvert.DeductNum - Residual
	local TargetNumTotal = ScoreConvert.TargetNum * DeductUnit
	self:SendConvertScore(DeductID, DeductNumTotal, TargetID, TargetNumTotal)
end

---@param ScoreID int32
---@return string
function ScoreMgr:GetScoreName(ScoreID)
	local Name = ScoreCfg:FindValue(ScoreID, "Name") or "Nil"
	_G.FLOG_INFO("ScoreMgr: Score %s", Name)
	return Name
end

function ScoreMgr:GetScoreNameText(ScoreID)
	local NameText = ScoreCfg:FindValue(ScoreID, "NameText") or "Nil"
	_G.FLOG_INFO("ScoreMgr: Score %s", NameText)
	return NameText
end

function ScoreMgr:GetScoreMaxValue(ScoreID)
	local MaxValue = ScoreCfg:FindValue(ScoreID, "MaxValue") or 0
	return MaxValue
end

function ScoreMgr:GetScoreWeekUpperValue(ScoreID)
	local ScoreCfgItem = ScoreCfg:FindCfgByKey(ScoreID)
	if not ScoreCfgItem then
		_G.FLOG_WARNING("ScoreMgr:GetScoreWeekUpperValue ScoreCfg %d not found", ScoreID or 0)
		return 0
	end
	local WeekUpper = ScoreCfgItem.WeekUpper or GetEmptyWeekUpper()

	local bUseFloatUpper = IsFloatCondValid(WeekUpper.CondType, WeekUpper.CondValues)
	return bUseFloatUpper and WeekUpper.Float or WeekUpper.Fixed
end

---积分到达上限前，剩余可获取的积分值
function ScoreMgr:GetScoreResidualValue(ScoreID)
	local MaxValue = self:GetScoreMaxValue(ScoreID)
	local Value = self:GetScoreValueByID(ScoreID)
	local MaxResidual = MaxValue - Value
	if (MaxResidual < 0) then
		_G.FLOG_ERROR("ScoreMgr:GetScoreResidualValue found negative max residual, %d, %d/%d", ScoreID, Value, MaxValue)
		return 0
	end

	local WeekUpperValue = self:GetScoreWeekUpperValue(ScoreID)
	if WeekUpperValue == 0 then
		return MaxResidual
	end

	local WeekValue = self:GetScoreWeekValueByID(ScoreID)
	local WeekResidual = WeekUpperValue - WeekValue
	if (WeekResidual < 0) then
		_G.FLOG_ERROR("ScoreMgr:GetScoreResidualValue found negative week residual, %d, %d/%d", ScoreID, WeekValue, WeekUpperValue)
		return 0
	end

	return math.min(MaxResidual, WeekResidual)
end



---@param ScoreID int32
---@return string
function ScoreMgr:GetScoreIconName(ScoreID)
	local IconName = ScoreCfg:FindValue(ScoreID, "IconName")
	if IconName == nil then
		_G.FLOG_WARNING("ScoreMgr: %d IconName = nil", ScoreID or 0)
	end
	return IconName
end

---@param ScoreID int32
---@return string
function ScoreMgr:GetScoreDesc(ScoreID)
	local Desc = ScoreCfg:FindValue(ScoreID, "Desc") or "No score description found"
	_G.FLOG_INFO("ScoreMgr: Score %d: %s", ScoreID, Desc)
	return Desc
end

---格式化积分文本，增加千分位符
---@param Score int
function ScoreMgr.FormatScore(Score)
	local FormattedScore = string.formatint(Score)
	if string.len(FormattedScore) == 1 then
		FormattedScore = " " .. FormattedScore -- 宽度最小为两位数
	end
	return FormattedScore
end

--用于货币栏获得积分时播放动效
function ScoreMgr:GetScorePlayAni(ScoreID, ScoreValue)
	local CurHas = self:GetScoreValueByID(ScoreID)
	if ScoreValue - CurHas > 0 then
		_G.EventMgr:SendEvent(EventID.PlayGetScoreAni, ScoreID)
	end
end

return ScoreMgr
