--
-- Author: ZhengJianChuan
-- Date: 2024-02-22 16:38
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local UIDefine = require("Define/UIDefine")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local UIBindableList = require("UI/UIBindableList")
local ClosetClassifyCfg = require("TableCfg/ClosetClassifyCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local WardrobeUnlockListItemVM = require("Game/Wardrobe/VM/Item/WardrobeUnlockListItemVM")
local WardrobePositionItemVM = require("Game/Wardrobe/VM/Item/WardrobePositionItemVM")
local WardrobeAppearancePageVM = require("Game/Wardrobe/VM/WardrobeAppearancePageVM")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local CommBtnColorType = UIDefine.CommBtnColorType

local NormalColor = "#D5D5D5FF"
local WarningColor = "#F5514FFF"

local LSTR

---@class WardrobeUnlockPanelVM : UIViewModel
local WardrobeUnlockPanelVM = LuaClass(UIViewModel)

---Ctor
function WardrobeUnlockPanelVM:Ctor()
	self.AppearanceTabList = UIBindableList.New(WardrobePositionItemVM)
	self.AppearanceList = UIBindableList.New(WardrobeUnlockListItemVM)
	self.CostMoney = 0
	self.AllNum = ""
	self.UnlockBtnState = CommBtnColorType.Recommend
	self.AppearancePageVM = WardrobeAppearancePageVM.New()
	self.AllCheckedState = false
	self.HorizontalCurrent2Visible = true
	self.Subtitle = ""
	self.CostMoneyColor = NormalColor
	self.UnlockBtnTxtColor = "#FFFCF1FF"
end

function WardrobeUnlockPanelVM:OnInit()
end

function WardrobeUnlockPanelVM:OnBegin()
	LSTR = _G.LSTR
end

function WardrobeUnlockPanelVM:OnEnd()
end

function WardrobeUnlockPanelVM:OnShutdown()
end

function WardrobeUnlockPanelVM:ClearList()
	self.AppearanceTabList:Clear()
	self.AppearanceList:Clear()
	self.AppearancePageVM:ClearBindList()
end

-- 更新左边菜单栏
function WardrobeUnlockPanelVM:UpdateAppearanceTabList(List, IsQuickLock)
	IsQuickLock = IsQuickLock or false
	self.AppearanceTabList:Clear()
	local TabList = {}

    local TempData = {}
    TempData.ID = 0
    TempData.PositionIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Noraml.UI_Icon_Tab_Bag_Equip_All_Noraml'"
	TempData.PositionSelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Bag_Equip_All_Select.UI_Icon_Tab_Bag_Equip_All_Select"
    TempData.StateIcon = ""
    TempData.StainTagVisible = false
	TempData.SortID = 0
	table.insert(TabList, TempData)

	-- Todo 判断可解锁的部件导航
	for _, v in ipairs(List) do
		local Cfg = ClosetCfg:FindCfgByKey(v)
		if Cfg ~= nil then
			local PartID = WardrobeUtil.GetPartByAppearanceID(v)
			if PartID == ProtoCommon.equip_part.EQUIP_PART_FINGER  then
				PartID = ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER
			end
			local ClassifyCfg = ClosetClassifyCfg:FindCfgByKey(PartID)
			if ClassifyCfg ~= nil then
				local Data = {}
				Data.ID = PartID
	 			Data.PositionIcon = ClassifyCfg.Icon
				Data.PositionSelectIcon = ClassifyCfg.SelectIcon
	 			Data.StateIcon = ""		    -- 如果当前部分解锁激活,icon使用当前装备的icon
				Data.StainTagVisible = false    -- 染色标签
				Data.SortID = self:GetSortID(PartID)

				if not self:ContainTabKey(TabList, PartID) then
					table.insert(TabList, Data)
				end
			end
		end
	end

	table.sort(TabList, function (a, b)
		return a.SortID < b.SortID
	end)

	self.AppearanceTabList:UpdateByValues(TabList)
end

function WardrobeUnlockPanelVM:ContainTabKey(List, PartID)
	for _, v in ipairs(List) do
		if v.ID == PartID then
			return true
		end
	end

	return false
end

function WardrobeUnlockPanelVM:UpdateAppearanceList(PartID, AppearanceList, IsQuickUnlock, SelectedAppID)
	local IsQuickUnlock = IsQuickUnlock or false
	self.AppearanceList:Clear()
	local DataList = {}
	for _, v in ipairs(AppearanceList) do
		local AppID = v
		local Part = WardrobeUtil.GetPartIDByAppearanceID(AppID)
		if Part == ProtoCommon.equip_part.EQUIP_PART_FINGER then
			Part = ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER   
		end
		if (PartID == Part or PartID == 0) then
			local Data = self:CreateAppearanceItem(AppID)
			if  Data ~= nil then
				table.insert(DataList, Data)
			end
		end
	end

	local function SortPredicate(Left, Right)
		if Left.CreatTime ~= Right.CreateTime then
			return Left.CreateTime > Right.CreateTime
		end

		if Left.FavoriteVisible ~= Right.FavoriteVisible then
			return Left.FavoriteVisible
		end

		return false
	end

	table.sort(DataList, SortPredicate)

	self.AppearanceList:UpdateByValues(DataList)
	self:UpdateAppearanceListCheckState(IsQuickUnlock, SelectedAppID)
	self:UpdateAppearanceListCheckStateData()


	return DataList

end

function WardrobeUnlockPanelVM:CreateAppearanceItem(AppID)
	local Data = {}
	Data.ID = AppID
	Data.ItemName = WardrobeUtil.GetEquipmentAppearanceName(AppID)
	Data.ReduceCond = WardrobeMgr:IsLessReduceConditionEquipment(AppID)
	Data.FavoriteVisible = WardrobeMgr:GetIsFavorite(AppID)
	Data.EquipmentIcon = WardrobeUtil.GetEquipmentAppearanceIcon(AppID)
	Data.CheckedState = false

	local EuqipmentIDList = WardrobeUtil.GetBagOwnAppearanceEquipmentList(AppID)
	local MinCreateTime = 0
	for _, v in ipairs(EuqipmentIDList) do
		if MinCreateTime == 0 or MinCreateTime >= v.CreateTime then
			MinCreateTime= v.CreateTime
		end
	end
	Data.CreateTime = MinCreateTime
	return Data
end

function WardrobeUnlockPanelVM:SetAppearanceItemCheckState(AppID, SetCheckedState, TotalUseItemNum)
	return SetCheckedState, TotalUseItemNum
end

function WardrobeUnlockPanelVM:CheckItemByIndex(Index)
	local ItemVM = self.AppearanceList:Get(Index)
	if ItemVM then
		ItemVM:SetCheckedState(true)
		self:UpdateAppearanceListCheckStateData()
	end
end

function WardrobeUnlockPanelVM:UpdateAppearanceListCheckState(IsQuickUnlock, SelectedAppID)
	local LackUseItem = false
	local CanCheckedNum = 0
	local OverMaxUnlockNum = false
	local TotalItemNum = _G.BagMgr:GetItemNum(WardrobeDefine.NormalItemID)
	for i = 1, self.AppearanceList:Length() do
		local ItemVM = self.AppearanceList:Get(i)
		if ItemVM ~= nil then
			local AppID = ItemVM.ID
			local SetCheckedState = IsQuickUnlock
			if SelectedAppID ~= nil and SelectedAppID == AppID and not IsQuickUnlock then
				SetCheckedState = true
			end
			if CanCheckedNum >= WardrobeMgr:GetMaxUnlockNum() then
				SetCheckedState = false
				OverMaxUnlockNum = true
			end
			local CheckedState, NewTotalItemNum = self:SetAppearanceItemCheckState(AppID, SetCheckedState, TotalItemNum)
			ItemVM:SetCheckedState(CheckedState)
			if CheckedState then
				CanCheckedNum = CanCheckedNum + 1
			end
			if not CheckedState and not OverMaxUnlockNum  then
				LackUseItem = true
			end
			TotalItemNum = NewTotalItemNum
		end
	end

	if OverMaxUnlockNum then
		MsgTipsUtil.ShowTips(_G.LSTR(1080127))
		return
	end

	if LackUseItem and self.IsQuickUnlock then
		if CanCheckedNum > 1 then
			MsgTipsUtil.ShowTips(string.format(LSTR(1080070), ItemUtil.GetItemName(WardrobeDefine.NormalItemID)))
		elseif CanCheckedNum == 0 then
			MsgTipsUtil.ShowTips(string.format(LSTR(1080071), ItemUtil.GetItemName(WardrobeDefine.NormalItemID)))
		end
	end
end

function WardrobeUnlockPanelVM:CheckedUseItemNum()
	local TotalItemUseItem = 0
	for i = 1, self.AppearanceList:Length() do
		local ItemVM = self.AppearanceList:Get(i)
		if ItemVM ~= nil then
			local CheckedState = ItemVM.CheckedState
			if CheckedState then
				if not WardrobeUtil.GetIsSpecial(ItemVM.ID) then
					TotalItemUseItem = TotalItemUseItem + WardrobeUtil.GetUnlockCostItemNum(ItemVM.ID)
				end
			end 
		end
	end

	return TotalItemUseItem
end

function WardrobeUnlockPanelVM:CheckedStateNum()
	local TotalItemUseItem = 0
	for i = 1, self.AppearanceList:Length() do
		local ItemVM = self.AppearanceList:Get(i)
		if ItemVM ~= nil then
			local CheckedState = ItemVM.CheckedState
			if CheckedState then
				TotalItemUseItem = TotalItemUseItem + 1
			end 
		end
	end

	return TotalItemUseItem
end

function WardrobeUnlockPanelVM:UpdateAppearanceListCheckStateData()
	local TotalCheckNum = 0
	local TotalItemNum = 0
	for i = 1, self.AppearanceList:Length() do
		local ItemVM = self.AppearanceList:Get(i)
		if ItemVM ~= nil then
			local CheckedState = ItemVM.CheckedState
			if CheckedState then
				TotalCheckNum = TotalCheckNum + 1
				if not WardrobeUtil.GetIsSpecial(ItemVM.ID) then
					TotalItemNum = TotalItemNum + WardrobeUtil.GetUnlockCostItemNum(ItemVM.ID)
				end
			end 
		end
	end

	self.AllCheckedState = TotalCheckNum == self.AppearanceList:Length()
	self.CostMoney = TotalItemNum
	self.AllNum = string.format("(%d/%d)", TotalCheckNum, self.AppearanceList:Length())
	self.CostMoneyColor = _G.BagMgr:GetItemNum(WardrobeDefine.NormalItemID) >= TotalItemNum and NormalColor or WarningColor
	self.UnlockBtnState = TotalCheckNum > 0 and  CommBtnColorType.Recommend or CommBtnColorType.Disable

	local TextNormalColor = "#FFFCF1FF"
	local TextGrayColor = "#F3F3F399"
	self.UnlockBtnTxtColor = TotalCheckNum > 0 and TextNormalColor or TextGrayColor
end

function WardrobeUnlockPanelVM:UpdateInfo(ID)
	self.AppearancePageVM:UpdateInfo(ID)
	-- 更新
	self.AppearancePageVM:UpdateImproveFlag(ID)
end

function WardrobeUnlockPanelVM:ClearBindList()
end

function WardrobeUnlockPanelVM:GetSortID(PartID)
	for index, v in ipairs(WardrobeDefine.EquipmentTab) do
		if PartID == v then
			return index
		end
	end

	return 0
end


--要返回当前类
return WardrobeUnlockPanelVM