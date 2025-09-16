---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local AchievementCfg = require("TableCfg/AchievementCfg")
local AchievementTextCfg = require("TableCfg/AchievementTextCfg")
local AchievementShowCfg = require("TableCfg/AchievementShowCfg")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local AchievementTotleLevelCfg = require("TableCfg/AchievementTotleLevelCfg")
local AchievementGroupCfg = require("TableCfg/AchievementGroupCfg")
local AchievementMainPanelVM = require("Game/Achievement/VM/AchievementMainPanelVM")
local AchievementDefine = require("Game/Achievement/AchievementDefine")
local MsgTipsID = require("Define/MsgTipsID")
local EventID = require("Define/EventID")
local LogMgr = require("Log/LogMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local FLOG_WARNING = LogMgr.Warning
local LSTR
local GameNetworkMgr
local ChatMgr
local LootMgr
local UIViewMgr
local RedDotMgr

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CsAchievementCmd
local AchievementStatus = ProtoCS.AchievementStatus

---@class AchievementMgr : MgrBase
local AchievementMgr = LuaClass(MgrBase)

---OnInit
function AchievementMgr:OnInit()

end

function AchievementMgr:OnBegin()
	LSTR = _G.LSTR
	GameNetworkMgr = _G.GameNetworkMgr
	ChatMgr = _G.ChatMgr
	UIViewMgr = _G.UIViewMgr
	LootMgr = _G.LootMgr
	RedDotMgr = _G.RedDotMgr

	AchievementDefine.RedDotName = RedDotMgr:GetRedDotNameByID(AchievementDefine.RedDotID) or ""

	self.AchievementDataList = {}
	self.LevelData = {}
	self.TotalLevel = 0
	self.GroupIDMap = {}
	self.CollectAchieveIDList = {}
	self.NewAchieveIDList = {}    -- ID CompeletedTime
	self.CollectionCacheIDs = {}
	self.CollectionCacheOperation = false
	self.RedDotList = {}
	self.NotificationAchieveIDs = {}
	self.TextLoaded = false
	self.ShowInfoLoaded = false
	self.HaveNewAchieveFinish = true

	self.TempSysNotifyList = {}
	self.OtherPlayerAchievementMap = {}

	self:LoadAllCfgData()
	self:LoadLevelCfgData()
	self:LoadAllAchieveGroupCfgData()
end

function AchievementMgr:OnEnd()
	if #self.NotificationAchieveIDs > 0 then
		self:OnNetMsgShowedCompletedReq(self.NotificationAchieveIDs)
	end
end

function AchievementMgr:OnShutdown()

end

function AchievementMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACHIEVEMENT, SUB_MSG_ID.CS_ACHIEVEMENT_QUERY, 		self.OnNetMsgQueryRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACHIEVEMENT, SUB_MSG_ID.CS_ACHIEVEMENT_CLAIM, 		self.OnNetMsgClaimRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACHIEVEMENT, SUB_MSG_ID.CS_ACHIEVEMENT_TARGET_LIST,	self.OnNetMsgTargetListRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACHIEVEMENT, SUB_MSG_ID.CS_ACHIEVEMENT_LEVEL_AWARD, 	self.OnNetMsgLevelAwardyRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACHIEVEMENT, SUB_MSG_ID.CS_ACHIEVEMENT_UPDATE, 		self.OnNetMsgUpdateRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACHIEVEMENT, SUB_MSG_ID.CS_ACHIEVEMENT_SHOWED_COMPLETED, 		self.OnNetMsgShowedCompletedRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACHIEVEMENT, SUB_MSG_ID.CS_ACHIEVEMENT_OTHER_COMPLETE, 		self.OnNetMsgOtherCompletRsp)
end

function AchievementMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes) 
end

function AchievementMgr:OnGameEventLoginRes()
	self:OnNetMsgQueryReq()
end

--------------------------------------------------------- 数据结构读取

---@type LocalAchievementMgrata table@客户端存储的成就结构体成员
---@field ID number @成就ID
---@field TypeID number @类型ID
---@field CategoryID number @类别ID
---@field TextName string @名字文本
---@field TextContent string @描述文本
---@field IconPath string @图标路径
---@field IsItemIcon int32 @是否使用道具图标
---@field Sort int32 @显示优先级
---@field GroupID number @成就组ID
---@field IsFinish number @是否完成
---@field AchievePoint number @成就点数
---@field AchievePointIcon number @成就点数图标
---@field FinishTime number @完成时间     未完成为0
---@field HaveReward bool   @是否有奖励    true有  false无 领取后false
---@field RewardList AwardsList   @奖励数据表   { ResID Num RewardType(对应奖励类型表id) }
---@field AwardTypeList AwardsTypeID   @奖励类型表与奖励表 两者下标对应
---@field HideType number   @隐藏类型 	Protocol/ProtoRes.AchievementHideType
---@field ConditionList number[]  @当前条件列表  完成成就的条件为或时 只有一个条件ID 并的为条件ID数组
---@field ProgressType number    @进度显示类型   1数量计算   2无数量计算   表中约定
---@field StatisticsInfo number  @条件id列表  （没缓存）
---@field ConditionIsAnd number   @关系
---@field BelongGroups number[]   @归属于哪些成就组
---@field IsAutoReceive number    @是否自动领取目标奖励   0 = 手动   1 = 自动(策划定)
---
---@field Progress number    @进度
---@field TotalProgress number  @进度类型需要完成的总数  并是叠加的


function AchievementMgr:LoadAllCfgData()
	local AllCfg = AchievementCfg:FindAllCfg() or {}
	for i = 1, #AllCfg do
		if AllCfg[i].OnOff == 1 then
			local NewAchieveMent = {}
			NewAchieveMent.ID = AllCfg[i].ID
			NewAchieveMent.TypeID = AllCfg[i].Type
			NewAchieveMent.CategoryID = AllCfg[i].Category
			NewAchieveMent.TextName = ""
			NewAchieveMent.TextContent = ""
			NewAchieveMent.IconPath = ""
			NewAchieveMent.IsItemIcon = 0
			NewAchieveMent.GroupID = 0
			NewAchieveMent.Sort = 0
			NewAchieveMent.IsFinish = false
			NewAchieveMent.AchievePoint = 0
			NewAchieveMent.AchievePointIcon = ""
			NewAchieveMent.FinishTime = 0
			NewAchieveMent.ConditionIsAnd = 0
			NewAchieveMent.ProgressType = 0
			NewAchieveMent.Progress = nil
			NewAchieveMent.TotalProgress = nil
			NewAchieveMent.BelongGroups = {}
			NewAchieveMent.RewardList = {}
			NewAchieveMent.AwardTypeList = {}
			local Awards = AllCfg[i].Awards or {}
			for j = 1, #Awards do 
				if Awards[j].ResID ~= nil and Awards[j].ResID ~= 0 then
					Awards[j].RewardType = Awards[j].Type or 1
					table.insert(NewAchieveMent.AwardTypeList, Awards[j].RewardType)
					table.insert(NewAchieveMent.RewardList, Awards[j])
				end
			end
			if #NewAchieveMent.RewardList > 0 then
				NewAchieveMent.IsAutoReceive = AllCfg[i].IsAutoReceive or 0
				NewAchieveMent.HaveReward = NewAchieveMent.IsAutoReceive == 0
			else
				NewAchieveMent.IsAutoReceive = nil
				NewAchieveMent.HaveReward = false
			end
			self.AchievementDataList[NewAchieveMent.ID] = NewAchieveMent
		end
	end
end

function AchievementMgr:LoadAllAchieveTextData()
	if not self.TextLoaded then
		local AllTextCfg = AchievementTextCfg:FindAllCfg() or {}
		for i = 1, #AllTextCfg do
			local TextCfg = AllTextCfg[i] or {}
			local AchieveInfo = self:GetAchievementInfo(TextCfg.ID)
			if AchieveInfo ~= nil then
				AchieveInfo.TextName = TextCfg.Name or ""
				AchieveInfo.TextContent = TextCfg.Help or ""
				AchieveInfo.AchievePoint = TextCfg.AchievePoint
				AchieveInfo.AchievePointIcon = AchievementDefine.AchievePointIconMap[TextCfg.AchievePoint]
				AchieveInfo.HideType = TextCfg.HideType
			end
		end
		self.TextLoaded = #AllTextCfg > 0
	end
end

function AchievementMgr:LoadAllAchieveShowData()
	if not self.ShowInfoLoaded then
		local AllShowInfoCfg = AchievementShowCfg:FindAllCfg() or {}
		for i = 1, #AllShowInfoCfg do
			local TextCfg = AllShowInfoCfg[i] or {}
			local AchieveInfo = self:GetAchievementInfo(TextCfg.ID)
			if AchieveInfo ~= nil then
				AchieveInfo.IconPath = AllShowInfoCfg[i].Icon
				AchieveInfo.IsItemIcon = AllShowInfoCfg[i].IsItemIcon
				AchieveInfo.GroupID = AllShowInfoCfg[i].Group
				local StatisticsInfo = AllShowInfoCfg[i].StatisticsInfo or {}
				AchieveInfo.ConditionIsAnd = AllShowInfoCfg[i].IsAnd
				AchieveInfo.Sort = AllShowInfoCfg[i].Sort
				AchieveInfo.ProgressType = AllShowInfoCfg[i].ProgressType
				if (AchieveInfo.Progress == nil or AchieveInfo.TotalProgress == nil) and AchieveInfo.ProgressType == 1 then
					AchieveInfo.Progress = 0
					local TotalCount = 0
					local MaxCount = 0
					for j = 1, #StatisticsInfo do
						local TargetInfo = StatisticsInfo[j]
						if TargetInfo ~= nil then
							local Target = TargetInfo.Target or 0
							TotalCount = TotalCount + Target
							if MaxCount < Target then
								MaxCount = Target
							end
						end
					end
					if AchieveInfo.ConditionIsAnd == 1 then -- 1 是同时满足所有
						AchieveInfo.TotalProgress = TotalCount
					else
						AchieveInfo.TotalProgress = MaxCount
					end
				end
			end
		end
		self.ShowInfoLoaded = #AllShowInfoCfg > 0
	end
end

--------------------------------------------
---@type LevelData table   @客户端等级数据结构
---@field TypeID number @类型ID  0是总等级 其他的对应类型id  (根据后台的LevelType枚举)
---@field CurrentLevel number @当前等级
---@field LevelAwardInfo table @所有等级奖励信息  { Level  RewardList@奖励列表  Received@ true 已经领取了    BasicAchievePoint@需要开启此级的起始点数  }
---@field AchievementPoint number @当前已拥有成就点数
---@field FinishAchieveNum number @当前类型中已完成成就数量


function AchievementMgr:LoadLevelCfgData()
	local AllTotalLevelCfg = AchievementTotleLevelCfg:FindAllCfg() or {}

	self.LevelData = {}
	local TotalLevelData = {}
	TotalLevelData.TypeID = 0
	TotalLevelData.CurrentLevel = 0
	TotalLevelData.AchievementPoint = 0
	TotalLevelData.FinishAchieveNum = 0
	TotalLevelData.LevelAwardInfo = {}
	for i = 1, #AllTotalLevelCfg do
		local AwardInfo = {}
		AwardInfo.Level = AllTotalLevelCfg[i].Level
		local TempRewardList = AllTotalLevelCfg[i].Awards or {}
		AwardInfo.RewardList = AchievementUtil.CheckCfgLevelRewardList(TempRewardList)
		AwardInfo.Received = false
		AwardInfo.BasicAchievePoint = AllTotalLevelCfg[i].AchievePoint
		table.insert(TotalLevelData.LevelAwardInfo, AwardInfo)
	end
	table.sort(TotalLevelData.LevelAwardInfo, function(A, B) return A.Level < B.Level end)
	table.insert(self.LevelData, TotalLevelData)
end

function AchievementMgr:LoadAllAchieveGroupCfgData()
	local GroupCfg = AchievementGroupCfg:FindAllCfg() or {}
	for i = 1, #GroupCfg do
		local  Details = GroupCfg[i].Details or {}
		table.insert(self.GroupIDMap, GroupCfg[i].ID, Details)
		for j = 1, #Details do
			local AchieveInfo = self:GetAchievementInfo(Details[j])
			if AchieveInfo ~= nil then
				table.insert(AchieveInfo.BelongGroups, GroupCfg[i].ID)
			end
		end
	end
end

----------------------------------------------------后台数据


-- 处理后台发过来已完成成就
function AchievementMgr:AddCompeletedEntryInfo(InfoList)
	local  OldNewAchieveIDList = {}
	for i = 1, #self.NewAchieveIDList do
		table.insert(OldNewAchieveIDList, self.NewAchieveIDList[i].ID)
	end
	--梳理出最新成就列表
	InfoList = AchievementUtil.NewUnlockAchieveSort(InfoList)
	local AddCount = 0
	for i = 1, #InfoList do
		local Value = self:GetAchievementInfo(InfoList[i].ID)
		if (not table.contain(OldNewAchieveIDList, InfoList[i].ID)) and Value ~= nil then
			table.insert( self.NewAchieveIDList ,{ ID = InfoList[i].ID, CompeletedTime = InfoList[i].CompeletedTime } )
			AddCount = AddCount + 1
			if AddCount == AchievementDefine.NewAchievementShowNum then
				break
			end
		end
	end
	self.NewAchieveIDList = AchievementUtil.NewUnlockAchieveSort(self.NewAchieveIDList)

	for i = #self.NewAchieveIDList, 1, -1 do
		if i > AchievementDefine.NewAchievementShowNum then
			local AchievementID = self.NewAchieveIDList[i].ID
			if table.contain(OldNewAchieveIDList, AchievementID) then
				self:AddNewUnLockRedDot(AchievementID, false)
			end
			table.remove(self.NewAchieveIDList, i)
		end
	end

	local TypeCompletedCount = {}
	local TotalCount = 0

	for i = 1, #InfoList do
		local AchievementInfo = self:GetAchievementInfo(InfoList[i].ID)
		if AchievementInfo ~= nil then
			if AchievementInfo.IsFinish ~= true then
				AchievementInfo.FinishTime = InfoList[i].CompeletedTime
				AchievementInfo.IsFinish = true
				if InfoList[i].Status == AchievementStatus.ACHIEVEMENT_STATUS_COMPLETED then
					local HaveReward = (AchievementInfo.IsAutoReceive) == 0
					AchievementInfo.HaveReward = HaveReward
				elseif InfoList[i].Status == AchievementStatus.ACHIEVEMENT_STATUS_CLIAMED then
					AchievementInfo.HaveReward = false
				end
				TotalCount = TotalCount + 1
				local _, CountIndex = table.find_item(TypeCompletedCount, AchievementInfo.TypeID, "TypeID")
				if CountIndex == nil then
					table.insert(TypeCompletedCount, { TypeID = AchievementInfo.TypeID, FinishCount = 1 } )
				else
					TypeCompletedCount[CountIndex].FinishCount = TypeCompletedCount[CountIndex].FinishCount + 1
				end
			else
				if InfoList[i].Status == AchievementStatus.ACHIEVEMENT_STATUS_COMPLETED then
					AchievementInfo.HaveReward = (AchievementInfo.IsAutoReceive) == 0
				elseif InfoList[i].Status == AchievementStatus.ACHIEVEMENT_STATUS_CLIAMED then
					AchievementInfo.HaveReward = false
				end
			end
			self:AddIDRedDot(AchievementInfo.ID, AchievementInfo.HaveReward)
		end
	end

	for i = 1,  #TypeCompletedCount do
		local Value, Index = table.find_item(self.LevelData, TypeCompletedCount[i].TypeID, "TypeID")
		if Value ~= nil then
			self.LevelData[Index].FinishAchieveNum = self.LevelData[Index].FinishAchieveNum + TypeCompletedCount[i].FinishCount
		end
	end

	local Value, Index = table.find_item(self.LevelData, 0, "TypeID")
	if Value ~= nil then
		self.LevelData[Index].FinishAchieveNum = self.LevelData[Index].FinishAchieveNum + TotalCount
	end
end

-- 处理后台发过来进度中成就
function AchievementMgr:AddInProgressEntryInfo(InfoList)
	for i = 1, #InfoList do
		local AchievementInfo = self:GetAchievementInfo(InfoList[i].ID)
		if AchievementInfo ~= nil then
			AchievementInfo.IsFinish = false
			AchievementInfo.FinishTime = 0

			AchievementInfo.Progress = InfoList[i].Progress
			AchievementInfo.TotalProgress = InfoList[i].Target
		end
	end
end

-- 处理后台发过来的等级信息结构
function AchievementMgr:SetTypeLevel(Levels)
	for Key, Value in pairs(Levels) do
		local Item, Index = table.find_item(self.LevelData, Key, "TypeID")
		if Item ~= nil then
			self.LevelData[Index].CurrentLevel = Value or 0
		end
	end
end

-- 处理后台发过来的成就点信息结构
function AchievementMgr:SetAchievePoint(Point)
	for Key, Value in pairs(Point) do
		local Item, Index = table.find_item(self.LevelData, Key, "TypeID")
		if Item ~= nil then
			self.LevelData[Index].AchievementPoint = Value or 0
		end
	end
	AchievementMainPanelVM:SetTotalAchievePointText()
end 
------------------------------------------------  协议相关
function AchievementMgr:OnNetMsgQueryRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.Query then
		return
	end

	local QueryData = MsgBody.Query
	self.TotalLevel = QueryData.Level
	local Compeleted = QueryData.Compeleted or {}
	local Inprogress = QueryData.Inprogress or {}
	self.CollectAchieveIDList = {}
	local CollectAchieveIDList = QueryData.TargetList or {}
	for i = 1, #CollectAchieveIDList do
		table.insert(self.CollectAchieveIDList, 1, CollectAchieveIDList[i])
	end

	self:AddCompeletedEntryInfo(Compeleted)
	self:AddInProgressEntryInfo(Inprogress)
	local NeedPlayUnlock = {}
	for i = 1, #Compeleted do
		if not Compeleted[i].ShowedCompleted and not table.contain(self.NotificationAchieveIDs, Compeleted[i].ID) then
			table.insert(NeedPlayUnlock, Compeleted[i])
		end
		self.HaveNewAchieveFinish = true
	end
	self:AddNewUnlockInfoToChatChannel(NeedPlayUnlock)

	local Levels = QueryData.Levels or {}
	local ClaimedLevels = QueryData.ClaimedLevels or {}
	local Point = QueryData.Point or {}

	self:SetTypeLevel(Levels)
	self:SetAchievePoint(Point)

	for Key, Value in pairs(ClaimedLevels) do
		local Item, Index = table.find_item(self.LevelData, Key, "TypeID")
		if Item ~= nil then
			for _, Level in pairs( Value.Levels or {} ) do
				local _, LevelIndex = table.find_item(self.LevelData[Index].LevelAwardInfo , Level, "Level")
				if LevelIndex ~= nil then
					self.LevelData[Index].LevelAwardInfo[LevelIndex].Received = true
				end
			end
		end
	end

	self:RefreshLevelRedDot()
	AchievementMainPanelVM:RefreshDisplaysAchievementsProgress()
end

function AchievementMgr:OnNetMsgClaimRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.Claim then
		return
	end

	local AchieveIDs = MsgBody.Claim.AchieveIDs or {}
	local AwardList = {}

	for i = 1, #AchieveIDs do
		local AchievementInfo = self:GetAchievementInfo(AchieveIDs[i])
		if AchievementInfo ~= nil then
			AchievementInfo.HaveReward = false
			for j = 1, #AchievementInfo.RewardList do
				table.insert(AwardList, AchievementInfo.RewardList[j])
			end
			self:AddIDRedDot(AchievementInfo.ID, false)
		end
	end

	AchievementMainPanelVM:ReceiveAwardSucceed(AchieveIDs, AwardList)
	AchievementUtil.OpenRewardPanel(AwardList)
end

function AchievementMgr:OnNetMsgTargetListRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.TargetList then
		self.CollectionCacheIDs = nil
		self.CollectionCacheOperation = nil
		return
	end
	self.CollectAchieveIDList = {}
	local CollectAchieveIDList =  MsgBody.TargetList.AchieveIDs or {}
	for i = 1, #CollectAchieveIDList do
		table.insert(self.CollectAchieveIDList, 1, CollectAchieveIDList[i])
	end

	if self.CollectionCacheIDs == nil or self.CollectionCacheOperation == nil then
		self.CollectionCacheIDs = nil
		self.CollectionCacheOperation = nil
		return
	end

	local SucceedList = {}
	local CacheListNum = #(self.CollectionCacheIDs or {})
	if self.CollectionCacheOperation then
		for i = 1, CacheListNum do
			if table.contain(self.CollectAchieveIDList , self.CollectionCacheIDs[i]) then
				table.insert(SucceedList, self.CollectionCacheIDs[i])
			end
		end
	else
		for i = 1, CacheListNum do
			if not table.contain(self.CollectAchieveIDList , self.CollectionCacheIDs[i]) then
				table.insert(SucceedList, self.CollectionCacheIDs[i])
				--self:AddCollectRedDot(self.CollectionCacheIDs[i], false)
			end
		end
	end
	AchievementMainPanelVM:CollectionSucceed(self.CollectionCacheOperation, SucceedList)
	for i = 1, #SucceedList do
		local Info = self:GetAchievementInfo(SucceedList[i])
		if Info ~= nil and Info.HaveReward and Info.IsFinish then
			self:AddCollectRedDot(self.CollectionCacheIDs[i], self.CollectionCacheOperation)
		end
	end

	self.CollectionCacheIDs = nil
	self.CollectionCacheOperation = nil
end

function AchievementMgr:OnNetMsgLevelAwardyRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.LevelAward then
		return
	end

	local Level = MsgBody.LevelAward.Level
	local LevelType = MsgBody.LevelAward.LevelTye
	local AwardList = {}

	local Item, Index = table.find_item(self.LevelData, LevelType, "TypeID")
	if Item ~= nil then
		local LevelInfo, LevelIndex = table.find_item(self.LevelData[Index].LevelAwardInfo , Level, "Level")
		if LevelIndex ~= nil then
			self.LevelData[Index].LevelAwardInfo[LevelIndex].Received = true
			for j = 1, #LevelInfo.RewardList do
				table.insert(AwardList, LevelInfo.RewardList[j])
			end
		end
	end
	self:RefreshLevelRedDot()
	AchievementMainPanelVM:ReceiveLevelAwardSucceed(Level)
	AchievementUtil.OpenRewardPanel(AwardList)
end

function AchievementMgr:OnNetMsgUpdateRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.Update then
		return
	end
	self:LoadAllAchieveTextData()
	local Compeleted = MsgBody.Update.Comp or {}
	local Updated = MsgBody.Update.Upd or {}
	local UpdateLevel = MsgBody.Update.UpdateLevel or {}
	local UpdateAchievePoint = MsgBody.Update.UpdateAchievePoint or {}

	self:SetTypeLevel(UpdateLevel)
	self:SetAchievePoint(UpdateAchievePoint)
	self:RefreshLevelRedDot()

	local AwardList = {}
	for i = 1, #Compeleted do
		Compeleted[i].Status = AchievementStatus.ACHIEVEMENT_STATUS_COMPLETED
		-- 先处理下立即获得的非称号奖励
		local AchievementInfo = AchievementMgr:GetAchievementInfo( Compeleted[i].ID )
		if AchievementInfo ~= nil and AchievementInfo.IsAutoReceive == 1 and (not table.contain(AchievementInfo.AwardTypeList, 2)) then
			for j = 1, #AchievementInfo.RewardList do
				table.insert(AwardList, AchievementInfo.RewardList[j])
			end
		end
		self.HaveNewAchieveFinish = true
	end
	if #AwardList > 0 then
		AchievementUtil.OpenRewardPanel(AwardList)
	end

	self:AddCompeletedEntryInfo(Compeleted)
	self:AddInProgressEntryInfo(Updated)
	self:AddNewUnlockInfoToChatChannel(Compeleted)
end

function AchievementMgr:OnNetMsgShowedCompletedRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.ShowedCompleted then
		return
	end

	local AchievementIDs = MsgBody.ShowedCompleted.AchievementIDs or {}
	for i = 1, #AchievementIDs do
		table.remove_item(self.NotificationAchieveIDs, AchievementIDs[i])
	end
end

function AchievementMgr:OnNetMsgOtherCompletRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.OtherCompleted then
		return
	end

	if table.empty(self.OtherPlayerAchievementMap) then 
		self:RegisterTimer(self.OtherPlayerNewAchievementNotify, 1)
	end

	local OtherCompleted = MsgBody.OtherCompleted
	local PlayerName = OtherCompleted.RoleName or ""
	local CompeletedList = OtherCompleted.Compeleted or {}
	local NotifyList = self.OtherPlayerAchievementMap[PlayerName]
	if NotifyList == nil then
		NotifyList = {}
	end
	for i =1, #CompeletedList do
		table.insert(NotifyList, CompeletedList[i].ID)
	end
	self.OtherPlayerAchievementMap[PlayerName] = NotifyList
end

function AchievementMgr:OnNetMsgQueryReq()
	local MsgID = CS_CMD.CS_CMD_ACHIEVEMENT
	local SubMsgID = SUB_MSG_ID.CS_ACHIEVEMENT_QUERY
	local MsgBody = {
		Cmd = SUB_MSG_ID.CS_ACHIEVEMENT_QUERY,
		Query = {}
	}
	if GameNetworkMgr then
		GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	end
end

function AchievementMgr:OnNetMsgClaimReq(AchieveIDs)
	local MsgID = CS_CMD.CS_CMD_ACHIEVEMENT
	local SubMsgID = SUB_MSG_ID.CS_ACHIEVEMENT_CLAIM
	local MsgBody = { 
		Cmd = SUB_MSG_ID.CS_ACHIEVEMENT_CLAIM,
		Claim = { AchieveIDs = AchieveIDs, }
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function AchievementMgr:OnNetMsgTargetListReq(IsAdd, AchieveIDs)
	local MsgID = CS_CMD.CS_CMD_ACHIEVEMENT
	local SubMsgID = SUB_MSG_ID.CS_ACHIEVEMENT_TARGET_LIST
	local MsgBody = {
		Cmd = SUB_MSG_ID.CS_ACHIEVEMENT_TARGET_LIST,
		TargetList = {
			Add = IsAdd,
			AchieveIDs = AchieveIDs,
		}
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function AchievementMgr:OnNetMsgLevelAwardyReq(LevelType, Level)
	local MsgID = CS_CMD.CS_CMD_ACHIEVEMENT
	local SubMsgID = SUB_MSG_ID.CS_ACHIEVEMENT_LEVEL_AWARD
	local MsgBody = { 
		Cmd = SUB_MSG_ID.CS_ACHIEVEMENT_LEVEL_AWARD,
		LevelAward = {
			Level = Level,
			LevelTye = LevelType,
		}
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function AchievementMgr:OnNetMsgShowedCompletedReq(AchievementIDs)
	local MsgID = CS_CMD.CS_CMD_ACHIEVEMENT
	local SubMsgID = SUB_MSG_ID.CS_ACHIEVEMENT_SHOWED_COMPLETED
	local MsgBody = { 
		Cmd = SUB_MSG_ID.CS_ACHIEVEMENT_SHOWED_COMPLETED,
		ShowedCompleted = { AchievementIDs = AchievementIDs }
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


------------------------------------ 红点
function AchievementMgr:RefreshLevelRedDot()
	for _, Value in pairs(self.LevelData) do
		local AddOrRemove = AchievementUtil.IsCanGetLevelReward(Value.TypeID)
		local EntirelyName = AchievementDefine.RedDotName .. '/' .. tostring(Value.TypeID) .. '/level'
		local Exist = table.contain(self.RedDotList, EntirelyName)
		if AddOrRemove and (not Exist) then
			table.insert(self.RedDotList, EntirelyName)
			RedDotMgr:AddRedDotByName(EntirelyName, 1)
		elseif Exist and (not AddOrRemove) then
			table.remove_item(self.RedDotList, EntirelyName)
			RedDotMgr:DelRedDotByName(EntirelyName)
		end
	end
end

---@type 根据成就组id检查是否有红点
function AchievementMgr:AddGroupIDRedDot(GroupID, Operation)
	if (GroupID or 0) == 0 then
		return
	end
	local Exist = self:GetGroupIDRedDotName(GroupID) ~= ""
	local GroupName = 'Group' .. tostring(GroupID)
	if Operation and (not Exist) then
		table.insert(self.RedDotList, GroupName)
		RedDotMgr:AddRedDotByName(AchievementDefine.AchieveGroupRedDotName .. '/' .. GroupName, 1)
	elseif Exist and (not Operation) then
		local Details = self.GroupIDMap[GroupID] or {}
		local Confirm = false
		for i = 1, #Details do
			if self:CheckRedDot(Details[i]) then
				Confirm = true
				break
			end
		end
		if not Confirm then
			RedDotMgr:DelRedDotByName(AchievementDefine.AchieveGroupRedDotName .. '/' .. GroupName)
		end
	end
end


---@type 根据成就id获取红点名字
---@param AchievementID number @成就ID
---@param Operation  true 增加  false 删除
function AchievementMgr:AddIDRedDot(AchievementID, Operation)
	local Exist = table.contain(self.RedDotList, tostring(AchievementID))
	if Operation and (not Exist) then
		local EntirelyName = self:GetRedDotName(AchievementID)
        table.insert(self.RedDotList, tostring(AchievementID))
        RedDotMgr:AddRedDotByName(EntirelyName, 1)
		if table.contain (self.CollectAchieveIDList, AchievementID) then
			self:AddCollectRedDot(AchievementID, Operation)
		end
		if table.find_item(self.NewAchieveIDList, AchievementID, "ID") then
			self:AddNewUnLockRedDot(AchievementID, Operation)
		end
		local AchieveInfo = self:GetAchievementInfo(AchievementID)
		if AchieveInfo ~= nil then
			for i = 1, #AchieveInfo.BelongGroups do
				self:AddGroupIDRedDot(AchieveInfo.BelongGroups[i], Operation)
			end
		end
	elseif Exist and (not Operation) then
		local EntirelyName = self:GetRedDotName(AchievementID)
        table.remove_item(self.RedDotList, tostring(AchievementID))
        RedDotMgr:DelRedDotByName(EntirelyName)
		if table.contain (self.CollectAchieveIDList, AchievementID) then
			self:AddCollectRedDot(AchievementID, Operation)
		end
		if table.find_item(self.NewAchieveIDList, AchievementID, "ID") then
			self:AddNewUnLockRedDot(AchievementID, Operation)
		end
		local AchieveInfo = self:GetAchievementInfo(AchievementID)
		if AchieveInfo ~= nil then
			for i = 1, #AchieveInfo.BelongGroups do
				self:AddGroupIDRedDot(AchieveInfo.BelongGroups[i], Operation)
			end
		end
	end
end

---@type 收藏红点
---@param AchievementID number @成就ID
---@param Operation  true 增加  false 删除
function AchievementMgr:AddCollectRedDot(AchievementID, Operation)
	local TargetRedDotName = AchievementDefine.RedDotName .. '/'
			.. tostring(AchievementDefine.OverviewCategoryDataTable[1].TypeID) .. '/'
			.. tostring(AchievementDefine.OverviewCategoryDataTable[1].CategoryID) .. '/'
			.. tostring(AchievementID)

	if Operation then
		RedDotMgr:AddRedDotByName(TargetRedDotName, 1)
	else
		RedDotMgr:DelRedDotByName(TargetRedDotName)
	end
end

---@type 最新解锁红点
---@param AchievementID number @成就ID
---@param Operation  true 增加  false 删除
function AchievementMgr:AddNewUnLockRedDot(AchievementID, Operation)
	local NewRedDotName = AchievementDefine.RedDotName .. '/'
			.. tostring(AchievementDefine.OverviewCategoryDataTable[2].TypeID) .. '/'
			.. tostring(AchievementDefine.OverviewCategoryDataTable[2].CategoryID) .. '/'
			.. tostring(AchievementID)

	if Operation then
		RedDotMgr:AddRedDotByName(NewRedDotName, 1)
	else
		RedDotMgr:DelRedDotByName(NewRedDotName)
	end
end

---@type 根据成就id获取红点名字
---@param AchievementID number @成就ID
function AchievementMgr:GetRedDotName(AchievementID)
	local AchieveInfo = self:GetAchievementInfo(AchievementID)
	if AchieveInfo ~= nil then
		return AchievementDefine.RedDotName .. '/' .. tostring(AchieveInfo.TypeID) .. '/' .. tostring(AchieveInfo.CategoryID) .. '/' .. tostring(AchievementID)
	end
	return ""
end

---@type 根据成就组id检查并获取成就组红点名字
function AchievementMgr:GetGroupIDRedDotName(GroupID)
	local GroupName = 'Group' .. tostring(GroupID)
	if table.contain(self.RedDotList, GroupName) then
		return AchievementDefine.AchieveGroupRedDotName .. '/' .. GroupName
	end
	return ""
end

---@type 根据成就id检查是否有红点
function AchievementMgr:CheckRedDot(AchievementID)
	return table.contain(self.RedDotList, tostring(AchievementID))
end

------------------------------------ 成就通知

-- 将完成成就信息添加至系统聊天频道
function AchievementMgr:AddNewUnlockInfoToChatChannel(Compeleted)
	self:LoadAllAchieveTextData()
	local StartPlayNotify = false
	local TheSysNotifyList = {}

	for i = 1, #Compeleted do
		local AchievementInfo = self:GetAchievementInfo( Compeleted[i].ID )
		if AchievementInfo ~= nil then
			if not StartPlayNotify then
				StartPlayNotify = #self.TempSysNotifyList <= 0
			end
			local TitleText = nil
			if table.contain(AchievementInfo.AwardTypeList, 2) and AchievementInfo.IsAutoReceive == 1 then
				if AchievementInfo.RewardList[1] ~= nil then
					TitleText = _G.TitleMgr:GetDecoratedTitleText(AchievementInfo.RewardList[1].ResID, MajorUtil.GetMajorGender() )
				end
			end
			table.insert(TheSysNotifyList, { ID = AchievementInfo.ID, TextName = AchievementInfo.TextName, TitleText = TitleText, CompeletedTime = AchievementInfo.FinishTime })
		end
	end
	TheSysNotifyList = AchievementUtil.NewUnlockNotifySort(TheSysNotifyList)
	for i = 1, #TheSysNotifyList do
		local AchieveId = TheSysNotifyList[i].ID
		table.insert(self.TempSysNotifyList, TheSysNotifyList[i])
		_G.EventMgr:SendEvent(EventID.AchievementCompeleted, AchieveId )
	end

	if StartPlayNotify then
		self:RegisterTimer(self.NewAchievementNotifyTimerCB, 1)
	end
	return
end

function AchievementMgr:NewAchievementNotifyTimerCB()
	local IconPath = "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Icon_Chat_Get_png.UI_Achievement_Icon_Chat_Get_png'"
	IconPath = RichTextUtil.GetTexture(IconPath, 40, 40, -8) or ""
	local NewCompeltedID = {}
	self.TempSysNotifyList = AchievementUtil.NewUnlockNotifySort(self.TempSysNotifyList)
	local PlayerName = MajorUtil.GetMajorName() or ""
	for j = 1, #(self.TempSysNotifyList or {}) do
		local TempSysNotify = self.TempSysNotifyList[j] or {}
		local StrPlayerName = RichTextUtil.GetText(string.format(LSTR(720002), PlayerName), "d1ba8e")
		local Hyperlink = RichTextUtil.GetHyperlink(string.format(LSTR(720003), TempSysNotify.TextName or ""), 1, "d1ba8e", nil, nil, nil, nil, nil, false)
		local Content = string.format("%s%s%s", StrPlayerName, IconPath, Hyperlink)
		ChatMgr:ShareAchievement(TempSysNotify.ID, Content)

		if TempSysNotify.TitleText ~= nil then
			MsgTipsUtil.ShowTips(string.format(LSTR(720015), TempSysNotify.TitleText or ""))
			ChatMgr:AddSysChatMsg( RichTextUtil.GetText(string.format(LSTR(720014), TempSysNotify.TitleText or ""), "d1ba8e"))
		end
		table.insert(NewCompeltedID, TempSysNotify.ID )
		table.insert(self.NotificationAchieveIDs, TempSysNotify.ID)
	end
	-- 成就提示放入队列
	MsgTipsUtil.ShowAchievementTips(NewCompeltedID)
	self.TempSysNotifyList = {}
	self:OnNetMsgShowedCompletedReq(self.NotificationAchieveIDs)
end

function AchievementMgr:OtherPlayerNewAchievementNotify()
	local IconPath = "PaperSprite'/Game/UI/Atlas/Achievement/Frames/UI_Achievement_Icon_Chat_Get_png.UI_Achievement_Icon_Chat_Get_png'"
	IconPath = RichTextUtil.GetTexture(IconPath, 40, 40, -8) or ""
	self:LoadAllAchieveTextData()

	for PlayerName, CompeletedList in pairs(self.OtherPlayerAchievementMap) do
		table.sort(CompeletedList, function(A, B) return A < B end)
        for i = 1, #CompeletedList do
			local AchievementInfo = self:GetAchievementInfo( CompeletedList[i] )
			if AchievementInfo ~= nil then
				local StrPlayerName = RichTextUtil.GetText(string.format(LSTR(720002), PlayerName), "d1ba8e")
				local Hyperlink = RichTextUtil.GetHyperlink(string.format(LSTR(720003), AchievementInfo.TextName or ""), 1, "d1ba8e", nil, nil, nil, nil, nil, false)
				local Content = string.format("%s%s%s", StrPlayerName, IconPath, Hyperlink)
				ChatMgr:ShareAchievement(CompeletedList[i], Content)
			end
		end
    end
	self.OtherPlayerAchievementMap = {}
end
------------------------------------ 数据查询

-- 根据成就类型Id 获取某类型完成数量
---@param TypeID number
function AchievementMgr:GetFinishAchievementNumFromType(TypeID)
	local Value = self:GetAchievementLevelRewardInfo(TypeID)
	if Value ~= nil then
		return Value.FinishAchieveNum
	end
	return 0
end

-- 获取当前目标成就数量
function AchievementMgr:GetTargetAchievementNum( )
	return #self.CollectAchieveIDList
end 

-- 根据成就类型Id 获取某类型等级
---@param TypeID number
function AchievementMgr:GetAchievementLevelFromType(TypeID)
	local Value = self:GetAchievementLevelRewardInfo(TypeID)
	if Value ~= nil then
		return Value.CurrentLevel
	end
	return 0
end

-- 根据成就类型Id 获取某类型等级奖励信息
---@param TypeID number
function AchievementMgr:GetAchievementLevelRewardInfo(TypeID)
	local Value, _ = table.find_item(self.LevelData, TypeID, "TypeID")
	if Value == nil then
		if TypeID == 0 then
			FLOG_WARNING(" No found achievement total level Info ! ")
		else
			FLOG_WARNING(string.format(" No found achievement level Info TypeID: %d ! ", TypeID))
		end
		return 
	end
	return Value
end

---查询当前成就有无被收藏
function AchievementMgr:IsCollectAchievement(AchievementID)
	return table.contain( self.CollectAchieveIDList, AchievementID)
end

-- 根据成就Id 判断是否达成成就
function AchievementMgr:GetAchievementFinishState(AchievemwntID)
	local Info = self:GetAchievementInfo(AchievemwntID)
	if Info ~= nil then
		return Info.IsFinish
	end
	return false
end

---收藏成就 成就列表
---@param IsAdd bool @true 增加  false 取消
---@param AchieveIDs table @成就id列表
function AchievementMgr:CollectAchievement(IsAdd, AchieveIDs)
	if IsAdd and self:GetTargetAchievementNum() >= AchievementDefine.TagetAchievementTotalNum then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.AchieveTargetNumLimit)
		return
	end
	self.CollectionCacheIDs = AchieveIDs
	self.CollectionCacheOperation = IsAdd
	self:OnNetMsgTargetListReq(IsAdd, AchieveIDs)
end

--  根据成就Id拿成就信息
function AchievementMgr:GetAchievementInfo( AchievementID )
	-- local Value, _ = table.find_item(self.AchievementDataList, AchievementID, "ID")
	return self.AchievementDataList[AchievementID]
end

--  领取成就奖励
function AchievementMgr:GetAchievementReward( AchievementIDList )
	LootMgr:SetDealyState(true)
	self:OnNetMsgClaimReq(AchievementIDList)
end

--  领取成就等级奖励  
---@param TypeID number      @类型ID
---@param Level number    @等级值
function AchievementMgr:GetAchievementLevelReward(TypeID, Level )
	LootMgr:SetDealyState(true)
	-- 将typeid 转为后台定义的 LevelType
	self:OnNetMsgLevelAwardyReq(TypeID, Level)
end

-- 根据成就类别Id 拿成就数据列表
---@param CategoryID number
function AchievementMgr:GetAchieveDataListFromCategoryID(CategoryID)
	return table.find_all_by_predicate(self.AchievementDataList, function(Item) return Item.CategoryID == CategoryID end) or {}
end

-- 根据成就类型Id 拿成就数据列表
---@param TypeID number
function AchievementMgr:GetAchieveDataListFromTypeID(TypeID)
	return table.find_all_by_predicate(self.AchievementDataList, function(Item) return Item.TypeID == TypeID end) or {}
end

-- 拿目标成就数据列表
function AchievementMgr:GetTargetAchievementDataList()
	local DataList = {}
	for i = 1, #self.CollectAchieveIDList do
		local AchievementInfo = self:GetAchievementInfo(self.CollectAchieveIDList[i])
		if AchievementInfo ~= nil then
			table.insert(DataList, AchievementInfo)
		else
			FLOG_WARNING(string.format(" No found target achievement data from id: %d ! ", self.CollectAchieveIDList[i]))
		end
	end 

	return DataList
end

-- 拿新成就数据列表
function AchievementMgr:GetNewAchievementDataList()
	local DataList = {}
	for i = 1, #self.NewAchieveIDList do 
		local AchievementInfo = self:GetAchievementInfo(self.NewAchieveIDList[i].ID)
		if AchievementInfo ~= nil then
			table.insert(DataList, AchievementInfo)
		else
			FLOG_WARNING(string.format(" No found new achievement from id: %d ! ", self.NewAchieveIDList[i].ID or -1 ))
		end
	end

	return DataList
end

function AchievementMgr:ClearCollectionReqCache( )
	self.CollectionCacheIDs = nil
	self.CollectionCacheOperation = nil
end

-- 判断成就Id列表中是否有可领取奖励的成就
function AchievementMgr:GetHaveRewardList(GetIDList)
	local HaveRewardIDList = {}
	for i = 1, #GetIDList do
		local AchievementInfo = self:GetAchievementInfo( GetIDList[i] )
		if AchievementInfo ~= nil then
			if AchievementInfo.HaveReward and AchievementInfo.IsFinish == true then
				table.insert(HaveRewardIDList, GetIDList[i])
			end
		end
	end
    return HaveRewardIDList
end

-- 是否能正常跳转到界面判断
--- @return bool  @true 可以开启
function AchievementMgr:CheckInterfaceActivation(Params)
	if Params == nil or Params.AchievemwntID == nil then
		return true
	end
	local CheckID = Params.AchievemwntID
	local AchieveInfo = self:GetAchievementInfo(CheckID)
	if AchievementMainPanelVM.TableViewTabsList == nil or AchieveInfo == nil then
		return false
	end
	local TypeMode = AchievementMainPanelVM.TableViewTabsList:Find(function(Item) return Item.TypeID == AchieveInfo.TypeID end)
	if TypeMode ~= nil and AchieveInfo.CategoryID ~= 0 then
		local CategoryVM = TypeMode:GetChildVM(AchieveInfo.CategoryID)
		if CategoryVM ~= nil then
			local AchievementHideType = ProtoRes.AchievementHideType
			if not ( not AchieveInfo.IsFinish and AchieveInfo.HideType == AchievementHideType.ACHIEVEMENT_HIDE_TYPE_HIDE_ACHIEVEMENT ) then
				return true
			end
		end
	end
	return false
end

------------------------------------ 界面

-- 打开成就等级奖励界面
function AchievementMgr:OpenTypeLevelRewardView()
	AchievementMainPanelVM:OpenTypeLevelRewardView()
end

-- 通过二级菜单打开主界面
function AchievementMgr:OpenAchievementEntryPanelView()
	self:LoadAllAchieveTextData()

	local Params = { CategoryID = AchievementDefine.OverviewCategoryDataTable[2].CategoryID }
	self:OpenAchievementMainPanelView(Params)
end

-- 根据成就Id 开启成就主界面
---@param AchieveID number
function AchievementMgr:OpenAchieveMainViewByAchieveID(AchieveID)
	local Params = { AchievemwntID = AchieveID }
	self:OpenAchievementMainPanelView(Params)
end

-- 打开成就主界面
---@param Params table       @目标成就id AchievemwntID  @目标成就类型id TypeID  @目标成就分类id CategoryID
function AchievementMgr:OpenAchievementMainPanelView(Params)
	self:LoadAllAchieveTextData()
	self:LoadAllAchieveShowData()
	if self.HaveNewAchieveFinish then
		AchievementMainPanelVM:LoadTypeData()
		self.HaveNewAchieveFinish = false
	end

	if self:CheckInterfaceActivation(Params) then
		-- Params.AchievemwntID or Params.TypeID or Params.CategoryID
		local MainView = UIViewMgr:FindView(UIViewID.AchievementMainPanel)
		if MainView == nil then 
			MainView = UIViewMgr:ShowView(UIViewID.AchievementMainPanel, Params)
		else
			MainView:SetParams(Params)
			MainView:OnShow()
		end
	else
		MsgTipsUtil.ShowTips(LSTR(720028))     -- "没有获得此成就，无法查看"
	end
end

--要返回当前类
return AchievementMgr