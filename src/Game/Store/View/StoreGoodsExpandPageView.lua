
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local StoreDefine = require("Game/Store/StoreDefine")

---@class StoreGoodsExpandPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExtend UFButton
---@field PanelGoodsExpend UFCanvasPanel
---@field SingleBoxNotPossess CommSingleBoxView
---@field TableViewGoods UTableView
---@field TableViewSort UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreGoodsExpandPageView = LuaClass(UIView, true)

function StoreGoodsExpandPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExtend = nil
	--self.PanelGoodsExpend = nil
	--self.SingleBoxNotPossess = nil
	--self.TableViewGoods = nil
	--self.TableViewSort = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreGoodsExpandPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBoxNotPossess)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreGoodsExpandPageView:OnInit()
	self.FilterTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSort, self.OnFilterSelectChanged, false, false)
	self.Binders = {
		{ "FilterList", UIBinderUpdateBindableList.New(self, self.FilterTableViewAdapter) },
	}
end

function StoreGoodsExpandPageView:OnDestroy()

end

function StoreGoodsExpandPageView:OnShow()
	self:PlayAnimation(self.AnimGoodsUpdate)
	self.FilterTableViewAdapter:SetSelectedIndex(1)
	if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		UIUtil.SetIsVisible(self.SingleBoxNotPossess, StoreMainVM.TabList.Items[StoreMainVM.TabSelecteIndex].IsDisplayHaveFilter)
	else
		UIUtil.SetIsVisible(self.SingleBoxNotPossess, false)
	end
end

---@type 切换筛选类型
function StoreGoodsExpandPageView:OnFilterSelectChanged(Index, ItemData, ItemView)
	StoreMainVM:ChangeFilter(Index)
	self:PlayAnimation(self.AnimGoodsUpdate)
end

function StoreGoodsExpandPageView:OnHide()
	self.SingleBoxNotPossess.ToggleButton:SetChecked(false)
end

function StoreGoodsExpandPageView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxNotPossess.ToggleButton, self.OnChangedSecondScreen)
end

function StoreGoodsExpandPageView:OnRegisterGameEvent()
end

---@type 切换未拥有筛选
function StoreGoodsExpandPageView:OnChangedSecondScreen(ToggleButton, State)
	local Flag = UIUtil.IsToggleButtonChecked(State)
	StoreMainVM.TabList.Items[StoreMainVM.TabSelecteIndex]:SetIsSelectedOwned(Flag)
	StoreMainVM.bSecondScreen = Flag
	StoreMainVM:SetSecondScreen(Flag)
	self:PlayAnimation(self.AnimUpdateList)
end

function StoreGoodsExpandPageView:OnRegisterBinder()
	self:RegisterBinders(StoreMainVM, self.Binders)
end

return StoreGoodsExpandPageView