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

return MagicCardVMUtils
