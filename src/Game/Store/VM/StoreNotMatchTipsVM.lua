local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local StoreNotMatchTipsItemVM  = require("Game/Store/VM/ItemVM/StoreNotMatchTipsItemVM")
local UIBindableList = require("UI/UIBindableList")

---@class StoreNotMatchTipsVM : UIViewModel
local StoreNotMatchTipsVM = LuaClass(UIViewModel)

--- 购买弹窗特殊Tips物品VM
---Ctor
function StoreNotMatchTipsVM:Ctor()
	self.Index = 0
	self.Des = ""
	self.ItemIDList = UIBindableList.New(StoreNotMatchTipsItemVM)
end

function StoreNotMatchTipsVM:UpdateVM(Value)
	if Value == nil then
		return
	end
	self.Index = Value.Index
	self.Des = Value.Des
	local TempItemIDList = Value.ItemID
	for i = 1, #TempItemIDList do
		local TempItemVM = StoreNotMatchTipsItemVM.New()
		TempItemVM:UpdateVM(TempItemIDList[i])
		self.ItemIDList:Add(TempItemVM)
	end
end

function StoreNotMatchTipsVM:OnInit()
end

function StoreNotMatchTipsVM:OnBegin()

end

function StoreNotMatchTipsVM:OnEnd()
end

function StoreNotMatchTipsVM:OnShutdown()
end

function StoreNotMatchTipsVM:AdapterOnGetWidgetIndex()
	return self.Index
end
return StoreNotMatchTipsVM