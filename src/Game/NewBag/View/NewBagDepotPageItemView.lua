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
local DepotVM = require("Game/Depot/DepotVM")
local DepotMgr = _G.DepotMgr
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

---@class NewBagDepotPageItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewItem UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewBagDepotPageItemView = LuaClass(UIView, true)

function NewBagDepotPageItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewBagDepotPageItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewBagDepotPageItemView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItem, nil, true)
	self.TableViewAdapter:SetOnClickedCallback(self.OnItemClicked)
	self.TableViewAdapter:SetOnDoubleClickedCallback(self.OnItemDoubleClicked)

	self.Binders = {
		{ "DepotListItem", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
	}
end

function NewBagDepotPageItemView:OnDestroy()

end

function NewBagDepotPageItemView:OnShow()
end

function NewBagDepotPageItemView:OnHide()

end

function NewBagDepotPageItemView:OnRegisterUIEvent()

end

function NewBagDepotPageItemView:OnRegisterGameEvent()

end

function NewBagDepotPageItemView:OnRegisterBinder()
	self:RegisterBinders(DepotVM, self.Binders)
end

function NewBagDepotPageItemView:OnItemClicked(Index, ItemData, ItemView)
	if UIViewMgr:IsViewVisible(UIViewID.BagItemTips) then
		UIViewMgr:HideView(UIViewID.BagItemTips)
	end

	local function Callback()
		ItemData:SetItemSelected(false)
	end

	if ItemData == nil or not ItemData.IsValid then
		return
	end

	ItemData:SetItemSelected(true)
	local Params = {ItemData = ItemData.Item, SlotView = ItemView, DepotIndex = Index, HideCallback = Callback}
	UIViewMgr:ShowView(UIViewID.BagItemTips, Params)
end

function NewBagDepotPageItemView:OnItemDoubleClicked(Index, ItemData, ItemView)
	DepotMgr:SendMsgDepotTransfer(DepotVM:GetCurDepotIndex(), Index, ItemData.GID)
end

return NewBagDepotPageItemView