--[[
Author: pengxingran_ds pengxingran@dasheng.tv
Date: 2025-09-15 11:50:13
LastEditors: pengxingran_ds pengxingran@dasheng.tv
LastEditTime: 2025-09-15 12:10:55
FilePath: \Script\Game\Photo\ItemVM\PhotoRoleSettingChildItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoSettingFunc = require("Game/Photo/Util/PhotoSettingFunc")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local PhotoRoleSettingChildItemVM = LuaClass(UIViewModel)

function PhotoRoleSettingChildItemVM:Ctor()
    self.Name = ""
	self.IsSelected = false
	self.Idx = -1
	self.IsShowTips = false
	self.Type = -1
end

function PhotoRoleSettingChildItemVM:UpdateVM(Data)
	self.Idx = Data.Idx
	self.Name = Data.Name
	self.Parent = Data.ParentVM
	self.Type = Data.Type
	self.IsOpen = self.Type ~= PhotoDefine.RoleSettingType.Camera
end

function PhotoRoleSettingChildItemVM:IsEqualVM(Data)
	return Data.Idx == self.Idx
end

function PhotoRoleSettingChildItemVM:SetIsOpen(IsOpen)
	if IsOpen == self.IsOpen then
		return
	end

	_G.PhotoMgr:CallSettingFunc(self.Type, self.Idx, IsOpen)

	self.IsOpen = IsOpen

	self.Parent:CheckEnableAll()
end

function PhotoRoleSettingChildItemVM:AdapterOnGetWidgetIndex()
    return 1
end

function PhotoRoleSettingChildItemVM:AdapterOnGetCanBeSelected()
    return false
end


return PhotoRoleSettingChildItemVM