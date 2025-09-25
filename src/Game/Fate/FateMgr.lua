local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local GlobalCfgTable = require("TableCfg/GlobalCfg")
local FateAchievementCfgTable = require("TableCfg/FateAchievementCfg")
local FateGeneratorCfgTable = require("TableCfg/FateGeneratorCfg")
local FateInsidePromptTable = require("TableCfg/FateInsidePromptCfg")
local FateDefine = require("Game/Fate/FateDefine")
local MainPanelVM = require("Game/Main/MainPanelVM")
local UIViewID = require("Define/UIViewID")
local PworldCfg = require("TableCfg/PworldCfg")
local NpcCfgTable = require("TableCfg/NpcCfg")
local BagMgr = require("Game/Bag/BagMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")
local FateTargetCfg = require("TableCfg/FateTargetCfg")
local FateNpcDialogCfg = require("TableCfg/FateNpcDialogCfg")
local DialogCfg = require("TableCfg/DialogCfg")
local FateGuardCfg = require("TableCfg/FateGuardCfg")
local FateModelParamCfg = require("TableCfg/FateModelParamCfg")
local MapCfg = require("TableCfg/MapCfg")
local UIViewMgr = require("UI/UIViewMgr")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local ItemUtil = require("Utils/ItemUtil")
local UserDataID = require("Define/UserDataID")
local HUDType = require("Define/HUDType")
local FateNpcEntity = require("Game/Fate/FateNpcEntity")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local PathMgr = require("Path/PathMgr")
local CommonUtil = require("Utils/CommonUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local FateEventCfg = require("TableCfg/FateEventCfg")
local FateHighRiskCfg = require("TableCfg/FateHighRiskCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local FateBattleRuneCfg = require("TableCfg/FateBattleRuneCfg")
local BuffCfg = require("TableCfg/BuffCfg")
local FateForlornMaidenCfg = require("TableCfg/FateForlornMaidenCfg")
local PuzzleDefine = require("Game/NewBieGame/Puzzle/PuzzleDefine")
local EmotionContentCfg = require("TableCfg/EmotionContentCfg")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local FateAchievementRewardCfg = require("TableCfg/FateAchievementRewardCfg")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local ChatMgr = require("Game/Chat/ChatMgr")
local EffectUtil = require("Utils/EffectUtil")

local UAudioMgr = nil
local LootMgr = nil

local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_FATE_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
local FLOG_ERROR = _G.FLOG_ERROR
local EActorType = _G.UE.EActorType
local FateTipsCheckTimeSpan = 0.5
local FateNotExitErrorCode = 334035
local FateNpcErrorCode = 334036

local FateTipsType = {
    MainTitleTips = 1, -- 大标题文字
    HighRiskInfoTips = 2, -- 高危FATE的信息TIPS
    LevelLowMentionTips = 3, -- 低等级提示
    SpecialTextTips = 4, -- 特殊情况提示文字
    JoinFateMentionTips = 5, -- 加入或者等级同步提示
    NormalTips = 6, -- 其他普通类型的
}

local FLOG_INFO = nil
local PWorldMgr = nil
local NpcDialogMgr = nil
local ActorMgr = nil
local MapEditDataMgr = nil
local ClientVisionMgr = nil
local LevelText = "{Level}"
local FateRuneNotJoinTipsTimeSpan = 2 -- 战场符文未参加飘字提示间隔
local FateRuneNotJoinTipsID = 307105 -- 战场符文未参加飘字
local PuzzleFinishedMsgID = 334016
local ELevelSyncState = {
    None = 0,
    NotSynchronized = 1,
    Synchronized = 2,
    NotJoin = 3,
    Join = 4
}

local EffectPath1 = "VfxBlueprint'/Game/Assets/Effect/Particles/Fate/VBP/BP_FATE_NPC_circle_1.BP_FATE_NPC_circle_1_C'"
local EffectPath2 = "VfxBlueprint'/Game/Assets/Effect/Particles/Fate/VBP/BP_Fate_m_2_Deform.BP_Fate_m_2_Deform_C'"
local EffectPath3 = "VfxBlueprint'/Game/Assets/Effect/Particles/Fate/VBP/BP_Fate_m_1_Born.BP_Fate_m_1_Born_C'"
--local EffectPath4 = "VfxBlueprint'/Game/Assets/Effect/Particles/Fate/VBP/BP_FATE_NPC_circle_1.BP_FATE_NPC_circle_1_C'"

local NotBattleJobTipsID = 307101 -- 点击参与或者同步等级时，提示不是战斗职业
local AchievementCountInFate = 4 -- 一个FATE的成就数量，默认是4个
local HighRiskSystemNoticeID = 351003 -- 高危FATE的系统通知ID

local LostLadyCheckDistance = 2000 -- 迷失少女的检测距离
local FateMgr = LuaClass(MgrBase)
-------------- 外部接口 ----------------

---FateMgr.GetActiveFate 获取指定位置所在的Fate的信息
---@param Position _G.UE.FVEctor 传入位置
---@return FateTable Fate信息，不在Fate范围内时返回nil
---   FateTable.ID        FateID
---   FateTable.State     当前Fate状态，参考ProtoCS.FateState
---   FateTable.Progress  当前Fate进度
---   FateTable.StartTime 开始时间的时间戳
function FateMgr:GetActiveFateByPosition(Position)
    if (Position == nil) then
        FLOG_ERROR("传入的位置为空，请检查")
        return nil
    end

    if (self.CurrActiveFateList == nil) then
        return nil
    end

    for _, Fate in pairs(self.CurrActiveFateList) do
        local bWaitTrigger = Fate.State == ProtoCS.FateState.FateState_WaitNPCTrigger
        if (not bWaitTrigger) then
            local FateCenter = Fate.FateCenter
            local FateRadius = Fate.FateRadius or 0
            local FateHeight = Fate.FateHeight

            local Dist = FateRadius + 10
            if (FateCenter ~= nil) then
                -- 做容错处理，如果 FateCenter 为空，引擎会崩溃
                Dist = Position:Dist2D(FateCenter)
                local bInPosUpZ = Position.Z <= (FateCenter.Z + FateHeight)
                local bInPosDownZ = Position.Z >= (FateCenter.Z - FateHeight)
                local bInDist = Dist <= FateRadius
                local InRange = bInPosUpZ and bInPosDownZ and bInDist
                if InRange then
                    return Fate
                end
            else
                FLOG_ERROR("FateCenter 为空，请检查 !")
            end
        end
    end
    return nil
end

function FateMgr:InternalCreateDanceEobj(InListID)
    if (self.FateDanceHideEobjMap == nil) then
        self.FateDanceHideEobjMap = {}
    end
    local TargetEntityID = self.FateDanceHideEobjMap[InListID]
    if (TargetEntityID ~= nil) then
        return
    end

    local ListID = InListID
    local MapEditorData = _G.ClientVisionMgr:GetEditorDataByEditorID(ListID, "EObj")
    if (MapEditorData ~= nil) then
        TargetEntityID = _G.ClientVisionMgr:DoClientActorEnterVision(
            ListID,
            MapEditorData,
            _G.MapEditorActorConfig.EObj,
            MapEditorData.ResID
        )
    else
        _G.FLOG_ERROR("ClientVisionMgr:GetEditorDataByEditorID() 失败， ID是:%s", tostring(ListID))
        return
    end

    if (TargetEntityID ~= nil) then
        self.FateDanceHideEobjMap[InListID] = TargetEntityID
    else
        _G.FLOG_ERROR("无法获取目标 Actor ，EntityID 是: %s", TargetEntityID)
    end
end

function FateMgr:InternalPlayDanceNpcHideEffect(InListID)
    local TargetEntityID = self.FateDanceHideEobjMap[InListID]
    if (TargetEntityID == nil) then
        self:InternalCreateDanceEobj(InListID)
        TargetEntityID = self.FateDanceHideEobjMap[InListID]
        if (TargetEntityID == nil) then
            _G.FLOG_ERROR("FateMgr:InternalPlayDanceNpcHideEffect 错误，TargetEntityID为空, InListID : %s", InListID)
            return
        end
    end

    local TargetActor = ActorUtil.GetActorByEntityID(TargetEntityID)
    if (TargetActor == nil) then
        _G.FLOG_ERROR("无法获取目标 Actor ，EntityID 是: %s", TargetEntityID)
        return
    end

    local EffectPos = TargetActor:FGetActorLocation()
    local Actor = TargetActor
    local VfxParameter = _G.UE.FVfxParameter()
    VfxParameter.VfxRequireData.EffectPath = EffectPath2
    VfxParameter.PlaySourceType = _G.UE.EVFXPlaySourceType.PlaySourceType_UVfxComponent
    VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(
        _G.UE.FQuat(), EffectPos, _G.UE.FVector(1,1,1)
    )
    VfxParameter:SetCaster(Actor, 0, _G.UE.EVFXAttachPointType.AttachPointType_Max, 0)
    local VfxID = EffectUtil.PlayVfx(VfxParameter)
    _G.FLOG_INFO("播放特效返回的VFXID : %s", VfxID)
end

function FateMgr:IsInActiveFate(Position)
    local TargetFate = self:GetActiveFateByPosition(Position)
    return TargetFate ~= nil
end

---FateMgr.GetActiveFate 获取指定FateID的Fate信息
---@param FateID number 传入FateID
---@return  FateTable Fate信息，找不到时返回nil
function FateMgr:GetActiveFate(FateID)
    local CurrentFate = self.CurrActiveFateList[FateID]
    if (CurrentFate == nil) then
        return nil
    end

    -- 这里要判断一下，如果已经结束了，那么也返回空
    local bFinished = CurrentFate.State == ProtoCS.FateState.FateState_Finished
    if (bFinished) then
        return nil
    end

    return CurrentFate
end

function FateMgr:GetActiveFateProgress(FateID)
    local Fate = self.CurrActiveFateList[FateID]
    if Fate ~= nil then
        return Fate.Progress
    end
    return 0
end

--- func desc
---@param InMapID

--- func desc
---@param InMapID int32 地图关联表中的地图ID
---@param InFateMapInfoTable Table, 保存了 MapID 包含的所有 FateID， 外部可以自己保存一下，避免每次遍历表格
---@param InFateIDToMapTable Table, 保存了 FateID 对应的 MapID , 外部自己保存一下，避免每次遍历表格
function FateMgr:GetAchievementInfoByMapID(InMapID, InFateMapTable, InFateIDToMapTable)
    if (InMapID == nil or InMapID <= 0) then
        return 0
    end

    local FinishedCount = 0
    local TotalCount = 0
    local FinalMapInfoTable = InFateMapTable
    local FinalFateIdToMapTable = InFateIDToMapTable
    if (FinalMapInfoTable == nil or FinalFateIdToMapTable == nil) then
        FinalMapInfoTable, FinalFateIdToMapTable = self:GatherMapFateStageInfo()
    end

    local FateIDList = FinalMapInfoTable[InMapID]
    if (FateIDList == nil) then
        _G.FLOG_ERROR("GetFinishedAchievementCountByMapID 无法获取FATE的地图数据，传入的 ID是" .. tostring(InMapID))
        return 0
    end

    for _, FateCfg in pairs(FateIDList) do
        local FateInfo = self:GetFateInfo(FateCfg.ID)
        if (FateInfo ~= nil and FateInfo.Achievement ~= nil) then
            for Idx, Event in ipairs(FateInfo.Achievement) do
                local bShowed = Event.Target ~= nil and Event.Progress ~= nil and Event.Target > 0 -- 是否被揭示
                local bFinish = bShowed and Event.Progress >= Event.Target
                if bFinish then
                    FinishedCount = FinishedCount + 1
                end
            end
        end

        TotalCount = TotalCount + AchievementCountInFate
    end

    return FinishedCount, TotalCount, FinalMapInfoTable, FinalFateIdToMapTable
end

function FateMgr:CheckIsFateNPC(InEntityID)
    local UserData = self:TryGetUserData(InEntityID)
    if (UserData == nil) then
        return false
    end

    local bHaveFateID = UserData.FateID ~= nil and UserData.FateID > 0
    return bHaveFateID
end

function FateMgr:CheckNpcFateState(InEntityID)
    local UserData = self:TryGetUserData(InEntityID)
    if (UserData == nil) then
        return ProtoCS.FateState.FateState_Invalid
    end

    local FateID = UserData.FateID or 0
    if (FateID <= 0) then
        return ProtoCS.FateState.FateState_Invalid
    end

    local Fate = self.CurrActiveFateList[FateID]
    if Fate == nil then
        return ProtoCS.FateState.FateState_Invalid
    end
    return Fate.State
end

function FateMgr:MapNavigateToFate(FateID)
    local FateGeneratorCfg = FateGeneratorCfgTable:FindCfgByKey(FateID)
    if FateGeneratorCfg == nil then
        return
    end

    local MapID = FateGeneratorCfg.MapID
    if MapID == nil then
        return
    end
    local MapDefine = require("Game/Map/MapDefine")
    _G.WorldMapMgr:ShowWorldMap(MapID, MapDefine.MapOpenSource.Fate)
end

function FateMgr:InternalLoadLostLadyResTable(InbForceReload)
    if (InbForceReload or self.LostLadyResIDTable == nil) then
        self.LostLadyResIDTable = {} -- 迷失少女的RESID表格
        local AllCfg = FateForlornMaidenCfg:FindAllCfg()
        for Key, Value in pairs(AllCfg) do
            self.LostLadyResIDTable[Value.ResID] = Key
        end
    end
end

-------------- 内部接口 -----------------
function FateMgr:OnInit()
    UAudioMgr = _G.UE.UAudioMgr.Get()
    LSTR = _G.LSTR
    LootMgr = require("Game/Loot/LootMgr")
    FLOG_INFO = _G.FLOG_INFO
    self.ELevelSyncState = ELevelSyncState -- 外部用到
    self.LevelLimitMax = 5
    self:ResetData()
    self:InternalLoadLostLadyResTable()
    self.NewFateIDListForShow = self:LoadNewTriggeredFateData()
    self.FakeFateWorldStatsForMonster = {
        {FateID = 227, Percent = 0, AvatarDone = false},
        {FateID = 239, Percent = 0, AvatarDone = false},
        {FateID = 221, Percent = 0, AvatarDone = false},
        {FateID = 226, Percent = 0, AvatarDone = false},
        {FateID = 225, Percent = 0, AvatarDone = false},
        {FateID = 237, Percent = 0, AvatarDone = false},
        {FateID = 240, Percent = 0, AvatarDone = false},
        {FateID = 220, Percent = 0, AvatarDone = false},
        {FateID = 229, Percent = 0, AvatarDone = false},
        {FateID = 231, Percent = 0, AvatarDone = false},
        {FateID = 235, Percent = 0, AvatarDone = false},
        {FateID = 222, Percent = 0, AvatarDone = false},
        {FateID = 463, Percent = 0, AvatarDone = false},
        {FateID = 464, Percent = 0, AvatarDone = false},
        {FateID = 475, Percent = 0, AvatarDone = false},
        {FateID = 479, Percent = 0, AvatarDone = false},
        {FateID = 480, Percent = 0, AvatarDone = false},
        {FateID = 484, Percent = 0, AvatarDone = false},
        {FateID = 490, Percent = 0, AvatarDone = false},
        {FateID = 493, Percent = 0, AvatarDone = false},
        {FateID = 494, Percent = 0, AvatarDone = false},
        {FateID = 499, Percent = 0, AvatarDone = false},
        {FateID = 500, Percent = 0, AvatarDone = false},
        {FateID = 503, Percent = 0, AvatarDone = false},
        {FateID = 505, Percent = 0, AvatarDone = false},
        {FateID = 506, Percent = 0, AvatarDone = false},
        {FateID = 507, Percent = 0, AvatarDone = false},
        {FateID = 508, Percent = 0, AvatarDone = false},
        {FateID = 245, Percent = 0, AvatarDone = false},
        {FateID = 257, Percent = 0, AvatarDone = false},
        {FateID = 265, Percent = 0, AvatarDone = false},
        {FateID = 261, Percent = 0, AvatarDone = false},
        {FateID = 333, Percent = 0, AvatarDone = false},
        {FateID = 314, Percent = 0, AvatarDone = false},
        {FateID = 322, Percent = 0, AvatarDone = false}
    }
end

-- 用于新手指引，获取当前图鉴选中的 FATE 是否已经开启
function FateMgr:IsFateArchiveCurSelectActive()
    if (self.CurArchiveSelectFateID == nil) then
        return false
    end

    local ServerInfo = self:GetFateInfo(self.CurArchiveSelectFateID)

    return ServerInfo ~= nil
end

function FateMgr:TryGetUserData(InEntityID)
    if (InEntityID == nil) then
        return nil
    end
    local TargetUserData = self.UserDataCacheMap[InEntityID]
    if (TargetUserData ~= nil) then
        if TargetUserData == {} then
            return nil
        end

        return TargetUserData
    end

    TargetUserData = ActorUtil.GetUserData(InEntityID, UserDataID.Fate)
    if (TargetUserData == nil) then
        self.UserDataCacheMap[InEntityID] = {}
        return nil
    end

    self.UserDataCacheMap[InEntityID] = TargetUserData
    return TargetUserData
end

function FateMgr:RemoveUserDataCache(InEntityID)
    if (self.UserDataCacheMap ~= nil) then
        self.UserDataCacheMap[InEntityID] = nil
    end
end

function FateMgr:ResetData(InExitWorldInsID, bNoSendMsg, bResetMapInfo)
    _G.FLOG_INFO("清理数据 : FateMgr:ResetData()")
    self.FateDanceHideEobjMap = {}
    if (self.TickForFateTipsViewID ~= nil) then
        self:UnRegisterTimer(self.TickForFateTipsViewID)
        self.TickForFateTipsViewID = nil
    end
    self.DancedNpcEntityIDTable = {} -- 庆典跳舞FATE，已经跳过的NPC记录
    self.CurFateDanceNpcEntityID = 0 -- 庆典跳舞FATE，当前跳的NPC记录
    self.FateTipsQueue = {} -- FATE提示TIPS的队列，确保都显示，并且有一个先后显示顺序
    self.FateTipsQueueCount = 0
    self.CurActiveFateTips = nil
    self.CurFateLeftTime = 0
    self.CurFateTimeInSec = 0
    self.HighRiskFateTableData = {}
    self.UserDataCacheMap = {} -- Key 是 EntityID，Value是UserData
    self:OnClearAllCollectItem()
    self:InternalCleanFateRune()
    self.CurArchiveSelectFateID = 0
    self.FateMapInfo = nil
    self.Fate2MapID = nil
    self.bShowRewardPanel = false
    self:CancelLevelSync(bNoSendMsg, InExitWorldInsID)
    self.FateAlreadyEndTable = {} -- 已经结束了的FATE，本地先检测，以防时间已经结束，但是服务器没有传过来
    self.bHasCheckDir = false
    self:InternalSetLevelSyncState(ELevelSyncState.None)
    self.EnterAreaFate = {}
    self.NewFateIDListForShow = {} -- 显示新发现FATE提示用
    self.AttackTipsRecordTime = 0
    self:SetCurrentFate(nil)
    self:InternalSetIsJoinFate(false)
    if (bResetMapInfo) then
        if (self.CurrActiveFateList ~= nil) then
            for Key, Value in pairs(self.CurrActiveFateList) do
                _G.EventMgr:SendEvent(EventID.FateEnd, Value)
            end
        end
    end
    self.CurrActiveFateList = {}

    -- 这里得处理一下，如果有NPC的话，先释放
    if (self.FateNpcList ~= nil) then
        for Key, Value in pairs(self.FateNpcList) do
            _G.UE.UActorManager:Get():RemoveClientActor(Value)
        end
    end

    self.FateNpcList = {}
    self.FateBossList = {}
    self.EnterArea_Record = {} -- 仅记录初次开启/重新登陆进入区域的fate
    self.EnterHintArea_Record = {}
    self:ResetGuardData()
    self.FateCfgCache = {}
    self.ItemCollectFateEObjShowList = {}
    self.LastFateState = nil
    self.ServerCurFateID = 0
    self.SelectedFateID = 0
    self.bHideFateArchive = false
    self.FateNpcEntityTable = {} -- key : fateid , value : List< key : entityid, value : FateNpcEntity>
    self.FateNpcEntityPool = {} -- FateNpcEntity 池
    self.FateArchiveShowMapID = 0
end

local function StringToTable(str)
    if not str or type(str) ~= "string" then
        return
    end

    local flag, result = xpcall(load("return " .. str), CommonUtil.XPCallLog)
    if flag then
        return result
    else
        return
    end
end

-- 读取本地的新发现的Fate
function FateMgr:LoadNewTriggeredFateData()
    local Ret = {}

    local Path = FateMgr.GetNewTriggerFilePath()
    local File = io.open(Path, "r")
    if not File then
        return Ret
    end
    local Text = File:read("*a")
    if not Text or "" == Text then
        File:close()
        return Ret
    end

    local T = StringToTable(Text)
    if not T then
        File:close()
        os.remove(Path)
        return Ret
    end

    Ret = T

    File:close()
    return Ret
end

-- 保存新发现的FATE数据
function FateMgr:SaveNewTriggeredFateData()
    local Text = _G.TableToString(self.NewFateIDListForShow)
    local FilePath = self.GetNewTriggerFilePath()
    local File = io.open(FilePath, "w")

    if File then
        if not File:write(Text) then
            File:close()
            os.remove(FilePath)
            return
        end

        File:flush()
        File:close()
    end
end

function FateMgr.GetSaveDirDir()
    -- 检查私聊缓存文件目录
    local Dir = string.format("%s/Fate/%s", _G.FDIR_PERSISTENT(), MajorUtil.GetMajorRoleID())
    if FateMgr.bHasCheckDir == false then
        if not PathMgr.ExistDir(Dir) then
            PathMgr.CreateDir(Dir, false)
        end

        FateMgr.bHasCheckDir = true
    end

    return Dir
end

function FateMgr.GetNewTriggerFilePath()
    -- 检查私聊缓存文件目录
    local FilePath = string.format("%s/NewTriggerFate.dat", FateMgr.GetSaveDirDir())

    return FilePath
end

function FateMgr:OnTriggerNewFate(InFateID)
    if (InFateID == nil or InFateID <= 0) then
        return
    end

    for Key, Value in pairs(self.NewFateIDListForShow) do
        if (Value == InFateID) then
            return
        end
    end

    table.insert(self.NewFateIDListForShow, InFateID)
    self:SaveNewTriggeredFateData()
end

function FateMgr:IsFateNewTrigger(InFateID)
    if (InFateID == nil) then
        _G.FLOG_ERROR("传入的 InFateID 为空，请检查")
        return false
    end
    for Key, Value in pairs(self.NewFateIDListForShow) do
        if (Value == InFateID) then
            return true
        end
    end
end

function FateMgr:ClearNewTriggerFateByFateID(InFateID)
    if (InFateID == nil) then
        _G.FLOG_ERROR("传入的 InFateID 为空，请检查")
        return
    end

    local RemoveItem = table.remove_item(self.NewFateIDListForShow, InFateID)
    if (RemoveItem ~= nil) then
        --有变化才需要保存
        self:SaveNewTriggeredFateData()
    end
end

function FateMgr:SetCurrentFate(InFate)
    local FateChanged = false
    if (self.CurrentFate ~= nil) then
        if (InFate ~= nil) then
            FateChanged = InFate.ID ~= self.CurrentFate.ID
        else
            FateChanged = true
        end
    else
        FateChanged = InFate ~= nil
    end

    if (InFate ~= nil) then
        _G.FLOG_INFO("[Fate] 设置当前FATE为: " .. InFate.ID)
    else
        _G.FLOG_INFO("[Fate] 设置当前FATE为 空")
    end

    self.CurrentFate = InFate

    if (self.CurrentFate == nil) then
        self.CurFateTimeInSec = 0
        self:InternalStopFateBGM()
    else
        local TempCfg = self:GetFateCfg(InFate.ID)
        if (TempCfg ~= nil) then
            self.CurFateTimeInSec = TempCfg.DurationM * 60
        end
    end

    if (FateChanged) then
        self.NeedForceShowInfo = true
    end
    self:RefreshLevelSyncState()
end

function FateMgr:CheckForFateDanceActivity()
end

function FateMgr:InternalStopFateBGM()
    if (self.FateBGMUniqueID ~= nil and self.FateBGMUniqueID > 0) then
        UAudioMgr:StopBGM(self.FateBGMUniqueID)
    end

    self.FateBGMUniqueID = 0
end

function FateMgr:OnEnd()
    self:ResetData()
end

function FateMgr:OnBegin()
    self.FateVM = require("Game/Fate/VM/FateVM")
    ClientVisionMgr = _G.ClientVisionMgr
    PWorldMgr = _G.PWorldMgr
    NpcDialogMgr = _G.NpcDialogMgr
    ActorMgr = _G.ActorMgr
    MapEditDataMgr = _G.MapEditDataMgr
    local LevelLimitMaxValue = GameGlobalCfg:FindValue(
        ProtoRes.Game.game_global_cfg_id.GAME_CFG_FATE_LEVEL_DIFF_MAX, "Value"
    ) -- 1006

    self.LevelLimitMax = LevelLimitMaxValue and LevelLimitMaxValue[1] or 0

    do
        local TempDataValue  = GameGlobalCfg:FindValue(
            ProtoRes.Game.game_global_cfg_id.GLOBAL_CFG_FATE_LOST_LADY_GUIDE_DIS, "Value"
        )
        LostLadyCheckDistance = TempDataValue and TempDataValue[1] or 2000
    end
    self:ResetData()
end

function FateMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_UPDATE, self.OnNetMsgUpdateFate)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_END, self.OnNetMsgFateEnd)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_GET_RECORD, self.OnNetMsgGetRecord)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_GET_ACH_MAP_REWARD, self.OnNetMsgGetAchMapReward)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_UPDATE_GATHER, self.OnNetMsgUpdateGather)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_GET_STATS, self.OnNetMsgGetFateStats)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_NPC_ACTION, self.OnNetMsgNpcAction)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_TRIGGER, self.OnFateTrigger)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_NPC_START, self.OnFateNpcStart)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_UPDATE_BATTLE_RUNE, self.OnFateRuneUpdate)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_START_PUZZLE, self.OnFateStartPuzzleRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_END_PUZZLE, self.OnFateEndPuzzleRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_NPC_DANCE_NOTIFY, self.OnFateNpcDance)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_DANCE, self.OnFateDanceRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_ENTER, self.OnFateEnterRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_EXIT, self.OnFateExitRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_DANCE_NPC_HIDDEN, self.OnFateDanceHideRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_ACTIVITY_RESULT, self.OnActivityResultHandle)
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_VISION,
        ProtoCS.CS_VISION_CMD.CS_VISION_CMD_USER_DATA_CHG,
        self.OnVisionUserDataChg
    )
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NAVMESH, 0, self.GuardOnFindPathNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgError)
end

function FateMgr:OnNetMsgError(MsgBody)
	local Msg = MsgBody
	if nil == Msg then
		return
	end

	local ErrorCode = Msg.ErrCode
    if (ErrorCode == FateNotExitErrorCode or ErrorCode == FateNpcErrorCode) then
        -- 这里是服务器返回的错误码，出现该错误码，直接清理本地数据，重新拉全部数据
        local bNoSendMsg = true
        local bResetMapInfo = true
        self:ResetData(nil, bNoSendMsg, bResetMapInfo)
        self:SendGetCurMapActiveFateList()
    end
end

function FateMgr:OnFateEnterRsp(InMsg)
    local RspMsg = InMsg.FateEnter
    if (RspMsg == nil) then
        _G.FLOG_ERROR("错误，FateMgr:OnFateEnterRsp 数据为空")
        return
    end

    -- 重要说明，和服务器协商过， RspMsg.Success一定为true，只有 true 的时候才下发
    self:InternalSetIsJoinFate(true) -- 加入了FATE，设置是否参加FATE 为 true

    if (self.CurrentFate ~= nil) then
        -- 加入FATE后需要处理的
        local FateCfg = self:GetFateCfg(self.CurrentFate.ID)
        if (FateCfg ~= nil) then
            local RealLevel = MajorUtil.GetTrueMajorLevel() -- 当前职业玩家真实的等级，同步前的，如50同步到20，返回的是50
            local TargetLevel = FateCfg.SyncMaxLv
            if (TargetLevel == nil or TargetLevel <= 0) then
                TargetLevel = FateCfg.Level + self.LevelLimitMax
            end
            if RealLevel > (TargetLevel) then
                local TipsStr = string.format(LSTR(190048), tostring(FateCfg.SyncMaxLv))-- 等级被同步到了%s级
                self:AppendFateTips(FateTipsType.JoinFateMentionTips, 3, TipsStr)
            else
                local TipsStr = LSTR(190050) -- 已正式加入危命任务
                self:AppendFateTips(FateTipsType.JoinFateMentionTips, 3, TipsStr)
            end
        else
            _G.FLOG_ERROR("错误，无法获取FATE表格数据，ID是:%s", self.CurrentFate.ID)
        end
    else
        _G.FLOG_ERROR("尝试加入当前的FATE,但是当前的FATE为空")
    end
end

function FateMgr:OnFateExitRsp(InMsg)
    local RspMsg = InMsg.FateExit
    if (RspMsg == nil) then
        _G.FLOG_ERROR("错误，FateMgr:OnFateExitRsp 数据为空")
        return
    end

    -- 重要说明，和服务器协商过， RspMsg.Success一定为true，只有 true 的时候才下发
    self:InternalSetIsJoinFate(false) -- 退出了FATE，设置是否参加FATE为 false

    if (self.bWaitExitAndReJoinFate) then
        -- 这里是重新加入的，玩家加入后，退出再登陆的，会自动加入退出前加入的FATE
        if (self.ServerCurFateID ~= nil and self.ServerCurFateID > 0) then
            self:RequireJoinFate(self.ServerCurFateID)
            self.ServerCurFateID = 0
        end
        self.bWaitExitAndReJoinFate = nil
    else
        -- 退出后需要显示的
        local SyncState = self:GetLevelSyncState()
        if (SyncState == ELevelSyncState.NotJoin) then
            local TipsStr = LSTR(190051) -- 已退出危命任务
            self:AppendFateTips(FateTipsType.JoinFateMentionTips, 3, TipsStr)
        else
            local TipsStr = LSTR(190049) -- 等级同步已解除
            self:AppendFateTips(FateTipsType.JoinFateMentionTips, 3, TipsStr)
        end
    end
end

function FateMgr:InternalShowMsgAfterJoinFate()
    if (self.CurrentFate == nil) then
        return
    end

    local SceneLevel = MajorUtil.GetMajorLevel() -- 场景中，当前职业显示的等级，同步后的，如50级同步到20，返回的是20
    local RealLevel = MajorUtil.GetTrueMajorLevel() -- 当前职业玩家真实的等级，同步前的，如50同步到20，返回的是50
end

function FateMgr:OnFateDanceHideRsp(InMsg)
    if (InMsg == nil or InMsg.FateDanceNpcHidden == nil) then
        _G.FLOG_ERROR("FateMgr:OnFateDanceHideRsp 出错，返回的数据为空，请检查")
        return
    end

    self:InternalPlayDanceNpcHideEffect(8800000)
    self:InternalPlayDanceNpcHideEffect(8800001)
    self:InternalPlayDanceNpcHideEffect(8800002)
end

function FateMgr:OnFateDanceRsp(InMsg)
    if (InMsg == nil or InMsg.FateDance == nil) then
        _G.FLOG_ERROR("FateMgr:OnFateDanceRsp 出错，返回的数据为空，请检查")
        return
    end

    if (InMsg.FateDance.Success) then
        local MsgID = 334030
        MsgTipsUtil.ShowTipsByID(MsgID)

        -- 关闭界面，并且记录一下交互的NPC是谁，到时候不弹出交互
        if (self.DancedNpcEntityIDTable == nil) then
            self.DancedNpcEntityIDTable = {}
        end

        if (self.CurFateDanceNpcEntityID~=nil and self.CurFateDanceNpcEntityID > 0) then
            self.DancedNpcEntityIDTable[self.CurFateDanceNpcEntityID] = 1
        end

        -- 关闭情感界面
        UIViewMgr:HideView(UIViewID.CommEasytoUseView)
    end
end

function FateMgr:OnActivityResultHandle(InMsg)
    if (InMsg == nil) then
        _G.FLOG_ERROR("错误，传入的数据 InMsg 为空，请检查")
        return
    end

    local Data = InMsg.FateActivityResult
    if (Data == nil) then
        _G.FLOG_ERROR("OnActivityResultHandle 出错，InMsg.FateActivityResult 为空，请检查")
        return
    end

    local TipsID = 334028
    MsgTipsUtil.ShowTipsByID(TipsID)
    self:RegisterTimer(
        function()
            _G.UIViewMgr:ShowView(UIViewID.FateActivityResultPanel, Data)
        end,
        3,
        0,
        1
    )
end

function FateMgr:OnFateNpcDance(InMsg)
    if (InMsg == nil) then
        _G.FLOG_ERROR("FateMgr:OnFateNpcDance 出错，传入的 InMsg 为错")
        return
    end

    local Data = InMsg.FateNpcDance
    if (Data == nil) then
        return
    end

    local TargetListID = Data.NpcListID
    local EmotionID = Data.EmotionID

    local TargetActor = ActorUtil.GetActorByTypeAndListID(_G.UE.EActorType.Npc, TargetListID)
    if (TargetActor == nil) then
        _G.FLOG_ERROR("无法找到NPC，ListID : "..tostring(TargetListID))
        return
    end

    local AttriComp = TargetActor:GetAttributeComponent()
    if (AttriComp  == nil) then
        _G.FLOG_ERROR("无法获取 GetAttributeComponent , List ID : "..tostring(TargetListID))
        return
    end

    local EntityID = AttriComp.EntityID

    _G.EmotionMgr:PlayEmotionIDFromEntityID(EmotionID, EntityID, true)

    -- 需要自定义一个头顶表现，不用情感系统的，那边只显示一个头顶图标，并且玩家可以设置是否显示
    local TipsDesc = _G.EmotionMgr:NoTargetTips(EntityID, EmotionID)

    local Params = {
        EmotionID = EmotionID,
        EntityID = EntityID,
        TipsDesc = TipsDesc
    }

    local TargetView = _G.UIViewMgr:FindView(UIViewID.FateEmoTipsPanelView)
    if (TargetView == nil) then
        TargetView = _G.UIViewMgr:ShowView(UIViewID.FateEmoTipsPanelView)
    else
        TargetView:ShowView()
    end

    TargetView:AppendNewEmoTips(Params)

    self:InternalCreateDanceEobj(8800000)
    self:InternalCreateDanceEobj(8800001)
    self:InternalCreateDanceEobj(8800002)
end

function FateMgr:OnFateEndPuzzleRsp(InMsg)
    if (InMsg == nil) then
        _G.FLOG_ERROR("FateMgr:OnFateEndPuzzle 出错，传入消息为空，请检查")
        return
    end

    local Data = InMsg.FateEndPuzzle
    local NpcListID = Data.NpcListID
    local bAddScore = Data.AddScore

    -- 这里做表现
    if (bAddScore) then
        -- 延迟做提示
        self:RegisterTimer(
            function()
                local TipsStr = LSTR(190142) -- 已完成拼图（%s/3）
                local FinalTipsStr = string.format(TipsStr, Data.FinishedCount)
                MsgTipsUtil.ShowTips(FinalTipsStr)
            end,
            6,
            0,
            1
        )
    end
end

function FateMgr:OnFateStartPuzzleRsp(InMsg)
    if (InMsg == nil) then
        return
    end
    local TargetData = InMsg.FateStartPuzzle
    if (TargetData.RoleFinished) then
        MsgTipsUtil.ShowTipsByID(PuzzleFinishedMsgID)
        return
    end
    local NpcListID = TargetData.NpcListID
    local EndTimeMS = TargetData.EndTimeMS
    if (EndTimeMS < 1000) then
        -- 小于1秒不开启了
        _G.FLOG_WARNING("拼图的结束时间小于1秒，不打开了，动画都播不完")
        return
    end
    local RemainTime = math.floor(EndTimeMS * 0.001) + 2 -- 有2秒的延迟
    if (RemainTime <=0) then
        -- 时间到了不开启
        return
    end

    if (_G.PuzzleMgr.IsPuzzling) then
        _G.FLOG_WARNING("当前正在进行游戏，不会在开启一次")
        return
    end

    _G.PuzzleMgr:EnterPuzzleGame(
        ProtoRes.Game.PuzzleGameType.PenguinJigsaw,
        TargetData.PuzzleID,
        RemainTime
    )
end

function FateMgr:OnNetworkReconnectLoginFinished()
    -- self:ResetData(nil, true, true)
    -- self:SendGetCurMapActiveFateList()
end

function FateMgr:FindItem(InTable, InElement, InElementName)
    if (InTable == nil) then
        return nil
    end
    for Key, Value in pairs(InTable) do
        if (Value[InElementName] == InElement) then
            return Value
        end
    end

    return nil
end

function FateMgr:OnFateRuneUpdate(InMsgData)
    if (InMsgData == nil) then
        FLOG_ERROR("传入的数据为空，请检查")
        return
    end
    local FateID = InMsgData.FateID
    local RunData = InMsgData.FateUpdateBattleRune
    if (RunData == nil) then
        self:InternalCleanFateRune(FateID)
        return
    end

    if (FateID == nil or FateID <= 0) then
        FLOG_ERROR("传入的 FATEID 无效，请检查")
        return
    end

    if (RunData.RuneInfos == nil or #RunData.RuneInfos < 1) then
        self:InternalCleanFateRune(FateID)
        return
    end

    if (self.CurrActiveFateList == nil or self.CurrActiveFateList[FateID] == nil) then
        self:InternalCleanFateRune(FateID)
        return
    end

    local TargetTable = self.FateRuneDataList[FateID]

    if (TargetTable == nil) then
        TargetTable = {}
        self.FateRuneDataList[FateID] = TargetTable
    else
        -- 这里检测需要删除的
        do
            local RemoveEntityList = {}
            for Key, Value in pairs(TargetTable) do
                local FindItem = self:FindItem(RunData.RuneInfos, Value.UID, "UID")
                if (FindItem == nil) then
                    RemoveEntityList[Key] = 1
                end
            end

            for Key, Value in pairs(RemoveEntityList) do
                _G.ClientVisionMgr:DestoryClientActor(Key, _G.UE.EActorType.EObj)
                TargetTable[Key] = nil
            end

            RemoveEntityList = nil
        end

        -- 这里检查需要新创建的
        do
            local Count = #RunData.RuneInfos
            for Index = Count, 1, -1 do
                local FindItem = self:FindItem(TargetTable, RunData.RuneInfos[Index].UID, "UID")
                if (FindItem ~= nil) then
                    RunData.RuneInfos[Index] = nil
                end
            end
        end
    end

    local NewAddRuneList = RunData.RuneInfos

    for Key, Value in pairs(NewAddRuneList) do
        local RuneTableID = Value.ResID
        local RuneTableData = FateBattleRuneCfg:FindCfgByKey(RuneTableID)
        if (RuneTableData == nil) then
            _G.FLOG_ERROR("FateBattleRuneCfg:FindCfgByKey 出错， ID是:%s", RuneTableID)
        else
            -- body
            local TargetPos = Value.Pos
            local EObjResID = RuneTableData.EobjResID

            -- 这是服务器生成下发的唯一ID，用作ListID，这个方式可能会有冲突的风险
            local ListID = Value.UID + math.floor(EObjResID * 0.001)*10000

            local EobjData = {
                ID = ListID,
                ResID = EObjResID,
                IsHide = true,
                Dir = _G.UE.FVector(),
                Scale = _G.UE.FVector(1, 1, 1),
                Point = TargetPos,
                Type = _G.UE.EActorType.EObj
            }

            local EntityID = _G.ClientVisionMgr:DoClientActorEnterVision(
                ListID,
                EobjData,
                _G.MapEditorActorConfig.EObj,
                EObjResID
            )

            if (EntityID ~= nil) then
                local RuneData = TargetTable[EntityID]
                if (RuneData == nil) then
                    RuneData = {}
                end
                TargetTable[EntityID] = RuneData
                RuneData.UID = Value.UID
                RuneData.ListID = ListID
                RuneData.RuneTableID = Value.ResID
            else
                _G.FLOG_ERROR("OnFateRuneUpdate ， _G.ClientVisionMgr:DoClientActorEnterVision 失败，请检查")
            end
        end
    end
end

-- 获取战场符文
function FateMgr:SendGetFateRune(InFateID)
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_UPDATE_BATTLE_RUNE
    local MsgBody = {
        Cmd = SubMsgID,
        FateUpdateBattleRune = {
            PickRuneUID = 0
        }, -- 这里和触碰符文是一个协议，这里不传数据的话，就是获取所有的符文
        FateID = InFateID
    }

    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

-- 传入怪物的 EntityID ，当 UserData.FateID > 0 ，并且不是当前参与的 FateID，返回true
-- 其他情况都返回 false
function FateMgr:IsFateMonsterButNotJoin(InEntityID)
    if (InEntityID == nil or InEntityID <= 0) then
        return false
    end

    local UserData = self:TryGetUserData(InEntityID)
    if (UserData == nil) then
        return false
    end

    local MonsterFateID = UserData.FateID or 0
    if (MonsterFateID == nil or MonsterFateID <= 0) then
        return false
    end

    local Result = false
    local ActiveFate = self:GetActiveFateById(MonsterFateID)
    if (ActiveFate == nil or ActiveFate.State == ProtoCS.FateState.FateState_Finished) then
        -- 如果获取不到，或者FATE已经结束了，那么不算FATE MONSTER
        return Result
    end
    local SyncState = self:GetLevelSyncState()

    if (self.CurrentFate == nil) then
        Result = true
    else
        local bJoinFate = SyncState == ELevelSyncState.Synchronized or SyncState == ELevelSyncState.Join

        Result = (not bJoinFate or self.CurrentFate.ID ~= MonsterFateID)
    end

    return Result
end

function FateMgr:IsNotJoinState()
    local SyncState = self:GetLevelSyncState()
    return SyncState == ELevelSyncState.NotJoin
end

function FateMgr:IsNotSynchronizedState()
    local SyncState = self:GetLevelSyncState()
    return SyncState == ELevelSyncState.NotSynchronized
end

-- InFateID 为空表示全部清理掉
function FateMgr:InternalCleanFateRune(InFateID)
    if (self.FateRuneDataList == nil) then
        self.FateRuneDataList = {}
        return
    end

    if (InFateID == nil) then
        -- 全部清理掉
        if (self.FateRuneDataList ~= nil) then
            for _, Value in pairs(self.FateRuneDataList) do
                for Key, Data in pairs(Value) do
                    _G.ClientVisionMgr:DestoryClientActor(Key, _G.UE.EActorType.EObj)
                end
            end
        end
        self.FateRuneDataList = {}
    else
        local DataList = self.FateRuneDataList[InFateID]
        if (DataList ~= nil) then
            for Key, Value in pairs(DataList) do
                _G.ClientVisionMgr:DestoryClientActor(Key, _G.UE.EActorType.EObj)
            end
        end

        self.FateRuneDataList[InFateID] = {}
    end
end

function FateMgr:OnFateNpcStart(InMsgData)
    if (InMsgData == nil) then
        return
    end

    if (InMsgData.FateNPCStart == nil) then
        _G.FLOG_ERROR("服务器下发的 InMsgData.FateNPCStart 为空，请检查")
        return
    end

    local FateID = InMsgData.FateID
    local TargetFate = self.CurrActiveFateList[FateID]
    if (TargetFate == nil) then
        _G.FLOG_ERROR("开启的FATE : %s, 无法在当前FATE列表中获取到，请检查", tostring(FateID))
        return
    end

    TargetFate.State = ProtoCS.FateState.FateState_InProgress
    -- 这里需要修改一下范围，避免检测出离开
    local TempCfg = self:GetFateCfg(FateID)
    if (TempCfg ~= nil) then
        local RangeParams = string.split(TempCfg.Range, ",")
        TargetFate.FateRadius = tonumber(RangeParams[5] or 0)
        TargetFate.FateHeight = tonumber(RangeParams[4] or 0)
    end

    self:OnEnterArea(TargetFate)
    self:RequireJoinFate()
end

function FateMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExitWorld)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
    self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
    self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
    self:RegisterGameEvent(EventID.Attr_Change_HP, self.OnGameEventChangeHP)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.MonsterCreate, self.OnMonsterCreate)
    self:RegisterGameEvent(EventID.UpdateBuff, self.OnUpdateBuff)
    self:RegisterGameEvent(EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
    self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
    self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnGameEventCharacterDead)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnMajorProfSwitch)
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead) --主角死亡
    self:RegisterGameEvent(EventID.FateLateShowLoot, self.OnFateLateShowLoot)
    self:RegisterGameEvent(EventID.EnterInteractionRange, self.OnEnterInteractionRange)
    self:RegisterGameEvent(EventID.TrivialSkillStart, self.OnGameEventTrivialSkillStart)
    self:RegisterGameEvent(EventID.NetworkReconnectLoginFinished, self.OnNetworkReconnectLoginFinished)
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnGameEventNetworkReconnected)
end

--- 闪断情况重连逻辑
function FateMgr:OnGameEventNetworkReconnected(Params)
    if not Params or not Params.bRelay then
        return
    end
end

-- 战场符文相关
function FateMgr:OnEnterInteractionRange(Params)
    if (self.CurrentFate == nil) then
        return
    end

    local ActorType = Params.IntParam1
    local EntityID = Params.ULongParam1
    local ResID = Params.ULongParam2 or 0

    if ActorType ~= _G.UE.EActorType.EObj then
        return
    end

    local DataList = self.FateRuneDataList[self.CurrentFate.ID]

    if (DataList == nil) then
        return
    end

    local TargetData = DataList[EntityID]
    if (TargetData == nil) then
        return
    end

    -- 判断当前的参与状态，未参与不给触发战场符文
    if (not self:IsJoinFate()) then
        local CurTime = TimeUtil.GetServerTime()
        if (self.NotJoinRecordTime == nil or ((CurTime - self.NotJoinRecordTime) >= FateRuneNotJoinTipsTimeSpan)) then
            -- 飘字提示
            MsgTipsUtil.ShowTipsByID(FateRuneNotJoinTipsID)
            self.NotJoinRecordTime = CurTime
        end
        return
    end

    local RuneTableData = FateBattleRuneCfg:FindCfgByKey(TargetData.RuneTableID)
    if (RuneTableData == nil) then
        _G.FLOG_ERROR("FateBattleRuneCfg:FindCfgByKey 错误，ID 是 : %s", TargetData.RuneTableID)
        return
    end
    local BuffTableData = BuffCfg:FindCfgByKey(RuneTableData.BuffID)
    if (BuffTableData == nil) then
        _G.FLOG_ERROR("BuffCfg:FindCfgByKey 错误，ID是:%s", RuneTableData.BuffID)
        return
    end

    do
        -- 战场符文的新手指南提示
        local function ShowAdvanceFateTutorial()
            --发送新手引导触发获得物品触发消息
            local EventParams = _G.EventMgr:GetEventParams()
            EventParams.Type = TutorialDefine.TutorialConditionType.FateBattleRune --新手引导触发类型
            _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
        end

        local Config = {
            Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
            Callback = ShowAdvanceFateTutorial,
            Params = {}
        }

        _G.TipsQueueMgr:AddPendingShowTips(Config)
    end

    -- 这里发送协议给服务器，已经触碰到了
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_UPDATE_BATTLE_RUNE
    local MsgBody = {
        Cmd = SubMsgID,
        FateUpdateBattleRune = {
            PickRuneUID = TargetData.UID
        },
        FateID = self.CurrentFate.ID
    }

    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)

    local TargetStr = string.format(LSTR(190141), BuffTableData.BuffName)
    MsgTipsUtil.ShowTips(TargetStr)

    self:RegisterTimer(
        function()
            _G.ClientVisionMgr:DestoryClientActor(EntityID, _G.UE.EActorType.EObj)
            DataList[EntityID] = nil
        end,
        0.5,
        0,
        1
    )
end

function FateMgr:OnFateLateShowLoot(Params)
    self:RegisterTimer(
        function()
            _G.LootMgr:SetDealyState(false)
        end,
        2,
        0,
        1
    )
end

function FateMgr:OnPWorldReady(Params)
end

function FateMgr:OnPWorldExit(Params)
    self.CheckLostLadyEntityIDTalbe = nil
    local CurFate = self:GetCurrentFate()
    if (CurFate ~= nil) then
        self:OnExitArea(CurFate)
    end
end

function FateMgr:OnGameEventMajorDead(Params)
    -- 这里，主角死亡以后，需要更新一下状态，服务器在角色死亡的时候已经取消了同步\参与
    if (self.LevelSyncState == ELevelSyncState.Synchronized) then
        self:InternalSetLevelSyncState(ELevelSyncState.NotSynchronized)
    elseif (self.LevelSyncState == ELevelSyncState.Join) then
        self:InternalSetLevelSyncState(ELevelSyncState.NotJoin)
    end

    self:InternalSetIsJoinFate(false)
end

-- 切换了职业
function FateMgr:OnMajorProfSwitch(Params)
    self:RefreshLevelSyncState()
end

function FateMgr:OnFateTrigger(MsgBody)
    local Msg = MsgBody.FatePlayerTrigger
    if (Msg ~= nil and Msg.NewFate) then
        self:OnTriggerNewFate(Msg.FateID)
    end
end

function FateMgr:GetFateHighRiskTableDataByHighRiskState(InHighRiskState)
    if (InHighRiskState == nil or InHighRiskState <= 0) then
        return nil
    end

    local TableData = self.HighRiskFateTableData[InHighRiskState]
    if (TableData == nil) then
        TableData = FateHighRiskCfg:FindCfgByKey(InHighRiskState)
        self.HighRiskFateTableData[InHighRiskState] = TableData
    end

    return TableData
end

--- 获取FATE的高危词条表格数据，如果传入的FATEID不是高危或者没有，那么返回空，有则返回对应的高危词条表格数据
function FateMgr:GetFateHighRiskTableDataByFateID(InFateID)
    if (InFateID == nil or InFateID <= 0) then
        return nil
    end

    local ActiveFate = self:GetActiveFateById(InFateID)
    if (ActiveFate == nil) then
        return nil
    end

    return self:GetFateHighRiskTableDataByHighRiskState(ActiveFate.HighRiskState)
end

function FateMgr:OnVisionUserDataChg(MsgBody)
    if (MsgBody == nil or MsgBody.UserDataChg == nil) then
        FLOG_ERROR("协议转换出错，请检查")
        return
    end
    local NPCEntityID = MsgBody.UserDataChg.EntityID
    local ActorVM = _G.HUDMgr:GetActorVM(NPCEntityID)
    if (ActorVM ~= nil and ActorVM.HUDType == HUDType.MonsterInfo) then
        ActorVM:UpdateMonsterTypeIcon()
        ActorVM:UpdateTitleInfo()
    end

    self:PrepareForFateNpcEntity(NPCEntityID)
end

function FateMgr:PrepareForFateNpcEntity(InEntityID)
    self:RemoveUserDataCache(InEntityID)
    local UserData = self:TryGetUserData(InEntityID)
    if (UserData == nil) then
        return
    end

    local AttrComp = ActorUtil.GetActorAttributeComponent(InEntityID)
    if (AttrComp == nil or AttrComp.ObjType == EActorType.Npc) then
        return
    end

    local FateID = UserData.FateID or 0
    if (FateID <= 0) then
        return
    end

    local FateEntityTable = self.FateNpcEntityTable[FateID]
    if (FateEntityTable == nil) then
        FateEntityTable = {}
        self.FateNpcEntityTable[FateID] = FateEntityTable
    end

    local Entity = FateEntityTable[InEntityID]
    if (Entity == nil) then
        local ResID = ActorUtil.GetActorResID(InEntityID)
        if (ResID == nil or ResID <= 0) then
            _G.FLOG_WARNING("错误 , ActorUtil.GetActorResID 获取失败，InEntityID 是 : " .. InEntityID)
            return
        end

        if (#self.FateNpcEntityPool > 0) then
            Entity = table.remove(self.FateNpcEntityPool, 1)
        else
            Entity = FateNpcEntity.New()
        end

        local InitResult = Entity:Init(InEntityID, ResID, FateID)
        if (InitResult == false) then
            Entity:ResetData()
            table.insert(self.FateNpcEntityPool, Entity)
            return
        end
        FateEntityTable[InEntityID] = Entity
    end
end

function FateMgr:OnGameEventCharacterDead(Params)
    if nil == Params then
        return
    end

    local EntityID = Params.ULongParam1

    self:InternalRemoveFateEntityByEntityID(EntityID)
end

function FateMgr:OnAssembleAllEnd(Params)
    local AssembleEndEntityID = Params.ULongParam1
    self:PrepareForFateNpcEntity(AssembleEndEntityID)
end

function FateMgr:OnRegisterTimer()
    self:RegisterTimer(self.TickPerSecond, 0, 1, 0)
end

-- 每秒检测
function FateMgr:TickPerSecond()
    -- 这里是指引相关的，出发了指引隐藏，那么需要每秒检测下，指引是否消失了，重新显示
    if (self.bNeedReCheckState) then
        if not _G.NewTutorialMgr.TutorialState or not _G.NewTutorialMgr:GetRunningSubGroup() then
            _G.FLOG_INFO("FateMgr:TickPerSecond() 右上角检测，当前没有指引，显示")
            self.bNeedReCheckState = false
            self:UpdateFateStageInfo()
        else
            _G.FLOG_INFO("FateMgr:TickPerSecond() 右上角检测，当前仍然有指引，不显示")
        end
    end

    self:CheckLostLadyGuidePerSecond()

    self:TickForFateInfo()

    -- 这里是做了每个创建的FATE NPC，用于做表现，目前是用来检测喊话
    for Key, Value in pairs(self.FateNpcEntityTable) do
        -- Value : List< key : entityid, value : FateNpcEntity>
        for K, V in pairs(Value) do
            -- V : FateNpcEntity
            V:Tick()
        end
    end
end

-- 注意，这里是每0.5秒检测
function FateMgr:OnCheckForFateTipsQueue()
    if (self.CurActiveFateTips == nil and self.FateTipsQueueCount <= 0) then
        self:UnRegisterTimer(self.TickForFateTipsViewID)
        self.TickForFateTipsViewID = nil
        return
    end
    if (self.CurActiveFateTips ~= nil) then
        self.CurActiveFateTips.PlayedTime = self.CurActiveFateTips.PlayedTime + FateTipsCheckTimeSpan
        if (self.CurActiveFateTips.PlayedTime >= self.CurActiveFateTips.ShowTime) then
            if (self.CurActiveFateTips.EndFunc ~= nil) then
                self.CurActiveFateTips.EndFunc()
            end
            self.CurActiveFateTips = nil
        end
    end

    if (self.CurActiveFateTips == nil and self.FateTipsQueueCount > 0) then
        self.FateTipsQueueCount = self.FateTipsQueueCount - 1
        local TargetFateTips = table.remove(self.FateTipsQueue)
        if (TargetFateTips ~= nil) then
            self.CurActiveFateTips = TargetFateTips
            if (self.CurActiveFateTips.BeginFunc ~= nil) then
                self.CurActiveFateTips.BeginFunc(self.CurActiveFateTips.Params)
            end
        end
    end
end

function FateMgr:OnGameEventEnterWorld(Params)
    self.CheckLostLadyEntityIDTalbe = nil
    local bNoSendMsg = true
    local bChangeLine = Params.bChangeLine or false
    if (bChangeLine) then
        _G.FLOG_INFO("地图发生了切换分线，需要清理FATE相关的地图信息")
    end
    local bIsReconnectInSameMap = _G.PWorldMgr:IsReconnectInSameMap() or false
    -- 注意，这里有可能是自动寻路FATE触发的传送水晶，一定是下面这样判断，否则会中断自动寻路
    -- local bResetMapInfo = bChangeLine or bIsReconnectInSameMap
    self:ResetData(nil, bNoSendMsg, false)
    self:SendGetCurMapActiveFateList()
end

function FateMgr:OnGameEventExitWorld(Params)
    self:ResetData(nil, false, false)
end

function FateMgr:InternalSendFateReqMsg(InMsgID, InSubMsgID, InMsgBody, InCurWorldInsID)
    if (InCurWorldInsID ~= nil and InCurWorldInsID > 0) then
        InMsgBody.CurrentSceneInsID = InCurWorldInsID
    else
        InMsgBody.CurrentSceneInsID = _G.PWorldMgr:GetCurrPWorldInstID()
    end
    _G.GameNetworkMgr:SendMsg(InMsgID, InSubMsgID, InMsgBody)
end

function FateMgr:SendGetCurMapActiveFateList()
    -- 目前主城会有FATE，副本里面暂时不会有，修改一下
    local bInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    if (bInDungeon) then
        return
    end

    -- 获取当前地图开启的Fate列表
    local MapID = PWorldMgr:GetCurrMapResID()
    local WorldInstID = PWorldMgr:GetCurrPWorldInstID()
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_UPDATE
    local MsgBody = {
        Cmd = SubMsgID,
        FateUpdate = {
            SceneInstID = WorldInstID,
            MapID = MapID
        }
    }

    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

function FateMgr:OnGameEventVisionEnter(Params)
    local EntityID = Params.ULongParam1
    local EntityType = Params.IntParam1
    local Attr = ActorUtil.GetActorAttributeComponent(EntityID)
    self:RemoveUserDataCache(EntityID)
    local UserData = self:TryGetUserData(EntityID)
    if (Attr ~= nil and UserData ~= nil) then
        if (EntityType == _G.UE.EActorType.Monster) then
            self:OnCheckLostLady(Attr, EntityID)

            local FateID = UserData.FateID or 0
            if self:IsKillBossHpFate(FateID, Attr) then
                local Fate = self.CurrActiveFateList[FateID]
                local Hp = Attr.GetAttrValue(ProtoCommon.attr_type.attr_hp)
                local HpMax = Attr.GetAttrValue(ProtoCommon.attr_type.attr_hp_max)
                if Hp and HpMax and Fate ~= nil then
                    Fate.Progress = 100 - Hp * 100 / HpMax
                end
                self.FateBossList[Attr.MonsterSourceID] = EntityID
                self:UpdateFateStageInfo()
            end
        end

        self:PrepareForFateNpcEntity(EntityID)
    end
end

function FateMgr:IsLostLadyResID(InResID)
    if (InResID == nil or InResID == 0) then
        return false
    end

    self:InternalLoadLostLadyResTable()

    local Result = self.LostLadyResIDTable[InResID] ~= nil

    return Result
end

function FateMgr:OnCheckLostLady(InAttrComponent, InEntityID)
    if (InAttrComponent == nil) then
        return
    end

    local TargetData = self.LostLadyResIDTable[InAttrComponent.ResID]
    if (TargetData == nil) then
        return
    end

    if (self.CheckLostLadyEntityIDTalbe == nil) then
        self.CheckLostLadyEntityIDTalbe = {}
    end
    self.CheckLostLadyEntityIDTalbe[InEntityID] = 1

    self:CheckLostLadyGuidePerSecond()
end

function FateMgr:CheckLostLadyGuidePerSecond()
    if (self.CheckLostLadyEntityIDTalbe == nil) then
        return
    end

    local Major = MajorUtil.GetMajor()
    if (Major == nil) then
        return
    end

    local MajorLocation = Major:FGetActorLocation()
    if (MajorLocation == nil) then
        return
    end
    local bFind = false
    for Key,_ in pairs(self.CheckLostLadyEntityIDTalbe) do
        -- 这里检测距离
        local TargetActor = ActorUtil.GetActorByEntityID(Key)
        if (TargetActor == nil) then
            return
        end

        local ActorLocation = TargetActor:FGetActorLocation()
        if (ActorLocation ~= nil) then
            local Distance = _G.UE.FVector.Dist(MajorLocation, ActorLocation)
            if (Distance <= LostLadyCheckDistance) then
                self:ShowLostLadyGuide()
                bFind = true
                break
            end
        end
    end

    if (bFind) then
        self.CheckLostLadyEntityIDTalbe = nil
    end
end

function FateMgr:ShowLostLadyGuide()
    local function ShowFateLostLadyTutorial()
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.FateLostLady --迷失少女新手指南
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local Config = {
        Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
        Callback = ShowFateLostLadyTutorial,
        Params = {}
    }

    _G.TipsQueueMgr:AddPendingShowTips(Config)
end

function FateMgr:OnGameEventVisionLeave(Params)
    if nil == Params then
        return
    end

    local EntityID = Params.ULongParam1

    self:InternalRemoveFateEntityByEntityID(EntityID)

    self:RemoveUserDataCache(EntityID)

    if (self.CheckLostLadyEntityIDTalbe ~= nil) then
        self.CheckLostLadyEntityIDTalbe[EntityID] = nil
    end
end

function FateMgr:InternalRemoveFateEntityByEntityID(InEntityID)
    if (InEntityID == nil or InEntityID <= 0) then
        return
    end

    for FateID, EntityTable in pairs(self.FateNpcEntityTable) do
        for EntityID, Entity in pairs(EntityTable) do
            if (EntityID == InEntityID) then
                Entity[EntityID] = nil
                table.insert(self.FateNpcEntityPool, Entity)
                Entity:ResetData()
                return
            end
        end
    end
end

function FateMgr:InternalRemoveFateNpc(InEntityID, InRemoveFateID)
    if (InEntityID == nil or InEntityID <= 0) then
        return
    end
    ClientVisionMgr:DestoryClientActor(InEntityID, _G.UE.EActorType.Npc)
    _G.EventMgr:SendEvent(EventID.OnDialogNpcDestory, InEntityID)

    if (InRemoveFateID) then
        self.FateNpcList[InRemoveFateID] = nil
    end
end

function FateMgr:OnMajorLevelUpdate(Params)
    local LevelUpReason = Params.Reason
    if (LevelUpReason == ProtoCS.LevelUpReason.LevelUpReasonScene) then
        -- 以 FATE 的状态和协议为准，不再关注等级同步 2025-5-8
        -- -- 这里是同步相关
        -- self:RefreshLevelSyncState()
    else
        local SyncState = self:GetLevelSyncState()
        -- 策划新需求，如果角色已经参与或者同步了，那么就不修改状态了
        if (not self.bJoinFate) then
            self:RefreshLevelSyncState()
        end
    end
end

function FateMgr:OnNetMsgUpdateFate(MsgBody)
    for _, Fate in ipairs(MsgBody.FateUpdate.Fates) do
        self:InternalProcessFateUpdate(Fate, MsgBody)
    end
end

function FateMgr:InternalProcessFateUpdate(Fate, MsgBody)
    local FateGeneratorCfg = FateGeneratorCfgTable:FindCfgByKey(Fate.ID)
    if FateGeneratorCfg == nil or FateGeneratorCfg.MapID ~= PWorldMgr:GetCurrMapResID() then
        self.CurrActiveFateList[Fate.ID] = nil
        return
    end

    Fate.MapID = PWorldMgr:GetCurrMapResID()
    local EventParams = Fate
    local OldFate = self.CurrActiveFateList[Fate.ID]

    local bIsNewFate = OldFate == nil or OldFate.State == ProtoCS.FateState.FateState_EndSubmitItem or
        OldFate.State == ProtoCS.FateState.FateState_Finished

    EventParams.bStateChanged = false
    if (OldFate == nil) then
        EventParams.bStateChanged = true
    else
        EventParams.bStateChanged = OldFate.State ~= Fate.State
    end

    self.CurrActiveFateList[Fate.ID] = Fate
    local bIsEndSubmit = Fate.State == ProtoCS.FateState.FateState_EndSubmitItem
    local bFinished = Fate.State == ProtoCS.FateState.FateState_Finished
    local bHighRisk = Fate.HighRiskState ~= nil and Fate.HighRiskState > 0
    if (bHighRisk and bIsNewFate and (not bFinished) and (not bIsEndSubmit)) then
        -- 这里去添加一个系统通知
        local SysTableData = SysnoticeCfg:FindCfgByKey(HighRiskSystemNoticeID)
        if (SysTableData ~= nil) then
            ChatMgr:AddSysChatMsg(SysTableData.Content[1])
        else
            _G.FLOG_ERROR("无法找到系统通知数据，ID是:"..HighRiskSystemNoticeID)
        end
    end

    local FateCfg = self:GetFateCfg(Fate.ID)
    if FateCfg ~= nil then
        local bIsCollectFate = FateCfg.Type == ProtoRes.Game.FATE_TYPE.FATE_TYPE_COLLECT
        if bIsCollectFate and bIsEndSubmit then
            if (Fate.ItemTime ~= nil and Fate.ItemTime > 0) then
                Fate.EndTime = Fate.ItemTime + 60000
            else
                Fate.EndTime = 0
            end
        else
            if (Fate.StartTime ~= nil and Fate.StartTime > 0) then
                if (bHighRisk) then
                    local EndTimeM = FateCfg.HighRiskDurationM or 6
                    Fate.EndTime = Fate.StartTime + (EndTimeM) * 60000
                else
                    local EndTimeM = FateCfg.DurationM or 10
                    Fate.EndTime = Fate.StartTime + (EndTimeM) * 60000
                end
            else
                Fate.EndTime = 0
            end
        end

        local NPCLocationString = FateCfg.TriggerNPCLocation
        local RangeString = FateCfg.Range
        local bWaitTrigger = Fate.State == ProtoCS.FateState.FateState_WaitNPCTrigger
        if (bWaitTrigger and NPCLocationString ~= "") then
            local NPCLocParams = string.split(NPCLocationString, ",")
            self.CurrActiveFateList[Fate.ID].FateCenter = _G.UE.FVector(
                tonumber(NPCLocParams[1]),
                tonumber(NPCLocParams[2]),
                tonumber(NPCLocParams[3])
            )
            self.CurrActiveFateList[Fate.ID].FateRadius = 10 -- 因为没有开启战斗，这个参数用于检测是否在战斗范围，临时填写一个10
            self.CurrActiveFateList[Fate.ID].FateHeight = 10 -- 因为没有开启战斗，这个参数用于检测是否在战斗范围，临时填写一个10
        elseif (RangeString ~= "") then
            local RangeParams = string.split(RangeString, ",")
            self.CurrActiveFateList[Fate.ID].FateCenter = _G.UE.FVector(
                tonumber(RangeParams[1]),
                tonumber(RangeParams[2]),
                tonumber(RangeParams[3])
            )
            self.CurrActiveFateList[Fate.ID].FateRadius = tonumber(RangeParams[5] or 0)
            self.CurrActiveFateList[Fate.ID].FateHeight = tonumber(RangeParams[4] or 0)
        end
        self.CurrActiveFateList[Fate.ID].HintRange = FateCfg.HintRange or 3000
        self.CurrActiveFateList[Fate.ID].FateType = FateCfg.Type
        self.CurrActiveFateList[Fate.ID].TriggerNPC = FateCfg.TriggerNPC
        self.CurrActiveFateList[Fate.ID].Npc = Fate.Npc
        if (Fate.Npc ~= nil and Fate.FateType == ProtoRes.Game.FATE_TYPE.FATE_TYPE_ESCORT) then
            self:GuardCalcProgressAndPos(Fate, true, false)
        end
    else
        _G.FLOG_ERROR("无法获取FATE数据，ID是：" .. tostring(Fate.ID))
    end

    -- 如果更新的是当前的FATE，那么需要重新设置一下
    if (self.CurrentFate ~= nil and self.CurrentFate.ID == Fate.ID) then
        if (not bFinished) then
            local TempOldFate = self.CurrentFate
            self:SetCurrentFate(Fate)
            self.CurrentFate.IsEnterArea = TempOldFate.IsEnterArea
        end
    end

    self:ProcessFateNpcWhenFateStateChange(Fate, FateCfg)

    do
        -- 这里是针对单个NPC的
        local NPCEntityID = self.FateNpcList[Fate.ID]

        if (NPCEntityID ~= nil and NPCEntityID > 0) then
            EventParams.NPCEntityID = NPCEntityID

            _G.HUDMgr:OnFateUpdate({EntityID = NPCEntityID})

            if Fate.State ~= ProtoCS.FateState.FateState_WaitNPCTrigger then
                _G.InteractiveMgr:HideFunctionItemByFuncType(
                    NPCEntityID,
                    ProtoRes.interact_func_type.INTERACT_FUNC_START_FATE
                )
            end
        end
    end

    _G.EventMgr:SendEvent(EventID.FateUpdate, EventParams)

    self:UpdateFateStageInfo()
    self:OnItemCollectFateStagePrompt()

    if (MsgBody.FateUpdate.InFateID ~= nil and MsgBody.FateUpdate.InFateID > 0) then
        _G.FLOG_INFO("当前有在进行中的FATE ,id : %s ，将自动恢复加入", MsgBody.FateUpdate.InFateID)
        self.ServerCurFateID = MsgBody.FateUpdate.InFateID
    end
    if (MsgBody.FateUpdate.EndRspCache ~= nil) then
        self:TryShowRewardPanel(MsgBody.FateUpdate.EndRspCache)
    end
end

function FateMgr:CheckCanCreateOrDestroyNpc(InFateCfg)
    if (InFateCfg == nil) then
        return false
    end

    if (InFateCfg.bDontCreateOrDestroyNpc ~= nil and InFateCfg.bDontCreateOrDestroyNpc ~= 0) then
        return false
    end

    return true
end

function FateMgr:InternalProcessSingleFateNpc(
    InFate, InFateCfg, InNpcEntityID, InNpcResID, InNpcLocation, InGetNpcCallback, InDestroyCallback
)
    local TargetNpcEntityID = InNpcEntityID
    local NpcActor = nil
    if (TargetNpcEntityID ~= nil and TargetNpcEntityID > 0) then
        NpcActor = ActorUtil.GetActorByEntityID(TargetNpcEntityID)
    end

    local bTriggerGetNpc = false
    if (NpcActor == nil) then
        -- 这里去场景里面找一下，看是否已经创建出来过了
        NpcActor = ActorUtil.GetActorByResID(InNpcResID)
        if (NpcActor ~= nil) then
            TargetNpcEntityID = ActorUtil.GetActorEntityID(NpcActor)
            bTriggerGetNpc = true
        end
    end

    local bHideTriggerNpc = InFateCfg.IsHideTriggerNPC == 1

    if (NpcActor == nil) then
        -- 如果NPC还是为空，那么看下是否需要创建
        local bNeedCreate = self:CheckCanCreateOrDestroyNpc(InFateCfg)
        if (bNeedCreate and bHideTriggerNpc) then
            -- 如果需要隐藏NPC，那么看一下，状态是否已经出发了
            bNeedCreate = InFate.State < ProtoCS.FateState.FateState_InProgress
        end

        if (bNeedCreate) then
            local NpcResID = InNpcResID
            local NpcCfg = NpcCfgTable:FindCfgByKey(NpcResID)
            if NpcCfg == nil then
                local OldNpcID = NpcResID
                NpcResID = 29000007
                _G.FLOG_ERROR("错误，无法获取NPC，ID 是 : %s，将使用默认ID:%s", OldNpcID, NpcResID)
            end
            local NPCLocation = FateDefine.ParseLocation(InNpcLocation)
            local NPCRotation = FateDefine.ParseRotation(InNpcLocation)
            if NpcResID ~= nil and NPCLocation ~= nil and NPCRotation ~= nil then
                local NpcEntityID = _G.UE.UActorManager:Get():CreateClientActor(
                    _G.UE.EActorType.Npc,
                    0,
                    NpcResID,
                    NPCLocation,
                    NPCRotation
                )

                FLOG_INFO(
                    "[Fate] Create NPC %s at %s, Entity ID = %s",
                    tostring(NpcResID),
                    InNpcLocation,
                    tostring(NpcEntityID)
                )

                TargetNpcEntityID = NpcEntityID
                bTriggerGetNpc = true
            end
        end

        if (bTriggerGetNpc and InGetNpcCallback ~= nil and TargetNpcEntityID ~= nil and TargetNpcEntityID > 0) then
            InGetNpcCallback(InFate.ID, TargetNpcEntityID, InNpcResID)

            -- 如果NPC已经存在了，那么更新一下userrdata
            local UserData = self:TryGetUserData(TargetNpcEntityID)
            if (UserData ~= nil) then
                UserData.FateID = InFate.ID
                ActorUtil.SetUserData(TargetNpcEntityID, UserDataID.Fate, UserData)
            end
        end
    else
        -- 这里是有，看下是否需要销毁了
        if (bHideTriggerNpc and self:CheckCanCreateOrDestroyNpc(InFateCfg)) then
            local bTargetState = InFate.State >= ProtoCS.FateState.FateState_InProgress -- 触发后需要隐藏
            if (bTargetState) then
                -- 这里去销毁一下NPC
                self:InternalRemoveFateNpc(TargetNpcEntityID, InFateCfg.ID)
                if (InDestroyCallback ~= nil) then
                    InDestroyCallback(InFate.ID, TargetNpcEntityID)
                end
            end
        end
    end
end

-- 当FATE状态发生变化的时候，处理FATE的NPC相关
function FateMgr:ProcessFateNpcWhenFateStateChange(InFate, InFateCfg)
    if (InFateCfg == nil or InFate == nil) then
        _G.FLOG_ERROR("FateMgr:InternalTryCreateFateNpc 出错，传入的数据无效，请检查")
        return
    end

    if (InFateCfg.TriggerNPC ~= nil and InFateCfg.TriggerNPC > 0) then
        local TargetNpcEntityID = self.FateNpcList[InFate.ID]
        self:InternalProcessSingleFateNpc(
            InFate, InFateCfg, TargetNpcEntityID, InFateCfg.TriggerNPC, InFateCfg.TriggerNPCLocation,
            function(CallbackFateID, CallbackEntityID)
                -- 创建NPC回调函数
                self.FateNpcList[CallbackFateID] = CallbackEntityID
            end,
            function(CallbackFateID, CallbackEntityID)
                -- 销毁NPC回调函数
                self.FateNpcList[CallbackFateID] = nil -- 清理一下
            end
        )
        return
    end
end

function FateMgr:InternalSetIsJoinFate(InbJoinFate)
    self.bJoinFate = InbJoinFate
    self:RefreshLevelSyncState()
end

function FateMgr:SendFateStartPuzzleReq(InNpcEntityID)
    if (InNpcEntityID == nil or InNpcEntityID <= 0) then
        _G.FLOG_ERROR("传入的 InNpcEntityID 为空，请检查")
        return
    end

    local TargetActor = ActorUtil.GetActorByEntityID(InNpcEntityID)
    if (TargetActor == nil) then
        _G.FLOG_ERROR("无法获取NPC，EntityID")
        return
    end

    local AttriComp = TargetActor:GetAttributeComponent()
    if (AttriComp == nil) then
        _G.FLOG_ERROR("FateMgr:SendFateStartPuzzleReq 出错，无法获取 AttributeComponent，EntityID : "..InNpcEntityID)
        return
    end

    local TargetNpcListID = AttriComp.ListID
    if (TargetNpcListID <= 0) then
        _G.FLOG_ERROR("错误,NPCLISTID无效，请检查，传入的entityID : " .. InNpcEntityID)
        return
    end

    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_START_PUZZLE

    local InFateID = 0
    if (self.CurrentFate ~= nil) then
        InFateID = self.CurrentFate.ID
    end

    local MsgBody = {
        Cmd = SubMsgID,
        FateID = InFateID,
        FateStartPuzzle = {
            NpcListID = TargetNpcListID
        }
    }

    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

function FateMgr:SendFateDanceReq(InNpcEntityID, InEmotionID)
    if (InNpcEntityID == nil or InNpcEntityID <= 0) then
        _G.FLOG_ERROR("传入的 InNpcEntityID 为空，请检查")
        return
    end

    if (InEmotionID == nil or InEmotionID <=0) then
        _G.FLOG_ERROR("FateMgr:SendFateDanceReq 错误，InEmotionID无效")
        return
    end

    local TargetActor = ActorUtil.GetActorByEntityID(InNpcEntityID)
    if (TargetActor == nil) then
        _G.FLOG_ERROR("无法获取NPC，EntityID : "..InNpcEntityID)
        return
    end

    local AttriComp = TargetActor:GetAttributeComponent()
    if (AttriComp == nil) then
        return
    end

    local RaceID = AttriComp.RaceID
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_DANCE

    local InFateID = 0
    if (self.CurrentFate ~= nil) then
        InFateID = self.CurrentFate.ID
    end

    local MsgBody = {
        Cmd = SubMsgID,
        FateID = InFateID,
        FateDance = {
            EmotionID = InEmotionID,
            NpcRaceType = RaceID
        }
    }

    self.CurFateDanceNpcEntityID = InNpcEntityID

    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

function FateMgr:SendFateEndPuzzleReq(InNpcEntityID, InbSuccuess)
    if (InNpcEntityID == nil or InNpcEntityID <= 0) then
        _G.FLOG_ERROR("传入的 InNpcEntityID 为空，请检查")
        return
    end

    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_END_PUZZLE

    local InFateID = 0
    if (self.CurrentFate ~= nil) then
        InFateID = self.CurrentFate.ID
    end

    local TargetActor = ActorUtil.GetActorByEntityID(InNpcEntityID)
    if (TargetActor == nil) then
        _G.FLOG_ERROR("FateMgr:SendFateEndPuzzleReq 出错，无法获取NPC，传入的EntityID 是 : " .. InNpcEntityID)
        return
    end

    local AttributeComp = TargetActor:GetAttributeComponent()
    if (AttributeComp == nil) then
        _G.FLOG_ERROR("FateMgr:SendFateEndPuzzleReq 出错，无法获取NPC AttributeComp，传入的EntityID 是 : " .. InNpcEntityID)
        return
    end

    local ListID = AttributeComp.ListID
    if (ListID == nil or ListID <= 0) then
        _G.FLOG_ERROR("FateMgr:SendFateEndPuzzleReq 出错，无法获取有效ListID， EntityID : "..InNpcEntityID)
        return
    end

    local MsgBody = {
        Cmd = SubMsgID,
        FateID = InFateID,
        FateEndPuzzle = {
            NpcListID = ListID,
            Success = InbSuccuess
        }
    }

    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

function FateMgr:SendConfirmbShowRewardPanel(InFateID)
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_CONFIRM_REWARD

    local MsgBody = {
        Cmd = SubMsgID,
        FateID = InFateID,
        FateConfirmReward = {}
    }

    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

function FateMgr:TryShowRewardPanel(EndData)
    local ID = EndData.ID
    local bFinished = EndData.Finished
    local Rewards = EndData.Rewards
    local Achievement = EndData.Achievement
    local TargetFate = self.CurrActiveFateList[ID]

    local TempRewardList = self:MergeScoreItemIfSameResID(Rewards)
    Rewards = TempRewardList

    local EventCfg = FateAchievementCfgTable:FindCfgByKey(ID)
    if EventCfg ~= nil then
        for index, value in ipairs(Achievement) do
            value.ID = EventCfg.Achievements[index].EventID
            value.Params = EventCfg.Achievements[index].Params
        end
    end

    local FateCfg = self:GetFateCfg(ID)
    local TempFateName = nil
    local TempFateType = nil
    if FateCfg ~= nil then
        TempFateName = FateCfg.Name
        TempFateType = FateCfg.Type
    else
        FLOG_ERROR("无法获取Fate,ID是:%d", ID)
    end

    local FateParams = {
        bFinished = bFinished,
        FateName = TempFateName,
        FateType = TempFateType,
        Rewards = Rewards,
        Achievement = Achievement,
        FateId = ID,
        OldAchsState = EndData.OldAchsState,
        NewAchsState = EndData.NewAchsState,
        AwardType = EndData.AwardType,
        bHighRisk = TargetFate ~= nil and TargetFate .HighRiskState ~= nil and TargetFate .HighRiskState > 0,
        CloseCallback = function()
            self:OnCheckNewMapReward(ID, EndData.OldAchFinishCount, EndData.NewAchFinishCount)
        end
    }

    UIViewMgr:HideView(UIViewID.FateItemSubmitPanel)

    if (FateCfg and FateCfg.IsCelebrateFate and FateCfg.IsCelebrateFate > 0) then
        UIViewMgr:ShowView(UIViewID.FateCelebrateFinishPanel, FateParams)
    else
        UIViewMgr:ShowView(UIViewID.FateFinishPanel, FateParams)
    end

    self:SendConfirmbShowRewardPanel(ID)

    local function ShowFateFinish(Params)
    end

    local FateConfig = {
        Type = ProtoRes.tip_class_type.TIP_FATE_NOTICE,
        Callback = ShowFateFinish,
        Params = FateParams
    }
    _G.TipsQueueMgr:AddPendingShowTips(FateConfig)
end

-- 合并相同的货币
function FateMgr:MergeScoreItemIfSameResID(InLootList)
    if (InLootList == nil) then
        return {}
    end

	local Count = #InLootList
	if (Count <= 1) then
		return InLootList
	end

	local ResultList = {}
    table.insert(ResultList, InLootList[1])
	for Index = 2, Count do
        local ItemData = ItemCfg:FindCfgByKey(InLootList[Index].ItemResID)
        if (ItemData ~= nil and ItemData.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.MISCELLANY_CURRENCY) then
            local bSameScore = false
            for Key,Value in pairs(ResultList) do
                if (Value.ItemResID == InLootList[Index].ItemResID) then
                    -- ResID 相同，则增加Number
                    Value.Num = Value.Num + InLootList[Index].Num
                    bSameScore = true
                    break
                end
            end

            if (not bSameScore) then
                -- ResID 不同，则插入数据
                table.insert(ResultList, InLootList[Index])
            end
        else
            -- 不是货币，则不合并
            table.insert(ResultList, InLootList[Index])
        end
	end

	return ResultList
end

function FateMgr:IsDanceFateInTimeRange()
    if (self.DanceTimeRangeTable == nil) then
        self.DanceTimeRangeTable = {}
        local TimeCfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_FATE_DANCE_TIME_CFG)
        self.DanceTimeRangeTable[1] = {}
        local TimeBeforeFate = TimeCfg.Value[1] * 0.001
        local TimePrelude = tonumber(TimeCfg.Value[2] + TimeCfg.Value[3] + TimeCfg.Value[4]) * 0.001
        local TimeShow = tonumber(TimeCfg.Value[5]) * 0.001
        local TimeEndWait = tonumber(TimeCfg.Value[6]) * 0.001
        self.DanceTimeRangeTable[1].TimeBegin = TimeBeforeFate + TimePrelude
        self.DanceTimeRangeTable[1].TimeEnd = self.DanceTimeRangeTable[1].TimeBegin + TimeShow

        self.DanceTimeRangeTable[2] = {}
        self.DanceTimeRangeTable[2].TimeBegin = self.DanceTimeRangeTable[1].TimeEnd + TimeEndWait + TimePrelude
        self.DanceTimeRangeTable[2].TimeEnd = self.DanceTimeRangeTable[2].TimeBegin + TimeShow

        self.DanceTimeRangeTable[3] = {}
        self.DanceTimeRangeTable[3].TimeBegin = self.DanceTimeRangeTable[2].TimeEnd + TimeEndWait + TimePrelude
        self.DanceTimeRangeTable[3].TimeEnd = self.DanceTimeRangeTable[3].TimeBegin + TimeShow
    end

    local TimePlayed = self.CurFateTimeInSec - self.CurFateLeftTime

    for Index = 1, 3 do
        local Data = self.DanceTimeRangeTable[Index]
        if (TimePlayed >= Data.TimeBegin and TimePlayed <= Data.TimeEnd) then
            return true
        end
    end

    return false
end

function FateMgr:IsFateNpcDanced(InNpcEntityID)
    if (self.DancedNpcEntityIDTable == nil) then
        return false
    end

    if (InNpcEntityID == nil or InNpcEntityID == 0) then
        _G.FLOG_ERROR("FateMgr:IsFateNpcDanced，出错传入的 InNpcEntityID 为空，请检查")
        return false
    end

    local Value = self.DancedNpcEntityIDTable[InNpcEntityID]

    local Result = Value ~= nil and Value > 0

    return Result
end

function FateMgr:OnNetMsgFateEnd(MsgBody)
    FLOG_INFO("[Fate] 结束, MsgBody = %s", table.tostring(MsgBody))
    local EndData = MsgBody.FateEnd
    local ID = MsgBody.FateID
    local bFinished = EndData.Finished

    if (self.CurSubmitFateID ~= nil and self.CurSubmitFateID == ID) then
        -- 这里对比一下提交面板，如果提交面板有FATECFG并且ID是一样的， 那么关闭掉
        local TargetUI = _G.UIViewMgr:FindVisibleView(_G.UIViewID.NewQuestPropPanel)
        if (TargetUI ~= nil and TargetUI.Params ~= nil and TargetUI.Params.ViewModel) then
            if (TargetUI.Params.ViewModel.FateCfg ~= nil and TargetUI.Params.ViewModel.FateCfg.ID == ID) then
                TargetUI:OnClickedCancel()
            end
        end
    end

    -- 如果是庆典2002的FATE，那么需要关闭一下该界面
    if (ID == 2002) then
        UIViewMgr:HideView(UIViewID.FateEmoTipsPanelView)
        -- 已经结束了，就清理记录
        self.DancedNpcEntityIDTable = {} -- 庆典跳舞FATE，已经跳过的NPC记录
        self.CurFateDanceNpcEntityID = 0 -- 庆典跳舞FATE，当前跳的NPC记录
    end

    local FateCfg = self:GetFateCfg(ID)
    if (FateCfg == nil) then
        _G.FLOG_ERROR("Fate : [%s] 结束的时候，尝试获取表格数据，但是为空，请检查", ID)
    else
        local bCelebrateFate = FateCfg.IsCelebrateFate and FateCfg.IsCelebrateFate > 0
        if (EndData.PlayerJoinState == ProtoCS.FatePlayerJoinState.FatePlayerJoinState_InRange) then
            local bBossFight = FateCfg.Type == ProtoRes.Game.FATE_TYPE.FATE_TYPE_BOSS
            if (bCelebrateFate and not bBossFight) then
                -- 这里对于不在界面上显示的，默认认为是庆典FATE，不单独显示结算界面，只给个提示
                if (bFinished) then
                    local PanelStr = "PanelPositive"
                    MsgTipsUtil.ShowInfoMissionTips(LSTR(190128), nil, PanelStr, nil)
                else
                    local PanelStr = "PanelFail"
                    MsgTipsUtil.ShowInfoMissionTips(LSTR(190129), nil, PanelStr, nil)
                end
            else
                self:TryShowRewardPanel(EndData)
            end
        elseif (EndData.PlayerJoinState == ProtoCS.FatePlayerJoinState.FatePlayerJoinState_OutOfRange) then
            if (bCelebrateFate) then
                -- 如果是boss
                local bBossFight = FateCfg.Type == ProtoRes.Game.FATE_TYPE.FATE_TYPE_BOSS
                if (bBossFight) then
                    if (EndData.Rewards == nil or #EndData.Rewards < 1) then
                        -- 如果奖励是空的，那么不提示
                    else
                        local TipsStr = LSTR(190052)
                        self:AppendFateTips(FateTipsType.NormalTips, 3, LSTR(TipsStr))
                        self:OnCheckNewMapReward(ID, EndData.OldAchFinishCount, EndData.NewAchFinishCount)
                    end
                else
                    -- 目前其他的庆典活动不显示任何提示
                end
            else
                if (EndData.Rewards == nil or #EndData.Rewards < 1) then
                    -- 如果奖励是空的，那么不提示
                else
                    local TipsStr = LSTR(190052)
                    self:AppendFateTips(FateTipsType.NormalTips, 3, LSTR(TipsStr))
                    self:OnCheckNewMapReward(ID, EndData.OldAchFinishCount, EndData.NewAchFinishCount)
                end
            end
        end
    end

    self:InternalCleanAfterFateEnd(ID, FateCfg, bFinished)

    _G.EventMgr:SendEvent(EventID.FateEnd, EndData)
end

function FateMgr:InternalCleanFateNpc(InFateID, InFateCfg)
    if (InFateID ~= nil and InFateCfg ~= nil) then
        -- 移除单个 NPC
        if (self:CheckCanCreateOrDestroyNpc(InFateCfg)) then
            local NpcEntiyID = self.FateNpcList[InFateID]
            self:InternalRemoveFateNpc(NpcEntiyID, InFateID)
        end
    else
        -- 这里去清理所有的本地创建的NPC
        for Key,EntityID in pairs(self.FateNpcList) do
            -- body
            local TargetCfg = self:GetFateCfg(Key)
            if (self:CheckCanCreateOrDestroyNpc(TargetCfg)) then
                self:InternalRemoveFateNpc(EntityID)
            end
        end
        self.FateNpcList = {}
    end
end

function FateMgr:InternalCleanAfterFateEnd(InFateID, FateCfg, bFinished)
    self:InternalCleanFateRune(InFateID)
    self:OnClearAllCollectItem(InFateID)
    self:InternalCleanFateNpc(InFateID, FateCfg)

    -- 只有结束的是当前的Fate，才调用 OnExitArea
    if self.CurrentFate ~= nil and self.CurrentFate.ID == InFateID then
        self:InternalSetIsJoinFate(false)
        local bNoSendMsg = true
        self:OnExitArea(self.CurrentFate, bNoSendMsg)
    end

    self.EnterAreaFate[InFateID] = nil
    self.EnterHintArea_Record[InFateID] = nil
    self.EnterArea_Record[InFateID] = nil
    self.CurrActiveFateList[InFateID] = nil
    self.FateNpcList[InFateID] = nil

    self:UpdateFateStageInfo()

    local FateEntityTable = self.FateNpcEntityTable[InFateID]
    if (FateEntityTable ~= nil and #FateEntityTable > 0) then
        if (bFinished) then
            for _, Value in pairs(FateEntityTable) do
                Value:OnSuccess()
            end
        else
            for _, Value in pairs(FateEntityTable) do
                Value:OnFaied()
            end
        end

        for _, Value in pairs(FateEntityTable) do
            table.insert(self.FateNpcEntityPool, Value)
        end
        self.FateNpcEntityTable[InFateID] = {}
    end
end

--- func desc return type : ProtoRes.Game.FATE_TYPE
function FateMgr:GetCurrentFateType()
    if (self.CurrentFate == nil) then
        return ProtoRes.Game.FATE_TYPE.FATE_TYPE_INVALID
    end

    local FateCfg = self:GetFateCfg(self.CurrentFate.ID)
    if (FateCfg == nil) then
        return ProtoRes.Game.FATE_TYPE.FATE_TYPE_INVALID
    else
        return FateCfg.Type
    end
end

function FateMgr:OnEnterHintArea(Fate)
    if (Fate.State == ProtoCS.FateState.FateState_Finished) then
        return
    end

    if self.EnterHintArea_Record[Fate.ID] == nil then
        self.EnterHintArea_Record[Fate.ID] = Fate.ID
        self:SendGetFateRune(Fate.ID)
    end
end

function FateMgr:OnExitHintArea(Fate)
    if self.EnterHintArea_Record[Fate.ID] ~= nil then
        self.EnterHintArea_Record[Fate.ID] = nil
    end
end

--- 发送给服务器，进入了哪个Fate里面
---@param InFateID Int
function FateMgr:SendFatePlayerTrigger(InFateID)
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_TRIGGER

    local MsgBody = {
        Cmd = SubMsgID,
        FateID = InFateID,
        FatePlayerTrigger = {}
    }

    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

function FateMgr:ShowFirstEnterEffect(SceneLevel, FateCfg)
    if (self.CurrentFate == nil) then
        return
    end

    local ShowWaitTime = 3
    self:AppendFateTips(FateTipsType.MainTitleTips, ShowWaitTime)

    local HighRiskState = self.CurrentFate.HighRiskState
    if (HighRiskState ~= nil and HighRiskState > 0) then
        local TableData = FateHighRiskCfg:FindCfgByKey(HighRiskState)
        if (TableData ~= nil) then
            self:AppendFateTips(FateTipsType.HighRiskInfoTips, ShowWaitTime, TableData.Desc)
        else
            _G.FLOG_ERROR("无法找到高危词条表格数据，ID是：%s", HighRiskState)
        end
    end

    self:PlayFateInsidePrompt(ProtoRes.FateInsidePromptType.FATE_INSIDE_PROMPT_ENTER_AREA, FateCfg.ID)
end

function FateMgr:IsCurFateHighRisk()
    if (self.CurrentFate == nil) then
        return false
    end

    local HighRiskState = self.CurrentFate.HighRiskState
    if (HighRiskState ~= nil and HighRiskState > 0) then
        return true
    else
        return false
    end
end

function FateMgr:OnEnterArea(InFate)
    if (InFate == nil) then
        return
    end

    local bInProgress = InFate.State == ProtoCS.FateState.FateState_InProgress
    local bEndSubmit = InFate.State == ProtoCS.FateState.FateState_EndSubmitItem

    if (self.EnterAreaFate[InFate.ID] == nil) then
        self.EnterAreaFate[InFate.ID] = InFate
        if (bInProgress) then
            self:SendFatePlayerTrigger(InFate.ID)
        end
    end

    if (self.EnterHintArea_Record[InFate.ID] == nil) then
        self.EnterHintArea_Record[InFate.ID] = InFate
    end

    if not (bInProgress or bEndSubmit) then
        return
    end

    -- 这里只要身处于一个fate之中，没有离开区域，那么就不能进入其他Fate
    if (self.CurrentFate ~= nil) then
        return
    end

    local FateCfg = self:GetFateCfg(InFate.ID)
    if (FateCfg == nil) then
        _G.FLOG_ERROR("无法获取FATE的表格数据，ID是:%s", InFate.ID)
        return
    end

    self:SetCurrentFate(InFate)
    self:SendGetFateRune(InFate.ID)

    -- 这里播放 BGM
    if (UAudioMgr == nil) then
        UAudioMgr = _G.UE.UAudioMgr.Get()
    end

    self:InternalStopFateBGM()
    if (InFate.HighRiskState ~= nil and InFate.HighRiskState > 0) then
        if (FateCfg.HighRiskFateBGM ~= nil and FateCfg.HighRiskFateBGM > 0) then
            self.FateBGMUniqueID = UAudioMgr:PlayBGM(FateCfg.HighRiskFateBGM, _G.UE.EBGMChannel.Fate)
        end
    else
        if (FateCfg.FateBGM ~= nil and FateCfg.FateBGM > 0) then
            self.FateBGMUniqueID = UAudioMgr:PlayBGM(FateCfg.FateBGM, _G.UE.EBGMChannel.Fate)
        end
    end

    if (FateCfg.Type == ProtoRes.Game.FATE_TYPE.FATE_TYPE_ESCORT) then
        local NPCEntityID = ActorUtil.GetActorEntityIDByResID(FateCfg.TriggerNPC)
        if (NPCEntityID ~= nil) then
            self:InternalRemoveFateNpc(NPCEntityID, InFate.ID)
        end
    end

    do
        local function ShowFateTutorial()
            -- 触发新手引导
            local EventParams = _G.EventMgr:GetEventParams()
            EventParams.Type = TutorialDefine.TutorialConditionType.Fate --新手引导触发类型
            _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
        end
        local TutorialConfig = {
            Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
            Callback = ShowFateTutorial,
            Params = {}
        }
        _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
    end

    do
        -- 是否为高危FATE，是就显示一个新手提示
        local bHighRisk = InFate.HighRiskState ~= nil and InFate.HighRiskState > 0
        if (bHighRisk) then
            local function ShowAdvanceFateTutorial()
                -- 触发新手引导
                local EventParams = _G.EventMgr:GetEventParams()
                EventParams.Type = TutorialDefine.TutorialConditionType.AdvanceFate --新手引导触发类型
                _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
            end

            local Config = {
                Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE,
                Callback = ShowAdvanceFateTutorial,
                Params = {}
            }

            _G.TipsQueueMgr:AddPendingShowTips(Config)
        end
        -- end
    end

    if self.EnterArea_Record[InFate.ID] == nil then
        local RealLevel = MajorUtil.GetTrueMajorLevel() -- 当前职业玩家真实的等级，同步前的，如50同步到20，返回的是50
        -- 初次开启时/或者重新登陆进入
        self.EnterArea_Record[InFate.ID] = InFate.ID
        if RealLevel < FateCfg.Level then
            local bIsCelebrateFate = FateCfg.IsCelebrateFate ~= nil and FateCfg.IsCelebrateFate > 0
            if (not bIsCelebrateFate) then
                local TargetID = 190046-- 当前等级较低，无法获得全部报酬
                if (RealLevel <= FateCfg.Level - 8) then
                    -- 如果小于等于8，提示:冒险者的等级过低，参与本次危命任务将无法获得报酬
                    TargetID = 190145
                end
                local TipsStr = LSTR(TargetID)
                self:AppendFateTips(FateTipsType.LevelLowMentionTips, 3, TipsStr)
            end
        end

        self:SendMsgUpdateGatherItemReq()
        do
            if FateCfg ~= nil then
                self:ShowFirstEnterEffect(RealLevel, FateCfg)

                local function ShowTipsCallback(Params)
                end
                local Config = {
                    Type = ProtoRes.tip_class_type.TIP_FATE_NOTICE,
                    Callback = ShowTipsCallback,
                    Params = {
                        SceneLevel = RealLevel,
                        FateCfg = FateCfg
                    }
                }

                _G.TipsQueueMgr:AddPendingShowTips(Config)
            end
            --end
        end
    end

    if (self.ServerCurFateID ~= nil and self.ServerCurFateID > 0) then
        if (self.CurrentFate ~= nil and (self.CurrentFate.ID == self.ServerCurFateID)) then
            _G.FLOG_INFO("登陆后，尝试加入记录的服务器正在进行的FATE, self.ServerCurFateID : %s",self.ServerCurFateID)
            self:InternalExitFate(self.ServerCurFateID)
            self.bWaitExitAndReJoinFate = true
        else
            _G.FLOG_INFO("进入到一个FATE，但是和服务器记录的FATE : %s ,不一样，请求退出", self.ServerCurFateID)
            self:InternalExitFate(self.ServerCurFateID)
            self.ServerCurFateID = 0
        end
    end

    local EventParams = self.CurrentFate
    EventParams.IsEnterArea = true
    _G.EventMgr:SendEvent(EventID.FateUpdate, EventParams)
end

function FateMgr:OnExitArea(InFate, InbNoSendMsg)
    if (InFate == nil) then
        return
    end

    if (self.EnterAreaFate ~= nil and self.EnterAreaFate[InFate.ID] ~= nil) then
        self.EnterAreaFate[InFate.ID] = nil
    end

    if self.CurrentFate == nil or InFate.ID ~= self.CurrentFate.ID then
        return
    end

    FLOG_INFO("[Fate] 离开了区域: %s", table.tostring(InFate.ID))

    local EventParams = self.CurrentFate
    EventParams.IsEnterArea = false
    _G.EventMgr:SendEvent(EventID.FateUpdate, EventParams)

    self:CancelLevelSync(InbNoSendMsg)
    self:SetCurrentFate(nil)
    self:ResetGuardData()
    _G.PWorldMgr:RestoreBGMusic()
end

function FateMgr:OnGameEventChangeHP(Params)
    local EntityID = Params.ULongParam1
    local Hp = Params.ULongParam3
    local HpMax = Params.ULongParam4

    local Attr = ActorUtil.GetActorAttributeComponent(EntityID)
    if (Attr == nil) then
        return
    end

    local UserData = self:TryGetUserData(EntityID)
    if UserData == nil then
        return
    end

    local FateID = UserData.FateID or 0
    if (FateID > 0) then
        if self:IsKillBossHpFate(FateID, Attr) then
            local Fate = self.CurrActiveFateList[FateID]
            if Fate ~= nil then
                Fate.Progress = 100 - 100 * Hp / HpMax
                local EventParams = Fate
                _G.EventMgr:SendEvent(EventID.FateUpdate, EventParams)
            end
        end

        if self.CurrentFate and self.CurrentFate.ID == FateID then
            self:UpdateFateStageInfo()
        end
    end
end

-- 是否通过击杀BOSS的HP影响进度的fate：1、讨伐类  2、防守类(仅有1个100积分的杀怪任务)
---@return boolean
function FateMgr:IsKillBossHpFate(InFateID, InMonsterAttr)
    local FateCfg = self:GetFateCfg(InFateID)
    if FateCfg == nil then
        return false
    end

    local bIsBoss = FateCfg.Type == ProtoRes.Game.FATE_TYPE.FATE_TYPE_BOSS
    local bIsDefence = FateCfg.Type == ProtoRes.Game.FATE_TYPE.FATE_TYPE_DEFENCE

    if (not bIsBoss and not bIsDefence) then
        return false
    end

    local FingAction = nil
    local TargetCfg = FateTargetCfg:FindCfgByKey(InFateID)
    if TargetCfg == nil then
        return false
    end
    for i = 1, #TargetCfg.Actions do
        local Action = TargetCfg.Actions[i]
        local bKillMonster = Action.Type == ProtoRes.Game.FATE_EVENT_CONDITION_TYPE.FATE_EVENT_CONDITION_KILL_MONSTER
        if (bKillMonster and Action.Score == 100) then
            FingAction = Action
            break
        end
    end

    if FingAction ~= nil and FingAction.Params == InMonsterAttr.ResID then
        return true
    end

    return false
end

function FateMgr:OnGameEventTrivialSkillStart(Params)
    local SkillID = Params.IntParam2
    local EntityID = Params.ULongParam1
    local TargetEntityId = Params.ULongParam2
    local MajorEntityID = MajorUtil.GetMajorEntityID()

    --只检测主角释放技能
    if MajorEntityID ~= EntityID then
        return
    end

    if self.CurrentFate == nil or SkillID == 0 then
        return
    end

    --技能判断(只检查攻击和治疗技能)
    local SkillCfg = SkillMainCfg:FindCfgByKey(SkillID)
    --是否治疗技能
    local IsHealSkill = false
    if (SkillCfg.Class & ProtoRes.skill_class.SKILL_CLASS_HEAL) ~= 0 then
        IsHealSkill = true
    end
    --是否攻击技能
    local IsAtkSkill = false
    if (SkillCfg.Class & ProtoRes.skill_class.SKILL_CLASS_ATK) ~= 0 then
        IsAtkSkill = true
    end
    if not (IsHealSkill or IsAtkSkill) then
        return
    end

    --使用鼠标选中的目标(TargetEntityId=0，比如学者的治疗技能 / TargetEntityId=主角,比如白魔的治疗技能)
    if TargetEntityId == nil or TargetEntityId == 0 or TargetEntityId == MajorEntityID then
        local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
        if nil ~= SelectedTarget then
            local TempAttriComp = SelectedTarget:GetAttributeComponent()
            if (TempAttriComp ~= nil) then
                TargetEntityId = TempAttriComp.EntityID
            end
        end
    end

    local UserData = self:TryGetUserData(TargetEntityId)
    if (UserData == nil or UserData.FateID == nil or UserData.FateID <= 0) then
        return
    end

    self:TryShowAttackMentionTips()
end

function FateMgr:OnGameEventLoginRes(Params)
    print("FateMgr:OnGameEventLoginRes")
    local bReconnect = Params.bReconnect

    if (bReconnect) then
        self:ResetData(nil, true, true)
        self:SendGetCurMapActiveFateList()
    end
end

function FateMgr:RefreshLevelSyncState()
    self:InternalRefreshLevelSyncState()
    self:UpdateFateStageInfo()
end

function FateMgr:InternalRefreshLevelSyncState()
    if self.CurrentFate == nil then
        self:InternalSetLevelSyncState(ELevelSyncState.None)
        return
    end

    local FateCfg = self:GetFateCfg(self.CurrentFate.ID)
    if FateCfg == nil then
        _G.FLOG_ERROR("FateMgr:RefreshLevelSyncState() 错误，无法获取 Fate 数据，ID是：%s", self.CurrentFate.ID)
        self:InternalSetLevelSyncState(ELevelSyncState.None)
        return
    end

    local RealLevel = MajorUtil.GetTrueMajorLevel() -- 当前职业玩家真实的等级，同步前的，如50同步到20，返回的是50
    local TargetLevel = FateCfg.SyncMaxLv
    if (TargetLevel == nil or TargetLevel <= 0) then
        TargetLevel = FateCfg.Level + self.LevelLimitMax
    end
    if (self.bJoinFate) then
        -- 加入FATE后需要处理的
        if RealLevel > TargetLevel then
            self:InternalSetLevelSyncState(ELevelSyncState.Synchronized)
        else
            self:InternalSetLevelSyncState(ELevelSyncState.Join)
        end
    else
        -- 如果当前没有加入FATE
        if RealLevel > TargetLevel then
            self:InternalSetLevelSyncState(ELevelSyncState.NotSynchronized)
        else
            self:InternalSetLevelSyncState(ELevelSyncState.NotJoin)
        end
    end
end

function FateMgr:RequireJoinFate(InFateID)
    local TargetFateID = 0
    if (InFateID ~= nil and InFateID > 0) then
        TargetFateID = InFateID
    elseif(self.CurrentFate ~= nil) then
        TargetFateID =  self.CurrentFate.ID
    else
        _G.FLOG_ERROR("当前没有FATE，无法加入，请检查")
        return
    end

    if (TargetFateID == nil or TargetFateID <= 0) then
        _G.FLOG_ERROR("尝试加入FATE，但是FATEID为0，请检查")
        return
    end

    if self.LevelSyncState ~= ELevelSyncState.NotSynchronized and self.LevelSyncState ~= ELevelSyncState.NotJoin then
        _G.FLOG_ERROR("当前状态：%s ， 不符合参与的状态，请检查", self.LevelSyncState)
        return
    end

    -- 新需求，如果角色的职业不是战斗职业，那么提示参加
    -- 当前选中职业类型
    local bIsCombatProf = MajorUtil.GetMajorProfSpecialization() == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT
    if (not bIsCombatProf) then
        _G.MsgTipsUtil.ShowTipsByID(NotBattleJobTipsID) -- 提示 "请切换至战斗职业再参与危命任务"
        return
    end

    _G.FLOG_INFO("尝试加入FATE，ID是:%s", TargetFateID)

    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_ENTER
    local MsgBody = {
        Cmd = SubMsgID,
        FateID = TargetFateID,
        FateEnter = {}
    }

    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

--- 返回 bool ，是否参加了 fate
function FateMgr:IsJoinFate()
    if self.CurrentFate == nil then
        return false
    end

    local Result = self.LevelSyncState ~= nil and (self.LevelSyncState == ELevelSyncState.Synchronized or self.LevelSyncState == ELevelSyncState.Join)
    return Result
end

function FateMgr:InternalSetLevelSyncState(TargetState)
    self.LevelSyncState = TargetState
end

--- InCurWorldInsID 是应服务器需求，添加的，在进入副本的时候，服务器无法确保等级同步的先后顺序
--- 为了修改方便，就让客户端上报的时候带上退出场景时，场景的insId用于判断
function FateMgr:CancelLevelSync(bNoSendMsg, InCurWorldInsID)
    if self.LevelSyncState ~= ELevelSyncState.Synchronized and self.LevelSyncState ~= ELevelSyncState.Join then
        return
    end
    if self.CurrentFate == nil then
        return
    end

    FLOG_INFO("[Fate] Cancel LevelSync")

    local CurFateID = self.CurrentFate.ID

    if (bNoSendMsg == nil or bNoSendMsg == false) then
        self:InternalExitFate(CurFateID, InCurWorldInsID)
    end

    _G.EventMgr:SendEvent(EventID.FateQuit, CurFateID)
end

function FateMgr:InternalExitFate(InFateID, InCurWorldInsID)
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_EXIT
    local MsgID = CS_CMD.CS_CMD_FATE
    local MsgBody = {
        Cmd = SubMsgID,
        FateID = InFateID,
        FateExit = {}
    }
    
    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody, InCurWorldInsID)
end

function FateMgr:TickForFateInfo()
    local MajorLocation = nil
    local Major = MajorUtil.GetMajor()
    if (Major ~= nil) then
        MajorLocation = Major:FGetActorLocation()
    end

    local ServerTimeNow = TimeUtil.GetServerLogicTimeMS()

    for _, TempFate in pairs(self.CurrActiveFateList) do
        self:InternalTickForFateRange(TempFate, MajorLocation)

        self:GuardCalcProgressAndPos(TempFate, true, true)

        self:InternalTickForFateEndTime(TempFate, ServerTimeNow)
    end

    for Index = #self.FateAlreadyEndTable, 1, -1 do
        local Record = self.FateAlreadyEndTable[Index]
        if (Record.Times >= 2) then
            -- 移除，并发消息
            local TempFate = self.CurrActiveFateList[Record.FateID]
            if (TempFate ~= nil) then
                local EventParams = TempFate
                _G.EventMgr:SendEvent(EventID.FateEnd, EventParams)

                if (self.CurrentFate ~= nil and self.CurrentFate.ID == TempFate.ID) then
                    _G.FLOG_INFO("[Fate] : %d 已经到时间，将移除", TempFate.ID)
                    local bNoSendReqest = true
                    self:OnExitArea(self.CurrentFate, bNoSendReqest)
                end

                self.CurrActiveFateList[Record.FateID] = nil
                local InfoStr = string.format("当前FATE ： %s ,超时了，移除掉", Record.FateID)
                _G.FLOG_INFO(InfoStr)
            end

            table.remove(self.FateAlreadyEndTable, Index)
        end
    end
end

-- 这里本地做一下FATE是否完结的检测，网络通信有可能信号不好，导致本地收不到结束的消息
function FateMgr:InternalTickForFateEndTime(InFate, InServerTimeNow)
    if (InFate == nil) then
        return
    end
    if (InServerTimeNow == nil) then
        _G.FLOG_ERROR("传入的 InServerTimeNow 为空，请检查")
        return
    end

    if (InFate.EndTime == nil) then
        _G.FLOG_ERROR("Fate 的结束时间无效，请检查，ID是：" .. tostring(InFate.ID))
        return
    end

    if (InFate.EndTime > 0 and InServerTimeNow > InFate.EndTime) then
        if (self.FateAlreadyEndTable == nil) then
            self.FateAlreadyEndTable = {}
        end

        local TargetRecord = nil
        for i = 1, #self.FateAlreadyEndTable do
            if (self.FateAlreadyEndTable[i].FateID == InFate.ID) then
                TargetRecord = self.FateAlreadyEndTable[i]
                break
            end
        end

        if (TargetRecord ~= nil) then
            TargetRecord.Times = 2
        else
            -- 这里记录一下，然后等待1秒，下次再删除
            local NewRecord = {}
            NewRecord.FateID = InFate.ID
            NewRecord.Times = 1
            table.insert(self.FateAlreadyEndTable, NewRecord)
        end
    end
end

function FateMgr:InternalTickForFateRange(InFate, InMajorLocation)
    if (InMajorLocation == nil) then
        return
    end

    -- 没有触发的，不做检测
    local bWaitTrigger = InFate.State == ProtoCS.FateState.FateState_WaitNPCTrigger
    if (bWaitTrigger) then
        return
    end

    local CurrentMapResID = _G.PWorldMgr:GetCurrMapResID()
    if CurrentMapResID == InFate.MapID then
        local FateCenter = InFate.FateCenter
        local FateRadius = InFate.FateRadius or 0
        local FateHeight = InFate.FateHeight
        local HintRange = InFate.HintRange
        if (FateCenter == nil or FateRadius == nil or FateHeight == nil or HintRange == nil) then
            FLOG_ERROR("配置错误，请检查Fate=" .. InFate.ID .. "的FateCenter、FateRadius、FateHeight、HintRange字段")
        else
            local Dist = InMajorLocation:Dist2D(FateCenter)
            if ((InMajorLocation.Z <= FateCenter.Z + FateHeight) and (InMajorLocation.Z >= FateCenter.Z - FateHeight)) then
                -- 检测 警示区域
                if Dist > HintRange then
                    self:OnExitHintArea(InFate)
                else
                    if (Dist > FateRadius) then
                        self:OnEnterHintArea(InFate)
                    end
                end

                -- 检测 战斗区域
                if Dist > FateRadius then
                    if (self.CurrentFate ~= nil and InFate.ID == self.CurrentFate.ID) then
                        _G.FLOG_INFO("1 [Fate] 玩家离开FATE:%d 的范围将退出FATE，范围是：%s", InFate.ID, FateRadius)
                        self:OnExitArea(InFate)
                    end
                else
                    if (self.CurrentFate == nil) then
                        self:OnEnterArea(InFate)
                    end
                end
            else
                if (self.CurrentFate ~= nil and InFate.ID == self.CurrentFate.ID) then
                    _G.FLOG_INFO("2 [Fate] 玩家离开FATE:%d 的范围将退出FATE，范围是：", InFate.ID)
                end
                self:OnExitArea(InFate)
            end
        end
    end
end

function FateMgr:OnStartFateInteractiveClick(ResID, InEntityID)
    local UserData = self:TryGetUserData(InEntityID)
    if (UserData == nil) then
        return
    end

    local FateID = UserData.FateID or 0
    if (FateID <= 0) then
        return
    end

    local FateCfg = self:GetFateCfg(FateID)
    if FateCfg == nil then
        _G.FLOG_WARNING("[Fate] Wrong fateID: " .. tostring(FateID))
        return
    end
    local NpcDialogCfg = FateNpcDialogCfg:FindCfgByKey(FateID)

    local function PlayDialogLibCallback()
        local function Confirm()
            local DialogLibID = (nil == NpcDialogCfg) and 0 or NpcDialogCfg.StartDialogLibID
            if DialogLibID ~= 0 then
                NpcDialogMgr:OverrideStateEnd()
                NpcDialogMgr:PlayDialogLib(DialogLibID, InEntityID, false)
            end

            -- 这里要看一下如果FATE已经结束了，那么不发送，弹出一个提示
            local TargetFate = self.CurrActiveFateList[FateID]
            if (TargetFate == nil or TargetFate.State == ProtoCS.FateState.FateState_Finished) then
                MsgTipsUtil.ShowTips(LSTR(190056))
                return
            end

            if (TargetFate.State ~= ProtoCS.FateState.FateState_WaitNPCTrigger) then
                MsgTipsUtil.ShowTips(LSTR(190057))
                return
            end

            local MsgID = CS_CMD.CS_CMD_FATE
            local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_NPC_START
            local MsgBody = {
                Cmd = SubMsgID,
                FateID = FateID,
                FateNPCStart = {}
            }
            self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
        end

        local function Cancel()
            local DialogLibID = (nil == NpcDialogCfg) and 0 or NpcDialogCfg.DenyDialogLibID
            if DialogLibID ~= 0 then
                NpcDialogMgr:OverrideStateEnd()
                NpcDialogMgr:PlayDialogLib(DialogLibID, InEntityID, false)
            end
        end

        local MessageBoxText = LSTR(190058)
        if NpcDialogCfg ~= nil then
            local SearchConditions = string.format("DialogLibID==%d", NpcDialogCfg.OpenConfirmDialogLibID)
            local DialogCfg = DialogCfg:FindCfg(SearchConditions)
            if DialogCfg ~= nil then
                MessageBoxText = string.gsub(DialogCfg.DialogContent, LevelText, FateCfg.Level)
            end
        end
        MsgBoxUtil.MessageBox(MessageBoxText, LSTR(10027), LSTR(10028), Confirm, Cancel, nil, nil, true)
    end

    local DialogLibID = (nil == NpcDialogCfg) and 0 or NpcDialogCfg.TriggerDialogLibID
    NpcDialogMgr:OverrideStatePending()
    NpcDialogMgr:PlayDialogLib(DialogLibID, InEntityID, false, PlayDialogLibCallback)
end

function FateMgr:OnProcessingInteractiveClick(InResID, InEntityID)
    local CurrentFateType = self:GetCurrentFateType()
    if (CurrentFateType == ProtoRes.Game.FATE_TYPE.FATE_TYPE_COLLECT) then
        -- 物品采集fate 提交物品对话逻辑
        self:OnItemCollectInteractive(InResID, InEntityID)
    elseif (CurrentFateType ~= ProtoRes.Game.FATE_TYPE.FATE_TYPE_INVALID) then
        local UserData = self:TryGetUserData(InEntityID)
        if (UserData == nil) then
            return
        end

        local FateID = UserData.FateID or 0
        local FateCfg = self:GetFateCfg(FateID)
        if FateCfg == nil then
            _G.FLOG_WARNING("[Fate] Wrong fateID: " .. tostring(FateID))
            return
        end
        local NpcDialogCfg = FateNpcDialogCfg:FindCfgByKey(FateID)
        local bIsTargetFateType =
            CurrentFateType == ProtoRes.Game.FATE_TYPE.FATE_TYPE_MONSTER or
            CurrentFateType == ProtoRes.Game.FATE_TYPE.FATE_TYPE_BOSS or
            CurrentFateType == ProtoRes.Game.FATE_TYPE.FATE_TYPE_DEFENCE

        if NpcDialogCfg ~= nil then
            local PlayDialogLib = NpcDialogCfg.TriggerDialogLibID
            -- 如果AfterDialogLibID为0，还是用初始的对话
            if NpcDialogCfg.AfterDialogLibID ~= 0 then
                PlayDialogLib = bIsTargetFateType and NpcDialogCfg.AfterDialogLibID or NpcDialogCfg.TriggerDialogLibID
            end
            NpcDialogMgr:PlayDialogLib(PlayDialogLib, InEntityID, false, nil)
        end
    else
        FLOG_ERROR("无效的Fate类型 ： %s , 请检查", tostring(CurrentFateType))
    end
end

function FateMgr:GetFateSpecialTexet(InFateID)
    local Cfg = self:GetFateCfg(InFateID)
    if (Cfg == nil) then
        return nil
    end
    local Text = Cfg.FateSpecialText
    if (Text == nil) then
        return nil
    end

    local FinalStr = LSTR(190124)..Cfg.FateSpecialText
    return FinalStr
end

function FateMgr:GetNPCHudIcon(InEntityID)
    local UserData = self:TryGetUserData(InEntityID)
    if (UserData == nil) then
        return nil
    end
    local FateID = UserData.FateID or 0
    local FateCfg = self:GetFateCfg(FateID)
    if FateCfg == nil then
        return nil
    end

    local Fate = self.CurrActiveFateList[FateID]
    if Fate == nil then
        return nil
    end
    local bFinish = Fate.State == ProtoCS.FateState.FateState_Finished
    if (bFinish) then
        return nil
    end
    local bInProgress = Fate.State == ProtoCS.FateState.FateState_InProgress
    local bEndSubmit = Fate.State == ProtoCS.FateState.FateState_EndSubmitItem
    if Fate.State == ProtoCS.FateState.FateState_WaitNPCTrigger then
        return FateDefine.GetIcon(ProtoRes.FateIconType.ICON_NPC_WAIT)
    elseif bInProgress or bEndSubmit then
        if Fate.FateType == ProtoRes.Game.FATE_TYPE.FATE_TYPE_COLLECT then
            return FateDefine.GetIconByFateID(FateID)
        end
        return nil
    end
    return nil
end

--- func desc
---@param InFateId int
function FateMgr:GetActiveFateById(InFateId)
    local TargetFate = self.CurrActiveFateList[InFateId]
    if (TargetFate == nil) then
        return nil
    end

    return TargetFate
end

function FateMgr:GetFateCfg(FateID)
    if (FateID == nil) then
        _G.FLOG_ERROR("尝试获取Fate数据，但是传入的 FateID为空，请检查")
        return nil
    end
    if (self.FateCfgCache == nil) then
        self.FateCfgCache = {}
    end
    if self.FateCfgCache[FateID] == nil then
        local FateCfg = FateMainCfgTable:FindCfgByKey(FateID)
        self.FateCfgCache[FateID] = FateCfg
        return FateCfg
    else
        return self.FateCfgCache[FateID]
    end
end

function FateMgr:OnPaintFateOnMap()
end

function FateMgr:GetCurrentFate()
    return self.CurrentFate
end

--更新主界面右上角fate进度状态
function FateMgr:UpdateFateStageInfo()
    if (self.CurrentFate == nil) then
        _G.FLOG_INFO("FateMgr:UpdateFateStageInfo() 当前 Fate 为空，隐藏右上角 Fate 信息")
        MainPanelVM:SetFateStageVisible(false)
        return
    end

    if (self.FateVM == nil) then
        _G.FLOG_ERROR("FateMgr:UpdateFateStageInfo() 出错，当前的 FateVM 为空，将重新获取")
        self.FateVM = require("Game/Fate/VM/FateVM")
    end

    if (self.FateVM == nil) then
        _G.FLOG_ERROR("FateMgr:UpdateFateStageInfo() 出错，再次获取 FateVM 为空，隐藏右上角 Fate 信息")
        MainPanelVM:SetFateStageVisible(false)
        return
    end

    local bInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    if (bInDungeon) then
        _G.FLOG_INFO("当前在副本中，不显示FATE右上角信息")
        MainPanelVM:SetFateStageVisible(false)
        return
    end

    local bIsExpanded = true
    if self.FateVM:GetStageInfo() ~= nil then
        bIsExpanded = self.FateVM:GetStageInfo().bIsExpanded
    end

    if (self.NeedForceShowInfo) then
        self.NeedForceShowInfo = false
        bIsExpanded = true
    end

    if (bIsExpanded) then
        -- 策划需求，在有任意指引的时候，不显示
        -- https://tapd.tencent.com/tapd_fe/20420083/bug/detail/1020420083141113632
        if _G.NewTutorialMgr.TutorialState and _G.NewTutorialMgr:GetRunningSubGroup() then
            _G.FLOG_INFO("FateMgr:UpdateFateStageInfo() ，当前有指引，根据需求，不显示右上角Fate信息，将进入每秒检测，等指引结束再显示")
            self.bNeedReCheckState = true
        else
            MainPanelVM:SetFateStageVisible(true)
        end
    else
        _G.FLOG_INFO("FateMgr:UpdateFateStageInfo() ，当前设置为不展开，隐藏主要信息，但是显示可以展开的按钮")
        --MainPanelVM:SetFateStageVisible(true)
    end

    local VMValue = {
        LevelSyncState = self.LevelSyncState,
        bIsExpanded = bIsExpanded,
        TargetFate = self.CurrentFate
    }

    _G.FLOG_INFO("FateMgr:UpdateFateStageInfo() 更新右上角信息")
    self.FateVM:SetStageInfo(VMValue)
end

function FateMgr:IsHighRiskFate(InFateID)
    if (InFateID == nil) then
        return false
    end

    if (self.CurrActiveFateList == nil) then
        return false
    end

    local FateInfo = self.CurrActiveFateList[InFateID]
    if (FateInfo == nil) then
        return false
    end

    return FateInfo.HighRiskState ~= nil and FateInfo.HighRiskState > 0
end

-- 收集配置中的地图关联Fate信息，一般只执行一遍
function FateMgr:GatherMapFateStageInfo(bForceReload)
    if (self.FateMapInfo == nil or self.Fate2MapID == nil or bForceReload == true) then
        self.FateMapInfo = {}
        self.Fate2MapID = {}
        local AllGeneratorCfg = FateGeneratorCfgTable:FindAllCfg()
        for _, Generator in pairs(AllGeneratorCfg) do
            if Generator.MapID ~= nil and Generator.MapID ~= 0 then
                local FateCfg = self:GetFateCfg(Generator.ID)
                if (FateCfg ~= nil and FateCfg.Name ~= nil and FateCfg.Name ~= "") then
                    local bShowInArchive = FateCfg.bHideInArchive == false or FateCfg.bHideInArchive == 0
                    if (bShowInArchive) then
                        if self.FateMapInfo[Generator.MapID] == nil then
                            self.FateMapInfo[Generator.MapID] = {}
                        end
                        table.insert(self.FateMapInfo[Generator.MapID], FateCfg)
                        self.Fate2MapID[FateCfg.ID] = Generator.MapID
                    end
                end
            end
        end
        for k, v in pairs(self.FateMapInfo) do
            local FateEventList = v
            table.sort(
                FateEventList,
                function(A, B)
                    return A.Level < B.Level
                end
            )
            self.FateMapInfo[k] = FateEventList
        end
    end

    return self.FateMapInfo, self.Fate2MapID
end

function FateMgr:OnCheckNewMapReward(InFateID, OldValue, NewValue)
    if (InFateID == nil or InFateID <= 0) then
        _G.FLOG_ERROR("传入的数据有误，请检查")
        return
    end

    local FinalFateID = InFateID
    local FinalOldValue = OldValue
    local FinalNewValue = NewValue
    local MapID = self:GetMapIDByFateID(FinalFateID)
    if (MapID == nil or MapID <=0) then
        _G.FLOG_ERROR("无法获取 %s 所属的地图", FinalFateID)
        return
    end

    local RewardMapData = FateAchievementRewardCfg:FindCfgByKey(MapID)
    if (RewardMapData == nil) then
        _G.FLOG_ERROR("无法获取隐藏地图奖励，FATEID : %s, 地图ID : %s", InFateID, MapID)
        return
    end
    local MapData = MapCfg:FindCfgByKey(MapID)
    if (MapData == nil) then
        _G.FLOG_ERROR("无法获取地图信息，ID是 : %s", MapID)
        return
    end

    local MaxIndex = #RewardMapData.Rewards
    local MaxTargetCount = 0
    do
        for Index = 1, MaxIndex do
            if (RewardMapData.Rewards[Index].Target <=0) then
                break
            end
            if (RewardMapData.Rewards[Index].Target > MaxTargetCount) then
                MaxTargetCount = RewardMapData.Rewards[Index].Target
            end
        end
    end

    do
        for Index = MaxIndex, 1, -1  do
            local TargetCount = RewardMapData.Rewards[Index].Target
            if (FinalOldValue < TargetCount and FinalNewValue >= TargetCount) then
                -- 这里就弹出显示一下
                _G.LeftSidebarMgr:AppendPerform(
                    SidebarDefine.LeftSidebarType.Fate,
                    {
                        Title = LSTR(190120)..LSTR(190121),
                        Content = string.format(
                            "%s %s/%s",MapData.DisplayName,
                            TargetCount,
                            MaxTargetCount
                        ),
                        ClickCallback = function()
                            -- 打开图鉴
                            local bShowRewardPanel = true
                            local bHideArchive = false
                            self:ShowFateArchive(InFateID, 0, bShowRewardPanel, bHideArchive)
                        end
                    }
                )
                return
            end
        end
    end
end

function FateMgr:GetMapIDByFateID(InFateID)
    if (InFateID == nil or InFateID<=0) then
        return nil
    end

    local FateGenTableData =  FateGeneratorCfgTable:FindCfgByKey(InFateID)
    if (FateGenTableData == nil) then
        _G.FLOG_ERROR("FateGeneratorCfgTable:FindCfgByKey 错误，无法获取数据, ID是：%s", InFateID)
        return nil
    end

    return FateGenTableData.MapID
end

function FateMgr:IsFateAchievementFinish(FateID)
    local FateInfo = self:GetFateInfo(FateID)
    if FateInfo == nil then
        return false
    end
    local finishCount = 0
    for _, Event in ipairs(FateInfo.Achievement) do
        if (Event.Target ~= nil and Event.Target > 0 and Event.Progress ~= nil) then
            local bFinish = Event.Progress >= Event.Target
            if bFinish then
                finishCount = finishCount + 1
            end
        end
    end
    if finishCount == 4 then
        return true
    end
    return false
end

function FateMgr:ShowDebugUI(flag)
    print("FateMgr:ShowDebugUI ", flag)
    local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
    FateArchiveMainVM.bShowDebugUI = flag
end

function FateMgr:ForceShowAll(flag)
    print("FateMgr:bForceShowAll ", flag)
    local FateArchiveMainVM = require("Game/FateArchive/VM/FateArchiveMainVM")
    FateArchiveMainVM.bForceShowAll = flag
end

-- 打开图鉴，如果传入ID，那么会跳转到指定的FATE
-- FateID in32 指定的FATEID，会自动跳转显示到指定条目
-- MapID int32 指定的地图ID，如果有FateID，那么FateID优先
-- InbShowRewardPanel 是否显示地图的奖励，布尔值，默认nil 、false， 不显示地图奖励
-- bHideFateArchive 默认false,是否隐藏图鉴，有其他的跳转只需要获取数据，不打开图鉴，这个就填写true，否则写false或者，nil
function FateMgr:ShowFateArchive(FateID, InMapID, InbShowRewardPanel, bHideFateArchive)
    self.SelectedFateID = FateID
    self.bHideFateArchive = bHideFateArchive
    self.FateArchiveShowMapID = InMapID
    self.bShowRewardPanel = InbShowRewardPanel
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_GET_RECORD
    local MsgBody = {
        Cmd = SubMsgID,
        FateGetRecord = {}
    }
    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

function FateMgr:OnNetMsgGetRecord(MsgBody)
    self.FateRecordTable = {}
    self.FateMapState = {}
    FLOG_INFO("[Fate] Response Get Record: %s", table.tostring(MsgBody))
    local RecordList = MsgBody.FateGetRecord.Record
    for i = 1, #RecordList do
        local Record = RecordList[i]
        self.FateRecordTable[Record.FateID] = Record
    end
    local MapStateList = MsgBody.FateGetRecord.MapState
    -- TODO:临时测试数据
    if #MapStateList == 0 then
        MapStateList = {
            {
                MapID = 11003,
                CurProgress = 25,
                MaxProgress = 50,
                AwardedRewards = {
                    0,
                    1
                }
            },
            {
                MapID = 11005,
                CurProgress = 30,
                MaxProgress = 60,
                AwardedRewards = {
                    0
                }
            }
        }
    end
    for i = 1, #MapStateList do
        local MapState = MapStateList[i]
        self.FateMapState[MapState.MapID] = MapState
    end

    if not self.bHideFateArchive then
        UIViewMgr:ShowView(UIViewID.FateArchiveMainPanel)
    end
    self.SelectedFateID = nil
    self.bShowRewardPanel = false
    self.FateArchiveShowMapID = 0
    _G.EventMgr:SendEvent(EventID.FateArchiveDataUpdate, self.bHideFateArchive)
end

function FateMgr:GetFateInfo(FateID)
    if self.FateRecordTable ~= nil then
        return self.FateRecordTable[FateID]
    end

    return nil
end

function FateMgr:GetMapState(MapID)
    if (self.FateMapState == nil) then
        _G.FLOG_ERROR("当前 self.FateMapState 为空，但是有数据需求，请检尝试查原因")
        return nil
    end
    return self.FateMapState[MapID]
end

function FateMgr:GetAllMapState()
    return self.FateMapState or {}
end

function FateMgr:GetAllFateRecord()
    return self.FateRecordTable
end

function FateMgr:GetLevelSyncState()
    return self.LevelSyncState
end

---领取地图奖励相关的内容
function FateMgr:SendGetMapReward(MapID, Index)
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_GET_ACH_MAP_REWARD
    local MsgBody = {
        Cmd = SubMsgID,
        FateGetAchMapReward = {
            MapID = MapID,
            RewardIndex = Index - 1 -- 这里是从0开始的
        }
    }
    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

function FateMgr:OnNetMsgGetAchMapReward(MsgBody)
    FLOG_INFO("[Fate] Response Get Map Reward: %s", table.tostring(MsgBody))
    local RewardState = MsgBody.FateGetAchMapReward
    -- if RewardState.Success then -- 协议内容已经废弃不用就行
    local MapState = RewardState.MapState
    self.FateMapState[MapState.MapID] = MapState
    -- 事件通知界面刷新
    _G.EventMgr:SendEvent(EventID.FateMapRewardUpdate)
    -- end
end

---请求Fate统计界面的数据
function FateMgr:SendGetFateStats()
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_GET_STATS
    local MsgBody = {
        Cmd = SubMsgID,
        FateStats = {}
    }
    self.FateWorldStats = {}
    self.FatePlayerStats = {}
    self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
end

---接受Fate统计界面的数据
function FateMgr:OnNetMsgGetFateStats(MsgBody)
    FLOG_INFO("[Fate] Response Get Fate Stats: %s", table.tostring(MsgBody))
    local FateStats = MsgBody.FateStats
    self.FateWorldStats = {}
    self.FatePlayerStats = FateStats.PlayerStats
    for Key, Value in pairs(self.FatePlayerStats) do
        if (Value.Percent == nil or Value.Percent < 0) then
            Value.Percent = 0
        elseif (Value.Percent > 100) then
            Value.Percent = 100
        end
    end
    table.sort(
        FateStats.PlayerStats,
        function(A, B)
            return A.Percent < B.Percent
        end
    )
    for _, v in pairs(FateStats.WorldStats) do
        if self.FateWorldStats[v.Type] == nil then
            self.FateWorldStats[v.Type] = {}
        end
        if (v.Percent == nil or v.Percent < 0) then
            v.Percent = 0
        elseif (v.Percent > 100) then
            v.Percent = 100
        end
        table.insert(self.FateWorldStats[v.Type], v)
    end
    for k, v in pairs(self.FateWorldStats) do
        table.sort(
            v,
            function(A, B)
                return A.Percent > B.Percent
            end
        )
    end

    -- 发送消息打开
    _G.EventMgr:SendEvent(EventID.FateOpenStatisticsPanel)
end

FateMgr.UnknownMonsterIconColor = "313131FF"
function FateMgr:GetUnknownMonsterIconColor()
    return self.UnknownMonsterIconColor
end

FateMgr.UnknownMonsterIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_Unknown.UI_FateArchive_Img_Unknown'"
function FateMgr:GetUnknownIcon()
    return self.UnknownMonsterIcon
end

FateMgr.DefaultMonsterIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_Monster01.UI_FateArchive_Img_Monster01'"
function FateMgr:GetDefaultIcon()
    return self.DefaultMonsterIcon
end

FateMgr.DefaultMonsterTabBGIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_Main_ListMountBG01.UI_FateArchive_Img_Main_ListMountBG01'"
FateMgr.DefaultMonsterBGIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_Main_RightMountBG01.UI_FateArchive_Img_Main_RightMountBG01'"
FateMgr.DefaultMonsterCardBGIcon = "Texture2D'/Game/UI/Texture/FateArchive/UI_FateArchive_Img_IncidentCount_MountBG01.UI_FateArchive_Img_IncidentCount_MountBG01'"

function FateMgr:GetMonsterIcon(FateID)
    local ParamCfg = FateModelParamCfg:FindCfgByKey(FateID)
    if ParamCfg ~= nil then
        return ParamCfg.MonsterIcon
    else
        return self.DefaultMonsterIcon
    end
end

function FateMgr:IsReplaceModel(FateID)
    local ParamCfg = FateModelParamCfg:FindCfgByKey(FateID)
    if ParamCfg ~= nil then
        return (ParamCfg.IsReplaceModel == true)
    else
        return false
    end
end

function FateMgr:GetWorldEventData(Type)
    if (self.FateWorldStats[Type] == nil) then
        self.FateWorldStats[Type] = {}
    end
    local TempList = self.FateWorldStats[Type]
    local bMonster = Type == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_POWERFUL_MONSTER
    local bHardFate = Type == ProtoCS.CS_FATE_STATS.CS_FATE_STATS_DIFFICULT_FATE
    if (bMonster or bHardFate) then
        self:InternalFillFakeWorldEventData(TempList)
    end
    local Result = {}
    for i, v in ipairs(TempList) do
        v.Index = i
        table.insert(Result, v)
    end
    self.CurEventType = Type
    self.CurEventData = Result
    return Result
end

function FateMgr:InternalFillFakeWorldEventData(InList)
    if (InList == nil) then
        return
    end
    local HaveCount = #InList
    if (HaveCount >= 20) then
        return
    end

    local NeedFillCount = 20 - HaveCount -- 需要填充的数量

    for Index = 1, #self.FakeFateWorldStatsForMonster do
        local FillItem = self.FakeFateWorldStatsForMonster[Index]
        local TargetItem, ItemIndex = table.find_item(InList, FillItem.FateID, "FateID")
        if (TargetItem == nil) then
            -- body
            table.insert(InList, FillItem)
            NeedFillCount = NeedFillCount - 1

            if (NeedFillCount <= 0) then
                break
            end
        end
    end
end

function FateMgr:GetMyEventData()
    if self.FatePlayerStats == nil then
        local TempList = {
            {ID = 1, Percent = 1, Params = {1}},
            {ID = 2, Percent = 2, Params = {2}},
            {ID = 3, Percent = 3, Params = {3}},
            {ID = 4, Percent = 4, Params = {11003, 10}},
            {ID = 5, Percent = 5, Params = {11004, 20}},
            {ID = 6, Percent = 10, Params = {20}},
            {ID = 7, Percent = 10, Params = {10}},
            {ID = 8, Percent = 15, Params = {30}},
            {ID = 9, Percent = 16, Params = {120, 30}},
            {ID = 10, Percent = 20, Params = {10, 30}}
        }
        return TempList
    end
    return self.FatePlayerStats
end

function FateMgr:GetCurWorldEventData()
    return self.CurEventData, self.CurEventType
end
-------------------------------------------------护送相关 Fate-------------------------------------------------

function FateMgr:ResetGuardData()
    self.CurGuardPatrolPath = nil -- 当前护送任务，进度计算的路径点
    self.CurGuardPatrolPoint = nil -- 当前护送任务，进度计算的路径点下，包含的坐标的下标
    self.CurGuardProgStartPos = nil -- 当前护送任务，进度计算开始位置
    self.CurGuardProgEndPos = nil -- 当前护送任务，进度计算结束位置
    self.CurGuardProgPercentage = 1 -- 当前护送任务，进度计算，每一个段落进度百分比
    self.CurrentDistance = 0 -- 当前护送任务，进度计算的开始点和结束点的距离
    self.CurGuardPatrolPathPoints = 1 -- 当前护送任务，该路径点下，包含几个具体坐标点
    self.CurGuardPathData = nil -- 当前寻路路径数据
end

function FateMgr:InternalCalcProgWhenPathIDChange(TargetPathID, IndexInPatrolPath, FateGuardData)
    self.CurGuardPatrolPath = TargetPathID
    if (IndexInPatrolPath == 0 or IndexInPatrolPath == 1) then
        local FateCfg = self:GetFateCfg(self.CurrentFate.ID)
        self.CurGuardProgStartPos = FateDefine.ParseLocation(FateCfg.TriggerNPCLocation)
    else
        local _prePatrolPath = FateGuardData.Points[IndexInPatrolPath - 1]
        local _prePathData = _G.MapEditDataMgr:GetPath(_prePatrolPath)
        local _tempPoint = _prePathData.Points[#_prePathData.Points].Point
        self.CurGuardProgStartPos = _G.UE.FVector(_tempPoint.X, _tempPoint.Y, _tempPoint.Z)
    end
    self.CurGuardPatrolPoint = 1
    -- 需要重新设置ENDPOS
    self.CurGuardPathData = _G.MapEditDataMgr:GetPath(self.CurGuardPatrolPath)
    local _pointData = self.CurGuardPathData.Points[self.CurGuardPatrolPoint]
    self.CurGuardPatrolPathPoints = #self.CurGuardPathData.Points
    self.CurGuardProgEndPos = _G.UE.FVector(_pointData.Point.X, _pointData.Point.Y, _pointData.Point.Z)
    self.CurGuardProgPercentage = 1 / self.CurGuardPatrolPathPoints
    self.CurrentDistance = (self.CurGuardProgEndPos - self.CurGuardProgStartPos):Size()
    if (self.CurrentDistance < 10) then
        self.CurrentDistance = nil
    end
end

function FateMgr:InternalCalcProgWhenPointChange(TargetPoint)
    self.CurGuardPatrolPoint = TargetPoint
    -- 有可能不同的Point切换了，需要重新设置ENDPOS
    local PathData = _G.MapEditDataMgr:GetPath(self.CurGuardPatrolPath)
    local _preIndex = TargetPoint - 1
    if (_preIndex < 1) then
        _preIndex = 1
    end
    if (PathData ~= nil) then
        local _prePoint = PathData.Points[_preIndex].Point
        local _pointData = PathData.Points[self.CurGuardPatrolPoint]
        self.CurGuardProgStartPos = _G.UE.FVector(_prePoint.X, _prePoint.Y, _prePoint.Z)
        self.CurGuardProgEndPos = _G.UE.FVector(_pointData.Point.X, _pointData.Point.Y, _pointData.Point.Z)
    end

    self.CurrentDistance = (self.CurGuardProgEndPos - self.CurGuardProgStartPos):Size()
    if (self.CurrentDistance < 10) then
        self.CurrentDistance = nil
    end
end

--- func desc
---@param Fate InFate
---@param NeedUpdatePos bool 更新当前 fate 的位置
---@param SendEvent bool 发送消息，有可能外面发送
function FateMgr:GuardCalcProgressAndPos(InFate, NeedUpdatePos, SendEvent)
    if (InFate == nil or InFate.Npc == nil or InFate.FateType ~= ProtoRes.Game.FATE_TYPE.FATE_TYPE_ESCORT) then
        return
    end

    local FateGuardData = FateGuardCfg:FindCfgByKey(InFate.ID)
    local IndexInPatrolPath = 0
    local PathListCount = 0
    for i = 1, #FateGuardData.Points do
        if (FateGuardData.Points[i].RoutePoint > 0 and FateGuardData.Points[i].RoutePoint == InFate.Npc.PatrolPath) then
            IndexInPatrolPath = i
            break
        end
    end
    for i = 1, #FateGuardData.Points do
        if (FateGuardData.Points[i].RoutePoint > 0) then
            PathListCount = PathListCount + 1
        end
    end

    local SingleProgForPhase = 1 / PathListCount
    local FateEntityID = InFate.Npc.EntityID
    local TargetActor = ActorUtil.GetActorByEntityID(FateEntityID)

    if (InFate.Npc.PatrolPath > 0) then
        local MinProgressForCurrent = 0
        if (IndexInPatrolPath > 0) then
            MinProgressForCurrent = (IndexInPatrolPath - 1) / PathListCount
        end

        local PathData = _G.MapEditDataMgr:GetPath(InFate.Npc.PatrolPath)
        local SingelProgress = 0
        if (PathData ~= nil and PathData.Points ~= nil) then
            SingelProgress = 1 / #PathData.Points
        else
            FLOG_ERROR("_G.MapEditDataMgr:GetPath 获取数据出错，目标ID是：" .. tostring(InFate.Npc.PatrolPath))
        end

        local _finalProgress = (SingelProgress * InFate.Npc.PatrolPoint) * SingleProgForPhase
        InFate.Progress = math.ceil((MinProgressForCurrent + _finalProgress) * 100)
    end

    if (NeedUpdatePos) then
        if (TargetActor == nil) then
            -- 如果没有，那么取获取一下地图点的位置
            local PathData = _G.MapEditDataMgr:GetPath(InFate.Npc.PatrolPath)
            if (PathData ~= nil and PathData.Points ~= nil and #PathData.Points > 0) then
                local TempCenter = PathData.Points[InFate.Npc.PatrolPoint]
                if (TempCenter ~= nil and TempCenter.Point ~= nil) then
                    InFate.FateCenter.X = TempCenter.Point.X
                    InFate.FateCenter.Y = TempCenter.Point.Y
                    InFate.FateCenter.Z = TempCenter.Point.Z
                else
                    FLOG_ERROR("计算的 FateCenter 为空，请检查")
                end
            end
        else
            local NPCEntityID = ActorUtil.GetActorEntityIDByResID(InFate.TriggerNPC)
            if (NPCEntityID ~= nil) then
                self:InternalRemoveFateNpc(NPCEntityID, InFate.ID)
            end

            -- 如果有，那么获取他的位置
            local TempCenter = TargetActor:FGetActorLocation()
            if (TempCenter ~= nil) then
                InFate.FateCenter = TempCenter
            else
                FLOG_ERROR("TargetActor的 ActorLocation 为空，请检查")
            end
        end
    end

    if (SendEvent and InFate.State ~= ProtoCS.FateState.FateState_Finished) then
        local EventParams = InFate
        _G.EventMgr:SendEvent(EventID.FateUpdate, EventParams)
    end

    if (self.CurrentFate ~= nil and self.CurrentFate.ID == InFate.ID) then
        self:UpdateFateStageInfo()
    end
end

function FateMgr:GuardOnFindPathNotify(MsgBody)
    local FindPathRsp = MsgBody
    if not FindPathRsp or self.GuardFindPathSeqID ~= FindPathRsp.id then
        return
    end
    self.GuardFindPathSeqID = 0
    local PointNum = #FindPathRsp.NavPoints
    if PointNum <= 1 then
        FLOG_INFO("未能找到寻路路径，请检查")
        return
    end

    self:GuardConvertFindPathRsp(FindPathRsp)
end

function FateMgr:GuardConvertFindPathRsp(FindPathRsp)
    self.GuardPointListRsp = {}
    self.CurPointIndex = 1

    local WorldOriginLoc = _G.PWorldMgr:GetWorldOriginLocation()
    local PointNum = #FindPathRsp.NavPoints
    for index = 1, PointNum do
        local Pos = FindPathRsp.NavPoints[index].point_data
        local FVectorPos = _G.UE.FVector(Pos.X, Pos.Y, Pos.Z) - WorldOriginLoc
        table.insert(self.GuardPointListRsp, FVectorPos)
    end
end

-------------------------------------------------结束-------------------------------------------------

-------------------------------------------------Npc物品采集fate交互 start--------------------------------------------------------
-- 开始提交物品NPC交互
---OnItemCollectInteractive
---@param ResID number
---@param EntityID number
function FateMgr:OnItemCollectInteractive(ResID, InEntityID)
    local UserData = self:TryGetUserData(InEntityID)
    if nil == UserData or nil == self.CurrentFate then
        return
    end
    local FateID = UserData.FateID or 0
    local InteractiveFate = self.CurrActiveFateList[FateID]
    -- 需要在fate进行过程中，才能进提交物品的交互流程(不判断接fate任务或者其他情况也会进来)
    if nil == InteractiveFate then
        return
    end
    local bIsInProgress = InteractiveFate.State == ProtoCS.FateState.FateState_InProgress
    local bIsEndSubmit = InteractiveFate.State == ProtoCS.FateState.FateState_EndSubmitItem
    if not (bIsInProgress or bIsEndSubmit) then
        return
    end

    local FateCfg = self:GetFateCfg(FateID)
    local NpcDialogCfg = FateNpcDialogCfg:FindCfgByKey(FateID)
    if nil == FateCfg or nil == NpcDialogCfg then
        _G.FLOG_ERROR("FATE ID : %s，没有FateNpc配置对话表，请检查", FateID)
        return
    end

    if not (self:IsJoinFate()) then
        NpcDialogMgr:PlayDialogLib(NpcDialogCfg.TriggerDialogLibID, InEntityID, false, nil, true)
        return
    end

    -- 对话的NPCID
    local NPCEntityID = self.FateNpcList[FateID]

    -- 获取背包中采集物品的数量
    local TargetActionList = self:FindItemCollectFateSubmitTargetAction(FateID)
    if #TargetActionList <= 0 then
        return
    end
    local ItemNum = 0
    for index, TargetAction in ipairs(TargetActionList) do
        local ItemId = TargetAction.Params
        ItemNum = ItemNum + BagMgr:GetItemNum(ItemId)
    end

    -- 对白交互面板流程
    if InteractiveFate.State == ProtoCS.FateState.FateState_InProgress then
        if ItemNum > 0 then
            local function PlayDialogLibCallback()
                self:OpenItemCollectFateSubmitPanel(
                    InteractiveFate,
                    TargetActionList,
                    NpcDialogCfg,
                    FateCfg,
                    NPCEntityID
                )
            end
            NpcDialogMgr:PlayDialogLib(
                NpcDialogCfg.ItemSumitFateProcess1,
                InEntityID,
                false,
                PlayDialogLibCallback,
                true
            )
        else
            NpcDialogMgr:PlayDialogLib(NpcDialogCfg.ItemSumitFateProcess2, InEntityID, false, nil, true)
        end
    elseif InteractiveFate.State == ProtoCS.FateState.FateState_EndSubmitItem then
        if ItemNum > 0 then
            local function PlayDialogLibCallback()
                self:OpenItemCollectFateSubmitPanel(
                    InteractiveFate,
                    TargetActionList,
                    NpcDialogCfg,
                    FateCfg,
                    NPCEntityID
                )
            end
            NpcDialogMgr:PlayDialogLib(
                NpcDialogCfg.ItemSumitFateFinish1,
                InEntityID,
                false,
                PlayDialogLibCallback,
                true
            )
        else
            NpcDialogMgr:PlayDialogLib(NpcDialogCfg.ItemSumitFateFinish2, InEntityID, false, nil, true)
        end
    end
end

-- 打开采集fate的物品提交UI界面
---OpenItemCollectFateSubmitPanel
---@param InInteractiveFate FateTable
---@param InTargetActionList table
---@param InNpcDialogCfg
function FateMgr:OpenItemCollectFateSubmitPanel(
    InInteractiveFate,
    InTargetActionList,
    InNpcDialogCfg,
    FateCfg,
    NPCEntityID
)
    if (self.FateVM ~= nil) then
        self.CurSubmitFateID = FateCfg.ID
        self.FateVM:ShowItemSubmitView(InInteractiveFate, InTargetActionList, InNpcDialogCfg, FateCfg, NPCEntityID)
    end
end

-- 查找是否物品采集fate的提交物品action
---FindItemCollectFateSubmitTargetAction
---@param FateID number
---@return table
function FateMgr:FindItemCollectFateSubmitTargetAction(FateID)
    local TargetActionList = {}
    local Cfg = FateTargetCfg:FindCfgByKey(FateID)
    if nil ~= Cfg then
        if Cfg.Actions ~= nil then
            for _, Action in pairs(Cfg.Actions) do
                if Action.Type == ProtoRes.Game.FATE_EVENT_CONDITION_TYPE.FATE_EVENT_CONDITION_SUBMIT_ITEM then
                    table.insert(TargetActionList, Action)
                end
            end
        end
    end
    return TargetActionList
end

function FateMgr:OnLootItemUpdateRes(InLootList, InReason)
    if (self.CurrentFate == nil) then
        return
    end
    if self.CurrentFate.FateType ~= ProtoRes.Game.FATE_TYPE.FATE_TYPE_COLLECT then
        return
    end
    local SyncLevelState = self:GetLevelSyncState()
    local bJoin = SyncLevelState == ELevelSyncState.NotJoin
    local bSync = SyncLevelState == ELevelSyncState.NotSynchronized
    if bJoin or bSync then
        return
    end

    if (InLootList == nil) then
        return
    end

    local TargetItem = InLootList[1].Item
    if (TargetItem == nil) then
        return
    end

    if (InReason == nil or InReason == "") then
        return
    end

    local LowerReasonStr = string.lower(InReason)

    local bLuckGather = string.find(LowerReasonStr, "fateluckgather")
    if (bLuckGather) then
        local TipsID = 307103 -- 触发了幸运采集
        MsgTipsUtil.ShowTipsByID(TipsID)
    else
        local TargetActionList = self:FindItemCollectFateSubmitTargetAction(self.CurrentFate.ID)
        if #TargetActionList <= 0 then
            return
        end
        local HaveCount = _G.BagMgr:GetItemNum(TargetItem.ResID)
        local ItemName = nil
        for _, TargetAction in ipairs(TargetActionList) do
            if TargetAction.Params == TargetItem.ResID and HaveCount > 0 and HaveCount % 5 == 0 then
                ItemName = ItemUtil.GetItemName(TargetItem.ResID)
                break
            end
        end

        if (ItemName ~= nil) then
            MsgTipsUtil.ShowTips(string.format(LSTR(190060), tostring(ItemName)))
        end
    end
end

-- 物品采集fate进入倒计时一分钟提示
function FateMgr:OnItemCollectFateStagePrompt()
    if self.CurrentFate ~= nil then
        if self.CurrentFate.FateType == ProtoRes.Game.FATE_TYPE.FATE_TYPE_COLLECT then
            local bJoin = self:GetLevelSyncState() == ELevelSyncState.NotJoin
            local bSync = self:GetLevelSyncState() == ELevelSyncState.NotSynchronized
            if bJoin or bSync then
                return
            end
            local bNil = self.LastFateState == nil
            local bInProgress = self.LastFateState == ProtoCS.FateState.FateState_InProgress
            local bEndSubmit = self.CurrentFate.State == ProtoCS.FateState.FateState_EndSubmitItem
            if (bNil or bInProgress) and bEndSubmit then
                MsgTipsUtil.ShowTips(string.format(LSTR(190061)))
            end
            self.LastFateState = self.CurrentFate.State
        end
    end
end

-- 检查是不是物品采集fate的NPC
---CheckIsItemCollectFateNPC
---@param InEntityID number
---@return boolean
function FateMgr:CheckIsItemCollectFateNPC(InEntityID)
    local UserData = self:TryGetUserData(InEntityID)
    if (UserData ~= nil) then
        local FateID = UserData.FateID or 0
        local FateCfg = self:GetFateCfg(FateID)
        if FateCfg ~= nil and FateCfg.Type == ProtoRes.Game.FATE_TYPE.FATE_TYPE_COLLECT then
            return true
        end
    end
    return false
end

-- 是否能创建采集fate的场景采集物
---CanCreateEObj
---@param MapEditorID number Eobj的ID
---@param EObjResID number Eobj的ResID
---@return boolean
function FateMgr:CanCreateEObj(MapEditorID, EObjResID)
    if self.CurrentFate ~= nil then
        local bInProgress = self.CurrentFate.State == ProtoCS.FateState.FateState_InProgress
        local bEndSubmit = self.CurrentFate.State == ProtoCS.FateState.FateState_EndSubmitItem
        if bInProgress or bEndSubmit then
            local EObjShowList = self:GetItemCollectFateEObjShowList(self.CurrentFate.ID)
            if table.contain(EObjShowList, MapEditorID) then
                return true
            end
        end
    end
    return false
end

-- 检测是不是FATE互动的ID
function FateMgr:CheckIsFateCollectItem(InteractiveID)
    return InteractiveID == 500006
end

-- 检查是否能交互-采集物品(未参与/未同步此fate不能采集)
---@return boolean
function FateMgr:CheckCanInteractiveCollectItem(InteractiveID)
    if InteractiveID ~= 500006 then
        return false
    end

    if (self.CurrentFate == nil) then
        return false
    end

    if self.CurrentFate.FateType ~= ProtoRes.Game.FATE_TYPE.FATE_TYPE_COLLECT then
        return false
    end

    if self.CurrentFate.State <= ProtoCS.FateState.FateState_WaitNPCTrigger then
        return false
    end

    if self:GetLevelSyncState() == ELevelSyncState.None then
        _G.FLOG_ERROR("当前的状态是 None, 请检查")
        return false
    end

    if self:GetLevelSyncState() == ELevelSyncState.NotJoin then
        local TipsStr = LSTR(190055)
        FateMgr.ShowTips(TipsStr)
        return false
    elseif self:GetLevelSyncState() == ELevelSyncState.NotSynchronized then
        local TipsStr = LSTR(190062)
        FateMgr.ShowTips(TipsStr)
        return false
    else
        return true
    end
end

-- 显示攻击提醒的Tips
function FateMgr:TryShowAttackMentionTips()
    if self:IsNotSynchronizedState() then
        local CurTime = TimeUtil.GetServerLogicTime()
        if (CurTime - self.AttackTipsRecordTime < 2) then
            return
        end

        self.AttackTipsRecordTime = CurTime
        MsgTipsUtil.ShowErrorTips(LSTR(190054))
    elseif self:IsNotJoinState() then
        local CurTime = TimeUtil.GetServerLogicTime()
        if (CurTime - self.AttackTipsRecordTime < 2) then
            return
        end

        self.AttackTipsRecordTime = CurTime
        MsgTipsUtil.ShowErrorTips(LSTR(190055))
    end
end

-- 发送给服务器：请求采集物eobj数据
---SendMsgUpdateGatherItemReq
function FateMgr:SendMsgUpdateGatherItemReq()
    if nil ~= self.CurrentFate then
        local MsgID = CS_CMD.CS_CMD_FATE
        local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_UPDATE_GATHER
        local MsgBody = {
            Cmd = SubMsgID,
            FateID = self.CurrentFate.ID,
            UpdateGather = {}
        }

        self:InternalSendFateReqMsg(MsgID, SubMsgID, MsgBody)
    end
end

-- 接收服务器：物品采集fate场景采集物的显示与销毁
---OnNetMsgUpdateGather
---@param MsgBody
function FateMgr:OnNetMsgUpdateGather(MsgBody)
    local FateUpdateGatherRsp = MsgBody.FateUpdateGather
    if self.CurrentFate == nil then
        return
    end

    local EObjShowList = self:GetItemCollectFateEObjShowList(self.CurrentFate.ID)
    for _, EObjID in pairs(FateUpdateGatherRsp.Show) do
        --print("OnNetMsgUpdateGather===SHOW==", EObjID)
        if not table.contain(EObjShowList, EObjID) then
            local MapEditorData = ClientVisionMgr:GetEditorDataByEditorID(EObjID, "EObj")
            if MapEditorData then
                table.insert(EObjShowList, EObjID)
                ClientVisionMgr:ClientActorEnterVision(MapEditorData, _G.UE.EActorType.EObj)
            end
        end
    end

    self:OnReomveCollectItem(FateUpdateGatherRsp.Hide)
    for _, EObjID in pairs(FateUpdateGatherRsp.Hide) do
        --print("OnNetMsgUpdateGather===Hide==", EObjID)
        if table.contain(EObjShowList, EObjID) then
            table.remove_item(EObjShowList, EObjID)
        end
    end

    self.ItemCollectFateEObjShowList[self.CurrentFate.ID] = EObjShowList
end

-- 获取当前采集fate的采集物EObject
---@param FateID
---@return table
function FateMgr:GetItemCollectFateEObjShowList(FateId)
    local EObjShowList = self.ItemCollectFateEObjShowList[FateId]
    if EObjShowList then
        return EObjShowList
    end
    return {}
end

-- 清掉场景中指定的采集物
---OnClearItemCollectFateEObjGather
---@param RemoveEObjList table
function FateMgr:OnReomveCollectItem(RemoveEObjList)
    if #RemoveEObjList <= 0 then
        return
    end
    local CurrMapEditCfg = MapEditDataMgr:GetMapEditCfg()
    if CurrMapEditCfg then
        for _, EObjData in ipairs(CurrMapEditCfg.EObjList) do
            if EObjData.Type == ProtoRes.ClientEObjType.ClientEObjTypeFateGather then
                if table.contain(RemoveEObjList, EObjData.ID) then
                    _G.ClientVisionMgr:ClientActorLeaveVision(EObjData.ID, _G.UE.EActorType.EObj)
                end
            end
        end
    end
end

-- 清掉场景中的采集物，如果没有InFateID，那么是清理所有的，如果有，则清理指定FATE的
function FateMgr:OnClearAllCollectItem(InFateID)
    if (InFateID == nil) then
        if (self.ItemCollectFateEObjShowList ~= nil) then
            for Key,Value in pairs(self.ItemCollectFateEObjShowList) do
                self:OnReomveCollectItem(Value)
            end
            self.ItemCollectFateEObjShowList = {}
        end
    else
        local EObjShowList = self:GetItemCollectFateEObjShowList(InFateID)
        self:OnReomveCollectItem(EObjShowList)
        self.ItemCollectFateEObjShowList[InFateID] = nil
    end
end
-------------------------------------------------Npc物品采集fate交互 end--------------------------------------------------------

----------------------------------------------------fate局内提示/喊话 start----------------------------------------------------------
function FateMgr:OnMonsterCreate(Params)
    local EntityID = Params.ULongParam1
    local MonsterId = Params.IntParam1

    if self.CurrentFate ~= nil then
        self:PlayFateInsidePrompt(
            ProtoRes.FateInsidePromptType.FATE_INSIDE_PROMPT_MONSTER_CREATE,
            self.CurrentFate.ID,
            MonsterId
        )
    end
end

function FateMgr:OnUpdateBuff(Params)
    local BuffID = Params.IntParam1
    local EntityID = Params.ULongParam1
    if not ActorUtil.IsMonster(EntityID) then
        return
    end
    
    local MonsterResID = ActorUtil.GetActorResID(EntityID)

    -- 这里设置延迟1秒检测，因为玩家对话开启的话，战斗服的BUFF更新消息可能会比参加FATE的更快速
    self:RegisterTimer(
        function()
            if self.CurrentFate ~= nil and MonsterResID ~= 0 then
                self:PlayFateInsidePrompt(
                    ProtoRes.FateInsidePromptType.FATE_INSIDE_PROMPT_MONSTER_BUFF,
                    self.CurrentFate.ID,
                    MonsterResID,
                    BuffID
                )
            end
        end,
        1,
        0,
        1
    )
end

function FateMgr:PlayFateInsidePrompt(FateInsidePromptType, FateID, MonsterId, BuffId)
    local TextTable = self:GetFateInsidePrompt(FateInsidePromptType, FateID, MonsterId, BuffId)
    if TextTable == nil then
        return
    end

    for Key, Value in pairs(TextTable) do
        self:AppendFateTips(FateTipsType.SpecialTextTips, 3, Value)
    end
end

--获取fate局内提示信息
---@return string
function FateMgr:GetFateInsidePrompt(FateInsidePromptType, FateID, MonsterId, BuffId)
    local SearchConditions = nil
    if FateInsidePromptType == ProtoRes.FateInsidePromptType.FATE_INSIDE_PROMPT_ENTER_AREA then
        SearchConditions = string.format("Type=%d and FateID==%d", FateInsidePromptType, FateID)
    elseif FateInsidePromptType == ProtoRes.FateInsidePromptType.FATE_INSIDE_PROMPT_MONSTER_CREATE then
        SearchConditions =
            string.format("Type=%d and FateID==%d and MonsterId==%d", FateInsidePromptType, FateID, MonsterId)
    elseif FateInsidePromptType == ProtoRes.FateInsidePromptType.FATE_INSIDE_PROMPT_MONSTER_BUFF then
        SearchConditions = string.format(
            "Type=%d and FateID==%d and MonsterId==%d and BuffId=%d",
            FateInsidePromptType,
            FateID,
            MonsterId,
            BuffId
        )
    end

    if SearchConditions == nilr or string.len(SearchConditions) <= 0 then
        return nil
    end
    local FateInsidePromptCfg = FateInsidePromptTable:FindAllCfg(SearchConditions)
    if FateInsidePromptCfg == nil then
        _G.FLOG_WARNING("无法找到FATE特殊提示，搜索条件是:%s",SearchConditions)
        return nil
    end
    local ResultStrTable = {}
    for Key, Value in pairs (FateInsidePromptCfg) do
        table.insert(ResultStrTable, Value.Text)
    end
    return ResultStrTable
end

--接收服务器：通知开始对话的NPC喊话
---OnNetMsgNpcYell
---@param MsgBody
function FateMgr:OnNetMsgNpcAction(MsgBody)
    local FateID = MsgBody.FateID
    local ActionType = MsgBody.FateNpcAction.ActionType
    local ActionParams = MsgBody.FateNpcAction.ActionParams
    if FateID == nil or self.CurrentFate == nil then
        return
    end
    if self.CurrentFate.ID ~= FateID then
        return
    end

    local NPCEntityID = self.FateNpcList[FateID]
    if ActionType == ProtoCS.CS_FATE_NPC_ACTION.CS_FATE_NPC_ACTION_YELL then
        local YellId = ActionParams
        _G.SpeechBubbleMgr:ShowBubbleByID(NPCEntityID, YellId)
    elseif ActionType == ProtoCS.CS_FATE_NPC_ACTION.CS_FATE_NPC_ACTION_PERFORM_ATL then
        local AnimComp = ActorUtil.GetActorAnimationComponent(NPCEntityID)
        if AnimComp ~= nil then
            local ATLId = ActionParams
            local ATLPathCfg = ActiontimelinePathCfg:FindCfgByKey(ATLId)
            if ATLPathCfg ~= nil then
                local ActionTimelinePath = AnimComp:GetActionTimeline(ATLPathCfg.Filename)
                AnimComp:PlayAnimationCallBack(ActionTimelinePath)
            end
        end
    end
end

-- InFateTipsType : FateTipsType
-- InShowTime : 显示的时间
-- InParams : 对应不同的类型的参数
function FateMgr:AppendFateTips(InFateTipsType, InShowTime, InParams, InbShowNow)
    if (InbShowNow) then
        if (InFateTipsType == FateTipsType.MainTitleTips) then
            FateMgr.ShowMainTitleTips(InParams)
        else
            FateMgr.ShowTips(InParams)
        end
        return
    end

    local TipsData = nil
    
    if (InFateTipsType == FateTipsType.MainTitleTips) then
        TipsData = {}
        TipsData.BeginFunc = function(InParams)
            FateMgr.ShowMainTitleTips(InParams)
        end

        TipsData.EndFunc = function(InParams)
            FateMgr.HideMainTitleTips(InParams)
        end
    else
        TipsData = {}
        TipsData.BeginFunc = function(InParams)
            FateMgr.ShowTips(InParams)
        end
    end

    TipsData.TipsType = InFateTipsType
    TipsData.ShowTime =  InShowTime
    TipsData.Params = InParams
    TipsData.PlayedTime = 0

    table.insert(self.FateTipsQueue, TipsData)
    self.FateTipsQueueCount = self.FateTipsQueueCount + 1
    if (self.FateTipsQueueCount > 1) then
        table.sort(
            self.FateTipsQueue,
            function(Left, Right)
                local Value = Left.TipsType - Right.TipsType
                return Value > 0
            end
        )
    end

    if (self.TickForFateTipsViewID == nil) then
        self.TickForFateTipsViewID = self:RegisterTimer(
            self.OnCheckForFateTipsQueue,
            0,
            FateTipsCheckTimeSpan,
            0
        )
    end
end

function FateMgr.ShowMainTitleTips(InParams)
    UIViewMgr:ShowView(UIViewID.InfoFateTips)
end

function FateMgr.HideMainTitleTips(InParams)
    UIViewMgr:HideView(UIViewID.InfoFateTips)
end

function FateMgr.ShowTips(InParams)
    MsgTipsUtil.ShowTips(InParams)
end

----------------------------------------------------fate局内提示/喊话 end------------------------------------------------------------
return FateMgr
