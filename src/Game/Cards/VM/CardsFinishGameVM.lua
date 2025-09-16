---
--- Author: MichaelYang_LightPaw
--- DateTime: 2023-11-21 10:01
--- Description:
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local MagicCardLocalDef = require("Game/MagicCard/MagicCardLocalDef")
local MajorUtil = require("Utils/MajorUtil")
local CardReadnessRewardItemVM = require("Game/Cards/VM/CardReadnessRewardItemVM")
local GetMoreCardHintsCfg = require("TableCfg/FantasyCardMoreCardHintCfg")
local DialogCfg = require("TableCfg/DialogCfg")
local ProtoCS = require("Protocol/ProtoCS")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local NpcCfg = require("TableCfg/FantasyCardNpcCfg")
local FantasyCardNpcCfg = require("TableCfg/FantasyCardNpcCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")
local CardItemType = MagicCardLocalDef.CardItemType
local MagicCardMgr = _G.MagicCardMgr
local BagMgr = require("Game/Bag/BagMgr")

---@class CardsFinishGameVM : UIViewModel
local CardsFinishGameVM = LuaClass(UIViewModel)

---@param GameFinishRsp FantasyCardFinishRsp
function CardsFinishGameVM:Ctor()
    self.BattleResult = nil
    self.BlueTeamName = nil
    self.RedTeamName = nil
    self.BattleRecordNum = 0
    self.AwardCoinsCount = 0
    self.AllHintsList = nil
    self.IsShowGetMoreSuggest = false
    self.__NewCards = nil
    self.ResultCoin = 0
    self.RewardItemVMList = nil
    self.HeadIconPath = ""
    self.OpponentRoleID = 0
end

function CardsFinishGameVM:InitData(GameFinishRsp)
    local _opponentInfo = MagicCardMgr:GetOpponentInfo()
    if (_opponentInfo ~= nil) then
        self.RedTeamName = _opponentInfo.Name
        self.HeadIconPath = _opponentInfo.HeadIconImage
        self.OpponentRoleID = _opponentInfo.RoleID
    else
        _G.FLOG_ERROR("错误，获取幻卡对手信息为空")
        self.RedTeamName = nil
        self.HeadIconPath = nil
        self.OpponentRoleID = 0
    end

    self.BattleResult = GameFinishRsp.Result
    self.BlueTeamName = MajorUtil.GetMajorName()
    self.BattleRecordNum = GameFinishRsp.Record
    self.ResultCoin = GameFinishRsp.AwardCoinsCount

    local RewardItemList = {}
        
    GameFinishRsp.AwardCardsResID = GameFinishRsp.AwardCardsResID or {}
    for i, CardId in ipairs(GameFinishRsp.AwardCardsResID) do
        local _newVM = CardReadnessRewardItemVM.New()
        RewardItemList[i] = _newVM
        _newVM:SetCardId(CardId)
    end

    self.AllHintsList = GetMoreCardHintsCfg:GetHints()
    self.IsShowGetMoreSuggest = false
    self.__NewCards = GameFinishRsp.FirstSeenCards

    if (self.ResultCoin > 0) then
        local _newVM = CardReadnessRewardItemVM.New()
        RewardItemList[#RewardItemList + 1] = _newVM
        _newVM:SetCount(self.ResultCoin)
        _newVM:SetIconImage(ScoreMgr:GetScoreIconName(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE))
        _newVM.CurrencyID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE

        local LootItem = {}
        LootItem.IsSameTime = false
        LootItem.Type = 0
        LootItem.Score = {}
        LootItem.Score.ResID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
        LootItem.Score.Value = self.ResultCoin
        LootItem.Score.Percent = 0
        LootItem.Score.ProfID = 10
        self.CoinLootItem = LootItem
    else
        self.CoinLootItem = nil
    end

    self.RewardItemVMList = RewardItemList
end


function CardsFinishGameVM:OnQuitGame()
    local DialogIdMap = {
        [ProtoCS.BATTLE_RESULT.BATTLE_RESULT_WIN] = "DialogIDSuccess",
        [ProtoCS.BATTLE_RESULT.BATTLE_RESULT_FAIL] = "DialogIDFailure",
        [ProtoCS.BATTLE_RESULT.BATTLE_RESULT_TIE] = "DialogIDDraw"
    }

    local PVENPCID = MagicCardMgr:GetPVENPCID()
    local PVENPCEntityID = MagicCardMgr:GetPVENPCEntityID()
    if (PVENPCID ~= nil and PVENPCID > 0) then
        local Cfg = NpcCfg:FindCfgByKey(PVENPCID)
        local NpcDialogLibID = Cfg and Cfg[DialogIdMap[self.BattleResult]] or 14048
        local NpcDialogCfg = DialogCfg:FindAllCfg("DialogLibID = "..NpcDialogLibID)
        if NpcDialogCfg == nil or next(NpcDialogCfg) == nil then
            _G.FLOG_ERROR("NPC：%d ，配置的对话ID在NPC对话表中不存在，请检查NPC对话表", PVENPCID or 0)
            MagicCardMgr:OnUserQuitGame()
        else
            Utils.PlayNpcDialog(
                PVENPCEntityID, NpcDialogLibID, function()
                    MagicCardMgr:OnUserQuitGame()
                end
            )
        end
    else
        MagicCardMgr:OnUserQuitGame()
    end
end

return CardsFinishGameVM
