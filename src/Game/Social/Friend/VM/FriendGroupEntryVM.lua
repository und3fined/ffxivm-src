---@author: wallencai(蔡文超)
---Date: 2022-08-24
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local UIBindableList = require("UI/UIBindableList")
local FriendEntryVM = require("Game/Social/Friend/VM//FriendEntryVM")

local FriendGroupEntryVM = LuaClass(UIViewModel)

function FriendGroupEntryVM:Ctor()
    self.ID = nil
    self.Name = ""
    self.OnlineCount = 0
    self.TotalCount = 0
    self.Desc = "" 
    self.CreateTime = 0
    self.IsAutoExpand = true
    self.IsExpanded = nil

    self.MemberVMList = UIBindableList.New()
end

function FriendGroupEntryVM:IsEqualVM(Value)
    return Value ~= nil and Value.ID == self.ID
end

--- 更新数据（好友分组）
---@param Value table @好友分组信息
function FriendGroupEntryVM:UpdateByFriendGroup(Value)
    local ID = Value.ID
    self.ID = ID
    self.Name = ID == FriendDefine.DefaultGroupID and FriendDefine.DefaultGroupName or Value.Name
    self.CreateTime = Value.CreateTime
    self.Desc = ""

    local Friends = table.clone(Value.Friends or {}, true)
    if #Friends > 0 then
        local EntryList = {}

        for _, v in ipairs(Friends) do
            v.GroupID = ID
            v.IsFriend = true

            local Entry = FriendEntryVM:New()
            Entry:UpdateVM(v)

            table.insert(EntryList, Entry)
        end

        local MemberVMList = self.MemberVMList
        MemberVMList:Clear()
        MemberVMList:AddRange(EntryList)
    end

    self:UpdateCount(0)
end

--- 更新数据（黑名单）
---@param Value table @黑名单列表
function FriendGroupEntryVM:UpdateByBlackList(Value)
    self.ID = FriendDefine.BlackGroupID 
    self.Name = FriendDefine.BlackGroupName
    self.Desc = ""

    local BlackList = table.clone(Value or {}, true)
    if #BlackList > 0 then
        local EntryList = {}

        local ID = self.ID

        for _, v in ipairs(BlackList) do
            v.GroupID = ID

            local Entry = FriendEntryVM:New()
            Entry:UpdateVM(v)

            table.insert(EntryList, Entry)
        end


        local MemberVMList = self.MemberVMList
        MemberVMList:Clear()
        MemberVMList:AddRange(EntryList)
    end

    self:UpdateCount(0)
end

--- 更新成员角色信息
function FriendGroupEntryVM:UpdateMembersRoleInfo()
    local OnlineCnt = 0
    local VMList = self.MemberVMList

    for _, v in ipairs(VMList:GetItems())  do
        local RoleVM = RoleInfoMgr:FindRoleVM(v.RoleID, true)
        if RoleVM then 
            if RoleVM.IsOnline then
                OnlineCnt = OnlineCnt + 1
            end

            v:UpdateRoleInfo(RoleVM)
        end
    end

    self:UpdateCount(OnlineCnt)
end

--- 更新数量信息
---@param OnlineCnt number @在线好友人数
function FriendGroupEntryVM:UpdateCount( OnlineCnt )
    self.OnlineCount = OnlineCnt
    self.TotalCount = self.MemberVMList:Length()
    self:UpdateDesc()

    self.IsExpanded = self.IsExpanded and self.TotalCount > 0
end

--- 更新分组名
---@param NewName string @新的分组名
function FriendGroupEntryVM:UpdateName( NewName )
    self.Name = NewName or ""
    self:UpdateDesc()
end

--- 更新分组描述
function FriendGroupEntryVM:UpdateDesc()
    self.Desc = string.format("%s %s/%s", self.Name, self.OnlineCount, self.TotalCount)
end

function FriendGroupEntryVM:GetMemberByRoleID( RoleID )
    local Ret = self.MemberVMList:Find(function(Item) return Item.RoleID == RoleID end)
    return Ret
end

--- 是否可以展开树形控件子节点
function FriendGroupEntryVM:AdapterOnGetIsCanExpand()
    return self.IsAutoExpand
end

-- 设置展开状态
function FriendGroupEntryVM:AdapterOnExpansionChanged(IsExpanded)
    self.IsExpanded = IsExpanded and self.TotalCount > 0
end

function FriendGroupEntryVM:AdapterOnGetCanBeSelected()
    return false 
end

--- 设置返回的索引：0
function FriendGroupEntryVM:AdapterOnGetWidgetIndex()
    return 0
end

--- 返回子节点列表
function FriendGroupEntryVM:AdapterOnGetChildren()
    return self.MemberVMList:GetItems()
end

return FriendGroupEntryVM