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
---@field ScoreValueList luatable
function ScoreMgr:OnInit()
	self.MajorRoleID = nil
    self.ScoreValueList = {}
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
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SCORE, ScoreSubCmd.SCORE_LIMIT_INFO, self.OnNetMsgGetScoreLimitInfo)
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
	if not Params.bReconnect then   --- 如果是重连就不要重置积分列表了，解决挂机重连后没有积分的问题
		self.ScoreValueList = {}
	end

	-- 请求全部积分数据
	self:SendSelectScore()
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
	local ScoreList = ScoreSelectRsp.ScoreList

	for ScoreID, ScoreValue in pairs(ScoreList) do
		if ScoreValue >= 0 then
			self:SetScoreValueByIDInternal(ScoreID, ScoreValue)
			if ScoreID == SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP then
				self:SendExpUpdateEvent()
			end
		end
	end
	_G.EventMgr:SendEvent(EventID.ScoreUpdate)
	-- 积分一览
	EquipmentCurrencyVM:LoadAllScore()
	EquipmentCurrencyVM:UpdateScorePossesNum(ScoreList)
end

---收到积分兑换消息
---@param MsgBody ScoreRsp
function ScoreMgr:OnNetMsgScoreConvert(MsgBody)
	local ScoreConvertRsp = MsgBody.ScoreConvert

	local bIsValidScoreConvert =
		ScoreConvertRsp.DeductIdTotal ~= -1
		and ScoreConvertRsp.TargetIdTotal ~= -1

	if bIsValidScoreConvert then
		self:SetScoreValueByIDInternal(ScoreConvertRsp.DeductID, ScoreConvertRsp.DeductIdTotal)
		self:SetScoreValueByIDInternal(ScoreConvertRsp.TargetID, ScoreConvertRsp.TargetIdTotal)
	end

	MarketMgr:ShowSysChatObtainScoreMsg(ScoreConvertRsp.TargetID, ScoreConvertRsp.Delta)
	_G.EventMgr:SendEvent(EventID.ScoreUpdate)

end

---收到积分更新消息
---@param MsgBody ScoreRsp
function ScoreMgr:OnNetMsgScoreUpdate(MsgBody)
	local ScoreData = MsgBody.ScoreUpdate.Score
	local ScoreID = ScoreData.ID
	local ScoreValue = ScoreData.Value
	self:GetScorePlayAni(ScoreID, ScoreValue)
	self:SetScoreValueByIDInternal(ScoreID, ScoreValue)

	if ScoreID == SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP then
		self:SendExpUpdateEvent(ScoreData)
	else
		_G.EventMgr:SendEvent(EventID.UpdateScore, ScoreID)
	end
	-- 积分一览
	EquipmentCurrencyVM:UpdateScorePossesNum(self.ScoreValueList)

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

-- 收到积分周获取量回包消息
function ScoreMgr:OnNetMsgGetScoreLimitInfo(MsgBody)
	if MsgBody == nil then
		return
	end
	if MsgBody.LimitInfo ~= nil then
		EquipmentCurrencyVM:UpdateScoreWeekUpper(MsgBody.LimitInfo.Limits)
	end
end
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

---请求积分限制获取情况
function ScoreMgr:SendGetScoreLimitInfo(ScoreIDList)
	local MsgBody = {
		Cmd = ScoreSubCmd.SCORE_LIMIT_INFO,
		ScoreSelect = {
			RoleID = self.MajorRoleID,
			ScoreIdList = ScoreIDList
		}
	}
	self:SendNetMsgScore(MsgBody)
end
--------------- 内部接口 ---------------

---@param ScoreID int64
---@param ScoreValue int64
function ScoreMgr:SetScoreValueByIDInternal(ScoreID, ScoreValue)
	if ScoreValue ~= nil then
		self.ScoreValueList[ScoreID] = ScoreValue
	end
end

--------------- 外部接口 ---------------

---获取积分列表
---@return table
function ScoreMgr:GetScoreValueList()
	return self.ScoreValueList
end

---根据积分ID获取或初始化对应积分值
---@param ScoreID int64
---@return int64 | nil
function ScoreMgr:GetScoreValueByID(ScoreID)
	if ScoreID == nil then
		_G.FLOG_ERROR("ScoreMgr:GetScoreValueByID receive ScoreID=nil")
		return 0
	end
	local ScoreValue = self.ScoreValueList[ScoreID]
	if ScoreValue == nil then
		self.ScoreValueList[ScoreID] = 0
		return 0
	end
	return ScoreValue
end

---@param RoleDetail RoleDetail
function ScoreMgr:SetExpByRoleDetail(RoleDetail)
	local ProfID = RoleDetail.Simple.Prof
	local ProfData = RoleDetail.Prof.ProfList[ProfID]
	if ProfData ~= nil then
		self:SetScoreValueByIDInternal(SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP, ProfData.Exp)
	else
		self:SendSelectScore({SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP})
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

---@param ScoreID int64
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

---未完成
---@param ScoreID int64
function ScoreMgr:GetScoreIconSet(ScoreID)

end

---@param ScoreID int64
---@return string
function ScoreMgr:GetScoreIconName(ScoreID)
	local IconName = ScoreCfg:FindValue(ScoreID, "IconName")
	if IconName == nil then
		_G.FLOG_WARNING("ScoreMgr: %d IconName = nil", ScoreID or 0)
	end
	return IconName
end

---@param ScoreID int64
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
