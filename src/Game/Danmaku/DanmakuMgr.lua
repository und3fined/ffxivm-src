---
--- Author: xingcaicao
--- DateTime: 2025-04-11 16:03:00
--- Description: 弹幕
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local DanmakuVM = require("Game/Danmaku/DanmakuVM")
local DanmakuDefine = require("Game/Danmaku/DanmakuDefine")
local ChatSetting = require("Game/Chat/ChatSetting")

local DanmakuType = DanmakuDefine.DanmakuType

---@class DanmakuMgr : MgrBase
local Class = LuaClass(MgrBase)

function Class:OnInit()

end

function Class:OnBegin()

end

function Class:OnEnd()

end

function Class:OnShutdown()

end

function Class:OnRegisterNetMsg()

end

function Class:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapChanged, self.OnGameEventMapChanged)
	self:RegisterGameEvent(EventID.SettingsMaxFPSChanged, self.OnGameEventSettingsMaxFPSChanged)
    self:RegisterGameEvent(EventID.ChatOpenPrivateDanmakuChanged, self.OnGameEventOpenPrivateDanmakuChanged) -- 私聊弹幕开关变化
    self:RegisterGameEvent(EventID.ChatOpenTeamDanmakuChanged, self.OnGameEventOpenTeamDanmakuChanged) -- 队伍弹幕开关变化
end

function Class:OnGameEventMapChanged()
    self:ClearAllDanmakuMsg()
end

function Class:OnGameEventSettingsMaxFPSChanged()
    DanmakuVM:UpdateMoveSpeed()
end

function Class:OnGameEventOpenPrivateDanmakuChanged()
    if not ChatSetting.IsOpenPrivateDanmaku() then
        DanmakuVM:RemoveWaitingMsg(DanmakuType.PrivateChat)
    end
end

function Class:OnGameEventOpenTeamDanmakuChanged()
    if not ChatSetting.IsOpenTeamDanmaku() then
        DanmakuVM:RemoveWaitingMsg(DanmakuType.TeamChat)
    end
end

function Class:AddDanmakuInternal(Content, Type)
    if string.isnilorempty(Content) then
        return
    end

    DanmakuVM:AddMessage(Content, Type)
end

-------------------------------------------------------------------------------------------------------
--- Public API 

function Class:ClearAllDanmakuMsg()
    DanmakuVM:ClearAllMsg()
end

--- 添加私聊弹幕
--- @param Content string @弹幕内容
function Class:AddDanmakuPrivateChat(Content)
    self:AddDanmakuInternal(Content, DanmakuType.PrivateChat)
end

--- 添加队伍频道聊天消息弹幕
--- @param Content string @弹幕内容
function Class:AddDanmakuTeamChat(Content)
    self:AddDanmakuInternal(Content, DanmakuType.TeamChat)
end

return Class