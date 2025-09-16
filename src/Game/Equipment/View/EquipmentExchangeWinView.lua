---
--- Author: Administrator
--- DateTime: 2024-11-17 16:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local EquipmentExchangeVM = require("Game/Equipment/VM/EquipmentExchangeWinVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local CS_CMD = ProtoCS.CS_CMD
local CS_EQUIP_CMD = ProtoCS.CS_EQUIP_CMD

--binder
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

--cfg
local EquipReceiptCfg = require("TableCfg/EquipReceiptCfg")
local EquipImproveMaterialCfg = require("TableCfg/EquipImproveMaterialCfg")

---@class EquipmentExchangeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSwitch UFButton
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field Comm96Slot CommBackpack96SlotView
---@field CommBtn CommBtnLView
---@field FTextBlock_101 UFTextBlock
---@field InforBtn CommInforBtnView
---@field SingleBox CommSingleBoxView
---@field TableViewList UTableView
---@field TextHint UFTextBlock
---@field TextSelectQuantity UFTextBlock
---@field TextSlot UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentExchangeWinView = LuaClass(UIView, true)

function EquipmentExchangeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSwitch = nil
	--self.Comm2FrameL_UIBP = nil
	--self.Comm96Slot = nil
	--self.CommBtn = nil
	--self.FTextBlock_101 = nil
	--self.InforBtn = nil
	--self.SingleBox = nil
	--self.TableViewList = nil
	--self.TextHint = nil
	--self.TextSelectQuantity = nil
	--self.TextSlot = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentExchangeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.CommBtn)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentExchangeWinView:OnInit()
	self.TotalMaterial = 0
	self.ViewModel = EquipmentExchangeVM.New()
	self.AdapterTabTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.UpdateSelectNum, false)
	self.AdapterTabTableView:SetScrollbarIsVisible(false)
end

function EquipmentExchangeWinView:OnDestroy()

end

function EquipmentExchangeWinView:OnShow()
	self.InforBtn.HelpInfoID = 11096
	self:InitTableList()
	self:UpdateSelectNum()
	self:UpdateExchangeItem()
	local SwitchNum = _G.EquipmentMgr:GetSwitchMaterialListNum()
	UIUtil.SetIsVisible(self.BtnSwitch, SwitchNum and SwitchNum > 1, true)
	self.SingleBox.TextContent:SetText(LSTR(1050168))
	self.CommBtn.TextContent:SetText(LSTR(1050169))
	self.FTextBlock_101:SetText(LSTR(1050170))
	self.TextTitle:SetText(LSTR(1050016))
	self.SingleBox.ToggleButton:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, true)
	UIUtil.SetIsVisible(self.Comm2FrameL_UIBP.FText_Title, false)
end

function EquipmentExchangeWinView:OnHide()
	self.TotalMaterial = 0
	self.ItemVM1 = nil
end

function EquipmentExchangeWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.SwitchExchangeItem)
	UIUtil.AddOnClickedEvent(self, self.CommBtn.Button, self.CheckCanSendMsg)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox.ToggleButton, self.OnFinishToggleBtnStateChange)
end

function EquipmentExchangeWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ExchangeNumUpdate, self.UpdateSelectNum)
	self:RegisterGameEvent(_G.EventID.ExchangeIndexChange, self.UpdateSelectItem)
	self:RegisterGameEvent(_G.EventID.ExchangeNetEvent, self.OnEquipExchangeReceipt)
end

function EquipmentExchangeWinView:OnEquipExchangeReceipt()
	self:InitTableList()
	self:UpdateSelectNum()
	self:UpdateExchangeItem()
	self.SingleBox.ToggleButton:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, true)
end

function EquipmentExchangeWinView:OnRegisterBinder()
	local binder = {
		{ "TabList", UIBinderUpdateBindableList.New(self, self.AdapterTabTableView) },
	}
	self:RegisterBinders(self.ViewModel, binder)
end

function EquipmentExchangeWinView:UpdateExchangeItem()
	local ItemID = self.Params.ItemID
	if not self.ItemVM1 then
		self.ItemVM1 = ItemVM.New()
	end
	local Cfg = EquipImproveMaterialCfg:FindCfgByKey(self.Params.ItemID)
	self.ItemVM1.IsQualityVisible = true 
	self.ItemVM1.ItemQualityIcon = ItemUtil.GetItemColorIcon(ItemID)
	self.ItemVM1.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ItemID))
	self.ItemVM1.IsValid = true
	self.ItemVM1.HideItemLevel = true
	self.ItemVM1.NumVisible = true
	self.ItemVM1.Num = self.TotalMaterial or 0
	self.Comm96Slot:SetParams({ Data = self.ItemVM1 })
	
	self.TextSlot:SetText(ItemUtil.GetItemName(ItemID))
	self.TextHint:SetText(Cfg and Cfg.Desc or "")

	local CallBack = function ()
		if self.Params.ItemID and self.Params.ItemID ~= 0 then
			ItemTipsUtil.ShowTipsByResID(self.Params.ItemID, self.Comm96Slot, nil, nil, 30)
		end
	end
	self.Comm96Slot:SetClickButtonCallback(self, CallBack)
end

function EquipmentExchangeWinView:SwitchExchangeItem()
	_G.UIViewMgr:ShowView(_G.UIViewID.EquipmentSwitchWinView, {ItemType = 2, SelectID = self.Params.ItemID})
end

function EquipmentExchangeWinView:InitTableList()
	--背包和身上的装备都需要查
	local BagEquipments = _G.BagMgr:FindItemsByItemType(ProtoCommon.ITEM_TYPE.ITEM_TYPE_EQUIP)
	local TableList = {}
	--查背包 
	if BagEquipments and next(BagEquipments) then
		for k, v in pairs(BagEquipments) do
			local Cfg = EquipReceiptCfg:CheckEquipCanExchange(v.ResID, self.Params.ItemID)
			if Cfg and next(Cfg) then
				local ItemData = {
					GID = v.GID,
					Cfg = Cfg,
					isChoise = false,
				}
				table.insert(TableList, ItemData)
			end
		end
	end
	self.ViewModel.TabList = TableList
end

function EquipmentExchangeWinView:UpdateSelectNum()
	local TotalSelectNum = 0
	local TotalExchangeNum = 0
	local TotalMaterial = 0
	if self.ViewModel.TabList and next(self.ViewModel.TabList) then
		TotalExchangeNum = #self.ViewModel.TabList
		for key, value in pairs(self.ViewModel.TabList) do
			if value.isChoise then
				TotalSelectNum = TotalSelectNum + 1
				TotalMaterial = TotalMaterial + value.Cfg.Num
			end
		end
	end
	self.TotalMaterial = TotalMaterial
	self.Comm96Slot:SetNum(self.TotalMaterial or 0)
	self.CommBtn:SetIsEnabled(TotalSelectNum > 0, true)
	self.TextSelectQuantity:SetText(string.format(_G.LSTR(1050058), TotalSelectNum, TotalExchangeNum))
end

function EquipmentExchangeWinView:UpdateSelectItem(Params)
	self.Params.ItemID = Params
	self:InitTableList()
	self:UpdateSelectNum()
	self:UpdateExchangeItem()
	self.SingleBox.ToggleButton:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, true)
end

function EquipmentExchangeWinView:CheckCanSendMsg()
	local Num = 0
	for k, v in pairs(self.ViewModel.TabList) do
		if v.isChoise then
			Num = Num + 1
		end
	end
	if Num <= 0 then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1050127))
		return
	end
	--检查是否装备中
	for k, v in pairs(self.ViewModel.TabList) do
		if v.isChoise then
			--魔晶石
			local Item = _G.EquipmentMgr:GetItemByGID(v.GID)
			if Item and Item.Attr and Item.Attr.Equip and Item.Attr.Equip.GemInfo and Item.Attr.Equip.GemInfo.CarryList then
				if next(Item.Attr.Equip.GemInfo.CarryList) then
					local Content = _G.LSTR(1050073)
					_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1050083), Content, self.SendExchangeMsg, nil, LSTR(1050044), LSTR(1050104))
					return
				end
			end
			--套装
			local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
			for key, value in pairs(RoleDetail.Prof.ProfList) do
				local Equipscheme = value.EquipScheme
				if Equipscheme and next(Equipscheme) then
					for _, data in pairs(Equipscheme) do
						if v.GID == data.GID then
							local Content = _G.LSTR(1050072)
							_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1050083), Content, self.SendExchangeMsg, nil, LSTR(1050044), LSTR(1050104))
							return
						end
					end
				end
			end
		end
	end
	self:SendExchangeMsg()
end

function EquipmentExchangeWinView:SendExchangeMsg()
	local MsgID = CS_CMD.CS_CMD_EQUIPMENT
	local SubMsgID = CS_EQUIP_CMD.CS_CMD_EQUIP_EXCHANGE_RECEIPT
	local ExchangeTable = {}
	for k, v in pairs(self.ViewModel.TabList) do
		if v.isChoise then
			table.insert(ExchangeTable, v.Cfg.ID)
		end
	end
	local MsgBody = {
		SubCmd = SubMsgID,
		["ExchangeReceipt"] = {
			ConsumeID = ExchangeTable,
		}
	}
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function EquipmentExchangeWinView:OnFinishToggleBtnStateChange(ToggleButton, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local TotalSelectNum = 0
	local TotalExchangeNum = 0
	local TotalMaterial = 0
	if self.ViewModel.TabList and next(self.ViewModel.TabList) then
		TotalExchangeNum = #self.ViewModel.TabList
		for key, value in pairs(self.ViewModel.TabList) do
		   value.isChoise = IsChecked
		   TotalSelectNum = IsChecked and TotalSelectNum + 1 or TotalSelectNum
		   if IsChecked then
				TotalMaterial = TotalMaterial + value.Cfg.Num
		   else
				TotalMaterial = 0
		   end
		end
	end
	self.TotalMaterial = TotalMaterial
	self.Comm96Slot:SetNum(self.TotalMaterial or 0)
	self.TextSelectQuantity:SetText(string.format(_G.LSTR(1050058), TotalSelectNum, TotalExchangeNum))
	self.AdapterTabTableView:UpdateAll(self.ViewModel.TabList)
	self.CommBtn:SetIsEnabled(TotalSelectNum > 0, true)
end


return EquipmentExchangeWinView