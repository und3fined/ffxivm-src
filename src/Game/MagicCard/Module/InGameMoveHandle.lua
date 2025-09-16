---
--- Author: frankjfwang
--- DateTime: 2022-05-20 17:43
--- Description:
---
local LuaClass = require("Core/LuaClass")

local Log = require("Game/MagicCard/Module/Log")
local ProtoRes = require("Protocol/ProtoRes")

local RuleDef = ProtoRes.Game.fantasy_card_rule

local ipairs = ipairs
local table = table
local table_find = table.find_item

---@class OneTriggerEffect 一组翻牌效果
---@field TriggerCardBoardLoc integer 触发规则效果的卡牌在牌桌上的Loc
---@field FlipCards OneFlippedCard[] 受规则效果影响的卡牌
local OneTriggerEffect = LuaClass()
function OneTriggerEffect:Ctor()
    self.TriggerCardBoardLoc = -1
    self.FlipCards = {}
end

---@class OneCommonFlipEffect 一条规则触发的多组翻牌效果，基类
---@field RuleId integer 规则id，0为普通规则
---@field TriggerEffects OneTriggerEffect[] 触发规则效果
local OneCommonFlipEffect = LuaClass()
function OneCommonFlipEffect:Ctor()
    self.RuleId = 0
    self.TriggerEffects = nil
end

---@class OneChangedRuleEffect : OneCommonFlipEffect 强化/弱化规则显示效果
local OneChangedRuleEffect = LuaClass(OneCommonFlipEffect)
function OneChangedRuleEffect:Ctor(RuleId)
    self.RuleId = RuleId
end

---@class OneChangedCard 单张卡牌同类强化/弱化效果
---@field IsPlayerCard boolean
---@field IsOnHandCard boolean
---@field Loc integer
---@field Change integer 加/减点数
local OneChangedCard = LuaClass()

---@param SvrCard FantasyCard
function OneChangedCard:Ctor(SvrCard, PlayerCardGroup)
    self.IsPlayerCard = SvrCard.Group == PlayerCardGroup
    self.IsOnHandCard = SvrCard.OnHandLoc ~= -1
    self.Loc = self.IsOnHandCard and SvrCard.OnHandLoc + 1 or SvrCard.BoardLoc + 1
    self.Change = SvrCard.Change
end

---@class OneChangedEffect 同类强化/弱化效果
---@field RuleEffect OneChangedRuleEffect 规则显示效果
---@field IsStrengthOrWeaken boolean 是强化还是弱化效果
---@field ChangedCards OneChangedCard[] 受影响的卡牌
local OneChangedEffect = LuaClass()

function OneChangedEffect:Ctor(SvrRuleEffect, PlayerCardGroup)
    local Rule = SvrRuleEffect.Rule
    Log.Check(Rule == RuleDef.FANTASY_CARD_RULE_STRENGTHEN or Rule == RuleDef.FANTASY_CARD_RULE_WEAKEN)
    self.RuleEffect = OneChangedRuleEffect.New(Rule)
    self.IsStrengthOrWeaken = Rule == RuleDef.FANTASY_CARD_RULE_STRENGTHEN
    self.ChangedCards = {}
    for i, Card in ipairs(SvrRuleEffect.Cards) do
        self.ChangedCards[i] = OneChangedCard.New(Card, PlayerCardGroup)
    end
end

---@class OneFlippedCard 单张卡牌翻牌效果
---@field IsPlayerCard boolean
---@field BoardLoc integer
---@field CardId integer
---@field FlipType ProtoCS.FLIP_MOVEMENT
---@field IsFlipBySpecialRule boolean
---@field RuleId integer
local OneFlippedCard = LuaClass()

---@param SvrCard FantasyCard
function OneFlippedCard:Ctor(SvrCard, PlayerCardGroup, RuleId)
    Log.Check(SvrCard.BoardLoc ~= -1, "翻牌必须是牌桌上的牌")
    self.BoardLoc = SvrCard.BoardLoc + 1
    self.CardId = SvrCard.CardID
    self.IsPlayerCard = SvrCard.Group == PlayerCardGroup
    self.FlipType = SvrCard.FlipType
    self.RuleId = RuleId
    self.IsFlipBySpecialRule = self.FlipType > 0 and table_find(OneFlippedCard.SpecialRules, RuleId)
end

--- 导致翻牌的特殊规则
OneFlippedCard.SpecialRules = {
    RuleDef.FANTASY_CARD_RULE_FOLLOW_UP,
    RuleDef.FANTASY_CARD_RULE_SAME_NUM,
    RuleDef.FANTASY_CARD_RULE_ADD_CALC
}

---@class OneComboFlipEffect : OneCommonFlipEffect 一张卡牌触发的一组连携效果
local OneComboFlipEffect = LuaClass(OneCommonFlipEffect)
function OneComboFlipEffect:Ctor(SvrFollowUpCauses, PlayerCardGroup)
    self.RuleId = RuleDef.FANTASY_CARD_RULE_FOLLOW_UP
    self.TriggerEffects = {}
    for i, Combo in ipairs(SvrFollowUpCauses) do
        local TriggerEffect = OneTriggerEffect.New()
        TriggerEffect.TriggerCardBoardLoc = Combo.SourceCard.BoardLoc + 1
        for j, Card in ipairs(Combo.FlippedCards) do
            TriggerEffect.FlipCards[j] = OneFlippedCard.New(Card, PlayerCardGroup, self.RuleId)
        end
        self.TriggerEffects[i] = TriggerEffect
    end
end

---@class OneAceKillerEffect : OneCommonFlipEffect 连携中触发的一次王牌杀手效果
local OneAceKillerEffect = LuaClass(OneCommonFlipEffect)
function OneAceKillerEffect:Ctor()
    self.RuleId = RuleDef.FANTASY_CARD_RULE_TRUMP
end

---@class OneComboEffect 单次连携效果，可能有多张卡牌触发多组
---@field AceKillerEffect OneAceKillerEffect 王牌杀手效果，没有为nil
---@field ComboFlipEffect OneComboFlipEffect 单次连携的效果
---@field FilpCards OneFlippedCard[] 单次连携造成的所有翻牌
local OneComboEffect = LuaClass()
function OneComboEffect:Ctor(SvrFollowUp, PlayerCardGroup)
    self.AceKillerEffect = SvrFollowUp.HasTrump == 1 and OneAceKillerEffect.New() or nil
    self.ComboFlipEffect = OneComboFlipEffect.New(SvrFollowUp.Causes, PlayerCardGroup)
    self.FilpCards = {}
    local CurCardIndex = 1
    for _, Combo in ipairs(SvrFollowUp.Causes) do
        for _, Card in ipairs(Combo.FlippedCards) do
            self.FilpCards[CurCardIndex] = OneFlippedCard.New(Card, PlayerCardGroup, self.ComboFlipEffect.RuleId)
            CurCardIndex = CurCardIndex + 1
        end
    end
end

---@class OneRuleEffect : OneCommonFlipEffect 一条规则触发的效果
local OneRuleEffect = LuaClass(OneCommonFlipEffect)
function OneRuleEffect:Ctor(SvrRuleEffect, PlayerCardGroup, PlayedBoardLoc)
    self.RuleId = SvrRuleEffect.Rule
    local TriggerEffect = OneTriggerEffect.New()
    TriggerEffect.TriggerCardBoardLoc = PlayedBoardLoc
    for i, Card in ipairs(SvrRuleEffect.Cards) do
        TriggerEffect.FlipCards[i] = OneFlippedCard.New(Card, PlayerCardGroup, self.RuleId)
    end
    self.TriggerEffects = {
        TriggerEffect
    }
end

---@class AllRuleEffect 王牌/加算/同数/普通规则/同类强化/弱化
---@field RuleEffects OneRuleEffect[] 所有造成效果的规则，服务器排序
---@field FlipCards OneFlippedCard[] 规则造成的所有翻牌效果
---@field ChangedEffect OneChangedEffect 同类强化/弱化
local AllRuleEffect = LuaClass()
function AllRuleEffect:Ctor(SvrRuleEffects, PlayerCardGroup, PlayedBoardLoc)
    self.RuleEffects = {}
    self.FlipCards = {}
    local CurRuleIndex, CurCardIndex = 1, 1
    for _, SvrRuleEffect in ipairs(SvrRuleEffects) do
        local RuleId = SvrRuleEffect.Rule
        if table_find(AllRuleEffect.ToFlipRules, RuleId) then
            self.RuleEffects[CurRuleIndex] = OneRuleEffect.New(SvrRuleEffect, PlayerCardGroup, PlayedBoardLoc)
            CurRuleIndex = CurRuleIndex + 1
            for _, Card in ipairs(SvrRuleEffect.Cards) do
                self.FlipCards[CurCardIndex] = OneFlippedCard.New(Card, PlayerCardGroup, RuleId)
                CurCardIndex = CurCardIndex + 1
            end
        elseif RuleId == RuleDef.FANTASY_CARD_RULE_STRENGTHEN or RuleId == RuleDef.FANTASY_CARD_RULE_WEAKEN then
            Log.Check(self.ChangedEffect == nil, "服务器下发了超过一次强化/弱化规则")
            self.ChangedEffect = OneChangedEffect.New(SvrRuleEffect, PlayerCardGroup)
        else
            Log.Error("服务器下发RuleID [%s] 无法处理", Log.EnumValueToKey(RuleDef, RuleId))
        end
    end
end

---会导致翻牌的规则
AllRuleEffect.ToFlipRules = {
    0,
    RuleDef.FANTASY_CARD_RULE_TRUMP,
    RuleDef.FANTASY_CARD_RULE_SAME_NUM,
    RuleDef.FANTASY_CARD_RULE_ADD_CALC
}

function AllRuleEffect:IsEmpty()
    return #self.RuleEffects == 0 and self.ChangedEffect == nil
end

---@class MoveFlipEffect 当前回合造成的所有卡牌效果
---@field RuleEffect AllRuleEffect
---@field ComboEffects OneComboEffect[] 连携
---@field PlayedBoardLoc integer 当前回合在牌桌上放牌的位置
local MoveFlipEffect = LuaClass()
function MoveFlipEffect:Ctor(SvrNewMoveRsp, PlayerCardGroup)
    local BoardCard = SvrNewMoveRsp.Card
    self.PlayedBoardLoc = BoardCard and BoardCard.BoardLoc + 1 or 0
    self.RuleEffect = AllRuleEffect.New(SvrNewMoveRsp.RuleEffects, PlayerCardGroup, self.PlayedBoardLoc)
    self.ComboEffects = {}
    for i, SvrFollowUp in ipairs(SvrNewMoveRsp.FollowUps) do
        self.ComboEffects[i] = OneComboEffect.New(SvrFollowUp, PlayerCardGroup)
    end
end

--- 计算这一轮pc和npc各自翻牌数量
---@return integer, integer
function MoveFlipEffect:GetFlipCardNumForPcAndNpc()
    local PcNum, NpcNum = 0, 0
    local function UpdateFlipCardNumForPcAndNpc(FilppedCards)
        for _, Card in ipairs(FilppedCards) do
            if Card.IsPlayerCard then
                PcNum = PcNum + 1
            else
                NpcNum = NpcNum + 1
            end
        end
    end
    UpdateFlipCardNumForPcAndNpc(self.RuleEffect.FlipCards)
    for _, ComboEffect in ipairs(self.ComboEffects) do
        UpdateFlipCardNumForPcAndNpc(ComboEffect.FilpCards)
    end
    return PcNum, NpcNum
end

function MoveFlipEffect:GetComboNum()
    return #self.ComboEffects
end

---是否本轮无事发生
function MoveFlipEffect:IsMoveEffectEmpty()
    return self.RuleEffect:IsEmpty() and self:GetComboNum() == 0
end

local MagicCardMgr = nil ---@type MagicCardMgr
local GameRuleService = nil ---@type GameRuleService
local InGameService = nil ---@type InGameService

---@class MoveHandle
local MoveHandle = {}

function MoveHandle.Init(InGameSrv)
    InGameService = InGameSrv
    MagicCardMgr = _G.MagicCardMgr
    GameRuleService = MagicCardMgr:GetRuleService()
end

function MoveHandle.Reset(IsPlayerNextMove)
end

function MoveHandle.SetMoveRsp(SvrNewMoveRsp)
    InGameService.NewMoveFlipEffect = MoveFlipEffect.New(SvrNewMoveRsp, InGameService.PlayerCardGroup)
end

return MoveHandle
