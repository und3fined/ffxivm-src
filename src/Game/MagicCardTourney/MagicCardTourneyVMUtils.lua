---
--- Author: Carl
--- DateTime: 2023-12-17 19:01
--- Description:
---
local ProtoCS = require("Protocol/ProtoCS")
local AwardCfg = require("TableCfg/FantasyTournamentAwardCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local FantasyCardRuleCfg = require("TableCfg/FantasyCardRuleCfg")
local FantasyCardNpcCfg = require("TableCfg/FantasyCardNpcCfg")
local HeadPortraitCfg = require("TableCfg/HeadPortraitCfg")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local TourneyCfg = require("TableCfg/FantasyTournamentCfg")
local TourneyEffectCfg = require("TableCfg/FantasyTournamentEffectCfg")
local FantasyAINameCfg = require("TableCfg/FantasyAiNameCfg")
local TourneyLocationCfg = require("TableCfg/FantasyTournamentLocationCfg")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local NPCBaseCfg = require("TableCfg/NpcbaseCfg")
local NPCCfg = require("TableCfg/NpcCfg")
local ItemUtil = require("Utils/ItemUtil")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")


local GLOBAL_CFG_ID = ProtoRes.Game.game_global_cfg_id
local MagicCardTourneyVMUtils = {}

---@type 排名是否可领奖励
---@param Rank number
function MagicCardTourneyVMUtils.IsCanGetAwardByRank(Rank)
	local SearchConditions = string.format("Type=%d and Arg=%d", 
		ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_RANK, Rank)
	local AwardCfg = AwardCfg:FindCfg(SearchConditions)
    return AwardCfg ~= nil
end

---@type 获取排名显示文本
---@param Rank number
function MagicCardTourneyVMUtils.GetRankText(InRank)
    local Type = ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_RANK
    local SearchConditions = string.format("Type=%d and Arg=%d", Type, InRank)
    local RankAwardCfg = AwardCfg:FindCfg(SearchConditions)
    local Rank = tonumber(InRank)
    if RankAwardCfg == nil or Rank <= 0 then
        return TourneyDefine.NotOnTheListText
    end
    
    return Rank
end

---@type 积分是否可领奖励
---@param Score number
function MagicCardTourneyVMUtils.IsCanGetAwardByScore(Score)
    local AwardScoreList = MagicCardTourneyVMUtils.GetScoreAwardInfo()
    for _, Award in ipairs(AwardScoreList) do
		if Score >= Award.AwardScore then
			return true
		end
	end
	
	return false
end

---@type 获取与NPC对局参加幻卡大赛的奖励信息
---@param NPCID number
function MagicCardTourneyVMUtils.GetNPCAwardWithTourney(NPCID)
    if NPCID == nil or NPCID <= 0 then
        return nil
    end

    local AICfg = FantasyCardNpcCfg:FindCfgByKey(NPCID)
    if AICfg == nil then
        return
    end

    local AwardScoreStr = AICfg.TournamentScore
    if string.isnilorempty(AwardScoreStr) then
        return
    end

    local ScoreList = string.split(AwardScoreStr, ",")
    if ScoreList == nil or #ScoreList <= 2 then
        return
    end

    local AwardScoreInfo = {
        WinAward = tonumber(ScoreList[1]),
        FailAward = tonumber(ScoreList[2]),
        TieAward = tonumber(ScoreList[3]),
    }
    
    return AwardScoreInfo
end

---@type 获取AI机器人对手信息
---@param RobotNameID number AI名字ID
---@param StageIndex number 阶段
function MagicCardTourneyVMUtils.GetOpponentInfoByRobotInfo(RobotOpponentInfo, StageIndex)
    local RobotNameID = RobotOpponentInfo.RobotNameID or 0
    local RobotRoleID = RobotOpponentInfo.RobotCopyTargetRoleID or 0
    local RobotNPCID = RobotOpponentInfo.RobotCopyTargetNPCID or 0
    local Info = {}
    local AINameCfg = FantasyAINameCfg:FindCfgByKey(RobotNameID)
    local AwardInfo = MagicCardTourneyVMUtils.GetMagicCardTourneyScoreAward(StageIndex)
    if RobotRoleID and RobotRoleID > 0 then
        Info.RoleID = RobotRoleID
    elseif RobotNPCID and RobotNPCID > 0 then
        Info.HeadIconImage = MagicCardTourneyVMUtils.GetPVPRobotNPCHeadIconPath(RobotNPCID)
    end

    if AINameCfg then
        Info.Name = _G.LSTR(1150074) --1150074("一个神秘的对手") AINameCfg.Name
        --Info.HeadIconImage = HeadPortraitCfg:GetHeadIcon(AINameCfg.HeadIcon)
    end
    
    if AwardInfo then
        Info.WinAward = AwardInfo.Win
        Info.FailAward = AwardInfo.Lose
        Info.TieAward = AwardInfo.Draw
    end

    return Info
end

---@type 获取真实玩家对手信息
---@param RoleID number 玩家对手ID
---@param StageIndex number 阶段
function MagicCardTourneyVMUtils.GetOpponentInfoByRoleID(RoleID, StageIndex)
    if RoleID == nil or RoleID <= 0 then
        return nil
    end
  
    local Info = {}
    local RoleVM, IsValid = RoleInfoMgr:FindRoleVM(RoleID, true)
    if IsValid then
        Info.Name = _G.LSTR(1150074) --1150074("一个神秘的对手") RoleVM.Name
        Info.RoleID = RoleID
    end

    local AwardInfo = MagicCardTourneyVMUtils.GetMagicCardTourneyScoreAward(StageIndex)
    if AwardInfo then
        Info.WinAward = AwardInfo.Win
        Info.FailAward = AwardInfo.Lose
        Info.TieAward = AwardInfo.Draw
    end

    return Info
end

---@type 获取最大对局数
function MagicCardTourneyVMUtils.GetMaxBattleCount()
    local Cfg = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_TOURNAMENT_BATTLE_COUNT, "Value")  ---1031
    local MaxBattleCount = 20
    if Cfg then
        MaxBattleCount = Cfg[1]
    end
    return MaxBattleCount
end

---@type 获取幻卡大赛对局积分奖励 @（基础分 + 阶段加成分)
---@param CurStageIndex number 阶段
function MagicCardTourneyVMUtils.GetMagicCardTourneyScoreAward(CurStageIndex)
    if CurStageIndex == nil then
        return nil
    end

    -- 胜负基础分
    local ScoreCfg = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_TOURNAMENT_SCORE_AWARD, "Value") --1032
    if ScoreCfg == nil then
        return nil
    end
    -- 阶段加成分
    local ScoreAddCfg = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_TOURNAMENT_STAGE_SCORE_ADD, "Value") --1034
    if ScoreAddCfg == nil then
        return nil
    end

    local AddScore = ScoreAddCfg[CurStageIndex] or 0
    
    local Award = {
        Win = ScoreCfg[1] + AddScore,
        Lose = ScoreCfg[2],
        Draw = ScoreCfg[3],
    }
    return Award
end

---@type 获取阶段效果加成积分
function MagicCardTourneyVMUtils.GetCurEffectAwardScore(CurEffectID)
    local EffectInfo = MagicCardTourneyVMUtils.GetEffectInfoByEffectID(CurEffectID)
    if EffectInfo then
        local Award = {
            Type = EffectInfo.Type,
            Win = EffectInfo.WinScore,
            Lose = EffectInfo.LoseScore,
        }
        return Award
    end
end

---@type 通过后台返回索引获取大赛ID
---@param TourneyIdx 大赛期数
function MagicCardTourneyVMUtils.GetTourneyIDByIndex(TourneyIdx)
    if TourneyIdx == nil then
        return 1
    end
    local NewTourneyID = TourneyIdx + 1 --索引从1开始
    local TourneyList = TourneyCfg:FindAllCfg()
    local TourneyNum = #TourneyList
    NewTourneyID = NewTourneyID > TourneyNum and 1 or NewTourneyID
    return NewTourneyID
end

---@type 获取大赛信息
---@param TourneyID 大赛ID
function MagicCardTourneyVMUtils.GetTourneyDataByID(TourneyID)
    local Cfg = TourneyCfg:FindCfgByKey(TourneyID)
    if Cfg == nil then
        return 
    end
    local TourneyData = 
    {
        Title = Cfg.Title,
        CupName = Cfg.CupName,
        Desc = Cfg.Desc
    }
    return TourneyData
end

---@type 获取预估匹配时间
function MagicCardTourneyVMUtils.GetExpectsTime()
    return MagicCardTourneyVMUtils.GetRobotMatchTime()
end

---@type 获取阶段名
function MagicCardTourneyVMUtils.GetStageNameByIndex(Index)
    return TourneyDefine.StageName[Index] or ""
end

---@type 获取效果信息
function MagicCardTourneyVMUtils.GetEffectInfoByEffectID(EffectID)
    local Cfg = TourneyEffectCfg:FindCfgByKey(EffectID)
    if Cfg == nil then
        return nil
    end
    local StageWinScore = Cfg.StageWinScore > 0 and string.format("<span color=\"#89bd88\">+%s</>", Cfg.StageWinScore) or ""
    local StageLoseScore = Cfg.StageLoseScore > 0 and string.format("<span color=\"#dc5868\">-%s</>", Cfg.StageLoseScore) or ""
    local WinScore = Cfg.WinScore > 0 and string.format("<span color=\"#89bd88\">+%s</>", Cfg.WinScore) or ""
    local LoseScore = Cfg.LoseScore > 0 and string.format("<span color=\"#dc5868\">-%s</>", Cfg.LoseScore) or ""
    local EffectInfo = {}
    EffectInfo.Type = Cfg.Type
    EffectInfo.EffectName = Cfg.Name or "未配置效果名" -- 效果名称
    EffectInfo.Arg = Cfg.Args and Cfg.Args[1] -- 效果参数
    EffectInfo.Arg2 = Cfg.Args and Cfg.Args[2]
    EffectInfo.StageWinScore = StageWinScore  -- 阶段奖励积分
    EffectInfo.StageLoseScore = StageLoseScore --阶段扣除积分
    EffectInfo.WinScore = WinScore --单局奖励积分
    EffectInfo.LoseScore = LoseScore --单局扣除积分
    EffectInfo.Desc = Cfg.Desc or "未添加说明"-- 效果说明
    EffectInfo.RiskLevel = Cfg.RiskLevel or 1 -- 风险等级
    EffectInfo.IconPath = Cfg.IconPath
    return EffectInfo
end

---@type 获取规则信息
function MagicCardTourneyVMUtils.GetRuleInfo(RuleID)
    local Cfg = FantasyCardRuleCfg:FindCfgByKey(RuleID)
    if Cfg == nil then
        return nil
    end
    local RuleInfo = {}
    RuleInfo.RuleName = Cfg.RuleText -- 规则名字
    RuleInfo.RuleDesc = Cfg.RuleDesc -- 规则说明
    return RuleInfo
end

---@type 获取大赛结算奖励
function MagicCardTourneyVMUtils.GetTourneySettlementAward(Score, Rank, TourneyID)
    local AwardList = {}
	-- 排名奖励
    AwardList = MagicCardTourneyVMUtils.GetAwardListByRank(Rank, TourneyID)
    -- 积分奖励
    local ScoreAwardList = MagicCardTourneyVMUtils.GetAwardListByScore(Score)
    local NewAwardListTemp = {}
    for _, AwardList in ipairs(ScoreAwardList) do
        for _, Award in ipairs(AwardList) do
            table.insert(NewAwardListTemp, Award)
        end
    end
    
    if AwardList and NewAwardListTemp then
        local NewAwardList = table.merge_table(AwardList, NewAwardListTemp)
        if NewAwardList and #NewAwardList > 0 then
            for index = #NewAwardList, 1, -1 do
                local Award = NewAwardList[index]
                if Award.ResID == nil or tonumber(Award.ResID) <= 0 then
                    table.remove(NewAwardList, index) -- 去除未配置奖励ID的
                end
            end
        end
    end
	return AwardList
end

---@type 获取排名奖励 废弃
---@param Rank number
function MagicCardTourneyVMUtils.GetAwardByRank(Rank)
	local SearchConditions = string.format("Type=%d and Arg=%d", 
		ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_RANK, Rank)
	local AwardCfg = AwardCfg:FindCfg(SearchConditions)
	if AwardCfg == nil then
		return nil
	end
    local Award = 
    {
        Coin = AwardCfg.Coin,
    }
	return Award
end

---@type 获取排名奖励
---@param Rank number
function MagicCardTourneyVMUtils.GetAwardListByRank(Rank, TourneyID)
    local AwardList = {}
    if Rank and Rank > 0 then
        local Type = ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_RANK
        local SearchConditions = string.format("Type=%d and Arg=%d", Type, Rank)
        local RankAwardCfg = AwardCfg:FindCfg(SearchConditions)
        if RankAwardCfg == nil then
            return AwardList
        end

        if RankAwardCfg.RegularLootID and tonumber(RankAwardCfg.RegularLootID) > 0 then
            -- 普通排名奖励
            local LootMapID = tonumber(RankAwardCfg.RegularLootID) 
            local LootID = MagicCardTourneyVMUtils.GetLootID(LootMapID)
            AwardList = ItemUtil.GetLootItems(LootID) or {}
        elseif RankAwardCfg.LootID then
            -- 特殊奖励
            local ActualTourneyID = TourneyID
            local LootMapID = tonumber(RankAwardCfg.LootID[ActualTourneyID])
            local LootID = MagicCardTourneyVMUtils.GetLootID(LootMapID)
            AwardList = ItemUtil.GetLootItems(LootID) or {}
        end
    end
    return AwardList
end

---@type 获取掉落ID
function MagicCardTourneyVMUtils.GetLootID(LootMapID)
    if LootMapID == nil or LootMapID <= 0 then
        return 0
    end
    local LootMappingCfgItem = LootMappingCfg:FindCfg(string.format("ID = %d", LootMapID))
	if (LootMappingCfgItem == nil) then
		return 0
	end

	return LootMappingCfgItem.Programs[1].ID -- 奖励规定只有一种掉落方案
end

---@type 获取积分能获得的所有奖励
---@param Score number
function MagicCardTourneyVMUtils.GetAwardListByScore(Score)
    local AwardList = {}
    if Score and Score > 0 then
        local ScoreAwardInfo = MagicCardTourneyVMUtils.GetScoreAwardInfo()
        if ScoreAwardInfo then
            for _, ScoreAward in ipairs(ScoreAwardInfo) do
                if Score >= ScoreAward.AwardScore then
                    table.insert(AwardList, ScoreAward.AwardList)
                end
            end
        end
    end
	return AwardList
end

---@type 获取大赛积分奖励信息
function MagicCardTourneyVMUtils.GetScoreAwardInfo()
    local Type = ProtoRes.Game.fantasy_tournament_award_type.FANTASY_TOURNAMENT_AWARD_TYPE_SCORE
	local SearchConditions = string.format("Type == %d", Type)
	local AwardCfgList = AwardCfg:FindAllCfg(SearchConditions)
    if AwardCfgList == nil then
        return
    end
    local ScoreAwardInfo = {}
    
    for _, AwardCfg in ipairs(AwardCfgList) do
        --local AwardID = MagicCardTourneyVMUtils.GetLootID(AwardCfg.RegularLootID)
        local LootMapID = tonumber(AwardCfg.RegularLootID) 
        local LootID = MagicCardTourneyVMUtils.GetLootID(LootMapID)
        local AwardList = ItemUtil.GetLootItems(LootID)
        table.insert(ScoreAwardInfo, {
            AwardScore = AwardCfg.Arg,
            AwardList = AwardList,
        })
        -- table.insert(ScoreAwardInfo, {
        --     AwardScore = AwardCfg.Arg,
        --     ResID = AwardID,
        -- })
    end
    return ScoreAwardInfo
end

function MagicCardTourneyVMUtils.MergeLootList(LootList)
    if LootList == nil then
        return
    end
    local SameLootMap = {}
    local LOOT_TYPE = ProtoCS.LOOT_TYPE
    for k, Loot in pairs(LootList) do
        if Loot.Type == LOOT_TYPE.LOOT_TYPE_ITEM then
            local ItemResID = Loot.Item.ResID
            local ItemValue = Loot.Item.Value
            if SameLootMap[ItemResID] == nil then
                SameLootMap[ItemResID] = Loot
            else
                SameLootMap[ItemResID].Item.Value = ItemValue + SameLootMap[ItemResID].Item.Value
            end
            LootList[k] = nil
        elseif Loot.Type == LOOT_TYPE.LOOT_TYPE_SCORE then 
            local ScoreResID = Loot.Score.ResID
            local ScoreValue = Loot.Score.Value
            if SameLootMap[ScoreResID] == nil then
                SameLootMap[ScoreResID] = Loot
            else
                SameLootMap[ScoreResID].Score.Value = ScoreValue + SameLootMap[ScoreResID].Score.Value
            end
            LootList[k] = nil
        end
    end
    
    for _, MergeLoot in pairs(SameLootMap) do
        table.insert(LootList, MergeLoot)  -- 相同物品合并后的数据
    end
    return LootList
end

---@type 获得弹窗奖励数据
---@param LootList table 后台下发奖励数据
function MagicCardTourneyVMUtils.GetAwardListFromLootList(LootList)
    if LootList == nil then
        return
    end
    local AwardList = {}
    local LOOT_TYPE = ProtoCS.LOOT_TYPE
    for k, Loot in pairs(LootList) do
        if Loot.Type == LOOT_TYPE.LOOT_TYPE_ITEM then 
            table.insert(AwardList, {ResID = Loot.Item.ResID, Num = Loot.Item.Value})
        elseif Loot.Type == LOOT_TYPE.LOOT_TYPE_SCORE then
            local ScoreInfo = {
                ResID = Loot.Score.ResID, 
                Num = Loot.Score.Value,
                PlayAddEffect = Loot.Score.Percent > 0 or nil,
            }
            if ScoreInfo.PlayAddEffect then
                ScoreInfo.OriginalNum = 0  --ScoreInfo.Num / (1 + Loot.Score.Percent)
                ScoreInfo.IncrementedNum = ScoreInfo.Num - ScoreInfo.OriginalNum
            end
            table.insert(AwardList, ScoreInfo)  
        end
    end
    return AwardList
end

---@type 是否要显示效果进度
function MagicCardTourneyVMUtils.IsNeedShowEfectProgress(CurEffectID, IsInResultView)
    local EffectInfo = MagicCardTourneyVMUtils.GetEffectInfoByEffectID(CurEffectID)
    if EffectInfo == nil then
        return false
    end

    local EffectType = EffectInfo.Type
    local WeakenType = ProtoRes.Game.fantasy_tournament_effect_type.FANTASY_TOURNAMENT_EFFECT_TYPE_WEAKEN
    local TimeLimitType = ProtoRes.Game.fantasy_tournament_effect_type.FANTASY_TOURNAMENT_EFFECT_TYPE_TIME_LIMIT
    local BattleFlipType = ProtoRes.Game.fantasy_tournament_effect_type.FANTASY_TOURNAMENT_EFFECT_TYPE_BATTLE_FLIP
    if EffectType == WeakenType then
        return false
    end

    if EffectType == TimeLimitType then
        return false
    end

    if not IsInResultView then
        if EffectType == BattleFlipType then
            return false
        end
    end
    return EffectInfo.Arg and EffectInfo.Arg > 0
end

---@type 获取对局玩家随机位置信息
function MagicCardTourneyVMUtils.GetRandomLocationAndRotationOfPlayers()
    local LocationCfgList = TourneyLocationCfg:FindAllCfg()
    if LocationCfgList == nil then
        return
    end
    local DeskNum = math.random(#LocationCfgList)
    if DeskNum <= 0 then
        return
    end
    return MagicCardTourneyVMUtils.GetLocationAndRotationOfPlayers(DeskNum)
end

---@type 获取对局桌子最大数量
function MagicCardTourneyVMUtils.GetMaxDeskNum()
    local LocationCfgList = TourneyLocationCfg:FindAllCfg()
    if LocationCfgList == nil then
        return 0
    end

    return #LocationCfgList
end

---@type 获取对局玩家位置信息
---@param DeskNum number 桌子编号
function MagicCardTourneyVMUtils.GetLocationAndRotationOfPlayers(DeskNum)
    if DeskNum == nil or DeskNum <= 0 then
        return nil
    end
    local LocationCfg = TourneyLocationCfg:FindCfgByKey(DeskNum)
    if LocationCfg == nil then
        return nil
    end
    
    local LocationInfoList = {}

    local LeftLocationInfo = {}
    
    local RightLocationInfo = {}
    local RightOffset = LocationCfg.RightLocOffset.X
    RightLocationInfo.Rotation = _G.UE.FRotator(0, LocationCfg.DeskRotation.Z, 0)
    RightLocationInfo.Location = _G.UE.FVector(LocationCfg.DeskLocation.X,LocationCfg.DeskLocation.Y, LocationCfg.DeskLocation.Z) + 
    _G.UE.FRotator(0, LocationCfg.DeskRotation.Z, 0):GetForwardVector() * RightOffset
    table.insert(LocationInfoList, RightLocationInfo)
    
    local LeftOffset = LocationCfg.LeftLocOffset.X
    LeftLocationInfo.Location = _G.UE.FVector(LocationCfg.DeskLocation.X, LocationCfg.DeskLocation.Y, LocationCfg.DeskLocation.Z) + 
    _G.UE.FRotator(0, LocationCfg.DeskRotation.Z, 0):GetForwardVector() * LeftOffset
    LeftLocationInfo.Rotation = _G.UE.UKismetMathLibrary.FindLookAtRotation(LeftLocationInfo.Location, RightLocationInfo.Location)
    table.insert(LocationInfoList, LeftLocationInfo)

    return LocationInfoList
end


---@type 获取桌子位置信息
---@param DeskNum number 桌子编号
function MagicCardTourneyVMUtils.GetDeskLocation(DeskNum)
    if DeskNum == nil or DeskNum <= 0 then
        return nil
    end

    local LocationCfg = TourneyLocationCfg:FindCfgByKey(DeskNum)
    if LocationCfg == nil then
        return nil
    end

    local Location = _G.UE.FVector(LocationCfg.DeskLocation.X, LocationCfg.DeskLocation.Y, LocationCfg.DeskLocation.Z)
    return Location
end

---@type 获取对局室ID
function MagicCardTourneyVMUtils.GetTourneyRoomID()
    local RoomIDValues = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASY_CARD_ROOM_ID, "Value") -- 1082
    return RoomIDValues and RoomIDValues[1] or 0
end

---@type 获取对局室信息
function MagicCardTourneyVMUtils.GetMatchRoomInfo()
    local SceneID = MagicCardTourneyVMUtils.GetTourneyRoomID()
    local PWorldCfg = PworldCfg:FindCfgByKey(SceneID)

    if not PWorldCfg then
        _G.FLOG_ERROR(string.format("MagicCardTourneyVMUtils has not Cfg SceneID = %s", tostring(SceneID)))
        return
    end
    local RoomInfo = {}
    RoomInfo.SneceIcon = ""  --副本小ICon
    -- 配置副本表/进入配置表
    local PWECfg = SceneEnterCfg:FindCfgByKey(SceneID)
    if PWECfg then
        RoomInfo.Summary = PWECfg.Summary -- 副本概要
        RoomInfo.Rewards = PWECfg.Rewards -- 奖励物品ID列表
        
        local Type = PWECfg.TypeID
        local PWETCfg = SceneEnterTypeCfg:FindCfgByKey(Type)
        if PWETCfg then
            RoomInfo.SneceIcon = PWETCfg.Icon
        else
            _G.FLOG_ERROR(string.format("PWorldVoteVM:UpdateVM has not SceneEnterTypeCfg SceneID = %s", tostring(SceneID)))
        end
    else
        _G.FLOG_ERROR(string.format("PWorldVoteVM:UpdateVM has not SceneEnterCfg SceneID = %s", tostring(SceneID)))
    end
    RoomInfo.ExistTimeText = PWorldCfg.ExistTime > 0 and PWorldCfg.ExistTime/60 or TourneyDefine.NoExistTimeText --持续时长 分钟
    RoomInfo.SceneBG = PWorldCfg.PWorldBanner  --大背景图
    RoomInfo.SceneName = PWorldCfg.PWorldName  --副本名字
    RoomInfo.SceneLevel = PWorldCfg.PlayerLevel --进入等级
    RoomInfo.SceneLevelDesc = string.format(TourneyDefine.EnterLimitLevelText, RoomInfo.SceneLevel)
    return RoomInfo
end

---@type 获取随机机器人外观信息
function MagicCardTourneyVMUtils.GetRandomRobotAvatarInfo()
    local RobotAvatarValues = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_ROBOT_AVATAR_RANGE, "Value") --1050
    local NPCBaseID, AINameID = 0, 0
    if RobotAvatarValues and #RobotAvatarValues >= 2 then
        NPCBaseID = math.random(tonumber(RobotAvatarValues[1]), tonumber(RobotAvatarValues[2]))
    end

    if RobotAvatarValues and #RobotAvatarValues >= 4 then
        AINameID = math.random(tonumber(RobotAvatarValues[3]), tonumber(RobotAvatarValues[4]))
    end
    
    return NPCBaseID, AINameID
end

---@type 获取机器人对手NPC形象的头像ID
function MagicCardTourneyVMUtils.GetPVPRobotNPCHeadIconPath(NPCID)
    local NPCCfg = NPCCfg:FindCfgByKey(NPCID)
    if NPCCfg == nil then
        return
    end
    local NPCBaseCfg = NPCBaseCfg:FindCfgByKey(NPCCfg.ProfileName)
    if NPCBaseCfg == nil then
        return
    end
    
    local RacePath = TourneyDefine.NPCHeadIconPath[NPCBaseCfg.Customize00]
    local HeadID = RacePath and RacePath[NPCBaseCfg.Customize04]
    if HeadID and HeadID > 0 then
        return HeadPortraitCfg:GetHeadIcon(HeadID)
    end
end

---@type 获取匹配确认时间
function MagicCardTourneyVMUtils.GetCardMatchConfirmTime()
    local ReadyTimeOutValues = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_READY_TIMEOUT, "Value")  --1093
    if ReadyTimeOutValues == nil or #ReadyTimeOutValues < 3 then
        return 10
    end

    return tonumber(ReadyTimeOutValues[3])
end

---@type 获取匹配机器人时间
function MagicCardTourneyVMUtils.GetRobotMatchTime()
    local RobotMatchTimeValues = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_TOURNAMENT_ROBOT_MATCH_TIME, "Value") --1092
    if RobotMatchTimeValues == nil or #RobotMatchTimeValues < 2 then
        return 0
    end
    local Time = tonumber(RobotMatchTimeValues[2]) --取最大值-- math.random(tonumber(RobotMatchTimeValues[1]), tonumber(RobotMatchTimeValues[2]))
    return Time
end

---@type 获取机器人准备时间
function MagicCardTourneyVMUtils.GetRobotReadyTime()
    local RobotReadyTimeValues = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_ROBOT_READY_TIME, "Value") --1092
    if RobotReadyTimeValues == nil or #RobotReadyTimeValues < 2 then
        return 0
    end
    local Time = math.random(tonumber(RobotReadyTimeValues[1]), tonumber(RobotReadyTimeValues[2]))
    return Time
end

---@type 获取机器人出牌延迟时间
function MagicCardTourneyVMUtils.GetRobotMoveDelayTime()
    local RobotReadyTimeValues = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FANTASYCARD_ROBOT_PLAY_TIME, "Value")--1091
    if RobotReadyTimeValues == nil or #RobotReadyTimeValues < 2 then
        return 0
    end
    local Time = math.random(tonumber(RobotReadyTimeValues[1]), tonumber(RobotReadyTimeValues[2]))
    return Time
end

---@type 获取玩家出牌限制时间
function MagicCardTourneyVMUtils.GetPlayerTimeOutForMove(EffectID, IsTournament)
    local TimeOut = 0
    local GCfg = GameGlobalCfg:FindCfgByKey(GLOBAL_CFG_ID.GAME_CFG_PLAYER_TIMEOUT) --1001
    if (GCfg ~= nil and GCfg.Value ~= nil and #GCfg.Value > 0) then
        TimeOut = GCfg.Value[1] * 0.001
    end

    if EffectID == nil or EffectID <= 0 then
        return TimeOut
    end

    local EffectInfo = MagicCardTourneyVMUtils.GetEffectInfoByEffectID(EffectID)
    if EffectInfo == nil then
        return TimeOut
    end

    local Type = ProtoRes.Game.fantasy_tournament_effect_type.FANTASY_TOURNAMENT_EFFECT_TYPE_TIME_LIMIT
    if EffectInfo.Type == Type and IsTournament then
        TimeOut = EffectInfo.Arg
    end

    return  TimeOut
end

---@type 获取金蝶币ID
function MagicCardTourneyVMUtils.GetAwardID()
    local AwardIDs = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_GOLD_SAUCER_Point_ID, "Value") -- 1002
    return AwardIDs and AwardIDs[1] or 0
end

---@type 获取通用提示信息时长
function MagicCardTourneyVMUtils.GetTipDurationByID(SysnoticeID)
	if SysnoticeID == nil or SysnoticeID <= 0 then
		return 0
	end
	local Cfg = SysnoticeCfg:FindCfgByKey(SysnoticeID)
	return Cfg and Cfg.ShowTime or 0
end

return MagicCardTourneyVMUtils
