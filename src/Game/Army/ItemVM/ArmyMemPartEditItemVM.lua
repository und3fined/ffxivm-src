---
--- Author: daniel
--- DateTime: 2023-03-15 16:22
--- Description:TreeView ParentItem
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local DefineCategorys = ArmyDefine.DefineCategorys
local GlobalCfgType = ArmyDefine.GlobalCfgType
local UIBindableList = require("UI/UIBindableList")
local ArmyMemEditPlayerItemVM = require("Game/Army/ItemVM/ArmyMemEditPlayerItemVM")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")

---@class ArmyMemPartEditItemVM : UIViewModel
---@field CategoryIcon string @Icon path
---@field ShowIndex number @显示Index
---@field CategoryName string @分组名称
---@field MemberNum number @成员数量
---@field BindableListChildren any @child
---@field Type number @类型
local ArmyMemPartEditItemVM = LuaClass(UIViewModel)

function ArmyMemPartEditItemVM:Ctor()
    self.CategoryIcon = nil
    self.CategoryID = nil
    self.ShowIndex = nil
    self.CategoryName = nil
    self.MemberNum = nil
    self.bSelected = nil
    self.Type = ArmyDefine.Zero
    self.bExpanded = false
    self.bAutoExpand = false
    self.BindableListChildren = UIBindableList.New(ArmyMemEditPlayerItemVM)
end

function ArmyMemPartEditItemVM:UpdateVM(Value)
    local ShowIndex = Value.ShowIndex or 0
    self.ShowIndex = ShowIndex + 1
    self.CategoryName = Value.Name
    local ID = Value.ID
    self.CategoryID = ID
    if string.isnilorempty(self.CategoryName) then
        local CfgCategoryName
        if ID == ArmyDefine.LeaderCID then
            CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMajorCategoryName)
            self.CategoryName = CfgCategoryName or DefineCategorys.LeaderName
        else
            CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMinorCategoryName)
            self.CategoryName = CfgCategoryName or DefineCategorys.MemName
        end
    end
    local Members = _G.ArmyMgr:GetArmyMembersByCategotyID(ID)
    self.MemberNum = #Members
    self.bExpanded = false
    local ChildVMList = {}
    local PList = {}
    local Count = 0
    self:SetIcon(Value.IconID)
    for i, MemberData in ipairs(Members) do
        local Member = MemberData.Simple
        Count = Count + 1
        table.insert(PList, Member)
        if Count == ArmyDefine.PartCount or self.MemberNum == i then
            local ChildItemVM = ArmyMemEditPlayerItemVM.New()
            local bLeader = ID == ArmyDefine.One
            ChildItemVM:RefreshChildVM(PList, bLeader, Count)
            table.insert(ChildVMList, ChildItemVM)
            PList = {}
            Count = 0
        end
    end
    self.BindableListChildren:Update(ChildVMList)
    self.bSelected = false
end

function ArmyMemPartEditItemVM:SetIcon(Id)
    self.CategoryIcon = GroupMemberCategoryCfg:GetCategoryIconByID(Id)
end

function ArmyMemPartEditItemVM:AdapterOnGetCanBeSelected()
    return false
end

function ArmyMemPartEditItemVM:AdapterOnGetWidgetIndex()
    return 0
end

function ArmyMemPartEditItemVM:AdapterOnGetIsCanExpand()
	return self.bAutoExpand
end

function ArmyMemPartEditItemVM:AdapterOnGetChildren()
	return self.BindableListChildren:GetItems()
end

function ArmyMemPartEditItemVM:AdapterOnExpansionChanged(bExpanded)
	self.bExpanded = bExpanded
end

function ArmyMemPartEditItemVM:SetIsChecked(bSelected)
    self.bSelected = bSelected
end

return ArmyMemPartEditItemVM