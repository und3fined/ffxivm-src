---
--- Author: anypkvcai
--- DateTime: 2021-08-23 18:54
--- Description: 背包
---


local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local TimeUtil = require("Utils/TimeUtil")
local CondCfg = require("TableCfg/CondCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local MajorUtil = require("Utils/MajorUtil")
local SingBarMgr = require("Game/Interactive/SingBar/SingBarMgr")
local BagDefine = require("Game/Bag/BagDefine")
local ItemUtil = require("Utils/ItemUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local GlobalCfg = require("TableCfg/GlobalCfg")
local AudioUtil = require("Utils/AudioUtil")
local MsgTipsID = require("Define/MsgTipsID")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local NewBagDowngradetWinVM = require("Game/NewBag/VM/NewBagDowngradetWinVM")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local BagEnlargeCfg = require("TableCfg/BagEnlargeCfg")
local ChatDefine = require("Game/Chat/ChatDefine")
local UIViewMgr = require("UI/UIViewMgr")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ModuleOpenMgr = require("Game/ModuleOpen/ModuleOpenMgr")
local AdventureRecordCfg = require("TableCfg/AdventureRecordCfg")

local ScoreMgr = nil
local MagicCardMgr = nil

local FuncType = ProtoRes.FuncType
-- local CondFuncRelate = ProtoRes.CondFuncRelate
local ItemTypeDetail = ProtoCommon.ITEM_TYPE_DETAIL
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_BAG_CMD
local ITEM_UPDATE_TYPE = ProtoCS.ITEM_UPDATE_TYPE
local ClientSetupKey = ProtoCS.ClientSetupKey
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local MapAllPointActivateState = AetherCurrentDefine.MapAllPointActivateState
local LSTR
local FLOG_ERROR
local FLOG_WARNING
local EquipmentMgr
local EventMgr
local TimerMgr
local BuddyMgr

---@class BagMgr : MgrBase
local BagMgr = LuaClass(MgrBase)

---@field ItemList table<CsBagInfoRsp> @背包所以物品 包含任务物品
function BagMgr:OnInit()
	MagicCardMgr = require("Game/MagicCard/MagicCardMgr")
	ScoreMgr = require("Game/Score/ScoreMgr")
	self.ItemList = {}
	self.Capacity = 0

	self.FreezeCDTable = {}
	self.CDInterval = 1


	--职业药品设置
	self.ProfMedicineTable = {}

	--记录物品显示New
	self.NewItemRecord = {}

	local Cfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_ITEM_RECYCLE_NUM_UPPER_LIMIT, "Value")
	if Cfg then
		self.RecoveryMaxNum =  Cfg[1] or 100
	else
		self.RecoveryMaxNum =  100
	end

	local Cfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_ITEM_RECYCLE_SCORE_ID , "Value")
	if Cfg then
		self.RecoveryScoreID = Cfg[1] or ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
	else
		self.RecoveryScoreID =  ProtoRes.SCORE_TYPE.SCORE_TYPE_GOLD_CODE
	end

	--记录物品是否被使用
	self.ItemUsedMap = {}
end

function BagMgr:RegisterItemUsedFun(Type, Function)
	if self.ItemUsedMap == nil then
		self.ItemUsedMap = {}
	end
	self.ItemUsedMap[Type] = Function
end

function BagMgr:OnBegin()
	EquipmentMgr = require("Game/Equipment/EquipmentMgr")
	EventMgr = _G.EventMgr
	TimerMgr = _G.TimerMgr
	LSTR = _G.LSTR
	FLOG_ERROR = _G.FLOG_ERROR
	FLOG_WARNING = _G.FLOG_WARNING
	BuddyMgr = _G.BuddyMgr

	UIViewMgr:PreLoadWidgetByViewID(UIViewID.BagMain)
end

function BagMgr:OnEnd()
	self.ItemList = {}
	self.Capacity = 0
	self.FreezeCDTable = {}
	self.ProfMedicineTable = {}
	self.NewItemRecord = {}
	self.ItemUsedMap = {}
end

function BagMgr:OnShutdown()
end

function BagMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_BAG_USE_ITEM, self.OnNetMsgBagUseItem)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_BAG_INFO, self.OnNetMsgBagInfo)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_BAG_BUY, self.OnNetMsgBagBuy)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_BAG_TRIM, self.OnNetMsgBagTrim)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_BAG_UPDATE, self.OnNetMsgBagUpdate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_BAG_DROP, self.OnNetMsgBagDrop)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_ITEM_TOMQ, self.OnNetMsgItemToNQ)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_BAG_TRANS_DEPOT, self.OnNetMsgBagTransDepot)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_ITEM_CD, self.OnNetMsgBagItemCdInfo) --Cd单个GroupID信息获取
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_ITEM_CD_ALL, self.OnNetMsgBagItemCdAllInfo) --Cd所有Group信息获取

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BAG, SUB_MSG_ID.CS_CMD_ITEM_RECYC, self.OnNetBatchRecovery) --Cd所有Group信息获取
end

function BagMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.MagicsparInlaySucc, self.OnMagicsparInlaySucc)
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnClientSetupPost)
end

function BagMgr:OnGameEventLoginRes(Params)
	self:SendMsgBagInfoReq()
	self:SendMsgBagItemCDInfo(0) --同步物品Cd
end

function BagMgr:OnNetMsgBagUseItem(MsgBody)
	local Msg = MsgBody.Item
	if nil == Msg then
		return
	end

	BagMgr:SendMsgBagItemCDInfo(0) --同步物品Cd

	local ResID = Msg.ResID
	if not ResID then
		return
	end
	--有使用成功需要弹tips的 显示tips
	local Cfg = ItemCfg:FindCfgByKey(ResID)
    if Cfg ~= nil and Cfg.UseSuccTipsID ~= nil then
		if Cfg.UseSuccTipsID == MsgTipsID.UseMusicSuccTips then
			MsgTipsUtil.ShowTipsByID(Cfg.UseSuccTipsID, nil, Cfg.ItemName)
		else
			if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_BUDDYEQUIT then
				local ContentText = string.format(LSTR(990096))..Cfg.ItemName
				MsgTipsUtil.ShowTips(ContentText)
			else
            	MsgTipsUtil.ShowTipsByID(Cfg.UseSuccTipsID)
			end
		end
    end

	if Cfg ~= nil then
		---新手引导这里触发使用物品成功
		local EventParams = _G.EventMgr:GetEventParams()
		EventParams.Type = TutorialDefine.TutorialConditionType.UseItem --新手引导触发类型
		EventParams.Param1 = Cfg.ItemMainType
		EventParams.Param2 = Cfg.ItemType
		_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
	end

	--道具使用成功
	--if Cfg ~= nil and Cfg.ItemType == ITEM_TYPE_DETAIL.COLLAGE_BUDDYEQUIT
		--or Cfg.ItemType == ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD
		--or Cfg.ItemType == ITEM_TYPE_DETAIL.MISCELLANY_AETHERYTETICKET then
			--_G.EventMgr:SendEvent(EventID.BagUseItemSucc, { ResID = ResID})
	--end

	_G.EventMgr:SendEvent(EventID.BagUseItemSucc, { ResID = ResID})

	local ChatParams = {}
	ChatParams.ResID = ResID
	ChatParams.GID = self:GetItemGIDByResID(ResID)
	ChatParams.ChatType = ChatDefine.SysChatMsgBattleType.UseItem
	_G.SkillLogicMgr:PushSysChatMsgBattle(ChatParams)
end

function BagMgr:OnNetMsgBagInfo(MsgBody)
	local Msg = MsgBody.Info
	if nil == Msg then
		return
	end

	self.ItemList = Msg.ItemList or {}
	table.sort(self.ItemList, self.SortBagItemPredicate)
	self.Capacity = Msg.Capacity
	self.Enlarge = Msg.Enlarge

	EventMgr:PostEvent(EventID.BagInit)

	self:UpdateBagCapacityRed()
end

function BagMgr.SortBagItemPredicate(Left, Right)
	local  LeftNew = BagMgr.NewItemRecord[Left.GID] == true
	local  RightNew = BagMgr.NewItemRecord[Right.GID] == true
	if LeftNew ~= RightNew then
		return LeftNew
	end

	local  LeftLimit = BagMgr:IsTimeLimitItem(Left) == true
	local  RightLimit = BagMgr:IsTimeLimitItem(Right) == true
	if LeftLimit ~= RightLimit then
		return LeftLimit
	end

	if Left.ResID ~= Right.ResID then
		--无论升序降序 ResID小的排前面
		return Left.ResID < Right.ResID
	end

	if Left.Num ~= Right.Num then
		--无论升序降序 数量多的排前面
		return Left.Num > Right.Num
	end

	if Left.GID ~= Right.GID then
		--无论升序降序 GID小的排前面
		return Left.GID < Right.GID

	end

	return false
end

function BagMgr:IsTimeLimitItem(Item)
	return Item.ExpireTime and Item.ExpireTime > 0
end

function BagMgr:TimeLimitItemExpired(Item)
	if self:IsTimeLimitItem(Item) then
		return Item.ExpireTime < _G.TimeUtil:GetServerLogicTime()
	end
	return false
end

function BagMgr:CalcBagUseCapacity()
	local UseCapacity = 0
	local AllItemList = self.ItemList
	local Length = #AllItemList
	for i = 1, Length do
		local Item = AllItemList[i]
		local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
		if Cfg then
			if Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
				UseCapacity = UseCapacity + 1
			end
		end
	end
	return UseCapacity
end

function BagMgr:GetItemByResID(ResID)
	if nil == self.ItemList or nil == ResID then
		return nil
	end

	for _, v in ipairs(self.ItemList) do
		if v.ResID == ResID then
			return v
		end
	end

	return nil
end

function BagMgr:FilterItemByCondition(ConditionFun)
	local FilterItemList = {}
	table.sort(self.ItemList, self.SortBagItemPredicate)
	local AllItemList = self.ItemList
	local Length = #AllItemList
	for i = 1, Length do
		local Item = AllItemList[i]
		if ConditionFun(Item) then
			table.insert(FilterItemList, Item)
		end
	end

	return FilterItemList
end

function BagMgr:OnNetMsgBagBuy(MsgBody)
	local Msg = MsgBody.Buy
	if nil == Msg then
		return
	end

	MsgTipsUtil.ShowTips(string.format(LSTR(990001), Msg.BagCapacity - self.Capacity))

	--扩充格子数量
	self.Capacity = Msg.BagCapacity
	self.Enlarge = Msg.Enlarge

	EventMgr:SendEvent(EventID.BagBuyCapacity)
end

function BagMgr:OnNetMsgBagTrim(MsgBody)
	local Msg = MsgBody.Trim
	if nil == Msg then
		return
	end

end

function BagMgr:OnNetMsgBagUpdate(MsgBody, bForce)
	--print("BagMgr:OnNetMsgBagUpdate", MsgBody.Update, #MsgBody.Update.UpdateItem)
	local Msg = MsgBody.Update
	if nil == Msg then
		return
	end

	--_G.UE.FProfileTag.StaticBegin("OnNetMsgBagUpdate")
	local UpdateItem = Msg.UpdateItem
	for _, v in ipairs(UpdateItem) do
		if v.Type == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD then
			if v.IsTransfer == false then
				self:AddNewItemRecord(v.PstItem.GID)
			end
			self:OnItemAdd(v.PstItem)
		elseif v.Type == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_DELETE then
			self:OnItemRemove(v.PstItem)
			self.NewItemRecord[v.PstItem.GID] = nil
			EventMgr:SendEvent(EventID.TreasureHuntDropItem,v.PstItem)
		elseif v.Type == ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_RENEW then
			self:OnItemUpdate(v.PstItem, v.IsTransfer)
		end
	end

	--table.sort(self.ItemList, self.SortBagItemPredicate)
	EventMgr:PostEvent(EventID.BagUpdate, UpdateItem)

	self:UpdateBagCapacityRed()
end

function BagMgr:OnNetMsgBagDrop(MsgBody)
	MsgTipsUtil.ShowTips(LSTR(990002))
end

function BagMgr:OnNetMsgItemToNQ()
	MsgTipsUtil.ShowTips(LSTR(990003))
end

function BagMgr:OnNetMsgBagTransDepot(MsgBody)
end

function BagMgr:OnNetBatchRecovery()
end

function BagMgr:SendMsgUseItemReq(GID, Num, UseType, ItemParams, InUseFrom)
	local MsgID = CS_CMD.CS_CMD_BAG
	local SubMsgID = SUB_MSG_ID.CS_CMD_BAG_USE_ITEM

	local ParamTarget = nil
	local ParamPos = nil
	if (ItemParams ~= nil) then
		if (ItemParams.TargetEntityID ~= nil) then
			ParamTarget = ItemParams.TargetEntityID
		end
		if (ItemParams.Pos ~= nil) then
			ParamPos = ItemParams.Pos
		end
	end

	local UseFrom = InUseFrom or ProtoCS.ITEM_USE_FROM.ITEM_USE_FROM_BAG
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Item = { GID = GID, Num = Num, UseType = UseType, ParamTarget = ParamTarget, ParamPos = ParamPos, UseFrom = UseFrom }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	self.UseItemTime = TimeUtil.GetServerTimeMS()
end

function BagMgr:SendMsgBagInfoReq()
	local MsgID = CS_CMD.CS_CMD_BAG
	local SubMsgID = SUB_MSG_ID.CS_CMD_BAG_INFO

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Info = {}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BagMgr:SendMsgBagBuyReq()
	local MsgID = CS_CMD.CS_CMD_BAG
	local SubMsgID = SUB_MSG_ID.CS_CMD_BAG_BUY

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Buy = {}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BagMgr:SendMsgBagTrimReq()
	local MsgID = CS_CMD.CS_CMD_BAG
	local SubMsgID = SUB_MSG_ID.CS_CMD_BAG_TRIM

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Trim = { }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BagMgr:AddNewItemRecord(GID)
	self.NewItemRecord[GID] = true
end

function BagMgr:SendMsgBagDropReq(GID)
	local MsgID = CS_CMD.CS_CMD_BAG
	local SubMsgID = SUB_MSG_ID.CS_CMD_BAG_DROP

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Drop = { GID = GID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BagMgr:SendMsgBagToNQReq(GID)
	local MsgID = CS_CMD.CS_CMD_BAG
	local SubMsgID = SUB_MSG_ID.CS_CMD_ITEM_TOMQ

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.ToNQ = { GID = GID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


---SendMsgBagTransDepot
---@param GID number
---@param DepotIndex number
---@param Pos number @ 0表示默认紧凑放置 1-20表示具体位置
function BagMgr:SendMsgBagTransDepot(GID, DepotIndex, Pos, Num)
	local MsgID = CS_CMD.CS_CMD_BAG
	local SubMsgID = SUB_MSG_ID.CS_CMD_BAG_TRANS_DEPOT

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Trans = { GID = GID, DepotIndex = DepotIndex, Pos = Pos, Num = Num}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---查询物品CD
function BagMgr:SendMsgBagItemCDInfo(CDGroupID)
	local MsgID = CS_CMD.CS_CMD_BAG
	local SubMsgID
	local MsgBody = {}
	if CDGroupID ~= 0 then
		SubMsgID = SUB_MSG_ID.CS_CMD_ITEM_CD
		MsgBody.Cmd = SubMsgID
		MsgBody.Cd = { GroupID  = CDGroupID}
	else
		SubMsgID = SUB_MSG_ID.CS_CMD_ITEM_CD_ALL
		MsgBody.Cmd = SubMsgID
	end

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BagMgr:SendMsgBatchRecoveryReq(GIDList)
	local MsgID = CS_CMD.CS_CMD_BAG
	local SubMsgID = SUB_MSG_ID.CS_CMD_ITEM_RECYC

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Recycle = {GIDs = GIDList}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function BagMgr:FindItem(GID)
	if nil == self.ItemList or nil == GID then
		return
	end

	for _, v in ipairs(self.ItemList) do
		if v.GID == GID then
			return v
		end
	end
end

---@param InItemType ProtoCommon.ITEM_TYPE
function BagMgr:FindItemsByItemType(InItemType)
	if nil == self.ItemList then
		return
	end

	local Ret = {}
	for _, v in ipairs(self.ItemList) do
		if v.Attr and v.Attr.ItemType == InItemType then
			table.insert(Ret, v)
		end
	end
	return Ret
end

function BagMgr:GetItemNum(ResID)
	if nil == ResID or ResID <= 0 then
		return 0
	end

	if nil == self.ItemList then
		return 0
	end

	local Num = 0
	for _, v in ipairs(self.ItemList) do
		if v.ResID == ResID then
			Num = Num + v.Num
		end
	end

	return Num
end

function BagMgr:GetItemHQNum(ResID)
	local Num = 0
	local NQHQItemID = self:GetItemHQItemID(ResID)
	if NQHQItemID > 0 then
		Num = self:GetItemNum(NQHQItemID)
	end
	return Num
end

function BagMgr:GetItemNumWithHQ(ResID)
	return self:GetItemNum(ResID) + self:GetItemHQNum(ResID)
end

function BagMgr:GetItemHQItemID(ResID)
	local NQHQItemID = 0
	local ItemCfg = ItemCfg:FindCfgByKey(ResID)
	-- 拥有配置    当前道具非HQ物品      有NQHQItemID
	if ItemCfg and ItemCfg.IsHQ == 0 and ItemCfg.NQHQItemID ~= 0 then
		NQHQItemID = ItemCfg.NQHQItemID
	end
	return NQHQItemID
end

function BagMgr:GetItemNumByCondition(ConditionFun)
	local Num = 0
	local AllItemList = self.ItemList
	local Length = #AllItemList
	for i = 1, Length do
		local Item = AllItemList[i]
		if ConditionFun(Item) then
			Num = Num + 1
		end
	end
	return Num
end

function BagMgr:GetItemNQHQItemID(ResID)
	local NQHQItemID = 0
	local ItemCfg = ItemCfg:FindCfgByKey(ResID)
	-- 拥有配置    有NQHQItemID
	if ItemCfg and ItemCfg.NQHQItemID ~= 0 then
		NQHQItemID = ItemCfg.NQHQItemID
	end
	return NQHQItemID
end

function BagMgr:GetItemDataByGID(GID)
	for _, v in ipairs(self.ItemList) do
		if v.GID == GID then
			return v
		end
	end
	return nil
end

function BagMgr:OnItemAdd(Item)
	table.insert(self.ItemList, Item)
	self:AfterOnItemAdd(Item)
end

function BagMgr:AfterOnItemAdd(Item)
	--MagicCardMgr:OnGetItem(Item)
	self:DealWithEasyUse(Item)
end

function BagMgr:DealWithEasyUse(Item)
	if self.NewItemRecord[Item.GID] == nil then
		return
	end

	if _G.UpgradeMgr.IsOnDirectUpState then
		return
	end
	--FLOG_INFO("DealWithEasyUse source addItem: %s", ItemUtil.GetItemName(Item.ResID))

	-- 便捷使用放入队列
	local function ShowTipsCallback(Params)
		self:PopUpEasyUse(Params.Item)
	end
	local Config = {Type = ProtoRes.tip_class_type.TIP_EASY_USE, Callback = ShowTipsCallback, Params = {Item = Item}}
	_G.TipsQueueMgr:AddPendingShowTips(Config)
end

function BagMgr:PopUpEasyUse(Item)
	_G.SidePopUpMgr:AddSidePopUp(ProtoRes.side_popup_type.SIDE_POPUP_EASY_USE, _G.UIViewID.SidePopUpEasyUse, Item, function(Item)
		--FLOG_INFO("ShowConditional addItem: %s", ItemUtil.GetItemName(Item.ResID))
		local ItemResID = Item.ResID
		local ItemGID = Item.GID
		local CurItemCfg = ItemCfg:FindCfgByKey(ItemResID)
		if CurItemCfg == nil then
			return false
		end

		if CurItemCfg.EasyUse == 1 then
			local IsEquipment = ItemUtil.CheckIsEquipmentByResID(ItemResID)
			if IsEquipment then
				if EquipmentMgr:CanEquiped(ItemResID) == false or self:DiffQualityWithEquipment(ItemResID) <= 0 then
					--FLOG_INFO("ShowConditional success addItem: %s, addLevel = %d", ItemUtil.GetItemName(Item.ResID), self:DiffQualityWithEquipment(Item.ResID))
					return false
				end
			end

			if CurItemCfg.ItemMainType == ProtoCommon.ItemMainType.ItemCollage then
				if CurItemCfg.ItemType == ItemTypeDetail.COLLAGE_COIFFURE then
					_G.HaircutMgr:SendMsgHairQuery()
				end
				if self:IsItemUsed(CurItemCfg) then
					return false
				end
			end

			if _G.AetherCurrentsMgr:IsTaskAetherCurrentItem(ItemResID) then
				return _G.AetherCurrentsMgr:IsCanShowEasyUse(CurItemCfg, ItemGID)
			end

			return true
		end

		return false
	end)
end

function BagMgr:DiffQualityWithEquipment(ResID)
	local CurItemCfg = ItemCfg:FindCfgByKey(ResID)
	if CurItemCfg == nil then
		return 0
	end

	local ECfg = EquipmentCfg:FindCfgByKey(ResID)
	if ECfg == nil then
		return 0
	end

	local EquipedLevel = 0
	if ECfg.Part == ProtoCommon.equip_part.EQUIP_PART_FINGER then
		local LeftEquipedItem = EquipmentMgr:GetEquipedItemByPart(ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER)
		local RightEquipedItem = EquipmentMgr:GetEquipedItemByPart(ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER)
		if LeftEquipedItem then
			local EquipedItemCfg = ItemCfg:FindCfgByKey(LeftEquipedItem.ResID)
			if EquipedItemCfg then
				EquipedLevel = EquipedItemCfg.ItemLevel
			end
		else
			EquipedLevel = 0
		end

		if RightEquipedItem then
			local EquipedItemCfg = ItemCfg:FindCfgByKey(RightEquipedItem.ResID)
			if EquipedItemCfg and EquipedLevel > EquipedItemCfg.ItemLevel then
				EquipedLevel = EquipedItemCfg.ItemLevel
			end
		else
			EquipedLevel = 0
		end
    else
        local EquipedItem = EquipmentMgr:GetEquipedItemByPart(ECfg.Part)
		if EquipedItem then
			local EquipedItemCfg = ItemCfg:FindCfgByKey(EquipedItem.ResID)
			if EquipedItemCfg then
				EquipedLevel = EquipedItemCfg.ItemLevel
			end
		end
    end

	return CurItemCfg.ItemLevel - EquipedLevel
end

function BagMgr:OnItemRemove(Item)
	for i, v in ipairs(self.ItemList) do
		if v.GID == Item.GID then
			table.remove(self.ItemList, i)
			return
		end
	end
end

function BagMgr:OnItemUpdate(Item, IsTransfer)
	for i, v in ipairs(self.ItemList) do
		if v.GID == Item.GID then
			if v.Num < Item.Num and IsTransfer == false then
				self:AddNewItemRecord(Item.GID)
			end
			self.ItemList[i] = Item
			self:AfterOnItemAdd(Item)
			return
		end
	end
end

function BagMgr:OnMagicsparInlaySucc(GID, Index, ResID)

end

-- 安装事件
function BagMgr:OnClientSetupPost(EventParams)
	local Key = EventParams.IntParam1
	local Value = EventParams.StringParam1
	if Key == ClientSetupKey.CSCombatDrug then
		if Value == "" then -- Value == "" 表示没有设置战斗药品
			self.ProfMedicineTable = {}
			return
		end
		self.ProfMedicineTable = {}
		local Reg = string.gmatch(Value, '(%d*)=(%d*)')

		for k, v in Reg do
			self.ProfMedicineTable[tonumber(k)] = tonumber(v)
		end
	end
end

function BagMgr:ManualSetMedicine(ProfID, ResID)
	self.ProfMedicineTable[ProfID] = ResID
	_G.EventMgr:SendEvent(EventID.BagManualSetMedicine, ProfID, ResID)
end

function BagMgr:OnNetMsgBagItemCdAllInfo(CdInfo)
	local CdList = CdInfo.Cd.CdList
	for GroupID, FreezeCDData in pairs(self.FreezeCDTable) do
		if FreezeCDData then
			if FreezeCDData.TimeId then
				EventMgr:SendEvent(EventID.BagFreezeCD, GroupID, TimeUtil.GetServerTime(), FreezeCDData.FreezeCD) --发生cd结束事件
				TimerMgr:CancelTimer(FreezeCDData.TimeId)
			end
		end
	end
	self.FreezeCDTable = {}

	for _, v in pairs(CdList) do
		local GroupID = v.GroupID
		local EndTime = v.NextTime
		local FreezeCD = v.Duration
		self:UpdateFreezeCDTableDateAndStartTimer(GroupID, EndTime, FreezeCD)
	end
end


function BagMgr:OnNetMsgBagItemCdInfo(CdInfo)
	local CdData = CdInfo.Cd.CdList[1]

	local GroupID = CdData.GroupID
	local EndTime = CdData.NextTime
	local FreezeCD = CdData.Duration
	self:UpdateFreezeCDTableDateAndStartTimer(GroupID, EndTime, FreezeCD)
end

--- 更新道具冷却CD数据并开启计时器更新
---@param GroupID number@CD道具组ID
---@param EndTime number@CD结束时间服务器时间戳
function BagMgr:UpdateFreezeCDTableDateAndStartTimer(GroupID, EndTime, FreezeCD)
	local CurTime = TimeUtil.GetServerTime()
	if EndTime - CurTime > 0 then --这边后台没有关闭计时器组，前台判断Cd<=0
		if self.FreezeCDTable[GroupID] == nil then
			self.FreezeCDTable[GroupID] = {}
			local TimeId = _G.TimerMgr:AddTimer(self, self.UpdateFreezeCD, 0, self.CDInterval, 0, {FreezeGroup = GroupID})
			self.FreezeCDTable[GroupID].TimeId = TimeId
			self.FreezeCDTable[GroupID].FreezeCD = FreezeCD
			self.FreezeCDTable[GroupID].EndTime = EndTime
		else
			self.FreezeCDTable[GroupID].FreezeCD = FreezeCD
			self.FreezeCDTable[GroupID].EndTime = EndTime
		end
	end
end

local USE_ITEM_CD = 500  -- 使用物品cd时间 500 毫秒
---使用背包物品
------@param GID 物品在背包中的GID
------@param ItemParams 额外使用物品的参数，如需要传入技能参数SkillParams
function BagMgr:UseItem(GID, ItemParams)
	if self.UseItemTime and self.UseItemTime > 0 then
		if TimeUtil.GetServerTimeMS() - self.UseItemTime > 0 and TimeUtil.GetServerTimeMS() - self.UseItemTime < USE_ITEM_CD then
			AudioUtil.LoadAndPlay2DSound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/SYS/Play_SE_UI_warning.Play_SE_UI_warning'")
			return
		else
			self.UseItemTime = 0
		end
	end

	self:UseItemNoCD(GID, ItemParams)
end


function BagMgr:UseItemNoCD(GID, ItemParams)
	if MajorUtil.IsMajorDead() then
		MsgTipsUtil.ShowTipsByID(MsgTipsID.EmitionCannotUse)
		return
	end

	if _G.ChocoboTransportMgr:GetIsTransporting() then
        MsgTipsUtil.ShowTips(LSTR(580010)) --580010=任务陆行鸟骑乘中，无法使用道具
		return
	end

	local Item = self:GetItemDataByGID(GID)
	-- 物品使用条件
	local LimitValue = nil
	local EntityID = nil
	if (ItemParams ~= nil) and (ItemParams.LimitValue ~= nil) then
		LimitValue = ItemParams.LimitValue
		EntityID = ItemParams.TargetEntityID
	end
	if Item == nil or not self:ItemUseCondition(Item, LimitValue, EntityID) then
		return
	end

	--搭档野菜需要特殊处理，未来视情况减小耦合
	if Item.ResID == BuddyMgr.CallTimeItemID and  BuddyMgr:IsBuddyOuting() == false then
		BuddyMgr:OnCallBuddy()
		return
	end

	-- 任务使用物品需求，未来视情况减小耦合
	if ItemParams and ItemParams.TargetEntityID then
		_G.InteractiveMgr:SetExeptionUseItem(Item.ResID, ItemParams.TargetEntityID)
	end


	-- 光之证
	if Item.ResID == _G.UpgradeMgr:GetUpgradeItemID() then
		local IsUpgradeStart, IsUpgradeEnd = _G.UpgradeMgr:IsUpgradeCanUse()
		if IsUpgradeStart then
			if not IsUpgradeEnd then
				_G.UpgradeMgr:SendUpdate()
			else
				MsgTipsUtil.ShowTips(LSTR(990126))
			end
		else
			MsgTipsUtil.ShowTips(LSTR(990127))
		end
        return
	end

	local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
	if Cfg == nil then
		return
	end

	if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_COIFFURE and self:IsItemUsed(Cfg) then
		MsgTipsUtil.ShowTips(LSTR(990004))
		return
	end

	if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_BUDDYEQUIT then
		if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDChocoboArmorCollect) then
			MsgTipsUtil.ShowTips(LSTR(670017))
			return
		end

		if self:IsItemUsed(Cfg) then
			MsgTipsUtil.ShowTips(LSTR(990095))
			return
		end
	end
    
	if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_ACCESSORY then
		if self:IsItemUsed(Cfg) then
			MsgTipsUtil.ShowTips(LSTR(1030021))
			return
		end
	end

	if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_ACTINGBOOK and _G.EmotionMgr:IsActivatedByItemID(Item.ResID) then
		MsgTipsUtil.ShowTips(LSTR(990004))
		return
	end

	--判断物品是否在CD中
	if self.FreezeCDTable[Cfg.FreezeGroup] ~= nil then
		local CDMsg = string.format("%s%s%s", LSTR(990005), ItemCfg:GetItemName(Item.ResID), LSTR(990006))
		if Item.ResID == PersonInfoDefine.RenameCardID then
			local TimeUtil = require("Utils/TimeUtil")
			local CurTime = TimeUtil.GetServerTime()
			local EndTimte = self.FreezeCDTable[Cfg.FreezeGroup].EndTime
			local LocalizationUtil = require("Utils/LocalizationUtil")
			CDMsg = string.format(LSTR(620105), LocalizationUtil.GetCountdownTimeForSimpleTime(EndTimte - CurTime, "m"))
		end

		MsgTipsUtil.ShowTips(CDMsg, nil)
		return
	end

	-- 吟唱
	if Cfg.SingID ~= nil and Cfg.SingID ~= 0 then
		local Func = FuncCfg:FindCfgByKey(Cfg.UseFunc)
		if Func ~= nil and (Func.Func[1].Type == FuncType.UseAdventureRocord or Func.Func[2].Type == FuncType.UseAdventureRocord) then -- 使用冒险录
			local Title = string.format(LSTR(990124), Cfg.ItemName)
			local Msg = string.format(LSTR(990125), Cfg.ItemName)
			MsgBoxUtil.ShowMsgBoxTwoOp(self, Title, Msg, function ()
				if UIViewMgr:IsViewVisible(UIViewID.BagMain) then
					UIViewMgr:HideView(UIViewID.BagMain)
				end
				self:UseSingItem(Item, Cfg.SingID, ItemParams)
			end)
		else
			self:UseSingItem(Item , Cfg.SingID, ItemParams)
		end
	elseif Cfg.InteractiveID ~= nil and Cfg.InteractiveID ~= 0 then
		self:UseInteractiveItem(Item , Cfg.InteractiveID, ItemParams)
	else
		self:ItemUseFunction(Item, ItemParams)
	end

end


function BagMgr:IsItemUsed(ItemCfg)
	if ItemCfg == nil then
		return false
	end

	local ItemUsedFunction = self.ItemUsedMap[ItemCfg.ItemType]
	if ItemUsedFunction == nil then
		return false
	end

	return self.ItemUsedMap[ItemCfg.ItemType](ItemCfg.ItemID)
end

function BagMgr:GetItemFuncCfg(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg == nil then return nil end
	return FuncCfg:FindCfgByKey(Cfg.UseFunc)
end

function BagMgr:GetItemCondCfg(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg == nil then return nil end
	return CondCfg:FindCfgByKey(Cfg.UseCond)
end

-- 使用物品的功能
function BagMgr:ItemUseFunction(Item, ItemParams)
	if ItemParams ~= nil then

	local EventParams = {
		ResID = Item.ResID,
	}
	_G.EventMgr:SendEvent(EventID.BagUseItem, EventParams)
	end
	local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
	if Cfg then
		local Func = FuncCfg:FindCfgByKey(Cfg.UseFunc) --物品使用没有函数调用
		if Cfg.IsCloseBag == 1 then
			if UIViewMgr:IsViewVisible(UIViewID.BagMain) then
				UIViewMgr:HideView(UIViewID.BagMain)
			end
		end
		if Func == nil then
			self:SendMsgUseItemReq(Item.GID, 1, 0)
			return
		end

		local FuncTypeCond = {}
		for _, Value in pairs(FuncType) do
			FuncTypeCond[Value] = false
		end

		for _, Func in pairs(Func.Func)do
		--状态并/或条件，或找到执行成功的第一个函数，执行成功后后面不执行
			FuncTypeCond[Func.Type] = {
				Func.Value[1], Func.Value[2], Func.Value[3]
			}	-- 记录功能类型是否有用到
		end

		if FuncTypeCond[FuncType.Skill] then --物品技能
			self:SendMsgUseItemReq(Item.GID, 1, FuncType.Skill, ItemParams)
		elseif FuncTypeCond[FuncType.CommitTask] then --任务物品使用
			self:SendMsgUseItemReq(Item.GID, 1, FuncType.CommitTask, ItemParams)
		elseif FuncTypeCond[FuncType.UseMake] then --解锁制作物
			self:SendMsgUseItemReq(Item.GID, 1, FuncType.UseMake, ItemParams)
		elseif FuncTypeCond[FuncType.UseGather] then --解锁采集物
			self:SendMsgUseItemReq(Item.GID, 1, FuncType.UseGather, ItemParams)
		elseif FuncTypeCond[FuncType.WindPulseDetect] then --风脉仪使用
			--self:SendMsgUseItemReq(Item.GID, 1, FuncType.WindPulseDetect, ItemParams)
			--风脉仪使用
			_G.AetherCurrentsMgr:UseSearchMachine()
		elseif FuncTypeCond[FuncType.UnlockBarberShopHair] then
			_G.HaircutMgr:AddNewHair(Item.ResID)
			self:SendMsgUseItemReq(Item.GID, 1, 0) --默认
		elseif FuncTypeCond[FuncType.Rename] then
			_G.UIViewMgr:ShowView(_G.UIViewID.UseRenameCard, {Item = Item})
		elseif FuncTypeCond[FuncType.OpenUI] then
			local UIViewID = FuncTypeCond[FuncType.OpenUI][1]
			if UIViewID == _G.UIViewID.BagTreasureChestWin then
				_G.TreasureChestMgr:OnUsedItemFromBag(Item.ResID, Item.GID, Item.Num)
			end
			if UIViewID == _G.UIViewID.BagExpandWin then
				local EnlargeCfg = BagEnlargeCfg:FindCfgByKey(BagMgr.Enlarge)
				-- 背包扩容已达到上限
				if EnlargeCfg == nil then
					_G.MsgTipsUtil.ShowErrorTips(LSTR(990043), 1)
					return
				end
			end
			if UIViewID == _G.UIViewID.WardrobeMainPanel then
				 _G.WardrobeMgr:OpenWardrobeMainPanel()
				 return
			end
			_G.UIViewMgr:ShowView(UIViewID)
		elseif FuncTypeCond[FuncType.WindPulseMapActive] then
			local CurMapID = _G.PWorldMgr:GetCurrMapResID()
			if not CurMapID then
				return
			end
			if _G.AetherCurrentsMgr:IsMapPointsAllActived(CurMapID) ~= MapAllPointActivateState.NotComp then
				_G.MsgTipsUtil.ShowTipsByID(306211)
				
			else
				local bInSearchMachine
				if ItemParams and type(ItemParams) == "table" then
					bInSearchMachine = ItemParams.bInSearchMachine
				end
				_G.AetherCurrentsMgr:ShowSecondConfirmPanel(bInSearchMachine)
			end
		elseif FuncTypeCond[FuncType.UseAdventureRocord] then	-- 使用冒险录
			_G.NewTutorialMgr:OnReadyUpgrade()
			ModuleOpenMgr:SetIsOnDirectUpState(true)
			local AdventureRecordCfg = AdventureRecordCfg:FindCfg(string.format("ItemID = %d", Item.ResID))
			if AdventureRecordCfg ~= nil then
				if AdventureRecordCfg.DialogueID ~= 0 then
					local function CallBack()
						_G.UpgradeMgr.IsOnDirectUpState = true
						_G.UpgradeMgr.IsLevelUpgrade = false
						self:SendMsgUseItemReq(Item.GID, 1, 0)
					end
					_G.NpcDialogMgr:PlayDialogLib(AdventureRecordCfg.DialogueID, nil, nil, CallBack)
				else
					_G.UpgradeMgr.IsOnDirectUpState = true
					_G.UpgradeMgr.IsLevelUpgrade = false
					self:SendMsgUseItemReq(Item.GID, 1, 0)
				end
			end
		else
			if Item.Num > 1 and Func.BatchUseNum > 1 then
				Item.BatchUse = true
				_G.UIViewMgr:ShowView(_G.UIViewID.BagDepotTransfer, {Item = Item}) -- 批量使用
			else
				self:SendMsgUseItemReq(Item.GID, 1, 0) --默认
			end
		end

	end
end

-- 使用物品的条件
---@param Item table @common.Item
---@param LimitValue number 限制值
---@param InEntityID number 使用对象
---@param bHideErrorTips boolean 不满足条件时不显示错误消息
---@return CondFlag bool 是否能使用
function BagMgr:ItemUseCondition(Item, LimitValue, InEntityID, bHideErrorTips)
	if Item == nil then
		return true
	end

	local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
	if Cfg == nil then
		return true
	end

	local Cond = CondCfg:FindCfgByKey(Cfg.UseCond) --物品状态/限制
	if Cond == nil or Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_FASHION then
		return true
	end
	--?? 不知道为啥这里加这两句代码 先屏蔽
	--local ProfID = MajorUtil.GetMajorProfID()
	--self:CurrentProfCanEquiped(ProfID, 60300007,  false)

	local ConditionParams = { LimitValue1 = LimitValue, EntityID = InEntityID }
	local CondRlt, CondFailReasonList, bHaveShowTips = ConditionMgr:CheckCondition(Cond, ConditionParams, not bHideErrorTips)

	if CondRlt == false and not bHideErrorTips and CondFailReasonList and not bHaveShowTips then
		for ReasonType, Value in pairs(CondFailReasonList) do
			if Value then
				if ReasonType == CondFailReason.AreaLimit then
					MsgTipsUtil.ShowErrorTips(LSTR(990007))
				else
					MsgTipsUtil.ShowErrorTips(LSTR(990008))
				end

				break
			end
		end
	end

	return CondRlt
end

function BagMgr:UseSingItem(Item, SingID, ItemParams)
	local SingFinshCallback = function (IsBreak)
		if not IsBreak then
			self:ItemUseFunction(Item, ItemParams)
		end
	end
	SingBarMgr:MajorSingBySingStateIDWithoutInteractiveID(SingID, SingFinshCallback, {ResID = Item.ResID})
end

function BagMgr:UseInteractiveItem(Item, InteractiveID, ItemParams)
	local CfgItem = InteractivedescCfg:FindCfgByKey(InteractiveID)
	if CfgItem then
		self.TempUseInteractiveItemParam = {}
		self.TempUseInteractiveItemParam.SingStateID = CfgItem.SingStateID[1]
		self.TempUseInteractiveItemParam.Item = Item
		self.TempUseInteractiveItemParam.ItemParams = ItemParams
		self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOverHandleOnce)
		_G.InteractiveMgr:SendInteractiveStartReqWithoutObj(InteractiveID)
	end
end

function BagMgr:OnMajorSingBarOverHandleOnce(EntityID, IsBreak, SingStateID)
	if EntityID == MajorUtil.GetMajorEntityID() then
		local Param = self.TempUseInteractiveItemParam
		if Param then
			if Param.SingStateID == SingStateID then
				if not IsBreak then
					self:ItemUseFunction(Param.Item, Param.ItemParams)
				end
			end
		end
		self.TempUseInteractiveItemParam = nil
		self:UnRegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOverHandleOnce)
	end
end

function BagMgr:UpdateFreezeCD(Params)
	local FreezeGroup = Params.FreezeGroup
	local FreezeCDData = self.FreezeCDTable[FreezeGroup]
	if FreezeCDData == nil then
		return
	end
	if FreezeCDData.EndTime <= TimeUtil.GetServerTime() then -- 关闭组计时器时间
		self.FreezeCDTable[FreezeGroup] = nil
		EventMgr:SendEvent(EventID.BagFreezeCD, FreezeGroup, FreezeCDData.EndTime, FreezeCDData.FreezeCD) --发送背包物品冷却事件
		TimerMgr:CancelTimer(FreezeCDData.TimeId)
		return
	end

	EventMgr:SendEvent(EventID.BagFreezeCD, FreezeGroup, FreezeCDData.EndTime, FreezeCDData.FreezeCD) --发送背包物品冷却事件
end

function BagMgr:FindEquipCfgByKey(Key)
	local EquipCfg = ItemCfg:FindCfgByKey(Key)
	if EquipCfg == nil then
		EquipCfg = EquipmentCfg:FindCfgByEquipID(Key)
	end
	return EquipCfg
end

---丢弃背包物品
---@param Item table @common.Item
function BagMgr: DropItem(Item)
	local function Callback()
		self:SendMsgBagDropReq(Item.GID)
	end

	local Message = LSTR(990009)
	if self:IsHighValueItem(Item) then
		Message = LSTR(990010)
	elseif ItemUtil.ItemIsInScheme(Item)then -- 拥有套装标记的装备需要丢弃两次
		Message = LSTR(990011)
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.BagItemActionTips, {Title = LSTR(990012), Message = Message, Item = Item, ClickedOkAction = Callback})
end


---降品背包物品
---@param Item table @common.Item
function BagMgr:ToNQItem(Item)
	if NewBagDowngradetWinVM.NoConfirm == true then
		self:SendMsgBagToNQReq(Item.GID)
		return
	end

	local function Callback()
		self:SendMsgBagToNQReq(Item.GID)
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.BagItemToNQTips, {Item = Item, ClickedOkAction = Callback})
end

function BagMgr:IsHighValueItem(Item)
	local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
	if nil ~= Cfg and Cfg.IsHighValue == 1 then
		return true
	end

	if Item.Attr and Item.Attr.Equip and Item.Attr.Equip.GemInfo and Item.Attr.Equip.GemInfo.CarryList and  #Item.Attr.Equip.GemInfo.CarryList > 0 then
		return true
	end

	return false
end

--获取背包剩余容量
--现在兵装库和物品是共用剩余容量
function BagMgr:GetBagLeftNum()
	if self.Capacity == nil then
		return 0
	end
	return self.Capacity - self:CalcBagUseCapacity()
end

function BagMgr:GetItemGIDByResID(ResID)
	if nil == self.ItemList or nil == ResID then
		return nil
	end

	for _, v in ipairs(self.ItemList) do
		if v.ResID == ResID then
			return v.GID
		end
	end

	return nil
end

function BagMgr:UpdateBagCapacityRed()
    local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
	if self:GetBagLeftNum() <= 10 then
		RedDotMgr:AddRedDotByID(BagDefine.RedDotID)
	else
		RedDotMgr:DelRedDotByID(BagDefine.RedDotID)
	end
end

function BagMgr:CheckLootItemInfo(LootItemInfo, bCheckBag)
	if bCheckBag then
		-- 和当前背包比较
		for _, Item in ipairs(self.ItemList) do
			if LootItemInfo[Item.ResID] ~= nil then
				local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
				-- 检查一下任务道具, 正常情况下任务道具和非任务道具的发放方式不一样
				if Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
					local LootItemNum = LootItemInfo[Item.ResID]
					local ItemCapacity = Cfg.MaxPile - Item.Num
					if LootItemNum > ItemCapacity then
						LootItemInfo[Item.ResID] = LootItemNum - ItemCapacity
					else
						LootItemInfo[Item.ResID] = nil
					end
				end
			end
		end
	end
	-- 计算发放道具需要的背包空间
	local LootItemCount = 0
	for ResID, Num in pairs(LootItemInfo) do
		local Cfg = ItemCfg:FindCfgByKey(ResID)
		if Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
			local MaxPile = Cfg.MaxPile
			if MaxPile > 0 then
				local Count = math.ceil(Num / MaxPile)
				LootItemCount = LootItemCount + Count
			end
		end
	end
	return LootItemCount
end

function BagMgr:IsMedicineItem(ResID)
	if ResID == nil then
		return false
	end
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg == nil then
		return false
	end

	return Cfg.ItemType == ITEM_TYPE_DETAIL.CONSUMABLES_MEDICINE and Cfg.UseFunc > 0
end

function BagMgr:GetItemByCondition(ConditionFun)
	if type(ConditionFun) ~= "function" then
		return {}
	end
	local RetList = {}
	local AllItemList = self.ItemList
	local Length = #AllItemList
	for i = 1, Length do
		local Item = AllItemList[i]
		if ConditionFun(Item) then
			table.insert(RetList, Item)
		end
	end
	return RetList
end


return BagMgr