local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local Json = require("Core/Json")
local UIViewID =  require("Define/UIViewID")
local ProtoRes = require("Protocol/ProtoRes")
local GuideGlobalCfg = require("TableCfg/GuideGlobalCfg")
local ChatNoviceExamPageVM = require("Game/Chat/VM/ChatNoviceExamPageVM")
local SaveKey = require("Define/SaveKey")
local MajorUtil = require("Utils/MajorUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local MathUtil = require("Utils/MathUtil")
local DynamicCutsceneCfg = require("TableCfg/DynamicCutsceneCfg")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local GlobalCfg = require("TableCfg/GlobalCfg")
local NewbieUtil = require("Game/Newbie/NewbieUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local NewbieInviteSidebarType = SidebarDefine.SidebarType.NewbieInvite
local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify

local LSTR = _G.LSTR
local RoleInfoMgr
local GameNetworkMgr
local EventMgr
local SidebarMgr
local UIViewMgr
local ClientSetupMgr
local OnlineStatusMgr
local USaveMgr

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.GuideOptCmd

--local NewbieInviteShowTime = 30
local SceneCutIDList = {297, 294, 298, 295} --新手入场动画ID
local ObstacleIDList = {2000002, 2000005, 2000006, 2000007} --动态阻挡ID

---@class NewbieMgr : MgrBase
local NewbieMgr = LuaClass(MgrBase)

---OnInit
function NewbieMgr:OnInit()

end

---OnBegin
function NewbieMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
	SidebarMgr = _G.SidebarMgr
	UIViewMgr = _G.UIViewMgr
	ClientSetupMgr = _G.ClientSetupMgr
	OnlineStatusMgr = _G.OnlineStatusMgr
	RoleInfoMgr = _G.RoleInfoMgr
	USaveMgr = _G.UE.USaveMgr

	-- 新人模块缓存数据
	self.Edition = nil
	self.IsNewbie = 0
	self.LastExamineAnswerTime = 0
	self.CurrentServerGuideNum = 0
	self.IsChannelOpen = false 
	self.IsJoinNewbieChannel = false
	self.DayMoveOutTimes = 0
	self.HourMoveOutTimes = 0
	self.BeKickOutJoinNewbieChannelTime = 0
	self.RemovedChannelPlayerInfos = {}
	self.SidebarTimer = nil
	self.RedayInviterInfo = nil
	self.LastInviterInfo = nil

	-- 新手过场动画
	self.IsInitClientSetup = nil	 --是否初始化客户端配置数据
	self.IsAlreadyPlayCutScene = nil --是否播过新手动画,客户端本地标记,避免弱网情况下重复播放

	-- 新手场景固定区域
	self.TargetLeaveArea = nil
	self.LastSafeLocationX = nil
	self.LastSafeLocationY = nil

	--获取后台数据
	--self:NewbieStatusReq()
	--self:SendGetGuiderNumReq()
	--self:ChannelDataReq()
	self:CheckLatestNewbieAssessRecordTime()

    self:InitNewbieSceneID()

	local LastInviterRoleIDStr = USaveMgr.GetString(SaveKey.NewbieLastInviterInfo, "", true)
	self.LastInviterInfo = string.totable(LastInviterRoleIDStr)
end

function NewbieMgr:OnEnd()

end

function NewbieMgr:OnShutdown()

end

function NewbieMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_NewbieStatus, self.NewbieStatusRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_NewbieAttestation, self.NewbieAttestationRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_GuideNum, self.CurrentGuideNumRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_JoinChannel, self.JoinChannelRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_QuitChannel, self.OnNewMsgQuitChannel) -- 退出新人频道
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_RspInviteJoinNewbieChannel, self.RspInviteJoinNewbieChannelRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_MoveOutNewbieChannel, self.OnNewMsgMoveOutNewbieChannel) -- 移出新人频道
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_InviteJoinNewbieChannelNtf, self.InviteJoinNewbieChannelNtf) -- 邀请加入新人频道通知
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_ChannelData, self.ChannelDataRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_GUIDE, SUB_MSG_ID.GuideOptCmd_BeMoveOutNewbieChannelNotice, self.OnNetMsgBeMoveOutNewbieChannelNotice) -- 玩家被踢出新人频道通知
end

function NewbieMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ClientSetupPost, self.ClientSetupPost)
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
end

function NewbieMgr:OnGameEventPWorldMapEnter()
	if not _G.PWorldMgr:CurrIsInDungeon() then
		self:UnRegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
		if self.RedayInviterInfo ~= nil then
			self:OpenNewbieSidebar(self.RedayInviterInfo)
			self.RedayInviterInfo = nil
		end
	end
end

--------   新人状态 相关       ----

-- 请求新人认证
function NewbieMgr:NewbieAttestationReq()
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_NewbieAttestation
	local MsgBody = { Cmd = SUB_MSG_ID.GuideOptCmd_NewbieAttestation }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function NewbieMgr:NewbieAttestationRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.NewbieAttestation then
		return
	end
	MsgTipsUtil.ShowTipsByID(115042)
end

-- 请求新人状态
function NewbieMgr:NewbieStatusReq()
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_NewbieStatus
	local MsgBody = { Cmd = SUB_MSG_ID.GuideOptCmd_NewbieStatus }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function NewbieMgr:NewbieStatusRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.NewbieStatus then
		return
	end

	local NewbieStatus =  MsgBody.NewbieStatus
	self.Edition = NewbieStatus
	self.IsNewbie = NewbieStatus
end

----------  新人频道本地缓存数据查询  相关  ---------

--- 查询新人频道发言考核状态
---@return  true 需要考核  false 不需要考核
function NewbieMgr:QueryNewChannelSpeechAssessment()
	if self.LastExamineAnswerTime == 0 then
		return true
	end
	local CutTime = TimeUtil.GetServerLogicTime()
	local CurrentMonth = tonumber(os.date("%m", CutTime))
	local RecordMonth = tonumber(os.date("%m", self.LastExamineAnswerTime ))
	local CurrentYear = tonumber(os.date("%Y", CutTime))
	local RecordYear = tonumber(os.date("%Y", self.LastExamineAnswerTime ))

	if CurrentMonth ~= RecordMonth or CurrentYear ~= RecordYear then
		return true
	end
	return false
end

--- 聊天新人频道是否开启
---@return boolean 
function NewbieMgr:IsNewbieChannelOpen()
	return self.IsChannelOpen
end

--- 查询 模块缓存指导者数量
function NewbieMgr:GetCurrentServerGuideNum()
	return self.CurrentServerGuideNum
end

--- 查询 是否在新人频道中
---@return  true 在  false 不在
function NewbieMgr:IsInNewbieChannel()
	return self.IsJoinNewbieChannel
end

--- 查询 加入新人频道冷却CD剩余时间
---@return number @剩余时间（秒）
function NewbieMgr:GetJoinNewbieChannelCDTime()
	return math.max(self.BeKickOutJoinNewbieChannelTime - TimeUtil.GetServerTime(), 0)
end

--- 是否可以在新人频道发言
function NewbieMgr:IsCanSpeakInNewbieChannel( )
	return self:IsInNewbieChannel() and not self:QueryNewChannelSpeechAssessment()
end

--- 查询上个邀请者信息
---@param IsClear bool
---@return  nil 无邀请者
function NewbieMgr:QueryLastInviterInfo( IsClear )
	if IsClear then
		self.LastInviterInfo = nil
		USaveMgr.SetString(SaveKey.NewbieLastInviterInfo, _G.TableToString(self.LastInviterInfo), true)
		self.RedayInviterInfo = nil
		EventMgr:SendEvent(EventID.NewBieChannelInviterChange)
	end
	return self.LastInviterInfo
end

--- 设置新人版本数据
function NewbieMgr:SetEdition(Edition)
	self.Edition = Edition
end

--- 设置是否是新人
function NewbieMgr:SetIsNewbie(IsNewbie)
	self.IsNewbie = IsNewbie
end

--- 设置是否加入了新人频道
function NewbieMgr:SetIsJoinNewbieChannel(IsJoinNewbieChannel)
	local IsJoin = IsJoinNewbieChannel
	if self.IsJoinNewbieChannel ~= IsJoin then
		self.IsJoinNewbieChannel = IsJoin

		if not IsJoin then
			_G.ChatMgr:ClearNewbieChannelMsg()
		end
		EventMgr:SendEvent(EventID.ChatIsJoinNewbieChannelChanged)
	end
end

--- 设置新人频道数据
---@param GuideNum number
---@param NewbieChannelOpen bool
function NewbieMgr:SetNewbieChannelData(GuideNum, NewbieChannelOpen)
	local Num = GuideNum
	local IsOpen = NewbieChannelOpen
	local IsChanged = not self:IsInNewbieChannel() and (self.CurrentServerGuideNum ~= Num or self.IsChannelOpen ~= IsOpen)

	self.CurrentServerGuideNum = Num
	self.IsChannelOpen = IsOpen

	if IsChanged then
		EventMgr:SendEvent(EventID.ChatNewbieGuiderNumChanged)
	end
end

--- 设置被踢出后可以再次加入新人频道的时间
function NewbieMgr:SetBeKickOutJoinNewbieChannelTime(BeKickOutJoinNewbieChannelTime)
	self.BeKickOutJoinNewbieChannelTime = BeKickOutJoinNewbieChannelTime or 0
end

--- 设置当天踢出新人频道人数
function NewbieMgr:SetDayMoveOutTimes(DayMoveOutTimes)
	self.DayMoveOutTimes = DayMoveOutTimes or 0
end

--- 设置本小时内踢出新人频道人数
function NewbieMgr:SetHourMoveOutTimes(HourMoveOutTimes)
	self.HourMoveOutTimes = HourMoveOutTimes or 0
end


--------   新人频道 功能相关     ----

-- 开始答题考核
function NewbieMgr:StartNewbieSpeakEvaluation()
	ChatNoviceExamPageVM:StartNewbieSpeakEvaluation()
end

-- 记录考核完成时间
--- @param AnswerTime number @服务器时间（秒）
function NewbieMgr:RecordNewbieChannelEvaluatTime(AnswerTime)
	self.LastExamineAnswerTime = AnswerTime
	local Params = {
		IntParam1 = ProtoCS.ClientSetupKey.NewbieChannel,
		StringParam1 = Json.encode({ AnswerTime = AnswerTime })
	}
	ClientSetupMgr:OnGameEventSet(Params)
end

-- 发起查询最新人答题考核时间
function NewbieMgr:CheckLatestNewbieAssessRecordTime()
	local Params = { IntParam1 = ProtoCS.ClientSetupKey.NewbieChannel, ULongParam1 = MajorUtil.GetMajorRoleID()}
	ClientSetupMgr:OnGameEventQuery(Params)
end

--是否需要新人频道答题考核时间  回复
function NewbieMgr:ClientSetupPost(EventParams)
	if EventParams.IntParam1 == ProtoCS.ClientSetupKey.NewbieChannel then
		local NewbieChannelTable = Json.decode(EventParams.StringParam1)
		self.LastExamineAnswerTime = NewbieChannelTable.AnswerTime
	end
	self.IsInitClientSetup = true
end

--------   新手过场动画      ----

function NewbieMgr:IsNewbiePWorld(PWorldResID)
	return PWorldResID == self.NewbieSceneID
end

function NewbieMgr:InitNewbieSceneID()
	self.NewbieSceneID = 1424030
	local GlobalCfgItem = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GlobalCfgNewbieSceneID)
    if GlobalCfgItem then
        self.NewbieSceneID = GlobalCfgItem.Value[1]
    end
end

function NewbieMgr:GetCutSceneList(...)
	local List = {}
	for _,ID in ipairs({...}) do
		local CfgItem = DynamicCutsceneCfg:FindCfgByKey(ID)
		if CfgItem then
			table.insert(List, CfgItem.SequencePath)
		end
	end
	return List
end

function NewbieMgr:PlayCutScene()
	if _G.DemoMajorType == 0 then
		FLOG_INFO("====LoginMgr role is created, PlayCutScene return")
		return false
	end

	if not self.IsInitClientSetup then --未初始化,无法判断历史是否播放过动画
		return false
	end
	if self.IsAlreadyPlayCutScene then
		return false
	end
	self.IsAlreadyPlayCutScene = true

	local NewbieCutSceneIndex = 1
	local RoleID = MajorUtil.GetMajorRoleID()
    local ValueString = ClientSetupMgr:GetSetupValue(RoleID, ClientSetupID.PlayNewbieCutScene)
	if not string.isnilorempty(ValueString) then
		NewbieCutSceneIndex = tonumber(ValueString)
	end

	if NewbieCutSceneIndex > #SceneCutIDList then
		return false
	end

	local function Callback(Index)
		ClientSetupMgr:SendSetReq(ClientSetupID.PlayNewbieCutScene, tostring(Index))
		if Index > #SceneCutIDList then
			--最后scene cut是同地图，不会收到EnterWorld事件，全部播完开始监听
			self:UnRegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnGameEventAreaTriggerBeginOverlap)
			self:UnRegisterGameEvent(EventID.MajorCollide, self.OnGameEventMajorCollide)
			self:UnRegisterGameEvent(EventID.UpdateQuest, self.OnGameEventUpdateQuest)

			self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnGameEventAreaTriggerBeginOverlap)
			self:RegisterGameEvent(EventID.MajorCollide, self.OnGameEventMajorCollide)
			self:RegisterGameEvent(EventID.UpdateQuest, self.OnGameEventUpdateQuest)
			--开启角色碰撞监听
			local Major = MajorUtil.GetMajor()
			if Major then
				Major:RegisterActorCollideEvent()
				self.IsForbidDialog = false
			end
		end
	end
	_G.TravelLogMgr:PlayNewbieCutScene(SceneCutIDList, NewbieCutSceneIndex, Callback)

	return true
end

function NewbieMgr:SetObstacleVisible(ObstacleID, IsShow)
	local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    local DynObstacle = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_OBSTACLE, ObstacleID)
    if DynObstacle then
		if IsShow then
			DynObstacle:UpdateState(1)
		else
			DynObstacle:UpdateState(0)
		end
    end
end

function NewbieMgr:OnGameEventEnterWorld()
	self:UnRegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnGameEventAreaTriggerBeginOverlap)
	self:UnRegisterGameEvent(EventID.MajorCollide, self.OnGameEventMajorCollide)
	self:UnRegisterGameEvent(EventID.UpdateQuest, self.OnGameEventUpdateQuest)
	local Major = MajorUtil.GetMajor()
	if Major then
		Major:UnRegisterActorCollideEvent()
	end
	--如果是出生地图
	if _G.PWorldMgr:GetCurrPWorldResID() == self.NewbieSceneID then
		if _G.DemoMajorType == 0 then
			FLOG_INFO("====LoginMgr  role is created, SendFinishTarget")
			_G.QuestMgr:SendFinishTarget(140225, 14022501)
			return
		end

		if _G.StoryMgr:SequenceIsPlaying() then
			return
		end
		--避免ClientSutep未初始化的情况,这里再判断一次需不需要播新手场景过场动画
		if self:PlayCutScene() then
			return
		end
		--相关事件监听
		self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnGameEventAreaTriggerBeginOverlap)
		self:RegisterGameEvent(EventID.MajorCollide, self.OnGameEventMajorCollide)
		self:RegisterGameEvent(EventID.UpdateQuest, self.OnGameEventUpdateQuest)

		--开启角色碰撞监听
		if Major then
			Major:RegisterActorCollideEvent()
			self.IsForbidDialog = false
		end
	end
end

function NewbieMgr:OnGameEventMajorCollide(EventParams)
	if self.IsForbidDialog then
		return
	end
	local HitName = EventParams.StringParam1
	local IsTargetObstacle = false
	local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
	for _, ID in ipairs(ObstacleIDList) do
		local DynData = PWorldDynDataMgr:GetDynData(ProtoCommon.MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_OBSTACLE, ID)
		if DynData then
			if DynData.ObstacleActorList then
				for _, ObstacleActor in ipairs(DynData.ObstacleActorList) do
					local Name = ObstacleActor:GetName()
					if Name == HitName then
						IsTargetObstacle = true
						break
					end
				end
				if IsTargetObstacle then
					break
				end
			end
		end
	end
	if not IsTargetObstacle then
		return
	end
	if not _G.NpcDialogMgr:IsDialogPanelVisible() then
		local CallBack = function ()
			self:StartForbidDialog()
		end
		_G.NpcDialogMgr:PlayDialogLib(510007, nil, nil, CallBack, nil, nil, nil, true)
	end
end

function NewbieMgr:OnGameEventUpdateQuest()
	local IsShow = ConditionMgr:CheckConditionByID(10068)
	for _, ID in ipairs(ObstacleIDList) do
		self:SetObstacleVisible(ID, IsShow)
	end
end

function NewbieMgr:StartForbidDialog()
	self.IsForbidDialog = true
	self:RegisterTimer(self.EndForbidDialog, 2)
end

function NewbieMgr:EndForbidDialog()
	self.IsForbidDialog = false
end

function NewbieMgr:OnGameEventAreaTriggerBeginOverlap(EventParam)
	if _G.PWorldMgr:GetCurrPWorldResID() == self.NewbieSceneID then
		if EventParam.AreaID == 2000000 then
			_G.NpcDialogMgr:PlayDialogLib(510000)
		elseif EventParam.AreaID == 2000001 then
			_G.NpcDialogMgr:PlayDialogLib(510001)
		elseif EventParam.AreaID == 2000002 then
			_G.NpcDialogMgr:PlayDialogLib(510002)
		end
	end
end

--- 主角是否为已加入频道的新人、回归者
function NewbieMgr:IsMajorNewcomerOrReturner()  
	return OnlineStatusMgr:MajorHasIdentity(OnlineStatusIdentify.OnlineStatusIdentifyNewHandChat)
	 or OnlineStatusMgr:MajorHasIdentity(OnlineStatusIdentify.OnlineStatusIdentifyReturner)
end

-- 将目标移出新人频道
---@param TargetRoleID uint64
function NewbieMgr:EvictNewbieChannel(TargetRoleID)
	local RoleVM = RoleInfoMgr:FindRoleVM(TargetRoleID, true)
	if nil == RoleVM then
		_G.FLOG_WARNING("NewbieMgr:EvictNewbieChannel Eviction target information is invalid ")
		return
	end
	local TargetIdentify = RoleVM.Identity
	local TargetName = RoleVM.Name
	local OnlineStatusCustomID = RoleVM.OnlineStatusCustomID

	local Params = { }
	Params.RoleID = TargetRoleID
	Params.TargetName = TargetName
	Params.Identity = TargetIdentify
	Params.OnlineStatusCustomID = OnlineStatusCustomID
	UIViewMgr:ShowView(UIViewID.ChatRemoveNewbieChannelWin, Params)
end

--------   新人频道 协议相关       ----

-- 主动邀请别人加入新人频道
---@param TargetRoleID uint64
function NewbieMgr:InviteJoinNewbieChannelReq(TargetRoleID)
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_InviteJoinNewbieChannel
	local MsgBody = {
		Cmd = SUB_MSG_ID.GuideOptCmd_InviteJoinNewbieChannel,
		InviteJoin = { RoleID = TargetRoleID }
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 自己主动加入新人频道
function NewbieMgr:JoinChannelReq()
	local MsgID = CS_CMD.CS_CMD_GUIDE 
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_JoinChannel
	local MsgBody = { Cmd = SUB_MSG_ID.GuideOptCmd_JoinChannel }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--清除新人邀请侧边栏
function NewbieMgr:ClearNewbieSidebar()
	if self.SidebarTimer ~= nil then
		self:UnRegisterTimer(self.SidebarTimer)
		SidebarMgr:RemoveSidebarItem( NewbieInviteSidebarType )
	end
end

--主动开启新人频道侧边栏
function NewbieMgr:OpenNewbieSidebar(InviteJoinName)
	self:ClearNewbieSidebar()
	local Params = {}
	Params.InviteRoleName = InviteJoinName or ""
	SidebarMgr:AddSidebarItem(NewbieInviteSidebarType, TimeUtil.GetServerTime(), 0, Params, true, "", true)
	self.SidebarTimer = self:RegisterTimer( function()
		self:UnRegisterTimer(self.SidebarTimer)
		self.SidebarTimer = nil
		SidebarMgr:RemoveSidebarItem( NewbieInviteSidebarType )
	end, SidebarMgr:GetShowTimeByType(NewbieInviteSidebarType) or 10 )
end

-- 被邀请加入新人频道
function NewbieMgr:InviteJoinNewbieChannelNtf(MsgBody)
	if nil == MsgBody or nil == MsgBody.InviteJoinNtf then
		return
	end

	local InviteJoinNtf = MsgBody.InviteJoinNtf or {}
	if not _G.PWorldMgr:CurrIsInDungeon() then
		self:OpenNewbieSidebar(InviteJoinNtf.Name or "")
	else
		self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
		self.RedayInviterInfo = InviteJoinNtf.Name or ""
	end
	self.LastInviterInfo = { InviteRoleName = InviteJoinNtf.Name, InviteRoleID = InviteJoinNtf.RoleID }
	USaveMgr.SetString(SaveKey.NewbieLastInviterInfo, _G.TableToString(self.LastInviterInfo), true)
	EventMgr:SendEvent(EventID.NewBieChannelInviterChange)
end

function NewbieMgr:OpenChatInvitationWinPanel(Params)
	UIViewMgr:ShowView(UIViewID.ChatInvitationWinPanel, Params)
	SidebarMgr:RemoveSidebarItem( NewbieInviteSidebarType )
end

--	响应被邀请加入新人频道请求
---@param IsJoin bool
function NewbieMgr:RspInviteJoinNewbieChannelReq(IsJoin)
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_RspInviteJoinNewbieChannel
	local MsgBody = {
		Cmd = SUB_MSG_ID.GuideOptCmd_RspInviteJoinNewbieChannel,
		RspInviteJoin = { IsJoin = IsJoin }
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 响应被邀请加入新人频道回复
function NewbieMgr:RspInviteJoinNewbieChannelRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.RspInviteJoin then
		return
	end
	if MsgBody.RspInviteJoin.IsJoin then
		_G.MsgTipsUtil.ShowTips(LSTR(50128)) -- "你已加入新人频道"
		self:SetIsJoinNewbieChannel(true)
		local View = UIViewMgr:FindVisibleView(UIViewID.MainPanel) or {}
    	local MainLBottomPanel = View.MainLBottomPanel
		if MainLBottomPanel ~= nil then
			local ShowTimeText = GuideGlobalCfg:FindValue(ProtoRes.GuideGlobalParam.GuideUnlockNewbieChannelTipsShowTime, "Value")[1]
			local JoinNewBieTipsText = LSTR(50129) -- "解锁了<span color="#bd8213ff">新人频道</>"
			MainLBottomPanel:ShowChatInfoTips(JoinNewBieTipsText, tonumber(ShowTimeText))
		end
	end
end

-- 离开新人频道请求
function NewbieMgr:QuitChannelReq()
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_QuitChannel
	local MsgBody = { Cmd = SUB_MSG_ID.GuideOptCmd_QuitChannel }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 发送移出新人频道请求
---@param RoleID uint64
---@param Info table
---@param Remark string
function NewbieMgr:MoveOutNewbieChannelReq(RoleID, Info, Remark)
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_MoveOutNewbieChannel
	local MsgBody = {
		Cmd = SUB_MSG_ID.GuideOptCmd_MoveOutNewbieChannel,
		MoveOut = { RoleID = RoleID, Remark = Remark }
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

	if RoleID then
		self.RemovedChannelPlayerInfos[RoleID] = Info
	end
end

-- 移目标出新人频道请求回复
function NewbieMgr:OnNewMsgMoveOutNewbieChannel(MsgBody)
	if nil == MsgBody then
		return
	end

	local MoveOut = MsgBody.MoveOut
	if nil == MoveOut then
		return
	end

	local RoleID = MoveOut.RoleID
	if nil == RoleID then
		return
	end

	local PlayerInfo = self.RemovedChannelPlayerInfos[RoleID]
	if PlayerInfo then
		_G.ChatMgr:RemovePlayerFromNewbieChannel(RoleID, PlayerInfo.Identity, PlayerInfo.OnlineStatusCustomID, PlayerInfo.Name, MoveOut.Remark)
		MsgTipsUtil.ShowTipsByID(115048, nil, tostring(PlayerInfo.Name))
		self.RemovedChannelPlayerInfos[RoleID] = nil
	end
end

-- 请求新人频道相关信息
function NewbieMgr:ChannelDataReq()
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_ChannelData
	local MsgBody = {
		Cmd = SUB_MSG_ID.GuideOptCmd_ChannelData
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 新人频道相关记录回复
function NewbieMgr:ChannelDataRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.ChannelData then
		return
	end
	local ChannelData = MsgBody.ChannelData
	self:SetBeKickOutJoinNewbieChannelTime(ChannelData.JoinNewbieChannelTime or 0)
	self:SetIsJoinNewbieChannel(ChannelData.IsJoinNewbieChannel)
	self:SetDayMoveOutTimes(ChannelData.DayMoveOutTimes)
	self:SetHourMoveOutTimes(ChannelData.HourMoveOutTimes)
	self:SetNewbieChannelData(ChannelData.CurGuideNum, self.IsChannelOpen)
end

---玩家被踢出新人频道通知
function NewbieMgr:OnNetMsgBeMoveOutNewbieChannelNotice(MsgBody)
	if nil == MsgBody then 
		return 
	end

	local BeMoveOutNotice = MsgBody.BeMoveOutNotice
	if BeMoveOutNotice then
		local RoleID = BeMoveOutNotice.InitiatorRoleID 
		if nil == RoleID then
			return
		end
		local RoleIdentity = (MajorUtil.GetMajorRoleVM() or {}).Identity
		self:SetBeKickOutJoinNewbieChannelTime(NewbieUtil.GetBeKickOutNewbieChannelCDTime(RoleIdentity) + TimeUtil.GetServerTime())
		self:SetIsJoinNewbieChannel(false)
		RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
			if nil == RoleVM then
				return
			end

			local Content = ""
			local Remark = BeMoveOutNotice.Remark
			if string.isnilorempty(Remark) then
				-- "被<span color="#4d85b4ff">%s</>移出新人频道。"
				Content = string.format(LSTR(50147), RoleVM.Name or "")
			else
				-- "被<span color="#4d85b4ff">%s</>移出新人频道。原因:%s"
				Content = string.format(LSTR(50148), RoleVM.Name or "", BeMoveOutNotice.Remark)
			end

			--- 发送一条玩家被T出新人频道的系统消息
			_G.ChatMgr:AddSysChatMsg(Content)
		end)
	end
end

-- 请求当前服务器中指导者数量
function NewbieMgr:SendGetGuiderNumReq()
	local MsgID = CS_CMD.CS_CMD_GUIDE
	local SubMsgID = SUB_MSG_ID.GuideOptCmd_GuideNum
	local MsgBody = {
		Cmd = SUB_MSG_ID.GuideOptCmd_GuideNum
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 指导者数量回复
function NewbieMgr:CurrentGuideNumRsp(MsgBody)
	if nil == MsgBody then
		return
	end

	local Rsp = MsgBody.GuideNum
	if nil == Rsp then
		return
	end

	self:SetNewbieChannelData(Rsp.GuideNum, Rsp.NewbieChannelOpen)
end

function NewbieMgr:OnNewMsgQuitChannel(MsgBody)
	_G.ChatMgr:ClearNewbieChannelMsg()
	self:SetIsJoinNewbieChannel(false)
    MsgTipsUtil.ShowTips(LSTR(50034)) -- "已经退出新人频道"
end

function NewbieMgr:JoinChannelRsp(MsgBody)
	self:SetIsJoinNewbieChannel(true)
end

-- --------------------------------------------------
-- GM
-- --------------------------------------------------

function NewbieMgr:PlayCutSceneFromGM()
	local RoleID = MajorUtil.GetMajorRoleID()
	ClientSetupMgr:RecordValue(RoleID, {[ClientSetupID.PlayNewbieCutScene]="1"})
	self:PlayCutScene()
end

--要返回当前类
return NewbieMgr