---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local AchievementUtil = {}

local ProtoRes = require("Protocol/ProtoRes")
local AchievementCategoryCfg = require("TableCfg/AchievementCategoryCfg")
local AchievementTypeCfg = require("TableCfg/AchievementTypeCfg")
local AchievementShowCfg = require("TableCfg/AchievementShowCfg")
local AchievementTextCfg = require("TableCfg/AchievementTextCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local LogMgr = require("Log/LogMgr")
local AchievementDefine = require("Game/Achievement/AchievementDefine")
local RichTextUtil = require("Utils/RichTextUtil")
local UIViewID = require("Define/UIViewID")
local UIBindableList = require("UI/UIBindableList")
local MailSlotItemViewVM = require("Game/Mail/View/Item/MailSlotItemViewVM")

local FLOG_WARNING = LogMgr.Warning
local table = _G.table
local AchievementHideType = ProtoRes.AchievementHideType
local LSTR = _G.LSTR


---查询当前类别下是否有解锁成就
function AchievementUtil.HaveUnLockAchieveFromCategory( CategoryID)
	local AchieveList = _G.AchievementMgr:GetAchieveDataListFromCategoryID(CategoryID)
    local OwnerFinish = false
    for i = 1, #AchieveList do
        if AchieveList[i].IsFinish then 
            OwnerFinish = true
        end
    end

	return OwnerFinish
end

-- 根据成就类型Id 获取某类型和当前等级 已完成成就点与成就总数
---@param TypeID number
function AchievementUtil.GetAchievementPointInfo(TypeID)
    local AchievementPoint = 0
    local TargetPoint = 1
	local LevelInfo = _G.AchievementMgr:GetAchievementLevelRewardInfo(TypeID)
	if LevelInfo ~= nil then
        AchievementPoint = LevelInfo.AchievementPoint
        local AwardInfo, AwardInfoIndex = table.find_item(LevelInfo.LevelAwardInfo , LevelInfo.CurrentLevel + 1, "Level")
        if AwardInfo ~= nil then
            TargetPoint = LevelInfo.LevelAwardInfo[AwardInfoIndex].BasicAchievePoint
        else
            TargetPoint = AchievementPoint
        end
	end

	return AchievementPoint, TargetPoint
end


-- 根据成就Id 判断当前成就是否符合筛选类型
---@param AwardTypeID
---@param AchievemwntData 
function AchievementUtil.CheckMeetFilterCriteria(AwardTypeID, AchievemwntData)
    if AwardTypeID == 0 then
        return false
    elseif AwardTypeID == 1 then 
        return true
    else
        local AwardTypeList = AchievemwntData.AwardTypeList or {}
        return table.contain(AwardTypeList, AwardTypeID)
    end
end


-- 根据成就类别Id 获取类型Id
---@param TypeID number
function AchievementUtil.GetTypeIDFromCategoryID(CategoryID)
    
    local OverviewCategoryDataTable = AchievementDefine.OverviewCategoryDataTable or {}
    for i = 1, #(OverviewCategoryDataTable) do
        if CategoryID == OverviewCategoryDataTable[i].CategoryID then 
            return OverviewCategoryDataTable[i].TypeID
        end
    end

	local Cfg = AchievementCategoryCfg:FindCfgByKey(CategoryID)
    if Cfg ~= nil then
        return Cfg.Type or 0
    else
        FLOG_WARNING(string.format(" No found achievement CategoryID: %d ! ", CategoryID))
        return 0
    end
end

-- 根据成就类型Id 获取类型文本
---@param TypeID number
function AchievementUtil.GetTypeTextFromtTypeID(TypeID)
    local OverviewTypeDataTable = AchievementDefine.OverviewTypeDataTable or {}
    for i = 1, #(OverviewTypeDataTable) do
        if TypeID == OverviewTypeDataTable[i].TypeID then 
            return OverviewTypeDataTable[i].TypeName
        end
    end

    local Cfg = AchievementTypeCfg:FindCfgByKey(TypeID) or {}
    if Cfg ~= nil then
        return Cfg.TypeName or ""
    else
        FLOG_WARNING(string.format(" No found achievement TypeID: %d ! ", TypeID))
        return ""
    end
end

-- 查询最新解锁成就数量
---@param ResId number @索引奖励的ID
---@param ItemType number @对应奖励类型ID   成就表中的奖励类型页签   
function AchievementUtil.GetAwardIconPath(ResId, ItemType)
    if ItemType == 2 then
        return "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Icon_Title_png.UI_Achievement_Icon_Title_png'"
    else
        local Cfg = ItemCfg:FindCfgByKey(ResId or 0 )
        if Cfg ~= nil then
            return ItemCfg.GetIconPath(Cfg.IconID or 0)
        end
    end
    return nil
end

-- 成就列表依据HideType判断是否显示自己
function AchievementUtil.CheckShowFromHideType(ShowAchievementDataList)
    local HideDataList = {}
    for i = 1, #ShowAchievementDataList do
        if ShowAchievementDataList[i].HideType == AchievementHideType.ACHIEVEMENT_HIDE_TYPE_HIDE_ACHIEVEMENT and ShowAchievementDataList[i].IsFinish == false then 
            table.insert(HideDataList, ShowAchievementDataList[i])
        end
    end

    for i = 1, #HideDataList do
        table.remove_item(ShowAchievementDataList, HideDataList[i])
    end
    return ShowAchievementDataList
end

--打开奖励界面
function AchievementUtil.OpenRewardPanel(AwardList)
    local VMList = UIBindableList.New(MailSlotItemViewVM)
	local NewItemList = {}
	for _, V in ipairs(AwardList) do
		if NewItemList[V.ResID] ~= nil then
			NewItemList[V.ResID].Num = NewItemList[V.ResID].Num + V.Num
		else
			NewItemList[V.ResID] = { ResID = V.ResID, Num = V.Num }
		end
	end
    
    if table.length(NewItemList) > 0 then
        for _, V in pairs(NewItemList) do
            VMList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num, IsValid = true, NumVisible = true, ItemNameVisible = true }, nil, true)
        end
        _G.UIViewMgr:ShowView(UIViewID.CommonRewardPanel, { Title = LSTR(720025), ItemVMList = VMList })     --  "获得物品"
    else
        _G.LootMgr:SetDealyState(false)
    end
end

--获取进度文本样式
function AchievementUtil.GetProgressTextStyle(ProgressValue, TotleValue)
    local ProgressText = ""
    if ProgressValue > TotleValue then
        ProgressText = RichTextUtil.GetText(string.format("%d", ProgressValue), "af4c58")
    else
        ProgressText = RichTextUtil.GetText(string.format("%d", ProgressValue), "bd8213")
    end
    local TotalProgressText = RichTextUtil.GetText(string.format("/%d", TotleValue), "313131")
    return ProgressText .. TotalProgressText
end

-- 表格信息中等级奖励数据 筛掉无效数据
function AchievementUtil.CheckCfgLevelRewardList(RewardList)
    local RetList = {}
    for j = 1, #RewardList do
        if (RewardList[j].ResID or 0) ~= 0 then
            table.insert(RetList, RewardList[j])
        end
    end
    return RetList
end

-- 获取当前类型的等级奖励物品列表
function AchievementUtil.GetLevelRewardList(TypeID)
    local LevelInfo = _G.AchievementMgr:GetAchievementLevelRewardInfo(TypeID)
    if LevelInfo ~= nil then
        local LevelAwardInfo = LevelInfo.LevelAwardInfo or {}
        return LevelAwardInfo
    end
    return {}
end

-- 获取当前是否有可领取等级奖励
---@return bool @true有  @fasle 没有
function AchievementUtil.IsCanGetLevelReward(TypeID)
    local LevelInfo = _G.AchievementMgr:GetAchievementLevelRewardInfo(TypeID)
    if LevelInfo ~= nil then
        local LevelAwardInfo = LevelInfo.LevelAwardInfo or {}    
        for i = 1, #LevelAwardInfo do
            if (not LevelAwardInfo[i].Received) and LevelAwardInfo[i].Level <= LevelInfo.CurrentLevel then 
                return true
            end
        end
    end
    return false
end


-- 最新解锁列表成就排序
function AchievementUtil.NewUnlockAchieveSort(NewUnlockAchieveList)
    table.sort(NewUnlockAchieveList, 
		function(A, B)  
			if A.CompeletedTime ~= B.CompeletedTime then 
				return A.CompeletedTime > B.CompeletedTime 
			else
				return A.ID > B.ID
			end
		end )
    return NewUnlockAchieveList
end

-- 最新解锁成就通知排序
function AchievementUtil.NewUnlockNotifySort(NewUnlockAchieveList)
    table.sort(NewUnlockAchieveList, 
		function(A, B)  
			if A.CompeletedTime ~= B.CompeletedTime then 
				return A.CompeletedTime > B.CompeletedTime 
			else
				return A.ID < B.ID
			end
		end )
    return NewUnlockAchieveList
end

-------------------------------  查询数据

-- 根据成就Id 获取成就名称
---@param AchievemwntID number @成就id
function AchievementUtil.GetAchievementName(AchievemwntID)
    local AchievementMgr = _G.AchievementMgr
    AchievementMgr:LoadAllAchieveTextData()
    local Info = AchievementMgr:GetAchievementInfo(AchievemwntID)
    if Info == nil then
       return ""      -- 这里意味着成就没有实装
    end
    if Info.IsFinish == false then
        if Info.HideType == AchievementHideType.ACHIEVEMENT_HIDE_TYPE_HIDE_ACHIEVEMENT 
        or Info.HideType == AchievementHideType.ACHIEVEMENT_HIDE_TYPE_HIDE_ALL then
            return LSTR(720010)       -- "未解锁"
        end 
    end

    return Info.TextName or LSTR(720029)    -- "未找到成就名称"
end

-- 根据成就Id 查询该成就隐藏类型
---@param AchievemwntID number @成就id
function AchievementUtil.QueryAchievementConcealType(AchievemwntID)
    local Info = _G.AchievementMgr:GetAchievementInfo(AchievemwntID)
    if Info ~= nil then
        return Info.HideType or 0
    end
end

-- 根据成就ID 查询该成就Icon
---@param AchievemwntID number @成就id
---@return IconPath string @成就图标
function AchievementUtil.QueryAchievementIconPath(AchievemwntID)
    local Info = _G.AchievementMgr:GetAchievementInfo(AchievemwntID)
    if Info ~= nil and Info.IconPath ~= "" then
        return Info.IconPath
    end
    return AchievementShowCfg:FindValue(AchievemwntID, "Icon") or ""
end

-- 根据成就ID 查询该成就所属分组
---@param AchievemwntID number @成就id
---@return GroupID int @组ID
function AchievementUtil.QueryAchievementGroupID(AchievemwntID)
    local Info = _G.AchievementMgr:GetAchievementInfo(AchievemwntID)
    if Info ~= nil and Info.GroupID ~= 0 then
        return Info.GroupID
    end
    return AchievementShowCfg:FindValue(AchievemwntID, "Group") or 0
end

-- 根据成就ID 查询该成就描述
---@param AchievemwntID number @成就id
---@return HelpStr string @成就描述
function AchievementUtil.QueryAchievementHelp(AchievemwntID)
    local Info = _G.AchievementMgr:GetAchievementInfo(AchievemwntID)
    if Info ~= nil and Info.TextContent ~= "" then
        return Info.TextContent
    end
    return AchievementTextCfg:FindValue(AchievemwntID, "Help") or ""
end

return AchievementUtil