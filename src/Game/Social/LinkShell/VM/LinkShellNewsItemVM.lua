---
--- Author: xingcaicao
--- DateTime: 2023-08-21 10:05
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local TimeUtil = require("Utils/TimeUtil")

local LSTR = _G.LSTR
local LINKSHELL_EVENT = LinkShellDefine.LINKSHELL_EVENT

---@class LinkShellNewsItemVM : UIViewModel
local LinkShellNewsItemVM = LuaClass(UIViewModel)

function LinkShellNewsItemVM:Ctor( )
    self.Type = LINKSHELL_EVENT.EVENT_UNKNOWN
    self.Time = 0 
    self.Sender = nil
    self.Receiver = nil

    self.Desc = nil 
    self.TimeDesc = nil
end

function LinkShellNewsItemVM:IsEqualVM( Value )
    return false
end

function LinkShellNewsItemVM:UpdateVM( Value )
    self.Type = Value.EventType
    self.Time = Value.Time or 0
    self.Sender = Value.SendID
    self.Receiver = Value.RecvID

    local SrvTime = TimeUtil.GetServerTime()
    local Time = SrvTime - self.Time
    if Time > 86400 then
        -- "%s天前"
        self.TimeDesc = string.format(LSTR(40088), math.modf(Time / 86400))

    elseif Time > 3600 then
        -- "%s小时前"
        self.TimeDesc = string.format(LSTR(40089), math.modf(Time / 3600))

    elseif Time > 60 then
        -- "%s分前"
        self.TimeDesc = string.format(LSTR(40090), math.modf(Time / 60))

    else
        -- "刚刚"
        self.TimeDesc = LSTR(40091)
    end
end

function LinkShellNewsItemVM:UpdateRoleInfo( )
    local Type = self.Type
    local DescFmt = LSTR(LinkShellDefine.EventDescFmtConfig[Type])
    if string.isnilorempty(DescFmt) then
        self.Desc = LSTR(40092) -- "未知消息"
        return
    end

    -- 事件发起者
    local RoleVM = RoleInfoMgr:FindRoleVM(self.Sender)
    local SenderName = string.format('<span color="#6FB1E9FF">%s</>', (RoleVM or {}).Name or "")

    -- 事件接收者
    RoleVM = RoleInfoMgr:FindRoleVM(self.Receiver)
    local ReceiverName = string.format('<span color="#6FB1E9FF">%s</>', (RoleVM or {}).Name or "")

    if Type == LINKSHELL_EVENT.SET_MANAGE_LINKSHELL then
        self.Desc = string.format(DescFmt, ReceiverName, SenderName)

    else
        self.Desc = string.format(DescFmt, SenderName, ReceiverName)
    end
end

return LinkShellNewsItemVM