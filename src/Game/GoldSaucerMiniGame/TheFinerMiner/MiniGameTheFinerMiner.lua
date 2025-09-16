local LuaClass = require("Core/LuaClass")
local MiniGameBase = require("Game/GoldSaucerMiniGame/MiniGameBase")
local MajorUtil = require("Utils/MajorUtil")
local DifficultControlCfg = require("TableCfg/TheFinerMinerDifficultyControlCfg")
local RoundControlCfg = require("TableCfg/TheFinerMinerLoopControlCfg")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local UIViewMgr = require("UI/UIViewMgr")
local MiniGameVM = require("Game/GoldSaucerMiniGame/MiniGameVM")
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local ExtraChanceResetPolicy = GoldSaucerMiniGameDefine.ExtraChanceResetPolicy
local AnimTimeLineSourceKey = GoldSaucerMiniGameDefine.AnimTimeLineSourceKey
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR
local UIViewID = require("Define/UIViewID")
local DynAssetInstanceID = 5965785 -- 关卡中创建的动态物件实例id
local IdleAnimPlayAheadTime = 1.1 -- 挥斧动画结束提前播放Idle动画需提前的时间（for timeline不恢复到主场景的Idle状态）

---@class MiniGameOutOnALimb
---@param MiniGameType number @GoldSaucerMiniGameDefine.MiniGameType
local MiniGameTheFinerMiner = LuaClass(MiniGameBase)

---Ctor
function MiniGameTheFinerMiner:Ctor()
    local Type = MiniGameType.TheFinerMiner
	self.MiniGameType = Type
    self.Name = MiniGameClientConfig[Type].Name
    self.UIViewMainID = UIViewID.TheFinerMinerMainPanel
    self.DoubleWinViewID = UIViewID.OutOnALimbDoubleWin
    self.SettlementViewID = UIViewID.TheFinerMinerSettlementPanel
    self.IdleStateKey = AnimTimeLineSourceKey.MiningIdle
    local DefineCfg = MiniGameClientConfig[Type]
    if DefineCfg then
        self.DefineCfg = DefineCfg
        self.ProgressCfg = DefineCfg.ProgressLevel
    end
    self.DynAssetID = DynAssetInstanceID
    self.WeaponModel = "7001,1,2,0"
    self.ClientRltShowDelayTime = 0.2
end

--- 初始化游戏数据
function MiniGameTheFinerMiner:LoadTableCfg()
    local RoundToCount = 1
    while(RoundControlCfg:FindCfgByKey(RoundToCount) ~= nil)
    do
        RoundToCount = RoundToCount + 1
    end
    self.MaxRound = RoundToCount - 1
end

--- 初始化游戏数据
function MiniGameTheFinerMiner:InitMiniGame()
    local ResetTime, ResetChances = self:GetRestartTimeAndChances()
    self.RemainSeconds = ResetTime
    self.RemainChances = ResetChances -- 特定难度下单轮游戏的出手次数
end

--- 设定选择游戏难度MsgText内容
function MiniGameTheFinerMiner:OnCreateDifficultyParams()
    --return LSTR("把握时机挥下手斧！\n\n根据力量槽停止的位置，\n来决定采集的速度。\n\n泰坦：非常快\n魔界花：快\n仙人刺：慢")
    local GameType = self.MiniGameType
    local ParamResult = {
        TimeLimit = MiniGameClientConfig[GameType].DifficultyTime
    }
    return ParamResult
end

--- 是否有难度选择阶段
function MiniGameTheFinerMiner:OnIsGameHaveDifficultySelect()
    return true
end

--- 获取镜头移动参数
function MiniGameTheFinerMiner:OnCreateCameraSettingParam()
    local CameraMoveParam = _G.UE.FCameraResetParam()
	CameraMoveParam.Distance = 500
	CameraMoveParam.Rotator =  _G.UE.FRotator(0, -30, 0)
	CameraMoveParam.ResetType =  _G.UE.ECameraResetType.Interp
	CameraMoveParam.LagValue = 10
	CameraMoveParam.NextTransform = _G.UE.FTransform()
	CameraMoveParam.TargetOffset = _G.UE.FVector(0, 0, 0)
	CameraMoveParam.SocketExternOffset = _G.UE.FVector(-50, 220, 50)
	CameraMoveParam.FOV = 0
	CameraMoveParam.bRelativeRotator = true
    return CameraMoveParam
end

--- 是否结束游戏
function MiniGameTheFinerMiner:OnIsGameRunEnd()
	local AchievedProgress = self.AchieveRewardProgress
	if AchievedProgress >= 1 then
		self.RoundEndState = MiniGameRoundEndState.Success
        --FLOG_INFO("MiniGameTheFinerMiner:OnIsGameRunEnd End Success")
		return true
	end
	local RemainTime = self.RemainSeconds
	if RemainTime <= 0 then
		self.RoundEndState = MiniGameRoundEndState.FailTime
        --FLOG_INFO("MiniGameTheFinerMiner:OnIsGameRunEnd End FailTime")
		return true
	end
	local RemainChances = self.RemainChances
	if RemainChances <= 0 then
		self.RoundEndState = MiniGameRoundEndState.FailChance
        --FLOG_INFO("MiniGameTheFinerMiner:OnIsGameRunEnd End FailChance")
		return true
	end
	return false
end

--- 是否带有翻倍阶段
function MiniGameTheFinerMiner:OnIsHaveRestartStage()
    local GameType = self.MiniGameType
    local Cfg = MiniGameClientConfig[GameType]
    if Cfg then
        local ExtraReset = Cfg.ExtraReset
        return ExtraReset ~= nil
    end
end

--- 翻倍挑战提示参数
function MiniGameTheFinerMiner:OnCreateRestartContentParams()
    --- 时间，次数重置策略提前到出翻倍确认提示框
    local DCfg = self.DefineCfg
    if DCfg then
        local ResetTime, ResetChances = self:GetRestartTimeAndChances()
        local RestartPolicy = DCfg.ExtraReset
        if RestartPolicy == ExtraChanceResetPolicy.TimeAndCount or
        RestartPolicy == ExtraChanceResetPolicy.OnlyTime then
            self.RemainSeconds = ResetTime or 0
        end
        if RestartPolicy == ExtraChanceResetPolicy.TimeAndCount or
        RestartPolicy == ExtraChanceResetPolicy.OnlyCount then
            self.RemainChances = ResetChances or 0
        end
    end
    
    local RoundIndex = self.CurRound

    return {
        GameType = self.MiniGameType,
        RemainTime = self.RemainSeconds,
        RemainChances = self.MaxRound - RoundIndex - 1,
        CurReward = self:GetTheRewardGotInTheRoundInternal(RoundIndex),
        NewReward = self:GetTheRewardGotInTheRoundInternal(RoundIndex + 1),
    }
end

--- 获取游戏翻倍挑战重置时间和次数
function MiniGameTheFinerMiner:GetRestartTimeAndChances()
	local Time = 0
	local Chances = 0
	local DCfg = self.DefineCfg
    if DCfg then
        Time = DCfg.TimeLimit or 0
		local Difficulty = self:GetDifficulty()
		local DcCfg = DifficultControlCfg:FindCfgByKey(Difficulty)
		Chances = DcCfg.Count or 0
    end
	return Time, Chances
end

--- 获取当前轮能够获得的奖励
function MiniGameTheFinerMiner:GetTheRewardGotInTheRoundInternal(Round)
    local DifficultyLv = self:GetDifficulty()
	local DifficultyCfg = DifficultControlCfg:FindCfgByKey(DifficultyLv)
	if DifficultyCfg == nil then
		return
	end

	local ActualReward = 0
	local BasicReward = DifficultyCfg.BaseReward or 0

	local RoundCfg = RoundControlCfg:FindCfgByKey(Round + 1)
	if RoundCfg then
		local RewardRate = RoundCfg.RewardRate / 100 or 1
		ActualReward = math.ceil(BasicReward * RewardRate)
	else
		FLOG_ERROR("OutOnALimbMainPanelView:UpdateRewardPanel:RoundIndex is valid. CurRound:%s", tostring(Round))
        return 0
	end 

    return ActualReward
end

--- 获取当前轮能够获得的奖励
function MiniGameTheFinerMiner:GetTheRewardGotInTheRound()
	local CurRound = self:GetRoundIndex()
    return self:GetTheRewardGotInTheRoundInternal(CurRound)
end

--- 获取当前轮轮盘速度
function MiniGameTheFinerMiner:GetTheSpeedInTheRound()
	local DifficultyLv = self:GetDifficulty()
	local DifficultyCfg = DifficultControlCfg:FindCfgByKey(DifficultyLv)
	if DifficultyCfg == nil then
		return
	end
	local ActualSpeed = DifficultyCfg.Speed / 100 or 1 -- 随难度变化的速度倍率

	local CurRound = self:GetRoundIndex()
	local RoundCfg = RoundControlCfg:FindCfgByKey(CurRound + 1)
	if RoundCfg then
		local SpeedRate = RoundCfg.SpeedRate / 100 or 1
		ActualSpeed = ActualSpeed * SpeedRate
	else
		FLOG_ERROR("MiniGameTheFinerMiner:GetTheSpeedInTheRound:RoundIndex is valid. CurRound:%s", tostring(CurRound))
	end
    FLOG_INFO("MiniGameTheFinerMiner:GetTheSpeedInTheRound Difficulty: %s, CurRound: %s, ActualSpeed: %s", tostring(DifficultyLv), tostring(CurRound), tostring(ActualSpeed))
    return ActualSpeed
end

--- 获取顶部tips内容
function MiniGameTheFinerMiner:OnGetTopTipsContent(GameState)
    local Title
    local Content
    local bShowDifficultyMark

    if GameState == MiniGameStageType.DifficultySelect then
        Title = LSTR(380011)
        Content = LSTR(380012)
        bShowDifficultyMark = true
    elseif GameState == MiniGameStageType.Start then
        Title = LSTR(380013)
        Content = LSTR(380014)
        bShowDifficultyMark = false
    end 
    return {
        Title = Title,
        Content = Content,
        bShowDifficultyMark = bShowDifficultyMark
    }
end

--- 退出时重置游戏信息（for再战）
function MiniGameTheFinerMiner:Reset()
    self:ResetGameInfo()
end

--- 播放主角砍伐/挖掘动画
function MiniGameTheFinerMiner:PlayMajorCutAnimation()
	local RaceID = MajorUtil.GetMajorRaceID()
	if not RaceID then
		return
	end

	local ClientDef = self.DefineCfg
	if not ClientDef then
		return
	end

	local ActionAnimList = ClientDef.ActionPath
	if not ActionAnimList then
		return
	end

	local AnimPath = ActionAnimList[RaceID]
	if not AnimPath then
		return
	end
	
	self:PlayActionTimeLineByPath(AnimPath)
	self:StopMajorSlotAnimation(GoldSaucerMiniGameDefine.DefaultSlot)
	local function RePlayIdleAnim()
		local Path = self:GetIdlePathByRaceID()
		self:PlayAnyAsMontageLoopByPath(Path, GoldSaucerMiniGameDefine.DefaultSlot, 9999, true)
	end
    local TimerHandle =_G.TimerMgr:AddTimer(self, RePlayIdleAnim, IdleAnimPlayAheadTime)
    self:AddTimerHandle(TimerHandle)
end

return MiniGameTheFinerMiner