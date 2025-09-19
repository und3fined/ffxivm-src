--[[
Author: pengxingran_ds pengxingran@dasheng.tv
Date: 2025-09-15 11:50:13
LastEditors: pengxingran_ds pengxingran@dasheng.tv
LastEditTime: 2025-09-15 12:09:51
FilePath: \Script\Game\Photo\ItemVM\PhotoRoleSettingUnCtrlItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoSettingFunc = require("Game/Photo/Util/PhotoSettingFunc")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local PhotoRoleSettingUnCtrlItemVM = LuaClass(UIViewModel)

function PhotoRoleSettingUnCtrlItemVM:Ctor()
    self.Name = ""
	self.IsSelected = false
	self.Idx = -1
	self.IsShowTips = false
end

function PhotoRoleSettingUnCtrlItemVM:UpdateVM(Data)
	self.Idx = Data.Idx
	self.Name = PhotoDefine.RoleCtrlSettingInfo.UnCtrl[self.Idx].Name
	self.IsOpen = true
	self.Parent = Data.ParentVM
	self.IsShowTips = self.Idx == PhotoDefine.RoleCtrlSetting.UnCtrl.Other
end

function PhotoRoleSettingUnCtrlItemVM:IsEqualVM(Data)
	return Data.Idx == self.Idx
end

function PhotoRoleSettingUnCtrlItemVM:SetIsOpen(IsOpen)
	if IsOpen == self.IsOpen then
		return
	end

	_G.PhotoMgr:CallSettingFunc(PhotoDefine.RoleSettingType.UnCtrl, self.Idx, IsOpen)

	self.IsOpen = IsOpen

	self.Parent:CheckEnableAll()
end

function PhotoRoleSettingUnCtrlItemVM:AdapterOnGetWidgetIndex()
    return 1
end

function PhotoRoleSettingUnCtrlItemVM:AdapterOnGetCanBeSelected()
    return false
end

return PhotoRoleSettingUnCtrlItemVM