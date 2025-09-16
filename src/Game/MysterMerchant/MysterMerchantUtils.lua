---
--- Author: Carl
--- DateTime: 2024-05-10 19:01
--- Description:
---
local GlobalCfg = require("TableCfg/GlobalCfg")
local GoodsCfg = require("TableCfg/MysteryMerchantGoodsCfgCfg")
local GoodsGroupCfg = require("TableCfg/MysteryMerchantGoodsGroupCfgCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCS = require("Protocol/ProtoCS")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local MerchantCfg = require("TableCfg/MysteryMerchantCfgCfg")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local MerchantTaskCfg = require("TableCfg/MysteryMerchantTaskCfgCfg")
local FriendlyExpCfg = require("TableCfg/MysteryMerchantFriendlyExpCfgCfg")
local MerchantMapPointCfg = require("TableCfg/MysteryMerchantMapPointCfgCfg")
local ExclusiveRefreshCfgCfg = require("TableCfg/MysteryMerchantExclusiveRefreshCfgCfg")
local MerchantDialogCfg = require("TableCfg/MysteryMerchantDialogCfgCfg")
local MysterMerchantDefine = require("Game/MysterMerchant/MysterMerchantDefine")
local ProtoRes = require("Protocol/ProtoRes")
local GLOBAL_CFG_ID = ProtoRes.Game.game_global_cfg_id
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local LSTR = _G.LSTR
local MERCHANT = ProtoCS.Game.MysteryMerchant
local MERCHANT_TASK_STATUS = MERCHANT.MERCHANT_TASK_STATUS
local MERCHANT_INVEST_STATUS = MERCHANT.INVEST_MERCHANT_STATUS
local EBubbleType = MysterMerchantDefine.EBubbleType
local EATLType = MysterMerchantDefine.EATLType
local MysterMerchantUtils = {}


---@type 获取货物拾取交互ID
function MysterMerchantUtils.GetInteractID()
    local AwardIDs = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_MERCHANT_INTERACTION_ID, "Value") -- 1002
    return AwardIDs and AwardIDs[1] or 0
end

---@type 获取友好度等级信息
---@param FriendlinessEXP number 累计总经验
function MysterMerchantUtils.GetFriendlinessLevelInfo(FriendlinessEXP)
	if FriendlinessEXP == nil or FriendlinessEXP < 0 then
		return
	end
	
    local FriendlinessLevelCfgs = FriendlyExpCfg:FindAllCfg()
	if FriendlinessLevelCfgs == nil then
		return
	end
	
	local MaxLevel = #FriendlinessLevelCfgs
	local CurLevel = 1
    local CurLevelLeftExp = 0
	local NextLevelRequiredExp = 0
	local AccumulationExp = 0

	for index, LevelCfg in ipairs(FriendlinessLevelCfgs) do
		if LevelCfg.NextExp > 0 then
			AccumulationExp = AccumulationExp + LevelCfg.NextExp
			if AccumulationExp > FriendlinessEXP then
				CurLevel = index
				math.clamp(CurLevel, 1, MaxLevel)
				CurLevelLeftExp = FriendlinessEXP - (AccumulationExp - LevelCfg.NextExp) 
				NextLevelRequiredExp = LevelCfg.NextExp or 0
				break
			end
		end
	end

	local LevelInfo = {
		Level = CurLevel,
		LevelMax = MaxLevel, -- 最大等级
		LevelLeftExp = CurLevelLeftExp, -- 当前等级剩余经验
		ExpMax = AccumulationExp,
		NextLevelRequiredExp = NextLevelRequiredExp, -- 升到下一级所需经验
		IsGetMaxLevel = false, -- 是否达到最大等级
	}

	if LevelInfo.ExpMax <= FriendlinessEXP then
		LevelInfo.Level = MaxLevel
		LevelInfo.LevelLeftExp = 0
		LevelInfo.IsGetMaxLevel = true
	end
	return LevelInfo
end

---@type 获取解锁商品列表
function MysterMerchantUtils.GetUnlockGoodsList(Level)
	local FriendlinessLevelCfg = FriendlyExpCfg:FindCfgByKey(Level)
	if FriendlinessLevelCfg == nil then
		return
	end
	local UnlockGoodsList = {}
	local UnlockStr = FriendlinessLevelCfg.UnlockGoods
    local UnlockGoodsGroupList = string.split(UnlockStr, ",") -- 解锁商品组ID列表
	if UnlockGoodsGroupList and table.length(UnlockGoodsGroupList) > 0 then
		for _, GroupID in ipairs(UnlockGoodsGroupList) do
			local GoodsGroupCfg = GoodsGroupCfg:FindCfgByKey(tonumber(GroupID))
			local GoodsInfoList = GoodsGroupCfg and GoodsGroupCfg.Goods
			if GoodsInfoList then
				for _, GoodsInfo in ipairs(GoodsInfoList) do
					local GoodsID = GoodsInfo and GoodsInfo.GoodsID or 0
					if GoodsID > 0 then
						table.insert(UnlockGoodsList, GoodsID)
					end
				end
			end
		end
	end
    return UnlockGoodsList
end

---@type 获取任务所需物品
function MysterMerchantUtils.GetRequiredItemList(TaskID)
	local MerchantTaskCfg = MerchantTaskCfg:FindCfgByKey(TaskID)
	if MerchantTaskCfg == nil then
		return
	end
	local ResID = MerchantTaskCfg.FallItemID
	local RequiredItemList = {
		ResID
	}
    local RequiredItemNumList = {
		MerchantTaskCfg.FinishNum
	}
    return RequiredItemList, RequiredItemNumList
end

---@type 获取商品信息
function MysterMerchantUtils.GetGoodsInfo(GoodsID)
	local GoodsCfg = GoodsCfg:FindCfgByKey(GoodsID)
	if GoodsCfg == nil then
		FLOG_ERROR("[MysterMerchantUtils.GetGoodsInfo]商品ID不存在")
		return
	end
	local GoodsInfo = {}
	GoodsInfo.FirstType = 0--GoodsCfg.FirstType
	GoodsInfo.Discount = GoodsCfg.Discount
	GoodsInfo.DiscountDurationStart = 0 --GoodsCfg.DiscountDurationStart
	GoodsInfo.DiscountDurationEnd = 0 --GoodsCfg.DiscountDurationEnd
	GoodsInfo.ItemID = GoodsCfg.Item.ID
	GoodsInfo.Price = {ID = SCORE_TYPE.SCORE_TYPE_GOLD_CODE, Count = GoodsCfg.PriceCount}
	GoodsInfo.PurchaseConditions = {} --GoodsCfg.PurchaseConditions
	GoodsInfo.ItemInfo = ItemCfg:FindCfgByKey(GoodsInfo.ItemID)
	GoodsInfo.RestrictionType = GoodsCfg.RestrictionType --限购类型
	GoodsInfo.LimitNum = GoodsCfg.RestrictionCount --限购数量

	return GoodsInfo
end

--- 商品是否可使用
---@param GoodsId number @商品id
---@return boolean @是否可使用
function MysterMerchantUtils.IsCanUse(GoodsId)
    local TmpGoodsCfg = GoodsCfg:FindCfgByKey(GoodsId)
    return TmpGoodsCfg ~= nil
end

---@type 获取任务信息
---@param TaskID 任务ID
function MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
	local MerchantTaskCfg = MerchantTaskCfg:FindCfgByKey(TaskID)
	if MerchantTaskCfg == nil then
		return
	end
	local TaskInfo = {
		TaskRadius = MerchantTaskCfg.ClientAwakenDistance, --任务（触发与提示，显示任务情报栏）半径
		EscapeDistance = MerchantTaskCfg.EscapeDistance, -- 脱战距离（移除加成状态与隐藏任务情报栏）
		AskForHelpDistance = MerchantTaskCfg.AskForHelpDistance, -- 喊话距离
		TaskHeight = MerchantTaskCfg.ClientAwakenHeight or 500, --任务触发高度，运输陆行鸟中不会触发
		TaskType = MerchantTaskCfg.InteractiveType, --任务类型
		ResID = MerchantTaskCfg.MonsterResID, --怪物或者拾取物品ID
		FinishNum = MerchantTaskCfg.FinishNum, -- 任务达成数量
		VisualNum = MerchantTaskCfg.VisualNum, -- 场上交互物或怪物数量
		OverWeightNum = MerchantTaskCfg.InteractivesNum or 0, --拾取货物超重数量
		TaskID = TaskID,
		ResPointList = MerchantTaskCfg.ResPoint,
		AddExp = MerchantTaskCfg.FriendlyExp, --获得经验
		NPCListID = MerchantTaskCfg.NPCListID,
		SceneResID = MerchantTaskCfg.SceneResID, --位面副本ID
		DefaultDialogID = MerchantTaskCfg.DefaultDialogID, -- 未完成任务默认对话ID
		MonsterGroupListID = MerchantTaskCfg.MonsterGroupListID, -- 位面外怪物组ID
	}

    return TaskInfo
end

---@type 获取任务ID
---@param PWorldResID 副本ID
---@param MapResID 地图ID
function MysterMerchantUtils.GetTaskIDByPworldID(PWorldResID, MapResID)
	if PWorldResID == nil or MapResID == nil then
		return
	end
	local SearchConditions = string.format("SceneResID=%d and MapResID=%d", 
	PWorldResID, MapResID)
	local MerchantTaskCfg = MerchantTaskCfg:FindCfg(SearchConditions)
	return MerchantTaskCfg and MerchantTaskCfg.TaskID or 0
end

---@type 获取对话信息
---@param TaskID 任务ID
function MysterMerchantUtils.GetMerchantDialogInfo(NPCID, FriendlinessLevel, InMerchantID)
    if FriendlinessLevel == nil then
		return
	end

	local MerchantID = InMerchantID
	if MerchantID == nil or MerchantID <= 0 then
		if NPCID and NPCID > 0 then
			local MerchantCfg = MerchantCfg:FindCfg(string.format("NpcID=%d", NPCID))
			MerchantID = MerchantCfg and MerchantCfg.ID or 0
		end
	end

	local SearchConditions = string.format("MerchantID=%d and FriendlyLevel=%d", 
	MerchantID, FriendlinessLevel)
	local MerchantDialogCfg = MerchantDialogCfg:FindCfg(SearchConditions)
	if MerchantDialogCfg == nil then
		return
	end

	local DialogInfo = {
		DialogID = MerchantDialogCfg.DialogID, -- 默认对白ID
		FinishedDialogID = MerchantDialogCfg.FinishedDialogID, -- 任务完成对白ID(交谈选项触发)
		InvestDialogID = MerchantDialogCfg.InvestDialogID, -- 投资选项对话ID
		InvestRewardDialogID = MerchantDialogCfg.InvestRewardDialogID, -- 投资回报对话ID
	}

    return DialogInfo
end

---@type 是否神秘商人
function MysterMerchantUtils.IsMysterMerchant(NPCResID)
    if NPCResID == nil or NPCResID <= 0 then
		return false
	end

	local SearchConditions = string.format("NpcID=%d", NPCResID)
	local MerchantCfg = MerchantCfg:FindCfg(SearchConditions)
	return	MerchantCfg ~= nil
end

---@type 商人类型
function MysterMerchantUtils.GetMerchantType(MerchantID)
    local MerchantCfg = MerchantCfg:FindCfgByKey(MerchantID)
	if MerchantCfg == nil then
		return
	end
	return MerchantCfg.MerchantType
end

---@type 商人NPCID
function MysterMerchantUtils.GetMerchantResID(MerchantID)
	local MerchantCfg = MerchantCfg:FindCfgByKey(MerchantID)
	if MerchantCfg == nil then
		return 0
	end
	return MerchantCfg.NpcID
end

---@type 商人信息
function MysterMerchantUtils.GetMerchantInfoByID(MerchantID)
	local MerchantCfg = MerchantCfg:FindCfgByKey(MerchantID)
	if MerchantCfg == nil then
		return
	end
	local MerchantInfo = {
		MerchantType = MerchantCfg.MerchantType,
		NPCID = MerchantCfg.NpcID,
		DefaultBubbleID = MerchantCfg.DefaultBubbleID,
		FinishBubbleID = MerchantCfg.FinishBubbleID,
	}
	return MerchantInfo
end

---@type 气泡ID
function MysterMerchantUtils.GetMerchantBubbleID(MerchantID, BubbleType)
    if MerchantID == nil then
		return 
	end

	local MerchantCfg = MerchantCfg:FindCfgByKey(MerchantID)
	if MerchantCfg == nil then
		FLOG_WARNING("神秘商人ID不存在:"..MerchantID)
		return
	end

	if BubbleType == EBubbleType.Default then
		return MerchantCfg.DefaultBubbleID
	elseif BubbleType == EBubbleType.FinishTask then
		return MerchantCfg.FinishBubbleID
	elseif BubbleType == EBubbleType.Shop then
		return MerchantCfg.ShopBubbleID
	end
	
	return 0
end

---@type ActionTimelineID
function MysterMerchantUtils.GetMerchantATLID(MerchantID, TaskID, ATLType)
    if TaskID == nil then
		return 
	end

	local TaskCfg = MerchantTaskCfg:FindCfgByKey(TaskID)
	if TaskCfg == nil then
		FLOG_WARNING("商人任务ID不存在:"..TaskID)
	end

	local MerchantCfg = MerchantCfg:FindCfgByKey(MerchantID)
	if MerchantCfg == nil then
		FLOG_WARNING("神秘商人ID不存在:"..MerchantID)
	end

	if ATLType == EATLType.DefaultIdle then
		return TaskCfg and TaskCfg.StartAtlID or 0
	elseif ATLType == EATLType.Saved then
		return TaskCfg and TaskCfg.SaveAtlID or 0
	elseif ATLType == EATLType.FinishTaskIdle then
		return TaskCfg and TaskCfg.FinishAtlID or 0
	elseif ATLType == EATLType.ShopIdle then
		return MerchantCfg and MerchantCfg.ShopAtlID or 0
	end
	
	return 0
end

---@type 获取商人刷新点
function MysterMerchantUtils.GetMerchantPointInfo(MerchantPointID)
    if MerchantPointID == nil then
		return
	end
	local MerchantMapPointCfg = MerchantMapPointCfg:FindCfgByKey(MerchantPointID)
	if MerchantMapPointCfg == nil then
		return
	end
	local PointInfo = {
		MapResID = MerchantMapPointCfg.MapID,
		BirthPointID = MerchantMapPointCfg.BirthID,
		EndPointID = MerchantMapPointCfg.GoHomeID,
	}
	return	PointInfo
end

---@type 是否配置商人刷新点
function MysterMerchantUtils.IsConfigMerchantMapPoint(MapResID)
    if MapResID == nil then
		return false
	end
	local SearchConditions = string.format("MapID=%d", MapResID)
	local MerchantMapPointCfg = MerchantMapPointCfg:FindCfg(SearchConditions)
	return	MerchantMapPointCfg ~= nil
end

---@type 获取采集物刷新ID列表
function MysterMerchantUtils.GetGatherEditorIDList(TaskID, VisualNum)
    if TaskID == nil then
		return
	end
	local MerchantTaskCfg = MerchantTaskCfg:FindCfgByKey(TaskID)
	if MerchantTaskCfg == nil then
		return
	end
	local EditorIDListStr = MerchantTaskCfg.EobjListIDs
	local EditorIDList = string.split(EditorIDListStr, ",")
	return	MysterMerchantUtils.RandomSubArray(EditorIDList, VisualNum)
end

function MysterMerchantUtils.RandomSubArray(OriginalArray, NewSize)
    if NewSize > #OriginalArray then
        return nil
    end

	if NewSize == #OriginalArray then
		return OriginalArray
	end
    
    local NewArray = {}
    local UsedIndices = {}  -- 记录已使用的索引
    
    for i = 1, NewSize do
        local RandomIndex
        repeat
            RandomIndex = math.random(#OriginalArray)
        until not UsedIndices[RandomIndex]
        
        UsedIndices[RandomIndex] = true
        NewArray[i] = OriginalArray[RandomIndex]
    end
    
    return NewArray
end

---@type 获取随机采集物刷新ID
function MysterMerchantUtils.GetRandomGatherEditorID(GatherEditorIDList, TaskID)
    if TaskID == nil or GatherEditorIDList == nil then
		return
	end
	local MerchantTaskCfg = MerchantTaskCfg:FindCfgByKey(TaskID)
	if MerchantTaskCfg == nil then
		return
	end
	local EditorIDListStr = MerchantTaskCfg.EobjListIDs
	local EditorIDList = string.split(EditorIDListStr, ",")
	-- 排除已存在的采集物
	for index = #EditorIDList, 1, -1 do
		local EditorID = tonumber(EditorIDList[index])
		for _, GatherEditorID in ipairs(GatherEditorIDList) do
			if EditorID == GatherEditorID then
				table.remove(EditorIDList, index)
			end
		end
	end

	local RandomIndex = math.random(#EditorIDList)
	local RandomID = tonumber(EditorIDList and EditorIDList[RandomIndex])
	return	RandomID or 0
end

---@type 求救喊话距离
function MysterMerchantUtils.GetHelpDistance(TaskID)
    local TaskInfo = MysterMerchantUtils.GetMerchantTaskInfo(TaskID)
    return TaskInfo and TaskInfo.AskForHelpDistance or 0
end

---@type 拾取货物减速状态ID
function MysterMerchantUtils.GetOverWeightStateID()
    local Values = GameGlobalCfg:FindValue(GLOBAL_CFG_ID.GAME_CFG_MERCHANT_INTERACTIVE_BUFF, "Value") -- 1184
    return Values and Values[1] or 0
end

---@type 获取通用提示信息时长
function MysterMerchantUtils.GetTipDurationByID(SysnoticeID)
	if SysnoticeID == nil or SysnoticeID <= 0 then
		return 0
	end
	local Cfg = SysnoticeCfg:FindCfgByKey(SysnoticeID)
	return Cfg and Cfg.ShowTime or 0
end


return MysterMerchantUtils
