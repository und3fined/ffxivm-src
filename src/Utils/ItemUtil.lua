---
--- Author: anypkvcai
--- DateTime: 2021-09-06 19:28
--- Description:
---


local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local LootCfg = require("TableCfg/LootCfg")
local ItemGetaccesstypeCfg = require("TableCfg/ItemGetaccesstypeCfg")
local MajorUtil = require("Utils/MajorUtil")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipImproveCfg = require("TableCfg/EquipImproveCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local CommonUtil = require("Utils/CommonUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local FuncCfg = require("TableCfg/FuncCfg")
local ITEM_TYPE = ProtoCommon.ITEM_TYPE
local ITEM_CLASSIFY_TYPE = ProtoRes.ITEM_CLASSIFY_TYPE
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local AccessFuntype = ProtoRes.ItemAccessFunType
local ProtoCS = require("Protocol/ProtoCS")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

local AetherCurrentItemID = 66700211 -- 风脉仪道具ID
local ItemQualityColors = {
	"#d5d5d5",
	"#89bd88",
	"#6fb1e9",
	"#ac88bd",
}

---@class ItemUtil
local ItemUtil = {

}

---GetEquipData
---@param Item table @common.Item
---@return @common.EquipData
function ItemUtil.GetItemEquipData(Item)
	if nil == Item then
		return
	end

	local Attr = Item.Attr
	if nil == Attr then
		return
	end

	local ItemType = Attr.ItemType
	if ItemType ~= ITEM_TYPE.ITEM_TYPE_EQUIP then
		return
	end

	return Attr.Equip
end

function ItemUtil.CheckIsEquipmentByResID(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg == nil then
		return false
	end

	return ItemUtil.CheckIsEquipment(Cfg.Classify)
end

---CheckIsEquipment
---@param Classify number
---@return boolean
function ItemUtil.CheckIsEquipment(Classify)
	return Classify >= ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_MAIN_HAND and Classify <= ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_RING
end

function ItemUtil.CheckIsTreasureMapByResID(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg == nil then
		return false
	end

	return ItemUtil.CheckIsTreasureMap(Cfg.ItemType)
end

function ItemUtil.CheckIsTreasureMap(ItemType)
	return ItemType == ITEM_TYPE_DETAIL.MISCELLANY_TREASUREMAP
end

function ItemUtil.CheckIsMateriaByResID(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg == nil then
		return false
	end

	return ItemUtil.CheckIsMateria(Cfg.ItemType)
end

function ItemUtil.CheckIsMateria(ItemType)
	return ItemType == ITEM_TYPE_DETAIL.MISCELLANY_MATERIA
end

function ItemUtil.CheckIsAetherCurrentMachine(ResID)
	return ResID == AetherCurrentItemID
end

function ItemUtil.CheckIsAetheryteticket(ItemType)
	return ItemType == ITEM_TYPE_DETAIL.MISCELLANY_AETHERYTETICKET
end

function ItemUtil.IsCanPreviewByResID(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg == nil then
		return false
	end
	if Cfg.ItemType == ITEM_TYPE_DETAIL.COLLAGE_MOUNT or Cfg.ItemType == ITEM_TYPE_DETAIL.COLLAGE_MINION or
		Cfg.ItemType == ITEM_TYPE_DETAIL.COLLAGE_FASHION then
		return true
	else
		return false
	end
end

---CreateItem 根据资源ID创建协议里物品结构common.Item
---@param ResID number @资源ID
---@param Num number @数量
function ItemUtil.CreateItem(ResID, Num)
	local Item = {}

	Item.GID = -1
	Item.ResID = ResID
	Item.Num = Num or 0
	Item.CreateTime = 0
	Item.ExpireTime = 0
	Item.FreezeTime = 0
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg then
		Item.IsBind = Cfg.IsMarketable == 0
	else
		Item.IsBind = false
	end

	return Item
end

---GetLootItems 根据掉落方案ID获取当前展示的ITEM列表
function ItemUtil.GetLootItems(LootID)
	local RewardItemList = {}
	local LootCfgItem = LootCfg:FindCfgByKey(LootID)
	if LootCfgItem == nil then return end

	-- 经验不配置在Produce里
	local ExpFixedValue = LootCfgItem.ExpFixedValue or 0
	if ExpFixedValue > 0 then
		table.insert(RewardItemList, {
			GID = 1,
			ResID = 19000099, -- 升级经验
			Num = ExpFixedValue,
		})
	end

	for _, Produce in ipairs(LootCfgItem.Produce) do
		if Produce.ID ~= 0 then
			local bIsScore = (math.floor(Produce.ID / 1000000) == 19) -- 是积分道具如银币
			table.insert(RewardItemList, {
				GID = 1,
				ResID = Produce.ID,
				Num = Produce.MinValue,
				IsScore = bIsScore,
			})
		end
	end

	return RewardItemList
end

function ItemUtil.ItemIsScore(ResID)
	return  math.floor(ResID / 1000000) == 19
end

function ItemUtil.GetItemAccess(ItemID)
	local Item = ItemCfg:FindCfgByKey(ItemID)
	if Item ~= nil then
		return Item.Access
	end

	return nil
end

function ItemUtil.BItemHasGetWay(ItemID)
	local AccessList = ItemUtil.GetItemAccess(ItemID)
    return AccessList ~= nil and not table.empty(AccessList)
end

function ItemUtil.GetItemGetWayList(ItemID)
	local Cfg

	local AccessList = ItemUtil.GetItemAccess(ItemID)
	if AccessList == nil then
		return
	end

	local MajorLevel = MajorUtil.GetMajorLevel()
	local UnLockIndex = 1
	local CommGetWayItems = {}

	for _, value in ipairs(AccessList) do
		Cfg = ItemGetaccesstypeCfg:FindCfgByKey(value)
		if Cfg ~= nil then
			local ViewParams = {ID = Cfg.ID, FunDesc = Cfg.FunDesc, ItemID = ItemID, MajorLevel = MajorLevel, FunIcon = Cfg.FunIcon, ItemAccessFunType = Cfg.FunType, UnLockLevel = Cfg.UnLockLevel, IsRedirect = Cfg.IsRedirect, FunValue = Cfg.FunValue, RepeatJumpTipsID = Cfg.RepeatJumpTipsID, UnLockTipsID = Cfg.UnLockTipsID}
			if (ViewParams.UnLockLevel == nil or ViewParams.MajorLevel == nil or ViewParams.UnLockLevel <= ViewParams.MajorLevel) and ItemUtil.QueryIsUnLock(ViewParams.ItemAccessFunType, ViewParams.FunValue, ViewParams.ItemID) then --等级限制
				ViewParams.IsUnLock = true
			else
				ViewParams.IsUnLock = false
			end
			
			if ViewParams.IsUnLock and Cfg.SpoilerCondition and Cfg.SpoilerCondition ~= 0 then
				ViewParams.CanRevealPlot = ItemUtil.QueryIsCanRevealPlot(ViewParams.ItemAccessFunType, Cfg.SpoilerCondition)
				ViewParams.SpoilerTipsDesc = Cfg.SpoilerTipsDesc
			else
				ViewParams.CanRevealPlot = true
			end
			
			---- 如果是任务获取方式 任务完成时 不显示途径
			if (Cfg.FunType == AccessFuntype.Fun_Branch or Cfg.FunType == AccessFuntype.Fun_MainLineTask) and ViewParams.FunValue ~= 0 then
				local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
				local Cfg = QuestChapterCfg:FindCfgByKey(ViewParams.FunValue)
				local EndStatus = _G.QuestMgr:GetQuestStatus(Cfg.EndQuest)
				if EndStatus ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
					table.insert(CommGetWayItems, UnLockIndex, ViewParams)
					UnLockIndex = UnLockIndex + 1
				end
			else
				if ViewParams.IsUnLock then
					table.insert(CommGetWayItems, UnLockIndex, ViewParams)
					UnLockIndex = UnLockIndex + 1
				else
					if Cfg.NotRedirectHide == 0 then
						table.insert(CommGetWayItems,ViewParams)
					end
				end
			end
		end
	end

	return CommGetWayItems

end

function ItemUtil.QueryIsUnLock(ItemAccessFunType, FunValue, ItemID)
	-- 系统解锁查询接口 用系统分类Id查询用 CheckIDType 获取具体模块ID  用具体“功能”“副本”“职业” Id查询用CheckOpenState
	if ItemAccessFunType == AccessFuntype.Fun_Warofannihilation then
		return _G.ModuleOpenMgr:CheckOpenState(FunValue)
	elseif ItemAccessFunType == AccessFuntype.Fun_LargePWorldMatch then
		return _G.ModuleOpenMgr:CheckOpenState(FunValue)
	elseif ItemAccessFunType == AccessFuntype.Fun_Mazechallenge then
		return _G.ModuleOpenMgr:CheckOpenState(FunValue)
	elseif ItemAccessFunType == AccessFuntype.Fun_Making then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMakerNote)
	elseif ItemAccessFunType == AccessFuntype.Fun_Collection then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGatherNote)
	elseif ItemAccessFunType == AccessFuntype.Fun_Fishing then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDFisherNote)
	elseif ItemAccessFunType == AccessFuntype.Fun_Store then
		return _G.ShopMgr:ShopIsUnLock(FunValue)
	elseif ItemAccessFunType == AccessFuntype.Fun_Achievement then
		local AchievementUtil = require("Game/Achievement/AchievementUtil")
		local AchievementName = AchievementUtil.GetAchievementName(FunValue)
		return AchievementName ~= _G.LSTR(1020019)
	elseif ItemAccessFunType == AccessFuntype.Fun_NpcMagicCardBattle then
		return _G.MagicCardMgr:HasFinishPreQuestByResID(FunValue)
	elseif ItemAccessFunType == AccessFuntype.Fun_EquipExchange then
		return _G.EquipmentMgr:CheckMaterailCanGet(ItemID)
	elseif ItemAccessFunType == AccessFuntype.Fun_ArmyShop then
		return _G.ArmyMgr:IsArmyShopUnlock()
	elseif ItemAccessFunType == AccessFuntype.Fun_Dungeon then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDEntertain)
	elseif ItemAccessFunType == AccessFuntype.Fun_CommerceChamber then
		return _G.ShopMgr:ShopIsUnLock(1001)
	elseif ItemAccessFunType == AccessFuntype.Fun_DailyRandom then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDDailyRand)
	elseif ItemAccessFunType == AccessFuntype.Fun_CollectiblesTrade then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDCollection)
	elseif ItemAccessFunType == AccessFuntype.Fun_Leveque then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLeveQuest)
	elseif ItemAccessFunType == AccessFuntype.Fun_CareerGuidance then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDJobQuest)
	elseif ItemAccessFunType == AccessFuntype.Fun_PVPBattle then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBattle)
	elseif ItemAccessFunType == AccessFuntype.Fun_ArmyPreparation then
		return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDCompanySeal)
	elseif ItemAccessFunType == AccessFuntype.Fun_Market or ItemAccessFunType == AccessFuntype.Fun_Marketbulletinboard then
		return _G.MarketMgr:CanUnLockMarket()
	elseif ItemAccessFunType == AccessFuntype.Fun_JumpTableCfgID then
		local JumpUtil = require("Utils/JumpUtil")
		return JumpUtil.IsCurJumpIDCanJump(FunValue)
	else
		-- 这里包含了默认开启的模块
		return true
	end
end

--- 是否可剧透
function ItemUtil.QueryIsCanRevealPlot(FunType, SpoilerCondition)
	if FunType == AccessFuntype.Fun_Branch or FunType == AccessFuntype.Fun_MainLineTask  then
		local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
		local ChapterCfg = QuestChapterCfg:FindCfgByKey(SpoilerCondition)
		local QuestHelper = require("Game/Quest/QuestHelper")
		return QuestHelper.CheckCanActivate(ChapterCfg.StartQuest)
	elseif FunType == AccessFuntype.Fun_LargeTask then
		return _G.CounterMgr:GetCounterCurrValue(SpoilerCondition) > 0
	elseif FunType == AccessFuntype.Fun_Warofannihilation then
		return _G.CounterMgr:GetCounterCurrValue(SpoilerCondition) > 0
	elseif FunType == AccessFuntype.Fun_Mazechallenge then
		return _G.CounterMgr:GetCounterCurrValue(SpoilerCondition) > 0
	else
		FLOG_ERROR("RevealPlot FunType UnSupport")
		return true
	end
end

function ItemUtil.UpdateProfRestrictions(ItemResID)
	local ResID = ItemResID
	local Reason, FailReason= EquipmentMgr:CanEquiped(ResID, false)
	--tips职业限制过滤掉种族性别的限制
	local CanWearable = Reason
	if FailReason == 4 or FailReason == 5 then
		CanWearable = true
	end
	local OtherProfWearable = false
	if CanWearable == false then
		local MajorRoleDetail = _G.ActorMgr:GetMajorRoleDetail()
		if nil ~= MajorRoleDetail then
			for _, ProfData in pairs(MajorRoleDetail.Prof.ProfList) do
				OtherProfWearable = OtherProfWearable or EquipmentMgr:CanEquiped(ResID, false, ProfData.ProfID, ProfData.Level)
			end
		end
	end
	return CanWearable, OtherProfWearable
end

---GetEquipData
---@param Item table @common.Item
---@return @common.EquipData
function ItemUtil.ItemIsInScheme(Item)
	if Item == nil then
		return false
	end

	local Attr = Item.Attr
	if Attr == nil then
		return false
	end

	local EquipData = Attr.Equip
	if EquipData == nil then
		return false
	end

	return EquipData.IsInScheme
end

--- 获取道具名称
---@param ResID number@道具ID
function ItemUtil.GetItemName(ResID)
	return ItemCfg:GetItemName(ResID)
end

--- 获取道具iconID
---@param ResID number@道具ID
function ItemUtil.GetItemIcon(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg == nil then
		return 0
	end

	local IconID = Cfg.IconID
	if IconID == nil then
		return 0
	end
	return IconID
end

--获取物品品质框
function ItemUtil.GetItemColorIcon(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
		return ""
	end

	local IsHQ = (1 == Cfg.IsHQ)
	if IsHQ then
		return ItemDefine.HQItemIconColorType[Cfg.ItemColor]
	else
		return ItemDefine.ItemIconColorType[Cfg.ItemColor]
	end

end

function ItemUtil.GetSlotColorIcon(ResID, ItemSlotType)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg or nil == ItemSlotType then
		return ""
	end

	local IsHQ = (1 == Cfg.IsHQ)
	if IsHQ then
		if ItemSlotType == ItemDefine.ItemSlotType.Item58Slot then
			return ItemDefine.HQItem58SlotColotType[Cfg.ItemColor]
		elseif ItemSlotType == ItemDefine.ItemSlotType.Item74Slot then
			return ItemDefine.HQItem74SlotColotType[Cfg.ItemColor]
		elseif ItemSlotType == ItemDefine.ItemSlotType.Item96Slot then
			return ItemDefine.HQItem96SlotColotType[Cfg.ItemColor]
		elseif 	ItemSlotType == ItemDefine.ItemSlotType.Item126Slot then
			return ItemDefine.HQItem126SlotColotType[Cfg.ItemColor]
		elseif 	ItemSlotType == ItemDefine.ItemSlotType.Item152Slot then
			return ItemDefine.HQItem152SlotColotType[Cfg.ItemColor]
		end
	else
		if ItemSlotType == ItemDefine.ItemSlotType.Item58Slot then
			return ItemDefine.Item58SlotColotType[Cfg.ItemColor]
		elseif ItemSlotType == ItemDefine.ItemSlotType.Item74Slot then
			return ItemDefine.Item74SlotColotType[Cfg.ItemColor]
		elseif ItemSlotType == ItemDefine.ItemSlotType.Item96Slot then
			return ItemDefine.Item96SlotColotType[Cfg.ItemColor]
		elseif 	ItemSlotType == ItemDefine.ItemSlotType.Item126Slot then
			return ItemDefine.Item126SlotColotType[Cfg.ItemColor]
		elseif 	ItemSlotType == ItemDefine.ItemSlotType.Item152Slot then
			return ItemDefine.Item152SlotColotType[Cfg.ItemColor]
		end
	end
end

function ItemUtil.IsBaitItem(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
		return false
	end
	
	return Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.CONSUMABLES_BAIT
end

function ItemUtil.IsHQ(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
		return false
	end

	return (1 == Cfg.IsHQ)
end

function ItemUtil.GetItemNumText(Num)
	if Num == nil then
		return ""
	end
	
	local iCount = 0
	if Num == 0 then
		return string.format("%d", Num)
	end
	
	if Num // 1000000 == 0 then
		-- 6位数以内
		local a = Num
		local NumberTable = {}
		while (a > 0) do
			NumberTable[#NumberTable + 1] = tostring(a % 10)
			a = _G.math.modf(a / 10)
			iCount = iCount + 1
			if a > 0 and iCount % 3 == 0 then
				NumberTable[#NumberTable + 1] = ","
			end
		end
		--倒序
		local iNumberCount = #NumberTable
		local Temp
		for i = 1, iNumberCount / 2 do
			Temp = NumberTable[i]
			NumberTable[i] = NumberTable[iNumberCount - i + 1]
			NumberTable[iNumberCount - i + 1] = Temp
		end
		---concat
		local Text = table.concat(NumberTable)
		return Text
	elseif Num // 100000000 == 0 then
			-- 8位数以内
			local Text = CommonUtil.IsCurCultureChinese() and  string.format(_G.LSTR(1020062), Num // 10000) or string.format("%dm", Num // 1000000)
			return Text
	else
		--8位数以上
		local Text = CommonUtil.IsCurCultureChinese() and  string.format(_G.LSTR(1020063), Num // 100000000) or string.format("%dm", Num // 1000000)
		return Text
	end
end

function ItemUtil.GetNumProgressFormat(Value, Total)
	if Total == nil then
		return ""
	end

	local Max = 999
	if Value > Max then
		Value = Max
	end

	if Total > Max then
		Total = Max
	end

	if Value >= Total then
		return string.format("%d/%d", Value, Total )
	end

	local curNumRichText = RichTextUtil.GetText(string.format("%d", Value), "dc5868", 0, nil)
    return string.format("%s/%d", curNumRichText, Total)

end

function ItemUtil.JumpGetWayByItemData(ItemData)
	local LSTR = _G.LSTR
	local MsgTipsUtil = require("Utils/MsgTipsUtil")
	local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")
	local UIViewID = require("Define/UIViewID")
	local ItemAccessFunTypeValue = ItemData.ItemAccessFunType
	if ItemAccessFunTypeValue == AccessFuntype.Fun_Warofannihilation then
		SystemEntranceMgr:ShowPwordEntrance(3, ItemData.FunValue)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_LargePWorldMatch then
		SystemEntranceMgr:ShowPwordEntrance(4, ItemData.FunValue)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Mazechallenge then
		SystemEntranceMgr:ShowPwordEntrance(2, ItemData.FunValue)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Store then
		local TransferData = ItemData.TransferData
		SystemEntranceMgr:ShowShopEntrance(ItemData.FunValue, ItemData.ItemID, TransferData)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Shop then
		if _G.UIViewMgr:IsViewVisible(UIViewID.StoreNewMainPanel) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		local TransferData = ItemData.TransferData or {}
		TransferData.FunValue = ItemData.FunValue
		SystemEntranceMgr:ShowStoreEntrance(ItemData.ItemID, TransferData)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_ArmyShop then
		local TransferData = ItemData.TransferData
		_G.ArmyMgr:JumpToArmyShopGoods(ItemData.ItemID, TransferData)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Making then
		SystemEntranceMgr:ShowCraftingLogEntrance(ItemData.ItemID)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Collection then
		if _G.UIViewMgr:IsViewVisible(UIViewID.GatheringLogMainPanelView) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		if ItemData.ItemID then
			SystemEntranceMgr:ShowGatheringLogEntrance(ItemData.ItemID)
		else
			_G.UIViewMgr:ShowView(UIViewID.GatheringLogMainPanelView)
		end
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Fishing then
		SystemEntranceMgr:ShowFishIngholeEntrance(ItemData)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Map then
		SystemEntranceMgr:ShowMapEntrance(ItemData.FunValue)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_FateTask then
		SystemEntranceMgr:ShowFateTask(ItemData.FunValue)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Marketbulletinboard then
		if _G.UIViewMgr:IsViewVisible(UIViewID.MarketMainPanel) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		SystemEntranceMgr:ShowMarketItemEntrance(ItemData.ItemID)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_NpcMagicCardBattle then
		local FantasyCardNpcCfg = require("TableCfg/FantasyCardNpcCfg")
		local NPCAIData = FantasyCardNpcCfg:FindCfgByKey(ItemData.FunValue)
		_G.WorldMapMgr:ShowWorldMapLocationNpc(NPCAIData.MapResID, ItemData.FunValue)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Achievement then
		if _G.UIViewMgr:IsViewVisible(UIViewID.AchievementMainPanel) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end

		local Params = {AchievemwntID = ItemData.FunValue}
		_G.AchievementMgr:OpenAchievementMainPanelView(Params)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_EquipExchange then
		if ItemData.ItemID ~= 0 then
			_G.UIViewMgr:ShowView(UIViewID.EquipmentExchangeWinView, {ItemID = ItemData.ItemID})
		end
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_CommerceChamber then
		if _G.UIViewMgr:IsViewVisible(UIViewID.ShopInletPanelView) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		_G.UIViewMgr:ShowView(UIViewID.ShopInletPanelView)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Market then
		if _G.UIViewMgr:IsViewVisible(UIViewID.MarketMainPanel) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		_G.UIViewMgr:ShowView(UIViewID.MarketMainPanel)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_FateArchive then
		if _G.UIViewMgr:IsViewVisible(UIViewID.FateArchiveMainPanel) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		_G.FateMgr:ShowFateArchive()
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_TaskLog then
		if _G.UIViewMgr:IsViewVisible(UIViewID.QuestLogMainPanel) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		_G.UIViewMgr:ShowView(UIViewID.QuestLogMainPanel)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_DailyRandom then
		if _G.UIViewMgr:IsViewVisible(UIViewID.PWorldEntranceSelectPanel) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		PWorldEntUtil.ShowPWorldEntView(ProtoCommon.ScenePoolType.ScenePoolRandom)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_CareerGuidance then
		if _G.UIViewMgr:IsViewVisible(UIViewID.AdventruePanel) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		_G.AdventureCareerMgr:JumpToTargetProf()
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_CollectiblesTrade then
		if _G.UIViewMgr:IsViewVisible(UIViewID.CollectablesMainPanelView) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		_G.UIViewMgr:ShowView(UIViewID.CollectablesMainPanelView)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_Leveque then
		if _G.UIViewMgr:IsViewVisible(UIViewID.LeveQuestMainPanel) then
			MsgTipsUtil.ShowTipsByID(ItemData.RepeatJumpTipsID)
			return
		end
		_G.LeveQuestMgr:OpenLeveQuestViewByItemID(ItemData.ItemID)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_ArmyPreparation then
		_G.CompanySealMgr:OpenCompanyTaskView()
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_LegendaryWeapon then
		local IsModuleOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLegendaryWeapon)
		if not IsModuleOpen then
			print("===== 传奇武器未解锁")
			MsgTipsUtil.ShowTips(LSTR(1540008))
			return
		end
		local Params = {
			OpenSource = ItemData.FunValue,
			ItemID = ItemData.ItemID
		}
		_G.UIViewMgr:ShowView(UIViewID.LegendaryWeaponPanel, Params)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_PVPBattle then
		_G.UIViewMgr:ShowView(UIViewID.PVPInfoPanel)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_MainLineTask or ItemAccessFunTypeValue == AccessFuntype.Fun_Branch then
		_G.AdventureCareerMgr:JumpChapterOnMap(ItemData.FunValue)
	elseif ItemAccessFunTypeValue == AccessFuntype.Fun_JumpTableCfgID then
		local JumpUtil = require("Utils/JumpUtil")
		JumpUtil.JumpTo(ItemData.FunValue)
	else
		MsgTipsUtil.ShowTips(LSTR(1020064))
	end
end

function ItemUtil.GetItemQualityColor(ItemColorType)
	if nil == ItemColorType or ItemColorType > #ItemQualityColors then
		return ItemQualityColors[1]

	else
		return ItemQualityColors[ItemColorType]
	end
end

function ItemUtil.GetItemQualityColorByResID(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if nil == Cfg then
		_G.FLOG_WARNING("ItemUtil.GetItemQualityColorByResID can't find item cfg, ResID =%d", tostring(ResID))
		return ItemQualityColors[1]
	end

	return ItemUtil.GetItemQualityColor(Cfg.ItemColor)
end

-- 判断激活类物品（如宠物、坐骑、乐谱等）是否被激活过
function ItemUtil.IsActivated(ItemID)
	local ItemCfgData = ItemCfg:FindCfgByKey(ItemID)
	if nil == ItemCfgData then
		-- _G.FLOG_WARNING("[ItemUtil.IsActivated] Cannot find item " .. tostring(ItemID))
		return false
	end
	if nil == ItemCfgData.UseFunc or ItemCfgData.UseFunc == 0 then
		return false
	end
	local FuncCfgData = FuncCfg:FindCfgByKey(ItemCfgData.UseFunc)
	if nil == FuncCfgData or nil == FuncCfgData.Func[1] then
		_G.FLOG_WARNING("[ItemUtil.IsActivated] Cannot find func " .. tostring(ItemCfgData.UseFunc))
		return false
	end
	local FuncData = FuncCfgData.Func[1]
	local FuncType = FuncData.Type
	if FuncType == ProtoRes.FuncType.UnlockMount then
		if nil == _G.MountMgr then
			return false
		end
		return _G.MountMgr:IsMountOwned(FuncData.Value[1])
	elseif FuncType == ProtoRes.FuncType.CompanionActive then
		if nil == _G.CompanionMgr then
			return false
		end
		return _G.CompanionMgr:IsOwnCompanion(FuncData.Value[1])
	elseif FuncType == ProtoRes.FuncType.ActiveClosetAppearance then
		if nil == _G.WardrobeMgr then
			return false
		end
		return _G.WardrobeMgr:GetIsUnlock(FuncData.Value[1])
	elseif FuncType == ProtoRes.FuncType.UseMusic then
		if nil == _G.MusicPlayerMgr then
			return false
		end
		return _G.MusicPlayerMgr:CheckAtlasOpenState(ItemID)
	elseif FuncType == ProtoRes.FuncType.UnlockEmotion then
		if nil == _G.EmotionMgr then
			return false
		end
		return _G.EmotionMgr:IsActivatedByItemID(ItemID)
	elseif FuncType == ProtoRes.FuncType.UnlockMountFacade then
		if nil == _G.MountMgr then
			return false
		end
		return _G.MountMgr:IsCustomMadeOwned(FuncData.Value[1])
	elseif FuncType == ProtoRes.FuncType.UnlockGif then
		if nil == _G.ChatMgr then
			return false
		end
		return _G.ChatMgr:IsUnlockGifByItemID(ItemID)
	elseif FuncType == ProtoRes.FuncType.UnlockBarberShopHair then
		if nil == _G.HaircutMgr then
			return false
		end
		return _G.HaircutMgr:CheckIsHairUnlock(ItemID)
	elseif FuncType == ProtoRes.FuncType.UseFantasycard then
		if nil == _G.MagicCardCollectionMgr then
			return false
		end
		return _G.MagicCardCollectionMgr.CheckMagicCardUnlock(ItemID)
	end

	return false
end

return ItemUtil