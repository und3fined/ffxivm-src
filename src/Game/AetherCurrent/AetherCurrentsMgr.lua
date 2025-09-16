--
-- Author: alex
-- Date: 2023-08-24 16:40
-- Description:风脉泉系统
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local AetherCurrentsVM = require("Game/AetherCurrent/AetherCurrentsVM")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local ModuleMapContentVM = require("Game/Map/VM/ModuleMapContentVM")
--local AetheCurrentMainItemVM = require("Game/AetherCurrent/ItemVM/AetheCurrentMainItemVM")
local AetherCurrentCfg = require("TableCfg/AetherCurrentCfg")
local AetherCurrentCompSetCfg = require("TableCfg/AetherCurrentCompSetCfg")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local MapMap2areaCfg = require("TableCfg/MapMap2areaCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local ObjectGCType = require("Define/ObjectGCType")
local EObjCfg = require("TableCfg/EobjCfg")
local MapUtil = require("Game/Map/MapUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local MathUtil = require("Utils/MathUtil")
local BitUtil = require("Utils/BitUtil")
local EffectUtil = require("Utils/EffectUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local AudioUtil = require("Utils/AudioUtil")
local ActorUtil = require("Utils/ActorUtil")
local TimeUtil = require("Utils/TimeUtil")
local ItemUtil = require("Utils/ItemUtil")
local SaveKey = require("Define/SaveKey")
local HUDType = require("Define/HUDType")
local MapUICfg = require("TableCfg/MapUICfg")
local FuncCfg = require("TableCfg/FuncCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CSWindPulseCmd
local WindPulseSpringActivateType = ProtoRes.WindPulseSpringActivateType
local MarkerIconPath = AetherCurrentDefine.MarkerIconPath
local MapAllPointActivateState = AetherCurrentDefine.MapAllPointActivateState
local MachineDetectDef = AetherCurrentDefine.MachineDetectDef
local MachineDetectRange = AetherCurrentDefine.MachineDetectRange
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType
--local OpenLinkedQuest = AetherCurrentDefine.OpenLinkedQuest
local VfxEffectType = AetherCurrentDefine.VfxEffectType
local VfxEffectPath = AetherCurrentDefine.VfxEffectPath
local LeftSidebarType = SidebarDefine.LeftSidebarType
local TutorialStartHandleType = ProtoRes.TutorialStartHandleType
local FuncType = ProtoRes.FuncType
--local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local LSTR = _G.LSTR
local EActorType = _G.UE.EActorType

local ClientVisionMgr
local PWorldMgr
local MapEditDataMgr
local SaveMgr
local QuestMgr
local BuoyMgr
local BagMgr
local UAudioMgr
local ModuleOpenMgr
local TipsQueueMgr
local SingBarMgr
local LeftSidebarMgr
local SkillSingEffectMgr
local NewTutorialMgr
local RangeCheckTriggerMgr
local AnimMgr
local OffsetDir = 360 / 16
local UseSearchMachineAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Tank_Jobs_Skill/Play_SE_VFX_Item_use_P.Play_SE_VFX_Item_use_P'"
local RTPCName = "Compass_volume" -- 范围0-50
local PointActiveAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_Zingle_Unlock.Play_Zingle_Unlock'"
local CommonFloatTipsAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_TextPrompt.Play_FM_TextPrompt'"

local AetherCurrentActiveSingStateID = 237 -- 风脉激活吟唱ID
local AetherCurrentItemID = 66700211 -- 风脉仪道具ID
local AetherFreezeTime = 5
local MapActiveItemID = AetherCurrentDefine.MapActiveItemID
local TutorialGroupID = AetherCurrentDefine.TutorialGroupID

---@class AetherCurrentsMgr : MgrBase
---@field AetherCurrentsServerInfos table@各版本地图风脉泉数据
local AetherCurrentsMgr = LuaClass(MgrBase)

function AetherCurrentsMgr:OnInit()
    self.AetherCurrentsMapCfg = {}
    self.CachePointIDToShowWhenOpen = {} -- MapItems上的地图标记
    self.CachePointIDToShowInMap = {} -- MapContent上的地图标记
    self:LoadAetherCurrentMapCompCfg()
    self.PointListsCfg = {} -- 缓存所有的风脉泉ID
    self.ItemID2PointID = {} -- 辅助查找任务型风脉泉道具ID to 风脉泉id的映射
    self:LoadAetherCurrentDetailCfg()
end

function AetherCurrentsMgr:OnBegin()
    self.bShowAetherCurrentSearchPanel = false
	self.AetherCurrentsServerInfos = {}
    self.ActivedPointIDs = {} -- Vision内快速判断风脉是否激活
    ClientVisionMgr = _G.ClientVisionMgr
    PWorldMgr = _G.PWorldMgr
    MapEditDataMgr = _G.MapEditDataMgr
    SaveMgr = _G.UE.USaveMgr
    BuoyMgr = _G.BuoyMgr
    QuestMgr  = _G.QuestMgr
    BagMgr = _G.BagMgr
    UAudioMgr = _G.UE.UAudioMgr.Get()
    ModuleOpenMgr = _G.ModuleOpenMgr
    TipsQueueMgr = _G.TipsQueueMgr
    SingBarMgr = _G.SingBarMgr
    LeftSidebarMgr = _G.LeftSidebarMgr
    SkillSingEffectMgr = _G.SkillSingEffectMgr
    AnimMgr = _G.AnimMgr
    NewTutorialMgr = _G.NewTutorialMgr
    RangeCheckTriggerMgr = _G.RangeCheckTriggerMgr
    self.SkillTimerHandle = nil
	self.CurrentCD = 0
    self.CfgGroupID = 0
    self.CfgFreezeCD = AetherFreezeTime
    local Cfg = ItemCfg:FindCfgByKey(AetherCurrentItemID)
	if Cfg then
        self.CfgGroupID = Cfg.FreezeGroup or 4
        self.CfgFreezeCD = Cfg.FreezeTime or AetherFreezeTime
	end

    self.SecondCount = 0
    self.LastRangeStage = 0
    self.LastClosestPoint = 0
    self.BuoyUID = nil
    self.BuoyTimeHandle = nil
    self.SkillPanelDisTimeHandle = nil
    self.SingVfxID = nil -- 播放中的吟唱ID
    self.StartAudioHandle = nil -- 风脉仪范围音效缓存ID
    self:LoadLastAddPointDataFromLocalDevice()

    --- ModuleMapVM地图数据处理
    self.MapIDWaitForUpdateFog = {}

    self.TaskPointItemWaitForEasyUse = {} -- 等待判定是否需要快捷使用的任务型风脉泉道具

    self.CurClosestPointDis = nil -- 当前最近点位距离（确保提示与风脉仪使用同一份数据，抹除误差）
    self.CurClosestPointDir = nil -- 当前最近点位方向

    self.PointID2EntityIDInVision = {} -- 缓存进入视野的风脉泉数据

    self.ForceSelectMapID = nil -- 抛开界面的固有规则，强制选中地图id

    self.bInNewPlayerGuiding = false -- 是否处于新手引导中
    self.PointActiveMapID = nil -- 缓存在新手指南结束后播放tips所属地图ID
    self.bMapActiveByItem = false -- 是否通过道具整张地图解锁

    self.NotCompleteMapInfoMap = {} -- 未完成地图所剩点位激活数量

    self.MontageUseSearchMachine = nil -- UAnimMontage
    self.MontageItemActiveMap = nil -- UAnimMontage 道具解锁地图所有风脉泉

    self.bMapActiveUseSecondPanelShow = false -- 是否处于地图解锁二次确认框显示中

    self.ShowSecondPanelMapCheck = {} -- 是否弹出二次界面开关
end

function AetherCurrentsMgr:OnEnd()
	self.AetherCurrentsServerInfos = nil
    self:EndSkillCDCount()
    self:SaveLastAddPointDataInLocalDevice()
    self.MapIDWaitForUpdateFog = nil
    self.TaskPointItemWaitForEasyUse = nil
    --self.MapActiveCache = nil
    self.CurClosestPointDis = nil
    self.PointID2EntityIDInVision = nil
    self.ActivedPointIDs = nil
    self.NotCompleteMapInfoMap = nil
    self.MontageUseSearchMachine = nil
    self.MontageItemActiveMap = nil
    self.ShowSecondPanelMapCheck = nil
end

function AetherCurrentsMgr:OnShutdown()
    self.AetherCurrentsMapCfg = nil
    self.CachePointIDToShowWhenOpen = nil
    self.CachePointIDToShowInMap = nil
    self.ItemID2PointID = nil
    self.PointListsCfg = nil
end

function AetherCurrentsMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_WINDPULSE, SUB_MSG_ID.WindPulseDataSync, self.OnNetMsgAetherCurrentsDataSync)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_WINDPULSE, SUB_MSG_ID.WindPulseActivatePointSuccess, self.OnNetMsgAetherCurrentsSuccessAct)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_WINDPULSE, SUB_MSG_ID.WindPulseMapActivate, self.OnNetMsgMapAetherCurrentsSuccessAct)
end

function AetherCurrentsMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnGameEventNetworkReconnected)
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnQuestDataUpdate)
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpen)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
    self:RegisterGameEvent(EventID.ActorReviveNotify,self.OnGameEventActorReviveNotify)
    self:RegisterGameEvent(EventID.MajorSingBarBegin, self.OnMajorSingBarBegin)
    self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOver)
    self:RegisterGameEvent(EventID.UpdateFogInfo, self.OnUpdateFogInfo)
    self:RegisterGameEvent(EventID.ShowUI, self.OnNotifyUIShow)
    self:RegisterGameEvent(EventID.HideUI, self.OnSkillCancelPanelHide)
    self:RegisterGameEvent(EventID.BagInit, self.OnCreateTaskPointEasyUseMap)
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
    self:RegisterGameEvent(EventID.TutorialGuideFenMaiQuanFinish, self.OnGameEventTutorialGuideAetherCurrentFinish)
end

function AetherCurrentsMgr:OnRegisterTimer()
    self:RegisterTimer(self.OnTimeTick, 0, 0.2, 0)
end

function AetherCurrentsMgr:NotifyPointInVisionStateChange(Params, bEnterOrLeave)
    local ActorType = Params.IntParam1
    if ActorType ~= EActorType.EObj then
        return
    end

    local EobjID = Params.IntParam2
    if not EobjID then
        return
    end

    local EntityID = Params.ULongParam1
    if not EntityID then
        return
    end

    local Cfg = EObjCfg:FindCfgByKey(EobjID)
    if not Cfg then
        return
    end

    local Params = Cfg.Param
    if not Params or not next(Params) then
        return
    end
    local PointID = Params[1]
    if not PointID then
        return
    end

    local bAetherCurrent = self.PointListsCfg[PointID]
    if not bAetherCurrent then
        return
    end

    if bEnterOrLeave then
        local InVision = self.PointID2EntityIDInVision or {}
        InVision[PointID] = EntityID
        self.PointID2EntityIDInVision = InVision
    else
        local OutVision = self.PointID2EntityIDInVision
        if not OutVision or not next(OutVision) then
            return
        end
        OutVision[PointID] = nil
    end

    if not _G.NewTutorialMgr:IsGroupComplete(TutorialGroupID) then
        if bEnterOrLeave then
            RangeCheckTriggerMgr:AddRangeCheckActorCreated(TriggerGamePlayType.AetherCurrentTutorial, EntityID)
        else
            RangeCheckTriggerMgr:RemoveRangeCheckActorCreated(EntityID)
        end
    end
end

function AetherCurrentsMgr:OnGameEventVisionEnter(Params)
    self:NotifyPointInVisionStateChange(Params, true)
end

function AetherCurrentsMgr:OnGameEventVisionLeave(Params)
    self:NotifyPointInVisionStateChange(Params)
end

function AetherCurrentsMgr:OnCreateTaskPointEasyUseMap()
    self.TaskPointItemWaitForEasyUse = {}
    local ItemID2PointID = self.ItemID2PointID
    if not ItemID2PointID or not next(ItemID2PointID) then
        return
    end
    local ItemList = BagMgr:FilterItemByCondition(function(Item)
		return ItemID2PointID[Item.ResID]
	end)
    for _, Item in ipairs(ItemList) do
        self.TaskPointItemWaitForEasyUse[Item.GID] = 1
    end
end

function AetherCurrentsMgr:OnNotifyUIShow(ViewID)
    self:OnSkillCancelPanelShow(ViewID)
end

function AetherCurrentsMgr:OnSkillCancelPanelShow(ViewID)
    if ViewID ~= UIViewID.SkillCancelJoyStick then
        return
    end

    local SkillVM = AetherCurrentsVM.SkillPanelVM
    if not SkillVM then
        return
    end

    SkillVM:SetPanelSkillBtnVisible(false) -- 与技能取消按钮互斥
end

function AetherCurrentsMgr:OnSkillCancelPanelHide(ViewID)
    if ViewID ~= UIViewID.SkillCancelJoyStick then
        return
    end
    self:UpdateSkillBtnVisibleState() -- 刷新风脉仪按钮显示状态
    self:UpdateSkillPanelAndBuoyShow()
end

function AetherCurrentsMgr:OnMajorSingBarBegin(EntityID, SingStateID)
    if not MajorUtil.IsMajor(EntityID) then
        return
    end
    if SingStateID ~= AetherCurrentActiveSingStateID then
        return
    end

    _G.InteractiveMgr:SetShowMainPanelEnabled(false)
    self.SingVfxID = self:PlayEffectByPathWithCallBack(VfxEffectType.ActiveSing) -- 吟唱特效持续超过5s不需要考虑反复播放的问题
end

function AetherCurrentsMgr:OnMajorSingBarOver(EntityID, IsBreak)
     if not MajorUtil.IsMajor(EntityID) then
        return
    end

    if not self.SingVfxID then
        return
    end

    EffectUtil.StopVfx(self.SingVfxID)
    self.SingVfxID = nil
    FLOG_INFO("AetherCurrentLeaveVision:SingOver %s", tostring(TimeUtil.GetServerTimeMS()))
 
    if IsBreak then
        _G.InteractiveMgr:SetShowMainPanelEnabled(true)
    end
end

function AetherCurrentsMgr:OnUpdateFogInfo()
    local FogMapIDs = self.MapIDWaitForUpdateFog
    if not FogMapIDs or not next(FogMapIDs) then
        return
    end

    for _, MapID in ipairs(FogMapIDs) do
        ModuleMapContentVM:SetDiscoveryFlag(_G.FogMgr:GetFlogFlag(MapID))
        ModuleMapContentVM:SetIsAllActivate(_G.FogMgr:IsAllActivate(MapID))
    end
    self.MapIDWaitForUpdateFog = {}
end

--- 刷新面板和浮标显示
---@param bUseInTick boolean@是否在tick中调用，不在tick中调用时不需要对状态是否一致进行判断
---@param bShowTips boolean @是否触发显示Tips
function AetherCurrentsMgr:UpdateSkillPanelAndBuoyShow(bUseInTick)
    local SkillVM = AetherCurrentsVM.SkillPanelVM
    if not SkillVM then
        return
    end
    
    -- 不符合显示风脉仪的状态就不去更新风脉显示，并关闭音效
    local AetherCurrentSkillPanelShow = SkillVM:GetPanelSkillBtnVisible()
    if not AetherCurrentSkillPanelShow then
        return
    end

    local ClosestPoint = self:GetTheClosestAetherCurrentPointID()
    if not ClosestPoint then -- 交互型风脉泉激活完毕，任务型风脉泉还在的情况
        return
    end

    local Dis, Angle = self:CalculatePointDistanceAndAngle(ClosestPoint)
    if not Dis or not Angle then
        return
    end

    local LastDis = self.CurClosestPointDis
    if LastDis ~= Dis then
        local HaveSoundIndex = 1
        local ValueMax = 50
        local MaxDisWithSound = MachineDetectRange[HaveSoundIndex]
        local MathInsensity = Dis / 100 / MaxDisWithSound * ValueMax
        local RTPCValue = MathInsensity > ValueMax and ValueMax or MathInsensity
        UAudioMgr.SetRTPCValue(RTPCName, RTPCValue, 0, nil)
    end
    self.CurClosestPointDis = Dis
    self.CurClosestPointDir = Angle

    local LastRangeStage = self.LastRangeStage
    local CurRangeIndex, TextRangeIndex = self:CalculateDetectRangeStage(Dis / 100)
    if CurRangeIndex then
        local RangeDetectDef = MachineDetectDef[TextRangeIndex]
        local DisText = string.format("%sm", tostring(math.floor(Dis / 100)))
        local TextFarContent = RangeDetectDef.bShowDisNumOrText and DisText or LSTR(310001)
        SkillVM:UpdateClosestPointDistance(TextFarContent)
        if not bUseInTick or CurRangeIndex ~= LastRangeStage then
            FLOG_INFO("MainMiniMapPanelView:OnRangeIndexChange dis %s", DisText)
            SkillVM:UpdateSkillPanelShowAfterRangeStageChange(CurRangeIndex)
        end
        self.LastRangeStage = CurRangeIndex
    end
end

--- 实时检测人物与最近风脉泉点的距离
function AetherCurrentsMgr:OnTimeTick()
    --[[if PWorldMgr:IsLoadingWorld() then -- 世界加载时时刻更新动效音效状态
        self:UpdateSkillBtnVisibleState()
    end--]]

    if self:IsMajorMoving() then -- 非移动状态不进行Tick更新
        self:UpdateSkillPanelAndBuoyShow(true)
        local MontageUseSearchMachine = self.MontageUseSearchMachine
        if MontageUseSearchMachine then
            local MajorEntityID = MajorUtil.GetMajorEntityID()
            local AnimInst = AnimationUtil.GetAnimInst(MajorEntityID)
            AnimationUtil.MontageStop(AnimInst, MontageUseSearchMachine)
            self.MontageUseSearchMachine = nil
        end

        self:BreakTheMajorActionTimeLineAtMapActive()
    end
end

--- 重连/切图情况下重置相关Mgr状态变量
function AetherCurrentsMgr:ResetPointActiveVar()
    _G.InteractiveMgr:SetShowMainPanelEnabled(true)
end

function AetherCurrentsMgr:OnGameEventLoginRes(Params)
    local bReconnect = Params.bReconnect
    if bReconnect then
        self:ResetPointActiveVar()
    end

    if not self:IsAetherCurrentSysOpen() then
        return
    end

    self:SendMsgAetherCurrentsDataSync()
end

--- 闪断情况重连逻辑
function AetherCurrentsMgr:OnGameEventNetworkReconnected(Params)
    if not Params or not Params.bRelay then
        return
    end
  
    self:ResetPointActiveVar()
end


function AetherCurrentsMgr:OnGameEventPWorldMapEnter(Params)
    self:UpdateSkillBtnVisibleState()
    self:UpdateSkillPanelAndBuoyShow()
   
    self:UpdateEasyUseItemWhenChangeMap()
    self:ResetPointActiveVar()
end

function AetherCurrentsMgr:OnGameEventMajorDead()
    if MajorUtil.IsMajorDead() then
        local SkillVM = AetherCurrentsVM.SkillPanelVM
        if SkillVM == nil then
            return
        end
        SkillVM:SetPanelSkillBtnVisible(false)
    end
end

function AetherCurrentsMgr:OnGameEventActorReviveNotify(Params)
    if nil == Params then
		return
	end

    local EntityID = Params.ULongParam1
    if EntityID ~= MajorUtil.GetMajorEntityID() then
        return
    end

    self:UpdateSkillBtnVisibleState()
    self:UpdateSkillPanelAndBuoyShow()
    self:ResetPointActiveVar()
end

function AetherCurrentsMgr:OnGameEventPWorldMapExit(bChangeMap)
    if not bChangeMap then
        return
    end
    self:CancelTheBlockToShowSecondPanel()
end


function AetherCurrentsMgr:OnQuestDataUpdate(Params)

end

function AetherCurrentsMgr:OnGameEventTutorialGuideAetherCurrentFinish()
    if self.bInNewPlayerGuiding and self.PointActiveMapID then
        if self.bMapActiveByItem then
            local function ShowTipsCallback(_)
                self:ShowCompMissionTip(self.PointActiveMapID, true)
            end
            local Duration =  AetherCurrentDefine.MissionTipShowDuration + AetherCurrentDefine.MissionTipShowDelayTime + 2
            local Config = {Type = ProtoRes.tip_class_type.TIP_WIND_UNLOCK, Callback = ShowTipsCallback, Duration = Duration}
            _G.TipsQueueMgr:AddPendingShowTips(Config)
        else
            self:ShowTipsAfterPointUnlock(self.PointActiveMapID)
        end
        self.bInNewPlayerGuiding = false
        self.PointActiveMapID = nil
        self.bMapActiveByItem = false
    end
end

--- 功能解锁界面表现结束
function AetherCurrentsMgr:OnModuleOpen(OpenID)
    local bIsAetherCurrent = OpenID == ProtoCommon.ModuleID.ModuleIDAetherCurrent --  table.contain(OpenIDList, ) 
    if bIsAetherCurrent then
        self:SendMsgAetherCurrentsDataSync()
        WorldMapVM.BtnAetherCurrentVisible = self:IsAetherCurrentSysOpen()
    end
end

function AetherCurrentsMgr:IsMajorMoving()
    local Major = MajorUtil.GetMajor()
    if not Major then
        return
    end
    local CharacterMovement = Major.CharacterMovement
    if not CharacterMovement then
        return
    end

    local MojorVec = CharacterMovement.Velocity
    if not MojorVec then
        return
    end

    local INF = 0.000000001
    return MojorVec:Size() >= INF
end

function AetherCurrentsMgr:SaveLastAddPointDataInLocalDeviceInternal(SaveKeyParam)
    local CachePointList
    if SaveKeyParam == SaveKey.LastRecordPointSequence then
        CachePointList = self.CachePointIDToShowWhenOpen
    elseif SaveKeyParam == SaveKey.LastRecordPointMap then
        CachePointList = self.CachePointIDToShowInMap
    end
    if CachePointList == nil or next(CachePointList) == nil then
        SaveMgr.SetString(SaveKeyParam, "", true)
        return
    end

    local StrToSave
    for index, PointID in ipairs(CachePointList) do
        if index == 1 then
            StrToSave = tostring(PointID)
        else
            StrToSave = string.format("%s,%s", StrToSave, tostring(PointID))
        end
    end
    if StrToSave == nil then
        return
    end
    SaveMgr.SetString(SaveKeyParam, StrToSave, true)
end

--- 将当前角色数据缓存入本地设备
function AetherCurrentsMgr:SaveLastAddPointDataInLocalDevice()
    self:SaveLastAddPointDataInLocalDeviceInternal(SaveKey.LastRecordPointSequence)
    self:SaveLastAddPointDataInLocalDeviceInternal(SaveKey.LastRecordPointMap)
end

function AetherCurrentsMgr:LoadLastAddPointDataFromLocalDeviceInternal(SaveKeyParam)
    local CachePointList = {}
    local StrLoaded = SaveMgr.GetString(SaveKeyParam, "", true)
    if StrLoaded == "" then
        if SaveKeyParam == SaveKey.LastRecordPointSequence then
            self.CachePointIDToShowWhenOpen = {}
        elseif SaveKeyParam == SaveKey.LastRecordPointMap then
            self.CachePointIDToShowInMap = {}
        end
        return
    end
    local LocalStrParams = string.split(StrLoaded, ',')
    for _, value in ipairs(LocalStrParams) do
        local PointID = tonumber(value)
        if PointID then
            table.insert(CachePointList, PointID)
        end
    end
    if SaveKeyParam == SaveKey.LastRecordPointSequence then
        self.CachePointIDToShowWhenOpen = CachePointList
    elseif SaveKeyParam == SaveKey.LastRecordPointMap then
        self.CachePointIDToShowInMap = CachePointList
    end
end

--- 将本地设备数据加载到内存中
function AetherCurrentsMgr:LoadLastAddPointDataFromLocalDevice()
    self:LoadLastAddPointDataFromLocalDeviceInternal(SaveKey.LastRecordPointSequence)
    self:LoadLastAddPointDataFromLocalDeviceInternal(SaveKey.LastRecordPointMap)
end

--- 清空内存数据
function AetherCurrentsMgr:ClearLastAddPointData()
    self.CachePointIDToShowWhenOpen = {}
end

--- 删除地图上已播放过特效的PointID
---@param PointID number@风脉泉点的ID
function AetherCurrentsMgr:ClearLastAddPointDataByPointIDInMap(PointID)
    local CachePointIDToShowInMap = self.CachePointIDToShowInMap
    if not CachePointIDToShowInMap or not next(CachePointIDToShowInMap) then
        return
    end
    table.array_remove_item_pred(CachePointIDToShowInMap, function(e)
        return e == PointID
    end)
end

--- 删除已播放过特效的PointID
---@param PointID number@风脉泉点的ID
function AetherCurrentsMgr:ClearLastAddPointDataByPointID(PointID)
    local CachePointIDToShowWhenOpen = self.CachePointIDToShowWhenOpen
    if not CachePointIDToShowWhenOpen or not next(CachePointIDToShowWhenOpen) then
        return
    end
    table.array_remove_item_pred(CachePointIDToShowWhenOpen, function(e)
        return e == PointID
    end)
end

--- 添加新激活风脉泉缓存数据
function AetherCurrentsMgr:AddNewLastAddPointData(PointID)
    local CacheList = self.CachePointIDToShowWhenOpen
    if CacheList == nil then
        return
    end
    table.insert(CacheList, PointID)

    local CacheListMap = self.CachePointIDToShowInMap
    if CacheListMap == nil then
        return
    end
    table.insert(CacheListMap, PointID)
end

--- 是否有风脉激活的内容需要播放
function AetherCurrentsMgr:IsNeedShowActivePointChangeWhenOpenPanel()
    local CacheList = self.CachePointIDToShowWhenOpen
    return CacheList and next(CacheList)
end

--- 目标地图是否有风脉泉动效需要播放
---@param MapID number@目标地图ID
function AetherCurrentsMgr:IsNeedShowActivePointChangeCurMap(MapID)
    local CacheList = self.CachePointIDToShowInMap
    if not CacheList or not next(CacheList) then
        return
    end
    for index = #CacheList, 1, -1 do
        local PointID = CacheList[index]
        local AeCurCfg = AetherCurrentCfg:FindCfgByKey(PointID)
        if AeCurCfg then
            local CfgMapID = AeCurCfg.MapID
            if CfgMapID then
                if CfgMapID == MapID then
                    return true
                end
            end
        end
    end
end

--- 根据范围设定声音强度
---@param RangeIndex number@范围区间序号
function AetherCurrentsMgr:SetSearchMachineAudioVolume(RangeIndex)
    local RangeDef = MachineDetectDef[RangeIndex]
    if not RangeDef then
        return
    end

    local Value = RangeDef.AudioValue -- 为nil表示不需要设定声音强度
    if not Value then
        return
    end

    if not self.StartAudioHandle then
        return
    end

    UAudioMgr.SetRTPCValue(RTPCName, Value, 0, nil)
end

--- 是否需要播放风脉仪音效
---@param RangeIndex number@范围区间序号
function AetherCurrentsMgr:IsSearchMachineNeedAudio(RangeIndex)
    local RangeDef = MachineDetectDef[RangeIndex]
    if not RangeDef then
        return
    end

    local Value = RangeDef.AudioValue -- 为nil表示不需要设定声音强度
    if not Value then
        return
    end
    return true
end

--- 打开界面播放当前地域的风脉泉解锁特效
---@return boolean @是否有缓存表现
function AetherCurrentsMgr:ShowTheActivePointChangeWhenOpenPanelByRegionID(RegionID)
    local CacheList = self.CachePointIDToShowWhenOpen
    if not CacheList or not next(CacheList) then
        return
    end

    local LoopList = table.clone(CacheList)
    for _, value in ipairs(LoopList) do
        local CurPointRegion = self:GetPointRegionID(value)
        if CurPointRegion and CurPointRegion == RegionID then
            self:OnNotifyNewAetherCurrentActived(value)
            self:ClearLastAddPointDataByPointID(value)
        end
    end
end

--- 查找最新激活的风脉泉所属地图id
function AetherCurrentsMgr:GetTheLatestActivePointMapID()
    local CacheList = self.CachePointIDToShowWhenOpen
    if CacheList == nil then
        return
    end
    local Len = #CacheList
    if Len == 0 then
        return
    end
    local TailPoint = CacheList[Len]
    local AeCurCfg = AetherCurrentCfg:FindCfgByKey(TailPoint)
    if AeCurCfg == nil then
        -- body
        FLOG_ERROR("AetherCurrentsMgr:GetTheLatestActivePointMapID: AetherCurrentCfg can not find the data. ID:%d", TailPoint)
        return
    end

    return AeCurCfg.MapID
end

function AetherCurrentsMgr:SendMsgAetherCurrentsDataSync()
    local MsgID = CS_CMD.CS_CMD_WINDPULSE
    local SubMsgID = SUB_MSG_ID.WindPulseDataSync

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 根据服务器bytes数组确认PointID
function AetherCurrentsMgr:GetTheActivedPointIDFromBitSet(MapPointIndexBytes)
    local ResultPointIDs = {}
    for MapID, Bytes in pairs(MapPointIndexBytes) do
        local BytesSet = BitUtil.StringToByteArray(Bytes)
        FLOG_INFO("OnNetMsgAetherCurrentsDataSync: Bytes: %s", table.tostring(BytesSet))
        local PointCompCfg = AetherCurrentCompSetCfg:FindCfgByKey(MapID)
        if PointCompCfg then
            local PointIDs = PointCompCfg.AetherCurrentPointList
            if PointIDs and next(PointIDs) ~= nil then
                for i = 1, #PointIDs do
                    local IndexInC = i - 1
                    local BytesIndex = math.floor(IndexInC / 8) + 1
                    local Byte = BytesSet[BytesIndex]
                    if Byte then
                        local BitIndex = IndexInC % 8
                        if BitUtil.IsBitSet(Byte, BitIndex) then
                            table.insert(ResultPointIDs, PointIDs[i])
                        end
                    end
                end
            end
        end
    end
    return ResultPointIDs
end

---同步服务器风脉泉激活信息
function AetherCurrentsMgr:OnNetMsgAetherCurrentsDataSync(MsgBody)
    FLOG_INFO("OnNetMsgAetherCurrentsDataSync: MsgID(CS_CMD_WINDPULSE): %d, SubMsgID(WindPulseDataSync): %d",
        CS_CMD.CS_CMD_WINDPULSE, SUB_MSG_ID.WindPulseDataSync)
    if nil == MsgBody then
        FLOG_ERROR("OnNetMsgAetherCurrentsDataSync: MsgBody is nil")
        return
    end
    local SevAetherCurrentsInfo = MsgBody.WindPulseData
    if nil == SevAetherCurrentsInfo then
        return
    end

    local MapPointIndexBytes = SevAetherCurrentsInfo.PointBitSlice
    local SevActivatedPointIDs = self:GetTheActivedPointIDFromBitSet(MapPointIndexBytes)
    local MapAllPointActived = SevAetherCurrentsInfo.MapList
   
    for _, MapID in ipairs(MapAllPointActived) do
        local PointCompCfg = AetherCurrentCompSetCfg:FindCfgByKey(MapID)
        if PointCompCfg then
            local PointIDs = PointCompCfg.AetherCurrentPointList
            if PointIDs and next(PointIDs) ~= nil then
                table.merge_table(SevActivatedPointIDs, PointIDs)
            end
        end
    end
    self:UpdateAetherCurrentSevInfo(SevActivatedPointIDs)
    self:UpdateNotCompleteMapInfoArray(MapAllPointActived)
    self:OnNotifySyncAetherCurrentMainVM()
    self:UpdateSkillBtnVisibleState()
    self:UpdateSkillPanelAndBuoyShow()
end

---风脉泉激活成功回复
function AetherCurrentsMgr:OnNetMsgAetherCurrentsSuccessAct(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("OnNetMsgAetherCurrentsFinishAct: MsgBody is nil")
        return
    end
    local ActivateRsp = MsgBody.ActivateRsp
    if nil == ActivateRsp then
        return
    end

    local StartActPoint = ActivateRsp.PointID


    self:AddNewActivedAetherCurrent(StartActPoint)
    self:AddNewLastAddPointData(StartActPoint)
    self:SaveLastAddPointDataInLocalDevice() -- 2025.1.16 将保存操作放到数据变化步骤，以解决清除后台时不走OnEnd的问题
    self:NotifyOtherModuleAetherCurrentPointActive(StartActPoint)
    self:OnNotifyEobjAetherCurrentLeaveVision(StartActPoint)
    self:UpdatePointActiveClientPerformance(StartActPoint)
    self:OnNotifyAetherCurrentQuestActivated(StartActPoint)
    self:UpdateSkillPanelAndBuoyShow() -- 激活成功后风脉泉数量发生改变，手动触发一次显示刷新
    self:UpdateMapNotCompletePointInfo(StartActPoint)
end

--- 道具使用后整个地图风脉泉激活成功回复
function AetherCurrentsMgr:OnNetMsgMapAetherCurrentsSuccessAct(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("OnNetMsgMapAetherCurrentsSuccessAct: MsgBody is nil")
        return
    end
    local ActivateRsp = MsgBody.MapActivateRsp
    if nil == ActivateRsp then
        return
    end

    local ActivedMap = ActivateRsp.MapID
    local MapCompCfg = AetherCurrentCompSetCfg:FindCfgByKey(ActivedMap)
    if not MapCompCfg then
        FLOG_ERROR("OnNetMsgMapAetherCurrentsSuccessAct: Config is nil")
        return
    end

    local PointList = MapCompCfg.AetherCurrentPointList
    if not PointList or not next(PointList) then
        return
    end

    for _, PointID in ipairs(PointList) do
        if not self:IsPointActivedQuickCheck(PointID) then
            self:AddNewActivedAetherCurrent(PointID)
            self:AddNewLastAddPointData(PointID)
            self:OnNotifyEobjAetherCurrentLeaveVision(PointID)
        end
    end
    self:SaveLastAddPointDataInLocalDevice() -- 2025.1.16 将保存操作放到数据变化步骤，以解决清除后台时不走OnEnd的问题
    self:NotifyOtherModuleCheckAllActiveByMap(ActivedMap)
    self:UpdateMapActiveClientPerformance(ActivedMap)
    self:RemoveNotCompleteInfoByMap(ActivedMap)
    self:UpdateSkillBtnVisibleState()
    self:UpdateSkillPanelAndBuoyShow() -- 激活成功后风脉泉数量发生改变，手动触发一次显示刷新
end



---加载风脉泉地图数据配置
function AetherCurrentsMgr:LoadAetherCurrentMapCompCfg()
    local ACurrentCompCfg = AetherCurrentCompSetCfg:FindAllCfg("1=1")
    if nil == ACurrentCompCfg then
        -- body
        FLOG_ERROR("InitAetherCurrentSevInfo: ACurrentCompCfg is nil")
        return
    end

    local AeCurMapCfgs = self.AetherCurrentsMapCfg
    for _, MapComp in ipairs(ACurrentCompCfg) do
        -- body
        local MapKey = MapComp.MapID
        if MapKey then
            local UIMapID = MapUtil.GetUIMapID(MapKey)
            if UIMapID then
                table.insert(AeCurMapCfgs, MapKey)
            end
        end
    end
end

---加载风脉泉详情表格数据
function AetherCurrentsMgr:LoadAetherCurrentDetailCfg()
    local DetailCfg = AetherCurrentCfg:FindAllCfg("1=1")
    if nil == DetailCfg then
        FLOG_ERROR("LoadAetherCurrentDetailCfg: DetailCfg is nil")
        return
    end

    local ItemID2PointID = self.ItemID2PointID or {}
    local PointListsCfg = self.PointListsCfg or {}
    for _, Cfg in ipairs(DetailCfg) do
        local PointID = Cfg.PointID
        if PointID then
            local CurrentType = Cfg.CurrentType
            if CurrentType == WindPulseSpringActivateType.Task then
                local ItemID = Cfg.ItemID or 0
                ItemID2PointID[ItemID] = PointID
            end
            PointListsCfg[PointID] = true
        end
    end
    self.ItemID2PointID = ItemID2PointID
    self.PointListsCfg = PointListsCfg
end

--- 根据关卡编辑器数据获取位置信息并缓存
---@param MapID number@地图id
---@param PointID number@风脉泉表id
function AetherCurrentsMgr:GetPosInfoFromMapEditCfg(PointID, MapID)
    local SevInfo = self:GetAetherCurrentActivedByPointID(PointID)
    if not SevInfo then
        return
    else
        local SevCachePos = SevInfo.Pos
        if SevCachePos then
            return SevCachePos
        end
    end

    local AeCurCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if not AeCurCfg then
        return
    end

    local ListID = AeCurCfg.ListID
    if not ListID then
        return
    end

    local MapEditCfg = MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    if not MapEditCfg then
       return
    end
    local EObjData = MapEditDataMgr:GetEObjByListID(ListID, MapEditCfg)
    if EObjData ~= nil then
        local P = EObjData.Point
        local Pos = {X = P.X, Y = P.Y}
        SevInfo.Pos = Pos
        return Pos
    end

end

--- 从任务系统获取对应任务的坐标
function AetherCurrentsMgr:GetPosInfoFromAetherCurrentCfg(PointID)
    local ACfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if ACfg then
        local PosVec = ACfg.PosVec
        if PosVec then
            return {X = PosVec[1] or 0, Y = PosVec[2] or 0}
        end
    end
end

--- 添加新的激活的风脉泉数据[Region,[map,[Point,[]]]]
---@param PointID number@风脉泉唯一ID
function AetherCurrentsMgr:AddNewActivedAetherCurrent(PointID)
    local AeCurCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if AeCurCfg == nil then
        -- body
        FLOG_ERROR("AetherCurrentsMgr:AddNewActivedAetherCurrent: AetherCurrentCfg can not find the data. ID:%d", PointID)
        return
    end
    local SevInfo = self.AetherCurrentsServerInfos
    if SevInfo == nil then
        -- body
        FLOG_ERROR("AetherCurrentsMgr:AddNewActivedAetherCurrent: AetherCurrentsServerInfos is nil")
        return
    end

    --local Version = 1 --AeCurCfg.BoosterCategory(2期改为按地域划分)
    local MapID = AeCurCfg.MapID
    if not MapID then
        FLOG_ERROR("AetherCurrentsMgr:AddNewActivedAetherCurrent: MapID is nil")
        return
    end

    local RegionID = MapUtil.GetMapRegionID(MapID)
    if not RegionID then
        FLOG_ERROR("AetherCurrentsMgr:AddNewActivedAetherCurrent: RegionID is invalid")
        return
    end
    local RegionSevInfo = SevInfo[RegionID] or {}
    local CurrentType = AeCurCfg.CurrentType
    local QuestID = AeCurCfg.QuestID
    local ListID = AeCurCfg.ListID

    do
        local MapSevInfo = RegionSevInfo[MapID] or {}
        local PointSevInfo = MapSevInfo[PointID]
        if PointSevInfo == nil then
            local ActivedPointIDs = self.ActivedPointIDs or {}
            PointSevInfo = {}
            PointSevInfo.CurrentType = CurrentType
            if CurrentType == WindPulseSpringActivateType.Interact then
                PointSevInfo.MarkID = ListID
            elseif CurrentType == WindPulseSpringActivateType.Task then
                PointSevInfo.QuestID = QuestID
            end
            MapSevInfo[PointID] = PointSevInfo
            ActivedPointIDs[PointID] = true
            self.ActivedPointIDs = ActivedPointIDs
        end
        RegionSevInfo[MapID] = MapSevInfo
    end
    SevInfo[RegionID] = RegionSevInfo
end

---根据已激活风脉泉ID更新风脉泉激活信息
function AetherCurrentsMgr:UpdateAetherCurrentSevInfo(PointList)
    self.AetherCurrentsServerInfos = {}
    if PointList == nil or next(PointList) == nil then
        return
    end

    for _, PointID in pairs(PointList) do
       self:AddNewActivedAetherCurrent(PointID)
       --self:AddNewLastAddPointData(StartActPoint)
    end
end

---根据已激活风脉泉ID更新地图风脉泉激活信息
function AetherCurrentsMgr:UpdateNotCompleteMapInfoArray(MapAllPointActived)
    local AllMapList = self.AetherCurrentsMapCfg
    if not AllMapList or not next(AllMapList) then
        return
    end
    local NotCompleteMapInfoMap = {}
    local AllMapsTmp = {}
    for _, MapID in ipairs(AllMapList) do
        AllMapsTmp[MapID] = true
    end
    for _, MapID in ipairs(MapAllPointActived) do
        AllMapsTmp[MapID] = nil
    end

    for MapID, _ in pairs(AllMapsTmp) do
        NotCompleteMapInfoMap[MapID] = {
            MapID = MapID,
            MapRemainPointNum = 0,
        }

        local AtiveNum, TotalNum = self:GetTheMapPointUnlockProcess(MapID)
        if AtiveNum and TotalNum  then
            NotCompleteMapInfoMap[MapID].MapRemainPointNum = TotalNum - AtiveNum
        end
    end

    self.NotCompleteMapInfoMap = NotCompleteMapInfoMap
end

---根据单次激活风脉泉ID更新地图风脉泉激活信息
function AetherCurrentsMgr:UpdateMapNotCompletePointInfo(PointID)
    local NotCompleteMapInfoMap = self.NotCompleteMapInfoMap
    if not NotCompleteMapInfoMap or not next(NotCompleteMapInfoMap) then
        return
    end

    local MapID = AetherCurrentCfg:FindValue(PointID, "MapID")
    if not MapID then
        return
    end

    local MapTmpInfo = NotCompleteMapInfoMap[MapID]
    if not MapTmpInfo then
        return
    end

    local MapRemainPointNum = MapTmpInfo.MapRemainPointNum - 1
    if MapRemainPointNum <= 0 then
        NotCompleteMapInfoMap[MapID] = nil
    else
        MapTmpInfo.MapRemainPointNum = MapRemainPointNum
    end
end

---根据地图MapID清理记录的剩余未解锁进度内容
function AetherCurrentsMgr:RemoveNotCompleteInfoByMap(MapID)
    local NotCompleteMapInfoMap = self.NotCompleteMapInfoMap
    if not NotCompleteMapInfoMap or not next(NotCompleteMapInfoMap) then
        return
    end

    local MapTmpInfo = NotCompleteMapInfoMap[MapID]
    if not MapTmpInfo then
        return
    end
    NotCompleteMapInfoMap[MapID] = nil
end

--- 快速检查对应风脉泉点位是否已激活
---@param PointID number@风脉泉唯一ID
function AetherCurrentsMgr:IsPointActivedQuickCheck(PointID)
    if not PointID or type(PointID) ~= "number" then
        return
    end

    local ActivedPointIDs = self.ActivedPointIDs
    if not ActivedPointIDs or not next(ActivedPointIDs) then
        return
    end

    return ActivedPointIDs[PointID]
end

---根据风脉泉id获取风脉泉激活信息
---@param PointID number@风脉泉唯一ID
function AetherCurrentsMgr:GetAetherCurrentActivedByPointID(PointID)
    local SevCurrentInfo = self.AetherCurrentsServerInfos
    if SevCurrentInfo == nil or next(SevCurrentInfo) == nil then
        return
    end
    local AetherCurrentDetailCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if AetherCurrentDetailCfg == nil then
        if type(PointID) == "number" then
            FLOG_ERROR("AetherCurrentCfg Can Not Find The Data. PointID:%d", PointID)
        else
            FLOG_ERROR("AetherCurrentCfg Can Not Find The Data. PointID is error type")
        end
        return
    end
    local MapID = AetherCurrentDetailCfg.MapID
    if not MapID then
        return
    end

    local RegionID = MapUtil.GetMapRegionID(MapID)
    if not RegionID then
        return
    end

    local SevInfoUnderVer = SevCurrentInfo[RegionID]
    if SevInfoUnderVer == nil or next(SevInfoUnderVer) == nil then
        return nil
    end
    local MapIDForPoint = AetherCurrentDetailCfg.MapID
    if MapIDForPoint == nil then
        return nil
    end
    local SevInfoUnderMap = SevInfoUnderVer[MapIDForPoint]
    if SevInfoUnderMap == nil or next(SevInfoUnderMap) == nil then
        return nil
    end
    local PointSevInfo = SevInfoUnderMap[PointID]
    return PointSevInfo
end

--- 打开风脉泉主界面
function AetherCurrentsMgr:OpenAetherCurrentMainPanel(MapID)
    if MapID then
        self.ForceSelectMapID = MapID
    end
    UIViewMgr:ShowView(UIViewID.AetherCurrentMainPanelView)
end

--- 根据风脉泉唯一id获取VM使用的Mark信息
function AetherCurrentsMgr:GetViewModelMarkIDByPointID(PointID)
    local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if PointCfg == nil then
        FLOG_ERROR("AetherCurrentsMgr:GetViewModelMarkIDByPointID: PointCfg is nil")
        return
    end
    local Type = PointCfg.CurrentType
    if Type == WindPulseSpringActivateType.Interact then
        return Type, PointCfg.ListID
    elseif Type == WindPulseSpringActivateType.Task  then
        return Type, PointCfg.QuestID
    end
end

--- 根据需要解锁的PointID判断是否已全部解锁
---@param PointList table<number>@风脉泉ID列表
function AetherCurrentsMgr:IsAetherCurrentsPointAllActived(PointList)
    if PointList == nil or next(PointList) == nil then
        FLOG_ERROR("AetherCurrentsMgr:IsAetherCurrentsPointAllActived: PointList is nil")
        return false
    end
    local bAllActived = true
    for _, PointID in pairs(PointList) do
        if not self:IsPointActivedQuickCheck(PointID) then
            bAllActived = false
            break
        end
    end
    return bAllActived
end


--- 初始化创建风脉泉地图列表Value
function AetherCurrentsMgr:CreateMapListData(MapID)
    local UIMapID = MapUtil.GetUIMapID(MapID) or 0
    local MapName = MapUtil.GetMapName(UIMapID) or ""
    local MapListItemValue = {
        MapID = MapID,
        MapName = MapName,
    }
    return MapListItemValue
end

--- 同步数据时创建MapItem上的标记数据
function AetherCurrentsMgr:CreateMarkListData(PointList)
    if PointList == nil or next(PointList) == nil then
        return
    end
    local QuestMark = {}
    local InteractMark = {}
    for _, PointID in ipairs(PointList) do
        local MarkItemData = {}
        local Type, MarkID = self:GetViewModelMarkIDByPointID(PointID)
        if Type and MarkID then
            MarkItemData.MarkID = MarkID
            MarkItemData.bActived = self:IsPointActivedQuickCheck(PointID) and (not self:IsPointNeedHideInViewModel(PointID))
            if Type == WindPulseSpringActivateType.Task then
                table.insert(QuestMark, MarkItemData)
            elseif Type == WindPulseSpringActivateType.Interact then
                table.insert(InteractMark, MarkItemData)
            end
        end
    end
    --[[if next(QuestMark) then
        table.sort(QuestMark, AetherCurrentDefine.QuestMarkSortRule)
    end--]]
    return QuestMark, InteractMark
end

--- 构造风脉泉主界面MapItem的ViewModel
function AetherCurrentsMgr:CreateAetheCurrentMainItemVM(MapID)
    local ValInVM = self:CreateMapListData(MapID)
    local MapCfg = AetherCurrentCompSetCfg:FindCfgByKey(MapID)
    if MapCfg then
        local Map2areaCfg = MapMap2areaCfg:FindCfgByKey(MapID)
        if Map2areaCfg then
            ValInVM.BannerPath = Map2areaCfg.ScreenImage
        end
        local PointListData = MapCfg.AetherCurrentPointList
        local QuestMarkDatas, InteractMarkDatas = self:CreateMarkListData(PointListData)
        ValInVM.QuestMarkDatas = QuestMarkDatas
        ValInVM.InteractMarkDatas = InteractMarkDatas
        ValInVM.bFinished = self:IsAetherCurrentsPointAllActived(PointListData)
    end
    return ValInVM
end

function AetherCurrentsMgr:MakeTheAllMapItems()
    local MapOpened = self.AetherCurrentsMapCfg
    if MapOpened == nil then
        FLOG_ERROR("AetherCurrentsMgr:OnNotifySyncAetherCurrentMainVM: MapOpened is nil")
        return
    end
    local ValInMainVM = {}
    for _, MapID in ipairs(MapOpened) do
        local RegionID = MapUtil.GetMapRegionID(MapID)
        if RegionID then
            local RegionInfo = ValInMainVM[RegionID] or {}
            local MainItemVM = self:CreateAetheCurrentMainItemVM(MapID)
            if MainItemVM then
                table.insert(RegionInfo, MainItemVM)
            end
            ValInMainVM[RegionID] = RegionInfo
        end
    end
    return ValInMainVM
end

function AetherCurrentsMgr:OnNotifySyncAetherCurrentMainVM()
    local ValInMainVM = self:MakeTheAllMapItems()
    AetherCurrentsVM:UpdateAllMapItems(ValInMainVM)
end

--- 显示记录完毕tips
function AetherCurrentsMgr:ShowCompMissionTip(MapID, bNoFlyTips)
    local bFinished = self:IsMapPointsAllActived(MapID) == MapAllPointActivateState.AllComp
    if bFinished then
        local UIMapID = MapUtil.GetUIMapID(MapID) or 0
        local MapName = MapUtil.GetMapName(UIMapID) or ""
        local TipsContent = string.format(LSTR(310014), MapName)

        local function ShowCanFlyTips()
            MsgTipsUtil.ShowAetherCurrentPanelTips(LSTR(310015))
            AudioUtil.LoadAndPlayUISound(CommonFloatTipsAudioPath)
            local MajorEntityID = MajorUtil.GetMajorEntityID()
            if MajorEntityID then
                AudioUtil.LoadAndPlaySoundEvent(MajorEntityID, PointActiveAudioPath, true)
            end
        end

        local function ShowTip()
            if not bNoFlyTips then
                MsgTipsUtil.ShowAetherCurrentPanelTips(TipsContent, AetherCurrentDefine.MissionTipShowDuration, MapName, true, false,
                ShowCanFlyTips)
            else
                MsgTipsUtil.ShowAetherCurrentPanelTips(TipsContent, AetherCurrentDefine.MissionTipShowDuration, MapName, true, false)
            end
           
            AudioUtil.LoadAndPlayUISound(CommonFloatTipsAudioPath)
        end
        _G.TimerMgr:AddTimer(self, ShowTip, AetherCurrentDefine.MissionTipShowDelayTime)
    end
end

--- 通知其他依赖模块(飞行),检测是否所有风脉点位解锁
function AetherCurrentsMgr:NotifyOtherModuleCheckAllActiveByMap(MapID, bUnlockByInteractive)
    -- 新手指南触发，不管是否全地图解锁都触发
    local GameEventParams = _G.EventMgr:GetEventParams()
    GameEventParams.Type = TutorialStartHandleType.AetherCurrent
    local AetherCurrentGuideID = 40 --风脉泉新手指南表格ID
    GameEventParams.Param1 = AetherCurrentGuideID
    _G.NewTutorialMgr:OnCheckTutorialStartCondition(GameEventParams)

    local bNeedNotifyMapActive
    if not bUnlockByInteractive then
        bNeedNotifyMapActive = MapAllPointActivateState.AllComp
    else
        bNeedNotifyMapActive = self:IsMapPointsAllActived(MapID)
    end

    if bNeedNotifyMapActive ~= MapAllPointActivateState.AllComp then
        return
    end

    if MapID then
        EventMgr:SendEvent(EventID.AetherCurrentMapFlyOpen, MapID) -- 仅在风脉泉解锁回复消息中发送此事件，重连不再处理 2024.12.23
    end

    if bUnlockByInteractive then -- 2025.4.12 道具解锁整张地图风脉泉不进行飞行引导 alexCY
        local function ShowBuoyAetherStageTutorial(Params)
            local EventParams = _G.EventMgr:GetEventParams()
            EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
            EventParams.Param1 = TutorialDefine.GameplayType.BuoyAether
            EventParams.Param2 = TutorialDefine.GamePlayStage.BuoyAetherFly
            _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
        end
    
        local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowBuoyAetherStageTutorial, Params = {}}
        _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
    end
end

--- 风脉泉解锁后通知其他依赖模块检查
function AetherCurrentsMgr:NotifyOtherModuleAetherCurrentPointActive(PointID)
    local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if PointCfg == nil then
        return
    end

    local MapID = PointCfg.MapID
    EventMgr:SendEvent(EventID.AetherCurrentSingleActive)
    self:NotifyOtherModuleCheckAllActiveByMap(MapID, true)
end

--- 显示当前地图解锁进度
function AetherCurrentsMgr:ShowProcessTips(MapID)
    local CurMapID = MapID
    if not CurMapID then
        return
    end
    local ActiveNum, TotalNum = self:GetTheMapPointUnlockProcess(CurMapID)
    if not TotalNum or not ActiveNum then
        return
    end

    --[[
    local TipsContent = 
    MsgTipsUtil.ShowAetherCurrentPanelTips(TipsContent, nil, LSTR("风脉泉解锁进度"), false, true)
    AudioUtil.LoadAndPlayUISound(CommonFloatTipsAudioPath)--]]
    local function JumpToAetherCurrentPanel()
        self:OpenAetherCurrentMainPanel(MapID)
    end
    local UIMapID = MapUtil.GetUIMapID(CurMapID) or 0
    local MapName = MapUtil.GetMapName(UIMapID) or ""
    LeftSidebarMgr:AppendPerform(LeftSidebarType.AetherCurrents, {
        Content = string.format("%s %s/%s", MapName, tostring(ActiveNum) or "0", tostring(TotalNum) or "0"),
        ClickCallback = JumpToAetherCurrentPanel,
    })
end

function AetherCurrentsMgr:OnNotifyNewAetherCurrentActived(PointID)
    local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if PointCfg == nil then
        FLOG_ERROR("AetherCurrentsMgr:OnNotifyNewAetherCurrentActived: PointCfg is nil")
        return
    end
    local MapID = PointCfg.MapID or 0
    local Type, MarkID = self:GetViewModelMarkIDByPointID(PointID)
    if Type == nil or MarkID == nil then
        FLOG_ERROR("AetherCurrentsMgr:OnNotifyNewAetherCurrentActived: GetViewModelMarkIDByPointID func error")
        return
    end

    local bFinished = self:IsMapPointsAllActived(MapID) == MapAllPointActivateState.AllComp

    local NewPointActived = {
        MapID = MapID,
        MarkID = MarkID,
        CurrentType = Type,
        bFinished = bFinished,
    }
    AetherCurrentsVM:AddNewActivedAetherCurrent(NewPointActived)
end

--- World加载EObj Actor时的判断依据
---@param EObjID number@EObj表格id
function AetherCurrentsMgr:CanCreateEObj(EObjID)
    local PointECfg = EObjCfg:FindCfgByKey(EObjID)
    if PointECfg == nil then
        FLOG_ERROR("AetherCurrentsMgr:CanCreateEObj: EObjDb do not have this data.")
        return false
    end

    local Param = PointECfg.Param
    if Param == nil or next(Param) == nil then
        return false
    end
    local PointID = Param[1]
    if PointID == nil then
        return false
    end

    --- 表格内未配置的风脉泉不再显示
    local bAetherCurrent = self.PointListsCfg[PointID]
    if not bAetherCurrent then
        return false
    end

    if not self:IsAetherCurrentSysOpen() then
        return false
    end

    return not self:IsPointActivedQuickCheck(PointID)
end

--- 播放风脉泉激活后特效与音效
function AetherCurrentsMgr:PlayPointActiveShowOnMajor()
    self:PlayEffectByPathWithCallBack(VfxEffectType.AllComplete)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID then
        AudioUtil.LoadAndPlaySoundEvent(MajorEntityID, PointActiveAudioPath, true)
    end
end

function AetherCurrentsMgr:BreakTheMajorActionTimeLineAtMapActive()
    local MontageItemActiveMap = self.MontageItemActiveMap
    if MontageItemActiveMap then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        local AnimInst = AnimationUtil.GetAnimInst(MajorEntityID)
        AnimationUtil.MontageStop(AnimInst, MontageItemActiveMap)
        self.MontageItemActiveMap = nil
    end
end

--- 播放道具激活地图风脉泉后的玩家表现
function AetherCurrentsMgr:PlayMapActiveShowOnMajor()
    self:PlayEffectByPathWithCallBack(VfxEffectType.OneTimeMapComplete)
    if self:IsMajorMoving() or _G.MountMgr:IsInRide() then
        self:PlayEffectByPathWithCallBack(VfxEffectType.UseItem1, function()
            self:PlayEffectByPathWithCallBack(VfxEffectType.UseItem2)
        end)
    else
        self:PlayItemEndATL()
    end
end

--- 解锁后tips显示
---@param MapID number @解锁风脉泉所属地图ID
function AetherCurrentsMgr:ShowTipsAfterPointUnlock(MapID)
    -- 风脉提示放入队列
    local UnlockTipsQueueShowTotalTime = 0

    local bNotAllPointActive = self:IsMapPointsAllActived(MapID) == MapAllPointActivateState.NotComp

    local function ShowSecondTips()
        local CurMapID = MapID
        if not CurMapID then
            return
        end

        self:UpdateSkillBtnVisibleState()

        if bNotAllPointActive then
            self:ShowProcessTips(CurMapID)
        else
            self:ShowCompMissionTip(CurMapID)
        end
    end

	local function ShowTipsCallback(_)
        local PointInteractSuccess = LSTR(310017)
        MsgTipsUtil.ShowAetherCurrentPanelTips(PointInteractSuccess, nil, nil, false, false, ShowSecondTips)
        AudioUtil.LoadAndPlayUISound(CommonFloatTipsAudioPath)
	end

    if bNotAllPointActive then
        UnlockTipsQueueShowTotalTime = AetherCurrentDefine.PanelTipsShowTime * 2
    else
        UnlockTipsQueueShowTotalTime = AetherCurrentDefine.PanelTipsShowTime + AetherCurrentDefine.MissionTipShowDuration + AetherCurrentDefine.MissionTipShowDelayTime + 2
    end

    if UnlockTipsQueueShowTotalTime == 0 then
        return
    end

    local Config = {Type = ProtoRes.tip_class_type.TIP_WIND_UNLOCK, Callback = ShowTipsCallback, Duration = UnlockTipsQueueShowTotalTime}
    _G.TipsQueueMgr:AddPendingShowTips(Config)
end

--- 单个解锁风脉泉成功显示在自身的特效
function AetherCurrentsMgr:UpdatePointActiveClientPerformance(PointID)
    self:PlayPointActiveShowOnMajor()
    local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if not PointCfg then
        return
    end
    local MapID = PointCfg.MapID
    if not MapID then
        return
    end
    if self:IsFirstActivateAetherCurrent() then
        self.bInNewPlayerGuiding = true
        self.PointActiveMapID = MapID
        self.bMapActiveByItem = false
    else
        self:ShowTipsAfterPointUnlock(MapID)
    end
end

--- 全地图解锁风脉泉表现
function AetherCurrentsMgr:UpdateMapActiveClientPerformance(MapID)
    self:PlayMapActiveShowOnMajor()
    if not MapID then
        return
    end
    if self:IsFirstActivateAetherCurrent() then
        self.bInNewPlayerGuiding = true
        self.PointActiveMapID = MapID
        self.bMapActiveByItem = true
    else
        local function ShowTipsCallback(_)
            self:ShowCompMissionTip(MapID, true)
        end
        local Duration =  AetherCurrentDefine.MissionTipShowDuration + AetherCurrentDefine.MissionTipShowDelayTime + 2
        local Config = {Type = ProtoRes.tip_class_type.TIP_WIND_UNLOCK, Callback = ShowTipsCallback, Duration = Duration}
        _G.TipsQueueMgr:AddPendingShowTips(Config)
    end
end

--- 任务完成，提示激活以太风流
function AetherCurrentsMgr:OnNotifyAetherCurrentQuestActivated(PointID)
    local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if PointCfg == nil then
        return
    end
    local PointType = PointCfg.CurrentType
    if PointType ~= WindPulseSpringActivateType.Task then
        return
    end
    AetherCurrentsVM.bShowTemporaryBtn = true
    self:UpdatePointActiveClientPerformance(PointID)
end

--- 交互成功，隐藏World中的EObj实体
function AetherCurrentsMgr:OnNotifyEobjAetherCurrentLeaveVision(PointID)
    local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if PointCfg == nil then
        return
    end
    local PointType = PointCfg.CurrentType
    if PointType ~= WindPulseSpringActivateType.Interact then
        return
    end
    local MapEditorID = PointCfg.ListID
    if MapEditorID == nil then
        return
    end
  
    local EntityID = self.PointID2EntityIDInVision[PointID]
    if not EntityID then
        return
    end
    local EObjActor = ActorUtil.GetActorByEntityID(EntityID)
    if not EObjActor then
        return
    end

    EObjActor:SetSharedGroupVisible(false, true)
    AetherCurrentsVM.bShowTemporaryBtn = true
    self:RegisterTimer(function()
        ClientVisionMgr:ClientActorLeaveVision(MapEditorID, _G.MapEditorActorConfig.EObj.ActorType)
        FLOG_INFO("AetherCurrentLeaveVision:ClientActorLeave %s", tostring(TimeUtil.GetServerTimeMS()))
        _G.InteractiveMgr:SetShowMainPanelEnabled(true)
        _G.InteractiveMgr:ShowInteractiveEntrance()-- 2025.4.23 交互界面被隐藏需要手动打开
    end, 2)
end

--- 统一CD获取方式(由道具表获取)
function AetherCurrentsMgr:GetTheItemCD()
    local DefaultCD = AetherCurrentDefine.BaseSearchCD
    local Cfg = ItemCfg:FindCfgByKey(AetherCurrentItemID)
    if not Cfg then
        return DefaultCD
    end

    local ItemFreezeTime = Cfg.FreezeTime or 0
    return ItemFreezeTime > 0 and ItemFreezeTime or DefaultCD
end

--技能交互CDUpdate
function AetherCurrentsMgr:OnSkillCDUpdate()
	local CurrentCD = self.CurrentCD
	local BaseCD = self:GetTheItemCD()

	if CurrentCD <= 0 then
		AetherCurrentsVM:UpdateSearchSkillCD("", 0)
		self:EndSkillCDCount()
	else
		local CDPercent = 1 - CurrentCD / BaseCD
		if CDPercent < 0 then CDPercent = 0 end
        local TextCDContent = string.format("%ds", math.ceil(CurrentCD))
        AetherCurrentsVM:UpdateSearchSkillCD(TextCDContent, CDPercent)
	end
	self.CurrentCD = CurrentCD - AetherCurrentDefine.SkillCDUpdateInterval

end

function AetherCurrentsMgr:EndSkillCDCount()
	local TimerHandle = self.SkillTimerHandle
	if TimerHandle ~= nil then
		_G.TimerMgr:CancelTimer(TimerHandle)
		self.SkillTimerHandle = nil
		self.CurrentCD = 0
        AetherCurrentsVM:SetSkillCDPanelVisible(false)
	end
end

function AetherCurrentsMgr:StartSkillCDCount()
    local InitCD = self:GetTheItemCD()
	self.CurrentCD = InitCD
	if self.SkillTimerHandle ~= nil then
		FLOG_ERROR("AetherCurrentsMgr:StartSkillCDCount: Add Timer Error")
		return
	end
    AetherCurrentsVM:SetSkillCDPanelVisible(true)
    if UIViewMgr:IsViewVisible(UIViewID.BagMain) then -- 背包打开的情况下更新背包cd
        self:SyncBagItemCD(InitCD)
    end
	self.SkillTimerHandle = _G.TimerMgr:AddTimer(self, self.OnSkillCDUpdate, 0, AetherCurrentDefine.SkillCDUpdateInterval, 0)
end

function AetherCurrentsMgr:SyncBagItemCD(RemainCD)
    local CurSeverTime = TimeUtil.GetServerTime()
    local EndTime = CurSeverTime + RemainCD
    BagMgr:UpdateFreezeCDTableDateAndStartTimer(self.CfgGroupID, EndTime, self.CfgFreezeCD)
end

function AetherCurrentsMgr:SyncBagItemCDWhenOpenPanel()
    local RemainCD = self.CurrentCD
    if not RemainCD or RemainCD <= 0 then
        return
    end
    local CurSeverTime = TimeUtil.GetServerTime()
    local EndTime = CurSeverTime + RemainCD
    BagMgr:UpdateFreezeCDTableDateAndStartTimer(self.CfgGroupID, EndTime, self.CfgFreezeCD)
end

--- 计算风脉点的方位信息（距离和角度）
---@param PointID number@风脉泉id
---@return number, number @距离， 角度
function AetherCurrentsMgr:CalculatePointDistanceAndAngle(PointID)
    local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if not PointCfg then
        return
    end

    if PointCfg.CurrentType ~= WindPulseSpringActivateType.Interact then
        return
    end
    local bActived = self:IsPointActivedQuickCheck(PointID)
    if bActived then
       return
    end

    local MapEditorID = PointCfg.ListID
    if not MapEditorID then
        return
    end
    local EObjData = MapEditDataMgr:GetEObjByListID(MapEditorID)
    if EObjData then
        local Point = EObjData.Point
        local MajorActor = MajorUtil.GetMajor()
        if MajorActor then
            local MajorPos = MajorActor:FGetActorLocation()
            --FLOG_INFO("AetherCurrentsMgr:GetTheClosestAetherCurrentInfo MajorActor Pos: %f, %f", MajorPos.X, MajorPos.Y)
            local Xlen = Point.X - MajorPos.X
            local Ylen = MajorPos.Y - Point.Y
            return math.sqrt(Xlen * Xlen + Ylen * Ylen), MathUtil.GetAngle(Xlen, Ylen)
        end
    end
end

--- 生成指示方向文本
---@param AngleDeg number@目标角度
---@return String
function AetherCurrentsMgr:MakeTheDirContent(AngleDeg)
    local CalDeg = AngleDeg
    if CalDeg < OffsetDir then
        CalDeg = AngleDeg + 360
    end
    local DegMinus = CalDeg - OffsetDir
    local DirContentIndex = math.floor(DegMinus / (360 / 8)) + 1
    return AetherCurrentDefine.EightDirectContent[DirContentIndex] or ""
end

--- 获取最近的交互类风脉泉信息
---@return number @PointID
function AetherCurrentsMgr:GetTheClosestAetherCurrentPointID()
    local CurMapID = PWorldMgr:GetCurrMapResID()
    local MapCompCfg = AetherCurrentCompSetCfg:FindCfgByKey(CurMapID)
    if MapCompCfg == nil then
        return
    end

    local PointList = MapCompCfg.AetherCurrentPointList
    if PointList == nil or next(PointList) == nil then
        return
    end

    local MinDis = -1
    local TargetPoint
    for _, PointID in ipairs(PointList) do
        local Dis, _ = self:CalculatePointDistanceAndAngle(PointID)
        if Dis then
            if MinDis == -1 or Dis <= MinDis then
                MinDis = Dis
                TargetPoint = PointID
            end
        end
    end
    return TargetPoint
end

--- 使用风脉仪探测
---@return boolean @风脉仪是否进入CD
function AetherCurrentsMgr:UseSearchMachine()
    local bInCD = false
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if not MajorEntityID then
        FLOG_ERROR("AetherCurrentsMgr:UseSearchMachine Major EntityID is Wrong")
        return
    end
   
    -- 引导状态无法使用
    if SingBarMgr:GetMajorIsSinging() then
        MsgTipsUtil.ShowTips(LSTR(310029))
        return bInCD
    end

    -- 技能读条无法使用
    if SkillSingEffectMgr:IsSinging(MajorEntityID) or MajorUtil.IsUsingSkill() then
        MsgTipsUtil.ShowTips(LSTR(310018))
        return bInCD
    end

    -- 死亡状态无法使用
    if MajorUtil.IsMajorDead() then
        MsgTipsUtil.ShowTips(LSTR(310019))
        return bInCD
    end

    local TimerHandle = self.SkillTimerHandle
    if TimerHandle ~= nil then
        MsgTipsUtil.ShowTips(LSTR(310020))
        return bInCD
    end
    local CurMapID = PWorldMgr:GetCurrMapResID()
    local ActivateState = self:IsMapInteractPointsAllActived(CurMapID)
    local AllPointActivateState = self:IsMapPointsAllActived(CurMapID)
    if AllPointActivateState == MapAllPointActivateState.NotComp and ActivateState == MapAllPointActivateState.AllComp then
        local TipsContent = (LSTR(310021))
        MsgTipsUtil.ShowTips(TipsContent)
        return bInCD
    end

    local UIMapID = MapUtil.GetUIMapID(CurMapID) or 0
    local MapName = MapUtil.GetMapName(UIMapID) or ""
    if ActivateState == MapAllPointActivateState.InvalidMap then
        local TipsContent = (LSTR(310022))
        MsgTipsUtil.ShowTips(TipsContent)
        return bInCD
    elseif ActivateState == MapAllPointActivateState.AllComp then
        local TipsContent = string.format(LSTR(310023), MapName)
        MsgTipsUtil.ShowTips(TipsContent)
        return bInCD
    end

    self:StartSkillCDCount()
    bInCD = true

    self:CheckMapActiveItemUseCondByBagFunc()
    if self.bMapActiveUseSecondPanelShow then
        return
    end
  
    if MajorEntityID then
        --AudioUtil.LoadAndPlaySoundEvent(MajorEntityID, UseSearchMachineAudioPath, true) 2025.4.14 音效已接入到对应动画上
    end

    if self:IsMajorMoving() or _G.MountMgr:IsInRide() then
        self:PlayEffectByPathWithCallBack(VfxEffectType.UseItem1, function()
            self:PlayEffectByPathWithCallBack(VfxEffectType.UseItem2)
        end)
    else
        self:PlayItemEndATL()
    end
    self:UpdateDetectFeedBackView() -- 2024.8.28 调整风脉仪反馈时间到动画播放开始阶段
    return bInCD
end

function AetherCurrentsMgr:PlayItemEndATL()
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID then
        local MajorShowID = 85
        local ActionCfg = ActiontimelinePathCfg:FindCfgByKey(MajorShowID)
        self.MontageUseSearchMachine = AnimMgr:PlayActionTimeLine(MajorEntityID, ActionCfg.Filename)
    end
end

--- 根据距离计算当前探测阶段
---@param Distance number @距离值(米)
function AetherCurrentsMgr:CalculateDetectRangeStage(Distance)
    if not Distance then
        return
    end
    local RangeList = MachineDetectRange
    if not RangeList then
        return
    end

    -- 2024.8.28 alexCY 策划需求首次解锁探测区间上限减半
    local ServerPointInfos = self.AetherCurrentsServerInfos
    local FirstActive = not ServerPointInfos or not next(ServerPointInfos)

    return self:CalculateDetectRangeStageInternal(Distance, false), 
        self:CalculateDetectRangeStageInternal(Distance, FirstActive)
end


--- 2024.8.28 alexCY 策划需求首次解锁风脉仪文本显示以及探测反馈tips探测区间上限减半（动效音效显示维持原状）
---@param Distance number @距离值(米)
function AetherCurrentsMgr:CalculateDetectRangeStageInternal(Distance, bFirst)
    if not Distance then
        return
    end
    local RangeList = MachineDetectRange
    if not RangeList then
        return
    end

    local RangeIndex
    for Index, RangeLimit in ipairs(RangeList) do
        local CompareLimit = bFirst and RangeLimit / 2 or RangeLimit
        if Distance <= CompareLimit then
            RangeIndex = Index
            break
        end
    end

    if not RangeIndex then
        return #RangeList + 1
    else
        return RangeIndex
    end
end

--- 清除当前浮标显示
function AetherCurrentsMgr:ClearAetherCurrentBuoy()
    local BuoyUID = self.BuoyUID
    if BuoyUID then
        BuoyMgr:RemoveBuoyByUID(BuoyUID)
        local TimeHandle = self.BuoyTimeHandle
        if TimeHandle then
            self:UnRegisterTimer(TimeHandle)
            self.BuoyTimeHandle = nil
        end
        self.BuoyUID = nil
    end
end

--- 在tick中更新浮标的可视状态
---@param RangeIndex number@范围所属阶段
function AetherCurrentsMgr:SetBuoyInvisibleInTick(RangeIndex)
    local FeedBackDef = MachineDetectDef[RangeIndex]
    if not FeedBackDef then
        return
    end

    local bShowBuoy = FeedBackDef.bShowBuoy
    if not bShowBuoy then
        self:ClearAetherCurrentBuoy()
    end
end

-- 距离变化显示不同浮标
---@param RangeIndex number@范围所属阶段
---@param PointID number@风脉泉配表唯一id
function AetherCurrentsMgr:ShowBuoyByRangeStage(RangeIndex, PointID)
    self:ClearAetherCurrentBuoy()
    local FeedBackDef = MachineDetectDef[RangeIndex]
    if not FeedBackDef then
        return
    end

    local bShowBuoy = FeedBackDef.bShowBuoy
    if not bShowBuoy then
        return
    end

    local ExistTime = FeedBackDef.bNormalBuoyExistTime
    if not ExistTime then
        return
    end

    FLOG_INFO("AetherCurrentsMgr:ShowBuoyByRangeStage: CreateBuoy RangeIndex:%d, PointID:%d, bShowBuoy:%s", RangeIndex, PointID, tostring(bShowBuoy))
    local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if not PointCfg then
        return
    end

    if PointCfg.CurrentType ~= WindPulseSpringActivateType.Interact then
        return
    end

    local bActived = self:IsPointActivedQuickCheck(PointID)
    if bActived then
        return
    end

    local MapEditorID = PointCfg.ListID
    if not MapEditorID then
        return
    end
    local EObjData = MapEditDataMgr:GetEObjByListID(MapEditorID)
    if not EObjData then
        return
    end
    local EobjResID = EObjData.ResID
    if not EobjResID then
        return
    end

    if not self.BuoyUID then
        local _, BuoyUID = BuoyMgr:AddBuoyByEObjID(EobjResID, PointCfg.MapID, HUDType.BuoyAetherCurrent)
        self.BuoyUID = BuoyUID

        if self.BuoyTimeHandle then
            self:UnRegisterTimer(self.BuoyTimeHandle)
            self.BuoyTimeHandle = nil
        end
        self.BuoyTimeHandle = self:RegisterTimer(function()
            self:ClearAetherCurrentBuoy()
        end, ExistTime, 0, 1)
    end
end

--- 距离变化显示不同tips
---@param RangeIndex number @探测范围阶段
---@param Dis number @距离值（厘米）
---@param Angle number @角度（角度）
function AetherCurrentsMgr:ShowTipsByRangeStage(RangeIndex, Dis, Angle)
    local FeedBackDef = MachineDetectDef[RangeIndex]
    if not FeedBackDef then
        return
    end
    -- tips显示
    local TipsContent = ""
    if FeedBackDef.bFormatReplace then
        local DisContent = tostring(math.floor(Dis / 100))
        local DirContent = self:MakeTheDirContent(Angle)
        TipsContent = string.format(FeedBackDef.FormatContent, DirContent, DisContent)
    else
        TipsContent = FeedBackDef.FormatContent
    end

    MsgTipsUtil.ShowTips(TipsContent, FeedBackDef.TipsExistTime)
end

--- 在tick中更新技能面板距离显示文本的可视状态
---@param RangeIndex number@范围所属阶段
function AetherCurrentsMgr:SetSkillPanelDisContentInvisibleInTick(RangeIndex)
    local SkillVM = AetherCurrentsVM.SkillPanelVM
    if not SkillVM then
        return
    end

    local FeedBackDef = MachineDetectDef[RangeIndex]
    if not FeedBackDef then
        return
    end

    local bShowSkillPanelDisContent = FeedBackDef.bShowSkillPanelDisContent
    if not bShowSkillPanelDisContent then
        if self.SkillPanelDisTimeHandle then
            self:UnRegisterTimer(self.SkillPanelDisTimeHandle)
            self.SkillPanelDisTimeHandle = nil
        end
        SkillVM.bShowSkillPanelDisContent = false
    end
end

--- 风脉仪面板距离显示文本
---@param RangeIndex number @探测范围阶段
function AetherCurrentsMgr:ShowSkillPanelDisContentByRangeStage(RangeIndex)
    local SkillVM = AetherCurrentsVM.SkillPanelVM
    if not SkillVM then
        return
    end

    local FeedBackDef = MachineDetectDef[RangeIndex]
    if not FeedBackDef then
        return
    end

    local SkillPanelDisContentExistTime = FeedBackDef.SkillPanelDisContentExistTime
    if not SkillPanelDisContentExistTime then
        return
    end

    SkillVM.bShowSkillPanelDisContent = true
    if self.SkillPanelDisTimeHandle then
        self:UnRegisterTimer(self.SkillPanelDisTimeHandle)
    end
    self.SkillPanelDisTimeHandle = self:RegisterTimer(function()
        SkillVM.bShowSkillPanelDisContent = false
    end, SkillPanelDisContentExistTime, 0, 1)

end

--- 刷新探测反馈表现
function AetherCurrentsMgr:UpdateDetectFeedBackView()
    local Dis = self.CurClosestPointDis
    local Angle = self.CurClosestPointDir
    if not Dis or not Angle then
        FLOG_ERROR("AetherCurrentsMgr:UpdateDetectFeedBackView: ClosestPoint Not Valid")
        return
    end

    --local Dis, Angle = self:CalculatePointDistanceAndAngle(ClosestPoint)
    local _, TextRangeIndex = self:CalculateDetectRangeStage(Dis / 100)
    if not TextRangeIndex then
        return
    end
  
    self:ShowTipsByRangeStage(TextRangeIndex, Dis, Angle)
    --self:ShowBuoyByRangeStage(FeedBackStage, ClosestPoint)
    self:ShowSkillPanelDisContentByRangeStage(TextRangeIndex)
end

--- 根据MapID获取已激活的风脉泉信息
function AetherCurrentsMgr:GetAetherCurrentActivedByMapID(MapID)
    local SevCurrentInfo = self.AetherCurrentsServerInfos
    if SevCurrentInfo == nil or next(SevCurrentInfo) == nil then
        return
    end
    local RegionID = MapUtil.GetMapRegionID(MapID)
    if not RegionID then
        return
    end
    local SevInfoUnderVer = SevCurrentInfo[RegionID]
    if SevInfoUnderVer == nil or next(SevInfoUnderVer) == nil then
        return
    end
    local SevInfoUnderMap = SevInfoUnderVer[MapID]
    if SevInfoUnderMap == nil or next(SevInfoUnderMap) == nil then
        return
    end
    return SevInfoUnderMap
end

--- 根据UIMapID获取已激活的风脉泉Marker所需数据
---@param UIMapID number@UIMap表id
function AetherCurrentsMgr:CreateMarkersDataSource(UIMapID)
    local SrcResult = {}
    local MapID = MapUtil.GetMapID(UIMapID)
    if MapID and type(MapID) == "number" then
        local ActivedPointInMap = self:GetAetherCurrentActivedByMapID(MapID)
        if ActivedPointInMap and next(ActivedPointInMap) then
            for PointID, value in pairs(ActivedPointInMap) do
                local CurrentType = value.CurrentType
                local MarkID
                if CurrentType == WindPulseSpringActivateType.Interact then
                    MarkID = value.MarkID
                    table.insert(SrcResult,
                    {
                        MarkID = MarkID,
                        PointContent = {
                            {
                                PointID = PointID,
                                bWaitForPlayEffect = self:IsPointNeedHideInViewModelOnMapContent(PointID),
                            },
                        },

                        PointLocation = self:GetPosInfoFromMapEditCfg(PointID, MapID),
                        IconPath = MarkerIconPath.Interact,
                    })
                elseif CurrentType == WindPulseSpringActivateType.Task then -- 2024.8.27 alexCY P4优化取消任务型风脉泉的地图显示
                    --[[MarkID = value.QuestID
                    local Pos = value.Pos
                    if Pos then
                        local ExistedSrcData = table.find_by_predicate(SrcResult, function(e)
                            return e.PointLocation and
                                e.PointLocation.X == Pos.X and e.PointLocation.Y == Pos.Y
                        end)
                        if ExistedSrcData ~= nil then
                            local PointList = ExistedSrcData.PointContent
                            table.insert(PointList,  {
                                PointID = PointID,
                                bWaitForPlayEffect = self:IsPointNeedHideInViewModelOnMapContent(PointID),
                            })
                        else
                            table.insert(SrcResult,
                            {
                                MarkID = MarkID,
                                PointContent = {
                                    {
                                        PointID = PointID,
                                        bWaitForPlayEffect = self:IsPointNeedHideInViewModelOnMapContent(PointID),
                                    },
                                },
                                PointLocation = Pos,
                                IconPath = MarkerIconPath.Task,
                            })
                        end
                    end--]]
                end
            end
            return SrcResult
        end
        MapEditDataMgr:ClearOtherMapEditCfgByMapID(MapID)
    end
end

--- 此风脉泉是否需要在VM层隐藏激活状态（for 播放激活动效）
function AetherCurrentsMgr:IsPointNeedHideInViewModel(PointID)
    local CacheList = self.CachePointIDToShowWhenOpen
    if CacheList == nil or next(CacheList) == nil then
        return false
    end

    for _, value in ipairs(CacheList) do
        if value == PointID then
           return true
        end
    end
    return false
end

--- 此风脉泉是否需要在VM层隐藏激活状态在地图上（for 播放激活动效）
function AetherCurrentsMgr:IsPointNeedHideInViewModelOnMapContent(PointID)
    local CacheList = self.CachePointIDToShowInMap
    if CacheList == nil or next(CacheList) == nil then
        return false
    end

    for _, value in ipairs(CacheList) do
        if value == PointID then
           return true
        end
    end
    return false
end

--- 播放风脉泉特效Vfx接口调用
function AetherCurrentsMgr:PlayEffectByPath(EffectPath, CasterOrTarget)
    local VfxParameter = _G.UE.FVfxParameter()
    local Major = MajorUtil.GetMajor()
    VfxParameter.VfxRequireData.EffectPath = EffectPath
    VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_AetherCurrents
    local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
    if CasterOrTarget then
        VfxParameter:SetCaster(Major, 0, AttachPointType_Body, 0)
    else
        VfxParameter:AddTarget(Major, 0, AttachPointType_Body, 0)
    end

    return EffectUtil.PlayVfx(VfxParameter)
end

--- 播放风脉泉特效Vfx接口调用
function AetherCurrentsMgr:PlayEffectByID(VfxResID, CasterOrTarget)
    return EffectUtil.PlayVfxByCommonID(VfxResID, _G.UE.EVFXPlaySourceType.PlaySourceType_AetherCurrents,
    CasterOrTarget, _G.UE.EVFXAttachPointType.AttachPointType_Body)
end

--- 播放主角激活风脉泉特效
function AetherCurrentsMgr:PlayEffectByPathWithCallBack(DefineVfxKey, CallBack, bOnlyTimer)
    local Define = VfxEffectPath[DefineVfxKey]
    if not Define then
        return
    end

    local InstID
    local EffectID = Define.ID
    if EffectID then
        InstID = self:PlayEffectByID(EffectID, Define.CasterOrTarget)
    else
        local EffectPath = Define.Path
        if not EffectPath then
            return
        end
        InstID = self:PlayEffectByPath(EffectPath, Define.CasterOrTarget)
    end

    local CallBackDelayTime = Define.Time or 0
    if CallBackDelayTime <= 0 then
        return InstID
    end

    if not CallBack then
        return InstID
    end

    self:RegisterTimer(function()
        CallBack(InstID)
    end, CallBackDelayTime)
    --self:AddEffectDelayCallBackTimer(DefineVfxKey, TimerID, bOnlyTimer)
    return InstID
end

--- 查找按地域排序的第一个地图
function AetherCurrentsMgr:GetTheFirstMapIDInRegionOrder()
    local AllItems = self:MakeTheAllMapItems()
    if not AllItems or next(AllItems) == nil then
        return
    end
    local RegionList = table.indices(AllItems)
    if not RegionList then
        return
    end

	table.sort(RegionList, AetherCurrentDefine.SortRegion)
    
    local RegionID = RegionList[1]
    if not RegionID then
       return
    end

    local FirstRegionData = AllItems[RegionID]
    if not FirstRegionData then
        return
    end

    local FirstMapData = FirstRegionData[1]
    if not FirstMapData then
        return
    end
    
    return FirstMapData.MapID
end

------ 道具解锁整个地图风脉 ------
function AetherCurrentsMgr:NotifyTriggerTheTutorial()
    local function OnTutorial()
        --发送新手引导触发靠近风脉泉
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.NearTargetField --新手引导触发类型
        EventParams.Param1 = TutorialDefine.NearTargetFieldType.AetherCurrent
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end


--- 点击风脉仪操作弹出二次确认提醒框
---@param bInSearchMachine boolean @是否从使用风脉仪处打开
function AetherCurrentsMgr:ShowSecondConfirmPanel(bInSearchMachine)
    local bInNewGuid = self.bInNewPlayerGuiding
    if bInNewGuid then
        return
    end
    
    local ItemNum = BagMgr:GetItemNum(MapActiveItemID)
    if ItemNum <= 0 then
        return
    end
    --[[if bInSearchMachine and not NewTutorialMgr:IsGroupComplete(TutorialGroupID) then
        return
    end--]]

    local CommItem = ItemUtil.CreateItem(MapActiveItemID)
    CommItem.NumText = string.format("%d/%d", ItemNum, 1)

    if bInSearchMachine then
        UIViewMgr:ShowView(UIViewID.BagItemActionTips, {
            Title = LSTR(310030), Message = LSTR(310031), Item = CommItem, ClickedOkAction = self.ConfirmToUse,
            ClickedOkListener = self, ClickedCancelAction = self.CancelUse, ClickedCancelListener = self, SingleBoxVisible = true, SingleBoxText = LSTR(310032),
            SingleBoxCheckedListener = self, SingleBoxCheckedFunc = self.SetCurMapNotShowPanelState
        })
        self.bMapActiveUseSecondPanelShow = true
    else
        UIViewMgr:ShowView(UIViewID.BagItemActionTips, {
            Title = LSTR(310030), Message = LSTR(310031), Item = CommItem, ClickedOkAction = self.ConfirmToUse,
            ClickedOkListener = self, ClickedCancelAction = self.CancelUse, ClickedCancelListener = self, SingleBoxVisible = false,
        })
    end
end

function AetherCurrentsMgr:ConfirmToUse()
    local ItemGID = BagMgr:GetItemGIDByResID(MapActiveItemID)
    if not ItemGID then
        FLOG_ERROR("AetherCurrentsMgr:ConfirmToUse Can not Find the GID")
        return
    end
    BagMgr:SendMsgUseItemReq(ItemGID, 1, FuncType.WindPulseMapActive)
    if UIViewMgr:IsViewVisible(UIViewID.BagMain) then
        UIViewMgr:HideView(UIViewID.BagMain)
    end
    self.bMapActiveUseSecondPanelShow = false
end

function AetherCurrentsMgr:CancelUse()
    if not self.bMapActiveUseSecondPanelShow then
        return -- 非从风脉仪进入不显示后续提示
    end
    local ShowFeedBackDelayTime = 1
    self:RegisterTimer(function()
        self:UpdateDetectFeedBackView()
    end, ShowFeedBackDelayTime)
    self.bMapActiveUseSecondPanelShow = false
end

function AetherCurrentsMgr:CheckMapActiveItemUseCondByBagFunc()
    local ItemGID = BagMgr:GetItemGIDByResID(MapActiveItemID)
    if not ItemGID then
        FLOG_ERROR("AetherCurrentsMgr:CheckMapActiveItemUseCondByBagFunc Can not Find the GID")
        return
    end
    if not self:IsTheSecondPanelCanShowBySingleBox() then
        return
    end
    BagMgr:UseItem(ItemGID, {bInSearchMachine = true})
end

function AetherCurrentsMgr:IsTheSecondPanelCanShowBySingleBox()
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        return
    end
    local ShowSecondPanelMapCheck = self.ShowSecondPanelMapCheck
    if not ShowSecondPanelMapCheck or not next(ShowSecondPanelMapCheck) then
        return true
    end
    local bNotShow = ShowSecondPanelMapCheck[CurMapID]
    return not bNotShow
end

function AetherCurrentsMgr:SetCurMapNotShowPanelState(bTrue)
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        return
    end

    if bTrue then
        local ShowSecondPanelMapCheck = self.ShowSecondPanelMapCheck or {}
        ShowSecondPanelMapCheck[CurMapID] = true
        self.ShowSecondPanelMapCheck = ShowSecondPanelMapCheck
    else
        local ShowSecondPanelMapCheck = self.ShowSecondPanelMapCheck
        if not ShowSecondPanelMapCheck or not next(ShowSecondPanelMapCheck) then
            return
        end
        ShowSecondPanelMapCheck[CurMapID] = nil
    end
end

function AetherCurrentsMgr:CancelTheBlockToShowSecondPanel()
    local CurMapResID = PWorldMgr:GetCurrMapResID()
    local LastMapResID = PWorldMgr:GetLastMapResID()
  
    local ShowSecondPanelMapCheck = self.ShowSecondPanelMapCheck
    if not ShowSecondPanelMapCheck or not next(ShowSecondPanelMapCheck) then
        return
    end
    ShowSecondPanelMapCheck[LastMapResID] = nil
    ShowSecondPanelMapCheck[CurMapResID] = nil
end

------ 道具解锁整个地图风脉 END ------

-- ==================================================
-- 外部接口
-- ==================================================
--- 判断是否首次激活风脉泉
function AetherCurrentsMgr:IsFirstActivateAetherCurrent()
    local SevInfos = self.AetherCurrentsServerInfos
    return not SevInfos or not next(SevInfos)
end

--- 判断当前所在地图是否可以飞行
function AetherCurrentsMgr:IsCurMapCanFlyLimitByAetherCurrent()
    local MapID = PWorldMgr:GetCurrMapResID()
    local ActiveState = self:IsMapPointsAllActived(MapID)
    return ActiveState ~= MapAllPointActivateState.NotComp
end

--- 根据MapID判断当前地图风脉泉是否全部开启
---@param MapID number@地图id
function AetherCurrentsMgr:IsMapPointsAllActived(MapID)
    local ResultState = MapAllPointActivateState.InvalidMap
    local MapComCfg = AetherCurrentCompSetCfg:FindCfgByKey(MapID)
    if MapComCfg == nil then
        --FLOG_INFO("AetherCurrentCompSetCfg do not have the MapID")
        return ResultState
    end
    local PointList = MapComCfg.AetherCurrentPointList
    if self:IsAetherCurrentsPointAllActived(PointList) then
        ResultState = MapAllPointActivateState.AllComp
    else
        ResultState = MapAllPointActivateState.NotComp
    end
    return ResultState
end

--- 根据MapID判断当前地图交互类风脉泉是否全部开启
---@param MapID number@地图id
function AetherCurrentsMgr:IsMapInteractPointsAllActived(MapID)
    local ResultState = MapAllPointActivateState.InvalidMap
    local MapComCfg = AetherCurrentCompSetCfg:FindCfgByKey(MapID)
    if MapComCfg == nil then
        --FLOG_ERROR("AetherCurrentCompSetCfg do not have the MapID")
        return ResultState
    end
    local AllPointList = MapComCfg.AetherCurrentPointList
    local PointList = {}
    for _, PointID in ipairs(AllPointList) do
        local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
        if PointCfg then
            if PointCfg.CurrentType == WindPulseSpringActivateType.Interact then
                table.insert(PointList, PointID)
            end
        end
    end

    if not next(PointList) then
        return ResultState -- 地图内没有交互类风脉泉
    end

    if self:IsAetherCurrentsPointAllActived(PointList) then
        ResultState = MapAllPointActivateState.AllComp
    else
        ResultState = MapAllPointActivateState.NotComp
    end
    return ResultState
end

--- 使用风脉仪打开风脉仪技能界面
function AetherCurrentsMgr:UseAetherCurrentSearchMachine()
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        FLOG_ERROR("AetherCurrentsMgr:UseAetherCurrentSearchMachine: CurMapID is not valid")
        return
    end
    local bHavePointToActive = self:IsMapInteractPointsAllActived(CurMapID) == MapAllPointActivateState.NotComp
    if bHavePointToActive then
        AetherCurrentsVM.bShowAetherCurrentSearchSkill = true
    else
        MsgTipsUtil.ShowTips(LSTR(310024))
    end
end

--- 计算当前地图风脉的解锁进度
---@param MapID number @地图id
---@return number, number @激活点的数量，总的数量
function AetherCurrentsMgr:GetTheMapPointUnlockProcess(MapID)
    local MapComCfg = AetherCurrentCompSetCfg:FindCfgByKey(MapID)
    if not MapComCfg then
        return
    end

    local PointList = MapComCfg.AetherCurrentPointList
    if not PointList or next(PointList) == nil then
        return
    end

    local ActivedNum = 0
    for _, PointID in ipairs(PointList) do
        if self:IsPointActivedQuickCheck(PointID) then
            ActivedNum = ActivedNum + 1
        end
    end
    return ActivedNum, #PointList
end

--- 刷新主界面风脉仪探索按钮的可视状态
function AetherCurrentsMgr:UpdateSkillBtnVisibleState()
    local SkillVM = AetherCurrentsVM.SkillPanelVM
    if SkillVM == nil then
        return
    end
    if not self:IsAetherCurrentSysOpen() then
        SkillVM:SetPanelSkillBtnVisible(false)
        return
    end
    local CurMapID = PWorldMgr:GetCurrMapResID()
	if CurMapID then
        SkillVM:SetPanelSkillBtnVisible(self:IsMapPointsAllActived(CurMapID) == MapAllPointActivateState.NotComp) -- 2024.8.28 所有风脉泉完成激活才隐藏按钮
	else
		SkillVM:SetPanelSkillBtnVisible(false)
	end
end

function AetherCurrentsMgr:GetPointRegionID(PointID)
    local AeCurCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if AeCurCfg == nil then
        -- body
        FLOG_ERROR("AetherCurrentsMgr:AddNewActivedAetherCurrent: AetherCurrentCfg can not find the data. ID:%d", PointID)
        return
    end
    local SevInfo = self.AetherCurrentsServerInfos
    if SevInfo == nil then
        -- body
        FLOG_ERROR("AetherCurrentsMgr:AddNewActivedAetherCurrent: AetherCurrentsServerInfos is nil")
        return
    end

    local MapID = AeCurCfg.MapID
    if not MapID then
        FLOG_ERROR("AetherCurrentsMgr:AddNewActivedAetherCurrent: MapID is nil")
        return
    end

    local RegionID = MapUtil.GetMapRegionID(MapID)
    return RegionID
end

--- 风脉系统是否开启
function AetherCurrentsMgr:IsAetherCurrentSysOpen()
    return ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDAetherCurrent)
end

--- 通用模块简单地图切换地图接口
function AetherCurrentsMgr:ChangeMap(UIMapID)
    local Cfg = MapUICfg:FindCfgByKey(UIMapID)
    if not Cfg then
        return
    end

    local MapID = Cfg.MapID or 0
    ModuleMapContentVM:ChangeUIMap(UIMapID)

    --edit by sammrli: pull fog data 大于0的MapID才是有效值
    if MapID > 0 then
        if not _G.FogMgr:IsFlagInit(MapID) then
            _G.FogMgr:SendGetMapFogInfo({MapID})
            self:AddMapIDNeedUpdateFog(MapID)
        end
    end
end

function AetherCurrentsMgr:AddMapIDNeedUpdateFog(MapID)
    local FogMapIDs = self.MapIDWaitForUpdateFog or {}
    table.insert(FogMapIDs, MapID)
    self.MapIDWaitForUpdateFog = FogMapIDs
end

--- 是否为任务型风脉泉道具
---@param ItemResID number@道具资源ID
function AetherCurrentsMgr:IsTaskAetherCurrentItem(ItemResID)
    local ItemID2PointID = self.ItemID2PointID
    if not ItemID2PointID or not next(ItemID2PointID) then
        return
    end

    return ItemID2PointID[ItemResID] ~= nil
end

--- BagMgr使用，是否可以快捷使用的判定
---@param FindItemCfg ItemCfg@物品表单行配表数据结构
---@param ItemGID number@物品服务器生成唯一ID
function AetherCurrentsMgr:IsCanShowEasyUse(FindItemCfg, ItemGID)
    if not FindItemCfg then
        return
    end

    local ItemID = FindItemCfg.ItemID
    if not ItemID then
        return
    end

    local ItemID2PointID = self.ItemID2PointID
    if not ItemID2PointID or not next(ItemID2PointID) then
        return
    end

    local PointID = ItemID2PointID[ItemID]
    if not PointID then
        return
    end
    if self:IsPointActivedQuickCheck(PointID) then -- 已经解锁不再出现侧边栏
        return false
    end

    local PointCfg = AetherCurrentCfg:FindCfgByKey(PointID)
    if not PointCfg then
        return false
    end

    local PointAtMapID = PointCfg.MapID
    if not PointAtMapID then
        return false
    end

    local CurMapID = PWorldMgr:GetCurrMapResID() or 0
    local bAtThePointMap = CurMapID == PointAtMapID
    local CacheItemList = self.TaskPointItemWaitForEasyUse
    if CacheItemList then
        CacheItemList[ItemGID] = 1
    end

    return bAtThePointMap
end

--- 跨地图时更新风脉泉道具相关的快捷使用
function AetherCurrentsMgr:UpdateEasyUseItemWhenChangeMap()
    local CacheItemList = table.clone(self.TaskPointItemWaitForEasyUse)
    if not CacheItemList or not next(CacheItemList) then
        return
    end

    for GID, _ in pairs(CacheItemList) do
        local SevItem = BagMgr:FindItem(GID)
        if SevItem then
            BagMgr:PopUpEasyUse(SevItem)
        else
            self.TaskPointItemWaitForEasyUse[GID] = nil
        end
    end
end

--- 为世界探索功能推荐最多4个符合要求的地图以及信息
function AetherCurrentsMgr:RecommandMapArrayForWildExplore()
    local NotCompleteMapInfoMap = self.NotCompleteMapInfoMap
    if not NotCompleteMapInfoMap or not next(NotCompleteMapInfoMap) then
        return {}
    end

    local Rlt = {}
    local RltNeedNum = 4
    local CurMapID = PWorldMgr:GetCurrMapResID()
    local ActivedNum, TotalNum = self:GetTheMapPointUnlockProcess(CurMapID)
    if ActivedNum and TotalNum and TotalNum > ActivedNum then
        if not Rlt[CurMapID] then
            Rlt[CurMapID] = {MapID = CurMapID, ActivedNum = ActivedNum, TotalNum = TotalNum}
            RltNeedNum = RltNeedNum - 1
        end
    end
    local MapInfoArray = table.values(NotCompleteMapInfoMap)
    table.sort(MapInfoArray, function(A, B) 
        return A.MapRemainPointNum < B.MapRemainPointNum
    end)
    for _, MapInfo in ipairs(MapInfoArray) do
        if RltNeedNum > 0 then
            local MapID = MapInfo.MapID
            local ActivedNum, TotalNum = self:GetTheMapPointUnlockProcess(MapID)
            if not Rlt[MapID] then
                Rlt[MapID] = {MapID = MapID, ActivedNum = ActivedNum, TotalNum = TotalNum}
                RltNeedNum = RltNeedNum - 1
            end
        else
            break
        end
    end

    return table.values(Rlt) 
end

--- 获取当前地图所有已激活的点的ID
function AetherCurrentsMgr:GetTheMapActivedPointIdList(MapID)
    if not MapID then
        return
    end

    local MapCompCfg = AetherCurrentCompSetCfg:FindCfgByKey(MapID)
    if not MapCompCfg then
        return
    end
    local Rlt = {}
    local ConfigPointList = MapCompCfg.AetherCurrentPointList
    if not ConfigPointList or not next(ConfigPointList) then
        return
    end

    for _, PointID in ipairs(ConfigPointList) do
        if self:IsPointActivedQuickCheck(PointID) then
            table.insert(Rlt, PointID)
        end
    end
    return Rlt
end

return AetherCurrentsMgr