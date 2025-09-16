---
--- Author: xingcaicao
--- DateTime: 2025-04-18 14:13
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

---@class FriendPlatformFriendItemVM : UIViewModel
local FriendPlatformFriendItemVM = LuaClass(UIViewModel)

---Ctor
function FriendPlatformFriendItemVM:Ctor( )
    self.RoleID = nil
    self.OpenID = ""
    self.PlayerName = nil 
    self.PlatformName = nil 
    self.MapResName = nil
    self.State = nil
    self.ServerName = nil
    self.Level = nil
    self.ProfID = 0
    self.LevelDesc = ""

    self.IsOnline = false 
    self.OnlineStatusIcon = "" -- 在线状态
    self.IsSortPriority = false -- 是否排序优先

	self.CurWorldID = 0 -- 玩家当前所在服务器ID
    self.IsInvited = false -- 是否被邀请
    self.IsShowInvitedBtn = false

    self.HeadInfo = nil
    self.HeadFrameID = nil

    self.LaunchType = 0
end

function FriendPlatformFriendItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.RoleID == self.RoleID
end

function FriendPlatformFriendItemVM:UpdateVM(Value)
    local RoleID = Value.RoleID
    self.RoleID = RoleID
    self.PlatformName = Value.PlatformName or ""
    self.IsSortPriority = false 
    self.IsInvited = Value.IsInvited

    RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
        self:UpdateRoleInfo(RoleVM)
    end, nil, true)
end

--- 更新角色信息 
---@param Value RoleVM @角色数据
function FriendPlatformFriendItemVM:UpdateRoleInfo(Value)
    self.RoleID = Value.RoleID
    self.OpenID = Value.OpenID 
    self.MapResName = Value.MapResName
    self.PlayerName = Value.Name
    self.ProfID = Value.Prof 
    self.LoginTime = Value.LoginTime
    self.HeadInfo = Value.HeadInfo 
    self.HeadFrameID = Value.HeadFrameID

    local IsOnline = Value.IsOnline
    self.IsOnline = IsOnline

    local LogoutTime = Value.LogoutTime
    self.LogoutTime = LogoutTime

    if not IsOnline and _G.LoginMgr:IsQQLogin() then
        self.IsShowInvitedBtn = true 
    else
        self.IsShowInvitedBtn = false 
    end

    local Level = Value.Level
    self.Level = Level 
    self.LevelDesc = tostring(Level or 0)

    local WorldID = Value.WorldID
    if WorldID and WorldID > 0 then
        self.ServerName =  _G.LoginMgr:GetMapleNodeName(WorldID) 
    else
        self.ServerName = ""
    end

    if IsOnline then
        self.State = self.MapResName
    else
        self.State = _G.TimeUtil.GetOfflineDesc(LogoutTime)
    end

    -- 在线状态
    self.OnlineStatusIcon = Value.OnlineStatusIcon

    self.LaunchType = Value.LaunchType
end

function FriendPlatformFriendItemVM:SetSortPriority(b)
    self.IsSortPriority = b == true
end

function FriendPlatformFriendItemVM:SetIsInvited(b)
    self.IsInvited = b == true
end

return FriendPlatformFriendItemVM