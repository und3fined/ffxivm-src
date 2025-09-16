--
-- Author: ZhengJianChuan
-- Date: 2024-02-22 16:38
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local UIBindableList = require("UI/UIBindableList")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local WardrobeTipsItemVM = require("Game/Wardrobe/VM/Item/WardrobeTipsItemVM")
local WardrobePositionItemVM = require("Game/Wardrobe/VM/Item/WardrobePositionItemVM")
local WardrobePageTabItemVM = require("Game/Wardrobe/VM/Item/WardrobePageTabItemVM")
local WardrobeEquipmentSlotItemVM = require("Game/Wardrobe/VM/Item/WardrobeEquipmentSlotItemVM")
local WardrobeJumpItemVM = require("Game/Wardrobe/VM/Item/WardrobeJumpItemVM")
local WardrobeBagSlotItemVM = require("Game/Wardrobe/VM/Item/WardrobeBagSlotItemVM")
local AchievementCfg = require("TableCfg/AchievementCfg")
local ClosetClassifyCfg = require("TableCfg/ClosetClassifyCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ClosetSuitCfg = require("TableCfg/ClosetSuitCfg")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local BagMgr = require("Game/Bag/BagMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ItemUtil = require("Utils/ItemUtil")
local CommonUtil = require("Utils/CommonUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local TimeUtil = require("Utils/TimeUtil")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local ProfMgr = require("Game/Profession/ProfMgr")
local SettingsTabRole = nil

local WarningColor = "#dc5868ff"
local NormalColor = "#D5D5D5FF"

local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local EquipmentPartList = ProtoCommon.equip_part

---@class WardrobeMainPanelVM : UIViewModel
local WardrobeMainPanelVM = LuaClass(UIViewModel)

---Ctor
function WardrobeMainPanelVM:Ctor()
	--列表
	self.AppearanceTabList = UIBindableList.New(WardrobePositionItemVM)
	self.AppearanceSecTabList = UIBindableList.New(WardrobePageTabItemVM)
	self.AppearanceList = UIBindableList.New(WardrobeEquipmentSlotItemVM)
	self.AchievementList = UIBindableList.New(WardrobeJumpItemVM)

	--按钮控件
	self.BtnHandChecked = true
	self.BtnHatChecked = true
	self.BtnHatStyleChecked = false
	self.BtnPoseChecked = false
	self.BtnHatStyleVisible = false
	self.BtnSuitSwitchChecked = false

	self.BtnSuitVisible = nil

	self.AppearanceTabText = ""
	self.CharmNumText = ""
	self.AppearanceName = ""
	self.PanelNameVisible = true
	self.PanelStainVisible = true
	self.PanelUnStainVisible = false
	self.PanelCanStainVisible = false
	self.PanelReduceVisible = false
	self.JobBoxVisible = false
	self.UnlockBoxVisible = false
	self.ReduceCondVisible = false
	self.PanelBtnVisible = nil
	self.QuickUnlockVisible = true
	self.BagSlotItemVM1 = WardrobeBagSlotItemVM.New()
	self.BagSlotItemVM2 = WardrobeBagSlotItemVM.New()
	--self.TipsVM = WardrobeTipsItemVM.New()
	self.GenderCondText = ""
	self.ProfCondText = ""	
	self.ProfLevelText = 0
	self.RaceCondText = 0
	self.UnlockVisible = false
	self.GenderCondColor = NormalColor
	self.ProfCondColor = NormalColor
	self.ProfLevelColor = NormalColor
	self.RaceCondColor = NormalColor
	self.BagSlot2Visible = false
	self.BagSlot1Visible = false
	self.BtnUnlockEnable = true
	self.BtnUnlockText = ""
	self.StainText = ""
	self.StainTextColor = NormalColor
	self.IsSearching = false
	self.BtnScreenerVisible = true
	self.EmptyVisible = false
	self.SearchTempList = {}
	self.EmptyText = ""
	self.DetailProfVisible = false
	self.UnlockTextVisible = true
	self.CharmEffVisible = false
	self.BtnCameraChecked = false

	self.CurAppUnlockedVisible = false
	self.CurAppUnlockCondition = ""
	self.CurAppUnlockLevelConditon = nil
	self.CurAppUnlockProfCondVisible = nil
	self.CurAppUnlockGenderCondVisible = nil
	self.CurAppUnlockRaceCondVisible = nil
	self.CurAppUnlockConditionVisible = nil

	-- 数据缓存
	self.AppearanceDataList = {}
	self.FavoriteVisibleData = {}
end

function WardrobeMainPanelVM:OnInit()
end

function WardrobeMainPanelVM:OnBegin()
	SettingsTabRole = require("Game/Settings/SettingsTabRole")
end

function WardrobeMainPanelVM:OnEnd()
end

function WardrobeMainPanelVM:OnShutdown()
end

function WardrobeMainPanelVM:GetAppearanceDataList(PartID)
	if self.AppearanceDataList[PartID] ~= nil then
		return self.AppearanceDataList[PartID]
	end

	self.AppearanceDataList[PartID] = {}
	local TempCacheList= {}

	--从装备里外观ID，然后按照EquipmentCfg的部位
	local AppList = EquipmentCfg:FindAllAppearanceIDByPart(PartID)

	local ServerTime = TimeUtil.GetServerLogicTime()
	for _, cfg in ipairs(AppList) do
		local Cfg = ClosetCfg:FindCfgByKey(cfg.AppearanceID)
		if Cfg ~= nil then
			if TempCacheList[cfg.AppearanceID] == nil then
				if Cfg.UpTime == ""  then
					table.insert(self.AppearanceDataList[PartID], Cfg)
					TempCacheList[cfg.AppearanceID] = 1
				else
					local AppTime = TimeUtil.GetTimeFromString(Cfg.UpTime)
					if  ServerTime >= AppTime and AppTime > 0 then
						table.insert(self.AppearanceDataList[PartID], Cfg)
						TempCacheList[cfg.AppearanceID] = 1
					end
				end
			end
		end
	end

	return self.AppearanceDataList[PartID]
end

function WardrobeMainPanelVM:InitFavoriteData()
	self.FavoriteVisibleData = {}
	local Cfg = ClosetCfg:FindAllCfg()
	for i, v in ipairs(Cfg) do
		self.FavoriteVisibleData[v.ID] = WardrobeMgr:GetIsFavorite(v.ID)
	end
end

--- 初始化左边菜单栏
function WardrobeMainPanelVM:InitAppearanceTabList()
	local _ <close> = CommonUtil.MakeProfileTag("InitAppearanceTabList")
	self.AppearanceTabList:Clear()
	local TabList = {}
	for _, partID in ipairs(WardrobeDefine.EquipmentTab) do
		local Cfg = ClosetClassifyCfg:FindCfgByKey(partID)
		if Cfg ~= nil then
			local AppearanceID = WardrobeMgr:GetEquipPartAppearanceID(partID)
			local Data = {}
			Data.ID = partID
			Data.PositionIcon = Cfg.Icon
			Data.PositionSelectIcon = Cfg.SelectIcon
			Data.StateIcon = AppearanceID ~= 0 and WardrobeUtil.GetEquipmentAppearanceIcon(AppearanceID) or ""
			local IsUnlock =  WardrobeMgr:GetIsUnlock(AppearanceID) 
			Data.StainTagVisible = IsUnlock and (WardrobeMgr:GetDyeEnable(AppearanceID) or WardrobeMgr:GetEquipPartCanDyeColor(partID)) or false
			Data.StainColorVisible = WardrobeMgr:GetIsDye(AppearanceID)
			table.insert(TabList, Data)
		end
	end

	self.AppearanceTabList:UpdateByValues(TabList)
	
end

--- 更新左边菜单栏
function WardrobeMainPanelVM:UpdateAppearanceTabList()
	local _ <close> = CommonUtil.MakeProfileTag("UpdateAppearanceTabList")
	for i = 1, self.AppearanceTabList:Length() do
		local ItemVM = self.AppearanceTabList:Get(i)
		local PartID = ItemVM.ID
		local Cfg = ClosetClassifyCfg:FindCfgByKey(PartID)
		if Cfg ~= nil then
			local AppearanceID = WardrobeMgr:GetEquipPartAppearanceID(PartID)
			local Data = {}
			Data.ID = PartID
			Data.PositionIcon = Cfg.Icon
			Data.PositionSelectIcon = Cfg.SelectIcon
			Data.StateIcon = AppearanceID ~= 0 and WardrobeUtil.GetEquipmentAppearanceIcon(AppearanceID) or ""
			local IsUnlock =  WardrobeMgr:GetIsUnlock(AppearanceID) 
			Data.StainTagVisible =  IsUnlock and (WardrobeMgr:GetDyeEnable(AppearanceID) or WardrobeMgr:GetEquipPartCanDyeColor(PartID)) or false
			Data.StainColorVisible = WardrobeMgr:GetIsDye(AppearanceID)
			ItemVM:UpdateVM(Data)
		end
	end
end

--- 更新外观装备二级菜单
function WardrobeMainPanelVM:UpdateAppearanceSecTabList(Index)
	local _ <close> = CommonUtil.MakeProfileTag("UpdateAppearanceSecTabList")
	self.AppearanceSecTabList:Clear()

	local SubTabList = {}
	local Cfg = ClosetClassifyCfg:FindCfgByKey(Index)
	local Data = {}
	Data.TabName = _G.LSTR(1080037)
	Data.ID = 0
	table.insert(SubTabList, Data)

	if Cfg and not table.is_nil_empty(Cfg.SubID) then
		for _, SubName in ipairs(Cfg.SubID) do
			if not string.isnilorempty(SubName) then
				local Data = {}
				Data.TabName = SubName
				table.insert(SubTabList, Data)
			end
		end
	end

	self.AppearanceSecTabList:UpdateByValues(SubTabList)

end

function WardrobeMainPanelVM:GetAppearanceDataListByPartAndSubID(PartID, PartSubName)
	local PartIDList = self:GetAppearanceDataList(PartID)
	local RetList = {}
	for _, cfg in ipairs(PartIDList) do
		if cfg.PartSubID == PartSubName then
			table.insert(RetList, cfg)
		end
	end
	return RetList
end

local function CheckProfLimitAndClassLimit(Item, CheckList)
	if Item == nil then
		return false
	end

	if (table.is_nil_empty(Item.ProfLimit) or Item.ProfLimit[1] == 0) and (table.is_nil_empty(Item.ClassLimits) or Item.ClassLimits[1] == 0 ) then
        return _G.LSTR(1080016)
    end
	-- local NotHaveProfLimit = table.is_nil_empty(Item.ProfLimit) or (Item.ProfLimit[1] and Item.ProfLimit[1] == 0)

	for __, vv in ipairs(Item.ProfLimit) do
		for i, v in ipairs(CheckList) do
			if v == vv then
				return true
			end
		end
	end
	for __, class in ipairs(Item.ClassLimits) do
		for i, prof in ipairs(CheckList) do
			if ProfMgr.CheckProfClass(prof, class) then
				return true
			end
		end
	end

	return false
end

local function GetDataByFilterIndex(FilterIndex, DataList)
	local FilterProfList = WardrobeDefine.FilterProfList 
	if FilterIndex and FilterIndex ~= 0 then
		local Condition = FilterProfList[FilterIndex]

		local IsAll = Condition.ProfID == -1 and  Condition.ClassType == WardrobeDefine.ProfClass.ClassType
		if IsAll then
			return DataList
		end

		local FilterList = {}
		for i = 1, #DataList do
			local ItemVM = DataList[i]
			local ID = ItemVM.ID
			local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ID) or {}
			local RealData = WardrobeMgr:GetUnlockAppearanceDataByID(ID) or {}
			local EquipmentConditionData = {}
			if WardrobeUtil.GetIsSpecial(ID) then
				table.insert(EquipmentConditionData, {ID = WardrobeUtil.GetUnlockCostItemID(ID)})
			else
				EquipmentConditionData = EquipmentCfgs
			end

			local CheckList = {} --- checklist为空时 视为不限职业

			if Condition.ProfID == 0 and Condition.ClassType == WardrobeDefine.ProfClass.ClassType then
				CheckList = {}
			else
				if Condition.ClassType == WardrobeDefine.ProfClass.ClassType then
					local ClassData = WardrobeUtil.GetClassTypeData()
					CheckList = ClassData[Condition.ProfID] or {}
				elseif Condition.ClassType == WardrobeDefine.ProfClass.BasicType then
					CheckList = {[1] = Condition.ProfID}
				elseif Condition.ClassType == WardrobeDefine.ProfClass.AdvanceType then
					local ProfCfg = RoleInitCfg:FindCfgByKey(Condition.ProfID)
					if ProfCfg ~= nil then
						local AdvanceProf = ProfCfg.AdvancedProf
						CheckList = {[1] = Condition.ProfID, [2]= AdvanceProf}
					end
				end
			end

			local CheckTag = false
			local CheckNum = 0

			if not table.is_nil_empty(RealData) then
				local Item = {
					ProfLimit = RealData.ProfLimits,
					ClassLimits = RealData.ClassLimits,
				}

				local IsCanInsert, UnlimitNum = CheckProfLimitAndClassLimit(Item, CheckList)
				if not FilterList[ID] and IsCanInsert then
					CheckTag = true
					CheckNum = CheckNum + (UnlimitNum or 0)
				end
			else
				for _, v in ipairs(EquipmentConditionData) do
					local Item  = ItemCfg:FindCfgByKey(v.ID)
					if Item and not FilterList[ID] then
						Item.ClassLimits = {Item.ClassLimit}
						local IsCanInsert, UnlimitNum = CheckProfLimitAndClassLimit(Item, CheckList)
						if IsCanInsert then
							CheckTag = true
							CheckNum = CheckNum + (UnlimitNum or 0)
						end
					end
				end
			end

			local IsIncludeUnlimit = Condition.ClassType == WardrobeDefine.ProfClass.BasicType or Condition.ClassType == WardrobeDefine.ProfClass.AdvanceType
			local OriginEquipmenNum = table.is_nil_empty(RealData) and #EquipmentConditionData or 1
			if CheckTag then
				if next(CheckList) then
					if CheckNum ~= OriginEquipmenNum or IsIncludeUnlimit then
						FilterList[ID] = ItemVM
					end
				else
					if CheckNum == OriginEquipmenNum then
						FilterList[ID] = ItemVM
					end
				end
			end
		end
	
		local TempList = {}
		for k, v in pairs(FilterList) do
			table.insert(TempList, v)
		end

		DataList = TempList
	end

	return DataList
end

local function GetFilterInfo(ScreenerList)
	local FilterInfo = {}
	if ScreenerList and next(ScreenerList) then
		FilterInfo.SelectedFilterUnlock = nil
    	FilterInfo.SelectedFilterRaceList = nil
    	FilterInfo.SelectedFilterGender = nil
		FilterInfo.SelectedFilterStain = nil
		FilterInfo.SelectedFilterLevelList = {}
		for i = 1, #ScreenerList do
			local ScreenerData = ScreenerList[i]
			if ScreenerList[i].ScreenerID == 30 then
				local CondStrList = ScreenerData.FilterAnd
				if CondStrList and #CondStrList > 0 then
					if #CondStrList == 2 then
						local MinLevelCon = string.split(CondStrList[1],">=")
						local MaxLevelCon = string.split(CondStrList[2], "<=")

						local Len = table.length(FilterInfo.SelectedFilterLevelList)
						if FilterInfo.SelectedFilterLevelList[Len + 1] == nil then
							FilterInfo.SelectedFilterLevelList[Len + 1] = {}
						end

						FilterInfo.SelectedFilterLevelList[Len + 1].MinLevel = tonumber(MinLevelCon[2])
						FilterInfo.SelectedFilterLevelList[Len + 1].MaxLevel = tonumber(MaxLevelCon[2])

					end
				end
			else
				local CondStrList = ScreenerData.FilterAnd
				if CondStrList and #CondStrList > 0 then
					for _, CondStr in ipairs(CondStrList) do
						local CondList = string.split(CondStr,"==")
						if CondList and #CondList == 2 then
							local Key = CondList[1]
							local Value = tonumber(CondList[2])
							if Key == "Lock " then
								FilterInfo.SelectedFilterLock = Value
							elseif Key == "Gender " then
								FilterInfo.SelectedFilterGender = Value
							elseif Key == "Race " then
								FilterInfo.SelectedFilterRaceList = Value
							elseif Key == "Stain " then
								FilterInfo.SelectedFilterStain = Value
							end
						end
					end
				end
			end
		end
	end

	return FilterInfo
end

local function GetDataByFilterInfo(DataList, FilterInfo)
	local UnlockDataList = {}
	local RaceDataList = {}
	local LevelDataList = {}
	local GenderDataList = {}
	local StainDataList = {}

	-- 染色
	if FilterInfo ~= nil and FilterInfo.SelectedFilterStain ~= nil then
		local FilterCondition
		if FilterInfo.SelectedFilterStain == 1 then
			FilterCondition = function(item) return WardrobeMgr:GetDyeEnable(item.ID) end
		else
			FilterCondition = function(item) return not WardrobeMgr:GetDyeEnable(item.ID) end
		end
		for i = 1, #DataList do
			local item = DataList[i]
			if FilterCondition(item) then
				StainDataList[#StainDataList+1] = item
			end
		end
		if #StainDataList >= 0 then
			DataList = StainDataList
		end
	end

	--解锁状态
	if FilterInfo ~= nil and FilterInfo.SelectedFilterLock ~= nil then
		local FilterCondition
		if FilterInfo.SelectedFilterLock == 0 then
			FilterCondition = function(item) return  WardrobeMgr:GetIsUnlock(item.ID) end
		elseif FilterInfo.SelectedFilterLock == 1 then
			FilterCondition = function(item) return not WardrobeMgr:GetIsUnlock(item.ID) end
		end
		for i = 1, #DataList do
			local item = DataList[i]
			if FilterCondition(item) then
				UnlockDataList[#UnlockDataList+1] = item
			end
		end
		if #UnlockDataList >= 0 then
			DataList = UnlockDataList
		end
	end

	--种族
	if FilterInfo ~= nil and FilterInfo.SelectedFilterRaceList ~= nil then
		for _, value in ipairs(DataList) do
			if FilterInfo.SelectedFilterRaceList then
				if WardrobeMgr:GetIsUnlock(value.ID) then
					local Data = WardrobeMgr:GetUnlockAppearanceDataByID(value.ID)
					local Race = WardrobeMgr:GetRaceLimit(Data)
					if Race == FilterInfo.SelectedFilterRaceList or Race == 0 then
						table.insert(RaceDataList, value)
					end
				else
					local ClientData = WardrobeMgr:GetAppearanceClientData(value.ID)
					if ClientData ~= nil then
						local RaceLimit = ClientData.RaceLimit
						local Race = RaceLimit == 0 and ProtoCommon.race_type.RACE_TYPE_NULL or RaceLimit
						if Race == FilterInfo.SelectedFilterRaceList or Race == 0 then
							table.insert(RaceDataList, value)
						end
					end
				end
			end
		end

		if #RaceDataList >= 0 then
			DataList = RaceDataList
		end
	end

	-- 性别
	if FilterInfo ~= nil and FilterInfo.SelectedFilterGender ~= nil then
		for _, value in ipairs(DataList) do
			if FilterInfo.SelectedFilterGender then
				if WardrobeMgr:GetIsUnlock(value.ID) then
					local Data = WardrobeMgr:GetUnlockAppearanceDataByID(value.ID)
					if Data.GenderLimit == FilterInfo.SelectedFilterGender or Data.GenderLimit == 0 or Data.GenderLimit == 3 then
						table.insert(GenderDataList, value)
					end
				else
					local ClientData = WardrobeMgr:GetAppearanceClientData(value.ID)
					if ClientData ~= nil then
						local GenderLimit = ClientData.GenderLimit
						if GenderLimit == FilterInfo.SelectedFilterGender or GenderLimit == 0 then
							table.insert(GenderDataList, value)
						end
					end
				end
			end
		end

		if #GenderDataList >= 0 then
			DataList = GenderDataList
		end
	end

	if FilterInfo ~= nil and FilterInfo.SelectedFilterLevelList ~= nil then
		for _, v in ipairs(FilterInfo.SelectedFilterLevelList) do
			for _, value in ipairs(DataList) do
				local Level
				if WardrobeMgr:GetIsUnlock(value.ID) then
					local Data = WardrobeMgr:GetUnlockAppearanceDataByID(value.ID)
					Level = Data.LevelLimit
				else
					local ClientData = WardrobeMgr:GetAppearanceClientData(value.ID)
					if ClientData ~= nil then
						Level = ClientData.LevelLimit
					end
				end
				
				if Level ~= nil and Level >= v.MinLevel and Level <= v.MaxLevel then
					table.insert(LevelDataList, value)
				end
			end
		end

		if not table.empty(FilterInfo.SelectedFilterLevelList) and #LevelDataList >= 0 then
			DataList = LevelDataList
		end
	end

	return DataList
end

---@param number PartID 部位ID
---@param string PartSubName 分类字符串
---@param number FilterIndex 职业筛选ID
function WardrobeMainPanelVM:UpdateAppearanceList(PartID, PartSubName, FilterIndex, ScreenerList)
	local _ <close> = CommonUtil.MakeProfileTag("UpdateAppearanceList")
	self.AppearanceList:Clear()
	self.AppearanceList:UpdateByValues({})
	local DataList = {}
	--右手指 == 左手指
	self.PartID = PartID
	if PartID == EquipmentPartList.EQUIP_PART_RIGHT_FINGER or PartID == EquipmentPartList.EQUIP_PART_LEFT_FINGER then
		PartID = EquipmentPartList.EQUIP_PART_FINGER
	end

	local Cfg = (PartSubName == _G.LSTR(1080037)) and self:GetAppearanceDataList(PartID) or self:GetAppearanceDataListByPartAndSubID(PartID, PartSubName)
	for _, v in ipairs(Cfg) do
		local Data = self:CreateAppearanceItem(v.ID, WardrobeUtil.GetEquipmentAppearanceName(v.ID), self.PartID)
		table.insert(DataList, Data)
	end

	if FilterIndex then
		DataList = GetDataByFilterIndex(FilterIndex, DataList)
	end

	local FilterInfo = GetFilterInfo(ScreenerList)
	if next(FilterInfo) then
		DataList = GetDataByFilterInfo(DataList, FilterInfo)
	end

	table.sort(DataList, self.AppearanceSortFunction)
	self.AppearanceList:UpdateByValues(DataList)

	-- 如果有穿戴的就穿戴，否则不选择
	self:SelectClothingViewSuit(PartID)
	self.EmptyVisible = #DataList == 0
	self.PanelNameVisible = not #DataList == 0
end

function WardrobeMainPanelVM:SelectClothingViewSuit(PartID)
	local PartViewSuitID = WardrobeMgr:GetClothingViewSuit(PartID)
	if PartViewSuitID then
		for i = 1, self.AppearanceList:Length() do
			local TempAppearanceItem = self.AppearanceList:Get(i)
			if TempAppearanceItem and TempAppearanceItem.ID == PartViewSuitID then
				TempAppearanceItem.IsSelected = true
			end
		end
	end
end

--- 更新外观表Item的状态
function WardrobeMainPanelVM:UpdateAppearanceListState(PartID)
	for i = 1, self.AppearanceList:Length() do
		local ItemVM = self.AppearanceList:Get(i)
		local AppearanceID = ItemVM.ID
		local Data = self:CreateAppearanceItem(AppearanceID, ItemVM.ItemName, PartID)
		ItemVM:UpdateVM(Data)
	end
end

--- 创建新的外观ItemVM
function WardrobeMainPanelVM:CreateAppearanceItem(AppearanceID, AppearanceName, PartID)
	local _ <close> = CommonUtil.MakeProfileTag("CreateAppearanceItem")
	local Data = {}
	Data.ID = AppearanceID
	Data.PartID = PartID
	local CanUnlock = WardrobeUtil.GetIsBagOwnAppearanceEquipment(AppearanceID)
	local IsUnlock =  WardrobeMgr:GetIsUnlock(AppearanceID)
	local UnlockVisible
	local CanUnlockVisible
	if IsUnlock then
		UnlockVisible = IsUnlock
		CanUnlockVisible = false
	else
		CanUnlockVisible = CanUnlock
		UnlockVisible = CanUnlock or IsUnlock
	end
	Data.UnlockVisible = UnlockVisible
	Data.CanUnlockVisible = CanUnlockVisible
	Data.CheckVisible = WardrobeMgr:GetIsClothing(AppearanceID, PartID)
	Data.FavoriteVisibleForSort = self.FavoriteVisibleData[AppearanceID] or false
	Data.FavoriteVisible = WardrobeMgr:GetIsFavorite(AppearanceID)
	Data.CanEquip = WardrobeMgr:CanEquipAppearance(AppearanceID)

	Data.StainTagVisible = WardrobeMgr:GetDyeEnable(AppearanceID)
	Data.StainColorVisible = WardrobeMgr:GetIsDye(AppearanceID)

	Data.EquipmentIcon = WardrobeUtil.GetEquipmentAppearanceIcon(AppearanceID)
	Data.ItemName = WardrobeUtil.GetEquipmentAppearanceName(AppearanceID)
	Data.IsSelected = false
	return Data
end

---@param ApperanceID 外观ID 更新选中的外观信息
function WardrobeMainPanelVM:UpdateCurrentAppearanceInfo(ApperanceID)

	local IsUnlock = WardrobeMgr:GetIsUnlock(ApperanceID) 

	self.AppearanceName = WardrobeUtil.GetEquipmentAppearanceName(ApperanceID)
	self.UnlockVisible = not IsUnlock
	self.UnlockBoxVisible = not IsUnlock
	self.UnlockTextVisible = not IsUnlock
	self.JobBoxVisible = IsUnlock

	self.CurAppUnlockedVisible = IsUnlock

	self.BagSlot1Visible = false
	self.BagSlot2Visible = false
	self.AchievementList:Clear()

	if IsUnlock then
		self.CurAppUnlockConditionVisible = true
		local Data = WardrobeMgr:GetUnlockAppearanceDataByID(ApperanceID)
		if Data ~= nil then
			local ProfLimit = WardrobeMgr:GetProfLimit(Data)
			local RaceLimit = WardrobeMgr:GetRaceLimit(Data)
			local LevelLmit = WardrobeMgr:GetLevelLimit(Data)
			local GenderLimit = WardrobeMgr:GetGenderLimit(Data)
			local ClassLimit = WardrobeMgr:GetClassLimits(Data)

			self.GenderCondText = WardrobeUtil.GetGenderCondText(GenderLimit)
			self.ProfLevelText = WardrobeUtil.GetLevelCondText(LevelLmit)
			self.ProfCondText = WardrobeUtil.GetSimpleProfCondText(ProfLimit, ClassLimit)
			self.RaceCondText = WardrobeUtil.GetRaceCondText(RaceLimit)

			local GenderCond = WardrobeUtil.JudgeGenderCond(GenderLimit)
			local LevelCond = WardrobeUtil.JudgeLevelCond(LevelLmit)
			local ProfCond = WardrobeUtil.JudgeProfCond(ProfLimit, ClassLimit)
			local RaceCond = WardrobeUtil.JudgeRaceCond(RaceLimit) 

			self.GenderCondColor =  GenderCond and NormalColor or WarningColor
			self.ProfLevelColor = LevelCond and NormalColor or WarningColor
			self.ProfCondColor = ProfCond and NormalColor or WarningColor
			self.RaceCondColor = RaceCond and NormalColor or WarningColor

			self.CurAppUnlockLevelConditon = not LevelCond
			self.CurAppUnlockProfCondVisible = not ProfCond
			self.CurAppUnlockGenderCondVisible = not GenderCond
			self.CurAppUnlockRaceCondVisible = not RaceCond

			local CanEquip =  WardrobeMgr:CanEquipedAppearanceByServerData(ApperanceID)
			if not CanEquip then
				self.DetailProfVisible = true
			else
				self.DetailProfVisible = WardrobeUtil.GetDetailProfVisible(ProfLimit, ClassLimit) 
			end  
		end
	else
		-- 未解锁
		local IsSpecial =  WardrobeUtil.GetIsSpecial(ApperanceID)
		local ItemValue1 = {}
		ItemValue1.Name = LSTR(1080059)
		local ItemNum = BagMgr:GetItemNum(WardrobeUtil.GetUnlockCostItemID(ApperanceID))
		local Str = RichTextUtil.GetText(string.format("%d", ItemNum), "#DC5868FF")
		ItemValue1.Num =  string.format("%s/%d", ItemNum >= WardrobeUtil.GetUnlockCostItemNum(ApperanceID) and tostring(ItemNum) or Str,  WardrobeUtil.GetUnlockCostItemNum(ApperanceID) )
		ItemValue1.Item = WardrobeUtil.GetUnlockCostItemID(ApperanceID) 
		self.BagSlotItemVM1:UpdateVM(ItemValue1)
		self.BagSlot1Visible = not IsSpecial

		local AchievementIDList = WardrobeUtil.GetAchievementIDList(ApperanceID)
		local IsAchievementEquip = not table.is_nil_empty(AchievementIDList)
		self.BagSlot2Visible = not IsAchievementEquip

		if IsAchievementEquip then
			--传奇武器
			local ItemList = {}
			for index, id in ipairs(AchievementIDList) do
				local ACfg = AchievementCfg:FindCfgByKey(id)
				if ACfg ~= nil then
					local Name = AchievementUtil.GetAchievementName(id)
					local Item = {
						ID = id,
						Name =  Name,
						ItemID = WardrobeUtil.GetUnlockCostItemID(ApperanceID),
						Index = index,
					}
					if Name ~= "" then
						table.insert(ItemList,Item)
					end
				end
			end
			self.AchievementList:UpdateByValues(ItemList)
		else
			local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ApperanceID)
			local ItemNum = 0
			if IsSpecial then
				ItemNum = BagMgr:GetItemNum(WardrobeUtil.GetUnlockCostItemID(ApperanceID))
			else
				if (not table.is_nil_empty(EquipmentCfgs)) and table.length(EquipmentCfgs) > 0 then
					for i = 1, #EquipmentCfgs do
						local ResID = EquipmentCfgs[i].ID
						ItemNum = ItemNum + BagMgr:GetItemNum(ResID) + _G.EquipmentMgr:GetEquipedItemNum(ResID)
					end
				end
			end
			local ItemValue2 = {}
			ItemValue2.Name = LSTR(1080060)
			local Str = RichTextUtil.GetText(string.format("%d", ItemNum), "#DC5868FF")
			ItemValue2.Num = string.format("%s/%d",  ItemNum >= 0 and tostring(ItemNum) or Str,  WardrobeUtil.GetUnlockCostItemNum(ApperanceID) )
			ItemValue2.Item = IsSpecial and  WardrobeUtil.GetUnlockCostItemID(ApperanceID)  or WardrobeUtil.GetEquipIDByAppearanceID(ApperanceID)
			_G.FLOG_INFO(string.format("点击的外观 %d, 可以解锁的装备ID ====> %d", ApperanceID, IsSpecial and  WardrobeUtil.GetUnlockCostItemID(ApperanceID) or WardrobeUtil.GetEquipIDByAppearanceID(ApperanceID)))
			self.BagSlotItemVM2:UpdateVM(ItemValue2)
		end

	end

	if not IsUnlock then
		self.CurAppUnlockConditionVisible = true
		local Data = WardrobeMgr:GetAppearanceClientData(ApperanceID)
		if Data ~= nil then
			if  Data.RaceLimit == nil or not WardrobeUtil.JudgeRaceCond(Data.RaceLimit) then
				self.CurAppUnlockCondition = LSTR(1080116) -- 种族不符
				self.CurAppUnlockConditionVisible = false
				return 
			end

			if Data.GenderLimit == nil or not WardrobeUtil.JudgeGenderCond(Data.GenderLimit) then
				self.CurAppUnlockCondition = LSTR(1080117) -- 性别不符
				self.CurAppUnlockConditionVisible = false
				return
			end

			if Data.ProfLimit == nil or Data.ClassLimit == nil or not WardrobeUtil.JudgeProfCond(Data.ProfLimit, Data.ClassLimit) then
				self.CurAppUnlockCondition = LSTR(1080118) -- 职业不符
				self.CurAppUnlockConditionVisible = false
				return
			end

			if Data.LevelLimit == nil or not WardrobeUtil.JudgeLevelCond(Data.LevelLimit) then
				self.CurAppUnlockCondition = LSTR(1080119) --等级不符
				self.CurAppUnlockConditionVisible = false
				return
			end
		end
	end

end

---@param ApperanceID 外观ID 更新选中的外观是否有套装
function WardrobeMainPanelVM:UpdateSuitBtnState(ApperanceID)
	--Todo 办理套装表，查找AppItems 是否存在对应外观
	local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(ApperanceID)
	
	local Cfgs = ClosetSuitCfg:FindAllCfg(string.format("TabIndex = 3 or TabIndex = 2"))

	for _, v in ipairs(Cfgs) do
		if v.AppItems and next(v.AppItems) then
			if table.contain(v.AppItems, EquipID) then
				self.BtnSuitVisible = true
				return v.ID
			end
		end
	end

	self.BtnSuitVisible = false
end

---刷新同模装备列表
function WardrobeMainPanelVM:UpdateSameEquipmentList(ApperanceID)
	local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ApperanceID)
	local DataList = {}
	local WardrobeTipsListItemVM  = require("Game/Wardrobe/VM/Item/WardrobeTipsListItemVM")

	if not table.is_nil_empty(EquipmentCfgs) then
		for i = 1, #EquipmentCfgs do
			local ID = WardrobeUtil.GetIsSpecial(ApperanceID) and (EquipmentCfgs[i].ID + WardrobeDefine.SpecialShiftID) or EquipmentCfgs[i].ID
			local Data = WardrobeTipsListItemVM.New()
			Data.ID = ID
			local Item = ItemUtil.CreateItem(ID, 0)
			Data.BagSlotVM:UpdateVM(Item, {IsShowNum = false, IsShowLeftCornerFlag = false})
			Data.EquipmentName = ItemUtil.GetItemName(ID)
			Data.BagNum = BagMgr:GetItemNum(ID) + _G.EquipmentMgr:GetEquipedItemNum(ID)
			table.insert(DataList, Data)
		end
	end

	local TipsItemVM = WardrobeTipsItemVM.New()
	TipsItemVM.ApperanceID = ApperanceID
	TipsItemVM.SameEquipmentList = DataList

	return TipsItemVM
end

---刷新
function WardrobeMainPanelVM:UpdateUnlockBtnTextState(ApperanceID)
	local IsUnlock = WardrobeMgr:GetIsUnlock(ApperanceID)
	local DyeEnable = WardrobeMgr:GetDyeEnable(ApperanceID)
	local CanUnlock = WardrobeUtil.GetIsBagOwnAppearanceEquipment(ApperanceID)

	-- 未解锁
	if not IsUnlock then
		-- 如果有道具就是解锁，没有道具就是获取
		if #WardrobeUtil.GetAchievementIDList(ApperanceID) > 0 then
			self.BtnUnlockText = LSTR(1080061)
		else
			self.BtnUnlockText = CanUnlock and LSTR(1080061) or LSTR(1080110)
		end
	else
		-- 未解锁染色，不可染色 禁用态
		-- 可解锁染色，已解锁染色 推荐
		-- 染色不可用，无法预览时，禁用态，但是可以点击
		if not DyeEnable then
			self.BtnUnlockText = LSTR(1080054)
		else
			self.BtnUnlockText = LSTR(1080062)
		end
	end

	-- self.BtnUnlockEnable = not IsUnlock and CanUnlock or (DyeEnable)
end

function WardrobeMainPanelVM:UpdateTryStainState(ApperanceID)
	local IsUnlock = WardrobeMgr:GetIsUnlock(ApperanceID)
	local ClientDyeEnable = WardrobeUtil.GetAppearanceCanBeDyed(ApperanceID)

	self.PanelStainVisible = false -- 试染
	self.PanelUnStainVisible = false -- 不可染色
	self.PanelCanStainVisible = false -- 可染色，无法穿戴

	self.StainTextColor = NormalColor

	if IsUnlock then
		self.PanelBtnVisible = false
	else
		self.PanelBtnVisible = true
	end

	if not IsUnlock then
		if ClientDyeEnable then
			local CanEquiped = WardrobeMgr:CanPreviewAppearanceByClientData(ApperanceID)
			if not CanEquiped then
				self.PanelCanStainVisible = true
				return
			end
			self.PanelStainVisible = true
		else
			self.PanelUnStainVisible = true
		end
	end
	
end

function WardrobeMainPanelVM:UpdateReduceCondState(ApperanceID)
	--解锁判断是否满足最低的解锁条件
	self.ReduceCondVisible = WardrobeMgr:GetIsUnlock(ApperanceID) and WardrobeMgr:IsLessReduceConditionEquipment(ApperanceID)
end

function WardrobeMainPanelVM:UpdateQuickUnlockState()
	local _ <close> = CommonUtil.MakeProfileTag("UpdateQuickUnlockState")
	self.QuickUnlockVisible = WardrobeMgr:GetQuickUnlockAppearanceListVisible()
end

function WardrobeMainPanelVM:UpdateCharismNum()
	if not WardrobeMgr:IsExceedCfgLevel() then
		self.CharmNumText = string.format("%d/%d", WardrobeMgr:GetCharismNum(), WardrobeMgr:GetCharismTotalNum())
		self.CharmEffVisible = WardrobeMgr:GetCharismNum() >= WardrobeMgr:GetCharismTotalNum()
	else
		self.CharmNumText = string.format("%d", WardrobeMgr:GetCharismNum())
		self.CharmEffVisible = false
	end
end

function WardrobeMainPanelVM:SearchEquipmentList(PartID, PartSubName, SearchText)
	self.AppearanceList:Clear()

	local Cfg = PartSubName == _G.LSTR(1080037) and self:GetAppearanceDataList(PartID) or self:GetAppearanceDataListByPartAndSubID(PartID, PartSubName)
	local EquipCfg = EquipmentCfg:FindCfgByPartID(PartID)

	local DataList = {}
	local IDList = {}
	local SpeacialAppIDList  = {}
	for _, v in ipairs(Cfg) do
		local Name = WardrobeUtil.GetEquipmentAppearanceName(v.ID)
		if string.find(Name, SearchText) then
			if not table.contain(IDList, v.ID) then
				local Data = self:CreateAppearanceItem(v.ID, Name, PartID)
				table.insert(IDList, v.ID)
				table.insert(DataList, Data)
			end
		end

		if WardrobeUtil.GetIsSpecial(v.ID) then
			table.insert(SpeacialAppIDList, { AppID = v.ID, UnlockCostItemID = v.UnlockCostItemID })
		end
	end

	for _, v in ipairs(SpeacialAppIDList) do
		local ItemC = ItemCfg:FindCfgByKey(v.UnlockCostItemID)
		if ItemC ~= nil then
			if string.find(ItemC.ItemName, SearchText) then
				if not table.contain(IDList, v.AppID) then
					local Data = self:CreateAppearanceItem(v.AppID, WardrobeUtil.GetEquipmentAppearanceName(v.AppID), PartID)
					table.insert(DataList, Data)
					table.insert(IDList, v.AppID)
				end
			end
		end 
	end

	for _, v in ipairs(EquipCfg) do
		if v.AppearanceID > 0 then
			local ItemC = ItemCfg:FindCfgByKey(v.ID)
			if ItemC ~= nil then
				if string.find(ItemC.ItemName, SearchText) then
					if not table.contain(IDList, v.AppearanceID) and v.AppearanceID ~= 0 then
						local Data = self:CreateAppearanceItem(v.AppearanceID,  WardrobeUtil.GetEquipmentAppearanceName(v.AppID), PartID)
						table.insert(DataList, Data)
						table.insert(IDList, v.AppearanceID)
					end
				end
			end
		end
	end

	table.sort(DataList, self.AppearanceSortFunction)

	self.AppearanceList:UpdateByValues(DataList)
	self.EmptyVisible = #DataList == 0

end

function WardrobeMainPanelVM:CancelSearchEquipmentList()
end

function WardrobeMainPanelVM:FilterAppearanceList(Table, Condition)
	local _ <close> = CommonUtil.MakeProfileTag("FilterAppearanceList")
	local Condition = Condition

	local FilterList = {}
	for i = 1, #Table do
		local ItemVM = Table[i]
		local ID = ItemVM.ID
		local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ID)

		for _, v in ipairs(EquipmentCfgs) do
			local Item  = ItemCfg:FindCfgByKey(v.ID)
			if Item ~= nil then
				if Condition.ClassType == WardrobeDefine.ProfClass.ClassType then
					-- 判断是否是符合职业大类的
					if Item.ClassLimit == Condition.ProfID then
						if FilterList[ID] == nil then
							FilterList[ID] = ItemVM
						end
					end
				elseif Condition.ClassType == WardrobeDefine.ProfClass.BasicType then
					if table.is_nil_empty(Item.ProfLimit) then
						if FilterList[ID] == nil then
							FilterList[ID] = ItemVM
						end
					end
					for __, vv in ipairs(Item.ProfLimit) do
						if vv == Condition.ProfID then
							if FilterList[ID] == nil then
								FilterList[ID] = ItemVM
							end
						end
					end
				elseif Condition.ClassType == WardrobeDefine.ProfClass.AdvanceType then
					if table.is_nil_empty(Item.ProfLimit) then
						if FilterList[ID] == nil then
							FilterList[ID] = ItemVM
						end
					end
					local ProfCfg = RoleInitCfg:FindCfgByKey(Condition.ProfID)
					local AdvanceProf = ProfCfg.AdvancedProf
					for __, vv in ipairs(Item.ProfLimit) do
						if (vv == Condition.ProfID or vv == AdvanceProf) then
							if FilterList[ID] == nil then
								FilterList[ID] = ItemVM
							end
						end
					end
				end
			end
		end
	end

	local TempList = {}
	for k, v in pairs(FilterList) do
		table.insert(TempList, v)
	end

	table.sort(TempList, self.AppearanceSortFunction)

	self.AppearanceList:Clear()
	self.AppearanceList:UpdateByValues(TempList)

	self.EmptyVisible = #TempList == 0
	self.PanelNameVisible = not #TempList == 0
end

--可解锁(收藏)>可解锁>已解锁(收藏)>未解锁(收藏)>未解锁
function WardrobeMainPanelVM.AppearanceSortFunction(Left, Right)
	local function getPriority(Item)
		if Item.CanUnlockVisible and Item.FavoriteVisibleForSort then  
            return 6  
        elseif Item.CanUnlockVisible and not Item.FavoriteVisibleForSort then  
            return 5  
        elseif Item.UnlockVisible and Item.FavoriteVisibleForSort then  
            return 4  
        elseif Item.UnlockVisible and not Item.FavoriteVisibleForSort then  
            return 3 
		elseif not Item.UnlockVisible and Item.FavoriteVisibleForSort then  
            return 2
		elseif not Item.UnlockVisible and not Item.FavoriteVisibleForSort then  
            return 1 
        else 
            return 0  
        end
	end

	local priorityA = getPriority(Left)  
    local priorityB = getPriority(Right)  
  
    -- 如果优先级不同，则按优先级排序  
    if priorityA ~= priorityB then  
        return priorityA > priorityB
    end

	return Left.ID < Right.ID
end

function WardrobeMainPanelVM:SetIsShowWeapon(IsShow, IsSave)
	self.BtnHandChecked = IsShow
end

function WardrobeMainPanelVM:ShowHead(IsShow, IsSave)
	self.BtnHatChecked = IsShow
end

function WardrobeMainPanelVM:SwitchHelmet(bIsHelmetGimmickOn, IsSave)	
	self.BtnHatStyleChecked = bIsHelmetGimmickOn
end

WardrobeMainPanelVM.GetDataByFilterIndex = GetDataByFilterIndex

--要返回当前类
return WardrobeMainPanelVM