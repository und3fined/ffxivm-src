--
-- Author: frankjfwang && michaelyang_lightpaw
-- Date: 2021-07-21 16:57:14
-- Description:
--
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local GameRuleService = require("Game/MagicCard/Module/GameRuleService")
local ActorAnimService = require("Game/MagicCard/Module/ActorAnimService")
local MagicCardLocalDef = require("Game/MagicCard/MagicCardLocalDef")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local ActorUtil = require("Utils/ActorUtil")
local AudioUtil = require("Utils/AudioUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local CommonUtil = require("Utils/CommonUtil")
local Log = require("Game/MagicCard/Module/Log")
local MajorUtil = require("Utils/MajorUtil")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local ItemCfg = require("TableCfg/ItemCfg")
local CardCfg = require("TableCfg/FantasyCardCfg")
local Json = require("Core/Json")
local SettingsMgr = require("Game/Settings/SettingsMgr")
local EffectUtil = require("Utils/EffectUtil")
local FantasyCardNpcCfg = require("TableCfg/FantasyCardNpcCfg")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local MagicCardTourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local GlobalCfg = require("TableCfg/GlobalCfg")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local DialogCfg = require("TableCfg/DialogCfg")
local CameraConfigTable = require("TableCfg/FantasyCardCameraConfigCfg")
local FantasyCardRaceConfigCfg = require("TableCfg/FantasyCardRaceConfigCfg")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local LuaCameraMgr = require("Game/Camera/LuaCameraMgr")
local NpcCfg = require("TableCfg/NpcCfg")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local LeftSidebarMgr = nil
local LSTR = _G.LSTR
local QUEST_CMD = ProtoCS.CS_QUEST_CMD
local UActorManager = nil
local HUDMgr = nil
local ClickSoundEffectEnum = MagicCardLocalDef.ClickSoundEffectEnum
local EPlayMode = MagicCardLocalDef.EPlayMode
local AudioMgr = nil
local Cache_Map = _G.UE.EObjectGC.Cache_Map
local EventMgr = _G.EventMgr
local AudioType_BGM = _G.UE.EWWiseAudioType.Music
local CS_CMD = ProtoCS.CS_CMD
local FANTASY_CARD_OP = ProtoCS.FANTASY_CARD_OP
local ClientSetupKey = ProtoCS.ClientSetupKey
local LocalDef = MagicCardLocalDef
local ErrorCodeList = {}
local FLOG_INFO = _G.FLOG_INFO
local UIViewID = nil
local UIViewMgr = nil
local LOOT_TYPE = ProtoCS.LOOT_TYPE
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS
local DefaultCameraParamID = 101 -- 默认摄像机镜头参数
local GLOBAL_CFG_ID = ProtoRes.Game.game_global_cfg_id
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL

---@class MagicCardMgr : MgrBase
---@class GameRuleService GameRuleService
---@class ActorAnimService ActorAnimService
local MagicCardMgr = LuaClass(MgrBase)

function MagicCardMgr:ResetData()
    self.IsOutSide = false
    self.PVEOpponentInfo = {}
    self.PVPRobotOpponentInfo = {}
    self.OpponentEmoList = {}
    self.PVPRoleID = 0
    self.OpponentRoleSimple = {}
    self.OwnedCardList = {}
    self.InteractWithNPC = false
    self.CardGameId = 0
    self.PrepareSecond = 0
    self.DelayShowRewardItemList = {}
    self.IsGameBegin = false
    self.IsGameEnd = true
    
    self.PlayMode = EPlayMode.None
    self.IsTournament = false
    self.IsNeedReqRecover = false
    self.RecoverTimeCount = 0
    self.RecoverTimeOut = 5.0
    self.UsedCardID = 0
    self.IsFinishedRecover = false
end

function MagicCardMgr:OnInit()
    UActorManager = _G.UE.UActorManager.Get()
    AudioMgr = _G.UE.UAudioMgr.Get()
    self.QuestNeedFinished = 171102 -- 完成了该任务才可以触发幻卡对局相关
    UIViewID = _G.UIViewID
    UIViewMgr = _G.UIViewMgr
    HUDMgr = _G.HUDMgr
    self.NpcPreQuestTable = {}
    ErrorCodeList[1] = 109001
    ErrorCodeList[2] = 109002
    ErrorCodeList[3] = 109003
    self:ResetData()
    self.NpcHudIconMap = {}
    self.NpcResIdHudIconMap = {} -- 保存的是NPC的ResID，因为有可能NPC还没有创建出来没有ENTITYID
    Utils.Init()
    self.InteractWithNPC = false
    self.BGMVolume = AudioMgr:GetAudioVolume(AudioType_BGM)
    self.BGMID = 0
    self.EmoIDTable = {
        0,
        0,
        0,
        0
    }
    self.MapResID = 0
    self.EmoIDTable[1] = LocalDef.DefualtSalutEmoID

    -- 摄像机转动配置表，由于有可能是从匹配里面进入的，所以不要放到界面上
    self.DefaultCameraMoveParam = _G.UE.FCameraResetParam()
    self.DefaultCameraMoveParam.Distance = 130
    self.DefaultCameraMoveParam.Rotator = _G.UE.FRotator(0, -10, 0)
    self.DefaultCameraMoveParam.ResetType = _G.UE.ECameraResetType.Interp
    self.DefaultCameraMoveParam.LagValue = 10
    self.DefaultCameraMoveParam.bRelativeRotator = true
    self.DefaultCameraMoveParam.TargetOffset = _G.UE.FVector(0, 0, 0)
    self.DefaultCameraMoveParam.NextTransform = _G.UE.FTransform()
    self.DefaultCameraMoveParam.SocketExternOffset = _G.UE.FVector(-50, 95, 0)
    self.DefaultCameraMoveParam.FOV = 0

    self.ReadyGame = false
end

function MagicCardMgr:OnBegin()
    LeftSidebarMgr = require("Game/Sidebar/LeftSidebarMgr")
    -- 读取开启幻卡对局需要完成的任务
    local Key = ProtoRes.client_global_cfg_id.GLOBAL_CFG_FANTASY_CARD_REQUIRE_QUEST
    local FantasyCardData = ClientGlobalCfg:FindCfgByKey(Key)
    if (FantasyCardData ~= nil) then
        self.QuestNeedFinished = FantasyCardData.Value[1]
    end
    --_G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD, self.CheckMagicCardOpenState)
    -- end
end

function MagicCardMgr:HasFinishTargetQuest()
    local _questStatus = _G.QuestMgr:GetQuestStatus(self.QuestNeedFinished)
    if (_questStatus == nil or _questStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED) then
        return false
    end

    return true
end

function MagicCardMgr:OnEnd()
end

function MagicCardMgr:OnShutdown()
end

function MagicCardMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUEST, QUEST_CMD.QUEST_TARGET_FINISH_CMD, self.OnNetMsgQuestUpdateNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUEST, QUEST_CMD.QUEST_UPDATE_NOTIFY_CMD, self.OnNetMsgQuestUpdateNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUEST, QUEST_CMD.QUEST_SUBMIT_CMD, self.OnNetMsgQuestUpdateNotify)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, ProtoCS.CS_BAG_CMD.CS_CMD_BAG_USE_ITEM, self.OnUseItem)

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_SELECT, self.OnNetMsgSelectGroupRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_ENTER, self.OnNetMsgFantasyCardEnterRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_NEW_MOVE, self.OnNetMsgFantasyCardNewMoveRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_FINISH, self.OnNetMsgFantasyCardFinishRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_VIEW_GROUP, self.OnNetMsgViewGroupRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_EDIT, self.OnNetMsgEditGroupRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_COLLECTION, self.OnNetMsgUpdateCollectionRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_NPC, self.OnNetMsgNpcUpdateRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_MATCH_DONE, self.OnNetMsgMatchSuccess)
end

function MagicCardMgr:OnUseItem(MsgBody)
    local Msg = MsgBody.Item
	if nil == Msg then
		return
	end

    local ResID = Msg.ResID
    local TableData = CardCfg:FindCfgByKey(ResID)
    if (TableData == nil) then
        return
    end
    if (self:IsMagicCardOwned(ResID)) then
        return
    end

    LeftSidebarMgr:AppendPerform(
        SidebarDefine.LeftSidebarType.FantacyCard,
        {
            CardID = ResID
        }
    )
end

function MagicCardMgr:OnRegisterTimer()
    --self:RegisterTimer(self.CheckCardItemUse, 0, 0.5, 0)
end

function MagicCardMgr:OnNetMsgQuestUpdateNotify(MsgBody)
    local QuestUpdateRsp = MsgBody.QuestUpdate
    if (QuestUpdateRsp==nil) then
        return
    end
    local Quests = QuestUpdateRsp.Quests
    if (Quests == nil or #Quests < 1) then
        return
    end

    for Key, Value in pairs(Quests) do
        if (Value.QuestID ~= nil and Value.QuestID == self.QuestNeedFinished) then
            if (Value.Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED) then
                self:SendNPCUpdateReq(self.MapResID)
            end
        end
    end
end

function MagicCardMgr:OnNetMsgError()
    -- 这里要注意一下，如果是在局内才这么做，如果是局外的，那么不管
    if (not self.IsOutSide) then
        self.HideReadinessViewRelativeUI()
        self:ResetDataAfterQuit()
        UIViewMgr:HideView(UIViewID.MagicCardMainPanel)
        self:HandleOthersVisiblle(true)
    end
end

---@type 隐藏准备界面的相关UI
function MagicCardMgr.HideReadinessViewRelativeUI()
    UIViewMgr:HideView(UIViewID.MagicCardEnterConfirmPanel)
    UIViewMgr:HideView(UIViewID.MagicCardEditPanel) -- 有可能打开了，直接关闭
end

---@type 先进入对局界面等待对手准备卡牌
function MagicCardMgr:OnWaitingGameToStart(RemainTime)
    self:OnBeforeGameStartHandle()
    local function OnConfirmEnterGame()
        self.IsPVP = self:IsPVPMode()
        --self:TurnCamera(nil, LocalDef.CameraTurnTime, nil)
        if self.IsPVP then
            local IsRobot = MagicCardTourneyMgr:IsOpponentRobot()
            if IsRobot then --对手是机器人
                local RobotReadyTime = MagicCardTourneyVMUtils.GetRobotReadyTime()
                local PlayerReadyTime = self.PrepareSecond - RemainTime
                -- 本地玩家准备时间超过了机器人的准备时长，则直接确认
                if PlayerReadyTime >= RobotReadyTime then
                    self:SendConfirmEnterGame(false)
                    return
                end
                -- 客户端准备时间很短，机器人延迟确认时间 = 两者的时间差
                local Delay = RobotReadyTime - PlayerReadyTime
                _G.TimerMgr:AddTimer(self, self.SendConfirmEnterGame, Delay, 0, 1, false)
                return
            end
        end
    
        self:SendConfirmEnterGame(false)
    end

    UIViewMgr:ShowView(UIViewID.MagicCardMainPanel, {RemainTime = RemainTime, IsOpponentPVP = self.IsPVP}, OnConfirmEnterGame)
end

---@type 进入对局前处理
function MagicCardMgr:OnBeforeGameStartHandle()
    self:HandleOthersVisiblle(false)
    -- 进入对局时清除玩家对其他目标的选中态
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.ULongParam1 = 0
    _G.EventMgr:SendCppEvent(_G.EventID.ManualUnSelectTarget, EventParams)
    self:PlayCardBGM() -- 播放幻卡背景音
    self:StopBGM() -- 关闭环境音
end

---@type 隐藏所有宠物
function MagicCardMgr:HideAllCompanions(IsHide)
    local Companions = _G.UE.UActorManager.Get():GetAllCompanions()
    for _, Companion in pairs(Companions) do
        Companion:SetActorHiddenInGame(IsHide)
    end
end

---@type 本地传送到NPC对面
function MagicCardMgr:SetMajorToFrontOfNPC(DistanceToNpc)
    local PVENPCEntityID = self:GetPVENPCEntityID()
    local NpcActor = ActorUtil.GetActorByEntityID(PVENPCEntityID)
    if not NpcActor then
        return
    end

    local NpcForward = NpcActor:FGetActorRotation():GetForwardVector()
    local DesLoc = NpcActor:FGetLocation(_G.UE.EXLocationType.ActorLoc) + (NpcForward * DistanceToNpc)
    local Major = MajorUtil.GetMajor()

    if Major == nil then
        return
    end

    local CurMajorLoc = Major:FGetActorLocation()

    -- 导航的方式有问题，只能直线，在中间有障碍物的情况下会卡住不动（暂时弃用），这里是计算出一个合理的位置，直接设置过去
    local MapID = MagicCardMgr.MapResID
    local MapPaths = _G.NavigationPathMgr:FindMapPaths(MapID, CurMajorLoc, MapID, DesLoc)
    local LastPos = nil
    if MapPaths and #MapPaths > 0 then
        for _, Path in ipairs(MapPaths) do
            for _, Pos in ipairs(Path.Paths) do
                LastPos = Pos.EndPos
            end
        end
    end

    if (LastPos ~= nil) then --如果导航能找到路径
        DesLoc.Z = CurMajorLoc.Z
    else
        DesLoc = CurMajorLoc --如果导航不能找到路径，则不动
    end

    self:SetMajorToGameTransform(DesLoc, PVENPCEntityID)
end

---@type 更新玩家和NPC的位置与朝向
function MagicCardMgr:UpdateMajorAndNPCTransform()
    if self.PlayMode ~= EPlayMode.PVE then
        return
    end

    local Major = MajorUtil.GetMajor()
    if Major then
        if self.CurMajorLoc == nil then
            self.CurMajorLoc = Major:FGetActorLocation()
        end
        
        if self.CurMajorRotation == nil then
            self.CurMajorRotation = Major:K2_GetActorRotation()
        end
        Major:DoClientModeEnter()
    end

    local function OnEnterClientMode()
        --如果在幻卡NPC表中设置了玩家的位置
        local PVENPCEntityID = self:GetPVENPCEntityID()
        local NpcActor = ActorUtil.GetActorByEntityID(PVENPCEntityID)
        if not NpcActor then
            return
        end

        local PVENPCID = self:GetPVENPCID()
        local PosInfo = MagicCardVMUtils.GetGamePosInfoWithNPC(PVENPCID)
        if PosInfo == nil then
            return
        end
        local MajorLoc = PosInfo.MajorLocation
        local NpcLoc = PosInfo.NPCLocation
        local DistanceToNpc = PosInfo.DistanceToNpc
        -- 保存NPC对局前位置与朝向
        if self.CurNPCRotation == nil then
            self.CurNPCRotation = NpcActor:K2_GetActorRotation()
        end
        if self.CurNPCLocation == nil then
            self.CurNPCLocation = NpcActor:K2_GetActorLocation()
        end

        -- 将NPC设置在固定位置
        if NpcLoc then
            NpcActor:K2_SetActorLocation(NpcLoc, false, nil, false)
        end

        if MajorLoc then
            -- 将玩家设置在固定位置
            self:SetMajorToGameTransform(MajorLoc, PVENPCEntityID, MajorLoc)
        else
            -- 将玩家设置在NPC正前方位置
            self:SetMajorToFrontOfNPC(DistanceToNpc)
        end
        ActorUtil.LookAtPos(NpcActor, MajorLoc)
        
        self:TurnCamera(nil, MagicCardLocalDef.CameraTurnTime, nil)
    end
    Utils.Delay(0.2, OnEnterClientMode)
end

---@type 设置玩家位置与朝向
function MagicCardMgr:SetMajorToGameTransform(MajorLoc, OpponentEntityID, StoolLoc)
    local Major = MajorUtil.GetMajor()
    if Major == nil then
        return
    end

    local NPCID = ActorUtil.GetActorResID(OpponentEntityID)
    local NPCActor = ActorUtil.GetActorByEntityID(OpponentEntityID)
    
    --生成凳子垫高
    local NewMajorLoc = nil
    local MajorHalfHeight = Major:GetCapsuleHalfHeight()
    if MagicCardVMUtils.IsMajorNeedStandOnStool(NPCID) then
        local MajorBaseLoc = Major:FGetActorBaseLocation()-- 取玩家服务器地面位置
        local NewStoolLoc = StoolLoc or _G.UE.FVector(MajorLoc.X, MajorLoc.Y, MajorBaseLoc.Z)
        if self.MajorStool == nil then
            self.MajorStool = self:AllocStool(NewStoolLoc, NPCActor)
        end
        local StoolHigh = 47 --凳子高度
        NewMajorLoc = _G.UE.FVector(NewStoolLoc.X, NewStoolLoc.Y, NewStoolLoc.Z + StoolHigh + MajorHalfHeight) --角色放凳子上方
        -- 取消碰撞，防止与桌子碰撞导致悬空站在凳子上
        local CollisionComponent = Major:GetComponentByClass(_G.UE.UCapsuleComponent)
        if (CollisionComponent) then
            local CapsuleComponent = CollisionComponent:Cast(_G.UE.UCapsuleComponent)
            if (CapsuleComponent) then
                CapsuleComponent:SetCollisionEnabled(_G.UE.ECollisionEnabled.NoCollision)
            end
        end
    else
        NewMajorLoc = _G.UE.FVector(MajorLoc.X, MajorLoc.Y, MajorLoc.Z + MajorHalfHeight * 1.02) -- 升高一点，防止在地下
    end
    
    if NewMajorLoc then
        Major:K2_SetActorLocation(NewMajorLoc, false, nil, false)
        self.IsFinishedRecover = true
    end
    MajorUtil.LookAtActor(OpponentEntityID)
end

---@type 生成凳子
function MagicCardMgr:AllocStool(NewLocation, OpponentActor)
    if OpponentActor == nil then
        return
    end
    local NPCLocation = OpponentActor:K2_GetActorLocation()
    local TargetRotation = _G.UE.UKismetMathLibrary.FindLookAtRotation(_G.UE.FVector(NewLocation.X, NewLocation.Y, 0), 
    _G.UE.FVector(NPCLocation.X, NPCLocation.Y, 0))
    local StoolPath = "StaticMesh'/Game/Assets/bg/ffxiv/wil_w1/twn/common/bgparts/w1t0_w0_stp1.w1t0_w0_stp1'" 
    local ObjectGCType = require("Define/ObjectGCType")
    local Obj = _G.ObjectMgr:LoadObjectSync(StoolPath, ObjectGCType.LRU)
    local NewStool = _G.CommonUtil.SpawnActor(_G.UE.AStaticMeshActor.StaticClass(), NewLocation, TargetRotation)
    if NewStool then
        NewStool:SetMobility(_G.UE.EComponentMobility.Movable)
        NewStool.StaticMeshComponent:SetStaticMesh(Obj)
    end

    return NewStool
end

---@type 移除凳子
function MagicCardMgr:RemoveMajorStool()
    if self.MajorStool and _G.UE.UCommonUtil.IsObjectValid(self.MajorStool) then
        CommonUtil.DestroyActor(self.MajorStool)
        self.MajorStool = nil
    end
end

---@type 恢复玩家和NPC位置
function MagicCardMgr:ReSetMajorAndNpcLocalTrans()
    self.IsFinishedRecover = false
    local Major = MajorUtil.GetMajor()
    if self.CurMajorLoc and self.CurMajorRotation then
        if Major then
            local SafeLoc = _G.UE.FVector(self.CurMajorLoc.X, self.CurMajorLoc.Y, self.CurMajorLoc.Z + 20) -- 设置时，防止掉落地板下，加高点
            Major:K2_SetActorLocation(SafeLoc, false, nil, false)
            Major:FSetRotationForServer(self.CurMajorRotation)
            local CollisionComponent = Major:GetComponentByClass(_G.UE.UCapsuleComponent)
            if (CollisionComponent) then
                local CapsuleComponent = CollisionComponent:Cast(_G.UE.UCapsuleComponent)
                if (CapsuleComponent) then
                    CapsuleComponent:SetCollisionEnabled(_G.UE.ECollisionEnabled.QueryAndPhysics)
                end
            end
        end
        self.CurMajorLoc = nil
        self.CurMajorRotation = nil
    end

    local PVENPCEntityID = self:GetPVENPCEntityID()
    local NpcActor = ActorUtil.GetActorByEntityID(PVENPCEntityID)
    if NpcActor then
        if self.CurNPCRotation then
            NpcActor:K2_SetActorRotation(self.CurNPCRotation, false)
            self.CurNPCRotation = nil
        end
        if self.CurNPCLocation then
            NpcActor:K2_SetActorLocation(self.CurNPCLocation, false, nil, false)
            self.CurNPCLocation = nil
        end
    end
    
    local function RestoreState()
        local Major = MajorUtil.GetMajor()
        if Major then
            Major:DoClientModeExit()
            self:RemoveMajorStool()
            print("[MagicCardMgr]ReSetMajorAndNpcLocalTrans:DoClientModeExit")
        end
    end

    Utils.Delay(0.1, RestoreState)
end

function MagicCardMgr:TurnCamera(CameraParamTableID, DelayTime, CallbackFunc)
    Utils.Delay(
        DelayTime,
        function()
            local TargetCameraParamID = DefaultCameraParamID
        
            if (CameraParamTableID == nil or CameraParamTableID <= 0) then
                --与NPC对局时，读取幻卡AI表中对应NPC的镜头ID， 进行幻卡大赛PVP时，读取客户端全局表的镜头ID
                local Key = ProtoRes.client_global_cfg_id.GLOBAL_CFG_FANTASY_CARD_CAMERA_DEFINE
                local FantasyCardCameraCfg = ClientGlobalCfg:FindCfgByKey(Key)
                local PVPCameraID = FantasyCardCameraCfg and FantasyCardCameraCfg.Value[1] or 0
                local NPCID = self:GetPVENPCID()
                local NpcCfg = FantasyCardNpcCfg:FindCfgByKey(NPCID)
                local PVECameraID = NpcCfg and NpcCfg.CameraID or 0
                TargetCameraParamID = (self.IsPVP and PVPCameraID) or PVECameraID
            else
                TargetCameraParamID = CameraParamTableID
            end
            local NpcEntityID = self:GetOpponentEntityID()
            if TargetCameraParamID and NpcEntityID then
                LuaCameraMgr:TryChangeViewByConfigID(TargetCameraParamID, NpcEntityID)
            else
                FLOG_ERROR("更新玩家幻卡镜头时，找不到对手实体，请检查！")
            end
            if (CallbackFunc ~= nil) then
                CallbackFunc()
            end
        end
    )
end

---根据NpcEntityID，取得当前应在头顶显示的图标信息
---@param NpcEntityID interger
---@return string|nil 图标资源路径
function MagicCardMgr:GetNPCHudIcon(NpcEntityID)
    -- 玩法表中幻卡AI表配置的前置任务，非NPC身上的任务
    local bFinishPreQuest = self:HasFinishPreQuestByEntityID(NpcEntityID)
    if (not bFinishPreQuest) then
        return nil
    end

    local bFinishTargetQuest = self:HasFinishTargetQuest()
    if (not bFinishTargetQuest) then
        return nil
    end
    local Icon = self.NpcHudIconMap[NpcEntityID]
    if (Icon == nil) then
        local ResID = ActorUtil.GetActorResID(NpcEntityID)
        local FinalIcon = self.NpcResIdHudIconMap[ResID]
        if (FinalIcon ~= nil) then
            self.NpcHudIconMap[NpcEntityID] = FinalIcon
        end
        return FinalIcon
    else
        return Icon
    end
end

function MagicCardMgr:GetMapMarkerIcon(NpcID)
    -- 玩法表中幻卡AI表配置的前置任务，非NPC身上的任务
    local bFinishPreQuest = self:HasFinishPreQuestByResID(NpcID)
    if (not bFinishPreQuest) then
        return nil
    end

    -- 整个幻卡玩法的前置任务
    local bFinishTargetQuest = self:HasFinishTargetQuest()
    if (not bFinishTargetQuest) then
        return nil
    end
    -- 此NPC所有任务（有任务未完成时，不显示幻卡标记）
    local bFinishNPCQuest = MagicCardVMUtils.IsCardNPCFinishedQuest(NpcID)
    if not bFinishNPCQuest then
        return nil
    end
    local FinalIcon = self.NpcResIdHudIconMap and self.NpcResIdHudIconMap[NpcID]
    return FinalIcon
end

function MagicCardMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnRelayConnected)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldEnter)
    self:RegisterGameEvent(EventID.MagicCardPlayCardClickSound, self.OnGameEventPlayClickSound)
    self:RegisterGameEvent(EventID.ClientSetupPost, self.OnEventClientSetupPost)
    self:RegisterGameEvent(EventID.ActorDestroyed, self.OnEventActorDestroy)
    self:RegisterGameEvent(EventID.PlayerCreate, self.OnGameEventPlayerCreate)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.MagicCardGameStartReq, self.OnMagicCardGameStartReq)
    self:RegisterGameEvent(EventID.BagUseItemSucc, self.OnEventUseItemSucc)
    self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
    self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
    self:RegisterGameEvent(EventID.NPCCreate, self.OnNPCCreate)
    self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnGameEventStartFadeIn)
end

function MagicCardMgr:OnGameEventPlayerCreate(Params)
    if (not self.IsGameBegin) then
        return
    end
    local EntityID = Params.ULongParam1
    local CurrentOpponentEntityID = self:GetOpponentEntityID()
    if (CurrentOpponentEntityID ~= nil and CurrentOpponentEntityID ~= EntityID) then
        UActorManager:HideActor(EntityID, true)
    end
end

function MagicCardMgr:OnGameEventMajorCreate(Params)
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
    self:RegisterGameEvent(EventID.MagicCardNeedReqRecover, self.OnGameEventNeedReqRecover)
    self.CheckIsNeedRecoverTimer = self:RegisterTimer(self.CheckIsNeedRecover, 0, 0.1, 0)
end

function MagicCardMgr:OnNPCCreate(Params)
	local EntityID = Params.ULongParam1
    local ResID = ActorUtil.GetActorResID(EntityID)
    local IsCardNPC = MagicCardVMUtils.IsMagicCardNPC(ResID)
    if IsCardNPC then
        self:OnGameEventNeedReqRecover() -- 靠近幻卡NPC时，标记下，用于重登需要重连的情况
        self:UpdateMajorAndNPCTransform()
        local CurNPCID = self:GetPVENPCID()
        local IsInCardGame = CurNPCID == ResID
        if IsInCardGame then
            -- 针对断线重连后，对手播放待机动作
            ActorAnimService:PlayNpcIdleAnim()
        end
    end
end

function MagicCardMgr:OnGameEventStartFadeIn(Params)
    local EntityID = Params.ULongParam1
    if EntityID == nil or EntityID == 0 then
        return
    end
    local ResID = ActorUtil.GetActorResID(EntityID)
    local IsCardNPC = MagicCardVMUtils.IsMagicCardNPC(ResID)
    local CurNPCID = self:GetPVENPCID()
    local IsInCardGame = CurNPCID == ResID
    -- 杀端重连
    --local IsInCardGame= MagicCardMgr:IsInMagicCardGame(EntityID)
    if IsCardNPC then
        if IsInCardGame then
            if not self.IsFinishedRecover then
                self:UpdateMajorAndNPCTransform()
            end
            -- 针对杀端重连后，对手播放待机动作
            ActorAnimService:PlayNpcIdleAnim()
            self:TurnCamera(nil, 1, nil)
        end
    end
end

function MagicCardMgr:OnGameEventNeedReqRecover()
    self.IsNeedReqRecover = true
end

---@type 刚登陆时or断线重连时or在对局室内时检测是否需要重连幻卡对局
function MagicCardMgr:CheckIsNeedRecover()
    self.RecoverTimeCount = self.RecoverTimeCount + 0.1
    local IsTimeOut = self.RecoverTimeCount >= self.RecoverTimeOut
    local IsEndCheck = IsTimeOut or self.IsNeedReqRecover
    if IsEndCheck then
        self.RecoverTimeCount = 0
        if self.CheckIsNeedRecoverTimer then
            self:UnRegisterTimer(self.CheckIsNeedRecoverTimer)
            self.CheckIsNeedRecoverTimer = nil
        end
        self:UnRegisterGameEvent(EventID.MagicCardNeedReqRecover, self.OnGameEventNeedReqRecover)
        self:UnRegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
    end

    if self.IsNeedReqRecover then
        self.IsNeedReqRecover = false
        self:SendFantasyCardRecoverReq()
    end
end

function MagicCardMgr:OnGameEventVisionEnter(Params)
    local EntityID = Params.ULongParam1
    if EntityID == nil or EntityID == 0 then
        return
    end
    local ResID = ActorUtil.GetActorResID(EntityID)
    local IsCardNPC = MagicCardVMUtils.IsMagicCardNPC(ResID)
    -- 杀端重连
    if IsCardNPC and not self.bReconnect then
        self:UpdateMajorAndNPCTransform()
        self.bReconnect = false
    end
end

--- 角色被销毁后，检测一下，如果是创建出来的NPC对象，那么重置一下 ActorAnimService 保存的数据
function MagicCardMgr:OnEventActorDestroy(Params)
    local EntityID = Params.ULongParam1
    if (EntityID ~= nil and EntityID == self.PVPOpponentEntityID) then
        if (ActorAnimService ~= nil) then
            ActorAnimService:Reset()
        end
        self.PVPOpponentEntityID = nil
    end
end

function MagicCardMgr:OnEventClientSetupPost(EventParams)
    local Value = EventParams.StringParam1 or nil
    local SetupKey = EventParams.IntParam1
    local IsSetCB = EventParams.BoolParam1
    if SetupKey == ClientSetupKey.FantacyCardEmoList then
        local _usedIDList = nil
        if (Value ~= nil and Value ~= "") then
            _usedIDList = Json.decode(Value)
        end
        if (_usedIDList == nil or #_usedIDList ~= 4) then
            _usedIDList = {
                0,
                0,
                0,
                0
            }
        end
        self.EmoIDTable = _usedIDList
        if (self.EmoIDTable[1] <= 0) then
            self.EmoIDTable[1] = LocalDef.DefualtSalutEmoID
        end
    end
end

function MagicCardMgr:OnRelayConnected(Params)
    if not Params.bRelay then
        return
    end
    -- 闪断后关闭对局界面
	UIViewMgr:HideView(UIViewID.MagicCardMainPanel)
    if not self.IsGameEnd then
        self:SendFantasyCardRecoverReq()
    end
end

function MagicCardMgr:OnGameEventLoginRes(Param)
    self.bReconnect = Param and Param.bReconnect
    if (self.bReconnect) then
        if self.ReadyGame then
            self:OnEnterCardState(false)
            self:HandleOthersVisiblle(true)
            self:ResetDataAfterQuit()
        end

        if CommonStateUtil.IsInState(ProtoCommon.CommStatID.CommStatFantasyCard) then
            self:OnUserQuitGame()
        end

        self.IsFinishedRecover = false
    end
    self:ResetData()
    self:SendCollectionUpdateReq()

end

function MagicCardMgr:OnGameEventAppEnterBackground()
    --self.IsEnterBackground = true
end

function MagicCardMgr:OnGameEventAppEnterForeground()
    -- if self.IsEnterBackground then
    --     self:SendFantasyCardRecoverReq()
    -- end
end

function MagicCardMgr:SendFantasyCardRecoverReq()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_RECOVER

    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_RECOVER
    MsgBody.RecoverReq = {
        CardGameID = self.CardGameId
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 检查一下，编辑的卡组是否有效修改的时候得特别注意，其他地方也用到了
--- @param ViewModel CardsGroupCardVM 目前是这些在用
function MagicCardMgr.CheckCardGropuIsValid(ViewModel)
    if (ViewModel == nil) then
        _G.FLOG_ERROR("Error , pass params : ViewModel , is empty ,please check!")
        return
    end

    local AllCardNum, FiveStarNum, FourStarNum = 0, 0, 0
    for _, CardItem in ipairs(ViewModel.GroupCardList) do
        local _targetID = CardItem:GetCardId()
        if _targetID ~= 0 then
            AllCardNum = AllCardNum + 1
            local ItemCfg = CardCfg:FindCfgByKey(_targetID)
            if ItemCfg then
                if ItemCfg.Star == 5 then
                    FiveStarNum = FiveStarNum + 1
                elseif ItemCfg.Star == 4 then
                    FourStarNum = FourStarNum + 1
                end
            end
        end
    end

    ViewModel.CheckRuleCardNum = AllCardNum == 5
    ViewModel.CheckRuleFiveStarCard = FiveStarNum <= 1
    ViewModel.CheckRuleFourStarCard = true
    if FiveStarNum == 1 then
        ViewModel.CheckRuleFourStarCard = FourStarNum <= 1
    elseif FiveStarNum == 0 then
        ViewModel.CheckRuleFourStarCard = FourStarNum <= 2
    end
    ViewModel.IsAllRulePass = ViewModel.CheckRuleCardNum and ViewModel.CheckRuleFiveStarCard and ViewModel.CheckRuleFourStarCard

    -- 这里是为了方便做检测的，外面的检测
    ViewModel:ChangeCheckNotify()
end

function MagicCardMgr:OnGameEventPWorldEnter(Params)
    self.NpcHudIconMap = {}
    self.NpcResIdHudIconMap = {}
    self:SendNPCUpdateReq(Params.CurrMapResID)
    self.MapResID = Params.CurrMapResID
end

function MagicCardMgr:OnMagicCardGameStartReq(Info)
    if Info == nil then
        return
    end
    self.PVEOpponentInfo.NPCID = Info.NPCID
    self.PVEOpponentInfo.NPCEntityID = Info.NPCEntityID
    self.IsTournament = Info.IsTournament
    -- 匹配中或者匹配确认中不能开新局
    if MagicCardTourneyMgr:GetIsInMatching() then
        _G.MsgTipsUtil.ShowTips(_G.LSTR(MagicCardLocalDef.UKeyConfig.WithNewGameOnMatchingTips))
        return
    end

    -- 战斗
    if MajorUtil.IsMajorCombat() then
        _G.MsgTipsUtil.ShowTipsByID(MagicCardLocalDef.CombatTipsID)
        return
    end

    self:SendOpenGameStartReq(self.IsTournament)

end

function MagicCardMgr:GetPVENPCID()
    return self.PVEOpponentInfo and self.PVEOpponentInfo.NPCID or 0
end

function MagicCardMgr:GetPVENPCEntityID()
    if self.PVEOpponentInfo == nil then
        return
    end
    local NPCID = self.PVEOpponentInfo.NPCID
    local NPCEntityID = nil
    if NPCID and NPCID > 0 then
        NPCEntityID = ActorUtil.GetActorEntityIDByResID(NPCID)
    end
    if NPCEntityID == nil or NPCEntityID <= 0 then
        NPCEntityID = self.PVEOpponentInfo.NPCEntityID or 0
    end
    return NPCEntityID
end

function MagicCardMgr:IsInMagicCardGame(EntityID)
    local CurEntityID = self:GetOpponentEntityID()
    return CurEntityID and CurEntityID == EntityID
end

function MagicCardMgr:SetMajorCanMove(bCanMove)
    local StateComponent = MajorUtil.GetMajorStateComponent()
   	if StateComponent ~= nil then
        --有tag，先判断状态是否一样
        local State = StateComponent:GetActorControlState(_G.UE.EActorControllStat.CanMove)
		print("========================= CanMoveSet %s", State)
        if State == bCanMove then
            return
        end
		
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanMove, bCanMove, "GoldMiniGame")
		StateComponent:SetActorControlState(_G.UE.EActorControllStat.CanAllowMove, bCanMove, "GoldMiniGame")
		print("========================= CanMoveSet %s", bCanMove)
	end--]] 
end

function MagicCardMgr:GetOpponentInfo()
    if self.PlayMode == EPlayMode.None then
        return nil
    end

    if (self.PlayMode == EPlayMode.PVE) then
        -- NPC里面拿
        local NPCID = self:GetPVENPCID()
        local NPCData = FantasyCardNpcCfg:FindCfgByKey(NPCID)
        if (NPCData == nil) then
            _G.FLOG_ERROR(string.format("错误，无法获取 c_fantasy_card_npc_cfg 数据，ID 是：%s"), NPCID)
        else
            local IsInTourney = MagicCardTourneyMgr:GetIsInTourney()
            if IsInTourney then
                local TourneyAwardScore = MagicCardTourneyVMUtils.GetNPCAwardWithTourney(NPCID)
                if TourneyAwardScore then
                    NPCData.WinAward = TourneyAwardScore.WinAward
                    NPCData.FailAward = TourneyAwardScore.FailAward
                    NPCData.TieAward = TourneyAwardScore.TieAward
                end
            end
            return NPCData
        end
    end

    local TourneyStageIndex = TourneyVM.CurStageIndex

    if (self.PlayMode == EPlayMode.PVP) then
        local PVPRoleData = MagicCardTourneyVMUtils.GetOpponentInfoByRoleID(self.PVPRoleID, TourneyStageIndex)
        if (PVPRoleData == nil) then
            _G.FLOG_ERROR(string.format("错误，无法获取 NPCAIData 数据，ID 是：%s"), self.PVPRoleID or 0)
        else
            return PVPRoleData
        end
    end

    if (self.PlayMode == EPlayMode.PVPRobot) then
        local NPCAIData = MagicCardTourneyVMUtils.GetOpponentInfoByRobotInfo(self.PVPRobotOpponentInfo, TourneyStageIndex)
        return NPCAIData
    end
end

function MagicCardMgr:GetOpponentHeadIconStr()
end

--- func 获取对手的 EntityID
function MagicCardMgr:GetOpponentEntityID()
    if (self.PVPOpponentEntityID ~= nil and self.PVPOpponentEntityID > 0) then
        return self.PVPOpponentEntityID
    end

    local NPCEntityID = self:GetPVENPCEntityID()
    if (NPCEntityID ~= nil and NPCEntityID > 0) then
        return NPCEntityID
    end

    if (self.PVPRoleID ~= nil and self.PVPRoleID > 0) then
        return ActorUtil.GetEntityIDByRoleID(self.PVPRoleID)
    end

    return nil
end

--- func 获取对手设置的对局表情
function MagicCardMgr:GetOpponentSettedEmo()
    return self.OpponentEmoList
end

---@type PVP模式 对手包含机器人
function MagicCardMgr:IsPVPMode()
    return self.PlayMode == EPlayMode.PVP or self.PlayMode == EPlayMode.PVPRobot
end

---@type PVP机器人
function MagicCardMgr:IsPVPRobotMode()
    return self.PlayMode == EPlayMode.PVPRobot
end

function MagicCardMgr:GetPrepareSeconds()
    return self.PrepareSecond
end

function MagicCardMgr:OnEnterCardState(IsEnter)
    CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.CommStatFantasyCard, IsEnter)
end

---@type 幻卡准备
function MagicCardMgr:OnNetMsgViewGroupRsp(MsgBody)
    if MsgBody and MsgBody.ErrorCode then
        self:OnNetMsgError()
        return
    end
    
    local ViewGroupRsp = MsgBody and MsgBody.GroupViewRsp
    if (ViewGroupRsp == nil) then
        _G.FLOG_ERROR("错误，ViewGroupRsp 为空，请检查")
        return
    end

    self:OnEnterCardState(true)
    self.ReadyGame = true
    self.NpcGameInfo = ViewGroupRsp
    self.CardGameId = ViewGroupRsp.BattleID or 0
    self:UpdateOpponentInfo(ViewGroupRsp.OpponentInfo)
    local RemainPrepareSecond = math.ceil((self.NpcGameInfo.FinishTime - _G.TimeUtil.GetServerTimeMS())/1000)
    self.PrepareSecond = (self:IsPVPMode() and RemainPrepareSecond) or MagicCardVMUtils.GetCardReadyTime(self:IsPVPMode())
    
    FLOG_INFO("OnNetMsgViewGroupRsp 设置 CardGameId 为:"..self.CardGameId)
    ActorAnimService:Reset()
    -- 显示准备界面
    local function ShowReadyView()
        ActorAnimService:Reset()
        self:TurnCamera(nil, LocalDef.CameraTurnTime, nil)
        self:SetMajorCanMove(false)
        UIViewMgr:ShowView(UIViewID.MagicCardEnterConfirmPanel)
        GameRuleService:SetGameRules(self.NpcGameInfo.PlayRules)
        EventMgr:SendEvent(EventID.OnMagicCardStart) -- 开始幻卡
    end

    -- 局内和NPC交互打开的
    if self.PlayMode == EPlayMode.PVE then
        self.IsOutSide = false
        if self.SkipDialogByRestart then
            self.SkipDialogByRestart = nil
            ShowReadyView()
            return
        end

        local NPCID = self:GetPVENPCID()
        local NPCEntityID = self:GetPVENPCEntityID()
        self:PlayDefaultDialog(NPCID, NPCEntityID, ShowReadyView)
        return
    end

    -- PVP对局
    local InteractWithPVP = self:IsPVPMode()
    if InteractWithPVP then
        self:UpdateOpponentRoleSimple(ShowReadyView) -- 查询完对手信息后显示准备界面
        self.IsGameEnd = false
        self.IsOutSide = false
        return
    end

    -- 幻卡编辑界面
    if self.PlayMode == EPlayMode.None then
        self.IsOutSide = true
        self.IsGameEnd = false
        -- 局外直接打开，没有NPC相关
        GameRuleService:SetGameRules(self.NpcGameInfo.PlayRules)
        UIViewMgr:ShowView(
            UIViewID.MagicCardPrepareMainPanel,
            {
                -- repeated FantasyCardGroup CardGroups = 8; 			// 选卡组页面展示玩家所有卡组, 索引0-4对应从上到下
                CardGroups = ViewGroupRsp.CardGroups,
                -- int32 DefaultIndex = 9;								// 从上到下依次为0-4，自动卡组为-1
                DefaultIndex = ViewGroupRsp.DefaultIndex
            }
        )
    end
end

function MagicCardMgr:PlayDefaultDialog(InNpcResId, InEntityId, FinishCallback)
    local NpcDialogLibID = 0
    local bHasFinishQuest = self:HasFinishTargetQuest()
    if (bHasFinishQuest) then
        local Cfg = FantasyCardNpcCfg:FindCfgByKey(InNpcResId)
        NpcDialogLibID = Cfg and tonumber(Cfg.DialogIDPreGame) or 14048
        if (NpcDialogLibID == nil or NpcDialogLibID == 0) then
            _G.FLOG_ERROR("NPC：%d ，没有配置对局前的对话，请检查玩法表-幻卡AI配置!", InNpcResId)
        end
    else
        local Cfg = NpcCfg:FindCfgByKey(InNpcResId)
        if Cfg.SwitchTalkID and Cfg.SwitchTalkID > 0 then
            DefaultDialogID = Cfg.SwitchTalkID
        end
        if (NpcDialogLibID == nil or NpcDialogLibID == 0) then
            _G.FLOG_ERROR("NPC：%d ，没有配置解锁幻卡功能前的对话，请检查NPC表是否配置自定义对话!", InNpcResId)
        end
    end
    
    local NpcDialogCfg = DialogCfg:FindAllCfg("DialogLibID = "..NpcDialogLibID)
    if NpcDialogCfg == nil or next(NpcDialogCfg) == nil then
        _G.FLOG_ERROR("NPC：%d ，配置的对话ID在NPC对话表中不存在，请检查NPC对话表", InNpcResId or 0)
        if FinishCallback then
            FinishCallback()
        end
        return
    end

    Utils.PlayNpcDialog(InEntityId, NpcDialogLibID, FinishCallback)
end

---@type 更新大赛对手形象信息
function MagicCardMgr:UpdateOpponentRoleSimple(UpdateFinishedCallback)
    self.IsPVP = self:IsPVPMode()
    if not self.IsPVP then
        self.OpponentRoleSimple = nil
        return
    end

    local RoleID = 0

    if self.PlayMode == EPlayMode.PVP then
        RoleID = self.PVPRoleID --对手是玩家，直接采用对手形象
    elseif self.PlayMode == EPlayMode.PVPRobot then
        if self.PVPRobotOpponentInfo then
            local RobotRoleID = self.PVPRobotOpponentInfo.RobotCopyTargetRoleID
            RoleID = RobotRoleID --对手是机器人，复制其他玩家形象
        end
    end

    local function HandleOpponentAndMajor(OpponentRoleSimple)
        --生成对手形象
        local RobotNPCID = self.PVPRobotOpponentInfo and self.PVPRobotOpponentInfo.RobotCopyTargetNPCID or 0
        self.PVPOpponentEntityID = MagicCardTourneyMgr:HandleOpponentAndMajor(self.IsPVP, OpponentRoleSimple, RobotNPCID)
        if UpdateFinishedCallback then
            UpdateFinishedCallback()
        end
    end

    if RoleID == nil or RoleID <= 0 then
        self.OpponentRoleSimple = nil
        HandleOpponentAndMajor(self.OpponentRoleSimple)
    else
        _G.RoleInfoMgr:QueryRoleSimple(
            RoleID,
            function(_, RoleVM)
                if RoleVM then
                    self.OpponentRoleSimple = RoleVM.RoleSimple
                end
                HandleOpponentAndMajor(self.OpponentRoleSimple)
            end
        )
    end

end

function MagicCardMgr:OnNetMsgFantasyCardEnterRsp(MsgBody)
    if MsgBody and MsgBody.ErrorCode then
        self:OnNetMsgError()
        return
    end

    local FantasyCardEnterRsp = MsgBody and MsgBody.EnterRsp
    if FantasyCardEnterRsp == nil then
        return
    end

    --对局状态：0匹配完成，1选卡组，2进行中，3等待领奖
    if FantasyCardEnterRsp.Status == 1 then
        return
    end
    
    self:OnEnterCardState(true)
    self.IsGameBegin = true
    self.IsGameEnd = false
    self.ReadyGame = false
    self.CardGameId = FantasyCardEnterRsp.CardGameID
    self:UpdateOpponentInfo(FantasyCardEnterRsp.OpponentInfo)
    FLOG_INFO(string.format("OnNetMsgFantasyCardEnterRsp 设置 CardGameId 为 [%s]", FantasyCardEnterRsp.CardGameID))
    ActorAnimService:Reset()
    if self.PlayMode == EPlayMode.None then
        _G.FLOG_ERROR("下发的数据有问题，没有可用的对手信息，请检查！")
        return
    end
    self:UpdateOpponentEmo(FantasyCardEnterRsp.OpponentEmoSetup)
    
    if (self.NpcGameInfo == nil) then
        self.NpcGameInfo = {}
    end
    -- "天选"规则，会在EnterRsp里更新规则
    self.NpcGameInfo.PlayRules = FantasyCardEnterRsp.Rules
    self.NpcGameInfo.PopularRules = FantasyCardEnterRsp.PopularRules
    GameRuleService:SetGameRules(FantasyCardEnterRsp.Rules)
    local InteractiveMgr = require("Game/Interactive/InteractiveMgr")
    InteractiveMgr:ClearFunctionViewID()
    -- 如果其它界面还开着，那么关闭掉
    self.HideReadinessViewRelativeUI()
    local function TryRecover()
        if UIViewMgr:IsViewVisible(UIViewID.MagicCardMainPanel) then
            -- if self.IsEnterBackground then
            --     -- 从后台切换回来的
            --     self.IsEnterBackground = false
            --     EventMgr:SendEvent(EventID.MagicCardRecover, FantasyCardEnterRsp)
            -- else
            --     EventMgr:SendEvent(EventID.MagicCardRefreshMainPanel, FantasyCardEnterRsp)
            -- end
            EventMgr:SendEvent(EventID.MagicCardRefreshMainPanel, FantasyCardEnterRsp)
        else
            -- 断线重连恢复
            self:OnRecoverGamingView(FantasyCardEnterRsp)
        end
    end
    self:RegisterTimer(TryRecover, 0.2) -- 延迟，防止重连模块未及时隐藏对局界面，造成误判
end

---@type 恢复对局界面
function MagicCardMgr:OnRecoverGamingView(FantasyCardEnterRsp)
    self:OnBeforeGameStartHandle() -- 背景音与隐藏其它
    local InteractWithPVP = self:IsPVPMode()
    local function OnOpponentInit()
        ActorAnimService:Reset()
        ActorAnimService:PlayNpcIdleAnim()
        self:TurnCamera(nil, LocalDef.CameraTurnTime, nil)
    end

    if InteractWithPVP then
        self:UpdateOpponentRoleSimple(OnOpponentInit) -- 更新完对手后，设置镜头
        self.IsGameEnd = false
        self.IsOutSide = false
    else
        self:UpdateMajorAndNPCTransform() -- 与NPC对局位置
    end

    local function OnShowMagicCardMainView(MainView)
        MainView:OnRecoverGame(FantasyCardEnterRsp) -- 界面牌局
    end
    UIViewMgr:ShowView(UIViewID.MagicCardMainPanel, {RemainTime = 0, IsOpponentPVP = self.IsPVP}, OnShowMagicCardMainView)
end

function MagicCardMgr:OnNetMsgMatchSuccess()
    -- 如果在准备界面，则关闭退出
    self:QuitBeforeEnterGame()
end

---@type 更新对手信息
function MagicCardMgr:UpdateOpponentInfo(OpponentInfo)
    if OpponentInfo == nil then
        self.PlayMode = EPlayMode.None
        self.PVEOpponentInfo = {}
        self.PVPRobotOpponentInfo = {}
        self.PVPRoleID = 0
        return
    end

    local NPCID = OpponentInfo.NPCID -- PVE
    if (NPCID ~= nil and NPCID > 0) then
        self.PVEOpponentInfo = {
            NPCID = NPCID,
            NPCEntityID = ActorUtil.GetActorEntityIDByResID(NPCID)
        }
        self.PlayMode = EPlayMode.PVE
        return
    end

    local RobotInfo = OpponentInfo.Robot -- PVP 机器人对手ID
    if RobotInfo then
        self.PVPRobotOpponentInfo = {}
        -- PVP 机器人ID, RoleID为其它玩家ID，用于展示机器人形象（RoleID无效则取NPCID，从表格读取形象)
        if RobotInfo.RoleID and RobotInfo.RoleID > 0 then
            self.PVPRobotOpponentInfo.RobotCopyTargetRoleID = RobotInfo.RoleID
        else
            self.PVPRobotOpponentInfo.RobotCopyTargetNPCID = RobotInfo.NPCID
        end
        self.PVPRobotOpponentInfo.RobotNameID = RobotInfo.NameID
        self.PlayMode = EPlayMode.PVPRobot
        return
    end

    local RoleID = OpponentInfo.RoleID -- PVP 玩家对手ID
    if RoleID ~= nil then
        self.PVPRoleID = RoleID
        self.PlayMode = EPlayMode.PVP
        return
    end

    self.PlayMode = EPlayMode.None
end

function MagicCardMgr:UpdateOpponentEmo(EmoStr)
    if string.isnilorempty(EmoStr) then
        self.OpponentEmoList = {}
        return
    end
    self.OpponentEmoList = Json.decode(EmoStr)
end

function MagicCardMgr:OnNetMsgFantasyCardNewMoveRsp(MsgBody)
    local MsoveRsp = MsgBody and MsgBody.NewMoveRsp
    EventMgr:SendEvent(EventID.MagicCardNewMove, MsoveRsp)
end

function MagicCardMgr:OnNetMsgFantasyCardFinishRsp(MsgBody)
    local FantasyCardFinishRsp = MsgBody and MsgBody.FinishRsp
    local TargetView = UIViewMgr:FindVisibleView(UIViewID.MagicCardMainPanel)
    if (TargetView == nil) then
        -- 这里是还没有进入正式游戏，可能是对面结束了
        local BattleResult = FantasyCardFinishRsp.Result
        self:EndGame(FantasyCardFinishRsp)
        -- if (BattleResult == ProtoCS.BATTLE_RESULT.BATTLE_RESULT_WIN) then
        -- end
    end
    EventMgr:SendEvent(EventID.MagicCardGameFinish, FantasyCardFinishRsp)
    self.IsGameBegin = false
    self.IsGameEnd = true
    self.ReadyGame = false
    self:HideReadinessViewRelativeUI()
    --self:EndGame(FantasyCardFinishRsp)
end

-- 从表格中加载数据
function MagicCardMgr:LoadDefineTimeFromTable()
    -- 玩家和PVP以及机器人的等待时间
    local _tableData = GameGlobalCfg:FindCfgByKey(GLOBAL_CFG_ID.GAME_CFG_PLAYER_TIMEOUT) ---1001
    if (_tableData ~= nil and _tableData.Value ~= nil and #_tableData.Value > 0) then
        LocalDef.TotalTimeForOneMove = _tableData.Value[1] * 0.001
    end

    -- 纯NPC的出牌等待时间，客户端计时，然后发送给服务器让服务器出牌
    local _tableData = GameGlobalCfg:FindCfgByKey(GLOBAL_CFG_ID.GAME_CFG_AI_TIMEOUT) --1000
    if (_tableData ~= nil and _tableData.Value ~= nil and #_tableData.Value > 0) then
        LocalDef.NPCPutCardDelayTime = _tableData.Value[1] * 0.001
        if (LocalDef.NPCPutCardDelayTime < 1) then
            LocalDef.NPCPutCardDelayTime = 1
        end
    end
end

function MagicCardMgr:OnNetMsgEditGroupRsp(MsgBody)
    local GroupEditRsp = MsgBody and MsgBody.GroupEditRsp
    if not GroupEditRsp.EditSuccess then
        Log.I("MagicCardMgr:OnNetMsgEditGroupRsp EditFailed!")
        return
    end
    if (GroupEditRsp.EditSuccess) then
        EventMgr:SendEvent(EventID.MagicCardOnNetEditGroupRsp, GroupEditRsp.CardGroupIdx + 1, GroupEditRsp.Cards)
    else
        _G.MsgTipsUtil.ShowTips(_G.LSTR(LocalDef.UKeyConfig.SaveFailed))
    end
end

function MagicCardMgr:OnNetMsgUpdateCollectionRsp(MsgBody)
    local CollectionUpdateRsp = MsgBody and MsgBody.CollectionUpdateRsp
    for _, NewCardId in ipairs(CollectionUpdateRsp.Cards) do
        if not table.find_item(self.OwnedCardList, NewCardId) then
            table.insert(self.OwnedCardList, NewCardId)
        end
    end

    local function SortForCard(CardIDA, CardIDB)
        local ItemCfgA = CardCfg:FindCfgByKey(CardIDA)
        local ItemCfgB = CardCfg:FindCfgByKey(CardIDB)

        if (ItemCfgA ~= nil and ItemCfgB ~= nil) then
            if (ItemCfgA.Star == ItemCfgB.Star) then
                return CardIDA < CardIDB
            else
                return ItemCfgA.Star < ItemCfgB.Star
            end
        end

        if (ItemCfgA ~= nil) then
            return true
        end

        return false
    end

    -- 这里排序一下 星级从低到高，然后按照id从低到高
    table.sort(self.OwnedCardList, SortForCard)
end

function MagicCardMgr:HasFinishPreQuestByEntityID(InEntityID)
    local ResID = ActorUtil.GetActorResID(InEntityID)
    return self:HasFinishPreQuestByResID(ResID)
end

function MagicCardMgr:HasFinishPreQuestByResID(InResID)
    local NPCAIData = FantasyCardNpcCfg:FindCfgByKey(InResID)
    if (NPCAIData == nil) then
        return false
    end
    local PreQuestIDTable = self.NpcPreQuestTable[InResID]
    if (PreQuestIDTable == nil) then
        PreQuestIDTable = {}
        self.NpcPreQuestTable[InResID] = PreQuestIDTable
        local PreQuestIDStr = NPCAIData.PreQuestID
        if (PreQuestIDStr == nil or PreQuestIDStr == "") then
            return true
        end
        local SplitArry = string.split(PreQuestIDStr, ";")
        if (SplitArry == nil or #SplitArry < 1) then
            return true
        end

        for _,Value in pairs(SplitArry) do
            local QuestID = tonumber(Value)
            table.insert(PreQuestIDTable, QuestID)
        end
    end

    if (#PreQuestIDTable < 1) then
        return true
    end

    for _,QuestID in pairs(PreQuestIDTable) do
        local _questStatus = _G.QuestMgr:GetQuestStatus(QuestID)
        if (_questStatus == nil or _questStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED) then
            return false
        end
    end

    return true
end

function MagicCardMgr:OnNetMsgNpcUpdateRsp(MsgBody)
    local NPCUpdateRsp = MsgBody and MsgBody.NPCUpdateRsp
    local function GetHudIconPathByState(State)
        if State == ProtoCS.FANTASY_CARD_NPC_STATUS.FANTASY_CARD_NPC_STATUS_NEVER_WIN then
            return "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_MC_Missed_png.UI_Icon_Hud_MC_Missed_png'"
        elseif State == ProtoCS.FANTASY_CARD_NPC_STATUS.FANTASY_CARD_NPC_STATUS_HAS_COLLECTABLE_CARD then
            return "PaperSprite'/Game/UI/Atlas/HUDQuest/Frames/UI_Icon_Hud_MC_Go_png.UI_Icon_Hud_MC_Go_png'"
        else
            return nil
        end
    end
    local NpcIdList, id = {}, 1
    for NpcID, NpcState in pairs(NPCUpdateRsp.NPCs) do
        local NPCEntityID = ActorUtil.GetActorEntityIDByResID(NpcID)
        self.NpcResIdHudIconMap[NpcID] = GetHudIconPathByState(NpcState.status)
        if NPCEntityID then
            NpcIdList[id] = NPCEntityID
            id = id + 1
            self.NpcHudIconMap[NPCEntityID] = GetHudIconPathByState(NpcState.status)
        end
    end

    EventMgr:SendEvent(EventID.MagicCardUpdateNPCHudIcon, NpcIdList)
end

function MagicCardMgr:OnNetMsgSelectGroupRsp(MsgBody)
    if MsgBody == nil or MsgBody.SelectRsp == nil then
        return
    end
    local GroupSelectRsp = MsgBody.SelectRsp
    -- GroupSelectRsp.Cards为空表示是设置默认卡组的返回，不处理
    if GroupSelectRsp.Cards and #GroupSelectRsp.Cards ~= 0 then
        local CardIdListStr = ""
        for _, CardId in ipairs(GroupSelectRsp.Cards) do
            CardIdListStr = CardIdListStr .. string.format(" %d ", CardId)
        end
        Log.I("MagicCardMgr:OnNetMsgSelectGroupRsp: cards [%s]", CardIdListStr)
        EventMgr:SendEvent(EventID.MagicCardOnSvrCreateAutoGroup, GroupSelectRsp.Cards)
    end
end

--test
-- function MagicCardMgr:SendAppEnterBackground()
--     self.IsEnterBackground = true
--     self:SendFantasyCardRecoverReq()
-- end

function MagicCardMgr:LowerBGMVolume()
    self.BGMVolume = AudioMgr:GetAudioVolume(AudioType_BGM)
    AudioMgr:SetAudioVolume(AudioType_BGM, MagicCardLocalDef.BGMVolumeWhenPlaying)
end

function MagicCardMgr:RestoreBGMVolume()
    AudioMgr:SetAudioVolume(AudioType_BGM, self.BGMVolume)
end

function MagicCardMgr:PlayCardBGM()
    self.BGMID = AudioMgr:PlayBGM(MagicCardLocalDef.CardBGMID, _G.UE.EBGMChannel.UI)
end

function MagicCardMgr:StopCardBGM()
    if self.BGMID and self.BGMID > 0 then
        AudioMgr:StopBGM(self.BGMID)
    end
end

function MagicCardMgr:StopBGM()
    AudioMgr:StopSceneBGM()
end

function MagicCardMgr:RestartGame(CardGameID, IsReturnToStart)
    if not IsReturnToStart then
        self:SendConfirmEnterGame(true)
    else
        UIViewMgr:HideView(UIViewID.MagicCardMainPanel)
        self.SkipDialogByRestart = true
        self:SendOpenGameStartReq(self.IsTournament)
    end
end

function MagicCardMgr:EndGame(GameFinishRsp)
    UIViewMgr:HideView(UIViewID.MagicCardMainPanel)
    self:StopCardBGM()
    if _G.PWorldMgr:CurrIsInDungeon() then
        return
    end
    UIViewMgr:ShowView(
        UIViewID.MagicCardGameFinishPanel,
        {
            Data = GameFinishRsp
        }
    )
end

function MagicCardMgr:SendOpenGameStartReq(InIsTournament)
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_VIEW_GROUP
    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_VIEW_GROUP

    local NPCID = self:GetPVENPCID()
    MsgBody.GroupViewReq = {
        NPCID = NPCID,
        IsTournament = InIsTournament
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MagicCardMgr:SendNewMoveReq(ChosedCardIndex, ChosedBoardCardLoc, IsAutoPlay, Round)
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_NEW_MOVE
    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_NEW_MOVE
    local PlaceCardSvrIndex = ChosedCardIndex - 1
    local ChosedBoardSvrLoc = ChosedBoardCardLoc - 1

    _G.FLOG_INFO(
        string.format(
            "发送出牌请求，当前轮次：[%s] , 卡牌下标：[%s], 出牌位置下标：[%s], 是否自动出牌:[%s]",
            Round,
            ChosedCardIndex,
            ChosedBoardCardLoc,
            IsAutoPlay
        )
    )

    if self.CardGameId == nil or self.CardGameId <= 0 then
        Log.I("self.CardGameId 为0, 不发送出牌请求")
        return
    end

    MsgBody.NewMoveReq = {
        CardGameID = self.CardGameId,
        PlaceCard = PlaceCardSvrIndex,
        Loc = ChosedBoardSvrLoc,
        AutoPlay = IsAutoPlay,
        Round = Round
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MagicCardMgr:SendFinishFantasyCard(bForceLeave)
    if self.IsGameEnd then
        return
    end

    if self.CardGameId == nil or self.CardGameId <= 0 then
        Log.I("self.CardGameId 为0, 不发送结束请求")
        return
    end
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_FINISH
    local MsgBody = {}

    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_FINISH

    MsgBody.FinishReq = {
        CardGameID = self.CardGameId,
        ForceLeave = (bForceLeave ~= nil and bForceLeave) or false
    }

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MagicCardMgr:SendConfirmEnterGame(IsRestarEnter)
    Log.I("确认进入幻卡对局了，是否为直接重开 : " .. tostring(IsRestarEnter))
    if self.PlayMode ~= EPlayMode.PVE then
        if self.CardGameId == nil or self.CardGameId <= 0 then
            Log.I("self.CardGameId 为0, 不发送进入游戏请求")
            return
        end
    end

    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_ENTER

    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_ENTER
    if (IsRestarEnter) then
        -- 不胜不休规则进入的，不用修改
        MsgBody.EnterReq = {
            CardGameID = self.CardGameId
        }
    else
        MsgBody.EnterReq = {
            NPCID = self:GetPVENPCID(),
            CardGameID = self.CardGameId,
            IsTournament = MagicCardTourneyMgr:GetIsInTourney()
        }
    end

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MagicCardMgr:SendCollectionUpdateReq()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_COLLECTION

    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_COLLECTION

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@param GroupEditItemVm MagicCardGroupEditItemVM
function MagicCardMgr:SendGroupSaveEditReq(GroupEditItemVm)
    local EditedCardList = {}
    for i = 1, #GroupEditItemVm.GroupCardList do
        EditedCardList[i] = GroupEditItemVm.GroupCardList[i].CardId
    end
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_EDIT

    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_EDIT
    MsgBody.GroupEditReq = {
        CardGroupIdx = GroupEditItemVm:GetServerIndex(),
        DoAutoEdit = false,
        CardGroupName = GroupEditItemVm.GroupName,
        Cards = EditedCardList
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MagicCardMgr:SendGroupAutoEditReq(SvrCardGroupId)
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_EDIT

    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_EDIT
    MsgBody.GroupEditReq = {
        CardGroupIdx = SvrCardGroupId,
        DoAutoEdit = true
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MagicCardMgr:SendSelectGroupAsDefaultReq(SvrCardGroupId)
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_SELECT

    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_SELECT
    MsgBody.SelectReq = {
        CardGroupIdx = SvrCardGroupId,
        DoAutoEdit = false
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MagicCardMgr:SendCreateAutoGroupReq()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_SELECT

    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_SELECT
    MsgBody.SelectReq = {
        CardGroupIdx = -1, -- 与服务器约定：创建自动组卡的卡组id为-1
        DoAutoEdit = true
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MagicCardMgr:SendNPCUpdateReq(MapResID)
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_NPC

    local MsgBody = {}
    MsgBody.Operation = ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_NPC
    MsgBody.NPCUpdateReq = {
        MapResID = MapResID
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- endregion handle net msg

function MagicCardMgr:OnUserQuitGame()
	self:OnEnterCardState(false)
    
    -- 恢复显示所有玩家
    self:HandleOthersVisiblle(true)
    
    self:SendFinishFantasyCard(true)
    self:ResetDataAfterQuit()
    EventMgr:SendEvent(EventID.MagicCardBattleQuit)
end

-- 掉线后对局界面关闭后处理
function MagicCardMgr:OnUserQuitGameWithDisConnect()
	self:OnEnterCardState(false)
    self:ResetDataAfterQuit()
    self:HandleOthersVisiblle(true)
    self:StopCardBGM()
end

-- 处理所有非对局玩家的显示
function MagicCardMgr:HandleOthersVisiblle(IsVisible)
    -- 其它模块监听事件，用于处理进入幻卡和退出幻卡时的表现
    if IsVisible then
        EventMgr:SendEvent(EventID.OnMagicCardExit) -- 退出幻卡
    else
        EventMgr:SendEvent(EventID.OnMagicCardStart) -- 进入幻卡
    end

    -- 隐藏其它玩家技能特效
    EffectUtil.SetIsInMiniGame(not IsVisible)
    self:HideAllCompanions(not IsVisible)
    -- 寻路指引线
    _G.NaviDecalMgr:SetNavPathHiddenInGame(not IsVisible)
    _G.NaviDecalMgr:DisableTick(not IsVisible)

    _G.BuoyMgr:ShowAllBuoys(IsVisible)
    local Major = MajorUtil.GetMajor()
    local NPCEntityID = self:GetPVENPCEntityID()
    if IsVisible then
        -- 正在对局中的其它玩家不恢复显示
        local ExcludeArray = _G.UE.TArray(_G.UE.uint64)
        local InGamePlayers MagicCardTourneyMgr:GetInGamePlayerEntityIDMap()
        if InGamePlayers then
            for _, EntityID in pairs(InGamePlayers) do
                ExcludeArray:Add(EntityID)
            end
        end
        UActorManager:HideAllActors(false, ExcludeArray,  _G.UE.TArray(_G.UE.uint8))
        HUDMgr:ShowAllActors()
        HUDMgr:UpdateActorVisibility(NPCEntityID, true, true)
        HUDMgr:ShowAllNpc()
        self:SetMajorCanMove(true)
        AudioMgr:SetAudioVolume(_G.UE.EWWiseAudioType.Sfx, SettingsMgr:GetValueBySaveKey("MainPlayerVol")) 	-- 特效

        if Major then 
            Major:HideMasterHand(false)
            Major:HideSlaveHand(false)
        end
    else
        local OpponentEntityID = self:GetOpponentEntityID()
        --在和NPC打牌时，隐藏所有玩家
        local ExcludeArray = _G.UE.TArray(_G.UE.uint64)
        if (OpponentEntityID ~= nil and OpponentEntityID > 0) then
            ExcludeArray:Add(OpponentEntityID)
        end
        ExcludeArray:Add(MajorUtil.GetMajorEntityID())
        UActorManager:HideAllActors(true, ExcludeArray,  _G.UE.TArray(_G.UE.uint8))
        HUDMgr:HideAllActors()
        HUDMgr:ShowTargetNpcOnly(OpponentEntityID)
        HUDMgr:UpdateActorVisibility(OpponentEntityID, false, true)
        AudioMgr:SetAudioVolume(_G.UE.EWWiseAudioType.Sfx, 0) 	-- 特效

        if Major then 
            Major:HideMasterHand(true)
            Major:HideSlaveHand(true)
        end
    end
    _G.UE.UCameraMgr:Get():SwitchVirtual(IsVisible)
end

-- 在准备界面退出了
function MagicCardMgr:QuitBeforeEnterGame()
    self:OnEnterCardState(false)
    if self:IsPVPMode() then
        self:SendFinishFantasyCard(true) -- PVP 退出时需要下发
    else
        self:HandleOthersVisiblle(true)
        self:HideReadinessViewRelativeUI()
        self:ResetDataAfterQuit()
    end
    --EventMgr:SendEvent(EventID.MagicCardBeforeEnterQuit)
end

function MagicCardMgr:ResetDataAfterQuit()
    self:ReSetMajorAndNpcLocalTrans()
    self.PVPRoleID = 0
    self.PVEOpponentInfo = {}
    self.PVPRobotOpponentInfo = {}
    self.PVPOpponentEntityID = nil
    self.OpponentEmoList = {}
    self.PVPRoleID = 0
    self.IsPVP = false
    self.IsGameEnd = true
    self.ReadyGame = false
    self.CardGameId = 0
    FLOG_INFO("ResetDataAfterQuit 设置 CardGameId 为 0")
    self.DelayShowRewardItemList = {}
    self.PlayMode = EPlayMode.None

    --self:RestoreBGMVolume()
    PWorldMgr:RestoreBGMusic()

    LuaCameraMgr:ResumeCamera(true)
    -- 有可能打开了单独的规则界面，这里去尝试关闭一下
    UIViewMgr:HideView(UIViewID.MagicCardRulePanelView)
end

---@return GameRuleService
function MagicCardMgr:GetRuleService()
    return GameRuleService
end

---@param SoundEnum int
function MagicCardMgr:OnGameEventPlayClickSound(SoundEnum)
    if SoundEnum == ClickSoundEffectEnum.Select and self.SoundEffect_Select then
        AudioUtil.LoadAndPlay2DSound(self.SoundEffect_Select, Cache_Map)
    elseif SoundEnum == ClickSoundEffectEnum.Put and self.SoundEffect_Put then
        AudioUtil.LoadAndPlay2DSound(self.SoundEffect_Put, Cache_Map)
    elseif SoundEnum == ClickSoundEffectEnum.Cancel and self.SoundEffect_Cancel then
        AudioUtil.LoadAndPlay2DSound(self.SoundEffect_Cancel, Cache_Map)
    end
end

function MagicCardMgr:IsMagicCardOwned(ResID)
    for _, CardId in ipairs(self.OwnedCardList) do
        if CardId == ResID then
            return true
        end
    end
    return false
end

function MagicCardMgr:OnGetItem(Item)
    -- 如果是在幻卡游戏中，那么不自动使用，记录到 MagicCard里 等结算界面弹出以后，在结算界面自动使用
    if (self.CardGameId ~= nil and self.CardGameId > 0) then
        local ItemData = {}
        ItemData.Item = {}
        ItemData.Item.GID = Item.GID
        ItemData.Item.ResID = Item.ResID
        ItemData.Item.Num = Item.Num
        ItemData.Type = LOOT_TYPE.LOOT_TYPE_ITEM
        table.insert(self.DelayShowRewardItemList, ItemData)
        return
    end

	-- 这里看一下，是否为幻卡物品，如果是幻卡物品，那么判断一下，是否完成了任务，如果完成了任务，那么自动使用
    if self.CheckMagicCardOpenState(Item.ResID) then
        self:AddNewCardToDelayUseList(Item)
    end
end

---@type 将背包中未使用的幻卡加入待使用队列
function MagicCardMgr:GetBagMagicCardItemList()
	local AllItemList = _G.BagMgr.ItemList
	local Length = #AllItemList
	local ItemList = {}
    self.DelayUseCardItemList = {}
	for i = 1, Length do
		local Item = AllItemList[i]
        local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
        if Cfg and Cfg.ItemType == ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD then
            self:AddNewCardToDelayUseList(Item)
        end
	end
	return ItemList
end

---@type 加入待使用幻卡队列
function MagicCardMgr:AddNewCardToDelayUseList(Item)
    if self.DelayUseCardItemList == nil then
        self.DelayUseCardItemList = {}
    end

    local ExistItem = self.DelayUseCardItemList[Item.GID]
    if ExistItem then
        ExistItem.Num = Item.Num
    else
        self.DelayUseCardItemList[Item.GID] = {GID = Item.GID, Num = Item.Num, ResID = Item.ResID}
    end
end

---@type 监测背包里是否有幻卡未使用
function MagicCardMgr:CheckCardItemUse()
    if self.DelayUseCardItemList == nil or next(self.DelayUseCardItemList) == nil then
        return
    end

    -- 一次使用一个
    for GID, CardItem in pairs(self.DelayUseCardItemList) do
        _G.BagMgr:UseItem(CardItem.GID)
        --FLOG_INFO("使用幻卡："..CardItem.GID)
        if CardItem.Num <= 0 then
            self.DelayUseCardItemList[GID] = nil
        end
        return
    end
end

---幻卡使用成功
function MagicCardMgr:OnEventUseItemSucc(Params)
    if nil == Params then 
        return 
    end
    
    local ItemID = Params.ResID
    local Cfg = ItemCfg:FindCfgByKey(ItemID)
    if Cfg == nil then return end

    if (Cfg.ItemType ~= ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD) then
        self.UsedCardID = 0
        return
    end

    self.UsedCardID = ItemID
    if self.DelayUseCardItemList == nil then
        return
    end

    for key, UseCardItem in pairs(self.DelayUseCardItemList) do
        if Params.ResID == UseCardItem.ResID then
            if UseCardItem.Num >= 1 then
                UseCardItem.Num = UseCardItem.Num - 1
            else
                self.DelayUseCardItemList[key] = nil
            end
        end
    end
end

---幻卡使用成功聊天框提示
function MagicCardMgr:GetUseCardSuccStr()
    if self.UsedCardID == nil or self.UsedCardID <= 0 then
        return nil
    end

    local Cfg = ItemCfg:FindCfgByKey(self.UsedCardID)
    if Cfg == nil then 
        return nil
    end

    local GoodsDesc = ItemCfg:GetItemName(self.UsedCardID)
	if string.isnilorempty(GoodsDesc) then
		return
	end
    local GetRitchText = RichTextUtil.GetText(string.format("%s",LSTR(LocalDef.UKeyConfig.CardUsedInChatText1)), "d1ba8e", 0, nil)
    local GetRitchText1 = RichTextUtil.GetText(string.format("%s",LSTR(LocalDef.UKeyConfig.CardUsedInChatText2)), "d1ba8e", 0, nil)
	local SuccStr = string.format("%s%s%s", GetRitchText, GoodsDesc, GetRitchText1)
    return SuccStr
end

---@type 检查幻卡模块是否解锁
function MagicCardMgr.CheckMagicCardOpenState(CardResID)
    local Cfg = ItemCfg:FindCfgByKey(CardResID)
	if Cfg == nil then
		return false
	end

	if (Cfg.ItemType ~= ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD or Cfg.UseFunc ~= 74) then
        return false
	end

    local _isModuelOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDFantasyCard)
    return _isModuelOpen
end

return MagicCardMgr
