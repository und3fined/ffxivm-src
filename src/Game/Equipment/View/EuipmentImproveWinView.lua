---
--- Author: Administrator
--- DateTime: 2024-11-17 23:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local ProtoCS = require("Protocol/ProtoCS")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local CS_CMD = ProtoCS.CS_CMD
local CS_EQUIP_CMD = ProtoCS.CS_EQUIP_CMD

local ItemCfg = require("TableCfg/ItemCfg")
local EquipImproveCfg = require("TableCfg/EquipImproveCfg")
local EquipReceiptCfg = require("TableCfg/EquipReceiptCfg")
local EquipImproveMaterialCfg = require("TableCfg/EquipImproveMaterialCfg")

local OpenType = {
	Equipment = 1,
	Bag = 2
}
---@class EuipmentImproveWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoto UFButton
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field Comm96Slot CommBackpack96SlotView
---@field CommBtnL_UIBP CommBtnLView
---@field EuipmentSlot1 CommBackpack96SlotView
---@field EuipmentSlot2 CommBackpack96SlotView
---@field InforBtn CommInforBtnView
---@field PanelGotoExchange UFCanvasPanel
---@field RichTextNumeric URichTextBox
---@field TextEuipment1 UFTextBlock
---@field TextEuipment2 UFTextBlock
---@field TextExchange UFTextBlock
---@field TextNumeric UFTextBlock
---@field TextSlot UFTextBlock
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EuipmentImproveWinView = LuaClass(UIView, true)

function EuipmentImproveWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoto = nil
	--self.Comm2FrameM_UIBP = nil
	--self.Comm96Slot = nil
	--self.CommBtnL_UIBP = nil
	--self.EuipmentSlot1 = nil
	--self.EuipmentSlot2 = nil
	--self.InforBtn = nil
	--self.PanelGotoExchange = nil
	--self.RichTextNumeric = nil
	--self.TextEuipment1 = nil
	--self.TextEuipment2 = nil
	--self.TextExchange = nil
	--self.TextNumeric = nil
	--self.TextSlot = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EuipmentImproveWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.Comm96Slot)
	self:AddSubView(self.CommBtnL_UIBP)
	self:AddSubView(self.EuipmentSlot1)
	self:AddSubView(self.EuipmentSlot2)
	self:AddSubView(self.InforBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EuipmentImproveWinView:OnInit()

end

function EuipmentImproveWinView:OnDestroy()

end
	
function EuipmentImproveWinView:OnShow()
	self.HasNum = 0
	self.MaterialID = 0 
	self.NeedNum = 0
	self.InforBtn.HelpInfoID = 11088
	UIUtil.SetIsVisible(self.Comm2FrameM_UIBP.FText_Title, false)
	local Type = self.Params and self.Params.OpenType or nil
	UIUtil.SetIsVisible(self.BtnSwitch, Type == OpenType.Equipment, true)
	self:UpdateView()
	self:CheckCanGotoExchange()
	self.TextTitle:SetText(LSTR(1050123))
	self.TextHint:SetText(LSTR(1050159))
	self.TextExchange:SetText(LSTR(1050016))
	self.CommBtnL_UIBP.TextContent:SetText(LSTR(1050084))
end

function EuipmentImproveWinView:UpdateView()
	local ItemID = self.Params.EquipID
	if not self.ItemVM1 then
		self.ItemVM1 = ItemVM.New()
	end
	local Item1Score = 0
	self.ItemVM1.IsQualityVisible = true 
	self.ItemVM1.ItemQualityIcon = ItemUtil.GetItemColorIcon(ItemID)
	self.ItemVM1.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ItemID))
	self.ItemVM1.IsValid = true
	self.ItemVM1.Num = 1
	self.ItemVM1.HideItemLevel = true
	self.ItemVM1.NumVisible = false
	self.EuipmentSlot1:SetParams({ Data = self.ItemVM1 })
	self.TextEuipment1:SetText(ItemUtil.GetItemName(ItemID))
	local EquipItemCfg = ItemCfg:FindCfgByKey(ItemID)
	if (EquipItemCfg) then
		Item1Score = EquipItemCfg.ItemLevel or 0
		self.TextNumeric:SetText(Item1Score)
	end 
	--检查背包或者身上有没有多余的装备
	local EquipmentTable = _G.EquipmentMgr:GetCanImproveEquipment()
	local Type = self.Params and self.Params.OpenType or nil
	if Type == OpenType.Equipment and EquipmentTable and next(EquipmentTable) and #EquipmentTable > 1 then
		UIUtil.SetIsVisible(self.BtnSwitch, true, true)
	else
		UIUtil.SetIsVisible(self.BtnSwitch, false, true)
	end
	local CallBack = function ()
		ItemTipsUtil.ShowTipsByResID(ItemID, self.EuipmentSlot1, nil, nil, 30)
	end
	self.EuipmentSlot1:SetClickButtonCallback(self, CallBack)
	local IsEnough = _G.EquipmentMgr:GetImproveMaterialEnough(self.Params.EquipID)
	self.CommBtnL_UIBP:SetIsEnabled(IsEnough, true)
	
	local Cfg = EquipImproveCfg:FindCfgByKey(ItemID)
	local MaterialID = Cfg and Cfg.MaterialID or 0
	self.MaterialID = MaterialID
	if not self.ItemVM2 then
		self.ItemVM2 = ItemVM.New()
	end
	self.ItemVM2.IsQualityVisible = true 
	self.ItemVM2.ItemQualityIcon = ItemUtil.GetItemColorIcon(MaterialID)
	self.ItemVM2.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(MaterialID))
	self.ItemVM2.IsValid = true
	local NeedNum = Cfg and Cfg.Num or 1
	local HasNum = _G.BagMgr:GetItemNum(tonumber(MaterialID))
	local ColorStr = HasNum < NeedNum and "<span color=\"#d05758\">" or "<span color=\"#d5d5d5\">"
	self.ItemVM2.Num = string.format("%s%d</>/%d", ColorStr, HasNum, Cfg.Num or 1)
	self.ItemVM2.HideItemLevel = true
	self.ItemVM2.NumVisible = true
	self.Comm96Slot:SetParams({ Data = self.ItemVM2 })
	self.TextSlot:SetText(ItemUtil.GetItemName(MaterialID))
	self.NeedNum = NeedNum
	self.HasNum = HasNum

	local CallBack2 = function ()
		if MaterialID and MaterialID ~= 0 then
			ItemTipsUtil.ShowTipsByResID(MaterialID, self.Comm96Slot, nil, nil, 30)
		end
	end
	self.Comm96Slot:SetClickButtonCallback(self, CallBack2)

	local ExchangeID = Cfg.ImprovedID or 0
	if not self.ItemVM3 then
		self.ItemVM3 = ItemVM.New()
	end
	self.ItemVM3.IsQualityVisible = true 
	self.ItemVM3.ItemQualityIcon = ItemUtil.GetItemColorIcon(ExchangeID)
	self.ItemVM3.Icon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ExchangeID))
	self.ItemVM3.IsValid = true
	self.ItemVM3.HideItemLevel = true
	self.ItemVM3.NumVisible = false
	self.EuipmentSlot2:SetParams({ Data = self.ItemVM3 })
	self.TextEuipment2:SetText(ItemUtil.GetItemName(ExchangeID))
	local ExchangeIDItemCfg = ItemCfg:FindCfgByKey(ExchangeID)
	if (ExchangeIDItemCfg) then
		local Score = ExchangeIDItemCfg.ItemLevel or 0
		self.RichTextNumeric:SetText(Score)
	end

	local CallBack3 = function ()
		ItemTipsUtil.ShowTipsByResID(ExchangeID, self.EuipmentSlot2, nil, nil, 30)
	end
	self.EuipmentSlot2:SetClickButtonCallback(self, CallBack3)
end

function EuipmentImproveWinView:OpenSwitchPanel()
	_G.UIViewMgr:ShowView(_G.UIViewID.EquipmentSwitchWinView, {ItemType = 1, SelectID = self.Params.EquipID})
end

function EuipmentImproveWinView:OnHide()
	self.HasNum = 0
	self.MaterialID = 0
	self.NeedNum = 0 
end

function EuipmentImproveWinView:CheckCanGotoExchange()
	local CanExchange = EquipImproveMaterialCfg:GetCanExchange(self.MaterialID)
	UIUtil.SetIsVisible(self.PanelGotoExchange, CanExchange)
end

function EuipmentImproveWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OpenSwitchPanel)
	UIUtil.AddOnClickedEvent(self, self.CommBtnL_UIBP.Button, self.SendImproveMsg)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto, self.OpenExchangeView)
end

function EuipmentImproveWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ImproveIndexChange, self.UpdateSelectItem)
	self:RegisterGameEvent(_G.EventID.ExchangeNetEvent, self.Hide)
	self:RegisterGameEvent(_G.EventID.LootItemUpdateRes, self.OnLootItemUpdateRes)
end

function EuipmentImproveWinView:OnLootItemUpdateRes(InLootList, InReason)
	if not InLootList or not next(InLootList) then
        return
    end
	for key, value in pairs(InLootList) do
		-- body
		if value.Item and value.Item.ResID == self.MaterialID then
			self:UpdateView()
			self:CheckCanGotoExchange()
		end
	end
end

function EuipmentImproveWinView:UpdateSelectItem(Params)
	self.Params.EquipID = Params
	self:UpdateView()
	self:CheckCanGotoExchange()
end

function EuipmentImproveWinView:OpenExchangeView()
	local IsInVersion = EquipImproveMaterialCfg:CheckIsInVersion(self.MaterialID)
	if IsInVersion then
		_G.UIViewMgr:ShowView(_G.UIViewID.EquipmentExchangeWinView,{ItemID = self.MaterialID})
	else
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1050130))
	end
end

function EuipmentImproveWinView:CheckCanSendImprove()
	--先判断装备数量
	local HasEquipmentNum = _G.BagMgr:GetItemNum(tonumber(self.Params.EquipID))
	if HasEquipmentNum < 0 then
		local ItemName = ItemUtil.GetItemName(self.Params.EquipID)
		_G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(1050112), ItemName))
		return false
	end
	
	--判断材料数量
	local HasMaterial =  _G.BagMgr:GetItemNum(tonumber(self.MaterialID))
	if HasMaterial < self.NeedNum then
		local ItemName = ItemUtil.GetItemName(self.MaterialID)
		_G.MsgTipsUtil.ShowTips(string.format(_G.LSTR(1050112), ItemName))
		return false
	end
	
	return true
end

function EuipmentImproveWinView:SendImproveMsg()
	if not self:CheckCanSendImprove() then
		return
	end
	local MsgID = CS_CMD.CS_CMD_EQUIPMENT
	local SubMsgID = CS_EQUIP_CMD.CS_CMD_EQUIP_IMPROVE
	local GID = self.Params.GID
	if not GID or GID <= 0 then
		return
	end
	local bEquiped = _G.EquipmentMgr:IsEquiped(GID)
	local EquipmentCfg = EquipmentCfg:FindCfgByEquipID(self.Params.EquipID)
	local MsgBody = {
		SubCmd = SubMsgID,
		["Improve"] = {
			ID = self.Params.EquipID,
			GID = GID,
			On = bEquiped,
		}
	}
	if not _G.EquipmentMgr:CheckCanOperate(LSTR(1050176)) then
		return
	end
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

return EuipmentImproveWinView