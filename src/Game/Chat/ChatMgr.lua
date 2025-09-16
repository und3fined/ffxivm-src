--
-- Author: anypkvcai
-- Date: 2020-12-23 15:45:49
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ChatVM = require("Game/Chat/ChatVM")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoBuff = require("Network/ProtoBuff")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatSetting = require("Game/Chat/ChatSetting")
local ChatFileIO = require("Game/Chat/ChatFileIO")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local EventMgr = require("Event/EventMgr")
local ChatUtil = require("Game/Chat/ChatUtil")
local ArmyMgr = require("Game/Army/ArmyMgr")
local ItemUtil = require("Utils/ItemUtil")
local MapUtil = require("Game/Map/MapUtil")
local ActorUtil = require("Utils/ActorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local Json = require("Core/Json")
local ChatGifCfg = require("TableCfg/ChatGifCfg")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_CHAT_CMD
local FailReason = ProtoCS.FailReason
local PARAM_TYPE_DEFINE = ProtoCS.PARAM_TYPE_DEFINE
local SPECIAL_SYSTEM_MSG_ID = ProtoCS.SPECIAL_SYSTEM_MSG_ID
local ChatChannel = ChatDefine.ChatChannel
local ChatMacros = ChatDefine.ChatMacros
local ChatMsgType = ChatDefine.ChatMsgType
local SysMsgType = ChatDefine.SysMsgType
local SidebarType = SidebarDefine.SidebarType.PrivateChat
local ServerMsgSortFunc = ChatDefine.ServerMsgSortFunc

local DefaultHistoryMsgNum = 20
local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR
local MaxMsgCountPerTime = 5  -- 每次处理消息上限

local ChatParamsProtoName = "csproto.SimpleHref"

---@class ChatMgr : MgrBase
local ChatMgr = LuaClass(MgrBase)

function ChatMgr:OnInit()
	self:Reset(true)
end

function ChatMgr:OnBegin()
end

function ChatMgr:OnEnd()
end

function ChatMgr:OnShutdown()
	self:Reset()
end

function ChatMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 0.01, 0)
end

function ChatMgr:OnRegisterNetMsg()
	-- 默认丢弃
	self:SetPioneerChannelNetPackDiscardFlag(true)

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_MSG_PUSH, self.OnNetMsgChatMsgPush) -- 发送频道消息
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_MSG_PULL, self.OnNetMsgChatMsgPull) -- 频道消息请求
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_CHANNEL_HAVE_READ, self.OnNetMsgChatChannelHaveRead) -- 获得各个频道的已读序列号
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_SET_CHANNEL_HAVE_READ, self.OnNetMsgSetChannelHaveRead) -- 设置玩家已读序列号

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_MSG_SEQ_NOTIFY, self.OnNetMsgChatMsgSeqNotify) -- 主动通知最新序列号
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_MSG_DETAIL_NOTIFY, self.OnNetMsgChatMsgDetailNotify) -- 主动通知详细消息
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_CHANNEL_UPDATE_NOTIFY, self.OnNetMsgChatChannelUpdateNotify) -- 频道下发通知
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_PRIVATE_CHAT_MSG_NTF, self.OnNetMsgChatPrivateNtf) -- 私聊通知
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_GET_CLIENT_SETUP, self.OnNetMsgGetClientSetup) -- 聊天设置 
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_QUERY_MEMBER, self.OnNetMsgQueryMember) -- 频道成员查询 
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_QUERY_UNLOCK_GIF, self.OnNetMsgQueryUnlockGifs) -- 查询已解锁的Gifs
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_UNLOCK_GIF_NOFITY, self.OnNetMsgUnlockGifsNtf) -- 解锁Gifs通知
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_VANGUARD_INFO, self.OnNetMsgQueryPioneerChannelInfo) -- 查询先锋频道信息
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_VANGUARD_JOIN, self.OnNetMsgJoinPioneer) -- 加入先锋频道
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_VANGUARD_QUIT, self.OnNetMsgQuitPioneer) -- 退出先锋频道
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_VANGUARD_NOTIFY, self.OnNetMsgPioneerChannelMsgNotify) -- 先锋频道消息推送 先锋特殊命令字，包体内容和PULL包相同 

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_DELETE_ROLE_MSG, self.OnNetMsgDeleteRoleMsg) -- 删除玩家公聊类频道消息 
end

function ChatMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnEventClientSetupPost)

    self:RegisterGameEvent(EventID.RoleLoginRes, 			self.OnGameEventLoginRes) 			-- 角色成功登录
    self:RegisterGameEvent(EventID.NetworkReconnected, 		self.OnNetworkReconnected) 			-- 断线重连 
    self:RegisterGameEvent(EventID.PWorldMapEnter, 			self.OnGameEventPWorldMapEnter) 	-- 进入地图
	self:RegisterGameEvent(EventID.PWorldExit, 				self.OnGameEventPWorldExit)			-- 退出副本
	self:RegisterGameEvent(EventID.LinkShellListUpdate, 	self.OnGameEventGroupListUpdate) 	-- 通讯贝列表更新
	self:RegisterGameEvent(EventID.LinkShellRename, 		self.OnGameEventGroupRename) 		-- 通讯贝修改名字
	self:RegisterGameEvent(EventID.LinkShellDestory, 		self.OnGameEventGroupDestory) 		-- 退出/被踢/解散
	self:RegisterGameEvent(EventID.TeamIDUpdate, 			self.OnTeamIDChanged) 				-- 队伍ID更新
	self:RegisterGameEvent(EventID.ArmySelfArmyIDUpdate, 	self.OnGameEventSelfArmyIDUpdate) 	-- 玩家公会ID更新(进入、退出、被踢等)
	self:RegisterGameEvent(EventID.FriendRemoved, 			self.OnGameEventRemoveFriend)		-- 移除好友
	self:RegisterGameEvent(EventID.TeamQueryFinish, 		self.OnGameEventTeamQueryFinish)	-- 队伍数据查询完成 
	self:RegisterGameEvent(EventID.SceneTeamQueryFinish,	self.OnGameEventSceneTeamQueryFinish) -- 场景小队数据查询完成 

	self:RegisterGameEvent(EventID.MapChanged, self.OnEventMapChanged)
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnGameEventSidebarItemTimeOut) --侧边栏Item超时
    self:RegisterGameEvent(EventID.ChatOpenPrivateSidebarChanged, self.OnGameEventOpenPrivateSidebarChanged) -- 私聊侧边栏开关变化
end

function ChatMgr:OnEventClientSetupPost( EventParams )
	if nil == EventParams then
		return
	end

	local IsSetRsp = EventParams.BoolParam1
    if IsSetRsp then
        return
    end

    local SetupKey = EventParams.IntParam1
    if SetupKey == ClientSetupID.ChatReadGifRedDotIDs then  -- 已读的Gif红点ID列表
        local Value = EventParams.StringParam1 or ""
        if not string.isnilorempty(Value) then
            local IDs = Json.safe_decode(Value)
            if IDs and type(IDs) == "table" then
                ChatVM:UpdateGifReadRedDotIDs(IDs)
            end
        end

	elseif SetupKey == ClientSetupID.ChatShownChatSetTips then -- 聊天设置提示
        local Value = tonumber(EventParams.StringParam1)
        ChatVM:UpdateSetTipsRedDot(Value ~= 1)
    end
end

function ChatMgr:OnGameEventLoginRes()
	-- 更新角色登录成功时间
	ChatVM.RoleLoginTime = TimeUtil.GetServerTime()

	-- 查询先锋频道信息
	self:SendQueryPioneerChannelInfo()

	-- 加载私聊会话
	self:LoadPrivateSessions()

    local ModuleID = ProtoCommon.ModuleID
    if not _G.ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDArmy) then -- 部队系统未开启
		self.IsInitArmy = true
		self:TryPullChatHistory()
	end

	self:SendQueryUnlockGifs()
end

function ChatMgr:OnGameEventSidebarItemTimeOut(Type, TransData)
    if Type == SidebarType then 
		SidebarMgr:RemoveSidebarItem(SidebarType)
    end
end

function ChatMgr:OnGameEventOpenPrivateSidebarChanged( )
	if not ChatSetting.IsOpenPrivateSidebar() then
		ChatVM:ClearSidebarItem(true)
	end
end

function ChatMgr:OnNetworkReconnected(Params)
    if nil == Params or Params.bRelay then
        return
    end

	self:TryPullChatHistory(true)
	self:SendQueryPioneerChannelInfo()
end

function ChatMgr:OnGameEventPWorldMapEnter()
	---更新队伍相关聊天数据
	ChatVM:UpdateTeamChatData()
end

function ChatMgr:OnGameEventPWorldExit()
	--清空区域频道相关聊天信息
	ChatVM:ClearChannelAllChatMsg(ChatChannel.Area, nil, false)
end

function ChatMgr:Reset(IsInit)
	if IsInit then
		ChatUtil.IsCheckPrivateChatDir = true 
		ChatSetting.InitSetting()
		ChatVM:TryInitPublicItemVMList() -- 需要依赖聊天设置中的频道排序和隐藏数据

		-- 公频需要的拉取的历史消息数量
		self.HistoryMsgNumNewbie 	= self:GetChannelHistoryMsgCfgNum(ProtoRes.global_cfg_id.GLOBAL_CFG_CHAT_CHANNEL_NEWBIE)
		self.HistoryMsgNumArmy 		= self:GetChannelHistoryMsgCfgNum(ProtoRes.global_cfg_id.GLOBAL_CFG_CHAT_CHANNEL_ARMY)
		self.HistoryMsgNumGroup 	= self:GetChannelHistoryMsgCfgNum(ProtoRes.global_cfg_id.GLOBAL_CFG_CHAT_CHANNEL_GROUP)
	end

	self.IsInitGroup = false -- 是否已初始化通讯贝模块数据
	self.IsInitArmy = false -- 公会
	self.IsInitTeam = false
	self.IsInitSceneTeam = false
	self.IsPullChatHistory = false

	self.IsCleanedPublicOfflineRedDot = false 

	self.MsgSortID = 0
	self.IsPrivateChatLoaded = false
	self.IsSavePrivateChatMsg = false
	self.WaitSavePrivateChannelIDs = {}

	self.IsPrivateSessionsLoaded = false
	self.IsSavePrivateSessions = false

    self.MsgBuffer = {} 		-- 消息队列
	self.IsRecording = false 	-- 是否正在录制语音
end

function ChatMgr:OnTimer( )
	-- 私聊
	if self.IsPrivateChatLoaded and self.IsSavePrivateChatMsg then
		self.IsSavePrivateChatMsg = false
		self:SavePrivateChatLogs()
	end

	-- 私聊会话
	if self.IsPrivateSessionsLoaded and self.IsSavePrivateSessions then
		self.IsSavePrivateSessions = false
		self:SavePrivateSessions()
	end

	-- 处理消息队列
	if #self.MsgBuffer > 0 then
		self:ProcessMsgsInternal()
	end
end

function ChatMgr:ProcessMsgsInternal()
    -- 批量提取
    local Batch = {}
	local Buffer = self.MsgBuffer

    for i = 1, MaxMsgCountPerTime do
        if #Buffer == 0 then 
			break 
		end

        table.insert(Batch, table.remove(Buffer, 1))
    end

    -- 提交消息
    if #Batch > 0 then
        -- 连续分组
        local Groups = self:GroupConsecutiveInternal(Batch)
        
        -- 提交
        for _, v in ipairs(Groups) do
            ChatVM:AddChatMsgList(v.Channel, v.ChannelID, v.MsgList)
        end
    end
end

--- 根据Channel、ChannelID进行连续分组
function ChatMgr:GroupConsecutiveInternal(Batch)
    local Ret = {}
    if #Batch == 0 then 
		return Ret 
	end

    -- 初始化第一个组
    local CurGroup = {
        Channel = Batch[1].Channel,
        ChannelID = Batch[1].ChannelID,
        MsgList = {Batch[1].Msg}
    }

    for i = 2, #Batch do
        local Data = Batch[i]
		local Channel = Data.Channel
		local ChannelID = Data.ChannelID
		local Msg = Data.Msg

        -- 判断是否连续相同
        if Channel == CurGroup.Channel and (nil == ChannelID or ChannelID == CurGroup.ChannelID) then
            table.insert(CurGroup.MsgList, Msg)

        else
            table.insert(Ret, CurGroup)

            CurGroup = {
                Channel = Channel,
                ChannelID = ChannelID,
                MsgList = {Msg}
            }
        end
    end

    table.insert(Ret, CurGroup) -- 添加最后一个组

    return Ret
end

--- 添加聊天消息到消息队列
function ChatMgr:AddMsgListToBuffer(Channel, ChannelID, MsgList)
    local Buffer = self.MsgBuffer
	if nil == Buffer then
		FLOG_ERROR("ChatMgr:AddMsgListToBuffer, MsgBuffer is nil")
		return
	end

	if table.is_nil_empty(MsgList) then
		FLOG_WARNING("ChatMgr:AddMsgListToBuffer, MsgList is nil or empty")
		return
	end

	for _, v in ipairs(MsgList) do
        table.insert(Buffer, {
            Channel = Channel,
            ChannelID = ChannelID,
            Msg = v
        })
    end
end

function ChatMgr:AddMsgToBuffer(Channel, ChannelID, Msg)
    local Buffer = self.MsgBuffer
	if nil == Buffer then
		FLOG_ERROR("ChatMgr:AddMsgToBuffer, MsgBuffer is nil")
		return
	end

	if table.is_nil_empty(Msg) then
		FLOG_WARNING("ChatMgr:AddMsgToBuffer, Msg is nil or empty")
		return
	end

	table.insert(Buffer, {
		Channel = Channel,
		ChannelID = ChannelID,
		Msg = Msg 
	})
end

--- 设置先锋频道网络包丢弃标志
function ChatMgr:SetPioneerChannelNetPackDiscardFlag(bDiscard)
	GameNetworkMgr:SetMsgToDiscard(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_VANGUARD_NOTIFY, bDiscard)
end

function ChatMgr:CheckAndSaveUnreadPrivateChatMsg()
	for _, v in ipairs(ChatVM.ChannelVMList) do
		if v:GetChannel() == ChatChannel.Person then
			local NewMsgNum = v.NewMsgNum
			if NewMsgNum and NewMsgNum > 0 then
				self:ActivateSavePrivateChatMsgMark(v:GetChannelID())
			end
		end
	end
end

function ChatMgr:ActivateSavePrivateChatMsgMark(ChannelID)
	if nil == ChannelID or table.contain(self.WaitSavePrivateChannelIDs, ChannelID) then
		return
	end

	table.insert(self.WaitSavePrivateChannelIDs, ChannelID)

	self.IsSavePrivateChatMsg = true
end

function ChatMgr:DeletePrivateChatMsgFile(ChannelIDs)
	for _, v in ipairs(ChannelIDs) do
		ChatFileIO.DeletePrivateChat(v)
	end
end

function ChatMgr:ActivateSavePrivateSessionsMark( )
	self.IsSavePrivateSessions = true
end

function ChatMgr:GetChannelHistoryMsgCfgNum(Key)
	local Data = GlobalCfg:FindValue(Key, "Value")
	if nil == Data then 
		return DefaultHistoryMsgNum
	end

	return tonumber(Data[1]) or DefaultHistoryMsgNum
end

function ChatMgr:OnGameEventGroupListUpdate()
	ChatVM:UpdateGroupChannelItems()

	self.IsInitGroup = true
	self:TryPullChatHistory()

	if ChatVM.IsChatMainPanelVisible then
		ChatVM:UpdateCompSpeakChannelList()
	end
end

function ChatMgr:OnGameEventGroupRename(LinkShellID)
	ChatVM:UpdateGroupChannelName(LinkShellID)
end

function ChatMgr:OnGameEventGroupDestory(LinkShellID)
	-- 移除综合频道屏蔽通讯贝数据中玩家不在的通讯贝
	ChatSetting.RemoveComprehensiveChannelBlockGroupIDs(LinkShellID)
end

function ChatMgr:OnGameEventSelfArmyIDUpdate()
	local ChannelArmy = ChatChannel.Army
	if not ArmyMgr:IsInArmy() then -- 离开公会
		local ChannelVM = ChatVM:FindChannelVM(ChannelArmy)
		if ChannelVM then
			ChannelVM:ClearMsg()
		end
	end

	if ChatVM.CurChannel == ChannelArmy then
		ChatVM:ClearNewMsgTips()
		ChatVM:UpdateChatBarVisible()
		ChatVM:UpdateGoTo()
	end

	self.IsInitArmy = true
	self:TryPullChatHistory()

	if ChatVM.IsChatMainPanelVisible then
		ChatVM:UpdateCompSpeakChannelList()
	end
end

function ChatMgr:OnGameEventRemoveFriend(RoleIDs)
	if nil == RoleIDs then
		return
	end

	for _, v in ipairs(RoleIDs) do
		self:UpdatePrivateChatSession(v, false)
	end
end

function ChatMgr:OnGameEventTeamQueryFinish()
	self.IsInitTeam = true 
	self:TryPullChatHistory()
end

function ChatMgr:OnGameEventSceneTeamQueryFinish()
	self.IsInitSceneTeam = true 
	self:TryPullChatHistory()
end

function ChatMgr:OnEventMapChanged()
	local MapName = MapUtil.GetMapFullName()  
	if string.isnilorempty(MapName) then
		return
	end

	-- "- 已进入%s -"
	local Content = string.format(LSTR(50097), MapName)
	self:AddAreaChatMsg(Content, ChatMsgType.TextTipsCenter, nil, false)
end

function ChatMgr:OnNetMsgChatMsgPush(MsgBody)
	local Rsp = MsgBody.Push
	if nil == Rsp then
		return
	end

	_G.EventMgr:SendEvent(_G.EventID.ChatMsgPushed, table.clone(Rsp))

	local ChannelInfo = Rsp.Channel or {}
	local Channel = ChannelInfo.Type
	local ChannelID = ChannelInfo.ChannelID

	local Fail = Rsp.Fail 
	if nil == Fail then
		-- 添加未读私聊
		if Channel == ChatChannel.Person then
			ChatVM:AddPrivateChatUnreadMsg(ChannelID, { Rsp.Msg.ID })
		end

		-- 添加消息
		self:AddMsgToBuffer(Channel, ChannelID, Rsp.Msg)
		ChatVM:TryAddHistoryInfo(Rsp.Msg)
		return
	end

	-- 发送消息失败
	local Reason = Fail.Reason
	if Reason == FailReason.ReasonBlockStranger then -- 对方开启了免打扰模式(非好友不接受私聊)
		if Channel == ChatChannel.Person then
			-- "- 消息未送达，该玩家只接受好友私聊 -"
	 		self:AddMsgInternal(Channel, ChannelID, LSTR(50031), nil, ChatMsgType.TextTipsCenter, ChannelID, false)
		end

	elseif Reason == FailReason.ReasonBan then -- 玩家被封禁发言
		local BanInfo = Fail.Ban
		if BanInfo then
			local StrTime = _G.LocalizationUtil.LocalizeStringDate_Timestamp_YMDHMS(BanInfo.BanTime or 0)
			local Fmt = LSTR(50155) -- "%s，解封时间：%s"
			_G.MsgTipsUtil.ShowErrorTips(string.format(Fmt, BanInfo.BanReason or "", StrTime), 2)

		else
			FLOG_WARNING("ChatMgr:OnNetMsgChatMsgPush, Rsp.Ban is nil")
		end
	end
end

function ChatMgr:OnNetMsgChatMsgPull(MsgBody)
	local Msg = MsgBody.Pull
	if nil == Msg then
		return
	end

	local RoleIDList = {}

	local MsgList = Msg.MsgList
	for _, v in ipairs(MsgList) do
		for _, ChatMsg in ipairs(v.Msg) do
			table.insert(RoleIDList, ChatMsg.Sender)
		end
	end

	local Callback = function(Params)
		local ParamsMsgList = Params.MsgList

		for _, v in ipairs(ParamsMsgList) do
			local ChatMsgList = v.Msg
			if not table.is_nil_empty(ChatMsgList) then
				table.sort(ChatMsgList, ServerMsgSortFunc)

				self:AddMsgListToBuffer(v.Channel.Type, v.Channel.ChannelID, ChatMsgList)
			end
		end
	end

	RoleInfoMgr:QueryRoleSimples(RoleIDList, Callback, Msg)
end

function ChatMgr:OnNetMsgChatChannelHaveRead(MsgBody)
	local Msg = MsgBody.Read
	if nil == Msg then
		return
	end

	local MaxAckInfoMap = {}
	local ReadList = Msg.ReadList

	for _, v in ipairs(ReadList) do
		local Channel = v.Channel.Type
		if Channel ~= ChatChannel.Person then -- 私聊的当前ID设置方法，详见ChatVM.AddChatMsgInternal函数
			local ChannelID = v.Channel.ChannelID
			local ChannelVM = ChatVM:FindChannelVM(Channel, ChannelID)
			if ChannelVM ~= nil then
				if v.Ack > ChannelVM:GetCurrentMsgID() then
					ChannelVM:SetCurrentMsgID(v.Ack)
				end
			end

			if Channel ~= nil and ChannelID ~= nil then
				if nil == MaxAckInfoMap[Channel] then
					MaxAckInfoMap[Channel] = {}
				end

				MaxAckInfoMap[Channel][ChannelID] = v.MaxAck
			end
		end
	end

	local PullList = {}

	for _, v in ipairs(ChatVM.ChannelVMList) do
		local Channel = v:GetChannel()
		if v:IsNeedPull() then --- 私聊的拉取，通过 CS_CHAT_CMD_PRIVATE_CHAT_MSG_NTF 回包获取到ChannelID后拉取
			local BeginMsgID = 0
			local ChannelID = v:GetChannelID()
			local ChannelInfo = { Type = Channel, ChannelID = ChannelID }
			if ChannelID ~= nil and MaxAckInfoMap[Channel] ~= nil then
				local MaxAck = MaxAckInfoMap[Channel][ChannelID]
				if  MaxAck ~= nil then
					-- 需要拉取的最大数量
					local Num = self:GetHistoryMsgNum(Channel)
					if Num ~= nil then
						BeginMsgID = math.max(MaxAck - Num + 1, 0)
					end
				end
			end

			table.insert(PullList, { Channel = ChannelInfo, BeginMsgID = BeginMsgID, EndMsgID = -1 })
		end
	end

	self:SendChatMsgPullMessage(PullList)
end

function ChatMgr:OnNetMsgSetChannelHaveRead(MsgBody)
	local Msg = MsgBody.SetAck
	if nil == Msg or nil == Msg.SetSeqOk then
		return
	end

	for _, v in ipairs(Msg.SetSeqOk) do
		local Channel = v.Channel
		if Channel ~= nil and Channel.Type == ChatChannel.Person then 
			ChatVM:DelPrivateChatUnreadMsg(Channel.ChannelID, v.Ack)
		end
	end
end

---激活角色聊天频道 
function ChatMgr:SendActiveRoleChannels(ChannelInfos)
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_ACTIVE_ROLE

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.ActiveRole = { Channels = ChannelInfos }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 设置玩家已读信息 
function ChatMgr:SendSetChatChannelHaveRead(ReadSeqList)
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_SET_CHANNEL_HAVE_READ

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.SetAck = { SetSeq = ReadSeqList }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 设置玩家-拒收非好友消息
function ChatMgr:SendSetBlockStranger(IsBlock)
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_UPDATE_CLIENT_SETUP

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.UpdateSetup = { Setup = { BlockStranger = IsBlock == true } }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 获取玩家设置-拒收非好友消息状态
function ChatMgr:SendGetBlockStranger()
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_GET_CLIENT_SETUP

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 获取新人频道参与者玩家
function ChatMgr:SendQueryNewbieMembers()
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_QUERY_MEMBER

	local Channel = ChatChannel.Newbie
	local ChannelVM = ChatVM:FindChannelVM(Channel)
	if nil == ChannelVM then
		return
	end

	ChatVM.IsQueryingNewbieMember = true 

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.QueryMemeber = { 
		Channel = {
			Type = Channel,
			ChannelID = ChannelVM:GetChannelID() 
		}, 
		Count = 50 
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询已解锁的Gifs
function ChatMgr:SendQueryUnlockGifs()
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_QUERY_UNLOCK_GIF

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询先锋频道信息
function ChatMgr:SendQueryPioneerChannelInfo()
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_VANGUARD_INFO

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.VanGuardInfo = {
		Channel = {
			Type = ChatChannel.Pioneer,
			ChannelID = self:GetPioneerChannelID()
		}, 
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 加入先锋频道
function ChatMgr:SendJoinPioneerChannel()
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_VANGUARD_JOIN

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.VanGuardJoin = {
		Channel = {
			Type = ChatChannel.Pioneer,
			ChannelID = self:GetPioneerChannelID()
		}, 
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 退出先锋频道
function ChatMgr:SendQuitPioneerChannel()
	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_VANGUARD_QUIT

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.VanGuardQuit = {
		Channel = {
			Type = ChatChannel.Pioneer,
			ChannelID = self:GetPioneerChannelID()
		}, 
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ChatMgr:OnNetMsgChatMsgSeqNotify(MsgBody)
	local Msg = MsgBody.Seq
	if nil == Msg then
		return
	end

	local NotifyList = Msg.NotifyList
	local PullList = {}

	for _, v in ipairs(NotifyList) do
		local ChannelInfo = v.Channel or {}
		local ChannelVM = ChatVM:FindChannelVM(ChannelInfo.Type, ChannelInfo.ChannelID)
		if nil ~= ChannelVM then
			if v.Ack > ChannelVM:GetCurrentMsgID() then
				local PullData = { Channel = v.Channel, BeginMsgID = v.Ack, EndMsgID = -1 }
				table.insert(PullList, PullData)
			end
		end
	end

	if #PullList > 0 then
		self:SendChatMsgPullMessage(PullList)
	end
end

function ChatMgr:OnNetMsgChatMsgDetailNotify(MsgBody)
	local Msg = MsgBody.Detail
	if nil == Msg then
		return
	end

	local Callback = function(Params)
		local Channel = Params.Channel.Type
		local ChannelID = Params.Channel.ChannelID
		if Channel == ChatChannel.Person then
			ChatVM:AddPrivateChatUnreadMsg(ChannelID, { Params.Detail.ID })
		end

		self:AddMsgToBuffer(Channel, ChannelID, Params.Detail)
	end

	local Sender = Msg.Detail.Sender
	if MajorUtil.IsMajorByRoleID(Sender) then
		Callback(Msg)
	else
		RoleInfoMgr:QueryRoleSimple(Sender, Callback, Msg)
	end
end

function ChatMgr:OnNetMsgChatChannelUpdateNotify(MsgBody)
	local Msg = MsgBody.Update
	if nil == Msg then
		return
	end

	local ChannelVM = ChatVM:FindChannelVM(Msg.Channel.Type)
	if ChannelVM ~= nil then
		ChannelVM:SetCurrentMsgID(0)
	end
end

function ChatMgr:OnNetMsgChatPrivateNtf(MsgBody)
	if nil == MsgBody.PrivateChat or nil == MsgBody.PrivateChat.Msgs then
		return
	end

	local PullList = {}
	local Data = MsgBody.PrivateChat.Msgs

	for _, v in ipairs(Data) do
		local ChannelID = v.RoleID
		local Channel = ChatChannel.Person

		-- 未读消息
		local ChannelVM = ChatVM:FindChannelVM(Channel, ChannelID, true)
		if ChannelVM ~= nil then
			for _, msgId in ipairs(v.MessageID) do
				if msgId > ChannelVM:GetCurrentMsgID() then
					table.insert(PullList, { Channel = { Type = Channel, ChannelID = ChannelID }, BeginMsgID = msgId, EndMsgID = -1 })
					break
				end
			end

			ChatVM:AddPrivateChatUnreadMsg(ChannelID, v.MessageID)
		end
	end

	-- 拉取私聊未读信息
	if #PullList > 0 then
		self:SendChatMsgPullMessage(PullList)
	end

	-- 加载本地私聊
	self:LoadPrivateChatLogs()
end

---封禁玩家消息
function ChatMgr:OnNetMsgDeleteRoleMsg(MsgBody)
	if nil == MsgBody then 
		return 
	end

	local Rsp = MsgBody.DeleteRoleMsgRsp
	if Rsp then 
		-- 删除玩家公共频道消息
		ChatVM:DeleteRolePublicChannelMsg(Rsp.DeleteRole)
	end
end

---聊天设置
function ChatMgr:OnNetMsgGetClientSetup(MsgBody)
	if nil == MsgBody then 
		return 
	end

	local Setup = (MsgBody.GetSetup or {}).Setup
	if Setup then 
		EventMgr:SendEvent(EventID.ChatGetIsBlockStranger, Setup.BlockStranger)
	end
end

---频道成员查询
function ChatMgr:OnNetMsgQueryMember(MsgBody)
	if nil == MsgBody then 
		return 
	end

    local ErrorCode = MsgBody.ErrorCode
	if ErrorCode and ErrorCode > 0 then
		ChatVM.IsQueryingNewbieMember = false 
		return
	end

	local QueryMsg = MsgBody.QueryMember 
	if nil == QueryMsg then
		return
	end

	-- 新人频道
	if QueryMsg.Channel.Type == ChatChannel.Newbie then
		ChatVM:UpdateNewbieMemberVMList((MsgBody.QueryMember or {}).RoleIDs)
	end
end

--- 已解锁Gifs查询
function ChatMgr:OnNetMsgQueryUnlockGifs(MsgBody)
	if nil == MsgBody then 
		return 
	end

	local QueryUnlockGif = MsgBody.QueryUnlockGif
	if nil == QueryUnlockGif then
		return
	end

	ChatVM:UpdateUnlockGifs(QueryUnlockGif.GifIDs)
end

--- 通知解锁Gifs
function ChatMgr:OnNetMsgUnlockGifsNtf(MsgBody)
	if nil == MsgBody then 
		return 
	end

	local UnlockGif = MsgBody.UnlockGif
	if nil == UnlockGif then
		return
	end

	ChatVM:UpdateUnlockGifs(UnlockGif.GifIDs)
end

--- 查询先锋频道信息
function ChatMgr:OnNetMsgQueryPioneerChannelInfo(MsgBody)
	if nil == MsgBody then 
		return 
	end

	local VanGuardInfo = MsgBody.VanGuardInfo
	if nil == VanGuardInfo or nil == VanGuardInfo.Channel then
		return
	end	

	local Channel = VanGuardInfo.Channel
	if Channel.Type == ChatChannel.Pioneer and Channel.ChannelID == self:GetPioneerChannelID() then
		ChatVM:UpdatePioneerChannelInfo(VanGuardInfo.InChannel, VanGuardInfo.CloseTime)
	end
end

--- 加入先锋频道
function ChatMgr:OnNetMsgJoinPioneer(MsgBody)
	if nil == MsgBody then 
		return 
	end

	local VanGuardJoin = MsgBody.VanGuardJoin
	if nil == VanGuardJoin or nil == VanGuardJoin.Channel then
		return
	end	

	local Channel = VanGuardJoin.Channel
	if Channel.Type == ChatChannel.Pioneer and Channel.ChannelID == self:GetPioneerChannelID() then
		ChatVM:UpdatePioneerChannelInfo(true, ChatVM.PioneerChannelCloseTime)
	end
end

--- 退出先锋频道
function ChatMgr:OnNetMsgQuitPioneer(MsgBody)
	if nil == MsgBody then 
		return 
	end

	local VanGuardQuit = MsgBody.VanGuardQuit
	if nil == VanGuardQuit or nil == VanGuardQuit.Channel then
		return
	end	

	local Channel = VanGuardQuit.Channel
	if Channel.Type == ChatChannel.Pioneer and Channel.ChannelID == self:GetPioneerChannelID() then
		-- 50167("已退出先锋频道")
		MsgTipsUtil.ShowTips(LSTR(50167))

		-- 清除先锋频道老数据
		ChatVM:ClearChannelAllChatMsg(ChatChannel.Pioneer, nil, false)
		ChatVM:UpdatePioneerChannelInfo(false, ChatVM.PioneerChannelCloseTime)
	end
end

--- 先锋频道消息推送 先锋特殊命令字，包体内容和PULL包相同
function ChatMgr:OnNetMsgPioneerChannelMsgNotify(MsgBody)
	self:OnNetMsgChatMsgPull(MsgBody)
end

function ChatMgr:GetPioneerChannelID()
	return _G.LoginMgr.WorldID
end

---SendChatMsgPushMessage
---@param ChannelType number @CHANNEL_TYPE_DEFINE
---@param ChannelID number
---@param Content string
---@param Facade number
---@param ParamList table @超链内容
---@param NotAddExtend boolean @是否不添加扩展内容
function ChatMgr:SendChatMsgPushMessage(ChannelType, ChannelID, Content, Facade, ParamList, NotAddExtend)
	if nil == ChannelType or nil == ChannelID then
		return
	end

	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_MSG_PUSH

	local Channel = { Type = ChannelType, ChannelID = ChannelID }
	local Msg = { 
		Content 	= Content, 
		Facade 		= Facade, 
		ParamList 	= ParamList,
		Extend		=  not NotAddExtend and ChatUtil.GetMsgExtend(ChannelType) or nil
	}

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Push = { Channel = Channel, Msg = Msg }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

	-- 可能有任务需要检查聊天内容
	EventMgr:SendEvent(EventID.OnSendChat, ChannelType, Content)
end

---SendChatMsgPullMessage
---@param PullList table @csproto.PullMessage
function ChatMgr:SendChatMsgPullMessage(PullList)
	if nil == PullList or #PullList <= 0 then
		return
	end

	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_MSG_PULL

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Pull = { PullList = PullList }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---SendChatMsgGetChannelRead
---@param ChannelList table @csproto.ChatChannel列表
function ChatMgr:SendChatMsgGetChannelRead(ChannelList)
	if nil == ChannelList or #ChannelList <= 0 then
		return
	end

	local MsgID = CS_CMD.CS_CMD_CHATC
	local SubMsgID = SUB_MSG_ID.CS_CHAT_CMD_CHANNEL_HAVE_READ

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Read = { ChannelList = ChannelList }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ChatMgr:TryPullChatHistory(bForcePull)
	if not bForcePull then
		if self.IsPullChatHistory then
			return
		end 

		if not self.IsInitGroup or not self.IsInitArmy or not self.IsInitTeam or not self.IsInitSceneTeam then
			local Fmt = "ChatMgr:TryPullChatHistory, try pull history chat msg failed(IsInitGroup = %s IsInitArmy = %s IsInitTeam = %s IsInitSceneTeam = %s)"
			FLOG_INFO(Fmt, self.IsInitGroup, self.IsInitArmy, self.IsInitTeam, self.IsInitSceneTeam)
			return
		end

		self.IsPullChatHistory = true
	end

	local ChannelList = {}
	local NeedActiveChannelList = {}

	for _, v in ipairs(ChatVM.ChannelVMList) do
		local Channel = v:GetChannel()
		local ChannelID = v:GetChannelID()

		if v:IsNeedPull() then
			table.insert(ChannelList, { Type = Channel, ChannelID = ChannelID })
		end

		if v:IsNeedActive() then 
			table.insert(NeedActiveChannelList, { Type = Channel, ChannelID = ChannelID })
		end
	end

	-- 激活频道
	self:SendActiveRoleChannels(NeedActiveChannelList)

	-- 私聊频道
	table.insert(ChannelList, { Type = ChatChannel.Person })

	self:SendChatMsgGetChannelRead(ChannelList)

	FLOG_INFO("ChatMgr:TryPullChatHistory, try pull history chat msg success")
end

---EncodeChatParams
---@param ChatParams table
---@return string
function ChatMgr:EncodeChatParams(ChatParams)
	return ProtoBuff:Encode(ChatParamsProtoName, ChatParams)
end

---DecodeChatParams
---@param Buffer string
---@return Buffer(Buffer不为nil), string（Buffer为nil)
function ChatMgr:DecodeChatParams(Buffer)
	return ProtoBuff:Decode(ChatParamsProtoName, Buffer)
end

function ChatMgr:SetPrivateChatHaveRead(ChannelID, MsgID)
	if nil == ChannelID or MsgID <= 0 then
		return
	end

	if not ChatVM:IsPrivateChatMsgUnread(ChannelID, MsgID) then
		return
	end

	local ReadSeqList = { { Channel = { Type = ChatChannel.Person, ChannelID = ChannelID }, Ack = MsgID } }
	self:SendSetChatChannelHaveRead(ReadSeqList)

	-- 存储私聊 
	self:ActivateSavePrivateChatMsgMark(ChannelID)
end

function ChatMgr:LoadPrivateChatLogs()
	if self.IsPrivateChatLoaded then
		return
	end

	ChatFileIO.ParseAllPrivateChats()

	self.IsPrivateChatLoaded = true
end

function ChatMgr:SavePrivateChatLogs()
	local Channel = ChatChannel.Person 

	for _, v in ipairs(self.WaitSavePrivateChannelIDs) do
		local ChannelVM = ChatVM:FindChannelVM(Channel, v)
		if ChannelVM then
			ChatFileIO.SavePrivateChat(ChannelVM)
		end
	end

	self.WaitSavePrivateChannelIDs = {}
end

function ChatMgr:GetHistoryMsgNum(Channel)
	if Channel == ChatChannel.Newbie then -- 新人频道
		return self.HistoryMsgNumNewbie

	elseif Channel == ChatChannel.Army then -- 公会频道
		return self.HistoryMsgNumArmy

	elseif Channel == ChatChannel.Group then -- 通讯贝频道
		return self.HistoryMsgNumGroup
	end
end

function ChatMgr:LoadPrivateSessions()
	if self.IsPrivateSessionsLoaded then
		return
	end

	ChatVM:AddLocalCachingPrivateItems(ChatFileIO.LoadPrivateSessions())

	self.IsPrivateSessionsLoaded = true
end

function ChatMgr:SavePrivateSessions()
	ChatFileIO.SavePrivateSessions()
end

function ChatMgr:GetMsgSortID()
	self.MsgSortID = self.MsgSortID + 1
	return self.MsgSortID
end

--- 清除公共频道离线小红点提示
function ChatMgr:TryCleanPublicOfflineRedDotTips()
	if self.IsCleanedPublicOfflineRedDot then
		return
	end

	ChatVM:ClearPublicChannelRedDotNum()
	self.IsCleanedPublicOfflineRedDot = true 
end

function ChatMgr:AddMsgInternal(Channel, ChannelID, Content, ParamList, MsgType, Sender, ChannelTagVisible, ComprehensiveInvisible)
	if string.isnilorempty(Content) then
		return
	end

	Sender = Sender or 0

	if Channel ~= ChatChannel.System then
		if nil == MsgType then
			MsgType = Sender > 0 and ChatMsgType.Msg or ChatMsgType.Tips
		end
	end

	local Data = {}
	Data.MsgType 	= MsgType 
	Data.SysMsgID 	= SPECIAL_SYSTEM_MSG_ID.SPECIAL_SYSTEM_MSG_ID_NONE
	Data.Content 	= Content
	Data.Facade 	= 0
	Data.ParamList 	= ParamList or {}

	Data.ChannelTagVisible = ChannelTagVisible ~= false 
	Data.ComprehensiveInvisible = ComprehensiveInvisible

	local ChatMsg = {}
	ChatMsg.ID 		= 0
	ChatMsg.Sender 	= Sender
	ChatMsg.Time 	= TimeUtil.GetServerTime()
	ChatMsg.Data 	= Data
	ChatMsg.SortID 	= self:GetMsgSortID()

	self:AddMsgToBuffer(Channel, ChannelID, ChatMsg)
end

-------------------------------------------------------------------------------------------------
--- 队伍（普通组队和副本小队） 

---@private
---@param Mgr ATeamMgr
---@param ID  number @note may nil
function ChatMgr:OnTeamIDChanged(Mgr, ID)
	local Channel = Mgr.ChatChannelType
	if nil == Channel then
		return
	end

	if not Mgr:IsInTeam() then -- 离开队伍
		ChatVM:SetAllTeamChannelMsgToHistory(Channel)
	end

	if ChatVM.CurChannel == Channel then
		ChatVM:ClearNewMsgTips()
		ChatVM:UpdateChatBarVisible()
		ChatVM:UpdateGoTo()
	end

	if ChatVM.IsChatMainPanelVisible then
		ChatVM:UpdateCompSpeakChannelList()
	end
end

-------------------------------------------------------------------------------------------------
--- 对外接口

---是否处于指定频道中
---@param Channel ChatDefine.ChatChannel @渠道类型
---@param ChannelID number @渠道ID，没有可不传
function ChatMgr:IsInChannel(Channel, ChannelID)
	return ChatVM:CheckIsInChannel(Channel, ChannelID)
end

---获取私聊会话列表
function ChatMgr:GetPrivateItemVMList()
	return ChatVM.PrivateItemVMList
end

---打开聊天窗口
---@param Channel ChatDefine.ChatChannel @渠道类型
---@param ChannelID number @渠道ID，没有可不传
---@param Source ChatDefine.OpenSource @来源，没特殊需求可不传
---@param CurOpenViewID number @打开聊天的界面的界面ID，用于聊天跳转隐藏
---@param IsOpenEmptyClick number @是否允许点击下面界面，除主界面外应该都不行
function ChatMgr:ShowChatView(Channel, ChannelID, Source, CurOpenViewID, IsOpenEmptyClick)
	if Channel == ChatChannel.Team and _G.PWorldMgr:CurrIsInDungeon() then
		Channel = ChatChannel.SceneTeam
		ChannelID = nil
	elseif Channel == ChatChannel.SceneTeam and not _G.PWorldMgr:CurrIsInDungeon() then
		Channel = ChatChannel.Team
		ChannelID = nil
	end
	
	ChatVM:ShowChatMainView(Channel, ChannelID, Source, CurOpenViewID, IsOpenEmptyClick)
end

---更新私聊会话
---@param RoleID number @角色ID 
---@param CreateIfNoSession boolean @如果没有指定会话，是否创建新会话，默认true
function ChatMgr:UpdatePrivateChatSession(RoleID, CreateIfNoSession)
	ChatVM:UpdatePrivateItem(RoleID, CreateIfNoSession ~= false)
end

---跳转到指定聊天窗口（玩家）
---@param RoleID 角色ID 
function ChatMgr:GoToPlayerChatView(RoleID)
	if nil == RoleID or MajorUtil.IsMajorByRoleID(RoleID) then
		return
	end

	local Channel = ChatChannel.Person
	local ChannelID = RoleID
	local ChannelVM = ChatVM:FindChannelVM(Channel, ChannelID, true)
	if nil == ChannelVM then
		return
	end

	--- 创建私聊会话
	ChatVM:CreatePrivateItem(RoleID)
	ChatVM:ShowChatMainView(Channel, ChannelID)
end

---跳转到指定聊天窗口（通讯贝）
---@param GroupID 通讯贝ID 
---@param Source ChatDefine.OpenSource @来源，没特殊需求可不传
---@param CurOpenViewID number @打开聊天的界面的界面ID，用于聊天跳转隐藏
function ChatMgr:GoToGroupChatView(GroupID, Source, CurOpenViewID)
	if nil == GroupID then
		return
	end

	local Channel = ChatChannel.Group
	local ChannelID = GroupID 
	local ChannelVM = ChatVM:FindChannelVM(Channel, ChannelID, true)
	if nil == ChannelVM then
		return
	end

	ChatVM:ShowChatMainView(Channel, ChannelID, Source, CurOpenViewID)
end

---在系统频道展示获取物品提示 
---@param ResID 物品ResID
---@param Num 物品数量 
---@param GID 物品GID
function ChatMgr:ShowGetGoodsTipsInSystemChannel(ResID, Num, GID)
	local GoodsDesc = ChatUtil.GetGoodsChatDesc(ResID)
	if string.isnilorempty(GoodsDesc) then
		return
	end

	-- 10023, "获得了"
	local GetRichText = RichTextUtil.GetText(string.format("%s", LSTR(50023)), "d1ba8e")
	local GetRichText2 = RichTextUtil.GetText(string.format("%s","x"), "d1ba8e")
	local GetNumRichText =  RichTextUtil.GetText(string.format("%s",  Num or 1), "d1ba8e")

	local Content = string.format("%s%s%s%s", GetRichText, GoodsDesc, GetRichText2, GetNumRichText)
	self:AddSysChatMsgGoodsTips(ResID, GID, Content)
end

--在系统频道战斗信息中展示使用物品提示
---@param ResID 物品ResID
---@param GID 物品GID
function ChatMgr:ShowUseItemInSysChatMsgBattle(GID, ResID)
	if nil == GID or nil == ResID then
		return
	end
	local GoodsDesc = ChatUtil.GetGoodsChatDesc(ResID)
	if string.isnilorempty(GoodsDesc) then
		return
	end

	-- 140090, "你使用了"
	local Content = string.format(LSTR(140090), GoodsDesc)
	self:AddSysChatMsgGoodsTips(ResID, GID, Content, SysMsgType.Battle)
end

---在先锋频道插入一条消息
---@param Content string @消息内容 
---@param Sender number @发送者RoleID，默认为0（值为0时，本消息设置为本频道提示消息）
---@param ChannelTagVisible boolean @频道标签是否可见，默认可见
---@param IsCenterTextTips boolean @是否为显示在中间位置的文本提示
function ChatMgr:AddPioneerChatMsg(Content, Sender, ChannelTagVisible, IsCenterTextTips)
	local MsgType = IsCenterTextTips and ChatMsgType.TextTipsCenter or nil
	self:AddMsgInternal(ChatChannel.Pioneer, nil, Content, nil, MsgType, Sender, ChannelTagVisible)
end

---在系统频道插入一条消息
---@param Content string @消息内容 
function ChatMgr:AddSysChatMsg(Content)
	self:AddMsgInternal(ChatChannel.System, nil, Content)
end

---在系统频道插入战斗信息
---@param Content string @消息内容 
function ChatMgr:AddSysChatMsgBattle(Content)
	--local _ <close> = CommonUtil.MakeProfileTag("AddSysChatMsgBattle")
	self:AddMsgInternal(ChatChannel.System, nil, Content, nil, ChatMsgType.SystemBattle)
end

---在系统频道插入剧情信息
---@param Content string @消息内容 
function ChatMgr:AddSysChatMsgStory(Content)
	self:AddMsgInternal(ChatChannel.System, nil, Content, nil, ChatMsgType.SystemStory, nil, false)
end

---添加物品相关提示到系统频道
---@param ResID number @物品ResID
---@param GID number @物品GID
---@param Content string @文本内容
---@param Type ChatDefine.SysMsgType @系统消息类型, 默认系统通知消息Notice
function ChatMgr:AddSysChatMsgGoodsTips(ResID, GID, Content, Type)
	--local _ <close> = CommonUtil.MakeProfileTag("AddSysChatMsgGoodsTips")
	local ItemHref = {}
	ItemHref.GID 	= GID 
	ItemHref.ResID 	= ResID
	ItemHref.RoleID	= MajorUtil.GetMajorRoleID()

	local Params = {}
	Params.Type 	= PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ITEM
	Params.Direct 	= true
	Params.Param 	= self:EncodeChatParams({Item = ItemHref})

	local ParamList = table.pack(Params)

	local MsgType = ChatMsgType.SystemNotice
	if Type == SysMsgType.Battle then
		MsgType = ChatMsgType.SystemBattle
	elseif Type == SysMsgType.Story then
		MsgType = ChatMsgType.SystemStory
	end

	self:AddMsgInternal(ChatChannel.System, nil, Content, ParamList, MsgType)
end

---在系统频道插入一条容错任务消息
---@param NeedNames string
---@param TargetName string
---@param MapID number
---@param QuestID number
---@param Cfg QuestFaultTolerantCfg
function ChatMgr:AddQuestMsg(NeedNames, TargetName, MapID, QuestID, Cfg)
	local Href = {}
	Href.MapID 	= MapID
	Href.QuestID	= QuestID

	local GetRichText1
	if Cfg.Type == ProtoRes.QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_ITEM then
		-- <span color="#d1ba8eff">%s</>丢失，请前往<span color="#d1ba8eff">%s</>处重新获取
		GetRichText1 = string.format(LSTR(50172), NeedNames, TargetName)

    elseif Cfg.Type == ProtoRes.QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_MOUNT then
		-- <span color="#d1ba8eff">%s</>离开了，请前往<span color="#d1ba8eff">%s</>处重新获取
		GetRichText1 = string.format(LSTR(50174), NeedNames, TargetName)

    elseif Cfg.Type == ProtoRes.QUEST_FAULT_TOLERANT_TYPE.QUEST_FAULT_TOLERANT_TYPE_BUFF then
		-- <span color="#d1ba8eff">%s</>失效，请前往<span color="#d1ba8eff">%s</>处重新获取
		GetRichText1 =string.format(LSTR(50173), NeedNames, TargetName)
    end

	local TargetPos
	if Cfg.NpcID > 0 then
        local Actor = ActorUtil.GetActorByResID(Cfg.NpcID)
		if Actor then
			TargetPos = Actor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
		else
			local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
			if MapEditCfg then
				local NpcData = _G.MapEditDataMgr:GetNpc(Cfg.NpcID, MapEditCfg)
				if NpcData then
					TargetPos = NpcData.BirthPoint
				end
			end
		end
    elseif Cfg.EobjID > 0 then
        local Actor = ActorUtil.GetActorByResID(Cfg.EobjID)
		if Actor then
			TargetPos = Actor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
		else
			local MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
			if MapEditCfg then
				local EObjData = _G.MapEditDataMgr:GetEObjByResID(Cfg.EobjID, MapEditCfg)
				if EObjData then
					TargetPos = EObjData.Point
				end
			end
		end
    end

	if nil == TargetPos then
		return
	end
	local UIMapID = _G.MapMgr:CalcUIMapID(MapID)
	local X, Y = MapUtil.GetUIPosByLocation(TargetPos, UIMapID)
	Href.X = X
	Href.Y = Y
	local Params = {}
	Params.Type 	= PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_MAP
	Params.Direct 	= true
	Params.Param 	= self:EncodeChatParams({Map = Href})

	local Position = MapUtil.GetCoordinateText({X=X, Y=Y})

	local LocationDesc = RichTextUtil.GetHyperlink(string.format("%s%s", MapUtil.GetChatHyperlinkMapName(MapID), Position), 1, "d1ba8eff", nil, nil, nil, nil, nil, false)
	local Content = string.format("%s%s", GetRichText1, LocationDesc)
	local ParamList = table.pack(Params)
	self:AddMsgInternal(ChatChannel.System, nil, Content, ParamList)
end

---在队伍频道插入一条消息
---@param Content string @消息内容 
---@param TeamID number @队伍ID
---@param Sender number @发送者RoleID，默认为0（值为0时，本消息设置为本频道提示消息）
---@param IsCenterTextTips boolean @是否为显示在中间位置的文本提示
function ChatMgr:AddTeamChatMsg(Content, TeamID, Sender, IsCenterTextTips)
	local MsgType = IsCenterTextTips and ChatMsgType.TextTipsCenter or nil
	self:AddMsgInternal(ChatChannel.Team, TeamID, Content, nil, MsgType, Sender)
end

-- 在队伍频道插入一个打开宝图的消息
function ChatMgr:AddTeamTreasureMapChatMsg(TeamID, Sender,TreasureMap)
	if TreasureMap == nil then
		return
	end
    local Num = 0
    local ParamList = {}

	local ItemName = ItemUtil.GetItemName(TreasureMap.ID) 
	local Item = {ResID = TreasureMap.ID}

	local Key = string.revisePattern(string.format("[%s]", ItemName))
    local ItemNameText = string.format("[%s]", ItemName)

	local Color = ItemUtil.GetItemQualityColorByResID((Item or {}).ResID)
	local RichText = RichTextUtil.GetHyperlink(ItemNameText, 1, Color, nil, nil, nil, nil, nil, false)
    local strContent = string.format(LSTR(50029),ItemNameText)
    strContent, Num = string.gsub(strContent, Key, RichText, 1)

    local ItemHref = {
		Type = PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ITEM,
		Item = { 
			GID 	= _G.BagMgr:GetItemGIDByResID(Item.ResID), 
			ResID 	= Item.ResID,
			RoleID 	= MajorUtil.GetMajorRoleID()
		}
	}
	ItemHref.Type = nil

    local Param = self:EncodeChatParams(ItemHref)
    local Params = { Type = PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ITEM, Direct = true, Param = Param }
    table.insert(ParamList,Params)

    local MapHref = {TeamTreasureHunt = TreasureMap}
    local Param1 = self:EncodeChatParams(MapHref)
	local Params1 = { Type = PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_TREASUREHUNT, Direct = true, Param = Param1}
    table.insert(ParamList,Params1)

	-- 10029("我使用了%s,大家快来帮忙找宝箱吧！")
	local Content = string.format('%s<a color="#97C3FFFF" linkid="2" underline="false">[%s]</>',strContent,LSTR(50154))
	self:SendChatMsgPushMessage(ChatChannel.Team, TeamID, Content, 0, ParamList)
end

---在部队频道插入一条消息
---@param Content string @消息内容 
---@param Sender number @发送者RoleID，默认为0（值为0时，本消息设置为本频道系统提示消息）
---@param ChannelTagVisible boolean @频道标签是否可见，默认可见
---@param IsCenterTextTips boolean @是否为显示在中间位置的文本提示
function ChatMgr:AddArmyChatMsg(Content, Sender, ChannelTagVisible, IsCenterTextTips)
	if ArmyMgr:IsInArmy() then
		local ArmyID = ArmyMgr.SelfArmyID
		if ArmyID and ArmyID > 0 then
			local MsgType = IsCenterTextTips and ChatMsgType.TextTipsCenter or nil
			self:AddMsgInternal(ChatChannel.Army, ArmyID, Content, nil, MsgType, Sender, ChannelTagVisible)
		end
	end
end

--- 发送一条纯文本消息到部队频道
---@param Content string @消息内容 
---@return boolean @是否发送成功
function ChatMgr:SendArmyChannelMsg(Content)
	if string.isnilorempty(Content) then
		return false
	end

	if not ArmyMgr:IsInArmy() then
		return false
	end

	if not ChatVM:CheckSendTimeCD() then
		return false
	end

	local ChannelVM = ChatVM:FindChannelVM(ChatChannel.Army)
	if nil == ChannelVM then
		return false
	end

	local Channel = ChannelVM:GetChannel()
	local ChannelID = ChannelVM:GetChannelID()
	self:SendChatMsgPushMessage(Channel, ChannelID, Content)

	return true
end

---在附近频道插入一条消息
---@param Content string @消息内容 
---@param MsgType ChatDefine.ChatMsgType @消息类型，默认为ChatMsgType.Msg
---@param Sender number @发送者RoleID，默认为0（值为0时，本消息设置为本频道提示消息）
function ChatMgr:AddNearbyChatMsg(Content, MsgType, Sender)
	self:AddMsgInternal(ChatChannel.Nearby, nil, Content, nil, MsgType, Sender)
end

--- 在附近频道插入一条情感动作提示消息
--- @param Content string @消息内容 
function ChatMgr:AddEmotionTipsMsgInNearbyChannel(Content)
	self:AddNearbyChatMsg(Content, ChatMsgType.EmotionTips)
end

---在区域频道插入一条消息
---@param Content string @消息内容 
---@param MsgType ChatDefine.ChatMsgType @消息类型，默认为ChatMsgType.Msg
---@param Sender number @发送者RoleID，默认为0（值为0时，本消息设置为本频道提示消息）
---@param ChannelTagVisible boolean @频道标签是否可见，默认不可见
---@param ComprehensiveInvisible boolean @频道标签是否可见，默认不可见
function ChatMgr:AddAreaChatMsg(Content, MsgType, Sender, ChannelTagVisible)
	self:AddMsgInternal(ChatChannel.Area, nil, Content, nil, MsgType, Sender, ChannelTagVisible)
end

--- 添加超链接 -- 位置
---@param MapID number @地图ID 
---@param Position table @位置坐标信息，{ X = ..., Y = ... }
function ChatMgr:AddLocationHref(MapID, Position)
	EventMgr:SendEvent(EventID.ChatHyperLinkAddLocation, MapID, Position)
end

--- 从新人频道中移出玩家
---@param RoleID number @玩家RoleID
---@param Identity number @玩家身份
---@param OnlineStatusCustomID number @玩家主动设置的在线状态ID
---@param PlayerName string @玩家名
---@param Remark string @移除评述（原因）
function ChatMgr:RemovePlayerFromNewbieChannel(RoleID, Identify, OnlineStatusCustomID, PlayerName, Remark)
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.ChatNewbieMemberPanel) then
		ChatVM:RemoveNewbieMember(RoleID)
	end

	self:SendRemovePlayerFromNewbieChannelNotice(Identify, OnlineStatusCustomID, PlayerName, Remark)
end

--- 发送把玩家从新人频道移除公告消息（超链接形式）
function ChatMgr:SendRemovePlayerFromNewbieChannelNotice(Identify, OnlineStatusCustomID, PlayerName, Remark)
	if nil == Identify or nil == OnlineStatusCustomID then
		FLOG_ERROR("ChatMgr:SendNoticeRemovePlayerFromNewbieChannel, params error")
		return
	end

	local RoleVM = MajorUtil.GetMajorRoleVM()
	if nil == RoleVM then
		FLOG_ERROR("ChatMgr:SendNoticeRemovePlayerFromNewbieChannel, MajorRoleVM is nil")
		return
	end

	local Href = {
		Identity 		= RoleVM.Identity,
		TargetIdentity	= Identify,
		StatusID 		= RoleVM.OnlineStatusCustomID,
		TargetStatusID	= OnlineStatusCustomID,
		Name 			= RoleVM.Name,
		TargetName 		= PlayerName,
		Remark 			= Remark or "",
	}

	local ExtraParams = { }
	ExtraParams.Type 	= PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_NEWBIE
	ExtraParams.Direct 	= true
	ExtraParams.Param 	= self:EncodeChatParams({Newbie = Href})

	local ChannelVM = ChatVM:FindChannelVM(ChatChannel.Newbie)
	if ChannelVM then
		local Content = "newbienotice" -- 后台对聊天内容有判空抛弃处理
		self:SendChatMsgPushMessage(ChannelVM:GetChannel(), ChannelVM:GetChannelID(), Content, 0, table.pack(ExtraParams), true)
	end
end

---发送Gif表情 (超链接形式)
---@param ID number @Gif表情ID 
function ChatMgr:SendGif(ID)
	if nil == ID or not ChatVM:CheckSendTimeCD() then
		return false
	end

	local Href = {ID = ID}
	local ExtraParams = { }
	ExtraParams.Type 	= PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_GIF
	ExtraParams.Direct 	= true
	ExtraParams.Param 	= self:EncodeChatParams({Gif = Href})

	local Channel, ChannelID = ChatVM:GetSendMsgChannelAndChannelID()
	local ChannelVM = ChatVM:FindChannelVM(Channel, ChannelID)
	if ChannelVM then
		local Content = string.format("#GIF_%s", ID)
		self:SendChatMsgPushMessage(ChannelVM:GetChannel(), ChannelVM:GetChannelID(), Content, 0, table.pack(ExtraParams))
	end

	ChatVM:UpdateSendTimeCD(Channel, ChannelID)

	return true
end

--- 清空新人频道聊天消息
function ChatMgr:ClearNewbieChannelMsg()
	ChatVM:ClearChannelAllChatMsg(ChatChannel.Newbie, nil, false)
end

--- 队伍招募分享
---@param Channel ChatDefine.ChatChannel @渠道类型
---@param ID number @招募ID 
---@param ResID number @招募配置表ID 
---@param IconIDs table @成员图标ID列表
---@param LocList table @各位置人员情况列表（0，未招募到玩家; 1，已招募到玩家）
---@param TaskLimit Team.TeamRecruit.TASK_LIMIT @任务设置（场景模式）
---@param RoleID Number @玩家RoleID，默认为nil，在Channel为ChatChannel.Person时，会发送私聊消息给指定玩家
---@return boolean, number @是否分享成功，剩余冷却时间
function ChatMgr:ShareTeamRecruit(Channel, ID, ResID, IconIDs, LocList, TaskLimit, RoleID)
	if nil == Channel or nil == ID  or nil == ResID or nil == IconIDs or table.empty(IconIDs) or nil == LocList or table.empty(LocList) or nil == TaskLimit then
		FLOG_ERROR("ChatMgr:ShareTeamRecruit, params error")
		return false
	end

	if not self:IsInChannel(Channel) then
		return false
	end

	-- 发送CD
	local Time = ChatVM:GetSendCDRemainTime()
	if Time > 0 then
		Time = math.ceil(Time / 1000) 
		return false, Time
	end

	local Href = { ID = ID, ResID = ResID, IconIDs = IconIDs, LocList = LocList, TaskLimit = TaskLimit}
	local ExtraParams = { }
	ExtraParams.Type 	= PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_RECRUIT
	ExtraParams.Direct 	= true
	ExtraParams.Param 	= self:EncodeChatParams({TeamRecruit = Href})

	local ChannelID = nil
	if Channel == ChatChannel.Person and RoleID and RoleID > 0 then
		ChannelID = RoleID
	end

	local ChannelVM = ChatVM:FindChannelVM(Channel, ChannelID, true)
	if ChannelVM then
		local Content = self.MakeRecruitShareContent(ID) 
		self:SendChatMsgPushMessage(ChannelVM:GetChannel(), ChannelVM:GetChannelID(), Content, 0, table.pack(ExtraParams))
	end

	ChatVM:UpdateSendTimeCD(Channel)

	return true
end

function ChatMgr.MakeRecruitShareContent(ID)
	return ChatMacros.TeamRecruit .. tostring(ID)  
end

--- 任务分享
---@param Channel ChatDefine.ChatChannel @渠道类型
---@param ID number @任务ID (ChapterID)
---@return boolean, number @是否分享成功，剩余冷却时间
function ChatMgr:ShareTask(Channel, ID)
	if nil == Channel or nil == ID then
		FLOG_ERROR("ChatMgr:ShareQuest, params error")
		return false
	end

	if not self:IsInChannel(Channel) then
		return false
	end

	-- 发送CD
	local Time = ChatVM:GetSendCDRemainTime()
	if Time > 0 then
		Time = math.ceil(Time / 1000) 
		return false, Time
	end

	local ExtraParams = { }
	ExtraParams.Type 	= PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TASK
	ExtraParams.Direct 	= true
	ExtraParams.Param 	= self:EncodeChatParams({Task = { TaskID = ID }})

	local ChannelVM = ChatVM:FindChannelVM(Channel)
	if ChannelVM then
		local Content = "TASK_SHARE" .. ID
		self:SendChatMsgPushMessage(ChannelVM:GetChannel(), ChannelVM:GetChannelID(), Content, 0, table.pack(ExtraParams))
	end

	ChatVM:UpdateSendTimeCD(Channel)

	return true
end

--- 成就分享
---@param ID number @成就ID
---@param Content string @消息内容 
function ChatMgr:ShareAchievement(ID, Content)
	if nil == ID or string.isnilorempty(Content) then
		FLOG_ERROR("ChatMgr:ShareAchievement, params error")
		return
	end

	local ItemHref = {}
	ItemHref.ID = ID 

	local Params = {}
	Params.Type 	= PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ACHIEVEMENT_SHARE
	Params.Direct 	= true
	Params.Param 	= self:EncodeChatParams({AchievementShare = ItemHref})

	local ParamList = table.pack(Params)
	self:AddMsgInternal(ChatChannel.System, nil, Content, ParamList)
end

--- 道具ID对应的Gif表情是否解锁 
---@param ItemID number @道具ID
function ChatMgr:IsUnlockGifByItemID(ItemID)
    if nil == ItemID or ItemID <= 0 then
        return false
    end

	local UnlockGifIDMap = ChatVM.UnlockGifIDMap
	if table.is_nil_empty(UnlockGifIDMap) then
		return false
	end	

	local CfgList = ChatGifCfg:GetCfgListByItemID(ItemID)
	if table.is_nil_empty(CfgList) then
		return false 
	end	

	for _, v in ipairs(CfgList) do
		local GifID = v.ID
		if GifID and UnlockGifIDMap[GifID] then
			return true
		end
	end

	return false
end

--- 是否正在录音语音
function ChatMgr:IsRecordingVoice()
	return self.IsRecording
end

return ChatMgr