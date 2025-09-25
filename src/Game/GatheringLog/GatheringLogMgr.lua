---
--- Author: Leo
--- DateTime: 2023-03-29 15:36:31
--- Description: 采集笔记
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local GatherPointCfg = require("TableCfg/GatherPointCfg")
local DataReportUtil = require("Utils/DataReportUtil")
local GatherNoteCfg = require("TableCfg/GatherNoteCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local AudioUtil = require("Utils/AudioUtil")
local TimeUtil = require("Utils/TimeUtil")
local TimeDefine = require("Define/TimeDefine")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local LoginMgr = require("Game/Login/LoginMgr")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local GlobalCfg = require("TableCfg/GlobalCfg")
local MapDefine = require("Game/Map/MapDefine")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local LocalizationUtil = require("Utils/LocalizationUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ScoreCfg = require("TableCfg/ScoreCfg")
local Json = require("Core/Json")
local HorBarIndex = GatheringLogDefine.HorBarIndex
local GatheringLogType = GatheringLogDefine.GatheringLogNoteType
local SpecialType = GatheringLogDefine.SpecialType
local SaveKey = require("Define/SaveKey")
local SaveMgr = _G.UE.USaveMgr
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local GatherPointType = ProtoRes.GATHER_POINT_TYPE

local StringTools = _G.StringTools
local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_NOTE_CMD
local FLOG_ERROR = _G.FLOG_ERROR
local ActorMgr = _G.ActorMgr
local MajorUtil = require("Utils/MajorUtil")
local ItemUtil = require("Utils/ItemUtil")

local UpdataType = {HistoryList = 1, CollectList = 2, ClockList = 3}

---@class GatheringLogMgr : MgrBase
---@field public DefaultProfEnum number 默认职业ID
---@field public LeftProfessionData table<number, table> @左侧职业数据
---@field public LastFilterState table @最后选中状态的各种数据
---@field public LastSelectProfessMiner table @最后选中的矿工职业的状态
---@field public LastSelectProfessBotanist table @最后选中的园艺工职业的状态
---@field public AllGatheringItemsInfo table @所有采集物的信息
---@field public SearchRecordList table @搜索记录
---@field public SeleckClockCheckList table @选中的闹钟列表
---@field public ClockSetting table @闹钟设置
---@field public PromptedAlarmGather table @在同一时间段已经_提示_过闹钟的采集物合集
---@field public AdvancePromptedAlarmGather table @在同一时间段已经_提前提示_过闹钟的采集物合集
---@field public AdvanceRemindTime number @闹钟提前提醒的时间1，3，5分钟
---@field public bArraignmentVersion bool @是否时提审版本
---@field public UseLineageProf table @使用过背包中的传承录的职业(默认已经解锁)
---@field public bFinishCommerceCollectiblesTask boolean @是否完成特殊采集物的解锁任务(默认已经解锁)
---@field public bFinishOldPatronTradingTask boolean @是否完成特殊采集物的解锁任务(默认已经解锁)
---@field public bFinishCareerStoriesTask boolean @是否完成特殊采集物的解锁任务(默认已经解锁)
---@field public bFinishRebuildIshgardTask boolean @是否完成特殊采集物的解锁任务(默认已经解锁)
---@field public MinerLevel number @矿工等级
---@field public BotanistLevel number @园艺工等级
---@field public SearchRecordOrderNum number @用于搜索记录排序
---@field public AlarmExistProf table @哪些职业的采集物发出了闹钟提醒，记录了职业
---@field public NormalDropRedDotLists table @普通页签下拉选项红点回包
---@field public SpecialDropRedDotLists table @特殊页签下拉选项红点回包
local GatheringLogMgr = LuaClass(MgrBase)

function GatheringLogMgr:OnInit()
    self.DefaultProfEnum = ProtoCommon.prof_type.PROF_TYPE_MINER
    self.LeftProfessionData = {}
    --记录最后选中物品
    self.LastFilterState = {}
    self.LastSelectProfessMiner = {}
    self.LastSelectProfessBotanist = {}
    self.AllHorbarsSelectData = {}

    self.ParamTabItems = nil
    self.AllGatheringItemsInfo = {}
    self.SearchRecordList = {}
    self.SeleckClockCheckList = {}
    self.ClockSetting = {}
    self.PromptedAlarmGather = {}
    self.AdvancePromptedAlarmGather = {}
    self.AlarmExistProf = {bMiner = false, bBotanist = false}
    self.knownLocList = nil
    self.GatherPlaceList = nil
    self.HistoryList = nil
    self.CollectList = nil
    self.ClockList = nil

    self.AdvanceRemindTime = 0
    self.bArraignmentVersion = true

    self.UseLineageProf = {}
    self.bFinishCommerceCollectiblesTask = false
    self.bFinishOldPatronTradingTask = false
    self.bFinishCareerStoriesTask = false
    self.bFinishRebuildIshgardTask = false

    --修改职业等级时改这两个值
    self.MinerLevel = 0
    self.BotanistLevel = 0
    self.AttrGathering = 100
    self.SearchRecordOrderNum = 0

    -- GM 是否开启已采集
    self.bGotGM = false
    self.VersionNametoNum = {}
    self.GameVersionNum = self:GetGameVersionNum()

    ---未读过的普通页签下拉框选项
    self.NormalDropRedDotLists = {}
    ---未读过的特殊页签下拉框选项
    self.SpecialDropRedDotLists = {}
    self.AddNewIndex = {}
    ---保存采集物的红点名
    self.GatherItemRedDotNameList = {}
    ---已读过的普通页签下拉框选项
    self.CancelNormalDropRedDotLists = {}
    ---已读过的特殊页签下拉框选项
    self.CancelSpecialDropRedDotLists = {}

    --是否进入搜索状态
    self.SearchState = 0
    self.ReverseOrder = false --正序为从小到大

    self:InitAllData()
    self:GetGatherToCloseAlarmGather()
end

function GatheringLogMgr:GetQuestStatus()
    self.bFinishCommerceCollectiblesTask = _G.QuestMgr:GetQuestStatus(GatheringLogDefine.CollectionQuestID) == QUEST_STATUS.CS_QUEST_STATUS_FINISHED
    return self.bFinishCommerceCollectiblesTask
end

function GatheringLogMgr:OnBegin()
    self.bArraignmentVersion = LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_VERIFY)
end

function GatheringLogMgr:OnRegisterNetMsg()
    -- 获取解锁了的版本号及背包中的传承录是否使用过
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_QUERY_VERSION, self.OnNetMsgQueryVersion)
    --获取/更新采集笔记获得下拉列表的新字
    --self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_COLLECTION_APPEAR, self.OnNetMsgAddGatherNoteNewData)
    --移除采集笔记获得下拉列表的新字
    --self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_COLLECTION_REMOVE_APPEAR, self.OnNetMsgRemoveGatherNoteNewData)
    --收藏或者取消收藏的消息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_MARK, self.OnNetMsgCollectOrNotinfo)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_CANCEL_MARK, self.OnNetMsgCancelCollect)
    --获去收藏列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_MARK_LIST, self.OnNetMsgCollectItemsInfo)
    --获取历史记录
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_HISTORY_LIST, self.OnNetMsgHistoryInfo)
    --获取新的采集物
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_NOTIFY_HISTORY_UPDATE, self.OnNetMsgUpdateHitoryInfo)
    --获去拉取闹钟信息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_CLOCK, self.OnNetMsgClockInfo)
    --订阅列表更新，添加(采集闹钟和钓鱼闹钟通用)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_CLOCK_LIST_UPDATE, self.OnNetMsgItemInfoAfterSetClock)
    --订阅列表更新，删除(采集闹钟和钓鱼闹钟通用)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_CANCEL_CLOCK, self.OnNetMsgItemInfoAfterSetClock)
    --修改闹钟设置
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, SUB_MSG_ID.CS_CMD_NOTE_CLOCK_SET, self.OnNetMsgClockSettingInfo)
end

function GatheringLogMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch) --切换职业
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnGatherAlarmSidebarItemTimeOut) --侧边栏Item超时
    self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate) --升级
    self:RegisterGameEvent(EventID.MajorProfActivate, self.MajorProfActivate) --激活
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnUpdateQuest)--- 监听任务事件
end

function GatheringLogMgr:OnRegisterTimer()
    -- 注册一个全局闹钟计时器
    self:RegisterTimer(self.CheckShouldShowAlarmTip, 0.6, 0.6, -1)
end

function GatheringLogMgr:OnEnd()
    UIViewMgr:HideView(UIViewID.GatheringLogMainPanelView)
    self:SaveGatherToCloseAlarmGather()
    self:CloceClockAlarm(true)
end

function GatheringLogMgr:OnShutdown()
    self.LeftProfessionData = nil
    self.LastFilterState = nil
    self.LastSelectProfessMiner = nil
    self.LastSelectProfessBotanist = nil
    self.AllGatheringItemsInfo = nil
    self.SearchRecordList = nil
    self.SeleckClockCheckList = nil
    self.ClockSetting = nil
    self.AllHorbarsSelectData = nil
    self.knownLocList = nil
    self.GatherPlaceList = nil
    self.HistoryList = nil
    self.CollectList = nil
    self.ClockList = nil
end

function GatheringLogMgr:ClearOldData()
    self.LastFilterState = {}
end

function GatheringLogMgr:OnGameEventLoginRes()
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGatherNote) then
        return
    end
    self:SendMsgMarkListinfo(GatheringLogDefine.GatheringLogNoteType)
    local RoleDetail = ActorMgr:GetMajorRoleDetail()
    local Prof = RoleDetail and RoleDetail.Prof
    local ProfList = Prof and Prof.ProfList
    if table.is_nil_empty(ProfList) then
        return
    end
    local ProfID = GatheringLogDefine.ProfID
    if ProfList[ProfID.MinerJobID] == nil and ProfList[ProfID.BotanistJobID] == nil then
        return
    end
    self:SendMsgClockinfo(GatheringLogDefine.GatheringLogNoteType)
    self:SendMsgHistoryListinfo()
    for _, value in pairs(GatheringLogDefine.ProfID) do
        self:SendMsgUpdateDropNewData(value)
    end
    self:SendMsgQueryVersion()
end

function GatheringLogMgr:OnEventMajorProfSwitch()
    --若玩家正在追踪一个采集点，玩家切换至其他职业，此次追踪取消
    local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo and FollowInfo.FollowType == MapDefine.MapMarkerType.WorldMapGather then
        MsgTipsUtil.ShowTips(LSTR(70060)) --"因职业变更，追踪采集点取消"
		_G.WorldMapMgr:CancelMapFollow()
	end
    --切换职业时重置功能(笔记内通过采集追踪点切换除外)
    if not UIViewMgr:IsViewVisible(UIViewID.GatheringLogMainPanelView) then
        self.LastFilterState = {}
        self.LastSelectProfessMiner = {}
        self.LastSelectProfessBotanist = {}
        self.AllHorbarsSelectData = {}
    end
end

--region NetMsg
---@type 请求下拉或新增列表DropFilterList中新字的数据
---@param Index number @0表示查询，其余表示新增
function GatheringLogMgr:SendMsgUpdateDropNewData(Prof, Index, SpecialType, ReadVersion, IsRead, Volume)
    local appear = {}
    appear.Index = Index or 0
    appear.NoteType = GatheringLogDefine.GatheringLogNoteType
    appear.ProfID = Prof
    if SpecialType ~= 0 and SpecialType ~= nil then
        local SpecialData = {}
        SpecialData.SpecialType = SpecialType
        SpecialData.IsRead = IsRead
        SpecialData.ReadVersion = ReadVersion or 0
        SpecialData.Volume = Volume
        appear.SpecialData = SpecialData
    end

    -- local MsgID = CS_CMD.CS_CMD_NOTE
    -- local SubMsgID = SUB_MSG_ID.CS_CMD_COLLECTION_APPEAR
    -- local MsgBody = {}
    -- MsgBody.Cmd = SubMsgID
    -- MsgBody.appear = appear
    --GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 移除下拉列表DropFilterList中新字
function GatheringLogMgr:SendMsgRemoveDropNewData(Prof, Index, SpecialType, ReadVersion, IsRead, Volume)
    local appear = {}
    appear.Index = Index or 0
    appear.NoteType = GatheringLogDefine.GatheringLogNoteType
    appear.ProfID = Prof
    if SpecialType ~= 0 and SpecialType ~= nil then
        local SpecialData = {}
        SpecialData.SpecialType = SpecialType
        SpecialData.IsRead = IsRead
        SpecialData.ReadVersion = ReadVersion or 0
        SpecialData.Volume = Volume
        appear.SpecialData = SpecialData
    end

    -- local MsgID = CS_CMD.CS_CMD_NOTE
    -- local SubMsgID = SUB_MSG_ID.CS_CMD_COLLECTION_REMOVE_APPEAR
    -- local MsgBody = {}
    -- MsgBody.Cmd = SubMsgID
    -- MsgBody.removeAppear = appear
    -- GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 请求收藏
---@param NoteType table @笔记类型
---@param MarkID table @标记的收藏品
function GatheringLogMgr:SendMsgMarkOrNotinfo(NoteType, MarkID)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_MARK

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.mark = {}
    MsgBody.mark.NoteType = NoteType
    MsgBody.mark.MarkID = MarkID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 请求取消收藏
function GatheringLogMgr:SendMsgCancelMark(NoteType, MarkID)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_CANCEL_MARK

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.cancelMark = {}
    MsgBody.cancelMark.NoteType = NoteType
    MsgBody.cancelMark.MarkID = MarkID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 请求收藏列表
---@param NoteType table @笔记类型
function GatheringLogMgr:SendMsgMarkListinfo(NoteType)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_MARK_LIST

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.markList = {}
    MsgBody.markList.NoteType = NoteType
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 请求获得收藏品的历史记录
---@param NoteType table @笔记类型
function GatheringLogMgr:SendMsgHistoryListinfo(NoteType)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_HISTORY_LIST

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.historyList = {}
    MsgBody.historyList.NoteType = GatheringLogDefine.GatheringLogNoteType
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 发送闹钟相关信息
---@param NoteType table @笔记类型
function GatheringLogMgr:SendMsgClockinfo(NoteType)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_CLOCK

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.clock = {}
    MsgBody.clock.NoteType = NoteType
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 订阅列表更新，添加(采集闹钟和钓鱼闹钟通用)
---@param NoteType table @笔记类型
---@param Item table @订阅的采集物
function GatheringLogMgr:SendMsgAfterClockUpdate(NoteType, Item)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_CLOCK_LIST_UPDATE

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.clockUpdate = {}
    MsgBody.clockUpdate.NoteType = NoteType
    MsgBody.clockUpdate.Item = Item
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 订阅列表更新，删除(采集闹钟和钓鱼闹钟通用)
---@param NoteType table @笔记类型
---@param Item table @订阅的采集物
function GatheringLogMgr:SendMsgCancelClock(NoteType, Item)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_CANCEL_CLOCK

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.cancelClock = {}
    MsgBody.cancelClock.NoteType = NoteType
    MsgBody.cancelClock.Item = Item
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 请求修改闹钟设置
---@param NoteType table @笔记类型
---@param Setting table @闹钟设置
function GatheringLogMgr:SendMsgClockSettinginfo(NoteType, Setting)
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_CLOCK_SET

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.set = {}
    MsgBody.set.NoteType = NoteType
    MsgBody.set.Setting = Setting
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--查询版本号
function GatheringLogMgr:SendMsgQueryVersion()
    local MsgID = CS_CMD.CS_CMD_NOTE
    local SubMsgID = SUB_MSG_ID.CS_CMD_NOTE_QUERY_VERSION

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.queryVersion = {}
    MsgBody.queryVersion.NoteType = GatheringLogDefine.GatheringLogNoteType
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    self.IsSendMsgQueryVersion = true
end

function GatheringLogMgr:OnNetMsgQueryVersion(MsgBody)
    if MsgBody == nil or MsgBody.queryVersion == nil then
        return
    end
    local queryVersion = MsgBody.queryVersion
    if queryVersion.NoteType == nil or queryVersion.NoteType ~= GatheringLogDefine.GatheringLogNoteType then
        return
    end
    self:SaveUseLineageProf(queryVersion.Unlocks)

    if self.IsSendMsgQueryVersion == false then
        if not table.is_nil_empty(queryVersion.Unlocks) then
            local Unlock = queryVersion.Unlocks[1]
            local ReadData = self:GetSpecialReadData(Unlock.Prof, SpecialType.SpecialTypeInherit)
            local ReadVersion = ReadData and ReadData.ReadVersion or 0
            local IsRead = ReadData and ReadData.IsRead
            self:SendMsgUpdateDropNewData(Unlock.Prof, 0, SpecialType.SpecialTypeInherit, ReadVersion, IsRead, Unlock.Volume)
        end
        return
    end

    self.IsSendMsgQueryVersion = false
    --版本更新，检查传承录的更新
    self:UpdateInheritRedDot()
    --版本更新或使用完之后，更新特殊页签
    if UIViewMgr:FindVisibleView(UIViewID.GatheringLogMainPanelView) then
        if self.LastFilterState.HorTabsIndex == HorBarIndex.SpecialIndex then
            EventMgr:SendEvent(EventID.GatheringLogUpdateHorTabs,2)
            EventMgr:SendEvent(EventID.GatheringLogUpdateDropDownFilter,2)
        end
    end
end

function GatheringLogMgr:SaveUseLineageProf(Unlocks)
    self.UseLineageProf = self.UseLineageProf or {}
    if table.is_nil_empty(Unlocks) then
        return
    end
    for _, value in pairs(Unlocks) do
        local Prof = value.Prof
        if self.UseLineageProf[Prof] == nil then
            self.UseLineageProf[Prof] = {}
        end
        self.UseLineageProf[Prof][value.Volume] = true
    end
end

function GatheringLogMgr:GetGameVersionNum()
    local GetGameVersionNum = SaveMgr.GetInt(SaveKey.GatherNoteVersion, 0, true)
    if GetGameVersionNum ~= 0 then
        FLOG_INFO("GatheringLogMgr:GetGameVersionName SaveKey.GatherNoteVersion is %s", tostring(GetGameVersionNum))
        return GetGameVersionNum
    end
    local GameVersionCfg = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION)
    local VersionName = GameVersionCfg.Value
    if not table.is_nil_empty(VersionName) then
        GetGameVersionNum = VersionName[1] * 100 + VersionName[2] * 10 + VersionName[3]
    else
        GetGameVersionNum = GatheringLogDefine.DefaultGameVersionNum
    end
    return GetGameVersionNum
end

function GatheringLogMgr:SetGameVersionNameGM(Version)
    if string.isnilorempty(Version) then
        return
    end
    local GameVersionNum = self:VersionNameToNum(Version)
    SaveMgr.SetInt(SaveKey.GatherNoteVersion, GameVersionNum, true)
    self.GameVersionNum = GameVersionNum
    _G.CraftingLogMgr.GameVersionNum = GameVersionNum
end

function GatheringLogMgr:VersionNameToNum(Name)
    local Version = string.split(Name, ".")
    local VersionNum = Version[1] * 100 + Version[2] * 10 + Version[3]
    self.VersionNametoNum[Name] = VersionNum
    return VersionNum
end

function GatheringLogMgr:OnNetMsgCollectOrNotinfo(MsgBody)
    if nil == MsgBody or MsgBody.mark == nil then
        return
    end
    local NoteType = MsgBody.mark.NoteType
    if NoteType == nil or NoteType ~= GatheringLogType then
        return
    end
    local MarkID = MsgBody.mark.MarkID
    if MarkID == nil then
        FLOG_INFO("GatheringLogMgr CollectOrNotinfo MarkID is nil")
        return
    end
    local ItemData = _G.GatheringLogVM:GetItemDataByID(MarkID)
    local ItemVM = _G.GatheringLogVM:GetItemVMByItemID(ItemData.ItemID)
    if not ItemVM then
        FLOG_ERROR(string.format("GatheringLogMgr:ItemID = %d ,ItemVM is nil", ItemData.ItemID))
        return
    end
    self.CollectList = self.CollectList or {}
    self.CollectList[MarkID] = true
    ItemVM.bSetFavor = MsgBody.mark.IsMarked
    --更新右侧GatheringLogInfoPageView
    if ItemVM.bSelect then
        _G.GatheringLogVM.bSetFavor = ItemVM.bSetFavor
    end

    local CollectionIndex = HorBarIndex.CollectionIndex
    if self.LastFilterState.HorTabsIndex == CollectionIndex then
        EventMgr:SendEvent(EventID.GatheringLogUpdateDropDownFilter, CollectionIndex)
    end
end

function GatheringLogMgr:OnNetMsgCancelCollect(MsgBody)
    if nil == MsgBody or MsgBody.cancelMark == nil then
        return
    end
    local NoteType = MsgBody.cancelMark.NoteType
    if NoteType == nil or NoteType ~= GatheringLogType then
        return
    end
    local MarkID = MsgBody.cancelMark.MarkID
    if MarkID == nil then
        FLOG_INFO("GatheringLogMgr CollectOrNotinfo MarkID is nil")
        return
    end
    local ItemData = _G.GatheringLogVM:GetItemDataByID(MarkID)
    local ItemVM = _G.GatheringLogVM:GetItemVMByItemID(ItemData.ItemID)
    if not ItemVM then
        FLOG_ERROR(string.format("GatheringLogMgr:ItemID = %d ,ItemVM is nil", ItemData.ItemID))
        return
    end
    self.CollectList[MarkID] = nil
    ItemVM.bSetFavor = false
    --更新右侧GatheringLogInfoPageView
    if ItemVM.bSelect then
        _G.GatheringLogVM.bSetFavor = ItemVM.bSetFavor
    end

    local CollectionIndex = HorBarIndex.CollectionIndex
    if self.LastFilterState.HorTabsIndex == CollectionIndex then
        _G.GatheringLogVM.CurLogItemVMList:Remove(ItemVM)
        local Length = _G.GatheringLogVM.CurLogItemVMList:Length()
        if Length >= 1 then
            local Elem = _G.GatheringLogVM.CurLogItemVMList:Get(1)
            _G.GatheringLogVM:UpdateSelectItemTab(Elem.ID)
            EventMgr:SendEvent(EventID.GatheringLogUpdateDropDownProgress, CollectionIndex)
        else
            EventMgr:SendEvent(EventID.GatheringLogUpdateDropDownFilter, CollectionIndex)
        end
    end
end

---@type 收藏列表更新
---@param MsgBody table @主题信息
function GatheringLogMgr:OnNetMsgCollectItemsInfo(MsgBody)
    if nil == MsgBody then
        return
    end
    local markList = MsgBody.markList
    if markList == nil or markList.NoteType ~= GatheringLogType then
        return
    end
    local CollectItemList = markList.MarkList
    if #CollectItemList == 0 then
        return
    end
    self:UpdateGatherRsqItemVM(CollectItemList, UpdataType.CollectList)
end

---@type 历史记录回包
---@param MsgBody table @主题信息
function GatheringLogMgr:OnNetMsgHistoryInfo(MsgBody)
    if nil == MsgBody then
        return
    end
    local HistoryList = MsgBody.historyList
    if HistoryList == nil or HistoryList.NoteType ~= GatheringLogType then
        return
    end
    local ItemList = HistoryList.ItemList
    if #ItemList == 0 then
        return
    end
    self:UpdateGatherRsqItemVM(ItemList, UpdataType.HistoryList)
end

---@type 获得新的采集物是会触发
---@param MsgBody table @主题信息
function GatheringLogMgr:OnNetMsgUpdateHitoryInfo(MsgBody)
    if nil == MsgBody then
        return
    end
    local HistoryUpdate = MsgBody.historyUpdate
    if HistoryUpdate == nil or HistoryUpdate.NoteType ~= GatheringLogType then
        return
    end
    local ItemList = HistoryUpdate and HistoryUpdate.UpdateList
    if table.is_nil_empty(ItemList) then
        return
    end
    local Item = _G.GatheringLogVM:GetItemDataByID(ItemList[1].DoneID)
    if Item == nil then
        FLOG_ERROR("This GatherItem is Not Exiting in DataBase, Plesa Converting Excel Data To DataBase")
        return
    end
    if not self.HistoryList or not self.HistoryList[Item.ID] then
        -- 第一次采集到要出現提示。
        self:ShowTips(Item)
    end
    self:UpdateGatherRsqItemVM(ItemList, UpdataType.HistoryList)
end

---@type 第一次采集到某采集物时出现提示
---@param ItemList table @采集物列表
function GatheringLogMgr:ShowTips(Item)
    local GatherItemName = Item.Name
    local Simple = ActorMgr:GetMajorRoleDetail().Simple
    local RoleName = Simple.Name
    local Default = {Text1st = LSTR(70027), Text2nd = "", Text3rd = LSTR(70028)} --70027 将  70028 记录在了采集笔记上
    local Content =
        string.format(
        "%s%s%s%s%s%s",
        RoleName,
        Default.Text1st,
        Default.Text2nd,
        GatherItemName,
        Default.Text2nd,
        Default.Text3rd
    )
    MsgTipsUtil.ShowActiveTips(Content, nil, nil, nil)
end

---@type 更新收到回包后的采集物信息
---@param List table @信息列表
---@param Type number @类型
function GatheringLogMgr:UpdateGatherRsqItemVM(List, Type)
    local CurLogItemVMList = _G.GatheringLogVM.CurLogItemVMList:GetItems()
    for i = 1, #List do
        for _, v in pairs(CurLogItemVMList) do
            local Elem = v
            local ListElem = List[i]
            if Type == UpdataType.HistoryList and Elem.ID == ListElem.DoneID then
                Elem.bGot = true
                self:SetPlaceUnknownLocTrue(Elem)
                break
            elseif Type == UpdataType.CollectList and Elem.ID == ListElem then
                Elem.bSetFavor = true
                break
            elseif Type == UpdataType.ClockList and Elem.ID == ListElem then
                Elem.bSetClock = true
                break
            end
        end
    end

    if Type == UpdataType.HistoryList then
        self.HistoryList = self.HistoryList or {}
        for i = 1, #List do
            local ListElem = List[i]
            self.HistoryList[ListElem.DoneID] = true
            local Item = GatherNoteCfg:FindCfgByKey(ListElem.DoneID)
            self:SetPlaceUnknownLocTrue(Item)
        end
    elseif Type == UpdataType.CollectList then
        self.CollectList = self:SaveGatherRsqList(List)
    elseif Type == UpdataType.ClockList then
        self.ClockList = self:SaveGatherRsqList(List)
    end
end

function GatheringLogMgr:SaveGatherRsqList(List)
    local SaveList = {}
    for i = 1, #List do
        local ListElemID = List[i]
        SaveList[ListElemID] = true
    end
    return SaveList
end

---@type 解锁未知采集点
function GatheringLogMgr:SetPlaceUnknownLocTrue(Item)
    local ExistPlace = self:GetGatherPlaceByItemData(Item)
    self.knownLocList = self.knownLocList or {}
    for i = 1, #ExistPlace do
        local PlaceElem = ExistPlace[i]
        if PlaceElem and PlaceElem.IsUnknownLoc == 1 then
            self.knownLocList[PlaceElem.ID] = true
            local PlaceElemVM = _G.GatheringLogVM:GetPlaceItemByID(PlaceElem.ID)
            if PlaceElemVM then
                PlaceElemVM:SetUnknownLocTrue(PlaceElem)
            end
        end
    end
end
--endregion

--region =========================采集闹钟 Begin===================================================
---@type 闹钟回包
---@param MsgBody table @主题信息
function GatheringLogMgr:OnNetMsgClockInfo(MsgBody)
    if nil == MsgBody or MsgBody.clock == nil then
        return
    end
    local ClockInfo = MsgBody.clock.ClockInfo
    if ClockInfo.NoteType ~= GatheringLogDefine.GatheringLogNoteType then
        return
    end
    local Setting = ClockInfo.Setting
    if Setting.IsFirstSet then
        Setting.ComingNotify = 1
        Setting.Sound = false
        Setting.CloseNotify = true
    end
    self.ClockSetting = Setting
    self:SetAdvanceRemindersTime(Setting)
    local ClockItemList = ClockInfo.SubscribeList
    if #ClockItemList == 0 then
        return
    end
    self:UpdateGatherRsqItemVM(ClockItemList, UpdataType.ClockList)
end

function GatheringLogMgr:OnNetMsgItemInfoAfterSetClock(MsgBody)
    if nil == MsgBody then
        return
    end
    local ClockMsg = MsgBody.clockUpdate or MsgBody.cancelClock
    if ClockMsg == nil then
        return
    end
    local Result = ClockMsg.Result
    if #Result < 0 then
        FLOG_ERROR("GatheringLogMgr:MsgBody.clockUpdate.Result's number is 0")
        return
    end
    if Result.NoteType ~= GatheringLogDefine.GatheringLogNoteType then
        return
    end

    local ItemData = _G.GatheringLogVM:GetItemDataByID(Result.ItemID)
    if not ItemData then
        FLOG_ERROR("GatheringLogMgr:ItemData is nil")
        return
    end
    local ItemVM = _G.GatheringLogVM:GetItemVMByItemID(ItemData.ItemID)
    if not ItemVM then
        FLOG_ERROR(string.format("GatheringLogMgr:ItemID = %d ,ItemVM is nil", ItemData.ItemID))
        return
    end
    self.ClockList = self.ClockList or {}
    if Result.IsSubscribe == false then
        self.ClockList[ItemData.ID] = nil
    else
        self.ClockList[ItemData.ID] = Result.IsSubscribe
    end
    ItemVM.bSetClock = Result.IsSubscribe
    --更新右侧GatheringLogInfoPageView
    if ItemVM.bSelect then
        _G.GatheringLogVM.bSetClock = ItemVM.bSetClock
    end

    local ClockIndex = HorBarIndex.ClockIndex
    if self.LastFilterState.HorTabsIndex == ClockIndex then
        if self.LastFilterState.HorTabsIndex == ClockIndex then
            _G.GatheringLogVM.CurLogItemVMList:Remove(ItemVM)
            local Length = _G.GatheringLogVM.CurLogItemVMList:Length()
            if Length >= 1 then
                local Elem = _G.GatheringLogVM.CurLogItemVMList:Get(1)
                _G.GatheringLogVM:UpdateSelectItemTab(Elem.ID)
                EventMgr:SendEvent(EventID.GatheringLogUpdateDropDownProgress, ClockIndex)
            else
                EventMgr:SendEvent(EventID.GatheringLogUpdateDropDownFilter, ClockIndex)
            end
        end
    end
    self:SendClockDataReportor(1, ItemData, nil, Result.IsSubscribe)
end

function GatheringLogMgr:OnNetMsgClockSettingInfo(MsgBody)
    if nil == MsgBody then
        return
    end
    _G.MsgTipsUtil.ShowTips(LSTR(70059)) --"闹钟设置更改成功"
    local Set = MsgBody.set
    if Set == nil then
        return
    end
    local Setting = Set.Setting
    self.ClockSetting = Setting
    self:SetAdvanceRemindersTime(Setting)
end

---@type 根据闹钟设置来设置提前的时间
---@param Setting table @闹钟设置
function GatheringLogMgr:SetAdvanceRemindersTime(Setting)
    local IsComingNotify = Setting.IsComingNotify
    if IsComingNotify then
        if Setting.ComingNotify < self.AdvanceRemindTime then
            self.AdvancePromptedAlarmGather = {}
        end
        self.AdvanceRemindTime = Setting.ComingNotify
    else
        self.AdvanceRemindTime = 0
    end
end

---@type 总检测是否应该出现闹钟提示（游戏状态可否提醒，闹钟设置是否提醒，闹钟是否到提醒时间（同一时间提醒一次））
function GatheringLogMgr:CheckShouldShowAlarmTip()
    local MapLoadStatus = {
        Loading = 1,
        Finish = 2
    }
    local ClockSetting = self.ClockSetting
    local CloseNotify = ClockSetting.CloseNotify
    local Trigger = ClockSetting.Trigger
    -- 加载界面，勾选了副本不提示且副本/水晶冲突副本中，主界面提示未勾选，或提前和正点都未勾选 则不通知
    if PWorldMgr.MapTravelInfo.TravelStatus == MapLoadStatus.Loading or ((PWorldMgr:CurrIsInDungeon() or _G.PWorldMgr:CurrIsInPVPColosseum())and CloseNotify)
        or not Trigger or (not ClockSetting.IsComingNotify and not ClockSetting.StartNotify) then
        return
    end
    local GatherItemWithAlarm = self.ClockList or {}
    self:CheckCanAlarmAgain()
    for ID, _ in pairs(GatherItemWithAlarm) do
        local Elem = self:GetGatherItemInfoByID(ID)
        if Elem then
            self:CheckShowAlarmTip(Elem.TimeCondition, Elem.Cfg)
        end
    end
end

---@type __检测是否需要展示闹钟提示前_把过了采集时间可以再次提示的采集物_从暂时不能出现闹钟提醒的采集物列表中剔除(删)
function GatheringLogMgr:CheckCanAlarmAgain()
    local ServerTime = TimeUtil.GetServerLogicTime()
    local AozyTimeDefine = TimeDefine.AozyTimeDefine
    local OneMinSec = 60
    local OneDaySec = 86400
    -- RealSec2AozyMin = 12/35
    local RealSec2AozyMin = AozyTimeDefine.RealSec2AozyMin
    local AozySecond = ServerTime * (RealSec2AozyMin) * OneMinSec
    local CurDayTime = AozySecond % OneDaySec
    local PromptedAlarmGather = self.PromptedAlarmGather
    local AdvancePromptedAlarmGather = self.AdvancePromptedAlarmGather
    -- 过了这个采集段结束时间，移除，可进行下个时间段的提示
    if not table.is_nil_empty(PromptedAlarmGather) then
        for i, v in pairs(PromptedAlarmGather) do
            local Elem = v
            if CurDayTime > Elem.EndAozyTime then
                table.remove(PromptedAlarmGather, i)
            end
        end
    end
    if not table.is_nil_empty(AdvancePromptedAlarmGather) then
        for i, v in pairs(AdvancePromptedAlarmGather) do
            local Elem = v
            if CurDayTime > Elem.EndAozyTime then
                local AdvanceAozySec = math.floor(self.AdvanceRemindTime * OneMinSec * RealSec2AozyMin * OneMinSec) --提前的艾欧泽亚的秒数
                local AdvancedTime = Elem.StartAozyTime - AdvanceAozySec
                if AdvancedTime < 0 then
                    AdvancedTime = AdvancedTime + OneDaySec
                    if CurDayTime < AdvancedTime then
                        table.remove(AdvancePromptedAlarmGather, i)
                    end
                else
                    table.remove(AdvancePromptedAlarmGather, i)
                end
            end
        end
    end
end

---@type 检测是否需要展示闹钟提示
---@param TimeCondition table @时间条件
---@param GatherItem table @采集物
function GatheringLogMgr:CheckShowAlarmTip(TimeCondition, GatherItem)
    local ServerTime = TimeUtil.GetServerLogicTime()
    local AozyTimeDefine = TimeDefine.AozyTimeDefine
    local OneMinSec = 60
    -- RealSec2AozyMin = 12/35
    local RealSec2AozyMin = AozyTimeDefine.RealSec2AozyMin
    local AozySecond = ServerTime * (RealSec2AozyMin) * OneMinSec
    local Conditions = string.split(TimeCondition, ";")
    local OneDaySec = 86400
    local CurDayTime = AozySecond % OneDaySec
    local AdvanceRemindTime = self.AdvanceRemindTime -- 1 or 3 or 5 minute
    local AdvanceAozySec = math.floor(AdvanceRemindTime * OneMinSec * RealSec2AozyMin * OneMinSec) --提前的艾欧泽亚的秒数
    local bIsComingNotify = self.ClockSetting.IsComingNotify
    local bStartNotify = self.ClockSetting.StartNotify
    -- 如果开启了开始时出现的设置，则判断是否已经出现
    if bStartNotify then
        for _, v in pairs(Conditions) do
            local Elem = v
            local StartAozyTime, EndAozyTime = self:GetStartAndEndAozyTime(Elem)
            if CurDayTime >= StartAozyTime and CurDayTime <= EndAozyTime then
                -- 如果不是某段时间已经提示过的采集物，且不是在同一时间点出现的采集物，才可出现提示
                if not self:CheckIsPromptedAlarmGather(GatherItem, true) then
                    self:ShowShowAlarmTip(GatherItem, StartAozyTime, EndAozyTime, 0, true)
                    break
                end
            end
        end
    end
    -- 没有设置提前提醒，则返回
    if not bIsComingNotify then
        return
    end
    --检测是否到达了将时间提前后了的时间点
    for _, v in pairs(Conditions) do
        local Elem = v
        local StartAozyTime, EndAozyTime = self:GetStartAndEndAozyTime(Elem)
        local AdvancedTime = StartAozyTime - AdvanceAozySec
        local RemainTimeAozy = AdvancedTime < 0 and (StartAozyTime - CurDayTime + OneDaySec) or (StartAozyTime - CurDayTime)
        local RemainTime = math.floor(RemainTimeAozy / OneMinSec * AozyTimeDefine.AozyMin2RealSec) -- 还剩多少分s开始(现实时间)
        -- 判断在提前出现的情况
        if (AdvancedTime > 0 and CurDayTime >= AdvancedTime and CurDayTime < StartAozyTime) or (AdvancedTime < 0 and CurDayTime >= OneDaySec + AdvancedTime and CurDayTime < OneDaySec) then
            -- 判断是否在开始时间的提前时间内（比如，9：00开始，设置3分钟前，判断是否在 8：57 —— 9：00 之间）或 假如提前时间算到前一天去了，那就加一天时间（比如算到前一天23：58了，说明今天23：58时应该提醒，当前时间在[23:58,00:00]这个时间段内就该提醒）
            if not self:CheckIsPromptedAlarmGather(GatherItem,false) then
                self:ShowShowAlarmTip(GatherItem, StartAozyTime, EndAozyTime,  RemainTime, false)
                return
            end
        end
    end
end

---@type __提示之前_检查是否是已经提示过了的采集物（查）
---@param GatherItem number @采集物
function GatheringLogMgr:CheckIsPromptedAlarmGather(GatherItem, IsAppearing)
    local PromptedAlarmGather = IsAppearing and self.PromptedAlarmGather or self.AdvancePromptedAlarmGather
    for _, v in pairs(PromptedAlarmGather) do
        local Elem = v
        if Elem.ID == GatherItem.ID then
            return true
        end
    end
    return false
end

---@type 得到时间戳 例：9：00~11：00 返回 9：00在当日对应的秒数 11：00返回在当日对应的秒数
function GatheringLogMgr:GetStartAndEndAozyTime(Time)
    local StartAndEndTime = StringTools.StringSplit(Time, " - ")
    local StartTime = StartAndEndTime[1]
    local EndTime = StartAndEndTime[3]
    local OneHourSec = 3600
    local OneMinSec = 60
    local EndTimeIndex = 2

    local StartHourAndMinute = StringTools.StringSplit(StartTime, ":")
    local StartHour = tonumber(StartHourAndMinute[1])
    local MinIndex = 2
    local StartMinute = tonumber(StartHourAndMinute[MinIndex])
    local StartAozyTime = StartHour * OneHourSec + StartMinute * OneMinSec

    local EndHourAndMinute = StringTools.StringSplit(EndTime, ":")
    local EndHour = tonumber(EndHourAndMinute[1])
    local EndMinute = tonumber(EndHourAndMinute[EndTimeIndex])
    local EndAozyTime = EndHour * OneHourSec + EndMinute * OneMinSec
    return StartAozyTime, EndAozyTime
end

---@type __提示之后_把采集物加入展示不提醒的行列（增）
---@param GatherItem number @采集物
---@param EndAozyTime number @某采集物结束的艾欧泽亚时间（时间戳）
function GatheringLogMgr:AddGatherToCloseAlarmGather(GatherItemID, StartAozyTime, EndAozyTime, IsAppearing)
    local TempTable = {}
    TempTable.ID = GatherItemID
    TempTable.EndAozyTime = EndAozyTime
    TempTable.StartAozyTime = StartAozyTime
    if IsAppearing then
        table.insert(self.PromptedAlarmGather, TempTable)
    else
        table.insert(self.AdvancePromptedAlarmGather, TempTable)
    end
end

function GatheringLogMgr:GetGatherToCloseAlarmGather()
    local JsonStr = SaveMgr.GetString(SaveKey.PromptedAlarmGather, "", true)
    self.PromptedAlarmGather = string.isnilorempty(JsonStr) and {} or Json.decode(JsonStr)
    local JsonStr = SaveMgr.GetString(SaveKey.AdvancePromptedAlarmGather, "", true)
    self.AdvancePromptedAlarmGather = string.isnilorempty(JsonStr) and {} or Json.decode(JsonStr)
end

function GatheringLogMgr:SaveGatherToCloseAlarmGather()
    local PromptedAlarmGather = Json.encode(self.PromptedAlarmGather)
    SaveMgr.SetString(SaveKey.PromptedAlarmGather, PromptedAlarmGather, true)
    local AdvancePromptedAlarmGather = Json.encode(self.AdvancePromptedAlarmGather)
    SaveMgr.SetString(SaveKey.AdvancePromptedAlarmGather, AdvancePromptedAlarmGather, true)
end

---@type 出现侧边提示
---@param GatherItem number @采集物
---@param EndAozyTime number @某采集物结束的艾欧泽亚时间（时间戳）
---@param AdvanceRemindTime number @提前多少时间
---@param IsAppearing number @是否正在出现中
function GatheringLogMgr:ShowShowAlarmTip(GatherItem, StartAozyTime, EndAozyTime, RemainTime, IsAppearing)
    self:AddGatherToCloseAlarmGather(GatherItem.ID, StartAozyTime, EndAozyTime, IsAppearing)
    -- 先检测属于那个职业的采集物，再设置提示内容，然后加载侧边提示，最后那该采集物记录下来（该时间段不再提示）
    local TransData = self:SetAlarmTipContent(RemainTime, IsAppearing)
    TransData.GatherItem = GatherItem
    TransData.ResID = GatherItem.ItemID
    TransData.IsAppearing = IsAppearing
    local SidebarType = GatheringLogDefine.GatheringLogSliderType[GatherItem.GatheringJob]
    SidebarMgr:RemoveSidebarItemByParam(TransData.GatherItem, "GatherItem")
    self:CloceClockAlarm()
    self:TryAddSidebarItem(SidebarType, GatheringLogDefine.SidebarCountDown, TransData)
end

---@type 设置提示的职业
---@param GatheringJob number @职业ID
function GatheringLogMgr:CheckAlarmExistProf(GatheringJob)
    local ProfID = GatheringLogDefine.ProfID
    local AlarmExistProf = self.AlarmExistProf
    if GatheringJob == ProfID.MinerJobID then
        AlarmExistProf.bMiner = true
        return LSTR(70031) --采矿物
    elseif GatheringJob == ProfID.BotanistJobID then
        AlarmExistProf.bBotanist = true
        return LSTR(70032) --采集物
    end
end

---@type 设置闹钟提示的文本
---@param AdvanceRemindTime number @提前多少时间
---@param IsAppearing number @是否正在出现中
function GatheringLogMgr:SetAlarmTipContent(RemainTime, IsAppearing)
    local TipContent
    local TransData = {}
    if IsAppearing or RemainTime == 0 then
        TipContent = LSTR(180100)--"活跃出现中"
    else
        local RemainTimeText = LocalizationUtil.GetCountdownTimeForLongTime(RemainTime or 0)
        TipContent = string.format(LSTR(180099), RemainTimeText)
    end
    TransData.TipContent = TipContent
    return TransData
end

---@type 生成侧边提示
---@param CountDown number @进度条消失的时间
function GatheringLogMgr:TryAddSidebarItem(SidebarType, CountDown, TransData)
    local StartTime = TimeUtil.GetServerLogicTime()
    SidebarMgr:AddSidebarItem(SidebarType, StartTime, CountDown, TransData)
    self:StartClockAlarm()
    self:SendClockDataReportor(2, TransData.GatherItem, TransData.IsAppearing)
end

function GatheringLogMgr:StartClockAlarm()
    if self.ClockSetting and self.ClockSetting.Sound then
        local ClockAlarmID = AudioUtil.LoadAndPlayUISound(GatheringLogDefine.ClockSoundPath)
        self.ClockAlarmList = self.ClockAlarmList or {}
        table.insert(self.ClockAlarmList, ClockAlarmID)
    end
end

function GatheringLogMgr:CloceClockAlarm(CloseAll)
    if not table.is_nil_empty(self.ClockAlarmList) then
        if CloseAll then
            for _, value in pairs(self.ClockAlarmList) do
                AudioUtil.StopAsyncAudioHandle(value)
            end
        else
            local ClockAlarmID = table.remove(self.ClockAlarmList, 1)
            AudioUtil.StopAsyncAudioHandle(ClockAlarmID)
        end
    end
end

---@type 出现闹钟提示
---@param StartTime number @开始时间
---@param CountDown number @持续多少s
function GatheringLogMgr:OpenGatheringLogAlarmSidebar(StartTime, CountDown, TransData, Type)
    _G.FLOG_INFO("TransData.TipContent:%s", TransData.TipContent)
    local Params = {
        Title = LSTR(70035), --采集闹钟提醒
        Desc1 = TransData.GatherItem.Name or "",
        Desc2 = TransData.TipContent,
        StartTime = StartTime,
        CountDown = CountDown,
        BtnTextLeft = LSTR(180005),--关闭
        BtnTextRight = LSTR(70037), --查看
        CBFuncRight = self.AcceptCallBack,
        CBFuncLeft = self.IgnoreCallBack,
        Type = Type,
        --透传数据
        TransData = TransData
    }
    UIViewMgr:ShowView(UIViewID.SidebarFishClock, Params)
end

---@type 接受按钮的回调
function GatheringLogMgr:AcceptCallBack(TransData)
    local GatherItem = TransData.GatherItem
    --local SidebarType = GatheringLogDefine.GatheringLogSliderType[GatherItem.GatheringJob]
    SidebarMgr:RemoveSidebarItemByParam(TransData.GatherItem, "GatherItem")
    GatheringLogMgr:CloceClockAlarm()

    --处于封闭任务中
    local RoleVM = MajorUtil.GetMajorRoleVM()
    if RoleVM and OnlineStatusUtil.CheckBit(RoleVM.OnlineStatus, ProtoRes.OnlineStatus.OnlineStatusCloseTask) then
        MsgTipsUtil.ShowTips(LSTR(70057)) --正处于封闭任务中，无法打开采集笔记
        return
    end

    local Params = TransData
    if not UIViewMgr:IsViewVisible(UIViewID.GatheringLogMainPanelView) then
        UIViewMgr:ShowView(UIViewID.GatheringLogMainPanelView)
        EventMgr:SendEvent(EventID.GatheringLogSetFiltraSelect, Params)
    else
        EventMgr:SendEvent(EventID.GatheringLogSetFiltraSelect, Params)
    end

    GatheringLogMgr:SendClockDataReportor(3, GatherItem, TransData.IsAppearing)
end

function GatheringLogMgr:IgnoreCallBack(TransData)
    local GatherItem = TransData.GatherItem
    local SidebarType = GatheringLogDefine.GatheringLogSliderType[GatherItem.GatheringJob]
    SidebarMgr:RemoveSidebarItemByParam(TransData.GatherItem, "GatherItem")
    GatheringLogMgr:CloceClockAlarm()
end

---@type 采集笔记进度条减少到没有时调用
---@param Type number @笔记类型
function GatheringLogMgr:OnGatherAlarmSidebarItemTimeOut(Type, TransData)
    local MinerJobID = GatheringLogDefine.ProfID.MinerJobID
    local BotanistJobID = GatheringLogDefine.ProfID.BotanistJobID
    if Type == nil or (Type ~= GatheringLogDefine.GatheringLogSliderType[MinerJobID] and Type ~= GatheringLogDefine.GatheringLogSliderType[BotanistJobID]) then
        return
    end
    if TransData == nil then
        --FLOG_ERROR("GatheringLogMgr:OnGatherAlarmSidebarItemTimeOut TransData is nil")
        local SidebarType = GatheringLogDefine.GatheringLogSliderType
        for _, Value in pairs(SidebarType) do
            if Value == Type then
                SidebarMgr:RemoveSidebarItem(Type)
                GatheringLogMgr:CloceClockAlarm(true)
            end
        end
    else
        SidebarMgr:RemoveSidebarItemByParam(TransData.GatherItem, "GatherItem")
        GatheringLogMgr:CloceClockAlarm()
    end
end

--闹钟触发流水[1-设置闹钟、2-闹钟触发、3-点击前往]
function GatheringLogMgr:SendClockDataReportor(OpType, ItemData, IsAppearing, IsSubscribe)
    local CollectingID = ItemData.ID --采集物ID
    local AlarmTime = -1
    if OpType == 1 then
        local ClockSetting = self.ClockSetting
        if ClockSetting.StartNotify and ClockSetting.IsComingNotify then
            AlarmTime = 2
        elseif ClockSetting.StartNotify then
            AlarmTime = 0
        elseif ClockSetting.IsComingNotify then
            AlarmTime = 1
        end
        IsSubscribe =  IsSubscribe and 1 or 0
    else
        AlarmTime = IsAppearing and 0 or self.ClockSetting.ComingNotify
    end
    DataReportUtil.ReportSystemFlowData("AlarmTriggeredFlow", OpType, CollectingID, AlarmTime, IsSubscribe)
end
--endregion =========================采集闹钟 End==========================================================================

--region ===========================红点 begin==========================================================================

---@type 获取或更新采集笔记获得下拉列表的红点
function GatheringLogMgr:OnNetMsgAddGatherNoteNewData(MsgBody)
    if nil == MsgBody or nil == MsgBody.appear or nil == MsgBody.appear.NoteAppear then
        return
    end
    local AllNoteAppear = MsgBody.appear.NoteAppear
    if #AllNoteAppear == 0 then
        return
    end

    for _, NoteAppear in pairs(AllNoteAppear) do
        if NoteAppear.NoteType ~= GatheringLogDefine.GatheringLogNoteType then
            break
        end
        local ProfID = NoteAppear.ProfID

        if self.NormalDropRedDotLists == nil then
            self.NormalDropRedDotLists = {}
        end
        --普通页签
        if not (table.is_nil_empty(self.NormalDropRedDotLists[ProfID]) and table.is_nil_empty(NoteAppear.IndexList)) then
            self.NormalDropRedDotLists[ProfID] = NoteAppear.IndexList
            self:NormalRedDotDataUpdate(ProfID)
        end

        if self.SpecialDropRedDotLists == nil then
            self.SpecialDropRedDotLists = {}
        end
        for _, value in pairs(NoteAppear.IndexList) do
            if value == 100 then
                if self.SpecialDropRedDotLists[ProfID] == nil then
                    self.SpecialDropRedDotLists[ProfID] = {}
                end
                self.SpecialDropRedDotLists[ProfID][3] = {ReadVersion = 0, Volume = 0, IsRead = false, SpecialType = 3}
                self:SpecialRedDotDataUpdate(ProfID)
                break
            end
        end
        --特殊页签
        local SpecialData = NoteAppear.SpecialData
        if not table.is_nil_empty(SpecialData) then
            if self.SpecialDropRedDotLists[ProfID] == nil then
                self.SpecialDropRedDotLists[ProfID] = {}
            end
            for _, value in pairs(SpecialData) do
                local Type = value.SpecialType
                if Type ~= 0 then
                    self.SpecialDropRedDotLists[ProfID][Type] = value
                end
            end
            self:SpecialRedDotDataUpdate(ProfID)
        end
    end

    local function SendUpdateTabRedDot()
        EventMgr:SendEvent(EventID.UpdateTabRedDot)
        if self.LastFilterState.HorTabsIndex == HorBarIndex.SpecialIndex then
            EventMgr:SendEvent(EventID.GatheringLogUpdateHorTabs, 2)
        end
        self.UpdateTabRedDotTimer = nil
    end
    if self.UpdateTabRedDotTimer == nil then
        self.UpdateTabRedDotTimer = self:RegisterTimer(SendUpdateTabRedDot, 0.2, 1, 1)
    end
end

---@type 红点系统增删调用普通页签
function GatheringLogMgr:NormalRedDotDataUpdate(Prof, IsRemove)
    local HorIndex = HorBarIndex.NormalIndex
    local DropRedDotLists = self.NormalDropRedDotLists[Prof]
    local bShowHorIndexRedDot = #DropRedDotLists > 0

    --弱红点提醒
    local ProfRedDotName = self:GetRedDotName(Prof, nil, nil, GatheringLogDefine.RedDotID.GarherLogProf)
    local HorIndexRedDotName = self:GetRedDotName(Prof, HorIndex, nil, GatheringLogDefine.RedDotID.GarherLogProf)
    if bShowHorIndexRedDot and not IsRemove then --- 新增
        if not HorIndexRedDotName then
            --左侧职业列表的红点
            if not ProfRedDotName then
                ProfRedDotName = RedDotMgr:AddRedDotByParentRedDotID(GatheringLogDefine.RedDotID.GarherLogProf)
                local ProfRedNode = RedDotMgr:FindRedDotNodeByName(ProfRedDotName)
                if ProfRedNode then
                    ProfRedNode.ProfID = Prof
                    ProfRedNode.SubRedDotList = {}
                end
            end

            --上方普通页签的红点
            HorIndexRedDotName = RedDotMgr:AddRedDotByParentRedDotName(ProfRedDotName)
            local HorIndexRedNode = RedDotMgr:FindRedDotNodeByName(HorIndexRedDotName)
            if HorIndexRedNode then
                HorIndexRedNode.HorIndex = HorIndex
                HorIndexRedNode.SubRedDotList = {}
            end
        end

        --下拉框列表的红点
        for _, DropDownIndex in pairs(DropRedDotLists) do
            local RedDotName =
                self:GetRedDotName(Prof, HorIndex, DropDownIndex, GatheringLogDefine.RedDotID.GarherLogProf)
            if not RedDotName then
                RedDotName = string.format("%s/%s级", HorIndexRedDotName, DropDownIndex)
                RedDotMgr:AddRedDotByName(RedDotName)
                --RedDotName = RedDotMgr:AddRedDotByParentRedDotName(HorIndexRedDotName)
                local RedNode = RedDotMgr:FindRedDotNodeByName(RedDotName)
                if RedNode then
                    RedNode.DropDownIndex = DropDownIndex
                end
            end
        end
    end

    ---删除
    if not bShowHorIndexRedDot and HorIndexRedDotName then
        local IsDel = RedDotMgr:DelRedDotByName(HorIndexRedDotName)
        if IsDel then
            local TheOtherRedDotName = self:GetRedDotName(Prof, GatheringLogDefine.HorBarIndex.SpecialIndex,nil, GatheringLogDefine.RedDotID.GarherLogProf)
            if not TheOtherRedDotName then
                RedDotMgr:DelRedDotByName(ProfRedDotName)
            end
        end
    end
end

---@type 红点系统增删调用特殊页签
function GatheringLogMgr:SpecialRedDotDataUpdate(Prof)
    local HorIndex = HorBarIndex.SpecialIndex
    local DropRedDotLists = self.SpecialDropRedDotLists[Prof]
    local SpecialAddRedDots = {}

    --强红点提醒（下拉框为叶子节点）
    if DropRedDotLists then
        local IsAllRead = true
        local RedDotID = GatheringLogDefine.RedDotID.GarherLog
        local ProfRedDotNameStrong = self:GetRedDotName(Prof, nil, nil, RedDotID)
        for _, value in pairs(DropRedDotLists) do
            if value.SpecialType ~= 0 then
                if value.IsRead == false then
                    IsAllRead = false
                    --左侧职业列表的红点
                    if not ProfRedDotNameStrong then
                        ProfRedDotNameStrong = RedDotMgr:AddRedDotByParentRedDotID(RedDotID)
                        local ProfRedNodeStrong = RedDotMgr:FindRedDotNodeByName(ProfRedDotNameStrong)
                        ProfRedNodeStrong.ProfID = Prof
                        ProfRedNodeStrong.IsStrongReminder = true
                        ProfRedNodeStrong.SubRedDotList = {}
                    end

                    --上方普通页签的红点
                    local HorIndexRedDotName = self:GetRedDotName(Prof, HorBarIndex.SpecialIndex, nil, RedDotID)
                    if HorIndexRedDotName == nil then
                        HorIndexRedDotName = RedDotMgr:AddRedDotByParentRedDotName(ProfRedDotNameStrong)
                        local HorIndexRedNode = RedDotMgr:FindRedDotNodeByName(HorIndexRedDotName)
                        HorIndexRedNode.HorIndex = HorBarIndex.SpecialIndex
                        HorIndexRedNode.IsStrongReminder = true
                        HorIndexRedNode.SubRedDotList = {}
                    end

                    --下拉框列表的红点
                    local RedDotName = RedDotMgr:AddRedDotByParentRedDotName(HorIndexRedDotName)
                    local RedNode = RedDotMgr:FindRedDotNodeByName(RedDotName)
                    RedNode.DropDownIndex = value.SpecialType
                    RedNode.IsStrongReminder = true
                end

                --检测弱红点是否提醒
                if value.SpecialType == SpecialType.SpecialTypeInherit and self.UseLineageProf[Prof] ~= nil then
                    if value.ReadVersion == 0 or self:BeIncludedInGameVersionNum(value.ReadVersion) or
                            (value.ReadVersion == GatheringLogMgr.GameVersionNum and
                        self:IsHaveUnReadLInheritVolume(Prof, value.Volume)) then
                        SpecialAddRedDots[SpecialType.SpecialTypeInherit] = true
                    end
                elseif value.SpecialType == SpecialType.SpecialTypeCollection and value.IsRead == true then
                    --value.ReadVersion < MajorUtil.GetMajorLevelByProf(Prof)
                    SpecialAddRedDots[SpecialType.SpecialTypeCollection] = true
                end
            end
        end

        ---强红点删除
        if IsAllRead then
            local HorIndexRedDotName = self:GetRedDotName(Prof, HorBarIndex.SpecialIndex, nil, RedDotID)
            if HorIndexRedDotName then
                local IsDel = RedDotMgr:DelRedDotByName(HorIndexRedDotName)
                if IsDel and ProfRedDotNameStrong then
                    RedDotMgr:DelRedDotByName(ProfRedDotNameStrong)
                    local RedNodeStrong = RedDotMgr:FindRedDotNodeByID(RedDotID)
                    if RedNodeStrong and table.is_nil_empty(RedNodeStrong.SubRedDotList) then
                        RedDotMgr:DelRedDotByID(RedDotID)
                    end
                end
            end
        end
    end

    --弱红点提醒
    local ProfRedDotName = self:GetRedDotName(Prof, nil, nil, GatheringLogDefine.RedDotID.GarherLogProf)
    local HorIndexRedDotName = self:GetRedDotName(Prof, HorIndex, nil, GatheringLogDefine.RedDotID.GarherLogProf)
    if not table.is_nil_empty(SpecialAddRedDots) then --- 新增
        if not HorIndexRedDotName then
            --左侧职业列表的红点
            if not ProfRedDotName then
                ProfRedDotName = RedDotMgr:AddRedDotByParentRedDotID(GatheringLogDefine.RedDotID.GarherLogProf)
                local ProfRedNode = RedDotMgr:FindRedDotNodeByName(ProfRedDotName)
                if ProfRedNode then
                    ProfRedNode.ProfID = Prof
                    ProfRedNode.SubRedDotList = {}
                end
            end

            --上方普通页签的红点
            HorIndexRedDotName = RedDotMgr:AddRedDotByParentRedDotName(ProfRedDotName)
            local HorIndexRedNode = RedDotMgr:FindRedDotNodeByName(HorIndexRedDotName)
            if HorIndexRedNode then
                HorIndexRedNode.HorIndex = HorIndex
                HorIndexRedNode.SubRedDotList = {}
            end
        end

        --下拉框列表的红点
        for _, DropDownIndex in pairs(DropRedDotLists) do
            if SpecialAddRedDots[DropDownIndex.SpecialType] then
                local RedDotName = self:GetRedDotName(Prof,HorIndex,DropDownIndex.SpecialType, GatheringLogDefine.RedDotID.GarherLogProf)
                if not RedDotName then
                    RedDotName = RedDotMgr:AddRedDotByParentRedDotName(HorIndexRedDotName)
                    local RedNode = RedDotMgr:FindRedDotNodeByName(RedDotName)
                    if RedNode then
                        RedNode.DropDownIndex = DropDownIndex.SpecialType
                    end
                end
            end
        end
    end

    ---弱红点删除
    if HorIndexRedDotName and table.is_nil_empty(SpecialAddRedDots) then
        local IsDel = RedDotMgr:DelRedDotByName(HorIndexRedDotName)
        if IsDel then
            local TheOtherRedDotName = self:GetRedDotName(Prof, GatheringLogDefine.HorBarIndex.NormalIndex, nil, GatheringLogDefine.RedDotID.GarherLogProf)
            if not TheOtherRedDotName then
                RedDotMgr:DelRedDotByName(ProfRedDotName)
            end
        end
    end
end

-- 是否有未读的传承录卷
function GatheringLogMgr:IsHaveUnReadLInheritVolume(Prof, Volume)
    local UseLineage = self.UseLineageProf and self.UseLineageProf[Prof]
    if table.is_nil_empty(UseLineage) then
        return false
    end
    for index, value in pairs(UseLineage) do
        if (Volume >> (index)) & 1 == 1 then
            return true
        end
    end
    return false
end

function GatheringLogMgr:GetSpecialReadData(Prof, SpecialType)
    local DropRedDotLists = self.SpecialDropRedDotLists[Prof]
    if DropRedDotLists then
        for _, value in pairs(DropRedDotLists) do
            if value.SpecialType == SpecialType then
                return value
            end
        end
    end
end

---@type 红点名获取（没有就是无红点）
---@param Prof 左侧职业列表
---@param HorIndex 上方四种页签_0表示总数
function GatheringLogMgr:GetRedDotName(Prof, HorIndex, DropDownIndex, RedDotID)
    if Prof == nil then
        Prof = self:GetChoiceProfID()
        if Prof == nil then
            return
        end
    end

    local RedNode = nil
    local RedNodeList = nil
    local ProfRedDotName = nil

    --获取所有职业总红点
    if RedDotID == nil then
        RedDotID = GatheringLogDefine.RedDotID.GarherLogProf
        if HorIndex == nil or HorIndex == HorBarIndex.SpecialIndex then
            RedNode = RedDotMgr:FindRedDotNodeByID(GatheringLogDefine.RedDotID.GarherLog)
            if RedNode then
                RedNodeList = RedNode.SubRedDotList
                if RedNodeList ~= nil then
                    for _, value in pairs(RedNodeList) do
                        if value.ProfID == Prof then
                            ProfRedDotName = value.RedDotName
                            RedDotID = GatheringLogDefine.RedDotID.GarherLog
                        end
                    end
                end
            end
        end
    end

    if not ProfRedDotName then
        RedNode = RedDotMgr:FindRedDotNodeByID(RedDotID)
        if not RedNode then
            return nil
        end

        --获取该职业的红点名 及红点
        RedNodeList = RedNode.SubRedDotList
        ProfRedDotName = nil
        if RedNodeList == nil then
            return
        end
        for _, value in pairs(RedNodeList) do
            if value.ProfID == Prof then
                ProfRedDotName = value.RedDotName
            end
        end
        if ProfRedDotName == nil then
            return nil
        end
    end

    if HorIndex == nil then
        return ProfRedDotName
    end
    local ProfRedNode = RedDotMgr:FindRedDotNodeByName(ProfRedDotName)
    if not ProfRedNode then
        return nil
    end

    if HorIndex == 0 then
        HorIndex = self.LastFilterState.HorTabsIndex or 1
    end
    --获取该页签的红点名 及红点
    local HorRedDotList = ProfRedNode.SubRedDotList
    if HorRedDotList == nil then
        return nil
    end
    local HorRedDotNode = nil
    for _, value in pairs(HorRedDotList) do
        if value.HorIndex == HorIndex then
            HorRedDotNode = value
        end
    end
    if HorRedDotNode == nil then
        return nil
    end
    if DropDownIndex == nil then
        return HorRedDotNode.RedDotName
    elseif DropDownIndex == 0 then
        return nil
    end

    ----获取该下拉选项的红点名
    local DropDownRedDotList = HorRedDotNode.SubRedDotList
    if DropDownRedDotList == nil then
        return nil
    end
    for _, value in pairs(DropDownRedDotList) do
        if HorIndex == HorBarIndex.NormalIndex and value.DropDownIndex == DropDownIndex then
            return value.RedDotName
        end
        if HorIndex == HorBarIndex.SpecialIndex and value.DropDownIndex == DropDownIndex then
            return value.RedDotName
        end
    end

    if HorIndex == HorBarIndex.SpecialIndex and RedDotID == GatheringLogDefine.RedDotID.GarherLog then
        return self:GetRedDotName(Prof, HorIndex, DropDownIndex, GatheringLogDefine.RedDotID.GarherLogProf)
    end
end

---@type 红点强弱类型获取（没有就是无红点）
function GatheringLogMgr:GetRedDotIsStrongReminder(RedDotName)
    local RedNode = RedDotMgr:FindRedDotNodeByName(RedDotName)
    if RedNode and RedNode.IsStrongReminder == true then
        return true
    end
    return false
end

---@type 当激活时
function GatheringLogMgr:MajorProfActivate(Params)
    local ProfID = Params.ActiveProf.ProfID
    if not _G.GatherMgr:IsGatherProf(ProfID) then
        return
    end
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGatherNote) then
        local Profs = GatheringLogDefine.ProfID
        if (ProfID == Profs.MinerJobID and self.BotanistLevel == 0) or (ProfID == Profs.BotanistJobID and self.MinerLevel == 0) then
            --就代表是刚解锁笔记
            return
        end
        local ProfName = ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, ProfID)
        local function ShowNoteTip()
            MsgTipsUtil.ShowTips(string.format(LSTR(70038), ProfName)) --采集笔记中追加了%s的书页
        end
        self:RegisterTimer(ShowNoteTip, 1.5, 1, 1)
    end
    self:UpdateProfessionData()
end

---@type 当升级时新增普通页签下拉选项红点
function GatheringLogMgr:OnMajorLevelUpdate(Params)
    local prof = Params.RoleDetail.Simple.Prof
    if not MajorUtil.IsGatherProf() then
        return
    end
    local Level = Params.RoleDetail.Simple.Level
    local OldLevel = Params.OldLevel
    if OldLevel == nil then --激活或转职
        if Level == 1 then
            OldLevel = 0
        else
            return
        end
    end

    --新增等级段红点（由于采集笔记可预览功能单，等级段红点暂时屏蔽）
    local ProfessType = ProtoCommon.prof_type
    --local DropListData = GatheringLogDefine.DropFilterTabData[HorBarIndex.NormalIndex]
    -- for Index, v1 in pairs(DropListData) do
    --     if not self.AddNewIndex or not self.AddNewIndex[prof] or not self.AddNewIndex[prof][Index] then
    --         local DropData = v1
    --         local DropName = DropData.Name
    --         local LevelMinMax = StringTools.StringSplit(DropName, "~")
    --         local LevelMin = tonumber(LevelMinMax[1])
    --         if OldLevel < LevelMin and Level >= LevelMin then
    --             self:SendMsgUpdateDropNewData(prof, Index)
    --             if not self.AddNewIndex[prof] then
    --                 self.AddNewIndex[prof] = {}
    --             end
    --             self.AddNewIndex[prof][Index] = true --表示已经发过新增了
    --         end
    --     end
    -- end

    --当收藏品解锁时新增特殊页签下拉选项红点（收藏品的解锁暂时用等级解锁）
    if
        self:GetQuestStatus() == true and Level >= GatheringLogDefine.CollectionUnLockLevel and
            OldLevel < GatheringLogDefine.CollectionUnLockLevel
     then
        --self:SendMsgUpdateDropNewData(prof, nil, SpecialType.SpecialTypeCollection,nil,false)
        self:SendMsgUpdateDropNewData(prof, 100)
    end

    --更新存储的职业等级信息
    if prof == ProfessType.PROF_TYPE_MINER then
        self.MinerLevel = Level
    elseif prof == ProfessType.PROF_TYPE_BOTANIST then
        self.BotanistLevel = Level
    end

    --更新界面选中
    local LastSelectProfess = self.LastSelectProfessMiner
    if prof == ProfessType.PROF_TYPE_MINER then
        LastSelectProfess = self.LastSelectProfessMiner
    elseif prof == ProfessType.PROF_TYPE_BOTANIST then
        LastSelectProfess = self.LastSelectProfessBotanist
    end
    --切换职业也会收到此消息，采集笔记内追踪采集点切换职业时不要重置选中
    if Params.OldLevel == nil and UIViewMgr:IsViewVisible(UIViewID.GatheringLogMainPanelView) then
        return
    end
    LastSelectProfess.DropDownID = 1
    self.LastFilterState.DropDownIndex = 1
end

--- 在完成一流工匠的新工作后解锁收藏品交易列表
function GatheringLogMgr:OnUpdateQuest(Params)
    if Params == nil then
        FLOG_INFO("GatheringLogMgr:OnUpdateQuest Params is nil")
        return
    end

    local Quests = Params.RemovedQuestList
    if table.is_nil_empty(Quests) then
        FLOG_INFO("GatheringLogMgr:OnUpdateQuest Params.RemovedQuestList is nil")
        return
    end

    for _, RspQuest in ipairs(Quests) do
        local QuestID = RspQuest.QuestID
        if QuestID == GatheringLogDefine.CollectionQuestID then
            FLOG_INFO("Unlock GatherLog Collection QuestID")
            self.bFinishCommerceCollectiblesTask = true
            for _, Prof in pairs(GatheringLogDefine.ProfID) do
                local ProfLevel = MajorUtil.GetMajorLevelByProf(Prof)
                if ProfLevel and ProfLevel >= GatheringLogDefine.CollectionUnLockLevel then
                    --self:SendMsgUpdateDropNewData(Prof, nil, SpecialType.SpecialTypeCollection,nil,false)
                    self:SendMsgUpdateDropNewData(Prof, 100)
                end
            end

            --制作笔记的收藏品交易解锁也是由self.bFinishCommerceCollectiblesTask判断
            _G.CraftingLogMgr:OnUpdateQuest()
        end
    end
end

---@type 当版本更新_传承录解锁时新增特殊页签下拉选项红点 --2.ToDo：如果后来才解锁的职业，也要添加红点(调用此方法)
function GatheringLogMgr:UpdateInheritRedDot()
    local RoleDetail = ActorMgr:GetMajorRoleDetail()
    if RoleDetail == nil then
        FLOG_ERROR("GatheringLogMgr:UpdateInheritRedDot RoleDetail is nil")
        return
    end
    local Prof = RoleDetail.Prof
    local ProfList = Prof.ProfList

    for _, ProfID in pairs(GatheringLogDefine.ProfID) do
        if ProfList[ProfID] ~= nil then
            local IsUnLock = self:IsUnLockInheritByVersion(ProfID) --Check更新后的版本是否可解锁传承录
            if not IsUnLock then
                break
            end
            local SpecialDropRedDotList = self.SpecialDropRedDotLists[ProfID]
            local IsRead = nil --从服务器拉取的传承录是否已读
            local InheritReadVer = nil --从服务器拉取的传承录已读版本
            if not table.is_nil_empty(SpecialDropRedDotList) then
                for _, value in pairs(SpecialDropRedDotList) do
                    if value.SpecialType == SpecialType.SpecialTypeInherit then
                        IsRead = value.IsRead
                        InheritReadVer = value.ReadVersion
                    end
                end
            end

            --如果未读过,按职业添加强红点,,,向服务器新增，回包加到红点树，并且在服务器记录已读版本
            if IsRead == nil then
                self:SendMsgUpdateDropNewData(ProfID, nil, SpecialType.SpecialTypeInherit, nil, false)
            end

            --游戏过程中使用过了之后更新一下，（在红点协议拉取后就更新了）
            if self.UseLineageProf[ProfID] ~= nil then
                --且已读版本小于本地版本，按职业添加弱红点红点,,,在本地显示就行了，与服务器的交互就是EsotericaReadVer的值
                if InheritReadVer == 0 or self:BeIncludedInGameVersionNum(InheritReadVer) then
                    --遍历采集物的时候添加
                    --SpecialData.IsRead = false --下拉框上的强提醒点过了就是true
                    --SpecialData.ReadVersion = nil --下拉框上的弱提醒点过了再存版本号
                    --换言之SpecialData.ReadVersion只要小于当前版本，弱红点就要显示
                    self:SpecialRedDotDataUpdate(ProfID, HorBarIndex.SpecialIndex)
                end
            end
        end
    end
end
---@type 检查当前游戏版本是否可解锁传承录
function GatheringLogMgr:IsUnLockInheritByVersion(ProfID)
    local ItemData = self:GetItemDataByTopFilter(ProfID, HorBarIndex.SpecialIndex)
    for _, value in pairs(ItemData) do
        --看看版本之内有没有GatheringLabel为秘籍的
        if value.GatheringLabel == LSTR(GatheringLogDefine.DropDownConditions.Lineage) then
            return true
        end
    end
    return false
end

---@type 当关闭界面时点过的下拉框选项的红点移除
function GatheringLogMgr:DelRedDotsOnHide()
    if self.CancelNormalDropRedDotLists ~= nil then
        for Prof, CancelNormalDropRedDotList in pairs(self.CancelNormalDropRedDotLists) do
            local NormalDropRedDotLists = self.NormalDropRedDotLists[Prof]
            if NormalDropRedDotLists then
                for _, DropdownIndex in pairs(NormalDropRedDotLists) do
                    if CancelNormalDropRedDotList[DropdownIndex] then
                        local RedDotName = self:GetRedDotName(Prof, HorBarIndex.NormalIndex, DropdownIndex)
                        if RedDotName then
                            _G.RedDotMgr:DelRedDotByName(RedDotName)
                            self:SendMsgRemoveDropNewData(Prof, DropdownIndex)
                        end
                    end
                end
            end
        end
    end
    self.CancelNormalDropRedDotLists = {}
    if self.CancelSpecialDropRedDotLists ~= nil then
        for Prof, CancelSpecialDropRedDotList in pairs(self.CancelSpecialDropRedDotLists) do
            local SpecialDropRedDotLists = self.SpecialDropRedDotLists[Prof]
            if SpecialDropRedDotLists then
                for _, DropdownIndex in pairs(SpecialDropRedDotLists) do
                    if DropdownIndex.SpecialType ~= 0 and CancelSpecialDropRedDotList[DropdownIndex.SpecialType] then
                        local RedDotName = self:GetRedDotName(Prof, HorBarIndex.SpecialIndex, DropdownIndex.SpecialType)
                        if RedDotName then
                            local isDel = _G.RedDotMgr:DelRedDotByName(RedDotName)
                            if isDel then
                                local ReadVersion = nil
                                if DropdownIndex.SpecialType == GatheringLogDefine.SpecialType.SpecialTypeCollection then
                                    ReadVersion = MajorUtil.GetMajorLevelByProf(Prof)
                                    --self:SendMsgRemoveDropNewData(Prof, nil, DropdownIndex.SpecialType, ReadVersion, true)
                                    self:SendMsgRemoveDropNewData(Prof, 100)
                                    self.SpecialDropRedDotLists[Prof][3] = nil
                                    self:SpecialRedDotDataUpdate(Prof)
                                else
                                    ReadVersion = GatheringLogMgr.GameVersionNum
                                    if self.UseLineageProf[Prof][1] then
                                        self:SendMsgRemoveDropNewData(Prof, nil, DropdownIndex.SpecialType, ReadVersion,true, 1)
                                    end
                                    if self.UseLineageProf[Prof][2] then
                                        self:SendMsgRemoveDropNewData(Prof, nil, DropdownIndex.SpecialType, ReadVersion,true, 2)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    self.CancelSpecialDropRedDotLists = {}
end

---@type 移除采集笔记获得下拉列表的红点
function GatheringLogMgr:OnNetMsgRemoveGatherNoteNewData(MsgBody)
    if nil == MsgBody or nil == MsgBody.removeAppear or nil == MsgBody.removeAppear.NoteAppear then
        return
    end
    local AllNoteAppear = MsgBody.removeAppear.NoteAppear
    if #AllNoteAppear == 0 then
        return
    end

    for _, NoteAppear in pairs(AllNoteAppear) do
        if NoteAppear.NoteType ~= GatheringLogDefine.GatheringLogNoteType then
            break
        end
        local ProfID = NoteAppear.ProfID

        --普通页签
        self.NormalDropRedDotLists[ProfID] = NoteAppear.IndexList
        self:NormalRedDotDataUpdate(ProfID, true)

        --特殊页签
        local SpecialData = NoteAppear.SpecialData
        if not table.is_nil_empty(SpecialData) and self.SpecialDropRedDotLists[ProfID] ~= nil then
            for _, value in pairs(SpecialData) do
                local Type = value.SpecialType
                if Type ~= 0 then
                    self.SpecialDropRedDotLists[ProfID][Type] = value
                end
            end
            self:SpecialRedDotDataUpdate(ProfID)
            _G.EventMgr:SendEvent(EventID.UpdateTabRedDot)
        end
    end
end
--endregion ===========================红点 End============================================================================

--region =========================界面数据初始化 Begin===================================================================
--当前选中采集物
function GatheringLogMgr:GetSelectGatherData()
    local LastFilterState = self.LastFilterState
    local GatherID = LastFilterState.GatherID
    if self.SearchState == GatheringLogDefine.SearchState.InSearching then
        GatherID = LastFilterState.IDofSearchItem
    end
    if GatherID then
        local GatherData = GatherNoteCfg:FindCfgByKey(GatherID)
        GatherData.Name = ItemUtil.GetItemName(GatherData.ItemID)
        return GatherData
    end
end

-- 采集物信息
function GatheringLogMgr:GetGatherItemInfoByID(ID)
    if ID == nil then
        FLOG_ERROR("GatheringLogMgr:GetGatherItemInfoByID ID is nil")
        return
    end
    self.AllGatheringItemsInfo = self.AllGatheringItemsInfo or {}
    local GatherItemInfo = self.AllGatheringItemsInfo[ID]
    if GatherItemInfo == nil then
        local Cfg = GatherNoteCfg:FindCfgByKey(ID)
        if Cfg ~= nil then
            Cfg.Name = ItemUtil.GetItemName(Cfg.ItemID)
            GatherItemInfo = {
                Cfg = Cfg,
                TimeCondition = self:GetTimeConditonByGatherItem(Cfg) or "",
            }
            self.AllGatheringItemsInfo[ID] = GatherItemInfo
        else
            FLOG_ERROR(string.format("GatheringLogMgr:GetGatherItemInfoByID Cfg is nil, ID = %d",ID))
        end
    end
    return GatherItemInfo
end

function GatheringLogMgr:InitAllData()
    --更新等级
    local RoleDetail = ActorMgr:GetMajorRoleDetail()
    if RoleDetail == nil then
        return
    end
    local ProfList = RoleDetail.Prof.ProfList
    self:UpdateProfessionLevel(ProfList)
end

---@type 获取采集点的时间条件从而设置采集物的时间条件
function GatheringLogMgr:GetTimeConditonByGatherItem(Elem)
    if Elem == nil then
        return
    end
    local ExistPlace = self:GetGatherPlaceByItemData(Elem)
    for i = 1, #ExistPlace do
        local PlaceElem = ExistPlace[i]
        local TimeCondition = PlaceElem.TimeCondition
        local bChanged = false
        if TimeCondition ~= nil then
            for j = 1, #TimeCondition do
                local TimeElem = TimeCondition[j]
                if j == 1 then
                    Elem.TimeCondition = TimeElem
                else
                    Elem.TimeCondition = string.format("%s;%s", Elem.TimeCondition, TimeElem)
                end
                bChanged = true
            end
        end
        if bChanged and i ~= #ExistPlace then
            Elem.TimeCondition = string.format("%s;", Elem.TimeCondition)
        end
    end
    return Elem.TimeCondition
end

function GatheringLogMgr:GetTimeConditonByPlace(PlaceItem)
    local TimeCondition = {}
    for i = 1, #PlaceItem.StarTime do
        local StartTime = PlaceItem.StarTime[i]
        local EndTime = PlaceItem.StarTime[i] + PlaceItem.PopLife[i]
        local StartHourTime = tonumber(string.sub(StartTime, 0, -3)) or 0
        local StartSecTime = tonumber(string.sub(StartTime, -2)) or 0
        local EndHourTime = tonumber(string.sub(EndTime, 0, -3)) or 0
        local EndSecTime = tonumber(string.sub(EndTime, -2)) or 0
        TimeCondition[i] = string.format("%02d:%02d - %02d:%02d", StartHourTime, StartSecTime,EndHourTime,EndSecTime)
    end
    return TimeCondition
end

function GatheringLogMgr:GetGatherJobByGatherType(GatherType)
    if GatherType == GatherPointType.GATHER_POINT_TYPE_MINE or GatherType == GatherPointType.GATHER_POINT_TYPE_STONE then
        return ProtoCommon.prof_type.PROF_TYPE_MINER
    else
        return ProtoCommon.prof_type.PROF_TYPE_BOTANIST
    end
end

---@type 给定采集点ID_获取同采集点分组的所有采集点ID
function GatheringLogMgr:GetGatherResIDListInSameGroup(GatherResID)
    local BelongGatherGroup = GatherPointCfg:FindValue(GatherResID, "GatherGroup")
    local AllPlaceList = GatherPointCfg:FindAllCfg()
    local GatherResIDList = {}
    for _, PlaceElem in pairs(AllPlaceList) do
        if self:BeIncludedInGameVersion(PlaceElem.Version) and PlaceElem.GatherGroup == BelongGatherGroup then
            table.insert(GatherResIDList, PlaceElem.ID)
        end
    end

    return GatherResIDList
end

---@type 获取采集物对应的采集点
---@param ID number @采集点ID
function GatheringLogMgr:GetGatherPlaceByItemData(ItemData)
    if ItemData == nil then
        return
    end
    local ItemID = ItemData.ItemID
    local GatheringJob = ItemData.GatheringJob
    self.GatherPlaceList = self.GatherPlaceList or {}
    self.GatherPlaceList[GatheringJob] = self.GatherPlaceList[GatheringJob] or {}
    local NeedGatherPlaceList = self.GatherPlaceList[GatheringJob][ItemID]
    local knownLocList = self.knownLocList or {}
    if NeedGatherPlaceList == nil then
        NeedGatherPlaceList = {}
        local AllPlaceList = GatherPointCfg:FindAllCfg()
        local LastGatherGroup = {}
        for _, v1 in pairs(AllPlaceList) do
            if self:BeIncludedInGameVersion(v1.Version) then
                local CommonResourceID = v1.CommonResourceID
                local GatherGroup = v1.GatherGroup
                local GatherJob = self:GetGatherJobByGatherType(v1.GatherType)
                for _, v2 in pairs(CommonResourceID) do
                    local Elem = v2
                    if Elem == ItemID and GatheringJob == GatherJob and LastGatherGroup[GatherGroup] == nil then
                        LastGatherGroup[GatherGroup] = true
                        local PlaceItem = {
                                ID = v1.ID,
                                GatherLevel = v1.GatherLevel,
                                IsUnknownLoc = v1.IsUnknownLoc,
                                bUnknownLoc = not (knownLocList[v1.ID] or v1.IsUnknownLoc == 0),
                                CommonResourceID = v1.CommonResourceID,
                                MapID = v1.MapID,
                                bSelect = v1.bSelect,
                                GatherType = v1.GatherType,
                                GatherDescribe = v1.GatherDescribe,
                                TimeCondition = v1.IsUnknownLoc == 1 and self:GetTimeConditonByPlace(v1) or nil
                            }
                        table.insert(NeedGatherPlaceList, PlaceItem)
                        break
                    end
                end
            end
        end
        table.sort(NeedGatherPlaceList, self.SortPlaceDataByLevelPredicate)
        --设置ImgLine的显示
        local LastElemMapID = 0
        if #NeedGatherPlaceList > 0 then
            for i = 1, #NeedGatherPlaceList do
                local Elem = NeedGatherPlaceList[i]
                local LastElem = NeedGatherPlaceList[i - 1]
                if Elem.MapID ~= LastElemMapID and LastElemMapID ~= 0 then
                    LastElem.bImgLineVisible = false
                end
                Elem.bImgLineVisible = true
                LastElemMapID = Elem.MapID
            end
            NeedGatherPlaceList[#NeedGatherPlaceList].bImgLineVisible = false
        end
        self.GatherPlaceList[GatheringJob][ItemID] = NeedGatherPlaceList
    else
        for _, value in pairs(NeedGatherPlaceList) do
            value.bUnknownLoc = not (knownLocList[value.ID] or value.IsUnknownLoc == 0)
        end
    end

    return NeedGatherPlaceList
end

---@type 更新职业信息
function GatheringLogMgr:UpdateProfessionData()
    local RoleDetail = ActorMgr:GetMajorRoleDetail()
    if RoleDetail == nil then
        FLOG_ERROR("GatheringLogMgr:UpdateProfessionData RoleDetail is nil")
        return
    end
    --更新属性
    self:UpdateAttrGathering()

    --更新等级
    local ProfList = RoleDetail.Prof.ProfList
    self:UpdateProfessionLevel(ProfList)
    --左侧职业数据
    local ProfessType = ProtoCommon.prof_type
    self:InitLeftProfessionData(ProfessType.PROF_TYPE_MINER)
    self:InitLeftProfessionData(ProfessType.PROF_TYPE_BOTANIST)
    --更新上方tab
    self:UpdateHorBarData()
end

function GatheringLogMgr:InitLeftProfessionData(ProfID)
    local VerIconTabIcons = GatheringLogDefine.VerIconTabIcons[ProfID]
    local Data = {}
    Data.ProfID = ProfID
    Data.IconPath = VerIconTabIcons.IconPath
    Data.SelectIcon = VerIconTabIcons.SelectIcon
    Data.ProfessionName = RoleInitCfg:FindRoleInitProfName(ProfID)
    Data.IsLock = false
    local Index = self:GetProfListIndex(ProfID)
    local ProfList = ActorMgr:GetMajorRoleDetail().Prof.ProfList
    if Index ~= -1 then
        --如果拥有这个职业，就把一些数据存在ProfList[Index]中
        ProfList[Index].IsLock = Data.IsLock
        ProfList[Index].IconPath = Data.IconPath
        ProfList[Index].SelectIcon = VerIconTabIcons.SelectIcon
        ProfList[Index].ProfessionName = Data.ProfessionName
        --无论是否拥有这个职业，统一返回Data
        Data = ProfList[Index]
        Data.RedDotType = GatheringLogType
        Data.ID = ProfID
    else
        Data.IsLock = true
    end

    --Data.bShowlock = false
    if #self.LeftProfessionData > 1 then
        for index, value in pairs(self.LeftProfessionData) do
            if value.ProfessionName == Data.ProfessionName then
                table.remove(self.LeftProfessionData, index)
            end
        end
    end
    table.insert(self.LeftProfessionData, Data)
    table.sort(self.LeftProfessionData, self.SortByProfID)
end

function GatheringLogMgr:ShowProfUnmatchTips(GatheringItemJobID)
    local Title = LSTR(80015) --切换职业
    local Message = string.format(LSTR(70061),--"职业不符，是否切换为<span color=\"#D1BA8E\">“%s”</>？"
        RoleInitCfg:FindCfgByKey(GatheringItemJobID).ProfName)
    local function RightCB()
        if not _G.ProfMgr:CanChangeProf(GatheringItemJobID) then
            return
        end
        _G.EquipmentMgr:SwitchProfByID(GatheringItemJobID)
    end
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, Title, Message, RightCB, nil, nil, LSTR(10002))
end

function GatheringLogMgr:GetCurProfbLock(GatheringJobID)
    local GatheringJobID = GatheringJobID or GatheringLogMgr:GetChoiceProfID()
    for _, value in pairs(self.LeftProfessionData) do
        if value.ProfID == GatheringJobID then
            return value.IsLock
        end
    end
end

function GatheringLogMgr:GetProfListIndex(ProfID)
    local ProfList = ActorMgr:GetMajorRoleDetail().Prof.ProfList
    for Index, v in pairs(ProfList) do
        if v.ProfID == ProfID then
            return Index
        end
    end
    return -1
end

---@type 初始化获得力
---@param AttrList table @属性列表
function GatheringLogMgr:UpdateAttrGathering(AttrList)
    local AttrType = ProtoCommon.attr_type
    local AttributeComponent = MajorUtil.GetMajorAttributeComponent()
    if AttributeComponent == nil then
        return
    end
    self.AttrGathering = AttributeComponent:GetAttrValue(AttrType.attr_gathering)
end

---@type 更新职业等级
function GatheringLogMgr:UpdateProfessionLevel(ProfList)
    local ProfData = ProfList
    local ProfessType = ProtoCommon.prof_type
    for _, v in pairs(ProfData) do
        local Elem = v
        if Elem.ProfID == ProfessType.PROF_TYPE_MINER then
            self.MinerLevel = Elem.Level
        elseif Elem.ProfID == ProfessType.PROF_TYPE_BOTANIST then
            self.BotanistLevel = Elem.Level
        end
    end
end

---@type 更新Horbar结构
function GatheringLogMgr:UpdateHorBarData()
    local AllHorbarsSelectData = GatheringLogMgr.AllHorbarsSelectData
    local LeftProfessionData = GatheringLogMgr.LeftProfessionData
    local MaxHorbarsIndex = 4
    local OffsetWithMiner = 35
    for i = 1, #LeftProfessionData do
        --i + OffsetWithMiner = 35 为采矿工 36 为园艺工
        if AllHorbarsSelectData[i + OffsetWithMiner] == nil then
            AllHorbarsSelectData[i + OffsetWithMiner] = {}
        end
        for HorbarIndex = 1, MaxHorbarsIndex do
            if AllHorbarsSelectData[i + OffsetWithMiner][HorbarIndex] == nil then
                AllHorbarsSelectData[i + OffsetWithMiner][HorbarIndex] = {}
            end
        end
    end
end

---@type 保存选择的上方页签
---@param GatheringJobID number @职业ID
function GatheringLogMgr:SaveHorbarData(ProfID, Saved)
    if self.HorbarDataSaved then
        self.HorbarDataSaved = Saved
        return
    end
    self.HorbarDataSaved = Saved
    local NeedAddProf = self.AllHorbarsSelectData[ProfID]
    if NeedAddProf == nil then
        return
    end
    local LastFilterState = self.LastFilterState
    local HorbarIndex = LastFilterState.HorTabsIndex
    if HorbarIndex == nil then
        return
    end
    local DorpDownIndex = LastFilterState.DropDownIndex
    local GatherID = LastFilterState.GatherID
    NeedAddProf[HorbarIndex].HorbarIndex = HorbarIndex
    NeedAddProf[HorbarIndex].DorpDownIndex = DorpDownIndex
    NeedAddProf[HorbarIndex].GatherID = GatherID
end

function GatheringLogMgr:GetLastSelectHorbarData(ProfID, HorBarIndex)
    local AllHorbarsSelectData = self.AllHorbarsSelectData
    if AllHorbarsSelectData[ProfID] == nil then
        return
    end
    return AllHorbarsSelectData[ProfID][HorBarIndex]
end

---@type 根据玩家所处的职业获取职业列表中的索引
---@param ProfessionData table @职业列表数据
---@param Prof number @玩家所处的职业
function GatheringLogMgr:GetProfIndexByProfID(Prof)
    local ProfessionData = self.LeftProfessionData
    local Data = ProfessionData
    for i = 1, #Data do
        local Elem = Data[i]
        if Elem.ProfID == Prof then
            return i
        end
    end
end

---@type 首次打开界面展示左侧的职业页签的职业
function GatheringLogMgr:GetChoiceProfID()
    --当玩家打开制作笔记时，记录上一次关闭时的配方选择
    if self.LastFilterState.GatheringJobID then
        return self.LastFilterState.GatheringJobID
    end
    --若无上次的打开记录，默认打开当前职业
    local RoleDetail = ActorMgr:GetMajorRoleDetail()
    local Simple = RoleDetail and RoleDetail.Simple
    local MajorProf = Simple and Simple.Prof
    if MajorProf then
        if MajorProf == ProtoCommon.prof_type.PROF_TYPE_MINER or MajorProf == ProtoCommon.prof_type.PROF_TYPE_BOTANIST then
            return MajorProf
        end
    else
        FLOG_ERROR("GatheringLogMgr Major CurProf is nil")
    end
    --若当前职业为战职，默认选择排序首位的职业
    if not table.is_nil_empty(self.LeftProfessionData) then
        local ProfessionData = self.LeftProfessionData
        return ProfessionData[1] and ProfessionData[1].ProfID
    end
    return GatheringLogDefine.ProfID.MinerJobID
end

--判断是在, 出现中, 一小时内出现, 一小时外出现
-- DropTimeCondition = {
--     [1] = {Name = "出现中", },
--     [2] = {Name = "一小时内出现", },
--     [3] = {Name = "一小时外出现", },
--     [4] = {Name = "一小时内出现", },
-- }
function GatheringLogMgr:SetAppearCondition(TimeCondition, GatherItem)
    if #TimeCondition <= 0 then
        GatherItem.AppearCondition = ""
        return
    end
    local ServerTime = TimeUtil.GetServerLogicTime()
    local AozySecond = ServerTime * (12 / 35) * 60
    local OneDaySec = 86400
    local DayTime = AozySecond % OneDaySec -- 取余
    local DropFilterTabData = GatheringLogDefine.DropFilterTabData
    local ClockIndex = HorBarIndex.ClockIndex
    local DropTimeCondition = DropFilterTabData[ClockIndex]
    local ConditionIndex = {IsAppearing = 2, AppearInOneHour = 3, ApperOutOneHour = 4}
    for i = 1, #TimeCondition do
        local Elem = TimeCondition[i]
        local StartAozyTime, EndAozyTime = self:GetStartAndEndAozyTime(Elem)
        GatherItem.TimeConditionStart = StartAozyTime
        GatherItem.TimeConditionEnd = EndAozyTime
        if DayTime <= EndAozyTime and DayTime >= StartAozyTime then
            GatherItem.AppearCondition = DropTimeCondition[ConditionIndex.IsAppearing].Name
            GatherItem.LeftTime = EndAozyTime - DayTime
        elseif DayTime <= StartAozyTime then
            GatherItem.AppearCondition = DropTimeCondition[ConditionIndex.AppearInOneHour].Name
            GatherItem.LeftTime = StartAozyTime - DayTime
        end
    end
    local Length = #TimeCondition
    local StartAozyTime, LastEndAozyTime = self:GetStartAndEndAozyTime(TimeCondition[Length])
    if DayTime > LastEndAozyTime then
        GatherItem.AppearCondition = DropTimeCondition[ConditionIndex.AppearInOneHour].Name
        GatherItem.LeftTime = StartAozyTime + OneDaySec - DayTime
    end
end

function GatheringLogMgr:BeIncludedInGameVersionNum(Version)
    if Version ~= nil and Version < self.GameVersionNum then
        return true
    else
        return false
    end
end

---@type 指定版本是否被包含于当前游戏版本
---@param VersionName string @指定版本
function GatheringLogMgr:BeIncludedInGameVersion(VersionName)
    if not string.isnilorempty(VersionName) then
        local VersionNum = self.VersionNametoNum[VersionName] or self:VersionNameToNum(VersionName)
        if VersionNum ~= nil and VersionNum <= self.GameVersionNum then
            return true
        end
    end
    return false
end

---@type 根据DropDown所选择的条件筛选采集物
---@param GatheringJobID number @职业ID
---@param Condition string @条件
---@param TabID number @顶部TabID
function GatheringLogMgr:UpdataItems(GatheringJobID, ConditionData, TabID)
    local Condition = ConditionData.Name
    local MajorLevel = MajorUtil.GetMajorLevelByProf(GatheringJobID)
    local EndResultItemData = {}
    local LockItemTable = {}
    --采矿工 或 园艺工 所有的可采的采集物
    local CurItems = self:GetItemDataByTopFilter(GatheringJobID, TabID)
    --要遍历的条件分类
    local DropDownConditions = GatheringLogDefine.DropDownConditions
    --80062"[工票商店]"
    local ShopName = RichTextUtil.GetHyperlink(LSTR(80062), 1, "#d1ba8e", nil, nil, nil, nil, nil, false)
    local ItemText = string.format(LSTR(GatheringLogDefine.UnUsedInheritText), ShopName)

    --根据特殊条件获取采集物----------------------------------------------------------
    if TabID == HorBarIndex.SpecialIndex then
        local UnlockVolume = self.UseLineageProf[GatheringJobID]
        for _, v in pairs(CurItems) do
            if v.GatherLabel[2] == Condition then
                --如果是筛选的是传承录且背包中的传承录未使用过
                if Condition == LSTR(DropDownConditions.Lineage) then
                    if UnlockVolume and UnlockVolume[v.LineageVolume] then
                        table.insert(EndResultItemData, v)
                    else
                        if not LockItemTable[v.GatherLabel[3]] then
                            table.insert(EndResultItemData, {
                                TextTips = ItemText,
                                Category = v.GatherLabel[3],
                                CategoryItemID = GatheringLogDefine.CategoryItemIDMap[GatheringJobID][v.LineageVolume],
                                LineageVolume = v.LineageVolume,
                                GatheringJob = GatheringJobID
                            })
                            LockItemTable[v.GatherLabel[3]] = true
                        end
                    end
                else
                    --收藏品交易
                    if self.bFinishCommerceCollectiblesTask and (MajorLevel // 10 + 1) * 10 >= v.GatheringGrade then
                        table.insert(EndResultItemData, v)
                    end
                end
            end
        end
        table.sort(EndResultItemData, self.SortItemDataByLevelPredicate)
        return EndResultItemData
    end

    --剩下的都是普通采集物，按等级排序------------------------------------------------
    if TabID == HorBarIndex.NormalIndex then
        --等级条件 例如：86~90级（等级列表和收藏列表会出现）
        local LevelMin = ConditionData.LevelMin
        local LevelMax = ConditionData.LevelMax
        local ProfbLock = self:GetCurProfbLock()
        local bLockGray = ProfbLock or (MajorLevel + 10) <= LevelMax
        for _, Elem in pairs(CurItems) do
            if Elem.GatheringGrade >= LevelMin and Elem.GatheringGrade <= LevelMax then
                Elem.bLockGray = bLockGray
                table.insert(EndResultItemData, Elem)
            end
        end
        table.sort(EndResultItemData, self.SortItemDataByLevelPredicate)
        return EndResultItemData
    end

    -- NoCondition = "全部"（收藏列表和闹钟列表会出现“全部”）
    local IsNoCondition =  string.find(Condition, LSTR(DropDownConditions.NoCondition))
    --根据是否收藏和等级条件获取采集物
    if TabID == HorBarIndex.CollectionIndex then
        if IsNoCondition then
            EndResultItemData = CurItems
        else
            for _, Elem in pairs(CurItems) do
                if Elem.GatheringGrade >= ConditionData.LevelMin and Elem.GatheringGrade <= ConditionData.LevelMax then
                    table.insert(EndResultItemData, Elem)
                end
            end
        end
        table.sort(EndResultItemData, self.SortItemDataByLevelPredicate)
        return EndResultItemData
    end

    --根据时间条件获取采集物
    --遍历所有采集物，挑选符合此次循环条件的采集物
    for _, Elem in pairs(CurItems) do
        local TimeCondition = StringTools.StringSplit(Elem.TimeCondition, ";")
        ----判断是在, 出现中, 一小时内出现, 一小时外出现
        local GatherCfg = Elem.Cfg
        self:SetAppearCondition(TimeCondition, GatherCfg)
        --如果条件是限时采集物的出现时间
        if IsNoCondition or GatherCfg.AppearCondition == Condition then
            table.insert(EndResultItemData, GatherCfg)
        end
    end
    table.sort(EndResultItemData, self.SortItemDataByClockTime)
    return EndResultItemData
end

---@type 获取下拉列表DropFilterList数据
---@param JobType number 职业ID
---@param TabID number 顶部标签index
function GatheringLogMgr:UpdateDropData(JobType, TabID)
    local ResultDropList = {}
    --读取本地数据
    local DropListData = GatheringLogDefine.DropFilterTabData[TabID]
    local ItemData = self:GetItemDataByTopFilter(JobType, TabID)
    local DropDownConditions = GatheringLogDefine.DropDownConditions
    local MajorLevel = MajorUtil.GetMajorLevelByProf(JobType) or 0
    local ProfbLock = self:GetCurProfbLock()
    if TabID == HorBarIndex.NormalIndex then
        --走任务接口 完成任务就解锁
        for Index, v1 in pairs(DropListData) do
            local DropData = v1
            local LevelMax = DropData.LevelMax
            local bTextGray = ProfbLock or (MajorLevel + 10) <= LevelMax
            if LevelMax <= GatheringLogDefine.MaxLevel then
                DropData.RedDotType = GatheringLogType
                DropData.Prof = JobType
                DropData.HorIndex = TabID
                DropData.DropdownIndex = Index
                DropData.IconPath = bTextGray and GatheringLogDefine.LockIcon or nil
                DropData.ImgIconColorbSameasText = true
                table.insert(ResultDropList, DropData)
            end
        end
        table.sort(ResultDropList, self.SortDropDown)
    elseif TabID == HorBarIndex.SpecialIndex then
        --满足的条件：1.版本号；2.有对应的采集物
        local TabList = {}
        for _, value in pairs(ItemData) do
            if value.GatherLabel[1] == LSTR(DropDownConditions.Special) then
                local RecipeLable = value.GatherLabel[2]
                --当玩家处于秘籍可解锁版本之前，不解锁秘籍
                --if self:BeIncludedInGameVersion(value.VersionName) then
                    if RecipeLable and TabList[RecipeLable] == nil then
                        -- 不是传承录的根据等级解锁
                        if
                            RecipeLable == LSTR(DropDownConditions.Lineage) or
                                (self.bFinishCommerceCollectiblesTask and MajorLevel and
                                    (MajorLevel // 10 + 1) * 10 >= value.GatheringGrade)
                         then
                            local DropData = {}
                            DropData.Name = RecipeLable
                            DropData.RedDotType = GatheringLogType
                            DropData.Prof = JobType
                            DropData.HorIndex = TabID
                            if RecipeLable == LSTR(DropDownConditions.Lineage) then
                                DropData.DropdownIndex = SpecialType.SpecialTypeInherit
                            elseif RecipeLable == LSTR(DropDownConditions.CommerceCollectibles) then
                                DropData.DropdownIndex = SpecialType.SpecialTypeCollection
                            end
                            table.insert(ResultDropList, DropData)
                            TabList[RecipeLable] = true
                        end
                    end
                --end
            end
        end
    elseif TabID == HorBarIndex.CollectionIndex then
        for _, v1 in pairs(DropListData) do
            local DropData = v1
            if DropData.Name == LSTR(DropDownConditions.NoCondition) then
                --table.insert(ResultDropList, DropData)
            else
                local LevelMin = DropData.LevelMin
                local LevelMax = DropData.LevelMax
                if LevelMin ~= nil and LevelMax ~= nil then
                    for _, v2 in pairs(ItemData) do
                        local Data = v2
                        local GatheringGrade = Data.GatheringGrade
                        if GatheringGrade >= LevelMin and GatheringGrade <= LevelMax then
                            table.insert(ResultDropList, DropData)
                            break
                        end
                    end
                end
            end
        end
        if #ResultDropList > 0 then
            table.insert(ResultDropList, 1, {Name = LSTR(DropDownConditions.NoCondition)})
        end
    else
        --ResultDropList = GatheringLogDefine.DropFilterTabData[TabID]
        if #ItemData > 0 then
            for _, value in pairs(DropListData) do
                local List = self:UpdataItems(JobType, value, TabID)
                if #List > 0 then
                    table.insert(ResultDropList, value)
                end
            end
        end
    end
    
    if not table.is_nil_empty(ResultDropList) then
        self:UpdateDropItemsProgress(ResultDropList, JobType, TabID)
    end
    return ResultDropList
end

function GatheringLogMgr:UpdateDropItemsProgress(ResultDropList, JobType, TabID)
    local DropDownConditions = GatheringLogDefine.DropDownConditions
    if TabID == HorBarIndex.NormalIndex then
        local AllItemInfo = GatherNoteCfg:FindAllCfg()
        local MaxLevel = GatheringLogDefine.MaxLevel
        for _, value in pairs(ResultDropList) do
            value.TotalNum = 0
            value.FinishNum = 0
        end
        local HistoryList = self.HistoryList or {}
        local Total = GatheringLogDefine.MaxLevel//5
        for _, Elem in pairs(AllItemInfo) do
            if Elem.GatheringJob == JobType and self:BeIncludedInGameVersion(Elem.VersionName)  and (Elem.GatheringLabel == LSTR(DropDownConditions.Normal) or Elem.GatherLabel[1] == LSTR(70041)) then --70041 普通
                if Elem.GatheringGrade <= MaxLevel then
                    local Total = GatheringLogDefine.MaxLevel//5
                    local GradeIndex = (Elem.GatheringGrade - 1) // 5 + 1
                    GradeIndex = self.ReverseOrder and (Total + 1 - GradeIndex) or GradeIndex
                    ResultDropList[GradeIndex].TotalNum = ResultDropList[GradeIndex].TotalNum + 1
                    if HistoryList[Elem.ID] then
                        ResultDropList[GradeIndex].FinishNum = ResultDropList[GradeIndex].FinishNum + 1
                    end
                end
            end
        end
        for _, value in pairs(ResultDropList) do
            value.bTextQuantityShow = true
            value.TextQuantityStr = string.format("%d/%d", value.FinishNum, value.TotalNum)
        end
    elseif TabID == HorBarIndex.SpecialIndex then
        local CurItems = self:GetItemDataByTopFilter(JobType, TabID)
        local UnlockVolume = self.UseLineageProf[JobType]
        local MajorLevel = MajorUtil.GetMajorLevelByProf(JobType)
        local HistoryList = self.HistoryList or {}
        for _, value in pairs(ResultDropList) do
            value.bTextQuantityShow = true
            value.TotalNum = 0
            value.FinishNum = 0
            for _, Elem in pairs(CurItems) do
                if Elem.GatherLabel[2] == value.Name then
                    --如果是筛选的是传承录且背包中的传承录未使用过
                    if (value.Name == LSTR(DropDownConditions.Lineage) and UnlockVolume and UnlockVolume[Elem.LineageVolume])
                        or (MajorLevel and value.Name == LSTR(DropDownConditions.CommerceCollectibles) and self.bFinishCommerceCollectiblesTask and (MajorLevel // 10 + 1) * 10 >= Elem.GatheringGrade) then
                            value.TotalNum = value.TotalNum + 1
                        if HistoryList[Elem.ID] then
                            value.FinishNum = value.FinishNum + 1
                        end
                    end
                end
            end
            value.TextQuantityStr = string.format("%d/%d", value.FinishNum, value.TotalNum)
        end
    elseif TabID == HorBarIndex.CollectionIndex then
        local CurItems = self:GetItemDataByTopFilter(JobType, TabID)
        for index, value in pairs(ResultDropList) do
            value.bTextQuantityShow = true
            if index == 1 then
                value.TextQuantityStr = string.format("%d/%d", #CurItems, tostring(_G.GatheringLogVM.MaxCollectCount))
            else
                value.TotalNum = 0
                for _, Elem in pairs(CurItems) do
                    if Elem.GatheringGrade >= value.LevelMin and Elem.GatheringGrade <= value.LevelMax then
                        value.TotalNum = value.TotalNum + 1
                    end
                end
                value.TextQuantityStr = string.format("%d", value.TotalNum)
            end
        end
    else
        local CurItems = self:GetItemDataByTopFilter(JobType, TabID)
        for index, value in pairs(ResultDropList) do
            value.bTextQuantityShow = true
            if index == 1 then
                value.TextQuantityStr = string.format("%d/%d", #CurItems, tostring(_G.GatheringLogVM.MaxClockCount))
            else
                value.TotalNum = 0
                for _, Elem in pairs(CurItems) do
                    --if index == 2 then
                        --判断是在, 出现中, 一小时内出现 
                        --local TimeCondition = StringTools.StringSplit(Elem.TimeCondition, ";")
                        --local GatherCfg = Elem.Cfg
                        --self:SetAppearCondition(TimeCondition, GatherCfg)
                    --end
                    if Elem.Cfg.AppearCondition == value.Name then
                        value.TotalNum = value.TotalNum + 1
                    end
                end
                value.TextQuantityStr = string.format("%d", value.TotalNum)
            end
        end
    end
end

-- DropDownConditions.Normal = "常规"
---@type 得到最上方四种分类的Item数据（筛选）
---@param JobType number @职业类型
---@param TopTabID number @顶部TabID
function GatheringLogMgr:GetItemDataByTopFilter(JobType, TopTabID)
    local ReturnItemInfoList = {}
    if TopTabID == HorBarIndex.ClockIndex then
        local ClockList = self.ClockList or {}
        for ID, _ in pairs(ClockList) do
            local Elem = self:GetGatherItemInfoByID(ID)
            if Elem and Elem.Cfg.GatheringJob == JobType then
                table.insert(ReturnItemInfoList, Elem)
            end
        end
        return ReturnItemInfoList
    end

    if TopTabID == HorBarIndex.CollectionIndex then
        local CollectList = self.CollectList or {}
        for ID, _ in pairs(CollectList) do
            local Elem = GatherNoteCfg:FindCfgByKey(ID)
            if Elem.GatheringJob == JobType then
                Elem.Name = ItemUtil.GetItemName(Elem.ItemID)
                table.insert(ReturnItemInfoList, Elem)
            end
        end
        return ReturnItemInfoList
    end

    local AllItemInfo = GatherNoteCfg:FindAllCfg()
    if TopTabID == HorBarIndex.NormalIndex then
        for _, v in pairs(AllItemInfo) do
            local Elem = v
            Elem.Name = ItemUtil.GetItemName(Elem.ItemID)
            if Elem.GatheringJob == JobType and Elem.GatherLabel[3] == nil and self:BeIncludedInGameVersion(Elem.VersionName) then
                table.insert(ReturnItemInfoList, Elem)
            end
        end
    else
        for _, v in pairs(AllItemInfo) do
            local Elem = v
            if Elem.GatheringJob == JobType and Elem.GatherLabel[3] ~= nil and self:BeIncludedInGameVersion(Elem.VersionName) then
                table.insert(ReturnItemInfoList, Elem)
            end
        end
    end
    return ReturnItemInfoList
end

---@type 根据职业等级筛选采集物_用于更新搜索列表
---@param GatherItemData table @采集物数据
---@param PorfID number @职业索引
function GatheringLogMgr:GetItemDataByLevel()
    local ProfessType = ProtoCommon.prof_type
    local PorfMinerID = ProfessType.PROF_TYPE_MINER
    local PorfBotanistID = ProfessType.PROF_TYPE_BOTANIST
    local ProfList = ActorMgr:GetMajorRoleDetail().Prof.ProfList
    local ProfLevel = {
        [PorfMinerID] = ProfList[PorfMinerID] and ProfList[PorfMinerID].Level or 0,
        [PorfBotanistID] = ProfList[PorfBotanistID] and ProfList[PorfBotanistID].Level or 0
    }
    local NeedData = {}
    local LineageData = {}
    local AllItemInfo = GatherNoteCfg:FindAllCfg()
    local UseLineageProf = self.UseLineageProf
    local GatheringJob = 0
    local IsCollection = 0
    local LineageVolume = 0
    for _, Elem in pairs(AllItemInfo) do
        if self:BeIncludedInGameVersion(Elem.VersionName) then
            IsCollection = Elem.IsCollection
            LineageVolume = Elem.LineageVolume
            GatheringJob = Elem.GatheringJob
            if IsCollection ~= 1 and LineageVolume == 0 or
            (IsCollection == 1 and self.bFinishCommerceCollectiblesTask and ((ProfLevel[GatheringJob] // 10 + 1) * 10 >= Elem.GatheringGrade)) or
            (LineageVolume ~= 0 and UseLineageProf[GatheringJob] and UseLineageProf[GatheringJob][LineageVolume]) then
                Elem.Name = ItemUtil.GetItemName(Elem.ItemID)
                table.insert(NeedData, Elem)
            elseif LineageVolume ~= 0 then
                table.insert(LineageData, Elem)
            end
        end
    end
    return NeedData, LineageData
end
--endregion

--region 排序
function GatheringLogMgr:OnBtnSorting(DropDown)
    self.ReverseOrder = not self.ReverseOrder
    if self.SearchState == 0 then
        local GatheringJobID = GatheringLogMgr:GetChoiceProfID()
        GatheringLogMgr:SaveHorbarData(GatheringJobID, false)
        local ProfIDList = GatheringLogDefine.ProfID
        local NormalIndex = HorBarIndex.NormalIndex
        local LastFilterState = self.LastFilterState
        local HorTabsIndex = LastFilterState.HorTabsIndex or 1
        for _, ProfID in pairs(ProfIDList) do
            local SavedData = self.AllHorbarsSelectData[ProfID] and self.AllHorbarsSelectData[ProfID][NormalIndex]
            local DropDownIndex = SavedData and SavedData.DorpDownIndex
            if DropDownIndex then
                local Total = GatheringLogDefine.MaxLevel//5
                local NewDropDownIndex = Total + 1 - DropDownIndex
                if ProfID == GatheringJobID and HorTabsIndex == NormalIndex then
                    local Data = self:UpdateDropData(GatheringJobID, NormalIndex)
                    DropDown:UpdateItems(Data, NewDropDownIndex)
                else
                    SavedData.DorpDownIndex = NewDropDownIndex
                end
            end
        end
    end
    _G.GatheringLogVM.CurLogItemVMList:Sort(self.SortItemDataByLevelPredicate)
    MsgTipsUtil.ShowTips(LSTR(80067))--"已切换排序"
end

function GatheringLogMgr.SortDropDown(Left, Right)
    if GatheringLogMgr.ReverseOrder then
        return Left.LevelMax > Right.LevelMax
    else
        return Left.LevelMax < Right.LevelMax
    end
end

---@type 通过等级排序
function GatheringLogMgr.SortItemDataByLevelPredicate(Left, Right)
    --搜索
    if GatheringLogMgr.SearchState ~= 0 and _G.GatheringLogVM.SearchText ~= nil then
        local searchKey = LSTR(_G.GatheringLogVM.SearchText)
        local leftMatch = Left.Name == searchKey
        local rightMatch = Right.Name == searchKey
        if leftMatch or rightMatch then
            return leftMatch and not rightMatch 
        end
    end
    if Left.GatheringJob ~= Right.GatheringJob then
        return Left.GatheringJob < Right.GatheringJob
    end
    if GatheringLogMgr.ReverseOrder then
        if Left.LineageVolume ~= Right.LineageVolume then
            return Left.LineageVolume > Right.LineageVolume
        elseif Left.GatheringStar ~= Right.GatheringStar then
            return Left.GatheringStar > Right.GatheringStar
        elseif Left.GatheringGrade ~= Right.GatheringGrade then
            return Left.GatheringGrade > Right.GatheringGrade
        else
            return Left.ID < Right.ID
        end
    else
        if Left.LineageVolume ~= Right.LineageVolume then
            return Left.LineageVolume < Right.LineageVolume
        elseif Left.GatheringStar ~= Right.GatheringStar then
            return Left.GatheringStar < Right.GatheringStar
        elseif Left.GatheringGrade ~= Right.GatheringGrade then
            return Left.GatheringGrade < Right.GatheringGrade
        else
            return Left.ID < Right.ID
        end
    end
end

---@type 闹钟列表按照即将出现时间排序_时间_星级_ID
function GatheringLogMgr.SortItemDataByClockTime(Left, Right)
    if Left.AppearCondition ~= Right.AppearCondition then
        --出现中优先于即将出现
        if Left.AppearCondition == LSTR(70016) and Right.AppearCondition == LSTR(70023) then
            return true
        else
            return false
        end
    elseif Left.LeftTime ~= Right.LeftTime then
        return Left.LeftTime < Right.LeftTime
    end
    if Left.GatheringStar ~= Right.GatheringStar then
        return Left.GatheringStar < Right.GatheringStar
    else
        return Left.ID < Right.ID
    end
end

---@type 采集点的排序
function GatheringLogMgr.SortPlaceDataByLevelPredicate(Left, Right)
    if Left.MapID ~= Right.MapID then
        if Left.MapID < Right.MapID then
            return true
        end
    elseif Left.MapID == Right.MapID then
        if Left.GatherLevel < Right.GatherLevel then
            return true
        elseif Left.GatherLevel == Right.GatherLevel then
            return Left.bUnknownLoc < Right.bUnknownLoc
        end
    end
    return false
end

---@type 根据时间和职业排序
function GatheringLogMgr.SortByProfID(Left, Right)
    if Left.IsLock == true and Right.IsLock == false then
        return false
    end
    if Left.IsLock == false and Right.IsLock == true then
        return true
    end
    local LeftProfID = Left.ProfID
    local RightProfID = Right.ProfID
    if LeftProfID ~= RightProfID then
        if LeftProfID < RightProfID then
            return true
        end
    elseif LeftProfID == RightProfID then
        if Left.OnTime and Right.OnTime then
            return Left.OnTime < Right.OnTime
        end
    end
    return false
end

---@type 根据时间和职业排序
function GatheringLogMgr.SortSearchRecord(Left, Right)
    local LSearchRecordOrderNum = Left.SearchRecordOrderNum
    local RSearchRecordOrderNum = Right.SearchRecordOrderNum
    if LSearchRecordOrderNum ~= RSearchRecordOrderNum then
        if LSearchRecordOrderNum > RSearchRecordOrderNum then
            return true
        end
    elseif LSearchRecordOrderNum == RSearchRecordOrderNum then
        return false
    end
    return false
end
--endregion

---@type 首次制作经验的提示
function GatheringLogMgr:FirstGatherEXPBonus(Name, Score)
    local EXPValue = Score.Value
    local GetRitchText = RichTextUtil.GetText(string.format("%s", LSTR(70029)), "d1ba8e", 0, nil) --70029 获得了
    local ScoreInfo = ScoreCfg:FindCfgByKey(19000099)
    local IconRichText = RichTextUtil.GetTexture(ScoreInfo.IconName, 40, 40, -10)
    local ScoreRichText = RichTextUtil.GetText(string.format("[%s]", ScoreInfo.NameText), "DAB53AFF", 0, nil)
    local SoceNumRichText = RichTextUtil.GetText(string.format("x%s", _G.LootMgr.FormatCurrency(EXPValue)), "d1ba8e", 0, nil)
    local Content = string.format(LSTR(70030), Name, GetRitchText, IconRichText, ScoreRichText, SoceNumRichText) --70030 首次采集了[%s]%s%s%s%s
    if Score.Percent ~= 0 then
        Content = string.format("%s  ( + %d%s)", Content, Score.Percent, "%")
    end
    self:RegisterTimer(function ()
        _G.MsgTipsUtil.ShowTips(Content)
        _G.ChatMgr:AddSysChatMsg(Content)
    end, 2, 0, 1, nil)
end

---@type 获取途径接口
---@param ItemID number @笔记类型
function GatheringLogMgr:SearchInGatheringLog(ItemID)
    if ItemID == nil then
        _G.FLOG_ERROR("GatheringLogMgr:SearchInGatheringLog ItemID is nil")
        return
    end
    local Cfg = GatherNoteCfg:FindCfgByItemID(ItemID)
    if Cfg ~= nil then
        local Name = ItemUtil.GetItemName(ItemID)
        UIViewMgr:ShowView(UIViewID.GatheringLogMainPanelView)
        EventMgr:SendEvent(EventID.GatheringLogSearch, Name)
    else
        FLOG_ERROR("GatheringLogMgr:SearchInGatheringLog Cfg is nil")
	end
end

---@type 根据等级推荐的适合升级的普通采集点
---@param Prof number @职业ID 采矿工36or园艺工37
function GatheringLogMgr:GetRecommendCommonGatherPoint(Prof)
    -- 根据等级获得采集物
    local AllItems = self:GetItemDataByLevel()
    local CurItems = {}
    local HistoryList = self.HistoryList or {}
    for _, value in pairs(AllItems) do
        --筛选职业，普通/稀有
        if value.GatheringJob == Prof and value.LineageVolume == 0 then
            value.bGot = HistoryList[value.ID]
            table.insert(CurItems, value)
        end
    end
    -- 排序，未采集过的取等级小的，采集过的取等级高的，获得经验较高，适合升级
    table.sort(CurItems, function(a, b)
        if a.bGot ~= b.bGot then
            return a.bGot == false
        end
        if a.bGot == false then
            return a.GatheringGrade < b.GatheringGrade
        end
        return a.GatheringGrade > b.GatheringGrade
    end)

    local RecommendList = {}
    local TempList = {}
    local MapID
    local NeedNum = 3
    for _, value in pairs(CurItems) do
        local ExistPlace = self:GetGatherPlaceByItemData(value)
        for _, GatherPoint in pairs(ExistPlace) do
            MapID = GatherPoint.MapID
            if not TempList[MapID] then
                TempList[MapID] = true
                table.insert(RecommendList, MapID)
                NeedNum = NeedNum -1
                if NeedNum == 0 then
                    return RecommendList
                end
            end
        end
    end
    return RecommendList
end

---@type 已满级时推荐的稀有采集点
---@param Prof number @职业ID 采矿工36or园艺工37
function GatheringLogMgr:GetRecommendRareGatherPoint(Prof)
    local RareGatherPoints = {}
    local ServerTime = TimeUtil.GetServerLogicTime()
    local AozySecond = ServerTime * (12 / 35) * 60
    local OneDaySec = 86400
    local DayTime = AozySecond % OneDaySec -- 取余
    local AllPlaceCfg = GatherPointCfg:FindAllCfg()
    for _, value in pairs(AllPlaceCfg) do
        if value.IsUnknownLoc == 1 and self:BeIncludedInGameVersion(value.Version) then
            local GatherJob = self:GetGatherJobByGatherType(value.GatherType)
            if GatherJob == Prof then
                local TimeCondition = self:GetTimeConditonByPlace(value)
                if not table.is_nil_empty(TimeCondition) then
                    local StartAozyTime, EndAozyTime = self:GetStartAndEndAozyTime(TimeCondition[1])
                    if DayTime <= EndAozyTime and DayTime >= StartAozyTime then
                        table.insert(RareGatherPoints, value)
                    end
                end
            end
        end
    end
    table.sort(RareGatherPoints, function(a, b)
        return a.GatherLevel < b.GatherLevel
    end)
    local RecommendList = {}
    local TempList = {}
    local MapID
    local NeedNum = 2
    for _, GatherPoint in pairs(RareGatherPoints) do
        MapID = GatherPoint.MapID
        if not TempList[MapID] then
            TempList[MapID] = true
            table.insert(RecommendList, MapID)
            NeedNum = NeedNum -1
            if NeedNum == 0 then
                return RecommendList
            end
        end
    end
    return RecommendList
end

return GatheringLogMgr
