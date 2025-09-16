---
--- Author: Administrator
--- DateTime: 2023-10-13 15:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WidgetCallback = require("UI/WidgetCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ShopTabItemVM = require("Game/Shop/ItemVM/ShopTabItemVM")
local ShopMgr = require("Game/Shop/ShopMgr")
local ShopTabListItemVM = require("Game/Shop/ItemVM/ShopTabListItemVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")


---@class ShopTabListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewTab UTableView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopTabListItemView = LuaClass(UIView, true)

function ShopTabListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewTab = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopTabListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopTabListItemView:OnInit()
	self.OnSelectionChanged = WidgetCallback.New()
	self.ViewModel = ShopTabListItemVM.New()
	self.Menu = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnSelectChanged, true)
	self.Binders = {
		{ "CurTabList", UIBinderUpdateBindableList.New(self, self.Menu) },
	}
	--self.Menu:SetOnClickedCallback(self.OnSelectChanged)
	self.IsShow = false
end

function ShopTabListItemView:OnDestroy()
	self.OnSelectionChanged:Clear()
	self.OnSelectionChanged = nil
end

function ShopTabListItemView:OnShow()
	local Index, IsAutoLv = ShopMgr:GetCurTabInfoFitLv()
	--通过物品跳转商店或直接跳转商店
	if ShopMgr.JumpToShop or ShopMgr.JumpToGoodsState or ShopMgr.IsJumpAgain then
		self:SetSelectedIndex(self.CurJumpIndex or ShopMgr:GetJumpType() or 1)
	else
		if IsAutoLv then
			self:SetSelectedIndex(Index)
		else
			self:SetSelectedIndex(ShopMgr.LashChosedIndexList[ShopMgr.CurOpenMallId] or 1)
		end
	end
end

function ShopTabListItemView:OnHide()

end

function ShopTabListItemView:OnRegisterUIEvent()

end

function ShopTabListItemView:OnRegisterGameEvent()

end

function ShopTabListItemView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ShopTabListItemView:OnSelectChanged(Index, ItemData, ItemView)
	self.OnSelectionChanged:OnTriggered(Index, ItemData, ItemView)
end

function ShopTabListItemView:UpdateItems(List)
	self.ViewModel:UpdateTabList(List)
	if ShopMgr.JumpToShop or ShopMgr.JumpToGoodsState then
		for Index, Value in ipairs(List) do
			if Value.FirstType == ShopMgr.ShopMainTypeIndex then
				self.CurJumpIndex = Index
				break
			end
		end
	end
end

function ShopTabListItemView:SetSelectedIndex(Index)
	self.Menu:SetSelectedIndex(Index)
end

function ShopTabListItemView:SetTabIndex(Index)
	--ShopMgr.ShopMainIndex = Index
end

function ShopTabListItemView:CancelSelected()
	self.Menu:CancelSelected()
end

return ShopTabListItemView