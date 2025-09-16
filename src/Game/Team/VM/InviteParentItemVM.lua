--[[
Author: stellahxhu
DateTime: 2022-07-15 12:56:49
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-05-23 15:23:49
FilePath: \Script\Game\Team\VM\InviteParentItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local InviteParentListItemVM = require("Game/Team/VM/InviteParentListItemVM")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local ArmyMgr = require("Game/Army/ArmyMgr")
local ActorUtil = require("Utils/ActorUtil")
local TeamDefine = require("Game/Team/TeamDefine")
local ProtoCommon = require("Protocol/ProtoCommon")

local ArmyCatOrder = {
	[ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_PRESIDENT] = 1,
	[ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_MEMBER] = 2,
	---部队见习阶级已删除
	--[ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_INTERN] = 3,
}
local SortFuncs = {
	[TeamDefine.InviteItemType.Nearby] = function(a, b)
		local ActorA = ActorUtil.GetActorByRoleID(a.RoleID)
		local ActorB = ActorUtil.GetActorByRoleID(b.RoleID)
		if ActorA == nil or ActorB == nil then
			return false
		end
		return ActorA:ClientGetDistanceSquareToMajor() < ActorB:ClientGetDistanceSquareToMajor()
	end,
	[TeamDefine.InviteItemType.Tribe] = function (a, b)
		local GetArmyCatOrder = function(RoleID)
			local ArmyInfo = ArmyMgr:GetSelfArmyInfo() or {}
			local Ele = table.find_by_predicate(ArmyInfo.Members or {}, function (e)
				return e.Simple.RoleID == RoleID
			end)
			if Ele then
				return ArmyCatOrder[Ele.Simple.CategoryID] or 999
			end
			return 999
		end
		local CatOrderA = GetArmyCatOrder(a.RoleID)
		local CatOrderB = GetArmyCatOrder(b.RoleID)
		if CatOrderA == CatOrderB then
			return a.Name < b.Name
		end
		return CatOrderA < CatOrderB
	end
}

---@class InviteParentItemVM: UIViewModel
local InviteParentItemVM = LuaClass(UIViewModel)

---Ctor
function InviteParentItemVM:Ctor()
	self.Type = nil
	self.Name = ""
	self.IsAutoExpand = true
	self.IsExpanded = true
	self.BindableListChildren = UIBindableList.New(InviteParentListItemVM)
end

---UpdateVM
---@param Value table @ParentInviteItemConfig
function InviteParentItemVM:UpdateVM(Value)
	self.Type = Value.Type
	self.Name = Value.Name
	self.IsExpanded = true

	local Data = {}
	for _, v in pairs(Value.Children or {}) do
		if v and v ~= 0 then
			table.insert(Data, {RoleID=v, Type=self.Type})
		end
	end

	self.BindableListChildren:UpdateByValues(Data, SortFuncs[self.Type])
end

function InviteParentItemVM:IsEqualVM(Value)
	return false
end

function InviteParentItemVM:AdapterOnGetCanBeSelected()
	return false
end

function InviteParentItemVM:AdapterOnGetWidgetIndex()
	return 0
end

--- 是否可以展开树形控件子节点
function InviteParentItemVM:AdapterOnGetIsCanExpand()
	return self.IsAutoExpand
end

function InviteParentItemVM:AdapterOnGetChildren()
	return self.BindableListChildren:GetItems()
end

function InviteParentItemVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
end

return InviteParentItemVM