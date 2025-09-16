--
-- Author: ZhengJianChuan
-- Date: 2024-02-28 15:51
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIBindableList = require("UI/UIBindableList")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local AchievementTextCfg = require("TableCfg/AchievementTextCfg")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local WardrobeConsumeSlotItemVM = require("Game/Wardrobe/VM/Item/WardrobeConsumeSlotItemVM")
local WardrobeBindSlotItemVM = require("Game/Wardrobe/VM/Item/WardrobeBindSlotItemVM")
local WardrobeSwitchListItemVM = require("Game/Wardrobe/VM/Item/WardrobeSwitchListItemVM")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local BagMgr = require("Game/Bag/BagMgr")
local WarningColor = "#dc5868ff"
local NormalColor = "#d5d5d5FF"

local LSTR = _G.LSTR

---@class WardrobeAppearancePageVM : UIViewModel
local WardrobeAppearancePageVM = LuaClass(UIViewModel)

---Ctor
function WardrobeAppearancePageVM:Ctor()
	self.TitleName = ""
	self.GenderCondText = ""
	self.ProfCondText = ""	
	self.ProfLevelText = 0
	self.RaceCondText = 0
	self.UnlockTxt = ""
	self.GenderCondColor = NormalColor
	self.ProfCondColor = NormalColor
	self.ProfLevelColor = NormalColor
	self.RaceCondColor = NormalColor
	self.UnlockTxtColor = NormalColor
	self.ConsumeList = UIBindableList.New(WardrobeConsumeSlotItemVM)
	self.BindList = UIBindableList.New(WardrobeBindSlotItemVM)
	self.SwitchList = UIBindableList.New(WardrobeSwitchListItemVM)
	self.DetailProfVisible = false
	self.PanelLegendaryWeaponVisible = false
	self.PanelConsumeVisible = false
	self.PanelBindVisible = false
	self.AchievementTxt1 = ""
	self.AchievementTxt2 = ""
	self.AchievementVisible1 = false
	self.AchievementVisible2 = false
	self.SwitchListSelectedIndex = nil
	self.BindListSelectedIndex = nil

	self.bAnyItemSelected = false
	self.ProfImproveVisible  = false
	self.LevelImproveVisible = false


	self.CurAppUnlockLevelConditon = nil
	self.CurAppUnlockProfCondVisible = nil
	self.CurAppUnlockGenderCondVisible = nil
	self.CurAppUnlockRaceCondVisible = nil
	self.CurAppUnlockStainCondVisible = nil

end

function WardrobeAppearancePageVM:OnInit()
end

function WardrobeAppearancePageVM:OnBegin()
end

function WardrobeAppearancePageVM:OnEnd()
end

function WardrobeAppearancePageVM:OnShutdown()
end

-- 展示等级对比
function WardrobeAppearancePageVM:ShowLevelImprove(IsUnlock, FirstEquipID, SelectedEquipID)
	if not IsUnlock then
		if SelectedEquipID == nil then
			self.LevelImproveVisible = true
		elseif FirstEquipID ~= nil and  SelectedEquipID ~= nil and  FirstEquipID == SelectedEquipID then
			self.LevelImproveVisible = true
		else
			local FirstEquipCfg = ItemCfg:FindCfgByKey(FirstEquipID)
			local SelectEquipCfg = ItemCfg:FindCfgByKey(SelectedEquipID)

			if FirstEquipCfg ~= nil and SelectEquipCfg ~= nil then
				self.LevelImproveVisible = FirstEquipCfg.Grade > SelectEquipCfg.Grade
			end
		end
		return
	end

	if SelectedEquipID ~= nil and FirstEquipID ~= SelectedEquipID then
		local FirstEquipCfg = ItemCfg:FindCfgByKey(FirstEquipID)
		local SelectEquipCfg = ItemCfg:FindCfgByKey(SelectedEquipID)

		if FirstEquipCfg ~= nil and SelectEquipCfg ~= nil then
			self.LevelImproveVisible = FirstEquipCfg.Grade > SelectEquipCfg.Grade
		end
	elseif (FirstEquipID ~= nil and SelectedEquipID ~= nil) and FirstEquipID == SelectedEquipID then
		self.LevelImproveVisible = true
	end
end

-- 展示职业对比
function WardrobeAppearancePageVM:ShowProfImprove(IsUnlock, FirstEquipID, SelectedEquipID)
	if not IsUnlock then
		if nil == SelectedEquipID or FirstEquipID == SelectedEquipID   then
			self.ProfImproveVisible = true
			return 
		end
	end

	if (FirstEquipID ~= nil and SelectedEquipID ~= nil) and FirstEquipID ~= SelectedEquipID then
		local FirstEquipCfg = ItemCfg:FindCfgByKey(FirstEquipID)
		local SelectEquipCfg = ItemCfg:FindCfgByKey(SelectedEquipID)

		if FirstEquipCfg ~= nil and SelectEquipCfg ~= nil then
			local FirstEquipData = WardrobeMgr:ConvertEquipmentLimit(FirstEquipCfg)
			local SelectedEquipData  = WardrobeMgr:ConvertEquipmentLimit(SelectEquipCfg)

			local FirstEquipDataClassLimit = FirstEquipData.ClassLimits
			local SelectedEquipDataClassLimit = SelectedEquipData.ClassLimits
			local FirstEquipDataProfLimit = FirstEquipData.ProfLimits
			local SelectedEquipDataProfLimit = SelectedEquipData.ProfLimits

			if not (FirstEquipDataClassLimit == 0 and SelectedEquipDataClassLimit == 0) then
				if SelectedEquipDataClassLimit == 0 and WardrobeUtil.ConvertProfCondNum(SelectedEquipDataProfLimit) == 0 then
					self.ProfImproveVisible = true
					return
				end
		
				local FirstEquipProfList = WardrobeAppearancePageVM.ConvertProfLimitList(FirstEquipDataClassLimit, FirstEquipDataProfLimit)
				local SelectedEquipProfList = WardrobeAppearancePageVM.ConvertProfLimitList(SelectedEquipDataClassLimit, SelectedEquipDataProfLimit)

				-- 如果选中的装备没有在第一个职业里面，那就是显示
				for _, profID in ipairs(SelectedEquipProfList) do
					if not table.contain(FirstEquipDataProfLimit, profID) then
						self.ProfImproveVisble = true
						return
					end
				end

				if table.length(SelectedEquipProfList) > table.length(FirstEquipProfList) then
					self.ProfImproveVisble = true
					return
				end
			end
		end
	elseif (FirstEquipID ~= nil and SelectedEquipID ~= nil) and FirstEquipID == SelectedEquipID then
		self.ProfImproveVisble = true
		return
	end

	self.ProfImproveVisble = false
end

function WardrobeAppearancePageVM.ConvertProfLimitList(ClassLimit, ProfLimit)
	local RetProfLimit = {}
	local ClassTypeData = WardrobeUtil.GetClassTypeData()
	if not table.is_nil_empty(ClassTypeData[ClassLimit]) then
		for _, v in ipairs(ClassTypeData[ClassLimit]) do
			if not table.contain(RetProfLimit, v) then
				table.insert(RetProfLimit, v)
			end
		end
	end
	if (not table.is_nil_empty(ProfLimit)) and ProfLimit[1] ~= 0 then
		for _, v in ipairs(ProfLimit) do
			if not table.contain(RetProfLimit, v) then
				table.insert(RetProfLimit, v)
			end
		end
	end
	return RetProfLimit
end

function WardrobeAppearancePageVM:UpdateInfo(ID)
	self.TitleName = WardrobeUtil.GetEquipmentAppearanceName(ID)

	local BestEquipementData = WardrobeMgr:GetBestEquipementData(ID)

	local GenderLimit = BestEquipementData.GenderLimit == 0 and ProtoCommon.role_gender.GENDER_UNKNOWN or BestEquipementData.GenderLimit
	local LevelLimit = BestEquipementData.LevelLimit
	local RaceLimit =  BestEquipementData.RaceLimits
	local ProfLimit = BestEquipementData.ProfLimits
	local ClassLimit = BestEquipementData.ClassLimits
	self.GenderCondText = WardrobeUtil.GetGenderCondText(GenderLimit)
	self.ProfLevelText = WardrobeUtil.GetLevelCondText(LevelLimit)
	self.ProfCondText = WardrobeUtil.GetSimpleProfCondText(ProfLimit, ClassLimit)
	self.RaceCondText = WardrobeUtil.GetRaceCondText(RaceLimit)

	local GenderCond = WardrobeUtil.JudgeGenderCond(GenderLimit)
	local LevelCond = WardrobeUtil.JudgeLevelCond(LevelLimit)
	local ProfCond = WardrobeUtil.JudgeProfCond(ProfLimit, ClassLimit)
	local RaceCond = WardrobeUtil.JudgeRaceCond(RaceLimit) 

	self.GenderCondColor = GenderCond and NormalColor or WarningColor
	self.ProfLevelColor = LevelCond and NormalColor or WarningColor
	self.ProfCondColor = ProfCond and NormalColor or WarningColor
	self.RaceCondColor = RaceCond and NormalColor or WarningColor
	self.DetailProfVisible = WardrobeUtil.GetDetailProfVisible(ProfLimit, ClassLimit)

	self.CurAppUnlockLevelConditon = not LevelCond
	self.CurAppUnlockProfCondVisible = not ProfCond
	self.CurAppUnlockGenderCondVisible = not GenderCond
	self.CurAppUnlockRaceCondVisible = not RaceCond

	local IsUnlock = WardrobeMgr:GetIsUnlock(ID)
	if IsUnlock then
		-- 服务器数据
		local DyeEnable = WardrobeMgr:GetDyeEnable(ID)
		self.UnlockTxt = DyeEnable and LSTR(1080053) or LSTR(1080054)
		self.UnlockTxtColor = DyeEnable and NormalColor or WarningColor
		self.CurAppUnlockStainCondVisible = not DyeEnable
	else
		-- 客户端数据
		local DyeEnable = WardrobeUtil.GetAppearanceCanBeDyed(ID)
		self.UnlockTxt = DyeEnable and LSTR(1080055) or LSTR(1080054)
		self.CurAppUnlockStainCondVisible = not DyeEnable
		self.UnlockTxtColor = DyeEnable and NormalColor or WarningColor
	end

	self.PanelConsumeVisible = table.is_nil_empty(WardrobeUtil.GetAchievementIDList(ID))

	if self.PanelConsumeVisible then
		self:UpdateConsumeList(ID)
		self:UpdateBindList(ID)
		if self.SwitchList:Length() > 0 then
			self.BindListSelectedIndex = 0
			self.BindListSelectedIndex = 1
		end
		self.PanelBindVisible = not WardrobeUtil.GetIsSpecial(ID)
	else
		self.PanelBindVisible = false
		self:UpdateAchievement(WardrobeUtil.GetAchievementIDList(ID))
	end
	
end

function WardrobeAppearancePageVM:UpdateImproveFlag(ID,SelectedEquipID)
	local IsUnlock = WardrobeMgr:GetIsUnlock(ID)
	local FirstEquipData = self.BindList:Get(1)
	local FirstEquipID = FirstEquipData and FirstEquipData.ID or nil
	self:ShowLevelImprove(IsUnlock, FirstEquipID, SelectedEquipID)
	self:ShowProfImprove(IsUnlock, FirstEquipID, SelectedEquipID)
end

function WardrobeAppearancePageVM:UpdateAchievement(AchievementIDList)
	for index, value in ipairs(AchievementIDList) do
		local Cfg = AchievementTextCfg:FindCfgByKey(value)
		if Cfg ~= nil then
			local FinishTxt = _G.AchievementMgr:GetAchievementFinishState(value) and _G.LSTR(1080057) or _G.LSTR(1080055)
			if index == 1 then
				self.AchievementTxt1 = string.format("%s(%s)", Cfg.Name, FinishTxt)
			elseif index == 2 then
				self.AchievementTxt2 = string.format("%s(%s)", Cfg.Name, FinishTxt)
			end
		end
	end

	self.AchievementVisible1 = table.length(AchievementIDList) > 0
	self.AchievementVisible2 = table.length(AchievementIDList) > 1 
end

function WardrobeAppearancePageVM:UpdateConsumeList(ID)
	self.ConsumeList:Clear()
	--暂时只有一个
	local Data = {}
	local ItemID = WardrobeUtil.GetUnlockCostItemID(ID)
	local ItemNum = WardrobeUtil.GetUnlockCostItemNum(ID)
	Data.Item = ItemID
	Data.Num = WardrobeUtil.GetIsSpecial(ID) and string.format("%d/%d", BagMgr:GetItemNum(ItemID), ItemNum) or ItemNum
	self.ConsumeList:UpdateByValues({Data})
end

function WardrobeAppearancePageVM:UpdateBindList(ID)
	self.BindList:Clear()
	local DataList = {}
	-- 查找背包里可绑定的装备列表
	-- 如果存在相同属性装备时显示 交换img
	local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ID) or {}
	local TempEquipmentIDList = {}
	local IsUnlock = WardrobeMgr:GetIsUnlock(ID)
	for _, v in  ipairs(EquipmentCfgs) do
		local ItemNum = _G.BagMgr:GetItemNum(v.ID) + _G.EquipmentMgr:GetEquipedItemNum(v.ID)
		if IsUnlock then
			if ItemNum > 0 and WardrobeMgr:IsLessReduceConditionEquipment(ID, v.ID) then
				table.insert(TempEquipmentIDList, v.ID)
			end
		else
			if ItemNum > 0 then
				table.insert(TempEquipmentIDList, v.ID)
			end
		end
	end

	local EquipmentIDList = WardrobeMgr:GetReduceEquipmentList(TempEquipmentIDList, ID)

	if not table.is_nil_empty(EquipmentIDList) then
		for _, EquipID in ipairs(EquipmentIDList) do
			local ItemConfig = ItemCfg:FindCfgByKey(EquipID)
			local Data = {}
			local IconID = ItemUtil.GetItemIcon(EquipID)
			if IconID ~= 0  then
				local BagItem = BagMgr:GetItemByResID(EquipID)
				local EquipItem = _G.EquipmentMgr:GetEquipedItemByResID(EquipID)
				local ItemNum = BagMgr:GetItemNum(EquipID) + _G.EquipmentMgr:GetEquipedItemNum(EquipID)
				Data.IsSwitch = ItemNum > 1
				Data.ID = EquipID
				Data.GID = BagItem ~= nil and BagItem.GID or EquipItem.GID
				Data.Level = ItemConfig.Grade
				table.insert(DataList, Data)
			end
		end
	end

	table.sort(DataList, function(a, b) return a.Level < b.Level end)

	self.BindList:UpdateByValues(DataList)
end

function WardrobeAppearancePageVM:UpdateSwitchList(ItemResID)
	self.SwitchList:Clear()
	if ItemResID == nil then
		return
	end
	local ItemList = BagMgr:FilterItemByCondition(function (Item)
		return Item.ResID == ItemResID
	end)

	--查找背包里相同itemID的装备道具
	local DataList = {}
	for _, v in ipairs(ItemList) do
		local IconID = ItemUtil.GetItemIcon(v.ResID)
		if IconID ~= 0 then
			local Data = {}
			Data.Item = v.ResID
			Data.Name = ItemUtil.GetItemName(v.ResID)
			Data.IsRecommend = false
			Data.ID = v.ResID
			Data.GID = v.GID
			table.insert(DataList, Data)
		end
	end

	-- 查找装备中相同itemID的装备道具
	local ItemList1 = EquipmentVM.ItemList
	for _, v in pairs(ItemList1) do
		if v.ResID == ItemResID then
			local IconID = ItemUtil.GetItemIcon(v.ResID)
			if IconID ~= 0 then
				local Data = {}
				Data.Item = v.ResID
				Data.Name = ItemUtil.GetItemName(v.ResID)
				Data.IsRecommend = false
				Data.ID = v.ResID
				Data.GID = v.GID
				table.insert(DataList, Data)
			end
		end
	end

	--推荐标签显示逻辑 已绑定>未绑定(无魔晶石)>未绑定(有魔晶石)
	local Index = self:FindRecommendIndex(DataList)
	if DataList[Index] ~= nil then
		DataList[Index].IsRecommend = true
	end

	table.sort(DataList, function(a,  b) 
		if a.IsRecommend ~= b.IsRecommend then
			return a.IsRecommend
		end
		return false
	end)

	self.SwitchList:UpdateByValues(#DataList > 1 and DataList or {})
	self.SwitchListSelectedIndex = 0
	self.SwitchListSelectedIndex = 1
end

function WardrobeAppearancePageVM:FindRecommendIndex(DataList)  
    if DataList == nil then return end  
      
    -- 尝试找到满足条件的装备项  
    local function findItem(predicate)  
        for index, v in ipairs(DataList) do  
            if predicate(v) then  
                return index  
            end  
        end  
    end  
      
    -- 首先查找 IsBind 为 true 的装备项  
    local index = findItem(function(item) return item.IsBind end)  
    if index then return index end  
      
    -- 然后查找 WithoutMojingShi 为 false 的装备项  
    index = findItem(function(item) return not item.WithoutMojingShi end)  
    if index then return index end  
      
    -- 最后查找 WithoutMojingShi 为 true 的装备项  
    index = findItem(function(item) return item.WithoutMojingShi end)  
    if index then return index end  
      
    -- 如果没有找到任何符合条件的装备项，返回默认索引  
    return 1  
end

function WardrobeAppearancePageVM:GetBindList()
	return self.BindList
end

function WardrobeAppearancePageVM:ClearBindList()
	self.BindList:Clear()
	self.SwitchList:Clear()
	self.BindListSelectedIndex = 0
end

function WardrobeAppearancePageVM:ClearSwitchList()
	self.SwitchList:Clear()
end


--要返回当前类
return WardrobeAppearancePageVM