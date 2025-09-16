---@author: wallencai(蔡文超)
---Date: 2022-10-9

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")

local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

---@field Type integer @身份类型
---@field MemList UIBindableList @成员列表
local LinkShellMemGroupVM = LuaClass(UIViewModel)

local LinkShellMemSortFunction = function(lhs, rhs)
    -- 优先根据身份进行排名
    if lhs.Identify ~= rhs.Identify then
        return lhs.Identify < rhs.Identify
    end

    -- 在线状态
    local IsOnline_lhs = lhs.IsOnline
    local IsOnline_rhs = rhs.IsOnline
    if IsOnline_lhs ~= IsOnline_rhs then
        return IsOnline_lhs
    end

    if IsOnline_lhs then
        -- 在线，按上线时间排序
        return (lhs.LoginTime or 0) < (rhs.LoginTime or 0)
    else
        -- 离线，按下线时间排序
        return (lhs.LogoutTime or 0) > (rhs.LogoutTime or 0)
    end
end

function LinkShellMemGroupVM:Ctor( Type )
    self.TotalCount = 0
    self.OnlineCount = 0
    self.Desc = ''
    self.IsAutoExpand = true
    self.IsExpanded = nil
    self.MemList = UIBindableList.New()

    self.Type = Type
    local Config = LinkShellDefine.MemGroupTypeConfig[Type]
    self.Name = _G.LSTR(Config.NameUkey)
end

function LinkShellMemGroupVM:IsEqualVM(Value)
    return Value ~= nil and Value.Type == self.Type and self.MemList:Length() == Value.MemList:Length()
end

--- 添加新的成员
---@param Member any
function LinkShellMemGroupVM:AddMember(Member)
    self.MemList:Add(Member)

    self.TotalCount = self.MemList:Length()
    local queryRoles = {}

    for _, Mem in ipairs(self.MemList:GetItems()) do
        table.insert(queryRoles, Mem.RoleID)
    end

    RoleInfoMgr:QueryRoleSimples(queryRoles, self.UpdateMemsRoleInfo, self, false)
end

function LinkShellMemGroupVM:UpdateMemsRoleInfo()
    self.OnlineCount = 0

    for _, Mem in ipairs(self.MemList:GetItems()) do
        local RoleVM = RoleInfoMgr:FindRoleVM(Mem.RoleID, true)
        if RoleVM ~= nil then
            if RoleVM.IsOnline then
                self.OnlineCount = self.OnlineCount + 1
            end

            Mem:UpdateRoleInfo(RoleVM)
        end
    end

    self:UpdateCountDesc()
    self.MemList:Sort(LinkShellMemSortFunction)
end

--- 移除某个成员
---@param Mem any @成员VM
function LinkShellMemGroupVM:RemoveMem(Mem)
    self.MemList:Remove(Mem, true)

    self.TotalCount = self.MemList:Length()
    self:UpdateMemsRoleInfo()
end

--- 移除掉某个成员
---@param RoleID any
function LinkShellMemGroupVM:RemoveByRoleID(RoleID)
    local Mem = self.MemList:Find(function(Mem) return Mem.RoleID == RoleID end)
    if Mem ~= nil then
        self:RemoveMem(Mem)
    end
end

function LinkShellMemGroupVM:UpdateCountDesc()
    self.Desc = string.format("%s %d/%d", self.Name, self.OnlineCount, self.TotalCount)
end

--- 是否可以展开树形控件子节点
function LinkShellMemGroupVM:AdapterOnGetIsCanExpand()
    return self.IsAutoExpand
end

-- 设置展开状态
function LinkShellMemGroupVM:AdapterOnExpansionChanged(IsExpanded)
    self.IsExpanded = IsExpanded
end

--- 设置返回的索引：0
function LinkShellMemGroupVM:AdapterOnGetWidgetIndex()
    return 0
end

function LinkShellMemGroupVM:AdapterOnGetCanBeSelected()
    return false
end

--- 返回子节点列表
function LinkShellMemGroupVM:AdapterOnGetChildren()
    return self.MemList:GetItems()
end

return LinkShellMemGroupVM