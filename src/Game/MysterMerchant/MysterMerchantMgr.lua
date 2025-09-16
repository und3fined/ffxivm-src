--
-- Author: Carl
-- Date: 2024-5-17 16:57:14
-- Description:神秘商人Mgr

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local EventID = require("Define/EventID")
local UIDefine = require("Define/UIDefine")
local CommBtnColorType = UIDefine.CommBtnColorType
local BagMgr = require("Game/Bag/BagMgr")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local ItemSubmitVM = require("Game/Quest/VM/PanelVM/ItemSubmitVM")
local MysterMerchantUtils = require("Game/MysterMerchant/MysterMerchantUtils")
local MysterMerchantVM = require("Game/MysterMerchant/VM/MysterMerchantVM")
local MysterMerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local LSTR = _G.LSTR
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local EBubbleType = MysterMerchantDefine.EBubbleType
local EATLType = MysterMerchantDefine.EATLType

local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CsInteractionCMD
local MERCHANT = ProtoCS.Game.MysteryMerchant
local MERCHANT_INVEST_STATUS = MERCHANT.INVEST_MERCHANT_STATUS
local MERCHANT_CMD = MERCHANT.Cmd
local MERCHANT_TYPE = ProtoRes.Game.MysteryMerchantType
local MERCHANT_TASK_STATUS = MERCHANT.MERCHANT_TASK_STATUS
local ETaskType = ProtoRes.Game.MerchantInteractiveType
local EEnterAreaType = {
    Task = 1,
    Help = 2,
    None = 10,
}

local MysterMerchantMgr = LuaClass(MgrBase)

function MysterMerchantMgr:Ctor()
    
end

function MysterMerchantMgr:OnInit()
    self.CurrActiveMerchantList = {}
    self.EnterCryHelpArea_Record = {} -- 记录初次进入NPC喊话区域
    self.EnterHintArea_Record = {} -- 记录初次进入触发区域
    self.RequiredItemList = {}
    self.RequiredNumList = {}
    self.RequiredItemHQList = {}
    self.OwnedItemDataList = {}
    self.OwnedItemCountList = {}
    self.CurrMapResID = 0
    self.MapInstID = 0
    self.TaskStatus = 0
    self.InvestStatus = 0
    self.ShowingEObjNum = 0
    self.CanMatch = true
    self.IsForceQuitGame = false
    self.IsRobot = false
    self.IsTriggerExclusiveTask = false  --是否触发独享商人任务
    self.NpcHudIconMap = {}
    self.NpcResIdHudIconMap = {} -- 保存的是NPC的ResID，因为有可能NPC还没有创建出来没有ENTITYID
    self.MerchantID = 0
    self.IsReceiveExclusiveData = false  -- 当前地图是否收到独享商人数据（用于请求地图商人数据，后台用于清理独享商人数据）
    self.IsInMerchantPWorld = false -- 是否在位面副本内
end

function MysterMerchantMgr:OnBegin()
end

function MysterMerchantMgr:OnEnd()
end

function MysterMerchantMgr:OnShutdown()
end

function MysterMerchantMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.QueryMerchantData, self.OnNetMsgMysterMerchantBase)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.QueryMerchantMapData, self.OnNetMsgMerchantMapData)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.ExclusiveRefresh, self.OnNetMsgExclMerchantMapRefresh)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.MerchantTaskStats, self.OnNetMsgMerchantTaskProgressRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.SharedMerchantBirth, self.OnNetMsgMerchantMapData)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.QueryMerchantGoods, self.OnNetMsgMysterMerchantGoods)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.SubmitMerchantTask, self.OnNetMsgSubmitTaskSuccess)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.BuyMerchantGoods, self.OnNetMsgBuyGoodsRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.InvestMerchant, self.OnNetMsgInvestRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MYSTER_MERCHANT, MERCHANT_CMD.ReceiveInvestRewards, self.OnNetMsgInvestRewardRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_INTERAVIVE, CS_SUB_CMD.CsInteractionCMDEnd, self.OnInteractiveEnd)
end

function MysterMerchantMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
    self:RegisterGameEvent(EventID.LeaveInteractionRange, self.OnGameEventLeaveInteractionRange)
    self:RegisterGameEvent(EventID.EnterInteractive, self.OnSingleInteractive)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.PWorldStageInfoUpdate, self.OnPWorldStageInfoUpdate)
    self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnGameEventStartFadeIn)
    self:RegisterGameEvent(EventID.PWorldTransBegin, self.OnPWorldTransBegin)
    self:RegisterGameEvent(EventID.EnterMapFinish, self.OnEnterWorld)
    self:RegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate)
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
end

function MysterMerchantMgr:OnRegisterTimer()
	
end

function MysterMerchantMgr:OnGameEventLoginRes()
    -- 登录时拉取友好度数据，用于 世界探索玩法显示进度
    self:SendMsgGetMysterMerchantInfo()
    -- if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMysteryMerchant) then -- TODO 目前值始终未解锁
    --     self:SendMsgGetMysterMerchantInfo()
    -- end
end

-- 当前地图内传送完成也会执行
function MysterMerchantMgr:OnEnterWorld()
    if not self.IsStartTrans then
        return
    end
    self.IsStartTrans = false
    
    --副本内传送离开商人范围
    if self.MerchantID and self.MerchantID > 0 then
        self:SendMsgRemoveStateReq(self.MerchantID)
    end

    -- 副本没传送时，会隐藏本地创建的怪物，所以在这里重新创建
    for _, ActiveMerchant in pairs(self.CurrActiveMerchantList) do
        local MonsterList = ActiveMerchant.MonsterAvatarList
        local MerchantID = ActiveMerchant.MerchantID
        local TaskID = ActiveMerchant.TaskID
        if MonsterList and #MonsterList > 0 then
            self:OnReomveMonsters(MerchantID)
        end
        local TaskState = ActiveMerchant.TaskState
        local TaskType = ActiveMerchant.TaskType
        if TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED then
            if TaskType ~= ETaskType.InteractiveTypePickUpCargo then 
                ActiveMerchant.MonsterAvatarList = self:CreateTaskMonsterAvatar(TaskID)
            end
        end
    end
end

--- @type 当场景加载完
function MysterMerchantMgr:OnPWorldReady()
    local BaseInfo = _G.PWorldMgr.BaseInfo
    self.CurrMapResID = BaseInfo.CurrMapResID
    self.PWorldResID = BaseInfo.CurrPWorldResID
    self.MapInstID = BaseInfo.CurrPWorldInstID

    -- 在冒险游商团副本内，则显示任务情报
    if _G.PWorldMgr:CurrIsInMerchant() then
        self:ShowTaskInfoBar(true)
        -- 重登后直接在位面内时，退出再进
        if self.MerchantID == nil or self.MerchantID <= 0 then
            _G.PWorldMgr:SendLeavePWorld(self.PWorldResID)
        end
        self.IsInMerchantPWorld = true
        return
    end

    if self.IsInMerchantPWorld then
        self.IsInMerchantPWorld = false
        -- 从位面副本出来时，任务完成，则显示结算界面
        if self.TaskStatus == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
            self:ShowMysterSettlementView()
        end
    end

    -- 在冒险游商团以外的其他副本内，不请求数据
    if _G.PWorldMgr:CurrIsInDungeon() then
        return
    end
    
    --当前地图没有配置商人地点，则不请求数据
    if not MysterMerchantUtils.IsConfigMerchantMapPoint(self.CurrMapResID) and not self.IsReceiveExclusiveData then
        return
    end

    if self.MerchantID and self.MerchantID > 0 then
        self.MerchantID = 0
    end
    self:ClearMerchantCacheAll()
    self:SendMsgQueryMerchantMapData()
end

---@type 离开场景
function MysterMerchantMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
    if self.MerchantCheckTimer then
        self:UnRegisterTimer(self.MerchantCheckTimer)
        self.MerchantCheckTimer = nil
    end

    if self.EnterHintArea_Record and self.EnterHintArea_Record[self.MerchantID] then
        self:SendMsgRemoveStateReq(self.MerchantID)
        --self:OnClearMerchantCache(self.MerchantID)
        if self.EnterHintArea_Record and self.EnterHintArea_Record[self.MerchantID] then
            self.EnterHintArea_Record[self.MerchantID] = nil
        end
    
        if self.EnterCryHelpArea_Record and self.EnterCryHelpArea_Record[self.MerchantID] then
            self.EnterCryHelpArea_Record[self.MerchantID] = nil
        end
    end
    self:ShowTaskInfoBar(false)
end

-- 副本内传送（由于离开商人范围没有触发，所以采用这个事件）
function MysterMerchantMgr:OnPWorldTransBegin(IsOnlyChangeLocation)
    if IsOnlyChangeLocation then
        return
    end
    
    --副本内传送离开商人范围
    if self.EnterHintArea_Record and self.EnterHintArea_Record[self.MerchantID] then
        self.IsStartTrans = true
    else
        self.IsStartTrans = false
    end
end 

function MysterMerchantMgr:OnGameEventStartFadeIn(Params)
    local EntityID = Params.ULongParam1
    if EntityID == nil or EntityID == 0 then
        return
    end
    local ResID = ActorUtil.GetActorResID(EntityID)
    if self.CurrActiveMerchantList == nil or next(self.CurrActiveMerchantList) == nil then
        return
    end

    for _, ActiveMerchant in pairs(self.CurrActiveMerchantList) do
        local EndTime = ActiveMerchant.EndTime
        local PointID = ActiveMerchant.MerchantPointID
        local MerchantID = ActiveMerchant.MerchantID
        local MerchantNPCID = ActiveMerchant.NPCID
        if MerchantNPCID and MerchantNPCID == ResID then
            -- 播放动作(任务状态改变，需要变动作)
            local TaskState = ActiveMerchant.TaskState
            if TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
                self:PlayActionTimeline(MerchantID, EATLType.FinishTaskIdle)
            else
                self:PlayActionTimeline(MerchantID, EATLType.DefaultIdle)
            end
        end
    end
end

---@type 更新商人头顶图标
function MysterMerchantMgr:OnUpdateMerchantHudIcon(MerchantID, TaskState)
    local function GetHudIconPathByState(TaskState)
        -- 完成任务或者任务待提交，那么就显示
        if (TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED) then
            return nil
        elseif TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_WAIT_SUBMIT or
            TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
            return "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_HUD_Icon_MysterMerchant_png.UI_HUD_Icon_MysterMerchant_png'"
        else
            return nil
        end
    end
    if self.CurrActiveMerchantList == nil then
        return
    end

    local ActiveMerchant = self.CurrActiveMerchantList[MerchantID]
    local NPCResID = ActiveMerchant.NPCID
    local MerchantEntityID = ActorUtil.GetActorEntityIDByResID(NPCResID)
    self.NpcResIdHudIconMap[NPCResID] = GetHudIconPathByState(TaskState)
    if MerchantEntityID then
        self.NpcHudIconMap[MerchantEntityID] = GetHudIconPathByState(TaskState)
    end
    
    _G.EventMgr:SendEvent(EventID.MysteryMerchantUpdateNPCHudIcon, MerchantEntityID)
end

function MysterMerchantMgr:GetNPCHudIcon(NpcEntityID)
    if NpcEntityID == nil or NpcEntityID <= 0 then
        return nil
    end

    local NPCResID = ActorUtil.GetActorResID(NpcEntityID)
    if not MysterMerchantUtils.IsMysterMerchant(NPCResID) then
        return nil
    end

    local Icon = self.NpcHudIconMap[NpcEntityID]
    if (Icon == nil) then
        local FinalIcon = self.NpcResIdHudIconMap[NPCResID]
        if (FinalIcon ~= nil) then
            self.NpcHudIconMap[NpcEntityID] = FinalIcon
        end
        return FinalIcon
    else
        return Icon
    end
end

---@type 更新当前场景所有商人信息
function MysterMerchantMgr:UpdateCurActiveMerchant(MerchantDataList)
    if MerchantDataList == nil or #MerchantDataList <= 0 then
        return
    end

    self.CurrActiveMerchantList = {}
    for _, MerchantData in ipairs(MerchantDataList) do
        self:UpdateMerchant(MerchantData)
    end
end

---@type 刷新商人数据
function MysterMerchantMgr:UpdateMerchant(MerchantData)
    if MerchantData == nil then
        return
    end

    if self.MerchantCheckTimer == nil then
        self.MerchantCheckTimer = self:RegisterTimer(self.MerchantTick, 0, 0.5, 0)
    end

    local MerchantPointID = MerchantData.PointID
    local PointInfo = MysterMerchantUtils.GetMerchantPointInfo(MerchantPointID)
    if PointInfo == nil then
        FLOG_WARNING("商人PointID不存在，请检查！".. MerchantPointID or 0)
        return
    end

    -- 与当前地图不符
    local MapResID = PointInfo.MapResID
    if MapResID ~= self.CurrMapResID then
        return
    end

    local MerchantID = MerchantData.MerchantID
    local MerchantNPCID = MysterMerchantUtils.GetMerchantResID(MerchantID)
    local EndTime = math.floor(MerchantData.ExpireTime/1000) --_G.TimeUtil.GetServerTime() + 120
    local MerchantTask = MerchantData.Task
    
    FLOG_INFO("商人回收时间："..EndTime)
    local TaskID = MerchantData.TaskID
    local MerchantType = MysterMerchantUtils.GetMerchantType(MerchantID)
    local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
    if TaskInfo == nil then
        FLOG_WARNING(string.format("任务ID %s不存在，请检查！", TaskID))
        return
    end
    local BirthPointID = PointInfo and PointInfo.BirthPointID or 0
    local BirthMapPoint = _G.MapEditDataMgr:GetMapPoint(BirthPointID)
    local NPCBirthLocation = BirthMapPoint and _G.UE.FVector(BirthMapPoint.Point.X, BirthMapPoint.Point.Y, BirthMapPoint.Point.Z)
    if self.CurrActiveMerchantList == nil then
        self.CurrActiveMerchantList = {}
    else
        local Merchant = self.CurrActiveMerchantList[MerchantID]
        if Merchant then
            self:OnClearMerchantCache(Merchant.MerchantID)
        end
    end

    local InvestData = MerchantData.InvestData
    local TaskProgress = MerchantTask and MerchantTask.Progress or 0
    local TaskSubmitNum = MerchantTask and MerchantTask.SubmitNum or 0
    self.CurrActiveMerchantList[MerchantID] = {
        MerchantID = MerchantID,
        NPCID = MerchantNPCID,
        MerchantPointID = MerchantPointID,
        TaskCenter = NPCBirthLocation,
        TaskRadius = TaskInfo.TaskRadius,
        TaskHeight = TaskInfo.TaskHeight,
        EscapeDistance = TaskInfo.EscapeDistance,
        TaskType = TaskInfo.TaskType,
        MerchantType = MerchantType,
        InvestStatus = InvestData and InvestData.InvestStatus or 0,
        SpentCoin = InvestData and InvestData.SpentCoin,
        Progress = TaskProgress,
        SubmitNum = TaskSubmitNum,
        FinishNum = TaskInfo.FinishNum,
        VisualNum = TaskInfo.VisualNum,
        TaskID = TaskID,
        EndTime = EndTime,
        IsPendingDisable = false,
    }
    
    --如果EndTime == 0 则不回收
    if EndTime and EndTime > 0 then
        self:RemoveMerchantCountDown(self.CurrActiveMerchantList[MerchantID], EndTime, MerchantPointID)
    end

    local MonsterAvatarList = nil
    local TaskEObjShowList = nil
    local TaskType = TaskInfo.TaskType -- 任务类型

    local TaskState = MerchantTask and MerchantTask.Status or 0
    if TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED then
        if TaskType == ETaskType.InteractiveTypePickUpCargo then 
            -- 拾取类型，显示采集物
            if MerchantType == MERCHANT_TYPE.MysteryMerchantTypeExclusive then
                --独享商人时显示采集物（共享商人不处理，服务器默认显示）
                TaskEObjShowList = self:GetEObjsEditorList(TaskID, TaskInfo.VisualNum)
            end
        else 
            -- 打怪类型,创建怪物模型
            MonsterAvatarList = self:CreateTaskMonsterAvatar(TaskID)
        end
    end

    if MerchantType == MERCHANT_TYPE.MysteryMerchantTypeExclusive then
        self.IsReceiveExclusiveData = true
    end

    self.CurrActiveMerchantList[MerchantID].TaskState = TaskState
    self.CurrActiveMerchantList[MerchantID].MonsterAvatarList = MonsterAvatarList
    self.CurrActiveMerchantList[MerchantID].TaskEObjShowList = TaskEObjShowList

    -- 从位面副本出来时播放动作
    if TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
        self:PlayActionTimeline(MerchantID, EATLType.FinishTaskIdle)
    else
        self:PlayActionTimeline(MerchantID, EATLType.DefaultIdle)
    end
end

---@type 创建怪物模型
function MysterMerchantMgr:CreateTaskMonsterAvatar(TaskID)
    local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
    local MonsterListID = TaskInfo.MonsterGroupListID
    if MonsterListID == nil or MonsterListID <= 0 then
        return
    end

    local MonsterGrouup = _G.MapEditDataMgr:GetMonsterGroupByListID(MonsterListID)
    local MonsterAvatarList = {}
    if MonsterGrouup then
        for _, Monster in ipairs(MonsterGrouup.Monsters) do
            local ResID = Monster.ID
            local BirthMapPoint = Monster.BirthPoint
            local BirthLocation = BirthMapPoint and _G.UE.FVector(BirthMapPoint.X, BirthMapPoint.Y, BirthMapPoint.Z)
            local NPCRotation = _G.UE.FRotator(0, Monster.BirthDir, 0)
            local MonsterEntityID = _G.UE.UActorManager:Get():CreateClientActor(
                _G.UE.EActorType.Monster, Monster.ListID, ResID, BirthLocation, NPCRotation
            )
            local MonsterActor = ActorUtil.GetActorByEntityID(MonsterEntityID)
            if (MonsterActor ~= nil) then
                MonsterActor:AdjustGround(true)
            end
            table.insert(MonsterAvatarList, MonsterEntityID)
            FLOG_INFO("创建怪物ID："..MonsterEntityID)
        end
    end

    return MonsterAvatarList
end

---@type 移除场景中的怪物
function MysterMerchantMgr:OnReomveMonsters(MerchantID)
    if MerchantID == nil or self.CurrActiveMerchantList == nil then
        return
    end
    local ExistMerchant = self.CurrActiveMerchantList[MerchantID]
    local MonsterAvatarList = ExistMerchant and ExistMerchant.MonsterAvatarList
    if MonsterAvatarList == nil or #MonsterAvatarList <= 0 then
        return
    end

    for i = #MonsterAvatarList, 1, -1 do
        local MonsterEntityID = MonsterAvatarList[i]
        _G.UE.UActorManager:Get():RemoveClientActor(MonsterEntityID)
        table.remove(MonsterAvatarList, i)
        FLOG_INFO("销毁怪物ID："..MonsterEntityID)
    end
    MonsterAvatarList = nil
end

---@type 场景所有采集物的显示
function MysterMerchantMgr:GetEObjsEditorList(TaskID, MaxNum)
    local TaskEObjShowList = {}
    local GatherEditorIDList = MysterMerchantUtils.GetGatherEditorIDList(TaskID, MaxNum)
    for _, EObjID in pairs(GatherEditorIDList) do
        local MapEditorData = _G.ClientVisionMgr:GetEditorDataByEditorID(tonumber(EObjID), "EObj")
        if MapEditorData then
            table.insert(TaskEObjShowList, tonumber(EObjID))
        end
    end
    return TaskEObjShowList
end

---@type 移除场景中的所有采集物
---@param RemoveEObjList table
function MysterMerchantMgr:OnRemoveCollectItemAll(MerchantID)
    if MerchantID == nil or self.CurrActiveMerchantList == nil then
        return
    end
    local ExistMerchant = self.CurrActiveMerchantList[MerchantID]
    local RemoveEObjList = ExistMerchant and ExistMerchant.TaskEObjShowList
    if RemoveEObjList == nil then
        return
    end
    local CurrMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if CurrMapEditCfg then
        for _, EObjData in ipairs(CurrMapEditCfg.EObjList) do
            if EObjData.Type == ProtoRes.ClientEObjType.ClientEObjTypeMerchantGather then
                if table.contain(RemoveEObjList, EObjData.ID) then
                    _G.ClientVisionMgr:ClientActorLeaveVision(EObjData.ID, _G.UE.EActorType.EObj)
                    FLOG_INFO("销毁货物ID："..EObjData.ID)
                end
            end
        end
    end
    RemoveEObjList = nil
end

---@type 移除场景中的采集物
---@param RemoveEObjList table
function MysterMerchantMgr:RemoveCollectItem(InEObjID)
    if InEObjID == nil or InEObjID <= 0 then
        return
    end

    local ExistMerchant = self:GetCurrActiveMerchant()
    if ExistMerchant == nil then
        return false
    end

    local GatherEditorIDList = ExistMerchant.TaskEObjShowList
    if GatherEditorIDList then
        for i = #GatherEditorIDList, 1, -1 do
            local ObjID = GatherEditorIDList[i]
            if InEObjID == ObjID then
                table.remove(GatherEditorIDList, i)
                --FLOG_ERROR("采集物被拾取隐藏:"..InEObjID)
            end
        end
    end

    _G.ClientVisionMgr:ClientActorLeaveVision(InEObjID, _G.UE.EActorType.EObj)
    -- 3秒后再刷新
    self:RegisterTimer(function ()
        local ExistMerchant = self:GetCurrActiveMerchant()
        if ExistMerchant == nil then
            return
        end
        local TaskID = ExistMerchant.TaskID
        local MaxNum = ExistMerchant.VisualNum
        local ExistNum = ExistMerchant.TaskEObjShowList and #ExistMerchant.TaskEObjShowList or 0
        if ExistNum > MaxNum then
            return
        end
        local GatherEditorIDList = ExistMerchant.TaskEObjShowList
        local EobjID = MysterMerchantUtils.GetRandomGatherEditorID(GatherEditorIDList, TaskID)
        if GatherEditorIDList then
            table.insert(GatherEditorIDList, EobjID)
        end
        --FLOG_ERROR("3s后刷新采集物:"..EObjID)
        self.ShowingEObjNum = self.ShowingEObjNum + 1
    end, 3, 0, 1, InEObjID)
end

---@type 货物拾取成功
function MysterMerchantMgr:OnInteractiveEnd(MsgBody)
    local EndMsg = MsgBody.End
    local RecvInteractiveID = EndMsg and EndMsg.InteractiveID
    local InteractionID = MysterMerchantUtils.GetInteractID()
    if InteractionID and RecvInteractiveID ~= InteractionID then
        return
    end
    
    local ExistMerchant = self:GetCurrActiveMerchant()
    if ExistMerchant == nil then
        return
    end
    self:RemoveCollectItem(self.EObjID)
end

function MysterMerchantMgr:OnBagUpdate(Params)
	if nil == Params then
		return
	end

    local ExistMerchant = self:GetCurrActiveMerchant()
    if ExistMerchant == nil then
        return
    end
    
    -- 超重Debuff提示
    local TaskID = ExistMerchant.TaskID
	for _, Value in pairs(Params) do
		local Item = Value.PstItem
		local bOn = Value.Type == ProtoCS.ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD or Value.Type == ProtoCS.ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_RENEW
        if bOn then
            local RequiredItemID = self.RequiredItemList and self.RequiredItemList[1]
            if RequiredItemID and RequiredItemID == Item.ResID then
                local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
                local OverWeightNum = TaskInfo and TaskInfo.OverWeightNum or 0
                local HaveTaskItemNum = Item.Num
                if OverWeightNum > 0 and HaveTaskItemNum == OverWeightNum then -- 只在超出时提示一次
                    MsgTipsUtil.ShowTipsByID(MysterMerchantDefine.TipID.OverWeightTip)
                end
            end
        end
	end
end

function MysterMerchantMgr:OnGameEventMajorDead(Params)
    -- 主角死亡以后，移除Debuf
    if self.MerchantID and self.MerchantID > 0 then
        self:SendMsgRemoveStateReq(self.MerchantID)
    end
end

-- 是否能创建商人NPC
---@param MapEditorID number
---@return boolean
function MysterMerchantMgr:CanCreateMerchantNPC(MapEditorID)
    if self.CurrActiveMerchantList == nil then
        return false
    end

    for _, ActiveMerchant in pairs(self.CurrActiveMerchantList) do 
        local TaskID = ActiveMerchant.TaskID
        local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
        if TaskInfo and TaskInfo.NPCListID == MapEditorID then
            --FLOG_ERROR("商人创建成功："..table_to_string(MapEditorID))
            return true
        end
    end
    --FLOG_ERROR("商人创建失败："..table_to_string(MapEditorID))
    return false
end

-- 是否能创建场景采集物
---CanCreateEObj
---@param MapEditorID number Eobj的ID
---@param EObjResID number Eobj的ResID
---@return boolean
function MysterMerchantMgr:CanCreateEObj(MapEditorID, EObjResID)
    if self.CurrActiveMerchantList == nil then
        --FLOG_ERROR("商人采集物创建条件不足,激活商人列表为空："..table_to_string(MapEditorID))
        return false
    end

    for _, ActiveMerchant in pairs(self.CurrActiveMerchantList) do 
        local TaskState = ActiveMerchant.TaskState
        if TaskState ~= MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
            local GatherEditorIDList = ActiveMerchant.TaskEObjShowList
            if GatherEditorIDList and #GatherEditorIDList > 0 then
                if table.contain(GatherEditorIDList, MapEditorID) then
                    return true
                end 
            end
        end
    end
    return false
end

function MysterMerchantMgr:MerchantTick()
    self:OnCheckAreaOverlap()
end

---@type 商人回收
---@param MerchantID number 商人ID
---@param EndTime number 回收时间
---@param EndPointID number 回收点
function MysterMerchantMgr:RemoveMerchantCountDown(ActiveMerchant, EndTime, PointID)
    if ActiveMerchant == nil then
        return
    end
    local MerchantID = ActiveMerchant.MerchantID

    if EndTime == nil or EndTime == 0 then
        return
    end

    local function RemoveMerchant(_, Params)
        --TODO 播放离开动作
        --TODO 播放离开气泡
        -- 移动到回收位置后再移除
        local MerchantID = Params.MerchantID
        local PointID = Params.PointID
        local PointInfo = MysterMerchantUtils.GetMerchantPointInfo(PointID)
        local BirthPointID = PointInfo and PointInfo.BirthPointID or 0
        local BirthMapPoint = _G.MapEditDataMgr:GetMapPoint(BirthPointID)
        local StartLocation = BirthMapPoint and _G.UE.FVector(BirthMapPoint.Point.X, BirthMapPoint.Point.Y, BirthMapPoint.Point.Z)
        
        local EndPointID = PointInfo and PointInfo.EndPointID
        local EndMapPoint = _G.MapEditDataMgr:GetMapPoint(EndPointID)
        local EndLocation = EndMapPoint and _G.UE.FVector(EndMapPoint.Point.X, EndMapPoint.Point.Y, EndMapPoint.Point.Z)
        
        self:OnMerchantMoveToEndPoint(MerchantID, StartLocation, EndLocation)
        self:OnMerchantPendingRemove(MerchantID)
    end
    local LocalTime = _G.TimeUtil.GetServerLogicTime()
    local Delay = math.clamp(EndTime - LocalTime, 0, EndTime - LocalTime)
    local Params = {
        MerchantID = MerchantID,
        PointID = PointID,
    }

    if ActiveMerchant.RemoveTimer == nil then
        FLOG_INFO(string.format("%s秒后移除商人：",Delay))
        ActiveMerchant.RemoveTimer = self:RegisterTimer(RemoveMerchant, Delay, 0, 1, Params)
    end
end

function MysterMerchantMgr.ForceRemoveNPC(_, MerchantEntityID)
    if MerchantEntityID == nil then
        FLOG_INFO("商人未消失，传入的MerchantEntityID 为空")
        return
    end
    local _, ObjID = ActorUtil.GetInteractionObjInfo(MerchantEntityID)
    if ObjID then
        FLOG_INFO("商人消失："..table_to_string(ObjID))
        _G.ClientVisionMgr:ClientActorLeaveVision(ObjID, _G.UE.EActorType.Npc)
        _G.EventMgr:SendEvent(EventID.RemoveMysterMerchantRangeCheckData, ObjID)
    else
        FLOG_INFO("商人未消失，找不到ObjID，MerchantEntityID："..MerchantEntityID)
    end
end

---@type 商人移动到消失位置
function MysterMerchantMgr:OnMerchantMoveToEndPoint(MerchantID, StartLocation, EndLocation)
    if MerchantID == nil or MerchantID <= 0 then
        FLOG_INFO("移除商人MerchantID为空")
        return
    end
    FLOG_INFO("商人初始位置："..table_to_string(StartLocation))
    FLOG_INFO("商人消失位置："..table_to_string(EndLocation))
    local ExistMerchant = self.CurrActiveMerchantList[MerchantID]
    if ExistMerchant == nil then
        FLOG_INFO("移除商人为空！MerchantID:"..MerchantID)
        return
    end
    
    local MerchantNPCID = ExistMerchant.NPCID
    if MerchantNPCID == nil then
        FLOG_INFO("移除商人NPCID为空！")
        return
    end

    local MerchantEntityID = ActorUtil.GetActorEntityIDByResID(MerchantNPCID)
    if MerchantEntityID == nil then
        FLOG_INFO("移除商人EntityID为空！")
        return
    end

    local MapID = self.CurrMapResID
    local MapPaths = _G.NavigationPathMgr:FindMapPaths(MapID, StartLocation, MapID, EndLocation)
    if MapPaths and #MapPaths > 0 then
        local PosTable = _G.UE.TArray(_G.UE.FVector)
        for _, Path in ipairs(MapPaths) do
            for _, Pos in ipairs(Path.Paths) do
                PosTable:Add(Pos.StartPos)
                PosTable:Add(Pos.EndPos)
            end
        end
        local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
        local Speed = 550 * 2  --商人移动速度，暂时取玩家的2倍，跑起来
        FLOG_INFO("商人开始移动到消失位置："..table_to_string(EndLocation))
        self:MakeFinishCallback(MerchantID, MerchantEntityID, self.ForceRemoveNPC)
        UMoveSyncMgr:StartClientMove(MerchantEntityID, PosTable, Speed)
    else
        FLOG_ERROR("没有找到商人移动到消失位置的路！！！！！")
        self.ForceRemoveNPC(MerchantEntityID)
    end

    self:RegisterTimer(self.ForceRemoveNPC, 5, 0, 1, MerchantEntityID) -- 在无法移动到消失地点情况下的保底做法，5秒后强制移除商人NPC
end

function MysterMerchantMgr:MakeFinishCallback(MerchantID, EntityID, OnFinishCallback)
    local UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
	local function ShellCallback(_, InEntityID)
		if EntityID ~= InEntityID then return end
		-- 延迟一会儿执行，避免在FMoveSyncPipeline::Tick()内CurrentStrategy->Tick()销毁Actor，导致破坏CurrentStrategy非空假设
        --_G.TimerMgr:AddTimer(self, OnFinishCallback, 0.2, 0, 1, InEntityID)
        self:RegisterTimer(OnFinishCallback, 0.1, 0, 1, InEntityID)
        _G.MysterMerchantMgr:PlayActionTimeline(MerchantID, EATLType.ShopIdle) --等待销毁过程中播放的待机动作而已
		UMoveSyncMgr.OnClientLocalMoveFinish:Remove(UMoveSyncMgr, ShellCallback)
	end
	UMoveSyncMgr.OnClientLocalMoveFinish:Add(UMoveSyncMgr, ShellCallback)
end

---@type 商人即将回收处理 移动到回收位置
function MysterMerchantMgr:OnMerchantPendingRemove(MerchantID)
    if MerchantID == self.MerchantID then
        local CurrActiveMerchant = self:GetCurrActiveMerchant()
        if CurrActiveMerchant then
            -- 隐藏交互
            local MerchantNPCID = CurrActiveMerchant.NPCID
            if MerchantNPCID then
                local MerchantEntityID = ActorUtil.GetActorEntityIDByResID(MerchantNPCID) or 0
                _G.InteractiveMgr:HideFunctionItemByFuncType(
                MerchantEntityID,
                ProtoRes.interact_func_type.INTERACT_FUNC_MYSTER_MERCHANT)
            end
        end

        _G.MsgTipsUtil.ShowTipsByID(MysterMerchantDefine.TipID.EndTrade)
        self:ShowTaskInfoBar(false)
        self:EndInteraction()
        _G.UIViewMgr:HideView(_G.UIViewID.MysterShopMainPanelView)
        _G.UIViewMgr:HideView(_G.UIViewID.MysterMerchantSettlementView)
        _G.UIViewMgr:HideView(_G.UIViewID.NewQuestPropPanel)
    end

    --标记为待移除
    local ActiveMerchant = self.CurrActiveMerchantList and self.CurrActiveMerchantList[MerchantID]
    if ActiveMerchant then
        ActiveMerchant.IsPendingDisable = true
        ActiveMerchant.RemoveTimer = nil
    end
    
    self:OnClearMerchantCache(MerchantID)
end

---@type 清除商人缓存
function MysterMerchantMgr:OnClearMerchantCache(MerchantID)
    if self.CurrActiveMerchantList and self.CurrActiveMerchantList[MerchantID] then
        if self.CurrActiveMerchantList[MerchantID].RemoveTimer then
            self:UnRegisterTimer(self.CurrActiveMerchantList[MerchantID].RemoveTimer)
            self.CurrActiveMerchantList[MerchantID].RemoveTimer = nil
        end
        self:OnReomveMonsters(MerchantID)
        self:OnRemoveCollectItemAll(MerchantID)
        self:SendMsgRemoveStateReq(MerchantID)

        local ActiveMerchant = self.CurrActiveMerchantList[MerchantID]
        local NPCResID = ActiveMerchant and ActiveMerchant.NPCID
        local MerchantEntityID = ActorUtil.GetActorEntityIDByResID(NPCResID)
        if MerchantEntityID and self.NpcHudIconMap and self.NpcHudIconMap[MerchantEntityID] then
            self.NpcHudIconMap[MerchantEntityID] = nil
        end
        
        self.CurrActiveMerchantList[MerchantID] = nil
    end

    if self.EnterHintArea_Record and self.EnterHintArea_Record[MerchantID] then
        self.EnterHintArea_Record[MerchantID] = nil
    end

    if self.EnterCryHelpArea_Record and self.EnterCryHelpArea_Record[MerchantID] then
        self.EnterCryHelpArea_Record[MerchantID] = nil
    end
end

---@type 清除所有商人缓存
function MysterMerchantMgr:ClearMerchantCacheAll()
    if self.CurrActiveMerchantList == nil then
        return
    end

    for _, ActiveMerchant in pairs(self.CurrActiveMerchantList) do
        self:OnClearMerchantCache(ActiveMerchant.MerchantID)
    end
end

---@type 播放气泡
function MysterMerchantMgr:PlayBubble(MerchantID, BubbleType)
    if MerchantID == nil or self.CurrActiveMerchantList == nil then
        return
    end
    local ExistMerchant = self.CurrActiveMerchantList[MerchantID]
    if ExistMerchant == nil then
        return
    end
    local BubbleID = MysterMerchantUtils.GetMerchantBubbleID(MerchantID, BubbleType)
    local MerchantNPCID = ExistMerchant.NPCID
    local MerchantEntityID = ActorUtil.GetActorEntityIDByResID(MerchantNPCID) or 0
    if BubbleID and MerchantEntityID then
        _G.SpeechBubbleMgr:ShowBubbleByID(MerchantEntityID, BubbleID) 
    end
end

---@type 播放动作ATL
function MysterMerchantMgr:PlayActionTimeline(MerchantID, ATLType)
    if MerchantID == nil or self.CurrActiveMerchantList == nil then
        return
    end
    local ExistMerchant = self.CurrActiveMerchantList[MerchantID]
    if ExistMerchant == nil then
        return
    end
    local TaskID = ExistMerchant.TaskID
    local MerchantNPCID = ExistMerchant.NPCID
    local MerchantEntityID = ActorUtil.GetActorEntityIDByResID(MerchantNPCID) or 0
    local NPCAnimationComponent = ActorUtil.GetActorAnimationComponent(MerchantEntityID)
    local TimelineID = MysterMerchantUtils.GetMerchantATLID(MerchantID, TaskID, ATLType)
    if NPCAnimationComponent and TimelineID and TimelineID > 0 then
        --播放完解救动作后播放任务完成的待机动作
        if ATLType == EATLType.Saved then
            local Montage = NPCAnimationComponent:PlayActionTimeline(TimelineID)
            local Length = AnimationUtil.GetAnimMontageLength(Montage) * 0.7
            local function PlayIdleTimeline()
                local IdleTimelineID = MysterMerchantUtils.GetMerchantATLID(self.MerchantID, TaskID, EATLType.FinishTaskIdle)
                NPCAnimationComponent:SetIdleActionTimeline(IdleTimelineID)
            end
            self:RegisterTimer(PlayIdleTimeline, Length, 0, 1)
        else
            NPCAnimationComponent:SetIdleActionTimeline(TimelineID) -- 待机动作
        end
    end
end 

---@type 进入任务区域检测
function MysterMerchantMgr:OnCheckAreaOverlap()
    local Major = MajorUtil.GetMajor()
    if Major == nil then return end
    local MajorLocation = Major:FGetActorLocation()
    for _, MerchantInfo in pairs(self.CurrActiveMerchantList) do
        local NPCCryForHelpRadius = MysterMerchantUtils.GetHelpDistance(MerchantInfo.TaskID)
        local TaskCenter = MerchantInfo.TaskCenter
        local TaskRadius = MerchantInfo.TaskRadius
        local TaskHeight = MerchantInfo.TaskHeight
        local EscapeDistance = MerchantInfo.EscapeDistance
        if TaskCenter and not MerchantInfo.IsPendingDisable then
            local Dist = MajorLocation:Dist2D(TaskCenter)
            if MajorLocation.Z <= TaskCenter.Z + TaskHeight and MajorLocation.Z >= TaskCenter.Z - TaskHeight then
                if Dist < TaskRadius then
                    self:OnEnterTaskRange(MerchantInfo)-- 进入战斗区域
                else
                    -- 喊话距离和脱战距离可能一样
                    if Dist < NPCCryForHelpRadius then
                        self:OnEnterCryForHelpArea(MerchantInfo)-- 进入NPC喊话区域
                    else
                        self:OnLeaveCryForHelpArea(MerchantInfo)-- 退出NPC喊话区域
                    end
    
                    if Dist > EscapeDistance then
                        self:OnLeaveTaskRange(MerchantInfo)-- 退出战斗区域
                    end
                end
            else
                self:OnLeaveTaskRange(MerchantInfo)-- 退出战斗区域
                self:OnLeaveCryForHelpArea(MerchantInfo)-- 退出NPC喊话区域
            end
        end
    end    
end

-- 当进入NPC喊话区域
function MysterMerchantMgr:OnEnterCryForHelpArea(MerchantInfo)
    if MerchantInfo == nil then
        return
    end

    local MerchantID = MerchantInfo.MerchantID
    local TaskState = MerchantInfo.TaskState
    if self.EnterCryHelpArea_Record and self.EnterCryHelpArea_Record[MerchantID] ~= nil then
        return
    end

    if self.EnterCryHelpArea_Record == nil then
        self.EnterCryHelpArea_Record = {}
    end
    
    if self.EnterCryHelpArea_Record then
        self.EnterCryHelpArea_Record[MerchantID] = MerchantID
    end
    if TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED then
        MsgTipsUtil.ShowTipsByID(MysterMerchantDefine.TipID.EnterCryHelpArea[MerchantID])
    end
end

-- 当离开NPC喊话区域
function MysterMerchantMgr:OnLeaveCryForHelpArea(MerchantInfo)
    if MerchantInfo == nil then
        return
    end
    local MerchantID = MerchantInfo.MerchantID
    if self.EnterCryHelpArea_Record[MerchantID] ~= nil then
        self.EnterCryHelpArea_Record[MerchantID] = nil
    end
end

-- 当进入任务区域
function MysterMerchantMgr:OnEnterTaskRange(MerchantInfo)
    if MerchantInfo == nil then
        return
    end

    local MerchantID = MerchantInfo.MerchantID
    self.MerchantID = MerchantID
    if self.EnterHintArea_Record and self.EnterHintArea_Record[MerchantID] then
        return
    else
        if self.EnterHintArea_Record == nil then
            self.EnterHintArea_Record = {}
        end
        self.EnterHintArea_Record[MerchantID] = MerchantID

        if self.EnterCryHelpArea_Record == nil then
            self.EnterCryHelpArea_Record = {}
        end
        self.EnterCryHelpArea_Record[MerchantID] = MerchantID -- 传送过来的情况下，直接算进入了喊话范围
        self:OnCheckTutorial()
    end

    self:ShowTaskInfoBar(true)
    MysterMerchantVM:OnEnterTaskRange(MerchantInfo)
    local MerchantType = MerchantInfo.MerchantType
    self.InvestStatus = MerchantInfo.InvestStatus
    local TaskState = MerchantInfo.TaskState
    local TaskType = MerchantInfo.TaskType
    if TaskState ~= MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
        if TaskType == ETaskType.InteractiveTypePickUpCargo then
            -- 拾取超重提示
            local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(MerchantInfo.TaskID)
            if TaskInfo and TaskInfo.OverWeightNum > 0 then
                MsgTipsUtil.ShowTipsByID(MysterMerchantDefine.TipID.PickUpCargoTip)
            end
        end
    
        --触发商人任务
        local function StartTask()
            self:SendMsgTriggerTaskReq(self.MerchantID, MerchantInfo.TaskID)
        end
    
        -- 商人系统提示
        local function PlayMissionTips()
            MsgTipsUtil.ShowTipsByID(MysterMerchantDefine.TipID.EnterArea)
            local TipDuration = MysterMerchantUtils.GetTipDurationByID(MysterMerchantDefine.TipID.EnterArea)
            if MerchantInfo.ReadyStartTaskTimer then
                self:UnRegisterTimer(MerchantInfo.ReadyStartTaskTimer)
                MerchantInfo.ReadyStartTaskTimer = nil
            end
            MerchantInfo.ReadyStartTaskTimer = self:RegisterTimer(StartTask, TipDuration)
        end
        local Config = {Type = ProtoRes.tip_class_type.TIP_SYS_NOTICE, Callback = PlayMissionTips, Params = {}}
        _G.TipsQueueMgr:AddPendingShowTips(Config)
    end

    self:UpdateTaskInfo(self.MerchantID, TaskState, MerchantInfo.Progress)
    self.RequiredItemList, self.RequiredNumList = MysterMerchantUtils.GetRequiredItemList(MerchantInfo.TaskID)

    -- 播放气泡
    if TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
        self:PlayBubble(self.MerchantID, EBubbleType.FinishTask)
    else
        self:PlayBubble(self.MerchantID, EBubbleType.Default)
    end
end

-- 当离开任务区域
function MysterMerchantMgr:OnLeaveTaskRange(MerchantInfo)
    if MerchantInfo == nil then
        return
    end

    if MerchantInfo.ReadyStartTaskTimer then
        self:UnRegisterTimer(MerchantInfo.ReadyStartTaskTimer)
        MerchantInfo.ReadyStartTaskTimer = nil
    end

    local MerchantID = MerchantInfo.MerchantID
    if self.EnterHintArea_Record[MerchantID] == nil then
        return
    else
        self.EnterHintArea_Record[MerchantID] = nil
    end

    -- 隐藏右上方的大赛提醒UI
    self:ShowTaskInfoBar(false)
    MysterMerchantVM:OnLeaveTaskRange(MerchantInfo)
    
    --移除减速Debuff
    self:SendMsgRemoveStateReq(MerchantID)
end

---@type 新手引导系统解锁处理
function MysterMerchantMgr:OnCheckTutorial()
    local function OnTutorial()
        --发送新手引导触发获得物品触发消息
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.NearTargetField --新手引导触发类型
        EventParams.Param1 = TutorialDefine.NearTargetFieldType.Mysterybusinessman
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

-- 显示任务信息栏
function MysterMerchantMgr:ShowTaskInfoBar(IsShow)
    if MainPanelVM then
        MainPanelVM:SetMysterMerchantTaskVisible(IsShow)
    end
end

function MysterMerchantMgr:OnGameEventLeaveInteractionRange()
    self.EObjID = 0
end

--------------- 功能接口 ---------------
--是不是需要请求信息
--需要请求信息的，流程等回包后启动
--不需要请求信息的，直接启动流程
function MysterMerchantMgr:OnInteractiveClick(NpcId, NpcEntityId, InteractionID, Values)
    --self.Values = Values
    self.NPCID = NpcId
    self.NpcEntityId = NpcEntityId
    local FriendlinessLevel = MysterMerchantVM:GetFriendlinessLevel()
    if InteractionID == MysterMerchantDefine.EndInteractType.SubmitItems then 
        -- 提交货物
        self:ShowSubmitView()
    elseif InteractionID == MysterMerchantDefine.EndInteractType.Invest then 
        -- 冒险投资
        local function ShowInvestWindow()
            self:EndInteraction()
            local function AcceptInvest()
                self:SendMsgInvestReq(self.MerchantID)
            end
            local CurMerchantData = self:GetCurrActiveMerchant()
            local CostItemID = SCORE_TYPE.SCORE_TYPE_GOLD_CODE
            local ExpenditureNum = CurMerchantData and CurMerchantData.SpentCoin or 0
            local CurNum = ScoreMgr:GetScoreValueByID(CostItemID )
            local NoEnoughCostNum = ExpenditureNum > CurNum
            local CostColor = ""
            local RightBtnOpState = CommBtnColorType.Recommend
            if NoEnoughCostNum then
                CostColor = MysterMerchantDefine.TextColor.NoEnoughRedHex
                RightBtnOpState = CommBtnColorType.Normal
            else
                CostColor = MysterMerchantDefine.TextColor.Normal
                RightBtnOpState = CommBtnColorType.Recommend
            end
            local MoneyData = {
                ["Money1"] = {ScoreType = SCORE_TYPE.SCORE_TYPE_GOLD_CODE} --UIView = _G.UIViewID.RechargingMainPanel}
            }
            local Params = { CostItemID = CostItemID, CostNum = ExpenditureNum, CostColor = CostColor, RightBtnOpState = RightBtnOpState, MoneyData = MoneyData}
            _G.MsgBoxUtil:ShowMsgBoxTwoOp(
            LSTR(1110050), -- “冒险投资”
            string.format(LSTR(1110051), ExpenditureNum), -- "是否愿意投资500金币资助冒险团的旅程？"
            AcceptInvest, nil, 
            LSTR(1110052), -- "拒绝"
            LSTR(1110053), -- "投资"
            Params)
        end

        local DialogInfo = MysterMerchantUtils.GetMerchantDialogInfo(self.NPCID, FriendlinessLevel)
        local InvestDialogID = DialogInfo and DialogInfo.InvestDialogID -- 投资选项对话ID
        _G.NpcDialogMgr:PlayDialogLib(InvestDialogID, self.NpcEntityId, false, ShowInvestWindow)
    elseif InteractionID == MysterMerchantDefine.EndInteractType.Talk then
        -- 交谈
        local CurMerchantData = self:GetCurrActiveMerchant()
        local CurTaskID = CurMerchantData and CurMerchantData.TaskID
        local DialogID = 0
        if CurMerchantData and CurMerchantData.TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
            -- 播放任务完成对话
            local DialogInfo = MysterMerchantUtils.GetMerchantDialogInfo(self.NPCID, FriendlinessLevel)
            DialogID = DialogInfo and DialogInfo.FinishedDialogID or 0
        else
            -- 未完成任务情况下的默认对白（与任务相关）
            local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(CurTaskID)
            DialogID = TaskInfo and TaskInfo.DefaultDialogID or 0 
        end
        _G.NpcDialogMgr:PlayDialogLib(DialogID, self.NpcEntityId)
    end
end

--- @type 点击一级交互开启对话
function MysterMerchantMgr:OnSingleInteractive(EntranceItem)
	if EntranceItem == nil then
		return
	end
    
	self.EntranceItem = EntranceItem
    self.EObjID = EntranceItem.ListID
    local IsMysterMerchant = MysterMerchantUtils.IsMysterMerchant(self.EntranceItem.ResID)
    if not IsMysterMerchant then
        return
    end
    self:ClearInteractFuncList()

    if self.TaskStatus == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then
        --查询商品 
        self:SendMsgGetGoodsInfo(self.MerchantID) 

        -- 播放对白
        local FriendlinessLevel = MysterMerchantVM:GetFriendlinessLevel()
        local DialogInfo = MysterMerchantUtils.GetMerchantDialogInfo(self.EntranceItem.ResID, FriendlinessLevel)
        if self.InvestStatus == MERCHANT_INVEST_STATUS.INVEST_MERCHANT_STATUS_WAIT_RECEIVE then
            -- 领取投资奖励
            local function OnPlayDialogFinished()
                self:SendMsgInvestRewardReq(self.MerchantID)
            end
            _G.NpcDialogMgr:OverrideStatePending()
            local InvestRewardDialogID = DialogInfo and DialogInfo.InvestRewardDialogID or 0 -- 投资奖励对话ID
            _G.NpcDialogMgr:PlayDialogLib(InvestRewardDialogID, EntranceItem.EntityID, false, OnPlayDialogFinished)
        else
            -- 播放默认对白
            _G.NpcDialogMgr:OverrideStatePending()
            local DefaultDialogID = DialogInfo and DialogInfo.DialogID or 0 -- 默认对白（完成任务情况下的一级交互对话ID）
            _G.NpcDialogMgr:PlayDialogLib(DefaultDialogID, EntranceItem.EntityID, false)
        end
    end

end

function MysterMerchantMgr:ClearInteractFuncList()
    _G.InteractiveMgr.CurInteractEntrance:OnInit()
end

--- @type 结束交互
function MysterMerchantMgr:EndInteraction()
	_G.NpcDialogMgr:EndInteraction()
end

---@type 是否显示提交货物选项
function MysterMerchantMgr:IsShowGoodsSubmit()
    --未完成且需要提交货物
    local TaskInfoVM = MysterMerchantVM:GetTaskInfoVM()
    local TaskStatus = TaskInfoVM and TaskInfoVM:GetTaskStatus()
    local IsPickupTask = TaskInfoVM.TaskType == ETaskType.InteractiveTypePickUpCargo
    local IsHaveTaskItem = self:GetOwnTaskItemNum() > 0
    return IsPickupTask and IsHaveTaskItem and TaskStatus ~= MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH
end

---@type 是否准备禁用商人
function MysterMerchantMgr:IsPendingDisableMerchant(EntityID)
    if EntityID == nil then
        return false
    end

    local NPCResID = ActorUtil.GetActorResID(EntityID)
    if not MysterMerchantUtils.IsMysterMerchant(NPCResID) then
        return false
    end
    
    local CurrActiveMerchant = self:GetCurrActiveMerchant()
    local MerchantNPCResID = CurrActiveMerchant and CurrActiveMerchant.NPCID or 0
    local MerchantEntityID = ActorUtil.GetActorEntityIDByResID(MerchantNPCResID)
    local IsPendingDisable = CurrActiveMerchant and CurrActiveMerchant.IsPendingDisable
    if MerchantEntityID ~= EntityID then
        return false
    end
    return not self:CanInteract() or IsPendingDisable
end

---@type 商人是否可交互
function MysterMerchantMgr:CanInteract()
    local CurrActiveMerchant = self:GetCurrActiveMerchant()
    local TaskState = CurrActiveMerchant and CurrActiveMerchant.TaskState
    local IsFinishTask = TaskState == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH
    local TaskType = CurrActiveMerchant and CurrActiveMerchant.TaskType
	if TaskType == ETaskType.InteractiveTypeKillMonster
		or TaskType == ETaskType.InteractiveTypeRepelMonster then
        return IsFinishTask
	end
    return true
end

---@type 背包拥有任务物品数量
function MysterMerchantMgr:GetOwnTaskItemNum()
    -- 暂时只有一种任务物品
    local OwnedNum = 0
    for i, _ in ipairs(self.RequiredItemList) do
        self:ProcessOnRequiredIndex(i, function(ItemData)
            OwnedNum = OwnedNum + ItemData.Num
        end)
    end
    return OwnedNum
end

---@type 任务剩余所需物品数
function MysterMerchantMgr:GetActualRequireTaskItemNum()
    -- 暂时只有一种任务物品
    local OwnedNum = 0
    for i, _ in ipairs(self.RequiredItemList) do
        self:ProcessOnRequiredIndex(i, function(ItemData)
            OwnedNum = OwnedNum + ItemData.Num
        end)
    end
    return OwnedNum
end
---@type 是否显示神秘商品选项
function MysterMerchantMgr:IsShowMysterMerchant()
    local TaskInfoVM = MysterMerchantVM:GetTaskInfoVM()
    local TaskStatus = TaskInfoVM and TaskInfoVM:GetTaskStatus()
    return TaskStatus == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH
end

---@type 是否显示冒险投资选项
function MysterMerchantMgr:IsShowInvestOption()
    local TaskInfoVM = MysterMerchantVM:GetTaskInfoVM()
    local TaskStatus = TaskInfoVM and TaskInfoVM:GetTaskStatus()
    local IsFinishTask = TaskStatus == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH
    return IsFinishTask and self.InvestStatus == MERCHANT_INVEST_STATUS.INVEST_MERCHANT_STATUS_TRIGGER --触发投资
end

---@type 显示商店界面
function MysterMerchantMgr:ShowMysterShopView()
    _G.UIViewMgr:ShowView(_G.UIViewID.MysterShopMainPanelView)
end

---@type 显示任务结算界面
function MysterMerchantMgr:ShowMysterSettlementView()
    _G.UIViewMgr:ShowView(_G.UIViewID.MysterMerchantSettlementView)
end

---@type 显示提交货物界面
function MysterMerchantMgr:ShowSubmitView()
    local RequiredItemValues = {}
    
    self.OwnedItemDataList = {}
    self.OwnedItemCountList = {}
    for i, ItemResID in ipairs(self.RequiredItemList) do
        local RequiredNum = self.RequiredNumList[i] or 0
        local CurrActiveMerchant = self:GetCurrActiveMerchant()
        if CurrActiveMerchant then
            RequiredNum = RequiredNum - CurrActiveMerchant.SubmitNum
        end
        local Params = {
            GID = -1,
            ResID = ItemResID,
            Num = RequiredNum,
        }
        table.insert(RequiredItemValues, Params)

        local OwnedNum = 0
        self:ProcessOnRequiredIndex(i, function(ItemData)
            OwnedNum = ItemData.Num
            table.insert(self.OwnedItemDataList, ItemData)
        end)
        self.OwnedItemCountList[i] = math.min(OwnedNum, RequiredNum)
    end

    self.ItemSubmitVMItem = ItemSubmitVM.CreateForQuestTarget(self)
    if self.ItemSubmitVMItem then
        self.ItemSubmitVMItem:InitRequiredItem(RequiredItemValues)
        self.ItemSubmitVMItem:UpdateOwnedItem(self.OwnedItemDataList)
        self.ItemSubmitVMItem.CheckReadyToSubmit = function()
            if self.OwnedItemDataList == nil or #self.OwnedItemDataList < 1 then
                return false
            end
            return self.OwnedItemDataList[1].Num > 0
        end
        local Params = {
            ViewModel = self.ItemSubmitVMItem,
        }
        _G.UIViewMgr:ShowView(_G.UIViewID.NewQuestPropPanel, Params)
    end
end

---@type 提交货物
function MysterMerchantMgr:SendFinish(CollectItem)
    self:EndInteraction()
    for GID, Num in pairs(CollectItem) do
        local ItemData = BagMgr:GetItemDataByGID(GID)
        if ItemData then
            local ItemResID = ItemData.ResID or 0
            self:SendMsgSubmitTask(self.MerchantID, ItemResID, Num)
        else
            FLOG_ERROR("MysterMerchantMgr:提交货物在背包中找不到"..GID)
        end
    end
end

---@param Index int32 需求物品索引
---@param Callback function 回调函数，以ItemVM为参数
function MysterMerchantMgr:ProcessOnRequiredIndex(Index, Callback)
    local ItemResID = self.RequiredItemList[Index] or 0
    if ItemResID == nil then return end
    local ItemList = BagMgr:FilterItemByCondition(function(Item)
        return Item.ResID == ItemResID
    end)

    for _, ItemData in ipairs(ItemList) do
        Callback(ItemData)
    end
end

function MysterMerchantMgr:CheckCanFinish()
    -- 现在改成可以随时提交了，所以注释
    -- for index, _ in ipairs(self.RequiredItemList) do
    --     local OwnedItemCount = self.OwnedItemCountList[index] or 0
    --     local RequiredItemNum = self.RequiredNumList[index]
    --     if OwnedItemCount < RequiredItemNum then
    --         return false
    --     end
    -- end
    
    return true
end

function MysterMerchantMgr:UpdateTaskInfo(MerchantID, TaskStatus, Progress)
    self.TaskStatus = TaskStatus
    local CurMerchantData = self.CurrActiveMerchantList[MerchantID]
    if CurMerchantData then
        CurMerchantData.Progress = Progress or CurMerchantData.Progress
    end
    local TaskID = CurMerchantData and CurMerchantData.TaskID
    local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
    if TaskInfo == nil then
        return
    end

    TaskInfo.Status = TaskStatus
    TaskInfo.MerchantID = MerchantID
    TaskInfo.Progress = Progress
    TaskInfo.EndTime = CurMerchantData and CurMerchantData.EndTime
    MysterMerchantVM:UpdateTaskInfo(TaskInfo)
    self:OnUpdateMerchantHudIcon(MerchantID, TaskStatus)
end

---@type 独享商人位面副本进度更新
function MysterMerchantMgr:OnPWorldStageInfoUpdate()
    local CurrProcess = _G.PWorldStageMgr.CurrProcess
    if self.MerchantID and self.MerchantID > 0 then
        self:UpdateTaskInfo(self.MerchantID, self.TaskStatus, CurrProcess)
    else
        -- 进游戏就在副本里的情况
        local BaseInfo = _G.PWorldMgr.BaseInfo
        self.CurrMapResID = BaseInfo.CurrMapResID
        self.PWorldResID = BaseInfo.CurrPWorldResID
        if _G.PWorldMgr:CurrIsInMerchant() then
            local TaskID = MysterMerchantUtils.GetTaskIDByPworldID(self.PWorldResID, self.CurrMapResID)
            local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
            if TaskInfo then
                TaskInfo.Status = MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED
                TaskInfo.MerchantID = 0
                TaskInfo.Progress = CurrProcess
                TaskInfo.EndTime = 0
                MysterMerchantVM:UpdateTaskInfo(TaskInfo)
            end
        end 
    end
end

---@type 获取当前商人列表
function MysterMerchantMgr:GetCurrActiveMerchantList()
    return self.CurrActiveMerchantList
end

---@type 获取当前商人
function MysterMerchantMgr:GetCurrActiveMerchant()
    return self.CurrActiveMerchantList and self.CurrActiveMerchantList[self.MerchantID]
end

function MysterMerchantMgr:ClearInteractFuncList()
    _G.InteractiveMgr.CurInteractEntrance:OnInit()
end


----------------------------------------region NetMsg ----------------------------------------


---@type 获取神秘商人基础信息请求
function MysterMerchantMgr:SendMsgGetMysterMerchantInfo()
    local MsgID = CS_CMD.CS_CMD_MYSTER_MERCHANT
    local SubMsgID = MERCHANT_CMD.QueryMerchantData

    local MsgBody = {}
    MsgBody.Cmd = MERCHANT_CMD.QueryMerchantData
    MsgBody.QueryMerchantData = {
        MapResID = self.CurrMapResID
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 基础信息
function MysterMerchantMgr:OnNetMsgMysterMerchantBase(MsgBody)
    if MsgBody == nil then
        return
    end
    local MerchantData = MsgBody.QueryMerchantData
    if MerchantData == nil then
        return
    end
    local LevelExp = MerchantData.LevelExp
    MysterMerchantVM:UpdateMerchantInfo(LevelExp)
end

---@type 查询商人地图数据请求
function MysterMerchantMgr:SendMsgQueryMerchantMapData()
    local MsgID = CS_CMD.CS_CMD_MYSTER_MERCHANT
    local SubMsgID = MERCHANT_CMD.QueryMerchantMapData

    local MsgBody = {}
    MsgBody.Cmd = MERCHANT_CMD.QueryMerchantMapData
    MsgBody.MerchantMapData = {
        MapResID = self.CurrMapResID
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 商人地图数据回包
function MysterMerchantMgr:OnNetMsgMerchantMapData(MsgBody)
    self.IsReceiveExclusiveData = false
    if MsgBody == nil then
        return
    end
    local MerchantMapData = MsgBody.MerchantMapData
    local MerchantDataList = MerchantMapData and MerchantMapData.MerchantData
    self:UpdateCurActiveMerchant(MerchantDataList)
    _G.EventMgr:SendEvent(EventID.LoadMysterMerchantRangeCheckData)
end

---@type 独享商人地图数据刷新
function MysterMerchantMgr:OnNetMsgExclMerchantMapRefresh(MsgBody)
    if MsgBody == nil or MsgBody.ExclusiveRefresh == nil then
        return
    end

    local MerchantData = MsgBody.ExclusiveRefresh.MerchantData
    self:UpdateMerchant(MerchantData)
    self.IsTriggerExclusiveTask = false
end

---@type 独享商人任务怪销毁成功
function MysterMerchantMgr:OnNetMsgExclusiveDestroyRsp()
    self.IsTriggerExclusiveTask = false
end

---@type 移除货物Debuff请求
function MysterMerchantMgr:SendMsgRemoveStateReq(MerchantID)
    if MerchantID == nil then
        return
    end

    local StateID = MysterMerchantUtils.GetOverWeightStateID()
    if not _G.BonusStateMgr:HasBonusStateMajor(StateID) then -- _G.SkillBuffMgr:IsBuffExist(DebufID)
        return
    end

    local MsgID = CS_CMD.CS_CMD_MYSTER_MERCHANT
    local SubMsgID = MERCHANT_CMD.MerchantBuffDestroy

    local MsgBody = {}
    MsgBody.Cmd = MERCHANT_CMD.MerchantBuffDestroy
    MsgBody.MerchantBuffDestroy = {
        MerchantID = MerchantID
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 触发商人任务请求
function MysterMerchantMgr:SendMsgTriggerTaskReq(MerchantID, TaskID)
    local MsgID = CS_CMD.CS_CMD_MYSTER_MERCHANT
    local SubMsgID = MERCHANT_CMD.TriggerMerchantTask
    local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
    local SceneResID = TaskInfo.SceneResID
	if TaskInfo.TaskType == ETaskType.InteractiveTypeKillMonster
		or TaskInfo.TaskType == ETaskType.InteractiveTypeRepelMonster then
        if SceneResID == nil or SceneResID <= 0 then
            FLOG_ERROR(string.format("商人任务表：未配置任务ID为%s的位面ID，请检查", TaskID))
            return
        end
	end
    local MsgBody = {}
    MsgBody.Cmd = MERCHANT_CMD.TriggerMerchantTask
    MsgBody.TriggerMerchantTask = {
        MerchantID = MerchantID,
        SceneResID = SceneResID
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 获取商品信息请求
function MysterMerchantMgr:SendMsgGetGoodsInfo(MerchantID)
    local MsgID = CS_CMD.CS_CMD_MYSTER_MERCHANT
    local SubMsgID = MERCHANT_CMD.QueryMerchantGoods

    local MsgBody = {}
    MsgBody.Cmd = MERCHANT_CMD.QueryMerchantGoods
    MsgBody.MerchantGoods = {
        MerchantID = MerchantID
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 商品信息
function MysterMerchantMgr:OnNetMsgMysterMerchantGoods(MsgBody)
    local GoodsInfo = MsgBody and MsgBody.MerchantGoods
    if GoodsInfo == nil then
        return
    end
    MysterMerchantVM:UpdateGoodsInfo(GoodsInfo.GoodsList)
end

---@type 投资请求
function MysterMerchantMgr:SendMsgInvestReq(InMerchantID)
    local MsgID = CS_CMD.CS_CMD_MYSTER_MERCHANT
    local SubMsgID = MERCHANT_CMD.InvestMerchant

    local MsgBody = {}
    MsgBody.Cmd = MERCHANT_CMD.InvestMerchant
    MsgBody.InvestMerchant = {
        MerchantID = InMerchantID
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 投资成功
function MysterMerchantMgr:OnNetMsgInvestRsp()
    FLOG_INFO("冒险投资成功!!!!!!!!!!!!!!!!")
    _G.MsgTipsUtil.ShowTipsByID(MysterMerchantDefine.TipID.InvestSuccess)
    self.InvestStatus = MERCHANT_INVEST_STATUS.INVEST_MERCHANT_STATUS_INVESTED
    local CurrActiveMerchant = self:GetCurrActiveMerchant()
    if CurrActiveMerchant then
        CurrActiveMerchant.InvestStatus = self.InvestStatus
    end
    self:EndInteraction()
    self:ClearInteractFuncList()
end

---@type 投资奖励领取
function MysterMerchantMgr:SendMsgInvestRewardReq(InMerchantID)
    local MsgID = CS_CMD.CS_CMD_MYSTER_MERCHANT
    local SubMsgID = MERCHANT_CMD.ReceiveInvestRewards

    local MsgBody = {}
    MsgBody.Cmd = MERCHANT_CMD.ReceiveInvestRewards
    MsgBody.ReceiveRewards = {
        MerchantID = InMerchantID
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 投资奖励回包
function MysterMerchantMgr:OnNetMsgInvestRewardRsp(MsgBody)
    local RewardInfo = MsgBody and MsgBody.ReceiveRewards
    local MerchantID = RewardInfo and RewardInfo.MerchantID or self.MerchantID
    self.InvestStatus = MERCHANT_INVEST_STATUS.INVEST_MERCHANT_STATUS_RECEIVED
    local CurrActiveMerchant = self.CurrActiveMerchantList and self.CurrActiveMerchantList[MerchantID]
    if CurrActiveMerchant then
        CurrActiveMerchant.InvestStatus = self.InvestStatus
    end
end

---@type 购买商品请求
function MysterMerchantMgr:SendMsgBuyGoodsReq(GoodsID, Count, MerchantID)
    local MsgID = CS_CMD.CS_CMD_MYSTER_MERCHANT
    local SubMsgID = MERCHANT_CMD.BuyMerchantGoods

    local MsgBody = {}
    MsgBody.Cmd = MERCHANT_CMD.BuyMerchantGoods
    MsgBody.BuyMerchantGoods = {
        MerchantID = self.MerchantID,
        GoodsID = GoodsID, -- 商品ID
        Num = Count, --商品数量
    }
    self.BuyGoodsID = GoodsID
    self.BuyNum = Count
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 购买商品成功
function MysterMerchantMgr:OnNetMsgBuyGoodsRsp()
    if self.BuyGoodsID and self.BuyNum then
        local GoodsInfo = {
            GoodsID = self.BuyGoodsID,
            BuyNum = self.BuyNum,
        }
        MysterMerchantVM:UpdateGoodsInfoAfterBuy(GoodsInfo)
    end
end

---@type 提交任务请求
function MysterMerchantMgr:SendMsgSubmitTask(MerchantID, ItemID, ItemNum)
    local MsgID = CS_CMD.CS_CMD_MYSTER_MERCHANT
    local SubMsgID = MERCHANT_CMD.SubmitMerchantTask

    local MsgBody = {}
    MsgBody.Cmd = MERCHANT_CMD.SubmitMerchantTask
    MsgBody.SubmitMerchantTask = {
        MerchantID = MerchantID,
        Item = {
            ItemID = ItemID,
            Num = ItemNum,
        }
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 提交任务成功
function MysterMerchantMgr:OnNetMsgSubmitTaskSuccess(MsgBody)
    local SubmitTaskRsp = MsgBody and MsgBody.SubmitMerchantTask
    if SubmitTaskRsp == nil then
        return
    end
    local MerchantID = SubmitTaskRsp.MerchantID
    local CurrActiveMerchant = self.CurrActiveMerchantList[MerchantID]
    if CurrActiveMerchant == nil then
        return
    end

    local MerchantTask = SubmitTaskRsp.Task
    if MerchantTask == nil then
        return
    end

    -- 用这个判断任务是否完成(后台说的...)
    local TaskFinishTime = math.floor(MerchantTask.TaskFinishTime/1000) -- 任务完成时间，用于计算商人回收时间
    local ExpireTime = math.floor(SubmitTaskRsp.ExpireTime and SubmitTaskRsp.ExpireTime/1000)-- 商人回收时间|任务完成才会下发
    -- 任务未完成
    if TaskFinishTime <= 0 then
        CurrActiveMerchant.SubmitNum = MerchantTask.SubmitNum
        return
    end
    
    -- 任务完成
    local LevelExp = SubmitTaskRsp.LevelExp -- 总的友好度
    MysterMerchantVM:UpdateMerchantInfo(LevelExp)
    local InvestData = SubmitTaskRsp.InvestData -- 投资信息|没触发就不会返回
    self.InvestStatus = InvestData and InvestData.InvestStatus or 0
    local SpentCoin = InvestData and InvestData.SpentCoin
    CurrActiveMerchant.InvestStatus = self.InvestStatus
    CurrActiveMerchant.SpentCoin = SpentCoin
    CurrActiveMerchant.TaskState = MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH
    if CurrActiveMerchant.MerchantType == MERCHANT_TYPE.MysteryMerchantTypeExclusive then
        CurrActiveMerchant.EndTime = ExpireTime or TaskFinishTime
        local PointID = CurrActiveMerchant.MerchantPointID
        self:RemoveMerchantCountDown(CurrActiveMerchant, CurrActiveMerchant.EndTime, PointID) -- 在副本外，任务完成后需要计时回收独享商人
    end
    self:OnRemoveCollectItemAll(MerchantID) --隐藏采集物
    if not _G.PWorldMgr:CurrIsInMerchant() then
        self:ShowMysterSettlementView()
    end
    self:UpdateTaskInfo(MerchantID, MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH)
    self:PlayBubble(MerchantID, EBubbleType.FinishTask)
    self:PlayActionTimeline(MerchantID, EATLType.Saved)

end

---@type 任务进度刷新
function MysterMerchantMgr:OnNetMsgMerchantTaskProgressRsp(MsgBody)
    if MsgBody == nil or MsgBody.TaskProgress == nil then
        return
    end
    local TaskProgress = MsgBody.TaskProgress
    local InvestData = TaskProgress and TaskProgress.InvestData
    self.InvestStatus = InvestData and InvestData.InvestStatus or 0
    local SpentCoin = InvestData and InvestData.SpentCoin
    local TaskStatus = TaskProgress.Status
    local MerchantID = TaskProgress.MerchantID
    local CurrActiveMerchant = self.CurrActiveMerchantList[MerchantID]
    if self.TaskStatus ~= TaskStatus and TaskStatus == MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH then --如果任务完成
        if not _G.PWorldMgr:CurrIsInMerchant() then
            self:ShowMysterSettlementView()
        end
        self:OnRemoveCollectItemAll(MerchantID) --隐藏采集物
        self:OnReomveMonsters(MerchantID)
        self:PlayBubble(MerchantID, EBubbleType.FinishTask)
        self:PlayActionTimeline(self.MerchantID, EATLType.Saved)
        if CurrActiveMerchant then
            CurrActiveMerchant.IsPendingDisable = false
        end
    end

    if CurrActiveMerchant then
        CurrActiveMerchant.TaskState = TaskStatus
        CurrActiveMerchant.InvestStatus = self.InvestStatus
        CurrActiveMerchant.SpentCoin = SpentCoin
    end
    self:UpdateTaskInfo(MerchantID, TaskStatus, TaskProgress.Progress)
end

function MysterMerchantMgr:GetTaskState(TaskID, Progress)
    local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
    local MaxNum = TaskInfo.FinishNum
    if Progress >= MaxNum then
        if TaskInfo.TaskType == ETaskType.InteractiveTypePickUpCargo or
            TaskInfo.TaskType == ETaskType.InteractiveTypeKillMonster then
            return MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_WAIT_SUBMIT
        else
            return MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_FINISH
        end
    else
        return MERCHANT_TASK_STATUS.MERCHANT_TASK_STATUS_UNFINISHED
    end
end

--endregion


---@type 获取友好度信息
function MysterMerchantMgr:GetFriendlinessInfo()
    local CurFriendlinessExp = MysterMerchantVM:GetFriendlinessEXPTotal()
    if CurFriendlinessExp then
        return MysterMerchantUtils.GetFriendlinessLevelInfo(CurFriendlinessExp)
    end
end

---@type 是否解锁友好度
function MysterMerchantMgr:IsUnlockFriendliness()
    local CurFriendlinessExp = MysterMerchantVM:GetFriendlinessEXPTotal()
    return CurFriendlinessExp > 0
end

return MysterMerchantMgr