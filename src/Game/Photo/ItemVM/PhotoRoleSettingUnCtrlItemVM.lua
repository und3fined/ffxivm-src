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

	PhotoSettingFunc.CallUnCtrlFunc(self.Idx, IsOpen)

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