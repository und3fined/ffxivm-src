---
--- Author: lydianwang
--- DateTime: 2022-01-11
---

local LuaClass = require("Core/LuaClass")
local TargetBase = require("Game/Quest/BasicClass/TargetBase")

local ALL_CHANNEL = -1

---@class TargetChat
local TargetChat = LuaClass(TargetBase, true)

function TargetChat:Ctor(_, Properties)
    self.ChannelType = tonumber(Properties[1]) - 1 -- 减一原因见蓝图枚举EChatChannelType
    self.PatternStrList = string.split(Properties[2], "|")
    self.MatchRule = tonumber(Properties[3]) -- 蓝图枚举EChatMatchRule
    self.NpcID = tonumber(Properties[4] or "0")
end

function TargetChat:DoStartTarget()
    self:RegisterEvent(_G.EventID.OnSendChat, self.OnEventSendChat)
end

function TargetChat:OnEventSendChat(ChannelType, Content)
	if (self.ChannelType == ChannelType) or (self.ChannelType == ALL_CHANNEL) then
		local bAllMatched = false

		for _, PatternStr in ipairs(self.PatternStrList) do
            if self.MatchRule == 0 then -- 包含
                bAllMatched = (string.match(Content, PatternStr) ~= nil)
            elseif self.MatchRule == 1 then -- 完全相同
                bAllMatched = (Content == PatternStr)
            end
			if not bAllMatched then break end
		end

		if bAllMatched then
			_G.QuestMgr:SendFinishTarget(self.QuestID, self.TargetID)
		end
	end
end

return TargetChat