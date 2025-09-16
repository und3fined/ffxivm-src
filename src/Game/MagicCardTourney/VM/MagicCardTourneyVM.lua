
--
-- Author: Carl
-- Date: 2023-10-08 16:57:14
-- Description:幻卡大赛VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local MatchMemberItemVM = require("Game/MagicCardTourney/VM/Item/MagicCardTourneyMatchMemberItemVM")
local MagicCardTourneyRankItemVM = require("Game/MagicCardTourney/VM/Item/MagicCardTourneyRankItemVM")
local MagicCardTourneySignUpVM = require("Game/MagicCardTourney/VM/MagicCardTourneySignUpVM")
local TourneyStageInfoVM = require("Game/MagicCardTourney/VM/MagicCardTourneyStageInfoVM")
local EffectListItemVM = require("Game/MagicCardTourney/VM/Item/MagicCardTourneyEffectItemVM")
local MagicCardTourneyRewardItemVM = require("Game/MagicCardTourney/VM/Item/MagicCardTourneyRewardItemVM")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local EMatchState = TourneyDefine.EMatchState
local TimeUtil = _G.TimeUtil

---@class MagicCardTourneyVM : UIViewModel
---@field IsSignUp boolean @是否已经报名
---@field CurBattleCount number @当前对局数
---@field MaxBattleCount number @总对局数
---@field Score number @当前积分
---@field CurStageIndex string @当前阶段索引
---@field CurStageName string @当前阶段名
---@field TourneyFullName string @幻卡大赛+奖杯名
---@field TourneyCupName string @大赛奖杯名
---下次大赛信息
---
local MagicCardTourneyVM = LuaClass(UIViewModel)

function MagicCardTourneyVM:Ctor()
    self.TourneySignUpVM = MagicCardTourneySignUpVM.New()
    self.StageInfoVM = TourneyStageInfoVM.New()
    self.EffectChoiceVMList = UIBindableList.New(EffectListItemVM)
    self.SelectedEffectVMList = UIBindableList.New(EffectListItemVM)
    self.TourneyRankList = UIBindableList.New(MagicCardTourneyRankItemVM)
    self.TourneyRewardVMs = UIBindableList.New(MagicCardTourneyRewardItemVM)
    self.IsSignUp = false
    self.CurBattleCount = 0
    self.Score = 0
    self.CurStageIndex = 1
    self.TourneyTitle = ""
    self.TourneyFullName = ""
    self.TourneyCupName = ""
    self.NextTourneyCupName = ""
    self.CurEffectName = ""
    self.StageAndRoundText = ""
    self.StageAndEffectText = ""
    self.RuleText = nil
    self.TourneyInfo = {}
    self.AutoCancelCDTip = ""
    self.AutoCancelCDPercent = 0
    self.TourneyID = 1
    self.NextTourneyID = 1
    self.IsCurEffectFinished = false
    self.TourneyDetailScoreText = ""
    self.StageInfoScoreText = ""
    self.TipText = ""
    self.StageInfoVisible = true
    self.ExitVisible = false
    self.RuleTextVisible = false
    self.StartBtnVisible = true
    self.IsFinishedTourney = false
    self.EndTime = 0
    self.NextEndTime = 0
    self.StartTime = 0
    self.NextStartTime = 0
    self.CurStageText = ""
    self.GetAwardDeadLineText = "" -- 领取奖励剩余时间
    self.SettlementDateText = "" -- 大赛结束剩余时间
    -- 副本玩法界面匹配入口使用
    self.PWorldTourneyCupName = "" 
    self.PWorldTourneyInfoText = ""
    self.CurStageEffectResultText = ""
    self.CurStageScoreChange = 0
    self.IsJoinBtnEnable = true -- 进入对局室副本按钮开关
    self.JoinBtnText = TourneyDefine.EnterMatchRoomText
    self.Model = -1
end

function MagicCardTourneyVM:OnInit()
    -- if TourneyVMUtils == nil then
    --     TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
    -- end
    self.MaxBattleCount = TourneyVMUtils.GetMaxBattleCount()
    self:InitSelectedEffectList()
    self.MatchMemberVMs = UIBindableList.New(MatchMemberItemVM)
end

function MagicCardTourneyVM:OnBegin()

end

function MagicCardTourneyVM:OnEnd()

end

function MagicCardTourneyVM:OnShutdown()

end

function MagicCardTourneyVM:InitSelectedEffectList()
    self.SelectedEffectList = {}
    for index = 1, 4 do
        local Effect = {
            StageIndex = index,
        }
        table.insert(self.SelectedEffectList, Effect)
    end
end

---@type 更新大赛信息
function MagicCardTourneyVM:UpdateTourneyInfo(TourneyInfo)
    if TourneyInfo == nil then
        return
    end

    self.TourneyInfo = TourneyInfo
    -- 大赛基本信息
    self.TourneyID = TourneyVMUtils.GetTourneyIDByIndex(self.TourneyInfo.TourneyID)
    self.NextTourneyID = TourneyVMUtils.GetTourneyIDByIndex(self.TourneyInfo.TourneyID + 1)

    self.StartTime = math.floor(self.TourneyInfo.StartTime/1000) -- 传回的时间是毫秒，转成秒
    self.NextStartTime = self.StartTime + TourneyDefine.Duration * 2

    
    self.IsSignUp = self.TourneyInfo.IsSignUp
    self.AwardCollected = self.TourneyInfo.AwardCollected  -- 已领奖
    self.IsActive = self.TourneyInfo.IsActive
    self.CanAwardCollect = not self.IsActive and not self.AwardCollected -- 可领奖（未领 且 大赛结束）
    self.CurStageStats = self.TourneyInfo.Stats
    self.PlayerScore = self.TourneyInfo.Score
    self.CurBattleCount = self.TourneyInfo.BattleCount
    self.Score = self.TourneyInfo.Score
    self.ScoreProgress = math.clamp(self.Score / TourneyDefine.MaxScore, 0, 1)
    
    -- 大赛日期
    self.EndTime = self.StartTime + TourneyDefine.Duration
    self.NextEndTime = self.NextStartTime + TourneyDefine.Duration
    local StartDateText = TimeUtil.GetTimeFormat("%Y/%m/%d", self.StartTime)
    local EndDateText = TimeUtil.GetTimeFormat("%Y/%m/%d", self.EndTime)
    local NextStartDateText = TimeUtil.GetTimeFormat("%Y/%m/%d", self.NextStartTime)
    local NextEndDateText = TimeUtil.GetTimeFormat("%Y/%m/%d", self.NextEndTime)

    local CurDateText = string.format(TourneyDefine.PWorldTourneyInfoWithActiveText, StartDateText, EndDateText)
    local NextDateText = string.format(TourneyDefine.PWorldTourneyInfoWithDiableText, NextStartDateText, NextEndDateText)
    self.PWorldTourneyInfoText = self.IsActive and CurDateText or NextDateText
    local EndTimeText = _G.TimeUtil.GetTimeFormat("%Y/%m/%d %H:%M", self.EndTime)
    local LocalEndTimeText = LocalizationUtil.GetTimeForFixedFormat(EndTimeText, false) --时间本地化
    self.GetAwardDeadLineText = string.format(TourneyDefine.GetRewardTimeText, LocalEndTimeText)
    -- 大赛效果
    local SelectEffectList = self.TourneyInfo.SelectedEffectList
    local EffectsLen = table.length(SelectEffectList)
    self.CurEffectInfo = EffectsLen > 0 and SelectEffectList[EffectsLen] or nil
    self.CurStageIndex = math.clamp(EffectsLen, 1, 4)
    self.CurStageName = TourneyVMUtils.GetStageNameByIndex(self.CurStageIndex)

    -- 领取奖励剩余时间
    local Secs = self:GetRemainTimeForReward()
	local LocalRemainTime = LocalizationUtil.GetCountdownTimeForLongTime(Secs) --天小时 _G.DateTimeTools.TimeFormat(Secs, "dd:hh", true) 
	self.SettlementDateText = string.format(TourneyDefine.RemainTimeForAwardText, LocalRemainTime)
    -- 大赛名称
    local TourneyData = TourneyVMUtils.GetTourneyDataByID(self.TourneyID)
    if TourneyData then
        self.TourneyCupName = TourneyData.CupName
        self.TourneyTitle = TourneyData.Title
        self.TourneyFullName = self.TourneyTitle..self.TourneyCupName
    end

    local NextTourneyData = TourneyVMUtils.GetTourneyDataByID(self.NextTourneyID)
    if NextTourneyData then
        self.NextTourneyCupName = NextTourneyData.CupName
    end
    self.PWorldTourneyCupName = self.IsActive and self.TourneyCupName or self.NextTourneyCupName

    self:UpdateScoreText()
    self.TourneyDetailScoreText = string.format(TourneyDefine.TourneyDetailScoreText, self.Score)
    self:UpdateSignUpVM()
    self:UpdateStageInfoVM()
    self:UpdateEffectChoiceInfo(self.TourneyInfo.EffectChoiceList)
    self:UpdateSelectEffectList(SelectEffectList)
    
    -- 阶段
    local AwardInfo = TourneyVMUtils.GetMagicCardTourneyScoreAward(self.CurStageIndex)
    if AwardInfo then
        self.CurStageDesc = string.format(TourneyDefine.StageDescText,AwardInfo.Win, AwardInfo.Lose)
        local StageNameHighLight = string.format("<span color=\"#bd8213\">%s</>", self.CurStageName)
        self.CurStageText = string.format(TourneyDefine.CurStageDesc, StageNameHighLight, self.CurStageDesc)
    end
    
    --效果进度
    if self.CurEffectInfo then
        self.CurStageScoreChange = self.CurEffectInfo.ScoreChange
        local EffectData = TourneyVMUtils.GetEffectInfoByEffectID(self.CurEffectInfo.EffectID)
        self.CurEffectName = EffectData and EffectData.EffectName or ""
        self.EffectArg = EffectData and EffectData.Arg or 0
        self.EffectProgress = self.CurEffectInfo.Progress
        self.ProgressText = ""
        self.CurEffectDesc = EffectData and EffectData.Desc or ""
        if TourneyVMUtils.IsNeedShowEfectProgress(self.CurEffectInfo.EffectID) then
            self.ProgressText = string.format("(%d/%d)", self.EffectProgress, self.EffectArg)
        end

        if self.CurStageName and self.CurEffectName then
            self.StageAndEffectText = self.CurStageName..":"..self.CurEffectName --..self.ProgressText
            self.EffectAndProgressText = self.CurEffectName..self.ProgressText
        end

        local EfectStatus = self:GetCurStageEffectStatusText()
        -- 阶段结束不显示进行中
        if EfectStatus == TourneyDefine.EffectStatusText[0] then
            EfectStatus = ""
        end
        self.CurStageEffectResultText = string.format(TourneyDefine.StageEffectBufffText, self.CurEffectName, EfectStatus)
    end

    local MatchRoomInfo = TourneyVMUtils.GetMatchRoomInfo()
	if self.TourneyRewardVMs then
        local Rewards = TourneyVMUtils.GetAwardListByRank(1, self.TourneyID) --MatchRoomInfo.Rewards --or {{ID = 83015111},}
        self.TourneyRewardVMs:UpdateByValues(Rewards)
	end
    
end

---@type 更新积分栏文本
function MagicCardTourneyVM:UpdateScoreText()
    self.StageInfoVisible = true
    self.RuleTextVisible = false
    self.ExitVisible = false
    self.IsFinishedTourney = false

    if self.CurBattleCount and self.MaxBattleCount then
        self.IsFinishedTourney = (self.IsActive and self.IsSignUp and self.CurBattleCount >= self.MaxBattleCount)
    end
    local AwardList = TourneyVMUtils.GetTourneySettlementAward(self.PlayerScore, self.PlayerRank, self.TourneyID)
    local IsRewardValid = AwardList and #AwardList > 0
    local RewardCondition = self.IsSignUp and not self.IsActive -- 已报名且大赛结束了
    local AwardNotCollected = not self.AwardCollected --未领奖
    local CanShowTourneyInfo = IsRewardValid and RewardCondition and AwardNotCollected
    if not self.IsActive then
        self.RuleText = ""
        self.TourneyFullName = TourneyDefine.RoomTitle
        self.ExitVisible = true
        if CanShowTourneyInfo then
            self.StageInfoScoreText = string.format(TourneyDefine.StageInfoScoreText, self.Score)
            self.StageAndRoundText = string.format(TourneyDefine.RoundText, self.CurBattleCount, self.MaxBattleCount)
            if self.IsFinishedTourney then
                self.StageAndRoundText = TourneyDefine.FinishedText
            end
            self.TipText = self.GetAwardDeadLineText
        else
            self.StageInfoScoreText = ""
            self.StageAndRoundText = ""
            self.TipText = ""
        end
    elseif not self.IsSignUp then
        --未报名，则显示报名截止时间
        local EndTimeText = TimeUtil.GetTimeFormat("%Y/%m/%d", self.EndTime)
        local LocalEndTimeText = LocalizationUtil.GetTimeForFixedFormat(EndTimeText, false) --时间本地化
        self.StageInfoScoreText = string.format(TourneyDefine.SignUpEndTimeText, LocalEndTimeText)
        self.StageInfoVisible = false
        self.ExitVisible = true
        self.TipText = TourneyDefine.SignUpTipText
        self.TourneyFullName = TourneyDefine.Title
    else
        --已报名，则显示积分
        self.StageInfoScoreText = string.format(TourneyDefine.StageInfoScoreText, self.Score)
        --阶段
        if self.CurBattleCount and self.MaxBattleCount then
            if self.CurEffectInfo then
                self.StageAndRoundText = string.format(TourneyDefine.StageAndRoundText, self.CurStageName, self.CurBattleCount, self.MaxBattleCount)
            else
                self.StageAndRoundText = string.format(TourneyDefine.RoundText, self.CurBattleCount, self.MaxBattleCount)
            end
            
            if self.IsFinishedTourney then
                self.StageAndRoundText = TourneyDefine.FinishedText
            end
        end
        
        --规则
        self.RuleTextVisible = true
        local RuleInfo = TourneyVMUtils.GetRuleInfo(self.TourneyInfo.Rule)
        if RuleInfo then
            self.RuleText = string.format(TourneyDefine.RuleText, RuleInfo.RuleName)
        end
        --在对局室外，提示进入对局室
        if not self.IsEnterMatchRoom and not self.IsFinishedTourney then
            self.TipText = TourneyDefine.EnterRoomTipText
        end

        if self.IsFinishedTourney then
            self.TipText = self.GetAwardDeadLineText
            self.RuleTextVisible = false
            self.ExitVisible = true
        end
    end
end

---@type 更新下次大赛信息
function MagicCardTourneyVM:UpdateNextTourneyInfo()
    local NextData = 
    {
        TourneyID = self.NextTourneyID,
        StartTime = self.NextStartTime,
        CanSingUp = false,
    }
    if self.TourneySignUpVM then
        self.TourneySignUpVM:UpdateSignUpInfo(NextData)
    end
end

-- 是否处于报名期间
function MagicCardTourneyVM:GetIsInSingUpTime(StartTime)
    if StartTime == nil then
        return false
    end
    
    local Now = TimeUtil.GetServerTime()
    local EndTime = StartTime + TourneyDefine.Duration
    return Now >= StartTime and Now <= EndTime
end

---@type 获取当前阶段效果状态文本
function MagicCardTourneyVM:GetCurStageEffectStatusText()
    if self.CurEffectInfo == nil then
        return ""
    end

    local EffectStatus = self.CurEffectInfo.Status
    if EffectStatus == nil then
        return ""
    end

    local StateText = TourneyDefine.EffectStatusText[EffectStatus]
    return StateText
end

---@type 获取当前阶段效果进度文本
function MagicCardTourneyVM:GetCurStageEffectProgressText()
    if self.CurEffectInfo == nil then
        return ""
    end

    if not string.isnilorempty(self.CurEffectName) then
        if TourneyVMUtils.IsNeedShowEfectProgress(self.CurEffectInfo.EffectID) then
            local ProgressText = string.format("(%d/%d)", self.EffectProgress, self.EffectArg)
            return self.CurEffectName..ProgressText
        else
            return string.format("%s(%s)", self.CurEffectName, TourneyDefine.EffectOngoingText)
        end
    end

    return ""
end

---@type 获取当前阶段效果状态
function MagicCardTourneyVM:GetCurStageEffectStatus()
    if self.CurEffectInfo == nil then
        return 0
    end

    return self.CurEffectInfo.Status
end

---@type 当前阶段效果是否结束
function MagicCardTourneyVM:IsCurStageEffectFinished()
    return self.IsCurEffectFinished
end

function MagicCardTourneyVM:UpdateEffectStatus()
    if self.CurEffectInfo == nil then
        return
    end

    local EffectStatus = self.CurEffectInfo.Status
    if EffectStatus == nil  then
        return
    end
    self.IsCurEffectFinished = EffectStatus ~= ProtoCS.EFFECT_STATUS.EFFECT_STATUS_IN_PROGRESS
end

-- 是否需要阶段结算
function MagicCardTourneyVM:IsNeedStageSettlement()
    if self.CurBattleCount == nil or self.CurBattleCount <= 0 then
        return false
    end
    local ModValue = math.fmod(self.CurBattleCount, 5)
    return ModValue == 0
end

function MagicCardTourneyVM:UpdateRankInfo(RankInfo)
    if RankInfo == nil then
        return
    end
 
    --排名
    self.PlayerRank = RankInfo.PlayerRank
    self.PlayerName = MajorUtil.GetMajorName()
    
    local RankList = RankInfo.TopRank
    local NewRankList = {}
    for Index = 1, #RankList do
        local Rank = RankList[Index]
        local NewRank = 
        {
            Rank = Index,
            Score = Rank.Score,
            RoleID = Rank.RoleID,
        }
        table.insert(NewRankList, NewRank)
    end
    self:UpdateScoreText()
    if self.TourneyRankList then
        self.TourneyRankList:UpdateByValues(NewRankList, nil)
    end
end

---@type 获取当前阶段效果ID
function MagicCardTourneyVM:GetCurStageEffectID()
    if self.CurEffectInfo == nil then
        return nil
    end
    
    return self.CurEffectInfo.EffectID
end

function MagicCardTourneyVM:UpdateEffectChoiceInfo(EffectList)
    self.EffectChoiceList = {}
    
    if EffectList == nil or next(EffectList) == nil then
        return
    end

    for Index, EffectData in ipairs(EffectList) do
        --与选择阶段数据结构保持一致
        local Effect = {}
        Effect.EffectInfo = {}
        Effect.EffectInfo.EffectIndex = Index - 1 --后台从0开始
        Effect.EffectInfo.EffectID = EffectData.EffectID
        Effect.EffectInfo.Reroll = EffectData.Reroll
        table.insert(self.EffectChoiceList, Effect)
    end
    if self.EffectChoiceVMList then
        self.EffectChoiceVMList:UpdateByValues(self.EffectChoiceList, nil)
    end
end

---@type 重随效果ID
function MagicCardTourneyVM:UpdateRerollEffectID(EffectIndex, NewEffectID)
    if self.EffectChoiceList == nil then
        return
    end

    local ExistEffect = self.EffectChoiceList[EffectIndex + 1]
    if ExistEffect == nil then
        return
    end

    ExistEffect.EffectInfo.EffectID = NewEffectID
    ExistEffect.EffectInfo.Reroll = math.abs(ExistEffect.EffectInfo.Reroll - 1)
    local UpdateEffectVM = self.EffectChoiceVMList and self.EffectChoiceVMList:Get(EffectIndex + 1)
    if UpdateEffectVM then
        UpdateEffectVM:UpdateByValue(ExistEffect, nil, false)
    end
end

function MagicCardTourneyVM:UpdateSelectEffectList(EffectList)
    self:InitSelectedEffectList()

    for index, Effect in ipairs(EffectList) do
        local NewEffect = 
        {
            CurStage = self.CurStageIndex,
            EffectID = Effect.EffectID,
            Progress = Effect.Progress,
            ScoreChange = Effect.ScoreChange,
            IsEffectEnd = self:IsCurStageEffectFinished()
        }

        if self.SelectedEffectList then
            local SelectedEffect = self.SelectedEffectList[index]
            if SelectedEffect then
                SelectedEffect.EffectInfo = NewEffect
            end
        end
    end

    if self.SelectedEffectVMList then
        self.SelectedEffectVMList:UpdateByValues(self.SelectedEffectList, nil)
    end
end

---@type 更新报名数据
function MagicCardTourneyVM:UpdateSignUpVM()
    local SignUpData = 
    {
        TourneyID = self.TourneyID,
        StartTime = self.StartTime,
        CanSingUp = self.IsActive,
    }
    if self.TourneySignUpVM then
        self.TourneySignUpVM:UpdateSignUpInfo(SignUpData)
    end
end

---@type 更新匹配栏信息
function MagicCardTourneyVM:UpdateStageInfoVM()
    if self.TourneyInfo == nil then
        return
    end

    if self.StageInfoVM == nil then
        return
    end

    self.StageInfoVM:OnTourneyInfoChanged(self.TourneyInfo)
end

---@type 更新匹配成功界面信息
---@param Delay number 自动取消时间
function MagicCardTourneyVM:UpdateMatchingResultInfo(CancelDelay)
    local CancelDelayInt = math.floor(CancelDelay)
    self.AutoCancelCDTip = string.format(TourneyDefine.AutoCancelMatchTipText, CancelDelayInt)
    local AutoCancelTourneyDelay = TourneyVMUtils.GetCardMatchConfirmTime()
    self.AutoCancelCDPercent = 1 - CancelDelay / AutoCancelTourneyDelay --进度条从0-1，交互要求
end

function MagicCardTourneyVM:OnMatchConfirm()
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    local MemberList = {
        {RoleID = MajorRoleID, HasReady = false},
        {RoleID = 0, HasReady = false},
    }
    if self.MatchMemberVMs then
        self.MatchMemberVMs:UpdateByValues(MemberList, nil, true)
    end

    local RoomInfo = TourneyVMUtils.GetMatchRoomInfo()
    self.SceneBG = RoomInfo.SceneBG
    self.SneceIcon = RoomInfo.SneceIcon
    self.SceneName = TourneyDefine.Title --这里不是副本，所以取幻卡大赛标题
    self.SceneLevelDesc = RoomInfo.SceneLevelDesc
    self.IsMajorReady = false
    self.Model = -1
    self.IsMem4 = true
end

function MagicCardTourneyVM:SetReadyForOpponent()
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    local MemberList = {
        {RoleID = MajorRoleID, HasReady = self.IsMajorReady},
        {RoleID = 0, HasReady = true},
    }
    if self.MatchMemberVMs then
        self.MatchMemberVMs:UpdateByValues(MemberList, nil, true)
    end
end

function MagicCardTourneyVM:SetReady(IsReady)
    local RoleID = MajorUtil.GetMajorRoleID()
    local Mem = self:FindMem(RoleID)
    if not Mem then
        return
    end

    Mem:SetReady(IsReady)
    local MajorID = MajorUtil.GetMajorRoleID()
    if RoleID == MajorID then
        self.IsMajorReady = IsReady
    end
end

function MagicCardTourneyVM:FindMem(RoleID)
    local Mem = self.MatchMemberVMs:Find(function(Item)
        return Item.RoleID == RoleID
    end)

    return Mem
end

---@type 获取大赛ID
function MagicCardTourneyVM:GetTourneyID()
    return self.TourneyID
end

---@type 获取玩家积分
function MagicCardTourneyVM:GetPlayerScore()
    return self.Score
end

---@type 获取玩家排名
function MagicCardTourneyVM:GetPlayerRank()
    return self.PlayerRank
end

---@type 获取奖杯名
function MagicCardTourneyVM:GetTourneyName()
    return self.TourneyCupName
end

---@type 获取下一次大赛时间
function MagicCardTourneyVM:GetNextTourneyTime()
    return self.NextStartTime
end

---@type 获取大赛结束时间
function MagicCardTourneyVM:GetTourneyEndTime()
    return self.EndTime
end

---@type 获取剩余可领奖时间
function MagicCardTourneyVM:GetRemainTimeForReward()
    local CurTime = _G.TimeUtil.GetServerLogicTime()
    local EndTime = self:GetTourneyEndTime()
    local NextTourneyTime = self:GetNextTourneyTime()
    local Secs = 0
    if CurTime < EndTime then
        Secs = EndTime - CurTime
    else
        Secs = NextTourneyTime - CurTime
    end
    return Secs
end

---@type 获取大赛信息 对外接口
function MagicCardTourneyVM:GetTourneySimpleInfo()
    local Info = {
        EndTime = self.EndTime,
        BattleCount = self.CurBattleCount,
        MaxBattleCount = self.MaxBattleCount,
        Score = self.PlayerScore,
    }
    return Info
end

---@type 当进入对局室
function MagicCardTourneyVM:OnEnterMatchRoom()
    self.IsEnterMatchRoom = true
    self:UpdateStageInfoVM()
    if self.StageInfoVM then
        self.StageInfoVM:OnEnterMatchRoom()
    end
end

---@type 当离开对局室
function MagicCardTourneyVM:OnExitMatchRoom()
    self.IsEnterMatchRoom = false
    if self.StageInfoVM then
        self.StageInfoVM:OnExitMatchRoom()
    end
end

---@type 是否为当前阶段选择了效果
function MagicCardTourneyVM:IsSelectedStageEffect()
    if self.EffectChoiceList == nil then
        return true
    end

    return #self.EffectChoiceList <= 0
end

---@type 是否完赛
function MagicCardTourneyVM:GetIsFinishedTourney()
    return self.IsFinishedTourney
end

return MagicCardTourneyVM