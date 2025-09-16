---
--- Author: Administrator
--- DateTime: 2024-02-27 19:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderCommBtnUpdateImage = require("Binder/UIBinderCommBtnUpdateImage")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local WardrobeUnlockPanelVM = require("Game/Wardrobe/VM/WardrobeUnlockPanelVM")
local ItemVM = require("Game/Item/ItemVM")

local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local UIViewID = require("Define/UIViewID")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local UKismetInputLibrary = UE.UKismetInputLibrary
local EventID = _G.EventID
local LSTR

---@class WardrobeUnlockPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AppearancePage WardrobeAppearancePageView
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnMoney2 UFButton
---@field BtnUnlock CommBtnLView
---@field CommonBkg CommonBkg01View
---@field CommonTitle CommonTitleView
---@field HorizontalCurrent2 UFHorizontalBox
---@field ImgMask UFImage
---@field ImgMoney2 UFImage
---@field MoneySlot CommMoneySlotView
---@field PanelBg UFCanvasPanel
---@field PanelTab UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field PositionList UFCanvasPanel
---@field SingleBox CommSingleBoxView
---@field TabList UTableView
---@field TableViewPosition UTableView
---@field TextAll UFTextBlock
---@field TextAllNum UFTextBlock
---@field TextCurrentPrice2 UFTextBlock
---@field TextSubtitle URichTextBox
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeUnlockPanelView = LuaClass(UIView, true)

function WardrobeUnlockPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AppearancePage = nil
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnMoney2 = nil
	--self.BtnUnlock = nil
	--self.CommonBkg = nil
	--self.CommonTitle = nil
	--self.HorizontalCurrent2 = nil
	--self.ImgMask = nil
	--self.ImgMoney2 = nil
	--self.MoneySlot = nil
	--self.PanelBg = nil
	--self.PanelTab = nil
	--self.PanelTitle = nil
	--self.PositionList = nil
	--self.SingleBox = nil
	--self.TabList = nil
	--self.TableViewPosition = nil
	--self.TextAll = nil
	--self.TextAllNum = nil
	--self.TextCurrentPrice2 = nil
	--self.TextSubtitle = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeUnlockPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AppearancePage)
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnUnlock)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.MoneySlot)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeUnlockPanelView:OnInit()

	self.VM = WardrobeUnlockPanelVM

	self.AppearanceTabListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPosition, self.OnAppearanceTabListChanged, true)
	self.AppearanceListAdapter  = UIAdapterTableView.CreateAdapter(self, self.TabList, self.OnAppearanceListChanged, true)
	
	self.Binders = {
		{ "AppearanceTabList",  UIBinderUpdateBindableList.New(self, self.AppearanceTabListAdapter)},
		{ "AppearanceList",  UIBinderUpdateBindableList.New(self, self.AppearanceListAdapter)},
		{ "CostMoney", UIBinderSetText.New(self, self.TextCurrentPrice2)},
		{ "AllNum", UIBinderSetText.New(self, self.TextAllNum)},
		{ "UnlockBtnState", UIBinderCommBtnUpdateImage.New(self, self.BtnUnlock)},
		{ "UnlockBtnTxtColor", UIBinderSetColorAndOpacityHex.New(self, self.BtnUnlock)},
		{ "AllCheckedState", UIBinderSetIsChecked.New(self, self.SingleBox)},
		{ "HorizontalCurrent2Visible", UIBinderSetIsVisible.New(self, self.HorizontalCurrent2)},
		{ "Subtitle", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle)},
		{ "CostMoneyColor", UIBinderSetColorAndOpacityHex.New(self, self.TextCurrentPrice2)},
	}

	self.IsQuickUnlock = false
	self.IsFirstEnter = true
	self.CurAppID = nil
	self.CurPartID = nil
	self.SelectedAppID = nil
	self.Common_Render2D_UIBP = nil
	self.SuperView = nil
	self.AutoSelected = false
	LSTR = _G.LSTR

end

function WardrobeUnlockPanelView:OnDestroy()
	self.CurAppID = nil
	self.CurPartID = nil
	self.IsFirstEnter = true
end

function WardrobeUnlockPanelView:OnShow()
	
	if self.Params == nil then
		return
	end
	self.IsFirstEnter = true
	UIUtil.SetIsVisible(self.CommonBkg, false)
	UIUtil.SetIsVisible(self.PanelTitle, false)
	self.Common_Render2D_UIBP = self.Params.SuperView.Common_Render2D_UIBP
	self.SuperView = self.Params.SuperView

	self.MoneySlot:UpdateView(WardrobeDefine.NormalItemID, false)
	self.BtnBack:AddBackClick(self, function () self.SuperView.ShowMainPanel(self.SuperView, true) self:Hide() end)

	if self.Params.AppearanceList == nil then
		return
	end

	-- self.Params.IsQuickUnlock 为 true 不勾选，
	self.IsQuickUnlock = false
	if  (self.Params ~= nil and self.Params.IsQuickUnlock ~= nil) then
		self.IsQuickUnlock = self.Params.IsQuickUnlock
	end

	self.SelectedAppID = self.Params.SelectedAppID
	self.VM:UpdateAppearanceTabList(self.Params.AppearanceList, self.IsQuickUnlock)
	self:SetAppearanceTabSelectIndex(self.Params.SelectedAppID, self.IsQuickUnlock)
	self:RefreshUnlockCheck()

	self:InitText()

	self.IsFirstEnter = false
end

function WardrobeUnlockPanelView:InitText()
	self.CommonTitle.TextTitleName:SetText(_G.LSTR(1080077))	-- 快捷解锁
	self.TextAll:SetText(_G.LSTR(1080078))  -- 全选
	self.BtnUnlock:SetText(_G.LSTR(1080061))
end

function WardrobeUnlockPanelView:RefreshUnlockCheck()
	if not self.Params.IsQuickUnlock then
		local AppearanceItem = self.Params.SelectedAppID

		for i = 1, self.AppearanceListAdapter:GetNum() do
			local ItemVM = self.AppearanceListAdapter:GetItemDataByIndex(i)
			if ItemVM ~= nil then
				if ItemVM.ID == AppearanceItem then
					self.VM:CheckItemByIndex(i)
					self.AppearanceListAdapter:ScrollToIndex(i)
					return
				end
			end
		end
	end
end

function WardrobeUnlockPanelView:OnHide()
	self.VM:ClearList()
	self.AutoSelected = false
	self.IsFirstEnter = true
end

function WardrobeUnlockPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnUnlock, self.OnClickedBtnUnlock)
	UIUtil.AddOnClickedEvent(self, self.BtnMoney2, self.OnClickedBtnMoney)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox.ToggleButton, self.OnAppearanceListCheckedChanged)
end

function WardrobeUnlockPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WardrobeUnlockUpdate, self.OnAppearanceListUnlockUpdate)
	self:RegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)

end

function WardrobeUnlockPanelView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
	self.AppearancePage:SetParams({Data = self.VM.AppearancePageVM})
end


function WardrobeUnlockPanelView:OnPreprocessedMouseButtonDown(MouseEvent)

	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	-- 点击的区域不是
	local ViewID = UIViewID.ItemTips
	local ExistView = _G.UIViewMgr:FindView(ViewID)
	if ExistView  ~= nil then
		if not UIUtil.IsUnderLocation(self.AppearancePage.TableViewSwitchList, MousePosition) and not UIUtil.IsUnderLocation(ExistView.PanelTips, MousePosition)  then
			self.AppearancePage:ClearSwitchList()
			self.AppearancePage:ClearBindSelected()
		end
	else
		if not UIUtil.IsUnderLocation(self.AppearancePage.TableViewSwitchList, MousePosition)  then
			self.AppearancePage:ClearSwitchList()
			self.AppearancePage:ClearBindSelected()
		end
	end
	
end

function WardrobeUnlockPanelView:OnBagUpdate()
	self.MoneySlot:UpdateView(WardrobeDefine.NormalItemID, false)
	self.VM:UpdateAppearanceListCheckStateData()
end

function WardrobeUnlockPanelView:SetAppearanceTabSelectIndex(SelectedAppID, IsQuickLock)
	local SelectIndex = 1
	if not IsQuickLock then
		if SelectedAppID ~= nil then
			local AppearanceItem = SelectedAppID
			local PartID = WardrobeUtil.GetPartIDByAppearanceID(AppearanceItem)
			if PartID == ProtoCommon.equip_part.EQUIP_PART_FINGER then
				PartID = ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER
			end
			for i = 1, self.AppearanceTabListAdapter:GetNum() do
				local ItemVM = self.AppearanceTabListAdapter:GetItemDataByIndex(i)
				if ItemVM ~= nil then
					local Cfg = ClosetCfg:FindCfgByKey(AppearanceItem)
					if Cfg ~= nil then
						if ItemVM.ID == PartID then
							self.AutoSelected = true
							self.AppearanceTabListAdapter:SetSelectedIndex(i)
							self.AppearanceTabListAdapter:ScrollToIndex(i)
							return 
						end
					end
				end
			end
		end
	end

	self.AppearanceTabListAdapter:SetSelectedIndex(SelectIndex)
end

function WardrobeUnlockPanelView:OnAppearanceTabListChanged(Index, ItemData, ItemView)
	-- 更新当前界面
	local ID = ItemData.ID
	self.CurPartID = ID
	local Subtitle = ProtoEnumAlias.GetAlias(ProtoCommon.equip_part, ID)
	if ID == ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER or ID == ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER then
		Subtitle = LSTR(1080047)
	end
	self.VM.Subtitle = ID == 0 and _G.LSTR(1080037) or Subtitle
	local IsChecked = self.VM.AllCheckedState
	if self.IsFirstEnter then
		if self.IsQuickUnlock then
			IsChecked = false
		else
			IsChecked = false
		end
	end
	self.VM:UpdateAppearanceList(ID, self:GetNotUnlockList(), IsChecked, self.SelectedAppID)
	if self.AutoSelected then
		local AppearanceItem = self.Params.SelectedAppID
		if AppearanceItem then
			for i = 1, self.AppearanceListAdapter:GetNum() do
				local ItemVM = self.AppearanceListAdapter:GetItemDataByIndex(i)
				if ItemVM ~= nil then
					if ItemVM.ID == AppearanceItem then
						self.AppearanceListAdapter:SetSelectedIndex(i)
						self.AutoSelected = false
						return
					end
				end
			end
		end
		self.AutoSelected = false
	else
		self.AppearanceListAdapter:SetSelectedIndex(1)
	end
end

function WardrobeUnlockPanelView:ClearOlderApp()
	if self.CurAppID ~= nil then
		local OldAppID = self.CurAppID
		local OldEquipementID = WardrobeUtil.GetWeaponEquipIDByAppearanceID(OldAppID)
		local Cfg = EquipmentCfg:FindCfgByKey(OldEquipementID)
		if  Cfg ~= nil  then
			local EquipList = EquipmentVM.ItemList
			local PartID = Cfg.Part
			for _ , part in pairs(WardrobeDefine.EquipmentTab) do
				if PartID == part then
					local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
					if CurrentAppID ~= 0 then
						local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
						local ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
						local TempRegionDye = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
						local RegionDye = WardrobeUtil.GetRegionDye(CurrentAppID, TempRegionDye)
						local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(CurrentAppID)
						self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, IsAppRegionDye and 0 or ColorID)
						self:StainPartForSection(CurrentAppID, part, RegionDye)
					else
						local TempEquip = EquipList[part]
						if TempEquip ~= nil then
							local EquipID = TempEquip.ResID
							self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, 0)
						else
							self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
						end
					end
				end
			end
		end
	end
end

function WardrobeUnlockPanelView:OnAppearanceListChanged(Index, ItemData, ItemView)
	-- 把之前的外观给清除了
	self:ClearOlderApp()

	-- 更新App
	local ID = ItemData.ID
	self.CurAppID = ID
	self.AppearancePage:SetCurAppearanceID(ID)
	self.VM:UpdateInfo(ID)
	self.AppearancePage:ClearBindSelected()

	--判断是否能否预览
	local IsUnlock = WardrobeMgr:GetIsUnlock(ID)
	local EquipementID = WardrobeMgr:IsRandomAppID(ID) and  WardrobeMgr:GetEquipIDByRandomApp(ID) or WardrobeUtil.GetEquipIDByAppearanceID(ID)
	if IsUnlock then
		local CanEquiped = WardrobeMgr:CanEquipedAppearanceByServerData(ID)
		local CanPreview = WardrobeMgr:CanPreviewAppearanceByServerData(ID)
		if CanEquiped then
			self:PreviewEquipment(EquipementID)
		else
			if CanPreview then
				self:PreviewEquipment(EquipementID)
			else
				MsgTipsUtil.ShowTips(LSTR(1080024))
				return
			end
		end
		return
	end

	local CanEquipedClient = WardrobeMgr:CanEquipedAppearanceByClientData(ID)
	local CanPreviewClient = WardrobeMgr:CanPreviewAppearanceByClientData(ID)
	if CanEquipedClient then
		self:PreviewEquipment(EquipementID)
	else
		if CanPreviewClient then
			self:PreviewEquipment(EquipementID)
		else
			MsgTipsUtil.ShowTips(LSTR(1080024))
			return
		end
	end
end

function WardrobeUnlockPanelView:OnAppearanceListUnlockUpdate()
	local NotUnlockList = self:GetNotUnlockList()

	if table.empty(NotUnlockList) then
		WardrobeMgr:ClearPlanUnlockAppearanceList()
		self.SuperView.ShowMainPanel(self.SuperView, true) self:Hide()
		return
	end

	-- 更新当前界面, 
	local List = self.VM:UpdateAppearanceList(self.CurPartID, NotUnlockList, nil, nil)
	if #List > 0 then
		self.AppearanceListAdapter:SetSelectedIndex(1)
	else
		self.AppearanceTabListAdapter:SetSelectedIndex(1)
	end

end

function WardrobeUnlockPanelView:GetNotUnlockList()
	local NotUnlockList = {}
	local List = WardrobeMgr:GetPlanUnlockAppearanceList()
	for _, id in ipairs(List) do
		local IsUnlock = WardrobeMgr:GetIsUnlock(id)
		local HasReduce = WardrobeMgr:IsLessReduceConditionEquipment(id)
		if not IsUnlock or HasReduce then
			table.insert(NotUnlockList, id)
		end
	end

	return NotUnlockList
end

function WardrobeUnlockPanelView:OnAppearanceListCheckedChanged(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local MaxUnlockNum = WardrobeMgr:GetMaxUnlockNum()
	local Length = self.AppearanceListAdapter:GetNum()
	local Num = 0
	for index = 1, Length do
		local ItemVM = self.AppearanceListAdapter:GetItemDataByIndex(index)
		if not IsChecked then
			ItemVM.CheckedState = IsChecked
		else
			if index > MaxUnlockNum then
				ItemVM.CheckedState = false
			else
				ItemVM.CheckedState = IsChecked
				Num =  Num + 1
			end
		end
	end

	if Num >= MaxUnlockNum then
		self.SingleBox.ToggleButton:SetChecked(false, false)
		MsgTipsUtil.ShowTips(_G.LSTR(1080127))
	end
	
	self.VM:UpdateAppearanceListCheckStateData()
end

function WardrobeUnlockPanelView:CalcItemCheckedState()
	local CheckNum = 0
	local Length = self.AppearanceListAdapter:GetNum()

	for index = 1, Length do
		local ItemData = self.AppearanceListAdapter:GetItemDataByIndex(index)
		if ItemData ~= nil and ItemData.CheckedState then
			CheckNum = CheckNum + 1
		end
	end

	return CheckNum
end

function WardrobeUnlockPanelView:OnClickedBtnMoney()
	local Item = ItemUtil.CreateItem(WardrobeDefine.NormalItemID)
	local Length = self.AppearanceListAdapter:GetNum()

	local TotalNum = 0
	for index = 1, Length do
		local ItemData = self.AppearanceListAdapter:GetItemDataByIndex(index)
		local CheckedState = ItemData.CheckedState
		if CheckedState then
			local Cfg = ClosetCfg:FindCfgByKey(ItemData.ID)
			if Cfg ~= nil and not WardrobeUtil.GetIsSpecial(ItemData.ID) then
				TotalNum = TotalNum + 1
			end
		end
	end
	Item.NeedBuyNum = TotalNum - _G.BagMgr:GetItemNum(WardrobeDefine.NormalItemID)
	ItemTipsUtil.ShowTipsByItem(Item, self.HorizontalCurrent2)
end

--全部解锁
function WardrobeUnlockPanelView:OnClickedBtnUnlock()
	--Todo 打开二级菜单
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CLOSET_UNLOCK, true) then
		return
	end

	local CheckedNum = self:CalcItemCheckedState()

	if CheckedNum == 0 then
		MsgTipsUtil.ShowTips(_G.LSTR(1080123)) --暂无选中的外观
		return
	end

	local Length = self.AppearanceListAdapter:GetNum()

	local TotalNum = 0
	for index = 1, Length do
		local ItemData = self.AppearanceListAdapter:GetItemDataByIndex(index)
		local CheckedState = ItemData.CheckedState
		if CheckedState then
			local Cfg = ClosetCfg:FindCfgByKey(ItemData.ID)
			if Cfg ~= nil and not WardrobeUtil.GetIsSpecial(ItemData.ID) then
				TotalNum = TotalNum + 1
			end
		end
	end

	
	if TotalNum > 0 then
		if not (_G.BagMgr:GetItemNum(WardrobeDefine.NormalItemID) >= TotalNum) then
			local function GoShopping()
				local Cfg = ItemUtil.GetItemGetWayList(WardrobeDefine.NormalItemID)
				if table.length(Cfg) > 0 then
					local Item = ItemUtil.CreateItem(WardrobeDefine.NormalItemID)
					-- Item.NeedBuyNum = TotalNum -  _G.BagMgr:GetItemNum(WardrobeDefine.NormalItemID)
					Cfg[1].TransferData = {}
					Cfg[1].TransferData.NeedBuyNum =  TotalNum - _G.BagMgr:GetItemNum(WardrobeDefine.NormalItemID)
					ItemUtil.JumpGetWayByItemData(Cfg[1])
				end
			end
	
			local RichTextUtil = require("Utils/RichTextUtil")
			local QuantityText = string.format(LSTR("%s/%d"), RichTextUtil.GetText(_G.BagMgr:GetItemNum(WardrobeDefine.NormalItemID), "dc5868"), TotalNum)
			local CostText = string.format(LSTR(1080101), RichTextUtil.GetText(ItemUtil.GetItemName(WardrobeDefine.NormalItemID), "d1ba8e"))
			local Params = {ItemResID = WardrobeDefine.NormalItemID, TextQuantity = QuantityText}
					_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(620039), CostText, GoShopping, nil, LSTR(620011), LSTR(620029), Params)
			return
		end
	end

	for index = 1, Length do
		local ItemData = self.AppearanceListAdapter:GetItemDataByIndex(index)
		local CheckedState = ItemData.CheckedState
		if CheckedState then
			-- 检查是否有特殊外观
			if WardrobeUtil.GetIsSpecial(ItemData.ID) then
				local ItemID = WardrobeUtil.GetUnlockCostItemID(ItemData.ID)
				if not (_G.BagMgr:GetItemNum(ItemID) >= WardrobeUtil.GetUnlockCostItemNum(ItemData.ID)) then
					MsgTipsUtil.ShowTips(string.format(_G.LSTR(1080048), ItemUtil.GetItemName(ItemID)))
					return
				end 
			end
			
			-- 检查是否有传奇武器
			local AchievementIDList = WardrobeUtil.GetAchievementIDList(ItemData.ID)
			if not table.is_nil_empty(AchievementIDList) then
				for index, value in ipairs(AchievementIDList) do
					if not _G.AchievementMgr:GetAchievementFinishState(value) then
						MsgTipsUtil.ShowTips(_G.LSTR(1080049))
						return
					end
				end
			end
		end 
	end

	local UnlockList = {}
	local UnlockGidsList = {}

	for index = 1, Length do
		local ItemData = self.AppearanceListAdapter:GetItemDataByIndex(index)
		if ItemData ~= nil and ItemData.CheckedState then
			local BindList = self.VM.AppearancePageVM:GetBindList()
			local GIDs = {}

			if WardrobeUtil.GetIsSpecial(ItemData.ID) then
				-- 插入解锁道具的GID
				local ItemID = WardrobeUtil.GetUnlockCostItemID(ItemData.ID)
				if _G.BagMgr:GetItemNum(ItemID) > 0 then
					local BagItem = _G.BagMgr:GetItemByResID(ItemID)
					if BagItem ~= nil then
						table.insert(GIDs, BagItem.GID)
					end
				end
			else

				local IsUnlock = WardrobeMgr:GetIsUnlock(ItemData.ID)
				if ItemData.ID == self.CurAppID then
					for i = 1, BindList:Length() do
						local ItemVM = BindList:Get(i)
						local GID = ItemVM.GID
						if GID ~= 0 then
							table.insert(GIDs, ItemVM.GID)
						end
					end
				else
					local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ItemData.ID)
					if not table.is_nil_empty(EquipmentCfgs) then
						for _, v in ipairs(EquipmentCfgs) do
							local ItemNum = _G.BagMgr:GetItemNum(v.ID) + _G.EquipmentMgr:GetEquipedItemNum(v.ID)
							if IsUnlock then
								if  ItemNum > 0 and WardrobeMgr:IsLessReduceConditionEquipment(ItemData.ID, v.ID) then
									local BagItem = _G.BagMgr:GetItemByResID(v.ID)
									local EquipedItem = _G.EquipmentMgr:GetEquipedItemByResID(v.ID)
									if EquipedItem ~= nil then
										table.insert(GIDs, EquipedItem.GID)
									end
									if BagItem ~= nil then
										table.insert(GIDs, BagItem.GID)
									end
								end
							else
								if ItemNum > 0 then
									local BagItem = _G.BagMgr:GetItemByResID(v.ID)
									local EquipedItem = _G.EquipmentMgr:GetEquipedItemByResID(v.ID)
									if EquipedItem ~= nil then
										table.insert(GIDs, EquipedItem.GID)
									end
									if BagItem ~= nil then
										table.insert(GIDs, BagItem.GID)
									end
								end
							end
						end
					end
				end
			end

			table.insert(UnlockList, {ID = ItemData.ID, GIDs = GIDs})
			table.insert(UnlockGidsList, GIDs)
		end
	end

	-- local TipsText1 = RichTextUtil.GetText(LSTR(1080050), WardrobeDefine.TxtColor.WarningColor, 0, nil)
	local TipsText = LSTR(1080051)
	
	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1080052), 
									 TipsText, 
									 function ()
										WardrobeMgr:SetUnlockGidsList(UnlockGidsList)
										WardrobeMgr:SendClosetUnLockReq(UnlockList)
									 end, 
									 nil,
									 LSTR(1080043),LSTR(1080044)
									)
	
end

function WardrobeUnlockPanelView:PreviewEquipment(EquipmentID)
	if EquipmentID == nil then
		return
	end

	local Cfg = EquipmentCfg:FindCfgByKey(EquipmentID)
	if Cfg ~= nil then
		local Part = Cfg.Part
		-- 如果当前部位是手指，
		if Part == ProtoCommon.equip_part.EQUIP_PART_FINGER then
			local SuperViewPartID = self.SuperView.CurPartID
			if SuperViewPartID ==  ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER or SuperViewPartID ==  ProtoCommon.equip_part.EQUIP_PART_LEFT_FINGER then
				Part = self.SuperView.CurPartID
			else
				Part = ProtoCommon.equip_part.EQUIP_PART_RIGHT_FINGER
			end
		end
		
		if self.Common_Render2D_UIBP then
			self.Common_Render2D_UIBP:PreViewEquipment(EquipmentID, Part, 0)
		end
	end

end


function WardrobeUnlockPanelView:StainPartForSection(AppID, PartID, RegionDyes)
	if AppID == nil then
		return
	end

	for _, v in ipairs(RegionDyes or {}) do
		local SectionList = WardrobeUtil.ParseSectionIDList(AppID, v.ID)
		for _, sectionID in ipairs(SectionList) do
			self.Common_Render2D_UIBP:StainPartForSection(WardrobeDefine.StainPartType[PartID], sectionID, v.ColorID)
		end
	end	
end


return WardrobeUnlockPanelView