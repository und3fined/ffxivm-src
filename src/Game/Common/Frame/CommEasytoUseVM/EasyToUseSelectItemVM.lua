--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-02-24 15:26:17
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-02-24 15:31:55
FilePath: \Script\Game\Common\Frame\CommEasytoUseVM\EasyToUseSelectItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class EasyToUseSelectItemVM : UIViewModel
local EasyToUseSelectItemVM = LuaClass(UIViewModel)

---Ctor
function EasyToUseSelectItemVM:Ctor( )
	self.Type = nil
	self.Title = nil
	self.Icon = nil
	self.NormalIcon = nil
	self.SelectedIcon = nil
	self.IsLock = nil
	self.ChildWidget = nil
	self.ModuleID = nil
	self.HelpInfoID = nil
	self.HelpInfoViewID = nil
end

function EasyToUseSelectItemVM:IsEqualVM(Value)
	return false
end

function EasyToUseSelectItemVM:UpdateVM(Value, Param)
	self.Type = Value.Type
	self.NormalIcon = Value.NormalIcon
	self.SelectedIcon = Value.SelectedIcon
	self.ChildWidget = Value.ChildWidget
	self.Icon = Value.NormalIcon
	self.Title = Value.Title
	self.bSelect = _G.UE.ESlateVisibility.HitTestInvisible
	self.ScaleBoxIconVisibility = 0
	self.ModuleID = Value.ModuleID
	self.IsLock = not _G.ModuleOpenMgr:CheckOpenState(Value.ModuleID)
	if Value.CheckOpenFunc and not self.IsLock then
		self.IsLock = not Value.CheckOpenFunc()
	end

	self.HelpInfoID  = Value.HelpInfoID
	self.HelpInfoViewID  = Value.HelpInfoViewID
end

function EasyToUseSelectItemVM:SetSelectIcon()
	self.Icon = self.SelectedIcon
end

function EasyToUseSelectItemVM:SetNormalIcon()
	self.Icon = self.NormalIcon
end

function EasyToUseSelectItemVM:AdapterOnGetIsVisible()
	return true
end

return EasyToUseSelectItemVM