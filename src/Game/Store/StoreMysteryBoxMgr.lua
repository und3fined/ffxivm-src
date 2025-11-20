
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local EventMgr = require("Event/EventMgr")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local TimeUtil = require("Utils/TimeUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCS = require("Protocol/ProtoCS")
local HairCfg = require("TableCfg/HairCfg")
local UIViewID = require("Define/UIViewID")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreCfg = require("TableCfg/ScoreCfg")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBindableList = require("UI/UIBindableList")
local ProtoCommon = require("Protocol/ProtoCommon")
local StoreDefine = require("Game/Store/StoreDefine")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local MysteryboxCfg = require("TableCfg/MysteryboxCfg")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local MountCustomCfg = require("TableCfg/MountCustomCfg")
local ConditionMgr = require("Game/Interactive/ConditionMgr")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")
local CommercializationRandConsumeCfg = require("TableCfg/CommercializationRandConsumeCfg")

local CS_CMD = ProtoCS.CS_CMD
local MysteryBoxSubCmd = ProtoCS.Game.BlindBox.CS_BLINDBOX_CMD
local TimePattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
local MysteryBoxTypes = ProtoRes.SpecialMysteryBoxTypes

local function FuncStringToTable(Str)
	Str = Str:gsub("[{}]", "")

	local Tbl = {}

	for key, value in Str:gmatch("(%d+)=(%d+)") do
		Tbl[tonumber(key)] = tonumber(value)
	end
	return Tbl
end

---@class StoreMysteryBoxMgr : MgrBase
local StoreMysteryBoxMgr = LuaClass(MgrBase)

function StoreMysteryBoxMgr:OnInit()
	self.MysteryBoxDownTimerList = {}
	self.MasteryBoxServerUpValue = {}
	self.MysteryBoxRewardList = UIBindableList.New(ItemVM)
	self.RedDotPathList = {}
end

function StoreMysteryBoxMgr:OnInitData()
	--- CommRewardPanel内部逻辑不适配发型Icon,所以这里初始化ItemVMList传进去
	local TempServerRedDotData = _G.ClientSetupMgr:GetSetupValue(MajorUtil.GetMajorRoleID(), ClientSetupID.StoreMasteryBoxReddot)
	if TempServerRedDotData ~= nil then
		self.MasteryBoxServerUpValue = FuncStringToTable(TempServerRedDotData)
	end
	self:InitMsteryBoxData(true)
end

function StoreMysteryBoxMgr:OnRegisterNetMsg()
	--- 奇遇盲盒
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BLINDBOX, MysteryBoxSubCmd.GETLIST, self.OnNetMysteryBoxGetList)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BLINDBOX, MysteryBoxSubCmd.BUY, self.OnNetBuyMysteryBox)
end
function StoreMysteryBoxMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
end

---@param Params any
function StoreMysteryBoxMgr:OnGameEventLoginRes(Params)
end

--- 盲盒购买记录
function StoreMysteryBoxMgr:SendGetMysteryBoxList(ID)
	if not ID then return end
	if table.is_nil_empty(self.MysteryBoxBoughtCount) or not self.MysteryBoxBoughtCount[ID] then
		local MsgID = CS_CMD.CS_CMD_BLINDBOX
		local SubMsgID = MysteryBoxSubCmd.GETLIST
		local MsgBody = {}
		MsgBody.Cmd = SubMsgID
		MsgBody.GetListReq = {ID = ID}
		GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	end
end

function StoreMysteryBoxMgr:OnNetMysteryBoxGetList(MsgBody)
	if MsgBody == nil then
		return
	end
	
	local Msg = MsgBody.GetListRsp
	if Msg == nil then
		return
	end
	local BlindBoxID = Msg.BlindBoxID
	local DrawCount = Msg.DrawCount
	self:SetMysteryBoxBoughtCount(BlindBoxID, DrawCount)
end


function StoreMysteryBoxMgr:OnNetBuyMysteryBox(MsgBody)
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
		local TempLootCfg = CommercializationRandCfg:FindAllCfg(string.format("DropID = %d AND PrizePoolID = %d", TempItemID, TempMysteryboxData.PrizePoolID))
		if TempLootCfg ~= nil and TempLootCfg[1] ~= nil then
			local ItemNum = ItemIDList[i].ItemNum
			local IsMustBeGet = TempLootCfg[1].ProbMode == ProtoRes.PROBABILITY_TYPE.PROBABILITY_TYPE_GUARANTEED
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
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID, true)
	self.MysteryBoxRewardList:UpdateByValues(TempTable)
	for _, value in ipairs(self.MysteryBoxRewardList.Items) do
		local TempCfg = HairUnlockCfg:FindCfgByItemID(value.ResID)
			if TempCfg ~= nil then
			local TempHairCfg = HairCfg:FindAllCfg(string.format("RaceID=%d AND Tribe=%d AND Gender=%d AND HaircutType=%d", RaceID, RoleVM.Tribe, RoleVM.Gender, TempCfg.HairID))
			if TempHairCfg ~= nil and TempHairCfg[1] ~= nil then
				value.Icon = TempHairCfg[1].IconPath
			end
		end
	end
	Params.ItemVMList = self.MysteryBoxRewardList
	Params.BtnLeftText = LSTR(950033)	--- 确认
    Params.BtnRightText = LSTR(950087) --- 再买一个
	Params.IsByMasteryBoxReset = true	--- 从盲盒打开的恭喜获得，关闭时需要重置下背景点击事件
    Params.BtnLeftCB = function() UIViewMgr:HideView(UIViewID.CommonRewardPanel) end
	Params.BtnRightCB = function() UIViewMgr:HideView(UIViewID.CommonRewardPanel) UIViewMgr:ShowView(UIViewID.StoreBlindBoxBuyWinPanel) end
 	local TempCommRewardView = UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
	TempCommRewardView.CommonPopUpBG:SetHideOnClick(false)
	UIUtil.SetIsVisible(TempCommRewardView.TextHint, false)
	UIUtil.SetIsVisible(TempCommRewardView.TextCloseTips, false)
	local GoodsCfg = self:GetMysteryBoxDataByID(BlindBoxID)

	local DelayTime = 0
	--- 发型盲盒需要播放翻转动画
	if GoodsCfg.Type == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE then
		self:RegisterTimer(function()
			--- 0.9秒后  找到发型Item播放翻转动画
			for index, value in ipairs(self.MysteryBoxRewardList.Items) do
				if value.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_COIFFURE then
					EventMgr:SendEvent(EventID.StoreMysteryAnimEvent, index)
					break
				end
			end
		end, 0.9, 0, 1)
		DelayTime = 1.4
	end
	self:RegisterTimer(function(_, TempGoodsCfg)
		local CanContinuePurchase = self:CheckGoodsIsOwned(TempGoodsCfg)
		-- UIUtil.SetIsVisible(TempCommRewardView.TextHint, CanContinuePurchase)
		UIUtil.SetIsVisible(TempCommRewardView.TextCloseTips, CanContinuePurchase)
		UIUtil.SetIsVisible(TempCommRewardView.PanelBtn, not CanContinuePurchase)
		UIUtil.SetIsVisible(TempCommRewardView.PanelBtnClose, not CanContinuePurchase)
		UIUtil.SetIsVisible(TempCommRewardView.PanelBtnCheck, not CanContinuePurchase)
		TempCommRewardView.CommonPopUpBG:SetHideOnClick(CanContinuePurchase)
		TempCommRewardView = nil
	end, DelayTime, 0, 1, GoodsCfg)
	--- 刷新界面
	_G.StoreMysteryBoxVM:UpdateAfterBuy(BlindBoxID)
	_G.StoreMysteryBoxVM:InitMysterBoxData(self.MysteryboxData)
	UIViewMgr:HideView(UIViewID.StoreNewBuyWinPanel)
	self:SetMysteryBoxBoughtCount(BlindBoxID, DrawCount)
end

---@type 购买请求
---@param ID number 商品ID
---@param Count number 购买数量
function StoreMysteryBoxMgr:SendMsgBuyMysteryBox(ID)
	local MsgID = CS_CMD.CS_CMD_BLINDBOX
	local SubMsgID = MysteryBoxSubCmd.BUY
	local MsgBody = {}

	MsgBody.Cmd = SubMsgID
	MsgBody.BuyReq = {
		BlindBoxID = ID,
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	UIViewMgr:HideView(UIViewID.StoreNewBuyWinPanel)
end

function StoreMysteryBoxMgr:InitMsteryBoxData(IsCheckTimer)
	self.MysteryboxData = {}
	self.MysteryBoxUpTimerList = {}
	if IsCheckTimer then
		self:UnRegisterAllTimer()
	end

	local TempMysteryboxData = MysteryboxCfg:FindAllCfg()
	local IsNeedHideRedDot = true
	for _, Item in ipairs(TempMysteryboxData) do
		local TempItem = {}
		local TempItemCfg = table.deepcopy(Item)
		local TempLootCfg = CommercializationRandConsumeCfg:FindAllCfg(string.format("PoolID=%d", Item.PrizePoolID))[1]
		TempItemCfg.Price = {[1] = {ID = TempLootCfg.ConsumeResID, Count = TempLootCfg.ConsumeResNum[1]}}
		TempItemCfg.DisCountedPrice = TempLootCfg.ConsumeResNumAfterDiscount
		TempItemCfg.DiscountDurationStart = TempLootCfg.DiscountStartTime
		TempItemCfg.DiscountDurationEnd = TempLootCfg.DiscountEndTime
		TempItemCfg.Discount = TempLootCfg.DiscountValue
		TempItemCfg.Items = {}
		for i = 1, #Item.ItemID do
			local TempItemID = Item.ItemID[i]
			local TempCfg, Icon
			if Item.Type == ProtoRes.SpecialMysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE then
				TempCfg = HairUnlockCfg:FindCfgByID(TempItemID)
				if TempCfg ~= nil then
					Icon = self:GetHairIconByHairID(TempCfg.HairID)
					if TempCfg ~= nil and Icon ~= nil then
						table.insert(TempItemCfg.Items, {ID = TempCfg.UnlockItemID, Icon = Icon, EquipmentID = TempCfg.HairID, Part = ProtoCommon.equip_part.EQUIP_PART_BODY_HAIR, ItemType = ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_COIFFURE})
					end
				end
			else
				local Part = 0
				-- Item.Type == 坐骑涂装和时装，查物品表
				TempCfg = ItemCfg:FindCfgByKey(TempItemID)
				if TempCfg ~= nil then
					Icon = ItemCfg.GetIconPath(TempCfg.IconID)
					--- 时装的每个部位查物品表，预览坐骑时  部位不需要
					if Item.Type == ProtoRes.SpecialMysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_CLOTHING then
						local TempEquipCfg = EquipmentCfg:FindCfgByKey(TempCfg.EquipmentID)
						if TempEquipCfg ~= nil then
							Part = TempEquipCfg.Part
						end
					end
					table.insert(TempItemCfg.Items, {ID = TempItemID, Icon = Icon, EquipmentID = TempCfg.EquipmentID, Part = Part, ItemType = TempCfg.ItemType})
				end
			end
		end
		TempItem.Cfg = TempItemCfg
		TempItem.Counter = 0
		TempItem.RestrictionType = 0
		TempItem.RestrictionCount = 0
		if IsCheckTimer then
			self:CheckRegsterOnTimeTimer(TempItemCfg.ID, TempItemCfg.ListingTime)
			self:CheckRegsterOffTimeTimer(TempItemCfg.ID, TempItemCfg.RemovalTime)
			--- 检测折扣开始结束时间，注册事件   到时间刷新物品列表
			self:CheckRegsterOffTimeTimer(TempItemCfg.ID, TempItemCfg.DiscountDurationStart)
			self:CheckRegsterOffTimeTimer(TempItemCfg.ID, TempItemCfg.DiscountDurationEnd)
		end
		local IsEnable = self:IsCanShowMysteryBox(Item.ID)
		if IsEnable then
			table.insert(self.MysteryboxData, TempItem)
		end
		if self:GetServerRedDotData(Item.ID) == 1 and IsNeedHideRedDot then
			IsNeedHideRedDot = false
		end
	end
	table.sort(self.MysteryboxData, function(a, b) return a.Cfg.Sort < b.Cfg.Sort end)
	if IsNeedHideRedDot then
		_G.RedDotMgr:DelRedDotByID(19)
	end
	_G.StoreMysteryBoxVM:InitMysterBoxData(self.MysteryboxData)
end

function StoreMysteryBoxMgr:IsCanShowMysteryBox(MysteryBoxID)
	local MysteryBoxCfgData = MysteryboxCfg:FindCfgByKey(MysteryBoxID)
	if nil == MysteryBoxCfgData then
		return false
	end
	--- 测试代码
	-- local OnTime = "2025-07-08 18:20:00"
	-- local OffTime = "2026-05-01 00:00:00"
	-- local TimeData = {OnTime = OnTime, OffTime = OffTime}

	local TimeData = {OnTime = MysteryBoxCfgData.ListingTime, OffTime = MysteryBoxCfgData.RemovalTime}
	return self:CheckWorldID(MysteryBoxCfgData.ZoneBlackList) and self:CheckOnTimeLimit(TimeData)
		and _G.UE.UVersionMgr.IsBelowOrEqualGameVersion(MysteryBoxCfgData.OnVersion)
end

function StoreMysteryBoxMgr:OnShutdown()
	self.MysteryBoxRewardList = nil
	self.MysteryBoxBoughtCount = nil
end

function StoreMysteryBoxMgr:OnGameEventMajorCreate()
	self:OnInitData()
end

function StoreMysteryBoxMgr:OnModuleOpenNotify(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDMall then
		self:InitMsteryBoxData(true)
	end
end

function StoreMysteryBoxMgr:SetMysteryBoxBoughtCount(BlindBoxID, DrawCount)
	if self.MysteryBoxBoughtCount == nil then
		self.MysteryBoxBoughtCount = {}
	end
	if self.MysteryBoxBoughtCount[BlindBoxID] == nil then
		self.MysteryBoxBoughtCount[BlindBoxID] = 0
	end
	self.MysteryBoxBoughtCount[BlindBoxID] = DrawCount
	EventMgr:SendEvent(EventID.StoreUpdateBlindText, {BlindBoxID = BlindBoxID, DrawCount = DrawCount})
end

function StoreMysteryBoxMgr:GetMysteryBoxBoughtCountByID(BlindBoxID)
	if self.MysteryBoxBoughtCount == nil then
		self.MysteryBoxBoughtCount = {}
	end
	return self.MysteryBoxBoughtCount[BlindBoxID] or 0
end

function StoreMysteryBoxMgr:CheckTime(Time)
	local TempServerTime = TimeUtil:GetServerLogicTime()
	local TempTime = 0
	if Time ~= "" then
		local year, month, day, hour, min, sec = Time:match(TimePattern)
		local timestamp = os.time({ year = year, month = month, day = day, hour = hour, min = min, sec = sec})
		TempTime =  timestamp
	end
	return TempTime > TempServerTime, TempTime - TempServerTime
end

function StoreMysteryBoxMgr:GetTimeInfo(Time)
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

--- 检查盲盒是否已拥有
function StoreMysteryBoxMgr:CheckGoodsIsOwned(GoodsCfgData)
	local Items = GoodsCfgData.Items
	local bOwned = true
	if not table.is_nil_empty(Items) then
		for _, Item in ipairs(Items) do
			local ItemResID = Item.ID
			if ItemResID ~= 0 then -- 捆绑销售商品不检查已拥有
				if GoodsCfgData.GoodType == ProtoRes.SpecialMysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE then
					bOwned = self.CheckItemOwned(ItemResID) or _G.HaircutMgr.CheckHairUnlock(ItemResID)
				else
					bOwned = self.CheckItemOwned(ItemResID)
				end
				--- 有一个Item未拥有，即视为当前商品未拥有
				if not bOwned then
					break
				end
			end
		end
	end
	return bOwned
end

function StoreMysteryBoxMgr.CheckItemOwned(ItemID)
    local bIsInBag = _G.BagMgr:GetItemNum(ItemID) > 0 or _G.DepotVM:GetDepotItemNum(ItemID) > 0
		or _G.MailMgr:GetGiftMailIDByGoodID(ItemID) ~= nil
	local bIsActivated = ItemUtil.IsActivated(ItemID)
	return bIsInBag or bIsActivated
end

--- 上架事件
function StoreMysteryBoxMgr:CheckRegsterOnTimeTimer(ID, OnTime)
	--- 上架时间有可能在离线过程中，这里把所有没有取消过红点的物品都显示
	local TimeIsNeedTimer, DelayTime = self:CheckTime(OnTime)
	if DelayTime < 0 then DelayTime = 0 end
	if self:GetServerRedDotData(ID) ~= 0 then
		self.MysteryBoxDownTimerList[ID] = self:RegisterTimer(function()
			self:InitMsteryBoxData(false)
			_G.StoreMainVM:UpdateTabList()
			_G.EventMgr:SendEvent(_G.EventID.StoreUpdateTabListByTimer)
			self.RedDotPathList[ID] = _G.RedDotMgr:AddRedDotByParentRedDotID(19, ID, true)
			-- _G.EventMgr:SendEvent(_G.EventID.StoreMysteryBoxRedDotEvent, ID)
		end, DelayTime, 0, 1)
	end
end

--- 下架事件
function StoreMysteryBoxMgr:CheckRegsterOffTimeTimer(ID, OffTime)
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

function StoreMysteryBoxMgr:ChangeRedDotState(Index, IsShow)
	self.MasteryBoxServerUpValue[Index] = IsShow
	_G.ClientSetupMgr:SendSetReq(ClientSetupID.StoreMasteryBoxReddot, _G.TableTools.table_to_string(self.MasteryBoxServerUpValue))
end

--- 获取保存在服务器的红点数据，返回0就视为点过红点 就不再显示了，其他值都需要显示
function StoreMysteryBoxMgr:GetServerRedDotData(ID)
	if table.is_nil_empty(self.MasteryBoxServerUpValue) or self.MasteryBoxServerUpValue[ID] == nil then
		local TempServerRedDotData = _G.ClientSetupMgr:GetSetupValue(MajorUtil.GetMajorRoleID(), ClientSetupID.StoreMasteryBoxReddot)
		self.MasteryBoxServerUpValue = {}
		if TempServerRedDotData ~= nil then
			self.MasteryBoxServerUpValue = FuncStringToTable(TempServerRedDotData)
		end
	end
	return self.MasteryBoxServerUpValue[ID] == 0 and 0 or 1
end

--- 检查当前大区是否在生效范围内
function StoreMysteryBoxMgr:CheckWorldID(DisabledWorldIds)
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

function StoreMysteryBoxMgr:CheckOnTimeLimit(ItemDate)
	local TempServerTime = TimeUtil:GetServerLogicTime()
	local OnTime = ItemDate.OnTime
	local OffTime = ItemDate.OffTime
	if OnTime == "" or OffTime == "" then
		return true
	end
	local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
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
	if TampOnTime <= TempServerTime and TempServerTime < TampOffTime then
		return true

	end
	return false
end

function StoreMysteryBoxMgr:GetHairIconByHairID(HairID)
	local RaceID = MajorUtil.GetMajorRaceID()
	local RoleID = MajorUtil.GetMajorRoleID()
	local RoleVM, IsValid = _G.RoleInfoMgr:FindRoleVM(RoleID, true)
	local TempHairCfg = HairCfg:FindAllCfg(string.format("RaceID=%d AND Tribe=%d AND Gender=%d AND HaircutType=%d", RaceID, RoleVM.Tribe, RoleVM.Gender, HairID))
	if TempHairCfg == nil or TempHairCfg[1] == nil then
		FLOG_ERROR("StoreMysteryBoxMgr  ItemType is hair, But TempHairCfg is nil")
		return ""
	end
	return TempHairCfg[1].IconPath
end

function StoreMysteryBoxMgr:GetItemCfgIconByResID(ResID)
	local TempCfg = ItemCfg:FindCfgByKey(ResID)
	if TempCfg ~= nil then
		return ItemCfg.GetIconPath(TempCfg.IconID)
	end
end

function StoreMysteryBoxMgr:GetMysteryBoxDataByID(BlindBoxID)
	for _, value in ipairs(self.MysteryboxData) do
		if value.Cfg.ID == BlindBoxID then
			return value.Cfg
		end
	end
end

function StoreMysteryBoxMgr:GetMysteryBoxTabIsEnable()
	--- 盲盒不能赠送
	if _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Gift then
		return false
	end
	--- 有数据就显示，如果不在上架时间内，MysteryboxData就没有数据
	return not table.is_nil_empty(self.MysteryboxData)
end

function StoreMysteryBoxMgr:GetMysteryBoxData()
	return self.MysteryboxData
end

function StoreMysteryBoxMgr:GetItemCfg(ID)
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
	}
	return ItemData
end

function StoreMysteryBoxMgr:GetHairCfg(ID)
	local TempHairCfg = HairUnlockCfg:FindCfgByID(ID)
	if TempHairCfg == nil then
		return
	end
	
	return self:GetItemCfg(TempHairCfg.UnlockItemID)
end

function StoreMysteryBoxMgr:GetCustomMadeIDByResID(ResID)
	if ResID == nil then return end
	local TempMountCustomCfg = MountCustomCfg:FindAllCfg(string.format("ItemID==%d", ResID))

	if TempMountCustomCfg ~= nil and TempMountCustomCfg[1] ~= nil then
		return TempMountCustomCfg[1].ID
	end
end

function StoreMysteryBoxMgr:GetTimeLimit(Time)
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

---@type 是否持有足够的货币单件购买
function StoreMysteryBoxMgr:OwnedEnoughCurrency(GoodsCfgData)
	if GoodsCfgData == nil then
		return
	end
	local PriceData = GoodsCfgData.Price[1]
	local Price = _G.StoreMysteryBoxVM.CurrentPrice
	if PriceData and Price then
		local ScoreValue = ScoreMgr:GetScoreValueByID(PriceData.ID)
		if ScoreValue < Price then
			local TempScoreCfg = ScoreCfg:FindCfgByKey(PriceData.ID)
			if TempScoreCfg == nil then
				return
			end
			local ScroeName = TempScoreCfg.NameText
			_G.StoreMgr:OnCheckCmmMsgBoxIsShow()
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
			UIViewMgr:HideView(UIViewID.StoreBlindBoxBuyWinPanel)
			self:SendMsgBuyMysteryBox(_G.StoreMysteryBoxVM.CurBlindBoxID)
		end
	else
		MsgTipsUtil.ShowTipsByID(StoreDefine.BuyError)
	end
end

--- 检查购买前置条件，解锁某个坐骑等
function StoreMysteryBoxMgr:CheckBuyCond(CurBoxCfgData)
	
	if CurBoxCfgData == nil then
		return
	end
	local CondType = CurBoxCfgData.BuyCondType
	local CondValue = CurBoxCfgData.BuyCondParam
	local TipsText = CurBoxCfgData.CannotBuyTipText
	local JumpValue = CurBoxCfgData.JumpID
	local BuyCond = false
	if CondType == nil or CondType == ProtoRes.MysteryBoxBuyCondType.MYSTERYBOX_BUYCONDTYPE_NONE or CondValue == nil or CondValue == ProtoRes.MysteryBoxBuyCondType.MYSTERYBOX_BUYCONDTYPE_NONE then
		BuyCond = true
	end
	--- 激活指定坐骑--- 改为查条件表
	if CondType == ProtoRes.MysteryBoxBuyCondType.MYSTERYBOX_BUYCONDTYPE_CONDCFG then
		BuyCond = ConditionMgr:CheckConditionByID(CondValue)
		--- 坐骑不满足购买条件时，可能在背包里没激活这里判断一下，如果真的在背包，就弹个Tips
		if not BuyCond then
			--- 进来这里证明没有解锁坐骑
			local RequiredItemID = CurBoxCfgData.RequiredItemID
			if _G.BagMgr:GetItemNum(RequiredItemID) > 0 then

				return 	_G.MsgTipsUtil.ShowTipsByID(CurBoxCfgData.TipsID)
			end
		end
	end

	--- 满足条件就直接判断货币
	if BuyCond then
		return true
	else
		--- 不满足条件弹提示，然后跳转
		MsgBoxUtil.ShowMsgBoxTwoOp(
			self,
			--- 购买提示
			LSTR(950094),
			TipsText,
			function()
				_G.StoreMgr:JumpToGoods(nil, JumpValue, true)
			end
		)
	end

end

return StoreMysteryBoxMgr
