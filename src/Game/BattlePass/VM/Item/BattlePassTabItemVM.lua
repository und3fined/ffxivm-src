---
---@Author: ZhengJanChuan
---@Date: 2024-01-09 15:04:21
---@Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local BattlePassTabItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassTabItemVM:Ctor()
   self.ID = nil --Tab标签ID
   self.Name = nil  -- 标签名
   self.IsSelected = false --是否被选中
   self.IsRed = false --是否显示红点
end

function BattlePassTabItemVM:OnInit()
end

function BattlePassTabItemVM:OnBegin()
end

function BattlePassTabItemVM:OnEnd()
end 

function BattlePassTabItemVM:OnShutdown()
end

function BattlePassTabItemVM:UpdateChangeState(IsSelected)
   self.IsSelected = IsSelected
end

return BattlePassTabItemVM
