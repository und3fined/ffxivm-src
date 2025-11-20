local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")


-- 显示特惠 、全民带芽、SDS芬里尔 在用
---@class OpsLimitedTimeSlotItemVM : UIViewModel
local OpsLimitedTimeSlotItemVM = LuaClass(UIViewModel)

---Ctor
function OpsLimitedTimeSlotItemVM:Ctor()
    self.ResID = 0
    self.ItemQualityIcon = ""
    self.Icon = ""

    self.IsSelect = false
    self.IsQualityVisible = true
    self.NumVisible = false
    self.IconChooseVisible = false
    self.IconReceivedVisible = false
    self.ItemLevelVisible = false
    self.ImgEmptyVisible = false
    self.BtnCheckVisible = false
end

function OpsLimitedTimeSlotItemVM:OnInit()

end

function OpsLimitedTimeSlotItemVM:IsEqualVM(Value)
    return false
end

function OpsLimitedTimeSlotItemVM:OnBegin()
end

function OpsLimitedTimeSlotItemVM:OnEnd()
end

function OpsLimitedTimeSlotItemVM:OnShutdown()
end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function OpsLimitedTimeSlotItemVM:UpdateVM(Value, Params)
    self.ResID = Value.ResID
    self.BtnCheckVisible = Value.BtnCheckVisible == true
    self.IsSelect = false
    local Cfg = ItemCfg:FindCfgByKey(Value.ResID)
	if Cfg ~= nil then
		self.Icon = ItemCfg.GetIconPath(Cfg.IconID)
		self.ItemQualityIcon = ItemUtil.GetItemColorIcon(Value.ResID)
	else
		self.Icon = ""
		self.ItemQualityIcon = ""
	end
end

--要返回当前类
return OpsLimitedTimeSlotItemVM