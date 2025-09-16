--[[
Description  : 私聊频道Item VM  
Author       : xingcaicao
Date         : 2022-12-14 10:11:23
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ChatDefine = require("Game/Chat/ChatDefine")

local PrivateItemType = ChatDefine.PrivateItemType

---@class ChatPrivateChannelItemVM : UIViewModel
local ChatPrivateChannelItemVM = LuaClass(UIViewModel)

---Ctor
function ChatPrivateChannelItemVM:Ctor()
    self.Type = PrivateItemType.NotFriend 
    self.Name = nil
    self.Channel = ChatDefine.ChatChannel.Person
    self.ChannelID = nil
    self.RoleID = nil
    self.IsFriend = false
    self.Time = 0 -- 最新消息时间
    self.CreateTime = 0 -- 频道创建时间

    self.HeadInfo = nil
    self.HeadFrameID = nil
    self.IsOnline = nil
    self.OnlineStatusIcon = "" -- 在线状态
    self.CurWorldID = nil
end

function ChatPrivateChannelItemVM:IsEqualVM(Value)
	return nil ~= Value and self.ChannelID == Value.RoleID
end

function ChatPrivateChannelItemVM:UpdateVM(Value)
    local RoleID = Value.RoleID
    self.RoleID = RoleID 
    self.ChannelID = RoleID 
    self.CreateTime = Value.CreateTime or 0
end

--- 更新角色信息 
---@param Value RoleVM @角色数据
function ChatPrivateChannelItemVM:UpdateRoleInfo( Value )
    self.Name = Value.Name or "" 
    self.HeadInfo = Value.HeadInfo 
    self.HeadFrameID = Value.HeadFrameID
    self.IsOnline = Value.IsOnline
    self.OnlineStatusIcon = Value.OnlineStatusIcon
    self.CurWorldID = Value.CurWorldID
end

function ChatPrivateChannelItemVM:SetTime( t )
    self.Time = t or 0
end

---@return boolean @好友标识是否有变更 
function ChatPrivateChannelItemVM:UpdateFriendFlag( )
    local LastFlag = self.IsFriend
    local IsFriend = _G.FriendMgr:IsFriend(self.RoleID)
    self.IsFriend = IsFriend
    self.Type = IsFriend and PrivateItemType.Friend or PrivateItemType.NotFriend 

    return LastFlag ~= IsFriend
end

function ChatPrivateChannelItemVM:SetName(Name)
	self.Name = Name or ""
end

function ChatPrivateChannelItemVM:GetName()
	return self.Name or ""
end

function ChatPrivateChannelItemVM:GetSubName()
end

return ChatPrivateChannelItemVM