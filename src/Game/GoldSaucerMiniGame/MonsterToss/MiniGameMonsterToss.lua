local LuaClass = require("Core/LuaClass")
local MiniGameBase = require("Game/GoldSaucerMiniGame/MiniGameBase")
local MajorUtil = require("Utils/MajorUtil")
local MonsterBasketballParamCfg = require("TableCfg/MonsterBasketballParamCfg") -- 怪物投篮参数表
local MonsterBasketballRewardCfg = require("TableCfg/MonsterBasketballRewardCfg") -- 怪物投篮奖励表 
local MonsterBasketballDifficultyCfg = require("TableCfg/MonsterBasketballDifficultyCfg") -- 怪物投篮难度表
local MonsterBasketballComboCfg = require("TableCfg/MonsterBasketballComboCfg") -- 怪物投篮连击表
local MonsterBasketballGlobalCfg = require("TableCfg/MonsterBasketballGlobalCfg") -- 怪物投篮全局配置表
local BasketballBaseScoreCfg = require("TableCfg/BasketballBaseScoreCfg")
local BasketballDifficultyRefreshCfg = require("TableCfg/BasketballDifficultyRefreshCfg")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local EffectUtil = require("Utils/EffectUtil")

local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local BasketballParamType = ProtoRes.Game.BasketballParamType
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local ExtraChanceResetPolicy = GoldSaucerMiniGameDefine.ExtraChanceResetPolicy
local AnimTimeLineSourceKey = GoldSaucerMiniGameDefine.AnimTimeLineSourceKey
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local Anim = MiniGameClientConfig[MiniGameType.MonsterToss].Anim
local ZOrderPriority = MiniGameClientConfig[MiniGameType.MonsterToss].ZOrder
local StageCfg = MiniGameClientConfig[MiniGameType.MonsterToss].StageCfg
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local EventMgr = _G.EventMgr
local EventID = _G.EventID
local TimerMgr = _G.TimerMgr
local UE = _G.UE
local BasketballType = ProtoCS.BasketballType

local ColorType = MiniGameClientConfig[MiniGameType.MonsterToss].ColorType


---@class MiniGameMonsterToss
---@param MiniGameType number @GoldSaucerMiniGameDefine.MiniGameType
local MiniGameMonsterToss = LuaClass(MiniGameBase)

---Ctor
function MiniGameMonsterToss:Ctor()
    local Type = MiniGameType.MonsterToss
	self.MiniGameType = Type
    self.Name = MiniGameClientConfig[Type].Name
    self.UIViewMainID = UIViewID.GoldSaucerMonsterTossMainPanel
    self.bOnShoot = false
    self.MaxScore = 0           -- 历史最大的得分
    self.CurScore = 0           -- 当前得分
    self.HitCount = 0
    self.DiffLevelTable = {}          -- 难度等级
    self.StageTimeTab = {}
    self.DynAssetID = nil
    self.ComboNum = 0 -- 连击数
    self.CurStage = 0
    self.bResultVisible = false
    self.bNormalVisible = true
    self.CurStageDiffParams = {}
    self.RewardGot = "0"
    self.AddRewardGot = "0"
    self.AddScoreText = ""
    self.AddScoreColor = "FFEED97F"
    self.AddScoreOutLineColor = "8E5C137F"
    self.AddScorePos = UE.FVector2D(0, 0)
    self.PosData = {}
    self.bResultMoneyVisible = false
    self.bGameTipVisible = true
    self.bAddScoreTextVisible = true
    self.TextScore1Text = ""
    self.bTextScore1TipVisible = false 
    self.bTextScore2TipVisible = false
    self.AllBallData = {}
    self.bShootTipVisible = false
    self.ShootResultData = {}
    self.AllResultData = {}
    self.CurZOrderData = {}
    self.CachColorProportion = {}
    self.ViewModel = nil
    self.GlobalParams = {}
    self.DelayFinishTime = 0
    self.EndEmotionID = 0
    self.CriticalText = ""
    self.bCriticalVisible = false
    self.EndReward = nil
    self.IsFightAgain = false
    self.IdleStateKey = AnimTimeLineSourceKey.BaskIdle
    local DefineCfg = MiniGameClientConfig[Type]
    if DefineCfg then
        self.DefineCfg = DefineCfg
    end
    local CoinID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE -- 金碟币ID
	local IconPath = _G.ScoreMgr:GetScoreIconName(CoinID)
    self.AwardIconPath = IconPath
    self.LastScoreMultAnim = nil
end


--- 初始化游戏数据
function MiniGameMonsterToss:LoadTableCfg()
    self.RewardData = MonsterBasketballRewardCfg:FindAllCfg()
    self.ComboScoreData = MonsterBasketballComboCfg:FindAllCfg()
    self.MaxCombo = #self.ComboScoreData
end

--- 初始化游戏数据
function MiniGameMonsterToss:InitMiniGame(Params)
    self.GlobalParams = MonsterBasketballGlobalCfg:FindAllCfg()

    local Type = self.MiniGameType
    local ResetTime = self:GetRestartTime()
    self.RemainSeconds = ResetTime

    if Params == nil then
        return
    end
    self.MaxScore = Params.MaxScore

    local DiffCfg = MonsterBasketballDifficultyCfg:FindCfgByKey(Params.DifficultyLevel)
    if DiffCfg ~= nil then
        self.DiffLevelTable = DiffCfg.Level
    end
    self:ConstructStageTimeTab()

    self:SetMoneySlotVisible(false)
    self:UpdateCurStageDiffParams(ResetTime)
    self:CaculateZOreder()
end

function MiniGameMonsterToss:ConstructStageTimeTab()
    self.StageTimeTab = {}
    local DiffLevelTable = self.DiffLevelTable
    for i = 1, #DiffLevelTable do
        local Elem = DiffLevelTable[i]
        local Cfg = MonsterBasketballParamCfg:FindCfgByKey(Elem)
        if Cfg ~= nil then
            table.insert(self.StageTimeTab, Cfg.StartTime)
        end
    end
end

--- @type 根据时间更新当前难度 
function MiniGameMonsterToss:OnGameRun(CurTime)
    self:UpdateCurStageDiffParams(CurTime)
    if CurTime <= 0 then

    end
end

--- @type 获取颜色ZOrder配置
function MiniGameMonsterToss:FindZOrderByColorType_Internal(ColorType, ZOrderData)
    for _, v in pairs(ZOrderData) do
        local Elem = v
        if Elem.ColorType == ColorType then
            return Elem.ZOrder
        end
    end
    return
end

--- @type 更新当前阶段难度参数
function MiniGameMonsterToss:UpdateCurStageDiffParams(CurTime)
    local NewStage = self:CalcuCurStage(CurTime)
    if self.CurStage == NewStage then
        return
    end
    self.CurStage = NewStage
    print("NewStage is %s", NewStage)

    
    -- local RandNum = math.random(1, 6)
    -- local ZOrderData = GoldSaucerMiniGameDefine.GetZOrderDataByType(RandNum)
    -- self.CurZOrderData = ZOrderData
    local DiffLevelTable = self.DiffLevelTable
    if #DiffLevelTable > 0 then
        local DiffParamID = DiffLevelTable[self.CurStage]
        local DiffParamCfg = MonsterBasketballParamCfg:FindCfgByKey(DiffParamID)
        if DiffParamCfg ~= nil then
            local CachColorProportion = self.CachColorProportion -- 缓存数据 当投篮时候拿出来用
            CachColorProportion.NormalProportion= DiffParamCfg.NormalProportion  -- 蓝色区域为普通球
            CachColorProportion.SuperProportion = DiffParamCfg.SuperProportion -- 紫色区域为高分球
            CachColorProportion.BangProportion = DiffParamCfg.BangProportion -- 红色区域为爆炸球

            local CurStageDiffParams = self.CurStageDiffParams
            CurStageDiffParams.ScoreMul = DiffParamCfg.ScoreMul
            CurStageDiffParams.RotateOnceTime = DiffParamCfg.RotateOnceTime

            local NeedAnim
            if DiffParamCfg.ScoreMul == StageCfg.Second then
                NeedAnim = Anim.AnimScoreMultiplierIn2
            elseif DiffParamCfg.ScoreMul == StageCfg.Third then
                NeedAnim = Anim.AnimScoreMultiplierIn3
            elseif NewStage == StageCfg.Fifth then
                NeedAnim = Anim.AnimScoreMultiplierIn5
            end
        
            if NeedAnim ~= nil and (self.LastScoreMultAnim == nil or self.LastScoreMultAnim ~= NeedAnim) then
                self.LastScoreMultAnim = NeedAnim
                EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, NeedAnim)
            end
        end
    end
  
    if not self:GetbOnShoot() and self.ViewModel ~= nil then
        -- TODO 根据需求是否打开下面两行 
        -- self:CaculateZOreder()
        -- self.ViewModel:UpdateProportLayOut()
    end
end

function MiniGameMonsterToss:SetFightAgain(IsFightAgain)
    self.IsFightAgain = IsFightAgain
end

function MiniGameMonsterToss:GetIsFightAgain()
    return self.IsFightAgain
end

--- @type 计算ZOrder配置和轮盘布局
function MiniGameMonsterToss:CaculateZOreder()
    local CachColorProportion = self.CachColorProportion -- 把缓存数据拿出来用
    local CurStageDiffParams = self.CurStageDiffParams
    CurStageDiffParams.BlueProportion= CachColorProportion.NormalProportion  -- 蓝色区域为普通球
    CurStageDiffParams.PurpleProportion = CachColorProportion.SuperProportion -- 紫色区域为高分球
    CurStageDiffParams.RedProportion = CachColorProportion.BangProportion -- 红色区域为爆炸球

    local RandNum = math.random(1, 6)
    local ZOrderData = GoldSaucerMiniGameDefine.GetZOrderDataByType(RandNum)
    self.CurZOrderData = ZOrderData

    local ZOrderCfg = {}
    ZOrderCfg.BlueProportOrder = self:FindZOrderByColorType_Internal(ColorType.Blue, ZOrderData)
    ZOrderCfg.PurpleProportOrder = self:FindZOrderByColorType_Internal(ColorType.Purple, ZOrderData)
    ZOrderCfg.RedProportOrder = self:FindZOrderByColorType_Internal(ColorType.Red, ZOrderData)
    self.CurStageDiffParams.ZOrderCfg = ZOrderCfg
    self.CurStageDiffParams.ColorCfg = self:GetColorCfgByZOrderCfg(self.CurStageDiffParams, ZOrderData, ZOrderCfg)
end


function MiniGameMonsterToss:MonsterTossSetCritical(bCritical)
    local Cfg = MonsterBasketballGlobalCfg:FindCfgByKey(BasketballParamType.BasketballParamTypeCriticalHitTimes)
    if not Cfg then
        return
    end
    
    self.CriticalText = string.format(LSTR(250002), Cfg.Value) -- %s倍暴击
    self.bCriticalVisible = bCritical
    -- local Anim = self.DefineCfg.Anim
    -- if bCritical then
    --     _G.EventMgr:SendEvent(_G.EventID.MiniGameMainPanelPlayAnim, Anim.Critical)
    -- end
end

--- @type 获取当前阶段
function MiniGameMonsterToss:GetCurStageDiffParams()
    return self.CurStageDiffParams
end

--- @type 得到配色的比例
function MiniGameMonsterToss:GetColorCfgByZOrderCfg(DiffParamCfg, ZOrderData, ZOrderCfg)
    if DiffParamCfg == nil or ZOrderData == nil then
        return
    end

    local MaxZOrderColorType
    for _, v in pairs(ZOrderData) do
        local Elem = v
        if Elem.ZOrder == ZOrderPriority.Max then
            MaxZOrderColorType = Elem.ColorType
        end
    end

    local MaxZOrderColorPropor
    if MaxZOrderColorType == ColorType.Red then
        MaxZOrderColorPropor = DiffParamCfg.RedProportion
    elseif MaxZOrderColorType == ColorType.Blue then
        MaxZOrderColorPropor = DiffParamCfg.BlueProportion
    elseif MaxZOrderColorType == ColorType.Purple then
        MaxZOrderColorPropor = DiffParamCfg.PurpleProportion
    end
    -- print("MaxZOrderColorPropor: "..tostring(MaxZOrderColorPropor))

    local ColorCfg = {}
    ColorCfg.BluePercent = self:GetPercent(DiffParamCfg.BlueProportion, ZOrderCfg.BlueProportOrder, MaxZOrderColorPropor)
    ColorCfg.PurplePercent = self:GetPercent(DiffParamCfg.PurpleProportion, ZOrderCfg.PurpleProportOrder, MaxZOrderColorPropor)
    ColorCfg.RedPercent = self:GetPercent(DiffParamCfg.RedProportion, ZOrderCfg.RedProportOrder, MaxZOrderColorPropor)
    return ColorCfg
end

--- @type 得到蓝色的比例
function MiniGameMonsterToss:GetPercent(Proportion, ZOrder, MaxZOrderColorPropor)
    local MaxZOrdImgPercent = MaxZOrderColorPropor / 100 / 2
    local Percent = Proportion / 100 / 2
    if ZOrder == ZOrderPriority.Min then
        return 0.5
    elseif ZOrder == ZOrderPriority.Middle then
        return MaxZOrdImgPercent + Percent
    elseif ZOrder == ZOrderPriority.Max then
        return Percent
    end
end

--- @type 根据当前时间得到当前的难度阶段
function MiniGameMonsterToss:CalcuCurStage(CurTime)
    -- local AllDiffStageData = BasketballDifficultyRefreshCfg:FindAllCfg()
    local StageTimeList = self.DefineCfg.StageTimeList
    local StageTimeTab = self.StageTimeTab
    local CurStage = 1
    if CurTime > StageTimeTab[StageTimeList.EnterStage2Time] / 1000 then
        CurStage = StageCfg.First
    elseif CurTime > StageTimeTab[StageTimeList.EnterStage3Time] / 1000 then
        CurStage = StageCfg.Second
    elseif CurTime > StageTimeTab[StageTimeList.EnterStage4Time] / 1000 then
        CurStage = StageCfg.Third
    elseif CurTime > StageTimeTab[StageTimeList.EnterStage5Time] / 1000 then
        CurStage = StageCfg.Fourth
    elseif CurTime > 0 then
        CurStage = StageCfg.Fifth
    end
    return CurStage
end

-- 投篮出手
function MiniGameMonsterToss:SetbOnShoot(bOnShoot)
    self.bOnShoot = bOnShoot
end

function MiniGameMonsterToss:GetbOnShoot()
    return self.bOnShoot
end

function MiniGameMonsterToss:SetDelayFinishTime()
    self.DelayFinishTime = 1.85
    local DelayFinishTime = self.DelayFinishTime
    local function SubTime()
        DelayFinishTime = DelayFinishTime - 0.2
        if DelayFinishTime <= 0.1 then
            TimerMgr:CancelTimer(self.FinishTimer)
        end
    end
    self.FinishTimer = TimerMgr:AddTimer(self, SubTime, 0, 0.2, 0)
    self:AddTimerHandle(self.FinishTimer)
end

-- function MiniGameMonsterToss:SetbIsBangBall(bIsBangBall)
--     self.bIsBangBall = bIsBangBall
-- end

-- function MiniGameMonsterToss:GetbIsBangBall()
--     return self.bIsBangBall
-- end

--- @type 设置投篮结果是否显示
function MiniGameMonsterToss:SetbShootTipVisible(bVisible)
    self.bShootTipVisible = bVisible
end

 -- 270011----270044 对应 一 到 三十四
local NumString = {
    LSTR(270011), LSTR(270012), LSTR(270013), LSTR(270014), LSTR(270015), LSTR(270016), LSTR(270017), LSTR(270018), LSTR(270019), LSTR(270020), LSTR(270021), LSTR(270022), LSTR(270023),
    LSTR(270024), LSTR(270025), LSTR(270026), LSTR(270027), LSTR(270028), LSTR(270029), LSTR(270030), LSTR(270031), LSTR(270032), LSTR(270033), LSTR(270034),
    LSTR(270035), LSTR(270036), LSTR(270037), LSTR(270038), LSTR(270039), LSTR(270040), LSTR(270041), LSTR(270042), LSTR(270043), LSTR(270044),
}
-- local TextColor = { TwoToSixCombo = "#d5d5d5", SevenToFifColor = "#d1ba8e", OverSixteen = "#d1906d"  }
-- local ComboStageCfg = {FirstStage = 2, SecondStage = 7, EndStage = 16}
--- @type 构造投篮结果提示数据
function MiniGameMonsterToss:ConstructShootResultData(ComboNum, bHit)
    local ComboScoreData = self.ComboScoreData
    local ShootResultData = {}
    if not bHit then
        ShootResultData.bSuccessTipVisible = false
        ShootResultData.bFailTipVisible = true
        ShootResultData.Text = LSTR(270007) -- 失败
        ShootResultData.bSubDataVisible = false
    else
        ShootResultData.bSuccessTipVisible = true
        ShootResultData.bFailTipVisible = false
        ShootResultData.Text = LSTR(270008) -- 成功
        ShootResultData.bSubDataVisible = ComboNum > 1
        ShootResultData.SubText = string.format(LSTR(270009), NumString[ComboNum]) -- %s连命中！
    end
    local Key = ComboNum <= #ComboScoreData and ComboNum or #ComboScoreData
    Key = Key == 0 and 1 or Key
    local Cfg = ComboScoreData[Key]
    ShootResultData.SubTextColor = Cfg.Color
    self.ShootResultData = ShootResultData
end

--- @type 设置是否展示右上角金币
function MiniGameMonsterToss:SetMoneySlotVisible(bVisible)
    self.bResultMoneyVisible = bVisible
    self.bGameTipVisible = not bVisible

end

--- @type 设置多倍分数提示
function MiniGameMonsterToss:SetMultiScoreByType(Type, bHit)
    if not bHit then
        return
    end
    local NeedContent, bFiveVisible, bDoubleVisible
    local Cfg = BasketballBaseScoreCfg:FindCfgByKey(Type)
    if Cfg == nil then
        FLOG_ERROR("BasketballBaseScoreCfg is Nil Type = %s", Type)
        return
    end
    if Type == BasketballType.BasketballType_Bang then
        NeedContent = Cfg.Score
        bFiveVisible = true
        bDoubleVisible = false
    elseif Type == BasketballType.BasketballType_Normal then
        NeedContent = ""
        bFiveVisible = false
        bDoubleVisible = false
    elseif Type == BasketballType.BasketballType_Super then
        NeedContent = Cfg.Score
        bFiveVisible = false
        bDoubleVisible = true
    end
    self.TextScore1Text = NeedContent
    self.bTextScore1TipVisible = bFiveVisible 
    self.bTextScore2TipVisible = bDoubleVisible 

end

--- @type 设置是否显示结算结果界面
function MiniGameMonsterToss:SetbResultQAndNormalVisible(bVisible)
    self.bResultVisible = bVisible
    self.bNormalVisible = not bVisible
end

--- @type 设置位置加分的信息
function MiniGameMonsterToss:SetPosData(Data)
    self.PosData = Data
end

--- @type 设置最大得分
function MiniGameMonsterToss:SetMaxScore(MaxScore)
    self.MaxScore = MaxScore
end

--- @type 设置最大得分 
function MiniGameMonsterToss:GetMaxScore()
    return self.MaxScore
end

--- @type 获得最大连击数
function MiniGameMonsterToss:GetComboNum()
    return self.ComboNum
end

--- @type 增加投中数量
function MiniGameMonsterToss:AddHitCount()
    self.HitCount = self.HitCount + 1
end

 --- @type 设置最大得分
function MiniGameMonsterToss:AddComboNum()
    self.ComboNum = self.ComboNum + 1
    self:SetAddScoreText_Internal(self.ComboNum)
    self:SetAddScorePos_Internal(self.ComboNum)
    local ComboNum = self.ComboNum
    if ComboNum == 3 then
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimConsecutiveHits1)
    elseif ComboNum == 5 then
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimConsecutiveHits2)
    elseif ComboNum == 8 then
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimConsecutiveHits3)
    end
end

--- @type 设置最大得分
function MiniGameMonsterToss:ResetComboNum()
    local LastComboNum = self.ComboNum
    if LastComboNum >= 3 then
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimConsecutiveHitsStop)
    end
    self.ComboNum = 0
    self:SetAddScoreText_Internal(self.ComboNum)
    self:SetAddScorePos_Internal(self.ComboNum)

end

--- @type 设置额外额外得分的位置
function MiniGameMonsterToss:SetAddScorePos_Internal(ComboNum)
    local PosData = self.PosData
    local MaxCombo = self.MaxCombo
    local NameIndex = string.format("Pos%d", ComboNum)
    if ComboNum == 0 then
        self.AddScorePos = UE.FVector2D(0, 0)
    else
        if ComboNum > MaxCombo then
            ComboNum = MaxCombo
        end
        self.AddScorePos = PosData[NameIndex]
    end
    
end

--- @type 设置额外增加分数
function MiniGameMonsterToss:SetAddScoreText_Internal(ComboNum)
    if ComboNum == 0 then
        self.AddScoreText = "0"
        self.bAddScoreTextVisible = false
        self.AddScoreColor = "FFEED97F"
        self.AddScoreOutLineColor = "8E5C137F"
    end
    local Key = ComboNum
    local MaxCombo = self.MaxCombo

    if Key > MaxCombo then
        Key = MaxCombo
    end
    local ComboCfg = MonsterBasketballComboCfg:FindCfgByKey(Key)
    if ComboCfg ~= nil then
        self.AddScoreText = string.format("+%d", ComboCfg.Score)
        self.bAddScoreTextVisible = ComboCfg.Score > 0
        local NeedColor, NeedOutLineColor
        if ComboCfg.Score == 3 then
            NeedColor = "FFA68BFF"
            NeedOutLineColor = "673E04FF"
        elseif ComboCfg.Score == 2 then
            NeedColor = "FFF274FF"
            NeedOutLineColor = "B76C00FF"
        elseif ComboCfg.Score == 1 and ComboNum >= 3 then
            NeedColor = "FFEED9FF"
            NeedOutLineColor = "8E5C13FF"
        elseif ComboNum >= 1 then
            NeedColor = "FFEED97F"
            NeedOutLineColor = "8ESC13FF"
        end
        self.AddScoreColor = NeedColor
        self.AddScoreOutLineColor = NeedOutLineColor
    end
end

--- @type 初始化篮球数据
function MiniGameMonsterToss:InitAllBallData(Data)
    local NeedData = {}
    for i = 1, #Data do
        local Temp = {}
        Temp.BallType = Data[i]
        -- Temp.bBallVisible = true
        -- Temp.Pos = i
        table.insert(NeedData, Temp)
    end
    self.AllBallData = NeedData
end

--- @type 更新篮球数据
function MiniGameMonsterToss:UpdateAllBallData(NewType)
    local AllBallData = self.AllBallData
    local LastBallData = {}
    LastBallData.BallType = NewType
    -- LastBallData.bBallVisible = false
    for i = 1, #AllBallData - 1 do
        AllBallData[i] = AllBallData[i + 1]
    end
    AllBallData[#AllBallData] = LastBallData
 
end


--- @type 更新当前得分以及获得的奖励
function MiniGameMonsterToss:UpdateCurScoreAndGotReward(CurScore)
    self.CurScore = CurScore
    self.RewardGot = self:GetRewardNumByScore(CurScore)
end

function MiniGameMonsterToss:MultiRewardGot()
    if self.EndReward ~= nil then
        self.RewardGot = self.EndReward
    end
end

--- @type 根据得分获取当前获得的金碟币
function MiniGameMonsterToss:GetRewardNumByScore(CurScore)
    local LastRewardGot = self.RewardGot
    local RewardData = self.RewardData

    if RewardData == nil then
        _G.FLOG_ERROR("Config is nil. Name: MonsterBasketballRewardCfg")
        return
    end
    local Reward = 0
    for _, v in pairs(RewardData) do
        local Elem = v
        if CurScore >= Elem.Score then
            Reward = Elem.GoldCoin
            self.EndEmotionID = Elem.EndEmotionID
        else
            break
        end
    end
    if tonumber(Reward) > tonumber(LastRewardGot) then
        self.AddRewardGot = Reward - LastRewardGot
    else
        self.AddRewardGot = 0
    end
    return Reward
end

function MiniGameMonsterToss:GetEndEmotionID()
    return self.EndEmotionID
end

--- @type 获得当前得分
function MiniGameMonsterToss:GetCurScore()
    return self.CurScore
end

--- @type 构造游戏结果数据
function MiniGameMonsterToss:ConstructAllResultData(CurScore, HitCount, EndReward)
    local RealScore = CurScore ~= 0 and CurScore or self.CurScore
    local AllResultData = {}
    local bSuccess, bFail, ResultListData, RewardGot, AwardIconPath
    if RealScore >= self.RewardData[1].Score then
        bSuccess = true
        bFail = false
        ResultListData = self:GetSuccessData(CurScore, HitCount)
    else
        bSuccess = false
        bFail = true
    end
    if EndReward ~= nil and self.bCriticalVisible then
        self.EndReward = EndReward
        RewardGot = self.RewardGot
    elseif EndReward ~= nil and not self.bCriticalVisible then
        RewardGot = EndReward
    end
 
    AwardIconPath = self.AwardIconPath
    AllResultData.bSuccess = bSuccess
    AllResultData.bFail = bFail
    -- AllResultData.ResultText = ResultText
    AllResultData.ResultListData = ResultListData
    AllResultData.RewardGot = RewardGot ~= nil and RewardGot or self.RewardGot
    AllResultData.AwardIconPath = AwardIconPath
    self.AllResultData = AllResultData
    self:UpdateResultCoinState()
end

--- @type 获得当前得分
function MiniGameMonsterToss:UpdateResultCoinState()
    local bIconGoldVisible, TryAgainTip, TryAgainTipColor, BtnText
    local CurJDNum = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
    if CurJDNum >= 1 then
        bIconGoldVisible = true
        TryAgainTip = "1"
        TryAgainTipColor = "#FFFFFF"
        BtnText = LSTR(250001) -- 再 战
    else
        bIconGoldVisible = false
        TryAgainTip = LSTR(270010) -- 当前金碟币不足
        TryAgainTipColor = "#FF0000"
        BtnText = LSTR(250003) -- 前往获取
    end

    self.AllResultData.bIconGoldVisible = bIconGoldVisible
    self.AllResultData.TryAgainTip = TryAgainTip
    self.AllResultData.TryAgainTipColor = TryAgainTipColor
    self.AllResultData.BtnText = BtnText

end

--- @type 获取胜利结果数据
function MiniGameMonsterToss:GetSuccessData(CurScore, HitCount)
    local Data = {}
    local Temp1 = {}
    Temp1.VarName = LSTR(270005) -- 命中
    local NeedHitCount = HitCount ~= 0 and HitCount or self.HitCount
    Temp1.Value = string.format(LSTR(270006), NeedHitCount) -- %s次
    Temp1.bIsNewRecord = HitCount ~= 0
    Temp1.bIsPerfectChallenge = HitCount ~= 0
    table.insert(Data, Temp1)
    local Temp2 = {}
    Temp2.VarName = LSTR(270004) -- 得分
    Temp2.Value = CurScore ~= 0 and CurScore or self.CurScore
    Temp2.bIsNewRecord = CurScore ~= 0
    Temp2.bIsPerfectChallenge = CurScore ~= 0
    table.insert(Data, Temp2)
    return Data
end

--- 是否有难度选择阶段
function MiniGameMonsterToss:OnIsGameHaveDifficultySelect()
    return false
end

--- 获取镜头移动参数
function MiniGameMonsterToss:OnCreateCameraSettingParam()
    local RaceID = MajorUtil.GetMajorRaceID()

    local CameraMoveParam = UE.FCameraResetParam()
	CameraMoveParam.Distance = self:SelectDistanceByRace(RaceID)
	CameraMoveParam.Rotator =  self:SelectCameraRotatorByRace(RaceID)
	CameraMoveParam.ResetType =  UE.ECameraResetType.Interp
	CameraMoveParam.LagValue = 10
	CameraMoveParam.NextTransform = UE.FTransform()
	CameraMoveParam.TargetOffset = UE.FVector(0, 0, 0)
	CameraMoveParam.SocketExternOffset = self:SelectCameraVectorByRace(RaceID)
	CameraMoveParam.FOV = 0
	CameraMoveParam.bRelativeRotator = true
    return CameraMoveParam
end

--- @type 根据当前种族选择旋转角度
function MiniGameMonsterToss:SelectCameraRotatorByRace(RaceID)
	local RaceType = ProtoCommon.race_type
    local NeedRotator -- Pitch  Yaw Roll
	if RaceID == RaceType.RACE_TYPE_Hyur then -- 人族
        NeedRotator = UE.FRotator(-3, -1, 0)
    elseif RaceID == RaceType.RACE_TYPE_Elezen then -- 精灵族
        NeedRotator = UE.FRotator(-3, -1, 0)
	elseif RaceID == RaceType.RACE_TYPE_Lalafell then -- 拉拉菲尔族
        NeedRotator = UE.FRotator(-3, -1, 0)
	elseif RaceID == RaceType.RACE_TYPE_Miqote then -- 猫魅族
        NeedRotator = UE.FRotator(0, -1, 0)
	elseif RaceID == RaceType.RACE_TYPE_Roegadyn then -- 鲁加族
        NeedRotator = UE.FRotator(-6, -5, 0)
	elseif RaceID == RaceType.RACE_TYPE_AuRa then -- 敖龙族
        NeedRotator = UE.FRotator(-5, -3, 0)
	elseif RaceID == RaceType.RACE_TYPE_Hrothgar then -- 硌狮族
        NeedRotator = UE.FRotator(-5, -3, 0)
	elseif RaceID == RaceType.RACE_TYPE_Viera then -- 维埃拉族
        NeedRotator = UE.FRotator(-5, -3, 0)
	end
    return NeedRotator
end

--- @type 根据当前种族选择旋转角度
function MiniGameMonsterToss:SelectCameraVectorByRace(RaceID)
	local RaceType = ProtoCommon.race_type
    local NeedFVector -- Y代表Camera往左还是往右  变大是往左，变小是往右
	if RaceID == RaceType.RACE_TYPE_Hyur then -- 人族
        NeedFVector = UE.FVector(0, 270, 75)
    elseif RaceID == RaceType.RACE_TYPE_Elezen then -- 精灵族
        NeedFVector = UE.FVector(0, 280, 75)
	elseif RaceID == RaceType.RACE_TYPE_Lalafell then -- 拉拉菲尔族
        NeedFVector = UE.FVector(20, 270, 75)
	elseif RaceID == RaceType.RACE_TYPE_Miqote then -- 猫魅族
        NeedFVector = UE.FVector(0, 250, 75)
	elseif RaceID == RaceType.RACE_TYPE_Roegadyn then -- 鲁加族
        NeedFVector = UE.FVector(0, 300, 40)
	elseif RaceID == RaceType.RACE_TYPE_AuRa then -- 敖龙族
        NeedFVector = UE.FVector(0, 300, 0)
	elseif RaceID == RaceType.RACE_TYPE_Hrothgar then -- 硌狮族
        NeedFVector = UE.FVector(0, 300, 0)
	elseif RaceID == RaceType.RACE_TYPE_Viera then -- 维埃拉族
        NeedFVector = UE.FVector(0, 300, 0)
	end
    return NeedFVector
end

--- @type 根据当前种族选择旋转角度
function MiniGameMonsterToss:SelectDistanceByRace(RaceID)
	local RaceType = ProtoCommon.race_type
    local Distance
	if RaceID == RaceType.RACE_TYPE_Hyur then -- 人族
        Distance = 560
    elseif RaceID == RaceType.RACE_TYPE_Elezen then -- 精灵族
        Distance = 560
	elseif RaceID == RaceType.RACE_TYPE_Lalafell then -- 拉拉菲尔族
        Distance = 560
	elseif RaceID == RaceType.RACE_TYPE_Miqote then -- 猫魅族
        Distance = 500
	elseif RaceID == RaceType.RACE_TYPE_Roegadyn then -- 鲁加族
        Distance = 560
	elseif RaceID == RaceType.RACE_TYPE_AuRa then -- 敖龙族
        Distance = 560
	elseif RaceID == RaceType.RACE_TYPE_Hrothgar then -- 硌狮族
        Distance = 560
	elseif RaceID == RaceType.RACE_TYPE_Viera then -- 维埃拉族
        Distance = 560
	end
    return Distance
end

--- @type 播放爆炸特效
function MiniGameMonsterToss:PlayExplodeVfx(bPreLoad)
	local VfxPath = self.DefineCfg.VfxPath
    local VfxParameter = _G.UE.FVfxParameter()
    local Major = MajorUtil.GetMajor()
    
    VfxParameter.VfxRequireData.EffectPath = VfxPath.Explode
    VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_MiniGameMonsterToss
    local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body--AttachPointType_Body
    local MajorTransform = Major:FGetActorTransform()
    local NeedTransform = _G.UE.FTransform()
 
    VfxParameter.OffsetTransform = NeedTransform 
    VfxParameter.VfxRequireData.VfxTransform = MajorTransform
    VfxParameter:SetCaster(Major, 0, AttachPointType_Body, 0)
    -- VfxParameter:AddTarget(Major, 32, AttachPointType_Body, 0)

    if bPreLoad then
        self.ExploadEffectID = EffectUtil.LoadVfx(VfxParameter)
    else
        self.ExploadEffectID = EffectUtil.PlayVfx(VfxParameter)
    end
end

--- @type 玩家变黑又变回来
function MiniGameMonsterToss:PlayerChangeColor(ChangeTime, bReset)
    -- local AvatarCmp = MajorUtil.GetMajorAvatarComponent()
    -- local Color = _G.UE.FVector(0, 0, 0)
    -- if bReset then
    --     Color = _G.UE.FVector(1, 1, 1)
    -- end
    -- if AvatarCmp then
    --     AvatarCmp:StartCharaColor(Color, Color, 1, 1, 1, 1, 0, 0
    --         , ChangeTime, false, true);
    -- end
end


function MiniGameMonsterToss:GetIdlePathByRaceID()
    local RaceID = MajorUtil.GetMajorRaceID()
    local IdlePath = self.DefineCfg.IdlePath
	return IdlePath[RaceID]
end

function MiniGameMonsterToss:Reset()
    local Type = MiniGameType.MonsterToss
	self.MiniGameType = Type
    self.Name = MiniGameClientConfig[Type].Name
    self.UIViewMainID = UIViewID.GoldSaucerMonsterTossMainPanel
    -- self.LoopNum = 30
    -- self.Interval = 0.05
    -- self.LastShootTime = 0
    -- self.ComboBangBallNum = 0
    -- self.DelayTime = 2--self.LoopNum * self.Interval -- 从预发球位置移动到发球位置的时间
    -- self.bIsBangBall = false
    self.MaxScore = 0           -- 历史最大的得分
    self.CurScore = 0           -- 当前得分
    self.HitCount = 0
    self.DiffLevelTable = {}          -- 难度等级
    self.StageTimeTab = {}
    self.ComboNum = 0 -- 连击数
    self.CurStage = 0
    self.bResultVisible = false
    self.bNormalVisible = true
    self.CurStageDiffParams = {}
    self.RewardGot = "0"
    self.AddRewardGot = "0"
    self.AddScoreText = ""
    self.AddScorePos = UE.FVector2D(0, 0)
    self.PosData = {}
    self.bResultMoneyVisible = false
    self.bGameTipVisible = true

    self.bAddScoreTextVisible = true
    self.TextScore1Text = ""
    self.AddScoreColor = "FFEED97F"
    self.AddScoreOutLineColor = "8E5C137F"
    self.bTextScore1TipVisible = false 
    self.bTextScore2TipVisible = false
    self.AllBallData = {}
    self.bShootTipVisible = false
    self.ShootResultData = {}
    self.AllResultData = {}
    self.CurZOrderData = {}
    self.CachColorProportion = {}
    self.ViewModel = nil
    self.GlobalParams = {}
    self.DelayFinishTime = 0
    self.EndEmotionID = 0
    self.CriticalText = ""
    self.bCriticalVisible = false
    self.EndReward = nil
    self.IsFightAgain = false
    self.IdleStateKey = AnimTimeLineSourceKey.BaskIdle
    local DefineCfg = MiniGameClientConfig[Type]
    if DefineCfg then
        self.DefineCfg = DefineCfg
    end

    local CoinID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE -- 金碟币ID
	local IconPath = _G.ScoreMgr:GetScoreIconName(CoinID)
    self.AwardIconPath = IconPath
    self.LastScoreMultAnim = nil

end

--- 是否结束游戏
function MiniGameMonsterToss:OnIsGameRunEnd()
	local RemainTime = self.RemainSeconds
	if RemainTime <= 0 then
		self.RoundEndState = MiniGameRoundEndState.FailTime
		return true
	end
	return false
end

function MiniGameMonsterToss:SetViewModel(ViewModel)
    self.ViewModel = ViewModel
end

--- 是否带有翻倍阶段
function MiniGameMonsterToss:OnIsHaveRestartStage()
    return false
end

--- 翻倍挑战提示参数
function MiniGameMonsterToss:OnCreateRestartContentParams()

end

--- 获取游戏翻倍挑战重置时间和次数
function MiniGameMonsterToss:GetRestartTime()
	-- local Time = 0
	-- local DCfg = self.DefineCfg
    -- if DCfg then
    --     Time = DCfg.TimeLimit or 0
    -- end
	return math.floor(self.GlobalParams[BasketballParamType.BasketballParamTypeTime].Value / 1000)

    
end

--- 获取当前轮能够获得的奖励
function MiniGameMonsterToss:GetTheRewardGotInTheRoundInternal(Round)

end

--- 获取当前轮能够获得的奖励
function MiniGameMonsterToss:GetTheRewardGotInTheRound()

end

--- 获取当前轮轮盘速度
function MiniGameMonsterToss:GetTheSpeedInTheRound()

end

--- 获取顶部tips内容
function MiniGameMonsterToss:OnGetTopTipsContent(GameState)

end

return MiniGameMonsterToss