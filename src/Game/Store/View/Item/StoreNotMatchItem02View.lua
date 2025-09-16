
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class StoreNotMatchItem02View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewSlot UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNotMatchItem02View = LuaClass(UIView, true)

function StoreNotMatchItem02View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewSlot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNotMatchItem02View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNotMatchItem02View:OnInit()
	self.AdapterItemList = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnSelectChanged)
	self.Binders = {
		{"ItemIDList", UIBinderUpdateBindableList.New(self, self.AdapterItemList)}
	}
end

function StoreNotMatchItem02View:OnSelectChanged(Index, ItemData, ItemView)
	if type(Index) == "number" then
		ItemTipsUtil.ShowTipsByResID(ItemData.ItemID)
	end
end

function StoreNotMatchItem02View:OnDestroy()

end

function StoreNotMatchItem02View:OnShow()
	
end

function StoreNotMatchItem02View:OnHide()

end

function StoreNotMatchItem02View:OnRegisterUIEvent()

end

function StoreNotMatchItem02View:OnRegisterGameEvent()

end

function StoreNotMatchItem02View:OnRegisterBinder()
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

return StoreNotMatchItem02View