---
--- Author: Administrator
--- DateTime: 2023-12-05 16:11
--- Description:
---

---
--- Author: Administrator
--- DateTime: 2023-09-05 15:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local ArmyMgr = nil
local BagMgr = nil
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyDepotPanelVM = nil
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL

---@class ArmyDepotPageItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewItem UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyDepotPageItemView = LuaClass(UIView, true)

function ArmyDepotPageItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyDepotPageItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyDepotPageItemView:OnInit()
	ArmyMgr = require("Game/Army/ArmyMgr")
	BagMgr = require("Game/Bag/BagMgr")
	ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItem, nil, true)
	self.TableViewAdapter:SetOnClickedCallback(self.OnItemClicked)
	self.TableViewAdapter:SetOnDoubleClickedCallback(self.OnItemDoubleClicked)
	--- 缓存的已点击表，防止快速点击带来的重复发送
	self.DoubleClickedItemList = {}
	self.Binders = {
		{ "BindableListItem", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
	}
end

function ArmyDepotPageItemView:OnDestroy()

end

function ArmyDepotPageItemView:OnShow()
end

function ArmyDepotPageItemView:OnHide()
	self:UnRegisterAllTimer()
	self.DoubleClickedItemList = {}
end

function ArmyDepotPageItemView:OnRegisterUIEvent()

end

function ArmyDepotPageItemView:OnRegisterGameEvent()

end

function ArmyDepotPageItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function ArmyDepotPageItemView:OnItemClicked(Index, ItemData, ItemView)
	if UIViewMgr:IsViewVisible(UIViewID.ArmyItemTips) then
		UIViewMgr:HideView(UIViewID.ArmyItemTips)
	end

	local function Callback()
		ItemData:SetItemSelected(false)
	end

	if ItemData == nil or not ItemData.IsValid then
		return
	end

	ItemData:SetItemSelected(true)
	local Params = {ItemData = ItemData.Item, SlotView = ItemView, DepotIndex = Index, HideCallback = Callback}
	UIViewMgr:ShowView(UIViewID.ArmyItemTips, Params)
end

function ArmyDepotPageItemView:OnItemDoubleClicked(Index, ItemData, ItemView)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local ItemResID = ItemData.ResID
	local Cfg = ItemCfg:FindCfgByKey(ItemResID)
	if Cfg == nil then
		return
	end

	for _, GID in ipairs(self.DoubleClickedItemList) do
		if ItemData.GID == GID then
			return
		end
	end
	table.insert(self.DoubleClickedItemList, ItemData.GID)
	self:RegisterTimer(function() 
		if #self.DoubleClickedItemList > 0  then 
			table.remove(self.DoubleClickedItemList, 1) 
		end 
	end, 0.6)
	---背包是否已满判断,
	local IsBagFull = BagMgr:GetBagLeftNum() == 0
	if IsBagFull then
		-- LSTR string:背包空间不足
		MsgTipsUtil.ShowTips(LSTR(910210)) 
	elseif not ArmyDepotPanelVM:IsAvailableCurDepot() then
		---暂无权限，请联系管理者
		MsgTipsUtil.ShowTipsByID(145010)
	elseif not ItemData.IsBind and Cfg.ItemType ~= ITEM_TYPE_DETAIL.MISCELLANY_TASKONLY then
		ArmyMgr:SendGroupStoreFetChItemAndCheck(ViewModel.PageIndex, ItemData.GID, ItemData.ResID, ItemData.Num )
	end

end

return ArmyDepotPageItemView
