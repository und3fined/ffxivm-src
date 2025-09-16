---
--- Author: carl
--- DateTime: 2024-01-29 19:01
--- Description:
---
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local EquipCfg = require("TableCfg/EquipmentCfg")
local EmotionCfg = require("TableCfg/EmotionCfg")
local GameWeekCronCfg = require("TableCfg/GameWeekCronCfg")
local SystemLightCfg = require("TableCfg/SystemLightCfg")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local ShowLocationCfg = require("TableCfg/FashioncheckShowLocationCfg")
local FashionThemeCfg = require("TableCfg/FashioncheckThemeCfg")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local FashionThemePartCfg = require("TableCfg/FashioncheckThemepartCfg")
local FashionBarrageRandomLibCfg = require("TableCfg/FashioncheckBarrageRandomLibCfg")
local CameraParamsCfg = require("TableCfg/FashioncheckCameraParamsCfg")
local FashionBarrageCfg = require("TableCfg/FashioncheckBarrageLibCfg")
local FahsionThemePartTextCfg = require("TableCfg/FashioncheckThemeparttextCfg")
local FasshionAwardCfg = require("TableCfg/FashioncheckAwardCfg")
local DefaultEquipCfg = require("TableCfg/FashioncheckDefaultEquipmentCfg")
local FashionCheckNpcCfg = require("TableCfg/FashioncheckNpcCfg")
local FashioncheckPrologueCfg = require("TableCfg/FashioncheckPrologueCfg")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local EEquipPart = ProtoCommon.equip_part
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")


local FashionEvaluationVMUtils = {}
local GLOBAL_CFG_ID = ProtoRes.Game.game_global_cfg_id
local EGameID = ProtoRes.Game.GameID

---@type 获取周最大挑战次数
function FashionEvaluationVMUtils.GetWeekMaxEvaluateTimes()
    local MaxTimesCfg = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FASHION_CHECK_MAX_CHECK_TIMES, "Value") -- 1013
    if MaxTimesCfg then
        return MaxTimesCfg[1]
    end
	return 0
end

---@type 获取部位主题信息
---@param PartThemeID integer
function FashionEvaluationVMUtils.GetPartThemeInfo(PartThemeID)
    local ThemePartCfg = FashionThemePartCfg:FindCfgByKey(PartThemeID)
    if ThemePartCfg == nil then
        return nil
    end

    local PartThemeInfo = {}
    local PartTextID = tonumber(ThemePartCfg.TextCh)
    local ThemePartTextCfg = FahsionThemePartTextCfg:FindCfgByKey(PartTextID)
    if ThemePartTextCfg then
        PartThemeInfo.PartThemeName = ThemePartTextCfg.TextCh -- 部位主题名字
    end

    return PartThemeInfo
end

---@type 获取主题名字
function FashionEvaluationVMUtils.GetThemeName(ThemeID)
    if ThemeID == nil then
        return ""
    end

    local ThemeCfg = FashionThemeCfg:FindCfgByKey(ThemeID)
    if ThemeCfg == nil then
        return ""
    end

    return ThemeCfg.TextCh
end

---@type 是否为时尚庆典
function FashionEvaluationVMUtils.IsFashionCelebration(ThemeID)
    if ThemeID == nil then
        return false
    end

    local ThemeCfg = FashionThemeCfg:FindCfgByKey(ThemeID)
    if ThemeCfg == nil then
        return false
    end

    return ThemeCfg.IsCelebration and ThemeCfg.IsCelebration == 1
end

---@type 获取主题部位列表 顺序 @MasterHand Head Body Arm Leg Feet Ear Neck Wrist RightFinger LeftFinger
---@param PartKey number 主题ID
function FashionEvaluationVMUtils.GetPartThemeList(ThemeID, ViewType)
    local ThemeCfg = FashionThemeCfg:FindCfgByKey(ThemeID)
    if ThemeCfg == nil then
        return
    end

    local ThemePartList = {}
    --按此顺序排序
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_MASTER_HAND, ThemeCfg.MasterHand, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_HEAD, ThemeCfg.Head, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_BODY, ThemeCfg.Body, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_ARM, ThemeCfg.Arm, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_LEG, ThemeCfg.Leg, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_FEET, ThemeCfg.Feet, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_EAR, ThemeCfg.Ear, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_NECK, ThemeCfg.Neck, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_WRIST, ThemeCfg.Wrist, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_RIGHT_FINGER, ThemeCfg.RightFinger, ViewType)
    FashionEvaluationVMUtils.AddThemePart(ThemePartList, EEquipPart.EQUIP_PART_LEFT_FINGER, ThemeCfg.LeftFinger, ViewType)

    return ThemePartList
end

function FashionEvaluationVMUtils.AddThemePart(ThemePartList, PartID, PartThemeID, ViewType)
    local AppearancesMap = FashionEvaluationVMUtils.GetMajorDefaultAppearances()
    local Equip = nil
    if AppearancesMap then
        Equip = AppearancesMap[PartID]
    end

    if FashionEvaluationVMUtils.IsThemePart(PartThemeID) then
        local PartData = {
            Part = PartID,
            PartThemeID = PartThemeID,
            AppearanceID = 0,
            DefaultAppearanceID = Equip and Equip.AppearanceID or 0,
            DefaultEquipID = Equip and Equip.DefaultEquipID,
            ViewType = ViewType,
        }
        table.insert(ThemePartList, PartData)
    end
end

---@type 是否为主题部位 值不为空的为主题部位
---@param PartKey number 部位主题ID
function FashionEvaluationVMUtils.IsThemePart(ThemePartID)
    if ThemePartID == nil then
        return false
    end

    local ThemePartCfg = FashionThemePartCfg:FindCfgByKey(ThemePartID)
    local ThemePartTextID = ThemePartCfg and ThemePartCfg.TextCh
    return ThemePartID and not string.isnilorempty(ThemePartTextID)
end

---@type 获取部位名
---@param PartID number 部位ID
function FashionEvaluationVMUtils.GetPartName(PartID)
    if PartID == nil then
        return ""
    end

    local PartName = FashionEvaluationDefine.EquipPartName[PartID]
    if string.isnilorempty(PartName) then
        return ""
    end
    return PartName
end

 
---@type 获取评分奖励列表
function FashionEvaluationVMUtils.GetEvaluateRewardCoinList(IsCelebration)
    local CoinKey = IsCelebration and GLOBAL_CFG_ID.GAME_CFG_FASHION_CHECK_CELEBRATION_REWARD_COINS --1070
                    or GLOBAL_CFG_ID.GAME_CFG_FASHION_CHECK_REWARD_COINS --1014
    local RewardList = GameGlobalCfg:FindValue(CoinKey, "Value")

	return RewardList
end

---@type 获取装备信息
function FashionEvaluationVMUtils.GetEquipInfo(EquipResID)
    if EquipResID == nil then
        return nil
    end

    local Item = ItemCfg:FindCfgByKey(EquipResID)
    if Item == nil then
        FLOG_ERROR(string.format("时尚品鉴同模装备：%s在物品表中找不到", EquipResID))
        return
    end
    local EquipInfo = {}
    local IconID = tonumber(Item.IconID)
    if IconID and IconID > 0 then
        EquipInfo.EquipIconPath = UIUtil.GetIconPath(IconID)
    end
    EquipInfo.EquipName =  ItemCfg:GetItemName(EquipResID)
    return EquipInfo
end

---@type 获取外观信息
function FashionEvaluationVMUtils.GetAppearanceInfo(AppearanceID)
    if AppearanceID == nil or AppearanceID <= 0 then
        return nil
    end

    local AppItem = ClosetCfg:FindCfgByKey(AppearanceID)
    if AppItem == nil then
        FLOG_ERROR(string.format("外观ID %s在衣橱表中不存在，请检查", AppearanceID))
        return
    end
    local AppInfo = {}
    AppInfo.AppIconPath = WardrobeUtil.GetEquipmentAppearanceIcon(AppearanceID)
    AppInfo.AppearanceName = WardrobeUtil.GetEquipmentAppearanceName(AppearanceID)
    if string.isnilorempty(AppInfo.AppearanceName) then
        FLOG_WARNING(string.format("时尚品鉴外观名字找不到：%s", AppearanceID))
    end
    if string.isnilorempty(AppInfo.AppIconPath) then
        FLOG_WARNING(string.format("时尚品鉴外观ICon找不到：%s", AppearanceID))
    end
    return AppInfo
end

---@type 获取同外观的装备列表
---@return table 返回同模装备列表
function FashionEvaluationVMUtils.GetSameAppearanceEquipmentList(AppearanceID)
    if AppearanceID == nil or AppearanceID <= 0 then
        return
    end
    local Ret = {}
    local EquipmentCfgs = EquipCfg:FindAllCfgByAppearanceID(AppearanceID)
    for _, v in ipairs(EquipmentCfgs) do
        local ID = WardrobeUtil.GetIsSpecial(AppearanceID) and (v.ID + WardrobeDefine.SpecialShiftID) or v.ID
        table.insert(Ret, ID)
    end

    return Ret
end

---@param InPart ProtoCommon.equip_part
function FashionEvaluationVMUtils.GetPartIcon(InPart)
	-- return string.format("Texture2D'/Game/UI/Texture/Role/%s.%s'", UIName, UIName)
	local UIName = string.format("UI_FashionEvaluation_Icon_%s_png", FashionEvaluationDefine.PartIconMap[InPart])
	return string.format("PaperSprite'/Game/UI/Atlas/FashionEvaluation/Frames/%s.%s'", UIName, UIName)
end

---@type 获取外观的唯一值 因为多个地方公用
function FashionEvaluationVMUtils.GetAppearanceKey(ViewType, SubType, Part, Appearance)
    if SubType == nil then
        return tonumber(ViewType..Part..Appearance) or 0
    else
        return tonumber(ViewType..SubType..Part..Appearance) or 0
    end
end

---@type 获取指定部位的装备列表
---@param PartID ProtoCommon.equip_part
---@return table 返回指定部位的外观列表
function FashionEvaluationVMUtils.GetAppearanceListByPartID(PartID)
    if PartID == nil then
        return
    end
    local TimeUtil = require("Utils/TimeUtil")
    local AppList = EquipCfg:FindAllAppearanceIDByPart(PartID)
    local AppearanceCfgs = {}
    local ServerTime = TimeUtil.GetServerLogicTime()
	for _, cfg in ipairs(AppList) do
		local Cfg = ClosetCfg:FindCfgByKey(cfg.AppearanceID)
		if Cfg ~= nil then
            if Cfg.UpTime == ""  then
			    table.insert(AppearanceCfgs, Cfg)
            else
                local AppTime = TimeUtil.GetTimeFromString(Cfg.UpTime)
				if  ServerTime >= AppTime and AppTime > 0 then
                    table.insert(AppearanceCfgs, Cfg)
				end
            end
		end
	end
    
    local AppearanceList = {}
    for _, Appearance in ipairs(AppearanceCfgs) do
        if Appearance.ID ~= 0 and not table.contain(AppearanceList, Appearance.ID) then
            table.insert(AppearanceList, Appearance.ID)
        end
    end

    return AppearanceList
end

---@type 获取衣橱外观对应的装备ID
function FashionEvaluationVMUtils.GetEquipIDByAppearanceID(AppearanceID)
    if AppearanceID == nil or AppearanceID <= 0 then
        return
    end

    local Cfg = ClosetCfg:FindCfgByKey(AppearanceID)
	if Cfg == nil then
        FLOG_ERROR(string.format("外观ID %s在衣橱表中不存在，请检查!", AppearanceID))
		return
	end

    return Cfg.EquipID
end

---@type 获取装备ID对应的外观ID
function FashionEvaluationVMUtils.GetAppearanceIDByEquipID(EquipID)
    local EquipmentCfg = EquipCfg:FindCfgByKey(EquipID)
	if EquipmentCfg == nil then
		return
	end

    return EquipmentCfg.AppearanceID
end

---@type 获取最大装备追踪数量
function FashionEvaluationVMUtils.GetMaxTrackNum()
    local MaxTrackNumCfg = GameGlobalCfg:FindValue(ProtoRes.client_global_cfg_id.GLOBAL_CFG_FASHION_CHECK_MAX_TRACK, "Value")
    if MaxTrackNumCfg then
        return tonumber(MaxTrackNumCfg[1])
    end
	return 10
end

---@type 获取玩家分数背景
function FashionEvaluationVMUtils.GetPlayerScoreBG(Score)
    local AwardCondList = FashionEvaluationVMUtils.GetAwardConditionList()
    if AwardCondList == nil then
        return
    end
    for index = #AwardCondList, 1, -1 do
        local AwardCond = AwardCondList[index]
        if Score >= AwardCond.TargetScore then
            return FashionEvaluationDefine.PlayerScoreBG[index]
        end
    end
end

---@type 获取NPC分数背景
function FashionEvaluationVMUtils.GetNPCcoreBG(Score)
    local AwardCondList = FashionEvaluationVMUtils.GetAwardConditionList()
    if AwardCondList == nil then
        return
    end
    for index = #AwardCondList, 1, -1 do
        local AwardCond = AwardCondList[index]
        if Score >= AwardCond.TargetScore then
            return FashionEvaluationDefine.NPCScoreBG[index]
        end
    end
end

---@type 获取LCut资源ID
function FashionEvaluationVMUtils.GetLCutSequence(Score)
    local LCutSeqGroupList = FashionEvaluationDefine.LCutSequenceList
    if LCutSeqGroupList == nil then
        return
    end

    local ScoreLevel = FashionEvaluationVMUtils.GetScoreLevelForAnim(Score)
    if ScoreLevel and ScoreLevel > 0 then
        local SequenceList = LCutSeqGroupList[ScoreLevel]
        if SequenceList then
            local Length = #SequenceList
            local RandomIndex = math.random(Length)
            return SequenceList[RandomIndex]
        end
    end
end

---@type 获取NPC头像
function FashionEvaluationVMUtils.GetNPCHeadIcon(NpcResID)
    local NpcCfg = FashionCheckNpcCfg:FindCfg(string.format("NPCID = %d", NpcResID))
    return NpcCfg and NpcCfg.HeadIconImage or ""
end

---@type 奖励目标是否达成
function FashionEvaluationVMUtils.IsGetProgress(AwardIndex, Score, WeekRemainTimes)
    local MaxTimes = FashionEvaluationVMUtils.GetWeekMaxEvaluateTimes()
    local AwardCondList = FashionEvaluationVMUtils.GetAwardConditionList()
    local AwardCond = AwardCondList and AwardCondList[AwardIndex]
    if AwardCond == nil then
        return false
    end

    if AwardCond.TargetScore <= 0 then
        return WeekRemainTimes < MaxTimes --参与过挑战
    end
    return Score >= AwardCond.TargetScore
end

---@type 奖励目标达成数量
function FashionEvaluationVMUtils.GetProgressNum(Score, WeekRemainTimes)
    local GetNum = 0
    for index = 1, 4 do
        if FashionEvaluationVMUtils.IsGetProgress(index, Score, WeekRemainTimes) then
            GetNum = GetNum + 1
        end
    end
    return GetNum
end

---@type 奖励目标达成条件列表
function FashionEvaluationVMUtils.GetAwardConditionList()
    local AwardCfgList = FasshionAwardCfg:FindAllCfg()
    if AwardCfgList == nil then
        return
    end
    local ConditionList = {}
    for Index, AwardCfg in ipairs(AwardCfgList) do
        local CondContent = FashionEvaluationDefine.AwardConditionContent[Index] or ""  --AwardCfg.Content
        local NewContent = CondContent
        if not string.isnilorempty(CondContent) and AwardCfg.Score and AwardCfg.Score > 0 then
            NewContent = string.format(CondContent, AwardCfg.Score) -- "达到%s分"
        end
        table.insert(ConditionList, {
            TargetScore = AwardCfg.Score,
            Coins = AwardCfg.Coins,
            CelebrationCoins = AwardCfg.CelebrationCoins,
            Content = NewContent
        })
    end
    return ConditionList
end

function FashionEvaluationVMUtils.GetAwardList(WeekHighestScore, WeekRemainTimes)
    local AwardList = FashionEvaluationVMUtils.GetAwardConditionList()
    if AwardList == nil then
        return
    end
    local ProgressAwardList = {}
    for index, Award in ipairs(AwardList) do
        local ProgressAward = {}
        ProgressAward.UnLockAwardIndex = index
        ProgressAward.ProgressName = Award.Content
        ProgressAward.AwardID = FashionEvaluationVMUtils.GetAwardID()
        ProgressAward.AwardNum = Award.Coins
        ProgressAward.IsGetProgress = FashionEvaluationVMUtils.IsGetProgress(index, WeekHighestScore, WeekRemainTimes)
        ProgressAward.IsNewGet = false
        table.insert(ProgressAwardList, ProgressAward)
    end
    return ProgressAwardList
end

---@type 获取弹幕间隔时间
function FashionEvaluationVMUtils.GetCommentInternal(Score)
    if Score == nil then
        return 1
    end
    local AwardCondList = FashionEvaluationVMUtils.GetAwardConditionList()
    if AwardCondList == nil then
        return 1
    end
    for index = #AwardCondList, 1, -1 do
        local AwardCond = AwardCondList[index]
        if Score >= AwardCond.TargetScore then
            return FashionEvaluationDefine.CommentInternal[index]
        end
    end
end

---@type 获取随机弹幕内容
function FashionEvaluationVMUtils.GetComment(IsMatchTheme)
    local BarrageRandomID = IsMatchTheme and 1 or 2 -- 1:--褒义库, 2:--贬义库
    local BarrageCfg = FashionBarrageRandomLibCfg:FindCfgByKey(BarrageRandomID)
    if BarrageCfg == nil then
        return
    end

    local BarrageList = BarrageCfg.Barrage
    if BarrageList == nil then
        return
    end

    local Length = #BarrageList
    if Length <= 0 then
        return
    end

    local RandomBarrageIndex = math.random(Length)
    local BarrageID = BarrageList[RandomBarrageIndex]
    local BarrageLibCfg = FashionBarrageCfg:FindCfgByKey(BarrageID)
    if BarrageLibCfg == nil then
        return
    end
    return BarrageLibCfg.NPCIdex, BarrageLibCfg.Content
end

---@type 获取摄像机配置
---@param AttachType string SkeletonName 骨骼模型名
---@param Index number 界面镜头索引
function FashionEvaluationVMUtils.GetCameraControlParams(FashionView, AttachType)
    local CameraParams = {}
    local CameraCfg = nil
    if string.isnilorempty(AttachType) then
        if FashionView == FashionEvaluationDefine.EFashionView.Main then
            CameraCfg = CameraParamsCfg:FindCfgByKey(1)
        end
    else
        CameraCfg = CameraParamsCfg:FindCfg(string.format("SkeletonName = \"%s\"", AttachType))
    end

    if CameraCfg then
        local CameraIndex = FashionEvaluationDefine.CameraIndexMap[FashionView]
        CameraParams.Distance = CameraCfg.ViewDistanceList[CameraIndex]
        CameraParams.Offset = CameraCfg.OffsetList[CameraIndex]
        local Rot = CameraCfg.RotationList[CameraIndex]
        CameraParams.Rotation = FashionEvaluationVMUtils.ConvertVectorToRotator(Rot)
        CameraParams.FOV = CameraCfg.FOVList[CameraIndex]
    end

    return CameraParams
end

function FashionEvaluationVMUtils.ConvertVectorToRotator(TargetVector)
    local Rotation = {
        X = TargetVector.Y, 
        Y = TargetVector.Z,
        Z = TargetVector.X,
    }
    return Rotation
end

---@type 获取NPC时尚达人信息
function FashionEvaluationVMUtils.GetNPCInfos()
    local NPCCfgs = FashionCheckNpcCfg:FindAllCfg()
    if NPCCfgs == nil then
        return
    end
    local NpcInfoList = {}
    for _, NPCInfo in ipairs(NPCCfgs) do
        local NpcID = NPCInfo.NPCID
        local Location = NPCInfo.Location
        local Rotation = NPCInfo.Rotation
        local NewLocation = _G.UE.FVector(Location.X, Location.Y, Location.Z)
        local NewRotation = _G.UE.FRotator(Rotation.X, Rotation.Y, Rotation.Z)
        table.insert(NpcInfoList, {NPCID = NpcID, Location = NewLocation, Rotation = NewRotation})
    end
    return NpcInfoList
end

---@type 获取玩家默认装备
function FashionEvaluationVMUtils.GetMajorDefaultAppearances()
    local EquipCfgs = DefaultEquipCfg:FindAllCfg() --专门为时尚品鉴配置的默认装备表
    if EquipCfgs == nil then
        return
    end

    local Equips = {}
    for _, Equip in ipairs(EquipCfgs) do
        Equips[Equip.Part] = {Part = Equip.Part, AppearanceID = Equip.AppearanceID, DefaultEquipID = 0}
        if Equip.AppearanceID == nil or Equip.AppearanceID <= 0 then
            local EquipedItem = _G.EquipmentMgr:GetEquipedItemByPart(Equip.Part)
            --如果当前部位有装备，则装上
            local EquipID = EquipedItem and EquipedItem.ResID
            if EquipID and EquipID > 0 then
                Equips[Equip.Part].DefaultEquipID = EquipID
            end
        end
    end
    return Equips
end

---@type 玩家参与品鉴前实际穿在身上的对应部位装备
function FashionEvaluationVMUtils.GetMajorActualEquips(PreviewAppearanceList)
    if PreviewAppearanceList == nil or table.length(PreviewAppearanceList) <= 0 then
        return
    end

    local Equips = {}
    for Part, Appearance in pairs(PreviewAppearanceList) do
        if Appearance.AppearanceID > 0 then
            Equips[Part] = {Part = Part, AppearanceID = 0, DefaultEquipID = 0}
            local EquipedItem = _G.EquipmentMgr:GetEquipedItemByPart(Part)
            --如果当前部位有装备，则装上
            local EquipID = EquipedItem and EquipedItem.ResID
            if EquipID and EquipID > 0 then
                Equips[Part].DefaultEquipID = EquipID
            end
        end
    end
    return Equips
end

---@type 获取动作分数档次
---@param Score number 分数
function FashionEvaluationVMUtils.GetScoreLevelForAnim(Score)
    local ScoreLevels = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FASHION_CHECK_ACTION_LEVELS, "Value") -- 1085
    if ScoreLevels then
        for i = #ScoreLevels, 1, -1 do
            local MinScore = ScoreLevels[i]
            if Score >= MinScore then
                return i
            end
        end
    end
    return 1
end

---@type 获取样式分数档次
---@param Score number 分数
function FashionEvaluationVMUtils.GetScoreLevelForUIType(Score)
    local ScoreLevels = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_FASHION_CHECK_SCORE_LEVELS, "Value") -- 1086
    if ScoreLevels then
        for i = #ScoreLevels, 1, -1 do
            local MinScore = ScoreLevels[i]
            if Score >= MinScore then
                return i
            end
        end
    end
    return 1
end

---@type 获取积分规则
---@param Score number 分数
function FashionEvaluationVMUtils.GetScoreRuleInfo()
    local ScoreRule = {}
    ScoreRule.BaseScore = 10
    ScoreRule.MatchScore = 15
    ScoreRule.SuperMatchScore = 0
    ScoreRule.OwnScore = 5
    return ScoreRule
end

---@type 获取情感动作路径
---@param Score number 分数
function FashionEvaluationVMUtils.GetAnimPathByScore(Score, Actor)
    local EmoID = FashionEvaluationVMUtils.GetEmotionIDByScore(Score)
    if EmoID == nil then
        return
    end
    local EmotionCfg = EmotionCfg:FindCfgByKey(EmoID)
    if EmotionCfg == nil then
        return
    end

    local AnimPath = EmotionAnimUtils.GetActorEmotionAnimPath(
        EmotionCfg.AnimPath,
        Actor,
        EmotionDefines.AnimType.EMOT
    )
    
    return AnimPath
end

---@type 获取情感动作ID
---@param Score number 分数
function FashionEvaluationVMUtils.GetEmotionIDByScore(Score)
    local Level = FashionEvaluationVMUtils.GetScoreLevelForAnim(Score)
    if Level == nil or Level <= 0 then
        return
    end
    local EmotionIDList = ClientGlobalCfg:FindValue(ProtoRes.client_global_cfg_id.GLOBAL_CFG_FASHION_CHECK_ANIM, "Value")
    if EmotionIDList == nil then
        return
    end

    local EmoID = EmotionIDList[Level]
    return EmoID
end

---@type 获取时尚品鉴奖励金蝶币ID
function FashionEvaluationVMUtils.GetAwardID()
    local AwardIDs = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_GOLD_SAUCER_Point_ID, "Value") -- 1002
    return AwardIDs and AwardIDs[1] or 0
end

---@type 获取指定界面展示站位
function FashionEvaluationVMUtils.GetShowLocationAndRotation(EFashionView)
    local LocCfg = ShowLocationCfg:FindCfg(string.format("ViewID = %d", EFashionView))
    if LocCfg == nil then
        return
    end
    local Location = LocCfg.Location
    local Rotation = LocCfg.Rotation
    local NewLocation = _G.UE.FVector(Location.X, Location.Y, Location.Z)
    local NewRotation = _G.UE.FRotator(Rotation.X, Rotation.Y, Rotation.Z)
    return NewLocation, NewRotation
end

---@type 获取时尚品鉴剩余时间
function FashionEvaluationVMUtils:GetRemainSecondTime()
    local Cfg = GameWeekCronCfg:FindCfgByKey(EGameID.GameIDFashionCheck)
    if Cfg == nil then
        return
    end
  
    -- local ServerTime = TimeUtil.GetServerTimeFormat("%H:%M:%S")
    -- if self:CheckIsInJumbArea(MajorUtil.GetMajorEntityID()) then
    --     FLOG_INFO("ServerTime = %s", ServerTime)
    -- end

    local ServerTime = TimeUtil.GetServerTime()
    local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
    local LocalServeTime = ServerTime + (DateTimeTools.GetTimeZone() - ServerZone) * 3600
	local TmTime = os.date("*t",LocalServeTime)
    local CurWeekday = TmTime.wday - 1  -- 表示周几
    local CurDaySec = TimeUtil.GetGameDayTimeSinceServerTime()
    local CurWeekSec = (CurWeekday - 1) * 86400 + CurDaySec
    local NeedWeek = Cfg.Week == 0 and 7 or Cfg.Week -- 0的时候表示的是周天
    local NeedMin = Cfg.Minute == nil and 0 or Cfg.Minute
    local NeedSec = Cfg.Second == nil and 0 or Cfg.Second
    local OneWeekLotterySec = 86400 * (NeedWeek - 1) + 3600 * Cfg.Hour + 60 * NeedMin + NeedSec -- 开奖时间对应在该周的秒数
    -- local OneWeekLotterySec = 86400 * 5 + 3600 * 21
    local RemainTime
    if CurWeekSec <= OneWeekLotterySec then
        RemainTime = OneWeekLotterySec - CurWeekSec
    else
        local OneWeekSec = 86400 * 7
        RemainTime = OneWeekSec - CurWeekSec + OneWeekLotterySec
    end
    return RemainTime
end

---@type 获取开场白信息
function FashionEvaluationVMUtils.GetPrologueInfo(ID)
    local Info = {}
    local PrologueCfg = FashioncheckPrologueCfg:FindCfgByKey(ID)
    Info.MaxPrologueNum = #(FashioncheckPrologueCfg:FindAllCfg())
    if PrologueCfg then
        Info.Prologue = {
            AnimIcon = PrologueCfg.AnimIcon,
            Content = FashionEvaluationDefine.PrologueContent[ID], --PrologueCfg.Content,
            Duration = PrologueCfg.Duration, 
        }
    end

    return Info
end

---@type 获取打分表现信息
function FashionEvaluationVMUtils.GetScorePerformInfo(Score)
    local AwardCondList = FashionEvaluationVMUtils.GetAwardConditionList()
    if AwardCondList == nil then
        return
    end
    for index = #AwardCondList, 1, -1 do
        local AwardCond = AwardCondList[index]
        if Score >= AwardCond.TargetScore then
            local PerformInfo = {
                CommentInternal = AwardCond.CommentInternal or 1,
                ScoreEffectSpeedScale = AwardCond.ScoreEffectSpeedScale or 1,
                ScoreDurationStageOne = AwardCond.ScoreDurationStageOne or 1,
                ScoreDurationStageTwo = AwardCond.ScoreDurationStageTwo or 1
            }
            return PerformInfo
        end
    end
end

---@type 获取灯光预设
function FashionEvaluationVMUtils.GetLightPresetPath()
    local SystemID = 14
    local SystemLightCfgItem = SystemLightCfg:FindCfgByKey(SystemID)
    if SystemLightCfgItem then
        local PathList = SystemLightCfgItem.LightPresetPaths
        return PathList and PathList[1] or ""
    end
    return ""
end

return FashionEvaluationVMUtils
