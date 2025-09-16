
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ActorMgr = require("Game/Actor/ActorMgr")
local UIViewMgr = require("UI/UIViewMgr")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local CounterMgr = require("Game/Counter/CounterMgr")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")

local StoreCfg = require("TableCfg/StoreCfg")
-- local StoreGiftstyleCfg = require("TableCfg/StoreGiftstyleCfg")
local StoreMallCfg = require("TableCfg/StoreMallCfg")
local ScoreCfg = require("TableCfg/ScoreCfg")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local CondCfg = require("TableCfg/CondCfg")
local RaceCfg = require("TableCfg/RaceCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local CounterCfg = require("TableCfg/CounterCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local StoreCouponCfg = require("TableCfg/StoreCouponCfg")
local ClosetSuitCfg = require("TableCfg/ClosetSuitCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local HairCfg = require("TableCfg/HairCfg")
local MysteryboxCfg = require("TableCfg/MysteryboxCfg")
local CommercializationRandConsumeCfg = require("TableCfg/CommercializationRandConsumeCfg")
local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
local UIViewID = require("Define/UIViewID")
local StoreDefine = require("Game/Store/StoreDefine")
local ObjectGCType = require("Define/ObjectGCType")
local SaveKey = require("Define/SaveKey")
local ItemVM = require("Game/Item/ItemVM")
local UIBindableList = require("UI/UIBindableList")
local StorePriceVM = require("Game/Store/VM/StorePriceVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CsMallAndStoreCmd
local MysterBoxSubCmd = ProtoCS.Game.BlindBox.CS_BLINDBOX_CMD
local RoleGender = ProtoCommon.role_gender
local ItemCondType = ProtoRes.CondType
local Store_CouponType = ProtoRes.Store_CouponType
local BuyIconPath = {
	[1] = "Texture2D'/Game/UI/Texture/Store/UI_Store_Goods_42.UI_Store_Goods_42'",
	[2] = "Texture2D'/Game/UI/Texture/Store/UI_Store_Goods_41.UI_Store_Goods_41'",
}
local function FuncStringToTable(Str)
	Str = Str:gsub("[{}]", "")

	local Tbl = {}

	for key, value in Str:gmatch("(%d+)=(%d+)") do
		Tbl[tonumber(key)] = tonumber(value)
	end
	return Tbl
end
local TimePattern = "(%d+)-(%d+)-(%d+)_(%d+):(%d+):(%d+)"

---@class StoreMgr : MgrBase
---@field ProductDataList table<number, table> 商品数据二次处理整合数据结构
---@field ProductCategory table<number, table> 商品类别二次处理整合数据结构
local StoreMgr = LuaClass(MgrBase)

--region Inherited
function StoreMgr:OnInit()
	self.ProductDataList = nil
	self.ProductCategory = nil
	self.GiftModeProductCategory = nil
	self.MeshKeyWordList = nil
	self.MysteryBoxDownTimerList = {}
	self.MysteryBoxUpTimerList = {}
	self.RedDotPathList = {}
	self.LimitCounterMap = {} -- 限购计数器到商品的映射
	--- CommRewardPanel内部逻辑不适配发型Icon,所以这里初始化ItemVMList传进去
	self.MysterBoxRewardList = UIBindableList.New(ItemVM)
	self.CommRewardPannelResPath = "WidgetBlueprint'/Game/UI/BP/Common/Reward/CommRewardPanel_UIBP.CommRewardPanel_UIBP_C'"
	self.CommRewardPannel = nil
	self.MysterBoxBoughtCount = nil
end

function StoreMgr:OnBegin()
end

function StoreMgr:OnEnd()
	self.ProductDataList = nil
	self.ProductCategory = nil
	self.GiftModeProductCategory = nil
	self.MeshKeyWordList = nil
	self.MysterBoxRewardList = nil
	self.MysterBoxBoughtCount = nil
end

function StoreMgr:OnShutdown()
	self.ProductDataList = nil
	self.ProductCategory = nil
	self.GiftModeProductCategory = nil
	self.MeshKeyWordList = nil
	self.MysterBoxRewardList = nil
	self.MysterBoxBoughtCount = nil
end

function StoreMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MALL_AND_STORE, SUB_MSG_ID.CS_MALL_AND_STORE_CMD_MALL_PURCHASE, self.OnNetBuyGood)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MALL_AND_STORE, SUB_MSG_ID.CS_MALL_AND_STORE_CMD_MALL_QUERY, self.OnNetQueryInfo)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MALL_AND_STORE, SUB_MSG_ID.CS_MALL_AND_STORE_CMD_MALL_GIFT, self.OnNetNetGift)

	--- 奇遇盲盒
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BLINDBOX, MysterBoxSubCmd.GETLIST, self.OnNetMysterBoxGetList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BLINDBOX, MysterBoxSubCmd.BUY, self.OnNetBuyMysterBox)
end

function StoreMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
	self:RegisterGameEvent(EventID.CounterUpdate, self.OnCounterUpdate)
end
--endregion

--region Data Base
function StoreMgr:InitData()
	local ProductCfg = StoreCfg:FindAllCfg()
	local TempCouponCfg = StoreCouponCfg:FindAllCfg()
	self.TempCouponCfg = TempCouponCfg
	self.ProductDataList = {}
	self.MeshKeyWordList = {}

	local ProductData
	for _, Product in ipairs(ProductCfg) do
		ProductData = {}
		if 0 == Product.Disabled then
			ProductData.Cfg = Product
			if Product.Background ~= nil and self.MeshKeyWordList[Product.Background] == nil then
				self.MeshKeyWordList[Product.Background] = Product.Background
			end
			local IsEnable = self:CheckWorldID(Product.DisabledWorldIds)
			if IsEnable then
				self.ProductDataList[Product.ID] = ProductData
			end
			if nil ~= Product.GoodsCounterFirst and Product.GoodsCounterFirst > 0 then
				self.LimitCounterMap[Product.GoodsCounterFirst] = Product.ID
			end
			if nil ~= Product.GoodsCounterSecond and Product.GoodsCounterSecond > 0 then
				self.LimitCounterMap[Product.GoodsCounterSecond] = Product.ID
			end
		end
	end

	local MallCfg = StoreMallCfg:FindAllCfg()
	self.ProductCategory = {}

	for _, Mall in ipairs(MallCfg) do
		self.ProductCategory[#self.ProductCategory + 1] = Mall
	end
	table.sort(self.ProductCategory, function(A, B)
		return A.DisplayID < B.DisplayID
	end)
	local TempProductCategory = {}
	for _, Category in ipairs(self.ProductCategory) do
		local TempProductList = StoreMgr:GetProductDataByCategory(Category)
		if #TempProductList > 0 or Category.Type == ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX then
			table.insert(TempProductCategory, Category)
		end
	end
	self.ProductCategory = TempProductCategory

	-- self.DefaultUnlockedStyleList = {}
	-- local UnlockedList = StoreGiftstyleCfg:FindAllCfg("Locked=1")
	-- for i = 1, #UnlockedList do
	-- 	table.insert(self.DefaultUnlockedStyleList, UnlockedList[i].StyleID, UnlockedList[i].StyleID)
	-- end
	local TempServerRedDotData = _G.ClientSetupMgr:GetSetupValue(MajorUtil.GetMajorRoleID(), ClientSetupID.StoreMasterBoxReddot)
	self.MasteryBoxServerUpValue = {}
	if TempServerRedDotData ~= nil then
		self.MasteryBoxServerUpValue = FuncStringToTable(TempServerRedDotData)
	end
	self:InitProductDataByReq()
	-- self:InitMsteryBoxData()
end

function StoreMgr:GetScoreCfg(ID)
	return ScoreCfg:FindCfgByKey(ID)
end

function StoreMgr:GetItemCfg(ID, BtnViewVisible)
	local TempItemCfg = ItemCfg:FindCfgByKey(ID)
	if TempItemCfg == nil then
		return
	end
	local ItemData = {
		Name = TempItemCfg.ItemName,
		IconID = TempItemCfg.IconID,
		Classify = TempItemCfg.Classify,
		ItemColor = TempItemCfg.ItemColor,
		ItemID = TempItemCfg.ItemID,
		ItemType = TempItemCfg.ItemType,
		EquipmentID = TempItemCfg.EquipmentID,
		BtnViewVisible = BtnViewVisible,
	}
	return ItemData
end

function StoreMgr:GetHairCfg(ID, BtnViewVisible)
	local TempHairCfg = HairUnlockCfg:FindCfgByID(ID)
	if TempHairCfg == nil then
		-- FLOG_ERROR("StoreMgr  GetHairCfg  ID is nil")
		return
	end
	
	return self:GetItemCfg(TempHairCfg.UnlockItemID, BtnViewVisible)
end

function StoreMgr:GetMallCfg(ID)
	return StoreMallCfg:FindCfgByKey(ID)
end

function StoreMgr:GetGoodCfg(ID)
	return StoreCfg:FindCfgByKey(ID)
end

-- 获取单个商品配置
function StoreMgr:GetProductDataByID(ID)
	if nil == ID then
		return nil
	end
	if self.ProductDataList == nil or self.ProductCategory == nil then
		self:InitData()
	end
	if self.ProductDataList == nil or self.ProductDataList[ID] == nil then
		return nil
	end
	return self.ProductDataList[ID]
end

---@type 获取指定类型商品
---@param Category table 商品类型数据
---@param StoreMode boolean 商城模式, 购买/赠送
---@return table, table 商品数据列表, 商品子类型列表
function StoreMgr:GetProductDataByCategory(Category, StoreMode)
	local ProductResult = {}
	
	if Category.Type == ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX then
		return self.MysteryboxData
	end
	local bBuyMode = StoreMode == nil or StoreMode == StoreDefine.StoreMode.Buy or
		Category.Type == ProtoRes.StoreMall.STORE_MALL_RECOMMEND
	local bGiftMode = StoreMode == StoreDefine.StoreMode.Gift
	for _, Product in pairs(self.ProductDataList) do
		local ProductMallType = self.LabelMainToMallType(Product.Cfg.LabelMain)
		if (bBuyMode and ProductMallType == Category.Type) or (bGiftMode and ProductMallType == Category.Type and
				Product.Cfg.BuyForOther == 1 and Product.Cfg.GoodsCounterFirst == 0) then
			if self:CheckOnTimeLimit(Product.Cfg) then
				table.insert(ProductResult, Product)
			end
		end
	end

	if Category.IsDisplayHaveFilter == 1 then 
		table.sort(ProductResult, function(a, b)
			if a.Cfg.BoughtCount == nil or b.Cfg.BoughtCount == nil then
				return false
			end
			if a.Cfg.ID == nil or b.Cfg.ID == nil then
				return false
			end
		
			if a.Cfg.BoughtCount ~= b.Cfg.BoughtCount then
				return a.Cfg.BoughtCount < b.Cfg.BoughtCount
			elseif a.Cfg.ID ~= b.Cfg.ID then
				return a.Cfg.ID < b.Cfg.ID
			end
		end)
	end

	ProductResult = self:CheckGoodsIsValid(ProductResult)
	return ProductResult
end

function StoreMgr:GetProductDataByLabelSub(DataList, LabelSub)
	local TempDataList = {}
	for _, Product in ipairs(DataList) do
		if Product.Cfg.LabelSub == LabelSub then
			table.insert(TempDataList, Product)
		end
	end
	return TempDataList
end

function StoreMgr:CheckGoodsIsValid(DataList)
	if DataList == nil then
		return
	end
	local TempDataList = {}
	for i = 1, #DataList do
		local TempItemdata = DataList[i].Cfg
		if self:IsCanShow(TempItemdata.ID) then
			table.insert(TempDataList, DataList[i])
		end
	end

	return TempDataList
end

--- 商品是否可展示
---@param GoodsId number@商品id
function StoreMgr:IsCanShow(GoodsId)
	local TmpGoodsCfg = StoreCfg:FindCfgByKey(GoodsId)
	if TmpGoodsCfg == nil then
		return false
	end

	--- 商城内部隐藏逻辑，从外部活动购买
	if TmpGoodsCfg.Hide == 1  then
		return false
	end

	-- 禁用商品
	if TmpGoodsCfg.Disabled == 1 then
		return false
	end

	-- 按区禁用
	if not self:CheckWorldID(TmpGoodsCfg.DisabledWorldIds) then
		return false
	end

	--- 校验版本号
	local OnVsEnable, OffVsEnable = self:CheckVersionByGlobalVersion(TmpGoodsCfg)
	--- 上下架字段检验不通过
	if (not OnVsEnable or not OffVsEnable)then
		return false
	end

	--商品是否在上架时间内
	local OnTime =  self:GetTimeInfo(TmpGoodsCfg.OnTime)
	local OffTime = self:GetTimeInfo(TmpGoodsCfg.OffTime)
	if OnTime > 0 and OffTime > 0 then
		local ServerTime = TimeUtil.GetServerLogicTime() --秒
		local IsStart = ServerTime - OnTime
		local RemainSeconds = OffTime - ServerTime
		if RemainSeconds < 0 or IsStart < 0 then
			return false
		end
	end

	---配表展示条件
	local GoodsShowConditionType = ProtoRes.GoodsShowConditionType
	local ShowConditions = TmpGoodsCfg.ShowConditions
	if ShowConditions == nil or next(ShowConditions) == nil then
		return true
	end
	for i = 1, #ShowConditions do
		local Cond = ShowConditions[i]
		if Cond and Cond.CondType > 0 then
			local ProfID = MajorUtil.GetMajorProfID()
			local CurrentProfInfo = {}
			local RoleDetail = ActorMgr:GetMajorRoleDetail()
			local ProfList = RoleDetail.Prof.ProfList
			for _, value in pairs(ProfList) do
				if value.ProfID == ProfID then
					CurrentProfInfo = value
					break
				end
			end
			local CondType = Cond.CondType
			local CondValues = Cond.Values
			if tonumber(CondType) and CondValues ~= nil and next(CondValues) then
				if CondType == GoodsShowConditionType.GOODS_SHOW_COND_UseLv then
					local ProfLevel = CurrentProfInfo.Level
					if not ProfLevel or ProfLevel < CondValues[1] then
						--FLOG_ERROR("no show 1 = %s",DescContent)
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_JobType then
					local MajorClass = RoleInitCfg:FindProfClass(ProfID)
					if CondValues[1] ~= ProtoCommon.class_type.CLASS_TYPE_NULL and CondValues[1] ~= MajorClass then
						--FLOG_ERROR("no show 2 = %s",DescContent)
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_Job then
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
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_Sex then
					local MajorGender = MajorUtil.GetMajorGender()
					local LimitGender = CondValues[1]
					if LimitGender ~= ProtoCommon.role_gender.GENDER_UNKNOWN and LimitGender ~= MajorGender then
						--FLOG_ERROR("no show 4 = %s",DescContent)
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_Race then
					local MajorRace = MajorUtil.GetMajorRaceID()
					local RaceTypeLimit = CondValues[1]
					if RaceTypeLimit ~= ProtoCommon.race_type.RACE_TYPE_NULL and MajorRace ~= RaceTypeLimit then
						--FLOG_ERROR("no show 5 = %s",DescContent)
						return false
					end
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_COMBAT_MAX_LV then
					local IsCan = false
					local DescContent = Cond.Desc
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
					return IsCan, DescContent
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COND_MANU_MAX_LV then
					local IsCan = false
					local DescContent = Cond.Desc
					for _, v in pairs(ProfList) do
						local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
						if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
							local CurLv = v.Level
							local NeedLv = CondValues[1]

							if CurLv >= NeedLv then
								IsCan = true
								break
							end
						end
					end
					return IsCan, DescContent
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_COMPLETED_DUNGEON then
					local CompletedDungeonNum = CounterMgr:GetCounterCurrValue(CondValues[1]) -- 对应副本通关次数
					return CompletedDungeonNum ~= nil and CompletedDungeonNum > 0
				elseif CondType == GoodsShowConditionType.GOODS_SHOW_UNLOCK_MOUNT then
					local DescContent = Cond.Desc
					local MountID = CondValues[1]
					if MountID == nil then
						return false
					end
					return _G.MountMgr:IsMountOwned(MountID), DescContent
				end
			end
		end
	end

	return true
end

function StoreMgr:IsCanShowMysteryBox(MysteryBoxID)
	local MysterBoxCfgData = MysteryboxCfg:FindCfgByKey(MysteryBoxID)
	if nil == MysterBoxCfgData then
		return false
	end
	local OnTime = string.gsub(MysterBoxCfgData.ListingTime, " ", "_")
	local OffTime = string.gsub(MysterBoxCfgData.RemovalTime, " ", "_")
	local TimeData = {OnTime = OnTime, OffTime = OffTime}
	return self:CheckWorldID(MysterBoxCfgData.ZoneBlackList) and self:CheckOnTimeLimit(TimeData)
		and _G.UE.UVersionMgr.IsBelowOrEqualGameVersion(MysterBoxCfgData.OnVersion)
end

-- 是否可赠送
function StoreMgr:CanGift(GoodsID)
	local bCanGift = false
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil ~= GoodsCfgData then
		bCanGift = GoodsCfgData.BuyForOther == 1 and GoodsCfgData.GoodsCounterFirst == 0
	end
	return bCanGift
end

--[[
		上架版本号，下架版本号都不填，则默认为所有版本都上架对用商品。
		只填写了上架版本号，没有填下架版本号，则大于&等于上架版本号的版本，才上架对应商品。
		没有填上架版本号，只填写了下架版本号，则小于下架版本号的版本，才上架对应商品。
		上架版本号，下架版本号都填写了，则 大于&等于上架版本号 且 小于下架版本号 的版本，才上架对应商品。
	]]
--- 校验版本号
---@param GoodData table 物品信息 需包含--OnVersion/OffVersion两个字段
function StoreMgr:CheckVersionByGlobalVersion(GoodData)
    local OnVersion = GoodData.OnVersion
    local OffVersion = GoodData.OffVersion
	--- 如果两个都是空字符串 就直接返回true
	local OnVsEnable = true
	local OffVsEnable = true

	--- 检查上架号
	if not string.isnilorempty(OnVersion) then
		OnVsEnable = _G.ClientVisionMgr:CheckVersionByGlobalVersion(OnVersion)
	end
	--- 检查下架号
	if not string.isnilorempty(OffVersion) then
		OffVsEnable = not _G.ClientVisionMgr:CheckVersionByGlobalVersion(OffVersion)
	end
	--- 两个值都为true才生效
	return OnVsEnable, OffVsEnable
end

function StoreMgr:GetTimeInfo(Time)
	if Time == nil or Time == "" then
		return 0
	end

	local Year, Month, Day, Hour, Min, Sec = Time:match(TimePattern)
	if Year == nil or Month == nil or Day == nil or Hour == nil or Min == nil or Sec == nil then
		return 0
	end
	local Timestamp = os.time({ year = Year, month = Month, day = Day, hour = Hour, min = Min, sec = Sec})

	return Timestamp
end

function StoreMgr:GetProductCategory(Index)
	local TempProductCategory = self:GetProductCategoryList()
	if Index == nil then
		return TempProductCategory
	end

	if _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		return TempProductCategory[Index]
	else
		if self.GiftModeProductCategory[Index] == nil then
			return TempProductCategory[Index]
		else
			return self.GiftModeProductCategory[Index]
		end
	end
end

--- 获取购买模式对应Tab下标
---@param Index number 赠礼模式下选择下标
---@return Index number 购买对应下标
function StoreMgr:GetBuyModeTabIndex(Index)
	local TempProductCategory = self:GetProductCategoryList()
	local ProductCategoryLength = self:GetProductCategoryLength()
	if self.GiftModeProductCategory == nil or Index == 0 then
		return 1
	end
	if self.GiftModeProductCategory[Index] == nil then
		Index = self:GetGiftModeTabIndex(Index)
	end
	if nil == self.GiftModeProductCategory[Index] then
		return 1
	end
	for i = 1, ProductCategoryLength do
		if TempProductCategory[i].ID == self.GiftModeProductCategory[Index].ID then
			return i
		end
	end
	return 1
end

--- 获取赠礼模式对应Tab下标
---@param Index number 购买模式下选择下标
---@return Index number 赠礼对应下标
function StoreMgr:GetGiftModeTabIndex(Index)
	local TempProductCategory = self:GetProductCategoryList()
	if TempProductCategory == nil or TempProductCategory[Index] == nil then
		return 1
	end
	for i = 1, #self.GiftModeProductCategory do
		if self.GiftModeProductCategory[i].ID == TempProductCategory[Index].ID then
			return i
		end
	end
	return 1
end

--- 根据下标对比商店类型
---@param number Index 商店下标
---@param MallType ProtoRes.StoreMall 商店类型
function StoreMgr:CheckMallTypeByIndex(Index, MallType)
	if nil == Index then
		return false
	end

	local TempProductCategory = self:GetProductCategoryList()
	if TempProductCategory == nil then
		return false
	end

	local Category = nil
	if _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		Category =  TempProductCategory[Index]
	else
		Category =  self.GiftModeProductCategory[Index]
	end
	if Category == nil then
		return TempProductCategory[Index].Type == MallType
	end
	return Category.Type == MallType
end

function StoreMgr:GetIsShowEquipList(Good)
	local Items = Good.Items
	local Result = 0

	for _, Item in ipairs(Items) do
		if Item.ID ~= 0 then
			Result = Result + 1
		end
	end

	return Result >= 1
end

function StoreMgr:GetProductDataByFilter(ProductList, Filter)
	local ProductResult = {}
	for _, Product in pairs(ProductList) do
		if Product.LabelSub == Filter then
			ProductResult[#ProductResult + 1] = Product
		end
	end

	return ProductResult
end

function StoreMgr:GetTimeLimit(Time)
	local CurrTime = TimeUtil.GetServerLogicTime()
	local TimeLimit = Time - CurrTime
	if TimeLimit < 0 then
		return nil
	end
	if TimeLimit // StoreDefine.TimeValue.Day >= 1 and TimeLimit // StoreDefine.TimeValue.Day >= 99 then
		return false, LSTR(StoreDefine.TimeSaleText)
	end

	return true, _G.LocalizationUtil.GetCountdownTimeForSimpleTime(TimeLimit, "s")
end

-- 商品是否在打折时间内
function StoreMgr:IsDuringSaleTime(GoodCfgData)
	if nil == GoodCfgData then
		return false
	end

	local CurrentTime = TimeUtil.GetServerLogicTime()
	local StartTime = self:GetTimeInfo(GoodCfgData.DiscountDurationStart)
	local EndTime = self:GetTimeInfo(GoodCfgData.DiscountDurationEnd)
	if StartTime > CurrentTime or (EndTime > 0 and EndTime < CurrentTime) then
		return false
	end

	return true
end

--endregion

--region Server Message

--- 盲盒购买记录
function StoreMgr:SendGetMysterBoxList(ID)
	if not ID then return end
	if table.is_nil_empty(self.MysterBoxBoughtCount) or not self.MysterBoxBoughtCount[ID] then
		local MsgID = CS_CMD.CS_CMD_BLINDBOX
		local SubMsgID = MysterBoxSubCmd.GETLIST
		local MsgBody = {}
		MsgBody.Cmd = SubMsgID
		MsgBody.GetListReq = {ID = ID}
		GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	end
end

---@type 购买请求
---@param ID number 商品ID
---@param Count number 购买数量
function StoreMgr:SendMsgBuyMysterBox(ID)
	local MsgID = CS_CMD.CS_CMD_BLINDBOX
	local SubMsgID = MysterBoxSubCmd.BUY
	local MsgBody = {}

	MsgBody.Cmd = SubMsgID
	MsgBody.BuyReq = {
		BlindBoxID = ID,
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	UIViewMgr:HideView(UIViewID.StoreNewBuyWinPanel)
end

---@type 购买请求
---@param ID number 商品ID
---@param Count number 购买数量
function StoreMgr:SendMsgBuyGood(ID, Count, CouponGID)
	local MsgID = CS_CMD.CS_CMD_MALL_AND_STORE
	local SubMsgID = SUB_MSG_ID.CS_MALL_AND_STORE_CMD_MALL_PURCHASE
	local MsgBody = {}

	MsgBody.Cmd = SubMsgID
	MsgBody.MallPurchase = {
		GoodID = ID,
		Num = Count,
		CouponGID = CouponGID or 0
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

	-- _G.GMMgr:ReqGM("zone goods shoppingbuy " .. ID .. " " .. Count)
end

---@type 购买回执
---@param MsgBody table 回执信息, MsgBody.ShoppingMallBuy = { GoodsID = 商品ID, Count = 购买数量, Counter = 购买次数 }
function StoreMgr:OnNetBuyGood(MsgBody)
	if MsgBody == nil then
		return
	end

	local Msg = MsgBody.MallPurchase
	local MallPurchaseGood = Msg.Good
	if MallPurchaseGood == nil then
		return
	end

	--- 展示恭喜获得界面
	local StoreMainVM = _G.StoreMainVM
	local Params = {}
	local TempTable = {}
	local TempCfg = StoreCfg:FindCfgByKey(Msg.Good.GoodID)
	if TempCfg == nil then
		return
	end
	local TempCfgItems = TempCfg.Items
	if TempCfgItems ~= nil then
		for i = 1, #TempCfgItems do
			local TempItemID = TempCfgItems[i].ID 
			if TempItemID ~= 0 then
				table.insert(TempTable,
				{
					ResID = TempItemID,
					Num = tonumber(StoreMainVM.MultiBuyPurchaseNumber) or 1
				})
			end
		end
		
		Params.ItemList = TempTable
		UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
	end
	--- 刷新优惠券数据
	self:UpdateCouponData()
	StoreMainVM:UpdateCouponData()
	-- GoodFilterDataList好像没有更新数据先注释掉
	--StoreMainVM:UpdateGoodList(StoreMainVM.GoodFilterDataList)
	-- 性能优化：从更新全量列表改为更新单个商品
	StoreMainVM:UpdateSingleGoods(MallPurchaseGood.GoodID)

	--- 通知其他界面购买完成+关闭购买界面，暂时留着参数
	EventMgr:SendEvent(EventID.StoreBuyGoodsDisplay, Msg)
	UIViewMgr:HideView(UIViewID.StoreNewBuyWinPanel)
	self:RecordActivityBuy(Msg)
end

function StoreMgr:OnNetMysterBoxGetList(MsgBody)
	if MsgBody == nil then
		return
	end
	
	local Msg = MsgBody.GetListRsp
	if Msg == nil then
		return
	end
	local BlindBoxID = Msg.BlindBoxID
	local DrawCount = Msg.DrawCount
	self:SetMysterBoxBoughtCount(BlindBoxID, DrawCount)
end

function StoreMgr:SetMysterBoxBoughtCount(BlindBoxID, DrawCount)
	if self.MysterBoxBoughtCount == nil then
		self.MysterBoxBoughtCount = {}
	end
	if self.MysterBoxBoughtCount[BlindBoxID] == nil then
		self.MysterBoxBoughtCount[BlindBoxID] = 0
	end
	self.MysterBoxBoughtCount[BlindBoxID] = DrawCount
	EventMgr:SendEvent(EventID.StoreUpdateBlindText, {BlindBoxID = BlindBoxID, DrawCount = DrawCount})
end

function StoreMgr:GetMysterBoxBoughtCountByID(BlindBoxID)
	if self.MysterBoxBoughtCount == nil then
		self.MysterBoxBoughtCount = {}
	end
	return self.MysterBoxBoughtCount[BlindBoxID] or 0
end

function StoreMgr:OnNetBuyMysterBox(MsgBody)
	if MsgBody == nil then
		return
	end

	local Msg = MsgBody.BuyRsp
	if Msg == nil then
		return
	end
	local BlindBoxID = Msg.BlindBoxID
	local DrawCount = Msg.DrawCount
	local TempMysteryboxData = MysteryboxCfg:FindCfgByKey(BlindBoxID)
	if TempMysteryboxData == nil then
		return
	end
	local TempLootCfg = CommercializationRandCfg:FindAllCfg(string.format("DropID=%d", TempMysteryboxData.PrizePoolID))
	if TempLootCfg == nil then
		return
	end

	local ItemIDList = Msg.BuyItem
	local TempTable = {}
	for i = 1, #ItemIDList do
		local TempItemID = ItemIDList[i].ItemID 
		local TempLootCfg = CommercializationRandCfg:FindAllCfg(string.format("DropID=%d", TempItemID))
		if TempLootCfg ~= nil then
			local ItemNum = ItemIDList[i].ItemNum
			local IsMustBeGet = TempLootCfg.ProbMode == ProtoRes.PROBABILITY_TYPE.PROBABILITY_TYPE_GUARANTEED
			if TempItemID ~= 0 and not ItemUtil.ItemIsScore(TempItemID)  then
				table.insert(TempTable,
				{
					ResID = TempItemID,
					Num = ItemNum,
					IsMustBeGet = IsMustBeGet
				})
			end
		end
	end
	table.sort(TempTable, function(a,b) return a.IsMustBeGet and (not b.IsMustBeGet) end)
	local Params = {}
	local RaceID = MajorUtil.GetMajorRaceID()
	local RoleID = MajorUtil.GetMajorRoleID()
	local RoleVM, IsValid = _G.RoleInfoMgr:FindRoleVM(RoleID, true)
	self.MysterBoxRewardList:UpdateByValues(TempTable)
	for _, value in ipairs(self.MysterBoxRewardList.Items) do
		local TempCfg = HairUnlockCfg:FindCfgByItemID(value.ResID)
			if TempCfg ~= nil then
			local TempHairCfg = HairCfg:FindAllCfg(string.format("RaceID=%d AND Tribe=%d AND Gender=%d AND HaircutType=%d", RaceID, RoleVM.Tribe, RoleVM.Gender, TempCfg.HairID))
			if TempHairCfg ~= nil and TempHairCfg[1] ~= nil then
				value.Icon = TempHairCfg[1].IconPath
			end
		end
	end
	Params.ItemVMList = self.MysterBoxRewardList
	Params.BtnLeftText = LSTR(950033)	--- 确认
    Params.BtnRightText = LSTR(950087) --- 再买一个
	Params.IsByMasterBoxReset = true	--- 从盲盒打开的恭喜获得，关闭时需要重置下背景点击事件
    Params.BtnLeftCB = function() UIViewMgr:HideView(UIViewID.CommonRewardPanel) end
	Params.BtnRightCB = function() UIViewMgr:HideView(UIViewID.CommonRewardPanel) _G.StoreBuyWinVM:UpdateByMysteryBoxData(_G.StoreMainVM.SkipTempData) UIViewMgr:ShowView(UIViewID.StoreNewBuyWinPanel) end
 	local TempCommRewardView = UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
	TempCommRewardView.CommonPopUpBG:SetHideOnClick(false)
	UIUtil.SetIsVisible(TempCommRewardView.TextHint, false)
	UIUtil.SetIsVisible(TempCommRewardView.TextCloseTips, false)
	local GoodsCfg = self:GetMysterBoxDataByID(BlindBoxID)
	self:RegisterTimer(function()
		--- 0.9秒后  找到发型Item播放翻转动画
		for index, value in ipairs(self.MysterBoxRewardList.Items) do
			if value.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_COIFFURE then
				EventMgr:SendEvent(EventID.StoreMysteryAnimEvent, index)
				break
			end
		end
	end, 0.9, 0, 1)
	self:RegisterTimer(function(_, TempGoodsCfg)
		local CanContinuePurchase = self:CheckGoodsIsOwned(TempGoodsCfg)
		UIUtil.SetIsVisible(TempCommRewardView.TextHint, CanContinuePurchase)
		UIUtil.SetIsVisible(TempCommRewardView.TextCloseTips, CanContinuePurchase)
		UIUtil.SetIsVisible(TempCommRewardView.PanelBtn, not CanContinuePurchase)
		UIUtil.SetIsVisible(TempCommRewardView.BtnLeft, not CanContinuePurchase)
		UIUtil.SetIsVisible(TempCommRewardView.BtnRight, not CanContinuePurchase)
		UIUtil.SetIsVisible(TempCommRewardView.BtnRight, not CanContinuePurchase)
		TempCommRewardView.CommonPopUpBG:SetHideOnClick(CanContinuePurchase)
		TempCommRewardView = nil
	end, 1.4, 0, 1, GoodsCfg)
	--- 刷新界面
	UIViewMgr:HideView(UIViewID.StoreNewBuyWinPanel)
	self:UpdateCouponData()
	_G.StoreMainVM:UpdateCouponData()
	_G.StoreMainVM:UpdateGoodList(_G.StoreMainVM.GoodFilterDataList)
	self:SetMysterBoxBoughtCount(BlindBoxID, DrawCount)
end

function StoreMgr:SendMsgQueryInfo(MallID)
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MALL, true) then
		return
	end
	local MsgID = CS_CMD.CS_CMD_MALL_AND_STORE
	local SubMsgID = SUB_MSG_ID.CS_MALL_AND_STORE_CMD_MALL_QUERY
	local MsgBody = {}

	MsgBody.Cmd = SubMsgID
	MsgBody.MallQuery = {
		MallID = MallID,
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 查询商品信息
---@param MsgBody table 回执信息, MsgBody.MallQuery = { MallID = 商店TypeID, Goods = table商品列表 }
function StoreMgr:OnNetQueryInfo(MsgBody)
	if MsgBody == nil then
		return
	end

	local Msg = MsgBody.MallQuery
	-- local GoodList = Msg.Goods
	self.UnlockedDecorativeStyle = Msg.UnlockedDecorativeStyle
	-- for i = 1, #self.DefaultUnlockedStyleList do
	-- 	table.insert(self.UnlockedDecorativeStyle, i, self.DefaultUnlockedStyleList[i])
	-- end
	-- local Data
	-- local GoodID
	-- for _, Good in ipairs(GoodList) do
	-- 	GoodID = Good.GoodID
	-- 	Data = self:GetProductDataByID(GoodID)
	-- 	if Data and Data.Cfg.ID == GoodID then
			-- if Good.CounterFirst ~= nil then
			-- 	local CounterFirstID = Good.CounterFirst.CounterID
			-- 	if CounterFirstID ~= 0 then
			-- 		local FirstCounterCfg = CounterCfg:FindCfgByKey(CounterFirstID)
			-- 		if FirstCounterCfg ~= nil then
			-- 			Data.RestrictionType = FirstCounterCfg.CounterType
			-- 		end
			-- 		local CurrentRestoreFrist = CounterMgr:GetCounterRestore(CounterFirstID)
			-- 		local CurrentFristSumLimit = CounterMgr:GetCounterLimit(CounterFirstID)
			-- 		Data.RestrictionCount = CurrentRestoreFrist
			-- 		Data.CurrentFristSumLimit = CurrentFristSumLimit
			-- 		local CounterFirstNum = Good.CounterFirst.CounterNum
			-- 		Data.CounterFirstID = CounterFirstID
			-- 		Data.CounteFirstNum = CounterFirstNum
			-- 		Data.CounterFristResidue = CurrentRestoreFrist
			-- 		Data.Counter = CounterFirstNum
			-- 		Data.Residue = CurrentRestoreFrist
			-- 		if Good.CounterSecond ~= nil then
			-- 			local CounterSecondID = Good.CounterSecond.CounterID
			-- 			local CounteSecondNum = Good.CounterSecond.CounterNum
			-- 			if CounterSecondID ~= 0 then
			-- 				local CurrentSecRestore = CounterMgr:GetCounterRestore(CounterSecondID)
			-- 				local CurrentSecSumLimit = CounterMgr:GetCounterLimit(CounterSecondID)
			-- 				Data.CurrentSecRestore = CurrentSecRestore
			-- 				Data.CurrentSecSumLimit = CurrentSecSumLimit
			-- 				Data.CounteSecondNum = CounteSecondNum
			-- 				Data.Residue = CurrentSecRestore
			-- 				Data.Counter = CounteSecondNum
			-- 			end
			-- 		end
			-- 	end
			-- end
			-- Data.AlreadyHave = Good.AlreadyHave
			-- self.ProductDataList[GoodID] = Data
		-- end
	-- end

end

--- 检查当前大区是否在生效范围内
function StoreMgr:CheckWorldID(DisabledWorldIds)
	if table.is_nil_empty(DisabledWorldIds) then
		return true
	end
	local WorldID = _G.LoginMgr.WorldID
	for _, value in ipairs(DisabledWorldIds) do
		if WorldID == value then
			return false
		end
	end
	return true
end

---@type 赠礼请求
---@param Params table 赠礼信息, {FriendID = 好友ID, GoodID = 商品ID, DecorativeStyle = 装饰风格, GiftMessage = 赠言, GiftNum = 赠礼数量}
function StoreMgr:SendNetGiftReq(Params)
	local MsgID = CS_CMD.CS_CMD_MALL_AND_STORE
	local SubMsgID = SUB_MSG_ID.CS_MALL_AND_STORE_CMD_MALL_GIFT
	local MsgBody = {}

	MsgBody.Cmd = SubMsgID
	MsgBody.Gift = Params

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 赠礼回执
function StoreMgr:OnNetNetGift(MsgBody)
	if MsgBody == nil then
		return
	end
	_G.CounterMgr:SendCounterReqList()
	EventMgr:SendEvent(EventID.StoreMailCloseEvent)
end
--endregion

--- 购买前置条件 种族->性别->职业->货币->背包空间
function StoreMgr:CheckPurchasePreconditions(GoodsCfgData)
	if self:CheckGenderAndRaceLimit(ItemCondType.RaceLimit, GoodsCfgData) then
		-- 提示种族不符合是否继续购买
		local GoodData = _G.StoreMainVM.SkipTempData
		local ItemIDList = GoodData.Items
		for i = 1, #ItemIDList do
			local TempItemCfg =  ItemCfg:FindCfgByKey(ItemIDList[i].ID)
			if TempItemCfg ~= nil and TempItemCfg.UseCond ~= 0 then
				local TempCondCfg = CondCfg:FindCfgByKey(TempItemCfg.UseCond)
				for _, Cond in ipairs(TempCondCfg.Cond) do
					local Race = Cond.Value[1]
					local TempRaceCfg = RaceCfg:FindCfgByKey(Race)
					if TempRaceCfg ~= nil then
						self:OnCheckCmmMsgBoxIsShow()
						local TempRichText = RichTextUtil.GetText(TempRaceCfg.RaceName, "#d1ba8e")
						_G.MsgBoxUtil.ShowMsgBoxTwoOp(
							self,
							LSTR(StoreDefine.BuyTipTittleText),
							string.format(LSTR(950070), TempRichText),	--- 部分装备只可%s角色穿戴，是否继续购买？
							self.CheckGender,
							nil,
							LSTR(950030),	--- 取消
							LSTR(950031)	--- 继续购买
						)
						break
					end
				end
			end
		end
	else
		self:CheckGender(GoodsCfgData)
	end
end

function StoreMgr:CheckGender(GoodsCfgData)
	if self:CheckGenderAndRaceLimit(ItemCondType.GenderLimit, GoodsCfgData) then
		-- 提示性别不符合是否继续购买  故性别取反
		local MajorGender = MajorUtil.GetMajorGender()
		local GenderDes = MajorGender == RoleGender.GENDER_MALE and LSTR(950071) or LSTR(950072)	--- 950071 == 女性	--- 950072 == 男性
		local TempRichText = RichTextUtil.GetText(GenderDes, "#d1ba8e")
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			LSTR(StoreDefine.BuyTipTittleText),
			string.format(LSTR(950070), TempRichText),	---  部分装备只可%s角色穿戴，是否继续购买？
			self.CheckProf,
			nil,
			LSTR(950030),	--- 取消
			LSTR(950031)	--- 继续购买
		)
	else
		self:CheckProf(GoodsCfgData)
	end
end

function StoreMgr:CheckProf(GoodsCfgData)
	local GoodData = GoodsCfgData or _G.StoreMainVM.SkipTempData
	if nil == GoodData then
		return
	end
	local ItemIDList = GoodData.Items
	local TempItemCfg =  ItemCfg:FindCfgByKey(ItemIDList[1].ID)
	if TempItemCfg == nil then
		return
	end
	
	if TempItemCfg.ClassLimit ~= ProtoCommon.class_type.CLASS_TYPE_NULL then
		local ProfID = MajorUtil.GetMajorProfID()
		if not _G.ProfMgr.CheckProfClass(ProfID, TempItemCfg.ClassLimit) then
			self:OnCheckCmmMsgBoxIsShow()
			local TempRichText = RichTextUtil.GetText(string.format("%s",
				ProtoEnumAlias.GetAlias(ProtoCommon.class_type, TempItemCfg.ClassLimit)), "#d1ba8e")
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(
				self,
				LSTR(StoreDefine.BuyTipTittleText),
				string.format(LSTR(950073), TempRichText),	---  部分装备只可%s角色穿戴，是否继续购买？
				self.OwnedEnoughCurrency,
				nil,
				LSTR(950030),	--- 取消
				LSTR(950031)	--- 继续购买
			)
		else
			self:OnMailConditionCheck(GoodData)
		end
	elseif next(TempItemCfg.ProfLimit) then
		local LimitProfID = TempItemCfg.ProfLimit[1]
		local MajorProfID = MajorUtil.GetMajorProfID()
		if MajorProfID ~= LimitProfID then
			-- 提示职业不符合是否继续购买
			local SpecialProfName = ""
			local ProfLimitDes = ""
			local LimitProfCfg = RoleInitCfg:FindCfgByKey(LimitProfID)
			if LimitProfCfg ~= nil then
				SpecialProfName = LimitProfCfg.ProfName
			end
			local TempRoleInitCfg = RoleInitCfg:FindAllCfg("AdvancedProf = " .. LimitProfID)
			if TempRoleInitCfg ~= nil and #TempRoleInitCfg ~= 0 then
				local BaseProfName = TempRoleInitCfg[1].ProfName
				ProfLimitDes = string.format("%s%s%s", BaseProfName, "/", SpecialProfName)
			else
				ProfLimitDes =  string.format("%s",SpecialProfName)
			end
			self:OnCheckCmmMsgBoxIsShow()
			local TempRichText = RichTextUtil.GetText(ProfLimitDes, "#d1ba8e")
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(
				self,
				LSTR(StoreDefine.BuyTipTittleText),
				string.format(LSTR(950073), TempRichText),	---  部分装备只可%s职业穿戴，是否继续购买？
				self.OwnedEnoughCurrency,
				function()
					self.IsEarlyBreak = true
				end,
				LSTR(950030),	--- 取消
				LSTR(950031)	--- 继续购买
			)
		else
			self:OnMailConditionCheck(GoodData)
		end
	else
		self:OnMailConditionCheck(GoodData)
	end
end

--- 判断性别与种族
---@param LimitType CondFailReason  限制类型 性别/种族
---@param GoodsCfgData table @StoreCfg数据
---@return boolean  限制类型 性别/种族
function StoreMgr:CheckGenderAndRaceLimit(LimitType, GoodsCfgData)
	local GoodData = GoodsCfgData or _G.StoreMainVM.SkipTempData
	local ItemIDList = GoodData.Items
	if ItemIDList == nil then
		return
	end
	for i = 1, #ItemIDList do
		if ItemIDList[i] ~= 0 then
			local TempItemCfg =  ItemCfg:FindCfgByKey(ItemIDList[i].ID)
			if TempItemCfg ~= nil then
				if TempItemCfg.UseCond ~= 0 then
					local ConditionID = TempItemCfg.UseCond
					local CondFlag, ConditionFailReasonList = ConditionMgr:CheckConditionByID(ConditionID)
					if not CondFlag then
						return ConditionFailReasonList[LimitType]
					end
				end
			end
		end
	end
end

--- 发协议购买前最后判断一次邮件里是否含有对应物品
function StoreMgr:OnMailConditionCheck(GoodsCfgData)
	if nil == GoodsCfgData then
		return
	end
	local ItemIDList = GoodsCfgData.Items
	if ItemIDList == nil then
		MsgTipsUtil.ShowTipsByID(StoreDefine.BuyError)
		return
	end
	local bIsInEmail = false
	local MailID
	for _, value in ipairs(ItemIDList) do
		local TempMailID =  _G.MailMgr:GetGiftMailIDByGoodID(value.ID)
		if TempMailID ~= nil then
			bIsInEmail = true
			MailID = TempMailID
			break
		end
	end
	--- 邮件里有，弹出提示
	if bIsInEmail then
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			LSTR(950074),	--- "提示"
			LSTR(950075),	--- "可以从赠礼邮件中领取该商品\n(如果自己购买，重复的商品只能回收少量金币)"
			function(MailID)
				if MailID then
					_G.MailMgr:OpenGiftMailviewByMailID(MailID)
				end
			end,
			self:OwnedEnoughCurrency(GoodsCfgData),
			LSTR(950076),	--- "前往赠礼邮件"
			LSTR(950077)	--- "自己购买"
		)
	else
		self:OwnedEnoughCurrency(GoodsCfgData)
	end
end

---@type 是否持有足够的货币单件购买
function StoreMgr:OwnedEnoughCurrency(GoodsCfgData)
	local GoodData = GoodsCfgData or _G.StoreMainVM.SkipTempData
	if GoodData == nil then
		MsgTipsUtil.ShowTipsByID(StoreDefine.BuyError)
		return
	end
	local PriceData = GoodData.Price[StoreDefine.PriceDefaultIndex]
	if PriceData and PriceData.Count then
		local ScoreValue = ScoreMgr:GetScoreValueByID(PriceData.ID)
		local Price = PriceData.Count
		local BuyPriceVM = self:GetBuyPriceVM()
		if nil ~= BuyPriceVM then
			Price = BuyPriceVM.BuyPrice
		end
		if ScoreValue < Price then
			local TempScoreCfg = ScoreCfg:FindCfgByKey(PriceData.ID)
			if TempScoreCfg == nil then
				return
			end
			local ScroeName = TempScoreCfg.NameText
			self:OnCheckCmmMsgBoxIsShow()
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(
				self,
				LSTR(950032),	--- "代币不足"
				string.format(LSTR(950034), ScroeName),	--- "%s不足，是否前往充值？"
				function()
					if _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_REBATE, true) then
						-- 打开充值界面
						RechargingMgr:ShowMainPanel()
						RechargingMgr:OnChangedMainPanelCloseBtnToBack(true)
					end
				end,
				nil,
				LSTR(950030),	--- "取消"
				LSTR(950033)	--- "确认"
			)
		else
			self:OnConfirmBuy(GoodsCfgData)
		end
	else
		MsgTipsUtil.ShowTipsByID(StoreDefine.BuyError)
	end
end

--- 确认购买
function StoreMgr:OnConfirmBuy(GoodsCfgData)
	UIViewMgr:HideView(UIViewID.StoreBuyGoodsWin)
	_G.StoreMainVM:BuyGood(GoodsCfgData)
end

function StoreMgr:OnCheckCmmMsgBoxIsShow()
	if UIViewMgr:IsViewVisible(UIViewID.CommonMsgBox) then
		UIViewMgr:HideView(UIViewID.CommonMsgBox, true)
	end
end

function StoreMgr.CheckItemOwned(ItemID)
    local bIsInBag = _G.BagMgr:GetItemNum(ItemID) > 0 or _G.DepotVM:GetDepotItemNum(ItemID) > 0
		or _G.MailMgr:GetGiftMailIDByGoodID(ItemID) ~= nil
	local bIsActivated = ItemUtil.IsActivated(ItemID)
	return bIsInBag or bIsActivated
end

--- 检查奇遇盲盒是否已拥有
function StoreMgr:CheckGoodsIsOwned(GoodsCfg)

	--- 遍历Item 发型检查HaircutMgr.CheckHairUnlock(HairLockID)/其他物品暂定检查背包仓库
	--- 奇遇盲盒已拥有检查
	local Items = GoodsCfg.Items
	if Items ~= nil then
		for _, value in ipairs(Items) do
			local ItemResID = value.ID
			if ItemResID ~= 0 then
				local IsHadItem = true
				if GoodsCfg.GoodType == ProtoRes.SpecialMysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE then
					IsHadItem = self.CheckItemOwned(ItemResID) or _G.HaircutMgr.CheckHairUnlock(ItemResID)
				else
					IsHadItem = self.CheckItemOwned(ItemResID)
				end
				--- 有一个Item未拥有，即视为当前商品未拥有
				if not IsHadItem then
					return false
				end

			end
		end

		--- 这里代表检查了所有Item，但无一个未拥有
		return true
	end
	return true
end

--- 商品是否可购买
---@param GoodsId number@商品id
---@param BoughtCount number@购买数量
---@return boolean @是否可购买
---@return string @不可购买原因
---已售罄算在不可购买里
function StoreMgr:IsCanBuy(GoodsId, BoughtCount)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsId)
	if nil == GoodsCfgData then
		return false
	end
	if BoughtCount == nil then
		BoughtCount = 0
	end

	local bIsProp = self:GetIsPropsByID(GoodsId)
	if bIsProp then
		-- 道具类 限购检查
		local RemainQuantity = self:GetRemainQuantity(GoodsId)
		local IsSoldOut = RemainQuantity >= 0 and BoughtCount >= RemainQuantity
		if IsSoldOut then
			local CanNotReason = LSTR(StoreDefine.SecondScreenType.SoldOut)
			local Category = StoreMgr:GetProductCategory(_G.StoreMainVM.TabSelecteIndex)
			if Category ~= nil and Category.DisplayLabel ~= nil then
				CanNotReason = Category.DisplayLabel
			end
			return false, CanNotReason
		end
	end
	if not bIsProp or GoodsCfgData.CheckAlreadyHave == 1 then
		-- 已拥有检查
		local Items = GoodsCfgData.Items
		if GoodsCfgData.LabelMain == ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_RECOMMEND and GoodsCfgData.JumpID == 0 then
			-- 推荐页直购商品仅配置一个, 待拆推荐表
			if nil ~= Items and nil ~= Items[1] then
				local InnerGoodsCfgData = StoreCfg:FindCfgByKey(Items[1].ID)
				Items = InnerGoodsCfgData and InnerGoodsCfgData.Items or Items
			end
		end
		if nil ~= Items then
			for _, Item in ipairs(Items) do
				local ItemResID = Item.ID
				if ItemResID ~= 0 then
					local bItemOwned = self.CheckItemOwned(ItemResID)
					--- 有一个Item未拥有，即视为当前套装可购买
					if not bItemOwned then
						return true
					end
				end
			end
			local CanNotReason = LSTR(StoreDefine.SecondScreenType.Owned)
			return false, CanNotReason
		end
	end

	---配表条件检查
	local PurchaseConditions = GoodsCfgData.PurchaseConditions
	if next(PurchaseConditions) == nil then
		return true
	end
	for i = 1, #PurchaseConditions do
		local Cond = PurchaseConditions[i]
		if Cond then
			local ProfID = MajorUtil.GetMajorProfID()
			local CurrentProfInfo = {}
			local RoleDetail = ActorMgr:GetMajorRoleDetail()
			local ProfList = RoleDetail.Prof.ProfList
			for _, value in pairs(ProfList) do
				if value.ProfID == ProfID then
					CurrentProfInfo = value
					break
				end
			end
			local CondType = Cond.CondType
			local CondValues = Cond.Values
			if type(CondType) == "number" and CondValues ~= nil and next(CondValues) ~= nil then
				if CondType == 1 then  --使用等级
					local ProfLevel = CurrentProfInfo.Level
					if ProfLevel < CondValues[1] then
						local DescContent = Cond.Desc
						--FLOG_ERROR("no buy 5 = %s",DescContent)
						return false, DescContent
					end
				elseif CondType == 2 then  --职业类型限制
					local MajorClass = RoleInitCfg:FindProfClass(ProfID)
					if CondValues[1] ~= ProtoCommon.class_type.CLASS_TYPE_NULL and CondValues[1] ~= MajorClass then
						local DescContent = Cond.Desc
						--FLOG_ERROR("no buy 6= %s",DescContent)
						return false, DescContent
					end
				elseif CondType == 3 then  --职业限制
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
							local DescContent = Cond.Desc
							--FLOG_ERROR("no buy 7= %s",DescContent)
							return false, DescContent
						end
					end
				elseif CondType == 4 then  --性别限制
					local MajorGender = MajorUtil.GetMajorGender()
					local LimitGender = CondValues[1]
					if LimitGender ~= ProtoCommon.role_gender.GENDER_UNKNOWN and LimitGender ~= MajorGender then
						local DescContent = Cond.Desc
						--FLOG_ERROR("no buy 8= %s",DescContent)
						return false, DescContent
					end
				elseif CondType == 5 then  --种族限制
					local MajorRace = MajorUtil.GetMajorRaceID()
					local RaceTypeLimit = CondValues[1]
					if RaceTypeLimit ~= ProtoCommon.race_type.RACE_TYPE_NULL and MajorRace ~= RaceTypeLimit then
						local DescContent = Cond.Desc
						--FLOG_ERROR("no buy 9= %s",DescContent)
						return false, DescContent
					end
				elseif CondType == 6 then  --战斗职业最高等级
					local IsCan = false
					local DescContent = Cond.Desc
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
					return IsCan, DescContent
				elseif CondType == 7 then  --生产职业最高等级
					local IsCan = false
					local DescContent = Cond.Desc
					for _, v in pairs(ProfList) do
						local Specialization = RoleInitCfg:FindProfSpecialization(v.ProfID)
						if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
							local CurLv = v.Level
							local NeedLv = CondValues[1]

							if CurLv >= NeedLv then
								IsCan = true
								break
							end
						end
					end
					return IsCan, DescContent
				end
			end
		end
	end
	return true
end

--- 获取途径跳转具体物品
---@param ItemID number 物品ResID 会定位到第一个包含此物品ID的商品
---@param GoodsID number 商城-商品表里的ID 定位到此商品
---@param bIsOpenBuyWinPanel boolean 跳转之后是否直接打开购买弹窗,只有true打开
---@param bIsMysteryBox boolean 是否是盲盒
function StoreMgr:JumpToGoods(ItemID, GoodsID, bIsOpenBuyWinPanel, bIsMysteryBox)
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MALL, true) then
		return
	end
	FLOG_INFO(string.format("[StoreMgr:JumpToGoods] Jump to Item ID %d. Goods ID %d.", ItemID or 0, GoodsID or 0))
	local TempProductCategory = self:GetProductCategoryList()
	local ProductCategoryLength = self:GetProductCategoryLength()
	if bIsOpenBuyWinPanel then
		_G.StoreMainVM.bIsOpenBuyWinPanel = true
	else
		_G.StoreMainVM.bIsOpenBuyWinPanel = false
	end
	if nil == GoodsID then
		GoodsID = bIsMysteryBox and self:FindMysteryBoxIDByItemID(ItemID) or self:FindGoodsIDByItemID(ItemID)
	end
	local bGoodsIsAvailable = bIsMysteryBox and self:IsCanShowMysteryBox(GoodsID) or self:IsCanShow(GoodsID)
	if not bGoodsIsAvailable then
		MsgTipsUtil.ShowTipsByID(138005) -- 商品未上架
		return
	end
	local GoodsMallType = ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX
	if not bIsMysteryBox then
		local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
		if nil == GoodsCfgData then
			FLOG_WARNING("[StoreMgr:JumpToGoods] Cannot find goods of ID " .. tostring(GoodsID))
			return
		end
		GoodsMallType = self.LabelMainToMallType(GoodsCfgData.LabelMain)
	end

	for i = 1, ProductCategoryLength do
		if TempProductCategory[i].Type == GoodsMallType then
			_G.StoreMainVM.JumpToCategoryIndex = i
		end
	end
	_G.StoreMainVM.JumpToItemID = ItemID
	_G.StoreMainVM.JumpToGoodsID = GoodsID
	local StoreMainView = UIViewMgr:FindVisibleView(UIViewID.StoreNewMainPanel)
	if nil ~= StoreMainView then
		StoreMainView:JumpToGoods()
	else
		self:ShowMainPanel()
	end
end

function StoreMgr:FindGoodsIDByItemID(ItemID)
	local GoodsID = 0

	-- local SearchCondition = "Items LIKE '%\"ID\":" .. ItemID .. "%' ORDER BY ID" -- Lua侧查表不能使用LIKE
	local GoodsCfgRows = StoreCfg:FindAllCfg()
	for _, GoodsCfgRow in ipairs(GoodsCfgRows) do
		local bHasItem = false
		for Index = 1, #GoodsCfgRow.Items do
			if ItemID == GoodsCfgRow.Items[Index].ID then
				bHasItem = true
				break
			end
		end
		-- 忽略推荐页与商城不展示商品
		if bHasItem and GoodsCfgRow.LabelMain ~= ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_RECOMMEND
			and self:IsCanShow(GoodsCfgRow.ID) then
			GoodsID = GoodsCfgRow.ID
			break
		end
	end

	return GoodsID
end

function StoreMgr:FindMysteryBoxIDByItemID(ItemID)
	local MysterboxID = 0

	local CommercRandCfgRows = CommercializationRandCfg:FindAllCfg(string.format("DropID = %d AND PrizeType = %d",
		ItemID, ProtoRes.CommercialPrizeType.CommercialPrizeTypeMysteryBox))
	for _, CommercRandCfgRow in ipairs(CommercRandCfgRows) do
		local PrizePoolID = CommercRandCfgRow.PrizePoolID
		local MysteryBoxCfgRows = MysteryboxCfg:FindAllCfg(string.format("PrizePoolID = %d", PrizePoolID))
		for _, MysteryBoxCfgRow in ipairs(MysteryBoxCfgRows) do
			if StoreMgr:IsCanShowMysteryBox(MysteryBoxCfgRow.ID) then
				MysterboxID = MysteryBoxCfgRow.ID
				break
			end
		end
		if MysterboxID ~= 0 then
			break
		end
	end

	return MysterboxID
end

--- 跳转至商店类型 时装、坐骑等
---@param CategoryID number ProtoRes.Store_Label_Type
function StoreMgr:JumpToCategoryPage(CategoryID)
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MALL, true) then
		return
	end
	local TempProductCategory = self:GetProductCategoryList()
	local ProductCategoryLength = self:GetProductCategoryLength()
	for i = 1, ProductCategoryLength do
		if TempProductCategory[i].DisplayID == CategoryID then
			_G.StoreMainVM.JumpToCategoryIndex = i
		end
	end
	local StoreMainView = UIViewMgr:FindVisibleView(UIViewID.StoreNewMainPanel)
	if nil ~= StoreMainView then
		StoreMainView:JumpToGoods()
	else
		self:ShowMainPanel()
	end
end

function StoreMgr:CheckOnTimeLimit(ItemDate)
	local TempServerTime = TimeUtil:GetServerLogicTime()
	local OnTime = ItemDate.OnTime
	local OffTime = ItemDate.OffTime
	if OnTime == "" or OffTime == "" then
		return true
	end
	local pattern = "(%d+)-(%d+)-(%d+)_(%d+):(%d+):(%d+)"
	local TampOnTime = 0
	local TampOffTime = 0
	if OnTime ~= "" then
		local year, month, day, hour, min, sec = OnTime:match(pattern)
		local timestamp = os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec})
		TampOnTime =  timestamp
	end
	if OffTime ~= "" then
		local year, month, day, hour, min, sec = OffTime:match(pattern)
		local timestamp = os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec})
		TampOffTime =  timestamp
	end
	if TampOnTime < TempServerTime and TempServerTime < TampOffTime then
		return true
	end
	return false
end

--- 读表获取赠送限制
function StoreMgr:GetGiftAllLimit()
	-- 出赠方最高战斗职业等级
	self.DonorLevelLimit = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_MALL_GIFT_GIVER_COMBAT_PROF_LEVEL).Value[1]
	-- 受赠方最高战斗职业等级
	self.DoneeLevelLimit = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_MALL_GIFT_RECIPIENT_COMBAT_PROF_LEVEL).Value[1]
	-- 出赠方添加受赠方好友持续时间
	local FriendDuration = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_MALL_GIFT_GIVER_AND_RECIPIENT_BEING_FRIEND_TIME).Value[1]
	self.FriendDuration = math.ceil(FriendDuration / 3600 / 24)
	-- 赠送次数计数器ID
	self.GiftCounterID = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_MALL_GIFT_COUNTER_ID).Value[1]
	-- 剩余赠送次数提醒触发次数
	self.RemindTimeNumber = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_MALL_GIFT_TIGGER_NOTICE_TIME).Value[1]

end

--- 剩余赠送次数
function StoreMgr:GetResidueGiftNumber()
	local ResidueGiftNum = CounterMgr:GetCounterCurrValue(self.GiftCounterID)
	local GiftLimit = CounterMgr:GetCounterRestore(self.GiftCounterID)

	if ResidueGiftNum == nil then
		return 0
	else
		return GiftLimit - ResidueGiftNum
	end
end

--- 检查出赠方最高战斗职业等级
function StoreMgr:CheckDonorLevel()
	local RoleDetail = ActorMgr:GetMajorRoleDetail()
	if RoleDetail == nil then
		FLOG_ERROR('StoreMgr:CheckDonorLevel GetMajorRoleDetail Error ')
		return false
	end
	if RoleDetail.Prof == nil or RoleDetail.Prof.ProfList == nil then
		FLOG_ERROR('StoreMgr:CheckDonorLevel RoleDetail.Prof == nil or RoleDetail.Prof.ProfList == nil')
		return false
	end
	local ProfList = RoleDetail.Prof.ProfList
	for _, value in pairs(ProfList) do
		local ProfCfg = RoleInitCfg:FindCfgByKey(value.ProfID)
		if ProfCfg.Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT and value.Level >= self.DonorLevelLimit  then
			return true
		end
	end
	return false
end

--- 获取赠礼风格解锁数组
---@return UnlockedDecorativeStyle table 已解锁风格数组
function StoreMgr:GetUnlockedDecorativeStyleList()
	return self.UnlockedDecorativeStyle
end

function StoreMgr:GetIsPropsByID(GoodID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodID)
	if nil == GoodsCfgData then
		return false
	end
	for _, value in ipairs(self:GetProductCategoryList()) do
		if value.ID == GoodsCfgData.LabelMain then
			return value.Type == ProtoRes.StoreMall.STORE_MALL_PROPS
		end
	end
	return false
end

--region 游戏事件
function StoreMgr:OnGameEventRoleLoginRes()
	if UIViewMgr:IsViewVisible(UIViewID.StoreNewMainPanel) then
		--- 闪断时模拟重新选中逻辑
		local Index = _G.StoreMainVM.TabSelecteIndex or 1
		_G.StoreMainVM:ChangeTab(Index)
	end
	--- 活动要用数据，所以放在登录的时候请求一遍
	if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMall) then
		self:SendMsgQueryInfo(1)
	end

	self.MysterBoxBoughtCount = nil
end

function StoreMgr:OnGameEventMajorCreate()
	self:InitMsteryBoxData(true)
end

function StoreMgr:OnModuleOpenNotify(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDMall then
		self:InitMsteryBoxData(true)
	end
end

function StoreMgr:OnCounterUpdate(Params)
	local bIsStoreCounterUpdated = false
	for Key, _ in pairs(Params.UpdatedCounters) do
		if nil ~= self.LimitCounterMap[Key] then
			bIsStoreCounterUpdated = true
			break
		end
	end
	if bIsStoreCounterUpdated then
		_G.StoreMainVM:UpdateProductList()
	end
end

--endregion

function StoreMgr:ChangeModelPositon(PosX, PosY, PosZ, RotZ, Distance)
	local Params = {}
	Params.PosX = PosX
	Params.PosY = PosY
	Params.PosZ = PosZ
	Params.RotZ = RotZ
	Params.Distance = Distance
	EventMgr:SendEvent(EventID.StoreChangeModelEvent, Params)
end

--- 测试创建NPC
function StoreMgr:TestCreatNPC(PosX, PosY, PosZ, NPCID)
	local CreateClientActorParam = _G.UE.FCreateClientActorParams()
	local NpcLocation = _G.UE.FVector(PosX, PosY, PosZ)
	local NpcRotation = _G.UE.FRotator(0, 0, 0)
	CreateClientActorParam.bUIActor = false
	local CreatedNPCEntityID = _G.UE.UActorManager:Get():CreateClientActorByParams(_G.UE.EActorType.Npc, 
	0, NPCID, NpcLocation, NpcRotation, CreateClientActorParam)
end

-- 待废弃
function StoreMgr:CreatNPCAndGetNPCModelEntityID(AttachType)
	local NpcID = StoreDefine.StoreNPCID[AttachType]
	local CreateClientActorParam = _G.UE.FCreateClientActorParams()
	local NpcLocation = _G.UE.FVector(-100000, 0, 100000)
	local NpcRotation = _G.UE.FRotator(0, 0, 0)
	CreateClientActorParam.bUIActor = true
	local CreatedNPCEntityID = _G.UE.UActorManager:Get():CreateClientActorByParams(_G.UE.EActorType.Npc, 
	0, NpcID, NpcLocation, NpcRotation, CreateClientActorParam)
	if CreatedNPCEntityID ~= nil then
		return CreatedNPCEntityID
	end
end

---@param ID int 商品表里的ID
---@param IsCalculateDisCount boolean 是否计算折扣  为true时 计算当前价格  折扣生效就是折扣价，为false时直接返回原价
---@return Price int 价格
function StoreMgr:GetGoodsPriceByID(ID, IsCalculateDisCount)
	local Price = 0
	local TempGoodData = self:GetProductDataByID(ID)
	if TempGoodData == nil or TempGoodData.Cfg == nil then
		return Price
	end
	local TempGoodCfg = TempGoodData.Cfg
	local Discount = TempGoodCfg.Discount
	local CfgPrice = TempGoodCfg.Price
	if Discount ~= StoreDefine.DiscountMaxValue and Discount ~= StoreDefine.DiscountMinValue and IsCalculateDisCount then
		--- 折后价
		Price = TempGoodCfg.DisCountedPrice
	else
		Price = CfgPrice[StoreDefine.PriceDefaultIndex].Count
	end

	return Price
end

--- 商城记录活动购买
function StoreMgr:RecordActivityBuy(Data)
	if not Data then return end
	if not self.ActivityBuyGoodsData then return end 
		
	local GoodID = Data.Good and Data.Good.GoodID or 0
	local NeedRecord = false
	local ActivityID
	for k, v in pairs(self.ActivityBuyGoodsData) do
		if v == GoodID then
			NeedRecord = true
			ActivityID = k
			break
		end
	end

	if NeedRecord then
		local RedDotStr = _G.UE.USaveMgr.GetString(SaveKey.OpsActivitySroreBuyRemind, "", true)
		local SaveStr = string.format("%s,%s,%s",RedDotStr, ActivityID, GoodID)
		_G.UE.USaveMgr.SetString(SaveKey.OpsActivitySroreBuyRemind, SaveStr, true)
	end
end

--- 活动购买标志
function StoreMgr:SetOneActivityBuyRecord(GoodID, ActivityID)
	if not GoodID then return end
		
	if not self.ActivityBuyGoodsData then
		self.ActivityBuyGoodsData = {}
	end

	if not self.ActivityBuyGoodsData[ActivityID] then
		self.ActivityBuyGoodsData[ActivityID] = GoodID
	end
end

--- 删除活动购买标志
function StoreMgr:DelOneActivityStoreBuyRecord(ActivityID)
	local RecordData = self:GetActivityStoreBuyRecord()
	local NewRecordData = {}
	for i, v in pairs(RecordData) do
		local ActivityInfo = _G.OpsActivityMgr:GetActivtyNodeInfo(i)
		if not (i == ActivityID or not ActivityInfo) then
			NewRecordData[i] = v
		end
	end

	local RedDotStr
	for Key, Value in pairs(NewRecordData) do
		if string.isnilorempty(RedDotStr) then
			RedDotStr = string.format("%d,%d", Key, Value)
		else
			RedDotStr = string.format("%s,%d,%d", RedDotStr, Key, Value)
		end
    end

    _G.UE.USaveMgr.SetString(SaveKey.OpsActivitySroreBuyRemind, RedDotStr, true)
end

function StoreMgr:GetActivityStoreBuyRecord()
	local RecordBuyData = {}
	local RedDotStr = _G.UE.USaveMgr.GetString(SaveKey.OpsActivitySroreBuyRemind, "", true)
    local SplitStr = string.split(RedDotStr,",")
	for i = 1, #SplitStr, 2 do
		local ActivityInfo = _G.OpsActivityMgr:GetActivtyNodeInfo(tonumber(SplitStr[i]))
		if ActivityInfo then
			RecordBuyData[tonumber(SplitStr[i])] = tonumber(SplitStr[i + 1])
		end
	end

	return RecordBuyData
end

--- 外部接口，获取价格区间的商品
---@param LabelMain enum		类型ProtoRes.Store_Label_Type 需要传入 0 == 所有类型, 1 == 时装,2 == 武器,3 == 坐骑,4 == 道具
---@param MinPrice number		最小值
---@param MaxPrice number		最大值
---@return table	TempGoodsList.Cfg该价格区间所有商品配置,TempGoodsList.ItemPossession已拥有状态,为true 时代表已经拥有
function StoreMgr:OnGetStoreGoodsByPriceLimit(LabelMain, MinPrice, MaxPrice)
	local TempMinPrice = MinPrice or 0
	local TempMaxPrice = MaxPrice or 0
	local LabelMainCond = LabelMain or 0
	local TempCfg = {}
	local SearchConditions = ""
	if LabelMain ~= 0 then
		SearchConditions = string.format("LabelMain == %d", LabelMainCond)
	end
	local AllCfg = StoreCfg:FindAllCfg(SearchConditions)
	if table.is_nil_empty(AllCfg) then
		return nil
	end
	for _, value in ipairs(AllCfg) do
		local Price = self:GetGoodsPriceByID(value.ID, false)
		if MinPrice <= Price and MaxPrice >= Price then
			table.insert(TempCfg, value)
		end
	end
	table.sort(TempCfg, function(A, B)
		local IsCanA, CanNotReasonA = StoreMgr:IsCanBuy(A.ID)
		local IsCanB, CanNotReasonB = StoreMgr:IsCanBuy(B.ID)
	
		if CanNotReasonA == _G.LSTR(StoreDefine.SecondScreenType.Owned) then
			if CanNotReasonB == _G.LSTR(StoreDefine.SecondScreenType.Owned) then
				return self:GetGoodsPriceByID(A.ID, false) > self:GetGoodsPriceByID(B.ID, false)
			end
			return false
		end

		if CanNotReasonB == _G.LSTR(StoreDefine.SecondScreenType.Owned) then
			return true
		end

		return self:GetGoodsPriceByID(A.ID, false) > self:GetGoodsPriceByID(B.ID, false)

	end)
	local TempGoodsList = {}
	for _, value in ipairs(TempCfg) do
		local ItemData = {}
		ItemData.Cfg = value
		table.insert(TempGoodsList, {GoodData = ItemData})
	end
	return TempGoodsList
end

function StoreMgr:ShowMainPanel()
	_G.StoreMainVM:InitData()
	UIViewMgr:ShowView(UIViewID.StoreNewMainPanel)
end

--- 0 == 抵扣券，抵扣具体数额的货币 -
--- 1 == 折扣券，抵扣百分之多少的货币 *
function StoreMgr:CheckCoupon(CurPrice, GoodID)
	if table.is_nil_empty(self.CouponList) then
		self:UpdateCouponData()
	end
	local IsHaveCoupon = false
	local CouponNum = CurPrice
	local CouponResID = 0
	if self.CouponList then
		for _, CouponData in ipairs(self.CouponList) do
			--- 每个优惠券优惠后的数额 --- 每个单独计算之后选择最优的优惠
			local TempCouponNum = 0
			if CouponData.Cfg.LowestActivePrice <= CurPrice and self:CheckCouponIsValid(CouponData, GoodID) then
				IsHaveCoupon = true
				TempCouponNum = self:GetPriceAfterCoupon(CurPrice, CouponData.Cfg)
				if TempCouponNum < CouponNum then
					CouponNum = TempCouponNum
					CouponResID = CouponData.Cfg.ID
				end
			end
		end
	end
	return IsHaveCoupon, CouponNum, CouponResID
end

function StoreMgr:GetPriceAfterCoupon(RawPrice, CouponCfgData)
	if nil == CouponCfgData then
		return RawPrice
	end
	local Result = RawPrice
	if CouponCfgData.CouponType == Store_CouponType.STORE_COUPON_TYPE_DISCOUNT then
		Result = RawPrice * CouponCfgData.DiscountValue
	elseif CouponCfgData.CouponType == Store_CouponType.STORE_COUPON_TYPE_REDUCTION then
		Result = math.max(0, RawPrice - CouponCfgData.DiscountNum)
	end
	return Result
end

--- 更新现有优惠券信息
function StoreMgr:UpdateCouponData()

	local CouponList = {}
	for _, CouponCfgData in ipairs(self.TempCouponCfg) do
		local ItemList = _G.BagMgr:FilterItemByCondition(function (Item) return Item.ResID == CouponCfgData.ID end)
		for _, Item in ipairs(ItemList) do
			local CouponData = {Cfg = CouponCfgData, GID = Item.GID, ExpireTime = Item.ExpireTime}
			table.insert(CouponList, CouponData)
		end
	end
	self.CouponList = CouponList
end

function StoreMgr:UpdateCouponValid()
	if nil == self.CouponList or #self.CouponList == 0 then
		self:UpdateCouponData()
	end
	for _, value in ipairs(self.CouponList) do
		value.IsValid = self:CheckCouponIsValid(value)
	end
	table.sort(self.CouponList, function(a,b) return a.IsValid and not b.IsValid end)
end

function StoreMgr:CheckCouponIsValid(CouponData, GoodsID)
	if nil == CouponData then
		return false
	end
	local Cfg = CouponData.Cfg
	local bIsOnTime = TimeUtil.GetServerLogicTime() < CouponData.ExpireTime
	--- 不在可用时间内
	if not bIsOnTime and CouponData.ExpireTime > 0 then
		return false
	end
	--- 检查优惠券对当前商品是否有效
	local GoodsCfgData = nil
	if nil == GoodsID then
		local CurrentSelectedItem = StoreMgr.ProductDataList[_G.StoreMainVM.CurrentselectedID]
		if nil == CurrentSelectedItem then
			return false
		end
		GoodsCfgData = CurrentSelectedItem.Cfg
		GoodsID = _G.StoreMainVM.CurrentselectedID
	else
		GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	end
	if nil == GoodsCfgData then
		return false
	end
	--- 检查商品价格是否可用(优惠券存在最低使用价格限制)
	if GoodsCfgData.Price[1].Count >= Cfg.LowestActivePrice then
		return self:CheckCouponIsEnableByGoodID(Cfg, GoodsID)
	else
		return false
	end
end

--- 物品ID是否在优惠券生效范围内
function StoreMgr:CheckCouponIsEnableByGoodID(CouponCfg, GoodID)
	if nil == self.ProductDataList or nil == self.ProductDataList[GoodID] then
		return false
	end
	local TempGoodCfg = self.ProductDataList[GoodID].Cfg
	if table.is_nil_empty(TempGoodCfg) then
		return false
	end
	if #CouponCfg.EnableGoodsList == 0 and #CouponCfg.EnableMallIDs == 0 and #CouponCfg.DisableGoodsList == 0 then
		return true
	end
	--- 有效商品列表
	if #CouponCfg.EnableGoodsList > 0 then
		for i = 1, #CouponCfg.EnableGoodsList do
			if GoodID == CouponCfg.EnableGoodsList[i] then
				return true
			end
		end

		return false
	else
		if #CouponCfg.DisableGoodsList > 0 then
			--- 无效商品列表
			for i = 1, #CouponCfg.DisableGoodsList do
				if GoodID == CouponCfg.DisableGoodsList[i] then
					return false
				end
			end
		end
		if #CouponCfg.EnableMallIDs > 0 then
			--- 有效商品类
			for i = 1, #CouponCfg.EnableMallIDs do
				if TempGoodCfg.LabelMain == CouponCfg.EnableMallIDs[i] then
					return true
				end
			end

			return false
		end
	end
	return true
end

--- 打开购买界面  旧蓝图 StoreBuyGoodsWin/StoreBuyPropsWin
---@param GoodsID number 商品表ID
function StoreMgr:OpenExternalPurchaseInterface(GoodsID, Param)
	if table.is_nil_empty(self.ProductDataList) then
		self:InitData()
	end
	local TempCfg =  StoreCfg:FindCfgByKey(GoodsID)
	if TempCfg == nil then
		FLOG_ERROR("StoreMgr  OpenExternalPurchaseInterface TempCfg is nil")
		return
	end
	Param.TempCfg = TempCfg

	if TempCfg.LabelMain == ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_PROP then
		_G.StoreMainVM:InitMultiBuyView(self.ProductDataList[GoodsID])
		UIViewMgr:ShowView(UIViewID.StoreBuyPropsWin, Param)
	else
		_G.StoreMainVM:InitBuyView(self.ProductDataList[GoodsID])
		UIViewMgr:ShowView(UIViewID.StoreBuyGoodsWin, Param)
	end
end

--- 打开商城新购买界面 非道具StoreNewBuyWinPanel/道具StoreBuyPropsWin
function StoreMgr:OpenExternalPurchaseInterfaceByNewUIBP(GoodsID)
	if table.is_nil_empty(self.ProductDataList) then
		self:InitData()
	end
	local TempCfg =  StoreCfg:FindCfgByKey(GoodsID)
	if TempCfg == nil then
		FLOG_ERROR("StoreMgr  OpenExternalPurchaseInterfaceByNewUIBP TempCfg is nil")
		return
	end
	_G.StoreMainVM:UpdateTabList()
	if TempCfg.LabelMain == ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_PROP then
		_G.StoreMainVM:InitMultiBuyView(self.ProductDataList[GoodsID])
		UIViewMgr:ShowView(UIViewID.StoreBuyPropsWin)
	else
		_G.StoreBuyWinVM:UpdateByGoodsID(GoodsID)
		local PriceVM = self:GetBuyPriceVM()
		if nil ~= PriceVM then
			PriceVM:UpdatePriceData(StoreCfg:FindCfgByKey(GoodsID))
		end
		local Params = Param or {}
		Params.IsShowGiftBtn = false
		UIViewMgr:ShowView(UIViewID.StoreNewBuyWinPanel, Params)
	end
end

function StoreMgr:GetProductCategoryList()
	if self.ProductCategory == nil then
		self:InitData()
	end
	return self.ProductCategory
end

function StoreMgr:GetProductCategoryLength()
	return #self.ProductCategory
end

function StoreMgr:InitProductDataByReq()
	local TempCategory = self:GetProductCategoryList()
	for _, value in ipairs(TempCategory) do
		self:SendMsgQueryInfo(value.DisplayID)
	end
	if UIViewMgr:IsViewVisible(UIViewID.StoreMainPanel) or UIViewMgr:IsViewVisible(UIViewID.StoreNewMainPanel) then
		EventMgr:SendEvent(EventID.StoreRefreshGoods)
	end
end

function StoreMgr:InitMsteryBoxData(IsCheckTimer)
	self.MysteryboxData = {}
	local TempMysteryboxData = MysteryboxCfg:FindAllCfg()
	
	local IsNeedHideRedDot = true
	--- 发型盲盒，不走商城表
	for _, Item in ipairs(TempMysteryboxData) do
		local TempItem = {}
		local TempItemCfg = {}
		for index, value in pairs(Item) do
			TempItemCfg[index] = value
		end
		TempItemCfg.Name = Item.Name
		TempItemCfg.LabelSub = LSTR(StoreDefine.LSTRTextKey.AllFilterText)	--- 全部
		local TempLootCfg = CommercializationRandConsumeCfg:FindAllCfg(string.format("PoolID=%d", Item.PrizePoolID))[1]
		TempItemCfg.Price = {[1] = {ID = TempLootCfg.ConsumeResID, Count = TempLootCfg.ConsumeResNum[1]}}
		TempItemCfg.DisCountedPrice = TempLootCfg.ConsumeResNumAfterDiscount
		TempItemCfg.DiscountDurationStart = string.gsub(TempLootCfg.DiscountStartTime, " ", "_")
		TempItemCfg.DiscountDurationEnd = string.gsub(TempLootCfg.DiscountEndTime, " ", "_")
		TempItemCfg.Discount = TempLootCfg.DiscountValue
		TempItemCfg.Desc = Item.Desc
		TempItemCfg.MysterID = Item.ID
		TempItemCfg.Note = Item.Note
		TempItemCfg.BuyNote = Item.BuyNote
		TempItemCfg.OnVersion = Item.OnVersion
		-- TempItemCfg.BuyIcon = Item.BuyIcon
		TempItemCfg.BuyIcon = BuyIconPath[Item.ID]
		TempItemCfg.Items = {}
		for i = 1, #Item.ItemID do
			local TempItemID = Item.ItemID[i]
			local TempHairCfg = HairUnlockCfg:FindCfgByID(TempItemID)
			if TempHairCfg ~= nil then
				table.insert(TempItemCfg.Items, {ID = TempHairCfg.UnlockItemID})
			end
		end
		TempItemCfg.DisplayID = TempItemCfg.Sort
		TempItemCfg.Icon = TempItemCfg.PictureAddr
		TempItemCfg.GoodType = Item.Type
		TempItemCfg.Type = ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX
		TempItem.Cfg = TempItemCfg
		local OnTime = string.gsub(TempItemCfg.ListingTime, " ", "_")
		local OffTime = string.gsub(TempItemCfg.RemovalTime, " ", "_")
		TempItem.Counter = 0
		TempItem.RestrictionType = 0
		TempItem.RestrictionCount = 0
		-- local OnTime = string.gsub(TempItemCfg.ListingTime, " ", "_")
		-- local OffTime = string.gsub(TempItemCfg.RemovalTime, " ", "_")
		-- local OnTime = "2025-04-02_02:20:00"
		-- local OffTime = "2025-08-20_20:21:00"
		-- TempItemCfg.DiscountDurationStart = "2025-03-20_16:49:00"
		-- TempItemCfg.DiscountDurationEnd = "2025-03-20_16:50:00"
		if IsCheckTimer then
			self:UnRegisterAllTimer()
			self:CheckRegsterOnTimeTimer(TempItemCfg.ID, OnTime)
			self:CheckRegsterOffTimeTimer(TempItemCfg.ID, OffTime)
			--- 检测折扣开始结束时间，注册事件   到时间刷新物品列表
			self:CheckRegsterOffTimeTimer(TempItemCfg.ID, TempItemCfg.DiscountDurationStart)
			self:CheckRegsterOffTimeTimer(TempItemCfg.ID, TempItemCfg.DiscountDurationEnd)
		end
		local IsEnable = StoreMgr:IsCanShowMysteryBox(Item.ID)
		if IsEnable then
			self.MysteryboxData[Item.ID] = TempItem
		end
		if StoreMgr:GetServerRedDotData(Item.ID) == 1 and IsNeedHideRedDot then
			IsNeedHideRedDot = false
		end
	end

	if IsNeedHideRedDot then
		_G.RedDotMgr:DelRedDotByID(19)
	end
end

---------------奇遇盲盒-------------
function StoreMgr:CheckTime(Time)
	local TempServerTime = TimeUtil:GetServerLogicTime()
	local TempTime = 0
	if Time ~= "" then
		local year, month, day, hour, min, sec = Time:match(TimePattern)
		local timestamp = os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec})
		TempTime =  timestamp
	end
	return TempTime > TempServerTime, TempTime - TempServerTime
end

--- 上架事件
function StoreMgr:CheckRegsterOnTimeTimer(ID, OnTime)
	if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMall) then
		return
	end
	--- 上架时间有可能在离线过程中，这里把所有没有取消过红点的物品都显示
	local TimeIsNeedTimer, DelayTime = self:CheckTime(OnTime)
	if DelayTime < 0 then DelayTime = 0 end
	if self:GetServerRedDotData(ID) ~= 0 then
		self.MysteryBoxDownTimerList[ID] = self:RegisterTimer(function()
			self:InitMsteryBoxData(false)
			_G.StoreMainVM:UpdateTabList()
			_G.EventMgr:SendEvent(_G.EventID.StoreUpdateTabListByTimer)
			self.RedDotPathList[ID] = _G.RedDotMgr:AddRedDotByParentRedDotID(19, ID, true)
			_G.EventMgr:SendEvent(_G.EventID.StoreMysteryBoxRedDotEvent, ID)
		end, DelayTime, 0, 1)
	end
end

--- 下架事件
function StoreMgr:CheckRegsterOffTimeTimer(ID, OffTime)
	if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMall) then
		return
	end
	local TimeIsNeedTimer, DelayTime = self:CheckTime(OffTime)
	if TimeIsNeedTimer then
		self.MysteryBoxUpTimerList[ID] = self:RegisterTimer(function() 
			-- self:UnRegisterAllTimer()
			self:InitMsteryBoxData(false)
			_G.StoreMainVM:UpdateTabList()
			_G.EventMgr:SendEvent(_G.EventID.StoreUpdateTabListByTimer)
			_G.EventMgr:SendEvent(_G.EventID.StoreRefreshGoods)
		end, DelayTime + 1.2, 0, 1)
	end
end

function StoreMgr:ChangeRedDotState(Index, IsShow)
	self.MasteryBoxServerUpValue[Index] = IsShow
	_G.ClientSetupMgr:SendSetReq(ClientSetupID.StoreMasterBoxReddot, _G.TableTools.table_to_string(self.MasteryBoxServerUpValue))
end

--- 获取保存在服务器的红点数据，返回0就视为点过红点 就不再显示了，其他值都需要显示
function StoreMgr:GetServerRedDotData(ID)
	if table.is_nil_empty(self.MasteryBoxServerUpValue) or self.MasteryBoxServerUpValue[ID] == nil then
		local TempServerRedDotData = _G.ClientSetupMgr:GetSetupValue(MajorUtil.GetMajorRoleID(), ClientSetupID.StoreMasterBoxReddot)
		self.MasteryBoxServerUpValue = {}
		if TempServerRedDotData ~= nil then
			self.MasteryBoxServerUpValue = FuncStringToTable(TempServerRedDotData)
		end
	end
	return self.MasteryBoxServerUpValue[ID] == 0 and 0 or 1
end

function StoreMgr:GetHairIconByHairID(HairID)
	local RaceID = MajorUtil.GetMajorRaceID()
	local RoleID = MajorUtil.GetMajorRoleID()
	local RoleVM, IsValid = _G.RoleInfoMgr:FindRoleVM(RoleID, true)
	local TempHairCfg = HairCfg:FindAllCfg(string.format("RaceID=%d AND Tribe=%d AND Gender=%d AND HaircutType=%d", RaceID, RoleVM.Tribe, RoleVM.Gender, HairID))
	if TempHairCfg == nil or TempHairCfg[1] == nil then
		FLOG_ERROR("StoreEquipPartVM  ItemType is hair, But TempHairCfg is nil")
		return ""
	end
	return TempHairCfg[1].IconPath
end

function StoreMgr:GetMysterBoxDataByID(BlindBoxID)
	for _, value in ipairs(self.MysteryboxData) do
		if value.Cfg.ID == BlindBoxID then
			return value.Cfg
		end
	end
end

---------------奇遇盲盒-------------

--region 售价

function StoreMgr:GetMainPriceVM()
	if nil == self.MainPriceVM then
		self.MainPriceVM = StorePriceVM.New()
	end
	return self.MainPriceVM
end

function StoreMgr:GetBuyPriceVM()
	if nil == self.BuyPriceVM then
		self.BuyPriceVM = StorePriceVM.New()
	end
	return self.BuyPriceVM
end

function StoreMgr:GetGiftPriceVM()
	if nil == self.GiftPriceVM then
		self.GiftPriceVM = StorePriceVM.New()
	end
	return self.GiftPriceVM
end

-- 计算商品售价信息
---@param GoodCfgData table @商品配置
---@param bUseDiscount boolean @是否计算折扣
---@param bUseCoupon boolean @是否使用优惠券
---@param InCouponID number @指定的优惠券ID，不指定则自动选择最佳优惠券
---@return number, number, number, boolean, number @原价，折扣价，优惠券价，是否使用了优惠券，优惠券ID
function StoreMgr:GetGoodPriceInfo(GoodCfgData, bUseDiscount, bUseCoupon, InCouponID)
	if nil == GoodCfgData or nil == GoodCfgData.Price[StoreDefine.PriceDefaultIndex] then
		return 0, 0, 0, false, 0
	end

	local RawPrice = GoodCfgData.Price[StoreDefine.PriceDefaultIndex].Count
	local PriceWithDiscount = RawPrice
	if bUseDiscount and GoodCfgData.Discount > 0 and self:IsDuringSaleTime(GoodCfgData) then
		PriceWithDiscount = GoodCfgData.DisCountedPrice
	end
	local PriceWithCoupon = PriceWithDiscount
	local bHasCoupon = false
	local CouponID = 0
	if bUseCoupon then
		if nil ~= InCouponID and InCouponID > 0 then
			CouponID = InCouponID
			bHasCoupon = true
			PriceWithCoupon = self:GetPriceAfterCoupon(PriceWithDiscount, StoreCouponCfg:FindCfgByKey(InCouponID))
		else
			bHasCoupon, PriceWithCoupon, CouponID = self:CheckCoupon(PriceWithDiscount, GoodCfgData.ID)
		end
	end
	return RawPrice, PriceWithDiscount, PriceWithCoupon, bHasCoupon, CouponID
end

function StoreMgr:GetCurrentCouponID()
	return _G.StoreMainVM.CurCouponResID
end

--endregion

--region 优惠券

function StoreMgr:ChooseBestCoupon(GoodsCfgData)
	GoodsCfgData = GoodsCfgData or _G.StoreMainVM:GetCurrentGoodCfgData()
	local _, _, _, _, CouponID = self:GetGoodPriceInfo(GoodsCfgData, true, true)
	_G.StoreMainVM:UpdateCouponChoose(0, CouponID, true)
end

--endregion

--region 限购

-- 获取剩余商品数量
---@param GoodsID number
---@return number @剩余商品数量，小于0为无穷大
function StoreMgr:GetRemainQuantity(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodsCfgData or GoodsCfgData.GoodsCounterFirst == 0 then
		return -1
	end
	local FirstRemainQuantity = CounterMgr:GetCounterRemainValue(GoodsCfgData.GoodsCounterFirst) or -1
	local SecondRemainQuantity = CounterMgr:GetCounterRemainValue(GoodsCfgData.GoodsCounterSecond) or FirstRemainQuantity
	return math.min(FirstRemainQuantity, SecondRemainQuantity)
end

-- 获取商品的限购计数器类型
---@param GoodsID number
---@param CounterIndex number @计数器索引，有1和2两种计数器
---@return ProtoRes.COUNTER_TYPE
function StoreMgr:GetCounterType(GoodsID, CounterIndex)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodsCfgData then
		return ProtoRes.COUNTER_TYPE.COUNTER_TYPE_NONE
	end
	CounterIndex = CounterIndex or 1
	local CounterID = CounterIndex == 1 and GoodsCfgData.GoodsCounterFirst or GoodsCfgData.GoodsCounterSecond
	local CounterCfgData = CounterCfg:FindCfgByKey(CounterID)
	if nil == CounterCfgData then
		return ProtoRes.COUNTER_TYPE.COUNTER_TYPE_NONE
	end
	return CounterCfgData.CounterType
end

-- 获取商品限购计数器的周期限额回复
function StoreMgr:GetCounterRestore(GoodsID, CounterIndex)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodsCfgData or GoodsCfgData.GoodsCounterFirst == 0 then
		return 0
	end
	CounterIndex = CounterIndex or 1
	local CounterID = CounterIndex == 1 and GoodsCfgData.GoodsCounterFirst or GoodsCfgData.GoodsCounterSecond
	return CounterMgr:GetCounterRestore(CounterID) or 0
end

--endregion

--region 工具函数

---@param Icon string|number
function StoreMgr.GetGoodIconPath(Icon)
	if nil == Icon then
		return ""
	end
	local IconNum = tonumber(Icon)
	Icon = IconNum or Icon
	if type(Icon) == "number" then
		return UIUtil.GetIconPath(Icon)
	else
		return Icon
	end
end

local LabelToMallTypeMap =
{
	[ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_FASHION] = ProtoRes.StoreMall.STORE_MALL_CLOTHING,
	[ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_WEAPON] = ProtoRes.StoreMall.STORE_MALL_WEAPON,
	[ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_MOUNT] = ProtoRes.StoreMall.STORE_MALL_MOUNT,
	[ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_PROP] = ProtoRes.StoreMall.STORE_MALL_PROPS,
	[ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_PET] = ProtoRes.StoreMall.STORE_MALL_PET,
	[ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_RECOMMEND] = ProtoRes.StoreMall.STORE_MALL_RECOMMEND,
}
---@param LabelMain ProtoRes.Store_Label_Type
---@return ProtoRes.StoreMall
function StoreMgr.LabelMainToMallType(LabelMain)
	if nil == LabelMain then
		return ProtoRes.StoreMall.STORE_MALL_INVALID
	end
	return LabelToMallTypeMap[LabelMain]
end

function StoreMgr:PreLoadCommRewardPannel()
	local function Callback()
		self.CommRewardPannel = _G.ObjectMgr:GetClass(self.CommRewardPannelResPath)
	end
	self.CommRewardPannel = _G.ObjectMgr:GetClass(self.CommRewardPannelResPath)
	if nil == self.CommRewardPannel then
		_G.ObjectMgr:LoadClassAsync(self.CommRewardPannelResPath, Callback)
	end
end

--endregion

return StoreMgr
