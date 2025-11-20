---
--- Author: frankjfwang
--- DateTime: 2022-05-17 19:01
--- Description:
---
local CardRuleCfg = require("TableCfg/FantasyCardRuleCfg")
local NpcCfg = require("TableCfg/NpcCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local RaceTypeEnum = ProtoCommon.race_type
local QuestHelper = require("Game/Quest/QuestHelper")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local QuestCfg = require("TableCfg/QuestCfg")
local ProtoRes = require("Protocol/ProtoRes")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local FantasyCardNpcCfg = require("TableCfg/FantasyCardNpcCfg")
local PrepareCameraCfg = require("TableCfg/FantasyCardPrepareCameraCfg")
local LSTR = _G.LSTR
local GLOBAL_CFG_ID = ProtoRes.Game.game_global_cfg_id
local MagicCardVMUtils = {}
local QUEST_STATUS = ProtoCS.CS_QUEST_STATUS

---将Server下发的RuleIdList转换成RuleConfig配置列表，并根据配置的SortWeight排序
---@param RuleIdList integer[]
---@return RuleConfig[]
function MagicCardVMUtils.GetRuleConfigListSorted(RuleIdList)
    local GameRules = {}
    for i = 1, #RuleIdList do
        local RuleId = RuleIdList[i]
        local RuleConfig = RuleId and CardRuleCfg:FindCfgByKey(RuleId) or nil
        if RuleConfig then
            table.insert(GameRules, RuleConfig)
        end
    end
    table.sort(
        GameRules, function(Rule1, Rule2)
            if Rule1.IsHideInUI == 1 then
                return false
            elseif Rule2.IsHideInUI == 1 then
                return true
            else
                return Rule1.SortWeight > Rule2.SortWeight
            end
        end
    )

    return GameRules
end

function MagicCardVMUtils.GetRuleTextList(RuleConfigList)
    local RuleTextList, k = {}, 1
    for _, rc in ipairs(RuleConfigList) do
        if rc.IsHideInUI == 0 then
            RuleTextList[k] = rc.RuleText
            k = k + 1
        end
    end

    -- 没有规则显示“无”
    if #RuleTextList == 0 then
        RuleTextList[1] = LSTR(LocalDef.UKeyConfig.None)
    end

    return RuleTextList
end

function MagicCardVMUtils.GetRuleNameAndDescList(RuleConfigList)
    local RuleTextList, k = {}, 1
    for _, rc in ipairs(RuleConfigList) do
        if rc.IsHideInUI == 0 then
            local RuleNameAndDesc = {}
            RuleNameAndDesc.Name = rc.RuleText
            RuleNameAndDesc.Desc = rc.RuleDesc
            RuleTextList[k] = RuleNameAndDesc
            k = k + 1
        end
    end

    return RuleTextList
end

function MagicCardVMUtils.GetBrefRulesInGame(HideNoResultText)
    local function GenRuleText(Rules)
        local RuleNameAndDescList = MagicCardVMUtils.GetRuleNameAndDescList(
                                        MagicCardVMUtils.GetRuleConfigListSorted(
                                            Rules
                                        )
                                    )
        local Res = ""
        if #RuleNameAndDescList == 0 then
            if (HideNoResultText == nil or not HideNoResultText) then
                Res = LSTR(LocalDef.UKeyConfig.None)
            end
        else
            for Index, Rule in ipairs(RuleNameAndDescList) do
                if Index == 1 then
                    Res = Res .. string.format("%s", Rule.Name)
                else
                    Res = Res .. string.format('\n%s', Rule.Name)
                end
            end
        end
        return Res
    end

    local GameInfo = _G.MagicCardMgr.NpcGameInfo
    local _text = ""
    if (GameInfo ~= nil) then
        local NewRules = table.array_concat(GameInfo.PlayRules, GameInfo.PopularRules)
        _text = GenRuleText(NewRules)
    end

    return _text
end

---@type 获取所有幻卡规则
function MagicCardVMUtils.GetAllRuleInfoList()
    local RuleCfgList = CardRuleCfg:FindAllCfg("IsHideInUI = 0")
    local RuleInfoList = {}
    for _, Rule in ipairs(RuleCfgList) do
        local RuleInfo = {}
        RuleInfo.Name = Rule.RuleText
        RuleInfo.Desc = Rule.RuleDesc
        RuleInfo.DetailedIcon = Rule.DetailedIcon -- 演示图片
        RuleInfo.PictureTitles = Rule.PictureTitles --演示图片标题
        RuleInfo.DetailedDesc = Rule.DetailedDesc --演示图片详细说明
        table.insert(RuleInfoList, RuleInfo)
    end

    return RuleInfoList
end

-- function MagicCardVMUtils.GetStartGameRuleDescRichText()
--     local function GenRuleText(Rules)
--         local RuleNameAndDescList = MagicCardVMUtils.GetRuleNameAndDescList(
--                                         MagicCardVMUtils.GetRuleConfigListSorted(
--                                             Rules
--                                         )
--                                     )
--         local Res = ""
--         if #RuleNameAndDescList == 0 then
--             Res = '<span size="22" color="#252525">无</>\n\n'
--         else
--             for _, Rule in ipairs(RuleNameAndDescList) do
--                 Res = Res ..
--                           string.format(
--                               '<span size="22" color="#252525">%s：</><span size="20" color="#585858">%s</>\n\n',
--                               Rule.Name, Rule.Desc
--                           )
--             end
--         end
--         return Res
--     end

--     local GameInfo = _G.MagicCardMgr.NpcGameInfo
--     local RuleDescPanelText = '<span size="22" color="#7D4C21">本局规则</>\n\n'
--     RuleDescPanelText = RuleDescPanelText .. GenRuleText(GameInfo.PlayRules) .. "\n\n"
--     RuleDescPanelText = RuleDescPanelText .. '<span size="22" color="#7D4C21">流行规则</>\n\n'
--     RuleDescPanelText = RuleDescPanelText .. GenRuleText(GameInfo.PopularRules) .. "\n\n"

--     return RuleDescPanelText
-- end

-- function MagicCardVMUtils.GetInGameRuleDescRichText()
--     local function GenRuleText(Rules)
--         local RuleNameAndDescList = MagicCardVMUtils.GetRuleNameAndDescList(
--                                         MagicCardVMUtils.GetRuleConfigListSorted(
--                                             Rules
--                                         )
--                                     )
--         local Res = ""
--         if #RuleNameAndDescList == 0 then
--             Res = '<span size="22" color="#FBFDFA">无</>\n\n'
--         else
--             for _, Rule in ipairs(RuleNameAndDescList) do
--                 Res = Res ..
--                           string.format(
--                               '<span size="22" color="#FBFDFA">%s：</><span size="20" color="#B1B4BB">%s</>\n\n',
--                               Rule.Name, Rule.Desc
--                           )
--             end
--         end
--         return Res
--     end

--     local GameInfo = _G.MagicCardMgr.NpcGameInfo
--     local RuleDescPanelText = '<span size="22" color="#E0D4BC">本局规则</>\n\n'
--     RuleDescPanelText = RuleDescPanelText .. GenRuleText(GameInfo.PlayRules) .. "\n\n"
--     RuleDescPanelText = RuleDescPanelText .. '<span size="22" color="#E0D4BC">流行规则</>\n\n'
--     RuleDescPanelText = RuleDescPanelText .. GenRuleText(GameInfo.PopularRules) .. "\n\n"

--     return RuleDescPanelText
-- end

---@type 获取对局准备时间
function MagicCardVMUtils.GetCardReadyTime(IsPVP)
    local ReadyTimeOutValues = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_READY_TIMEOUT, "Value")  --1093
    if ReadyTimeOutValues == nil or #ReadyTimeOutValues < 2 then
        return 0
    end

    return IsPVP and tonumber(ReadyTimeOutValues[1]) or tonumber(ReadyTimeOutValues[2])
end

---@type 等待对手准备期间的提示文本
function MagicCardVMUtils.GetWaitForOpponentText()
    local TipIDList = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_TOURNAMENT_WAIT_NOTICE, "Value") -- 1083
    if TipIDList and #TipIDList > 0 then
        local TipIDIndex = math.random(#TipIDList)
        local TipID = TipIDList[TipIDIndex]
        local Cfg = SysnoticeCfg:FindCfgByKey(TipID)
        if nil == Cfg then
            return
        end
        return Cfg.Content[1]
    end
    return ""
end

---@type 获取玩家打牌相关动作ID
function MagicCardVMUtils.GetFantasyCardTimelineID(AnimEnum)
    --暂时只有两个动作，1：待机 2：出牌 3:掏牌
    local TimeLineIDList = ClientGlobalCfg:FindValue(ProtoRes.client_global_cfg_id.GLOBAL_CFG_FANTASY_CARD_ANIM, "Value")
    if TimeLineIDList == nil or #TimeLineIDList <= 0 then
        return
    end

    return TimeLineIDList[AnimEnum]
end

---@type 获取玩家打牌位置信息
function MagicCardVMUtils.GetGamePosInfoWithNPC(NpcID)
    local NPCData = FantasyCardNpcCfg:FindCfgByKey(NpcID)
    if NPCData == nil then
        return
    end
    local PosInfo = {}
    PosInfo.DistanceToNpc = NPCData.DistanceToNpc
    local MajorLoc = NPCData.MajorLocation
    if not (MajorLoc.X == 0 and MajorLoc.Y == 0 and MajorLoc.Z == 0) then
        PosInfo.MajorLocation = _G.UE.FVector(MajorLoc.X, MajorLoc.Y, MajorLoc.Z)
    end
    local NPCLoc = NPCData.NPCLocation
    if not (NPCLoc.X == 0 and NPCLoc.Y == 0 and NPCLoc.Z == 0) then
        PosInfo.NPCLocation = _G.UE.FVector(NPCLoc.X, NPCLoc.Y, NPCLoc.Z)
    end
    return PosInfo
end

---@type 是否为幻卡NPC
function MagicCardVMUtils.IsMagicCardNPC(NpcID)
    local NPCData = FantasyCardNpcCfg:FindCfgByKey(NpcID)
    return NPCData ~= nil
end

---@type 玩家是否需要生成凳子
function MagicCardVMUtils.IsMajorNeedStandOnStool(NpcID)
    if MajorUtil:GetMajorRaceID() ~= RaceTypeEnum.RACE_TYPE_Lalafell then
        return false
    end
    local NPCData = FantasyCardNpcCfg:FindCfgByKey(NpcID)
    if NPCData == nil then
        return false
    end
    return NPCData.IsStandOnStool and NPCData.IsStandOnStool > 0
end

---@type 获取摄像机配置
---@param AttachType string SkeletonName 骨骼模型名
function MagicCardVMUtils.GetCameraControlParams(AttachType)
    local CameraParams = {}
    local CameraCfg = nil
    if string.isnilorempty(AttachType) then
        CameraCfg = PrepareCameraCfg:FindCfgByKey(1)
    else
        CameraCfg = PrepareCameraCfg:FindCfg(string.format("SkeletonName = \"%s\"", AttachType))
    end

    if CameraCfg then
        CameraParams.Distance = CameraCfg.ViewDistance
        CameraParams.Offset = CameraCfg.Offset
        CameraParams.FOV = CameraCfg.FOV
    end

    return CameraParams
end

---@type 幻卡NPC是否完成所有任务
function MagicCardVMUtils.IsCardNPCFinishedQuest(NpcResID)
    if NpcResID == nil then
        return false
    end

    local QuestItems = QuestCfg:FindAllCfg(string.format("StartNpc = \"%s\"", NpcResID))
    if QuestItems == nil then
        return true -- 没有任务需要完成
    end
    -- 所有任务是否已完成
    for _,QuestItem in pairs(QuestItems) do
        local QuestID = QuestItem.id
        local CanAccept = QuestHelper.CheckCanAccept(QuestID)
        -- 无法接取的任务，视为已完成，可以显示幻卡图标
        if not CanAccept then
            return true
        end
        -- 未开始的任务，视为已完成，可以显示幻卡图标
        local _questStatus = _G.QuestMgr:GetQuestStatus(QuestID)
        if _questStatus == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED then
            return true
        end
        -- 已开始但未完成的任务，不可以显示幻卡图标
        if (_questStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED) then
            return false
        end
    end
    
    return true
end

--------------------- 新手引导相关数据 ----------------------------------------

---@type 准备界面数据
function MagicCardVMUtils.GetTutorialGroupViewData()
    local TutorialGroupViewData = {
        PlayRules = {1},
        PopularRules = {},
        Cost = 0,
        Record = 0,
        AwardCoins = 0,
        AwardCards = {},
        AwardCardsNum = 0,
        CardGroups = {}, --[1] = {Name = "", Cards = {61400001,61400003,61400006,61400007,61400010}},
        DefaultIndex = 0,
        BattleID = 0,
        OpponentInfo = {
            NPCID = 1011060,
        },
        FinishTime = 0
    }

    for i = 1, LocalDef.CardGroupCount do
        local CardGroup = {
            Name = "",
        }
        if i == 1 then
            CardGroup.Cards = MagicCardVMUtils.GetPlayerInitCardIDs()
        else
            CardGroup.Cards = {}
        end
        table.insert(TutorialGroupViewData.CardGroups, CardGroup)
    end
    
    return TutorialGroupViewData
end

---@type 进入对局数据
function MagicCardVMUtils.GetTutorialEnterViewData()
    local TutorialEnterViewData = {
        CardGameID = 0, -- 牌局ID
        Group = 1,    -- 玩家后手
        Round = 6,         -- 当前轮次
        AutoPlayTime = 0,  -- 下次自动出牌时间戳MS(UTC)
      
        -- 双方持有的卡牌
        --{"CardID":61400001,"Group":0,"Change":0,"ScoreChange":0,"OnHandLoc":0,"FlipType":0,"IsExposed":true,"BoardLoc":-1},
        AttackerCards = LocalDef.TutorialInitCardsDataNPC, -- MagicCardVMUtils.GetTutorialInitCardsData(LocalDef.TutorialNPCID), -- 先手方持有的卡牌
        -- {"CardID":61400001,"Group":1,"Change":0,"ScoreChange":0,"OnHandLoc":0,"FlipType":0,"IsExposed":true,"BoardLoc":-1},
        DefenderCards = LocalDef.TutorialInitCardsDataPlayer, -- MagicCardVMUtils.GetTutorialInitCardsData(), -- 后手方持有的卡牌
      
        Board = LocalDef.TutorialInitCardsDataBoard, --{},  -- 牌局状态
      
        -- 混乱&秩序规则下，双方强制按照系统安排的顺序使用卡组中的卡牌, 数组元素为卡牌在玩家卡组里的次序
        CardsPlayOrder = {},
      
        -- 交换规则下，双方交换的卡牌在各玩家卡组里的次序, 无交换规则时值为-1
        AttackerExchange = -1,
        DefenderExchange = -1,
      
        Rules = {1},         -- 本局规则
        PopularRules = {},  -- 流行规则
        -- 对手信息
        OpponentInfo = {
            NPCID = LocalDef.TutorialNPCID,
        },
        OpponentEmoSetup = "",           -- 对手表情设置
        Status = 2,                      -- 对局状态：0匹配完成，1选卡组，2进行中，3等待领奖
    }

    -- for i = 1, 9 do
    --     table.insert(TutorialEnterViewData.Board, {
    --     Change = 0,
    --     ScoreChange  = 0,
    --     FlipType = 0,
    --     IsExposed = false,
    --     BoardLoc = 0,
    --     CardID = 0,
    --     Group = 0,
    --     OnHandLoc = 0})
    -- end

    return TutorialEnterViewData
end

---@type 获取初始卡牌数据
function MagicCardVMUtils.GetTutorialInitCardsData(NPCID)
    
    local Cards = {}
    local CardIDList = {}
    -- 玩家卡牌
    if NPCID == nil then
        CardIDList = MagicCardVMUtils.GetPlayerInitCardIDs()
        if CardIDList and #CardIDList > 0 then
            for Index, CardID in ipairs(CardIDList) do
                local CardData = {
                    Change = 0,
                    ScoreChange  = 0,
                    FlipType = 0,
                    IsExposed = true,
                    BoardLoc = -1,
                    CardID = CardID,
                    Group = 1, --玩家后手
                    OnHandLoc = Index - 1
                }
                table.insert(Cards, CardData)
            end
        end
    else
        CardIDList = MagicCardVMUtils.GetNPCInitCardIDs(NPCID)
        if CardIDList and #CardIDList > 0 then
            for Index, CardID in ipairs(CardIDList) do
                local CardData = {
                    Change = 0,
                    ScoreChange  = 0,
                    FlipType = 0,
                    IsExposed = true,
                    BoardLoc = -1,
                    CardID = CardID,
                    Group = 0,
                    OnHandLoc = Index - 1
                }
                table.insert(Cards, CardData)
            end
        end
    end

    return Cards
end

---@type 获取玩家初始卡牌ID
function MagicCardVMUtils.GetPlayerInitCardIDs()
    local CardIDList = {}
    local CardIDValues = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_INIT_CARDS, "Value") -- 幻卡初始卡组
    if CardIDValues and #CardIDValues > 0 then
        for _, Value in ipairs(CardIDValues) do
            table.insert(CardIDList, tonumber(Value))
        end
    end
    return CardIDList
end

---@type 获取NPC初始卡牌ID
function MagicCardVMUtils.GetNPCInitCardIDs(NPCID)
    local NPCData = FantasyCardNpcCfg:FindCfgByKey(NPCID)
    if NPCData == nil then
        return
    end
    return NPCData.Cards
end

---@type 对局中出牌数据
---@param Round 回合数
function MagicCardVMUtils.GetTutorialMoveDataByRound(Round, IsPlayerMove)
    if Round == nil then
        return
    end
    local TutorialMoveData = LocalDef.TutorialMoveDatas[Round]
    if TutorialMoveData == nil then
        return
    end
    -- local  CardIDList =  {}
    -- if IsPlayerMove then
    --     CardIDList = MagicCardVMUtils.GetPlayerInitCardIDs()
    -- else
    --     CardIDList = MagicCardVMUtils.GetNPCInitCardIDs(LocalDef.TutorialNPCID)
    -- end
    -- if Round >= 9  then
    --     TutorialMoveData.Card.CardID = CardIDList[2]
    -- else
    --     TutorialMoveData.Card.CardID = CardIDList[1]
    -- end
    return TutorialMoveData
end

function MagicCardVMUtils:GetTutorialWidget(TutorialID)
    local WidgetInfo = LocalDef.TutorialWidgetRef[TutorialID]
    if WidgetInfo == nil then
        return nil
    end

    local UIBPName = WidgetInfo.BPName or ""
    local ViewID = _G.UIViewMgr:GetViewIDByName(UIBPName)
    local View = _G.UIViewMgr:FindVisibleView(ViewID)
    local WidgetPath = WidgetInfo.WidgetPath

    if View == nil or WidgetPath == nil or WidgetPath == "" then
        return View
    end

    local ResTable = string.split(WidgetPath, "/")
    for _, v in ipairs(ResTable) do
        if View[v] then
            View = View[v]
        end
    end
    return View
end

function MagicCardVMUtils:HandleClickGuideWidget(TutorialID, Widget, MouseEvent)
    if Widget == nil then
        return
    end

    FLOG_INFO("[MagicCardVMUtils]Widget Name is %s",Widget:GetName())

    if MouseEvent and Widget["OnMouseButtonDown"] ~= nil then
		Widget.OnMouseButtonDown(Widget, nil, MouseEvent)
    elseif Widget["OnClicked"] ~= nil then
        Widget["OnClicked"]:Broadcast()
    end
end

--------------------- 新手引导相关数据 End----------------------------------------

return MagicCardVMUtils
