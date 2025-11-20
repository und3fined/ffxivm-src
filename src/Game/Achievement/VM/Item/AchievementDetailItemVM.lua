---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AchievementDiyGruopCfg = require("TableCfg/AchievementDiyGruopCfg")

---@class AchievementDetailItemVM : UIViewModel
local AchievementDetailItemVM = LuaClass(UIViewModel)

---Ctor
function AchievementDetailItemVM:Ctor()
	self.ID = nil
	self.Title = ""
	self.Icon = ""
	self.TitleIcon = ""
	self.Content = ""
end

function AchievementDetailItemVM:OnInit()

end

function AchievementDetailItemVM:OnBegin()

end

function AchievementDetailItemVM:IsEqualVM(Value)
	return Value.ID == self.ID
end

function AchievementDetailItemVM:OnEnd()

end

function AchievementDetailItemVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function AchievementDetailItemVM:UpdateVM(Value, Params)
	self:Ctor()
	local DiyGroupCfg = AchievementDiyGruopCfg:FindCfgByKey(Value.DiyGroupID)
	if DiyGroupCfg ~= nil then
		self.ID = Value.DiyGroupID
		self.Title = DiyGroupCfg.Title
		self.Icon = DiyGroupCfg.Icon
		self.TitleIcon = DiyGroupCfg.TitleIcon
		self.Content = DiyGroupCfg.Content
	end

end

return AchievementDetailItemVM