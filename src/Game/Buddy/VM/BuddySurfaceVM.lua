local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local UIBindableBagSlotList = require("Game/NewBag/VM/UIBindableBagSlotList")
local BuddySurfaceTabItemVM = require("Game/Buddy/VM/BuddySurfaceTabItemVM")
local BuddySurfaceTabItem02VM = require("Game/Buddy/VM/BuddySurfaceTabItem02VM")
local BuddySurfaceSlotVM = require("Game/Buddy/VM/BuddySurfaceSlotVM")
local BuddySurfaceColorItemVM = require("Game/Buddy/VM/BuddySurfaceColorItemVM")
local BuddySurfaceColorPanelItemVM = require("Game/Buddy/VM/BuddySurfaceColorPanelItemVM")

local BuddyEquipCfg = require("TableCfg/BuddyEquipCfg")
local BuddyColorCfg = require("TableCfg/BuddyColorCfg")
local ChocoboDyeStuffCfg = require("TableCfg/ChocoboDyeStuffCfg")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local BuddyDefine = require("Game/Buddy/BuddyDefine")
local DateTimeTools = require("Common/DateTimeTools")
local BagMgr = require("Game/Bag/BagMgr")
local ProtoCS = require("Protocol/ProtoCS")
local EquipPart = ProtoCommon.equip_part
local EToggleButtonState = _G.UE.EToggleButtonState
local ChocoboDyeType = ProtoCS.ChocoboDyeType
local BagMainVM = require("Game/NewBag/VM/BagMainVM")

local LSTR
local BuddyMgr

---@class BuddySurfaceVM : UIViewModel
local BuddySurfaceVM = LuaClass(UIViewModel)
BuddySurfaceVM.MenuType = {Equipment = 1,  Dye = 2}
BuddySurfaceVM.EquipmentMenuType = {Head = 1,  Body = 2, Leg = 3}
BuddySurfaceVM.DyeMenuType = {Normal = 1,  Fast = 2}
local EquipmentCapacity = 300
local FoodCapacity = 10
local ColorCapacity = 20

local FruitBasis = 10
local FruitCombination = {NegativeFruit = {61000001, 61000002, 61000003}, PlusFruit = {61000004, 61000005, 61000006}}

---Ctor
function BuddySurfaceVM:Ctor()
	BuddyMgr = _G.BuddyMgr
	LSTR = _G.LSTR
	--self.TabPageVMList = UIBindableList.New(BuddySurfaceTabItemVM)
	self.EquipmentPageVisible = nil
	self.NormalDyePageVisible = nil
	self.FastDyePageVisible = nil
	self.DyeCDPageVisible = nil
	self.ShowArmorBtnVisible = nil
	self.AttachType = nil

	self.DyeDescPanelVisible = nil
	--self.SubTitleText = nil
	self.EquipmentText = nil

	self.SubTabVMList = UIBindableList.New(BuddySurfaceTabItem02VM)

	self.EquipmentItemVMList = UIBindableBagSlotList.New(BuddySurfaceSlotVM, {IsShowNum = false})

	self.DyeItemVMList = UIBindableBagSlotList.New(BuddySurfaceSlotVM, {IsShowNum = true})
	self.DyeColorVMList = UIBindableBagSlotList.New(BuddySurfaceColorItemVM)
	self.DyeColorTypeVMList = UIBindableBagSlotList.New(BuddySurfaceColorPanelItemVM)

	self.TabPageIndex = nil
	self.SubTabIndex = nil
	self.EquipmentID = nil
	self.DyeItemID = nil
	self.NormalDyeItemList = {}

	self.ColorItemEmptyModes = {}

	--Btn
	self.UnLoadBtnVisible = nil
	self.WearBtnVisible = nil
	self.WearBtnEnabled = nil

	self.MountState = nil
	self.ArmorState = nil


	self.DyeTargetNodeVisible = nil
	self.TargetColorValidVisible = nil
	self.TargetColorAboutVisible = nil
	self.TargetColorInvalidVisible = nil

	self.CurColor = nil
	self.CurColorNameText = nil
	self.CurColorRText = nil
	self.CurColorGText = nil
	self.CurColorBText = nil

	self.TargetColor = nil
	self.TargetColorNameText = nil
	self.TargetColorRText = nil
	self.TargetColorGText = nil
	self.TargetColorBText = nil
	self.TargetColorR = nil
	self.TargetColorG = nil
	self.TargetColorB = nil

	self.DyeItemNameText = nil
	self.DyeItemRText = nil
	self.DyeItemGText = nil
	self.DyeItemBText = nil

	self.DyeItemAmountText = nil
	self.StainBtnEnabled = nil

	self.EquipmentCount = nil

	self.CurDyeColorType = nil
	self.DyeColorID = nil

	self.FruitNum = {}

	self.FastDyeItemListVisible = nil
	self.FastDyeFruitItemVMList = UIBindableList.New(ItemVM, {IsShowNumProgress = true, IsCanBeSelected = false})

	self.NormalDyeItemList01Visible = nil
	self.NormalDyeItemList02Visible = nil
	self.NormalDyeList = {}
	self.NormalDyeFruitItemVMList = UIBindableList.New(ItemVM, {IsShowNumProgress = true, IsCanBeSelected = false})
	self.NormalDyeUnselectedVisible = nil
	
	self.LockFastDyeText = nil
	self.FastDyeTipsText = nil
	self.FastDyeTipsColor = nil
	self.FastStainBtnEnabled = nil

	self.CDTimeText = nil
	--染色相关
	self.DyeLists = {}
	self.DyeType = ChocoboDyeType.ChocoboDyeTypeInvalid
	
	-- 陆行鸟
	self.IsShowChocoboName = false

	self.StainBtnVisible = nil
	self.BtnStain02Visible = nil

	self.ResID = nil -- 用于绑定获取途径
end

function BuddySurfaceVM:UpdateCurTabPage(Index)
	if Index == BuddySurfaceVM.MenuType.Equipment then
		self:ShowEquipmentPage()
	elseif Index == BuddySurfaceVM.MenuType.Dye then
		self:ShowDyePage()
	end
end

function BuddySurfaceVM:UpdateSubTabPage(Index)
	self:SetSubPageState(Index)
	if self.TabPageIndex == nil then
		return
	end

	if self.TabPageIndex == BuddySurfaceVM.MenuType.Equipment then
		self:UpdateEquipmentPanel()
	elseif self.TabPageIndex == BuddySurfaceVM.MenuType.Dye then
		self:UpdateDyePanel()
	end 
end

function BuddySurfaceVM:SelectedEquipmentItem(ID)
	for i = 1, self.EquipmentCount do
		local ItemVM = self.EquipmentItemVMList:Get(i)
		ItemVM:UpdateIconState(ID)	
	end
	self.EquipmentText = ItemUtil.GetItemName(ID) or ""

	if ID == nil then
		return
	end

	self.WearBtnEnabled = true
	self.UnLoadBtnVisible = false
	self.WearBtnVisible = true

	self.EquipmentID = ID

	local Armor = BuddyMgr:GetSurfaceArmor()
	if Armor == nil then
		return 
	end

	if ID == Armor.Head or ID == Armor.Body or ID == Armor.Feet then
		self.WearBtnVisible = false
		self.UnLoadBtnVisible = true
	end
end

function BuddySurfaceVM:UpdateChocoboInfo(ChocoboID)
	if ChocoboID > 0 then
		self.IsShowChocoboName = true
		--self.TitleText = _G.LSTR(1000012)
	else
		self.IsShowChocoboName = false
		--self.TitleText = _G.LSTR(1000013)
	end
end

function BuddySurfaceVM:UpdateIsShowChocobo()
	self.IsShowChocoboName = BuddyMgr.SurfaceViewCurID > 0
end

--普通染色，选中染色道具
function BuddySurfaceVM:SelectedDyeItem(ID)
	for i = 1, self.DyeItemVMList:Length() do
		local ItemVM = self.DyeItemVMList:Get(i)
		ItemVM:UpdateIconState(ID)	
	end

	self.DyeItemNameText = ItemUtil.GetItemName(ID)
	local DyeStuffCfg = ChocoboDyeStuffCfg:FindCfgByKey(ID)
	if DyeStuffCfg then
		self.DyeItemRText = DyeStuffCfg.R
		self.DyeItemGText = DyeStuffCfg.G
		self.DyeItemBText = DyeStuffCfg.B
	end

	self.DyeItemID = ID
	self.NormalDyeUnselectedVisible = not BuddyMgr:SurfaceBInDyeCD()
	self.NormalDyeItemList01Visible = true
	self.StainBtnVisible = not BuddyMgr:SurfaceBInDyeCD()

	self.ResID = ID
end

function BuddySurfaceVM:SetDyeItemAmount(Value)
	self.DyeItemAmountText = Value

	self.DyeType = ChocoboDyeType.ChocoboDyeTypeNormal

	local NeedAddItem = true
	for i = 1, #self.NormalDyeItemList do
		if self.NormalDyeItemList[i].ItemID == self.DyeItemID then
			if Value == 0 then
				table.remove(self.NormalDyeItemList, i)
				break
			end
			self.NormalDyeItemList[i].Num = Value
			NeedAddItem = false
			break
		end
	end

	if Value == 0 then
		NeedAddItem = false
	end 

	if NeedAddItem == true then
		table.insert(self.NormalDyeItemList, {ItemID = self.DyeItemID, Num = Value})
	end

	for i = 1, self.DyeItemVMList:Length() do
		local ItemVM = self.DyeItemVMList:Get(i)
		if ItemVM.ResID == self.DyeItemID then
			ItemVM:SetNumProgress(self.DyeItemID, Value)	
		end	
	end
	
	local DyeTargetColorCfg, TargetColorR, TargetColorG, TargetColorB = self:CalculateDyeTargetColor()
	self:RefreshBuddyTargetColorShow(DyeTargetColorCfg, TargetColorR, TargetColorG, TargetColorB)

	local ItemList = {}
	self.DyeLists = {}
	for i = 1, #self.NormalDyeItemList do
		local ItemID = self.NormalDyeItemList[i].ItemID
		local Num = self.NormalDyeItemList[i].Num
		if Num > 0 then
			table.insert(ItemList, ItemUtil.CreateItem(ItemID, Num))
			table.insert(self.DyeLists, {ResID = ItemID, Count = Num})
		end
	end

	self.NormalDyeItemList02Visible = #ItemList > 0
	self.NormalDyeFruitItemVMList:UpdateByValues(ItemList)
end

function BuddySurfaceVM:GetNormalDyeItemNum(ItemID)
	for i = 1, #self.NormalDyeItemList do
		if self.NormalDyeItemList[i].ItemID == ItemID then
			return self.NormalDyeItemList[i].Num
		end
	end
	return 0
end

function BuddySurfaceVM:CalculateDyeTargetColor()
	local TargetColorR = 0
	local TargetColorG = 0
	local TargetColorB = 0

	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor == nil then
		return nil, TargetColorR, TargetColorG, TargetColorB
	end
	local ColorCfg = BuddyColorCfg:FindCfgByKey(BuddyColor.RGB)
	if ColorCfg == nil then
		return nil, TargetColorR, TargetColorG, TargetColorB
	end

	local TargetColorR = ColorCfg.R
	local TargetColorG = ColorCfg.G
	local TargetColorB = ColorCfg.B

	for i = 1, #self.NormalDyeItemList do
		local ItemID = self.NormalDyeItemList[i].ItemID
		local Num = self.NormalDyeItemList[i].Num
		local DyeStuffCfg = ChocoboDyeStuffCfg:FindCfgByKey(ItemID)
		if DyeStuffCfg ~= nil then
			TargetColorR = TargetColorR + DyeStuffCfg.R * Num
			TargetColorG = TargetColorG + DyeStuffCfg.G * Num
			TargetColorB = TargetColorB + DyeStuffCfg.B * Num
		end
	end
	
	if self:IsColorOverBoundary(TargetColorR) or self:IsColorOverBoundary(TargetColorG) or self:IsColorOverBoundary(TargetColorB) then
		return nil, TargetColorR, TargetColorG, TargetColorB
	end

	local TargetColorCfg = nil
	local CfgList = BuddyColorCfg:FindAllCfg()
	local MinDiff = 255 + 255 + 255
	for _,CfgRow in ipairs(CfgList) do
		local Diff = math.abs(TargetColorR - CfgRow.R) + math.abs(TargetColorG - CfgRow.G) + math.abs(TargetColorB - CfgRow.B)
		if MinDiff > Diff then
			TargetColorCfg = CfgRow
			MinDiff = Diff
		end
   	end

	return TargetColorCfg, TargetColorR, TargetColorG, TargetColorB
end

function BuddySurfaceVM:IsColorOverBoundary(Value)
	if Value > 255 or Value < 0 then
		return true
	end
	return false
end

function BuddySurfaceVM:RefreshBuddyCurColorShow()
	self.DyeDescPanelVisible = false
	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor then
		local ColorCfg = BuddyColorCfg:FindCfgByKey(BuddyColor.RGB)
		if ColorCfg then
			self.DyeDescPanelVisible = true
			self.CurColor = string.format("#%02X%02X%02X", ColorCfg.R, ColorCfg.G, ColorCfg.B)
			self.CurColorNameText = ColorCfg.Name
			self.CurColorRText = ColorCfg.R
			self.CurColorGText = ColorCfg.G
			self.CurColorBText = ColorCfg.B
		end
	end

end

function BuddySurfaceVM:RefreshBuddyTargetColorShow(DyeTargetColorCfg, TargetColorR, TargetColorG, TargetColorB, HideShowSame)
	self.StainBtnEnabled = DyeTargetColorCfg ~= nil
	self.DyeTargetNodeVisible = true
	if DyeTargetColorCfg ~= nil then
		local SameWithCurColor = self:IsSameWithCurColor(DyeTargetColorCfg)
		self.StainBtnEnabled = not SameWithCurColor
		if HideShowSame and SameWithCurColor then
			self.DyeTargetNodeVisible = false
			return
		end
		self.TargetColorValidVisible = true
		self.TargetColorInvalidVisible = false
		self.DyeTargetColorID = DyeTargetColorCfg.ID
		self.TargetColor = string.format("#%02X%02X%02X", DyeTargetColorCfg.R, DyeTargetColorCfg.G, DyeTargetColorCfg.B)
		self.TargetColorNameText = string.format("%s", DyeTargetColorCfg.Name)
		self.TargetColorRText = TargetColorR
		self.TargetColorGText = TargetColorG
		self.TargetColorBText = TargetColorB
	else
		self.TargetColorValidVisible = false
		self.TargetColorAboutVisible = false
		self.TargetColorInvalidVisible = true
		self.TargetColorNameText = LSTR(1000014)
		self.TargetColorRText = TargetColorR
		self.TargetColorGText = TargetColorG
		self.TargetColorBText = TargetColorB
	end
	self.TargetColorR = self:IsColorOverBoundary(TargetColorR) and "dc5868" or "d5d5d5"
	self.TargetColorG = self:IsColorOverBoundary(TargetColorG) and "dc5868" or "d5d5d5"
	self.TargetColorB = self:IsColorOverBoundary(TargetColorB) and "dc5868" or "d5d5d5"

end

function BuddySurfaceVM:IsSameWithCurColor(DyeTargetColorCfg)
	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor == nil then
		return false
	end
	return DyeTargetColorCfg == BuddyColorCfg:FindCfgByKey(BuddyColor.RGB)
end


function BuddySurfaceVM:ShowEquipmentPage()
	self:SetCurrentPageState(BuddySurfaceVM.MenuType.Equipment)
	self.EquipmentPageVisible = true
	self.NormalDyePageVisible = false
	self.DyeCDPageVisible = false
	self.FastDyePageVisible = false
	self.ShowArmorBtnVisible = false
	self.DyeDescPanelVisible = false
	--self.SubTitleText = LSTR(1000015)
	self:InitEquipmentMenu()
	self:UpdateEquipmentPanel()
	self:UpdateIsShowChocobo()
end

function BuddySurfaceVM:ShowDyePage()
	self:SetCurrentPageState(BuddySurfaceVM.MenuType.Dye)
	self.EquipmentPageVisible = false
	self.FastDyePageVisible = false
	self.ShowArmorBtnVisible = true
	self.DyeDescPanelVisible = true
	self.IsShowChocoboName = false
	self.EquipmentText = ""
	--self.SubTitleText = LSTR(1000016)
	self:InitDyeMenu()
	self:UpdateDyePanel()
end


function BuddySurfaceVM:UpdateEquipmentPanel()
	local Armors = BuddyMgr:GetUsedArmors()
	local ItemList = {}
	if Armors then
		for i = 1, #Armors do
			local BuddyEquip = BuddyEquipCfg:FindCfgByKey(Armors[i])
			if BuddyEquip then
				if BuddyEquip.Part == EquipPart.EQUIP_PART_HEAD and self.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Head then
					table.insert(ItemList, {ResID = Armors[i]})
				elseif BuddyEquip.Part == EquipPart.EQUIP_PART_BODY and self.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Body then
					table.insert(ItemList, {ResID = Armors[i]})
				elseif BuddyEquip.Part == EquipPart.EQUIP_PART_LEG and self.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Leg then
					table.insert(ItemList, {ResID = Armors[i]})
				end
			end
		end
	end

	self.EquipmentCount = #ItemList

	ItemList = BagMainVM:FillCapacityByEmptyItem(ItemList, EquipmentCapacity - #ItemList)
	self.EquipmentItemVMList:UpdateByValues(ItemList)

	local SelectedEquipID = nil
	local Armor = BuddyMgr:GetSurfaceArmor()
	if self.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Head then
		if Armor ~= nil and Armor.Head >0 then
			SelectedEquipID = Armor.Head
		end
	elseif self.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Body then
		if Armor ~= nil and Armor.Body >0 then
			SelectedEquipID = Armor.Body
		end
	elseif self.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Leg then
		if Armor ~= nil and Armor.Feet > 0 then
			SelectedEquipID = Armor.Feet
		end
	end

	self:SelectedEquipmentItem(SelectedEquipID)

	if SelectedEquipID == nil then
		self.WearBtnVisible = true
		self.WearBtnEnabled = false
		self.UnLoadBtnVisible = false
	end

end

function BuddySurfaceVM:UpdateMountState()
	if self:BMountChecked() then
		self.MountState = EToggleButtonState.Unchecked
	else
		self.MountState = EToggleButtonState.Checked
	end
end

function BuddySurfaceVM:BMountChecked()
	return self.MountState == EToggleButtonState.Checked
end

function BuddySurfaceVM:SetMountUnchecked()
	self.MountState = EToggleButtonState.Unchecked
end

function BuddySurfaceVM:UpdateArmorState()
	if self:BArmorChecked() then
		self.ArmorState = EToggleButtonState.Unchecked
	else
		self.ArmorState = EToggleButtonState.Checked
	end
end

function BuddySurfaceVM:BArmorChecked()
	return self.ArmorState == EToggleButtonState.Checked
end

function BuddySurfaceVM:SetArmorChecked()
	self.ArmorState = EToggleButtonState.Checked
end

function BuddySurfaceVM:UpdateDyePanel()
	if self.SubTabIndex == BuddySurfaceVM.DyeMenuType.Normal then
		self:UpdateDyeNormalPanel()
	elseif self.SubTabIndex == BuddySurfaceVM.DyeMenuType.Fast then
		self:UpdateDyeFastPanel()
	end
	self.TargetColorAboutVisible = self.SubTabIndex == BuddySurfaceVM.DyeMenuType.Normal
	--初始颜色
	self:RefreshBuddyCurColorShow()

	--显示目标颜色
	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor then
		local TargetColorCfg = BuddyColorCfg:FindCfgByKey(BuddyColor.TargetRGB)
		if TargetColorCfg ~= nil then
			self:RefreshBuddyTargetColorShow(TargetColorCfg, TargetColorCfg.R, TargetColorCfg.G, TargetColorCfg.B, true)
		end
	end
end

function BuddySurfaceVM:UpdateDyeNormalPanel()
	local IsCD = BuddyMgr:SurfaceBInDyeCD()
	self:SetNormalDyeCDVisible(IsCD)

	local ItemList = {}
	local CfgList = ChocoboDyeStuffCfg:FindAllCfg()
	for _, CfgItem in ipairs(CfgList) do
		table.insert(ItemList, {ResID = CfgItem.ItemID})
	end
	
	ItemList = BagMainVM:FillCapacityByEmptyItem(ItemList, FoodCapacity - #ItemList)
	

	self.DyeItemVMList:UpdateByValues(ItemList)
	self.NormalDyeUnselectedVisible = false
	self.NormalDyeItemList = {}
	self.NormalDyeItemList02Visible = false

	if IsCD then
		self:SelectedDyeItem(ItemList[1].ResID)
	end
end


function BuddySurfaceVM:SetNormalDyeCDVisible(IsCD)
	self.DyeCDPageVisible = IsCD
	self.NormalDyeItemList01Visible = IsCD
	self.DyeTargetNodeVisible = IsCD
	self.StainBtnVisible = false

	self.NormalDyePageVisible = true
	self.FastDyePageVisible = false
end

function BuddySurfaceVM:UpdateDyeFastPanel()
	local IsCD = BuddyMgr:SurfaceBInDyeCD()
	self:SetFastDyeCDVisible(IsCD)
	local ColorValueList = BuddyDefine.ColorValue
    if ColorValueList == nil or next(ColorValueList) == nil then
        return
    end

	self.DyeColorTypeVMList:UpdateByValues(ColorValueList)

	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor then
		local ColorCfg = BuddyColorCfg:FindCfgByKey(BuddyColor.RGB)
		if ColorCfg then
			self:SetDyeColorTypeState(ColorCfg.Type)
		end
	end
end

function BuddySurfaceVM:SetFastDyeCDVisible(IsCD)
	self.DyeCDPageVisible = IsCD
	self.BtnStain02Visible = not IsCD

	self.NormalDyePageVisible = false
	self.FastDyePageVisible = true
end

function BuddySurfaceVM.SortDyeColorList(Left, Right)
	if Left.Sort ~= Right.Sort then
		--Sort小的排前面
		return Left.Sort < Right.Sort
	end

	return false
end

function BuddySurfaceVM:SetDyeColorTypeState(type)
	self.CurDyeColorType = type
	for i = 1, self.DyeColorTypeVMList:Length() do
		local ItemVM = self.DyeColorTypeVMList:Get(i)
		ItemVM:UpdateIconState(type)	
	end

	local CfgSearchCond = string.format("Type == %d", type)
	local DyeColorCfgList = BuddyColorCfg:FindAllCfg(CfgSearchCond)
	table.sort(DyeColorCfgList, self.SortDyeColorList)
	
	DyeColorCfgList = BagMainVM:FillCapacityByEmptyItem(DyeColorCfgList, ColorCapacity - #DyeColorCfgList)

	self.DyeColorVMList:UpdateByValues(DyeColorCfgList)

	self.DyeTargetNodeVisible = false
	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor then
		self:SetDyeColorItem(BuddyColor.RGB)
	end

end

function BuddySurfaceVM:SetDyeColorItem(ColorID)
	self.DyeColorID = ColorID
	local IsLock = false
	for i = 1, self.DyeColorVMList:Length() do
		local ItemVM = self.DyeColorVMList:Get(i)
		ItemVM:UpdateIconState(ColorID)	
		if ColorID == ItemVM.ColorID then
			IsLock = ItemVM.bIsLocked
		end
	end

	local ColorCfg = BuddyColorCfg:FindCfgByKey(ColorID)
	self:RefreshBuddyTargetColorShow(ColorCfg, ColorCfg.R, ColorCfg.G, ColorCfg.B)
	local IsCD = BuddyMgr:SurfaceBInDyeCD()
	if IsCD then
		self.LockFastDyeText = ""
		self.FastDyeItemListVisible = false
		return
	end

	self:SetFastDyeByColorAndLock(ColorCfg, IsLock)
end

function BuddySurfaceVM:SetFastDyeByColorAndLock(ColorCfg, IsLock)
	local SameWithCurColor = self:IsSameWithCurColor(ColorCfg)
	
	if not SameWithCurColor then
		if IsLock then
			self.FastDyeItemListVisible = false
			self.LockFastDyeText = LSTR(1000017)
			self.FastStainBtnEnabled = false
		else
			self.FastDyeItemListVisible = true
			self.LockFastDyeText = ""
			if ColorCfg.DyeItemID > 0 then
				local ItemList= {}
				table.insert(ItemList, ItemUtil.CreateItem(ColorCfg.DyeItemID, 1))
				self.DyeType = ChocoboDyeType.ChocoboDyeTypeSpecial
				self.DyeLists = {}
				table.insert(self.DyeLists, {ResID = ColorCfg.DyeItemID, Count = 1})
				self.FastDyeFruitItemVMList:UpdateByValues(ItemList)
				self.FastDyeTipsText = LSTR(1000018) 
				self.FastDyeTipsColor = "828282"
				self.FastStainBtnEnabled = true
			else
				local BuddyColor = BuddyMgr:GetSurfaceColor()
				if BuddyColor then
					local CurColorCfg = BuddyColorCfg:FindCfgByKey(BuddyColor.RGB)
					if CurColorCfg then
						self:CalculateConsumeFruit(ColorCfg.R - CurColorCfg.R, ColorCfg.G - CurColorCfg.G, ColorCfg.B - CurColorCfg.B)
					end
				end
			end
			
		end
	else
		self.FastDyeItemListVisible = false
		self.LockFastDyeText = LSTR(1000019)
		self.FastStainBtnEnabled = false
	end
end

function BuddySurfaceVM:CalculateConsumeFruit(DiffR, DiffG, DiffB)
	self:ClearFruitNum()
	
	local RTemp = DiffG + DiffB
	if RTemp > 0 then
		local RNum = math.ceil(RTemp / FruitBasis)
		self.FruitNum[FruitCombination.PlusFruit[1]] = self.FruitNum[FruitCombination.PlusFruit[1]] + RNum
	elseif RTemp < 0 then
		local RNum = math.floor(RTemp / FruitBasis)
		self.FruitNum[FruitCombination.NegativeFruit[1]]= self.FruitNum[FruitCombination.NegativeFruit[1]] - RNum

	end

	local GTemp = DiffR + DiffB
	if GTemp > 0 then
		local GNum = math.ceil(GTemp / FruitBasis)
		self.FruitNum[FruitCombination.PlusFruit[2]] = self.FruitNum[FruitCombination.PlusFruit[2]] + GNum
	elseif GTemp < 0 then
		local GNum = math.floor(GTemp / FruitBasis)
		self.FruitNum[FruitCombination.NegativeFruit[2]] = self.FruitNum[FruitCombination.NegativeFruit[2]] - GNum

	end

	local BTemp = DiffR + DiffG
	if BTemp > 0 then
		local BNum = math.ceil(BTemp / FruitBasis)
		self.FruitNum[FruitCombination.PlusFruit[3]] = self.FruitNum[FruitCombination.PlusFruit[3]] + BNum
	elseif BTemp < 0 then
		local BNum = math.floor(BTemp / FruitBasis)
		self.FruitNum[FruitCombination.NegativeFruit[3]] = self.FruitNum[FruitCombination.NegativeFruit[3]] - BNum

	end

	local HasFruit = true
	local ItemList= {}
	self.DyeType = ChocoboDyeType.ChocoboDyeTypeFast
	self.DyeLists = {}
	for key, value in pairs(self.FruitNum) do
		if value > 0 then
			if BagMgr:GetItemNum(key) < value then
				HasFruit = false
			end
			table.insert(ItemList, ItemUtil.CreateItem(key, value))
			table.insert(self.DyeLists, {ResID = key, Count = value})
		end
	end

	self.FastDyeFruitItemVMList:UpdateByValues(ItemList)

	if HasFruit == false then
		self.FastDyeTipsText = LSTR(1000020) 
		self.FastDyeTipsColor = "dc5868"
		self.FastStainBtnEnabled = false
	else
		self.FastDyeTipsText = LSTR(1000018) 
		self.FastDyeTipsColor = "828282"
		self.FastStainBtnEnabled = BuddyMgr:SurfaceBInDyeCD()  == false
	end
	
end

function BuddySurfaceVM:ClearFruitNum()
	local CfgList = ChocoboDyeStuffCfg:FindAllCfg()
	for _, CfgItem in ipairs(CfgList) do
		local ItemID = CfgItem.ItemID
		self.FruitNum[ItemID] = 0
	end
end

function BuddySurfaceVM:SetCurrentPageState(Index)
	self.TabPageIndex = Index
	--[[for i = 1, self.TabPageVMList:Length() do
		local ItemVM = self.TabPageVMList:Get(i)
		ItemVM:UpdateIconState(Index)	
	end]]--
end

function BuddySurfaceVM:SetSubPageState(Index)
	self.SubTabIndex = Index
	for i = 1, self.SubTabVMList:Length() do
		local ItemVM = self.SubTabVMList:Get(i)
		ItemVM:UpdateIconState(Index)	
	end

end

--[[function BuddySurfaceVM:InitPageMenu()
	local ItemList = {}
	table.insert(ItemList, {Index = BuddySurfaceVM.MenuType.Equipment, ImgIcon = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Tab01_png.UI_Buddy_Icon_Surface_Tab01_png'", SelectedIcon = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Tab01_Select_png.UI_Buddy_Icon_Surface_Tab01_Select_png'"})
	--table.insert(ItemList, {Index = BuddySurfaceVM.MenuType.Dye, ImgIcon = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Tab02_png.UI_Buddy_Icon_Surface_Tab02_png'", SelectedIcon = "PaperSprite'/Game/UI/Atlas/Buddy/Frames/UI_Buddy_Icon_Surface_Tab02_Select_png.UI_Buddy_Icon_Surface_Tab02_Select_png'"})

	self.TabPageVMList:UpdateByValues(ItemList)
end]]--

function BuddySurfaceVM:InitEquipmentMenu()
	local ItemList = {}
	table.insert(ItemList, {Index = BuddySurfaceVM.EquipmentMenuType.Head, Text = LSTR(1000021)})
	table.insert(ItemList, {Index = BuddySurfaceVM.EquipmentMenuType.Body, Text = LSTR(1000022)})
	table.insert(ItemList, {Index = BuddySurfaceVM.EquipmentMenuType.Leg, Text = LSTR(1000023)})

	self.SubTabVMList:UpdateByValues(ItemList)
	self:SetSubPageState(BuddySurfaceVM.EquipmentMenuType.Head)
end

function BuddySurfaceVM:InitDyeMenu()
	local ItemList = {}
	table.insert(ItemList, {Index = BuddySurfaceVM.DyeMenuType.Normal, Text = LSTR(1000024)})
	table.insert(ItemList, {Index = BuddySurfaceVM.DyeMenuType.Fast, Text = LSTR(1000025)})

	self.SubTabVMList:UpdateByValues(ItemList)
	self:SetSubPageState(BuddySurfaceVM.DyeMenuType.Normal)
end



function BuddySurfaceVM:SetCDOnTime()
	local LetfTime = BuddyMgr:GetSurfaceCDTime()
	if  LetfTime > 0 then
		self.CDTimeText = DateTimeTools.TimeFormat(LetfTime, "hh:mm:ss", false)
	else
		if self.TabPageIndex == BuddySurfaceVM.MenuType.Dye and self.SubTabIndex == BuddySurfaceVM.DyeMenuType.Normal then
			self:UpdateDyeNormalPanel()
		end
	end
end


--要返回当前类
return BuddySurfaceVM