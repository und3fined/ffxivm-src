local LuaClass = require("Core/LuaClass")
local MiniGameBase = require("Game/GoldSaucerMiniGame/MiniGameBase")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local CuffRoundCfg = require("TableCfg/CuffRoundCfg") -- 
local CuffStrengthStageCfg = require("TableCfg/CuffStrengthStageCfg")
local CuffInteractiveCfg = require("TableCfg/CuffInteractiveCfg") -- 
local CuffRewardCfg = require("TableCfg/CuffRewardCfg")
local CuffBatterCfg = require("TableCfg/CuffBatterCfg")
local CuffParamCfg = require("TableCfg/CuffParamCfg")
local CuffBlessCfg = require("TableCfg/CuffBlessCfg")
local CuffDifficultyCfg = require("TableCfg/CuffDifficultyCfg")
local FairyBlessedTargetCfg = require("TableCfg/FairyBlessedTargetCfg")

local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameVM = require("Game/GoldSaucerMiniGame/MiniGameVM")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local PWorldMgr = require("Game/PWorld/PWorldMgr")
local MiniGameCuffAudioDefine = require("Game/GoldSaucerMiniGame/Cuff/MiniGameCuffAudioDefine")
local AudioUtil = require("Utils/AudioUtil")

local AudioName = MiniGameCuffAudioDefine.AudioName
local AudioPath = MiniGameCuffAudioDefine.AudioPath
local InteractionCategory = ProtoRes.InteractionCategory
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local AnimTimeLineSourceKey = GoldSaucerMiniGameDefine.AnimTimeLineSourceKey
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local CenterBlowID = GoldSaucerMiniGameDefine.CuffDefine.CenterBlowID
local GilgameshParamType = ProtoRes.Game.GilgameshParamType
local BLESSED_KIND = ProtoCS.Game.FairyBlessed.BLESSED_KIND
local BigBlessSuccessIconPath = GoldSaucerMiniGameDefine.BigBlessSuccessIconPath
local BigBlessFailIconPath = GoldSaucerMiniGameDefine.BigBlessFailIconPath
local LittleBlessSuccessIconPath = GoldSaucerMiniGameDefine.LittleBlessSuccessIconPath
local LittleBlessFailIconPath = GoldSaucerMiniGameDefine.LittleBlessFailIconPath
local BlessSuccessItemBg = GoldSaucerMiniGameDefine.BlessSuccessItemBg
local BlessFailItemBg = GoldSaucerMiniGameDefine.BlessFailItemBg
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local TimerMgr = _G.TimerMgr
local UE = _G.UE
local EffectUtil = require("Utils/EffectUtil")

local ActorUtil = require("Utils/ActorUtil")

local RaceType = ProtoCommon.race_type

local UIViewID = require("Define/UIViewID")
local EffectAssetPath = {
    "ParticleSystem'/Game/Assets/Effect/Particles/JDYLC/ZJJMS/PS_C_1_3_Rota.PS_C_1_3_Rota'",
    "ParticleSystem'/Game/Assets/Effect/Particles/JDYLC/ZJJMS/PS_C_1_3_Rota_UP.PS_C_1_3_Rota_UP'"
}




---@class MiniGameCuff
---@param MiniGameType number @GoldSaucerMiniGameDefine.MiniGameType
local MiniGameCuff = LuaClass(MiniGameBase)

---Ctor
function MiniGameCuff:Ctor()
    local Type = MiniGameType.Cuff
    self.DynAssetID = nil --5360362
    self.MaxRound = 4 -- 最大四轮
	self.MiniGameType = Type
    self.Name = MiniGameClientConfig[Type].Name
    self.UIViewMainID = UIViewID.GoldSaucerCuffMainPanel
    self.PowerValue = 0 -- 当前总力量值
    self.StrengthPro = 0 -- 力量值进度条
    self.CurStrengthStage = 1
    self.CuffScore = 0 -- 一次交互获取的力量值
    self.ScoreByInteractItemType = 0 -- 一次交互获取的力量值所属交互Item
    self.bCuffScoreVisible = false -- 一次交互获取的力量值显隐
    self.bPanelNormalVisible = true
    self.bPanelResultVisible = false
    self.bFailed = false
    self.bSuccessed = false
    self.TextMultiple = ""
    self.MultipleNum = 1
    self.bTextMultipleVisible = false
    self.MaxComboNum = 0    
    self.CurRoundBlowNum = 0 -- 当前轮数出现的交互物数量
    self.ComboNum = 0  -- 完美连击数
    self.NextRoundInteractionCfg = {} -- 下一轮交互物配置数据
    self.ResultText = ""
    self.RewardGot = 0
    self.StrengthValue = 0  -- 记录真是力量值
    self.TextStrengthValue = 0 -- 用于显示力量值
    self.RoundEndState = MiniGameRoundEndState.None -- 結束的原因
    self.TextHint = ""
    self.bTextHintVisible = false
    self.JDCoinColor = "#FFFFFF"
    self.RightBtnContent = LSTR(250001) -- 再 战
    self.bEnterEndState = false
    self.CuffAddRewardGot = 0
    self.EndEmotionID = 0
    self.WindEffectID = nil
    self.FireEffectID = nil
    self.StrengthStageData = {}
    self.CurStrengthStageCfg = {}
    self.IsBegin = false
    self.CriticalText = ""
    self.bCriticalVisible = false
    self.bCriticalHit = false
    self.RewardNumByInter = 0               -- 通过交互获得的金碟币
    self.IdleStateKey = AnimTimeLineSourceKey.CuffIdle
    local DefineCfg = MiniGameClientConfig[Type]
    if DefineCfg then
        self.DefineCfg = DefineCfg
    end
    self.RewardCfg = {}
    self.bPlayPunchAnim = false
    self.WaitAnimTime = 0
    self.BlowAnimTime = 1.33
    self.IsFightAgain = false
    self.PunchWindVfxStage = 0
    self.CuffGameState = DefineCfg.EGameState.InGame

    self.bPlayerActed = false -- 玩家是否操作过

    self.BlessInteractorNumGot = 0
end

function MiniGameCuff:Reset()
    local Type = MiniGameType.Cuff
    -- self.DynAssetID = 5360362
	self.MiniGameType = Type
    self.Name = MiniGameClientConfig[Type].Name
    self.UIViewMainID = UIViewID.GoldSaucerCuffMainPanel
    self.PowerValue = 0 -- 当前总力量值
    self.StrengthPro = 0 -- 力量值进度条
    self.CurStrengthStage = 1
    self.CuffScore = 0 -- 一次交互获取的力量值
    self.bCuffScoreVisible = false -- 一次交互获取的力量值显隐
    self.bPanelNormalVisible = true
    self.bPanelResultVisible = false
    self.bFailed = false
    self.bSuccessed = false
    self.TextMultiple = ""
    self.MultipleNum = 1
    self.bTextMultipleVisible = false
    self.MaxComboNum = 0    
    self.CurRoundBlowNum = 0 -- 当前轮数出现的交互物数量
    self.ComboNum = 0  -- 完美连击数
    self.NextRoundInteractionCfg = {} -- 下一轮交互物配置数据
    self.ResultText = ""
    self.RewardGot = 0
    self.StrengthValue = 0
    self.TextStrengthValue = 0
    self.RoundEndState = MiniGameRoundEndState.None
    self.TextHint = ""
    self.bTextHintVisible = false
    self.JDCoinColor = "#FFFFFF"
    self.RightBtnContent = LSTR(250001)  --再 战
    self.bEnterEndState = false
    self.IsBegin = false
    self.CuffAddRewardGot = 0
    self.EndEmotionID = 0
    self.FireEffectID = nil
    self.WindEffectID = nil
    self.CriticalText = ""
    self.bCriticalVisible = false
    self.bCriticalHit = false
    self.RewardNumByInter = 0

    -- self.StrengthStageData = {}
    -- self.CurStrengthStageCfg = {}

    self.IdleStateKey = AnimTimeLineSourceKey.CuffIdle
    local DefineCfg = MiniGameClientConfig[Type]
    if DefineCfg then
        self.DefineCfg = DefineCfg
    end
    self.bPlayPunchAnim = false
    self.WaitAnimTime = 0
    self.IsFightAgain = false
    self.CuffGameState = DefineCfg.EGameState.InGame

    self:InitMiniGame()
    self.PunchWindVfxStage = 0

    self.bPlayerActed = false

    self.BlessInteractorNumGot = 0
    self.bResultPanelShow = false
end

--- 初始化游戏数据
function MiniGameCuff:LoadTableCfg()
    self.RewardCfg = CuffRewardCfg:FindAllCfg()

    local RaceID = MajorUtil.GetMajorRaceID()
    local RaceIndex
    if RaceID == RaceType.RACE_TYPE_Lalafell then
        RaceIndex = 1                               -- 策划说写死行了
    elseif RaceID == RaceType.RACE_TYPE_Roegadyn then
        RaceIndex = 2
    else
        RaceIndex = 3
    end
    local SearchCond = "(StageID - StageID % 100) / 100 == "..tostring(RaceIndex)
    self.StrengthStageData = CuffStrengthStageCfg:FindAllCfg(SearchCond)
    self.CurStrengthStageCfg = self.StrengthStageData[1]

    self:PlayFireEffect(true)
end

function MiniGameCuff:GetPlayerActed()
   return self.bPlayerActed
end

function MiniGameCuff:ChangeGameStateToEnd()
    self.CuffGameState = self.DefineCfg.EGameState.End
end

function MiniGameCuff:GetCuffGameState()
    return self.CuffGameState
end

function MiniGameCuff:SetFightAgain(IsFightAgain)
    self.IsFightAgain = IsFightAgain
end


function MiniGameCuff:GetStrengthStageCfg()
    return self.CurStrengthStageCfg
end

function MiniGameCuff:IsPlayPunchAct(bPlayPunchAct)
    self.bPlayPunchAnim = bPlayPunchAct
end

function MiniGameCuff:CuffSetCritical(bCritical)
    local Cfg = CuffParamCfg:FindCfgByKey(GilgameshParamType.GilgameshParamTypeCriticalHitTimes)
    if not Cfg then
        return
    end
    
    self.CriticalText = string.format(LSTR(250002), Cfg.Value) -- %s倍暴击
    self.bCriticalVisible = bCritical
    self.bCriticalHit = bCritical
    local Anim = self.DefineCfg.Anim
    if bCritical then
        _G.EventMgr:SendEvent(_G.EventID.MiniGameMainPanelPlayAnim, Anim.Critical)
    end
end

--- 初始化游戏数据
function MiniGameCuff:InitMiniGame()
    local ResetTime = self:GetRestartTimeAndChances()
    self.RemainSeconds = ResetTime
    local RTPCName = MiniGameCuffAudioDefine.RTPCName
    self:PlaySoundWithPostEvent(AudioName.PlayFistSwish, RTPCName.SpeedTwirl, 0)
end


function MiniGameCuff:GetIdlePathByRaceID()
    local RaceID = MajorUtil.GetMajorRaceID()
    local IdlePath = self.DefineCfg.IdlePath
	return IdlePath[RaceID]
end

function MiniGameCuff:GetRewardCfg()
    return self.RewardCfg
end

function MiniGameCuff:GetMaxRound()
    return self.MaxRound
end

--- @type 增加力量值
function MiniGameCuff:AddStrengthValue(Value, bShow)
    local NewStrengthValue = math.clamp(self.StrengthValue + Value, 0, 9999999)
    self.StrengthValue = NewStrengthValue
    if self:IsBless() then
        local BlessKind = self.BlessKind
        local BlessCfg = CuffBlessCfg:FindCfgByKey(BlessKind)
        if BlessCfg then
            local ChallengeTarget = BlessCfg.StrengthValue or 0
            if NewStrengthValue >= ChallengeTarget then
                self:SetIsBlessChallengeSuccess(true)
            end
        end
    end
 
    if bShow then
        self.TextStrengthValue = self.TextStrengthValue + Value
    end
end

--- @type 获得当前力量值
function MiniGameCuff:GetStrengthValue()
    return self.StrengthValue
end

--- @type 获得需要显示的力量值
function MiniGameCuff:GetTextStrengthValue()
    return self.TextStrengthValue
end

--- @type 增加连击数
function MiniGameCuff:AddComboNum(Num)
    self.ComboNum = self.ComboNum + Num
    if self.ComboNum > self.MaxComboNum then
        self:SetMaxComboNum(self.ComboNum)
    end
end

--- @type 设置最大连击数
function MiniGameCuff:SetMaxComboNum(Num)
    self.MaxComboNum = Num
end

function MiniGameCuff:GetMaxComboNum()
    return self.MaxComboNum
end

--- @type 获得连击数
function MiniGameCuff:GetComboNum()
    return self.ComboNum
end

--- @type 重置连击数
function MiniGameCuff:ResetComboNum()
    self.ComboNum = 0
end

function MiniGameCuff:UpdateStrengthPro(AddScore)
    local PowerTop = GilgameshParamType.GilgameshParamTypePowerTop
    local Cfg = CuffParamCfg:FindCfgByKey(PowerTop)
    if Cfg == nil then
        return
    end

    local DefineCfg = self.DefineCfg
    if not DefineCfg then
        return
    end

    local MaxProValue = Cfg.Value

    if self.AddProTimer ~= nil then
        TimerMgr:CancelTimer(self.AddProTimer)
    end

    local LastStrength = self:GetStrengthValue()
    local TotalPercent = (AddScore + LastStrength) / MaxProValue

    -- 暂定播放速度比例
    local PercentChangeTimeMulti = {
        [1] = 1.2,
        [2] = 1.5
    }

    -- 进度条变化百分比
    local PercentLimitChange = DefineCfg.PercentLimitChange
    if not PercentLimitChange then
        return
    end

    local TargetMulti = 1
    if TotalPercent > PercentLimitChange[1] then
        TargetMulti = PercentChangeTimeMulti[1]
    elseif TotalPercent > PercentLimitChange[2] then
        TargetMulti = PercentChangeTimeMulti[2]
    end

    local ViewModel = MiniGameVM:GetDetailMiniGameVM(self.MiniGameType)
    local TotleTime = 0.8 / TargetMulti
    local LoopNum = TotleTime / 0.05
    local AddValue = AddScore / LoopNum

    local function LeroProBar()
        LastStrength = LastStrength + AddValue
        self.StrengthPro = math.clamp(LastStrength / MaxProValue, 0, 1)
        ViewModel:UpdateStrengthPro(self.StrengthPro)
    end
    self.AddProTimer = TimerMgr:AddTimer(self, LeroProBar, 0, 0.05, LoopNum)
    self:AddTimerHandle(self.AddProTimer)
end

function MiniGameCuff:SetTextHint(Text, bVisible)
    self.TextHint = Text
    self.bTextHintVisible = bVisible
end

--- @type 设置一次交互增加的力量值
function MiniGameCuff:SetCuffScoreAndVisible(Score, Type)
    self.ScoreByInteractItemType = Type
    self.CuffScore = Score
    self.bCuffScoreVisible = Score > 0
end

--- @type 隐藏加分的Text
function MiniGameCuff:SetCuffScoreVisibleFalse()
    self.bCuffScoreVisible = false
end

--- @type 设置当前轮次剩余交互物数量
function MiniGameCuff:SetBlowNum(Num)
    self.CurRoundBlowNum = Num
end

function MiniGameCuff:SetIsBegin(IsBegin)
    self.IsBegin = IsBegin
end

--- @type 获得当前轮次剩余交互物数量
function MiniGameCuff:GetBlowNum()   --
    return self.CurRoundBlowNum
end

--- @type 设置当前轮次剩余交互物数量
function MiniGameCuff:SetbShowMoneySlot(bVisible)
    self.bEnterEndState = bVisible
end

--- @type 根据剩余金碟币设置花费金碟币Text颜色和按钮内容
function MiniGameCuff:SetBtnContentAndJDCoinColor()
    local OwnJdCoinNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE) --持有的金碟币
    if OwnJdCoinNum >= 1 then
        self.JDCoinColor = "#FFFFFF"
        self.RightBtnContent = LSTR(250001) -- 再 战 
    else
        self.JDCoinColor = "#FF0000"
        self.RightBtnContent = LSTR(250003) -- 前往获取 
    end
end

--- @type 通过交互增加金碟币
function MiniGameCuff:AddRewardNum(Type, HitResult)
    local EnumInteractResult = GoldSaucerMiniGameDefine.InteractResult
    local bAddExtraReward = Type == InteractionCategory.CATEGORY_STARLIGHT and (HitResult == EnumInteractResult.Perfect or HitResult == EnumInteractResult.Excellent)
    or HitResult == EnumInteractResult.Perfect
	if bAddExtraReward then
        local InteractCfg = CuffInteractiveCfg:FindCfgByKey(Type)
        if not InteractCfg then
            return
        end
        self.RewardNumByInter = self.RewardNumByInter + InteractCfg.RewardNum
	end
end

--- @type 获取奖励
function MiniGameCuff:SetRewardGot(RewardCount)
    if RewardCount ~= nil and not self.bCriticalHit then
        self.RewardGot = RewardCount
        return
    end
    local BaseReward = self:GetBaseReward(true) or 0
    if not RewardCount then
        local LastRewardCount = self.RewardGot or 0
        local NewRewardCount = BaseReward + self.RewardNumByInter
        if self:IsBless() and self:IsBlessChallengeSuccess() then
            local BlessCfg = CuffBlessCfg:FindCfgByKey(self.BlessKind)
            if BlessCfg then
                NewRewardCount = NewRewardCount + BlessCfg.Reward or 0
            end
        end
        self.CuffAddRewardGot = NewRewardCount - LastRewardCount
        self.RewardGot = NewRewardCount
    else
        self.CuffAddRewardGot = RewardCount - BaseReward
        self.RewardGot = RewardCount
    end
end

--- 设定根据表格
function MiniGameCuff:GetBaseReward(bSetEmotionID)
    local RewardCfg = CuffRewardCfg:FindAllCfg()
    local ShowStrengthValue = self:GetTextStrengthValue() or 0
    local Multi = self.MultipleNum or 1
    local Score = self.bTextMultipleVisible and ShowStrengthValue * Multi or ShowStrengthValue
    for Index = #RewardCfg, 1, -1 do
        local Elem = RewardCfg[Index]
        if Elem then
            if Score >= Elem.Score then
                if bSetEmotionID then
                    self.EndEmotionID = Elem.EndEmotionID
                end
                return Elem.GoldCoin
            end
        end
    end
end

function MiniGameCuff:GetMainPanelRewardGot()
    if self:IsBless() then
        if not self:IsBlessChallengeSuccess() then
            return self.RewardNumByInter or 0
        else
            local PreviewReward = self.RewardNumByInter or 0
            local BlessCfg = CuffBlessCfg:FindCfgByKey(self.BlessKind)
            if BlessCfg then
                PreviewReward = PreviewReward + BlessCfg.Reward or 0
            end
            return PreviewReward
        end
     end
    return self.RewardGot
end

--- @type 获得当前获得金碟币的数量
function MiniGameCuff:GetRewardGot()
    if self:IsBless() and not self:IsBlessChallengeSuccess() then
        return 0
    else
        return self.RewardGot
    end
end

--- @type 获取交互获得的额外金碟币奖励
function MiniGameCuff:GetInteractRewarNum()
    return self.RewardNumByInter
end

function MiniGameCuff:MultiRewardGot()
    if self.bCriticalHit then
        local Cfg = CuffParamCfg:FindCfgByKey(GilgameshParamType.GilgameshParamTypeCriticalHitTimes)
        if Cfg then
            self.RewardGot = self.RewardGot * Cfg.Value
        end
    end
end

function MiniGameCuff:GetEndEmotionID()
    return self.EndEmotionID
end

--- @type 设置成功还是失败，该显示什么
function MiniGameCuff:SetSuccessOrFail(bSuccess, bTimeOut)
    local ResultCfg = GoldSaucerMiniGameDefine.ResultCfg
    self.bFailed = not bSuccess
    self.bSuccessed = bSuccess
    local NeedText, NeexColor
    if bSuccess then
        NeedText = ResultCfg.Success.Text
        NeexColor = ResultCfg.Success.TextColor
    elseif bTimeOut then
        NeedText = ResultCfg.TimeOut.Text
        NeexColor = ResultCfg.TimeOut.TextColor
    else
        NeedText = ResultCfg.Failed.Text
        NeexColor = ResultCfg.Failed.TextColor
    end
    self.ResultText = NeedText
end

--- @type 设置增加多少比例的力量值
function MiniGameCuff:SetTextMutiAndVisible(Scale)
    self.TextMultiple = string.format("×%s", Scale)
    self.MultipleNum = Scale
    self.bTextMultipleVisible = Scale > 1
    if self.bTextMultipleVisible then
        local DoubleTime = GilgameshParamType.GilgameshParamTypeDoubleTime
        local Cfg = CuffParamCfg:FindCfgByKey(DoubleTime)
        if Cfg == nil then
            return
        end
        local TimerHandle = TimerMgr:AddTimer(self, function() 
            self.bTextMultipleVisible = false
            self.TextStrengthValue = math.ceil(self.TextStrengthValue * Scale)
        end, Cfg.Value / 1000)

        self:AddTimerHandle(TimerHandle)
    end
end

--- @type 缓存下一轮的交互物数据(新增轮数逻辑，赐福阶段不止4轮)
function MiniGameCuff:InitNextRoundCfgs(RoundID, ApertureList)
    local Cfg = CuffRoundCfg:FindCfgByKey(RoundID)
    if Cfg == nil then
        return
    end
    self.CurRound = RoundID
    self:SetBlowNum(#ApertureList)
    local RoundIndex = RoundID % 1000
    local RoundDifficult = math.floor(RoundID / 1000)
    if RoundIndex == 1 then
        -- 首轮更新MaxRound数值
        local DifficultCfg = CuffDifficultyCfg:FindCfgByKey(RoundDifficult)
        if DifficultCfg then
            local TotalNum = 0
            local RoundIDList = DifficultCfg.RoundID or {}
            for _, RoundID in ipairs(RoundIDList) do
                if RoundID > 0 then
                    TotalNum = TotalNum + 1
                end
            end
            self.MaxRound = TotalNum
        end
    end
    local NextRoundInteractionCfg = {}  -- 下一轮交互物配置
    if RoundIndex ~= self.MaxRound then
        for i = 1, 9 do
            local InteractionData = {}
            for _, v in pairs(ApertureList) do
                local Elem = v
                if Elem.Pos == i then
                    InteractionData.Pos = Elem.Pos
                    InteractionData.Type = Cfg.Category[Elem.Index + 1]
                    InteractionData.DelayShowTime = Cfg.DelayShowTime[Elem.Index + 1]
                    InteractionData.DelayShrinkTime = Cfg.DelayShrinkTime[Elem.Index + 1]
                    local InteractiveCfg = CuffInteractiveCfg:FindCfgByKey(InteractionData.Type)
                    if Cfg ~= nil and InteractiveCfg ~= nil then
                        InteractionData.ShrinkSp = InteractiveCfg.ShrinkSp
                        InteractionData.Scale = InteractiveCfg.Scale
                    else
                        FLOG_ERROR("MiniGameCuff:InitNextRoundCfgs Type%s", InteractionData.Type)
                    end
                    InteractionData.bBlowResultVisible = false
                    InteractionData.bBtnVisible = false
                    break
                end
            end
            table.insert(NextRoundInteractionCfg, InteractionData)
        end
    else            --- 最后一轮
        NextRoundInteractionCfg.Pos = CenterBlowID
        NextRoundInteractionCfg.Type = Cfg.Category[ApertureList[1].Index + 1]
        NextRoundInteractionCfg.DelayShowTime = Cfg.DelayShowTime[ApertureList[1].Index + 1]
        NextRoundInteractionCfg.DelayShrinkTime = Cfg.DelayShrinkTime[ApertureList[1].Index + 1]
        local InteractiveCfg = CuffInteractiveCfg:FindCfgByKey(NextRoundInteractionCfg.Type)
        if Cfg ~= nil and InteractiveCfg ~= nil then
            NextRoundInteractionCfg.ShrinkSp = InteractiveCfg.ShrinkSp
            NextRoundInteractionCfg.Scale = InteractiveCfg.Scale
        else
            FLOG_ERROR("MiniGameCuff:InitNextRoundCfgs Type%s", NextRoundInteractionCfg.Type)
        end
        NextRoundInteractionCfg.bBlowResultVisible = false
        NextRoundInteractionCfg.bBtnVisible = true

    end
    self.NextRoundInteractionCfg = NextRoundInteractionCfg
end

function MiniGameCuff:ClearInteractionCfg()
    self.NextRoundInteractionCfg = {}
end

--- @type 检测是否完成当前轮次
function MiniGameCuff:CheckIsFinishRoundAndSend()
	local CurBlowNum = self:GetBlowNum()
	self:SetBlowNum(CurBlowNum - 1)

	if self:GetBlowNum() == 0 then
        local function ResetCallBack()
            -- local ViewModel = MiniGameVM:GetDetailMiniGameVM(self.MiniGameType)
            -- ViewModel:ResetAllSubViewVM()
            -- _G.EventMgr:SendEvent(EventID.MiniGameCuffHide)
        end

        -- _G.TimerMgr:AddTimer(self, ResetCallBack, 1, 0, 1)
        local RoundCDTime = GilgameshParamType.GilgameshParamTypeRoundCDTime
        local Cfg = CuffParamCfg:FindCfgByKey(RoundCDTime)
        if Cfg == nil then
            return
        end
       self.InteractTimer =  _G.TimerMgr:AddTimer(self, function() _G.GoldSaucerMiniGameMgr:SendMsgCuffInteractionReq() end, Cfg.Value + self.WaitAnimTime, 0, 1)
       self:AddTimerHandle(self.InteractTimer)
    end
end

function MiniGameCuff:UnRegisterTimer()
    if self.InteractTimer ~= nil then
        _G.TimerMgr:CancelTimer(self.InteractTimer)
    end
end

--- @type 刷新自己的VM
function MiniGameCuff:ConstructResultData(Pos, InteractResult, Type)
	local VMData = self:GetSubViewVMData(Pos)
    if VMData ~= nil then
        VMData.bBlowResultVisible = true	-- 显示结果
    end
	local ResultData = {}
	local EnumInteractResult = GoldSaucerMiniGameDefine.InteractResult

	local bPerfectVisible, bExcellentVisible, bFailVisible
	if InteractResult == EnumInteractResult.Fail then
		bPerfectVisible = false
		bExcellentVisible = false
		bFailVisible = true
	elseif InteractResult == EnumInteractResult.Excellent then
        if Type ~= InteractionCategory.CATEGORY_STARLIGHT then
            bPerfectVisible = false
            bExcellentVisible = true
            bFailVisible = false
        else
            local ComboNum = self:GetComboNum()
            if ComboNum == 1 then
                bPerfectVisible = true
                bExcellentVisible = false
                bFailVisible = false
                ResultData.bPerfectComboVisible = false
            elseif ComboNum > 1 and ComboNum < 10 then
                ResultData.bComboVisible = true
                ResultData.ComboNum = ComboNum
                bPerfectVisible = false
                bExcellentVisible = false
                bFailVisible = false
                ResultData.bPerfectComboVisible = true
            end
        end
	elseif InteractResult == EnumInteractResult.Perfect then
		local ComboNum = self:GetComboNum()
        -- local ComboCfg = CuffBatterCfg:FindCfgByKey(ComboNum)
        if ComboNum > 1 and ComboNum < 10 then -- 连击数大于1小于10
            ResultData.bComboVisible = true
            ResultData.ComboNum = ComboNum
            bPerfectVisible = false
            bExcellentVisible = false
            bFailVisible = false
            ResultData.bPerfectComboVisible = true
        elseif ComboNum == 1 or Pos == CenterBlowID then
            bPerfectVisible = true
            bExcellentVisible = false
            bFailVisible = false
            ResultData.bPerfectComboVisible = false
        end
        -- if Pos ~= CenterBlowID then
        --     if ComboNum >= 10 then -- 连击数超过10特殊处理
        --         local TenNum = math.floor(ComboNum / 10)
        --         ResultData.bPerfectComboVisible = true
        --         ComboNum = ComboNum - TenNum * 10
        --         local ComboCfg = CuffBatterCfg:FindCfgByKey(ComboNum)
        --         ResultData.bComboVisible = true
        --         ResultData.ComboNum = ComboCfg.ImgNumberPath
        --     else
        --         ResultData.bComboVisible = false
        --     end
        -- end
	end
	ResultData.bPerfectVisible = bPerfectVisible
	ResultData.bExcellentVisible = bExcellentVisible
	ResultData.bFailVisible = bFailVisible
    return ResultData
end

--- @type 增加力量值和设置连击数
function MiniGameCuff:AddStrengthValueAndCombos(InteractionCfg, InteractResult)
	local EnumInteractResult = GoldSaucerMiniGameDefine.InteractResult
	local RewardScore = 0
	local bAddCombo = false
    local Type = InteractionCfg.Category
    local OldBlessInteractorNumGot = self.BlessInteractorNumGot or 0
	if InteractResult == EnumInteractResult.Fail then
		RewardScore = 0
		bAddCombo = false
	elseif InteractResult == EnumInteractResult.Excellent then
		RewardScore = InteractionCfg.NiceScore
        local bStarItem = Type == InteractionCategory.CATEGORY_STARLIGHT
		bAddCombo = bStarItem
        if bStarItem then
            self.BlessInteractorNumGot = OldBlessInteractorNumGot + 1
        end
	elseif InteractResult == EnumInteractResult.Perfect then
		RewardScore = InteractionCfg.BestScore
		bAddCombo = true
        if Type == InteractionCategory.CATEGORY_STARLIGHT then
            self.BlessInteractorNumGot = OldBlessInteractorNumGot + 1
        end
    elseif InteractResult == EnumInteractResult.Error then
        bAddCombo = false
        RewardScore = InteractionCfg.BestScore
	end
	if bAddCombo then
		self:AddComboNum(1)
		local ComboNum = self:GetComboNum() -- 获得连击数
		local ComboCfg = CuffBatterCfg:FindCfgByKey(ComboNum)
		if ComboCfg ~= nil then
            RewardScore = RewardScore + ComboCfg.Score  -- 增加连续得分
		end
	else
		self:ResetComboNum()
	end
    self:SetCuffScoreAndVisible(RewardScore, InteractionCfg.Category)
    self:UpdateStrengthPro(RewardScore)
	self:AddStrengthValue(RewardScore, true)
    self:CheckReachStrengthStage()
end

--- @type 增加力量值和设置连击数
function MiniGameCuff:MultiplyStrengthValue(InteractionCfg, InteractResult)
    local EnumInteractResult = GoldSaucerMiniGameDefine.InteractResult
    local StrengthValue = self:GetStrengthValue() --TextMultiple
	local RewardScore = 0
    local MultiScale = 1
	if InteractResult == EnumInteractResult.Fail then
		RewardScore = 0
	elseif InteractResult == EnumInteractResult.Excellent then
        local Scale = math.floor(InteractionCfg.NiceMagn / 100 * 10) / 10
        MultiScale = Scale
	elseif InteractResult == EnumInteractResult.Perfect then
        MultiScale = InteractionCfg.BestMagn / 100
	end
    RewardScore = math.ceil(StrengthValue * MultiScale) - StrengthValue
    self:ResetComboNum( )
    self:SetTextMutiAndVisible(MultiScale)
    self:UpdateStrengthPro(RewardScore)
	self:AddStrengthValue(RewardScore, false)
    self:CheckReachStrengthStage()
end

--- @type 进入慢动作
function MiniGameCuff:EnterSlowAnimMode()
    local CurStrengthStageCfg = self.CurStrengthStageCfg
    if CurStrengthStageCfg == nil then
        return
    end
    local DelayEnterEndAnimTime = tonumber(CurStrengthStageCfg.DealyEnterEndAnimTime)
    local WaitTime = CurStrengthStageCfg.WaitTime
    local EndAnimPlayRate = CurStrengthStageCfg.EndAnimPlayRate
    local TimerHandle1 =  TimerMgr:AddTimer(self, function() 
        if not self.bPlayPunchAnim then
            self:SetPlayRate(EndAnimPlayRate)
            self.WaitAnimTime = tonumber(WaitTime - EndAnimPlayRate * WaitTime)
        end
    end, DelayEnterEndAnimTime)
    self:AddTimerHandle(TimerHandle1)

   local TimerHandle2 = TimerMgr:AddTimer(self, function() 
        if not self.bPlayPunchAnim then
            self:SetPlayRate(CurStrengthStageCfg.LpAnimPlayRate)
        end
    end, DelayEnterEndAnimTime + WaitTime)
    self:AddTimerHandle(TimerHandle2)
end

--- @type 检查是否达到了下一个力量阶段
function MiniGameCuff:CheckReachStrengthStage()
    local StrengthStageData = self.StrengthStageData
    local StrengthValue = self.StrengthValue
    local LastStage = self.CurStrengthStage
    local NewStage = 1
    for i, v in pairs(StrengthStageData) do
        local Elem = v
        if StrengthValue >= Elem.StrengthValue then
            NewStage = i + 1
            self.CurStrengthStageCfg = Elem
        end
    end
    if NewStage ~= LastStage then
        self.CurStrengthStage = NewStage
        self:OnReachNextStrengthStage(NewStage, NewStage < LastStage)
    end
end

--- @type 当达到下一个力量阶段的表现
function MiniGameCuff:OnReachNextStrengthStage(NewStage, bLower)
    local CurStrengthStageCfg = self.CurStrengthStageCfg
    self:SetPlayRate(CurStrengthStageCfg.LpAnimPlayRate)

    local RTPCName = MiniGameCuffAudioDefine.RTPCName
    self:SetRTPCValue(RTPCName.SpeedTwirl, NewStage % 100, 0)
	AudioUtil.LoadAndPlayUISound(AudioPath.EnterNextLevel)

    if CurStrengthStageCfg.bPlayFireVfx and not bLower then
        self:PlayFireEffect(false)
    end

    local PunchWindVfxStage = CurStrengthStageCfg.PunchWindVfxStage

    if PunchWindVfxStage ~= self.PunchWindVfxStage and PunchWindVfxStage <= #EffectAssetPath then
        if PunchWindVfxStage > 0 then
            self:PlayWindEffectVfx(PunchWindVfxStage)
            FLOG_WARNING("New WindEffect Stage = %s", PunchWindVfxStage)
        end
        self.PunchWindVfxStage = PunchWindVfxStage
    end

    if PunchWindVfxStage == 0 then
        self:StopWindEffect()
    end

    -- self:SetPartcleSystemPlayRate(1)
    _G.FLOG_WARNING("Cuff Play Next Stage Effect")
end

--- @type 播放火焰粒子特效
function MiniGameCuff:PlayFireEffect(bPreLoad)
    local VfxParameter = _G.UE.FVfxParameter()
    local VfxPath = self.DefineCfg.VfxPath
    local Major = MajorUtil.GetMajor()
    VfxParameter.VfxRequireData.EffectPath = VfxPath.Fire
    VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_MiniGameCuff
    local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
    -- VfxParameter.VfxRequireData.VfxTransform = Major:FGetActorTransform()

    VfxParameter:SetCaster(Major, 28, AttachPointType_Body, 0)

    if self.FireEffectID ~= nil and self.FireEffectID > 0 then
        EffectUtil.PlayVfxByID(self.FireEffectID)
    else
        self.FireEffectID = EffectUtil.PlayVfx(VfxParameter)
    end
end

-- function MiniGameCuff:SetPartcleSystemPlayRate(NewRate)
--     if self.WindEffectID == nil then
--         return 
--     end
--     local UFXMgr = UE.UFXMgr.Get()
--     UFXMgr:SetPlaybackRate(self.WindEffectID, NewRate)
-- end


function MiniGameCuff:PlayWindEffectVfx(PunchWindVfxStage)
    self:StopWindEffect()
    local Major = MajorUtil.GetMajor()
    local RaceID = MajorUtil.GetMajorRaceID()
    local SgInstanceID = self:GetSgDynaInstanceID()
    local SgActorTransform = _G.UE.FTransform()
    PWorldMgr:GetInstanceAssetTransform(SgInstanceID, SgActorTransform)
    local SgRotator = SgActorTransform:Rotator()
    local NeedRotation = SgRotator + _G.UE.FRotator(0, 90, 0)
    local VfxPath = self.DefineCfg.VfxPath
    local VfxParameter = _G.UE.FVfxParameter()
    
    VfxParameter.VfxRequireData.EffectPath = VfxPath.PunchWind
    VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_MiniGameCuff
    -- local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body--AttachPointType_Body
    
    -- VfxParameter:SetCaster(Major, 0, AttachPointType_Body, 0)
    local NeedLoc = Major:FGetActorLocation() + self:GetWindOffsetByRace(RaceID)

    VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(NeedRotation:ToQuat(), NeedLoc, self:GetWindScaleByRace(RaceID))

    if self.WindEffectID ~= nil and self.WindEffectID > 0 then
        EffectUtil.SetWorldTransform(self.WindEffectID, VfxParameter.VfxRequireData.VfxTransform)
        EffectUtil.KickTrigger(self.WindEffectID, PunchWindVfxStage)
    else
        self.WindEffectID = EffectUtil.KickTrigger(VfxParameter, PunchWindVfxStage)
    end


        -- if self.WindEffectID ~= 0 then
        --     local VfxInst = _G.UE.UFGameFXManager.Get():GetVfxInstance(self.WindEffectID)
        --     if VfxInst then
        --         VfxInst:K2_SetActorTransform(_G.UE.FTransform(NeedRotation, NeedLoc, self:GetWindScaleByRace(RaceID)), false, nil, false)
        --     end
        -- end
    
    --- Test
    -- EffectUtil.KickTrigger(VfxParameter, 1)
end

function MiniGameCuff:GetWindScaleByRace(RaceID)
    local RaceType = ProtoCommon.race_type
local NeedScale -- Y代表Camera往左还是往右  变大是往左，变小是往右
	if RaceID == RaceType.RACE_TYPE_Hyur then -- 人族
        NeedScale = 2.5
    elseif RaceID == RaceType.RACE_TYPE_Elezen then -- 精灵族
        NeedScale = 2.8
	elseif RaceID == RaceType.RACE_TYPE_Lalafell then -- 拉拉菲尔族
        NeedScale = 1.5
	elseif RaceID == RaceType.RACE_TYPE_Miqote then -- 猫魅族
        NeedScale = 2.5
	elseif RaceID == RaceType.RACE_TYPE_Roegadyn then -- 鲁加族
        NeedScale = 2.5 
	elseif RaceID == RaceType.RACE_TYPE_AuRa then -- 敖龙族
        NeedScale = 2.5
    else
        NeedScale = 2.5
	-- elseif RaceID == RaceType.RACE_TYPE_Hrothgar then -- 硌狮族
        -- NeedScale = UE.FVector(0, 300, 0)
	-- elseif RaceID == RaceType.RACE_TYPE_Viera then -- 维埃拉族
        -- NeedScale = UE.FVector(0, 300, 0)
	end
    return UE.FVector(NeedScale, NeedScale, NeedScale)
end

function MiniGameCuff:GetWindOffsetByRace(RaceID)
    local RaceType = ProtoCommon.race_type
    local X, Y, Z = 0, 0, 0
	if RaceID == RaceType.RACE_TYPE_Hyur then -- 人族
        X, Y, Z = -35, 20, 40
    elseif RaceID == RaceType.RACE_TYPE_Elezen then -- 精灵族
        X, Y, Z = -35, 20, 40
	elseif RaceID == RaceType.RACE_TYPE_Lalafell then -- 拉拉菲尔族
        X, Y, Z = 0, 7, -38
	elseif RaceID == RaceType.RACE_TYPE_Miqote then -- 猫魅族
        X, Y, Z = -35, 20, 40
	elseif RaceID == RaceType.RACE_TYPE_Roegadyn then -- 鲁加族
        X, Y, Z = -70, 25, 50
	elseif RaceID == RaceType.RACE_TYPE_AuRa then -- 敖龙族
        X, Y, Z = -70, 25, 50
    else
        X, Y, Z = -35, 20, 40

	-- elseif RaceID == RaceType.RACE_TYPE_Hrothgar then -- 硌狮族
        -- NeedFVector = UE.FVector(0, 300, 0)
	-- elseif RaceID == RaceType.RACE_TYPE_Viera then -- 维埃拉族
        -- NeedFVector = UE.FVector(0, 300, 0)
	end
    local Major = MajorUtil.GetMajor()
    local NormalizeForward = Major:GetActorForwardVector()
    local NormalizeRight = Major:GetActorRightVector()
    local NormalizeUp = Major:GetActorUpVector()

    return NormalizeForward * X + NormalizeRight * Y + NormalizeUp * Z
end

--- @type stop旋风特效
function MiniGameCuff:StopWindEffect()
    local WindEffectID = self.WindEffectID
    if not WindEffectID then
        return
    end
    EffectUtil.StopVfx(WindEffectID, 0, 0)
    self.WindEffectID = nil
end

function MiniGameCuff:StopFireEffect()
    local FireEffectID = self.FireEffectID
    if not FireEffectID then
        return
    end
    EffectUtil.StopVfx(FireEffectID, 0, 0)
    self.FireEffectID = nil
end

--- @type 获得加载VM需要的数据
function MiniGameCuff:GetSubViewVMData(Pos)
   local NextRoundInteractionCfg = self.NextRoundInteractionCfg
   if Pos == CenterBlowID then
        return NextRoundInteractionCfg
   end
    for _, v in pairs(NextRoundInteractionCfg) do   
        local Elem = v
        if Elem.Pos == Pos then
            return Elem
        end
    end
    return
end

--- @type 设置显示游戏界面还是结算界面
function MiniGameCuff:SetPanelNormalVisible(bVisible)
    self.bPanelNormalVisible = bVisible
    self.bPanelResultVisible = not bVisible
end

function MiniGameCuff:CheckHitResult(Type, PauseTime)
    self.bPlayerActed = true
    local InteractResult = GoldSaucerMiniGameDefine.InteractResult
    if Type == InteractionCategory.CATEGORY_ERROR then
        -- 点到负面需要扣分
        return InteractResult.Error
    end
    local CheckResultTime = GoldSaucerMiniGameDefine.CuffCheckResultTime
    local NeedTime
    if Type == InteractionCategory.CATEGORY_LOW then
		NeedTime = CheckResultTime.Low
	elseif Type== InteractionCategory.CATEGORY_MIDDLE then
		NeedTime = CheckResultTime.Middle
	elseif Type== InteractionCategory.CATEGORY_HIGH then
		NeedTime = CheckResultTime.High
    elseif Type == InteractionCategory.CATEGORY_STARLIGHT then
		NeedTime = CheckResultTime.StarLight
	else
        NeedTime = CheckResultTime.Red
	end
    if PauseTime < NeedTime.MissOuter or PauseTime > NeedTime.Profect then
        return InteractResult.Fail
    elseif PauseTime <= NeedTime.Great then
        return InteractResult.Excellent
    elseif PauseTime <= NeedTime.Profect then
        return InteractResult.Perfect
    end
    return InteractResult.Fail
end

function MiniGameCuff:PlayAudioByHitResult(Result, bRed)
    local InteractResult = GoldSaucerMiniGameDefine.InteractResult
    local NeedAudioPath
    if Result == InteractResult.Excellent then
        NeedAudioPath = AudioPath.Excellent
    elseif Result == InteractResult.Fail or Result == InteractResult.Error then
        NeedAudioPath = AudioPath.Miss
    else
        if bRed then
            NeedAudioPath = AudioPath.RedPerfect
        else
            NeedAudioPath = AudioPath.Perfect
        end
    end
    AudioUtil.LoadAndPlayUISound(NeedAudioPath)
end

--- 设置是否结束游戏
function MiniGameCuff:SetEndState()
    self.GameState = MiniGameStageType.End

end

--- 是否是因为时间结束而结束游戏
function MiniGameCuff:IsTimeOut()
    return self.RoundEndState == MiniGameRoundEndState.FailTime
end

--- 设置结束的原因
function MiniGameCuff:SetRoundEndState(State)
    self.RoundEndState = State
end

--- 是否有难度选择阶段
function MiniGameCuff:OnIsGameHaveDifficultySelect()
    return false
end

--- 获取镜头移动参数
function MiniGameCuff:OnCreateCameraSettingParam()
    local CameraMoveParam = _G.UE.FCameraResetParam()
	CameraMoveParam.Distance = 450
	CameraMoveParam.Rotator =  _G.UE.FRotator(-20, 5, -2)
	CameraMoveParam.ResetType =  _G.UE.ECameraResetType.Interp
	CameraMoveParam.LagValue = 10
	CameraMoveParam.NextTransform = _G.UE.FTransform()
	CameraMoveParam.TargetOffset = _G.UE.FVector(100, 600, 0)
	CameraMoveParam.SocketExternOffset = _G.UE.FVector(-50, 150, 50)
	CameraMoveParam.FOV = 0
	CameraMoveParam.bRelativeRotator = true
    return CameraMoveParam
end

function MiniGameCuff:bNeedLoop()
    return true
end

--- 是否结束游戏
function MiniGameCuff:OnIsGameRunEnd()
    if self.RoundEndState == MiniGameRoundEndState.Success or self.RoundEndState == MiniGameRoundEndState.FailChance then
        return true
    end
    local RemainTime = self.RemainSeconds
    if RemainTime <= 0 then
        self:SetRoundEndState(MiniGameRoundEndState.FailTime)
        _G.GoldSaucerMiniGameMgr:SendMsgCuffExistReq(false)
        return true
    end
	return false
end

--- 获取顶部tips内容
function MiniGameCuff:OnGetTopTipsContent(GameState)
    return ""
end

function MiniGameCuff:GetStarInteractorGotNum()
    return self.BlessInteractorNumGot
end

--- 构造成功列表数据
function MiniGameCuff:ConstructData(Power, AttactCount)
    local bBless = self:IsBless()
    local BlessSuccess = self:IsBlessChallengeSuccess()
    local ResultListData = {}
    if (Power and AttactCount) or (bBless and BlessSuccess) then
        -- 普通挑战成功或者赐福挑战成功
        local NeedAttactCount =  self:GetMaxComboNum()
        local bAttackRecordVisible = AttactCount ~= 0 
        local NeedPower =  self:GetStrengthValue()
        local bPowerRecordVisible = Power ~= 0
        if Power ~= 0 then
            NeedPower = Power
        end
        if AttactCount ~= 0 then
            NeedAttactCount = AttactCount
        end
       
        local Temp1, Temp2 = {}, {}
        Temp1.VarName = LSTR(250004) -- 力量值
        Temp1.bIsNewRecord = bPowerRecordVisible
        Temp1.bIsPerfectChallenge = bPowerRecordVisible
        Temp1.Value = string.format("%sPz", NeedPower)
        Temp2.VarName = LSTR(250005) -- 连击数
        Temp2.bIsNewRecord = bAttackRecordVisible
        Temp2.bIsPerfectChallenge = bAttackRecordVisible
        Temp2.Value = string.format("%s次", NeedAttactCount)
        table.insert(ResultListData, Temp1)
        table.insert(ResultListData, Temp2)
    end

    -- 赐福模式条目
    if bBless then
        local BlessKind = self.BlessKind
        local function GetTheBlessChallengeTarget()
            local TargetCfg = FairyBlessedTargetCfg:FindCfgByKey(MiniGameType.Cuff)
            if not TargetCfg then
                return
            end
            if BlessKind == BLESSED_KIND.BLESSED_KIND_BIG then
                return TargetCfg.BChallengeTarget
            elseif BlessKind == BLESSED_KIND.BLESSED_KIND_LITTLE then
                return TargetCfg.LChallengeTarget
            end
        end
        if BlessSuccess then
            local TitleIcon = ""
            if BlessKind == BLESSED_KIND.BLESSED_KIND_BIG then
                TitleIcon = BigBlessSuccessIconPath
            elseif BlessKind == BLESSED_KIND.BLESSED_KIND_LITTLE then
                TitleIcon = LittleBlessSuccessIconPath
            end
    
            local ChallengeRewardScoreNum = ""
            local BlessCfg = CuffBlessCfg:FindCfgByKey(BlessKind)
            if BlessCfg then
                ChallengeRewardScoreNum = string.formatint(BlessCfg.Reward)
            end
           
            local BlessInteractorRlt = {}
            BlessInteractorRlt.bBless = true
            BlessInteractorRlt.BlessTitle = BlessKind == BLESSED_KIND.BLESSED_KIND_BIG and LSTR(1660008) or LSTR(1660009)
            BlessInteractorRlt.BlessTitleIcon = TitleIcon
            BlessInteractorRlt.BlessBg = BlessSuccessItemBg
            BlessInteractorRlt.bShowNumOrCheckIcon = true
            BlessInteractorRlt.GetRewardNumText = string.format("x%s", tostring(self:GetStarInteractorGotNum())) 
            BlessInteractorRlt.ScoreGotNumText = string.formatint(self:GetInteractRewarNum())
            BlessInteractorRlt.bPlayBlessSuccessAnim = true
            BlessInteractorRlt.bBigBless = BlessKind == BLESSED_KIND.BLESSED_KIND_BIG
            table.insert(ResultListData, BlessInteractorRlt)
    
            local BlessChallengeRlt = {}
            BlessChallengeRlt.bBless = true
            BlessChallengeRlt.BlessTitle = GetTheBlessChallengeTarget()
            BlessChallengeRlt.BlessTitleIcon = TitleIcon
            BlessChallengeRlt.BlessBg = BlessSuccessItemBg
            BlessChallengeRlt.bShowNumOrCheckIcon = false
            BlessChallengeRlt.CheckIconPath = "Texture2D'/Game/UI/Texture/GoldSaucerGame/UI_GoldSaucerGame_Img_ResultList_Check.UI_GoldSaucerGame_Img_ResultList_Check'"
            BlessChallengeRlt.ScoreGotNumText = ChallengeRewardScoreNum
            BlessChallengeRlt.bPlayBlessSuccessAnim = true
            BlessChallengeRlt.bBigBless = BlessKind == BLESSED_KIND.BLESSED_KIND_BIG
            table.insert(ResultListData, BlessChallengeRlt)
        else
            -- 设定titleIcon
            local TitleIcon = ""
            if BlessKind == BLESSED_KIND.BLESSED_KIND_BIG then
                TitleIcon = BigBlessFailIconPath
            elseif BlessKind == BLESSED_KIND.BLESSED_KIND_LITTLE then
                TitleIcon = LittleBlessFailIconPath
            end
            local BlessFailRlt = {}
            BlessFailRlt.bBless = true
            BlessFailRlt.BlessTitle = GetTheBlessChallengeTarget()
            BlessFailRlt.BlessTitleIcon = TitleIcon
            BlessFailRlt.BlessBg = BlessFailItemBg
            BlessFailRlt.bShowNumOrCheckIcon = false
            BlessFailRlt.CheckIconPath = "Texture2D'/Game/UI/Texture/GoldSaucerGame/UI_GoldSaucerGame_Img_ResultList_UnCheck.UI_GoldSaucerGame_Img_ResultList_UnCheck'"
            BlessFailRlt.ScoreGotNumText = "0"
            BlessFailRlt.bBigBless = false
            table.insert(ResultListData, BlessFailRlt)
        end
    end

    self.ResultListData = ResultListData
end

function MiniGameCuff:GetRestartTimeAndChances()
    local Time = 0
    local bBless = self:IsBless()
    if not bBless then
        local Cfg = CuffParamCfg:FindCfgByKey(GilgameshParamType.GilgameshParamTypeTotalTime)
        if Cfg then
            Time = Cfg.Value
        end
    else
        local BlessCfg = CuffBlessCfg:FindCfgByKey(self.BlessKind)
        if BlessCfg then
            Time = BlessCfg.OverrideTime
        end
    end
   
	return Time
end

--- 获取赐福时间提示开始关卡ID
function MiniGameCuff:GetBigBlessLvID()
    local BlessCfg = CuffBlessCfg:FindCfgByKey(BLESSED_KIND.BLESSED_KIND_BIG)
    if not BlessCfg then
        return nil
    end

    return BlessCfg.BigBlessLvID
end

function MiniGameCuff:OnRecycleVfxEffect()
    self:StopWindEffect()
    self:StopFireEffect()
end

return MiniGameCuff

