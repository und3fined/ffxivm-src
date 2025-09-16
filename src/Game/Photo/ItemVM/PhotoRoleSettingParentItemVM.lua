local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoSettingFunc = require("Game/Photo/Util/PhotoSettingFunc")

local PhotoRoleSettingParentItemVM = LuaClass(UIViewModel)

local PhotoDefine = require("Game/Photo/PhotoDefine")
local CtrlDef = PhotoDefine.RoleCtrlSetting.Ctrl
local UnCtrlDef = PhotoDefine.RoleCtrlSetting.UnCtrl

local UIBindableList = require("UI/UIBindableList")

local PhotoRoleSettingCtrlItemVM = require("Game/Photo/ItemVM/PhotoRoleSettingCtrlItemVM")
local PhotoRoleSettingUnCtrlItemVM = require("Game/Photo/ItemVM/PhotoRoleSettingUnCtrlItemVM")

local PhotoRoleSettingChildItemVM = require("Game/Photo/ItemVM/PhotoRoleSettingChildItemVM")


function PhotoRoleSettingParentItemVM:Ctor()
    self.Name = ""

	self.EnableAll = false

	self.CtrlList = UIBindableList.New(PhotoRoleSettingCtrlItemVM)
    self.UnCtrlList = UIBindableList.New(PhotoRoleSettingUnCtrlItemVM)
    self.IsShowCheckBox = false
	self.CurList = UIBindableList.New(PhotoRoleSettingChildItemVM)
end

local function Sort(a, b)
    return a.Idx < b.Idx
end

function PhotoRoleSettingParentItemVM:UpdateVM(Data)
	self.Type = Data.Type
	

	-- self.CurList = self.Type == PhotoDefine.RoleSettingType.Ctrl and self.CtrlList or self.UnCtrlList
	
	local Info = PhotoDefine.RoleSettingTypeInfo[Data.Type]
	self.Name = Info.Name

	local ChildData = {}
	for _, Idx in pairs(Info.ChildList) do
		table.insert(ChildData, {
            Type = Data.Type, 
            Idx = Idx, 
            ParentVM = self, 
            Name = Info.SettingInfo[Idx].Name
        })
	end

    table.sort(ChildData, Sort)
	self.CurList:UpdateByValues(ChildData)

	self.EnableAll = self.Type ~= PhotoDefine.RoleSettingType.Camera
    self.IsShowCheckBox = self.Type ~= PhotoDefine.RoleSettingType.Camera
end

function PhotoRoleSettingParentItemVM:IsEqualVM(Data)
	return Data.Name == self.Name
end

-------------------------------------------------------------------------------------------------------
---@region ParentItemConfig

function PhotoRoleSettingParentItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function PhotoRoleSettingParentItemVM:AdapterOnGetChildren()
    return self.CurList:GetItems()
end

function PhotoRoleSettingParentItemVM:AdapterOnGetCanBeSelected()
    return false  -- 不可选中，但受子节点选中影响
end

function PhotoRoleSettingParentItemVM:AdapterOnGetIsAutoExpand()
    return false  -- 不可收起
end

-------------------------------------------------------------------------------------------------------
---@region check state

function PhotoRoleSettingParentItemVM:SetEnableAll(V)
    if self.EnableAll == V then
        return
    end

    self.EnableAll = V

    for _, Item in pairs(self.CurList:GetItems()) do
        Item:SetIsOpen(V)
    end
end

function PhotoRoleSettingParentItemVM:CheckEnableAll()
    for _, Item in pairs(self.CurList:GetItems()) do
        if not Item.IsOpen then
            self.EnableAll = false
            return
        end
    end

    self.EnableAll = true
end

return PhotoRoleSettingParentItemVM