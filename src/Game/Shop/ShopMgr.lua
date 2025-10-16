---
--- Author: Alex
--- DateTime: 2023-02-03 18:27:31
--- Description: 商店系统
---
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ShopDefine = require("Game/Shop/ShopDefine")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemTypeCfg = require("TableCfg/ItemTypeCfg")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
--local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local MallCfg = require("TableCfg/MallCfg")
local MallMainTypeCfg = require("TableCfg/MallsMainTypeCfg")
local GoodsCfg = require("TableCfg/GoodsCfg")
-- local CondCfg = require("TableCfg/CondCfg")
--local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ActorMgr = require("Game/Actor/ActorMgr")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local QuestMgr = require("Game/Quest/QuestMgr")
local ScreenerInfoCfg = require("TableCfg/ScreenerInfoCfg")
local CounterCfg = require("TableCfg/CounterCfg")
local CounterMgr = require("Game/Counter/CounterMgr")
local CommScreenerVM = require("Game/Common/Screener/CommScreenerVM")
local GlobalCfg = require("TableCfg/GlobalCfg")
local SaveKey = require("Define/SaveKey")
local DataReportUtil = require("Utils/DataReportUtil")
local RichTextUtil = require("Utils/RichTextUtil")

local GoodsShowConditionType = ProtoRes.GoodsShowConditionType
local COUNTER_TYPE = ProtoRes.COUNTER_TYPE
local FILTER_MAINTYPE = ShopDefine.FILTER_MAINTYPE
local MainSortInfo = ShopDefine.MainSortInfo
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local MallTypeInfo = ProtoRes.MallTypeInfo
local ItemMainType = ProtoCommon.ItemMainType
local ItemTypeDetail = ProtoCommon.ITEM_TYPE_DETAIL
local ProfType = ProtoCommon.prof_type
local LSTR = _G.LSTR
local CondFailReason = _G.CondFailReason
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CsMallAndStoreCmd
local BagMgr
local EquipmentMgr
local ScoreMgr
local ConditionMgr
local LoginMgr
local FLOG_ERROR
local FLOG_WARNING
local specialization_type = ProtoCommon.specialization_type

--- 购买弹窗-武器详情-职业相关-显示颜色
local TipsColor_Blue = "#6fb1e9"
local TipsColor_Red = "#dc5868"
local TipsColor_Nomal = "#D5D5D5"
local ShopDefaultTipsID = 157031	--- 该商店将在后续开放，敬请期待 


---@class ShopMgr : MgrBase
---@field AllMallServerInfos table<number, ProtoRes.MallInfo> @所有商店信息
---@field MallTabDatas table<number, table> @商店tab页数据
---@field LastSelectState table @记录最后选中物品
---@field CurOpenMallId number @当前打开的商店id
---@field FilterSelectedData table @记录筛选器当前的选中项
local ShopMgr = LuaClass(MgrBase)

function ShopMgr:OnInit()
	self.AllMallServerInfos = {}
	self.MallTabDatas = {}
	self.LastSelectState = {} -- 记录最后选中物品
	self.CurOpenMallId = 0 -- 当前打开的商店id
	self.CurOpenMallCounterID = 0 -- 当前打开的商店计数器id
	self.FilterSelectedData = {}
	self.JumpToGoodsItemResID = nil -- 跳转到商店并打开选中特定商品道具ID
	self.ShopMainIndex = nil  --商会主界面Tab Index
	self.ShopMainTypeIndex = nil  --商店主界面主类 Index
	self.ShopMainTypeOpenList = {} --记录玩家关闭界面前最后点击的分类
	self.CurOpenShopGoodSList = {} -- 当前打开商店的货品信息
	self.CurFirstTypeGoodsList = {} --当前一级分类商品信息
	self.FilterAfterGoodsList = {} --筛选后商品信息
	self.FirstTypeIndex = 1 --当前打开商店的一级分类下标
	self.FilterIndexList = {} --筛选器下标
	self.CurChosedFilterIndex = 1 --当前选择的第一个筛选器下标
	self.OpenType = nil --交互打开商店类型
	self.BuyNum = 0 --购买商品数量
	self.OverlayNum = 0 --商品叠加数量
	self.OnceLimitation = 0 --一次批量购买上限
	self.CanChange = false
	self.LashChosedIndexList = {}
	self.JumpToGoodsState = false --是否是商品跳转商店状态
	self.JumpToShop = false --是否是跳转到商店状态
	self.CurQueryShopID = nil --当前查询的商店ID
	self.CurFirstTypeFilterList = {}
	self.AfterFistFilterList = {} --用于双筛选器 经过第一轮筛选过后
	self.CurQueryShopGoodsList = {}
	self.ShopMainSearchList = {}
	self.RedDotList = {}
	self.TabRedDotList = {}
	self.QueryResIDsInfoList = {}
	self.FilterSelectName1 = ""
	self.FilterSelectName2 = ""
	self.RedDotName = "Root/Mall/Goods"
	self.TabRedDotName = "Root/Mall/Tab"
	self.CurOpenTabInfo = {}
	self.CurShopVersion = ""
	self.GoodsCounterRedList = {}
	self.GoodsShowCondRedList = {}
	self.GoodsPurchaseCondRedList = {}
	self.IsJumpAgain = false
end

function ShopMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MALL_AND_STORE, SUB_MSG_ID.CS_MALL_AND_STORE_CMD_STORE_QUERY, self.OnNetMsgMallInfo)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MALL_AND_STORE, SUB_MSG_ID.CS_MALL_AND_STORE_CMD_STORE_PURCHASE, self.OnNetMsgMallInfoAfterBuy)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MALL_AND_STORE, SUB_MSG_ID.CS_MALL_AND_STORE_CMD_QUERY_RESIDS, self.OnNetMsgQueryResIDs)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MALL_AND_STORE, SUB_MSG_ID.CS_MALL_AND_STORE_CMD_BATCH_PRUCHASE, self.OnNetMsgBatchPruchase)
end

function ShopMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.ArmyExit, self.ExitArmyShop)
	--红点相关事件
	self:RegisterGameEvent(EventID.MajorLevelUpdate, self.DealMajorLevelUpdateRedDot) --使用等级
	self:RegisterGameEvent(EventID.MajorProfSwitch, self.DealProfRedDot) --职业 职业类型 职业限制
	self:RegisterGameEvent(EventID.FantasiaSuccessChangeRole, self.DealFantasiRedDot) --性别 种族变更
	self:RegisterGameEvent(EventID.ArmyLevelUpdate, self.UpdateArmyShop) --部队等级
	self:RegisterGameEvent(EventID.AchievementCompeleted, self.DealAchievementRedDot) --完成成就
	self:RegisterGameEvent(EventID.BattlePassGradeUpdate, self.DealBattlePassRedDot) --战令等级
	self:RegisterGameEvent(EventID.CompanySealRankUp, self.DealCompanyRankRedDot) --军衔等级
	self:RegisterGameEvent(EventID.CompanySealJionGrandCompany, self.DealCompanyIDRedDot) --所属军队
	self:RegisterGameEvent(EventID.UpdateQuest, self.DealFinisiTaskRedDot) --完成任务
	self:RegisterGameEvent(EventID.CounterUpdate, self.DealCounterUpdateRedDot) --限购计时器更新
	--self:RegisterGameEvent(EventID.BattlePassLevelUp, self.UpdateArmyShop) --已解锁职业满足等级要求
end

---OnBegin
function ShopMgr:OnBegin()
	BagMgr = require("Game/Bag/BagMgr")
	ScoreMgr = require("Game/Score/ScoreMgr")
	EquipmentMgr = require("Game/Equipment/EquipmentMgr")
	ConditionMgr = require("Game/Interactive/ConditionMgr")
	LoginMgr = require("Game/Login/LoginMgr")
	FLOG_ERROR = _G.FLOG_ERROR
	FLOG_WARNING = _G.FLOG_WARNING
	self:InitMallInfo()
	self:InitAllGoodsInfo()
	--self:InitAllGoodsItemInfo()
	local RecordStr = _G.UE.USaveMgr.GetString(SaveKey.ShopRecordRedDot, "", true)
	local RecordList = self:SetSaveString(RecordStr)
	self.RecordRemoveRedDotList = RecordList or {} --记录已添加过的红点
	self.CurShopVersion = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION).Value
end

function ShopMgr:OnEnd()
	local RecordStr = table_to_string(self.RecordRemoveRedDotList)
	_G.UE.USaveMgr.SetString(SaveKey.ShopRecordRedDot, RecordStr, true)
end

function ShopMgr:OnGameEventLoginRes(Params)
	if not Params.bReconnect then
		self:ClearOldRoleMallData()
		self:GoodsRedClassify()
	end
end

function ShopMgr:InitMallInfo()
	local AllMallCfg = MallCfg:FindAllCfg()
	self.AllShopInfo = {}
	for _, v in ipairs(AllMallCfg) do
		self.AllShopInfo[v.ID] = v
	end
end

-- 内存占用比较多 改成不缓存ItemCfg, 为了不改动访问ItemInfo的代码 改成元表获取
local GetItemInfoMT =
{
	__index = function(T, K)
		if K == "ItemInfo" then
			return ItemCfg:FindCfgByKey(T.GoodsInfo.Items[1].ID)
		end
	end
}

function ShopMgr:InitAllGoodsInfo()
	-- 优化前存储内容：{ID = GoodsCfg.ID,  Name=GoodsCfg.Name, 等其他从GoodsCfg复制的内容, ItemInfo = ItemCfg}
	-- 优化后存储内容： { GoodsInfo = GoodsCfg, ItemInfo = ItemCfg }
	-- GoodsCfg占用内存比较多，优化后避免了复制， 且避免没用到的字段被解析
	-- GoodsInfo对应类型是GoodsCfg, ItemInfo对应类型是ItemCfg, 很多地方用到所以保持之前的命名
	self.AllGoodsInfo = {}
	for MallID, _ in pairs(self.AllShopInfo) do
		local SearchCond = string.format("MallID == %d", MallID)
		local Gcfgs = GoodsCfg:FindAllCfg(SearchCond)
		local GoodsData = {}
		for _, Cfg in pairs(Gcfgs) do
			GoodsData[Cfg.ID] = setmetatable({ GoodsInfo = Cfg }, GetItemInfoMT)
		end
		self.AllGoodsInfo[MallID] = GoodsData
	end
end

function ShopMgr:InitAllGoodsItemInfo()
	for MallID, GoodsInfo in pairs(self.AllGoodsInfo) do
		for Key, Value in pairs(GoodsInfo) do
			local ItemInfo = ItemCfg:FindCfgByKey(Value.GoodsInfo.Items[1].ID)
			self.AllGoodsInfo[MallID][Key].ItemInfo = ItemInfo
		end
	end
end

function ShopMgr:GoodsRedClassify()
	for MallID, GoodsList in pairs(self.AllGoodsInfo) do
		if self.AllShopInfo[MallID].IsPortable == 1 and self.AllShopInfo[MallID].RedIsOn == 1 then
			for _, GoodsData in pairs(GoodsList) do
				local GoodsInfo = GoodsData.GoodsInfo
				if GoodsInfo.GoodsCounterFirst ~= 0 or GoodsInfo.GoodsCounterSecond ~= 0 then --计数器红点相关
					self.GoodsCounterRedList[GoodsInfo.ID] = GoodsInfo
					--table.insert(self.GoodsCounterRedList, GoodsInfo)
				end

				if GoodsInfo.ShowConditions[1] then --展示条件红点
					if GoodsInfo.ShowConditions[1].CondType ~= 0 then
						for _, v in pairs(GoodsInfo.ShowConditions) do
							local Value = v.Values
							self:ConditionStub(v.CondType, Value, self.GoodsShowCondRedList, GoodsInfo, true)
						end
					end
				end

				if GoodsInfo.PurchaseConditions[1] then --购买条件红点
					if GoodsInfo.PurchaseConditions[1].CondType ~= 0 then
						for _, v in pairs(GoodsInfo.PurchaseConditions) do
							local Value = v.Values
							self:ConditionStub(v.CondType, Value, self.GoodsPurchaseCondRedList, GoodsInfo, false)
						end
					end
				end
			end
		end
	end
end

function ShopMgr:ConditionStub(CondType, Data, List, GoodsInfo, IsShowCond)
	local Values
	if IsShowCond then
		Values = Data[1][1]
	else
		Values = Data[1]
	end
	if type(CondType) == "number" and Values then
		if List[CondType] == nil then
			List[CondType] = {}
			List[CondType][Values] = {}
			self:AttCondType(List, CondType, Data, Values, GoodsInfo)
		else
			if List[CondType][Values] == nil then
				List[CondType][Values] = {}
				self:AttCondType(List, CondType, Data, Values, GoodsInfo)
			else
				self:AttCondType(List, CondType, Data, Values, GoodsInfo)
			end
		end
	end
end

function ShopMgr:AttCondType(List, CondType, Data, Values, GoodsInfo)
	if CondType == GoodsShowConditionType.GOODS_SHOW_COND_ACHIEVEMENT then
		local AchieveList = Data
		for i = 1, #AchieveList do
			local CondValue
			if type(AchieveList[i]) == "table" then
				CondValue = AchieveList[i][1]
			else
				CondValue = AchieveList[i]
			end

			List[CondType] = List[CondType] or {}
			List[CondType][CondValue] = List[CondType][CondValue] or {}
			table.insert(List[CondType][CondValue], GoodsInfo)
		end
	elseif CondType == GoodsShowConditionType.GOODS_SHOW_UnLock_Job_Lv then
		local Info = {}
		local Prof
		local NeedLv
		if type(Data[1]) == "number" then
			Prof = Data[1]
			NeedLv = Data[2]
		else
			Prof = Data[1][1]
			NeedLv = Data[1][2]
		end
		Info.Prof = Prof
		Info.NeedLv = NeedLv
		Info.GoodsInfo = GoodsInfo

		List[CondType] = List[CondType] or {}
		List[CondType][Prof] = List[CondType][Prof] or {}
		table.insert(List[CondType][Prof], GoodsInfo)
	else
		local CondValue
		if type(Values) == "table" then
			CondValue = Values[1]
		else
			CondValue = Values
		end
		
		if not List[CondType] or CondValue == nil then
			return
		end

		if List[CondType] ~= nil and List[CondType][CondValue] == nil then
			List[CondType][CondValue] = {}
		end
		table.insert(List[CondType][CondValue], GoodsInfo)
	end
end

function ShopMgr:ExitArmyShop()
	local ShopMainViewVisible = UIViewMgr:IsViewVisible(UIViewID.ShopMainPanelView)
	local BuyViewVisible = UIViewMgr:IsViewVisible(UIViewID.ShopBuyPropsWinView)
	if ShopMainViewVisible then
		if BuyViewVisible then
			UIViewMgr:HideView(UIViewID.ShopBuyPropsWinView)
		end
		UIViewMgr:HideView(UIViewID.ShopMainPanelView)
	end
end

function ShopMgr:UpdateArmyShop(Lv)
	local ShopMainViewVisible = UIViewMgr:IsViewVisible(UIViewID.ShopMainPanelView)
	local BuyViewVisible = UIViewMgr:IsViewVisible(UIViewID.ShopBuyPropsWinView)
	local FirstShop = 6001
	local SecondShop = 6002
	local ThirdShop = 6003
	if ShopMainViewVisible then
		if BuyViewVisible then
			UIViewMgr:HideView(UIViewID.ShopBuyPropsWinView)
		end
		UIViewMgr:HideView(UIViewID.ShopMainPanelView)
		local Tips = LSTR(1200016)
		_G.MsgTipsUtil.ShowTips(Tips)
		if Lv == 4 and self.CurOpenMallId == FirstShop then
			self:SendMsgMallInfoReq(FirstShop, self.OpenType)
		elseif Lv == 8 and self.CurOpenMallId == SecondShop then
			self:SendMsgMallInfoReq(FirstShop, self.OpenType)
		elseif Lv == 12 and self.CurOpenMallId == ThirdShop then
			self:SendMsgMallInfoReq(FirstShop, self.OpenType)
		end
	end

	local ArmyShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_ARMY_LV] or {}
	local ArmyBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_ARMY_LV] or {}
	if ArmyShowList[Lv] then
		for _, GoodsInfo in pairs(ArmyShowList[Lv]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
	if ArmyBuyList[Lv] then
		for _, GoodsInfo in pairs(ArmyBuyList[Lv]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
end

--------------------红点相关start--------------------------------
function ShopMgr:DealMajorLevelUpdateRedDot()
	local ProfID = MajorUtil.GetMajorProfID()
	local MajorLevel = MajorUtil.GetMajorLevelByProf(ProfID)
	local RoleDetail = ActorMgr:GetMajorRoleDetail()
	local ProfList = RoleDetail.Prof.ProfList
	self:DealUseLvRedDot(MajorLevel)
	self:DealComBatMaxLvRedDot(MajorLevel, ProfList)
	self:DealManuMaxLvRedDot(MajorLevel, ProfList)
end

--使用等级
function ShopMgr:DealUseLvRedDot(MajorLevel)
	local ShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_UseLv] or {}
	local BuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_UseLv] or {}
	if ShowList[MajorLevel] then
		for _, GoodsInfo in pairs(ShowList[MajorLevel]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end

	if BuyList[MajorLevel] then
		for _, GoodsInfo in pairs(BuyList[MajorLevel]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end

	--已解锁职业等级
	local UnLockJobShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_UnLock_Job_Lv] or {}
	local UnLockJobBuyList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_UnLock_Job_Lv] or {}
	for Cond, GoodsList in pairs(UnLockJobShowList) do
		local ProfLv = MajorUtil.GetMajorLevelByProf(Cond) or 0
		if ProfLv > 0 then
			for _, Info in pairs(GoodsList) do
				if ProfLv >= Info.NeedLv then
					self:AddGoodsRedDot(Info.GoodsInfo.ID)
					self:AddTabRedDot(Info.GoodsInfo.FirstType)
				end
			end
		end
	end

	for Cond, GoodsList in pairs(UnLockJobBuyList) do
		local ProfLv = MajorUtil.GetMajorLevelByProf(Cond) or 0
		if ProfLv > 0 then
			for _, Info in pairs(GoodsList) do
				if ProfLv >= Info.NeedLv then
					self:AddGoodsRedDot(Info.GoodsInfo.ID)
					self:AddTabRedDot(Info.GoodsInfo.FirstType)
				end
			end
		end
	end
end

--战斗职业最高等级
function ShopMgr:DealComBatMaxLvRedDot(MajorLevel, ProfList)
	local ShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_COMBAT_MAX_LV] or {}
	local BuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_COMBAT_MAX_LV] or {}
	if ShowList[MajorLevel] then
		for _, GoodsInfo in pairs(ShowList[MajorLevel]) do
			for _, v in pairs(ProfList) do
				local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
				if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
					local CurLv = v.Level
					local NeedLv = MajorLevel
					if CurLv >= NeedLv then
						self:AddGoodsRedDot(GoodsInfo.ID)
						self:AddTabRedDot(GoodsInfo.FirstType)
					end
				end
			end
		end
	end

	if BuyList[MajorLevel] then
		local RoleDetail = ActorMgr:GetMajorRoleDetail()
		local ProfList = RoleDetail.Prof.ProfList
		for _, GoodsInfo in pairs(BuyList[MajorLevel]) do
			for _, v in pairs(ProfList) do
				local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
				if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
					local CurLv = v.Level
					local NeedLv = MajorLevel
					if CurLv >= NeedLv then
						self:AddGoodsRedDot(GoodsInfo.ID)
						self:AddTabRedDot(GoodsInfo.FirstType)
					end
				end
			end
		end
	end
end

--生产职业最高等级
function ShopMgr:DealManuMaxLvRedDot(MajorLevel, ProfList)
	local ShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_MANU_MAX_LV] or {}
	local BuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_MANU_MAX_LV] or {}
	if ShowList[MajorLevel] then
		for _, GoodsInfo in pairs(ShowList[MajorLevel]) do
			for _, v in pairs(ProfList) do
				local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
				if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
					local CurLv = v.Level
					local NeedLv = MajorLevel
					if CurLv >= NeedLv then
						self:AddGoodsRedDot(GoodsInfo.ID)
						self:AddTabRedDot(GoodsInfo.FirstType)
					end
				end
			end
		end
	end

	if BuyList[MajorLevel] then
		local RoleDetail = ActorMgr:GetMajorRoleDetail()
		local ProfList = RoleDetail.Prof.ProfList
		for _, GoodsInfo in pairs(BuyList[MajorLevel]) do
			for _, v in pairs(ProfList) do
				local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
				if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
					local CurLv = v.Level
					local NeedLv = MajorLevel
					if CurLv >= NeedLv then
						self:AddGoodsRedDot(GoodsInfo.ID)
						self:AddTabRedDot(GoodsInfo.FirstType)
					end
				end
			end
		end
	end
end

function ShopMgr:DealProfRedDot()
	local JobTyepShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_JobType] or {}
	local JobTyepBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_JobType] or {}
	local JobShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_Job] or {}
	local JobBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_Job] or {}

	local ProfID = MajorUtil.GetMajorProfID()
	local MajorClass = RoleInitCfg:FindProfClass(ProfID)
	if JobTyepShowList[MajorClass] then
		for _, GoodsInfo in pairs(JobTyepShowList[MajorClass]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
	if JobTyepBuyList[MajorClass] then
		for _, GoodsInfo in pairs(JobTyepBuyList[MajorClass]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end

	if JobShowList[ProfID] then
		for _, GoodsInfo in pairs(JobTyepShowList[ProfID]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
	if JobBuyList[ProfID] then
		for _, GoodsInfo in pairs(JobTyepBuyList[ProfID]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
end

function ShopMgr:DealFantasiRedDot(Data)
	if Data.OldSimple.Gender ~= Data.NewSimple.Gender then
		local SexShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_Sex] or {}
		local SexBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_Sex] or {}
		local CurGender = Data.NewSimple.Gender
		if SexShowList[CurGender] then
			for _, GoodsInfo in pairs(SexShowList[CurGender]) do
				self:AddGoodsRedDot(GoodsInfo.ID)
				self:AddTabRedDot(GoodsInfo.FirstType)
			end
		end

		if SexBuyList[CurGender] then
			for _, GoodsInfo in pairs(SexBuyList[CurGender]) do
				self:AddGoodsRedDot(GoodsInfo.ID)
				self:AddTabRedDot(GoodsInfo.FirstType)
			end
		end
	end

	if Data.OldSimple.Race ~= Data.NewSimple.Race then
		local RaceShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_Sex] or {}
		local RaceBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_Sex] or {}
		local CurRace = Data.NewSimple.Race
		if RaceShowList[CurRace] then
			for _, GoodsInfo in pairs(RaceShowList[CurRace]) do
				self:AddGoodsRedDot(GoodsInfo.ID)
				self:AddTabRedDot(GoodsInfo.FirstType)
			end
		end

		if RaceBuyList[CurRace] then
			for _, GoodsInfo in pairs(RaceBuyList[CurRace]) do
				self:AddGoodsRedDot(GoodsInfo.ID)
				self:AddTabRedDot(GoodsInfo.FirstType)
			end
		end
	end
end

function ShopMgr:DealAchievementRedDot(ID)
	local AchievementShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_ACHIEVEMENT] or {}
	local AchievementBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_COND_ACHIEVEMENT] or {}
	if AchievementShowList[ID] then
		for _, GoodsInfo in pairs(AchievementShowList[ID]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
	if AchievementBuyList[ID] then
		for _, GoodsInfo in pairs(AchievementBuyList[ID]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
end

function ShopMgr:DealBattlePassRedDot(Data)
	local Lv = Data.Grade
	local BPShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_BATTLEPASS_LV] or {}
	local BPBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_BATTLEPASS_LV] or {}
	if BPShowList[Lv] then
		for _, GoodsInfo in pairs(BPShowList[Lv]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
	if BPBuyList[Lv] then
		for _, GoodsInfo in pairs(BPBuyList[Lv]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
end

function ShopMgr:DealCompanyRankRedDot(Lv)
	local CompanyRankShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_GRANDCOMPANY_LV] or {}
	local CompanyRankBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_GRANDCOMPANY_LV] or {}
	if CompanyRankShowList[Lv] then
		for _, GoodsInfo in pairs(CompanyRankShowList[Lv]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
	if CompanyRankBuyList[Lv] then
		for _, GoodsInfo in pairs(CompanyRankBuyList[Lv]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
end

function ShopMgr:DealCompanyIDRedDot(ID)
	local CompanyIDShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_GRANDCOMPANY_ID] or {}
	local CompanyIDBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_GRANDCOMPANY_ID] or {}
	if CompanyIDShowList[ID] then
		for _, GoodsInfo in pairs(CompanyIDShowList[ID]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
	if CompanyIDBuyList[ID] then
		for _, GoodsInfo in pairs(CompanyIDBuyList[ID]) do
			self:AddGoodsRedDot(GoodsInfo.ID)
			self:AddTabRedDot(GoodsInfo.FirstType)
		end
	end
end

function ShopMgr:DealFinisiTaskRedDot(Data)
	local FinishiTaskID = 0
	if Data.UpdatedRspQuests ~= nil and #Data.UpdatedRspQuests > 0 then
		FinishiTaskID = Data.UpdatedRspQuests[1].QuestID or 0
		local FinisiTaskShowList = self.GoodsShowCondRedList[GoodsShowConditionType.GOODS_SHOW_FINISHI_TASK] or {}
		local FinisiTaskBuyList = self.GoodsPurchaseCondRedList[GoodsShowConditionType.GOODS_SHOW_FINISHI_TASK] or {}

		if FinisiTaskShowList[FinishiTaskID] then
			for _, GoodsInfo in pairs(FinisiTaskShowList[FinishiTaskID]) do
				self:AddGoodsRedDot(GoodsInfo.ID)
				self:AddTabRedDot(GoodsInfo.FirstType)
			end
		end
		if FinisiTaskBuyList[FinishiTaskID] then
			for _, GoodsInfo in pairs(FinisiTaskBuyList[FinishiTaskID]) do
				self:AddGoodsRedDot(GoodsInfo.ID)
				self:AddTabRedDot(GoodsInfo.FirstType)
			end
		end
	end
end


function ShopMgr:DealCounterUpdateRedDot(Params)
	if Params.UpdatedCounters then
		for CounterID, Value in pairs(Params.UpdatedCounters) do
			local CounterList = self.GoodsCounterRedList or {}

			if CounterList then
				for _, GoodsInfo in pairs(CounterList) do
					if GoodsInfo.GoodsCounterFirst == CounterID or GoodsInfo.GoodsCounterSecond == CounterID then
						local CurrentRestore = CounterMgr:GetCounterRestore(CounterID)
						if Value >= CurrentRestore then
							self:AddGoodsRedDot(GoodsInfo.ID, true)
							self:AddTabRedDot(GoodsInfo.FirstType)
						end
					end
				end
			end
		end
	end

end


function ShopMgr:AddGoodsRedDot(GoodsID, IsNoRecord)
	local RecordState = IsNoRecord or false
	if not table.contain(self.RedDotList, GoodsID) and not table.contain(self.RecordRemoveRedDotList, GoodsID) then
		local RedDotName = self.RedDotName .. "/" .. tostring(GoodsID)
		_G.RedDotMgr:AddRedDotByName(RedDotName, 1)
		table.insert(self.RedDotList, GoodsID)
		if not RecordState then
			table.insert(self.RecordRemoveRedDotList, GoodsID)
		end
	end
end

function ShopMgr:AddTabRedDot(FirstType)
	if not table.contain(self.TabRedDotList, FirstType) then
		local TabRedDotName = self.TabRedDotName .. "/" .. tostring(FirstType)
		_G.RedDotMgr:AddRedDotByName(TabRedDotName, 1)
		table.insert(self.TabRedDotList, FirstType)
	end
end

function ShopMgr:RemoveRedDot(ID)
	if table.contain(self.RedDotList, ID) then
		local RedDotName = self.RedDotName .. "/" .. tostring(ID)
		table.remove_item(self.RedDotList, ID)
		_G.RedDotMgr:DelRedDotByName(RedDotName)
	end
end

function ShopMgr:RemoveTabRedDot(FirstType)
	if table.contain(self.TabRedDotList, FirstType) then
		local RedDotName = self.TabRedDotName .. "/" .. tostring(FirstType)
		table.remove_item(self.TabRedDotList, FirstType)
		_G.RedDotMgr:DelRedDotByName(RedDotName)
	end
end

function ShopMgr:RemoveFirstTypeAllRed(List)
	for i = 1, #List do
		if table.contain(self.RedDotList, List[i].GoodsId) then
			local RedDotName = self.RedDotName .. "/" .. tostring(List[i].GoodsId)
			table.remove_item(self.RedDotList, List[i].GoodsId)
			_G.RedDotMgr:DelRedDotByName(RedDotName)
		end
	end
end

function ShopMgr:RemoveRecordRedDot(GoodsID, FirstType)
	if table.contain(self.RedDotList, GoodsID) then
		--table.remove_item(self.TabRedDotList, FirstType)
		local RedDotName = self.RedDotName .. "/" .. tostring(GoodsID)
		_G.RedDotMgr:DelRedDotByName(RedDotName)
		table.remove_item(self.RecordRemoveRedDotList, GoodsID)
	end
end

function ShopMgr:SetCurFistTypeRedDot(FirstType, GoodsID)
	if not self.FirstTypeAllRed then
		self.FirstTypeAllRed = {}
	end

	if not self.FirstTypeAllRed[FirstType] then
		self.FirstTypeAllRed[FirstType] = {}
	end

	if not table.contain(self.FirstTypeAllRed[FirstType], GoodsID) and table.contain(self.RedDotList, GoodsID) then
		table.insert(self.FirstTypeAllRed[FirstType], GoodsID)
	end
end

function ShopMgr:RemoveFistTypeRedDot(FirstType, GoodsID)
	if table.contain(self.FirstTypeAllRed[FirstType], GoodsID) then
		table.remove_item(self.FirstTypeAllRed[FirstType], GoodsID)
	end

	return self.FirstTypeAllRed[FirstType]
end
--------------------红点相关End--------------------------------

--- 申请具体id的商店信息
---@param MallId number@商店id
---@param Type number@打开类型 1 从商会打开商店  2 从Npc打开商店
---@param bool IsJump@是否通过跳转
function ShopMgr:SendMsgMallInfoReq(MallId, Type, IsJump)
	local ShopInfo = self.AllShopInfo[MallId]
	if ShopInfo == nil then
		return
	end
	self.CurOpenShopType = ShopInfo.ShopType
	local MsgID = CS_CMD.CS_CMD_MALL_AND_STORE
	local SubMsgID = SUB_MSG_ID.CS_MALL_AND_STORE_CMD_STORE_QUERY
	self.OpenType = Type
	self.CurQueryShopGoodsList = self.AllGoodsInfo[MallId]
	self.SpeciaGoodsList = {}

	if self.CurOpenShopType == MallTypeInfo.MALL_TYPE_Statistic then
		for _, GoodsData in pairs(self.CurQueryShopGoodsList) do
			local IsSpeciaGoods = self:IsQueryByServer(GoodsData.GoodsInfo)
			if IsSpeciaGoods then
				table.insert(self.SpeciaGoodsList, GoodsData.GoodsInfo.ID)
			end
		end
	end
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.StoreQuery = {}
	MsgBody.StoreQuery.MallID = MallId
	if #self.SpeciaGoodsList > 0 then
		MsgBody.StoreQuery.CondGoodIDs = self.SpeciaGoodsList
	end

	local Source = IsJump and 2 or 1
	self:ReportShopData(2, MallId, self.InletMainIndex, Source)
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	--FLOG_ERROR("ShopMgr:SendMsgMallInfoReq Time:%s", TimeUtil.GetLocalTime())
end

--- 购买具体id的特定数量商品
---@param GoodsId number@商品id
---@param Count number@购买数量
function ShopMgr:SendMsgMallInfoBuy(GoodsId, Count)
	local MsgID = CS_CMD.CS_CMD_MALL_AND_STORE
	local SubMsgID = SUB_MSG_ID.CS_MALL_AND_STORE_CMD_STORE_PURCHASE

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.StorePurchase = {}
	MsgBody.StorePurchase.GoodID = GoodsId
	MsgBody.StorePurchase.Num = Count
	self.BuyNum = Count
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 批量购买请求
---@param BatchList table  @批量购买数组 类型为{{GoodID = x, Num = x},{GoodID = x1, Num = x1}}
function ShopMgr:SendMsgMallInfoBatchPruchase(BatchList)
	local MsgID = CS_CMD.CS_CMD_MALL_AND_STORE
	local SubMsgID = SUB_MSG_ID.CS_MALL_AND_STORE_CMD_BATCH_PRUCHASE

	local MsgBody = {
		Cmd = SubMsgID,
		BatchPruchase = {Infos = BatchList}
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ShopMgr:SendQueryResIDs(IDsList, InfoList)
	local MsgID = CS_CMD.CS_CMD_MALL_AND_STORE
	local SubMsgID = SUB_MSG_ID.CS_MALL_AND_STORE_CMD_QUERY_RESIDS

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.QueryResIDs = {}
	MsgBody.QueryResIDs.Ids = IDsList
	self.QueryResIDsInfoList = InfoList
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 申请所有商店信息
function ShopMgr:OnNetMsgMallInfo(MsgBody)
	--FLOG_ERROR("OnNetMsgMallInfo = %s",table_to_string(MsgBody))
	if nil == MsgBody then
		return
	end

	-- local co = coroutine.create(self.UpdateSpecificMallInfo)
	-- _G.SlicingMgr:EnqueueCoroutine(co, self, MsgBody)

	self:UpdateSpecificMallInfo(MsgBody)
end

--- 购买商品后更新商店信息
function ShopMgr:OnNetMsgMallInfoAfterBuy(MsgBody)
	if nil == MsgBody then
		return
	end

	local MallInfo = MsgBody.StorePurchase
	self:OnShowCommRewardFunc({[1] = MallInfo.Good})
end

--- 批量购买
function ShopMgr:OnNetMsgBatchPruchase(MsgBody)
	if nil == MsgBody then
		return
	end

	local MallInfo = MsgBody.BatchPruchase
	local Infos = MallInfo.Infos
	self:OnShowCommRewardFunc(Infos)
end

-- 购买协议后打开通用恭喜获得界面
function ShopMgr:OnShowCommRewardFunc(PurchasedIDList)
	local MallInfoList = {}
	local ItemList = {}
	local SocreState = true
	for i = 1, #PurchasedIDList do
		local MallInfo = PurchasedIDList[i]
		local GoodID = MallInfo.GoodID
		local GoodsInfo
		GoodsInfo = self:GetGoodsInfo(self.CurOpenMallId, GoodID)
		if not GoodsInfo then
			FLOG_ERROR("OnShowCommRewardFunc not GoodsInfo GoodsID = %d", GoodID)
			return
		end
		
		local ItemID = GoodsInfo.Items[1].ID
		local IsPop = GoodsInfo.PopOut
		if IsPop == 1 then
			if GoodID and GoodID ~= 0 then
				local GetNum
				if self.OverlayNum > 1 and self.OnceLimitation == 1 then
					GetNum = self.OverlayNum
				else
					GetNum = self.BuyNum
				end
				table.insert(ItemList,
				{
					ResID = ItemID,
					Num = GetNum,
				})
			end
		end
		if not self:GetGoodsSocreInfoState(GoodID) and SocreState then
			SocreState = false
		end

		--有限购类的才刷新界面商品信息
		if GoodsInfo.GoodsCounterFirst and GoodsInfo.GoodsCounterFirst ~= 0 then
			table.insert(MallInfoList, MallInfo)
		end
	end

	if not table.is_nil_empty(ItemList) then
		UIViewMgr:ShowView(UIViewID.CommonRewardPanel, {ItemList = ItemList, Title = LSTR(1200077)})
	end

	if #MallInfoList > 0 then
		for _, MallInfo in ipairs(MallInfoList) do
			self:UpdateGoodsInfoAfterBuy(MallInfo)
		end
	end

	--如果交换商店全是item类型不会触发SocreMgr的更新通知 所以手动更新一下
	if not SocreState then
		EventMgr:SendEvent(EventID.UpdateScore)
	end
end


--搜索服务器查询条件回包
function ShopMgr:OnNetMsgQueryResIDs(MsgBody)
	if nil == MsgBody then
		return
	end

	local GoodsList = {}
	local QueryResIDs = MsgBody.QueryResIDs
	local GoodsInfo = QueryResIDs.Infos
	local GoodsConds = QueryResIDs.Conds
	for Index, Info in pairs(GoodsInfo) do
		if self.QueryResIDsInfoList[Info.GoodID] then
			local Data = {}
			Data.Infos = Info
			Data.Conds = GoodsConds[Index]
			Data.ShopID = self.QueryResIDsInfoList[Info.GoodID]
			GoodsList[Info.GoodID] = Data
		end
	end

	self:SetAfterServerSearch(GoodsList)
	EventMgr:SendEvent(EventID.UpdateSerchGoods, self.ShopMainSearchList)
	self.QueryResIDsInfoList = {}
end

--获取商品所需货币信息
function ShopMgr:GetGoodsSocreInfoState(GoodsId)
	local Cfg = self:GetGoodsInfo(self.CurOpenMallId, GoodsId)
	if Cfg == nil then
		return
	end

	local IsHaveScore = false
	local ScoreInfo = Cfg.Price
	local ScoreType = ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE
	for i = 1, #ScoreInfo do
		if ScoreInfo[i].Type == ScoreType then
			IsHaveScore = true

			break
		end
	end

	return IsHaveScore
end

--是否需要通过后台查询购买条件
function ShopMgr:IsQueryByServer(Goods, IsSearch)
	local ShowConditions = Goods.ShowConditions
	local PurchaseConditions = Goods.PurchaseConditions
	if next(PurchaseConditions) == nil and next(ShowConditions) == nil then
		return false
	end

	for i = 1, #ShowConditions do
		local Cond = ShowConditions[i]
		if Cond and Cond.CondType ~= 0 then
			local CondType = Cond.CondType
			local CondValues = Cond.Values
			if type(CondType) == "number" and CondValues ~= nil and next(CondValues) ~= nil then
				if CondType == GoodsShowConditionType.GOODS_SHOW_STATISTIC_VALUE then  --统计值
					return true
				end
			end
		end
	end

	for i = 1, #PurchaseConditions do
		local Cond = PurchaseConditions[i]
		if Cond then
			local CondType = Cond.CondType
			local CondValues = Cond.Values
			if type(CondType) == "number" and CondValues ~= nil and next(CondValues) ~= nil then
				if CondType == GoodsShowConditionType.GOODS_SHOW_STATISTIC_VALUE then  --统计值
					return true
				end
			end
		end
	end

	return false
end

--- 商品是否可展示
---@param Goods number@商品
function ShopMgr:IsCanShow(Goods)
	local TmpGoodsCfg = Goods
	if TmpGoodsCfg == nil then
		return false
	end

	local CurVersionIsShow

	--ShowVersion优先级比OnVersion高，有些商品需要在ShowVersion版本号内展示，在OnVersion版本号内才可以购买，所以分开
	if Goods.ShowVersion and Goods.ShowVersion ~= "" then
		CurVersionIsShow = self:IsOnVersion(Goods.ShowVersion, Goods.OffVersion)
	else
		CurVersionIsShow = self:IsOnVersion(Goods.OnVersion, Goods.OffVersion)
	end

	if not CurVersionIsShow then
		return false
	end

	--商品是否在上架时间内
	local OnTime = self:GetTimeIsEnable(TmpGoodsCfg)
	if not OnTime then
		return false
	end

	local ShowConditions = TmpGoodsCfg.ShowConditions
	if ShowConditions == nil or next(ShowConditions) == nil then
		return true
	end


	local ProfID = MajorUtil.GetMajorProfID()
	local RoleDetail = ActorMgr:GetMajorRoleDetail() or {}
	local MajorClass = RoleInitCfg:FindProfClass(ProfID)
	local MajorGender = MajorUtil.GetMajorGender()
	local MajorRace = MajorUtil.GetMajorRaceID()
	local CurrentProfInfo = {}

	if not RoleDetail then
		FLOG_ERROR("ShopMgr:IsCanShow RoleDetail = nil")
	end

	local ProfList = RoleDetail.Prof and RoleDetail.Prof.ProfList or {}
	for _, value in pairs(ProfList) do
		if value.ProfID == ProfID then
			CurrentProfInfo = value
			break
		end
	end

	---配表展示条件
	for i = 1, #ShowConditions do
		local Cond = ShowConditions[i]
		if Cond and Cond.CondType ~= 0 then
			local CondType = Cond.CondType
			local CondValues = Cond.Values
			if type(CondType) == "number" and CondValues ~= nil and next(CondValues) ~= nil then
				if CondType == GoodsShowConditionType.GOODS_SHOW_COND_UseLv then  --使用等级
					local ProfLevel = CurrentProfInfo.Level
					if ProfLevel < CondValues[1][1] then
						--FLOG_ERROR("no show 1 = %s",DescContent)
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_JobType then  --职业类型限制
					if CondValues[1][1] ~= ProtoCommon.class_type.CLASS_TYPE_NULL and CondValues[1] ~= MajorClass then
						--FLOG_ERROR("no show 2 = %s",DescContent)
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_Job then  --职业限制
					local ProfLimit = CondValues
					if type(ProfLimit) == "table" then
						local bHasLimit = false
						local bProfHas = false
						for _, v in pairs(ProfLimit) do
							if v ~= ProtoCommon.prof_type.PROF_TYPE_NULL then
								bHasLimit = true
								if v == ProfID then
									bProfHas = true
									break
								end
							end
						end
						if bHasLimit == true and bProfHas == false then
							--FLOG_ERROR("no show 3 = %s",DescContent)
							return false
						end
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_Sex then  --性别限制
					local LimitGender = CondValues[1][1]
					if LimitGender ~= ProtoCommon.role_gender.GENDER_UNKNOWN and LimitGender ~= MajorGender then
						--FLOG_ERROR("no show 4 = %s",DescContent)
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_Race then  --种族限制
					local RaceTypeLimit = CondValues[1][1]
					if RaceTypeLimit ~= ProtoCommon.race_type.RACE_TYPE_NULL and MajorRace ~= RaceTypeLimit then
						--FLOG_ERROR("no show 5 = %s",DescContent)
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_COMBAT_MAX_LV then  --战斗职业最高等级
					local IsCan = false
					local DescContent
					if #Cond.Desc > 0 then
						DescContent = Cond.Desc[1][1]
					end
					for _, v in pairs(ProfList) do
						local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
						if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
							local CurLv = v.Level
							local NeedLv = CondValues[1][1]

							if CurLv >= NeedLv then
								IsCan = true
								break
							end
						end
					end
					return IsCan, DescContent
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_MANU_MAX_LV then  --生产职业最高等级
					local IsCan = false
					local DescContent
					if #Cond.Desc > 0 then
						DescContent = Cond.Desc[1][1]
					end
					for _, v in pairs(ProfList) do
						local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
						if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
							local CurLv = v.Level
							local NeedLv = CondValues[1][1]

							if CurLv >= NeedLv then
								IsCan = true
								break
							end
						end
					end
					return IsCan, DescContent
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_ARMY_LV then  --部队等级
					local CurLv = _G.ArmyMgr:GetArmyLevel() or 0
					local NeedLv = CondValues[1][1]
					if CurLv < NeedLv then
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_ACHIEVEMENT then  --完成成就
					local IsCan = false
					local AchieveList = CondValues[1]
					for i = 1, #AchieveList do
						local IsFinish = _G.AchievementMgr:GetAchievementFinishState(AchieveList[i])
						if IsFinish then
							IsCan = IsFinish
						end
					end
					return IsCan
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_BATTLEPASS_LV then  --战令等级
					local CurLv = _G.BattlePassMgr:GetBattlePassGrade()
					local CurCond = CondValues[1][1]
					local NeedLv
					if type(CurCond) == "table" then
						NeedLv = CondValues[1][1][1]
					else
						NeedLv = CondValues[1][1]
					end
					if CurLv < NeedLv then
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_GRANDCOMPANY_LV then  --军衔等级
					local CurGrandCompanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
					local CurGrandCompanyID = CurGrandCompanyInfo.GrandCompanyID
					local NeedGrandCompanyLv = CondValues[1][1]
					if CurGrandCompanyID and CurGrandCompanyID ~= 0 then
						local CurGrandCompanyLv = CurGrandCompanyInfo.MilitaryLevelList[CurGrandCompanyID]
						if CurGrandCompanyLv < NeedGrandCompanyLv then
							return false
						end
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_GRANDCOMPANY_ID then  --所属军队
					local CurGrandCompanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
					local CurGrandCompanyID = CurGrandCompanyInfo.GrandCompanyID
					local NeedGrandCompanyID = CondValues[1][1]
					if CurGrandCompanyID ~= NeedGrandCompanyID then
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_FINISHI_TASK then  --完成任务
					local Task = CondValues[1][1]
					local IsFinish = _G.QuestMgr:GetQuestStatus(Task)
					if IsFinish ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_UnLock_Job_Lv then  --已解锁职业满足等级要求
					local CondList = CondValues[1]
					local Prof = CondList[1]
					local ProfLimitLv = CondList[2]
					local CurProfLv = MajorUtil.GetMajorLevelByProf(Prof) or 0
					if CurProfLv < ProfLimitLv then
						return false
					end
				end
			end
		end
	end

	return true
end

--判断商品上下架版本号是否符合当前版本号
function ShopMgr:IsOnVersion(FirstVersion, SecondVersion)
	--商品是否在当前版本内
	if not FirstVersion or not SecondVersion then
		return false
	end

	if type(FirstVersion) ~= "string" or type(SecondVersion) ~= "string" then
        return false
    end
	
	local CurVersion = self.CurShopVersion
	local OnVersion = string.split(FirstVersion, ".")
	local OffVersion = string.split(SecondVersion, ".")
	local IsAllConformOn
	local IsAllConformOfF
	if FirstVersion ~= "" and SecondVersion == "" then
		IsAllConformOn = self:CompareOnVersion(CurVersion, OnVersion)
		if not IsAllConformOn then
			return false
		end
	elseif FirstVersion == "" and SecondVersion ~= "" then
		IsAllConformOfF = self:CompareOffVersion(CurVersion, OffVersion)
		if not IsAllConformOfF then
			return false
		end
	elseif FirstVersion ~= "" and SecondVersion ~= "" then
		IsAllConformOn = self:CompareOnVersion(CurVersion, OnVersion)
		if not IsAllConformOn then
			return false
		end
		IsAllConformOfF = self:CompareOffVersion(CurVersion, OffVersion)
		if not IsAllConformOfF then
			return false
		end
	end

	return true
end


--比较当前版本号和下架版本号是否一致
---@param Version1 table@当前版本号
---@param Version2 table@下架版本号
function ShopMgr:CompareOffVersion(Version1, Version2)
	for i = 1, #Version1 do
		if Version1[i] < tonumber(Version2[i]) then
			return true
		elseif Version1[i] > tonumber(Version2[i]) then
			return false
		end
	end

	return false
end

--比较当前版本号和上架版本号是否一致
---@param Version1 table@当前版本号
---@param Version2 table@上架版本号
function ShopMgr:CompareOnVersion(Version1, Version2)
	if Version2 == nil or #Version2 < 3 then
		return true
	end

	for i = 1, #Version1 do
		if Version1[i] > tonumber(Version2[i]) then
			return true
		elseif Version1[i] < tonumber(Version2[i]) then
			return false
		end
	end

	return true
end

--- 商品是否可购买
---@param GoodsId number@商品id
---@return boolean @是否可购买
---@return string @不可购买原因
---已售罄算在不可购买里
function ShopMgr:IsCanBuy(GoodsInfo)
	local TmpGoodsCfg = GoodsInfo
	if TmpGoodsCfg == nil then
		--FLOG_ERROR("no buy 1")
		return false, ""
	end

	-- local Mall = self.AllMallServerInfos[self.CurOpenMallId]
	-- if Mall == nil then
	--     FLOG_ERROR("no buy 2")
	--     return false
	-- end

	-- local ServerGoodsInfos = Mall.MallGoodsInfos
	-- local GoodsInfo = table.find_by_predicate(ServerGoodsInfos, function(e)
	--     return e.GoodsId == GoodsId
	-- end)

	-- local ServerGoodsInfos = self.CurOpenShopGoodSList

	-- FLOG_ERROR("no buy 33333 = %s",table_to_string(GoodsInfo))
	-- if GoodsInfo == nil then
	--     FLOG_ERROR("no buy 3")
	--     return false
	-- end

	---限购检查
	if TmpGoodsCfg.CounterInfo ~= nil and TmpGoodsCfg.CounterInfo.CounterFirst ~= 0 then
		local IsSoldOut = TmpGoodsCfg.IsSoldOut
		if IsSoldOut then
			--FLOG_ERROR("no buy 4")
			return false, LSTR(1200032)
		end
	end

	--优先版本号判断
	local CurVersionIsCanBuy = self:IsOnVersion(TmpGoodsCfg.OnVersion, TmpGoodsCfg.OffVersion)
	if not CurVersionIsCanBuy then
		return false, LSTR(1200100)--未到版本不可购买
	end
	
	---配表条件检查
	local PurchaseConditions = TmpGoodsCfg.PurchaseConditions
	if next(PurchaseConditions) == nil then
		return true, ""
	end

	local ProfID = MajorUtil.GetMajorProfID()
	local RoleDetail = ActorMgr:GetMajorRoleDetail() or {}
	local ProfList = RoleDetail.Prof and RoleDetail.Prof.ProfList or {}
	local MajorClass = RoleInitCfg:FindProfClass(ProfID)
	local MajorGender = MajorUtil.GetMajorGender()
	local MajorRace = MajorUtil.GetMajorRaceID()
	local CurrentProfInfo = {}
	for _, value in pairs(ProfList) do
		if value.ProfID == ProfID then
			CurrentProfInfo = value
			break
		end
	end

	for i = 1, #PurchaseConditions do
		local Cond = PurchaseConditions[i]
		if Cond then
			local CondType = Cond.CondType
			local CondValues = Cond.Values
			local Desc = Cond.Desc[1]
			if type(CondType) == "number" and CondValues ~= nil and (type(CondValues) == "table" and next(CondValues) ~= nil) then
				if CondType == GoodsShowConditionType.GOODS_SHOW_COND_UseLv then  --使用等级
					local ProfLevel = CurrentProfInfo.Level
					if ProfLevel < CondValues[1] then
						--FLOG_ERROR("no buy 5 = %s",DescContent)
						return false, Desc
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_JobType then  --职业类型限制
					if CondValues[1] ~= ProtoCommon.class_type.CLASS_TYPE_NULL and CondValues[1] ~= MajorClass then
						--FLOG_ERROR("no buy 6= %s",DescContent)
						return false, Desc
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_Job then  --职业限制
					local ProfLimit = CondValues
					if type(ProfLimit) == "table" then
						local bHasLimit = false
						local bProfHas = false
						for _, v in pairs(ProfLimit) do
							if v ~= ProtoCommon.prof_type.PROF_TYPE_NULL then
								bHasLimit = true
								if v == ProfID then
									bProfHas = true
									break
								end
							end
						end
						if bHasLimit == true and bProfHas == false then
							--FLOG_ERROR("no buy 7= %s",DescContent)
							return false, Desc
						end
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_Sex then  --性别限制
					local LimitGender = CondValues[1]
					if LimitGender ~= ProtoCommon.role_gender.GENDER_UNKNOWN and LimitGender ~= MajorGender then
						--FLOG_ERROR("no buy 8= %s",DescContent)
						return false, Desc
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_Race then  --种族限制
					local RaceTypeLimit = CondValues[1]
					if RaceTypeLimit ~= ProtoCommon.race_type.RACE_TYPE_NULL and MajorRace ~= RaceTypeLimit then
						--FLOG_ERROR("no buy 9= %s",DescContent)
						return false, Desc
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_COMBAT_MAX_LV then  --战斗职业最高等级
					local IsCan = false
					for _, v in pairs(ProfList) do
						local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
						if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
							local CurLv = v.Level
							local NeedLv = CondValues[1]

							if CurLv >= NeedLv then
								IsCan = true
								break
							end
						end
					end
					return IsCan, Desc
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_MANU_MAX_LV then  --生产职业最高等级
					local IsCan = false
					for _, v in pairs(ProfList) do
						local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
						if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
							local CurLv = v.Level
							local NeedLv = CondValues[1]
							if NeedLv == nil then
								NeedLv = 1
								FLOG_ERROR("生产职业最高等级 NeedLv 错误")
							end

							if CurLv >= NeedLv then
								IsCan = true
								break
							end
						end
					end
					return IsCan, Desc
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_ARMY_LV then  --部队等级
					local CurLv = _G.ArmyMgr:GetArmyLevel() or 0

					local NeedLv = CondValues[1]
					if CurLv < NeedLv then
						return false, Desc
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_ACHIEVEMENT then  --完成成就
					local IsCan = false
					local AchieveList = CondValues
					for i = 1, #AchieveList do
						local IsFinish = _G.AchievementMgr:GetAchievementFinishState(AchieveList[i])
						if IsFinish then
							IsCan = IsFinish
						end
					end
					return IsCan, Desc
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_BATTLEPASS_LV then  --战令等级
					local CurLv = _G.BattlePassMgr:GetBattlePassGrade()
					local NeedLv = CondValues[1]
					if CurLv < NeedLv then
						return false, Desc
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_GRANDCOMPANY_LV then  --军衔等级
					local CurGrandCompanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
					local CurGrandCompanyID = CurGrandCompanyInfo.GrandCompanyID
					local NeedGrandCompanyLv = CondValues[1]
					if CurGrandCompanyID ~= nil and CurGrandCompanyID ~= 0 then
						local CurGrandCompanyLv = CurGrandCompanyInfo.MilitaryLevelList[CurGrandCompanyID] or 0
						if CurGrandCompanyLv < NeedGrandCompanyLv then
							return false, Desc
						end
					else
						return false, Desc
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_GRANDCOMPANY_ID then  --所属军队
					local CurGrandCompanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
					local CurGrandCompanyID = CurGrandCompanyInfo.GrandCompanyID
					local NeedGrandCompanyID = CondValues[1]
					if CurGrandCompanyID ~= NeedGrandCompanyID then
						return false, Desc
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_FINISHI_TASK then  --完成任务
					local Task = CondValues[1]
					local TaskName = _G.QuestMgr:GetQuestName(Task)
					local IsFinish = _G.QuestMgr:GetQuestStatus(Task)
					if IsFinish ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
						Desc = string.format("%s%s%s", LSTR(1200029), TaskName, LSTR(1200020))
						return false, Desc
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_UnLock_Job_Lv then  --已解锁职业满足等级要求
					local Prof = CondValues[1]
					local ProfLimitLv = CondValues[2]
					local CurProfLv = MajorUtil.GetMajorLevelByProf(Prof) or 0
					if CurProfLv < ProfLimitLv then
						return false, Desc
					end
				end
			end
		end
	end
	return true, ""
end

--- 获取商店商品对应的道具ID
---@param GoodsId number @商品id
---@return number @道具id
function ShopMgr:GetGoodsItemID(GoodsId)
	local TmpGoodsCfg = GoodsCfg:FindCfgByKey(GoodsId)
	local ItemInfoCfgs = TmpGoodsCfg.Items
	if ItemInfoCfgs == nil or next(ItemInfoCfgs) == nil then
		return -1
	end
	return ItemInfoCfgs[1].ID
end

--- 商品是否可使用的特殊条件（特定职业等级）
---@param ProfID number @职业id
function ShopMgr:GoodsCanUseExtendCondProfLv(ProfID, TargetLv)
	local RoleDetail = ActorMgr:GetMajorRoleDetail()
	local ProfList = RoleDetail.Prof.ProfList
	if nil == ProfList or next(ProfList) == nil then
		FLOG_ERROR("ShopMgr:IsCanUse ProfList is nil")
		return false
	end

	local ProfInfo
	for _, v in pairs(ProfList) do
		if v.ProfID == ProfID then
		ProfInfo = v
		break
		end
	end

	if nil == ProfInfo then
	return false
	end

	local ProfLv = ProfInfo.Level
	if nil == ProfLv then
	return false
	end

	return ProfLv >= TargetLv
end

--- 商品是否可使用的特殊条件（集合）
---@param GoodsId any
function ShopMgr:GoodsCanUseExtendCond(GoodsId)
	local bJudgeComplete = false -- 此方法是否完成所有判断
	local ItemID = self:GetGoodsItemID(GoodsId)
	local GoodsItemCfg = ItemCfg:FindCfgByKey(ItemID)
	if GoodsItemCfg == nil then
		return false
	end

	local Type = 0
	local Text = ""
	-- 钓饵类
	if GoodsItemCfg.ItemMainType == ItemMainType.ItemConsumables and
	GoodsItemCfg.ItemType == ItemTypeDetail.CONSUMABLES_BAIT then
		bJudgeComplete = true
		local bCanUse = self:GoodsCanUseExtendCondProfLv(ProfType.PROF_TYPE_FISHER, GoodsItemCfg.Grade)
		if not bCanUse then
			Type = 4
			Text = LSTR(1200037)
			return bJudgeComplete, false, Text,Type
		end
	end

	return bJudgeComplete, true
end


--- 商品是否可使用
---@param MallID number @商店id
---@param GoodsId number @商品id
---@return boolean @是否可使用
function ShopMgr:IsCanUse(MallID, GoodsId)
	local CurMallID = MallID or self.CurOpenMallId or self.CurQueryShopID
	local GoodsData = ShopMgr:GetGoodsData(CurMallID, GoodsId)
	if nil == GoodsData then
		FLOG_ERROR("ShopMgr:IsCanUse CurMallID Info = nil")
		return false
	end

	local GoodsInfo = GoodsData.GoodsInfo
	if nil == GoodsInfo then
		return false
	end
	-- 是否开启可用检查
	if GoodsInfo.CheckUsable == 0 then
		return true
	end

	local FailTips
	--local ShopExchangeName = self:IsNeedShowBuyOrExchange(self.CurOpenMallId)
	local ProfID = MajorUtil.GetMajorProfID()
	local ItemID = GoodsInfo.Items[1].ID
	local ItemInfo = GoodsData.ItemInfo
	if ItemInfo == nil then
		return false
	end

	--- 特殊条件判断
	local bJudgeComplete, bCanUse, ExtendCondFailReason,NoUseType = self:GoodsCanUseExtendCond(GoodsId)
	if not bCanUse then
		return bCanUse, ExtendCondFailReason,NoUseType
	else
		if bJudgeComplete then
			return true
		end
	end


	local Type = 0
	local CanNotUseArr = EquipmentMgr:CanEquiped(ItemID, false, ProfID, nil)
	if not CanNotUseArr then
		FailTips = LSTR(1200039)
		Type = 1
		return false, FailTips, Type
	end

	---种族与性别
	local ConditionID = ItemInfo.UseCond
	local bCanEquip, ConditionFailReasonList = ConditionMgr:CheckConditionByID(ConditionID)
	if not bCanEquip then
		if ConditionFailReasonList[CondFailReason.RaceLimit] then
			FailTips = LSTR(1200038)
			Type = 2
		elseif ConditionFailReasonList[CondFailReason.GenderLimit] then
			FailTips = LSTR(1200036)
			Type = 3
		end
		return false, FailTips, Type
	end
	return true
end

function ShopMgr:GetProfLevel(ProfID)
	local RoleDetail = ActorMgr:GetMajorRoleDetail()
	local ProfList = RoleDetail.Prof.ProfList
	for _, value in pairs(ProfList) do
		if value.ProfID == ProfID then
			return value.Level
		end
	end
	return 0
end

--- 获取品级描述
---@param table ItemCfg 物品配置
---@return string ItemLevelStr 品级%d  高于装备的话会显示绿色箭头
function ShopMgr:GetItemlevelStr(ParamItemCfg)
	local ItemLevel = ParamItemCfg.ItemLevel
	local Part = self:GetEquipPartByGoodPart(ParamItemCfg.Classify)
	local EquipItem = EquipmentMgr:GetEquipedItemByPart(Part)
	local ItemLevelStr = string.format("  %s%d", LSTR(1200091), ItemLevel)	--- 品级
	local bIsCanEquip = EquipmentMgr:CanEquiped(ParamItemCfg.ItemID)
	local EquipIetmLevel = 0
	if EquipItem ~= nil then
		local EquipItemCfg = ItemCfg:FindCfgByKey(EquipItem.ResID)
		if EquipItemCfg then
			EquipIetmLevel = EquipItemCfg.ItemLevel
		end
	end
    --- 绿色箭头只判断装备
	if bIsCanEquip and ItemLevel > EquipIetmLevel and ParamItemCfg.ItemMainType ~= ProtoCommon.ItemMainType.ItemMainTypeNone and ParamItemCfg.ItemMainType < ProtoCommon.ItemMainType.ItemConsumables then
		--- 可以穿戴且有提升，品级数字显示绿色 and 显示绿色箭头
		ItemLevelStr = string.format("  %s<span color=\"#89dd88\">%d</><img tex=\"PaperSprite'/Game/UI/Atlas/CommPic/Frames/UI_Comm_Icon_Arrow_Upgrade_png.UI_Comm_Icon_Arrow_Upgrade_png'\" size=\"40;40\" Baseline=\"-11\"></>", LSTR(1200091), ItemLevel)
	end
	return ItemLevelStr
end

--- 获取职业  等级限制描述
---@param table ItemCfg 物品配置
---@return string DesStr 职业 等级 拼接富文本之后的字符串
function ShopMgr:GetEquipProfInfoToBuyWinView(ParamItemCfg)
	local MajorProfID = MajorUtil.GetMajorProfID()
	local MajorClass = MajorUtil.GetMajorProfClass()
	local ClassLimit = ParamItemCfg.ClassLimit
	local ProfLimit = ParamItemCfg.ProfLimit
	local LevelLimit = ParamItemCfg.Grade
	local ProfStr = ""
	local ProfStrColor = TipsColor_Nomal
	local ProfLevelStrColor = TipsColor_Nomal

	local ProfIsUnlock = false				--- 职业是否解锁
	local ProfLevelSatisfied = false		--- 职业等级是否满足要求
	local IsCurProf = false					--- 是否是当前职业
	if ClassLimit ~= ProtoCommon.class_type.CLASS_TYPE_NULL then
		ProfLimit = self:GetProfLimitListByClassLimit(ClassLimit)
		ProfStr = ProtoEnumAlias.GetAlias(ProtoCommon.class_type, ClassLimit)
		IsCurProf = MajorClass == ClassLimit
	else
		for _, v in pairs(ParamItemCfg.ProfLimit) do
			ProfStr = string.format("%s/%s", ProfStr, ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, v))
		end
		ProfStr = string.gsub(ProfStr, "/", "", 1)
	end
	--- 职业限制
	local TempProfLevel = 0
	for _, v in pairs(ProfLimit) do
		if v ~= ProtoCommon.prof_type.PROF_TYPE_NULL then
			TempProfLevel = self:GetProfLevel(v)

			if not ProfIsUnlock then
				ProfIsUnlock = TempProfLevel ~= 0
			end
			if not ProfLevelSatisfied then
				ProfLevelSatisfied = TempProfLevel >= LevelLimit
			end
			if v == MajorProfID then
				IsCurProf = true
				break
			end
		end
	end

	if not ProfIsUnlock then
		ProfStrColor = TipsColor_Red
		ProfLevelStrColor = TipsColor_Red
	else
		ProfLevelStrColor = ProfLevelSatisfied and (IsCurProf and TipsColor_Nomal or TipsColor_Blue) or TipsColor_Red
		if not IsCurProf then
			ProfStrColor = TipsColor_Blue
		end
	end
	local LevelLimitStr = string.format("%d%s", LevelLimit, LSTR(1200099))	--- 级
	local DesStr = string.format("%s  %s", RichTextUtil.GetText(ProfStr, ProfStrColor), RichTextUtil.GetText(LevelLimitStr, ProfLevelStrColor))
	return DesStr
end

---切换角色清除商店旧数据
function ShopMgr:ClearOldRoleMallData()
	self.ShopMainIndex = nil  --商会主界面Tab Index
	self.ShopMainTypeIndex = nil  --商店主界面主类 Index
	self.ShopMainTypeOpenList = {} --记录玩家关闭界面前最后点击的分类
	self.CurOpenShopGoodSList = {} -- 当前打开商店的货品信息
	self.CurFirstTypeGoodsList = {} --当前一级分类商品信息
	self.FilterAfterGoodsList = {} --筛选后商品信息
	self.FirstTypeIndex = 1 --当前打开商店的一级分类下标
	self.FilterIndexList = {} --筛选器下标
	self.OpenType = nil --交互打开商店类型
	self.BuyNum = 0 --购买商品数量
	self.OverlayNum = 0
	self.OnceLimitation = 0
	self.CanChange = false
	self.CurFirstTypeFilterList = {}
	self.AfterFistFilterList = {}
	self.CurQueryShopGoodsList = {}
	self.LashChosedIndexList = {}
end

--- 商店排序 显示规则
function ShopMgr.SortShopGoodsPredicate(Left, Right)
	local LTaskSate = Left.TaskState or false
	local RTaskSate = Right.TaskState or false
	if LTaskSate ~= RTaskSate then
		return LTaskSate and (not RTaskSate)
	end
	local LeftItemCfg = ItemCfg:FindCfgByKey(Left.ItemID)
	local RightItemCfg = ItemCfg:FindCfgByKey(Right.ItemID)
	if LeftItemCfg == nil then
		return false
	end
	if RightItemCfg == nil then
		return false
	end
	Left.IsEquipment = LeftItemCfg.ItemMainType > ProtoCommon.ItemMainType.ItemMainTypeNone and LeftItemCfg.ItemMainType < ProtoCommon.ItemMainType.ItemConsumables
	Right.IsEquipment = RightItemCfg.ItemMainType > ProtoCommon.ItemMainType.ItemMainTypeNone and RightItemCfg.ItemMainType < ProtoCommon.ItemMainType.ItemConsumables
	--- 类型7
	local LbUes = Left.bUse or false
	local RbUes = Right.bUse or false
	if Left.IsEquipment or Right.IsEquipment then
		local LIsUp = Left.IsUp
		local RIsUp = Right.IsUp
		if LIsUp ~= RIsUp and LbUes or RbUes then
			return LIsUp and (not RIsUp)
		end
	end

	local LbBuy = Left.bBuy or false
	local RbBuy = Right.bBuy or false
	if LbBuy ~= RbBuy then
		return LbBuy and (not RbBuy)
	elseif LbBuy == RbBuy then
		local LbSoldOut = Left.IsSoldOut or false
		local RbSoldOut = Right.IsSoldOut or false
		if LbSoldOut ~= RbSoldOut then
			return LbSoldOut and (not RbSoldOut)
		else
			if LbUes ~= RbUes then
				return LbUes and (not RbUes)
			else
				local LShopItemId = Left.GoodsId or 0
				local RShopItemId = Right.GoodsId or 0
				return LShopItemId < RShopItemId
			end
		end
	end

	
	--return LShopItemId < RShopItemId
end

--- 根据返回消息更新前台商店信息
---@param MsgBody table @消息体
function ShopMgr:UpdateSpecificMallInfo(MsgBody)
	local _ <close> = CommonUtil.MakeProfileTag("UpdateSpecificMallInfo")
	local MallId = MsgBody.StoreQuery.MallID
	local ServerGoods = MsgBody.StoreQuery.Goods
	local ServerGoodsConds = MsgBody.StoreQuery.Conds
	self.CurOpenMallId = MallId
	local AllMallInfos = self.CurQueryShopGoodsList
	if AllMallInfos == nil then
		return
	end
	local EquipList = _G.ActorMgr:GetMajorRoleDetail().Equip.EquipList

	-- local YieldNum = math.ceil(#AllMallInfos / 3)
	-- local DiffNum = 0

	local MallInfo = {}
	local MallGoodsInfos = {}
	for _, GoodsData in pairs(AllMallInfos) do
		local GoodsInfo = GoodsData.GoodsInfo
		local GoodsID = GoodsInfo.ID
		if self:IsCanShow(GoodsInfo) then
			local bCfgDisabled = GoodsInfo.Disabled
			if bCfgDisabled ~= nil and bCfgDisabled == 0 then
				local TmpGoods = {}
				TmpGoods.GoodsId = GoodsID
				TmpGoods.FirstType = GoodsInfo.FirstType
				TmpGoods.Discount = GoodsInfo.Discount
				TmpGoods.DiscountDurationStart = self:GetTimeInfo(GoodsInfo.DiscountDurationStart)
				TmpGoods.DiscountDurationEnd = self:GetTimeInfo(GoodsInfo.DiscountDurationEnd)
				TmpGoods.BoughtCount = 0
				TmpGoods.ItemID = GoodsInfo.Items[1].ID
				TmpGoods.IsSoldOut = false
				TmpGoods.Price = GoodsInfo.Price
				TmpGoods.PurchaseConditions = GoodsInfo.PurchaseConditions
				TmpGoods.IsSpecial = GoodsInfo.IsSpecial
				TmpGoods.Items = GoodsInfo.Items
				TmpGoods.ItemInfo = GoodsData.ItemInfo
				TmpGoods.OnTime = GoodsInfo.OnTime
				TmpGoods.OffTime = GoodsInfo.OffTime
				TmpGoods.DisplayID = GoodsInfo.DisplayID
				TmpGoods.OnVersion = GoodsInfo.OnVersion
				TmpGoods.OffVersion = GoodsInfo.OffVersion
				if #ServerGoods > 0 then
					for j = 1,#ServerGoods do
						if ServerGoods[j].GoodID == GoodsID then
							TmpGoods.CounterInfo = ServerGoods[j]
							local RestrictionType, BoughtCount, IsSoldOut = self:GetGoodsBoughtCountAndIsSoldOut(ServerGoods[j])
							TmpGoods.RestrictionType = RestrictionType
							TmpGoods.BoughtCount = BoughtCount
							TmpGoods.IsSoldOut = IsSoldOut
							-- TmpGoods.CounterInfo = {}
							-- TmpGoods.CounterInfo.CounterFirst = ServerGoods[j].CounterFirst
							-- TmpGoods.CounterInfo.CounterSecond = ServerGoods[j].CounterSecond
						end
					end
				end
				---设定货物的可购买状态
				local bBuyDesc
				TmpGoods.bBuy, bBuyDesc = self:IsCanBuy(TmpGoods)
				TmpGoods.bBuyDesc = bBuyDesc or ""
				TmpGoods.bUse = self:IsCanUse(MallId, GoodsID)
				local LItemCfg = ItemCfg:FindCfgByKey(TmpGoods.ItemID)
				TmpGoods.IsUp = self:CheckEquipIconUpState(LItemCfg, EquipList)
				table.insert(MallGoodsInfos, TmpGoods)
			end
		end

		-- DiffNum = DiffNum + 1

		-- --3帧调用完
		-- if (DiffNum >= YieldNum) then
		--     DiffNum = 0
		--     _G.SlicingMgr.YieldCoroutine()
		-- end
	end

	--一些统计项相关的通过后台查询修改状态
	if #ServerGoodsConds > 0 then
		for k, v in pairs(MallGoodsInfos) do
			for _, j in pairs(ServerGoodsConds) do
				if v.GoodsId == j.GoodID then
					if not j.Show then
						MallGoodsInfos[k] = nil
					elseif not j.Purchase then
						v.bBuy = j.Purchase
						v.bBuyDesc = v.PurchaseConditions[1].Desc[1]
					end
				end
			end
		end
	end

	MallInfo.MallGoodsInfos = MallGoodsInfos
	self.CurOpenShopGoodSList = MallInfo
	--FLOG_ERROR("TEST SHOP INFO = %s",table_to_string(MallInfo))
	local ItemData = {}
	ItemData.ShopId = MallId
	ItemData.Open = self.OpenType
	UIViewMgr:ShowView(UIViewID.ShopMainPanelView, ItemData)
	--EventMgr:SendEvent(EventID.OpenShop,MallId)
	--EventMgr:SendEvent(EventID.InitMallGoodsListMsg, MallId)
end

--- 根据返回消息更新购买后前台商店信息
---@param MsgBody table @消息体
function ShopMgr:UpdateGoodsInfoAfterBuy(GoodInfo)
	local GoodsIdInMsg = GoodInfo.GoodID
	local CounterFirstID = GoodInfo.CounterFirst.CounterID
	local Cfg = GoodsCfg:FindCfgByKey(GoodsIdInMsg)
	if Cfg == nil then
		return
	end

	if self.CurOpenShopGoodSList.MallGoodsInfos == nil then
		return
	end

	local RestrictionType, BoughtCount, IsSoldOut = self:GetGoodsBoughtCountAndIsSoldOut(GoodInfo)

	local NeedSort = false
	if CounterFirstID ~= 0 then
		local GoodsListL = #self.CurFirstTypeGoodsList
		for i = 1, GoodsListL do
			if self.CurFirstTypeGoodsList[i].GoodsId == GoodsIdInMsg then
				self.CurFirstTypeGoodsList[i].RestrictionType = RestrictionType
				self.CurFirstTypeGoodsList[i].BoughtCount = BoughtCount
				NeedSort = self.CurFirstTypeGoodsList[i].IsSoldOut ~= IsSoldOut
				self.CurFirstTypeGoodsList[i].IsSoldOut = IsSoldOut
				local bBuy, bBuyDesc = self:IsCanBuy(self.CurFirstTypeGoodsList[i])
				self.CurFirstTypeGoodsList[i].bBuy = bBuy
				self.CurFirstTypeGoodsList[i].bBuyDesc = bBuyDesc
				self.CurFirstTypeGoodsList[i].CounterInfo = {}
				self.CurFirstTypeGoodsList[i].CounterInfo.CounterFirst = GoodInfo.CounterFirst
				self.CurFirstTypeGoodsList[i].CounterInfo.CounterSecond = GoodInfo.CounterSecond
				break
			end
		end

		table.sort(self.CurFirstTypeGoodsList, self.SortShopGoodsPredicate)
		EventMgr:SendEvent(EventID.UpdateMallGoodsListMsg, false)
	end
end

function ShopMgr:GetGoodsBoughtCountAndIsSoldOut(List)
	local RestrictionType = nil
	local BoughtCount = 0
	local IsSoldOut = false
	local GoodsInfo = List
	local CounterFirstID = GoodsInfo.CounterFirst.CounterID
	local CounterSecondID = GoodsInfo.CounterSecond.CounterID
	if CounterFirstID ~= 0 then
		local FirstCounterCfg = CounterCfg:FindCfgByKey(CounterFirstID)
		if FirstCounterCfg ~= nil then
			RestrictionType = FirstCounterCfg.CounterType
		end
		local CurrentRestore = CounterMgr:GetCounterRestore(CounterFirstID) or 0
		local CounterFirstNum = CounterMgr:GetCounterCurrValue(CounterFirstID)--GoodsInfo.CounterFirst.CounterNum
		local FirstSumLimit = CounterMgr:GetCounterLimit(CounterFirstID)
		local CounterSecondNum = CounterMgr:GetCounterCurrValue(CounterSecondID)--GoodsInfo.CounterSecond.CounterNum
		local SecondSumLimit = CounterMgr:GetCounterLimit(CounterSecondID)
		--[[
			x/y
			y固定为计数器1周期回复值
			计数器2为空  then
			 x=计数器1的周期回复值-后台返回的计数器1的CounterNum
				else
					x = 读表计数器2.limit - 计数器2后台返回的CounterNum
		]]
		if CounterFirstID ~= 0 and CounterSecondID == 0 then  --单限购
			local CanBuy = math.max(0, CurrentRestore - CounterFirstNum)
			BoughtCount = math.min(CanBuy, FirstSumLimit)
		elseif CounterFirstID ~= 0 and CounterSecondID ~= 0 then --双限购
			local CanBuy = math.max(0, CurrentRestore - CounterFirstNum)
			local Surplus = SecondSumLimit - CounterSecondNum
			BoughtCount = math.min(CanBuy, Surplus)
		end
	end

	if RestrictionType and RestrictionType ~= ProtoRes.COUNTER_TYPE.COUNTER_TYPE_NONE then
		if BoughtCount <= 0 then
			IsSoldOut = true
		end
	end

	--- 还能买的时候，检查商店计数器，如果上面计数器已经买完了，也没必要判断商店计数器了
	-- if not IsSoldOut and self.CurOpenMallCounterID ~= 0 and self.CurOpenMallCounterID ~= nil then
	-- 	local MallRestore = CounterMgr:GetCounterRestore(self.CurOpenMallCounterID) or 0
	-- 	local MallCounterNum = CounterMgr:GetCounterCurrValue(self.CurOpenMallCounterID)
	-- 	local MallLimit = CounterMgr:GetCounterLimit(self.CurOpenMallCounterID)
	-- 	local CanBuy = math.max(0, MallRestore - MallCounterNum)
	-- 	BoughtCount = math.min(CanBuy, MallLimit)
	-- 	IsSoldOut = math.min(CanBuy, MallLimit) <= 0
	-- end

	return RestrictionType, BoughtCount, IsSoldOut
end

--检查当前商店主类计数器是否已售罄
function ShopMgr:CheckCurMallCounter()
	local IsSoldOut = false
	if self.CurOpenMallCounterID ~= 0 and self.CurOpenMallCounterID ~= nil then
		local MallRestore = CounterMgr:GetCounterRestore(self.CurOpenMallCounterID) or 0
		local MallCounterNum = CounterMgr:GetCounterCurrValue(self.CurOpenMallCounterID)
		local MallLimit = CounterMgr:GetCounterLimit(self.CurOpenMallCounterID)
		local CanBuy = math.max(0, MallRestore - MallCounterNum)
		IsSoldOut = math.min(CanBuy, MallLimit) <= 0
	end

	return IsSoldOut
end


--- 货物是否在折扣中
---@param MallId number@商店ID
---@param GoodsId number@商品ID
---@return boolean@是否在折扣中
function ShopMgr:GoodsIsDiscount(MallId, GoodsId)
	local MallSevInfo = self.AllMallServerInfos[MallId]
	if MallSevInfo == nil then
		return false
	end
	local GoodsInfo = table.find_by_predicate(MallSevInfo.MallGoodsInfos, function(e)
		return e.GoodsId == GoodsId
	end)

	if nil == GoodsInfo then
		FLOG_ERROR("Server Not Have This Goods")
		return false
	end

	local Cfg = GoodsCfg:FindCfgByKey(GoodsId)
	if nil == Cfg then
		FLOG_ERROR("Table Not Have This Goods")
		return false
	end
	---商店未配置折扣
	local NoDiscountValue = 0
	local FullDiscountValue = 100
	if GoodsInfo.Discount == FullDiscountValue or GoodsInfo.Discount == NoDiscountValue then
		return false
	end
	---限时折扣商品的判断
	local ServerTime = TimeUtil.GetServerTime()
	if GoodsInfo.DiscountDurationStart == 0 or GoodsInfo.DiscountDurationEnd == 0 then
		return true
	else
		return GoodsInfo.DiscountDurationEnd >= ServerTime and GoodsInfo.DiscountDurationStart <= ServerTime
	end
end

--- 银币商店货币数量获取
---@param GoldCoinPrice number@商品价格
---@return table@货币信息
function ShopMgr:GetGoodsCostBySilverCoin(GoldCoinPrice)

	local CfgPrice = {}
	CfgPrice.ID = ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
	CfgPrice.Count = GoldCoinPrice or 0
	CfgPrice.Type = ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_SCORE
	CfgPrice.Show = true
	local CostList = {}
	table.insert(CostList, CfgPrice)
	return CostList
end

--- 所持材料/货币所能购买商品的最大数量
---@param GoodsId number@商品ID
---@return number@最大数量
function ShopMgr:GoodsMaxNumCanBuy(GoodsId)
	local Cfg = GoodsCfg:FindCfgByKey(GoodsId)
	if Cfg == nil then
		return 0
	end

	-- 商品可批量购买上限
	local Result = Cfg.OnceLimitation
	local IsDiscount = self:GoodsIsDiscount(Cfg.MallID, GoodsId)
	local IsSilverCoinValid, SilverCostList = self:GetGoodsCostBySilverCoin(GoodsId)
	local CalCostList = IsSilverCoinValid and SilverCostList or Cfg.Price
	for j = 1, #CalCostList do
		local TmpPrice = CalCostList[j]
		if TmpPrice.Type ~= ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_Invalid then
			local IsItem = TmpPrice.Type == ProtoRes.GoodsPriceType.GOODS_PRICE_TYPE_ITEM
			local SingleCost = IsDiscount and TmpPrice.Count * Cfg.Discount / 100 or TmpPrice.Count
			local ItemNumHave = IsItem and BagMgr:GetItemNum(TmpPrice.ID) or ScoreMgr:GetScoreValueByID(TmpPrice.ID)
			local OneOfResult = math.floor(ItemNumHave / SingleCost)
			if OneOfResult < Result then
				Result = OneOfResult < 0 and 0 or OneOfResult
				if Result == 0 then
					return Result, IsItem, TmpPrice.ID
				end
			end
		end
	end

	return Result
end

--- 商品的剩余可购数量
---@param GoodsId number@商品ID
---@return number@剩余可购数量
function ShopMgr:GoodsRemainNumCanBuy(GoodsId)
	local Cfg = GoodsCfg:FindCfgByKey(GoodsId)
	if Cfg == nil then
		FLOG_ERROR("ShopMgr:GoodsRemainNumCanBuy Cfg is nil GoodsID:%d", GoodsId)
		return -1
	end

	local MallIDOfGoods = Cfg.MallID
	if MallIDOfGoods == nil then
		-- body
		FLOG_ERROR("ShopMgr:GoodsRemainNumCanBuy MallIDOfGoods is nil GoodsID:%d", GoodsId)
		return -1
	end

	local SevGoodsInfos = self:GetMallServerGoodsInfoByMallID(MallIDOfGoods)
	if SevGoodsInfos == nil then
		return -1
	end

	local ServerData = table.find_by_predicate(SevGoodsInfos, function(e)
		return e.GoodsId == GoodsId
	end)

	-- 返回-1此结果不可作为依据
	if ServerData == nil then
		FLOG_ERROR("MallServerData Don't Have This Goods")
		return -1
	end

	local NoCounterType = COUNTER_TYPE.COUNTER_TYPE_NONE
	local RestrictionType = Cfg.RestrictionType or NoCounterType
	if RestrictionType == NoCounterType then
		return -1
	end

	local LimitBuyNum = Cfg.RestrictionCount or 0
	local SevHaveBoughtNum = ServerData.BoughtCount or 0
	local RemainNum = LimitBuyNum - SevHaveBoughtNum
	if RemainNum < 0 then
		FLOG_ERROR("MallServerData BoughtCount Error")
		return -1
	else
		return RemainNum
	end
end

--- 打开商店/由特定途径跳转到商店
---@param ShopId number@商店ID
---@param FirstType number@商品一级分类
---@param IsJump bool@是否跳转
---@param Type number@打开类型 1 从商会打开商店  2 从Npc打开商店
function ShopMgr:OpenShop(ShopId, FirstType, IsJump, Type)
	if FirstType == nil then
		FirstType = ShopId * 100 + 1
	end
	local NewFirstType = FirstType or 1
	local Cfg = self.AllShopInfo[ShopId]
	if Cfg == nil then
		FLOG_ERROR("Cannot Find The ShopTableData")
		return
	end

	if not self:ShopIsUnLock(ShopId, Type) then
		local UnLockNotifyTipsID = self.AllShopInfo[ShopId].UnLockNotifyTipsID
		local TipsID = UnLockNotifyTipsID == 0 and ShopDefaultTipsID or UnLockNotifyTipsID
		_G.MsgTipsUtil.ShowTipsByID(TipsID)
		return
	end

	--临时处理 防止旧商店数据引发报错
	if Cfg.ShopType == 0 then
		FLOG_ERROR("Cannot Find The ShopType")
		return
	end
	local TabTypeInfo = MallMainTypeCfg:FindCfgByKey(FirstType)
	if TabTypeInfo == nil then
		return
	end

	local OpenTyep = Type or 1
	self.CurOpenMallCounterID = TabTypeInfo.CounterID
	self.JumpToShop = false
	ShopMgr.ShopMainTypeIndex = NewFirstType
	local Data = {}
	Data.ShopId = ShopId
	Data.MainTypeIndex = NewFirstType
	self:SetShopMainTypeOpenList(Data)
	self:SendMsgMallInfoReq(ShopId, OpenTyep, IsJump)
end

--打开商会主界面 Index 选择的页签
function ShopMgr:OpenInletMainView(Index)
	local Data = {}
	Data.Index = Index or 1
	self.InletMainIndex = Data.Index 
	UIViewMgr:ShowView(UIViewID.ShopInletPanelView, Data)
	self:ReportShopData(1, nil, nil, nil)
end

--设置商店相关版本号GM
function ShopMgr:SetCurShopVersion(Str)
	local Version = tostring(Str)
	if not Version:match("^%d+%.%d+%.%d+$") then
		FLOG_ERROR("Version error")
		return
	end
	local NewVersion = {}
	for num in string.gmatch(Version, "%d+") do
		table.insert(NewVersion, tonumber(num))
	end

	print("Changed shop version = %s", Str)
	self.CurShopVersion = NewVersion
end

--- 跳转到商店并打开选中特定商品
---@param ShopId number@商店ID
---@param ItemResID number@道具ID（目前规则为选中最便宜的商品）
---@param OpenType number@1 从商会打开 2直接打开
---@param TransferData table
---@param FirstType number@商店一级分类
function ShopMgr:JumpToShopGoods(ShopId, ItemResID, OpenType, TransferData, FirstType)
	if ShopId == self.CurQueryShopID or ShopId == self.CurOpenMallId then
		local Tips = LSTR(1200048)
		_G.MsgTipsUtil.ShowTips(Tips)
		return
	end

	local ShopMainViewVisible = UIViewMgr:IsViewVisible(UIViewID.ShopMainPanelView)
	local MakertMainViewVisible = UIViewMgr:IsViewVisible(UIViewID.MarketMainPanel)

	if MakertMainViewVisible and ShopMainViewVisible then
		local Tips = LSTR(1200048)
		_G.MsgTipsUtil.ShowTips(Tips)
		return
	end

	local GCfg = self.AllGoodsInfo[ShopId]
	if GCfg == nil then
		FLOG_ERROR("Cannot Find The ShopTableData")
		return
	end

	if not ItemResID then
		self:OpenShop(ShopId, FirstType, true)
		return
	end

	if ShopMainViewVisible then
		self.IsJumpAgain = true
	end

	local BuyViewVisible = UIViewMgr:IsViewVisible(UIViewID.ShopBuyPropsWinView)
	if BuyViewVisible then
		UIViewMgr:HideView(UIViewID.ShopBuyPropsWinView)
	end

	for Index, _ in pairs(GCfg) do
		local GoodsInfo = GCfg[Index].GoodsInfo
		local GoodsShopId = GoodsInfo.MallID
		local ItemID = GoodsInfo.Items[1].ID
		if ItemID == ItemResID and GoodsShopId == ShopId then
			if GoodsInfo.FirstType ~= 0 then
				self.ShopMainTypeIndex = GoodsInfo.FirstType
				self.JumpToGoodsItemResID = GoodsInfo.ID
			end
			break
		end
	end


	if self.JumpToGoodsItemResID == nil then
		FLOG_ERROR("Cannot Find The GOODSTableData")
		return
	end

	self.OpenType = OpenType or 2
	local Data = {}
	Data.ShopId = ShopId
	Data.MainTypeIndex = self.ShopMainTypeIndex
	self:SetShopMainTypeOpenList(Data)
	self.JumpToGoodsState = true
	local BuyNum
	if TransferData then
		local NeedBuyNum = TransferData.NeedBuyNum or 0
		BuyNum = math.max(1, NeedBuyNum)
	end
	self.JumpToBuyNum = BuyNum or 1
	self:SendMsgMallInfoReq(ShopId, self.OpenType)
end

---商店是否解锁
--@param ShopID number@商店ID
function ShopMgr:ShopIsUnLock(ShopID, OpenType)
	local Cfg = self.AllShopInfo[ShopID]
	if not Cfg then
		FLOG_ERROR("ShopID is nil")
		return false
	end

	--商品是否在当前版本内
	local CurVersion = self.CurShopVersion
	local OnVersion = string.split(Cfg.OnVersion, ".")
	local IsOpen = false
	if string.isnilorempty(OnVersion) then
		IsOpen = self:CompareOnVersion(CurVersion, OnVersion)
	else
		IsOpen = true
	end

	local Task = Cfg.Task
	if Task and Task ~= 0 then
		local PreTaskState = _G.QuestMgr:GetQuestStatus(Task)
		if PreTaskState == QUEST_STATUS.CS_QUEST_STATUS_FINISHED and IsOpen then
			return true
		end
	else
		if Cfg.ShopType and Cfg.ShopType == MallTypeInfo.MALL_TYPE_GrandCompany then
			local GrandCompanyInfo = _G.CompanySealMgr:GetCompanySealInfo()
			local GrandCompanyID = GrandCompanyInfo.GrandCompanyID
			local CurShopCompanyID = _G.CompanySealMgr:GetGrandCompanyIDByScoreID(tonumber(Cfg.ScoreID))
			if GrandCompanyID ~= 0 and IsOpen and CurShopCompanyID == GrandCompanyID then 
				return true
			--目前加入军队后商会只会显示当前军队商店，但是其他军队商店也可以通关NPC打开，等后续规则出来在修改，目前先这样处理
			elseif GrandCompanyID ~= 0 and IsOpen and CurShopCompanyID ~= GrandCompanyID and OpenType == 2 then
				return true
			end
		else
			if IsOpen then
				return true
			end
		end
	end

	return false
end

--- 商店初始化新逻辑，根据道具id跳转时检查是否修改缓存的商店选中商品信息
function ShopMgr:CheckJumpToShopItemState()
	if nil == self.JumpToGoodsItemResID then
		return
	end

	local ItemResIDToCheck = self.JumpToGoodsItemResID
	self.JumpToGoodsItemResID = nil
	local ShopID = self.CurOpenMallId
	local MallInfo = self.AllMallServerInfos[ShopID]
	if MallInfo == nil then
		FLOG_ERROR("ShopMgr:CheckJumpToShopItemState MallInfo Do Not Have Data")
		return
	end

	local MallGoodsInfos = MallInfo.MallGoodsInfos
	if MallGoodsInfos == nil or next(MallGoodsInfos) == nil then
		FLOG_ERROR("ShopMgr:CheckJumpToShopItemState MallGoodsInfos Do Not Have Data")
		return
	end

	local SearchCond = string.format("MallID == %d", ShopID)
	local Gcfgs = GoodsCfg:FindAllCfg(SearchCond)
	if Gcfgs == nil or next(Gcfgs) == nil then
		FLOG_ERROR("ShopMgr:CheckJumpToShopItemState GoodsCfg Do Not Have Data")
		return
	end
	local GoodsIDToCheck = {}
	for _, v in pairs(Gcfgs) do
		local ItmArr = v.Items
		local GoodsID = v.ID
		if ItmArr ~= nil and next(ItmArr) ~= nil then
		   local FirstItem = ItmArr[1]
		   if FirstItem ~= nil then
				local ItemResID = FirstItem.ID
				if ItemResIDToCheck == ItemResID then
					table.insert(GoodsIDToCheck, GoodsID)
				end
		   end
		end
	end

	if next(GoodsIDToCheck) == nil then
		FLOG_ERROR("ShopMgr:CheckJumpToShopItemState GoodsIDToCheck Do Not Have Data")
		return
	end

	local GoodsSerInfosToCheck = {}
	for _, v in pairs(GoodsIDToCheck) do
		local GoodsSerInfo = table.find_by_predicate(MallGoodsInfos, function(e)
			return e.GoodsId == v
		end)
		if GoodsSerInfo ~= nil then
			table.insert(GoodsSerInfosToCheck, GoodsSerInfo)
		end
	end

	if next(GoodsSerInfosToCheck) == nil then
		FLOG_ERROR("ShopMgr:CheckJumpToShopItemState GoodsSerInfosToCheck Do Not Have Data")
		return
	end

	table.sort(GoodsSerInfosToCheck, self.SortShopGoodsPredicate)
	local FirstGoodsSerInfo = GoodsSerInfosToCheck[1]
	if FirstGoodsSerInfo ~= nil then
		self:StoreLastSelectedGoodsId(FirstGoodsSerInfo.GoodsId)
	end
end

--- 购买特定数量的特定商品
---@param ShopItemId number@商品ID
---@param Count number@购买数量
function ShopMgr:BuyShopItem(ShopItemId, Count)
	self:SendMsgMallInfoBuy(ShopItemId, Count)
end

--- 当前显示购买还是交换
---@param ShopId number @商店id
---@param IsNeedSpace boolean @是否需要空格
---@return string @购买还是交换
function ShopMgr:IsNeedShowBuyOrExchange(ShopId, IsNeedSpace)
	local TmpSpace = " "
	if not IsNeedSpace then
		TmpSpace = ""
	end
	local Cfg = MallCfg:FindCfgByKey(ShopId)
	if Cfg == nil then
		return ""
	end
	if Cfg.Type == ProtoRes.MallType.MALL_TYPE_Currency then
		return string.format(LSTR(1200081), TmpSpace)
	else
		return string.format(LSTR(1200012), TmpSpace)
	end
end

--- 在打开商店中根据关键字查找所有商品数据
---@param KeyWord string @关键字
---@return table @所有商品数据
function ShopMgr:FindAllItemsInSpecificShopByKeyWord(KeyWord)
	local Result = {}
	local MallInfo = self.AllMallServerInfos[self.CurOpenMallId]
	if MallInfo == nil then
		return nil
	end
	local MallGoodsInfo = MallInfo.MallGoodsInfos
	if MallGoodsInfo == nil then
		return nil
	end
	local bIsForTrial = LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_VERIFY)
	for i = 1, #MallGoodsInfo do
		local GoodsServerInfo = MallGoodsInfo[i]
		local Cfg = GoodsCfg:FindCfgByKey(GoodsServerInfo.GoodsId)
		if nil ~= Cfg then
			local ItemID = self:GetGoodsItemID(GoodsServerInfo.GoodsId)
			local ICfg = ItemCfg:FindCfgByKey(ItemID)
			if ICfg ~= nil then
				--- 提审与正式版本搜索逻辑不同
				local ItemName = ItemCfg:GetItemName(ItemID)
				local bValid = bIsForTrial and ItemName == KeyWord or string.find(ItemName, KeyWord)
				if bValid == true then
					table.insert(Result, GoodsServerInfo)
				end
			end
		end
	end
	return Result
end

--- 创建商店界面页签数据
--- 23.6.20剥离对服务器信息的依赖，将商店页签数据通过表格数据提前创建
---@param ShopId number @商店ID
---@return table @页签数据
function ShopMgr:CreateShopTabVMs(ShopId)
	local ShopCfg = MallCfg:FindCfgByKey(ShopId)
	if ShopCfg == nil then
		return
	end
	local TabDatas = self.MallTabDatas[ShopId]
	TabDatas = TabDatas or {}
	local SearchCond = string.format("MallID == %d", ShopId)
	local GoodsInfos = GoodsCfg:FindAllCfg(SearchCond)
	for _, GCfg in pairs(GoodsInfos) do
		if nil ~= GCfg then
			local LabelMainConv = GCfg.LabelMain
			local LabelSubConv = GCfg.LabelSub
			--local LabelMain = GCfg.LabelMain
			--local LabelSub = GCfg.LabelSub
			local TargetMainTab = table.find_by_predicate(TabDatas, function(e)
				return e.TabName == LabelMainConv
			end)
			if TargetMainTab == nil then
				TargetMainTab = {}
				table.insert(TabDatas, TargetMainTab)
			end
			TargetMainTab.TabName = LabelMainConv
			TargetMainTab.IsAutoExpand = false
			TargetMainTab.IsSelected = false
			if TargetMainTab.ChildList == nil then
				TargetMainTab.ChildList = {}
			end

			local ChildTabData = table.find_by_predicate(TargetMainTab.ChildList, function(e)
				return e.TabName == LabelSubConv
			end)
			if ChildTabData == nil then
				ChildTabData = {}
				table.insert(TargetMainTab.ChildList, ChildTabData)
			end
			ChildTabData.ParentName = LabelMainConv
			ChildTabData.TabName = LabelSubConv
			ChildTabData.FilterDatas = self:CreateFilterDataByGoodsList(LabelMainConv, LabelSubConv, GoodsInfos)
		end
	end
	self.MallTabDatas[ShopId] = TabDatas
end

--- 查找商品页签信息
---@param ShopId number @商店ID
function ShopMgr:FindShopTabVMs(ShopId)
	local ShopCfg = MallCfg:FindCfgByKey(ShopId)
	if ShopCfg == nil then
		return nil
	end
	if self.MallTabDatas[ShopId] == nil or next(self.MallTabDatas[ShopId]) == nil then
		return nil
	end

	FLOG_ERROR("Test TAB LIST111111 = %s",table_to_string(self.MallTabDatas[ShopId]))
	return self.MallTabDatas[ShopId]
end

--- 保存上次选中的商品数据
---@param MallID number @商店ID
---@param GoodsId number @商品ID
---@param LabelMain string @主页签名称
---@param LabelSub string @子页签名称
function ShopMgr:StoreLastSelectedGoodsIdBase(MallID, GoodsId, LabelMain, LabelSub)
	if nil == MallID then
		FLOG_ERROR("ShopMgr:StoreLastSelectedGoodsIdBase MallID is nil")
		return
	end
	self.LastSelectState[MallID] = {
		GoodsId = GoodsId,
		MainTab = LabelMain,
		SubTab = LabelSub
	}
end

--- 保存上次选中的商品数据By valid GoodsID
---@param GoodsId number @商品ID
function ShopMgr:StoreLastSelectedGoodsId(GoodsId)
	local Cfg = GoodsCfg:FindCfgByKey(GoodsId)
	if Cfg == nil then
		return
	end

	self:StoreLastSelectedGoodsIdBase(Cfg.MallID, GoodsId, Cfg.LabelMain, Cfg.LabelSub)
end

--- 初始化商店页签状态（上一次选中物品）
function ShopMgr:RefreshMallSelectStateTabData()
	local CurOpenMallId = self.CurOpenMallId
	local TabsData = self.MallTabDatas[CurOpenMallId]
	if TabsData == nil then
		return
	end
	local SelectState = self.LastSelectState[CurOpenMallId]
	if SelectState == nil or next(SelectState) == nil then
		---无上次选中数据
		SelectState = {}
		for i = 1, #TabsData do
			local TmpMainTab = TabsData[i]
			TmpMainTab.IsAutoExpand = i == 1
			TmpMainTab.IsSelected = i == 1
			if i == 1 then
				SelectState.MainTab = TmpMainTab.TabName
			end
			local TmpSubTabs = TmpMainTab.ChildList
			if TmpSubTabs ~= nil then
				for j = 1, #TmpSubTabs do
					local TmpSubTab = TmpSubTabs[j]
					TmpSubTab.IsSelected = i == 1 and j == 1
					if i == 1 and j == 1 then
						SelectState.SubTab = TmpSubTab.TabName
					end
				end
			end
		end
		self.LastSelectState[CurOpenMallId] = SelectState
	else
		---有上次选中数据
		local SelectedMainTab = SelectState.MainTab
		local SelectedSubTab = SelectState.SubTab
		for i = 1, #TabsData do
			local TmpMainTab = TabsData[i]
			local MainTabName = TmpMainTab.TabName
			TmpMainTab.IsAutoExpand = MainTabName == SelectedMainTab
			TmpMainTab.IsSelected = MainTabName == SelectedMainTab
			local TmpSubTabs = TmpMainTab.ChildList
			if TmpSubTabs ~= nil then
				for j = 1, #TmpSubTabs do
					local TmpSubTab = TmpSubTabs[j]
					local SubTabName = TmpSubTab.TabName
					TmpSubTab.IsSelected = SubTabName == SelectedSubTab
				end
			end
		end
	end
end

--- 查找当前子页签下的商品信息
---@param SubTabName string @子页签名称
---@return table @商品信息
function ShopMgr:GetGoodsInfoByMainAndSubTabName(MainTabName, SubTabName)
	local GoodsInfoUnderTheTab = {}
	local Mall = self.AllMallServerInfos[self.CurOpenMallId]
	if Mall == nil then
		return GoodsInfoUnderTheTab
	end
	local MallGoodsInfo = Mall.MallGoodsInfos
	if MallGoodsInfo ~= nil then
		for i = 1, #MallGoodsInfo do
			local TmpGoodsInfo = MallGoodsInfo[i]
			local GoodsItemCfg = GoodsCfg:FindCfgByKey(TmpGoodsInfo.GoodsId)
			if GoodsItemCfg ~= nil then
				local LabelMainConv = GoodsItemCfg.LabelMain
				local LabelSubConv = GoodsItemCfg.LabelSub
				if LabelMainConv == MainTabName and LabelSubConv == SubTabName then
					table.insert(GoodsInfoUnderTheTab, TmpGoodsInfo)
				end
			end
		end
	end
	return GoodsInfoUnderTheTab
end

--- 根据页签创建筛选器数据 23.6.20 (剥离对服务器数据的依赖)
---@param MainTab string @主页签名称
---@param SubTab string @子页签名称
---@param GoodsList table @商品列表
---@return table @筛选器数据
function ShopMgr:CreateFilterDataByGoodsList(MainTab, SubTab, GoodsList)
	local GoodsInfoUnderTheTab = table.find_all_by_predicate(GoodsList, function(e)
		return e.LabelMain == MainTab and e.LabelSub == SubTab
	end)
	if GoodsInfoUnderTheTab == nil or next(GoodsInfoUnderTheTab) == nil then
		return
	end
	local FilterData = {{{
		Content = LSTR(1200015),
		ItemMainTypeEnum = 0
	}}, {{
		Content = LSTR(1200015),
		ItemMainTypeEnum = 0,
		ItemTypeEnum = 0
	}}, {{
		QualityMax = -1,
		Content = LSTR(1200015)
	}}, {{
		LevelMax = -1,
		Content = LSTR(1200015)
	}}, {{
		Content = LSTR(1200015),
		JobEnum = 0
	}}}

	local MainSort = FilterData[FILTER_MAINTYPE.MainSortType]
	local ViceSort = FilterData[FILTER_MAINTYPE.ViceSortType]
	local QualitySort = FilterData[FILTER_MAINTYPE.ItemQuality]
	local LevelSort = FilterData[FILTER_MAINTYPE.UseLevel]
	local ProfSort = FilterData[FILTER_MAINTYPE.Job]

	local ClassList = {}
	local Prof = {}
	---数据筛选
	for _, Gcfg in pairs(GoodsInfoUnderTheTab) do
		if Gcfg ~= nil then
			local ItemID = self:GetGoodsItemID(Gcfg.ID)
			local SItemCfg = ItemCfg:FindCfgByKey(ItemID)
			if SItemCfg ~= nil then
				---主分类
				local ItemMainTypeInCfg = SItemCfg.ItemMainType
				local ItemType = SItemCfg.ItemType
				local MainSortElm = table.find_by_predicate(MainSort, function(e)
					return e.ItemMainTypeEnum == ItemMainTypeInCfg
				end)
				if MainSortElm == nil then
					local MainDefineInfo = table.find_by_predicate(MainSortInfo, function(e)
						return e.Type == ItemMainTypeInCfg
					end)
					if MainDefineInfo ~= nil then
						table.insert(MainSort, {
							Content = MainDefineInfo.Name,
							ItemMainTypeEnum = ItemMainTypeInCfg
						})
					end
				end
				---副分类
				local ViceSortElm = table.find_by_predicate(ViceSort, function(e)
					return e.ItemTypeEnum == ItemType
				end)
				local TypeCfg = ItemTypeCfg:FindCfgByKey(ItemType)
				if TypeCfg ~= nil then
					if ViceSortElm == nil then
						local Content = TypeCfg.ItemTypeName
						table.insert(ViceSort, {
							Content = Content,
							ItemTypeEnum = ItemType,
							ItemMainTypeEnum = ItemMainTypeInCfg
						})
					end
				end
				---物品品质
				local QualityDis = 10
				local CurQualityMaxPerTen = math.ceil(SItemCfg.ItemLevel / QualityDis) * QualityDis
				local QualitySortElm = table.find_by_predicate(QualitySort, function(e)
					return e.QualityMax == CurQualityMaxPerTen
				end)
				if QualitySortElm == nil then
					local StartQuality = CurQualityMaxPerTen - QualityDis + 1
					local Content = string.format("%d~%d", StartQuality, CurQualityMaxPerTen)
					table.insert(QualitySort, {
						QualityMax = CurQualityMaxPerTen,
						Content = Content
					})
				end
				---使用等级
				local LevelDis = 10
				local CurLevelMaxPerTen = math.ceil(SItemCfg.Grade / LevelDis) * LevelDis
				local LevelSortElm = table.find_by_predicate(LevelSort, function(e)
					return e.LevelMax == CurLevelMaxPerTen
				end)
				if LevelSortElm == nil then
					local StartLv = CurLevelMaxPerTen - LevelDis + 1
					local Content = string.format("%d~%d", StartLv, CurLevelMaxPerTen)
					table.insert(LevelSort, {
						LevelMax = CurLevelMaxPerTen,
						Content = Content
					})
				end
				---职业
				---职业类型限制
				if SItemCfg.ClassLimit ~= ProtoCommon.class_type.CLASS_TYPE_NULL then
					local ClassLimit = table.find_by_predicate(ClassList, function(e)
						return e.JobEnum == SItemCfg.ClassLimit
					end)
					if ClassLimit == nil then
						local ClassLimitName = EquipmentMgr:GetProfClassName(SItemCfg.ClassLimit)
						table.insert(ClassList, {
							Content = ClassLimitName,
							JobEnum = SItemCfg.ClassLimit
						})
					end
				end
				---职业限制
				if #SItemCfg.ProfLimit > 0 then
					for j = 1, #SItemCfg.ProfLimit do
						if SItemCfg.ProfLimit[j] ~= ProtoCommon.prof_type.PROF_TYPE_NULL then
							local ProfLimit = table.find_by_predicate(Prof, function(e)
								return e.JobEnum == SItemCfg.ProfLimit[j]
							end)
							if ProfLimit == nil then
								local ProfLimitName = EquipmentMgr:GetProfName(SItemCfg.ProfLimit[j])
								local Content = ProfLimitName
								table.insert(Prof, {
									Content = Content,
									JobEnum = SItemCfg.ProfLimit[j]
								})
							end
						end
					end
				end
			end
		end
	end

	---排序
	if #ClassList > 0 then
		table.sort(ClassList, function(a, b)
			return a.JobEnum < b.JobEnum
		end)
		for i = 1, #ClassList do
			table.insert(ProfSort, ClassList[i])
		end
	end

	if #Prof > 0 then
		table.sort(Prof, function(a, b)
			return a.JobEnum < b.JobEnum
		end)
		for i = 1, #Prof do
			table.insert(ProfSort, Prof[i])
		end
	end

	table.sort(MainSort, function(a, b)
		return a.ItemMainTypeEnum < b.ItemMainTypeEnum
	end)
	table.sort(ViceSort, function(a, b)
		return a.ItemTypeEnum < b.ItemTypeEnum
	end)
	table.sort(QualitySort, function(a, b)
		return a.QualityMax < b.QualityMax
	end)
	table.sort(LevelSort, function(a, b)
		return a.LevelMax < b.LevelMax
	end)
	return FilterData
end

--- 查找当前子页签下的筛选器信息
function ShopMgr:FindCurSubTabsFilterData()
	local MallID = self.CurOpenMallId
	local MallTabData = self.MallTabDatas[MallID]
	if self.LastSelectState == nil or next(self.LastSelectState) == nil then
		return nil
	end
	local LastSelectState = self.LastSelectState[MallID]
	if LastSelectState == nil then
		return nil
	end
	local MainTab = LastSelectState.MainTab
	local SubTab = LastSelectState.SubTab
	if MainTab == nil or SubTab == nil then
		return nil
	end

	local TargetMainTab = table.find_by_predicate(MallTabData, function(e)
		return e.TabName == MainTab
	end)
	if TargetMainTab == nil then
		return
	end

	local SrcChildList = TargetMainTab.ChildList
	local ChildTabData = table.find_by_predicate(SrcChildList, function(e)
		return e.TabName == SubTab
	end)
	if ChildTabData == nil then
		return nil
	end

	return ChildTabData.FilterDatas
end

--- 记录筛选Tab切换
---@param FilterTypeName string@筛选器类型名
---@param FilterDetail string@筛选器选项名
function ShopMgr:RecordCurFilterChange(FilterTypeName, FilterDetail)
	local FilterSelectDataInit = self.FilterSelectedData == nil or next(self.FilterSelectedData) == nil
	local FilterSelectedData = self.FilterSelectedData or {}
	local ExistFilterDetail = table.find_by_predicate(FilterSelectedData, function(e)
		return e.TypeName == FilterTypeName
	end)

	local HaveDataChanged = ExistFilterDetail == nil or ExistFilterDetail.FilterDetail ~= FilterDetail
	if ExistFilterDetail ~= nil then
		ExistFilterDetail.FilterDetail = FilterDetail
	else
		table.insert(FilterSelectedData, {
			TypeName = FilterTypeName,
			FilterDetail = FilterDetail
		})
	end
	if FilterSelectDataInit then
		self.FilterSelectedData = FilterSelectedData
	end

	if HaveDataChanged == true then
		self.LastSelectState[self.CurOpenMallId].GoodsId = nil
		EventMgr:SendEvent(EventID.UpdateMallGoodsListMsg)
	end
end

function ShopMgr:GetMallInfoByShowType()
	local List = {}
	if self.AllShopInfo then
		for _, v in pairs(self.AllShopInfo) do
			if v.ShowType ~= 0 then
				table.insert(List, v)
			end
		end
	end
	return List
end

function ShopMgr:GetMallInfoByShowTypeIndex(Index)
	local List = {}
	if self.AllShopInfo then
		for _, v in pairs(self.AllShopInfo) do
			if v.ShowTypeIndex == Index then
				table.insert(List, v)
			end
		end
	end
	return List
end


--获取商店一级分类可显示数据
function ShopMgr:GetFirstTypeTab()
	local ShopCfg = self:GetMallInfoByShowType()
	local UnlockList = {}

	for i = 1, #ShopCfg do
		local CurShowType = ShopCfg[i].ShowType
		local Task = ShopCfg[i].Task
		local IsHas = false
		local IsCanAdd = true

		for i = 1, #UnlockList do
			if UnlockList[i].ShowType == CurShowType then
				IsHas = true
			end
		end

		--第三期优化后不管有没有解锁都显示
		-- if Task == 0 then
		--     if not IsHas then
		--         IsCanAdd = true
		--     end
		-- else
		--     local PreTaskState = QuestMgr:GetQuestStatus(Task)
		--     if PreTaskState == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
		--         IsCanAdd = true
		--     end
		-- end

		if IsCanAdd and not IsHas then
			local TabName = ProtoEnumAlias.GetAlias(ProtoRes.ScoreSummaryType, CurShowType)
			local Data = {Name = TabName, ShowTypeIndex = ShopCfg[i].ShowTypeIndex, ShowType = CurShowType}
			table.insert(UnlockList, Data)
		end
	end

	return UnlockList
end

--根据页签获取商店配置
function ShopMgr:GetShopCfgByTab(Index)
	local List = self:GetMallInfoByShowTypeIndex(Index)
	local NewList = {}

	for i = 1, #List do
		local IsUnLock = self:ShopIsUnLock(List[i].ID)
	   if List[i].IsHide ~= 1 or IsUnLock then
			table.insert(NewList, List[i])
		end
	end

	local function Sort(V1,V2)
		if V1.ShopIndex < V2.ShopIndex then
			return true
		else
			return false
		end
	end

	table.sort(NewList, Sort)
	return NewList
end

--根据商店ID获取一级分类信息
function ShopMgr:GetTabListByShopID(ShopID)
	local TabList = self.AllShopInfo[ShopID]
	local TypeInfo

	if TabList == nil then
		FLOG_WARNING("GetTabListByShopID TabList = nil ShopID = %d", ShopID)
		return {}
	end

	TypeInfo = TabList.FirstType
	local TabInfoList = {}
	for _, v in pairs(TypeInfo) do
		local SearchConDitions = string.format("ID == %d",v)
		local TabTypeInfo = MallMainTypeCfg:FindCfg(SearchConDitions)

		if TabTypeInfo and TabTypeInfo.ID ~= 0 then
			local IsShowTab = self:GetCurFirstTypeList(TabTypeInfo.ID)
			if IsShowTab then
				local Data = {AutoLv = TabTypeInfo.AutoLv or 1, Name = TabTypeInfo.Name, PriceType = TabTypeInfo.PriceType, Price = TabTypeInfo.Price, FirstType = TabTypeInfo.ID, FilterInfo = TabTypeInfo, }
				table.insert(TabInfoList, Data)
			else
				print("CurFirstType No GoodListShow FirstType = ", TabTypeInfo.ID)
			end
		else
			FLOG_WARNING("TypeInfo == nil, check FirstType or cfg ID = %d", v)
		end
	end

	return TabInfoList
end

function ShopMgr:SetShopMainTypeOpenList(Data)
	--FLOG_ERROR("TEST data = %s",table_to_string(Data))
	local Key = Data.ShopId
	local Value = Data.MainTypeIndex
	--ShopMgr.FirstTypeIndex = Data.MainTypeIndex
	self.ShopMainTypeOpenList[Key] = self.FirstTypeIndex or 1
	self.FilterSelectName1 = ""
	self.FilterSelectName2 = ""
end

--当前一级分类是否有货品（用于一级分类是否可以显示）
function ShopMgr:GetCurFirstTypeList(FirstType)
	for key, GoodsInfo in pairs(self.CurOpenShopGoodSList.MallGoodsInfos) do
		-- body
		local CurFirstType = GoodsInfo.FirstType
		if CurFirstType == FirstType then
			return true
		end
	end

	return false
end

--根据当前一级分类获取商品信息
function ShopMgr:GetGoodsByType(ShopId, FirstType)
	if self.CurOpenShopGoodSList.MallGoodsInfos == nil then
		return
	end

	local CurTypeGoodsList = {}

	for key, GoodsInfo in pairs(self.CurOpenShopGoodSList.MallGoodsInfos) do
		-- body
		local CurFirstType = GoodsInfo.FirstType
		if CurFirstType == FirstType then
			GoodsInfo.TaskState = _G.QuestMgr:IsQuestGoods(GoodsInfo.ItemID)
			table.insert(CurTypeGoodsList,GoodsInfo)
		end
	end

	table.sort(CurTypeGoodsList, self.SortShopGoodsPredicate)
	self.CurFirstTypeGoodsList = CurTypeGoodsList
	return CurTypeGoodsList

	-- if self.CurFirstTypeGoodsList[ShopId] ~= nil then
	--     if self.CurFirstTypeGoodsList[ShopId][FirstType] ~= nil then
	--         CurTypeGoodsList = self:GetGoodsByFirstType(ShopId, FirstType)
	--     else
	--         CurTypeGoodsList = self:SetGoodsByFirstType(ShopId, FirstType, false)
	--     end
	-- else
	--     CurTypeGoodsList = self:SetGoodsByFirstType(ShopId, FirstType, true)
	-- end

	-- return CurTypeGoodsList
end

function ShopMgr:GetGoodsByFirstType(ShopId, FirstType)
	return self.CurFirstTypeGoodsList[ShopId][FirstType]
end

function ShopMgr:SetGoodsByFirstType(ShopId, FirstType, ShopIsnil)
	local CurTypeGoodsList = {}

	for key, GoodsInfo in pairs(self.CurOpenShopGoodSList.MallGoodsInfos) do
		-- body
		local CurFirstType = GoodsInfo.FirstType
		if CurFirstType == FirstType then
			table.insert(CurTypeGoodsList,GoodsInfo)
		end
	end

	table.sort(CurTypeGoodsList, self.SortShopGoodsPredicate)
	if ShopIsnil then
		self.CurFirstTypeGoodsList[ShopId] = {}
		self.CurFirstTypeGoodsList[ShopId][FirstType] = CurTypeGoodsList
	else
		self.CurFirstTypeGoodsList[ShopId][FirstType] = CurTypeGoodsList
	end

	return CurTypeGoodsList
end

function ShopMgr:GetTimeIsEnable(Good)
	if nil == Good then
		return false
	end

	local CurrentTime = TimeUtil.GetServerLogicTime()
	local OnTime = self:GetTimeInfo(Good.OnTime)
	local OffTime = self:GetTimeInfo(Good.OffTime)
	if OnTime > CurrentTime or (OffTime > 0 and OffTime < CurrentTime) then
		return false
	end

	return true
end

function ShopMgr:GetTimeInfo(Time)
	if Time == nil or Time == "" then
		return 0
	end

	local pattern = "(%d+)-(%d+)-(%d+)_(%d+):(%d+):(%d+)"
	local year, month, day, hour, min, sec = Time:match(pattern)
	local timestamp = os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec})

	return timestamp
end

--获取当前商店商品信息
function ShopMgr:GetGoodsByMallID(MallID)
	local CfgSearchCond = string.format("MallID == %d", MallID)
	return GoodsCfg:FindAllCfg(CfgSearchCond)
end

--获取筛选器相关信息
function ShopMgr:GetScreenerListInfo(ScreenerList)
	local CommScreenerItemList = {}
	local ScrenID = ScreenerList
	local DefaultIndex = 1

	if ScrenID ~= nil then
		local ScreenerInfoList, TempDefaultIndex = self:GetScreenerCfgList(ScrenID)
		DefaultIndex = TempDefaultIndex
		local SingleBoxItemValue = {}
		SingleBoxItemValue.SingleBoxList = ScreenerInfoList
		SingleBoxItemValue.Index = #CommScreenerItemList
		SingleBoxItemValue.ScreenerID = ScrenID
		table.insert(CommScreenerItemList, SingleBoxItemValue)
	end

	local ListData = {}
	local ListLen = #CommScreenerItemList[1].SingleBoxList
	local SingleBoxList = CommScreenerItemList[1].SingleBoxList
	for i = 1, ListLen do
		table.insert(ListData, {Name = SingleBoxList[i].ScreenerName, Data = SingleBoxList[i]})
	end

	return ListData, DefaultIndex
end

---@param SeleceIndex number @选择的下标
---@param FilterIndex number @选的筛选器下标
---@param FirstType number @当前一级分类下的筛选器
function ShopMgr:SetFilterSelectIndex(ShopId, SeleceIndex, FilterIndex, FirstType)
	if not ShopId then
		return
	end

	if not self.FilterIndexList then
		self.FilterIndexList = {}
	end
	local ChosedIndex = SeleceIndex or 1
	if FilterIndex == 1 then
		if self.FilterIndexList[ShopId] ~= nil then
			if self.FilterIndexList[ShopId][FirstType] ~= nil then
				self.FilterIndexList[ShopId][FirstType].Index1 = ChosedIndex
			else
				self.FilterIndexList[ShopId][FirstType] = {}
				self.FilterIndexList[ShopId][FirstType].Index1 = ChosedIndex
			end
		else
			self.FilterIndexList[ShopId] = {}
			self.FilterIndexList[ShopId][FirstType] = {}
			self.FilterIndexList[ShopId][FirstType].Index1 = ChosedIndex
		end

		self.CurChosedFilterIndex = ChosedIndex
	else
		if self.FilterIndexList[ShopId] ~= nil then
			if self.FilterIndexList[ShopId][FirstType] ~= nil then
				self.FilterIndexList[ShopId][FirstType].Index2 = ChosedIndex
			else
				self.FilterIndexList[ShopId][FirstType] = {}
				self.FilterIndexList[ShopId][FirstType].Index2 = ChosedIndex
			end
		else
			self.FilterIndexList[ShopId] = {}
			self.FilterIndexList[ShopId][FirstType] = {}
			self.FilterIndexList[ShopId][FirstType].Index2 = ChosedIndex
		end
	end
end

function ShopMgr:ClearFilterData()
	self.FilterIndexList = {}
end

function ShopMgr:GetGoodsListByFilter(ScreenerID, ProfName, List, Index)
	local SearchCond = {}
	if List == "" or List == nil then
		self.FilterAfterGoodsList = self.CurFirstTypeGoodsList
		return self.CurFirstTypeGoodsList
	end
	local GoodList = {}
	if Index == 1 then
		GoodList = self.CurFirstTypeGoodsList
	else
		GoodList = self.FilterAfterGoodsList
	end
	local NewSearchInfo = string.gsub(List,"[%(%)]","")
	local CondList = string.split(NewSearchInfo,"OR")
	local CondLen = #CondList
	local GoodsLen = #GoodList
		if CondLen > 0 then
			for i = 1, GoodsLen do
				local ItemID = GoodList[i].ItemID
				local ItemInfo = ItemCfg:FindCfgByKey(ItemID)
				local ItemLimit = nil

				for j = 1, CondLen do
					local Limit = string.split(CondList[j],"==")
					local Con1 = string.gsub(Limit[1],"%s+","")
					local Con2

					if Con1 == "ProfLimit" then
						Con2 = tonumber(string.match(Limit[2], "%d+"))
						ItemLimit = ItemInfo[Con1][1]
					else
						Con2 = tonumber(Limit[2])
						ItemLimit = ItemInfo[Con1]
					end

					if ItemLimit == Con2 then
						table.insert(SearchCond, GoodList[i])
					end
				end
			end

			-- for i = 1, CondLen do
			-- 	local Limit = string.split(CondList[i],"==")
			-- 	local Con1 = string.gsub(Limit[1],"%s+","")
			-- 	local Con2 --= tonumber(Limit[2])

			--     -- local Test = self:FindAllSameElements(GoodList, Con1, Con2)
			--     if Con1 == "ProfLimit" then
			--         Con2 = tonumber(string.match(Limit[2], "%d+"))
			--     else
			--         Con2 = tonumber(Limit[2])
			--     end

			-- 	for j = 1, #GoodList do
			-- 		local ItemID = GoodList[j].ItemID
			-- 		local ItemInfo = ItemCfg:FindCfgByKey(ItemID)
			-- 		local ItemLimit = nil

			--         if Con1 == "ProfLimit" then
			--             ItemLimit = ItemInfo[Con1][1]
			--         else
			--             ItemLimit = ItemInfo[Con1]
			--         end

			-- 		if ItemLimit == Con2 then
			--             table.insert(SearchCond, GoodList[j])
			-- 		end
			-- 	end
			-- end
		end

		-- if ScreenerID == 1 then
		-- 	for i = 1, #GoodList do
		-- 		local ItemID = GoodList[i].ItemID
		-- 		local ItemInfo = ItemCfg:FindCfgByKey(ItemID)
		-- 		local State = self:FilterByProf(ProfName, ItemInfo.ProfLimit)

		-- 		if State then
		--             table.insert(SearchCond, GoodList[i])
		-- 		end
		-- 	end
		-- end

		if Index == 1 then
			self.FilterAfterGoodsList = SearchCond
		end

		return SearchCond
end

function ShopMgr:GetCond(ShopInfo, ScreenerID, List, GoodList, Fliter1Index)
	local _ <close> = CommonUtil.MakeProfileTag("ShopGetCond")
	local SearchCond = {}
	local ShopID = ShopInfo.ShopID
	local FirstType = ShopInfo.FirstType
	local ScrIndex = ShopInfo.ScrIndex

	if self.CurFirstTypeFilterList[ShopID] ~= nil then
		if self.CurFirstTypeFilterList[ShopID][FirstType] ~= nil then
			SearchCond = self:GetCondByID(ShopInfo, ScreenerID, List, GoodList, Fliter1Index)
		else
			SearchCond = self:SetCondByID(ShopInfo, ScreenerID, List, GoodList, false, Fliter1Index)
		end
	else
		SearchCond = self:SetCondByID(ShopInfo, ScreenerID, List, GoodList, true, Fliter1Index)
	end
	return SearchCond
end

function ShopMgr:GetCondByID(ShopInfo, ScreenerID, List, GoodList, Fliter1Index)
	local GoodsList = {}
	local ShopID = ShopInfo.ShopID
	local FirstType = ShopInfo.FirstType
	local ScrIndex = ShopInfo.ScrIndex

	if self.CurFirstTypeFilterList[ShopID][FirstType][ScrIndex] ~= nil then
		if not Fliter1Index then
			GoodsList = self.CurFirstTypeFilterList[ShopID][FirstType][ScrIndex]
			return GoodsList
		else
			GoodsList = self:SetCondByID(ShopInfo, ScreenerID, List, GoodList, false, Fliter1Index)
			return GoodsList
		end
	else
		GoodsList = self:SetCondByID(ShopInfo, ScreenerID, List, GoodList, false, Fliter1Index)
		return GoodsList
	end
end

function ShopMgr:SetCondByID(ShopInfo, ScreenerID, List, GoodList, ShopIsnil, Fliter1Index)
	local ShopID = ShopInfo.ShopID
	local FirstType = ShopInfo.FirstType
	local ScrIndex = ShopInfo.ScrIndex

	local SearchCond = {}
	for i = 1,#List do
		local SearchInfo = CommScreenerVM:GetScreenerSearchCond(List[i].Data)
		local isCanShow, CanshowList = self:GetScrGoodsList(ScreenerID, List[i].Name, SearchInfo, GoodList)
		if isCanShow then
			table.insert(SearchCond, {Name = List[i].Name, Data = List[i].Data, GoodsList = CanshowList, Index = #SearchCond + 1})
		end
	end

	if Fliter1Index then
		self.AfterFistFilterList = SearchCond
		return SearchCond
	end

	if ShopIsnil then
		self.CurFirstTypeFilterList[ShopID] = {}
		self.CurFirstTypeFilterList[ShopID][FirstType] = {}
		self.CurFirstTypeFilterList[ShopID][FirstType][ScrIndex] = SearchCond
	else
		if self.CurFirstTypeFilterList[ShopID][FirstType] ~= nil then
			self.CurFirstTypeFilterList[ShopID][FirstType][ScrIndex] = SearchCond
		else
			self.CurFirstTypeFilterList[ShopID][FirstType] = {}
			self.CurFirstTypeFilterList[ShopID][FirstType][ScrIndex] = SearchCond
		end
	end

	return SearchCond
end

function ShopMgr:GetSecondFilterList(FistrFilter, SencondFilter)
	local SencondList = {}
	local FirstrL = #FistrFilter
	local SencondL = #SencondFilter

	for i = 1, SencondL do
		local SencondID = SencondFilter[i].GoodsId
		for j = 1, FirstrL do
			local FirstID = FistrFilter[j].GoodsId
			if SencondID == FirstID then
				table.insert(SencondList, SencondFilter[i])
			end
		end
	end

	return SencondList
end

function ShopMgr:GetScrGoodsList(ScreenerID, ProfName, SearchInfo, GoodList)
	local _ <close> = CommonUtil.MakeProfileTag("ShopGetScrGoodsList")
	local isCanShow = false
	local CanshowList = {}
	if SearchInfo == "" or SearchInfo == nil then
		return true ,GoodList
	else
		local NewSearchInfo = string.gsub(SearchInfo,"[%(%)]","")
		local CondList = string.split(NewSearchInfo,"OR")
		--筛选表职业ProfLimit字段删除后要自己实现ProfLimit相关筛选
		local CondLen = #CondList
		local GoodsLen = #GoodList
		if CondLen > 0 then
			for i = 1, GoodsLen do
				local ItemInfo = GoodList[i].ItemInfo
				if ItemInfo == nil then
					ItemInfo = ItemCfg:FindCfgByKey(GoodList[i].ItemID)
					if ItemInfo == nil then
						FLOG_ERROR("ItemCfg Not Find ID=%d", GoodList[i].ItemID)
						return false
					end
					GoodList[i].ItemInfo= ItemInfo
				end
				local ItemLimit = nil

				for j = 1, CondLen do
					local Limit = string.split(CondList[j],"==")
					local Con1 = string.gsub(Limit[1],"%s+","")
					local Con2

					if Con1 == "ProfLimit" then
						Con2 = tonumber(string.match(Limit[2], "%d+"))
						ItemLimit = ItemInfo[Con1][1]
					else
						Con2 = tonumber(Limit[2])
						ItemLimit = ItemInfo[Con1]
					end

					if ItemLimit == Con2 then
						isCanShow = true
						table.insert(CanshowList, GoodList[i])
					end
				end
			end
		end
	end
	return isCanShow, CanshowList
end

function ShopMgr:FilterByProf(CurProfName, ProfLimitList)
	local IsCanShow = false
	for i = 1, #ProfLimitList do
		local GoodsProfName = ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, ProfLimitList[i])

		if CurProfName == GoodsProfName then
			IsCanShow = true
			break
		end
	end

	return IsCanShow
end

function ShopMgr:GetFilterListIndex(ShopId, FirstType, Type)
	local Index = nil
	if Type == 1 then
		if self.FilterIndexList[ShopId] ~= nil then
			if self.FilterIndexList[ShopId][FirstType] ~= nil then
				Index = self.FilterIndexList[ShopId][FirstType].Index1
			end
		end
	else
		if self.FilterIndexList[ShopId] ~= nil then
			if self.FilterIndexList[ShopId][FirstType] ~= nil then
				Index = self.FilterIndexList[ShopId][FirstType].Index2
			end
		end
	end
	return Index
end

function ShopMgr:GetScreenerCfgList(ScreenerID)
	-- local CurProfClass = MajorUtil.GetMajorProfClass()
	local CurProfID = MajorUtil.GetMajorProfID()
	local CfgSearchCond = string.format("ScreenerID == %d", ScreenerID)
	local TempScrCfg = table.deepcopy(ScreenerInfoCfg:FindAllCfg(CfgSearchCond))
	local TempDefaultIndex = 1
	for Index, cfg in ipairs(TempScrCfg) do
		for _, str in ipairs(cfg.FilterOR) do
			local profLimits = string.match(str, "ProfLimit == %{(.-)%}")
			if profLimits then
				for profID in string.gmatch(profLimits, "%d+") do
					if tonumber(profID) == CurProfID then
						cfg.ScreenerName = cfg.ScreenerName .. LSTR(1200096)	--- 当前
						cfg.IsCurProf = true
						TempDefaultIndex = Index
						goto IterationFinishi
					end
				end
			end
		end
	end
	::IterationFinishi::
	if self.JumpToGoodsState then
		TempDefaultIndex = 1
	end
	return TempScrCfg, TempDefaultIndex
end

--通过装备部位来获取物品表的部位
function ShopMgr:GetEquipPartByGoodPart(EquipPart)
	local part = EquipPart
	if EquipPart > ProtoCommon.equip_part.EQUIP_PART_FEET then
		if EquipPart == ProtoCommon.equip_part.EQUIP_PART_NECK then
			part = ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_NECK
		elseif EquipPart == ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER or EquipPart == ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER then
			part = ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_RING
		elseif EquipPart == ProtoCommon.equip_part.EQUIP_PART_WRIST then
			part = ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FINESSE
		elseif EquipPart == ProtoCommon.equip_part.EQUIP_PART_EAR then
			part = ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_ERR
		end
	end

	return part
end

--通过物品部位来获取装备的部位
function ShopMgr:GetGoodsPartByEquipPart(Classify)
	if Classify == nil then
		FLOG_ERROR("GetGoodsPartByEquipPart Classify == Nil")
		return
	end
	local part = Classify
	local PartList = {}
	if Classify > ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FOOT then
		if Classify == ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_NECK then
			part = ProtoCommon.equip_part.EQUIP_PART_NECK
			table.insert(PartList, part)
		elseif Classify == ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_RING then
			table.insert(PartList, ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER)
			table.insert(PartList,  ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER)
		elseif Classify == ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FINESSE then
			part = ProtoCommon.equip_part.EQUIP_PART_WRIST
			table.insert(PartList, part)
		elseif Classify == ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_ERR then
			part = ProtoCommon.equip_part.EQUIP_PART_EAR
			table.insert(PartList, part)
		end
	else
		table.insert(PartList, part)
	end

	return PartList
end

--当前商店是否能搜索
function ShopMgr:CurShopIsCanSearch(ShopID)
	if self.AllShopInfo[ShopID] then
		if self.AllShopInfo[ShopID].IsPortable == 1 then--and self.AllShopInfo[ShopID].EnableSearch == 1 then
			return true
		end
	else
		return false
	end

	return false
end

function ShopMgr:SetSearchList(NormalList, ServerIDsList, ServerInfoList)
	if #ServerIDsList > 0 and #NormalList > 0 then
		self:SetNromalSearch(NormalList)
		self:SetServerSearch(ServerIDsList, ServerInfoList)
	elseif #ServerIDsList > 0 and #NormalList <= 0 then
		self:SetServerSearch(ServerIDsList, ServerInfoList)
	elseif #ServerIDsList <= 0 and #NormalList > 0 then
		self:SetNromalSearch(NormalList)
		EventMgr:SendEvent(EventID.UpdateSerchGoods, self.ShopMainSearchList)
	end
end
function ShopMgr:SetNromalSearch(List)
	self:SetSearchGoodsInfo(List)
end

function ShopMgr:SetServerSearch(ServerQueryList, ServerQueryInfoList)
	self:SendQueryResIDs(ServerQueryList, ServerQueryInfoList)
end

function ShopMgr:SetAfterServerSearch(List)
	local GoodsList = {}
	for GoodsID, value in pairs(List) do
		local Data = {}
		local GoodsData = self:GetGoodsData(value.ShopID, GoodsID)
		if nil ~= GoodsData then
			Data.GoodsInfo = GoodsData.GoodsInfo
			Data.ItemInfo = GoodsData.ItemInfo
			Data.Infos = value.Infos
			Data.Conds = value.Conds
			Data.ShopID = value.ShopID
			table.insert(GoodsList, Data)
		end
	end

	self:SetSearchGoodsInfo(GoodsList)
end

function ShopMgr:SetSearchGoodsInfo(List)
	local GoodsList = List
	for _, value in pairs(GoodsList) do
		local GoodsInfo = value.GoodsInfo
		local ShopID = value.ShopID
		if self:IsCanShow(GoodsInfo) then
			local bCfgDisabled = GoodsInfo.Disabled
			if bCfgDisabled ~= nil and bCfgDisabled == 0 then
				local TmpGoods = {}
				TmpGoods.MallID = ShopID
				TmpGoods.GoodsId = GoodsInfo.ID
				TmpGoods.FirstType = GoodsInfo.FirstType
				TmpGoods.Discount = GoodsInfo.Discount
				TmpGoods.DiscountDurationStart = self:GetTimeInfo(GoodsInfo.DiscountDurationStart)
				TmpGoods.DiscountDurationEnd = self:GetTimeInfo(GoodsInfo.DiscountDurationEnd)
				TmpGoods.BoughtCount = 0
				TmpGoods.ItemID = GoodsInfo.Items[1].ID
				TmpGoods.IsSoldOut = false
				TmpGoods.Price = GoodsInfo.Price
				TmpGoods.PurchaseConditions = GoodsInfo.PurchaseConditions
				TmpGoods.IsSpecial = GoodsInfo.IsSpecial
				TmpGoods.Items = GoodsInfo.Items
				TmpGoods.ItemInfo = value.ItemInfo
				TmpGoods.OnTime = GoodsInfo.OnTime
				TmpGoods.OffTime = GoodsInfo.OffTime
				TmpGoods.DisplayID = GoodsInfo.DisplayID
				TmpGoods.OnVersion = GoodsInfo.OnVersion
				TmpGoods.OffVersion = GoodsInfo.OffVersion
				local CounterInfo = self:GetGoodsCounterInfo(ShopID, GoodsInfo.ID)
				if CounterInfo then
					TmpGoods.CounterInfo = CounterInfo
					local RestrictionType, BoughtCount, IsSoldOut = self:GetGoodsBoughtCountAndIsSoldOut(CounterInfo)
					TmpGoods.RestrictionType = RestrictionType
					TmpGoods.BoughtCount = BoughtCount
					TmpGoods.IsSoldOut = IsSoldOut
					TmpGoods.CounterInfo = {}
					TmpGoods.CounterInfo.CounterFirst = CounterInfo.CounterFirst
					TmpGoods.CounterInfo.CounterSecond = CounterInfo.CounterSecond
				end

				local CondsInfo = value.Conds
				if CondsInfo then
					local IsCanshow = CondsInfo.Show
					local Purchase = CondsInfo.Purchase
					if IsCanshow then
						local bBuyDesc
						TmpGoods.bBuy = Purchase
						if Purchase then
							bBuyDesc = ""
						else
							if #value.GoodsInfo.PurchaseConditions > 0 then
								bBuyDesc = value.GoodsInfo.PurchaseConditions[1].Desc[1] or ""
							else
								bBuyDesc = ""
							end
						end
						TmpGoods.bBuyDesc = bBuyDesc
						table.insert(self.ShopMainSearchList, TmpGoods)
					end
				else
					local bBuyDesc
					TmpGoods.bBuy, bBuyDesc = self:IsCanBuy(TmpGoods)
					TmpGoods.bBuyDesc = bBuyDesc or ""
					table.insert(self.ShopMainSearchList, TmpGoods)
				end
			end
		end
	end
end


function ShopMgr:GetGoodsCounterInfo(ShopID, GoodsID)
	local CounterInfo = nil
	if self.AllGoodsInfo[ShopID] and self.AllGoodsInfo[ShopID][GoodsID] then
		CounterInfo = {}
		CounterInfo.CounterFirst = {}
		CounterInfo.CounterSecond = {}
		local Info = self.AllGoodsInfo[ShopID][GoodsID]
		CounterInfo.CounterFirst.CounterID = Info.GoodsInfo and Info.GoodsInfo.GoodsCounterFirst or 0
		CounterInfo.CounterSecond.CounterID = Info.GoodsInfo and Info.GoodsInfo.GoodsCounterSecond or 0
	end

	return CounterInfo
end


function ShopMgr:SetSaveString(Str)
	Str = Str:sub(2, -2)
	local Tab = {}
	for key, value in Str:gmatch("(%d+)=(%d+)") do
		Tab[tonumber(key)] = tonumber(value)
	end

	return Tab
end

function ShopMgr:GetCurTabInfoFitLv()
	local ProfID = MajorUtil.GetMajorProfID()
	local CurLv = MajorUtil.GetMajorLevelByProf(ProfID)
	local MajorSp = RoleInitCfg:FindProfSpecialization(ProfID)
	local TabInfo = self.CurOpenTabInfo
	local ChoseIndex = 1
	local IsAutoLv = false

	for i, value in ipairs(TabInfo) do
		if value.AutoLv and value.AutoLv > 0 and value.AutoLv <= CurLv then
			local Cur = math.abs(value.AutoLv - CurLv)
			local Next = math.abs(TabInfo[ChoseIndex].AutoLv - CurLv)

			if Cur <= Next and (value.FilterInfo.Specialization == MajorSp or value.FilterInfo.Specialization == 0) then
				ChoseIndex = i
			end

			IsAutoLv = true
		end
	end

	return ChoseIndex, IsAutoLv
end

---GetGoodsData
---@param ShopID number
---@param GoodsID number
---@return table {GoodsInfo, ItemInfo}
function ShopMgr:GetGoodsData(ShopID, GoodsID)
	local GoodsInfo = self.AllGoodsInfo[ShopID]
	if nil == GoodsInfo then
		return
	end

	return GoodsInfo[GoodsID]
end

function ShopMgr:GetGoodsInfo(ShopID, GoodsID)
	local GoodsData = self:GetGoodsData(ShopID, GoodsID)
	if nil == GoodsData then
		return
	end

	return GoodsData.GoodsInfo
end

--- 获取职能限制对应的职业数组
function ShopMgr:GetProfLimitListByClassLimit(ClassLimit)
	local TempCfg = {}
	if ClassLimit == ProtoCommon.class_type.CLASS_TYPE_COMBAT or ClassLimit == ProtoCommon.class_type.CLASS_TYPE_PRODUCTION then
		TempCfg = RoleInitCfg:GetOpenProfCfgListBySpecialization(ClassLimit - 7)
	else
		TempCfg = RoleInitCfg:GetOpenProfCfgListByClass(ClassLimit)
	end
	local TempProfLimit = {}
	for _, value in ipairs(TempCfg) do
		table.insert(TempProfLimit, value.Prof)
	end
	return TempProfLimit
end

function ShopMgr:CheckEquipIconUpState(ItemCfg, EquipList)
    --- 副手武器只有骑士剑术师判断
	if ItemCfg.Classify == ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_DEPUTY_HAND then
		if MajorUtil.GetMajorProfID() == ProtoCommon.prof_type.PROF_TYPE_PALADIN or MajorUtil.GetMajorProfID() == ProtoCommon.prof_type.PROF_TYPE_GLADIATOR then
			return _G.RollMgr:CheckAllEquipIsHighestItemLevel(ItemCfg, EquipList)
		end
		return false
	end
	return _G.RollMgr:CheckAllEquipIsHighestItemLevel(ItemCfg, EquipList)
end

function ShopMgr:GetTextColor_Blue()
	return TipsColor_Blue
end

function ShopMgr:GetTextColor_Red()
	return TipsColor_Red
end

function ShopMgr:GetTextColor_Nomal()
	return TipsColor_Nomal
end

--- 获取下周一的时间戳
function ShopMgr:GetNextMonday_ZeroMS()
	local timestamp = _G.TimeUtil.GetServerLogicTime() -- 默认当前时间
	local currentWday = tonumber(os.date("%w", timestamp))
	currentWday = currentWday == 0 and 7 or currentWday

	local daysToAdd = (8 - currentWday) % 7
	if daysToAdd == 0 then daysToAdd = 7 end

	local nextMonday = os.date("*t", timestamp + daysToAdd * 86400)
	nextMonday.hour, nextMonday.min, nextMonday.sec = 0, 0, 0

	return os.time(nextMonday) - timestamp
end

--- 数据上报
---@param OpenType number@打开类型 1 进入商会  2 进入特定商店
---@param StoreID number@商店ID
---@param TypeID number@商会类型Index 金币 共通等
---@param Source number@非跳转进商店1 跳转进2
function ShopMgr:ReportShopData(OpenType, StoreID, TypeID, Source)
	DataReportUtil.ReportSystemFlowData("StoreVisitFlow", tostring(OpenType), tostring(StoreID), tostring(TypeID), tostring(Source))
end

function ShopMgr:GetJumpType()
	--如果指定了TabIndex ShopMgr.ShopMainTypeIndex直接等于Index 如果是一级分类ID 则进行查找匹配
	local Index = self.ShopMainTypeIndex
	local TabInfoList = self:GetTabListByShopID(self.CurOpenMallId)
	for i = 1, #TabInfoList do 
		if TabInfoList[i].FirstType == ShopMgr.ShopMainTypeIndex then
			Index = i
			return Index
		end
	end

	for _, value in ipairs(TabInfoList) do
		--- 打开商店时，tab下标不传默认是shopid*100+1，但是有可能第一个未解锁，或其他情况未显示，这里就为空，所以这里再匹配一次
		if value.FirstType == Index then
			return Index
		end
	end
	for index, value in ipairs(TabInfoList) do
		ShopMgr.ShopMainTypeIndex = value.FirstType
		return index
	end

	return Index
end

return ShopMgr