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

	PhotoSettingFunc.CallRoleSettingFunc(self.Type, self.Idx, IsOpen)

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