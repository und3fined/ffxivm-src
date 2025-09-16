--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-08-23 15:37:45
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-09-19 15:15:51
FilePath: \Client\Source\Script\Game\Common\Tab\CommVerIconTabItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--
-- Author: Administrator
-- Date: 2024-04-16 14:50
-- Description:

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")


---@class CommVerIconTabItemVM : UIViewModel
local CommVerIconTabItemVM = LuaClass(UIViewModel)

---Ctor
function CommVerIconTabItemVM:Ctor()
	self.Icon = nil
	self.SelectIcon = nil -- 选中图标
	self.TextPercentVisible = false
	self.Percent = ""
	self.IsModuleOpen = false
	self.bShowlock = true

	self.ID = nil -- 作为数据交互时传送的标记使用（例如 如果使地域页签就是RegionID）
	self.RedDotType = nil --红点所属模块（例如 采集笔记GatherLog）
	self.RedDotData = nil
	self.ConditionFunc = nil
	self.ConditionData = nil
end

function CommVerIconTabItemVM:OnInit()

end

---UpdateVM
---@param Value table
function CommVerIconTabItemVM:UpdateVM(Data)
	if not Data then return end
	self.Icon = Data.IconPath or ""
	self.PatternIcon = Data.IconPath or ""
	self.SelectIcon = Data.SelectIcon or ""

	if Data.Percent ~= nil then
		self.TextPercentVisible = true
		self.Percent = string.format("%s%%", Data.Percent)
	else
		self.TextPercentVisible = false
	end
	
	if Data.IsLock then
		self.IsModuleOpen = true
	else
		self.IsModuleOpen = false
	end
	if Data.bShowlock == nil then
		self.bShowlock = true
	else
		self.bShowlock = Data.bShowlock
	end

	--系统解锁
	if Data.ModuleID ~= nil then
		self.ModuleID = Data.ModuleID
		self.IsUnLock = _G.ModuleOpenMgr:CheckOpenState(Data.ModuleID)
		self.IsModuleOpen = not self.IsUnLock
	end
	
	self.ID = Data.ID
	self.RedDotType = Data.RedDotType
	self.RedDotData = Data.RedDotData
	self.ConditionFunc = Data.ConditionFunc
	self.ConditionData = Data.ConditionData
end

function CommVerIconTabItemVM:OnBegin()

end

function CommVerIconTabItemVM:OnEnd()

end

function CommVerIconTabItemVM:OnShutdown()

end

function CommVerIconTabItemVM:IsEqualVM(Value)
	return true
end

function CommVerIconTabItemVM:AdapterOnGetCanBeSelected(bByClick)
	if bByClick and self.ConditionFunc and self.ConditionFunc(self.ConditionData) then
		return false
	end
	if self.ModuleID ~= nil then
		if not self.IsUnLock then
			_G.ModuleOpenMgr:ModuleState(self.ModuleID)
		end
		return self.IsUnLock
	else
		return true
	end
end

--要返回当前类
return CommVerIconTabItemVM