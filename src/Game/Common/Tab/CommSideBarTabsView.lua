---
--- Author: ccppeng
--- DateTime: 2024-10-29 10:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
---@class CommSideBarTabsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSideBarTabsView = LuaClass(UIView, true)

function CommSideBarTabsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSideBarTabsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSideBarTabsView:OnInit()
	self.TableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList,self.OnSelectChangedItem,true)
end

function CommSideBarTabsView:OnShow()
	if self.ViewModel and self.ViewModel.ParentVM then
		self:SetTabSelectByIndex(self.ViewModel.ParentVM.CurSelectIndex or 1)
	end
end

function CommSideBarTabsView:OnSelectChangedItem(Index, ItemData, ItemView)
	self.ViewModel:OnSelectChangedItem(Index, ItemData, ItemView)
end

function CommSideBarTabsView:SetTabSelectByIndex(Index)
	self.TableView:SetSelectedIndex(Index)
end

function CommSideBarTabsView:OnRegisterBinder()
	local ViewModel = self.Params
	self.ViewModel = ViewModel
	self.Binders = {
		{ "PublicItemVMList", 		UIBinderUpdateBindableList.New(self, self.TableView) },
	}
	self:RegisterBinders(self.ViewModel, self.Binders)
end


return CommSideBarTabsView