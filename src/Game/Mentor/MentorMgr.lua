local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local RichTextUtil = require("Utils/RichTextUtil")
local LogMgr = require("Log/LogMgr")
local SaveKey = require("Define/SaveKey")
local MentorDefine = require("Game/Mentor/MentorDefine")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local GuideGlobalCfg = require("TableCfg/GuideGlobalCfg")

local MentorMainPanelVM = require("Game/Mentor/MentorMainPanelVM")

local DataReportUtil = require("Utils/DataReportUtil")
local TimeUtil = require("Utils/TimeUtil")
local ReportButtonType = require("Define/ReportButtonType")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.GuideOptCmd
local GuideType = MentorDefine.GuideType
local USaveMgr

local UIViewMgr
local GameNetworkMgr
local LSTR
local FLOG_ERROR
local MsgBoxUtil
local EventMgr

---@class MentorMgr : MgrBase
local MentorMgr = LuaClass(MgrBase)


---OnInit
function MentorMgr:OnInit()

end

function MentorMgr:OnRegisterTimer()

end

---OnBegin
function MentorMgr:OnBegin()
	LSTR = _G.LSTR
	GameNetworkMgr = _G.GameNetworkMgr
	UIViewMgr = _G.UIViewMgr
	FLOG_ERROR = LogMgr.Error
	MsgBoxUtil = _G.MsgBoxUtil
	USaveMgr = _G.UE.USaveMgr
	EventMgr = _G.EventMgr

	local MaxLevelCfg = GuideGlobalCfg:FindCfgByKey(ProtoRes.GuideGlobalParam.GuideAttestationTimeAfterResign) or {}
	self.ResignCD = (MaxLevelCfg.Value or {})[1] or 0
	if MaxLevelCfg.Value == nil then
		LogMgr.Warning("not find Cfginformation on the 'GuideAttestationTimeAfterResign'")
	end
    
	self.GuideTypeList = {}     	--- { {GuideType:Type   bool:NeedUpdate}, ...}
	self.ResignTime = nil
	self.Edition = nil
	self.LoginTime = 0   			-- 指导者后台下发的登录时间戳
	self.GameAllTimeBefore = 0   	-- 本次登录之前，玩家的总游戏时长 单位秒
end

function MentorMgr:OnGameEventRoleLoginRes()
	self:SendGuideStatusReq( SUB_MSG_ID.GuideOptCmd_AllStatus )
end

function MentorMgr:OnEnd()

end

function MentorMgr:OnShutdown()

end

function MentorMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_Condition, self.GuideConditionRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_Status, self.GuideStatusRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_Attestation, self.GuideAttestationRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_Resign, self.GuideResignRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_ConditionUpdateNotice, self.GuideConditionUpdateNoticeRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_IdentifyChangeNotice, self.GuideIdentifyChangeNotice)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_AllStatus, self.AllStatusRsp)
end

function MentorMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)
end

---@param MentorType  MentorDefine.GuideType
function MentorMgr:OpenMentorConditionUI(MentorType)
	if not self:MentorTypeCheck(MentorType) then
		FLOG_ERROR(string.format(" mentor type Error from MentorMgr:OpenMentorConditionUI! Type: %d ", MentorType))
		return
	end
	self:SendMsgMentorConditionReq(MentorType)
end

---@param MentorType  MentorDefine.GuideType
function MentorMgr:OpenMentorAuthenticationUI(MentorType)
	if not self:MentorTypeCheck(MentorType) then
		FLOG_ERROR(string.format(" mentor type Error from MentorMgr:OpenMentorAuthenticationUI! Type: %d ", MentorType))
		return
	end
	UIViewMgr:ShowView(UIViewID.MentorAuthenticationPanel, { ShowType = MentorType })
end

function MentorMgr:OpenResignMentorUI()
	local CloseFun = function()  
		DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.MentorResign), "0")
	end

	local BackToGame = function()  
		if self.HelpInfoMidWinView ~= nil then
			self.HelpInfoMidWinView:Hide() 
			self.HelpInfoMidWinView = nil
			DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.MentorResign), "1")
		end
	end

	local ConfirmFun = function()  
		if self.HelpInfoMidWinView ~= nil then
			self.HelpInfoMidWinView:Hide() 
			self.HelpInfoMidWinView = nil
			self.SendMsgMentorResignReq()
			DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.MentorResign), "2")
		end
	end

	local Title = LSTR(760029)
	local ContentText = LSTR(760023)
	local HintText = RichTextUtil.GetText( string.format(LSTR(760002), self.ResignCD), "d1906d")
	--local Cfgs = {{HelpName = Title, SecTitle = ContentText, SecContent = { { SecContent = HintText } } } }
	local Cfgs = {{ HelpName = Title, SecTitle = ContentText, SecContent = {} }, {SecTitle = "", SecContent = { { SecContent = HintText } }} }
	local Params = { Cfgs = Cfgs, ShowBtn = true, LeftBtnText = LSTR(760030), RightBtnText = LSTR(760031), View = self, RightBtnCB = BackToGame, LeftBtnCB = ConfirmFun, CloseBtnCB = CloseFun, IsMentorResign = true }
	self.HelpInfoMidWinView = UIViewMgr:ShowView(UIViewID.HelpInfoMidWinView, Params)
end

-- 返回指导者所有相关状态
function MentorMgr:AllStatusRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.AllStatus then
		return
	end
	local ReturneeMgr = _G.ReturneeMgr
	local NewbieMgr = _G.NewbieMgr
	local AllStatus = MsgBody.AllStatus
	self.GuideTypeList = AllStatus.GuideStatus
	self.Edition = AllStatus.Edition
	self.ResignTime = AllStatus.GuideResignTime
	self.LoginTime = (AllStatus.LoginTime or 0) == 0 and TimeUtil.GetServerTime() or AllStatus.LoginTime
	self.GameAllTimeBefore = AllStatus.GameAllTimeBefore
	ReturneeMgr:SetEdition(AllStatus.Edition)
	ReturneeMgr:SetIsReturnee(AllStatus.IsReturnee)
	NewbieMgr:SetEdition(AllStatus.Edition)
	NewbieMgr:SetIsNewbie(AllStatus.IsNewbie)
	NewbieMgr:SetIsJoinNewbieChannel(AllStatus.IsJoinNewbieChannel)
	NewbieMgr:SetNewbieChannelData(AllStatus.GuideNum, AllStatus.IsNewbieChannelOpen)
	NewbieMgr:SetDayMoveOutTimes(AllStatus.DayMoveOutTimes)
	NewbieMgr:SetHourMoveOutTimes(AllStatus.HourMoveOutTimes)
	NewbieMgr:SetBeKickOutJoinNewbieChannelTime(AllStatus.BeKickOutJoinNewbieChannelTime)
end

-- 返回指导者状态
function MentorMgr:GuideStatusRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.Status then
		return
	end
	local Status = MsgBody.Status
	self.GuideTypeList = Status.GuideStatus
	self.Edition = Status.Edition
	self.ResignTime = Status.ResignTime
end

-- 返回指导者条件及完成状态
function MentorMgr:GuideConditionRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.Condition then
		return
	end

	local InGuideType = MsgBody.Condition.GuideType
	if not self:MentorTypeCheck(InGuideType) then
		FLOG_ERROR(string.format(" An invalid mentor type was received from MentorMgr:GuideConditionRsp! Type: %d ", InGuideType))
		return
	end

	MentorMainPanelVM:ShowMentorView(InGuideType, MsgBody.Condition.ConditionList)
end

-- 返回指导者认证结果
function MentorMgr:GuideAttestationRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.Attestation or MsgBody.ErrorCode then
		local View = UIViewMgr:FindVisibleView(UIViewID.MentorAuthenticationPanel)
		if View ~= nil then
			View:AuthenticationFeedback(false)
		end
		return
	end

	local InGuideType = MsgBody.Attestation.GuideType
	if not self:MentorTypeCheck(InGuideType) then
		FLOG_ERROR(string.format(" An invalid mentor type was received from MentorMgr:GuideAttestationRsp! Type: %d ", InGuideType))
		return
	end
	-- GuideOptCmd_Status 后台不会即时发送先自己添加
	table.insert(self.GuideTypeList, { Type = InGuideType, NeedUpdate = false })

	local View = UIViewMgr:FindVisibleView(UIViewID.MentorAuthenticationPanel)
	if View ~= nil then
		View:AuthenticationFeedback(true)
	else
		MentorMainPanelVM:OpenMentorUnlockTips(InGuideType)
	end
end

-- 返回 辞去指导者结果
function MentorMgr:GuideResignRsp(MsgBody)
	if nil == MsgBody then
		return
	end
	local Resign = MsgBody.Resign or {}
	self.ResignTime = Resign.ResignTime
	-- 接收到消息就是清空所有指导者成功
	self.GuideTypeList = {}
	_G.MsgTipsUtil.ShowTips(MentorDefine.GuideResignText)
end

--指导者资格更新通知
function MentorMgr:GuideConditionUpdateNoticeRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.ConditionUpdate then
		return
	end

	local CurrntEdition = MsgBody.ConditionUpdate.Edition
	local SaveKeyMentorUpdateEdition = SaveKey.MentorUpdateEdition
	local LocalEdition = USaveMgr.GetInt(SaveKeyMentorUpdateEdition, 0, true)
	if LocalEdition ~= CurrntEdition then
		USaveMgr.SetInt(SaveKey.MentorUpdateNoticeUI, 0, true)
		USaveMgr.SetInt(SaveKeyMentorUpdateEdition, CurrntEdition, true)
	end

	local Open = USaveMgr.GetInt(SaveKey.MentorUpdateNoticeUI, 0, true)
	if (Open or 0) == 0 then
		UIViewMgr:ShowView(UIViewID.MentorUpdateNoticePanel, {})
	end
end

-- 指导者身份变更通知  后台告知暂时只有“消失”通知
function MentorMgr:GuideIdentifyChangeNotice(MsgBody)
	if nil == MsgBody or nil == MsgBody.IdentifyChange then
		return
	end

	local ChangeRet = MsgBody.IdentifyChange.ChangeRet
	local ChangeList = MsgBody.IdentifyChange.GuideTypeList or {}
	local GuideTypeList = self.GuideTypeList or {}
	if ChangeRet == 0 then   --暂时只有消失需求， 后台没有处理增加
		if table.contain(ChangeList, GuideType.GUIDE_TYPE_RED_FLOWER) then
			OnlineStatusUtil.RedflowerMentorDisappear()
		end
		for i = 1, #ChangeList do
			table.remove_item(GuideTypeList, ChangeList[i], "Type")
		end
	end
end

-- 登录请求指导者状态
function MentorMgr:SendGuideStatusReq(SubMsgID)
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SubMsgID
	local MsgBody = { Cmd = SubMsgID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 请求指导者条件
---@param MentorType  MentorDefine.GuideType
function MentorMgr:SendMsgMentorConditionReq(MentorType)
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_Condition
	local MsgBody = {
		Cmd = SUB_MSG_ID.GuideOptCmd_Condition,
		Condition = { GuideType = MentorType },
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 请求指导者认证
---@param MentorType  MentorDefine.GuideType
function MentorMgr:SendMsgMentorConfirmReq(MentorType)
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_Attestation
	local MsgBody = {
		Cmd = SUB_MSG_ID.GuideOptCmd_Attestation,
		Attestation = { GuideType = MentorType },
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 请求辞去指导者
function MentorMgr:SendMsgMentorResignReq()
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_Resign
	local MsgBody = { Cmd = SUB_MSG_ID.GuideOptCmd_Resign }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 此本版不进行指导者更新提醒
function MentorMgr:UnpromptedMentorUpdate()
	USaveMgr.SetInt(SaveKey.MentorUpdateNoticeUI, 1, true)
end

function MentorMgr:MentorTypeCheck(InGuideType)
	if MentorDefine.FinishTabs[InGuideType] ~= nil and InGuideType ~= 0 then
		return true
	end
	return false
end

---验证指定指导者身份
---@param InGuideType MentorDefine.GuideType @传入验证类型枚举
---@return boolean @返回true有此身份 false无此身份
function MentorMgr:VerifyMentorIdentity(InGuideType)
	local GuideTypeList = self.GuideTypeList
	if not GuideTypeList then
		FLOG_ERROR(" MentorMgr GuideTypeList is nil!!! ")
		return false
	end

	for i = 1, #GuideTypeList do
		if GuideTypeList[i].Type == InGuideType then
			return true
		end
	end
	return false
end

---获取游戏总时长文本
function MentorMgr:GetTotalGameDurationText()
	local GameDuration = TimeUtil.GetServerTime() - self.LoginTime + self.GameAllTimeBefore
	GameDuration = GameDuration > 863999999 and 863999999 or GameDuration
	local Min = math.floor((GameDuration % 3600) / 60)
    local Hour = math.floor((GameDuration % 86400) / 3600)
	local Day = math.floor(GameDuration / 86400)
	if Day ~= 0 then
		Day = string.format(LSTR(760042), Day)       						 --%d天
	else
		Day = ""
	end
	if Hour == 0 and Day == "" then
		Hour = ""							 
	else
		Hour = string.format(LSTR(760043), Hour)                       --%02d小时  
	end
	Min = string.format(LSTR(760044), Min)							 --%02d分钟    
	return string.format(LSTR(760041), Day, Hour, Min)      --累计游玩时间为%s%s%s
end

--要返回当前类
return MentorMgr