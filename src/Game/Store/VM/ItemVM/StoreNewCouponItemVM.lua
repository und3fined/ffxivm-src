
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local StoreDefine = require("Game/Store/StoreDefine")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemVM = require("Game/Item/ItemVM")

---@class StoreNewCouponItemVM : UIViewModel
local StoreNewCouponItemVM = LuaClass(UIViewModel)

function StoreNewCouponItemVM:Ctor()
	self.Index = 0
	self.ResID = 0
	self.GID = 0
	self.ItemSlotData = ItemVM.New({IsCanBeSelected = false, IsShowNum = false, ShowItemLevel = false})
	self.TittleText = ""
	self.ExplainText = ""
	self.TimeText = ""
	self.CheckBoxEnable = false
	self.bCanSelect = true
end

function StoreNewCouponItemVM:UpdateVM(Params)
	local Value = Params.Value
	local Index = Params.Index
	local bCanSelect = Params.bCanSelect
	self.Index = Index
	self.bCanSelect = bCanSelect
	self.TittleText = Value.Cfg.Name
	self.GID = Value.GID
	if Value.Cfg.LowestActivePrice > 0 then
		self.ExplainText = string.format(LSTR(StoreDefine.LSTRTextKey.ThresholdForUse_d), Value.Cfg.LowestActivePrice)	--- 满%d可用
	else
		self.ExplainText = ""
	end
	if Value.ExpireTime == 0 then
		self.TimeText = LSTR(StoreDefine.LSTRTextKey.PermanentlyValid)	--- 永久有效
	else
		--- （时间点）%s前有效
		self.TimeText = string.format(LSTR(StoreDefine.LSTRTextKey.s_ValidBefore), os.date("%Y/%m/%d", Value.ExpireTime))
	end
	local TempItemCfg = ItemCfg:FindCfgByKey(Value.Cfg.ID)
	if TempItemCfg ~= nil then
		local ItemData = {
			ResID = TempItemCfg.ItemID
		}
		self.ResID = TempItemCfg.ItemID
		self.ItemSlotData:UpdateVM(ItemData)
	end
end

function StoreNewCouponItemVM:AdapterOnGetWidgetIndex()
	return 1
end

function StoreNewCouponItemVM:SetCheckBosEnable(Enable)
	self.CheckBoxEnable = Enable
end

return StoreNewCouponItemVM