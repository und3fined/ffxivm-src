--
-- Author: ZhengJanChuan
-- Date: 2024-01-15 19:13
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class BattlePassIncludeItemVM : UIViewModel
local BattlePassIncludeItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassIncludeItemVM:Ctor()
	self.Num = 0
	self.QuaImg = ""
	self.Icon = ""
    self.HasGot = false
    self.ShowFunc = false
    self.ShowTipFirst = false
    self.ShowTipDaily = false
	self.NumVisible = false
end

function BattlePassIncludeItemVM:OnInit()
end

function BattlePassIncludeItemVM:OnBegin()
end

function BattlePassIncludeItemVM:OnEnd()
end

function BattlePassIncludeItemVM:OnShutdown()
end

function BattlePassIncludeItemVM:UpdateVM(Value)
	if Value == nil then
		return
	end
	self.Num = Value.Num
	self.QuaImg = Value.ItemQualityIcon
	self.Icon = Value.Icon
    self.HasGot = false
    self.ShowFunc = false
    self.ShowTipFirst = false
    self.ShowTipDaily = false
	self.NumVisible = Value.NumVisible

end


--要返回当前类
return BattlePassIncludeItemVM