local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoSettingFunc = require("Game/Photo/Util/PhotoSettingFunc")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local PhotoRoleSettingCtrlItemVM = LuaClass(UIViewModel)

function PhotoRoleSettingCtrlItemVM:Ctor()
    self.Name = ""
	self.IsSelected = false
	self.Idx = -1
	self.IsShowTips = false
end

function PhotoRoleSettingCtrlItemVM:UpdateVM(Data)
	self.Idx = Data.Idx
	self.Name = PhotoDefine.RoleCtrlSettingInfo.Ctrl[self.Idx].Name
	self.IsOpen = true
	self.Parent = Data.ParentVM
end

function PhotoRoleSettingCtrlItemVM:IsEqualVM(Data)
	return Data.Idx == self.Idx
end

function PhotoRoleSettingCtrlItemVM:SetIsOpen(IsOpen)
	if IsOpen == self.IsOpen then
		return
	end

	PhotoSettingFunc.CallCtrlFunc(self.Idx, IsOpen)

	self.IsOpen = IsOpen

	self.Parent:CheckEnableAll()
end

function PhotoRoleSettingCtrlItemVM:AdapterOnGetWidgetIndex()
    return 1
end

function PhotoRoleSettingCtrlItemVM:AdapterOnGetCanBeSelected()
    return false
end


return PhotoRoleSettingCtrlItemVM