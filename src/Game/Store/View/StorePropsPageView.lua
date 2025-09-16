
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local StoreDefine = require("Game/Store/StoreDefine")

---@class StorePropsPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewProps UTableView
---@field TableViewSort UTableView
---@field AnimDyeUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StorePropsPageView = LuaClass(UIView, true)

function StorePropsPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewProps = nil
	--self.TableViewSort = nil
	--self.AnimDyeUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StorePropsPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StorePropsPageView:OnInit()
	self.PropsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewProps, self.OnPropsSelectChanged, true, false)
	self.SortTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSort, self.OnSortSelectedChanged, true, false)

	self.Binders = {
		{ "PropsList", UIBinderUpdateBindableList.New(self, self.PropsTableViewAdapter) },
		{ "PropsSortList", UIBinderUpdateBindableList.New(self, self.SortTableViewAdapter) },
	}
end

function StorePropsPageView:OnDestroy()

end

function StorePropsPageView:OnShow()
	self.SortTableViewAdapter:SetSelectedIndex(1)
end

function StorePropsPageView:OnPropsSelectChanged(Index, ItemData, ItemView)
	StoreMainVM:OnClickProps(Index)
	StoreMainVM:InitMultiBuyView()
	if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		_G.UIViewMgr:ShowView(_G.UIViewID.StoreBuyPropsWin)
	else
		_G.UIViewMgr:ShowView(_G.UIViewID.StoreGiftChooseFriendWin)
	end
end

function StorePropsPageView:OnSortSelectedChanged(Index, ItemData, ItemView)
	StoreMainVM:ChangeFilter(Index)
	self.TableViewProps:ScrollToTop()
	self:PlayAnimation(self.AnimDyeUpdate)
end

function StorePropsPageView:OnHide()

end

function StorePropsPageView:OnRegisterUIEvent()

end

function StorePropsPageView:OnRegisterGameEvent()

end

function StorePropsPageView:OnRegisterBinder()
	self:RegisterBinders(StoreMainVM, self.Binders)
end

--- 获取途径跳转
function StorePropsPageView:OnPropPageSkipItem()
	for i = 1, self.PropsTableViewAdapter:GetNum() do
		local ItemData = self.PropsTableViewAdapter:GetItemDataByIndex(i)
		if ItemData ~= nil then
			if ItemData.PropID == StoreMainVM.JumpToGoodsID then
				self:OnPropsSelectChanged(i)
				self:OnSortSelectedChanged(i)
			end
		end
	end
end

return StorePropsPageView