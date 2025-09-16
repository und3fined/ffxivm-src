---
--- Author: Alex, Leo
--- DateTime: 2023-10-08 10:53:13
--- Description: 金蝶小游戏
---
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local EffectUtil = require("Utils/EffectUtil")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local EobjCfg = require("TableCfg/EobjCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreType = ProtoRes.SCORE_TYPE
-- local MiniGameCuffDefine = require("Game/GoldSaucerMiniGame/Cuff/MiniGameCuffDefine")
local MiniGameCuffAudioDefine = require("Game/GoldSaucerMiniGame/Cuff/MiniGameCuffAudioDefine")
local AudioUtil = require("Utils/AudioUtil")
local CrystalTowerAudioDefine = require("Game/GoldSaucerMiniGame/CrystalTower/CrystalTowerAudioDefine")
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_ALONE_TREE_CMD
local SUB_MSG_ID_MooglePaw = ProtoCS.CatchBallCmd
local BASKET_SUB_MSG_ID = ProtoCS.CSMonsterBasketballCmd
local CRTSTAL_TOWER_SUB_MSG_ID = ProtoCS.CrystalTowerCmd
local EventID = require("Define/EventID")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local AudioPath = GoldSaucerMiniGameDefine.AudioPath
local UIViewID = require("Define/UIViewID")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local BallOriginVec = GoldSaucerMiniGameDefine.BallOriginVec
local MiniGameFactory = require("Game/GoldSaucerMiniGame/MiniGameFactory")
local MiniGameVM = require("Game/GoldSaucerMiniGame/MiniGameVM")
local ActorUtil = require("Utils/ActorUtil")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EobjLinktoSgAssetCfg = require("TableCfg/EobjLinktoSgAssetCfg")

local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local SettleEmotionID = GoldSaucerMiniGameDefine.SettleEmotionID
local NormalAnimDelayChangeNumTime = GoldSaucerMiniGameDefine.NormalAnimDelayChangeNumTime
local CriticalAnimDelayChangeNumTime = GoldSaucerMiniGameDefine.CriticalAnimDelayChangeNumTime
local RaceType = ProtoCommon.race_type
local UAudioMgr
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local EventMgr = _G.EventMgr
local LSTR = _G.LSTR
local GameNetworkMgr
local ScoreMgr
local UIViewMgr
local EmotionMgr
local HUDMgr
local LootMgr
--local PWorldMgr
local ActorManager = _G.UE.UActorManager
local EActorType = _G.UE.EActorType

---@class GoldSaucerMiniGameMgr : MgrBase
local GoldSaucerMiniGameMgr = LuaClass(MgrBase)
function GoldSaucerMiniGameMgr:OnInit()
    self.JDMapID = 12060
    self.ChocoMapID = 12061
    self.JDResID = 1008204
end

function GoldSaucerMiniGameMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ALONE_TREE, SUB_MSG_ID.CS_ALONE_TREE_ENTER, self.OnNetMsgNotifyAloneTreeEnterRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ALONE_TREE, SUB_MSG_ID.CS_ALONE_TREE_SELECT_DIFFICULTY, self.OnNetMsgNotifyAloneTreeSelectDifficultyRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ALONE_TREE, SUB_MSG_ID.CS_ALONE_TREE_CUT, self.OnNetMsgNotifyAloneTreeCutRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ALONE_TREE, SUB_MSG_ID.CS_ALONE_TREE_DOUBLE_CHANCE, self.OnNetMsgNotifyAloneTreeDoubleChanceRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ALONE_TREE, SUB_MSG_ID.CS_ALONE_TREE_EXIT, self.OnNetMsgNotifyAloneTreeExitRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CATCH_BALL, SUB_MSG_ID_MooglePaw.CatchBallStart, self.OnNetMsgNotifyMooglePawStartRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CATCH_BALL, SUB_MSG_ID_MooglePaw.CatchBallCatch, self.OnNetMsgNotifyMooglePawCatchRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CATCH_BALL, SUB_MSG_ID_MooglePaw.CatchBallDouble, self.OnNetMsgNotifyMooglePawDoubleRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CATCH_BALL, SUB_MSG_ID_MooglePaw.CatchBallExit, self.OnNetMsgNotifyMooglePawExitRsp)

    --- 怪物投篮
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_BASKETBALL, BASKET_SUB_MSG_ID.CSMonsterBasketball_Enter, self.OnNetMsgNotifyMonsterTossEnterRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_BASKETBALL, BASKET_SUB_MSG_ID.CSMonsterBasketball_Throw, self.OnNetMsgNotifyMonsterTossThrowRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_BASKETBALL, BASKET_SUB_MSG_ID.CSMonsterBasketball_Finish, self.OnNetMsgNotifyMonsterTossFinsihRsq)
    -- 重击吉尔伽美山
    local CUFF_SUB_CMD = ProtoCS.CSGilgameshCmd
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GILGAMESH,  CUFF_SUB_CMD.CSGilgameshCmdENTER, self.OnNetMsgNotifyCuffEnterRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GILGAMESH,  CUFF_SUB_CMD.CSGilgameshCmdInteraction, self.OnNetMsgInteractionRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GILGAMESH,  CUFF_SUB_CMD.CSGilgameshCmdExit, self.OnNetMsgExitRsp)

    -- 强袭水晶塔
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CRYSTAL_TOWER,  CRTSTAL_TOWER_SUB_MSG_ID.CrystalTowerCmdEnter, self.OnNetMsgNotifyCTEnterRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CRYSTAL_TOWER,  CRTSTAL_TOWER_SUB_MSG_ID.CrystalTowerCmdInteraction, self.OnNetMsgCTInteractionRsp)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_CRYSTAL_TOWER,  CRTSTAL_TOWER_SUB_MSG_ID.CrystalTowerCmdExit, self.OnNetMsgCTExitRsp)
end

function GoldSaucerMiniGameMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.DetailMiniGameAutoSelectDifficulty, self.OnDetailMiniGameAutoSelectDifficulty)
    self:RegisterGameEvent(EventID.DetailMiniGameRestart, self.OnDetailMiniGameRestart)
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
    self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
    self:RegisterGameEvent(EventID.DetailMooglePawsEndMove, self.OnGameEventMooglePawsEndMove)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.UpdateScore, self.OnUpdateScoreValue)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnRoleLoginRsp)
    self:RegisterGameEvent(EventID.RoleLogoutRes, self.OnRoleLogoutRsp)
end

---OnBegin
function GoldSaucerMiniGameMgr:OnBegin()
    --可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）
    --其他Mgr、全局对象 建议在OnBegin函数里初始化
    self.ActorPlayerInVision = {}
    GameNetworkMgr = require("Network/GameNetworkMgr")
    ScoreMgr = require("Game/Score/ScoreMgr")
    UIViewMgr = require("UI/UIViewMgr")
    EmotionMgr = require("Game/Emotion/EmotionMgr")
    HUDMgr = require("Game/HUD/HUDMgr")
    UAudioMgr = _G.UE.UAudioMgr.Get()
    LootMgr = _G.LootMgr
    --PWorldMgr = require("Game/PWorld/PWorldMgr")

    self.CurInteractEntityID = nil
    self.CurMiniGameInst = nil --当前所属小游戏实例（单例）
    self.bRewar = false
    self.RestartLock = false -- 翻倍挑战事件锁
  
    self.bWaitForCatchResult = false -- 是否等待抓球记录
    self.bLoginOut = false -- 是否已处于准备登出状态(重连情况下，屏蔽可能在登出流程里销毁UI时发送默认翻倍逻辑)

    self.BlockForEnterMsg = false -- 是否阻断等待进入回包
end

function GoldSaucerMiniGameMgr:OnEnd()
    --和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
    self:ClearMiniGameData()
    self.ActorPlayerInVision = nil
    self.CurInteractEntityID = nil
    self.CurMiniGameInst = nil

    self.RestartLock = false
    self.bWaitForCatchResult = false
end

function GoldSaucerMiniGameMgr:OnShutdown()

end

function GoldSaucerMiniGameMgr:ClearMiniGameData()
    local GameInst = self.CurMiniGameInst
    self:RemoveMiniGameAfterGameEnd()
    self.CurMiniGameInst = nil
end

--- 获取当前所处于的小游戏实例（按小游戏规则保证同时间仅有一个游戏实例）
function GoldSaucerMiniGameMgr:GetTheCurMiniGameInst()
    return self.CurMiniGameInst
end

--- 重连部分 ---

--- 封装小游戏的重连逻辑
---@param CurMiniGameInst MiniGameBase@小游戏实例
function GoldSaucerMiniGameMgr:DealWithMiniGameReconnect(CurMiniGameInst)
    local GameType = CurMiniGameInst.MiniGameType
    
    -- 在游戏循环阶段之前
    local GameState = CurMiniGameInst:GetGameState()
    if not GameState or GameState < MiniGameStageType.Update then
        --self:QuitMiniGame(GameType)
        local DelayShowTipsTime = 2
        self:RegisterTimer(function()
            MsgTipsUtil.ShowActiveTips(LSTR(250010)) -- 进程异常请稍后再试
        end, DelayShowTipsTime)
    end

    -- 在游戏循环阶段之后
    if GameState >= MiniGameStageType.End and GameState ~= MiniGameStageType.Restart then
        if CurMiniGameInst:NeedGameRewardAfterReconnect() then
            if GameType == MiniGameType.OutOnALimb
            or GameType == MiniGameType.TheFinerMiner then
                self:SendMsgAloneTreeDoubleChanceReq(GameType, false)
            elseif GameType == MiniGameType.MooglesPaw then
                self:SendMsgMooglePawDoubleReq(false)
            end
        end
        --self:QuitMiniGame(GameType)
        local DelayShowTipsTime = 2
        self:RegisterTimer(function()
            MsgTipsUtil.ShowActiveTips(LSTR(250010)) -- 进程异常请稍后再试
        end, DelayShowTipsTime)
    end
    self:QuitMiniGame(GameType)
    self.bWaitForCatchResult = false
    self.RestartLock = false
end

function GoldSaucerMiniGameMgr:OnPWorldMapEnter(_)

end

function GoldSaucerMiniGameMgr:OnGameEventLoginRes(Params)
    if Params.bReconnect then
        -- 处理重连逻辑
        local CurMiniGameInst = self:GetTheCurMiniGameInst()
        if CurMiniGameInst == nil then
            return
        end
  
        local GameType = CurMiniGameInst.MiniGameType
        if not GameType then
            return
        end

        if GameType == MiniGameType.OutOnALimb or GameType == MiniGameType.MooglesPaw
        or GameType == MiniGameType.TheFinerMiner then
            self:DealWithMiniGameReconnect(CurMiniGameInst)
        else
            -- 重置
            if CurMiniGameInst ~= nil then
                if GameType == MiniGameType.Cuff then -- 重击取消音效
                    local AudioName = MiniGameCuffAudioDefine.AudioName
                    CurMiniGameInst:PlaySoundWithPostEvent(AudioName.StopFistSwish)
                end
                self:QuitMiniGame(CurMiniGameInst:GetGameType(), false)
            end
            self:OnBegin()
            self:HideMiniGamePanel()
            FLOG_INFO("GoldSaucerMiniGameMgr:OnGameEventLoginRes(Params) self:OnBegin() bRelay = false")
        end
        self.BlockForEnterMsg = false -- 因为重连默认会清除游戏界面，退出游戏，故需要重置变量保证不阻塞
    end
end

function GoldSaucerMiniGameMgr:OnRoleLoginRsp(_)
    self.bLoginOut = false
end


function GoldSaucerMiniGameMgr:OnRoleLogoutRsp(_)
    self.bLoginOut = true
end

function GoldSaucerMiniGameMgr:OnGameEventMajorStartFadeIn(Params)
    local EntityID = Params.ULongParam1
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if not EntityID or EntityID ~= MajorEntityID then
        return
    end

    local CurMiniGameInst = self:GetTheCurMiniGameInst()
    if CurMiniGameInst == nil then
        return
    end

    CurMiniGameInst:SetTheSceneViewAfterReconnect()
    CurMiniGameInst:ReopenTheViewAfterReconnect()
    CurMiniGameInst:RecoverLoopLogicAfterReconnect()
end

--- 重连部分 end ---

function GoldSaucerMiniGameMgr:SetActorHUDNameHideInGame(EntityID, bHide)
	if not EntityID then
		return
	end

	local EobjVM = HUDMgr:GetActorVM(EntityID)
	if not EobjVM then
		return
	end

	EobjVM.NameVisible = not bHide
end

function GoldSaucerMiniGameMgr:OnGameEventVisionEnter(Params)
    local EntityID = Params.ULongParam1
    --直接使用ActorUtil.GetActorType可以避免将异步生成的对象立刻生成
    local ActorType = ActorUtil.GetActorType(EntityID)
    if ActorType == EActorType.Player then
        local ExistPlayer = self.ActorPlayerInVision[EntityID]
        if ExistPlayer == nil then
            if self:IsInGoldSaucerMiniGame() then
                self.ActorPlayerInVision[EntityID] = false
                ActorManager:Get():HideActor(EntityID, true)
                self:SetActorHUDNameHideInGame(EntityID, true)
            else
                self.ActorPlayerInVision[EntityID] = true
            end
        end
    end
end

function GoldSaucerMiniGameMgr:OnGameEventVisionLeave(Params)
    local EntityID = Params.ULongParam1
    --直接使用ActorUtil.GetActorType可以避免将异步生成的对象立刻生成
    local ActorType = Params.IntParam1
    if ActorType == EActorType.Player then
        local ExistPlayer = self.ActorPlayerInVision[EntityID]
        if ExistPlayer ~= nil then
            self.ActorPlayerInVision[EntityID] = nil
        end
    end
end

--- 进入游戏时屏蔽玩家
function GoldSaucerMiniGameMgr:HidePlayerEnter()
    local ActorPlayerInVision = self.ActorPlayerInVision
    if ActorPlayerInVision == nil or next(ActorPlayerInVision) == nil then
        return
    end
    for EntityID, bVisible in pairs(ActorPlayerInVision) do
        if bVisible then
            ActorManager:Get():HideActor(EntityID, true)
            self:SetActorHUDNameHideInGame(EntityID, true)
            ActorPlayerInVision[EntityID] = false
        end
    end
end

--- 离开游戏时显示玩家
function GoldSaucerMiniGameMgr:ShowPlayerLeave()
    local ActorPlayerInVision = self.ActorPlayerInVision
    if ActorPlayerInVision == nil or next(ActorPlayerInVision) == nil then
        return
    end
    for EntityID, bVisible in pairs(ActorPlayerInVision) do
        if not bVisible then
            ActorManager:Get():HideActor(EntityID, false)
            self:SetActorHUDNameHideInGame(EntityID, false)
            ActorPlayerInVision[EntityID] = true
        end
    end
end

--Msg Begin

--- 向服务器发送进入孤树无援
function GoldSaucerMiniGameMgr:SendMsgAloneTreeEnterReq(GameType)
    local MsgID = CS_CMD.CS_CMD_ALONE_TREE
    local SubMsgID = SUB_MSG_ID.CS_ALONE_TREE_ENTER

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ActivityType = GameType
    --MsgBody.EnterReq = {}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 服务器返回进入孤树无援
function GoldSaucerMiniGameMgr:OnNetMsgNotifyAloneTreeEnterRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        self:QuitMiniGame()
        return
    end

    local GameType = MsgBody.ActivityType
    self:OnMsgNotifyEnterTheMiniGame(GameType)
end

--- 向服务器发送选择难度
function GoldSaucerMiniGameMgr:SendMsgAloneTreeSelectDifficultyReq(GameType, Difficulty)
    local MsgID = CS_CMD.CS_CMD_ALONE_TREE
    local SubMsgID = SUB_MSG_ID.CS_ALONE_TREE_SELECT_DIFFICULTY

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ActivityType = GameType
    MsgBody.SelectDifficultyReq = {
        DifficultyLevel = Difficulty,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 服务器返回选择的难度
function GoldSaucerMiniGameMgr:OnNetMsgNotifyAloneTreeSelectDifficultyRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local GameType = MsgBody.ActivityType
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end
    local DifficultyRsp = MsgBody.SelectDifficultyRsp
    if DifficultyRsp == nil then
        return
    end
    local Difficulty = DifficultyRsp.DifficultyLevel
    local PerfectTimeRecord = DifficultyRsp.PerfectTimeRecord -- 单位：ms
    local ChallengeCountRecord = DifficultyRsp.ChallengeCountRecord

    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst then
        MiniGameInst:SelectDifficulty(Difficulty)
        MiniGameInst:SetPerfectTimeRecord(PerfectTimeRecord)
        MiniGameInst:SetChallengeCountRecord(ChallengeCountRecord)
    end
end

--- 向服务器发送砍树
function GoldSaucerMiniGameMgr:SendMsgAloneTreeCutReq(GameType, ClientResult)
    local MsgID = CS_CMD.CS_CMD_ALONE_TREE
    local SubMsgID = SUB_MSG_ID.CS_ALONE_TREE_CUT

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ActivityType = GameType
    MsgBody.EndCutReq = {
        AngelVal = math.floor(ClientResult),
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 服务器返回砍树结果
function GoldSaucerMiniGameMgr:OnNetMsgNotifyAloneTreeCutRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local GameType = MsgBody.ActivityType
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end
    local EndCutRsp = MsgBody.EndCutRsp
    if EndCutRsp == nil then
        return
    end

    local ProgressType = EndCutRsp.HandFeel
    local ActAngle = EndCutRsp.AngelVal
    local ProgressVal = EndCutRsp.ProgressVal
    FLOG_INFO("GoldSaucerMiniGameMgr:OnNetMsgNotifyAloneTreeCutRsp: angle is %s, ProgressVal: %s", tostring(ActAngle), tostring(ProgressVal))
    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst then
        MiniGameInst:ActionSettlement({ProgressLevel = ProgressType, ActAngle = ActAngle, ProgressVal = ProgressVal})
    end
end

--- 向服务器发送翻倍挑战
function GoldSaucerMiniGameMgr:SendMsgAloneTreeDoubleChanceReq(GameType, bRestart)
    if self.bLoginOut then
        return
    end

    local MsgID = CS_CMD.CS_CMD_ALONE_TREE
    local SubMsgID = SUB_MSG_ID.CS_ALONE_TREE_DOUBLE_CHANCE

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ActivityType = GameType
    MsgBody.DoubleChanceReq = {
        Continue = bRestart,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


--- 服务器返回翻倍挑战
function GoldSaucerMiniGameMgr:OnNetMsgNotifyAloneTreeDoubleChanceRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local GameType = MsgBody.ActivityType
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end

    local DoubleChanceRsp = MsgBody.DoubleChanceRsp
    if DoubleChanceRsp == nil then
        return
    end

    local GameInst = self.CurMiniGameInst
    if GameInst == nil then
        FLOG_ERROR("GoldSaucerMiniGameMgr:OnNetMsgNotifyAloneTreeDoubleChanceRsp the game is not exist")
        return
    end
    local bRestart = DoubleChanceRsp.Continue
    local bCritical = DoubleChanceRsp.VioletHit
    local RewardCount = DoubleChanceRsp.RewardCount
    if bRestart then
        GameInst:GameRestart() -- 翻倍重新开始
    else
        GameInst:SetRltCritical(bCritical) -- 设定是否结果翻倍
        GameInst:SetResultRewardSev(RewardCount)
        GameInst:GameReward()  -- 不翻倍结算

        local DelayTime = bCritical and CriticalAnimDelayChangeNumTime or NormalAnimDelayChangeNumTime
        self:RegisterTimer(function()
            _G.LootMgr:SetDealyState(false)
        end, DelayTime)
    end
    self.RestartLock = false
end

--- 向服务器发送退出游戏
function GoldSaucerMiniGameMgr:SendMsgAloneTreeExitReq(GameType)
    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst == nil then
        return
    end

    local PerfectChallengeTime = MiniGameInst:GetPerfectChallengeTime()
    local bForceEnd = MiniGameInst:GetIsForceEnd()

    local MsgID = CS_CMD.CS_CMD_ALONE_TREE
    local SubMsgID = SUB_MSG_ID.CS_ALONE_TREE_EXIT

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ActivityType = GameType
    MsgBody.TreeExitReq = {
        UseTime = math.floor(PerfectChallengeTime * 1000 + 0.5), -- 完美挑战&新纪录 2024.5.22
        NormalExit = not bForceEnd
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 服务器返回退出游戏
function GoldSaucerMiniGameMgr:OnNetMsgNotifyAloneTreeExitRsp(MsgBody)
    if MsgBody == nil then
        return
    end

    local GameType = MsgBody.ActivityType
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end

    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst == nil then
        return
    end

    if MiniGameInst:GetIsForceEnd() then
        --self:QuitMiniGame(GameType) -- 强制退出由调用处处理
        return
    end

    local AloneTreeExit = MsgBody.AloneTreeExit
    if AloneTreeExit ~= nil then
        local ObjCenterPos = AloneTreeExit.ObjCenterPos
        if ObjCenterPos == 0 then -- 成功奖励已在翻倍挑战结算，走此协议退出游戏
             -- 挑战成功展示界面
            local ViewModel = MiniGameVM:GetDetailMiniGameVM(GameType)
		    UIViewMgr:ShowView(MiniGameInst.SettlementViewID, ViewModel)
            --self:QuitMiniGame(GameType, false, self.bRewar)
        else -- 失败没有奖励，走此协议失败结算
            MiniGameInst:SetFailReasonPos(ObjCenterPos)
            MiniGameInst:GameFailInfoShow()
        end
    end
end

--- 向服务器发送退出游戏
function GoldSaucerMiniGameMgr:SendMsgAloneTreeExitReward(GameType)
    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst == nil then
        return
    end

    local MsgID = CS_CMD.CS_CMD_ALONE_TREE
    local SubMsgID = SUB_MSG_ID.CS_ALONE_TREE_EXIT_REWARD

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ActivityType = GameType
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


------------------------------------------------------重击吉尔加美什-------------------------------------------------------------
--- 向服务器发送进入重击吉尔加美什
function GoldSaucerMiniGameMgr:SendMsgCuffEnterReq(CurSgInstanceID)
    local MsgID = CS_CMD.CS_CMD_GILGAMESH
    local SubMsgID = ProtoCS.CSGilgameshCmd.CSGilgameshCmdENTER
    -- local GoldCoinGameType = ProtoCS.GoldCoinGameType

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.IsBlessed = _G.GoldSaucerBlessingMgr:GetSgIsInBlessing(CurSgInstanceID)
    -- MsgBody.GameType = GoldCoinGameType.GoldCoinGameTypeAttackGilgamesh
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 进入重击吉尔加美什Rsq
function GoldSaucerMiniGameMgr:OnNetMsgNotifyCuffEnterRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        self:QuitMiniGame()
        return
    end

    local GameType = MiniGameType.Cuff
    local Anim = MiniGameClientConfig[GameType].Anim

    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end
    local EnterRsp = MsgBody.EnterRsp
    if EnterRsp == nil then
        FLOG_ERROR("EnterRsp is nil")
        return
    end
    local ViewModel = MiniGameVM:GetDetailMiniGameVM(GameType)

    local MiniGameInst = self:GetTheCurMiniGameInst()
    if MiniGameInst == nil then
        self:HidePlayerEnter()
        self:CreateMiniGameAfterInteract(GameType)
        MiniGameInst = self.CurMiniGameInst
    end
    MiniGameInst:SetPanelNormalVisible(true)
    self.ApertureList = EnterRsp.ApertureList
    MiniGameInst:InitNextRoundCfgs(EnterRsp.RoundID, EnterRsp.ApertureList)
    MiniGameInst:SetTextHint(LSTR(250011), true) -- 点击光圈聚集力量
    MiniGameInst:SetbShowMoneySlot(false)

    if not MiniGameInst.IsFightAgain then
        MiniGameInst:GameEnter()
    else
        MiniGameInst:ResetDynAssetState()
        if ViewModel ~= nil then
            ViewModel:SetbTextHintVisible()
        end
    end
    self.BlockForEnterMsg = false
end

--- 请求交互
function GoldSaucerMiniGameMgr:SendMsgCuffInteractionReq()
    local GameType = MiniGameType.Cuff
    local MiniGameInst = self:GetTheCurMiniGameInst()
    self.UnusualTimer = self:RegisterTimer(function()
        if MiniGameInst ~= nil then
            MiniGameInst:StopWindEffect()
        end
        MiniGameInst:SetIsForceEnd(true)
        self:SendMsgCuffExistReq(false)
		self:QuitMiniGame(MiniGameType.Cuff, false)
        MsgTipsUtil.ShowActiveTips(LSTR(250010)) -- 进程异常请稍后再试
    end, 5)
    local MsgID = CS_CMD.CS_CMD_GILGAMESH
    local SubMsgID = ProtoCS.CSGilgameshCmd.CSGilgameshCmdInteraction
    if MiniGameInst == nil then
        return
    end
    local PowerValue = MiniGameInst:GetStrengthValue()
    local RwardNum = MiniGameInst:GetInteractRewarNum()
    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.InteractionReq = {
        PowerValue = PowerValue,
        ExtraReward = RwardNum
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 交互回包
function GoldSaucerMiniGameMgr:OnNetMsgInteractionRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    if self.UnusualTimer ~= nil then
        self:UnRegisterTimer(self.UnusualTimer)
    end
    local GameType = MiniGameType.Cuff
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end
    local InteractionRsp = MsgBody.InteractionRsp
    if InteractionRsp == nil then
        return
    end
    local MiniGameInst = self:GetTheCurMiniGameInst()
    if MiniGameInst == nil then
        FLOG_ERROR("MiniGameInst == nil GameType = Cuff")
        return
    end
    self.ApertureList = InteractionRsp.ApertureList
    if self:CheckShouldPunchOut(GameType, MiniGameInst, InteractionRsp.ApertureList) then
        return
    end
    MiniGameInst:InitNextRoundCfgs(InteractionRsp.RoundID, InteractionRsp.ApertureList)
    self:UpdateMiniGameVM(GameType)
    if InteractionRsp.RoundID % 1000 == MiniGameInst:GetMaxRound() then --- 最后一轮
        EventMgr:SendEvent(EventID.MiniGameCuffSubViewOnShow, true)
    end
end

--- @type 检查是否需要出拳
function GoldSaucerMiniGameMgr:CheckShouldPunchOut(GameType, MiniGameInst, ApertureList)
    if #ApertureList < 1 then
        local DelayTime = GoldSaucerMiniGameDefine.DelayTime
        local Power = MiniGameInst:GetStrengthValue()
        local ActionPath = self:GetActionPathByRaceID()
        if Power > 0 and MiniGameInst then
            MiniGameInst:StopWindEffect()
            MiniGameInst:StopFireEffect()
            local AudioName = MiniGameCuffAudioDefine.AudioName
            local RTPCName = MiniGameCuffAudioDefine.RTPCName
            MiniGameInst:IsPlayPunchAct(true)
            MiniGameInst:PlaySoundWithPostEvent(AudioName.StopFistSwish) --, RTPCName.SpeedPitch, 0
            self:RegisterTimer(function() MiniGameInst:PlayActionTimeLineByPath(ActionPath) end, 0.15)
            local Anim = MiniGameClientConfig[MiniGameType.Cuff].Anim
            local ResultPower = MiniGameClientConfig[MiniGameType.Cuff].ResultPower
            local RewardCfg = MiniGameInst:GetRewardCfg()
            if Power >= RewardCfg[ResultPower.Profect].Score then
                EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimBlowHigh)
            elseif Power >= RewardCfg[ResultPower.Good].Score then
                EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimBlowDown)
            end
            self:RegisterTimer(self.PunchCallBack, DelayTime.PunchTime, 0, 1, MiniGameInst)
            self.PlayAnimTimeLine(self, MiniGameInst)
        end
        self:RegisterTimer(function()
            self:SendMsgCuffExistReq(true)
            MiniGameInst:SetTextHint(LSTR(250012), false) -- 点击光圈出拳
            MiniGameInst:StopMajorSlotAnimation(GoldSaucerMiniGameDefine.DefaultSlot)
        end, 1, 0, 1, MiniGameInst)
        MiniGameInst:ClearInteractionCfg()
        self:UpdateMiniGameVM(GameType)
        return true
    elseif #ApertureList == 1 then
        MiniGameInst:SetTextHint(LSTR(250012), true) -- 点击光圈出拳
    end
    return false
end

--- @type 播放动态序列
function GoldSaucerMiniGameMgr.PlayAnimTimeLine(self, MiniGameInst)
    -- self:ResetDynaTimeLine()
    local Power = MiniGameInst:GetStrengthValue()
    local InstanceID = MiniGameInst:GetInstanceID()
    local ResultPower = MiniGameClientConfig[MiniGameInst.MiniGameType].ResultPower
    local TimeLineID = MiniGameClientConfig[MiniGameInst.MiniGameType].TimeLineID
    local RewardCfg = MiniGameInst:GetRewardCfg()
    local NeedTimeLineID
    if Power >= RewardCfg[ResultPower.Profect].Score then
        NeedTimeLineID = TimeLineID.Suc
    elseif Power >= RewardCfg[ResultPower.Nice].Score then
        NeedTimeLineID = TimeLineID.Suc2
    elseif Power >= RewardCfg[ResultPower.Good].Score then
        NeedTimeLineID = TimeLineID.SucMin
    else
        if MiniGameInst.MiniGameType ==  MiniGameType.Cuff then
            if Power > 0 then
                NeedTimeLineID = TimeLineID.SucMin
            else
                NeedTimeLineID = TimeLineID.Fail
            end
        else
            NeedTimeLineID = TimeLineID.Fail
        end
    end
    if NeedTimeLineID ~= nil then
        PWorldMgr:PlaySharedGroupTimeline(InstanceID, NeedTimeLineID)
        _G.FLOG_WARNING("PlaySharedGroupTimeline InstanceID:"..tostring(InstanceID).."TimelineID"..tostring(NeedTimeLineID))
    end
end

--- @type 播放动态序列
function GoldSaucerMiniGameMgr:ResetDynaTimeLine()
    local MiniGameInst = self.CurMiniGameInst
    local InstanceID = MiniGameInst:GetInstanceID()
    PWorldMgr:PlaySharedGroupTimeline(InstanceID, 0)
end

--- @type 当出拳时
function GoldSaucerMiniGameMgr.PunchCallBack(self, MiniGameInst)
    local Power = MiniGameInst:GetStrengthValue()
    EventMgr:SendEvent(EventID.MiniGameCuffShowPunchResult, Power)
end

--- @type 发送请求结束协议
function GoldSaucerMiniGameMgr:SendMsgCuffExistReq(bNormal)
    local MsgID = CS_CMD.CS_CMD_GILGAMESH
    local SubMsgID = ProtoCS.CSGilgameshCmd.CSGilgameshCmdExit
    local GameType = MiniGameType.Cuff
    local MiniGameInst = self:GetTheCurMiniGameInst()
    if MiniGameInst == nil then
        return
    end
    local ContinueCount = MiniGameInst:GetMaxComboNum()
    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ExitReq = {
        Normal = bNormal,
        ContinueCount = ContinueCount,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 请求协议回报
function GoldSaucerMiniGameMgr:OnNetMsgExitRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    local GameType = MiniGameType.Cuff
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end
    local MiniGameInst = self:GetTheCurMiniGameInst()
    if MiniGameInst == nil or GameType == nil then
        return
    end
    local Anim = MiniGameClientConfig[GameType].Anim
    local ExitRsp = MsgBody.ExitRsp
    local bNotNormal = MiniGameInst:GetIsForceEnd() --ExitRsp == nil  -- 非正常退出，包括强制退出（服务器并未进行此判断，需改为客户端本地处理）
    if bNotNormal then
        return
    end
    local Power = MiniGameInst:GetStrengthValue()
    local bSuccess = false
    local bTimeOut = MiniGameInst:IsTimeOut() and (not MiniGameInst:GetPlayerActed())
    local EndState, ResultAnim, bCriticalHit
    local RewardCfg = MiniGameInst:GetRewardCfg()
    if RewardCfg == nil then
        return
    end
    
    if bTimeOut then
        ResultAnim = Anim.AnimTimesup
        EndState = MiniGameRoundEndState.FailTime
    elseif Power < RewardCfg[1].Score and not bNotNormal then
        EndState = MiniGameRoundEndState.FailChance -- 失败
        ResultAnim = Anim.AnimFail
        FLOG_INFO("ResultAnim  is Fail")
    else
        bCriticalHit = ExitRsp.CriticalHit
        MiniGameInst:ConstructData(ExitRsp.Power, ExitRsp.AttractCount)
        MiniGameInst:CuffSetCritical(bCriticalHit)
        MiniGameInst:SetRewardGot(ExitRsp.RewardCount)
        bSuccess = true
        EndState = MiniGameRoundEndState.Success
        ResultAnim = Anim.AnimSuccess
        FLOG_INFO("ResultAnim  is Success, Success Need Strength %s, CurStrength is %s", RewardCfg[1].Score, Power)
    end
 
    MiniGameInst.RoundEndState = EndState
    MiniGameInst:ChangeGameStateToEnd()
    MiniGameInst:SetPanelNormalVisible(false)
    MiniGameInst:SetEndState()
    MiniGameInst:SetBtnContentAndJDCoinColor()
    MiniGameInst:SetSuccessOrFail(bSuccess, bTimeOut)
    MiniGameInst:SetbShowMoneySlot(true)
    MiniGameInst:PlaySoundWithPostEvent(MiniGameCuffAudioDefine.AudioName.StopFistSwish)
    self:UpdateMiniGameVM(GameType)
    EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimSettlementIn)
    EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, ResultAnim)
    local EndEmotionID = MiniGameInst:GetEndEmotionID()
    self:PlayEmotionActInSettlementStage(MiniGameType.Cuff, bSuccess, EndEmotionID)
    self:CuffGetReward(bCriticalHit)
end

function GoldSaucerMiniGameMgr:CuffGetReward(bCriticalHit)
    _G.LootMgr:SetDealyState(true)
    local DelayTime = 1
    if bCriticalHit then
        DelayTime = DelayTime * 2.5
    end
    self:RegisterTimer(function() _G.LootMgr:SetDealyState(false)end, DelayTime)
end

--- @type 再战按钮点击
function GoldSaucerMiniGameMgr:OnBtnFightAgainClick(GameType)
    -- local GameType = MiniGameType.Cuff
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end
    local MiniGameInst = self:GetTheCurMiniGameInst()
    if not MiniGameInst then
        return
    end
    MiniGameInst:Reset()
    _G.EmotionMgr:StopAllEmotions(MajorUtil.GetMajorEntityID(), false)
    local Anim = MiniGameClientConfig[GameType].Anim

    local SgDynaInstanceID = MiniGameInst:GetInstanceID()
    if GameType == MiniGameType.Cuff then
        -- self:UpdateMiniGameVM(GameType)
        MiniGameInst:SetFightAgain(true)
        self:SendMsgCuffEnterReq(SgDynaInstanceID)
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimNormalIn)
    elseif GameType == MiniGameType.MonsterToss then
        self:SendMsgBaskMonsterEnterReq(SgDynaInstanceID)
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimIn)
    elseif GameType == MiniGameType.CrystalTower then
        self:SendMsgCrystalTowerEnterReq(SgDynaInstanceID)
    elseif GameType == MiniGameType.MooglesPaw then
        self:SendMsgMooglePawStartReq(SgDynaInstanceID)
    elseif GameType == MiniGameType.OutOnALimb or GameType == MiniGameType.TheFinerMiner then
        self:SendMsgAloneTreeEnterReq(GameType)
    end
end

---------------------------------------------------------End-------------------------------------------------------------
----- 莫古抓球机协议
--- 莫古抓球机开始协议
function GoldSaucerMiniGameMgr:SendMsgMooglePawStartReq(CurSgInstanceID)
    local MsgID = CS_CMD.CS_CMD_CATCH_BALL
    local SubMsgID = SUB_MSG_ID_MooglePaw.CatchBallStart

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GoldSaucerMiniGameMgr:OnNetMsgNotifyMooglePawStartRsp(MsgBody)
    if not MsgBody then
        return
    end

    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        self:QuitMiniGame()
        return
    end

    local StartRsp = MsgBody.StartRsp
    if not StartRsp then
        return
    end

    self:OnMsgNotifyEnterTheMiniGame(MiniGameType.MooglesPaw, StartRsp)
    local PerfectTimeRecord = StartRsp.PerfectTimeRecord -- 单位：ms
    local ChallengeCountRecord = StartRsp.ChallengeCountRecord

    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst then
        MiniGameInst:SetPerfectTimeRecord(PerfectTimeRecord)
        MiniGameInst:SetChallengeCountRecord(ChallengeCountRecord)
    end
end

--- 莫古抓球机抓取协议
---@param PosX number@莫古力的X轴坐标
---@param PosY number@莫古力的Y轴坐标
function GoldSaucerMiniGameMgr:SendMsgMooglePawCatchReq(PosX, PosY)
    local MsgID = CS_CMD.CS_CMD_CATCH_BALL
    local SubMsgID = SUB_MSG_ID_MooglePaw.CatchBallCatch

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.CatchReq = {
        PosX = PosX,
        PosY = PosY,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end
function GoldSaucerMiniGameMgr:OnNetMsgNotifyMooglePawCatchRsp(MsgBody)
    if not MsgBody then
        return
    end
    local CatchRsp = MsgBody.CatchRsp
    if not CatchRsp then
        return
    end

    local CaughtBall = CatchRsp.BallID
    if CaughtBall == nil then
        FLOG_ERROR("GoldSaucerMiniGameMgr:OnNetMsgNotifyMooglePawCatchRsp: CaughtBall is nil")
        return
    end

    local MooglesPawInst = self.CurMiniGameInst
    if not MooglesPawInst then
        return
    end
    MooglesPawInst:CatchTheBall(CaughtBall)
    self.bWaitForCatchResult = false
end

--- 莫古抓球机翻倍协议
---@param bDouble boolean@是否翻倍
function GoldSaucerMiniGameMgr:SendMsgMooglePawDoubleReq(bDouble)
    if self.bLoginOut then
        return
    end

    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst == nil then
        return
    end
    local PerfectChallengeTime = MiniGameInst:GetPerfectChallengeTime()
    FLOG_INFO("MiniGameBase:GetPerfectChallengeTime %s", PerfectChallengeTime)
    local MsgID = CS_CMD.CS_CMD_CATCH_BALL
    local SubMsgID = SUB_MSG_ID_MooglePaw.CatchBallDouble

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.DoubleReq = {
        Double = bDouble,
        UseTime = math.floor(PerfectChallengeTime * 1000 + 0.5)-- 完美挑战&新纪录 2024.5.22
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GoldSaucerMiniGameMgr:OnNetMsgNotifyMooglePawDoubleRsp(MsgBody)
    if not MsgBody then
        return
    end
    local DoubleRsp = MsgBody.DoubleRsp
    if not DoubleRsp then
        return
    end

    local MooglesPawInst = self.CurMiniGameInst
    if not MooglesPawInst then
        return
    end

    local BallList = DoubleRsp.BallList
    local bCritical = DoubleRsp.VioletHit
    local RewardCount = DoubleRsp.RewardCount
    if not BallList or not next(BallList) then
        MooglesPawInst:OnSyncParamsByGameState(MiniGameStageType.Reward, DoubleRsp)
        MooglesPawInst:SetRltCritical(bCritical) -- 设定是否结果翻倍
        MooglesPawInst:SetResultRewardSev(RewardCount)
        MooglesPawInst:GameReward() --不翻倍

        local DelayTime = bCritical and CriticalAnimDelayChangeNumTime or NormalAnimDelayChangeNumTime
        self:RegisterTimer(function()
            _G.LootMgr:SetDealyState(false)
        end, DelayTime)
    else
        MooglesPawInst:OnSyncParamsByGameState(MiniGameStageType.Restart, DoubleRsp)
        MooglesPawInst:GameRestart() --翻倍
    end
    self.RestartLock = false
end

--- 莫古力抓球机退出协议
function GoldSaucerMiniGameMgr:SendMsgMooglePawExitReq()
    local MsgID = CS_CMD.CS_CMD_CATCH_BALL
    local SubMsgID = SUB_MSG_ID_MooglePaw.CatchBallExit

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


function GoldSaucerMiniGameMgr:OnNetMsgNotifyMooglePawExitRsp(MsgBody)
    if not MsgBody then
        return
    end
    local MiniGameInst = self.CurMiniGameInst
    if not MiniGameInst then
       return
    end

    --- 强行退出从此处退出游戏
    local bIsForceEnd = MiniGameInst:GetIsForceEnd()
    if bIsForceEnd then
        self:QuitMiniGame(MiniGameType.MooglesPaw)
    end
end

--- 莫古力结算奖励飘窗申请协议
function GoldSaucerMiniGameMgr:SendMsgMooglePawExitRewardReq()
    local MsgID = CS_CMD.CS_CMD_CATCH_BALL
    local SubMsgID = SUB_MSG_ID_MooglePaw.CatchBallExitReward

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


-------------------------------------------------------------------怪物投篮-----------------------------------------------------------
--- 怪物投篮进入游戏请求
function GoldSaucerMiniGameMgr:SendMsgBaskMonsterEnterReq(CurSgInstanceID)
    local MsgID = CS_CMD.CS_CMD_BASKETBALL
    local SubMsgID = BASKET_SUB_MSG_ID.CSMonsterBasketball_Enter

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.IsBlessed = _G.GoldSaucerBlessingMgr:GetSgIsInBlessing(CurSgInstanceID)
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    -- self:OnNetMsgNotifyMonsterTossEnterRsp()
end

--- 成功进入游戏回包
function GoldSaucerMiniGameMgr:OnNetMsgNotifyMonsterTossEnterRsp(MsgBody)
    if not MsgBody then
        return
    end

    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        self:QuitMiniGame()
        return
    end
    local EnterRsp = MsgBody.EnterRsp
    local DifficultyLevel = EnterRsp.DifficultyLevel
    local InitBall = EnterRsp.InitBall
    if #InitBall == 3 then --- 临时代码
        table.insert(InitBall, 1)
    end
    local MaxScore = EnterRsp.MaxScore

    local GameType = 3
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end

    local MiniGameInst = self.CurMiniGameInst

    if MiniGameInst == nil then
        self:HidePlayerEnter()
        MiniGameInst = self:CreateMiniGameAfterInteract(GameType)
    end
    local Params = {MaxScore = MaxScore, DifficultyLevel = DifficultyLevel}
    MiniGameInst:InitMiniGame(Params)
    MiniGameInst:InitAllBallData(InitBall)
    MiniGameInst:PlayExplodeVfx(true)

    MiniGameInst:GameEnter()

    if MiniGameInst:GetIsFightAgain() then
        local Anim = MiniGameClientConfig[GameType].Anim
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimIn)
    end
    self.BlockForEnterMsg = false
    -- self.BeginTime = TimeUtil.GetServerTimeMS()  -- 记录开始的时间
end

--- 怪物投篮玩家投篮请求
function GoldSaucerMiniGameMgr:SendMsgBaskMonsterShootReq(bSuccessHit, bTimeOut)
    self.UnusualTimer = self:RegisterTimer(function()
        GoldSaucerMiniGameMgr:SendMsgBaskMonsterFinishReq(false)
		GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.MonsterToss, false)
        MsgTipsUtil.ShowActiveTips(LSTR(250010)) -- 进程异常请稍后再试
    end, 5)

    local MsgID = CS_CMD.CS_CMD_BASKETBALL
    local SubMsgID = BASKET_SUB_MSG_ID.CSMonsterBasketball_Throw
    local MiniGameInst = self:GetTheCurMiniGameInst()
    if not MiniGameInst then
        return
    end
    local TimeLimit = MiniGameInst:GetRestartTime()
    local ThrowTime = math.ceil((TimeLimit - MiniGameInst.RemainSeconds) * 1000)
    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ThrowBallReq = {
        ThrowTime = ThrowTime,
        Hit = bSuccessHit,
        TimeOut = bTimeOut
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 投篮返回请求
function GoldSaucerMiniGameMgr:OnNetMsgNotifyMonsterTossThrowRsp(MsgBody)
    if self.UnusualTimer ~= nil then
        self:UnRegisterTimer(self.UnusualTimer)
    end
    local ThrowBallRsp = MsgBody.ThrowBallRsp
    if ThrowBallRsp == nil then
        return
    end
    local CurScore = ThrowBallRsp.CurScore
    local NewBallType = ThrowBallRsp.NewBallType
    local GameType = MiniGameType.MonsterToss
    local MiniGameInst = self.CurMiniGameInst
    local Anim = MiniGameClientConfig[MiniGameType.MonsterToss].Anim
    if MiniGameInst then
        local LastScore = MiniGameInst:GetCurScore()
        if CurScore > LastScore then -- 服务器验证是否投中
            MiniGameInst:AddComboNum()
            MiniGameInst:AddHitCount()
            local ComboNum = MiniGameInst:GetComboNum()
            MiniGameInst:ConstructShootResultData(ComboNum, true)
        else
            MiniGameInst:ResetComboNum()
            MiniGameInst:ConstructShootResultData(0, false)
        end
        MiniGameInst:UpdateCurScoreAndGotReward(CurScore)
    end
    -- EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimResume)
    self:RegisterTimer(function()
        if MiniGameInst then
            local MaxScore = MiniGameInst:GetMaxScore()
            if CurScore > MaxScore then
                EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimRefreshHighestScore)
                MiniGameInst:SetMaxScore(CurScore)
            end
            MiniGameInst:UpdateAllBallData(NewBallType)
        end

        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimNextBall)
        MiniGameVM:UpdateDetailMiniGameVM(GameType)
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimProgressBar)
    end, 1)
end

--- 怪物投篮游戏结束请求
function GoldSaucerMiniGameMgr:SendMsgBaskMonsterFinishReq(bNormalExit)
    local MsgID = CS_CMD.CS_CMD_BASKETBALL
    local SubMsgID = BASKET_SUB_MSG_ID.CSMonsterBasketball_Finish

    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.FinishReq = {
        NormalExit = bNormalExit,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 怪物投篮游戏结束回包
function GoldSaucerMiniGameMgr:OnNetMsgNotifyMonsterTossFinsihRsq(MsgBody)
    if MsgBody == nil or MsgBody.FinishRsp == nil then
        return
    end
    local FinishRsp = MsgBody.FinishRsp
    local CurScore = FinishRsp.CurScore  -- 服务器给的值 不破记录就是0
    local HitCount = FinishRsp.HitCount
    local bCriticalHit = FinishRsp.CriticalHit
    local Anim = MiniGameClientConfig[MiniGameType.MonsterToss].Anim
    local GameType = 3
    local ResultAnim
    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst then
        local bSuccess = MiniGameInst:GetCurScore() >= MiniGameInst.RewardData[1].Score
        if CurScore ~= 0 then
            MiniGameInst:UpdateCurScoreAndGotReward(CurScore)
            -- EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.Critical)
        end
        if bCriticalHit and MiniGameInst:GetCurScore() ~= 0 then
            MiniGameInst:MonsterTossSetCritical(bCriticalHit)
        end
        MiniGameInst:ConstructAllResultData(CurScore, HitCount, FinishRsp.RewardCount)
        MiniGameInst:SetMoneySlotVisible(true)
        MiniGameInst:SetbResultQAndNormalVisible(true)
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimResult)
        if bSuccess then
            ResultAnim = Anim.AnimSuccess
        else
            ResultAnim = Anim.AnimTimesup
        end
        -- MiniGameInst:PlayerChangeColor(0.1, true)
        local EndEmotionID = MiniGameInst:GetEndEmotionID()
        self:PlayEmotionActInSettlementStage(MiniGameType.MonsterToss, bSuccess, EndEmotionID)
    end
    self:MonsterTossGetReward(bCriticalHit)
    MiniGameVM:UpdateDetailMiniGameVM(GameType)
    EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, ResultAnim, bCriticalHit)
    EventMgr:SendEvent(EventID.MonsterTossEndEvent)
end

function GoldSaucerMiniGameMgr:MonsterTossGetReward(bCriticalHit)
    _G.LootMgr:SetDealyState(true)
    local DelayTime = 2
    if bCriticalHit then
        DelayTime = DelayTime + 2.5
    end
    self:RegisterTimer(function() _G.LootMgr:SetDealyState(false) end, DelayTime)
end

---------------------------------------------- 强袭水晶塔 ---------------------------------------------------
function GoldSaucerMiniGameMgr:RegisterCTNetError()
    self.UnusualTimer = self:RegisterTimer(function()
        GoldSaucerMiniGameMgr:SendMsgCrystalTowerExistReq(false)
		GoldSaucerMiniGameMgr:QuitMiniGame(MiniGameType.CrystalTower, false)
        MsgTipsUtil.ShowActiveTips(LSTR(250010)) -- 进程异常请稍后再试
    end, 8)
end

--- 强袭水晶塔进入游戏请求
function GoldSaucerMiniGameMgr:SendMsgCrystalTowerEnterReq(CurSgInstanceID)
    self:RegisterCTNetError()
    local MsgID = CS_CMD.CS_CMD_CRYSTAL_TOWER
    local SubMsgID = CRTSTAL_TOWER_SUB_MSG_ID.CrystalTowerCmdEnter
    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.IsBlessed = _G.GoldSaucerBlessingMgr:GetSgIsInBlessing(CurSgInstanceID)
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 强袭水晶塔进入游戏返回
function GoldSaucerMiniGameMgr:OnNetMsgNotifyCTEnterRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    local ErrorCode = MsgBody.ErrorCode
    if ErrorCode then
        self:QuitMiniGame()
        return
    end

    local GameType = MiniGameType.CrystalTower
    local Anim = MiniGameClientConfig[GameType].Anim
    if self.UnusualTimer ~= nil then
        self:UnRegisterTimer(self.UnusualTimer)
    end
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end
    local EnterRsp = MsgBody.EnterRsp
    local MiniGameInst = self:GetTheCurMiniGameInst()
    if MiniGameInst == nil then
        self:HidePlayerEnter()
        self:CreateMiniGameAfterInteract(GameType)
        MiniGameInst = self.CurMiniGameInst
    end

    local DifficultyLv = EnterRsp.DifficultyLv

    MiniGameInst:SetTextHint(LSTR(260003)) -- 请在晶体下落至线时点击
    MiniGameInst:SetRoundIntervalTimeAndRoundData(DifficultyLv)
    MiniGameInst:GameEnter()
    MiniGameInst:CreateInteractionProvider()
    local Items = EnterRsp.Items
    MiniGameInst:InitNextRoundCfgs(Items)
    -- EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimTipsIn, true)
    MiniGameInst:UpdateHammerVfx(true)
    MiniGameInst:SetbShowMoneySlot(false)

    local ViewModel = MiniGameVM:GetDetailMiniGameVM(GameType)
    ViewModel:InitVM()
    ViewModel:SetbInEndRound(false)

    local ResultListData = MiniGameInst:ConstructInteractResultListData()
    ViewModel:UpdateResultVMList(ResultListData)

    self.BlockForEnterMsg = false
end

function GoldSaucerMiniGameMgr:SendMsgCrystalTowerInteractionReq()
    self:RegisterCTNetError()
    local MsgID = CS_CMD.CS_CMD_CRYSTAL_TOWER
    local SubMsgID = CRTSTAL_TOWER_SUB_MSG_ID.CrystalTowerCmdInteraction
    local GameType = MiniGameType.CrystalTower
    local MiniGameInst = self:GetTheCurMiniGameInst()
    local CurRewardGot = MiniGameInst:GetInteractRewarNum()
    local PowerValue = MiniGameInst:GetStrengthValue()
    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.InteractionReq = {
        PowerValue = PowerValue,
        ExtraReward = CurRewardGot,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 交互回包
function GoldSaucerMiniGameMgr:OnNetMsgCTInteractionRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    if self.UnusualTimer ~= nil then
        self:UnRegisterTimer(self.UnusualTimer)
    end
    local GameType = MiniGameType.CrystalTower
    local Anim = MiniGameClientConfig[GameType].Anim

    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end
    local InteractionRsp = MsgBody.InteractionRsp
    local MiniGameInst = self:GetTheCurMiniGameInst()
    if MiniGameInst == nil or InteractionRsp == nil then
        FLOG_ERROR("OnNetMsgCTInteractionRsp MiniGameInst is null")
        return
    end
    local Items = InteractionRsp.Items
    MiniGameInst:InitNextRoundCfgs(Items)
    MiniGameInst:OnBeginFalling()
    local CurRoundIndex = MiniGameInst:GetCurRoundIndex()
    local MaxRound = MiniGameInst.DefineCfg.MaxRound
    if CurRoundIndex > MaxRound then
        MiniGameInst.bImgMask2Visible = true
        self:CheckShouldSmash(GameType, MiniGameInst)
    elseif CurRoundIndex == MaxRound then
        local ViewModel = MiniGameVM:GetDetailMiniGameVM(GameType)
        ViewModel:SetbInEndRound(true)
        MiniGameInst:SetTextHint(LSTR(260004)) -- 看准时间, 最后一击
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimTipsIn, true)
    end
    self:UpdateMiniGameVM(GameType)

end

--- @type 检查是否需要用锤子砸水晶塔
function GoldSaucerMiniGameMgr:CheckShouldSmash(GameType, MiniGameInst)
    if MiniGameInst:GetStrengthValue() > 0 then
        local ActionPath = self:GetActionPathByRaceID()
        MiniGameInst:PlayActionTimeLineByPath(ActionPath)
        FLOG_INFO("Function CheckShouldSmash() MiniGameInst:PlayActionTimeLineByPath(ActionPath)")

        local function PlayHammerSmashAction()
            self.PlayAnimTimeLine(self, MiniGameInst)
            AudioUtil.LoadAndPlay2DSound(CrystalTowerAudioDefine.AudioPath.SmashAction)
        end
        self:RegisterTimer(PlayHammerSmashAction, 0.1, 0, 1, MiniGameInst)
    end

    local Anim = MiniGameClientConfig[GameType].Anim
    EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimTipsIn, false)

    local DelayTime = GoldSaucerMiniGameDefine.DelayTime
    self:RegisterTimer(function()
        MiniGameInst:ShowCenterSmashTip()
    end, 2.5, 0, 1, MiniGameInst)
    self:RegisterTimer(function()
        self:SendMsgCrystalTowerExistReq(true)
        MiniGameInst:StopMajorSlotAnimation(GoldSaucerMiniGameDefine.DefaultSlot)
        AudioUtil.LoadAndPlay2DSound(CrystalTowerAudioDefine.AudioPath.SmashHit)
    end, 4, 0, 1, MiniGameInst)

    self:UpdateMiniGameVM(GameType)
end

--- @type 发送请求结束协议
function GoldSaucerMiniGameMgr:SendMsgCrystalTowerExistReq(bNormal)
    local MsgID = CS_CMD.CS_CMD_CRYSTAL_TOWER
    local SubMsgID = CRTSTAL_TOWER_SUB_MSG_ID.CrystalTowerCmdExit
    local GameType = MiniGameType.CrystalTower
    local MiniGameInst = self:GetTheCurMiniGameInst()
    if MiniGameInst == nil then
        return
    end
    MiniGameInst:TryHideHammerVfx()
    local ContinueCount = MiniGameInst:GetMaxComboNum()
    local MsgBody = {}
    MsgBody.SubCmd = SubMsgID
    MsgBody.ExitReq = {
        Normal = bNormal,
        ConHitCount = ContinueCount,
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 请求协议回报
function GoldSaucerMiniGameMgr:OnNetMsgCTExitRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    local GameType = MiniGameType.CrystalTower
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end
    local MiniGameInst = self:GetTheCurMiniGameInst()
    if MiniGameInst == nil then
        return
    end
    local Anim = MiniGameClientConfig[GameType].Anim
    local ResultPower = MiniGameClientConfig[GameType].ResultPower
    local ExitRsp = MsgBody.ExitRsp
    local bNewPower = ExitRsp.NewPower
    local bNewContinueHit = ExitRsp.NewContinueHit
    local bCriticalHit = ExitRsp.CriticalHit
    local Power = MiniGameInst:GetStrengthValue()
    local RewardCfg = MiniGameInst:GetRewardCfg()
    local bSuccess = false
    local EndState, ResultAnim
    if Power < RewardCfg[1].Score then
        EndState = MiniGameRoundEndState.FailChance -- 失败
        ResultAnim = Anim.AnimInFail
        FLOG_INFO("ResultAnim is AnimInTimeUp that is Fail")
    else
        MiniGameInst:ConstructEndResultData(bNewPower, bNewContinueHit)
        MiniGameInst:CTSetCritical(bCriticalHit)
        MiniGameInst:SetRewardGot(ExitRsp.RewardCount)
        bSuccess = true
        EndState = MiniGameRoundEndState.Success
        ResultAnim = Anim.AnimVictory
        FLOG_INFO("ResultAnim is AnimSuccess that is Fail")
    end
    MiniGameInst.RoundEndState = EndState
    -- MiniGameInst:SetPanelNormalVisible(false)
    EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimaNormalOut)
    MiniGameInst:SetEndState()
    MiniGameInst:SetBtnContentAndJDCoinColor()
    MiniGameInst:SetSuccessOrFail(bSuccess)
    MiniGameInst:SetbShowMoneySlot(true)
    self:UpdateMiniGameVM(GameType)
    EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, ResultAnim)
    local EndEmotionID = MiniGameInst:GetEndEmotionID()
    self:PlayEmotionActInSettlementStage(MiniGameType.CrystalTower, bSuccess, EndEmotionID)
    self:CrystalTowerGetReward(bCriticalHit)
end

function GoldSaucerMiniGameMgr:CrystalTowerGetReward(bCriticalHit)
    _G.LootMgr:SetDealyState(true)
    local DelayTime = 2
    if bCriticalHit then
        DelayTime = DelayTime + 2
    end
    self:RegisterTimer(function() _G.LootMgr:SetDealyState(false) end, DelayTime)
end
--Msg End

function GoldSaucerMiniGameMgr:GetActionPathByRaceID()
    local MajorUtil = require("Utils/MajorUtil")
    local RaceID = MajorUtil.GetMajorRaceID()
    if self.CurMiniGameInst == nil then
        return
    end
    local DefineCfg = self.CurMiniGameInst.DefineCfg
    local ActionPath = DefineCfg.ActionPath
    return ActionPath[RaceID]
end

--- 创建小游戏实例
---@param GameType GoldSaucerMiniGameDefine.MiniGameType@小游戏类型
---@return MiniGameBase @小游戏实例类型
function GoldSaucerMiniGameMgr:CreateMiniGameAfterInteract(GameType)
    local MiniGameInst = MiniGameFactory.CreateMiniGameInstance(GameType)
    if MiniGameInst then
        MiniGameInst.ID = self.CurInteractEntityID
        self.CurMiniGameInst = MiniGameInst
        return MiniGameInst
    end
end

--- 刷新小游戏VM
function GoldSaucerMiniGameMgr:UpdateMiniGameVM(GameType)
    local ViewModel = MiniGameVM:GetDetailMiniGameVM(GameType)
    if ViewModel ~= nil then
        ViewModel:UpdateVM()
    end
end

--- 游戏选择难度计时结束自动选择
function GoldSaucerMiniGameMgr:OnDetailMiniGameAutoSelectDifficulty(GameType)
    local MiniGameInst = self.CurMiniGameInst
    if not MiniGameInst then
       return
    end
    local DefaultDifficulty = MiniGameInst:GetDifficulty()
    self:SetTheMiniGameDifficulty(GameType, DefaultDifficulty)
end

--- 游戏退出，清除数据
function GoldSaucerMiniGameMgr:RemoveMiniGameAfterGameEnd(bRewar)
    FLOG_INFO("GoldSaucerMiniGameMgr:RemoveMiniGameAfterGameEnd")

    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst then
        MiniGameInst:GameQuit(bRewar)
        self:UnRegisterAllTimer() -- 目前只有单一小游戏会在客户端存在，故移除小游戏时将Mgr内部的所有计时器停止
        if not bRewar then
            self.CurMiniGameInst = nil
            EventMgr:SendEvent(EventID.MiniGameMajorEnterQuitMode)

            FLOG_INFO("GoldSaucerMiniGameMgr:RemoveMiniGameAfterGameEnd: CurMiniGameInst set nil")
        end
    end
end

--- 翻倍挑战协议发送
function GoldSaucerMiniGameMgr:OnDetailMiniGameRestart(Params)
    local bLock = self.RestartLock
    if bLock then
        FLOG_INFO("GoldSaucerMiniGameMgr:OnDetailMiniGameRestart: Msg is Sending, Do not Try Again")
        return
    end

    local GameType = Params.Type
    local bRestart = Params.bRestart
    if GameType == MiniGameType.MooglesPaw then
        self:SendMsgMooglePawDoubleReq(bRestart)
    elseif GameType == MiniGameType.OutOnALimb or GameType == MiniGameType.TheFinerMiner then
        self:SendMsgAloneTreeDoubleChanceReq(GameType, bRestart)
    end

    if not bRestart then
        LootMgr:SetDealyState(true)
    end

    self.RestartLock = true
end

function GoldSaucerMiniGameMgr:CheckIsInInteractiveRange(CurInteractEntityID)
    local EObj = ActorUtil.GetActorByEntityID(CurInteractEntityID)
    local Major = MajorUtil.GetMajor()

    local EObjID = ActorUtil.GetActorResID(CurInteractEntityID)
    local Cfg = EobjCfg:FindCfgByKey(EObjID)
    if Cfg == nil then
        return
    end
    local InteractDistance = Cfg.InteractDistance
    local EObjLoc = EObj:FGetActorLocation()
    local MajorLoc = Major:FGetActorLocation()
    local DistWithEObj = _G.UE.FVector.Dist(MajorLoc, EObjLoc)   --MajorLoc:Dist2D(EObjLoc)

    if DistWithEObj > InteractDistance then
        return false
    end
    return true
end

function GoldSaucerMiniGameMgr:HideInteractivePanel()
    if UIViewMgr:IsViewVisible(UIViewID.MooglePawOkWin) then
        UIViewMgr:HideView(UIViewID.MooglePawOkWin)
    end
end

--- 进入小游戏协议发送
function GoldSaucerMiniGameMgr:OnDetailMiniGameStart(GameType, CurInteractEntityID)
    local BlockForEnterMsg = self.BlockForEnterMsg
    if BlockForEnterMsg then
        return
    end
    self.CurInteractEntityID = CurInteractEntityID
    local CurSgInstanceID = self:GetSgInstanceIDByEntityID(CurInteractEntityID)
    if not self:CheckIsInInteractiveRange(CurInteractEntityID) then
        MsgTipsUtil.ShowTips(LSTR(250013)) -- 请回到交互范围进行游戏
        self:HideInteractivePanel()
        return
    end

    if self:CheckIsSkilling() then
        MsgTipsUtil.ShowTips(LSTR(250014)) -- 技能释放过程中无法进入游戏
        self:HideInteractivePanel()
        return
    end

    local Major = MajorUtil.GetMajor()
    if Major == nil then
        return
    end

    if not Major:IsOnGround() then
        MsgTipsUtil.ShowTips(LSTR(360037))  -- 角色未贴地不能进行游戏交互
        self:HideInteractivePanel()
        return
    end

    _G.SkillBuffMgr:RemoveAllBuff(false)
    if GameType == MiniGameType.MooglesPaw then
        self:SendMsgMooglePawStartReq(CurSgInstanceID)
    elseif GameType == MiniGameType.Cuff then
        self:SendMsgCuffEnterReq(CurSgInstanceID)
    elseif GameType == MiniGameType.OutOnALimb or GameType == MiniGameType.TheFinerMiner then
        self:SendMsgAloneTreeEnterReq(GameType)
    elseif GameType == MiniGameType.MonsterToss then
        self:SendMsgBaskMonsterEnterReq(CurSgInstanceID)
    elseif GameType == MiniGameType.CrystalTower then
        self:SendMsgCrystalTowerEnterReq(CurSgInstanceID)
    end
    self.BlockForEnterMsg = true
end

function GoldSaucerMiniGameMgr:CheckIsSkilling()
    local StateComp = MajorUtil.GetMajorStateComponent()
    if StateComp == nil then return end
    -- if StateComp:IsUsingSkill()(_G.UE.EActorState.Attack) then
    if StateComp:IsUsingSkill() then
        return true
    end

    return false
end

function GoldSaucerMiniGameMgr:FindAndSendCatchBall()
    local MooglePawsVM = MiniGameVM:GetDetailMiniGameVM(MiniGameType.MooglesPaw)
    if not MooglePawsVM then
        return
    end

    local MooglePos = MooglePawsVM.MooglePosition
    if not MooglePos then
        return
    end

    local OriginX = BallOriginVec.X or 0
    local OriginY = BallOriginVec.Y or 0
    local MooglePosX, MooglePosY = MooglePos:GetValue()
    local SendX = math.floor(MooglePosX - OriginX + 0.5)
    local SendY = math.floor(MooglePosY - OriginY + 0.5)
    local GameInst = MooglePawsVM.MiniGame
    if GameInst then
        GameInst:FindTheBallNearest(SendX, SendY)
    end
    self:SendMsgMooglePawCatchReq(SendX, SendY)
end

--- 莫古抓球机单轮停止操作移动
function GoldSaucerMiniGameMgr:OnGameEventMooglePawsEndMove()
    local HaveResultToWait = self.bWaitForCatchResult
    if HaveResultToWait then
        return
    end
    self:FindAndSendCatchBall()
    self.bWaitForCatchResult = true
end

function GoldSaucerMiniGameMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
    -- local BaseInfo = PWorldMgr.BaseInfo
    -- self.CurrMapResID = BaseInfo.CurrMapResID
    -- if BaseInfo.CurrMapResID == self.JDMapID or BaseInfo.CurrMapResID == self.JDResID then
    if LeaveMapResID == self.JDMapID or LeaveMapResID == self.ChocoMapID then
        local CurMiniGameInst = self:GetTheCurMiniGameInst()
        if CurMiniGameInst ~= nil then
            CurMiniGameInst:SetIsForceEnd(true)
            local CurMiniGameType = CurMiniGameInst.MiniGameType
            if CurMiniGameType == MiniGameType.Cuff then
                self:SendMsgCuffExistReq(false)
            elseif CurMiniGameType == MiniGameType.MonsterToss then
                self:SendMsgBaskMonsterFinishReq(false)
            elseif CurMiniGameType == MiniGameType.CrystalTower then
                self:SendMsgCrystalTowerExistReq(false)
            elseif CurMiniGameType == MiniGameType.OutOnALimb or CurMiniGameType == MiniGameType.TheFinerMiner then
                self:SendMsgAloneTreeExitReq(CurMiniGameType)
            elseif CurMiniGameType == MiniGameType.MooglesPaw then
                self:SendMsgMooglePawExitReq()
            end

            self:QuitMiniGame(CurMiniGameInst.MiniGameType, false)
        end
    end
end

function GoldSaucerMiniGameMgr:OnUpdateScoreValue(ScoreID)
    local JDCoinID = ScoreType.SCORE_TYPE_KING_DEE

    if JDCoinID == ScoreID then
        local CurGameInst = self.CurMiniGameInst
        if CurGameInst then
            if (CurGameInst.MiniGameType == MiniGameType.Cuff or CurGameInst.MiniGameType == MiniGameType.CrystalTower) then
                CurGameInst:SetBtnContentAndJDCoinColor()
                self:UpdateMiniGameVM(CurGameInst.MiniGameType)
            elseif CurGameInst.MiniGameType == MiniGameType.MonsterToss then
                CurGameInst:UpdateResultCoinState()
                self:UpdateMiniGameVM(CurGameInst.MiniGameType)
            end
        end
    end
end

--- 是否有此小游戏配置
function GoldSaucerMiniGameMgr:IsHaveTheGameInDefineCfg(GameType)
    if GameType == nil then
        FLOG_ERROR("GoldSaucerMiniGameMgr:IsHaveTheGameInDefineCfg GameType is nil")
        return false
    end
    if GameType == MiniGameType.None then
        FLOG_ERROR("GoldSaucerMiniGameMgr:IsHaveTheGameInDefineCfg GameType is none")
        return false
    end

    for _, Type in pairs(MiniGameType) do
        if Type == GameType then
            return true
        end
    end
    FLOG_ERROR("GoldSaucerMiniGameMgr:IsHaveTheGameInDefineCfg define do not have the game")
    return false
end

--- 回包后创建小游戏实例
---@param GameType GoldSaucerMiniGameDefine.MiniGameType@小游戏类型
---@param Params table@创建时传入参数
function GoldSaucerMiniGameMgr:OnMsgNotifyEnterTheMiniGame(GameType, Params)
    if not self:IsHaveTheGameInDefineCfg(GameType) then
        return
    end

    local MiniGameInst = self.CurMiniGameInst

    if MiniGameInst == nil then
        self:HidePlayerEnter()
        MiniGameInst = self:CreateMiniGameAfterInteract(GameType)
    end

    if MiniGameInst then
        if Params then
            MiniGameInst:OnSyncParamsByGameState(MiniGameStageType.Enter, Params)
        end
        MiniGameInst:GameEnter()
    end
    self.BlockForEnterMsg = false
end

function GoldSaucerMiniGameMgr:Test()
    _G.UE.UActorManager.Get():ResetVirtualJoystick()
end

--- end

--- 音效播放 ---

--- 播放对应UI音效
---@param AudioType GoldSaucerMiniGameDefine.AudioType
function GoldSaucerMiniGameMgr.PlayUISoundByAudioType(AudioType)
    if not AudioType then
        return
    end
    local Path = AudioPath[AudioType]
    if not Path then
        return
    end

    AudioUtil.LoadAndPlayUISound(Path)
end

function GoldSaucerMiniGameMgr.ChangeUISoundRTPCValue(RTPCName, Value)
    UAudioMgr.SetRTPCValue(RTPCName, Value, 0, nil)
end

--- 音效播放end ---

--- UIView调用接口/外部接口

--- 是否处于游戏状态（数据层面的游戏退出，先于UI界面的关闭）
function GoldSaucerMiniGameMgr:IsInGoldSaucerMiniGame()
    return self.CurMiniGameInst ~= nil
end

--- 是否处于游戏主流程中（仅判断主界面是否显示）
function GoldSaucerMiniGameMgr:CheckIsInMiniGame()
    local bInGame =
    UIViewMgr:IsViewVisible(UIViewID.OutOnALimbMainPanel) or UIViewMgr:IsViewVisible(UIViewID.TheFinerMinerMainPanel) or
    UIViewMgr:IsViewVisible(UIViewID.MooglePawMainPanel) or UIViewMgr:IsViewVisible(UIViewID.GoldSaucerCuffMainPanel) or
    UIViewMgr:IsViewVisible(UIViewID.GoldSaucerMonsterTossMainPanel) or UIViewMgr:IsViewVisible(UIViewID.CrystalTowerStrikerMainPanel)
    return bInGame
end

--- 交互特定小游戏
function GoldSaucerMiniGameMgr:InteractEnterTheGoldSaucerMiniGame(GameType, EntityID)
    if not self:CheckIsInInteractiveRange(EntityID) then
        MsgTipsUtil.ShowTips(LSTR(250013)) -- 请回到交互范围进行游戏
        self:RegisterTimer(function() _G.InteractiveMgr:ShowEntrances() end, 1.5)
        return
    end

    if self:CheckIsSkilling() then
        MsgTipsUtil.ShowTips(LSTR(250014)) -- 技能释放过程中无法进入游戏
        self:RegisterTimer(function() _G.InteractiveMgr:ShowEntrances() end, 1.5)
        return
    end

    if self.CurMiniGameInst then  -- 2025.5.21 将对小游戏的实例判定由View里的OnShow方法移到这边处理，防止未正常打开界面导致影响主界面显示
        FLOG_ERROR("GoldSaucerMiniGameMgr:InteractEnterTheGoldSaucerMiniGame(): CurMiniGameInst is not nil")
        return
    end

    local OKWinViewID = UIViewID.OutOnALimbOkWin
    local GameClientCfg = MiniGameClientConfig[GameType]
    if GameClientCfg then
        local CfgOKWinViewID = GameClientCfg.OKWinViewID
        if CfgOKWinViewID then
            OKWinViewID = CfgOKWinViewID
        end
    end
    if UIViewMgr:IsViewVisible(OKWinViewID) then
        MsgTipsUtil.ShowTips(LSTR(250015)) -- 点击过快请稍后再试
        return
    end

    UIViewMgr:ShowView(OKWinViewID, {GameType = GameType,  EntityID = EntityID, bEnterGame = true})
end

--- 确定要退出提示
function GoldSaucerMiniGameMgr:ShowEnsureExitTip(GameType, EnsureFailQuit, RecoverGameLoop)
    local OKWinViewID = UIViewID.OutOnALimbOkWin
    local GameClientCfg = MiniGameClientConfig[GameType]
    if GameClientCfg then
        local CfgOKWinViewID = GameClientCfg.OKWinViewID
        if CfgOKWinViewID then
            OKWinViewID = CfgOKWinViewID
        end
    end
    UIViewMgr:ShowView(OKWinViewID, {GameType = GameType, EnsureFailQuit = EnsureFailQuit, RecoverGameLoop = RecoverGameLoop, bEnterGame = false})
end

--- 设定游戏难度
function GoldSaucerMiniGameMgr:SetTheMiniGameDifficulty(GameType, Difficulty)
    self:SendMsgAloneTreeSelectDifficultyReq(GameType, Difficulty)
end

--- 单轮单次出手条件判定
---@param GameType number@游戏类别
function GoldSaucerMiniGameMgr:CanActInTheMiniGameRound(GameType)
    local MiniGameInst = self.CurMiniGameInst
    if not MiniGameInst then
        FLOG_ERROR("GoldSaucerMiniGameMgr:PressBtnToActInTheMiniGameRound do not have the GameInst")
        return false
    end

    local RemainTime = MiniGameInst:GetRemainSecondsInteger()
    if RemainTime <= 0 then
        FLOG_ERROR("GoldSaucerMiniGameMgr:PressBtnToActInTheMiniGameRound time is out")
        return false
    end

    local RemainChances = MiniGameInst:GetRemainChances()
    if RemainChances <= 0 then
        FLOG_ERROR("GoldSaucerMiniGameMgr:PressBtnToActInTheMiniGameRound Chances is not enough")
        return false
    end

    return true
end

--- 单轮单次出手
---@param GameType number@游戏类别
---@param ClientJudgeResult number@客户端判定结果 孤树为指针角度，矿脉为圆圈半径等
function GoldSaucerMiniGameMgr:PressBtnToActInTheMiniGameRound(GameType, ClientJudgeResult)
    local MiniGameInst = self.CurMiniGameInst
    if not MiniGameInst then
        FLOG_ERROR("GoldSaucerMiniGameMgr:PressBtnToActInTheMiniGameRound do not have the GameInst")
        return
    end

    self:SendMsgAloneTreeCutReq(GameType, ClientJudgeResult)
end

--- 莫古抓球机按下操作按钮
function GoldSaucerMiniGameMgr:PressDownBtnToActInTheMooglePawRound()
    local MiniGameInst = self.CurMiniGameInst
    if not MiniGameInst then
        FLOG_ERROR("GoldSaucerMiniGameMgr:PressBtnToActInTheMooglePawRound do not have the GameInst")
        return
    end
    MiniGameInst:OnActBtnPressDown()
end

--- 莫古抓球机抬起操作按钮
function GoldSaucerMiniGameMgr:PressUpBtnToActInTheMooglePawRound()
    local MiniGameInst = self.CurMiniGameInst
    if not MiniGameInst then
        FLOG_ERROR("GoldSaucerMiniGameMgr:PressBtnToActInTheMooglePawRound do not have the GameInst")
        return
    end
    MiniGameInst:OnActBtnPressUp()
end

--- 单次反馈后恢复游戏时间循环
---@param GameType number@游戏类别
function GoldSaucerMiniGameMgr:ActFeedBackRecoverTimeLoop(GameType)
    local MiniGameInst = self.CurMiniGameInst
    if not MiniGameInst then
        FLOG_ERROR("GoldSaucerMiniGameMgr:PressBtnToActInTheMiniGameRound do not have the GameInst")
        return
    end
    MiniGameInst:RecoverGameTimeLoop()
end

--- 退出游戏
---@param GameType number@游戏类别
---@param bRewar number@是否翻倍挑战

function GoldSaucerMiniGameMgr:QuitMiniGame(GameType, bRewar)
    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst == nil then
        return
    end

    self:RemoveMiniGameAfterGameEnd(bRewar)
    if not bRewar then
        self:ShowPlayerLeave()
    end
    if UIViewMgr:IsViewVisible(UIViewID.GoldSaucerMonsterTossShootingTips) then
        UIViewMgr:HideView(UIViewID.GoldSaucerMonsterTossShootingTips)
    end

    -- 修复小游戏界面打开聊天框导致退出到主界面的状态错乱
    local View = UIViewMgr:FindVisibleView(UIViewID.MainPanel)
    if View then
        View:OnShow()
        local MainLBottomPanel = View.MainLBottomPanel
        if MainLBottomPanel then
            local Anim = MainLBottomPanel.AnimPanelShowFold
            if Anim then
                MainLBottomPanel:PlayAnimation(Anim)
            end
        end
    end--]]
end

--- 结算阶段播放情感动作
---@param GameType GoldSaucerMiniGameDefine.MiniGameType @游戏种类
---@param bSuccess boolean @是否成功
---@param SuccessEmotionID number @挑战成功情感动作id
function GoldSaucerMiniGameMgr:PlayEmotionActInSettlementStage(GameType, bSuccess, SuccessEmotionID)
    local MiniGameInst = self.CurMiniGameInst
    if MiniGameInst == nil then
        return
    end

    MiniGameInst:StopMajorSlotAnimation(GoldSaucerMiniGameDefine.DefaultSlot)

    local EmotionIDToPlay = bSuccess and SuccessEmotionID or SettleEmotionID.Regret

    if GameType == MiniGameType.MooglesPaw and bSuccess then
        local RaceID = MajorUtil.GetMajorRaceID()
        if RaceType.RACE_TYPE_Elezen == RaceID then
            EmotionIDToPlay = 11 --- for 监修临时处理 2024.6.24 cy
        end
    end

    if GameType == MiniGameType.Cuff and bSuccess then -- for 监修临时处理 2024.6.24 cy
        local RaceID = MajorUtil.GetMajorRaceID()
        if RaceType.RACE_TYPE_Miqote == RaceID then
            local RewardCfg = MiniGameInst.RewardCfg
            for i, v in pairs(RewardCfg) do
                local Elem = v
                if MiniGameInst:GetStrengthValue() >= Elem.Score then
                    if i == 1 then
                        EmotionIDToPlay = 18
                    elseif i == 2 then
                        EmotionIDToPlay = 21
                    else
                        EmotionIDToPlay = 46
                    end
                end
            end
        end
    end
    -- local AvatarComp = MajorUtil.GetMajorAvatarComponent()
    -- if AvatarComp ~= nil then
    --     -- AvatarComp:TakeOffAvatarPart(_G.UE.EAvatarPartType.WEAPON_SYSTEM, false)
    --     -- AvatarComp:SetAvatarHiddenInGame(_G.UE.EAvatarPartType.WEAPON_MASTER_HAND, false, false, false)
    -- end

    self:RegisterTimer(function() EmotionMgr:PlayEmotionID(EmotionIDToPlay, false) end, 0.5)
end

--- 获取对应游戏界面的HelpInfoID
---@param GameType GoldSaucerMiniGameDefine.MiniGameType @游戏种类
---@param GameStageType GoldSaucerMiniGameDefine.MiniGameStageType@游戏阶段分类
function GoldSaucerMiniGameMgr:GetThePanelHelpInfoID(GameType, GameStageType)
    if not GameType then
        return
    end
    local GameDefine = MiniGameClientConfig[GameType]
    if not GameDefine then
        return
    end

    if not GameStageType then
        return GameDefine.HelpInfoID
    else
        if GameStageType == MiniGameStageType.DifficultySelect then
            return GameDefine.HelpInfoIDDifficult
        elseif GameStageType == MiniGameStageType.Update then
            return GameDefine.HelpInfoIDRun
        end
    end
end

function GoldSaucerMiniGameMgr:HideMiniGamePanel()
    if UIViewMgr:IsViewVisible(UIViewID.GoldSaucerCuffMainPanel) then
        UIViewMgr:HideView(UIViewID.GoldSaucerCuffMainPanel)
    elseif UIViewMgr:IsViewVisible(UIViewID.GoldSaucerMonsterTossMainPanel) then
        UIViewMgr:HideView(UIViewID.GoldSaucerMonsterTossMainPanel)
    elseif UIViewMgr:IsViewVisible(UIViewID.CrystalTowerStrikerMainPanel) then
        UIViewMgr:HideView(UIViewID.CrystalTowerStrikerMainPanel)
    end
end

--- @type 获得动态物件实例ID
function GoldSaucerMiniGameMgr:GetSgInstanceIDByEntityID(EntityID)
	local EObjID = ActorUtil.GetActorResID(EntityID)
	if not EObjID or EObjID == 0 then
		return
	end

	local Cfg = EobjLinktoSgAssetCfg:FindCfgByKey(EObjID)
	if Cfg ~= nil then
		return Cfg.SgbID
	else
		FLOG_ERROR("EobjLinktoSgAssetCfg Cfg = nil EObjID = %s", EObjID)
	end
end

return GoldSaucerMiniGameMgr
