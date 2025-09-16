---
--- Author: Administrator
--- DateTime: 2024-11-17 20:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local EquipmentSwitchVM = require("Game/Equipment/VM/EquipmentSwitchWinVM")

--cfg
local EquipImproveMaterialCfg = require("TableCfg/EquipImproveMaterialCfg")
local EquipReceiptCfg = require("TableCfg/EquipReceiptCfg")

--binder
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class EquipmentSwitchWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommBtnL_UIBP CommBtnLView
---@field TableView_104 UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentSwitchWinView = LuaClass(UIView, true)

local ItemType = {
	Equipment = 1,
	Material = 2
}

function EquipmentSwitchWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.CommBtnL_UIBP = nil
	--self.TableView_104 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentSwitchWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommBtnL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentSwitchWinView:OnInit()
	self.ViewModel = EquipmentSwitchVM.New()
	self.AdapterTabTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_104, self.UpdateSelect, false)
	self.AdapterTabTableView:SetScrollbarIsVisible(false)
end

function EquipmentSwitchWinView:OnDestroy()

end

function EquipmentSwitchWinView:OnShow()
	if self.Params and self.Params.ItemType then
		self:UpdateTableList(self.Params.ItemType)
	end
	self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(1050156))
	self.CommBtnL_UIBP.TextContent:SetText(LSTR(1050160))
end

function EquipmentSwitchWinView:UpdateTableList(Type)
	local TableList = {}
	local SelectIndex = 1
	if Type == ItemType.Material then
		self.ViewModel.Title = LSTR(1050029)
		local Cfg = EquipImproveMaterialCfg:FindAllCfg()
		if Cfg and next(Cfg) then
			for key, value in pairs(Cfg) do
				--判断版本号
				local VersionName = value.Version
				local InVersion = _G.EquipmentMgr:BeIncludedInGameVersion(VersionName)
				local CanExchange = EquipImproveMaterialCfg:GetCanExchange(value.ID)
				if InVersion and CanExchange then
					local Data = {
						ItemID = value.ID,
						ItemType = Type,
					}
					if value.ID == self.Params.SelectID then
						SelectIndex = key
					end
					table.insert(TableList, Data)
				end
			end
		end
	else
		self.ViewModel.Title = LSTR(1050030)
		local EquipmentTable = _G.EquipmentMgr:GetCanImproveEquipment()
		if EquipmentTable and next(EquipmentTable) then
			for key, value in pairs(EquipmentTable) do
				local Data = {
					ItemID = value.ResID,
					ItemType = Type,
					Part = value.Part,
					ItemLevel = value.ItemLevel,
				}
				if value.ResID == self.Params.SelectID then
					SelectIndex = key
				end
				table.insert(TableList, Data)
			end
			table.sort(TableList, function(a, b)
				--品级相同按照部位排
				if a.ItemLevel == b.ItemLevel then
					return a.Part < b.Part
				else
					return a.ItemLevel > b.ItemLevel
				end
			end)
		end
	end
	
	self.ViewModel.TabList = TableList
	self.AdapterTabTableView:ScrollToIndex(SelectIndex)
	self.AdapterTabTableView:SetSelectedIndex(SelectIndex)
end

function EquipmentSwitchWinView:OnHide()

end

function EquipmentSwitchWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnL_UIBP.Button, self.SendChangeEvent)
end

function EquipmentSwitchWinView:OnRegisterGameEvent()

end

function EquipmentSwitchWinView:OnRegisterBinder()
	local binder = {
		{ "Title", UIBinderSetText.New(self, self.Comm2FrameM_UIBP.FText_Title) },
		{ "TabList", UIBinderUpdateBindableList.New(self, self.AdapterTabTableView) },
	}
	self:RegisterBinders(self.ViewModel, binder)
end

function EquipmentSwitchWinView:UpdateSelect(Index, ItemData, ItemView)
	self.SelectIndex = Index
end

function EquipmentSwitchWinView:SendChangeEvent()
	if self.SelectIndex then
		local ItemID = self.ViewModel.TabList[self.SelectIndex].ItemID
		if self.Params and self.Params.ItemType then
			if self.Params.ItemType == ItemType.Equipment then
				_G.EventMgr:SendEvent(EventID.ImproveIndexChange, ItemID)
			else
				_G.EventMgr:SendEvent(EventID.ExchangeIndexChange, ItemID)
			end
		end
	end
	self:Hide()
end

return EquipmentSwitchWinView