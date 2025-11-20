local LuaClass = require("Core/LuaClass")
local MiniGameBase = require("Game/GoldSaucerMiniGame/MiniGameBase")
--local MajorUtil = require("Utils/MajorUtil")
local MiniGameVM = require("Game/GoldSaucerMiniGame/MiniGameVM")
local ProtoRes = require("Protocol/ProtoRes")
local MogulBallType = ProtoRes.Game.MogulBallType
local DifficultControlCfg = require("TableCfg/MooglePawDifficultyCfg")
local RoundControlCfg = require("TableCfg/MooglePawRoundCfg")
local MooglePawTypeCfg = require("TableCfg/MooglePawTypeCfg")
local MooglePawBallCfg = require("TableCfg/MooglePawBallCfg")
local MooglePawBlessCfg = require("TableCfg/MooglePawBlessCfg")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local ExtraChanceResetPolicy = GoldSaucerMiniGameDefine.ExtraChanceResetPolicy
local AnimTimeLineSourceKey = GoldSaucerMiniGameDefine.AnimTimeLineSourceKey
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local MoogleActBtnActiveType = GoldSaucerMiniGameDefine.MoogleActBtnActiveType
local MoogleMoveDir = GoldSaucerMiniGameDefine.MoogleMoveDir
local MoogleMoveState = GoldSaucerMiniGameDefine.MoogleMoveState
local MoogleBallCaughtState = GoldSaucerMiniGameDefine.MoogleBallCaughtState
local MiniGameProgressType = GoldSaucerMiniGameDefine.MiniGameProgressType

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local UIViewID = require("Define/UIViewID")
local MathUtil = require("Utils/MathUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local BlessExtraTimeDefault = 40 -- 赐福回合额外时间默认值


---@class MiniGameMooglesPaw
---@param MiniGameType number @GoldSaucerMiniGameDefine.MiniGameType
local MiniGameMooglesPaw = LuaClass(MiniGameBase)

---Ctor
function MiniGameMooglesPaw:Ctor()
    local Type = MiniGameType.MooglesPaw
	self.MiniGameType = Type
    self.Name = MiniGameClientConfig[Type].Name
    self.UIViewMainID = UIViewID.MooglePawMainPanel
    self.DoubleWinViewID = UIViewID.MooglePawDoubleWin
    self.DynAssetID = nil --DynAssetInstanceID
    self.IdleStateKey = AnimTimeLineSourceKey.MooglePawIdle
    local DefineCfg = MiniGameClientConfig[Type]
    if DefineCfg then
        self.DefineCfg = DefineCfg
        self.ProgressCfg = DefineCfg.ProgressLevel
    end
    self.ActBtnActiveType = MoogleActBtnActiveType.Invalid
    self.bActBtnPressed = false -- 操作按钮是否按下状态
    self.SlownDownConstantTime = 0 -- 减速运动持续时间
    self.SlowDownTimeCount = 0 -- 减速运动时间计数器
    self.SlowDownAcceleration = 0 -- 减速运动加速度
    self.LinearMotionDisCount = 0 -- 匀速运动距离计数器
    self.MoogleMoveDir = MoogleMoveDir.Idle -- 莫古力的运动方向
    self.MoogleMoveState = MoogleMoveState.OutGame -- 莫古力的运动状态
    self.bCatchReqSend = false -- 是否已发送过抓球协议
  
    self.RoundIdList = nil
    self.RoundScoreList = nil -- 单局分数

    self.BallList = nil -- 单局球的分布
    self.BallNum = 0 -- 单局球的数量
    self.StarBallCatchNum = 0 -- 特殊交互物的交互成功数量
    self.StarBallCatchTotalScore = 0 -- 特殊交互成功累计奖励

    self.bCaught = MoogleBallCaughtState.None -- 判定显示抓住与否
    self.CaughtBallID = 0 -- 抓取球的ID
    self.CatchBallType = nil -- 当前轮抓球种类 for 翻倍界面

    self.BaseMoogleSpeed = nil -- 初始的莫古速度

    self.bInExtraRound = false -- 是否已经经历过赐福时间阶段
end


--- 初始化游戏数据
function MiniGameMooglesPaw:LoadTableCfg()
  
end

--- 初始化游戏数据
function MiniGameMooglesPaw:MakeExtraTableCfg()
    local EnterStateParams = self:GetParamsByGameState(MiniGameStageType.Enter)
    if not EnterStateParams then
        return
    end
    local DifficultLv = EnterStateParams.DifficultyLv or 1
    self.Difficulty = DifficultLv
    local DifficultyCfg = DifficultControlCfg:FindCfgByKey(DifficultLv)
    if not DifficultyCfg then
        return
    end
    
    local RoundList = DifficultyCfg.RoundID
    if not RoundList then
        return
    end

    local CacheRoundIdList = {}
    for _, value in ipairs(RoundList) do
        if value > 0 then
            table.insert(CacheRoundIdList, value)
        end
    end
    self.RoundIdList = CacheRoundIdList
    local bRoundIdListValid = CacheRoundIdList and next(CacheRoundIdList)
    self.MaxRound = bRoundIdListValid and #CacheRoundIdList or 1

    self.BaseMoogleSpeed = self:GetTheBaseMoogleSpeed() or 0
end

--- 获取莫古力的原始速度
function MiniGameMooglesPaw:GetTheBaseMoogleSpeed()
    local RoundIDList = self.RoundIdList
    if not RoundIDList then
        return
    end

    local InitialRoundID = RoundIDList[1]
    if not InitialRoundID then
        return
    end

    local InitRoundCfg = RoundControlCfg:FindCfgByKey(InitialRoundID)
    if not InitRoundCfg then
        return
    end

    local MoogleID = InitRoundCfg.MoogleID
    if not MoogleID then
        return
    end

    local MoogleCfg = MooglePawTypeCfg:FindCfgByKey(MoogleID)
    if not MoogleCfg then
        return
    end
    return MoogleCfg.InitSpeed
end
--- 初始化操作按钮激活状态
function MiniGameMooglesPaw:InitActBtnActiveState()
    self:ChangeActBtnTypeActive(MoogleActBtnActiveType.Invalid)
    self.bActBtnPressed = false
end

--- 初始化莫古力运动状态
function MiniGameMooglesPaw:InitMoogleMoveState(bIdle)
    self.SlownDownConstantTime = 0 -- 减速运动持续时间
    self.SlowDownTimeCount = 0 -- 减速运动时间计数器
    self.SlowDownAcceleration = 0 -- 减速运动加速度
    self.LinearMotionDisCount = 0 -- 匀速运动距离计数器
    self.MoogleMoveDir = MoogleMoveDir.Idle -- 莫古力的运动方向 
    self.MoogleMoveState = bIdle and MoogleMoveState.Idle or MoogleMoveState.OutGame -- 初始化莫古力运动状态为局外

end

--- 初始化游戏数据
function MiniGameMooglesPaw:InitMiniGame()
    local ResetTime, ResetChances = self:GetRestartTimeAndChances()
    self.RemainSeconds = ResetTime
    self.RemainChances = ResetChances -- 特定难度下单轮游戏的出手次数
    self:InitActBtnActiveState()
    self:InitMoogleMoveState()
    --- 初始化创建球的分布数据
    local EnterStateParams = self:GetParamsByGameState(MiniGameStageType.Enter)
    if not EnterStateParams then
        return
    end

    local BallList = EnterStateParams.BallList
    self.BallList = BallList
    self.BallNum = #BallList
    self.bInExtraRound = false
end

--- 翻倍重新开始数据整理
function MiniGameMooglesPaw:OnGameRestart()
    local RestartParams = self:GetParamsByGameState(MiniGameStageType.Restart)
    if not RestartParams then
        return
    end
    local OldBallList = self.BallList
    if not OldBallList then
        FLOG_ERROR("MiniGameMooglesPaw:OnGameRestart Last Ball Distribution Data Have Been Cleared")
        return
    end
    local BallList = RestartParams.BallList
    self.BallList = BallList
    self.BallNum = #BallList
    self:InitActBtnActiveState()
    self:InitMoogleMoveState()
end

--- 奖励结算数据整理
function MiniGameMooglesPaw:OnGameReward()

end

--- 是否有难度选择阶段
function MiniGameMooglesPaw:OnIsGameHaveDifficultySelect()
    return false
end

--- 是否结束游戏
function MiniGameMooglesPaw:OnIsGameRunEnd()
	local AchievedProgress = self.AchieveRewardProgress
	if AchievedProgress >= 1 then
		self.RoundEndState = MiniGameRoundEndState.Success
		return true
    elseif AchievedProgress == -1 then
        self.RoundEndState = MiniGameRoundEndState.FailRule
        return true
	end

    local bBless = self:IsBless()
    if bBless then
        -- 赐福模式才进行球的数量计算
        local BallNum = self.BallNum
        if BallNum <= 0 then
            self.RoundEndState = MiniGameRoundEndState.None
            return true
        end
    end

	local RemainTime = self.RemainSeconds
	if RemainTime <= 0 then
        if bBless then
            self.RoundEndState = MiniGameRoundEndState.None
        else
            self.RoundEndState = MiniGameRoundEndState.FailTime
        end
		return true
	end
	return false
end

--- 是否抓住球
function MiniGameMooglesPaw:CatchTheBall(BallID)
	self.CaughtBallID = BallID or 0
    local bCaughtBySev = BallID > 0
	self.bCaught = bCaughtBySev and MoogleBallCaughtState.Caught or MoogleBallCaughtState.NotCaught
    if bCaughtBySev then
        -- 抓中小球后更新轮次分数
        local RoundID = self:GetCurRoundId()
        self:UpdateRoundScoreList(RoundID, BallID)
        self.BallNum = self.BallNum - 1
        local Ball = self:GetTheBall(BallID)
        if Ball then
            self.CatchBallType = Ball.BallType or MogulBallType.MogulBallTypeInvalid
        end
    end
	local GameType = self.MiniGameType
	MiniGameVM:UpdateDetailMiniGameVM(GameType)
    self.bInViewShowProcess = true
    self.LatestProgressLv = BallID > 0 and MiniGameProgressType.Perfect or MiniGameProgressType.Bad
    self:UpdateDynAssetState()
end

--- 重置抓住球的参数
function MiniGameMooglesPaw:ResetCaughtBall()
	self.bCaught = MoogleBallCaughtState.None
    self.CaughtBallID = 0
end

--- 更新客户端每局分数
function MiniGameMooglesPaw:UpdateRoundScoreList(RoundID, BallID)
    local RoundScore, BallType = self:GetActualRoundScore(RoundID, BallID)
    local bBless = self:IsBless()
    if BallType == MogulBallType.MogulBallTypeStar and bBless then
        self.StarBallCatchNum = self.StarBallCatchNum + 1
        self.StarBallCatchTotalScore = self.StarBallCatchTotalScore + RoundScore
    end
    self:AddRoundScoreByRoundId(RoundID, RoundScore)
    if bBless then
        -- 赐福阶段判断是否完成挑战
        local CurTotalScore = self:GetTotalRoundScore()
        local BlessCfg = MooglePawBlessCfg:FindCfgByKey(self.BlessKind)
        if BlessCfg then
            local TargetScore = BlessCfg.StrengthValue or 0
            local bChallengeSuccess = CurTotalScore >= TargetScore
            self:SetIsBlessChallengeSuccess(bChallengeSuccess)
            if bChallengeSuccess then
                local ExtraReward = BlessCfg.Reward or 0
                self:AddRoundScoreByRoundId(RoundID, ExtraReward)
            end
        end
    end
end

--- 获取抓住球的结果
---@return bCaught, CaughtBallID @抓取成功与否，抓取的球的ID
function MiniGameMooglesPaw:GetTheCatchBallResult()
    return self.bCaught, self.CaughtBallID
end

--- 抓取表现结束后推进游戏进程
function MiniGameMooglesPaw:PushGameProcessAfterCatchResultShow()
    local bCaught = self:GetTheCatchBallResult()
    local bBless = self:IsBless()
    self.bInViewShowProcess = false
    if not bBless then
        -- 非赐福状态才直接触发游戏结束
        if bCaught == MoogleBallCaughtState.Caught then
            self.AchieveRewardProgress = 1
        elseif bCaught == MoogleBallCaughtState.NotCaught then
            self.AchieveRewardProgress = -1
        end
    end
    self:ResetCaughtBall() -- 确保只出现一次抓取结果表现
end

--- 是否带有额外阶段
function MiniGameMooglesPaw:OnIsHaveExtraStage()
    -- 大赐福且挑战成功才开启额外回合
    if self:IsBigBlessMode() and not self.bInExtraRound then
        return true
    end
    return false
end

--- 是否带有翻倍阶段
function MiniGameMooglesPaw:OnIsHaveRestartStage()
    if self:IsBless() then --赐福模式不含有翻倍阶段
        return false
    end
    local GameType = self.MiniGameType
    local Cfg = MiniGameClientConfig[GameType]
    if Cfg then
        local ExtraReset = Cfg.ExtraReset
        return ExtraReset ~= nil
    end
end

--- 翻倍挑战提示参数
function MiniGameMooglesPaw:OnCreateRestartContentParams()
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
    local Rlt = {
        GameType = self.MiniGameType,
        RemainTime = self.RemainSeconds,
        RemainChances = self.MaxRound - RoundIndex - 1,
        NextRound = RoundIndex + 2,
        TotalRound = self.MaxRound,
        BaseReward = self:GetTheRewardGotInTheRoundInternal(0),
        CurReward = self:GetTheRewardGotInTheRoundInternal(RoundIndex),
        NextReward = self:GetTheRewardGotInTheRoundInternal(RoundIndex + 1),
    }
    self.CatchBallType = nil
    return Rlt
end

--- 获取游戏翻倍挑战重置时间和次数(增加赐福相关逻辑)
function MiniGameMooglesPaw:GetRestartTimeAndChances()
	local Time = 0
	local Chances = 0

    local bBless = self:IsBless()
    local MiniGameType = self.MiniGameType
    if not MiniGameType then
        FLOG_ERROR("MiniGameMooglesPaw:GetRestartTimeAndChances MiniGameType is not valid")
        return Time, Chances
    end
    if not bBless then
        local DCfg = self.DefineCfg
        if DCfg then
            Time = DCfg.TimeLimit or 0
        end
    else
        -- 只处理普通回合时间，额外回合（大赐福）单独处理
        local BlessKind = self.BlessKind
        local BlessCfg = MooglePawBlessCfg:FindCfgByKey(BlessKind)
        if BlessCfg then
            Time = BlessCfg.OverrideTime or BlessExtraTimeDefault
        end
    end
	
	return Time, Chances
end

--- 获取当前轮能够获得的奖励(以红球奖励为基准)
function MiniGameMooglesPaw:GetTheRewardGotInTheRoundInternal(Round)
    local RoundIDList = self.RoundIdList
    if not RoundIDList then
        return 0
    end

    local RoundId = RoundIDList[Round + 1]
    if not RoundId then
        return 0
    end

    return self:GetBallTypeRoundScore(RoundId, self.CatchBallType)
end

--- 获取当前轮能够获得的奖励
function MiniGameMooglesPaw:GetTheRewardGotInTheRound()
	local CurRound = self:GetRoundIndex()
    return self:GetTheRewardGotInTheRoundInternal(CurRound)
end

--- 获取当前轮数ID
function MiniGameMooglesPaw:GetCurRoundId()
    local CurRound = self:GetRoundIndex()
    local RoundIDList = self.RoundIdList
    if not RoundIDList then
        return
    end

    local RoundId = RoundIDList[CurRound + 1]
    return RoundId
end

--- 获取当前莫古力ID
function MiniGameMooglesPaw:GetCurMoogleID()
    local RoundId = self:GetCurRoundId()
    if not RoundId then
        return
    end

    local RoundCfg = RoundControlCfg:FindCfgByKey(RoundId)
    if not RoundCfg then
        return
    end

    local MoogleID = RoundCfg.MoogleID
    if not MoogleID then
        return
    end

    return MoogleID
end

--- 获取特定球的服务器信息
function MiniGameMooglesPaw:GetTheBall(BallID)
    if not BallID or type(BallID) ~= "number" then
        return
    end
    local CurBallList = self.BallList
    if not CurBallList then
        return
    end
    local Ball = table.find_by_predicate(CurBallList, function(e)
        return e.BallID == BallID
    end)

    return Ball
end

--- 新增轮数分数(赐福模式并非单次抓取即结束)
function MiniGameMooglesPaw:AddRoundScoreByRoundId(RoundId, RoundScore)
    local RoundScoreList = self.RoundScoreList or {}
    local ExistRoundScore = RoundScoreList[RoundId]
    if ExistRoundScore then
        RoundScoreList[RoundId] = ExistRoundScore + RoundScore
    else
        RoundScoreList[RoundId] = RoundScore
    end
    self.RoundScoreList = RoundScoreList
end

function MiniGameMooglesPaw:GetBallTypeRoundScore(RoundId, BallType)
    local RoundCfg = RoundControlCfg:FindCfgByKey(RoundId)
	if not RoundCfg then
        return 0
    end
  
    local BaseScore = 0
    if BallType == MogulBallType.MogulBallTypeBlue then
        BaseScore = RoundCfg.BlueReward
    elseif BallType == MogulBallType.MogulBallTypeOrange then
        BaseScore = RoundCfg.OrangeReward
    elseif BallType == MogulBallType.MogulBallTypeRed then
        BaseScore = RoundCfg.RedReward
    elseif BallType == MogulBallType.MogulBallTypeStar then
        BaseScore = RoundCfg.StarReward
    end
    --[[local BallTypeCfg = MooglePawBallCfg:FindCfgByKey(BallType)
    if BallTypeCfg then
        return BaseScore + BallTypeCfg.RewardNum or 0
    end--]]
    return BaseScore
end

--- 获取实际获取货币奖励
---@param RoundId number@轮次id
---@param BallId number@球号id
function MiniGameMooglesPaw:GetActualRoundScore(RoundId, BallId)
    local Ball = self:GetTheBall(BallId)
    if not Ball then
        return 0
    end

    local BallType = Ball.BallType
    return self:GetBallTypeRoundScore(RoundId, BallType), BallType
end

--- 获取特定轮数的分数
function MiniGameMooglesPaw:GetRoundScoreByIndex(RoundIndex)
    if self:IsBless() then
        if not self:IsBlessChallengeSuccess() then
            local StarInteractReward = self.StarBallCatchTotalScore or 0
            return StarInteractReward
        else
            local PreviewReward = self.StarBallCatchTotalScore or 0
            local BlessCfg = MooglePawBlessCfg:FindCfgByKey(self.BlessKind)
            if BlessCfg then
                PreviewReward = PreviewReward + BlessCfg.Reward
            end
            return PreviewReward
        end
    end

    local RoundIDList = self.RoundIdList
    if not RoundIDList then
        return
    end

    local RoundId = RoundIDList[RoundIndex + 1]
    if not RoundId then
        return
    end

    local RoundScoreList = self.RoundScoreList
    if not RoundScoreList then
        return
    end
    return RoundScoreList[RoundId]
end

--- 获取最终的分数
function MiniGameMooglesPaw:GetTotalRoundScore()
    local RoundIDList = self.RoundIdList
    if not RoundIDList or not next(RoundIDList) then
        return
    end

    local RoundScoreList = self.RoundScoreList
    if not RoundScoreList  then
        return
    end
    local ResultScore = 0
    local bBless = self:IsBless()
    if not bBless then
        -- 非赐福只算最后一轮分数
        local LastRoundID = RoundIDList[#RoundIDList]
        ResultScore = RoundScoreList[LastRoundID]
    else
        -- 赐福为所有回合获得的分数总和
        for _, value in ipairs(RoundIDList) do
            local RoundScore = RoundScoreList[value]
            if RoundScore then
                ResultScore = RoundScore + ResultScore
            end
        end
    end
   
    return ResultScore
end

--- 获取莫古力的初始速度
function MiniGameMooglesPaw:GetTheMotionInitSpeed()
    local MoogleID = self:GetCurMoogleID()
    if not MoogleID then
        return
    end

    local MoogleCfg = MooglePawTypeCfg:FindCfgByKey(MoogleID)
    if not MoogleCfg then
        return
    end
    local InitSpeed = MoogleCfg.InitSpeed
    return InitSpeed
end

--- 获取莫古力的速度倍率
function MiniGameMooglesPaw:GetTheMotionSpeedTimes()
    local BaseMoogleSpeed = self.BaseMoogleSpeed
    if not BaseMoogleSpeed or BaseMoogleSpeed == 0 then
        return
    end
    local CurSpeed = self:GetTheMotionInitSpeed()
    if not CurSpeed then
        return
    end

    return CurSpeed / BaseMoogleSpeed
end

--- 获取莫古力的移动方向
---@return MoogleMoveDir@莫古力的移动方向
function MiniGameMooglesPaw:GetMoogleMoveDir()
    return self.MoogleMoveDir
end

--- 获取莫古力的移动状态
---@return MoogleMoveState@莫古力的移动状态
function MiniGameMooglesPaw:GetMoogleMoveState()
    return self.MoogleMoveState
end

--- 设定莫古力的移动状态
---@return MoogleMoveState@莫古力的移动状态
function MiniGameMooglesPaw:SetMoogleMoveStateIdle()
    if self.MoogleMoveState == MoogleMoveState.Idle then
        return
    end
    self.MoogleMoveState = MoogleMoveState.Idle
end


--- 计算减速运动持续时间和运动的加速度
---@param LinearMotionDis number@匀速运动的距离
function MiniGameMooglesPaw:CalculateSlowDownTimeAndAcceleration(LinearMotionDis)
    local MoogleID = self:GetCurMoogleID()
    if not MoogleID then
        return
    end

    local MoogleCfg = MooglePawTypeCfg:FindCfgByKey(MoogleID)
    if not MoogleCfg then
        return
    end
    local InitSpeed = MoogleCfg.InitSpeed
    if not InitSpeed then
        return
    end

    local FixedMotionValue = MoogleCfg.FixedValue
    if not FixedMotionValue then
        return
    end

    local FixedMultpilier = MoogleCfg.FixedMultpilier and MoogleCfg.FixedMultpilier / 10000 or 1
    local SlowDownDis = FixedMotionValue + LinearMotionDis * FixedMultpilier
    
	local Acceleration = MathUtil.GetAccelerationInDecelerationMotion(SlowDownDis, InitSpeed)
    if not Acceleration then
        return
    end

    local ConstantTime = math.abs(InitSpeed / Acceleration) 
    return ConstantTime, Acceleration
end

--- 获取当前轮莫古力的移动距离
---@return Dis number@方向，距离
function MiniGameMooglesPaw:GetTheMotionDisInTheRound()
    if self.MoogleMoveState == MoogleMoveState.OutGame then
        return
    end
    local ActBtnPressState = self:GetActBtnPressState()
    local LastDis = self.LinearMotionDisCount or 0
    local TickTime = GoldSaucerMiniGameDefine.MiniGameTickInterval
    local InitSpeed = self:GetTheMotionInitSpeed() or 0
    local LastDir = self.MoogleMoveDir or MoogleMoveDir.Idle
    if ActBtnPressState then
        -- 匀速运动阶段
        local TickDis = InitSpeed * TickTime
        self.LinearMotionDisCount = LastDis + TickDis
        self.MoogleMoveState = MoogleMoveState.LinerMove
        return self.LinearMotionDisCount
    else
        -- 减速运动阶段
        local CountMoveTime = self.SlowDownTimeCount or 0
        local TotalMoveTime = self.SlownDownConstantTime or 0
        if CountMoveTime < TotalMoveTime then
            -- 处于减速阶段中
            if LastDir == MoogleMoveDir.Horizontal then
                self.MoogleMoveState = MoogleMoveState.LowSpeedMoveH
            elseif LastDir == MoogleMoveDir.Vertical then
                self.MoogleMoveState = MoogleMoveState.LowSpeedMoveV
            end

            local Acceleration = self.SlowDownAcceleration
            CountMoveTime = CountMoveTime + TickTime
            local SlowDownDis = MathUtil.GetMotionDisInDecelerationMotion(InitSpeed, CountMoveTime, Acceleration) or 0
            self.SlowDownTimeCount = CountMoveTime
            return LastDis + SlowDownDis
        else
            -- 减速阶段结束停止
            if LastDir == MoogleMoveDir.Horizontal then -- 水平移动到减速停止时激活垂直移动按钮
                self:ChangeActBtnTypeActive(MoogleActBtnActiveType.Vertical)
            elseif LastDir == MoogleMoveDir.Vertical then
                -- 发送判定是否抓住的协议
                EventMgr:SendEvent(EventID.DetailMooglePawsEndMove)
            end
            self:InitMoogleMoveState(true)
            return 0
        end
    end
end

--- 检测客户端的最近球体的判断
function MiniGameMooglesPaw:FindTheBallNearest(PosX, PosY)
    local BallList = self.BallList
    if not BallList or not next(BallList) then
        return
    end

    local NearestBallID = 0
    local NearestBallDis = -1
    for _, value in ipairs(BallList) do
        local BallX = value.PosX
        local BallY = value.PosY
        local Dis = math.sqrt((PosX - BallX) * (PosX - BallX) + (PosY - BallY) * (PosY - BallY))
        if NearestBallDis == -1 or Dis < NearestBallDis then
            NearestBallID = value.BallID
            NearestBallDis = Dis
            FLOG_INFO("Msg = 505 FindTheBallNearestLoop ID = %s, PosX = %s, PosY = %s", tostring(NearestBallID), tostring(BallX), tostring(BallY))
        end
    end
    FLOG_INFO("Msg = 505 FindTheBallNearest ID = %s, Dis = %s", tostring(NearestBallID), tostring(NearestBallDis))
    
end

--- 控制按钮按下
function MiniGameMooglesPaw:OnActBtnPressDown()
    local ActBtnPressState = self.bActBtnPressed
    if ActBtnPressState then
        return  -- 非抬起状态不再接受按下事件
    end

    self.bActBtnPressed = true
    if self.ActBtnActiveType == MoogleActBtnActiveType.Horizontal then
        self.MoogleMoveDir = MoogleMoveDir.Horizontal
    elseif self.ActBtnActiveType == MoogleActBtnActiveType.Vertical then
        self.MoogleMoveDir = MoogleMoveDir.Vertical
    else
        self.MoogleMoveDir = MoogleMoveDir.Idle
    end
end

--- 控制按钮抬起
function MiniGameMooglesPaw:OnActBtnPressUp()
    local ActBtnPressState = self.bActBtnPressed
    if not ActBtnPressState then
        return  -- 非按下状态不再接受抬起事件
    end
    self:ChangeActBtnTypeActive(MoogleActBtnActiveType.Invalid) -- 抬起后按钮进入不可操作状态等待惯性减速运动阶段结束
    self.bActBtnPressed = false
    local Time, Acceleration = self:CalculateSlowDownTimeAndAcceleration(self.LinearMotionDisCount)
    self.SlownDownConstantTime = Time or 0
    self.SlowDownAcceleration = Acceleration or 0
end

--- 获取当前可行动按钮的状态
function MiniGameMooglesPaw:GetActBtnPressState()
    return self.bActBtnPressed
end

--- 切换可以操作的按钮类型
---@param MoogleActBtnActiveType MoogleActBtnActiveType@激活的操作按钮状态
function MiniGameMooglesPaw:ChangeActBtnTypeActive(MoogleActBtnActiveType)
    local OldActBtnActiveType = self.ActBtnActiveType
    if OldActBtnActiveType ~= MoogleActBtnActiveType then
        self.ActBtnActiveType = MoogleActBtnActiveType
        MiniGameVM:UpdateDetailMiniGameVM(MiniGameType.MooglesPaw)
    end
end

--- 切换可以操作的按钮类型
---@return MoogleActBtnActiveType@激活的操作按钮状态
function MiniGameMooglesPaw:GetActBtnTypeActive()
    return self.ActBtnActiveType
end

--- 退出时重置游戏信息（for再战） 
function MiniGameMooglesPaw:Reset()
    self:ResetGameInfo()
    self.RoundIdList = nil
    self.RoundScoreList = nil -- 单局分数
end

--- 额外阶段数据重置(赐福)
function MiniGameMooglesPaw:OnGameExtraRound()
    if self:IsBigBlessMode() then
        -- 修改额外回合时间
        local BlessKind = self.BlessKind
        if not BlessKind then
            return
        end
        local BlessCfg = MooglePawBlessCfg:FindCfgByKey(BlessKind)
        if not BlessCfg then
            return
        end
        self.RemainSeconds = BlessCfg.BlessExtraTime or BlessExtraTimeDefault
        self:InitMoogleMoveState()
        self:InitActBtnActiveState()
    end
end

--- 额外阶段
function MiniGameMooglesPaw:OnGameExtraRoundStart()
    if not self:IsBigBlessMode() then
       return
    end
  
    local GameType = self.MiniGameType
    if not GameType then
        return
    end
 
    local BallList = self:GetParamsByGameState(MiniGameStageType.ExtraRound)
    if not BallList then
        return
    end
    local OldBallList = self.BallList
    if not OldBallList then
        FLOG_ERROR("MiniGameMooglesPaw:OnGameRestart Last Ball Distribution Data Have Been Cleared")
        return
    end
    
    self.BallList = BallList
    self.BallNum = #BallList
    self.bInExtraRound = true
end

--- 获取特殊球体抓取数量
function MiniGameMooglesPaw:GetStarInteractorCatchNum()
    return self.StarBallCatchNum or 0
end

--- 获取特殊球体抓取累计奖励
function MiniGameMooglesPaw:GetStarInteractorCatchTotalScore()
    return self.StarBallCatchTotalScore or 0
end

return MiniGameMooglesPaw