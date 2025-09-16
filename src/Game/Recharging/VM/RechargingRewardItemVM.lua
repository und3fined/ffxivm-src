local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local ItemVM = require("Game/Item/ItemVM")

---@class RechargingRewardItemVM : ItemVM
local RechargingRewardItemVM = LuaClass(ItemVM)

function RechargingRewardItemVM:Ctor()
	self.IsValid = true
	self.IsMountStory = false
	self.IsMountNotOwn = false
	self.IsShowNum = false
	self.NumVisible = false
	self.IconOpacity = 1
	self.ItemColorAndOpacity = _G.UE.FLinearColor(1, 1, 1, 1) --物品颜色透明度设置
end

function RechargingRewardItemVM:OnInit()
end

function RechargingRewardItemVM:OnBegin()
end

function RechargingRewardItemVM:OnEnd()
end

function RechargingRewardItemVM:OnShutdown()
end

function RechargingRewardItemVM:SetIcon(Icon)
	self.Icon = Icon
end

return RechargingRewardItemVM