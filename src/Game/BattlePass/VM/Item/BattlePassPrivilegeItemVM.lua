--
-- Author: ZhengJanChuan
-- Date: 2024-01-15 19:13
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class BattlePassPrivilegeItemVM : UIViewModel
local BattlePassPrivilegeItemVM = LuaClass(UIViewModel)

---Ctor
function BattlePassPrivilegeItemVM:Ctor()
    self.Icon = nil
    self.Content = ""
end

function BattlePassPrivilegeItemVM:OnInit()
end

function BattlePassPrivilegeItemVM:OnBegin()
end

function BattlePassPrivilegeItemVM:OnEnd()
end

function BattlePassPrivilegeItemVM:OnShutdown()
end

function BattlePassPrivilegeItemVM:UpdateVM(Value)
	if Value == nil then
		return
	end
    self.Icon = Value.Icon
	self.Content = Value.Content
end

--要返回当前类
return BattlePassPrivilegeItemVM