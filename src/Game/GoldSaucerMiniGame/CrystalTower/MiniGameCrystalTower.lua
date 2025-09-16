local LuaClass = require("Core/LuaClass")
local MiniGameBase = require("Game/GoldSaucerMiniGame/MiniGameBase")
local MajorUtil = require("Utils/MajorUtil")
local CrystalTowerDifficultyCfg = require("TableCfg/CrystalTowerDifficultyCfg") --  
local CrystalTowerroundCfg = require("TableCfg/CrystalTowerroundCfg") -- 
local CrystalTowerInteractionCfg = require("TableCfg/CrystalTowerInteractionCfg")
local CrystalTowerBatterCfg = require("TableCfg/CrystalTowerBatterCfg")
local CrystalTowerParamCfg = require("TableCfg/CrystalTowerParamCfg")
local CrystalTowerBlessCfg = require("TableCfg/CrystalTowerBlessCfg")
local CrystalTowerRewardCfg = require("TableCfg/CrystalTowerRewardCfg")
local CrystalTowerStrengthStageCfg = require("TableCfg/CrystalTowerStrengthStageCfg")

local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local CrystalTowerInteractionProvider = require("Game/GoldSaucerMiniGame/CrystalTower/CrystalTowerInteractionProvider")
local EffectUtil = require("Utils/EffectUtil")
local AudioUtil = require("Utils/AudioUtil")
local CrystalTowerAudioDefine = require("Game/GoldSaucerMiniGame/CrystalTower/CrystalTowerAudioDefine")
local AudioPath = CrystalTowerAudioDefine.AudioPath
local InteractionCategory = ProtoRes.InteractionCategory
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameRoundEndState = GoldSaucerMiniGameDefine.MiniGameRoundEndState
local AnimTimeLineSourceKey = GoldSaucerMiniGameDefine.AnimTimeLineSourceKey
local MiniGameStageType = GoldSaucerMiniGameDefine.MiniGameStageType
local CrystalTowerInteractionCategory = ProtoRes.CrystalTowerInteractionCategory
local Anim = MiniGameClientConfig[MiniGameType.CrystalTower].Anim
local CrystalTowerParamType = ProtoRes.Game.CrystalTowerParamType
local LSTR = _G.LSTR
local UE = _G.UE
local FLOG_ERROR = _G.FLOG_ERROR
local EventID = _G.EventID
local EventMgr = _G.EventMgr
local FLOG_INFO = _G.FLOG_INFO
local TimerMgr = _G.TimerMgr
local LastRoundTrack = 5 -- 最终交互物所在轨道index
local UIViewID = require("Define/UIViewID")

---@class MiniGameCrystalTower
---@param MiniGameType number @GoldSaucerMiniGameDefine.MiniGameType
local MiniGameCrystalTower = LuaClass(MiniGameBase)

---Ctor
function MiniGameCrystalTower:Ctor()
    local Type = MiniGameType.CrystalTower
    self.DynAssetID = nil
    self.MaxRound = 4 -- 最大四轮
	self.MiniGameType = Type
    self.Name = MiniGameClientConfig[Type].Name
    self.UIViewMainID = UIViewID.CrystalTowerStrikerMainPanel
    self.PowerValue = 0 -- 当前总力量值
    self.CTStrengthPro = 0 -- 力量值进度条
    local ParamsCfg =  CrystalTowerParamCfg:FindCfgByKey(CrystalTowerParamType.CrystalTowerParamMaxPower)
    self.MaxProValue = ParamsCfg ~= nil and ParamsCfg.Value or 0 -- 需要多少力量值进度条会满
    self.AddScore = 0 -- 一次交互获取的力量值
    self.bAddScoreVisible = false -- 一次交互获取的力量值显隐
    self.AddScoreOutLineColor = "D34C2EFF"
    self.AddScoreColor = "D8FFDBFF"
    -- self.AccruedScore = 0

    self.bPanelNormalVisible = true
    self.bPanelResultVisible = false
    self.bFailed = false
    self.bSuccessed = false
    self.CTTextMultiple = ""
    self.bTextMultipleVisible = false
    self.MaxComboNum = 0    
    self.CurRoundInteractionNum = 0 -- 当前轮数出现的交互物数量
    self.ComboNum = 0  -- 完美连击数
    self.ResultText = ""
    self.ResultTextColor = ""
    self.RewardGot = 0
    self.CTAddRewardGot = 0
    self.StrengthValue = 0  -- 记录真是力量值
    self.TextQuantityValue = 0 -- 用于显示
    self.RoundEndState = MiniGameRoundEndState.None -- 結束的原因
    self.TextHint = ""
    -- self.bTextHintVisible = false
    self.JDCoinColor = "#FFFFFF"
    self.RightBtnContent = LSTR(250001) -- 再 战
    self.bImgMask2Visible = false
    self.bEnterEndState = false
    -- self.DoubleWinViewID = UIViewID.OutOnALimbDoubleWin
    -- self.SettlementViewID = UIViewID.OutOnALimbSettlementPanel
    self.IdleStateKey = AnimTimeLineSourceKey.CrystalTowerIdle
    local DefineCfg = MiniGameClientConfig[Type]
    if DefineCfg then
        self.DefineCfg = DefineCfg
    end
    self.EndEmotionID = 0
    self.AddScorePos = UE.FVector2D(0, 0)
    self.RoundIntervalTime = {}
    self.RoundIDList = {}
    self.CurRoundIndex = 1
    self.bNormalExit = false
    self.AllProviders = {}
    self.InteractData = {}
    self.ArriveEffectPool = {}
    self.ProviderPos = {}
    self.VfxTriggerStage = 1
    self.HammerEffectID = nil

    self.CriticalText = ""
    self.bCriticalVisible = false
    self.RewardNumByInter = 0               -- 通过交互获得的金碟币
end

function MiniGameCrystalTower:Reset()
    local Type = MiniGameType.CrystalTower
    -- self.DynAssetID = nil
	self.MiniGameType = Type
    self.Name = MiniGameClientConfig[Type].Name
    self.UIViewMainID = UIViewID.CrystalTowerStrikerMainPanel
    self.PowerValue = 0 -- 当前总力量值
    self.CTStrengthPro = 0 -- 力量值进度条
    local ParamsCfg =  CrystalTowerParamCfg:FindCfgByKey(CrystalTowerParamType.CrystalTowerParamMaxPower)
    self.MaxProValue = ParamsCfg ~= nil and ParamsCfg.Value or 0 -- 需要多少力量值进度条会慢
    self.AddScore = 0 -- 一次交互获取的力量值
    -- self.AccruedScore = 0

    self.bAddScoreVisible = false -- 一次交互获取的力量值显隐
    self.AddScoreOutLineColor = "D34C2EFF"
    self.AddScoreColor = "D8FFDBFF"

    self.bPanelNormalVisible = true
    self.bPanelResultVisible = false
    self.bFailed = false
    self.bSuccessed = false
    self.CTTextMultiple = ""
    self.bTextMultipleVisible = false
    self.MaxComboNum = 0    
    self.CurRoundInteractionNum = 0 -- 当前轮数出现的交互物数量
    self.ComboNum = 0  -- 完美连击数
    self.ResultText = ""
    self.ResultTextColor = ""
    self.RewardGot = 0
    self.CTAddRewardGot = 0
    self.EndEmotionID = 0

    self.StrengthValue = 0
    self.TextQuantityValue = 0
    self.RoundEndState = MiniGameRoundEndState.None
    self.TextHint = ""
    -- self.bTextHintVisible = false
    self.JDCoinColor = "#FFFFFF"
    self.RightBtnContent = LSTR(250001) -- 再 战 
    self.bEnterEndState = false
    self.bImgMask2Visible = false
    self.IsBegin = false
    self.VfxTriggerStage = 1
    self.HammerEffectID = nil

    self.IdleStateKey = AnimTimeLineSourceKey.CrystalTowerIdle
    local DefineCfg = MiniGameClientConfig[Type]
    if DefineCfg then
        self.DefineCfg = DefineCfg
    end
    self:InitMiniGame()

    -- local AllProviders = self.AllProviders
    -- for _, v in pairs(AllProviders) do
    --     local Provider = v
    --     Provider:Reset()
    -- end
    self.AddScorePos = UE.FVector2D(0, 0)
    self.RoundIntervalTime = {}
    self.RoundIDList = {}
    self.CurRoundIndex = 1
    self.bNormalExit = false
    self.InteractData = {}
    self:ResetProvider()
    self.AllProviders = {}
    self.ArriveEffectPool = {}
    self.ProviderPos = {}

    
    self.CriticalText = ""
    self.bCriticalVisible = false
    self.RewardNumByInter = 0

    local ViewModel = self:GetViewModel(self.MiniGameType)
    ViewModel:UpdateAddScore()
end


--- 初始化游戏数据
function MiniGameCrystalTower:LoadTableCfg()
    self.RewardCfg = CrystalTowerRewardCfg:FindAllCfg()
    self.StrengthStageData = CrystalTowerStrengthStageCfg:FindAllCfg()
end

--- 初始化游戏数据
function MiniGameCrystalTower:InitMiniGame(Params)
    local ResetTime = self:GetRestartTime()
    self.RemainSeconds = ResetTime
    self.InteractionRule = {
        BeginExcellentInteractY = 208,
		BeginProfectInteractY = 215,
		EndProfectInteractY = 330,
        EndExcellentInteractY = 307,
	}
    self.SpecialInteractionRule = {
        BeginExcellentInteractY = 215,
		BeginProfectInteractY = 250,
		EndProfectInteractY = 330,
		-- EndExcellentInteractY = 307,
    }
end

-- function MiniGameCrystalTower:SetProviderPos(BeginPos)
--     self.ProviderPos = BeginPos
-- end

function MiniGameCrystalTower:SetArriveEffectPool(ArriveEffectPool)
    self.ArriveEffectPool = ArriveEffectPool
end

function MiniGameCrystalTower:RegisterInteractionFactory(Callback)
    local AllProviders = self.AllProviders
    for _, v in pairs(AllProviders) do
        local Provider = v
        Provider:RegisterInteractionFactory(Callback)
    end
end

--- @type 创建4个交互物生成器
function MiniGameCrystalTower:CreateInteractionProvider()
    local ProviderPos = self.DefineCfg.ProviderPos
    local AllProviders = self.AllProviders
    for i = 1, 5 do
        local PosIndex = string.format("Pos%d", i)
        local Provider = CrystalTowerInteractionProvider.New(ProviderPos[PosIndex], i)
        table.insert(AllProviders, Provider)
    end
end

function MiniGameCrystalTower:ResetProvider()
    local AllProviders = self.AllProviders
    for _, v in pairs(AllProviders) do
        local Elem = v
        Elem:Reset()
    end
end

--- @type 开始下落
function MiniGameCrystalTower:OnBeginFalling()
    local AllProviders = self.AllProviders
    for _, v in pairs(AllProviders) do
        local Provider = v
        Provider:OnBeginFalling()
    end
end

function MiniGameCrystalTower:SetbNormalExit(bNormal)
    self.bNormalExit = bNormal
end

function MiniGameCrystalTower:GetbNormalExit()
    return self.bNormalExit
end

function MiniGameCrystalTower:GetMaxRound()
    return self.MaxRound
end

function MiniGameCrystalTower:GetInstanceID()
    return self.DynAssetID
end

function MiniGameCrystalTower:GetRewardCfg()
    return self.RewardCfg
end

function MiniGameCrystalTower:AddCurRoundIndex()
    self.CurRoundIndex = self.CurRoundIndex + 1
    -- 进入下一轮的时候GC一下
    _G.ObjectMgr:CollectGarbage(false)
end

function MiniGameCrystalTower:GetCurRoundIndex()
    return self.CurRoundIndex
end

--- @type 增加力量值
function MiniGameCrystalTower:AddStrengthValue(Value, bShow)
    self.StrengthValue = math.clamp(self.StrengthValue + Value, 0, 99999) 
    if bShow then
        self.TextQuantityValue = math.clamp(self.TextQuantityValue + Value, 0, 99999)
    end
end

--- @type 获得当前力量值
function MiniGameCrystalTower:GetStrengthValue()
    return self.StrengthValue
end

--- @type 获得需要显示的力量值
function MiniGameCrystalTower:GetTextQuantityValue()
    return self.TextQuantityValue
end

--- @type 增加连击数
function MiniGameCrystalTower:AddComboNum(Num)
    self.ComboNum = self.ComboNum + Num
    if self.ComboNum > self.MaxComboNum then
        self:SetMaxComboNum(self.ComboNum)
    end
end

--- @type 设置最大连击数
function MiniGameCrystalTower:SetMaxComboNum(Num)
    self.MaxComboNum = Num
end

function MiniGameCrystalTower:GetMaxComboNum()
    return self.MaxComboNum
end

--- @type 获得连击数
function MiniGameCrystalTower:GetComboNum()
    return self.ComboNum
end

--- @type 重置连击数
function MiniGameCrystalTower:ResetComboNum()
    self.ComboNum = 0

end

function MiniGameCrystalTower:UpdateStrengthPro()
    self.CTStrengthPro = math.clamp(self:GetStrengthValue() / self.MaxProValue, 0, 1)
end

function MiniGameCrystalTower:SetTextHint(Text, bVisible)
    self.TextHint = Text
    -- self.bTextHintVisible = bVisible
end

--- @type 设置一次交互增加的力量值
function MiniGameCrystalTower:SetAddScoreAndVisible(Score)
    self.AddScore = Score
    self.bAddScoreVisible = true
    self.AddScoreOutLineColor = Score > 0 and "D34C2EFF" or "#23232399"
    self.AddScoreColor = Score > 0 and "D8FFDBFF" or "#d5d5d5"

    local StrengthValue = self:GetStrengthValue()
    local EndPosY = 340--225
    local FullStrengthVal = 500
    local TotalYLength = 592
    local PosY = EndPosY - math.clamp(StrengthValue / FullStrengthVal, 0, 1) * TotalYLength
    self.AddScorePos = UE.FVector2D(-310, PosY) -- 242 -350
end

--- @type 隐藏加分的Text
function MiniGameCrystalTower:SetAddScoreVisibleFalse()
    self.bAddScoreVisible = false
end

--- @type 初始化交互数量
function MiniGameCrystalTower:InitInteractionNum(Items)
    local CurRoundInteractionNum = 0
    for _, v in pairs(Items) do
        local Elem = v.Items
        CurRoundInteractionNum = CurRoundInteractionNum + #Elem
    end
    self.CurRoundInteractionNum = CurRoundInteractionNum
    -- print("CurRoundInteractionNum: "..tostring(self.CurRoundInteractionNum))
end

--- @type 设置当前轮次剩余交互物数量
function MiniGameCrystalTower:SubInteractionNum()
    self.CurRoundInteractionNum = self.CurRoundInteractionNum - 1
    -- print("CurRoundInteractionNum: "..tostring(self.CurRoundInteractionNum))
end

function MiniGameCrystalTower:SetIsBegin(IsBegin)
    self.IsBegin = IsBegin
end

--- @type 获得当前轮次剩余交互物数量
function MiniGameCrystalTower:GetInteractionNum()   --
    return self.CurRoundInteractionNum
end

--- @type 设置当前轮次剩余交互物数量
function MiniGameCrystalTower:SetbShowMoneySlot(bVisible)
    self.bEnterEndState = bVisible
end

--- @type 根据剩余金碟币设置花费金碟币Text颜色和按钮内容
function MiniGameCrystalTower:SetBtnContentAndJDCoinColor()
    local OwnJdCoinNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE) --持有的金碟币
    if OwnJdCoinNum >= 1 then
        self.JDCoinColor = "#FFFFFF"
        self.RightBtnContent = LSTR(250001) -- 再 战 
    else
        self.JDCoinColor = "#FF0000"
        self.RightBtnContent = LSTR(250003) -- 前往获取 
    end
end

function MiniGameCrystalTower:CTSetCritical(bCritical)
    local Cfg = CrystalTowerParamCfg:FindCfgByKey(CrystalTowerParamType.CrystalTowerParamCriticalHitTimes)
    if not Cfg then
        return
    end
    
    self.CriticalText = string.format(LSTR(250002), Cfg.Value) -- %s倍暴击
    self.bCriticalVisible = bCritical
    local Anim = self.DefineCfg.Anim
    if bCritical then
        _G.EventMgr:SendEvent(_G.EventID.MiniGameMainPanelPlayAnim, Anim.Critical)
    end
end

function MiniGameCrystalTower:UpdateCriticalRewardGot()
    if self.bCriticalVisible and self.EndReward ~= nil then
        self.RewardGot = self.EndReward
    end
end

--- @type 通过交互增加金碟币
function MiniGameCrystalTower:AddRewardNum(Type, bSucInteract)
	if bSucInteract then
        local InteractCfg = CrystalTowerInteractionCfg:FindCfgByKey(Type)
        if not InteractCfg then
            return
        end
        self.RewardNumByInter = self.RewardNumByInter + InteractCfg.JDRewardNum
	end
end

--- @type 获取奖励
function MiniGameCrystalTower:SetRewardGot(EndReward)
    self.EndReward = EndReward      --- 最终获得金碟币数量，包括暴击，加层等
    local LastRewardGot = self.RewardGot
    local RewardCfg = CrystalTowerRewardCfg:FindAllCfg()
    local Reward = 0
    for _, v in pairs(RewardCfg) do
        local Elem = v
        if self:GetStrengthValue() >= Elem.Score then
            Reward = Elem.GoldCoin
            self.EndEmotionID = Elem.EndEmotionID
        end
    end
    if tonumber(Reward) > tonumber(LastRewardGot) then
        self.CTAddRewardGot = Reward - LastRewardGot
    else
        self.CTAddRewardGot = 0
    end
    self.RewardGot = Reward + self.RewardNumByInter
    if not self.bCriticalVisible and EndReward ~= nil then
        self.RewardGot = EndReward  -- 如果没暴击直接用后端给的数量就行
    end
end

function MiniGameCrystalTower:GetRewardGot()
    return self.RewardGot
end

--- @type 获取交互获得的额外金碟币奖励
function MiniGameCrystalTower:GetInteractRewarNum()
    return self.RewardNumByInter
end


function MiniGameCrystalTower:GetEndEmotionID()
    return self.EndEmotionID
end

--- @type 设置成功还是失败，该显示什么
function MiniGameCrystalTower:SetSuccessOrFail(bSuccess, bTimeOut)
    local ResultCfg = GoldSaucerMiniGameDefine.ResultCfg
    self.bFailed = not bSuccess
    self.bSuccessed = bSuccess
    local NeedText, NeexColor
    if bSuccess then
        NeedText = ResultCfg.Success.Text
        NeexColor = ResultCfg.Success.TextColor
    -- elseif bTimeOut then
    --     NeedText = ResultCfg.TimeOut.Text
    --     NeexColor = ResultCfg.TimeOut.TextColor
    else
        NeedText = ResultCfg.Failed.Text
        NeexColor = ResultCfg.Failed.TextColor
    end
    self.ResultText = NeedText
    self.ResultTextColor = NeexColor
end

--- @type 设置增加多少比例的力量值
function MiniGameCrystalTower:SetTextMutiAndVisible(Scale)
    self.CTTextMultiple = string.format("×%s", Scale)
    self.bTextMultipleVisible = Scale > 1
end

--- @type 展示中心tip
function MiniGameCrystalTower:ShowCenterSmashTip()
    local ResultPower = self.DefineCfg.ResultPower
    local StrengthValue = self:GetStrengthValue()
    local bYellowTipVisible, bPrettyTipVisible, bGoodTipVisible ,bFailTipVisible, Text, NeedAnim
    local SubText = tostring(StrengthValue.."Pz")
    local TipVMData = {}

    local AllRewardCfg = CrystalTowerRewardCfg:FindAllCfg()
    if tonumber(StrengthValue) >= AllRewardCfg[ResultPower.Profect].Score then
        bYellowTipVisible = true
        Text = LSTR(260005) -- 全力一击
        NeedAnim = Anim.AnimTipsYellow
    elseif tonumber(StrengthValue) >= AllRewardCfg[ResultPower.Nice].Score then
        bPrettyTipVisible = true
        NeedAnim = Anim.AnimTipsBlue
        Text = LSTR(260006) -- 打得漂亮
    elseif tonumber(StrengthValue) >= AllRewardCfg[ResultPower.Good].Score then
        bGoodTipVisible = true
        NeedAnim = Anim.AnimTipsGreen
        Text = LSTR(260007) -- 打得好
    -- elseif StrengthValue < ResultPower.Good and StrengthValue > 0 then
    --     bFailTipVisible = true
    --     Text = LSTR("失败")
    --     NeedAnim = Anim.AnimTipsFail
    elseif tonumber(StrengthValue) == 0 then
        bFailTipVisible = true
        Text = LSTR(260008) -- 失败
        NeedAnim = Anim.AnimTipsFail
    end
    TipVMData.bYellowTipVisible = bYellowTipVisible
    TipVMData.bPrettyTipVisible = bPrettyTipVisible
    TipVMData.bGoodTipVisible = bGoodTipVisible
    TipVMData.bFailTipVisible = bFailTipVisible
    TipVMData.bFailTipVisible = bFailTipVisible
    TipVMData.bSubDataVisible = true
    TipVMData.Text = Text
    TipVMData.SubText = SubText
    local ViewModel = self:GetViewModel(self.MiniGameType)
    local TipVM = ViewModel:GetInteractionResultTipVM()
    TipVM:UpdateVM(TipVMData)
    ViewModel:SetbShootingTipVisible(true)
    EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, NeedAnim)
    local TimerHandle = TimerMgr:AddTimer(self, function() ViewModel:SetbShootingTipVisible(false) end, 2)
    self:AddTimerHandle(TimerHandle)
end

--- @type 当开始交互
--- @param TrackIndex 在第几个赛道
function MiniGameCrystalTower:OnInteract(PosY, Category, TrackIndex, ID)
    local InteractionRule = self.InteractionRule
    local Cfg = CrystalTowerInteractionCfg:FindCfgByKey(Category)
    if Cfg == nil then
        return
    end
    local DefineCfg = self.DefineCfg
    local Score = Cfg.Score
    local bPlayArriveEffect = true
    local NeedAudio
    if Category == CrystalTowerInteractionCategory.CT_CATEGORY_ERROR then                           -- 错误的交互物
        Score = Cfg.Score
        NeedAudio = AudioPath.InteracteMiss
    elseif PosY > InteractionRule.BeginProfectInteractY and PosY < InteractionRule.EndProfectInteractY then -- 完美
        Score = Cfg.Score
        NeedAudio = AudioPath.InteractePerfect
    else                                                                                                -- Miss
        Score = 0
        bPlayArriveEffect = false
        NeedAudio = AudioPath.InteracteMiss
    end
    if TrackIndex ~= LastRoundTrack then
        AudioUtil.LoadAndPlayUISound(NeedAudio)
    end
    -- local Score = self:GetScoreByPosAndCate(PosY, Category)
    local ViewModel = self:GetViewModel(self.MiniGameType)
    local ItemValue
    if Category <= CrystalTowerInteractionCategory.CT_CATEGORY_ERROR or Category == CrystalTowerInteractionCategory.CT_CATEGORY_STARLIGHT then
        self:AddStrengthValueAndCombos(Score)    
        ItemValue = self:ConstructSingleVMData(Score)
    else
        bPlayArriveEffect = self:MultiplyStrengthValue(Cfg, PosY)
        ItemValue = self:ConstructCenterResultData(PosY)
        AudioUtil.LoadAndPlayUISound(ItemValue.NeedAudioPath)
        EventMgr:SendEvent(EventID.MiniGameMainPanelPlayAnim, Anim.AnimShock)
    end
    self:AddRewardNum(Category, bPlayArriveEffect or Score ~= 0)
    self:SetRewardGot()
    ViewModel:UpdateListItemByPos(ItemValue, TrackIndex)
    ViewModel:UpdateAddScore(true)
    ViewModel:UpdateRewardGotSingle()
    -- self:CheckIsFinishRoundAndSend()
    if bPlayArriveEffect then
        self:PlayArriveEffectAnim(Category, TrackIndex, ItemValue)
    end
    self:UpdateHammerVfx(false)

    return ItemValue
end

--- @type 播放交互动效
function MiniGameCrystalTower:PlayArriveEffectAnim(Category, TrackIndex, ItemValue)
    local ArriveEffectPool = self.ArriveEffectPool
    if TrackIndex == LastRoundTrack and ItemValue.bProfectVisible then
        TrackIndex = TrackIndex + 1
    end
    local NeedEffect = ArriveEffectPool[TrackIndex]
    if NeedEffect == nil then
        return
    end
    NeedEffect:ActiveSwitcherAndPlayAnim(Category)
end

--- @type 构造交互结果的tableview数据
function MiniGameCrystalTower:ConstructInteractResultListData()
    -- local InteractData = {}
    local InteractResultData = {}
    for i = 1, 4 do
        local Tmp = {}
        Tmp.bExcellentVisible = false
        Tmp.ComboNum = 0
        Tmp.bMissVisible = false
        Tmp.bProfectVisible = false
        Tmp.bMultipleVisible = false
        table.insert(InteractResultData, Tmp)
    end
    return InteractResultData
end


function MiniGameCrystalTower:ConstructSingleVMData(Score)
    local Tmp = {}
    Tmp.bExcellentVisible = false
    local bMissVisible, bProfectVisible, bMultipleVisible
    local ComboNum = 0
    if Score > 0 then 
        bMissVisible = false
        bProfectVisible = true
        if self:GetComboNum() > 1 then
            bMultipleVisible = true
            ComboNum = self:GetComboNum()
        else
            bMultipleVisible = false
        end
    else
        bMissVisible = true
        bProfectVisible = false
        bMultipleVisible = false
    end
    Tmp.bMissVisible = bMissVisible
    Tmp.bProfectVisible = bProfectVisible
    Tmp.bMultipleVisible = bMultipleVisible
    Tmp.ComboNum = ComboNum
    return Tmp
end

function MiniGameCrystalTower:ConstructCenterResultData(PosY)
    local CenterItemData = {}
    local SpecialInteractionRule = self.SpecialInteractionRule
    local bMissVisible, bProfectVisible, bExcellentVisible
    local NeedAudio
    if PosY >= SpecialInteractionRule.EndProfectInteractY then
        bMissVisible = true
        bProfectVisible = false
        bExcellentVisible = false
        NeedAudio = AudioPath.InteracteMiss
    elseif PosY >= SpecialInteractionRule.BeginProfectInteractY then
        bMissVisible = false
        bProfectVisible = true
        bExcellentVisible = false
        NeedAudio = AudioPath.InteractePerfect
    elseif PosY >= SpecialInteractionRule.BeginExcellentInteractY then
        bMissVisible = false
        bProfectVisible = false
        bExcellentVisible = true
        NeedAudio = AudioPath.InteractePerfect
    else
        bMissVisible = true
        bProfectVisible = false
        bExcellentVisible = false
        NeedAudio = AudioPath.InteracteMiss
    end
    CenterItemData.bMultipleVisible = false
    CenterItemData.bMissVisible = bMissVisible
    CenterItemData.bProfectVisible = bProfectVisible
    CenterItemData.bExcellentVisible = bExcellentVisible
    CenterItemData.NeedAudioPath = NeedAudio
    return CenterItemData
end

--- @type 缓存下一轮的交互物数据
function MiniGameCrystalTower:InitNextRoundCfgs(Items)
    local RoundID = self.RoundIDList[self.CurRoundIndex]
    local Cfg = CrystalTowerroundCfg:FindCfgByKey(RoundID)
    if Cfg == nil then
        return
    end
    self:InitInteractionNum(Items)
    local CurRoundIndex = self.CurRoundIndex
    local MaxRound = self.DefineCfg.MaxRound
    local AllProviders = self.AllProviders
    for i = 1, #Items do
        local SubItems = Items[i]
        local InteractionCfgs = {}
        for i = 1, #SubItems.Items do
            local CategoryIndex = SubItems.Items[i]
            local InteractionCfg = {}
            -- InteractionCfg.Pos = i
            InteractionCfg.DelayShowTime = Cfg.DelayShowTime[CategoryIndex + 1]
            InteractionCfg.Category = Cfg.Category[CategoryIndex + 1]
            table.insert(InteractionCfgs, InteractionCfg)
        end
        if CurRoundIndex < MaxRound then
            AllProviders[i]:SetInteractionCfgs(InteractionCfgs)
        else
            AllProviders[5]:SetInteractionCfgs(InteractionCfgs) -- index == 5是中心的Provider发射
        end
    end
end

--- @type 检测是否完成当前轮次
function MiniGameCrystalTower:CheckIsFinishRoundAndSend()
	self:SubInteractionNum()
	local CurInterationNum = self:GetInteractionNum()
    local CurRoundIndex = self:GetCurRoundIndex()
    local IntervalTime = self.RoundIntervalTime[CurRoundIndex]

	if CurInterationNum == 0 then
        self.InteractTimer = TimerMgr:AddTimer(self, function() 
            self:ResetProvider()
            _G.GoldSaucerMiniGameMgr:SendMsgCrystalTowerInteractionReq()
        self:AddCurRoundIndex()
        end, IntervalTime, 0, 1)
        self:AddTimerHandle(self.InteractTimer)
    end
end

function MiniGameCrystalTower:UnRegisterTimer()
    if self.InteractTimer ~= nil then
        TimerMgr:CancelTimer(self.InteractTimer)
    end
end

--- @type 设置每一轮的间隔时间
function MiniGameCrystalTower:SetRoundIntervalTimeAndRoundData(DifficultyLv)
    local Cfg = CrystalTowerDifficultyCfg:FindCfgByKey(DifficultyLv)
    if Cfg ~= nil then
        local IntervalTime = Cfg.IntervalTime
        for i = 1, #IntervalTime do
            IntervalTime[i] = IntervalTime[i] / 1000    -- 毫秒变成秒
        end
        self.RoundIntervalTime = IntervalTime
        self.RoundIDList = Cfg.RoundID
    end
end

--- @type 获得当前的轮次ID
function MiniGameCrystalTower:GetCurRoundID()
    local CurRoundIndex = self.CurRoundIndex
    local RoundIDList = self.RoundIDList
    if CurRoundIndex > #RoundIDList then
        _G.FLOG_ERROR("CurRoundIndex is beyond max list Length")
        return
    end
    return RoundIDList[CurRoundIndex]
end

--- @type 播放锤子特效
function MiniGameCrystalTower:UpdateHammerVfx(bInit)
    if bInit then
        self:PlayHummerVfxEffect(1)
        return
    end

    local TriggerStage = self:GetEnterNewStage()
    local VfxTriggerStage = self.VfxTriggerStage
    if VfxTriggerStage ~= TriggerStage then
        self:PlayHummerVfxEffect(TriggerStage)
        self.VfxTriggerStage = TriggerStage
    end
end
-- function MiniGameCrystalTower:LoadHummerVfxEffect(TriggerStage)
--     self:TryHideHammerVfx() -- 如果有的话先清除
--     local VfxPath = self.DefineCfg.VfxPath
--     local VfxParameter = _G.UE.FVfxParameter()
--     local Major = MajorUtil.GetMajor()
    
--     VfxParameter.VfxRequireData.EffectPath = VfxPath.Hammer
--     -- VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_MiniGameCrystalTower
--     local AttachPointType_MainWeapon = _G.UE.EVFXAttachPointType.AttachPointType_MainWeapon--AttachPointType_Body
--     local MajorTransform = Major:FGetActorTransform()
--     local NeedTransform = _G.UE.FTransform()
 
--     VfxParameter.OffsetTransform = NeedTransform 
--     VfxParameter.VfxRequireData.VfxTransform = MajorTransform
--     VfxParameter:SetCaster(Major, 0, AttachPointType_MainWeapon, 0)
--     EffectUtil.LoadVfx(VfxParameter)

--     -- self.HammerEffectID = EffectUtil.KickTrigger(VfxParameter, TriggerStage)
--     -- self.VfxTriggerStage = TriggerStage
-- end

function MiniGameCrystalTower:PlayHummerVfxEffect(TriggerStage)
    self:TryHideHammerVfx() -- 如果有的话先清除
    local VfxPath = self.DefineCfg.VfxPath
    local VfxParameter = _G.UE.FVfxParameter()
    local Major = MajorUtil.GetMajor()

    VfxParameter.VfxRequireData.EffectPath = VfxPath.Hammer
    VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_MiniGameCrystalTower
    local AttachPointType_MainWeapon = _G.UE.EVFXAttachPointType.AttachPointType_MainWeapon--AttachPointType_Body
    local MajorTransform = Major:FGetActorTransform()
    local NeedTransform = _G.UE.FTransform()
 
    VfxParameter.OffsetTransform = NeedTransform 
    VfxParameter.VfxRequireData.VfxTransform = MajorTransform
    VfxParameter.VfxRequireData.bAlwaysSpawn = true
    VfxParameter:SetCaster(Major, 0, AttachPointType_MainWeapon, 0)

    --已经有了
    if self.HammerEffectID ~= nil and self.HammerEffectID > 0 then
        EffectUtil.SetWorldTransform(self.HammerEffectID, MajorTransform)
        EffectUtil.KickTrigger(self.HammerEffectID, TriggerStage)
        self.VfxTriggerStage = TriggerStage
    else
        self.HammerEffectID = EffectUtil.KickTrigger(VfxParameter, TriggerStage)

        self.VfxTriggerStage = TriggerStage
        FLOG_INFO("PlayHummerVfxEffect")
        if self.HammerEffectID == 0 then
            FLOG_INFO("PlayHummerVfxEffect Fail ")
        end
    end

    local NeedAudioPath
    if TriggerStage == 2 then -- 数字二
        NeedAudioPath = AudioPath.BiggerHammer
    elseif TriggerStage > 2 then
        NeedAudioPath = AudioPath.BiggestHammer
    end
    AudioUtil.LoadAndPlayUISound(NeedAudioPath)
end

--- @type 检测是否进入了新的阶段
function MiniGameCrystalTower:GetEnterNewStage()
    local TriggerStage  = 1
    local StrengthStage = self.StrengthStageData
    local StrengthValue = self.StrengthValue
    for i = 1, #StrengthStage do
        local StrengthDataValue = StrengthStage[i].StrengthValue
        if StrengthValue > StrengthDataValue then
            TriggerStage = i
        end
    end
    return TriggerStage
end

--- @type 干掉锤子Vfx特效
function MiniGameCrystalTower:TryHideHammerVfx()
    local HammerEffectID = self.HammerEffectID
    if HammerEffectID ~= nil then
        EffectUtil.StopVfx(HammerEffectID)
        FLOG_INFO("HideHummerVfxEffect")
        EffectUtil.UnloadVfx(HammerEffectID)
        self.HammerEffectID = nil
    end
end

--- @type 获得当前的轮次ID
-- function MiniGameCrystalTower:GetRoundIntervalTime()
--     local CurRoundIndex = self.CurRoundIndex
--     local RoundIntervalTime = self.RoundIntervalTime
--     if CurRoundIndex > #RoundIntervalTime then
--         _G.FLOG_ERROR("CurRoundIndex is beyond max list Length")
--         return
--     end
--     return RoundIntervalTime[CurRoundIndex]
-- end

--- @type 增加力量值和设置连击数
function MiniGameCrystalTower:AddStrengthValueAndCombos(Score)
    local RewardScore = Score
	if Score > 0 then
		self:AddComboNum(1)
		local ComboNum = self:GetComboNum() -- 获得连击数
        ComboNum = ComboNum > 9 and 9 or ComboNum   -- 连击额外加分最大为9
		local ComboCfg = CrystalTowerBatterCfg:FindCfgByKey(ComboNum)
		if ComboCfg ~= nil then
            RewardScore = Score + ComboCfg.Score  -- 增加连续得分
		end
	else
		self:ResetComboNum( )
	end
	self:AddStrengthValue(RewardScore, true)
    self:SetAddScoreAndVisible(RewardScore)
    self:UpdateStrengthPro()
end

--- @type 增加力量值和设置连击数
function MiniGameCrystalTower:MultiplyStrengthValue(InteractionCfg, PosY)
    local bPlayEffect
    local StrengthValue = self:GetStrengthValue() --CTTextMultiple
    local MultiScale = 1
    local SpecialInteractionRule = self.SpecialInteractionRule
    if PosY >= SpecialInteractionRule.EndProfectInteractY then
        bPlayEffect = false
    elseif PosY >= SpecialInteractionRule.BeginProfectInteractY then
        MultiScale = InteractionCfg.ProfectMagn / 100
        bPlayEffect = true
    elseif PosY >= SpecialInteractionRule.BeginExcellentInteractY then
        local Scale = InteractionCfg.ExcellectMagn-- 取一位小数
        MultiScale = Scale / 100
        bPlayEffect = true
    else
        bPlayEffect = false
    end
    local RewardScore = math.ceil(StrengthValue * MultiScale) - StrengthValue
    self:ResetComboNum( )
    self:SetTextMutiAndVisible(MultiScale)
	self:AddStrengthValue(RewardScore, false)
    self:UpdateStrengthPro()
    return bPlayEffect
end

function MiniGameCrystalTower:GetProviderByPos(TrackIndex)
    local AllProviders = self.AllProviders
    for _, v in pairs(AllProviders) do
        local Elem = v
        if Elem.TrackIndex == TrackIndex then
            return Elem
        end
    end
    return
end

function MiniGameCrystalTower:GetRoundIntervalTime()
    return self.RoundIntervalTime
end

--- @type 设置显示游戏界面还是结算界面
function MiniGameCrystalTower:SetPanelNormalVisible(bVisible)
    self.bPanelNormalVisible = bVisible
    self.bPanelResultVisible = not bVisible
end

-- function MiniGameCrystalTower:CheckHitResult(Type, PauseTime)
--     local InteractResult = GoldSaucerMiniGameDefine.InteractResult
--     local CheckResultTime = CuffCfg.CheckResultTime
--     local NeedTime
--     if Type == InteractionCategory.CATEGORY_LOW then
-- 		NeedTime = CheckResultTime.Low
-- 	elseif Type== InteractionCategory.CATEGORY_MIDDLE then
-- 		NeedTime = CheckResultTime.Middle
-- 	elseif Type== InteractionCategory.CATEGORY_HIGH then
-- 		NeedTime = CheckResultTime.High
-- 	else
--         NeedTime = CheckResultTime.Other
-- 	end
--     if PauseTime < NeedTime.Great or PauseTime >= NeedTime.Miss then
--         return InteractResult.Fail
--     elseif PauseTime >= NeedTime.Profect then
--         return InteractResult.Perfect
--     elseif PauseTime >= NeedTime.Great then
--         return InteractResult.Excellent
--     end
--     return InteractResult.Fail
-- end

--- 设置是否结束游戏
function MiniGameCrystalTower:SetEndState()
    self.GameState = MiniGameStageType.End
end

--- 是否是因为时间结束而结束游戏
function MiniGameCrystalTower:IsTimeOut()
    return self.RoundEndState == MiniGameRoundEndState.FailTime
end

--- 设置结束的原因
function MiniGameCrystalTower:SetRoundEndState(State)
    self.RoundEndState = State
end

--- 是否有难度选择阶段
function MiniGameCrystalTower:OnIsGameHaveDifficultySelect()
    return false
end

--- 获取镜头移动参数
function MiniGameCrystalTower:OnCreateCameraSettingParam()
    local CameraMoveParam = _G.UE.FCameraResetParam()
	CameraMoveParam.Distance = 540
	CameraMoveParam.Rotator =  _G.UE.FRotator(-5, -8, 0)
	CameraMoveParam.ResetType =  _G.UE.ECameraResetType.Interp
	CameraMoveParam.LagValue = 10
	CameraMoveParam.NextTransform = _G.UE.FTransform()
	CameraMoveParam.TargetOffset = _G.UE.FVector(0, 0, 0)
	CameraMoveParam.SocketExternOffset = _G.UE.FVector(0, 300, 80)
	CameraMoveParam.FOV = 0
	CameraMoveParam.bRelativeRotator = true
    return CameraMoveParam
end

function MiniGameCrystalTower:bNeedLoop()
    return true
end

--- 是否结束游戏
function MiniGameCrystalTower:OnIsGameRunEnd()

    if self.RoundEndState == MiniGameRoundEndState.Success or self.RoundEndState == MiniGameRoundEndState.FailChance then
		return true
    end
	local RemainTime = self.RemainSeconds
	if RemainTime <= 0 then
        self:SetRoundEndState(MiniGameRoundEndState.FailTime)
		return true
	end

  
	return false
end

--- 获取顶部tips内容
function MiniGameCrystalTower:OnGetTopTipsContent(GameState)
    return ""
end

--- 构造成功列表数据
function MiniGameCrystalTower:ConstructEndResultData(bNewPower, bNewContinueHit)
    local NeedAttactCount =  self:GetMaxComboNum()
    local bComboRecordVisible = bNewContinueHit
    local NeedPower =  self:GetStrengthValue()
    local bPowerRecordVisible = bNewPower
    local ResultListData = {}
    local Temp1, Temp2 = {}, {}
    Temp1.VarName = LSTR(250004) -- 力量值（复用重击加美什）
    Temp1.bIsNewRecord = bPowerRecordVisible
    Temp1.bIsPerfectChallenge = bPowerRecordVisible
    Temp1.Value = string.format("%sPz", NeedPower)
    Temp2.VarName = LSTR(250005) -- 连击数（复用重击加美什）
    Temp2.bIsNewRecord = bComboRecordVisible
    Temp2.bIsPerfectChallenge = bComboRecordVisible
    Temp2.Value = string.format(LSTR(260009), NeedAttactCount) -- %s次
    table.insert(ResultListData, Temp1)
    table.insert(ResultListData, Temp2)
    self.ResultListData = ResultListData
end

function MiniGameCrystalTower:GetRestartTime()
    local ParamsCfg =  CrystalTowerParamCfg:FindCfgByKey(CrystalTowerParamType.CrystalTowerParamTypeTime)
    if ParamsCfg == nil then
        return
    end
	return ParamsCfg.Value / 1000
end

return MiniGameCrystalTower

