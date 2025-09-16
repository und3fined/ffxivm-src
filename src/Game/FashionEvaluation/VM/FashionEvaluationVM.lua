--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:时尚品鉴VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local FashionProgressAwardItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionProgressAwardItemVM")
local FashionAwardItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionAwardItemVM")
local FashionEquipItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionEquipItemVM")
local FashionCommentItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionCommentItemVM")
local FashionNPCIndexItevVM = require("Game/FashionEvaluation/VM/ItemVM/FashionNPCIndexItevVM")
local FashionChallengeEquipItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionChallengeEquipItemVM")
local FashionEvaluationTrackVM = require("Game/FashionEvaluation/VM/FashionEvaluationTrackVM")
local FashionEvaluationFittingVM = require("Game/FashionEvaluation/VM/FashionEvaluationFittingVM")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local FashionThemePartItemVM = require("Game/FashionEvaluation/VM/ItemVM/FashionThemePartItemVM")

local LSTR = _G.LSTR
local RecommendTag = FashionEvaluationDefine.RecommendTag
local TimeUtil = _G.TimeUtil

---@class FashionEvaluationVM : UIViewModel
---@field ThemeName string @主题名
---@field ThemeID number @主题ID
---@field IsCelebration boolean @是否为时尚庆典
---@field WeekHighestScore number @本周最高得分
---@field ProgressAwardList table @评分进度奖励表
---@field SettlementProgressAwardList table @结算界面评分进度奖励表
---@field EvaluationHistoryList table @挑战记录表
---@field WeekRemainTimes number @本周剩余次数
---@field WeekMaxEvaluateTimes number @周最大挑战次数
---@field CurScore number @当前最新得分
---@field Coins number @当前最新奖励金碟币
---@field GetProgressNum number @奖励目标达成数量
---
local FashionEvaluationVM = LuaClass(UIViewModel)

function FashionEvaluationVM:Ctor()
    self.TrackVM = FashionEvaluationTrackVM.New(self) --追踪目标界面VM
    self.FittingVM = FashionEvaluationFittingVM.New(self) --试衣界面VM
    self.ProgressAwardList = {}
    self.SettlementProgressAwardList = {}
    self.ProgressAwardVMList = UIBindableList.New(FashionProgressAwardItemVM)
    self.SettlementProgressAwardVMList = UIBindableList.New(FashionProgressAwardItemVM)
    self.IsRemainTimesNotEnough = false
    self.IsCelebration = false
    self.WeekHighestScore = 0
    self.GetProgressNum = 0
    self.ThemeID = 0
    self.ThemeName = ""
    self.WeekRemainTimes = 0
    self.RemainTimesText = ""
    self.WeekHighestScoreText = FashionEvaluationDefine.WithoutScoreText
    self.WeekMaxEvaluateTimes = 0
    self.TextTimes = ""
    self.PartThemeList = {}
    self.PartThemeVMList = UIBindableList.New(FashionThemePartItemVM)
    ---NPC外观
    self.NPCInfoList = {}
    self.CurSelectedNPCAppList = {}
    self.CurSelectNPCAppVMList = UIBindableList.New(FashionChallengeEquipItemVM)
    self.NPCIndexList = {}
    self.NPCIndexVMList = UIBindableList.New(FashionNPCIndexItevVM)
    self.CurSelectedNPCScore = 0
    self.CurSelectedNPCScoreBG = ""
    self.SelectedNPCInfo = {}
    ---评分过程
    self.CurScore = 0
    self.CommentList = {}
    self.CommentVMList = UIBindableList.New(FashionCommentItemVM)
    ---结算界面
    self.Coins = 0
    self.IsGetReward = false
    self.StartSettlement = false
    self.EndSettlement = false
    self.IsOwnAll = false
    self.AwardEffectIndex = 0
    self.SettlementTipText = ""
    self.NewAwardGet = {}
    self.CurResultRewardVMList = UIBindableList.New(FashionAwardItemVM)
    self.CurChallengeEquipList = {}
    self.CurChallengeEquipVMList = UIBindableList.New(FashionChallengeEquipItemVM)
    self.MatchNumText = ""
    self.MatchScore = 0
    self.MatchScoreText = ""
    self.SuperMatchNumText = ""
    self.SuperMatchScore = 0
    self.SuperMatchScoreText = ""
    self.IsShowSuperMatchInfo = false
    self.BaseScore = 0
    self.BaseScoreText = ""
    self.OwnNumText = ""
    self.OwnScore = 0
    self.OwnScoreText = 0
    self.MatchNum = 0
    self.SuperMatchNum = 0
    self.OwnNum = 0
    self:InitViewsVisible()
end

function FashionEvaluationVM:OnInit()
    self.TrackVM:OnInit()
    self:InitViewsVisible()
    self.WeekMaxEvaluateTimes = FashionEvaluationVMUtils.GetWeekMaxEvaluateTimes()
    self.WeekRemainTimes = self.WeekMaxEvaluateTimes
end

function FashionEvaluationVM:OnBegin()
end

function FashionEvaluationVM:OnEnd()

end

function FashionEvaluationVM:OnShutdown()

end

function FashionEvaluationVM:InitViewsVisible()
    self.MainViewVisible = false
    self.FittingViewVisible = false
    self.RecordViewVisible = false
    self.ProgressViewVisible = false
    self.NPCEquipViewVisible = false
    self.SettlementViewVisible = false
end

function FashionEvaluationVM:GetTrackVM()
    return self.TrackVM
end

function FashionEvaluationVM:GetFittingVM()
    return self.FittingVM
end

---@type 更新时尚品鉴信息
function FashionEvaluationVM:UpdateFashionEvaluationInfo(Info)
    if Info == nil then
        return
    end

    self.ThemeID = Info.ThemeID
    self.ThemeName = FashionEvaluationVMUtils.GetThemeName(self.ThemeID)
    self.PartThemeList = FashionEvaluationVMUtils.GetPartThemeList(self.ThemeID, FashionEvaluationDefine.EFashionView.Main)
    if self.PartThemeVMList then
        self.PartThemeVMList:UpdateByValues(self.PartThemeList, nil)
    end
    self.IsCelebration = FashionEvaluationVMUtils.IsFashionCelebration(self.ThemeID)
    self.WeekRemainTimes = Info.RemainEvaluateTimes
    self.RemainTimesText = string.format(FashionEvaluationDefine.RemainTimesText, self.WeekRemainTimes, self.WeekMaxEvaluateTimes)
    self.IsRemainTimesNotEnough = self.WeekRemainTimes == nil or self.WeekRemainTimes <= 0
    if self.IsRemainTimesNotEnough then
        self.WeekRemainTimesColor = FashionEvaluationDefine.TextColor.RemainTimesNotEnoughColor
    else
        self.WeekRemainTimesColor = FashionEvaluationDefine.TextColor.DefaultTextColor
    end
    
    self.BestResult = Info.BestEvaluationResult
    if self.BestResult then
        self.WeekHighestScore = self.BestResult.TotalScore
        self.WeekHighestScoreText = string.format(FashionEvaluationDefine.WeekHighestScoreText, self.WeekHighestScore)
        self.GetProgressNum = FashionEvaluationVMUtils.GetProgressNum(self.WeekHighestScore, self.WeekRemainTimes)
    end

    if self.WeekHighestScore == 0 and self.WeekRemainTimes >= self.WeekMaxEvaluateTimes then
        self.WeekHighestScoreText = FashionEvaluationDefine.WithoutScoreText
    end


    self:UpdateProgressAwardList(self.BestResult)
    self:UpdateFittingInfo(Info)
    self:UpdateNPCEquipInfoList(Info.NPCList)
end

---@type 更新评分进度列表
function FashionEvaluationVM:UpdateProgressAwardList(BestResult)
    if BestResult == nil then
        return
    end

    self.ProgressAwardList = {}
    -- 根据当前最高分数更新进度
    self.ProgressAwardList = FashionEvaluationVMUtils.GetAwardList(self.WeekHighestScore, self.WeekRemainTimes)
    self.ProgressAwardVMList:UpdateByValues(self.ProgressAwardList, nil)
end

---更新弹幕信息
function FashionEvaluationVM:AddComment()
    local CommentInfo = self:GetRandomComment()
    if CommentInfo == nil or next(CommentInfo) == nil then
        return
    end
    self.CommentVMList:AddByValue(CommentInfo)
    --限制弹幕数量
    local Length = self.CommentVMList:Length()
    if Length > FashionEvaluationDefine.MaxCommentNum then
        self.CommentVMList:RemoveAt(1)
    end
end

---@type 获取随机部位弹幕
function FashionEvaluationVM:GetRandomComment()
    local PartThemeList = self.CurChallengeEquipList
    if PartThemeList == nil or #PartThemeList <= 0 then
        return
    end

    local CommentInfo = {}
    local RandomPartIndex = math.random(#PartThemeList)
    local PartTheme = PartThemeList[RandomPartIndex]
    if PartTheme == nil then
        return
    end

    local PartName = FashionEvaluationVMUtils.GetPartName(PartTheme.Part)
    local AppearanceID = PartTheme.AppearanceID
    local AppInfo = FashionEvaluationVMUtils.GetAppearanceInfo(AppearanceID)
    local NPCIndex, Comment = FashionEvaluationVMUtils.GetComment(PartTheme.IsMatchTheme)
    if NPCIndex and not string.isnilorempty(Comment) then
        local CommentNPC = self.NPCInfoList[NPCIndex]
        if CommentNPC and AppInfo then
            local NpcList = FashionEvaluationVMUtils.GetNPCInfos()
            if NpcList and #NpcList > 0 then
                local Npc = NpcList[NPCIndex]
                CommentInfo.NPCResID = Npc and Npc.NPCID
            end
            if not string.isnilorempty(PartName) and not string.isnilorempty(Comment) then
                CommentInfo.Comment = string.format(Comment, PartName, "")
            end
        end
    end

    return CommentInfo
end

---清除弹幕信息
function FashionEvaluationVM:ClearCommentList()
    
    self.CommentVMList:Clear()
end

function FashionEvaluationVM:OnSelectedNPC(Params)
    if Params == nil then
        return
    end
    
    self.CurSelectNPCIndex = Params.NPCIndex
    self:OnNPCIndexChanged()
end

function FashionEvaluationVM:ClearSelectedNPC()
    self.CurSelectNPCIndex = 0
end

function FashionEvaluationVM:UpNPCEquips()
    if self.NPCInfoList == nil then
        return
    end
    self.CurSelectNPCIndex = self.CurSelectNPCIndex - 1
    if self.CurSelectNPCIndex <= 0 then
        self.CurSelectNPCIndex = #self.NPCInfoList
    end
    self:OnNPCIndexChanged()
    return self.CurSelectNPCIndex
end

function FashionEvaluationVM:NextNPCEquips()
    if self.NPCInfoList == nil then
        return
    end
    self.CurSelectNPCIndex = self.CurSelectNPCIndex + 1
    if self.CurSelectNPCIndex > #self.NPCInfoList then
        self.CurSelectNPCIndex = 1
    end
    self:OnNPCIndexChanged()
    return self.CurSelectNPCIndex
end

---@type NPC改变
function FashionEvaluationVM:OnNPCIndexChanged()
    if self.CurSelectNPCIndex == nil then
        return
    end

    if self.NPCInfoList == nil then
        return
    end

    local CurSelectNPCInfo = self.NPCInfoList[self.CurSelectNPCIndex]
    if CurSelectNPCInfo == nil then
        return
    end

    --分数和背景
    self.CurSelectedNPCScore = CurSelectNPCInfo.TotalScore
    self.CurSelectedNPCScoreBG = FashionEvaluationVMUtils.GetNPCcoreBG(self.CurSelectedNPCScore)

    local SelectedAppList = CurSelectNPCInfo.AppInfoList
    if SelectedAppList == nil then
        return
    end

    -- 更新追踪状态
    for _, Appearance in ipairs(SelectedAppList) do
        Appearance.IsTracked = self:IsTracked(Appearance.AppearanceID)
    end

    self.CurSelectedNPCAppList = SelectedAppList
    table.sort(self.CurSelectedNPCAppList, FashionEvaluationDefine.PartSortFun)
    self.CurSelectNPCAppVMList:UpdateByValues(self.CurSelectedNPCAppList, nil, false)
end

---@type 更新NPC外观信息
function FashionEvaluationVM:UpdateNPCEquipInfoList(EquipInfoList)
    if EquipInfoList == nil or #EquipInfoList <= 0 then
        return
    end

    self.NPCIndexList = {}
    self.NPCInfoList = {}
    for Index, EquipInfo in ipairs(EquipInfoList) do
        local NewEquipInfo = {
            TotalScore = EquipInfo.TotalScore,
            AppInfoList = {}
        }
        local NewAppMap = EquipInfo.EquipMap
        for Part, Appearance in pairs(NewAppMap) do
            local NewAppearance = {
                Key = FashionEvaluationVMUtils.GetAppearanceKey(FashionEvaluationDefine.EFashionView.NPCEquip,
                Index, Part, Appearance.AppearanceID),
                Part = Part,
                PartThemeID = self.FittingVM:GetPartThemeID(Part),
                AppearanceID = Appearance.AppearanceID,
                IsTracked = self:IsTracked(Appearance.AppearanceID)
            }
            table.insert(NewEquipInfo.AppInfoList, NewAppearance)
        end
        self.NPCIndexList[Index] = Index
        table.insert(self.NPCInfoList, NewEquipInfo)
    end

    self.NPCIndexVMList:UpdateByValues(self.NPCIndexList, nil)
end

function FashionEvaluationVM:UpdateFittingInfo(Info)
    self.FittingVM:UpdateThemeInfo(Info)
end

---@type 结算信息
function FashionEvaluationVM:UpdateSettlementInfo(Result)
    local ResultInfo = Result.CheckResult
    if ResultInfo == nil then
        return
    end

    --本次挑战金碟币奖励
    if Result.Coins then
        self.Coins = Result.Coins
        self.IsGetReward = self.Coins and self.Coins > 0
        local RewardInfo = {}
        if self.IsGetReward then
            local AwardID = FashionEvaluationVMUtils.GetAwardID()
            table.insert(RewardInfo, {Coins = self.Coins, AwardID = AwardID})
        end
        self.CurResultRewardVMList:UpdateByValues(RewardInfo, nil)
    end
    
    self.WeekRemainTimes = Result.RemainEvaluateTimes
    self.BestResult = Result.BestEvaluationResult
    --挑战外观列表
    local OwnNum = 0
    local MatchNum = 0
    local SuperMatchNum = 0
    self.BaseScore = 0
    self.MatchScore = 0
    self.OwnScore = 0
    self.SuperMatchScore = 0
    self.CurScore = ResultInfo.TotalScore or 0
    local CheckResultMap = ResultInfo.EquipCheckResultMap
    self.CurChallengeEquipList = {}
    local PartThemeList = FashionEvaluationVMUtils.GetPartThemeList(self.ThemeID)
    if CheckResultMap and PartThemeList then
        for _, PartTheme in ipairs(PartThemeList) do
            local Part = PartTheme.Part
            local CheckResul = CheckResultMap[Part]
            local Equip = {}
            Equip.Part = Part
            Equip.PartThemeID = self.FittingVM:GetPartThemeID(Part)
            Equip.ViewType = FashionEvaluationDefine.EFashionView.Settlement
            if CheckResul then
                Equip.AppearanceID = CheckResul.Equip and CheckResul.Equip.AppearanceID or 0
                Equip.BaseScore = CheckResul.Score
                Equip.OwnScore = CheckResul.OwnScore
                Equip.MatchThemeScore = CheckResul.MatchThemeScore
                Equip.Special = CheckResul.Special
                Equip.IsMatchTheme = CheckResul.MatchThemeScore and CheckResul.MatchThemeScore > 0
                Equip.IsOwn = CheckResul.OwnScore and CheckResul.OwnScore > 0
                Equip.IsTracked = self:IsTracked(Equip.AppearanceID)
                Equip.IsSuperMatch = CheckResul.Special and CheckResul.Special > 0
            else
                Equip.AppearanceID = 0
                Equip.IsMatchTheme = false
                Equip.IsOwn = false
                Equip.IsTracked = false
                Equip.IsSuperMatch = false
                Equip.AppearanceID = 0
                Equip.BaseScore = 0
                Equip.OwnScore = 0
                Equip.MatchThemeScore = 0
                Equip.Special = 0
            end
            Equip.Key = FashionEvaluationVMUtils.GetAppearanceKey(Equip.ViewType,
            nil, Part, Equip.AppearanceID),
            table.insert(self.CurChallengeEquipList, Equip)

            self.BaseScore = self.BaseScore + Equip.BaseScore
            if Equip.IsOwn then
                OwnNum = OwnNum + 1
                self.OwnScore = self.OwnScore + Equip.OwnScore
            end
            
            if Equip.IsSuperMatch then
                SuperMatchNum = SuperMatchNum + 1
                self.SuperMatchScore = self.SuperMatchScore + Equip.Special
            elseif Equip.IsMatchTheme then
                MatchNum = MatchNum + 1
                self.MatchScore = self.MatchScore + Equip.MatchThemeScore
            end
        end

        self.OwnNum = OwnNum
        self.MatchNum = MatchNum
        self.SuperMatchNum = SuperMatchNum
        self.MatchScoreText = string.format("+%s", self.MatchScore)
        self.OwnScoreText = string.format("+%s", self.OwnScore)
        self.SuperMatchScoreText = string.format("+%s", self.SuperMatchScore)
        if CheckResultMap then
            self.BaseScoreText = string.format("+%s", self.BaseScore)
        end

        self.OwnNumText = LSTR(FashionEvaluationDefine.OwnScoreUKey)
        self.MatchNumText = LSTR(FashionEvaluationDefine.MatchScoreUKey)
        self.SuperMatchNumText = LSTR(FashionEvaluationDefine.SuperMatchScoreUKey)
        self.IsShowSuperMatchInfo = SuperMatchNum > 0
    end
    self.CurChallengeEquipVMList:UpdateByValues(self.CurChallengeEquipList, FashionEvaluationDefine.PartSortFun)

    --挑战进度
    self.IsOwnAll = self:GetIsOwnedAllChallengeEquip(CheckResultMap)
    self:UpdateLastEvaluateResult(ResultInfo)
    if self:IsGetMaxAward(self.BestResult) then
        self.SettlementTipText = FashionEvaluationDefine.SettlementTipTextFinish
    elseif self.CurScore >= FashionEvaluationDefine.TrackTipScore and not self.IsOwnAll then
        self.SettlementTipText = FashionEvaluationDefine.SettlementTipTextRetry
    elseif not self.IsGetReward then
        self.SettlementTipText = FashionEvaluationDefine.SettlementTipTextFaile
    end
end

---@type 获取各得分情况
function FashionEvaluationVM:GetScoreInfo()
   local ScoreInfo = {
        BaseScore = self.BaseScore,
        MatchScore = self.MatchScore,
        SuperMatchScore = self.SuperMatchScore,
        OwnScore = self.OwnScore,
        MatchNum = self.MatchNum,
        SuperMatchNum = self.SuperMatchNum,
        OwnNum = self.OwnNum,
   }
   return ScoreInfo
end

---@type 挑战外观是否全部拥有
function FashionEvaluationVM:GetIsOwnedAllChallengeEquip(ResultEquips)
    local OwnedAppearNum = 0
    for _, CheckResul in pairs(ResultEquips) do
        if CheckResul.IsOwn then
            OwnedAppearNum = OwnedAppearNum + 1
        end
    end
    return OwnedAppearNum >= 4
end

---@type 最新挑战结果
function FashionEvaluationVM:UpdateLastEvaluateResult(Result)
    if Result == nil then
        return
    end
    self.SettlementProgressAwardList = {}
    local ResultScore = Result.TotalScore
    self.EndSettlement = false
    if not self:IsImprove(ResultScore, self.WeekRemainTimes) then
        self.SettlementProgressAwardVMList:UpdateByValues(self.ProgressAwardList, nil)
        self.EndSettlement = true
        return
    end
    --self.BestResult = Result
    self.WeekHighestScore = ResultScore
    self.NewGetNum = 0

    self.SettlementProgressAwardList = FashionEvaluationVMUtils.GetAwardList(self.WeekHighestScore, self.WeekRemainTimes)
    for index, Award in pairs(self.SettlementProgressAwardList) do
        local ExistProgressAward = self.ProgressAwardList[index]
        local IsGetProgressPrev = ExistProgressAward and ExistProgressAward.IsGetProgress
        Award.IsNewGet = not IsGetProgressPrev and Award.IsGetProgress
    end
    self.SettlementProgressAwardVMList:UpdateByValues(self.SettlementProgressAwardList, nil)
    self.RegisterNewGetNum = 0
    self.NewGetList = {}
end


---@type 奖励目标达成数量有提升
function FashionEvaluationVM:IsImprove(Score, WeekRemainTimes)
    local CurGetProgressNum = FashionEvaluationVMUtils.GetProgressNum(Score, WeekRemainTimes)
    return CurGetProgressNum > self.GetProgressNum
end

---@type 获取目标达成数量
function FashionEvaluationVM:GetHaveGetProgressNum()
    return self.GetProgressNum
end

---@type 注册解锁奖励动效
function FashionEvaluationVM:RegisterProgressAward(ItemData, ItemView)
    if self.NewGetList == nil then
        self.NewGetList = {}
    end

    local NewGetInfo = {
        ItemData = ItemData,
        ItemView = ItemView,
    }
    table.insert(self.NewGetList, NewGetInfo)

    self.RegisterNewGetNum = self.RegisterNewGetNum + 1
    if self.RegisterNewGetNum >= self.NewGetNum then
        table.sort(self.NewGetList, function(a, b) 
           return  a.ItemData.UnLockAwardIndex < b.ItemData.UnLockAwardIndex
        end)
        local FirstNewGet = self.NewGetList[1]
        if FirstNewGet then
            local ItemView = FirstNewGet.ItemView
            if ItemView then
                ItemView:PlayEffectAnim()
                table.remove(self.NewGetList, 1)
            end
        end
    end
end

---@type 解锁奖励动效播完
function FashionEvaluationVM:OnPlayNewGetEffectFinished()
    if self.NewGetList == nil or #self.NewGetList <= 0 then
        self.EndSettlement = true
        return
    end
    local NextItemView = self.NewGetList[1].ItemView
    if NextItemView then
        NextItemView:PlayEffectAnim()
        table.remove(self.NewGetList, 1)
    end
end

---@type 挑战外观列表是否还有未拥有的外观
function FashionEvaluationVM:IsNotHaveAllInChallengeEquipList()
    if self.CurChallengeEquipList == nil then
        return true
    end

    for _, Equip in ipairs(self.CurChallengeEquipList) do
        if Equip.IsOwn == false then
            return true
        end
    end
    return false
end

---@type 外观是否追踪
---@param AppearanceID 外观ID
function FashionEvaluationVM:IsTracked(AppearanceID)
    return self.TrackVM and self.TrackVM:IsTracked(AppearanceID)
end

---@type 追踪目标更新
function FashionEvaluationVM:OnEquipTrackUpdate(AppearanceID, IsTrack)
    if AppearanceID == nil then
        return
    end

    local ActualIsTrack = IsTrack
    --更新本地数据
    if IsTrack then
        ActualIsTrack = self.TrackVM:AddEquipToTrackList(AppearanceID)
    else
        self.TrackVM:RemoveEquipFromTrackList(AppearanceID)
    end

    self.FittingVM:OnAppearanceTrackChanged(AppearanceID, ActualIsTrack)
end

---@type 当前挑战外观是否符合主题
function FashionEvaluationVM:IsMatchTheme(AppearanceID)
    if AppearanceID == nil then
        return false
    end

    if self.CurChallengeEquipList == nil then
        return false
    end
  
    for _, Equip in ipairs(self.CurChallengeEquipList) do
        if Equip.AppearanceID == AppearanceID then
            return Equip.IsMatchTheme
        end
    end

    return false
end

-- function FashionEvaluationVM:OnShowNPCEquipView(IsVisible, Params)
--     if IsVisible and Params then
--         self.SelectedNPCInfo = Params
--         self:OnSelectedNPC(Params)
--     end
--     self:SetNPCEquipViewVisible(IsVisible)
-- end

function FashionEvaluationVM:SetMainViewVisible(IsVisible)
    self.MainViewVisible = IsVisible
end

function FashionEvaluationVM:SetFittingViewVisible(IsVisible, IsMutualWithMainView)
    self.FittingViewVisible = IsVisible
    if IsMutualWithMainView then
        self.MainViewVisible = not IsVisible
    end
end

function FashionEvaluationVM:SetRecordViewVisible(IsVisible)
    self.RecordViewVisible = IsVisible
    self.FittingViewVisible = not IsVisible
end

function FashionEvaluationVM:SetProgressViewVisible(IsVisible)
    self.ProgressViewVisible = IsVisible
    self.MainViewVisible = not IsVisible
end

function FashionEvaluationVM:SetNPCEquipViewVisible(IsVisible)
    self.NPCEquipViewVisible = IsVisible
    self.MainViewVisible = not IsVisible
end

function FashionEvaluationVM:SetSettlementViewVisible(IsVisible)
    self.SettlementViewVisible = IsVisible
    self.MainViewVisible = not IsVisible
    if IsVisible then
        self.ProgressViewVisible = false
    end
end

---@type 第一次进入时尚品鉴场景
function FashionEvaluationVM:OnFirstTimesEnterMainView(IsFirstTimes)
    if self.FittingVM == nil then
        return
    end
    self.FittingVM.IsFirstTimesEnter = IsFirstTimes
end

function FashionEvaluationVM:GetReaminTimes()
    return self.WeekRemainTimes
end

---@type 是否达成最大奖励
function FashionEvaluationVM:IsGetMaxAward(BestResult)
    if BestResult == nil then
        return false
    end

    local BestScore = BestResult.TotalScore
    return FashionEvaluationVMUtils.IsGetProgress(4, BestScore, self.WeekRemainTimes)
end

function FashionEvaluationVM:GetFashionEvaluationSingleInfo()
    local Info = {
        WeekRemainTimes = self.WeekRemainTimes,
        MaxWeekRemainTimes = self.WeekMaxEvaluateTimes,
    }
    return Info
end

function FashionEvaluationVM:GetThemeName()
    return self.ThemeName
end

return FashionEvaluationVM