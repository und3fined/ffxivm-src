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
local ShopTabItemNewVM = require("Game/Shop/ItemVM/ShopTabItemNewVM")
local ShopMgr = require("Game/Shop/ShopMgr")

---@class ShopTabListItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewTab UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopTabListItemNewView = LuaClass(UIView, true)

function ShopTabListItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewTab = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopTabListItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopTabListItemNewView:OnInit()
	self.OnSelectionChanged = WidgetCallback.New()
	self.MenuAdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnSelectChanged, true)
	self.TabList = {}
	--self.Menu:SetOnClickedCallback(self.OnSelectChanged)
end

function ShopTabListItemNewView:OnDestroy()
	self.OnSelectionChanged:Clear()
	self.OnSelectionChanged = nil
end

function ShopTabListItemNewView:OnShow()
	--self:SetSelectedIndex(1)
end

function ShopTabListItemNewView:OnHide()

end

function ShopTabListItemNewView:OnRegisterUIEvent()

end

function ShopTabListItemNewView:OnRegisterGameEvent()

end

function ShopTabListItemNewView:OnRegisterBinder()

end

function ShopTabListItemNewView:OnSelectChanged(Index, ItemData, ItemView)
	self.OnSelectionChanged:OnTriggered(Index, ItemData, ItemView)
end

function ShopTabListItemNewView:UpdateItems(List)
	local ItemS = { }
	for i=1 ,#List do
		local ViewModel = ShopTabItemNewVM.New()
		List[i].Index = i
		ViewModel:UpdateVM(List[i])
		table.insert(ItemS,ViewModel)

	end
	self.TabList = ItemS
	local Menu = self.MenuAdapterTableView
	Menu:UpdateAll(ItemS)
end

function ShopTabListItemNewView:SetSelectedIndex(Index)
	self.MenuAdapterTableView:SetSelectedIndex(Index)
end

function ShopTabListItemNewView:SetTabIndex(Index)
	--ShopMgr.ShopMainIndex = Index
end

function ShopTabListItemNewView:CancelSelected()
	self.MenuAdapterTableView:CancelSelected()
end

return ShopTabListItemNewView