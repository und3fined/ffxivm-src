--
-- Author: MichaelYang_LightPaw
-- Date: 2022-09-19 14:50
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
local CardsGroupCardVM = require("Game/Cards/VM/CardsGroupCardVM")
local AudioUtil = require("Utils/AudioUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local CardReadnessRewardItemVM = require("Game/Cards/VM/CardReadnessRewardItemVM")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local CardsRuleDetailVM = require("Game/Cards/VM/CardsRuleDetailVM")
local MagicCardTourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MagicCardTourneyMgr = _G.MagicCardTourneyMgr
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender
local ErrorTipsId_NotEnoughCoin = 10006
local LSTR = _G.LSTR

---@class CardsReadinessPanelVM : UIViewModel
local CardsReadinessPanelVM = LuaClass(UIViewModel)

---Ctor
function CardsReadinessPanelVM:Ctor()
    self.IsShowRuleDesc = false
    self.OpponentName = ""
    self.OpponentRoleID = 0 -- 对手的玩家ID
    self.MatchCost = 0
    self.AwardCoins = 0 -- 胜利奖励金币
    self.FailCoins = 0 -- 失败奖励金币
    self.DrawCoins = 0 -- 平局奖励金币
    self.MatchRecord = 0
    self.BattleCardGroupName = ""
    self.RewardCardList = nil
    self.GeneralRulesTextList = nil
    self.PopularRulesTextList = nil
    self.CardGroupList = nil
    self.CardGroupSelectIndex = nil
    self.IsEditingGroup = false
    self.TotalCoinNum = 0
    self.__ItemSelectedToEdit = nil
    self.__ItemAsDefault = nil
    self.__ItemSelectedToBattle = nil
    self.__GroupItemEditing = nil
    self.RuleDescPanelText = nil
    self.CountDownSoundID = 0
    self.TimeWaitForMatchStart = 90
    self.CountDownSoundEffectPlayed = false
    self.UsingCardGroup = nil -- CardsGroupCardVM.New(self, 1) -- 首页显示的，当前使用的卡组信息
    self.UpdateNotify = false
    self.ShowRule = false
    self.CardsRuleDetailVMList = nil
    self.CardGroupList = nil
    self.CurrentSelectGroup = nil
    self.HasAutoGroup = false
    self.IsInTourney = false
    self.CurStageText = ""
    self.CurEffectText = ""
    self.CurEffectDesc = ""
end

function CardsReadinessPanelVM:OnClickBtnShowRule()
    self.ShowRule = not self.ShowRule
end

function CardsReadinessPanelVM:RefreshData()
    self.TimeWaitForMatchStart = MagicCardMgr:GetPrepareSeconds()
    self.HasAutoGroup = false
    local GameInfo = MagicCardMgr.NpcGameInfo
    self.MatchCost = GameInfo.Cost
    self.MatchRecord = GameInfo.Record
    self.AwardCoins = GameInfo.AwardCoins
    local _defaulotGroupIndex = GameInfo.DefaultIndex + 1
    if (_defaulotGroupIndex <= 0) then
        _defaulotGroupIndex = 1
    end
    self.TotalCoinNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
    local DefaultCardGroup = GameInfo.DefaultIndex ~= -1 and GameInfo.CardGroups[_defaulotGroupIndex] or
                                 GameInfo.AutoCardGroups
    self.BattleCardGroupName = DefaultCardGroup and DefaultCardGroup.Name or LSTR(1130086)--"默认卡组"
    self.GeneralRulesTextList = MagicCardVMUtils.GetRuleTextList(
                                    MagicCardVMUtils.GetRuleConfigListSorted(
                                        GameInfo.PlayRules
                                    )
                                )
    self.PopularRulesTextList = MagicCardVMUtils.GetRuleTextList(
                                    MagicCardVMUtils.GetRuleConfigListSorted(
                                        GameInfo.PopularRules
                                    )
                                )
    -- 奖励卡牌
    local RewardCardList = {}
    if GameInfo.AwardCardsNum and GameInfo.AwardCardsNum > #GameInfo.AwardCards then
        local ExposedCardBeginIndex = 0
        -- 新的奖励卡牌，不会下发id，协议中只有数量，显示卡牌背面
        ExposedCardBeginIndex = GameInfo.AwardCardsNum - #GameInfo.AwardCards
        for i = 1, ExposedCardBeginIndex do
            if (#RewardCardList < 4) then
                local NewCardVm = CardReadnessRewardItemVM.New()
                NewCardVm:SetCardId(0)
                table.insert(RewardCardList, NewCardVm)
            end
        end
    end

    if (#RewardCardList < 4) then
        for i, CardId in ipairs(GameInfo.AwardCards) do
            local NewCardVm = CardReadnessRewardItemVM.New()
            NewCardVm:SetCardId(CardId)
            table.insert(RewardCardList, NewCardVm)
        end
    end

    self.RewardCardList = RewardCardList
    -- 奖励卡牌结束

    -- 规则详情相关
    local CardsRuleDetailVMList = {}
    CardsRuleDetailVMList[1] = CardsRuleDetailVM.New()
    CardsRuleDetailVMList[1].TextTitle = LSTR(1130035)--"流行规则"
    CardsRuleDetailVMList[2] = CardsRuleDetailVM.New()
    CardsRuleDetailVMList[2].TextTitle = LSTR(1130036)-- "对局规则"

    local NoRuleColor = {
        R = 0.03,
        G = 0.03,
        B = 0.03,
        A = 1
    }
    local NormalRuleColor = {
        R = 0.462,
        G = 0.136,
        B = 0.02,
        A = 1
    }
    self.GenRuleText(GameInfo.PopularRules, CardsRuleDetailVMList[1], NoRuleColor, NormalRuleColor)
    self.GenRuleText(GameInfo.PlayRules, CardsRuleDetailVMList[2], NoRuleColor, NormalRuleColor)
    self.CardsRuleDetailVMList = CardsRuleDetailVMList
    -- 规则详情结束

    -- 卡组开始
    local CardGroupList = {}
    local _defaultIndex = GameInfo.DefaultIndex or 1
    _defaultIndex = _defaultIndex + 1
    if (_defaultIndex <= 0) then
        _defaultIndex = 1
    end
    for i = 1, LocalDef.CardGroupCount do
        local ServerGroupInfo = GameInfo.CardGroups[i]
        local GroupItemVM = CardsGroupCardVM.New(self, i)
        CardGroupList[i] = GroupItemVM
        if (ServerGroupInfo.Name and ServerGroupInfo.Name ~= "") then
            GroupItemVM:SetGroupName(ServerGroupInfo.Name)
        end
        GroupItemVM:SetGroupCardList(ServerGroupInfo.Cards)
        if (_defaultIndex == i) then
            self:SetSelectCardGroup(GroupItemVM)
        else
            GroupItemVM:SetIsSelected(false)
            GroupItemVM:SetIsDefaultGroup(false)
        end
    end
    self.CardGroupList = CardGroupList
    self:SetItemAsDefaultGroup(CardGroupList[_defaultIndex], true)
    -- 卡组结束

    self.CoinIconName = ScoreMgr:GetScoreIconName(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
    
    self:UpdateOpponentInfo()
    self:UpdateUIPerform()

    self:NotifyModity()
end

 --- 幻卡大赛和普通幻卡对局相关显示
function CardsReadinessPanelVM:UpdateUIPerform()
    self.IsInTourney = MagicCardTourneyMgr:GetIsInTourney()
    self.CurStageText = string.format(MagicCardTourneyDefine.StageProgressText, TourneyVM.CurStageName, TourneyVM.CurStageIndex, 4)
    self.CurEffectText = TourneyVM:GetCurStageEffectProgressText()
    self.CurEffectDesc = TourneyVM.CurEffectDesc
    local TourneyBG = MagicCardTourneyDefine.ImgPath.MagicCardReadinessBGTourney
    local NormalBG = MagicCardTourneyDefine.ImgPath.MagicCardReadinessBGNormal
    local RuleTourneyBG = MagicCardTourneyDefine.ImgPath.MagicCardReadinessRuleBGTourney
    local RuleNormalBG = MagicCardTourneyDefine.ImgPath.MagicCardReadinessRuleBGNormal
    local ScoreImgPath = MagicCardTourneyDefine.ImgPath.Score
    local CoinIconPath = ScoreMgr:GetScoreIconName(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
    self.CoinIconName = self.IsInTourney and ScoreImgPath or CoinIconPath
    self.BigBGPath = self.IsInTourney and TourneyBG or NormalBG
    self.RuleBGPath = self.IsInTourney and RuleTourneyBG or RuleNormalBG
end

--- 更新对手信息
function CardsReadinessPanelVM:UpdateOpponentInfo()
    local OpponentInfo = MagicCardMgr:GetOpponentInfo()
    if (OpponentInfo == nil) then
        _G.FLOG_ERROR("错误，无法获取对手的信息，请检查！")
        return
    end
    self.OpponentName = OpponentInfo.Name
    self.OpponentRoleID = OpponentInfo.RoleID
    self.AwardCoins = OpponentInfo.WinAward or 0
    self.FailCoins = OpponentInfo.FailAward or 0
    self.DrawCoins = OpponentInfo.TieAward or 0
    self.HeadIconPath = OpponentInfo.HeadIconImage
end

--- 自动组卡返回
---@param CardList 返回的卡片ID list 
function CardsReadinessPanelVM:OnAutoGroupCreated(CardList)
    if not CardList or #CardList ~= LocalDef.CardCountInGroup then
        return
    end

    -- 自动组卡处理: 服务器返回的自动卡组插到最前面

    local GroupItemVM = self.CardGroupList[1]
    if (#self.CardGroupList == 6) then
        -- 如果已经有了自动组卡，那么就替换一下
        self.CardGroupList[1]:SetGroupCardList(CardList)
    else
        local CardGroupList = {}
        GroupItemVM = CardsGroupCardVM.New(self, -1) -- 自动组卡
        GroupItemVM:SetGroupCardList(CardList)
        GroupItemVM:SetGroupName(LSTR(LocalDef.UKeyConfig.TempCardGroup))
        GroupItemVM:SetIsAutoGroup(true)
        CardGroupList[1] = GroupItemVM

        for i = 1, 5 do
            CardGroupList[i + 1] = self.CardGroupList[i]
        end
        self.CardGroupList = CardGroupList
    end
    GroupItemVM.ShouldPlayAnimAutoCard = true -- 播放一下自动组卡的动画
    self.HasAutoGroup = true
    self:SetItemAsDefaultGroup(GroupItemVM)

    self:NotifyModity()
end

function CardsReadinessPanelVM:OnClickBtnAuto()
    if (self.CardGroupList ~= nil and #self.CardGroupList > LocalDef.CardGroupCount) then
        return
    end

    _G.MagicCardMgr:SendCreateAutoGroupReq()
end

function CardsReadinessPanelVM:NotifyModity()
    self.UpdateNotify = not self.UpdateNotify -- 通知更新用的
end

function CardsReadinessPanelVM:SetSelectCardGroup(SelectItem)
    if (self.CurrentSelectGroup == SelectItem) then
        return
    end

    if (self.CurrentSelectGroup ~= nil) then
        self.CurrentSelectGroup:SetIsSelected(false)
    end

    self.CurrentSelectGroup = SelectItem
    if (self.CurrentSelectGroup ~= nil) then
        self.CurrentSelectGroup:SetIsSelected(true)
    end
end

---@param ItemVM CardsGroupCardVM
function CardsReadinessPanelVM:SetItemAsDefaultGroup(ItemVM, IsByPlayer)
    if not ItemVM then
        return
    end

    if (not ItemVM.IsAllRulePass and IsByPlayer) then
        return
    end

    self:SetSelectCardGroup(ItemVM)
    if (self.UsingCardGroup ~= nil) then
        self.UsingCardGroup:SetIsDefaultGroup(false)
    end
    self.UsingCardGroup = ItemVM
    self.UsingCardGroup:SetIsDefaultGroup(true)

    if IsByPlayer then
        MagicCardMgr:SendSelectGroupAsDefaultReq(ItemVM:GetServerIndex())
        self:NotifyModity()
    end
end

---@type 当前卡组是否可用
function CardsReadinessPanelVM:IsCurUsingGroupAvailable()
    return self.UsingCardGroup:IsGroupAvailable()
end

---@param CardsRuleDetailVM CardsRuleDetailVM
function CardsReadinessPanelVM.GenRuleText(Rules, CardsRuleDetailVM, NoRuleColor, NormalRuleColor)
    local _targetVM = CardsRuleDetailVM
    local RuleNameAndDescList = MagicCardVMUtils.GetRuleNameAndDescList(MagicCardVMUtils.GetRuleConfigListSorted(Rules))

    if #RuleNameAndDescList == 0 then
        _targetVM:AddTitleAndContent(LSTR(LocalDef.UKeyConfig.None), nil, NoRuleColor, NormalRuleColor)
    else
        for _, Rule in ipairs(RuleNameAndDescList) do
            _targetVM:AddTitleAndContent(Rule.Name, Rule.Desc, NoRuleColor, NormalRuleColor)
        end
    end
end

function CardsReadinessPanelVM:TryEnterChanllenge()
    if self.MatchCost > self.TotalCoinNum then
        _G.MagicCardMgr:QuitBeforeEnterGame()
        _G.MsgTipsUtil.ShowTipsByID(ErrorTipsId_NotEnoughCoin, nil, ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
        return false
    end
    return true
end

function CardsReadinessPanelVM:UpdateTimer()
    if (self.TimeWaitForMatchStart) then
        self.TimeWaitForMatchStart = self.TimeWaitForMatchStart - 1
        if self.TimeWaitForMatchStart <= 5 and not self.CountDownSoundEffectPlayed then
            self.CountDownSoundEffectPlayed = true
            self.CountDownSoundID = AudioUtil.SyncLoadAndPlayUISound(self.BeginCountDown_SoundEffect)
        end

        if self.TimeWaitForMatchStart < 0 then
            if self:TryEnterChanllenge() then
                local RemainTime = self.TimeWaitForMatchStart
                _G.MagicCardMgr:OnWaitingGameToStart(RemainTime)
            end
            -- 取消DragDrop效果
            _G.UE.UWidgetBlueprintLibrary.CancelDragDrop()
        end
    end
end

--- func desc
---@param TargetVM CardsSingleCardVM
function CardsReadinessPanelVM:CanCardClick(TargetVM)
    return false
end

-- 要返回当前类
return CardsReadinessPanelVM
