--
-- Author: anypkvcai
-- Date: 2022-05-05 12:23
-- Description:
--

local LuaClass = require("Core/LuaClass")
local ChatChannelVM = require("Game/Chat/VM/ChannelVM/ChatChannelVM")
local ArmyMgr = require("Game/Army/ArmyMgr")

---@class ChatChannelArmyVM : ChatChannelVM
local ChatChannelArmyVM = LuaClass(ChatChannelVM)

---Ctor
function ChatChannelArmyVM:Ctor()
end

---GetChannelID
function ChatChannelArmyVM:GetChannelID()
	return ArmyMgr.SelfArmyID or 0
end

function ChatChannelArmyVM:IsNeedPull()
	return ArmyMgr:IsInArmy()
end

function ChatChannelArmyVM:IsNeedActive()
	return ArmyMgr:IsInArmy()
end

function ChatChannelArmyVM:CheckGoToVisible()
	return ArmyMgr:IsInArmy()
end

function ChatChannelArmyVM:GetChatBarWidgetVisible()
	return ArmyMgr:IsInArmy()
end

return ChatChannelArmyVM