-- Author: AlexChen
-- Date : 2023-02-09
-- Description : 金碟手册
--
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local SaveKey = require("Define/SaveKey")
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local FairyColorPlayerStatus = ProtoCS.FairyColorPlayerStatus
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local MiniGameType = ProtoCS.MiniGameType
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local QuestHelper = require("Game/Quest/QuestHelper")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_GOLD_SAUSER_MAIN_CMD

local GameNetworkMgr
local CrystalPortalMgr
local TimerMgr
local PWorldMgr
local GoldSauserActivityMgr
local QuestMgr
local MiniCactpotMgr
local JumboCactpotMgr
local JumboCactpotLottoryCeremonyMgr
local GoldSauserMgr
local ModuleOpenMgr
local FashionEvaluationMgr
local MagicCardTourneyMgr
local EasyTraceMapMgr
local SaveMgr

local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MapUtil = require("Game/Map/MapUtil")
local TimeUtil = require("Utils/TimeUtil")
local ItemUtil = require("Utils/ItemUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local AudioUtil = require("Utils/AudioUtil")
local NpcCfg = require("TableCfg/NpcCfg")
local AetherCurrentsVM = require("Game/AetherCurrent/AetherCurrentsVM")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local GoldSaucerMinigameCfg = require("TableCfg/GoldSaucerMinigameCfg")
local GoldSaucerAwardShowCfg = require("TableCfg/GoldSaucerAwardShowCfg")
local GoldSaucerAwardBelongCfg = require("TableCfg/GoldSaucerAwardBelongCfg")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local AchievementGroupCfg = require("TableCfg/AchievementGroupCfg")
local GoodsCfg = require("TableCfg/GoodsCfg")
local MallCfg = require("TableCfg/MallCfg")
local GameDescCfg = require("TableCfg/GoldSaucerGameDescCfg")
local GoldSaucerTaskTypeCfg = require("TableCfg/GoldSaucerTaskTypeCfg")
local GoldSaucerCfg = require("TableCfg/GoldSaucerCfg")
local MountVM = require("Game/Mount/VM/MountVM")
local AsyncReqModuleType = GoldSauserMainPanelDefine.AsyncReqModuleType
local GoldSauserUnlockNpcID = GoldSauserMainPanelDefine.GoldSauserUnlockNpcID
local GoldSauserCrystalPortalID = GoldSauserMainPanelDefine.GoldSauserCrystalPortalID
local TeleportTicketItemResID = GoldSauserMainPanelDefine.TeleportTicketItemResID
local GoldSauserNpcID = GoldSauserMainPanelDefine.GoldSauserNpcID
--local GoldSauserUnlockQuestID = GoldSauserMainPanelDefine.GoldSauserUnlockQuestID
local GoldSauserTargetMapID = GoldSauserMainPanelDefine.GoldSauserTargetMapID
local TraceMarkerType = GoldSauserMainPanelDefine.TraceMarkerType
local GoldSauserMainClientType2ModuleID = GoldSauserMainPanelDefine.GoldSauserMainClientType2ModuleID
local ModuleID = ProtoCommon.ModuleID
local GoldSauserAwardBelongType = ProtoRes.GoldSauserAwardBelongType
local GoldSauserAwardSourceType = ProtoRes.GoldSauserAwardSourceType
local GoodsPriceTypeInfo = ProtoRes.GoodsPriceTypeInfo
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local AudioPath = GoldSauserMainPanelDefine.AudioPath
local AudioType = GoldSauserMainPanelDefine.AudioType
local FirstCactusTimeResID = 23 -- 首次出现仙人掌时间间隔
local OtherCactusTimeResID = 25 -- 非首次出现仙人掌时间间隔
local CactusInteractiveTimesResID = 24 -- 仙人掌点击交互不同次数标准
local FLOG_INFO = _G.FLOG_INFO

-- @class GoldSauserMainPanelMgr : MgrBase
local GoldSauserMainPanelMgr = LuaClass(MgrBase)

--- OnInit
function GoldSauserMainPanelMgr:OnInit()
    local GameIDLists = {}
    local PoolCfg = GoldSaucerTaskTypeCfg:FindAllCfg()
    if PoolCfg then
        for _, Cfg in ipairs(PoolCfg) do
            local TaskType = Cfg.TaskType
            if TaskType and not table.contain(GameIDLists, TaskType) then
                table.insert(GameIDLists, TaskType)
            end
        end
    end
    self.GameIDLists = GameIDLists -- 所有玩法事件id(服务器通信用)

    local GameID2GameEntranceID = {} -- 玩法事件id与具体玩法入口ID对应关系
    for _, GameID in ipairs(GameIDLists) do
        local SubTypeArr = GameID2GameEntranceID[GameID] or {}
        local Cfgs = GameDescCfg:FindAllCfg(string.format("TaskType = %d", GameID))
        for _, Cfg in ipairs(Cfgs) do
           table.insert(SubTypeArr, Cfg.GameType)
        end
        GameID2GameEntranceID[GameID] = SubTypeArr
    end
    self.GameID2GameEntranceID = GameID2GameEntranceID
end

function GoldSauserMainPanelMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    TimerMgr = _G.TimerMgr
    PWorldMgr = _G.PWorldMgr
    GoldSauserActivityMgr = _G.GoldSauserActivityMgr
    QuestMgr = _G.QuestMgr
    MiniCactpotMgr = _G.MiniCactpotMgr
    JumboCactpotMgr = _G.JumboCactpotMgr
    JumboCactpotLottoryCeremonyMgr = _G.JumboCactpotLottoryCeremonyMgr
    ModuleOpenMgr = _G.ModuleOpenMgr
    GoldSauserMgr = _G.GoldSauserMgr
    FashionEvaluationMgr = _G.FashionEvaluationMgr
    MagicCardTourneyMgr = _G.MagicCardTourneyMgr
    CrystalPortalMgr = PWorldMgr:GetCrystalPortalMgr()
    EasyTraceMapMgr = _G.EasyTraceMapMgr
    SaveMgr = _G.UE.USaveMgr

    self.CactusItemRunTimer = nil -- 仙人掌运动计时器
	self.CactusDisapperInterval = 0 -- 仙人掌消失时间间隔
	self.bFirst = true -- 是否首次运动
    self.bCactusReadyShow = false -- 仙人掌显示冷却结束
    self.bStayAtMainPanel = false -- 是否处于金碟主界面状态（仙人掌）

    self.OtherModuleMsgFlags = {} -- 其他模块协议更新标记

    GoldSauserMainPanelMainVM:InitGamePlayItemList(self.GameIDLists, self.GameID2GameEntranceID)

    self.IsInPanelMiniGame = false -- 是否处于主界面小游戏状态

    self.RewardMarkedList = {} -- 奖励一览收藏ID存储
    self:LoadMarkedReward()
end

function GoldSauserMainPanelMgr:OnEnd()
    self.OtherModuleMsgFlags = nil
    self.RewardMarkedList = nil
    self:EndRunTimer()
end

function GoldSauserMainPanelMgr:OnShutdown()
    self.GameIDLists = nil
    self.GameID2GameEntranceID = nil
    self.GoldSauserCrystalCfgs = nil
    self:SaveMarkedReward()
end

function GoldSauserMainPanelMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER_MAIN, SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GET_EVENT, self.OnNetMsgGoldSauserMainGetEvent)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER_MAIN, SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GET_REWARD, self.OnNetMsgGoldSauserMainGetReward)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER_MAIN, SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GET_ITEM, self.OnNetMsgGoldSauserMainGetItem)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER_MAIN, SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GAME_NOTIFY, self.OnNetMsgGoldSauserMainGameNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER_MAIN, SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GAME_FINISH, self.OnNetMsgGoldSauserMainGameFinish)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER_MAIN, SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_EVENT_UPDATE, self.OnNetMsgGoldSauserMainEventUpdate)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER_MAIN, SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_DATA_QUERY, self.OnNetMsgGoldSauserMainDataRsp)
end

function GoldSauserMainPanelMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpen)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
    --self:RegisterGameEvent(EventID.ExcuteAsyncInfoFromOtherModule, self.OnExcuteAsyncInfoCallBack)
end

function GoldSauserMainPanelMgr:OnGameEventLoginRes(Params)
    -- for 红点 （后续若协议修改，需配合修改此处内容
    if not ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDGoldSauserMain) then
        return
    end

    self:SendReqAllMainData()

    local bReconnect = Params.bReconnect
    if bReconnect then
        return -- 只在正式登录时拉取
    end
    self:PreReqSevInfoForGameWhenLogin() -- 幻卡大赛入口表现动画需求，提前获取不至于打开界面时穿帮
end

--- 功能解锁界面表现结束
function GoldSauserMainPanelMgr:OnModuleOpen(OpenID)
    local bIsOpen = OpenID == ModuleID.ModuleIDGoldSauserMain --  table.contain(OpenIDList, ) 
    if bIsOpen then
        self:SendReqAllMainData()
    end
end

--- 其他模块接入发送时间更新异步信息
--_G.EventMgr:SendEvent(EventID.ExcuteAsyncInfoFromOtherModule, {GameID = GameID, ModuleType = ModuleType, UpdateInfo = UpdateInfo})

function GoldSauserMainPanelMgr:OnGameEventPWorldMapEnter(Params)
    local CurMapID = Params.CurrMapResID
    if not CurMapID then
        return
    end

    local PanelVM = AetherCurrentsVM.SkillPanelVM
    if not PanelVM then
        return
    end

    local bInJD = self:IsInJDMap(CurMapID)
    PanelVM.bShowGoldSauserMainBtn = bInJD
    if bInJD then
        FLOG_INFO("ShowJDBtnByWorldEnterEvent: bShowGoldSauserMainBtn %s", bInJD)
    end
end

-------------- Request Part Start-------------------------

--- 全量拉取金碟手册数据
function GoldSauserMainPanelMgr:SendReqAllMainData()
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER_MAIN
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_DATA_QUERY

    local MsgBody = {
        Cmd = SubMsgID,
        DataInfo = {}
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainDataRsp(MsgBody)
    local MsgContent = MsgBody.DataInfo
    if not MsgContent then
        return
    end
    local TaskFinishedNum = MsgContent.TaskFinishedNum or 0
    local bTaskCompleteMax = self:IsTaskCompleteToMax(TaskFinishedNum)
    if bTaskCompleteMax then
        FLOG_INFO("GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainDataRsp bTaskCompleteMax")
        GoldSauserMainPanelMainVM:TaskCompleteToMax()
    else
        local Event = MsgContent.Event
        local TaskType2EventArray = {}
        local function GetTheEvtTaskType(ID)
            if not ID then
                return
            end
            local Cfg = GoldSaucerCfg:FindCfgByKey(ID)
            if not Cfg then
                return
            end

            local GameType = Cfg.GameType
            if not GameType then
                return
            end

            local TaskTypeCfg = GoldSaucerTaskTypeCfg:FindCfgByKey(GameType)
            if not TaskTypeCfg then
                return
            end
            return TaskTypeCfg.TaskType
        end

        for _, Evt in ipairs(Event) do
            local ID = Evt.ID
            local TaskType = GetTheEvtTaskType(ID)
            if TaskType then
                local EvtArray = TaskType2EventArray[TaskType] or {}
                table.insert(EvtArray, Evt)
                TaskType2EventArray[TaskType] = EvtArray
            end   
        end
        for _, EvtArray in pairs(TaskType2EventArray) do
            GoldSauserMainPanelMainVM:UpdateEventData(EvtArray)
        end
    end

    local IsUnlockDataItem = MsgContent.IsUnlockDataItem
    GoldSauserMainPanelMainVM.IsDataItemUnlock = IsUnlockDataItem
    if IsUnlockDataItem then
        local EventPool = MsgContent.EventPool
        local PercentList = MsgContent.PercentList
        if EventPool or PercentList then
            GoldSauserMainPanelMainVM:UpdateDataItemInfo(EventPool, PercentList)
        end
    end
end

---@请求玩法事件数据
function GoldSauserMainPanelMgr:SendGetGameEventViewDataMsg(TaskType)
    if not self:IsEventGameIDValid(TaskType) then
        return
    end

    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER_MAIN
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GET_EVENT
    
    local MsgBody = {
        Cmd = SubMsgID,
        Event = {
            TaskType = TaskType
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@下发对应玩法事件数据
function GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainGetEvent(MsgBody)
    local Msg = MsgBody.Event
	if nil == Msg then
		return
	end
    ---@param table {ID, Num}
  
    local TaskFinishedNum = Msg.TaskFinishedNum or 0
    local bTaskCompleteMax = self:IsTaskCompleteToMax(TaskFinishedNum)
    if bTaskCompleteMax then
        FLOG_INFO("GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainGetEvent bTaskCompleteMax")
        GoldSauserMainPanelMainVM:TaskCompleteToMax()
    else
        local Event = Msg.Event
        GoldSauserMainPanelMainVM:UpdateEventData(Event)
    end
end

---@领取奖励
function GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainGetReward(MsgBody)
    local Msg = MsgBody.Reward
	if nil == Msg then
		return
	end
    local TaskType = Msg.TaskType
    local AwardCoins = Msg.AwardCoins
    self:SendGetGameEventViewDataMsg(TaskType)
end

--@获取数据统计项
function GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainGetItem(MsgBody)
    local Msg = MsgBody.DataItem
	if nil == Msg then
		return
	end
    local EventPool = Msg.EventPool
    local PercentList = Msg.PercentList
    if nil == EventPool or nil == PercentList then
		return
	end
    GoldSauserMainPanelMainVM:UpdateDataItemInfo(EventPool, PercentList)
end

---@小游戏触发通知
function GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainGameNotify(MsgBody)
    local Msg = MsgBody.GameType
	if nil == Msg then
		return
	end
    --print("gold GameNotify "..Msg.MiniGameType)
    local MiniGameType = Msg.MiniGameType
    if not MiniGameType then
        return
    end

    local Level = Msg.Level
    if not Level then
        return
    end

    if not UIViewMgr:IsViewVisible(UIViewID.GoldSauserEntranceMainPanel) then
        return
    end

    GoldSauserMainPanelMainVM:SetGameNotify(MiniGameType, Level)
end

function GoldSauserMainPanelMgr:TestTriggerGameNotify(Level)
    GoldSauserMainPanelMainVM:SetGameNotify(MiniGameType.MiniGameTypeAirForceOne, Level)
end

function GoldSauserMainPanelMgr:TestTriggerBirdGameNotify(Level)
    GoldSauserMainPanelMainVM:SetGameNotify(MiniGameType.MiniGameTypeCliffHanger, Level)
end

---@小游戏完成统计次数
function GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainGameFinish(MsgBody)
    local Msg = MsgBody.GameFinish
	if nil == Msg then
		return
	end
    ---todo 后续等效果图
    if Msg.Success then
        local SuccessTipsID = 40292
        MsgTipsUtil.ShowTipsByID(SuccessTipsID)
        self:PlayAudio(AudioType.SuccTip)
    end
end

---@玩法事件进度更新响应
function GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainEventUpdate(MsgBody)
    local Msg = MsgBody.Update
	if nil == Msg then
		return
	end
    local Event = Msg.Event
    GoldSauserMainPanelMainVM:UpdateEventData(Event)
end

-------------- Request Part End---------------------------

-------------- Send Part Start-------------------------
---@请求趣味数据数据
function GoldSauserMainPanelMgr:SendGetDataWinItemViewDataMsg()
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER_MAIN
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GET_ITEM

    local MsgBody = {
        Cmd = SubMsgID,
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@请求领取奖励
function GoldSauserMainPanelMgr:SendGetGoldSauserRewardMsg(TaskType)
    if not self:IsEventGameIDValid(TaskType) then
        return
    end

    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER_MAIN
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GET_REWARD

    local MsgBody = {
        Cmd = SubMsgID,
        Reward = {
            TaskType = TaskType
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@小游戏完成计数
function GoldSauserMainPanelMgr:SendGoldSauserMainGameFinishedNumMsg(MiniGameType)
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER_MAIN
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GAME_FINISH
    local MsgBody = {
        Cmd = SubMsgID,
        GameFinish = {
            MiniGameType = MiniGameType
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@金蝶庆典时间请求
function GoldSauserMainPanelMgr:SendGoldSauserCelebrationMsg()
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER_MAIN
    local SubMsgID = SUB_MSG_ID.CS_GOLD_SAUSER_MAIN_CMD_GAME_CELEBRATION
    local MsgBody = {
        Cmd = SubMsgID,
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-------------- Send Part End---------------------------

--- 判断事件任务奖励数量达到上限
function GoldSauserMainPanelMgr:IsTaskCompleteToMax(TaskFinishedNum)
    local bTaskCompleteMax
    local Params
    local Cfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_GOLD_SAUSER_MAIN_TASK_FINISHED_LIMIT)
    if not Cfg then
        FLOG_ERROR("GoldSauserMainPanelMgr:OnNetMsgGoldSauserMainGetEvent GameGlobalCfg do not have the data")
    else
        Params = Cfg.Value
    end
    local ExplainWinVM = GoldSauserMainPanelMainVM.GoldSauserMainPanelExplainWinVM
    if Params and ExplainWinVM then
        local MaxCount = Params[1]
        bTaskCompleteMax = TaskFinishedNum >= MaxCount
    end
    return bTaskCompleteMax
end

--- 根据表格判断玩法事件ID是否有效
---@param GameID number @玩法事件ID
function GoldSauserMainPanelMgr:IsEventGameIDValid(TaskType)
    return table.contain(self.GameIDLists, TaskType)
end

---根据客户端GameEntranceID判断是否有效（表格配置检验）
function GoldSauserMainPanelMgr:IsGameBtnValid(GameEntranceID)
    local TaskType = self:FindGameParentTypeByGameEntranceID(GameEntranceID)
    if not TaskType then
        FLOG_ERROR("GoldSauserMainPanelMgr:IsGameUnlock cannot find the tasktype")
        return
    end
    local bGameIDValid = self:IsEventGameIDValid(TaskType)
    if not bGameIDValid then
        FLOG_ERROR("GoldSauserMainPanelMgr:IsGameUnlock Game Locked By No Data")
    end
    return bGameIDValid
end


--- 进入游戏选中特定入口
function GoldSauserMainPanelMgr:OpenGoldSauserMainPanel(SelectedGameType)
    local bOpen = ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDGoldSauserMain)
    if not bOpen then
        MsgTipsUtil.ShowTips(LSTR(350002))
        return
    end

    local Params
    if SelectedGameType then
        Params = {
            SelectedGameType = SelectedGameType
        }
    end

    self:SendReqAllMainData() -- 2025.4.21 服务器要求每次打开界面都需要拉取数据

    local bVisible = UIViewMgr:IsViewVisible(UIViewID.GoldSauserEntranceMainPanel)
    if not bVisible then
        UIViewMgr:ShowView(UIViewID.GoldSauserEntranceMainPanel, Params)
    else
        _G.EventMgr:SendEvent(EventID.GoldSauserSelectedEntrance, SelectedGameType)
    end
    
end

---@deprecated
--- 封装金碟主界面传送逻辑
---@param bMain boolean@是否是主界面按钮传送
--[[function GoldSauserMainPanelMgr:TransferByPanel(bMain)
    local function StartTransferSing()
        CrystalPortalMgr:TransferByMap(GoldSauserMainPanelDefine.GoldSauserCrystalPortalID.GoldSauserMain)
        UIViewMgr:HideView(UIViewID.GoldSauserEntranceMainPanel)
    end

    if bMain then
        StartTransferSing()
        return
    end

    local GoldSauserMainPanelExplainWinVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelExplainWinVM()
    if not GoldSauserMainPanelExplainWinVM then
        return
    end
    local GameId = GoldSauserMainPanelExplainWinVM:GetGameId()
	---判断是否在金蝶地图，考虑配表读取GoldSauserMapID
	local MapId = MapUtil.GetMajorMapIDAndPosition()
	if MapId == GoldSauserMainPanelDefine.GoldSauserMapID then
		--- todo先用水晶传送，等陆行鸟接口
		local FromCrystal = {}
		local ToCrystal = {}
		FromCrystal.EntityID = GoldSauserMainPanelDefine.GoldSauserCrystalPortalID.GoldSauserMain
		ToCrystal.EntityID = GoldSauserMainPanelDefine.GoldSauserCrystalPortalID[GameId]
		CrystalPortalMgr:TransferByInteractive(FromCrystal, ToCrystal)
        UIViewMgr:HideView(UIViewID.GoldSauserEntranceMainPanel) -- 小水晶传送不一定会出loading
	else
		--- todo先用水晶传送，等陆行鸟接口
		StartTransferSing()
	end
end--]]

--- 从系统解锁表获取所有解锁状态信息
---@param ModuleID ProtoCommon.ModuleID @模块ID
function GoldSauserMainPanelMgr:GetModuleOpenInfo(ModuleID)
    local bUnlock = ModuleOpenMgr:CheckOpenState(ModuleID)
    if bUnlock then
        return true
    end
    local OpenCfg = ModuleOpenMgr:GetCfgByModuleID(ModuleID)
    local PreTaskList = OpenCfg.PreTask
    local QuestName = ""
    if PreTaskList then
        for _, QuestID in ipairs(PreTaskList) do
            if QuestMgr:GetQuestStatus(QuestID) ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
                QuestName = QuestMgr:GetQuestName(QuestID)
                break
            end
        end
    end
    return bUnlock, QuestName
end

--- 入口上锁状态判定接口
---@param GameID GoldSauserGameClientType@具体玩法类型
function GoldSauserMainPanelMgr:IsGameEntranceLocked(GameID)
    if not GameID then
        return
    end

    local bGameIDValid = self:IsGameBtnValid(GameID)
    if not bGameIDValid then
        FLOG_ERROR("The Game Entrance Not In the Config")
        return true
    end
    local ModuleOpen = self:IsGameUnlock(GameID)
    if GameID == GoldSauserGameClientType.GoldSauserGameTypeChocoboRace or
    GameID == GoldSauserGameClientType.GoldSauserGameTypeChocobo then -- 5.7 OBT暂时屏蔽陆行鸟竞赛相关内容
        return true -- 暂时关闭
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace then
        local RaceStart = MagicCardTourneyMgr:IsTourneyActive()
        local RewardToReceive = MagicCardTourneyMgr:IsCanGetReward()
        return not ModuleOpen or (not RaceStart and not RewardToReceive)
    end
end

--- 获取金碟玩法是否解锁
---@param GameEntranceID GoldSauserGameClientType@具体玩法类型
---@return boolean, ...@是否解锁, 未解锁信息
function GoldSauserMainPanelMgr:IsGameUnlock(GameEntranceID)
    if not GameEntranceID then
        return
    end

    local UnlockState = false
    local QuestName = ""

    local bGameIDValid = self:IsGameBtnValid(GameEntranceID)
    if not bGameIDValid then
        return
    end
   
    local ModuleID = GoldSauserMainClientType2ModuleID[GameEntranceID]
    if not ModuleID then
        return true, nil
    end

    UnlockState, QuestName = self:GetModuleOpenInfo(ModuleID)
    return UnlockState, QuestName
end

function GoldSauserMainPanelMgr:AddAsyncCallBack(GameID, ModuleType, CallBack)
    if not CallBack then
        return
    end

    local GameFuncs = self.CallBackMap[GameID] or {}
    GameFuncs[ModuleType] = CallBack
    self.CallBackMap[GameID] = GameFuncs
end

--- 获取金碟玩法的辅助信息
---@param GameID GoldSauserGameClientType@具体玩法类型
---@return boolean, ...@是否异步/辅助信息
function GoldSauserMainPanelMgr:GetGameAssistInfo(GameID, CallBack)
    if not GameID then
        return
    end

    local bAsync = false
    local RoundText = ""
    local ScoreText = ""
    local BattleCount
    local MaxBattleCount
    local Score
    --TODO:测试数据，待获取其他功能接口后接入正式数据
    if GameID ==  GoldSauserGameClientType.GoldSauserGameTypeChocoboRace then
        --TODO:功能尚未开发
    elseif GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace then
        local RaceInfo = MagicCardTourneyMgr:GetTourneySimpleInfo()
        if RaceInfo then
            BattleCount = RaceInfo.BattleCount or 0
            MaxBattleCount = RaceInfo.MaxBattleCount or 0
            RoundText = string.format("%s/%s", BattleCount, MaxBattleCount)
            Score = RaceInfo.Score or 0
            ScoreText = tostring(Score)
        end
    end

    if bAsync then
        if not CallBack then
            FLOG_ERROR("GoldSauserMainPanelMgr:GetGameAssistInfo Async but no Callback")
            return
        end
        self:AddAsyncCallBack(GameID, AsyncReqModuleType.Assist, CallBack)
        return bAsync
    else
        return bAsync, RoundText, ScoreText
    end
end

--- 获取玩法的提示信息
---@param GameID GoldSauserGameClientType@具体玩法类型
---@return boolean, ...@是否异步/玩法提示信息
function GoldSauserMainPanelMgr:GetGameHintInfo(GameID, CallBack)
    if not GameID then
        return
    end

    local bAsync = false
    local Rlt = ""
    local bAwardToGet = false
    local IconTobeViewVisible = false
    local RemainTimes
    local MaxTimes
    local BattleCount
    local MaxBattleCount
    
    local function RaceHintFormat(BattleCount, MaxBattleCount)
        return BattleCount < MaxBattleCount and LSTR(350003) or LSTR(350004)
    end

    if GameID == GoldSauserGameClientType.GoldSauserGameTypeChocoboRace then
        --TODO:功能尚未开发
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace then
        local bCanReceive = MagicCardTourneyMgr:IsCanGetReward()
        if bCanReceive then
            Rlt = LSTR(350005)
            IconTobeViewVisible = true
        else
            local RaceInfo = MagicCardTourneyMgr:GetTourneySimpleInfo()
            if RaceInfo then
                BattleCount = RaceInfo.BattleCount or 0
                MaxBattleCount = RaceInfo.MaxBattleCount or 0
                Rlt = RaceHintFormat(BattleCount, MaxBattleCount)
                IconTobeViewVisible = true
            end
        end
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot then
        local LeftChance = MiniCactpotMgr:GetLeftChance() or 0
        --local MaxChance = MiniCactpotMgr.MiniCactpotInfo.MaxChance or 0
        Rlt = string.format(LSTR(350006), tostring(LeftChance))
        IconTobeViewVisible = LeftChance > 0
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFairyColor then
        local State = JumboCactpotMgr:GetCurJumbState()
        if State == FairyColorPlayerStatus.FairyColorPlayerExchange then
            Rlt = LSTR(350066)
            IconTobeViewVisible = true
        else
            RemainTimes = JumboCactpotMgr.RemainPurchases or 0
            --MaxTimes = JumboCactpotMgr.AllPurchasesNum or 0
            Rlt = string.format(LSTR(350007), tostring(RemainTimes))
            IconTobeViewVisible = RemainTimes > 0
        end
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFashionCheck then
        local FashionInfo = FashionEvaluationMgr:GetEvaluationInfo()
        if FashionInfo then
            RemainTimes = FashionInfo.WeekRemainTimes or 0
            --MaxTimes = FashionInfo.MaxWeekRemainTimes or 0
            Rlt = string.format(LSTR(350008), tostring(RemainTimes))
            IconTobeViewVisible = RemainTimes > 0
        end
    end

    if bAsync then
        if not CallBack then
            FLOG_ERROR("GoldSauserMainPanelMgr:GetGameHintInfo Async but no Callback")
            return
        end
        self:AddAsyncCallBack(GameID, AsyncReqModuleType.Hint, CallBack)
        return bAsync, nil, nil, nil
    else
        return bAsync, Rlt, bAwardToGet, IconTobeViewVisible
    end
end

--- 获取玩法的时限信息
---@param GameID GoldSauserGameClientType@具体玩法类型
---@return boolean, ...@是否异步/玩法提示信息
function GoldSauserMainPanelMgr:GetGameTimeLimitInfo(GameID, CallBack)
    if not GameID then
        return
    end

    local bAsync = false
    local Rlt = 0
    local CurTimeStamp = TimeUtil.GetServerTime()

    if GameID ==  GoldSauserGameClientType.GoldSauserGameTypeChocoboRace then
        --TODO:功能尚未开发
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace then
        local bCanReceive = MagicCardTourneyMgr:IsCanGetReward()
        local RaceInfo = MagicCardTourneyMgr:GetTourneySimpleInfo()
        if not bCanReceive and RaceInfo then
            local EndStamp = RaceInfo.EndTime or 0
            Rlt = EndStamp * 1000
        end
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot then
        -- 微彩更新时间与通用跨天更新时间相同，走配置
        Rlt = (CurTimeStamp + TimeUtil.GetNextDailyUpadteTime()) * 1000
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFairyColor then
        Rlt = JumboCactpotLottoryCeremonyMgr:GetRemainSecondTime() * 1000 + TimeUtil.GetServerTimeMS()
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFashionCheck then
        local RemainSecs = FashionEvaluationMgr:GetEvaluationRemainTime()
        Rlt = (CurTimeStamp + RemainSecs) * 1000
    end
    if bAsync then
        if not CallBack then
            FLOG_ERROR("GoldSauserMainPanelMgr:GetGameHintInfo Async but no Callback")
            return
        end
        self:AddAsyncCallBack(GameID, AsyncReqModuleType.Time, CallBack)
        return bAsync
    else
        return bAsync, Rlt
    end
end

--- 登录时即申请，预先向其他玩法发送相关拉取服务器信息协议
function GoldSauserMainPanelMgr:PreReqSevInfoForGameWhenLogin()
    if self:IsGameUnlock(GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace) then
        MagicCardTourneyMgr:SendMsgGetTourneyInfo()
    end 
end

--- 打开界面才申请
function GoldSauserMainPanelMgr:PreReqSevInfoForGameWhenOpenPanel()
    if self:IsGameUnlock(GoldSauserGameClientType.GoldSauserGameTypeFairyColor) then
        JumboCactpotMgr:SendReqBaseMsg()
    end    
    if self:IsGameUnlock(GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot) then
        MiniCactpotMgr:SendMiniCactpotInfoReq()
    end 
    if self:IsGameUnlock(GoldSauserGameClientType.GoldSauserGameTypeFashionCheck) then
        FashionEvaluationMgr:SendMsgGetFashionEvaluationInfo()
    end 
end

------ 仙人掌运动 ------

--- 给予特殊情况修改是否第一次进入的状态
function GoldSauserMainPanelMgr:ResetFirstInState()
	self.bFirst = true
end

--- 仙人掌出现时间相关配表数据（更新单位：秒）
function GoldSauserMainPanelMgr:GetCactusCfgTimeData()
	local bFirst = self.bFirst
	if bFirst then
		local FirstCfg = GoldSaucerMinigameCfg:FindCfgByKey(FirstCactusTimeResID)
		if not FirstCfg then
			return
		end
		local Value = FirstCfg.Value
		if not Value then
			return
		end

		return Value[1]
	else
		local OtherCfg = GoldSaucerMinigameCfg:FindCfgByKey(OtherCactusTimeResID)
		if not OtherCfg then
			return
		end
		local Value = OtherCfg.Value
		if not Value then
			return
		end

		return Value[1]
	end
end

--- 仙人掌点击次数相关配表数据
function GoldSauserMainPanelMgr:GetCactusCfgCountData(ClickedCount)
    local Cfg = GoldSaucerMinigameCfg:FindCfgByKey(CactusInteractiveTimesResID)
    if not Cfg then
        return
    end
    local Value = Cfg.Value
    if not Value then
        return
    end

    for Index, CountLimit in ipairs(Value) do
        if ClickedCount == CountLimit then
            return Index
        end
    end
end

--- 仙人掌交互相关计时逻辑（更新单位：秒）
function GoldSauserMainPanelMgr:UpdateCactusRunTime()
	local Interval = self.CactusDisapperInterval
	local CactusAppearTime = self:GetCactusCfgTimeData()
	if Interval >= CactusAppearTime then
		self:EndRunTimer()
		return
	end
	self.CactusDisapperInterval = Interval + 1
    
end

--- 开始仙人掌小游戏计时（保证同时只有一个CD计时器存在）
function GoldSauserMainPanelMgr:StartRunTimer()
	local CactusItemRunTimer = self.CactusItemRunTimer
	if CactusItemRunTimer then
		return
	end

    self.bCactusReadyShow = false
	self.CactusItemRunTimer = _G.TimerMgr:AddTimer(self, self.UpdateCactusRunTime, 0, 1, 0, nil, "GoldSauserMain")
    FLOG_INFO("GoldSauserMainPanelMgr:CactusTimeCount StartTime:%s", TimeUtil.GetServerTimeMS())
end

--- 停止仙人掌小游戏CD计时
function GoldSauserMainPanelMgr:EndRunTimer()
	local CactusItemRunTimer = self.CactusItemRunTimer
	if not CactusItemRunTimer then
		return
	end
	_G.TimerMgr:CancelTimer(CactusItemRunTimer)
	self.CactusItemRunTimer = nil
    self.CactusDisapperInterval = 0
    self.bCactusReadyShow = true
    if self.bStayAtMainPanel then
        _G.EventMgr:SendEvent(EventID.GoldSauserCactusShowOrHide, true)
    end
    self.bFirst = false
    FLOG_INFO("GoldSauserMainPanelMgr:CactusTimeCount EndTime:%s", TimeUtil.GetServerTimeMS())
end

--- 处于主界面时判断仙人掌状态（包括打开主界面以及回到主界面）
function GoldSauserMainPanelMgr:CheckCactusState()
    if UIViewMgr:IsViewVisible(UIViewID.GoldSauserEntranceMainPanel) then
        self:SetIsAtMainPanel(true)
    end
    local ReadyShow = self.bCactusReadyShow
    if ReadyShow then
        if self.bStayAtMainPanel then
            _G.EventMgr:SendEvent(EventID.GoldSauserCactusShowOrHide, true)
        end
    else
        self:StartRunTimer()
    end
end

--- 触发仙人掌消失逻辑(非点击规则消失使用)
function GoldSauserMainPanelMgr:TriggerCactusHide(bPlayAnim)
    _G.EventMgr:SendEvent(EventID.GoldSauserCactusShowOrHide, false, bPlayAnim)
    self:SetIsAtMainPanel(false)
end

--- 设置是否处于金碟主界面
---@param bAt boolean
function GoldSauserMainPanelMgr:SetIsAtMainPanel(bAt)
    self.bStayAtMainPanel = bAt
end

--- 设置是否在小游戏过程中
function GoldSauserMainPanelMgr:SetIsInPanelMiniGame(bIn)
    self.IsInPanelMiniGame = bIn
end

--- 处于小游戏流程中屏蔽点击功能
---@param bAt boolean
function GoldSauserMainPanelMgr:BlockByMiniGameInPanel(bShowTips)
    local IsInPanelMiniGame = self.IsInPanelMiniGame
    if IsInPanelMiniGame and bShowTips then
        --MsgTipsUtil.ShowTips(LSTR(350079)) -- 2025.4.22 应策划要求去除tips提示
    end
    return IsInPanelMiniGame
end
------ 仙人掌运动 end ------

--- 设置其他玩法模块服务器信息更新状态
---@param GameID GoldSauserGameClientType
---@param bUpdated boolean
function GoldSauserMainPanelMgr:SetTheMsgUpdateState(GameID, bUpdated)
    local FlagMap = self.OtherModuleMsgFlags or {}
    FlagMap[GameID] = bUpdated
    self.OtherModuleMsgFlags = FlagMap

    -- 更新完毕修改对应玩法标记状态
    if bUpdated then
        _G.EventMgr:SendEvent(EventID.ExcuteAsyncInfoFromOtherModule, GameID)
    end
end

--- 获取其他玩法模块服务器信息更新状态
---@param GameID GoldSauserGameClientType
---@return boolean
function GoldSauserMainPanelMgr:GetTheMsgUpdateState(GameID)
    local FlagMap = self.OtherModuleMsgFlags
    if not FlagMap then
        return
    end

    if not self:IsGameUnlock(GameID) then -- 玩法模块未解锁时，不会进行服务器信息更新直接刷新
        return true
    end

    -- 临时代码
    if GameID == GoldSauserGameClientType.GoldSauserGameTypeChocobo or GameID == GoldSauserGameClientType.GoldSauserGameTypeChocoboRace then
        return true
    end

    -- 移到登录时获取的信息，不需要开关控制，防止动效出错
    if GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace or GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCard then
        return true
    end
    return FlagMap[GameID]
end

--- 金碟手册播放音效
function GoldSauserMainPanelMgr:PlayAudio(AudioType)
    if not AudioType then
        return
    end
    local AudioToPlay = AudioPath[AudioType]
    if not AudioToPlay then
        return
    end
    AudioUtil.LoadAndPlayUISound(AudioToPlay)
end

------ 奖励一览 ------
--- 获取此奖励是否收藏
function GoldSauserMainPanelMgr:GetTheRewardIsMarked(ID)
    local RewardMarkedList = self.RewardMarkedList
    if not RewardMarkedList or not next(RewardMarkedList) then
        return
    end

    return table.contain(RewardMarkedList, ID)
end

function GoldSauserMainPanelMgr:ConfirmTheRewardMarked(ID)
    local RewardMarkedList = self.RewardMarkedList or {}
    table.insert(RewardMarkedList, ID)
    self.RewardMarkedList = RewardMarkedList
    MsgTipsUtil.ShowTips(LSTR(350090))
end

function GoldSauserMainPanelMgr:CancelTheRewardMarked(ID)
    local RewardMarkedList = self.RewardMarkedList
    if not RewardMarkedList or not next(RewardMarkedList) then
        return
    end
    table.remove_item(RewardMarkedList, ID)
    MsgTipsUtil.ShowTips(LSTR(350091))
end

--- 保存本地储存收藏奖励的变化
function GoldSauserMainPanelMgr:SaveMarkedReward()
    local CacheList = self.RewardMarkedList
    
    if CacheList == nil or next(CacheList) == nil then
        SaveMgr.SetString(SaveKey.RewardsMarked, "", true)
        return
    end

    local function MakeAarrayString(CacheList)
        local StrToSave
        local IDList = table.indices(CacheList)
        for Index, Value in ipairs(IDList) do
            if Index == 1 then
                StrToSave = tostring(Value)
            else
                StrToSave = string.format("%s,%s", StrToSave, tostring(Value))
            end
        end
        return StrToSave
    end

    local StoreStr = MakeAarrayString(CacheList)

    if StoreStr == nil then
        return
    end
    SaveMgr.SetString(SaveKey.RewardsMarked, StoreStr, true)
end

--- 加载本地储存收藏的奖励
function GoldSauserMainPanelMgr:LoadMarkedReward()
    local StrLoaded = SaveMgr.GetString(SaveKey.RewardsMarked, "", true)
    if StrLoaded == "" then
        self.RewardMarkedList = {}
        return
    end
    local LocalStrParams = string.split(StrLoaded, ',')
    local RewardMarkedList = self.RewardMarkedList or {}
    for _, Value in ipairs(LocalStrParams) do
        local ID = tonumber(Value)
        if ID then
            table.insert(RewardMarkedList, ID)
        end
    end
    self.RewardMarkedList = RewardMarkedList
end

--- 获取此奖励是否已拥有
function GoldSauserMainPanelMgr:GetTheRewardIsOwned(Cfg)
    local GroupID = Cfg.GroupID or 0 -- 配表可知对应具体数据类型
    local AwardType = Cfg.AwardType or 0
    if AwardType == GoldSauserAwardSourceType.AwardSourceTypeAchievement then
       return _G.AchievementMgr:GetAchievementFinishState(GroupID)
    elseif AwardType == GoldSauserAwardSourceType.AwardSourceTypeShop then
        local ItemID = Cfg.ItemID or 0
        -- 先判断背包有没有，再判断对应系统解没解锁物件
        local OwnItemNum = _G.BagMgr:GetItemNum(ItemID)
        if OwnItemNum > 0 then
            return true
        else
            return ItemUtil.IsActivated(ItemID)
        end
    end
end

--- 获取分类名称
function GoldSauserMainPanelMgr:GetBelongTypeName(Cfg)
    local BelongType = Cfg.BelongType
    local BelongTypeCfg = GoldSaucerAwardBelongCfg:FindCfgByKey(BelongType)
    if not BelongTypeCfg then
        return
    end

    return BelongTypeCfg.TypeName
end

--- 获取品质背景是否显示
function GoldSauserMainPanelMgr:GetIsQualityVisible(Cfg)
    local BelongType = Cfg.BelongType
    if BelongType == GoldSauserAwardBelongType.AwardBelongTypeHonor then
        return false
    else
        return true
    end
end

--- 获取品质背景资源路径
function GoldSauserMainPanelMgr:GetItemQualityIcon(Cfg)
    if not self:GetIsQualityVisible(Cfg) then
        return
    end

    local ItemResID = Cfg.ItemID
    return ItemUtil.GetItemColorIcon(ItemResID)
end

--- 获取奖励Icon
function GoldSauserMainPanelMgr:GetItemIcon(Cfg)
    local BelongType = Cfg.BelongType
    if not BelongType then
        return
    end
    if BelongType == GoldSauserAwardBelongType.AwardBelongTypeHonor then
        --[[local AchievementID = Cfg.GroupID
        if AchievementID then
            return AchievementUtil.QueryAchievementIconPath(AchievementID)
        end--]]
        return "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Icon_Title_png.UI_Achievement_Icon_Title_png'"
    else
        local ItemResID = Cfg.ItemID
        local IconID = ItemUtil.GetItemIcon(ItemResID)
        return UIUtil.GetIconPath(IconID)
    end
end

--- 获取奖励显示名称
function GoldSauserMainPanelMgr:GetItemName(Cfg)
    local BelongType = Cfg.BelongType
    if not BelongType then
        return
    end
    local CfgKey = Cfg.ItemID
    if BelongType == GoldSauserAwardBelongType.AwardBelongTypeHonor then
        local Gender = MajorUtil:GetMajorGender()
        return _G.TitleMgr:GetTargetTitleText(CfgKey, Gender)
    else
        return ItemUtil.GetItemName(CfgKey)
    end
end

--- 根据页签类型获取内容数据
function GoldSauserMainPanelMgr:CreateContentDatasByAwardType(AwardType)
    local TypeCfgs = GoldSaucerAwardShowCfg:FindAllCfg(string.format("AwardType = %d", AwardType))
    if not TypeCfgs or not next(TypeCfgs) then
        return
    end
    local ContentDatas = {}
    for _, Cfg in ipairs(TypeCfgs) do
        local CfgID = Cfg.ID
        local ItemValue = {
            ID = CfgID,
            bMarked = self:GetTheRewardIsMarked(CfgID),
            IconReceivedVisible = self:GetTheRewardIsOwned(Cfg),
            BelongTypeName = self:GetBelongTypeName(Cfg),
            IsQualityVisible = self:GetIsQualityVisible(Cfg),
            ItemQualityIcon = self:GetItemQualityIcon(Cfg),
            Icon = self:GetItemIcon(Cfg),
            Name = self:GetItemName(Cfg),
        }
        table.insert(ContentDatas, ItemValue)
    end
    return ContentDatas
end

function GoldSauserMainPanelMgr:GetDetailPanelDesc(ItemCfg)
    local CfgKey = ItemCfg.GroupID
    if not CfgKey then
        return
    end
    if ItemCfg.AwardType == GoldSauserAwardSourceType.AwardSourceTypeShop then
        local GoodsConfig = GoodsCfg:FindCfgByKey(CfgKey)
        if GoodsConfig then
            local MallName
            local PriceContent
            local MallID = GoodsConfig.MallID
            local MallConfig = MallCfg:FindCfgByKey(MallID)
            if MallConfig then
                MallName = MallConfig.Name
            end
            local PriceList = GoodsConfig.Price
            if PriceList and next(PriceList) then
                for _, Price in ipairs(PriceList) do
                    local Count = Price.Count
                    if Count and Count > 0 then
                        local Type = Price.Type
                        local PriceName
                        if Type == GoodsPriceTypeInfo.GOODS_PRICE_TYPE_SCORES then
                            PriceName = _G.ScoreMgr:GetScoreNameText(Price.ID)
                        elseif Type == GoodsPriceTypeInfo.GOODS_PRICE_TYPE_ITEMS then
                            PriceName = ItemUtil.GetItemName(Price.ID)
                        end
                        
                        if not PriceContent then
                            PriceContent = string.format(LSTR(350083), string.formatint(Count), PriceName)
                        else
                            PriceContent = string.format(LSTR(350084), PriceContent, string.formatint(Count), PriceName)
                        end
                    end
                end
                PriceContent = string.format(LSTR(350085), PriceContent)
            end
            return string.format(LSTR(350086), MallName or "", PriceContent or "")
        end
    elseif ItemCfg.AwardType == GoldSauserAwardSourceType.AwardSourceTypeAchievement then
        return AchievementUtil.QueryAchievementHelp(CfgKey)
    end
end

function GoldSauserMainPanelMgr:GetCondText(ItemCfg)
    local CfgKey = ItemCfg.GroupID
    if not CfgKey then
        return
    end
    if ItemCfg.AwardType == GoldSauserAwardSourceType.AwardSourceTypeShop then
        local GoodsConfig = GoodsCfg:FindCfgByKey(CfgKey)
        if GoodsConfig then
            local PriceContent
            local PriceList = GoodsConfig.Price
            if PriceList and next(PriceList) then
                for _, Price in ipairs(PriceList) do
                    local Count = Price.Count or 0
                    if Count > 0 then
                        local Type = Price.Type
                        local ID = Price.ID
                        local PriceRichTextIcon
                        local PriceRichTextCount
                        if Type == GoodsPriceTypeInfo.GOODS_PRICE_TYPE_SCORES then
                            local IconPath = _G.ScoreMgr:GetScoreIconName(ID)
                            PriceRichTextIcon = RichTextUtil.GetTexture(IconPath, 40, 40, -8)
                            local OwnScore = _G.ScoreMgr:GetScoreValueByID(ID)
                            if OwnScore < Count then
                                PriceRichTextCount = RichTextUtil.GetText(string.formatint(OwnScore), "AF4C58")
                            else
                                PriceRichTextCount = string.formatint(OwnScore)
                            end
                        elseif Type == GoodsPriceTypeInfo.GOODS_PRICE_TYPE_ITEMS then
                            local IconID = ItemUtil.GetItemIcon(ID)
                            local IconPath = UIUtil.GetIconPath(IconID)
                            PriceRichTextIcon = RichTextUtil.GetTexture(IconPath, 40, 40, -8)
                            local OwnItemNum = _G.BagMgr:GetItemNum(ID)
                            if OwnItemNum < Count then
                                PriceRichTextCount = RichTextUtil.GetText(tostring(OwnItemNum), "AF4C58")
                            else
                                PriceRichTextCount = OwnItemNum
                            end
                        end
    
                        if not PriceContent then
                            PriceContent = string.format(LSTR(350088), PriceRichTextIcon, PriceRichTextCount)
                        else
                            PriceContent = string.format("%s %s%s", PriceContent, PriceRichTextIcon, PriceRichTextCount)
                        end
                    end
                end
            end
            return PriceContent
        end
    elseif ItemCfg.AwardType == GoldSauserAwardSourceType.AwardSourceTypeAchievement then
        local AchSevInfo = _G.AchievementMgr:GetAchievementInfo(CfgKey)
        if AchSevInfo then
            local Progress = AchSevInfo.Progress or 0
            local TotalProgress = AchSevInfo.TotalProgress or 0
            local ProgressRichText
            if Progress < TotalProgress then
                ProgressRichText = RichTextUtil.GetText(tostring(Progress), "b56728")
            else
                ProgressRichText = tostring(Progress)
            end
            return string.format(LSTR(350089), ProgressRichText, TotalProgress)
        end
    end
end

function GoldSauserMainPanelMgr:GetWayDatas(ItemCfg)
    local CfgKey = ItemCfg.GroupID
    if not CfgKey then
        return
    end
    local RltDatas = {}
    if ItemCfg.AwardType == GoldSauserAwardSourceType.AwardSourceTypeAchievement then
        local Group = AchievementUtil.QueryAchievementGroupID(CfgKey)
        local GroupCfg = AchievementGroupCfg:FindCfgByKey(Group)
        if GroupCfg then
            local AchList = GroupCfg.Details
            for _, AchID in ipairs(AchList) do
                local AchTable = {
                    AchievementID = AchID,
                    Icon = AchievementUtil.QueryAchievementIconPath(AchID),
                    bGot = _G.AchievementMgr:GetAchievementFinishState(AchID),
                    AchievementName = AchievementUtil.GetAchievementName(AchID)
                }
                table.insert(RltDatas, AchTable)
            end
        end
    end

    return RltDatas
end

--- 根据具体ItemVM获取对应详情面板需要的额外信息
function GoldSauserMainPanelMgr:CreateExplainExtraParams(ItemVM)
    if not ItemVM then
        return
    end

    local ID = ItemVM.ID
    local ItemCfg = GoldSaucerAwardShowCfg:FindCfgByKey(ID)
    if not ItemCfg then
        return
    end
    local ExtraParam = {}
    ExtraParam.DetailPanelDesc = self:GetDetailPanelDesc(ItemCfg)
    if not ItemVM.IconReceivedVisible then
        ExtraParam.CondText = self:GetCondText(ItemCfg)
    end

    ExtraParam.GetWayDatas = self:GetWayDatas(ItemCfg)

    return ExtraParam
end

function GoldSauserMainPanelMgr:OpenAwardWinPanel()
    UIViewMgr:ShowView(UIViewID.GoldSauserMainPanelAwardWin)
end

------ 奖励一览 END ------

------ 外部接口 ------

--- 是否在金碟范围内地图
function GoldSauserMainPanelMgr:IsInJDMap(CurMapID)
    return CurMapID == GoldSauserMainPanelDefine.GoldSauserMapID 
    or CurMapID == GoldSauserMainPanelDefine.ChocoboMapID 
end

--- 快速兑换货币界面
function GoldSauserMainPanelMgr:ShowQuickExchangePanel(
    Title,
    SrcScoreType,
    SrcScoreValue,
    DstScoreType,
    DstScoreValue,
    ConfirmCallBack,
    CancelCallBack,
    ConfirmParams,
    CancelParams
   )

    local Params = {
        Title = Title,
        SrcScoreType = SrcScoreType,
        SrcScoreValue = SrcScoreValue,
        DstScoreType = DstScoreType,
        DstScoreValue = DstScoreValue,
        ConfirmCallBack = ConfirmCallBack,
        CancelCallBack = CancelCallBack,
        ConfirmParams = ConfirmParams,
        CancelParams = CancelParams,
    }
    UIViewMgr:ShowView(UIViewID.GoldSauserMainPanelExchangeWin, Params)
end

function GoldSauserMainPanelMgr:ShowKingDeeQuickExchangePanel()
    local IsInPanelMiniGame = self:BlockByMiniGameInPanel(true)
    if IsInPanelMiniGame then
        return
    end
    local Cfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_GOLD_SAUCER_QUICK_EXANGE)
    if Cfg == nil then
        return
    end

    self:ShowQuickExchangePanel(LSTR(350009), SCORE_TYPE.SCORE_TYPE_GOLD_CODE, 
        Cfg.Value[2], SCORE_TYPE.SCORE_TYPE_KING_DEE, Cfg.Value[3], GoldSauserMgr.SendExchangeJDCoin, nil, nil, nil)
    self:TriggerCactusHide()
end

function GoldSauserMainPanelMgr:ShowKingDeeExchangeTipsPanel()
    local IsInPanelMiniGame = self:BlockByMiniGameInPanel(true)
    if IsInPanelMiniGame then
        return
    end
    local Content = LSTR(350010)
    JumboCactpotMgr:ShowCommTips(LSTR(350011), Content, JumboCactpotMgr.OnGoGetJDCoinCallBack, nil, false, true)
    self:TriggerCactusHide()
end

function GoldSauserMainPanelMgr:ShowTraceAirShipTipsPanel()
    local Content = LSTR(350012)
    JumboCactpotMgr:ShowCommTips(LSTR(350013), Content, function()
        -- 临时追踪飞空艇传送点
        local TransPoint = 726
        local MapID = 12001
        local MapTitle = string.format(LSTR(350014))
        EasyTraceMapMgr:ShowEasyTraceMap(MapID, MapTitle, {ID = TransPoint}, {ID = TransPoint})
        --[[
        EasyTraceMapMgr:ShowEasyTraceMap(nil, MapTitle, {ID = GoldSauserMainPanelDefine.AirShipPlatformMarkerID}, {ID = GoldSauserMainPanelDefine.AirShipPlatformMarkerID}, nil, GoldSauserMainPanelDefine.AirShipPlatformUIMapID)--]]
    end, nil, true)
    
end

------ 金碟主界面传送逻辑 ------
function GoldSauserMainPanelMgr:BtnClickGoToGoldSauserMain()
    local bAcrossCrystalActive = CrystalPortalMgr:IsExistActiveCrystal(GoldSauserCrystalPortalID.GoldSauserMain)
    if bAcrossCrystalActive then
        local MapTitle = string.format(LSTR(350015))
        EasyTraceMapMgr:ShowEasyTraceMap(GoldSauserMainPanelDefine.GoldSauserMapID, MapTitle, {CrystalID = GoldSauserCrystalPortalID.GoldSauserMain})
        self:PlayAudio(AudioType.EasyMap)
        self:TriggerCactusHide()
        return
    end
    local CurMapID = PWorldMgr:GetCurrMapResID()
    local bAtGoldSauserScene = self:IsInJDMap(CurMapID)
   
    if bAtGoldSauserScene then
        --local Crystal = CrystalPortalMgr:GetCrystalByEntityId(GoldSauserCrystalPortalID.GoldSauserMain)
        local MapTitle = string.format(LSTR(350016))
        EasyTraceMapMgr:ShowEasyTraceMap(GoldSauserMainPanelDefine.GoldSauserMapID, MapTitle, {CrystalID = GoldSauserCrystalPortalID.GoldSauserMain}, {CrystalID = GoldSauserCrystalPortalID.GoldSauserMain})
        self:PlayAudio(AudioType.EasyMap)
    else
        local bHaveTeleportTicket = _G.BagMgr:GetItemNum(TeleportTicketItemResID) > 0
        if bHaveTeleportTicket then
            UIViewMgr:ShowView(UIViewID.GoldSaucerMainPanelUsingTeleportWin)
        else
            self:ShowTraceAirShipTipsPanel()
            self:PlayAudio(AudioType.EasyMap)
        end
    end
    self:TriggerCactusHide()
end

--- 针对Chapter进行追踪
---@param GameEntranceID GoldSauserGameClientType@客户端玩法入口ID
---@param TraceType TraceMarkerType@追踪地图图标的种类
function GoldSauserMainPanelMgr:FindTheCurrentQuestTraceTarget(GameEntranceID, TraceType)
    local ModuleID = GoldSauserMainClientType2ModuleID[GameEntranceID]
    if not ModuleID then
        return
    end
    local OpenCfg = ModuleOpenMgr:GetCfgByModuleID(ModuleID)
    if not OpenCfg then
        return
    end
    local PreTaskList = OpenCfg.PreTask
    if not PreTaskList or not next(PreTaskList) then
        return
    end

    local TraceStartQuest
    for _, QuestID in ipairs(PreTaskList) do
        if QuestMgr:GetQuestStatus(QuestID) ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
            TraceStartQuest = QuestID
            break
        end
    end

    if not TraceStartQuest then
        return
    end

    local QuestCfg = QuestHelper.GetQuestCfgItem(TraceStartQuest)
    if not QuestCfg then
        return
    end
    local ChapterID = QuestCfg.ChapterID
    if not ChapterID then
        return
    end

    local ChapterCfg = QuestHelper.GetChapterCfgItem(ChapterID)
    if not ChapterCfg then
        return
    end

    local ChapterQuests = ChapterCfg.ChapterQuests
    if not ChapterQuests then
        return
    end

    local TraceFinalQuest
    for _, QuestID in ipairs(ChapterQuests) do
        if QuestMgr:GetQuestStatus(QuestID) ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
            TraceFinalQuest = QuestID
            break
        end
    end

    if not TraceFinalQuest then
        return
    else
        if TraceMarkerType.Quest == TraceType then
            return TraceFinalQuest
        end
    end

    local FinalQuestCfg = QuestHelper.GetQuestCfgItem(TraceFinalQuest)
    if not FinalQuestCfg then
        return
    end

    local QuestStartNpc = FinalQuestCfg.StartNpc
    if QuestStartNpc and QuestStartNpc ~= 0 then
        if TraceMarkerType.Npc == TraceType then
            return QuestStartNpc
        end
    else
        local TargetParamID = FinalQuestCfg.TargetParamID
        if not TargetParamID then
            return
        end
        for _, TargetID in ipairs(TargetParamID) do
            if QuestMgr:GetTargetStatus(TargetID) ~= TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED then
                local TargetCfg = QuestHelper.GetTargetCfgItem(TraceFinalQuest, TargetID)
                if not TargetCfg then
                    return
                end
                return TargetCfg.NaviObjID
            end
        end
    end
end

function GoldSauserMainPanelMgr:FindTheTraceID(GameID)
    if not GameID then
        return
    end

    if GameID == GoldSauserGameClientType.GoldSauserGameTypeGateShow or GameID == GoldSauserGameClientType.GoldSauserGameTypeGateMagic
    or GameID == GoldSauserGameClientType.GoldSauserGameTypeGateCircle then
        return TraceMarkerType.Crystal, GoldSauserCrystalPortalID[GameID]
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCard then
        if self:IsGameUnlock(GameID) then
            return TraceMarkerType.Crystal, GoldSauserCrystalPortalID[GameID]
        else
            return TraceMarkerType.Npc, GoldSauserUnlockNpcID[GameID]
        end
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFantasyCardRace then
        if self:IsGameUnlock(GameID) then
            return TraceMarkerType.Npc, GoldSauserNpcID[GameID]
        else
            return TraceMarkerType.Npc, GoldSauserUnlockNpcID[GameID]
        end
    elseif GameID == GoldSauserGameClientType.GoldSauserGameTypeFashionCheck then
        if self:IsGameUnlock(GameID) then
            return TraceMarkerType.Place, GoldSauserNpcID[GameID]
        else
            return TraceMarkerType.Quest, self:FindTheCurrentQuestTraceTarget(GameID, TraceMarkerType.Quest)
        end
    else
        if self:IsGameUnlock(GameID) then
            return TraceMarkerType.Npc, GoldSauserNpcID[GameID]
        else
            return TraceMarkerType.Npc, GoldSauserUnlockNpcID[GameID]
        end
    end
end

function GoldSauserMainPanelMgr:MakeTheTraceName(TraceType, TraceID)
    if not TraceType or not TraceID then
        return
    end
    if TraceType == TraceMarkerType.Npc then
        local NpcConfig = NpcCfg:FindCfgByKey(TraceID)
        if NpcConfig then
            return NpcConfig.Name
        end
    elseif TraceType == TraceMarkerType.Crystal then
        local CrystalCfg = CrystalPortalCfg:FindCfgByKey(TraceID)
        if CrystalCfg then
            return CrystalCfg.CrystalName or ""
        end
    elseif TraceType == TraceMarkerType.Quest then
        return QuestMgr:GetQuestName(TraceID)
    end
end

function GoldSauserMainPanelMgr:MakeTheTraceParam(TraceType, TraceID)
    if TraceType == TraceMarkerType.Crystal then
        return {CrystalID = TraceID}
    else
        return {ID = TraceID}
    end
end

function GoldSauserMainPanelMgr:BtnClickGoToChildGameEntrance(GameID)
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        return
    end
    local TargetMapID = GoldSauserTargetMapID[GameID]
    local TraceType, TraceID = self:FindTheTraceID(GameID)
 
    if not TargetMapID or not TraceID then
        return
    end

    local TraceName = self:MakeTheTraceName(TraceType, TraceID) or ""
    if TraceType == TraceMarkerType.Place then
        -- 此类型为地图上标记配置特殊，直接根据Entrance玩法种类设置名称
        if GameID == GoldSauserGameClientType.GoldSauserGameTypeFashionCheck then
            TraceName = LSTR(350017)
        end
    end
    local MapTitle = string.format(LSTR(350018), TraceName)
     
    local bAtGoldSauserScene = self:IsInJDMap(CurMapID)
    local bAcrossCrystalActive = CrystalPortalMgr:IsExistActiveCrystal(GoldSauserCrystalPortalID.GoldSauserMain)

    local TraceParam = self:MakeTheTraceParam(TraceType, TraceID)
    if bAtGoldSauserScene then
        TraceParam.bAcrossMap = CurMapID ~= TargetMapID
        EasyTraceMapMgr:ShowEasyTraceMap(TargetMapID, MapTitle, {bCalculateClosestCrystal = true}, TraceParam, true)
    else
        if bAcrossCrystalActive then
            EasyTraceMapMgr:ShowEasyTraceMap(TargetMapID, MapTitle, {CrystalID = GoldSauserCrystalPortalID.GoldSauserMain}, TraceParam, true)
        else
            EasyTraceMapMgr:ShowEasyTraceMap(TargetMapID, MapTitle, TraceParam, TraceParam)
        end
    end
    self:PlayAudio(AudioType.EasyMap)
    self:TriggerCactusHide()
end

--- 金碟主界面前往各玩法按钮
---@param GameID GoldSauserGameClientType@玩法类型客户端枚举 GoldSauserGameClientType.GoldSauserGameTypeNone为主场景
function GoldSauserMainPanelMgr:BtnClickGoToGoldSauserMainGame(GameID)
    if not GameID then
        return
    end

    if GameID == GoldSauserGameClientType.GoldSauserGameTypeNone then
        self:BtnClickGoToGoldSauserMain()
    else
        GoldSauserMainPanelMgr:BtnClickGoToChildGameEntrance(GameID)
    end
    
end

------ 金碟主界面传送逻辑 end ------

--- 获取对应EntranceID的TaskType
function GoldSauserMainPanelMgr:FindGameParentTypeByGameEntranceID(GameEntranceID)
    if not GameEntranceID then
        return
    end
    local GameID2GameEntranceID = self.GameID2GameEntranceID
    if not GameID2GameEntranceID or not next(GameID2GameEntranceID) then
        return
    end

    for TaskType, GameIDList in pairs(GameID2GameEntranceID) do
        for _, GameID in ipairs(GameIDList) do
            if GameID == GameEntranceID then
                return TaskType
            end
        end
    end
end

--- 跳转九宫幻卡接口
function GoldSauserMainPanelMgr:JumpToMainPanelMagicCard()
    self:OpenGoldSauserMainPanel(GoldSauserGameClientType.GoldSauserGameTypeFantasyCard)
end


function GoldSauserMainPanelMgr:SendTlogMsgForGameResult(MiniGameType, bSuccess)
    local RltValue = bSuccess and 1 or 0
    DataReportUtil.ReportData("GoldSaucermanualGameFlow", 
        true, false, true, 
        "OpType", 2, "GameID", MiniGameType, "Arg1", RltValue)
end

return GoldSauserMainPanelMgr
