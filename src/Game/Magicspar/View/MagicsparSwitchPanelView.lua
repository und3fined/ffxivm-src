---
--- Author: jamiyang
--- DateTime: 2025-02-25 11:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local MagicsparDefine = require("Game/Magicspar/MagicsparDefine")
---- @Param {Key, GID, ResID}
---@class MagicsparSwitchPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field TableViewSlot UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparSwitchPanelView = LuaClass(UIView, true)

function MagicsparSwitchPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.TableViewSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparSwitchPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparSwitchPanelView:OnInit()
	self.CommonPopUpBG:SetCallback(self, self.OnClickedCallback)
	self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.SelectIndex = 0;
end

function MagicsparSwitchPanelView:OnDestroy()

end

function MagicsparSwitchPanelView:OnShow()
	self:UpdateShowList()
	if self.SelectIndex > 0 then
		self.TableViewListAdapter:SetSelectedIndex(self.SelectIndex)
	end
end

function MagicsparSwitchPanelView:OnHide()

end

function MagicsparSwitchPanelView:OnRegisterUIEvent()

end

function MagicsparSwitchPanelView:OnRegisterGameEvent()

end

function MagicsparSwitchPanelView:OnRegisterBinder()

end

function MagicsparSwitchPanelView:OnClickedCallback()
	UIViewMgr:HideView(UIViewID.MagicsparSwitchPanel)
end

function MagicsparSwitchPanelView:UpdateShowList()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ItemList = EquipmentVM.ItemList
	if (ItemList == nil) then return end
	local SwitchItem = {}

	for key, value in pairs(MagicsparDefine.MagicsparEquipSlot) do
		local Item = ItemList[value]
		local SlotItem = {Part = value, GID = nil, ResID = nil, bSelect = false}
		if Item ~= nil then
			SlotItem.GID = Item.GID
			SlotItem.ResID = Item.ResID
		end
		if Params.Part == value and Item ~= nil and
			Params.GID == SlotItem.GID and Params.ResID == SlotItem.ResID then
			SlotItem.bSelect = true
			self.SelectIndex = key
		end
		table.insert(SwitchItem, key, SlotItem)
	end
	self.TableViewListAdapter:UpdateAll(SwitchItem)
end

return MagicsparSwitchPanelView