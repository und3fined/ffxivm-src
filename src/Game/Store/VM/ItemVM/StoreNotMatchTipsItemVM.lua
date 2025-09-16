local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")

---@class StoreNotMatchTipsItemVM : UIViewModel
local StoreNotMatchTipsItemVM = LuaClass(UIViewModel)

--- 购买弹窗特殊Tips物品VM
---Ctor
function StoreNotMatchTipsItemVM:Ctor()
	self.ItemID = 0
	self.Icon = ""
end

function StoreNotMatchTipsItemVM:UpdateVM(Value)
	if Value == nil then
		return
	end
	self.ItemID = Value
	local ItemCfg = require("TableCfg/ItemCfg")
	local Cfg = ItemCfg:FindCfgByKey(self.ItemID)
	if Cfg == nil then
		return
	end
	self.Icon = UIUtil.GetIconPath(Cfg.IconID)
end

function StoreNotMatchTipsItemVM:OnInit()
end

function StoreNotMatchTipsItemVM:OnBegin()

end

function StoreNotMatchTipsItemVM:OnEnd()
end

function StoreNotMatchTipsItemVM:OnShutdown()
end

function StoreNotMatchTipsItemVM:AdapterOnGetWidgetIndex()
	return self.Index
end
return StoreNotMatchTipsItemVM