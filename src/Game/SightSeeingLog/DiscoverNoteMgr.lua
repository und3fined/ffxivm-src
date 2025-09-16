--
-- Author: Alex
-- Date: 2024-02-28 16:06
-- Description:探索笔记
-- SecondContentToChange 二期标签

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local DiscoverNoteVM = require("Game/SightSeeingLog/DiscoverNoteVM")
local DiscoverNoteDefine = require("Game/SightSeeingLog/DiscoverNoteDefine")
local MysterMerchantUtils = require("Game/MysterMerchant/MysterMerchantUtils")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local DiscoverNoteCfg = require("TableCfg/DiscoverNoteCfg")
local DiscoverNoteAreaCfg = require("TableCfg/DiscoverNoteAreaCfg")
local DiscoverCondCfg = require("TableCfg/DiscoverNotePerfectCondCfg")
local DiscoverNoteHintCfg = require("TableCfg/DiscoverNoteHintCfg")
local CompleteSkillCfg = require("TableCfg/DiscoverNoteCompleteSkillCfg")
local MapRegionIconCfg = require("TableCfg/MapRegionIconCfg")
--local EObjCfg = require("TableCfg/EobjCfg")
local MapUtil = require("Game/Map/MapUtil")
------local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local EffectUtil = require("Utils/EffectUtil")
local TimeUtil = require("Utils/TimeUtil")
local TimeDefine = require("Define/TimeDefine")
local AozyTimeDefine = TimeDefine.AozyTimeDefine
local WeatherUtil = require("Game/Weather/WeatherUtil")
local AudioUtil = require("Utils/AudioUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local BitUtil = require("Utils/BitUtil")
local SaveKey = require("Define/SaveKey")
local FlagBit = ProtoCS.FlagBit
--local HUDType = require("Define/HUDType")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")

local CS_CMD = ProtoCS.CS_CMD
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local SUB_MSG_ID = ProtoCS.SearchNoteCmd
local NoteUnlockType = DiscoverNoteDefine.NoteUnlockType
local NoteClueType = DiscoverNoteDefine.NoteClueType
local NoteClueSrcType = DiscoverNoteDefine.NoteClueSrcType
local NoteDetailSevReturnType = DiscoverNoteDefine.NoteDetailSevReturnType
local LeftSidebarType = SidebarDefine.LeftSidebarType
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType
local ModuleID = ProtoCommon.ModuleID
local GuideID = DiscoverNoteDefine.GuideID
local ITEM_UPDATE_TYPE = ProtoCS.ITEM_UPDATE_TYPE
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local NoteCompleteVfxEffectCommonID = DiscoverNoteDefine.NoteCompleteVfxEffectCommonID
local LSTR = _G.LSTR
local EActorType = _G.UE.EActorType
local SingleNoteTotalClueNum = 3 -- 单条笔记的总线索数
local ChatMsgMaxCd = 30 -- 系统提示信息间隔CD
local TimerDeltTime = 1 -- 计时器更新间隔

local ClientVisionMgr
local PWorldMgr
local EmotionMgr
local StoryMgr
local MapEditDataMgr
local QuestMgr
local SaveMgr
local RedDotMgr
local InteractiveMgr
local LeftSidebarMgr
local ModuleOpenMgr
local RangeCheckTriggerMgr
local BagMgr
local EventMgr
local WildBoxMoundMgr
local MysterMerchantMgr
local TouringBandMgr

---@class DiscoverNoteMgr : MgrBase
---@field EmotionEndCallBack function@情感动作结束后向服务器发送
local DiscoverNoteMgr = LuaClass(MgrBase)

function DiscoverNoteMgr:OnInit()
    -- 辅助查找
    self.NoteItemID2ItemIndex = {}
    self:InitDiscoverNoteIndexInfos()
    self.EobjID2NoteItemInfo = {}
    self.PerfectEobjID2NoteItemInfo = {}
    self.PickEobjId2ClueCfgInfo = {}
    self.HintMapNpcListID2NoteInfo = {} -- 情感动作提示NPCListID对应笔记
    self.HintSrcNpcListID2NoteHintInfo = {} -- 线索获取Npc与笔记ID
    self.MapID2PointNum = {} -- 地图ID对应的点位数量
   
    self.MapID2DetectSkillCfg = {} -- 以地图ID为Key存储的普通探索全收集技能数据

    -- 野外探索需求
    self.PointTotalNum = 0

    self:LoadDiscoverNoteTableCfgIDs()
    self:LoadDiscoverNoteClueTableCfgs()
    self:LoadDiscoverNoteCompleteSkillCfg()
end

function DiscoverNoteMgr:OnBegin()
    ClientVisionMgr = _G.ClientVisionMgr
    PWorldMgr = _G.PWorldMgr
    EmotionMgr = _G.EmotionMgr
    StoryMgr = _G.StoryMgr
    MapEditDataMgr = _G.MapEditDataMgr
    QuestMgr  = _G.QuestMgr
    SaveMgr = _G.UE.USaveMgr
    InteractiveMgr = _G.InteractiveMgr
    LeftSidebarMgr = _G.LeftSidebarMgr
    ModuleOpenMgr = _G.ModuleOpenMgr
    RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
    RangeCheckTriggerMgr = _G.RangeCheckTriggerMgr
    BagMgr = _G.BagMgr
    EventMgr = _G.EventMgr
    WildBoxMoundMgr = _G.WildBoxMoundMgr
    MysterMerchantMgr = _G.MysterMerchantMgr
    TouringBandMgr = _G.TouringBandMgr
    self.MapId2PointCompleteInfo = {} -- 地图ID点位完成进度信息
    self.MapIdZeroPercentage = {} -- 地图进度为0的id列表
    self:InitMapIdZeroPercentage()
    self.bEmotionEnd = false
    self.bIsInteracting = false -- 因为交互模块判断条件过于复杂，所以此处变量仍保持不处理
    self.bEmotionEndWaitForInteract = false -- 是否处于情感动作结束等待交互协议

    self.RegionTabNewRedDotList = {} -- 探索笔记地域页签新解锁红点提示地域id列表
    self.RegionWaitForUnlock = {} -- 探索笔记等待解锁地域页签
    self.bRegionWaitForUnlockInit = true -- 待解锁地域数据初始化标志
    self.ClueUnlockAnimRecordList = {} -- 笔记线索解锁动画记录

    self.NoteItemRedDotList = {} -- 探索笔记新解锁笔记红点列表

    self:LoadLastAddPointDataFromLocalDevice()

    -- 二期风景点激活情感动作流程修改不使用闭包回调完成请求交互逻辑
    self.InteractiveID = nil -- 单次解锁交互ID记录
    self.EntityID = nil -- 单次解锁交互的Actor唯一ID
    self.bPerfectPointActive = false -- 是否为完美探索风景点操作
    self.NotePointEobjIDsInVision = {} -- 视野内风景点列表

    -- 野外探索需求
    self.NormalCompleteNum = 0
    self.PerfectCompleteNum = 0

    -- 三期需求
    self.DetectTargetInRange = {} -- 标记用数据Param结构{ MarkerID = MarkerID, ActiveID = ActiveID, Location = Location, ActorType = ActorType }

    self.NoteNeedUpdatePerfectCond = {} -- 需要计时器更新的笔记列表
    self.PerfectCondFirstTimeHandle = nil -- 首次更新计时
    self.PerfectCondLoopTimeHandle = nil -- 界面中稳定计时（每艾欧泽亚时运行一次）

    self.MapUsePerfectCondFirstTimeHandle = nil -- 地图用定时更新计时器
    self.MapUsePerfectCondLoopTimeHandle = nil  -- 地图用定时更新计时器
    self.ChatMsgTipsCurCd = 0 -- 进入检测范围系统提示Cd

    --- V2 协议及存储结构优化
    self.NoteSevDatasMap = {} -- 笔记服务器数据结构直接存储{Key = NoteID Info = {Flag(点位及线索状态), NextTime(下次出现时间)}}
    self.NoteIDPerfectCompleteMap = {} -- 完美探索完成笔记Id(默认线索全解锁，节省内存)
end

function DiscoverNoteMgr:OnEnd()
    self:SaveLastAddPointDataInLocalDevice()
    self.NoteSevDatasMap = nil
    self.NoteIDPerfectCompleteMap = nil
    self.EmotionEndCallBack = nil
    self.bEmotionEnd = false
    self.RegionTabNewRedDotList = nil
    self.RegionWaitForUnlock = nil
    self.NoteItemRedDotList = nil
    self.ClueUnlockAnimRecordList = nil
    self.InteractiveID = nil -- 单次解锁交互ID记录
    self.EntityID = nil -- 单次解锁交互的Actor唯一ID
    self.MapId2PointCompleteInfo = nil
    self.MapIdZeroPercentage = nil
    self.DetectTargetInRange = nil
    self.PerfectCondFirstTimeHandle = nil
    self.PerfectCondLoopTimeHandle = nil
end

function DiscoverNoteMgr:OnShutdown()
    self.NoteItemID2ItemIndex = nil
    self.EobjID2PointID = nil
    self.PerfectEobjID2NoteItemInfo = nil
    self.PickEobjId2ClueCfgInfo = nil
    self.HintMapNpcListID2NoteInfo = nil
    self.MapID2PointNum = nil
    self.HintSrcNpcListID2NoteHintInfo = nil
    self.MapID2DetectSkillCfg = nil
end

function DiscoverNoteMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_SEARCH_NOTE, SUB_MSG_ID.SearchNoteCmdQuery, self.OnNetMsgExploreNoteDataSync)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_SEARCH_NOTE, SUB_MSG_ID.SearchNoteCmdNotify, self.OnNetMsgExploreNoteAccomplishRsp)
end

function DiscoverNoteMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnGameEventNetworkReconnected)
    self:RegisterGameEvent(EventID.PostEmotionEnter, self.OnGameEventPostEmotionEnter)
    self:RegisterGameEvent(EventID.PostEmotionEnd, self.OnGameEventPostEmotionEnd)
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnGameEventUpdateQuest)
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
    self:RegisterGameEvent(EventID.ShowUI, self.OnMainMapUIShow)
    self:RegisterGameEvent(EventID.HideUI, self.OnMainMapUIHide)
    self:RegisterGameEvent(EventID.BagUpdate, self.OnGameEventBagUpdate)

    self:RegisterGameEvent(EventID.LoadWildBoxRangeCheckData, self.LoadWildBoxRangeCheckData)
    self:RegisterGameEvent(EventID.RemoveWildBoxRangeCheckDataByBoxOpened, self.OnRemoveWildBoxRangeCheckDataByBoxOpened)
    self:RegisterGameEvent(EventID.AddTouringBandRangeCheckData, self.OnAddTouringBandRangeCheckData)
    self:RegisterGameEvent(EventID.RemoveTouringBandRangeCheckData, self.OnRemoveTouringBandRangeCheckData)
    self:RegisterGameEvent(EventID.LoadMysterMerchantRangeCheckData, self.LoadMysterMerchantRangeCheckData)
    self:RegisterGameEvent(EventID.RemoveMysterMerchantRangeCheckData, self.OnRemoveMysterMerchantRangeCheckData)
end

function DiscoverNoteMgr:OnRegisterTimer()
    self:RegisterTimer(self.OnTimeTick, 0, TimerDeltTime, 0)
end

function DiscoverNoteMgr:OnTimeTick()
    local CurCd = self.ChatMsgTipsCurCd
    if CurCd > 0 then
        self.ChatMsgTipsCurCd = CurCd - TimerDeltTime
    end

    -- 完美与普通条件切换时对应消失Point手动控制隐藏
    local NotePointsInVision = self.NotePointEobjIDsInVision
    if not NotePointsInVision or not next(NotePointsInVision) then
        return
    end

    for EObjID, _ in pairs(NotePointsInVision) do
        if not self:CanCreateEObj(EObjID) then
            local EObjData = MapEditDataMgr:GetEObjByResID(EObjID)
            if EObjData then
                local MapEditorID = EObjData.ID
                if MapEditorID then
                    ClientVisionMgr:ClientActorLeaveVision(MapEditorID, EActorType.EObj)
                end
            end

            -- 隐藏情感动作NPC
            local PerfectEobjID2NoteItemInfo = self.PerfectEobjID2NoteItemInfo
            if PerfectEobjID2NoteItemInfo then
                local NoteItemInfo = PerfectEobjID2NoteItemInfo[EObjID]
                if NoteItemInfo then
                    local NoteID = NoteItemInfo.NoteItemID
                    if NoteID then
                        DiscoverNoteVM:CloseActChoosePanelByPointChangeToNormal(NoteID)
                    end
                    local CondCfg = NoteItemInfo.CondCfg
                    if CondCfg then
                        local NPCListID = CondCfg.NPCListID
                        if NPCListID then
                            ClientVisionMgr:ClientActorLeaveVision(NPCListID, EActorType.Npc)
                        end
                    end
                end
            end
        end
    end

    -- 更新失败状态客户端恢复
    local NoteSevDatasMap = self.NoteSevDatasMap
    if not NoteSevDatasMap then
        return
    end
    for ID, Note in pairs(NoteSevDatasMap) do
        if self:IsNotePointUnderPerfectActiveFail(ID) then
            local NextTime = Note.NextTime
            local CurTime = TimeUtil.GetServerLogicTime()
            if CurTime > NextTime then
                local Flag = Note.Flag
                Note.Flag = BitUtil.ClearBit(Flag, FlagBit.FlagBitUnPerfectIdx)
                Note.NextTime = nil
            end
        end
    end
end

function DiscoverNoteMgr:NotifyTriggerTheTutorial()
    --新手引导系统解锁处理
    local function OnTutorial()
        --发送新手引导触发获得物品触发消息
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.NearTargetField --新手引导触发类型
        EventParams.Param1 = TutorialDefine.NearTargetFieldType.DiscoverNote
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

--- 通知风景点进入/离开视野
function DiscoverNoteMgr:NotifyNotePointVisionStateChange(Params, bEnterOrLeave)
    local EobjID = Params.IntParam2
    if not EobjID then
        return
    end

    local ActorType = Params.IntParam1
    if ActorType ~= EActorType.EObj then
        return
    end

    local EntityID = Params.ULongParam1
    if not EntityID then
        return
    end

    local bNormalPoint = self:IsNormalNotePoint(EobjID)
    local bPerfectPoint = self:IsPerfectNotePoint(EobjID)
    if not bNormalPoint and not bPerfectPoint then
        return
    end

    if bEnterOrLeave then
        local NotePointEobjIDsInVision = self.NotePointEobjIDsInVision or {}
        NotePointEobjIDsInVision[EobjID] = EntityID
        self.NotePointEobjIDsInVision = NotePointEobjIDsInVision
    else
        local NotePointEobjIDsInVision = self.NotePointEobjIDsInVision
        if not NotePointEobjIDsInVision or not next(NotePointEobjIDsInVision) then
            return
        end
        NotePointEobjIDsInVision[EobjID] = nil
        if bNormalPoint then -- 如果普通点去除
            if self.bIsInteracting and self.EntityID == EntityID then -- 如果处于情感动作进行中且交互的EObj就是当前EObj
                self.bIsInteracting = false
                self.bEmotionEndWaitForInteract = false
                _G.InteractiveMgr:SetShowMainPanelEnabled(true)
                _G.InteractiveMgr:ShowInteractiveEntrance()
            end
        end
    end
    if not _G.TutorialGuideMgr:CheckGuide(GuideID) then
        if bEnterOrLeave then
            RangeCheckTriggerMgr:AddRangeCheckActorCreated(TriggerGamePlayType.DiscoverNoteTutorial, EntityID)
        else
            RangeCheckTriggerMgr:RemoveRangeCheckActorCreated(EntityID)
        end
    end
end

--- 通知Eobj线索进入/离开视野
function DiscoverNoteMgr:NotifyNoteClueEobjVisionStateChange(Params, bEnterOrLeave)
    local EobjID = Params.IntParam2
    if not EobjID then
        return
    end

    local ActorType = Params.IntParam1
    if ActorType ~= EActorType.EObj then
        return
    end

    local EntityID = Params.ULongParam1
    if not EntityID then
        return
    end

    local PickEobjId2ClueCfgInfo = self.PickEobjId2ClueCfgInfo
    if not PickEobjId2ClueCfgInfo or not next(PickEobjId2ClueCfgInfo) then
        return
    end

    local ClueCfgInfo = PickEobjId2ClueCfgInfo[EobjID]
    if not ClueCfgInfo then
        return
    end

    --- 不配置特效种类的Eobj不进行范围检测
    local EffectType = ClueCfgInfo.EffectType
    if not EffectType or EffectType == 0 then
        return
    end

    if bEnterOrLeave then
        RangeCheckTriggerMgr:AddRangeCheckActorCreated(TriggerGamePlayType.DiscoverNoteClueEffect, EntityID)
    else
        RangeCheckTriggerMgr:RemoveRangeCheckActorCreated(EntityID)
    end
end

function DiscoverNoteMgr:OnGameEventVisionLeave(Params)
    self:NotifyNotePointVisionStateChange(Params)
    self:NotifyNoteClueEobjVisionStateChange(Params)
end

function DiscoverNoteMgr:OnGameEventVisionEnter(Params)
    self:NotifyNotePointVisionStateChange(Params, true)
    self:NotifyNoteClueEobjVisionStateChange(Params, true)
end

function DiscoverNoteMgr:OnMainMapUIShow(ViewID)
    if ViewID == UIViewID.WorldMapPanel then
        self:StartUpdateMapPerfectCondTimer()
    elseif ViewID == UIViewID.MainPanel then
        self:InitRegionWaitForUnlock()
    end
end

function DiscoverNoteMgr:OnMainMapUIHide(ViewID)
    if ViewID == UIViewID.WorldMapPanel then
        self:StopUpdateMapPerfectCondTimer()
    end
end

function DiscoverNoteMgr:OnGameEventBagUpdate(UpdateItem)
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        return
    end
    local ActiveID = self:GetTheMapActiveID(CurMapID)
    if not ActiveID then
        return
    end

    local ItemID = CompleteSkillCfg:FindValue(ActiveID, "EvidenceItemID")
    if not ItemID then
        return
    end

    for _, v in ipairs(UpdateItem) do
		if v.Type == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD then
            local CommItem = v.PstItem
            local ResID = CommItem.ResID
            if ResID == ItemID then
                self:SendLoadDetectRangeEventToUpdate()
                break
            end
		end
	end
end

function DiscoverNoteMgr:OnGameEventLoginRes(Params)
    if _G.DemoMajorType ~= 0 then
        return
    end

    if not ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDSightseeingLog) then
        return
    end

    -- 0表示拉取所有地域信息
    self:SendMsgGetExploreNote(0)

    local bReconnect = Params.bReconnect
    if bReconnect then
        _G.InteractiveMgr:SetShowMainPanelEnabled(true) 
    end
end

function DiscoverNoteMgr:OnModuleOpenNotify(InModuleID)
    if ModuleID.ModuleIDSightseeingLog == InModuleID then
        -- 0表示拉取所有地域信息
        self:SendMsgGetExploreNote(0)
    end
end

--- 闪断情况重连逻辑
function DiscoverNoteMgr:OnGameEventNetworkReconnected(Params)
    if not Params or not Params.bRelay then
        return
    end
    _G.InteractiveMgr:SetShowMainPanelEnabled(true)
end

function DiscoverNoteMgr:OnGameEventPostEmotionEnter(Params)

end

function DiscoverNoteMgr:NotifyActivateDiscoverNote(Params)
    if self.bEmotionEndWaitForInteract then -- 探索笔记情感动作交互判定中，不再接受新的情感动作事件
        return
    end
    local EntityID = Params.ULongParam1
	local EmotionID = Params.IntParam1
	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end

    self:InteractiveReqAfterEmotionEnd(EmotionID)
end

function DiscoverNoteMgr:OnGameEventPostEmotionEnd(Params)
	local _ <close> = CommonUtil.MakeProfileTag("DiscoverNoteMgr:OnGameEventPostEmotionEnd")
    self:NotifyActivateDiscoverNote(Params)
end

function DiscoverNoteMgr:OnGameEventUpdateQuest()
    self:UpdateRegionWaitForUnlock()
end

------ V2 ------
------ Msg Part ------

--- 主动拉取探索笔记服务器信息
---@param RegionID number@为0时为拉取所有地域信息
function DiscoverNoteMgr:SendMsgGetExploreNote(RegionID)
    local MsgID = CS_CMD.CS_CMD_SEARCH_NOTE
    local SubMsgID = SUB_MSG_ID.SearchNoteCmdQuery

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.Query = {RegionID = RegionID}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 回包解析探索笔记服务器信息
function DiscoverNoteMgr:OnNetMsgExploreNoteDataSync(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("OnNetMsgExploreNoteDataSync: MsgBody is nil")
        return
    end

    local MsgRsp = MsgBody.Query
    if not MsgRsp then
        return
    end

    local RegionID = MsgRsp.RegionID
    if not RegionID then
        return
    end
    
    local Notes = MsgRsp.Notes
    if Notes then
        for _, Note in ipairs(Notes) do
           self:UpdateClientNoteInfoFromSevInfo(Note)
        end
    end
end
------ Msg Part End ------

--- 更新单个笔记信息
---@param NoteSev SearchNote@CS协议结构
function DiscoverNoteMgr:UpdateClientNoteInfoFromSevInfo(NoteSev)
    local RltChange = {}
    local NoteSevDatasMap = self.NoteSevDatasMap or {}
    local NoteIDPerfectCompleteMap = self.NoteIDPerfectCompleteMap or {}
    local ID = NoteSev.ID
    local Flag = NoteSev.Flag
    if ID and Flag then
        local OldNotePerfectActive = self:IsNotePointPerfectActived(ID)
        local OldNoteNormalActive = self:IsNotePointActived(ID)
        local OldNotePerfectActiveFail = self:IsNotePointUnderPerfectActiveFail(ID)
        
        local bSevNotePerfectActive = BitUtil.IsBitSet(Flag, FlagBit.FlagBitPerfectIdx)
        -- 线索部分单独处理
        local OldWeatherCond = self:IsNoteClueUnlockByClueType(ID, NoteClueType.Weather)
        local OldTimeCond = self:IsNoteClueUnlockByClueType(ID, NoteClueType.Time)
        local OldEmotionCond = self:IsNoteClueUnlockByClueType(ID, NoteClueType.Emotion)
        local WeatherUnlock = bSevNotePerfectActive or BitUtil.IsBitSet(Flag, FlagBit.FlagBitWeatherClueIdx)
        local TimeUnlock = bSevNotePerfectActive or BitUtil.IsBitSet(Flag, FlagBit.FlagBitTimeClueIdx)
        local EmotionIDUnlock = bSevNotePerfectActive or BitUtil.IsBitSet(Flag, FlagBit.FlagBitEmotionClueIdx)
        RltChange.WeatherCondChange = WeatherUnlock ~= OldWeatherCond
        RltChange.TimeCondChange = TimeUnlock ~= OldTimeCond
        RltChange.EmotionCondChange = EmotionIDUnlock ~= OldEmotionCond

        -- 探索点状态部分
        if bSevNotePerfectActive then
            NoteIDPerfectCompleteMap[ID] = true
            NoteSevDatasMap[ID] = nil -- 探索笔记完美解锁之后不需要再存储其他状态
        else
            local NoteSevData = NoteSevDatasMap[ID] or {}
            local bSevNotePerfectActiveFail = BitUtil.IsBitSet(Flag, FlagBit.FlagBitUnPerfectIdx)
            if bSevNotePerfectActiveFail then
                local NextTime = NoteSev.NextTime
                local CurSevTime = TimeUtil.GetServerLogicTime()
                if CurSevTime > NextTime then
                    Flag = BitUtil.ClearBit(Flag, FlagBit.FlagBitUnPerfectIdx)
                else
                    NoteSevData.NextTime = NextTime
                end
                Flag = BitUtil.SetBit(Flag, FlagBit.FlagBitNormalIdx)
            end
            NoteSevData.Flag = Flag
            NoteSevDatasMap[ID] = NoteSevData
        end
        self.NoteSevDatasMap = NoteSevDatasMap
        self.NoteIDPerfectCompleteMap = NoteIDPerfectCompleteMap

        -- 探索数目部分(此时接口已使用的是更新后的数据)
        local bCurNotePerfectActive = self:IsNotePointPerfectActived(ID)
        local bCurNoteNormalActive = self:IsNotePointActived(ID)
        local bCurNotePerfectActiveFail = self:IsNotePointUnderPerfectActiveFail(ID)
        if bCurNotePerfectActive ~= OldNotePerfectActive then
            local OldPerfectCompleteNum = self.PerfectCompleteNum or 0
            self.PerfectCompleteNum = OldPerfectCompleteNum + 1
            self:AddMapPointCompleteNumByNoteID(ID, false)
            RltChange.PerfectActiveStateChange = true
        end
        if bCurNoteNormalActive ~= OldNoteNormalActive then
            local OldNormalCompleteNum = self.NormalCompleteNum or 0
            self.NormalCompleteNum = OldNormalCompleteNum + 1
            self:AddMapPointCompleteNumByNoteID(ID, true)
            RltChange.ActiveStateChange = true                   
        end
        if bCurNotePerfectActiveFail ~= OldNotePerfectActiveFail then
            RltChange.PerfectActiveFailChanged = true
        end
    end
    return RltChange    
end

--- 组装右侧笔记列表数据
---@param RegionID number@地域id
---@param bUpdatePerfectCondTimer boolean@是否更新符合条件的笔记的完美状态提醒
function DiscoverNoteMgr:MakeTheRegionNoteItemSevInfos(RegionID, bUpdatePerfectCondTimer)
    local Rlt = {}
    local RegionItemCfgs = DiscoverNoteCfg:FindAllCfg(string.format("AreaID = %d", RegionID))
    if not RegionItemCfgs then
        return Rlt
    end

    if bUpdatePerfectCondTimer then
        self.NoteNeedUpdatePerfectCond = {}
    end

    for _, RegionItemCfg in ipairs(RegionItemCfgs) do
        local Id = RegionItemCfg.ID
        if Id then
            local ItemSev = {
                NoteItemID = Id,
                ItemIndex = self.NoteItemID2ItemIndex[Id] or 0,
                bCompleted = self:IsNotePointActived(Id),
                bPerfectComplete = self:IsNotePointPerfectActived(Id),
                bShowPerfectCondEffect = false,
            }
            
            local bPerfectComplete = ItemSev.bPerfectComplete
            local bAllClueUnlock = self:IsNoteClueUnlockByClueType(Id, NoteClueType.Weather)
            and self:IsNoteClueUnlockByClueType(Id, NoteClueType.Time) and self:IsNoteClueUnlockByClueType(Id, NoteClueType.Emotion)
            ItemSev.bShowPerfectCondEffect = bAllClueUnlock and self:IsNotePointUnderPerfectCondByNoteID(Id) and not bPerfectComplete
            if bUpdatePerfectCondTimer and bAllClueUnlock and not bPerfectComplete then
                table.insert(self.NoteNeedUpdatePerfectCond, {NoteID = Id, bShowPerfectCondEffect = ItemSev.bShowPerfectCondEffect})
            end
            table.insert(Rlt, ItemSev)
        end
    end
    return Rlt
end

--- 获取地域笔记完成数量信息
---@param RegionID number@地域id
---@return TotalNum, CompletedNum @总数/完成数
function DiscoverNoteMgr:GetRegionNoteCompleteNumInfo(RegionID)
    local TotalNum = 0
    local CompletedNum = 0
    local MapID2PointNum = self.MapID2PointNum
    if not MapID2PointNum then
        return TotalNum, CompletedNum
    end

    for MapID, MapTotalNum in pairs(MapID2PointNum) do
        local MapRegionID = MapUtil.GetMapRegionID(MapID)
        if MapRegionID == RegionID then
            TotalNum = TotalNum + MapTotalNum
            local MapId2PointCompleteInfo = self.MapId2PointCompleteInfo
            if MapId2PointCompleteInfo then
                local MapCompleteInfo = MapId2PointCompleteInfo[MapID]
                if MapCompleteInfo then
                    CompletedNum = CompletedNum + MapCompleteInfo.NormalCompleteNum
                end
            end
        end
    end
    return TotalNum, CompletedNum
end

--- 探索笔记点是否完美激活（二期）
function DiscoverNoteMgr:IsNotePointPerfectActived(NoteItemID)
    local NoteIDPerfectCompleteMap = self.NoteIDPerfectCompleteMap
    if not NoteIDPerfectCompleteMap or not next(NoteIDPerfectCompleteMap) then
        return false
    end
    return NoteIDPerfectCompleteMap[NoteItemID] ~= nil
end

--- 探索笔记点是否已经激活(完美激活也认为已激活)
function DiscoverNoteMgr:IsNotePointActived(NoteItemID)
    if self:IsNotePointPerfectActived(NoteItemID) then
        return true
    end

    local NoteSevDatasMap = self.NoteSevDatasMap
    if not NoteSevDatasMap or not next(NoteSevDatasMap) then
        return false
    end

    local NoteSevData = NoteSevDatasMap[NoteItemID]
    if not NoteSevData then
        return false
    end

    local Flag = NoteSevData.Flag
    if not Flag then
        return false
    end

    return BitUtil.IsBitSet(Flag, FlagBit.FlagBitNormalIdx)
end

--- 判定当前探索点是否处于完美解锁失败的情况下
---@param NoteID number@笔记ID
function DiscoverNoteMgr:IsNotePointUnderPerfectActiveFail(NoteID)
    local NoteSevDatasMap = self.NoteSevDatasMap
    if not NoteSevDatasMap and not next(NoteSevDatasMap) then
        return false
    end
    local NoteSevData = NoteSevDatasMap[NoteID]
    if not NoteSevData then
        return false
    end
    local Flag = NoteSevData.Flag
    if not Flag then
        return false
    end
    return BitUtil.IsBitSet(Flag, FlagBit.FlagBitUnPerfectIdx)
end

--- 判定当前笔记是否在完美探索条件下(时间、天气)
---@param NoteCondCfg CfgBase@探索笔记条件表行数据
function DiscoverNoteMgr:IsNotePointUnderPerfectCond(NoteCondCfg)
    if not NoteCondCfg then
        return false
    end

    local NoteID = NoteCondCfg.ID
    if not NoteID then
        return false
    end
    
    local NoteItemCfg = DiscoverNoteCfg:FindCfgByKey(NoteID)
    if not NoteItemCfg then
        return false
    end

    local MapID = NoteItemCfg.MapID
    -- 天气条件判断
    do
        local CurWeatherId = WeatherUtil.GetMapWeather(MapID, 0)
        if CurWeatherId then
            local WeatherIDs = NoteCondCfg.WeatherID
            if WeatherIDs and next(WeatherIDs) then
                local bWeatherInclude = false
                local bWeatherNoLimit = true
                for _, WeatherID in ipairs(WeatherIDs) do
                    if WeatherID > 0 then
                        bWeatherNoLimit = false
                        if WeatherID == CurWeatherId then
                            bWeatherInclude = true
                            break
                        end
                    end
                end
                if not bWeatherNoLimit and not bWeatherInclude then
                    return false
                end
            end
        end
    end

    -- 时间条件判断
    do
        local StartTime = NoteCondCfg.StartTime or 0
        local EndTime = NoteCondCfg.EndTime or 0
        if StartTime > 0 or EndTime > 0 then
            local AozyHour = TimeUtil.GetAozyHour()
            if EndTime == 0 then
                EndTime = 24
            end
            if StartTime < EndTime then
                if AozyHour < StartTime or AozyHour >= EndTime then
                    return false
                end
            elseif StartTime > EndTime then
                if AozyHour >= EndTime and AozyHour < StartTime then
                    return false
                end
            end
        end

        if self:IsNotePointUnderPerfectActiveFail(NoteID) then
            return false
        end
    end

    return true
end

--- 探索笔记某种线索是否解锁
---@param NoteItemID number @探索笔记ID
---@param ClueType NoteClueType@线索种类枚举
function DiscoverNoteMgr:IsNoteClueUnlockByClueType(NoteID, ClueType)
    local NoteIDPerfectCompleteMap = self.NoteIDPerfectCompleteMap
    if NoteIDPerfectCompleteMap and next(NoteIDPerfectCompleteMap) then
        if NoteIDPerfectCompleteMap[NoteID] then
            return true
        end
    end

    local NoteSevDatasMap = self.NoteSevDatasMap
    if not NoteSevDatasMap or not next(NoteSevDatasMap) then
        return false
    end

    local NoteSevData = NoteSevDatasMap[NoteID]
    if not NoteSevData then
        return false
    end

    local Flag = NoteSevData.Flag
    if not Flag then
        return false
    end

    if ClueType == NoteClueType.Weather then
        return BitUtil.IsBitSet(Flag, FlagBit.FlagBitWeatherClueIdx)
    elseif ClueType == NoteClueType.Time then
        return BitUtil.IsBitSet(Flag, FlagBit.FlagBitTimeClueIdx)
    elseif ClueType == NoteClueType.Emotion then
        return BitUtil.IsBitSet(Flag, FlagBit.FlagBitEmotionClueIdx)
    end
    return false
end

--- 为展示结果界面构造数据
---@param NoteID number@笔记ID
function DiscoverNoteMgr:MakeTheFinishPopUpPanelData(NoteID)
    return {
        NoteItemID = NoteID,
        ItemIndex = self.NoteItemID2ItemIndex[NoteID] or 0,
        bPerfectComplete = self:IsNotePointPerfectActived(NoteID),
        bCompleted = self:IsNotePointActived(NoteID),
        UnlockFail = self:IsNotePointUnderPerfectActiveFail(NoteID)
    }
end

--- 根据EObjResId获取对应的笔记ID
function DiscoverNoteMgr:GetTheNoteIDByEobjResID(EobjResID)
    local PerfectEobjID2NoteItemInfo = self.PerfectEobjID2NoteItemInfo
    local EobjID2NoteItemInfo = self.EobjID2NoteItemInfo
    if not PerfectEobjID2NoteItemInfo and not EobjID2NoteItemInfo then
        return
    end

    local PerfectNoteCfgInfo = PerfectEobjID2NoteItemInfo[EobjResID]
    if PerfectNoteCfgInfo then
        return PerfectNoteCfgInfo.NoteItemID
    end

    local NoteCfgInfo = EobjID2NoteItemInfo[EobjResID]
    if NoteCfgInfo then
        return NoteCfgInfo.NoteItemID
    end
end

------ V2 End ------

--- World加载EObj Actor时的判断依据(二期待定)
---@param EObjID number@EObj表格id
function DiscoverNoteMgr:CanCreateEObj(EObjID)
    local NoteModuleOpen = ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDSightseeingLog)
    if not NoteModuleOpen then
        return false
    end

    local PerfectEobjID2NoteItemInfo = self.PerfectEobjID2NoteItemInfo
    if PerfectEobjID2NoteItemInfo then
        local PerfectNoteInfo = PerfectEobjID2NoteItemInfo[EObjID]
        if PerfectNoteInfo then
            local NoteId = PerfectNoteInfo.NoteItemID or 0
            local bPerfectCond = self:IsNotePointUnderPerfectCond(PerfectNoteInfo.CondCfg)
            if not bPerfectCond then
                return false
            end

            return not self:IsNotePointPerfectActived(NoteId)
        end
    end

    local EobjID2NoteItemInfo = self.EobjID2NoteItemInfo
    if not EobjID2NoteItemInfo then
        FLOG_ERROR("DiscoverNoteMgr:CanCreateEObj: EobjID2NoteItemInfo is not valid.")
        return false
    end

    local PointInfo = EobjID2NoteItemInfo[EObjID]
    if PointInfo == nil then
        return false
    end

    local PerfectEObjID = PointInfo.PerfectEObjID
    if PerfectEObjID and PerfectEObjID > 0 and PerfectEobjID2NoteItemInfo then
        local NoteItemInfo = PerfectEobjID2NoteItemInfo[PerfectEObjID]
        if NoteItemInfo and self:IsNotePointUnderPerfectCond(NoteItemInfo.CondCfg) then
            return false
        end
    end

    local PointID = PointInfo.NoteItemID
    if not PointID then
        return false
    end

    return not self:IsNotePointActived(PointID)
end

--- World加载EObj Actor时的判断依据(二期待定)
---@param EObjID number@EObj表格id
function DiscoverNoteMgr:CanCreateEObjClue(EObjID)
    local NoteModuleOpen = ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDSightseeingLog)
    if not NoteModuleOpen then
        return false
    end

    local PickEobjId2ClueCfgInfo = self.PickEobjId2ClueCfgInfo
    if not PickEobjId2ClueCfgInfo or not next(PickEobjId2ClueCfgInfo) then
        FLOG_ERROR("DiscoverNoteMgr:CanCreateEObjClue ClueSearchMap is Invalid")
        return
    end

    local ClueCfgInfo = PickEobjId2ClueCfgInfo[EObjID]
    if not ClueCfgInfo then
        return
    end

    local NoteID = ClueCfgInfo.NoteID
    if not NoteID then
        return
    end

  

    local ClueList = ClueCfgInfo.ClueTypeList
    if not ClueList or not next(ClueList) then
        return
    end

    for _, ClueType in ipairs(ClueList) do
        if not self:IsNoteClueUnlockByClueType(NoteID, ClueType) then
            return true
        end
    end
end

--- World加载是否加载情感动作提示NPC
---@param EObjID number@EObj表格id
function DiscoverNoteMgr:CanCreateNpc(NPCListID)
    local NoteModuleOpen = ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDSightseeingLog)
    if not NoteModuleOpen then
        return false
    end

    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        return false
    end

    local HintMapNpcListID2NoteInfo = self.HintMapNpcListID2NoteInfo
    if not HintMapNpcListID2NoteInfo then
        return false
    end
    local MapNotes = HintMapNpcListID2NoteInfo[NPCListID]
    if not MapNotes then
        return false
    end

    local NoteInfo = MapNotes[CurMapID]
    if not NoteInfo then
        return false
    end

    local NoteID = NoteInfo.NoteItemID
    if not NoteID then
        return false
    end

    if self:IsNotePointPerfectActived(NoteID) then
        return false
    end

    local CondCfg = NoteInfo.CondCfg
    if not CondCfg then
        return false
    end

    local bInPerfectTime = self:IsNotePointUnderPerfectCond(CondCfg)
    if bInPerfectTime then
        local NpcLevelData = MapEditDataMgr:GetNpcByListID(NPCListID)
        if not NpcLevelData then
            return false
        end
    end

    return bInPerfectTime
end


--- World加载是否加载获取线索NPC
---@param EObjID number@EObj表格id
function DiscoverNoteMgr:CanCreateHintNpc(NPCListID)
    local NoteModuleOpen = ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDSightseeingLog)
    if not NoteModuleOpen then
        return false
    end

    local CurMapResID = PWorldMgr:GetCurrMapResID()
    if not CurMapResID then
        return false
    end

    local HintSrcNpcListID2NoteHintInfo = self.HintSrcNpcListID2NoteHintInfo
    if not HintSrcNpcListID2NoteHintInfo or not next(HintSrcNpcListID2NoteHintInfo) then
        return false
    end

    local HintSrcInfo = HintSrcNpcListID2NoteHintInfo[NPCListID]
    if not HintSrcInfo then
        return false
    end

    local HintSrcInfoInThisMap = HintSrcInfo[CurMapResID]
    if not HintSrcInfoInThisMap then
        return false
    end

    local NoteID = HintSrcInfoInThisMap.NoteID
    if not NoteID then
        return false
    end

    local ClueType = HintSrcInfoInThisMap.ClueType
    if not ClueType then
        return false
    end
    return not self:IsNoteClueUnlockByClueType(NoteID, ClueType)
end

--- 交互成功，隐藏World中的EObj实体(二期区分探索点)
function DiscoverNoteMgr:OnNotifyEobjLeaveVision(AccomplishID)
    local NoteCfg = DiscoverNoteCfg:FindCfgByKey(AccomplishID)
    if not NoteCfg then
        FLOG_ERROR("DiscoverNoteMgr:OnNotifyEobjLeaveVision: The Note Table Do Not Have The Data")
        return
    end

    local bPerfectPointActive = self.bPerfectPointActive

    local ResID = bPerfectPointActive and NoteCfg.PerfectEobjID or NoteCfg.EobjID
    if not ResID then
        return
    end

    local EObjData = MapEditDataMgr:GetEObjByResID(ResID)
    if not EObjData then
        return
    end
    local MapEditorID = EObjData.ID
    if not MapEditorID then
        FLOG_ERROR("DiscoverNoteMgr:OnNotifyEobjLeaveVision: MapEditorID is invalid")
        return
    end
    ClientVisionMgr:ClientActorLeaveVision(MapEditorID, EActorType.EObj)
end

--- 探索笔记完成成功回复
function DiscoverNoteMgr:OnNetMsgExploreNoteAccomplishRsp(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("DiscoverNoteMgr:OnNetMsgExploreNoteAccomplishRsp: MsgBody is nil")
        return
    end
    local AccomplishRsp = MsgBody.Notify
    if nil == AccomplishRsp then
        return
    end

    local NoteInfo = AccomplishRsp.Note
    if not NoteInfo then
        return
    end
    local AccomplishID = NoteInfo.ID
    if not AccomplishID then
        return
    end
    local ClientPerfectActive = self:IsNotePointPerfectActived(AccomplishID)
    if ClientPerfectActive then
        FLOG_ERROR("DiscoverNoteMgr:OnNetMsgExploreNoteAccomplishRsp the point [%d] have perfectactive", AccomplishID)
        return
    end

    local NoteCfg = DiscoverNoteCfg:FindCfgByKey(AccomplishID)
    if not NoteCfg then
        return
    end

    local RltChange = self:UpdateNoteDetailInfo(NoteInfo) -- 更新具体信息(二期)
    local PerfectActiveStateChange = RltChange.PerfectActiveStateChange
    -- 线索解锁状态变化客户端逻辑
    local WeatherClueGot = RltChange.WeatherCondChange
    if WeatherClueGot then
        self:NotifyRemoveNoteClueEobj(AccomplishID, NoteClueType.Weather)
        self:NotifyRemoveNoteClueNpc(AccomplishID, NoteClueType.Weather)
    end
    local TimeClueGot = RltChange.TimeCondChange
    if TimeClueGot then
        self:NotifyRemoveNoteClueEobj(AccomplishID, NoteClueType.Time)
        self:NotifyRemoveNoteClueNpc(AccomplishID, NoteClueType.Time)
    end
    local EmotionClueGot = RltChange.EmotionCondChange
    if EmotionClueGot then
        self:NotifyRemoveNoteClueEobj(AccomplishID, NoteClueType.Emotion)
        self:NotifyRemoveNoteClueNpc(AccomplishID, NoteClueType.Emotion)
    end
    self:UpdateClue2NoteRecordList(AccomplishID, WeatherClueGot, TimeClueGot, EmotionClueGot)
    local bGetClue = WeatherClueGot or TimeClueGot or EmotionClueGot
    if bGetClue and not PerfectActiveStateChange then
        -- 二期内容 获取线索引导
        local function ShowDiscoverNoteClueTutorial(_)
            local EventParams = _G.EventMgr:GetEventParams()
            EventParams.Type = TutorialDefine.TutorialConditionType.GetClue--新手引导触发类型
            _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
        end
        local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowDiscoverNoteClueTutorial, Params = {}}
        _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
       
        -- 左侧栏位逻辑 有获取新线索
        local ClueGotNum = 0
        for Index = 1, SingleNoteTotalClueNum do
            if (Index == 1 and self:IsNoteClueUnlockByClueType(AccomplishID, NoteClueType.Weather))
            or (Index == 2 and self:IsNoteClueUnlockByClueType(AccomplishID, NoteClueType.Time))
            or (Index == 3 and self:IsNoteClueUnlockByClueType(AccomplishID, NoteClueType.Emotion)) then
                ClueGotNum = ClueGotNum + 1
            end
        end
        if ClueGotNum >= SingleNoteTotalClueNum then
            --- 解锁满3条线索添加红点提示 2025.4.23暂不处理解锁线索满红点，P5再处理红点不传到顶的问题
            --self:AddNewUnlockNoteItemRedDot(AccomplishID)
        end

        local function JumpToDiscoverPanel()
            self:OpenDiscoverNoteMainPanel(AccomplishID)
        end
        -- 目前没有三位数编号的探索点，如果需要需确认规则
        local ItemIndex = self.NoteItemID2ItemIndex[AccomplishID] or 0
        local IndexText = ""
        if math.floor(ItemIndex / 10) == 0 then
            IndexText = string.format("0%s", tostring(ItemIndex))
        else
            IndexText = tostring(ItemIndex)
        end
        local MapID = NoteCfg.MapID
        local RegionID = MapUtil.GetMapRegionID(MapID)
        local RegionName = MapUtil.GetRegionName(RegionID) or ""
        local UnlockClueName = string.format(LSTR(330018), RegionName, IndexText) -- 目前没有一个交互途径可以解锁多个线索的情况，后续如果有需求，需要扩展
        LeftSidebarMgr:AppendPerform(LeftSidebarType.DiscoverNote, {
            Content = string.format(LSTR(330001), UnlockClueName or "", ClueGotNum, SingleNoteTotalClueNum),
            ClickCallback = JumpToDiscoverPanel,
        })
    end

    -- 完美解锁对应线索EObj以及情感动作提示NPC移除
    if PerfectActiveStateChange then
        self:NotifyRemoveNoteClueEobj(AccomplishID, NoteClueType.Weather)
        self:NotifyRemoveNoteClueEobj(AccomplishID, NoteClueType.Time)
        self:NotifyRemoveNoteClueEobj(AccomplishID, NoteClueType.Emotion)
        self:NotifyRemoveNoteClueNpc(AccomplishID, NoteClueType.Weather)
        self:NotifyRemoveNoteClueNpc(AccomplishID, NoteClueType.Time)
        self:NotifyRemoveNoteClueNpc(AccomplishID, NoteClueType.Emotion)
        EventMgr:SendEvent(EventID.NoteSinglePerfectActive)
    end

    -- 探索点解锁状态更新
    local bNotePointActualStateChange = RltChange.ActiveStateChange or PerfectActiveStateChange
    if bNotePointActualStateChange then
        self:AddNewUnlockNoteItemRedDot(AccomplishID)
    end
    local bEobjNeedHide = bNotePointActualStateChange or (RltChange.PerfectActiveFailChanged and self:IsNotePointUnderPerfectActiveFail(AccomplishID)) -- 探索失败也需要进行客户端结果表现
    if bEobjNeedHide then
        self:OnNotifyEobjLeaveVision(AccomplishID)
        self:NotifyRemoveNoteNpc(AccomplishID)
        EffectUtil.PlayVfxByCommonID(NoteCompleteVfxEffectCommonID, _G.UE.EVFXPlaySourceType.PlaySourceType_AetherCurrents,
        true, _G.UE.EVFXAttachPointType.AttachPointType_Body)
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        if MajorEntityID then
            local PointActiveAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_Zingle_Unlock.Play_Zingle_Unlock'"
            AudioUtil.LoadAndPlaySoundEvent(MajorEntityID, PointActiveAudioPath, true)
        end
        self:NotePointActiveRltShow(AccomplishID)
        self.bIsInteracting = false
        self.bEmotionEndWaitForInteract = false
        _G.InteractiveMgr:SetShowMainPanelEnabled(true)
        _G.InteractiveMgr:ShowInteractiveEntrance()
    end
end

--- 探索笔记完成演出
function DiscoverNoteMgr:NotePointActiveRltShow(AccomplishID)
    if not AccomplishID then
        return
    end

    local SevInfo = self:MakeTheFinishPopUpPanelData(AccomplishID)
    DiscoverNoteVM:UpdateCompletePanelData(SevInfo)
    UIViewMgr:ShowView(UIViewID.SightSeeingLogFinishPopupView)
end

--- 更新需要播放线索解锁动画的列表
function DiscoverNoteMgr:UpdateClue2NoteRecordList(NoteID, WeatherClueGot, TimeClueGot, EmotionClueGot)
    local Clue2NoteRecord = self.ClueUnlockAnimRecordList[NoteID] or {}
    if WeatherClueGot then
        Clue2NoteRecord[NoteClueType.Weather] = true
    end

    if TimeClueGot then
        Clue2NoteRecord[NoteClueType.Time] = true
    end

    if EmotionClueGot then
        Clue2NoteRecord[NoteClueType.Emotion] = true
    end

    self.ClueUnlockAnimRecordList[NoteID] = Clue2NoteRecord
end

--- 清除线索解锁动画记录
---@param NoteID number @笔记ID
---@param ClueType NoteClueType @线索类别
function DiscoverNoteMgr:ClearNoteClueUnlockRecord(NoteID, ClueType)
    local ClueUnlockAnimRecordList = self.ClueUnlockAnimRecordList
    if not ClueUnlockAnimRecordList then
        return
    end

    local NoteRecord = ClueUnlockAnimRecordList[NoteID]
    if not NoteRecord then
        return
    end

    local ClueRecord = NoteRecord[ClueType]
    if not ClueRecord then
        return
    end
    NoteRecord[ClueType] = nil
end

--- 获取线索解锁动画是否需要播放
---@param NoteID number @笔记ID
---@param ClueType NoteClueType @线索类别
function DiscoverNoteMgr:IsNoteClueUnlockAnimNeedPlay(NoteID, ClueType)
    local ClueUnlockAnimRecordList = self.ClueUnlockAnimRecordList
    if not ClueUnlockAnimRecordList then
        return
    end

    local NoteRecord = ClueUnlockAnimRecordList[NoteID]
    if not NoteRecord then
        return
    end

    return NoteRecord[ClueType]
end

--- Msg Part End-

--- 切换选择笔记时调用逻辑
function DiscoverNoteMgr:SelectedChangeUpdateSingleNoteInfo(NoteID)
    -- 初始化上锁，避免线索泄露
    DiscoverNoteVM:SetTheClueLockState(NoteClueType.Weather, false)
    DiscoverNoteVM:SetTheClueLockState(NoteClueType.Time, false)
    DiscoverNoteVM:SetTheClueLockState(NoteClueType.Emotion, false)
    DiscoverNoteVM:UpdateHintPanelInfo(NoteID, {
        IsRealWeatherUnLock = self:IsNoteClueUnlockByClueType(NoteID, NoteClueType.Weather),
        IsRealTimeUnLock = self:IsNoteClueUnlockByClueType(NoteID, NoteClueType.Time),
        IsEmotionIDUnLock = self:IsNoteClueUnlockByClueType(NoteID, NoteClueType.Emotion),
        bWeatherUnLockAnimPlay = self:IsNoteClueUnlockAnimNeedPlay(NoteID, NoteClueType.Weather),
        bTimeUnLockAnimPlay = self:IsNoteClueUnlockAnimNeedPlay(NoteID, NoteClueType.Time),
        bEmotionIDUnLockAnimPlay = self:IsNoteClueUnlockAnimNeedPlay(NoteID, NoteClueType.Emotion),
    })
end

--- 探索笔记红点 ---
function DiscoverNoteMgr:InitRegionWaitForUnlock()
    local bRegionWaitForUnlockInit = self.bRegionWaitForUnlockInit
    if not bRegionWaitForUnlockInit then
        return
    end

    self.bRegionWaitForUnlockInit = false
    
    local RegionCfgs = DiscoverNoteAreaCfg:FindAllCfg("1=1")
    if not RegionCfgs or not next(RegionCfgs) then
        return
    end
    
    local RegionWaitForUnlock = self.RegionWaitForUnlock or {}
    for _, RegionCfg in ipairs(RegionCfgs) do
        local RegionId = RegionCfg.ID
        local QuestID = RegionCfg.UnlockTaskID
        if RegionId and QuestID then
            if QuestMgr:GetQuestStatus(QuestID) == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
                RegionWaitForUnlock[RegionId] = true
            end
        end
    end

    self.RegionWaitForUnlock = RegionWaitForUnlock
end

--- 更新新解锁地域状况
function DiscoverNoteMgr:UpdateRegionWaitForUnlock()
    local RegionWaitForUnlock = self.RegionWaitForUnlock
    if not RegionWaitForUnlock or not next(RegionWaitForUnlock) then
        return
    end

    local RegionUnlock = {}
    for RegionID, _ in pairs(RegionWaitForUnlock) do
        if self:GetRegionUnlockQuestStatus(RegionID) == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
            table.insert(RegionUnlock, RegionID)
        end
    end

    for _, RegionID in ipairs(RegionUnlock) do
        self:AddNewUnlockRegionTabRedDot(RegionID)
        RegionWaitForUnlock[RegionID] = nil
    end
end

---加载本地储存探索笔记地域新页签红点数据
function DiscoverNoteMgr:LoadLastAddPointDataFromLocalDeviceInternal(SaveKeyParam, bMapOrArray)
    local StrLoaded = SaveMgr.GetString(SaveKeyParam, "", true)
    if StrLoaded == "" then
        if SaveKeyParam == SaveKey.DiscoverNoteRegionID then
            self.RegionTabNewRedDotList = {}
        elseif SaveKeyParam == SaveKey.DiscoverNoteItemID then
            self.NoteItemRedDotList = {}
        elseif SaveKeyParam == SaveKey.DiscoverClueRecord then
            self.ClueUnlockAnimRecordList = {}
        end
        return
    end

    local LocalStrParams = string.split(StrLoaded, ',')
    if bMapOrArray then
        local bInSubLoop = false
        local MainKey
        for _, Value in ipairs(LocalStrParams) do
            if not bInSubLoop and Value == "Sub" then
                bInSubLoop = true
            elseif bInSubLoop and Value == "Sub" then
                bInSubLoop = false
            else
                local NumKey = tonumber(Value)
                if NumKey then
                    if not bInSubLoop then
                        self.ClueUnlockAnimRecordList[NumKey] = {}
                        MainKey = NumKey
                    else
                        if MainKey then
                            self.ClueUnlockAnimRecordList[NumKey][NumKey] = true
                        end
                    end
                end
            end
        end
    else
        for _, Value in ipairs(LocalStrParams) do
            local ID = tonumber(Value)
            if ID then
                if SaveKeyParam == SaveKey.DiscoverNoteRegionID then
                    self:AddNewUnlockRegionTabRedDot(ID)
                elseif SaveKeyParam == SaveKey.DiscoverNoteItemID then
                    self:AddNewUnlockNoteItemRedDot(ID)
                end
            end
        end
    end
end

--- 将本地设备数据加载到内存中
function DiscoverNoteMgr:LoadLastAddPointDataFromLocalDevice()
    self:LoadLastAddPointDataFromLocalDeviceInternal(SaveKey.DiscoverNoteRegionID)
    self:LoadLastAddPointDataFromLocalDeviceInternal(SaveKey.DiscoverNoteItemID)
end

function DiscoverNoteMgr:SaveLastAddPointDataInLocalDeviceInternal(SaveKeyParam, bMapOrArray)
    local CacheList
    if SaveKeyParam == SaveKey.DiscoverNoteRegionID then
        CacheList = self.RegionTabNewRedDotList
    elseif SaveKeyParam == SaveKey.DiscoverNoteItemID then
        CacheList = self.NoteItemRedDotList
    elseif SaveKeyParam == SaveKey.DiscoverClueRecord then
        CacheList = self.ClueUnlockAnimRecordList
    end
    if CacheList == nil or next(CacheList) == nil then
        SaveMgr.SetString(SaveKeyParam, "", true)
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

    local function MakeMapString(CacheList)
        local StrToSave
        for Key, Value in pairs(CacheList) do
            if not StrToSave then
                StrToSave = tostring(Key)
            else
                StrToSave = string.format("%s,%s", StrToSave, tostring(Key))
            end
            StrToSave = string.format("%s,%s", StrToSave, "Sub")
            for SubKey, _ in pairs(Value) do
                StrToSave = string.format("%s,%s", StrToSave, tostring(SubKey))
            end
            StrToSave = string.format("%s,%s", StrToSave, "Sub")
        end
        return StrToSave
    end

    local StoreStr = bMapOrArray and MakeMapString(CacheList) or MakeAarrayString(CacheList)

    if StoreStr == nil then
        return
    end
    SaveMgr.SetString(SaveKeyParam, StoreStr, true)
end

--- 将当前角色数据缓存入本地设备
function DiscoverNoteMgr:SaveLastAddPointDataInLocalDevice()
    self:SaveLastAddPointDataInLocalDeviceInternal(SaveKey.DiscoverNoteRegionID)
    self:SaveLastAddPointDataInLocalDeviceInternal(SaveKey.DiscoverNoteItemID)
    self:SaveLastAddPointDataInLocalDeviceInternal(SaveKey.DiscoverClueRecord, true)
end

--- 当前地域页签是否显示新解锁红点
---@param RegionID number@地域ID
function DiscoverNoteMgr:IsNewUnlockRegion(RegionID)
    local RegionTabNewRedDotList = self.RegionTabNewRedDotList
    if not RegionTabNewRedDotList then
        return
    end
    return RegionTabNewRedDotList[RegionID] ~= nil
end

--- 添加地域页签是否显示新解锁红点
---@param RegionID number@地域ID
function DiscoverNoteMgr:AddNewUnlockRegionTabRedDot(RegionID)
    local RegionTabNewRedDotList = self.RegionTabNewRedDotList
    if not RegionTabNewRedDotList then
        FLOG_ERROR("DiscoverNoteMgr:AddNewUnlockRegionTabRedDot THE MAP NOT INIT CORRECT")
        return
    end
    local RedDotStore = RegionTabNewRedDotList[RegionID]
    if RedDotStore then
        return
    end
    RegionTabNewRedDotList[RegionID] = true
    RedDotMgr:AddRedDotByName(string.format("%s/%s/%s", DiscoverNoteDefine.RedDotBaseName, tostring(RegionID), "NewUnlock"))
end

--- 清除地域页签是否显示新解锁红点
---@param RegionID number@地域ID
function DiscoverNoteMgr:RemoveNewUnlockRegionTabRedDot(RegionID)
    local DelSuccess = RedDotMgr:DelRedDotByName(string.format("%s/%s/%s", DiscoverNoteDefine.RedDotBaseName, tostring(RegionID), "NewUnlock"))
    if not DelSuccess then
        FLOG_ERROR("DiscoverNoteMgr:RemoveNewUnlockRegionTabRedDot REDDOT IS NOT EXIST")
        return
    end
    local RegionTabNewRedDotList = self.RegionTabNewRedDotList
    if not RegionTabNewRedDotList then
        return
    end
    local RedDotStore = RegionTabNewRedDotList[RegionID]
    if not RedDotStore then
        return
    end
    RegionTabNewRedDotList[RegionID] = nil
    self:SaveLastAddPointDataInLocalDeviceInternal(SaveKey.DiscoverNoteRegionID)
end

--- 添加探索笔记新解锁红点
---@param NoteItemID number@笔记ID
function DiscoverNoteMgr:AddNewUnlockNoteItemRedDot(NoteItemID)
    local NoteItemRedDotList = self.NoteItemRedDotList
    if not NoteItemRedDotList then
        return
    end
    local RedDotStore = NoteItemRedDotList[NoteItemID]
    if RedDotStore then
        return
    end

    local NoteCfg = DiscoverNoteCfg:FindCfgByKey(NoteItemID)
    if not NoteCfg then
        return
    end
    NoteItemRedDotList[NoteItemID] = true
    local MapID = NoteCfg.MapID
    local RegionID = MapUtil.GetMapRegionID(MapID)
    RedDotMgr:AddRedDotByName(string.format("%s/%s/%s", DiscoverNoteDefine.RedDotBaseName, tostring(RegionID), tostring(NoteItemID)))
end

--- 清除探索笔记新解锁红点
---@param NoteItemID number@笔记ID
function DiscoverNoteMgr:RemoveNewUnlockNoteItemRedDot(NoteItemID)
    local NoteCfg = DiscoverNoteCfg:FindCfgByKey(NoteItemID)
    if not NoteCfg then
        return
    end

    local MapID = NoteCfg.MapID
    local RegionID = MapUtil.GetMapRegionID(MapID)

    local DelSuccess = RedDotMgr:DelRedDotByName(string.format("%s/%s/%s", DiscoverNoteDefine.RedDotBaseName, tostring(RegionID), tostring(NoteItemID)))
    if not DelSuccess then
        return
    end
    local NoteItemRedDotList = self.NoteItemRedDotList
    if not NoteItemRedDotList then
        return
    end
    local RedDotStore = NoteItemRedDotList[NoteItemID]
    if not RedDotStore then
        return
    end
    NoteItemRedDotList[NoteItemID] = nil
    self:SaveLastAddPointDataInLocalDeviceInternal(SaveKey.DiscoverNoteItemID)
end

--- 清除所有新区域解锁红点（关闭界面使用）
function DiscoverNoteMgr:ClearRegionTabUnlockRedDot()
    local RegionTabNewRedDotList = self.RegionTabNewRedDotList
    if not RegionTabNewRedDotList or not next(RegionTabNewRedDotList) then
        return
    end

    local ListToRemove = table.clone(RegionTabNewRedDotList)
    for RegionID, _ in pairs(ListToRemove) do
        self:RemoveNewUnlockRegionTabRedDot(RegionID)
    end
end

--- 清除所有新笔记解锁红点（关闭界面使用）
function DiscoverNoteMgr:ClearNoteItemUnlockRedDot()
    local NoteItemRedDotList = self.NoteItemRedDotList
    if not NoteItemRedDotList or not next(NoteItemRedDotList) then
        return
    end

    local ListToRemove = table.clone(NoteItemRedDotList)
    for NoteID, _ in pairs(ListToRemove) do
        self:RemoveNewUnlockNoteItemRedDot(NoteID)
    end
end

--- 探索笔记红点 end ---

--- 初始化记录进度为0的地图id
function DiscoverNoteMgr:InitMapIdZeroPercentage()
    local MapID2PointNum = self.MapID2PointNum
    if not MapID2PointNum then
        return
    end
    for MapID, _ in pairs(MapID2PointNum) do
        self.MapIdZeroPercentage[MapID] = true
    end
end

---加载探索笔记数据配置
function DiscoverNoteMgr:LoadDiscoverNoteTableCfgIDs()
    local DiscoverNoteCfg = DiscoverNoteCfg:FindAllCfg("1=1")
    if nil == DiscoverNoteCfg then
        FLOG_ERROR("InitDiscoverNoteTableCfg: DiscoverNoteCfg is nil")
        return
    end

    local EobjID2NoteItemInfo = self.EobjID2NoteItemInfo or {}
    local PerfectEobjID2NoteItemInfo = self.PerfectEobjID2NoteItemInfo or {}
    local HintMapNpcListID2NoteInfo = self.HintMapNpcListID2NoteInfo or {}
    local MapID2PointNum = self.MapID2PointNum or {}
    for _, NoteItem in ipairs(DiscoverNoteCfg) do
        local NoteItemID = NoteItem.ID
        if NoteItemID then
            local EobjID = NoteItem.EobjID
            local RegionID = NoteItem.AreaID
            local PerfectEobjID = NoteItem.PerfectEobjID
            local RegionCfg = DiscoverNoteAreaCfg:FindCfgByKey(RegionID)
            if EobjID and RegionCfg then
                EobjID2NoteItemInfo[EobjID] = {
                    NoteItemID = NoteItemID,
                    QuestID = RegionCfg.UnlockTaskID,
                    PerfectEObjID = PerfectEobjID,
                }
            end

            local CondCfg = DiscoverCondCfg:FindCfgByKey(NoteItemID)
            if PerfectEobjID and RegionCfg then
                PerfectEobjID2NoteItemInfo[PerfectEobjID] = {
                    NoteItemID = NoteItemID,
                    QuestID = RegionCfg.UnlockTaskID,
                    CondCfg = CondCfg,
                }
            end

            if CondCfg then
                local NPCListID = CondCfg.NPCListID
                if NPCListID and NPCListID > 0 then
                    local MapID = NoteItem.MapID
                    -- MapID + ListID对应唯一的笔记ID
                    if MapID and MapID > 0 then
                        local NpcListID2MapNotes = HintMapNpcListID2NoteInfo[NPCListID] or {}
                        NpcListID2MapNotes[MapID] = {
                            NoteItemID = NoteItemID,
                            CondCfg = CondCfg,
                        }
                        HintMapNpcListID2NoteInfo[NPCListID] = NpcListID2MapNotes
                    end
                end
            end
            self.PointTotalNum = self.PointTotalNum + 1

            local MapID = NoteItem.MapID
            if MapID then
                local MapPointNum = MapID2PointNum[MapID] or 0
                MapPointNum = MapPointNum + 1
                MapID2PointNum[MapID] = MapPointNum
            end
        end
    end
    self.EobjID2NoteItemInfo = EobjID2NoteItemInfo
    self.PerfectEobjID2NoteItemInfo = PerfectEobjID2NoteItemInfo
    self.HintMapNpcListID2NoteInfo = HintMapNpcListID2NoteInfo
    self.MapID2PointNum = MapID2PointNum
end

---加载探索笔记线索表数据配置
function DiscoverNoteMgr:LoadDiscoverNoteClueTableCfgs()
    local HintCfg = DiscoverNoteHintCfg:FindAllCfg("1=1")
    if not HintCfg then
        FLOG_ERROR("LoadDiscoverNoteClueTableCfgs: DiscoverNoteHintCfg is nil")
        return
    end

    local PickEobjId2ClueCfgInfo = self.PickEobjId2ClueCfgInfo or {}
    local HintSrcNpcListID2NoteHintInfo = self.HintSrcNpcListID2NoteHintInfo or {}
    for _, HintCfgItem in ipairs(HintCfg) do
        local EobjID = HintCfgItem.PickEobjId
        if EobjID and EobjID > 0 then
            local EobjMapValue = PickEobjId2ClueCfgInfo[EobjID] or {}
            local NoteItemID = HintCfgItem.NoteID
            EobjMapValue.NoteID = NoteItemID
            local ClueType = HintCfgItem.ClueType
            local ClueTypeList = EobjMapValue.ClueTypeList or {}
            if not table.contain(ClueTypeList, ClueType) then
                table.insert(ClueTypeList, ClueType)
            end
            EobjMapValue.ClueTypeList = ClueTypeList
            EobjMapValue.EffectType = HintCfgItem.EffectType -- 理论上不会共用，如果有则特效生效范围也应一致
            PickEobjId2ClueCfgInfo[EobjID] = EobjMapValue
        end

        local NpcListID = HintCfgItem.NpcListID
        if NpcListID and NpcListID > 0 then
            local MapID = HintCfgItem.MapID
            if MapID and MapID > 0 then
                local NpcCfgItem = HintSrcNpcListID2NoteHintInfo[NpcListID] or {}
                local MapKeyItem = NpcCfgItem[MapID] or {}
                MapKeyItem.NoteID = HintCfgItem.NoteID
                MapKeyItem.ClueType = HintCfgItem.ClueType
                NpcCfgItem[MapID] = MapKeyItem
                HintSrcNpcListID2NoteHintInfo[NpcListID] = NpcCfgItem
            end
        end
    end
    self.PickEobjId2ClueCfgInfo = PickEobjId2ClueCfgInfo
    self.HintSrcNpcListID2NoteHintInfo = HintSrcNpcListID2NoteHintInfo
end

--- 加载探索完成技能表数据
function DiscoverNoteMgr:LoadDiscoverNoteCompleteSkillCfg()
    local SkillCfg = CompleteSkillCfg:FindAllCfg("1=1")
    if not SkillCfg then
        FLOG_ERROR("LoadDiscoverNoteCompleteSkillCfg: CompleteSkillCfg is nil")
        return
    end

    local MapID2DetectSkillCfg = self.MapID2DetectSkillCfg or {}
    for _, SkillCfgItem in ipairs(SkillCfg) do
        local ID = SkillCfgItem.ID
        if ID and ID > 0 then
            local ActiveMapList = SkillCfgItem.ActiveMapList
            if ActiveMapList and next(ActiveMapList) then
                for _, MapID in ipairs(ActiveMapList) do
                    MapID2DetectSkillCfg[MapID] = ID
                end
            end
        end
    end
    self.MapID2DetectSkillCfg = MapID2DetectSkillCfg
end

--- 初始化探索笔记服务器数据
function DiscoverNoteMgr:InitDiscoverNoteIndexInfos()
    local DiscoverNoteCfg = DiscoverNoteCfg:FindAllCfg("1=1")
    if nil == DiscoverNoteCfg then
        FLOG_ERROR("InitDiscoverNoteIndexInfos: DiscoverNoteCfg is nil")
        return
    end
    local NoteItemID2ItemIndex = self.NoteItemID2ItemIndex or {}
    local TempRegionCountMap = {}
    for _, NoteItem in ipairs(DiscoverNoteCfg) do
        local NoteItemID = NoteItem.ID
        local MapID = NoteItem.MapID
        local RegionID = MapUtil.GetMapRegionID(MapID)
        if NoteItemID and MapID and RegionID then
            local RegionCount = TempRegionCountMap[RegionID] or 0
            local CurCount = RegionCount + 1
            NoteItemID2ItemIndex[NoteItemID] = CurCount
            TempRegionCountMap[RegionID] = CurCount
        end
    end
    self.NoteItemID2ItemIndex = NoteItemID2ItemIndex
end

--- 更新单条笔记的详细信息
---@param Info ProtoCS.SearchNoteInfo@服务器笔记信息结构
---@param bNotify boolean@是否为服务器主动返回
---@return table@笔记各项条件是否改变
function DiscoverNoteMgr:UpdateNoteDetailInfo(Info)
    if not Info then
        return
    end
    return self:UpdateClientNoteInfoFromSevInfo(Info)
end

--- 增加地图点位完成探索次数信息
---@param NoteId number@地图ID
---@param bNormal boolean@是否为普通探索信息
function DiscoverNoteMgr:AddMapPointCompleteNumByNoteID(NoteId, bNormal)
    local PointCfg = DiscoverNoteCfg:FindCfgByKey(NoteId)
    if not PointCfg then
        return
    end
    local MapID = PointCfg.MapID
    if not MapID then
        return
    end
    self:AddMapPointCompleteNum(MapID, bNormal, 1)
end

--- 增加地图点位完成探索次数信息
---@param MapId number@地图ID
---@param bNormal boolean@是否为普通探索信息
---@param Num number@增加数量
function DiscoverNoteMgr:AddMapPointCompleteNum(MapId, bNormal, Num)
    local MapId2PointCompleteInfo = self.MapId2PointCompleteInfo or {}
    local MapCompleteInfo = MapId2PointCompleteInfo[MapId] or {}
    local MapIdExist = MapCompleteInfo.MapId

    if not MapIdExist then
        MapCompleteInfo.MapId = MapId
    end

    local TotalNum
    local MapID2PointNum = self.MapID2PointNum
    if MapID2PointNum then
        TotalNum = MapID2PointNum[MapId]
    end

    if not TotalNum then
        return
    end

    if bNormal then
        local NormalCompleteNum = MapCompleteInfo.NormalCompleteNum or 0
        NormalCompleteNum = NormalCompleteNum + Num
        MapCompleteInfo.NormalCompleteNum = NormalCompleteNum
        MapCompleteInfo.NormalProcess = NormalCompleteNum / TotalNum
    else
        local PerfectCompleteNum = MapCompleteInfo.PerfectCompleteNum or 0
        PerfectCompleteNum = PerfectCompleteNum + Num
        MapCompleteInfo.PerfectCompleteNum = PerfectCompleteNum
        MapCompleteInfo.PerfectProcess = PerfectCompleteNum / TotalNum
    end
    if self.MapIdZeroPercentage[MapId] then
        self.MapIdZeroPercentage[MapId] = nil
    end
    MapId2PointCompleteInfo[MapId] = MapCompleteInfo
    self.MapId2PointCompleteInfo = MapId2PointCompleteInfo
end

function DiscoverNoteMgr:UpdateClueBoxState(BoxIdList)
    if not BoxIdList or not next(BoxIdList) then
        return
    end
    for _, BoxID in ipairs(BoxIdList) do
        self:SetClueSrcStateDisableByBoxID(BoxID)
    end
end

function DiscoverNoteMgr:SetClueSrcStateDisableByBoxID(BoxID)
    if not BoxID or type(BoxID) ~= "number" or BoxID == 0 then
        return
    end
    local ClueCfg = DiscoverNoteHintCfg:FindCfg(string.format("TreasureBoxID = %d", BoxID))
    if not ClueCfg then
        return
    end

    local NoteID = ClueCfg.NoteID or 0
    local ClueType = ClueCfg.ClueType or 0

    DiscoverNoteVM:SetTheNoteClueSrcStateDisable(NoteID, ClueType, NoteClueSrcType.TreasureBox)
end

--- 该区域解锁任务完成状态（任务系统判断）
function DiscoverNoteMgr:GetRegionUnlockQuestStatus(RegionID)
    local RegionCfg = DiscoverNoteAreaCfg:FindCfgByKey(RegionID)
    if not RegionCfg then
        return
    end
    local QuestID = RegionCfg.UnlockTaskID
    if not QuestID then
        return
    end
    return QuestMgr:GetQuestStatus(QuestID)
end

--- 该区域是否有任何地图主角踏足过（任务系统判断）
function DiscoverNoteMgr:IsRegionActive(RegionID)
    local QuestState = self:GetRegionUnlockQuestStatus(RegionID)
    return QuestState == QUEST_STATUS.CS_QUEST_STATUS_FINISHED
end

--- 创建左侧地域页签（优先选中角色所在地图，默认选中第一个，用于UIView）
function DiscoverNoteMgr:MakeTheRegionData()
    local RegionCfgs = DiscoverNoteAreaCfg:FindAllCfg("1=1")
	if not RegionCfgs then
		return
	end

	local ListData = {}
	local SelectedIndex = 1
    local SelectRegionID = 0
    -- 默认选中地域规则(所处地区不可能是未来过的)
    local MapMajorLocated = PWorldMgr:GetCurrMapResID() or 0
    SelectRegionID = MapUtil.GetMapRegionID(MapMajorLocated) or 0

	if RegionCfgs then
		table.sort(RegionCfgs, function(A, B) return (A.ID or 0) < (B.ID or 0) end)
		for Index, RegionCfg in ipairs(RegionCfgs) do
            local RegionID = RegionCfg.ID or 0
			if RegionID == SelectRegionID then
				SelectedIndex = Index
			end
			local RegionIconCfg = MapRegionIconCfg:FindCfgByKey(RegionID)
			if RegionIconCfg then
				local Data = {}
				Data.ID = RegionID
				Data.Name = RegionIconCfg.Name
				Data.IconPath = RegionIconCfg.Icon
                Data.IsLock = not self:IsRegionActive(RegionID)
                local UnlockRegionRedDotName = string.format("%s/%s", DiscoverNoteDefine.RedDotBaseName, tostring(RegionID))
                Data.RedDotData = {
                    RedDotName = UnlockRegionRedDotName,
                    IsStrongReminder = false
                }

				table.insert(ListData, Data)
			end
		end
	end

	return ListData, SelectedIndex
end

--- 隐藏对应的EObj线索
function DiscoverNoteMgr:NotifyRemoveNoteClueEobj(NoteID, ClueType)
    if not NoteID or not ClueType then
        return
    end

    local NoteClueCfg = DiscoverNoteHintCfg:FindCfg(string.format("NoteID = %d AND ClueType = %d", NoteID, ClueType))
    if not NoteClueCfg then
        return
    end

    local PickEobjId = NoteClueCfg.PickEobjId
    if not PickEobjId or PickEobjId == 0 then
        return
    end

    local EObjMapEditorData = MapEditDataMgr:GetEObjByResID(PickEobjId)
    if not EObjMapEditorData then
        return
    end

    local MapEditorID = EObjMapEditorData.ID
    ClientVisionMgr:ClientActorLeaveVision(MapEditorID, EActorType.EObj)
end

--- 隐藏对应的Npc线索
function DiscoverNoteMgr:NotifyRemoveNoteClueNpc(NoteID, ClueType)
    if not NoteID or not ClueType then
        return
    end

    local NoteClueCfg = DiscoverNoteHintCfg:FindCfg(string.format("NoteID = %d AND ClueType = %d", NoteID, ClueType))
    if not NoteClueCfg then
        return
    end

    local NpcListID = NoteClueCfg.NpcListID
    if not NpcListID or NpcListID == 0 then
        return
    end

    ClientVisionMgr:ClientActorLeaveVision(NpcListID, EActorType.Npc)
end

function DiscoverNoteMgr:NotifyRemoveNoteNpc(NoteID)
    if not NoteID then
        return
    end

    local NoteCondCfg = DiscoverCondCfg:FindCfgByKey(NoteID)
    if not NoteCondCfg then
        return
    end

    local NPCListID = NoteCondCfg.NPCListID
    if not NPCListID or NPCListID == 0 then
        return
    end

    ClientVisionMgr:ClientActorLeaveVision(NPCListID, EActorType.Npc)
end

--- 三期需求 ---

--- 地图探测背包道具获取后立即更新当前地图探测内容
function DiscoverNoteMgr:SendLoadDetectRangeEventToUpdate()
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        return
    end
    EventMgr:SendEvent(EventID.LoadWildBoxRangeCheckData, CurMapID)
    EventMgr:SendEvent(EventID.LoadMysterMerchantRangeCheckData)

    --- 巡回乐团处理
    local TourMapData = TouringBandMgr.BandMapData
    if TourMapData and next(TourMapData) then
        for __, Item in ipairs(TourMapData) do
            local Band = Item.Band
            if Band.BirthTime > 0 then
                EventMgr:SendEvent(EventID.AddTouringBandRangeCheckData, Band.TimelineID)
            end
        end
    end
end

--- 判定当前地图探测技能是否激活
function DiscoverNoteMgr:IsTheCurrentMapDetectActive()
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        return
    end

    return self:IsTheMapDetectActive(CurMapID)
end

--- 判定特定地图探测技能是否激活
function DiscoverNoteMgr:IsTheMapDetectActive(MapID)
    local ActiveID = self:GetTheMapActiveID(MapID)
    if not ActiveID then
        return
    end

    local ItemID = CompleteSkillCfg:FindValue(ActiveID, "EvidenceItemID")
    if not ItemID then
        return
    end

    return BagMgr:GetItemGIDByResID(ItemID) ~= nil
end

--- 获取特定地图的激活技能ID
function DiscoverNoteMgr:GetTheMapActiveID(MapID)
    local MapID2DetectSkillCfg = self.MapID2DetectSkillCfg
    if not MapID2DetectSkillCfg or not next(MapID2DetectSkillCfg) then
        return
    end
    return MapID2DetectSkillCfg[MapID]
end

--- 获取特定地图激活ID对应的探测范围
function DiscoverNoteMgr:GetTheMapDetectRange(MapID)
    local ActiveID = self:GetTheMapActiveID(MapID)
    if not ActiveID then
        return
    end

    return CompleteSkillCfg:FindValue(ActiveID, "ActiveRange")
end

--- 添加检测到的标记数据
function DiscoverNoteMgr:AddTheDetectTargetInRange(RangeData)
    local AuthenID = RangeData:GetAuthenID()
    if not AuthenID then
        return
    end
    local ActorType = RangeData:OnGetGamePlayType()
    if not ActorType then
        return
    end

    local Pos = RangeData:GetLocation()

    local DetectTargetInRange = self.DetectTargetInRange or {}
    table.insert(DetectTargetInRange, {AuthenID = AuthenID, ActorType = ActorType, Position = Pos})
    self.DetectTargetInRange = DetectTargetInRange

    local CurMapID = PWorldMgr:GetCurrMapResID()
    local ActiveID = self:GetTheMapActiveID(CurMapID)
    EventMgr:SendEvent(EventID.EnterTheDetectedTargetRange, {MarkerID = AuthenID, ActorType = ActorType, ActiveID = ActiveID, Position = Pos})
end

--- 移除检测到的标记数据
function DiscoverNoteMgr:RemoveTheDetectTargetInRange(RangeData)
    local AuthenID = RangeData:GetAuthenID()
    if not AuthenID then
        return
    end
    local ActorType = RangeData:OnGetGamePlayType()
    if not ActorType then
        return
    end
    local DetectTargetInRange = self.DetectTargetInRange
    if not DetectTargetInRange or not next(DetectTargetInRange) then
        return
    end
    table.array_remove_item_pred(DetectTargetInRange, function(Element)
        return Element.AuthenID == AuthenID and Element.ActorType == ActorType
    end)

    local CurMapID = PWorldMgr:GetCurrMapResID()
    local ActiveID = self:GetTheMapActiveID(CurMapID)
    EventMgr:SendEvent(EventID.ExitTheDetectedTargetRange, {MarkerID = AuthenID, ActorType = ActorType, ActiveID = ActiveID})
end

--- 根据所属地图获取当前范围内的检测目标数据
function DiscoverNoteMgr:GetTheDetectTargetInRange(MapID)
    -- 非当前地图不生效
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if CurMapID ~= MapID then
        return
    end

    if not self:IsTheMapDetectActive(MapID) then
        return
    end

    local DetectTargetInRange = self.DetectTargetInRange
    if not DetectTargetInRange or not next(DetectTargetInRange) then
        return
    end

    local Rlt = {}
    local ActiveID = self:GetTheMapActiveID(MapID)
    Rlt.ActiveID = ActiveID
    local TargetArray = {}
    for _, MarkerParamData in ipairs(DetectTargetInRange) do
        table.insert(TargetArray, {MarkerID = MarkerParamData.AuthenID, ActorType = MarkerParamData.ActorType, Position = MarkerParamData.Position})
    end
    Rlt.TargetArray = TargetArray
    return Rlt
end

function DiscoverNoteMgr:LoadWildBoxRangeCheckData(MapID)
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        return
    end

    if CurMapID ~= MapID then
        -- 目前地图切换页签也会申请一次数据，此处需过滤
        return
    end

    if not self:IsTheMapDetectActive(CurMapID) then
        return
    end

    local WildBoxList = WildBoxMoundMgr:GetCurrentMapBoxList(CurMapID)
    if not WildBoxList or not next(WildBoxList) then
        return
    end

    for _, WildBox in ipairs(WildBoxList) do
        local EObjID = WildBox.EObjID
        local IsBoxOpened = WildBoxMoundMgr:IsBoxOpened(CurMapID, EObjID)
        if not IsBoxOpened then
            local EditorData = MapEditDataMgr:GetEObjByListID(EObjID)
            if EditorData then
                local ResID = EditorData.ResID
                if ResID then
                    RangeCheckTriggerMgr:AddRangeCheckActorNotCreated(TriggerGamePlayType.WildBox, ResID, EObjID)
                    FLOG_INFO("MarkerDetectTarget DiscoverNoteMgr:LoadWildBoxRangeCheckData")
                end
            end
        end
    end
end

function DiscoverNoteMgr:OnRemoveWildBoxRangeCheckDataByBoxOpened(_, ListID)
    if not ListID then
        return
    end
    
    if not self:IsTheCurrentMapDetectActive() then
        return
    end

    local EObjEditorData = MapEditDataMgr:GetEObjByListID(ListID)
    if not EObjEditorData then
        return
    end

    local ResID = EObjEditorData.ResID
    RangeCheckTriggerMgr:RemoveRangeCheckActorNotCreated(ResID, ListID)
end


function DiscoverNoteMgr:OnAddTouringBandRangeCheckData(TimeLineID)
    if not TimeLineID or not self:IsTheCurrentMapDetectActive() then
        return
    end
    RangeCheckTriggerMgr:AddRangeCheckCustomMap(TriggerGamePlayType.Band, TimeLineID)
end

function DiscoverNoteMgr:OnRemoveTouringBandRangeCheckData(TimeLineID)
    if not TimeLineID or not self:IsTheCurrentMapDetectActive() then
        return
    end
    RangeCheckTriggerMgr:RemoveRangeCheckCustomMap(TriggerGamePlayType.Band, TimeLineID)
end

function DiscoverNoteMgr:LoadMysterMerchantRangeCheckData()
    if not self:IsTheCurrentMapDetectActive() then
        return
    end
    local CurrActiveMerchantList = MysterMerchantMgr.CurrActiveMerchantList
    if not CurrActiveMerchantList or not next(CurrActiveMerchantList) then
        return
    end
    for _, ActiveMerchant in pairs(CurrActiveMerchantList) do
        local TaskID = ActiveMerchant.TaskID
        local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
        if TaskInfo then
            local ListID = TaskInfo.NPCListID
            local NpcData = MapEditDataMgr:GetNpcByListID(ListID)
            if ListID and NpcData then
                RangeCheckTriggerMgr:AddRangeCheckActorNotCreated(TriggerGamePlayType.MysterMerchant, NpcData.NpcID, ListID)
            end
        end
    end
end

function DiscoverNoteMgr:OnRemoveMysterMerchantRangeCheckData(ListID)
    if not ListID then
        return
    end
    if not self:IsTheCurrentMapDetectActive() then
        return
    end
    
    local NpcEditorData = MapEditDataMgr:GetNpcByListID(ListID)
    if not NpcEditorData then
        return
    end

    local ResID = NpcEditorData.NpcID
    RangeCheckTriggerMgr:RemoveRangeCheckActorNotCreated(ResID, ListID)
end

function DiscoverNoteMgr:ShowDetectChatMsgTips()
    local CurCd = self.ChatMsgTipsCurCd
    if CurCd > 0 then
        return
    end
    MsgTipsUtil.AddSysChatMsg(LSTR(330027))
    self.ChatMsgTipsCurCd = ChatMsgMaxCd
end

------ 外部调用接口 ------

--- 切换页签时调用，与界面强相关
function DiscoverNoteMgr:UpdateNotePerfectCondStateInList()
    local NoteNeedUpdatePerfectCond = self.NoteNeedUpdatePerfectCond
    if not NoteNeedUpdatePerfectCond or not next(NoteNeedUpdatePerfectCond) then
        return
    end

    local NoteNeedChangeInViewModel = {}
    for _, NoteInfo in pairs(NoteNeedUpdatePerfectCond) do
        local NoteID = NoteInfo.NoteID
        local OldShowState = NoteInfo.bShowPerfectCondEffect
        local bPerfectComplete = self:IsNotePointPerfectActived(NoteID)
        local bAllClueUnlock = self:IsNoteClueUnlockByClueType(NoteID, NoteClueType.Weather)
        and self:IsNoteClueUnlockByClueType(NoteID, NoteClueType.Time) and self:IsNoteClueUnlockByClueType(NoteID, NoteClueType.Emotion)
        local CurPerfectCond = bAllClueUnlock and self:IsNotePointUnderPerfectCondByNoteID(NoteID) and not bPerfectComplete
        if OldShowState ~= CurPerfectCond then
            local SevInfo = {
                NoteItemID = NoteID,
                bShowPerfectCondEffect = CurPerfectCond,
            }
            table.insert(NoteNeedChangeInViewModel, SevInfo)
        end
    end

    DiscoverNoteVM:UpdateNotePerfectCondPicked(NoteNeedChangeInViewModel)
end

function DiscoverNoteMgr:StartUpdatePerfectCondTimer()
    local NoteNeedUpdatePerfectCond = self.NoteNeedUpdatePerfectCond
    if not NoteNeedUpdatePerfectCond or not next(NoteNeedUpdatePerfectCond) then
        return
    end--]]
    local PerfectCondFirstTimeHandle = self.PerfectCondFirstTimeHandle
    if PerfectCondFirstTimeHandle then
        self:UnRegisterTimer(PerfectCondFirstTimeHandle)
        self.PerfectCondFirstTimeHandle = nil
    end

    local PerfectCondLoopTimeHandle = self.PerfectCondLoopTimeHandle
    if PerfectCondLoopTimeHandle then
        self:UnRegisterTimer(PerfectCondLoopTimeHandle)
        self.PerfectCondLoopTimeHandle = nil
    end

    local TimeSecDelay = TimeUtil.GetToNextAozyHourRealSec()
    --FLOG_INFO("note perfect state update=== firstTimerStart delayTime %d", TimeSecDelay)
    self.PerfectCondFirstTimeHandle = self:RegisterTimer(function()
        self:UpdateNotePerfectCondStateInList()
        --FLOG_INFO("note perfect state update=== firstTimerStart delayTime")
        self.PerfectCondLoopTimeHandle = self:RegisterTimer(function()
            self:UpdateNotePerfectCondStateInList()
            --FLOG_INFO("note perfect state update=== loopTimerStart")
        end, 0, AozyTimeDefine.AozyHour2RealSec, 0)
    end, TimeSecDelay)
end

function DiscoverNoteMgr:StopUpdatePerfectCondTimer()
    local PerfectCondFirstTimeHandle = self.PerfectCondFirstTimeHandle
    if PerfectCondFirstTimeHandle then
        self:UnRegisterTimer(PerfectCondFirstTimeHandle)
        self.PerfectCondFirstTimeHandle = nil
    end

    local PerfectCondLoopTimeHandle = self.PerfectCondLoopTimeHandle
    if PerfectCondLoopTimeHandle then
        self:UnRegisterTimer(PerfectCondLoopTimeHandle)
        self.PerfectCondLoopTimeHandle = nil
    end
    self.NoteNeedUpdatePerfectCond = nil
end

--- 启动计时器定时通知地图更新点位信息
function DiscoverNoteMgr:StartUpdateMapPerfectCondTimer()
    local PerfectCondFirstTimeHandle = self.MapUsePerfectCondFirstTimeHandle
    if PerfectCondFirstTimeHandle then
        self:UnRegisterTimer(PerfectCondFirstTimeHandle)
        self.MapUsePerfectCondFirstTimeHandle = nil
    end

    local PerfectCondLoopTimeHandle = self.MapUsePerfectCondLoopTimeHandle
    if PerfectCondLoopTimeHandle then
        self:UnRegisterTimer(PerfectCondLoopTimeHandle)
        self.MapUsePerfectCondLoopTimeHandle = nil
    end

    self.MapUsePerfectCondFirstTimeHandle = self:RegisterTimer(function()
        EventMgr:SendEvent(EventID.TimeToUpdateMapPointPerfectCond)
        self.MapUsePerfectCondLoopTimeHandle = self:RegisterTimer(function()
            EventMgr:SendEvent(EventID.TimeToUpdateMapPointPerfectCond)
        end, 0, AozyTimeDefine.AozyHour2RealSec, 0)
    end, TimeUtil.GetToNextAozyHourRealSec())
end

--- 停止计时器定时通知地图更新点位信息
function DiscoverNoteMgr:StopUpdateMapPerfectCondTimer()
    local PerfectCondFirstTimeHandle = self.MapUsePerfectCondFirstTimeHandle
    if PerfectCondFirstTimeHandle then
        self:UnRegisterTimer(PerfectCondFirstTimeHandle)
        self.MapUsePerfectCondFirstTimeHandle = nil
    end

    local PerfectCondLoopTimeHandle = self.MapUsePerfectCondLoopTimeHandle
    if PerfectCondLoopTimeHandle then
        self:UnRegisterTimer(PerfectCondLoopTimeHandle)
        self.MapUsePerfectCondLoopTimeHandle = nil
    end
end

--- 切换地域显示
---@param RegionID number@地域ID
function DiscoverNoteMgr:ChangeTheRegionTab(RegionID)
    if not RegionID or type(RegionID) ~= "number" then
        return
    end

    if self:IsNewUnlockRegion(RegionID) then
        self:RemoveNewUnlockRegionTabRedDot(RegionID)
    end

    local TotalNum, CompletedNum = self:GetRegionNoteCompleteNumInfo(RegionID)

    local SevInfos = self:MakeTheRegionNoteItemSevInfos(RegionID, true)
    if not SevInfos then
        return
    end

    -- 处理完美条件提示特效数据
    self:StartUpdatePerfectCondTimer()

    local RegionInfo = {
        RegionID = RegionID,
        Name = MapUtil.GetRegionName(RegionID),
        TotalNum = TotalNum or 0,
        CompletedNum = CompletedNum or 0,
        RegionSevInfos = SevInfos,
    }

    DiscoverNoteVM:ChangeTheRegion(RegionInfo)
end

--- 切换未完成checkBox状态
---@param SelectedRegion number@当前选中地域ID
---@param bChecked boolean@是否勾选
function DiscoverNoteMgr:ChangeTheCheckBoxCompleteState()
    local RegionID = DiscoverNoteVM.SelectedRegionID
    if not RegionID or type(RegionID) ~= "number" then
        return
    end

    local RegionCfg = MapRegionIconCfg:FindCfgByKey(RegionID)
    if not RegionCfg then
        return
    end

    local RegionSevInfos = self:MakeTheRegionNoteItemSevInfos(RegionID)
    if not RegionSevInfos then
        return
    end
    DiscoverNoteVM:ChangeTheCheckBoxCompleteState(RegionSevInfos)
end

--- 打开探索笔记主界面
function DiscoverNoteMgr:OpenDiscoverNoteMainPanel(EnterNoteID)
    DiscoverNoteVM.bEnterFromGuideMain = EnterNoteID == nil
    DiscoverNoteVM.NoteItemIdPointed = EnterNoteID
    UIViewMgr:ShowView(UIViewID.SightSeeingLogMainView)
end

--- 根据EObjID判定是否为完美风景点
function DiscoverNoteMgr:IsPerfectNotePoint(EObjID)
    local PerfectEobjID2NoteItemInfo = self.PerfectEobjID2NoteItemInfo
    if not PerfectEobjID2NoteItemInfo then
        return
    end

    return PerfectEobjID2NoteItemInfo[EObjID]
end

--- 根据EObjID判定是否为普通风景点
function DiscoverNoteMgr:IsNormalNotePoint(EObjID)
    local EobjID2NoteItemInfo = self.EobjID2NoteItemInfo
    if not EobjID2NoteItemInfo then
        return
    end

    return EobjID2NoteItemInfo[EObjID]
end

--- 情感动作请求逻辑
---@param EmotionID number@情感动作ID
---@param InteractiveID number@交互ID
---@param EntityID number@交互Actor唯一ID
function DiscoverNoteMgr:EmotionReqInternal(EmotionID)
    if false == EmotionMgr:IsNetMsgBody(EmotionID, true) then -- 情感动作移动判定影响探索笔记执行
        self:RegisterTimer(function()
            InteractiveMgr:ShowMainPanel()
        end, 0.2) -- 延时操作保证交互系统打开界面时判定状态不受计时器内方法调用时改变状态的逻辑影响
        return
    end
    EmotionMgr:SendEmotionReq(EmotionID)
    self.bIsInteracting = true
    _G.InteractiveMgr:SetShowMainPanelEnabled(false)
end

--- 交互按钮发送情感动作申请接口(普通解锁)
---@param NoteItemId number@探索笔记ID
---@param CallBack function@情感动作结束后回调
function DiscoverNoteMgr:EmotionInteractReq(NoteItemId, InteractiveID, EntityID)
    local NoteCfg = DiscoverNoteCfg:FindCfgByKey(NoteItemId)
    if not NoteCfg then
        return
    end
    local EmotionID = NoteCfg.EmotionID
    if not EmotionID then
        return
    end
    self.bPerfectPointActive = false
    self.InteractiveID = InteractiveID
    self.EntityID = EntityID
    self.bEmotionEndWaitForInteract = false
    self:EmotionReqInternal(EmotionID)
end

--- 情感动作界面情感动作申请接口(完美解锁)
---@param NoteItemId number@探索笔记ID
---@param CallBack function@情感动作结束后回调
function DiscoverNoteMgr:PerfectEmotionInteractReq(NoteItemId, EmotionID)
    if not NoteItemId or not EmotionID then
        return
    end

    self.bPerfectPointActive = true

    local CondCfg = DiscoverCondCfg:FindCfgByKey(NoteItemId)
    if not CondCfg then
        return
    end

    local ActualInteractiveID
    if EmotionID == CondCfg.PerfectDiscoveryEmotionID then
        ActualInteractiveID = CondCfg.CorrectInteractID
    else
        ActualInteractiveID = CondCfg.WrongInteractID
    end

    if ActualInteractiveID then
        self.InteractiveID = ActualInteractiveID
    else
        return
    end

    self:EmotionReqInternal(EmotionID)
end

--- 情感动作界面打开
---@param NoteItemId number@探索笔记ID
---@param CallBack function@情感动作结束后回调
function DiscoverNoteMgr:OpenPerfectEmotionView(NoteItemId, EntityID)
    self.bEmotionEndWaitForInteract = false
    self.EntityID = EntityID
    local Params = {
        NoteID = NoteItemId,
        EmotionIDList = nil,
    }

    local TempIDList = {}
    local CondCfg = DiscoverCondCfg:FindCfgByKey(NoteItemId)
    if not CondCfg then
        return
    end
    local CorrectEmotionID = CondCfg.PerfectDiscoveryEmotionID
    if CorrectEmotionID then
        table.insert(TempIDList, {
            ID = CorrectEmotionID, bGot = _G.EmotionMgr:IsActivatedID(CorrectEmotionID)
        })
    end

    local WrongEmotionIDs = CondCfg.NormalDiscoveryEmotionID
    if WrongEmotionIDs and next(WrongEmotionIDs) then
        for _, EmotionID in ipairs(WrongEmotionIDs) do
           table.insert(TempIDList, {
            ID = EmotionID, bGot = _G.EmotionMgr:IsActivatedID(EmotionID)
        })
        end
    end

    Params.EmotionIDList = TempIDList
    Params.bEmotionClueUnlock = self:IsNoteClueUnlockByClueType(NoteItemId, NoteClueType.Emotion)

    DiscoverNoteVM:UpdateActChooseViewVM(Params)
    UIViewMgr:ShowView(UIViewID.SightSeeingLogActChooseView)
end

function DiscoverNoteMgr:InteractiveReqAfterEmotionEnd(EmotionID)
    if not EmotionID then
        return
    end
    local InteractiveID = self.InteractiveID
    if not InteractiveID then
        return
    end

    local InteractiveEntityID = self.EntityID
    if not InteractiveEntityID then
        return
    end

    InteractiveMgr:SendInteractiveStartReq(InteractiveID, InteractiveEntityID)
    self.bEmotionEndWaitForInteract = true

    self.InteractiveID = nil
    self.EntityID = nil
end

--- 是否处于探索笔记交互解锁中
function DiscoverNoteMgr:CheckIsInInteract()
    return self.bIsInteracting
end

function DiscoverNoteMgr:IsNeedDoNotShowInteractivePanelWhenUnSelectMajor(EntityID)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if not MajorEntityID then
        return false
    end

    if MajorEntityID ~= EntityID then
        return false
    end

    if not self:CheckIsInInteract() then
        return false
    end

    return true
end

--- 通过笔记id判断探索点是否在完美条件下
---@param NoteID number
function DiscoverNoteMgr:IsNotePointUnderPerfectCondByNoteID(NoteID)
    if not NoteID then
        return
    end

    local CondCfg = DiscoverCondCfg:FindCfgByKey(NoteID)
    if not CondCfg then
        return
    end

    return self:IsNotePointUnderPerfectCond(CondCfg)
end

function DiscoverNoteMgr:TestShowRltView()
    UIViewMgr:ShowView(UIViewID.SightSeeingLogFinishPopupView)
end

--- 获取探索笔记普通探索完成进度
---@return bool,number,number@普通进度是否已满，普通探索完成数量，点位总数量
function DiscoverNoteMgr:GetNormalDiscoverProcess()
    local TotalNum = self.PointTotalNum or 0
    local NormalCompleteNum = self.NormalCompleteNum or 0
    local bNormalCompleteMax = NormalCompleteNum >= TotalNum
    return bNormalCompleteMax, NormalCompleteNum, TotalNum
end

--- 获取探索笔记完美探索完成进度
---@return bool,number,number@完美进度是否已满，完美探索完成数量，点位总数量
function DiscoverNoteMgr:GetPerfectDiscoverProcess()
    local TotalNum = self.PointTotalNum or 0
    local PerfectCompleteNum = self.PerfectCompleteNum or 0
    local bPerfectCompleteMax = PerfectCompleteNum >= TotalNum
    return bPerfectCompleteMax, PerfectCompleteNum, TotalNum
end

--- 野外探索推荐地图
---@return table@mapidList
function DiscoverNoteMgr:RecommandMapListForWildExplore()
    local bPerfectCompleteMax = self:GetPerfectDiscoverProcess()
    if bPerfectCompleteMax then
        return {}
    end

    local MapID2PointNum = self.MapID2PointNum
    if not MapID2PointNum or not next(MapID2PointNum) then
        FLOG_ERROR("DiscoverNoteMgr:RecommandMapListForWildExplore Config MapIDList is invalid")
        return {}
    end

    local RltNeedNum = 4 -- 外部接口需求MapID数量
    local Rlt = {}
    local MapIdZeroPercentage = self.MapIdZeroPercentage
    if MapIdZeroPercentage and next(MapIdZeroPercentage) then
        for MapID, _ in pairs(MapIdZeroPercentage) do
            if RltNeedNum > 0 then
                table.insert(Rlt, MapID)
                RltNeedNum = RltNeedNum - 1
            else
                return Rlt
            end
        end
    end

    local MapId2PointCompleteInfo = self.MapId2PointCompleteInfo
    if not MapId2PointCompleteInfo or not next(MapId2PointCompleteInfo) then
        return Rlt
    end

    local CompleteInfos = table.values(MapId2PointCompleteInfo)
    local bNormalCompleteMax = self:GetNormalDiscoverProcess()
    if bNormalCompleteMax then
        table.sort(CompleteInfos, function(A, B)
            return (A.PerfectProcess or 0) < (B.PerfectProcess or 0)
        end)
    else
        table.sort(CompleteInfos, function(A, B)
            return (A.NormalProcess or 0) < (B.NormalProcess or 0)
        end)
    end

    for Index = 1, RltNeedNum do
        local CompleteInfo = CompleteInfos[Index]
        if CompleteInfo then
            local bProcessFull = false
            if bNormalCompleteMax then
                bProcessFull = (CompleteInfo.PerfectProcess or 0) >= 1
            else
                bProcessFull = (CompleteInfo.NormalProcess or 0) >= 1
            end
            if not bProcessFull then
                local MapID = CompleteInfo.MapId
                if MapID then
                    table.insert(Rlt, MapID)
                end
            end
        end
    end
    return Rlt
end

--- 获取当前地图完美激活的探索点
---@return table @ID为笔记ID bPerfectCond为是否处于完美探索点显示的条件下
function DiscoverNoteMgr:GetThePerfectActivePointInfoByMapID(MapID)
    if not MapID then
        return
    end
    -- 内存紧张，不再走缓存在Mgr的数据，直接读取表格配置。后续会修改结构
    local MapPoints = DiscoverNoteCfg:FindAllCfg(string.format("MapID = %d", MapID))
    if not MapPoints or not next(MapPoints) then
        return
    end

    local Rlt = {}
    for _, NoteItemCfg in ipairs(MapPoints) do
        local NoteID = NoteItemCfg.ID
        if self:IsNotePointPerfectActived(NoteID) then
            table.insert(Rlt, {ID = NoteID, bPerfectCond = self:IsNotePointUnderPerfectCondByNoteID(NoteID)})
        end
    end

    return Rlt
end

--- 是否完美激活过任意一个点位的探索点
function DiscoverNoteMgr:IsActiveAnyPerfectPoint()
    local PerfectCompleteNum = self.PerfectCompleteNum or 0
    return PerfectCompleteNum > 0
end

return DiscoverNoteMgr